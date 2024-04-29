--------------------------------------------------------
--  DDL for Package Body OKC_SRE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_SRE_PVT" AS
/* $Header: OKCSSREB.pls 120.0 2005/05/26 09:48:48 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
    l_id Number;
-- for customer's data (for non-seeded date id should be 50000 or above)
    cursor nonseed_c is
      select
         OKC_SUBCLASS_ROLES_S1.nextval
      from
         dual;
-- for datamerge's data (for seeded date id should be greater than or equal to 11000 and less than 50000)
    cursor seed_c is
      select
	 nvl(max(id), 11000) + 1
      from
         OKC_SUBCLASS_ROLES_V
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
    SELECT OKC_SUBCLASS_ROLES_S1.nextval
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
  -- FUNCTION get_rec for: OKC_SUBCLASS_ROLES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sre_rec                      IN sre_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sre_rec_type IS
    CURSOR sre_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SCS_CODE,
            RLE_CODE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            START_DATE,
            END_DATE,
            ACCESS_LEVEL
      FROM Okc_Subclass_Roles
     WHERE okc_subclass_roles.id = p_id;
    l_sre_pk                       sre_pk_csr%ROWTYPE;
    l_sre_rec                      sre_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sre_pk_csr (p_sre_rec.id);
    FETCH sre_pk_csr INTO
              l_sre_rec.ID,
              l_sre_rec.SCS_CODE,
              l_sre_rec.RLE_CODE,
              l_sre_rec.OBJECT_VERSION_NUMBER,
              l_sre_rec.CREATED_BY,
              l_sre_rec.CREATION_DATE,
              l_sre_rec.LAST_UPDATED_BY,
              l_sre_rec.LAST_UPDATE_DATE,
              l_sre_rec.LAST_UPDATE_LOGIN,
              l_sre_rec.START_DATE,
              l_sre_rec.END_DATE,
              l_sre_rec.ACCESS_LEVEL;
    x_no_data_found := sre_pk_csr%NOTFOUND;
    CLOSE sre_pk_csr;
    RETURN(l_sre_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sre_rec                      IN sre_rec_type
  ) RETURN sre_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sre_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_SUBCLASS_ROLES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_srev_rec                     IN srev_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN srev_rec_type IS
    CURSOR okc_srev_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            RLE_CODE,
            SCS_CODE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            START_DATE,
            END_DATE,
            ACCESS_LEVEL
      FROM Okc_Subclass_Roles_V
     WHERE okc_subclass_roles_v.id = p_id;
    l_okc_srev_pk                  okc_srev_pk_csr%ROWTYPE;
    l_srev_rec                     srev_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_srev_pk_csr (p_srev_rec.id);
    FETCH okc_srev_pk_csr INTO
              l_srev_rec.ID,
              l_srev_rec.OBJECT_VERSION_NUMBER,
              l_srev_rec.RLE_CODE,
              l_srev_rec.SCS_CODE,
              l_srev_rec.CREATED_BY,
              l_srev_rec.CREATION_DATE,
              l_srev_rec.LAST_UPDATED_BY,
              l_srev_rec.LAST_UPDATE_DATE,
              l_srev_rec.LAST_UPDATE_LOGIN,
              l_srev_rec.START_DATE,
              l_srev_rec.END_DATE,
              l_srev_rec.ACCESS_LEVEL;
    x_no_data_found := okc_srev_pk_csr%NOTFOUND;
    CLOSE okc_srev_pk_csr;
    RETURN(l_srev_rec);
  END get_rec;

  FUNCTION get_rec (
    p_srev_rec                     IN srev_rec_type
  ) RETURN srev_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_srev_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_SUBCLASS_ROLES_V --
  ----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_srev_rec	IN srev_rec_type
  ) RETURN srev_rec_type IS
    l_srev_rec	srev_rec_type := p_srev_rec;
  BEGIN
    IF (l_srev_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_srev_rec.object_version_number := NULL;
    END IF;
    IF (l_srev_rec.rle_code = OKC_API.G_MISS_CHAR) THEN
      l_srev_rec.rle_code := NULL;
    END IF;
    IF (l_srev_rec.scs_code = OKC_API.G_MISS_CHAR) THEN
      l_srev_rec.scs_code := NULL;
    END IF;
    IF (l_srev_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_srev_rec.created_by := NULL;
    END IF;
    IF (l_srev_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_srev_rec.creation_date := NULL;
    END IF;
    IF (l_srev_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_srev_rec.last_updated_by := NULL;
    END IF;
    IF (l_srev_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_srev_rec.last_update_date := NULL;
    END IF;
    IF (l_srev_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_srev_rec.last_update_login := NULL;
    END IF;
    IF (l_srev_rec.start_date = OKC_API.G_MISS_DATE) THEN
      l_srev_rec.start_date := NULL;
    END IF;
    IF (l_srev_rec.end_date = OKC_API.G_MISS_DATE) THEN
      l_srev_rec.end_date := NULL;
    END IF;
    IF (l_srev_rec.access_level = OKC_API.G_MISS_CHAR) THEN
      l_srev_rec.access_level := NULL;
    END IF;
    RETURN(l_srev_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------------------
  --Attribute Level Validattion Procedures Starts(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id(
    p_srev_rec          IN srev_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_srev_rec.id = OKC_API.G_MISS_NUM OR
       p_srev_rec.id IS NULL
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
    p_srev_rec          IN srev_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_srev_rec.object_version_number = OKC_API.G_MISS_NUM OR
       p_srev_rec.object_version_number IS NULL
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
  -- PROCEDURE Validate_rle_code
  ---------------------------------------------------------------------------
  PROCEDURE validate_rle_code(
    p_srev_rec          IN srev_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_srev_rec.rle_code = OKC_API.G_MISS_CHAR OR
       p_srev_rec.rle_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'rle_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_rle_code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_scs_code
  ---------------------------------------------------------------------------
  PROCEDURE validate_scs_code(
    p_srev_rec          IN srev_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_srev_rec.scs_code = OKC_API.G_MISS_CHAR OR
       p_srev_rec.scs_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'scs_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_scs_code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_start_date
  ---------------------------------------------------------------------------
  PROCEDURE validate_start_date(
    p_srev_rec          IN srev_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_srev_rec.start_date = OKC_API.G_MISS_DATE OR
       p_srev_rec.start_date IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'start_date');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_start_date;
 --------------------------------------------------------------------------
  -- PROCEDURE validate_access_level
  ---------------------------------------------------------------------------
  PROCEDURE validate_access_level(
    p_srev_rec          IN srev_rec_type,
    x_return_status  OUT NOCOPY  VARCHAR2) IS
  BEGIN
    x_return_status :=OKC_API.G_RET_STS_SUCCESS;

    IF (p_srev_rec.access_level = OKC_API.G_MISS_CHAR OR
        p_srev_rec.access_level IS NULL)
    THEN

       raise G_EXCEPTION_HALT_VALIDATION;
     END IF;
     IF upper(p_srev_rec.access_level) not in ('S','E','U') Then
         OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                                 p_msg_name     => g_invalid_value,
                                 p_token1       => g_col_name_token,
                                 p_token1_value => 'Access Level');
          x_return_status :=OKC_API.G_RET_STS_ERROR;
      End If;
   exception
    when  G_EXCEPTION_HALT_VALIDATION then
         null;
    when OTHERS then
         OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                                 p_msg_name     => g_unexpected_error,
                                 p_token1       => g_sqlcode_token,
                                 p_token1_value => sqlcode,
                                 p_token2       => g_sqlerrm_token,
                                 p_token2_value => sqlerrm );
         x_return_status :=OKC_API.G_RET_STS_UNEXP_ERROR;

 END validate_access_level;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- Validate_Attributes for:OKC_SUBCLASS_ROLES_V --
  --------------------------------------------------
  FUNCTION Validate_Attributes (
    p_srev_rec IN  srev_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  ---------------------------------------------------------------------------------------
  --Attribute Level Validation Procedure Calls Starts(Modification on TAPI generated Code.
  ---------------------------------------------------------------------------------------
  BEGIN
    VALIDATE_id(p_srev_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_object_version_number(p_srev_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_rle_code(p_srev_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_scs_code(p_srev_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_start_date(p_srev_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_access_level(p_srev_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
    RETURN(x_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      return(x_return_status);
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      return(x_return_status);
  ---------------------------------------------------------------------------------------
  --Attribute Level Validation Procedure Calls Ends(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Record for:OKC_SUBCLASS_ROLES_V --
  ----------------------------------------------
  FUNCTION Validate_Record (
    p_srev_rec IN srev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_srev_rec IN srev_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_scsv_pk_csr (p_code               IN VARCHAR2) IS
      SELECT 'x'
        FROM Okc_Subclasses_V
       WHERE okc_subclasses_v.code = p_code;
      CURSOR fnd_lookups_pk_csr (p_lookup_code        IN VARCHAR2) IS
      SELECT 'x'
        FROM Fnd_Lookups
       WHERE fnd_lookups.lookup_code = p_lookup_code
         AND fnd_lookups.lookup_type = 'OKC_ROLE';
      l_dummy                        VARCHAR2(1);
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_srev_rec.SCS_CODE IS NOT NULL)
      THEN
        OPEN okc_scsv_pk_csr(p_srev_rec.SCS_CODE);
        FETCH okc_scsv_pk_csr INTO l_dummy;
        l_row_notfound := okc_scsv_pk_csr%NOTFOUND;
        CLOSE okc_scsv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SCS_CODE');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_srev_rec.RLE_CODE IS NOT NULL)
      THEN
        OPEN fnd_lookups_pk_csr(p_srev_rec.RLE_CODE);
        FETCH fnd_lookups_pk_csr INTO l_dummy;
        l_row_notfound := fnd_lookups_pk_csr%NOTFOUND;
        CLOSE fnd_lookups_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'RLE_CODE');
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
      p_srev_rec IN srev_rec_type
    ) RETURN VARCHAR2 IS
      unique_key_error          EXCEPTION;
      CURSOR c1 (p_id IN okc_subclass_roles_v.id%TYPE,
                 p_scs_code IN okc_subclass_roles_v.scs_code%TYPE,
                 p_rle_code IN okc_subclass_roles_v.rle_code%TYPE) IS
      SELECT 'x'
        FROM Okc_Subclass_Roles_V
       WHERE scs_code = p_scs_code
         AND rle_code = p_rle_code
         AND ((p_id IS NULL)
          OR  (p_id IS NOT NULL
         AND   id <> p_id));
      l_dummy                        VARCHAR2(1);
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_found                    BOOLEAN := FALSE;
    BEGIN
      IF (p_srev_rec.SCS_CODE IS NOT NULL AND
          p_srev_rec.RLE_CODE IS NOT NULL) THEN
        OPEN c1(p_srev_rec.ID,
                p_srev_rec.SCS_CODE,
                p_srev_rec.RLE_CODE);
        FETCH c1 INTO l_dummy;
        l_row_found := c1%FOUND;
        CLOSE c1;
        IF (l_row_found) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'SCS_CODE');
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'RLE_CODE');
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
    IF p_srev_rec.start_date IS NOT NULL AND
       p_srev_rec.end_date IS NOT NULL THEN
      IF p_srev_rec.end_date < p_srev_rec.start_date THEN
        OKC_API.set_message(G_APP_NAME, 'OKC_INVALID_END_DATE');
        l_return_status := OKC_API.G_RET_STS_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
    l_return_status := validate_foreign_keys (p_srev_rec);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    l_return_status := validate_unique_keys (p_srev_rec);
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
    p_from	IN srev_rec_type,
    p_to	OUT NOCOPY sre_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.scs_code := p_from.scs_code;
    p_to.rle_code := p_from.rle_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.access_level := p_from.access_level;
  END migrate;
  PROCEDURE migrate (
    p_from	IN sre_rec_type,
    p_to	IN OUT NOCOPY srev_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.scs_code := p_from.scs_code;
    p_to.rle_code := p_from.rle_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.access_level := p_from.access_level;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- validate_row for:OKC_SUBCLASS_ROLES_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_rec                     IN srev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srev_rec                     srev_rec_type := p_srev_rec;
    l_sre_rec                      sre_rec_type;
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
    l_return_status := Validate_Attributes(l_srev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_srev_rec);
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
  -- PL/SQL TBL validate_row for:SREV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_tbl                     IN srev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_srev_tbl.COUNT > 0) THEN
      i := p_srev_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_srev_rec                     => p_srev_tbl(i));
        EXIT WHEN (i = p_srev_tbl.LAST);
        i := p_srev_tbl.NEXT(i);
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
  ---------------------------------------
  -- insert_row for:OKC_SUBCLASS_ROLES --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sre_rec                      IN sre_rec_type,
    x_sre_rec                      OUT NOCOPY sre_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ROLES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sre_rec                      sre_rec_type := p_sre_rec;
    l_def_sre_rec                  sre_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKC_SUBCLASS_ROLES --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_sre_rec IN  sre_rec_type,
      x_sre_rec OUT NOCOPY sre_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sre_rec := p_sre_rec;
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
      p_sre_rec,                         -- IN
      l_sre_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_SUBCLASS_ROLES(
        id,
        scs_code,
        rle_code,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        start_date,
        end_date,
        access_level)
      VALUES (
        l_sre_rec.id,
        l_sre_rec.scs_code,
        l_sre_rec.rle_code,
        l_sre_rec.object_version_number,
        l_sre_rec.created_by,
        l_sre_rec.creation_date,
        l_sre_rec.last_updated_by,
        l_sre_rec.last_update_date,
        l_sre_rec.last_update_login,
        l_sre_rec.start_date,
        l_sre_rec.end_date,
        l_sre_rec.access_level);
    -- Set OUT values
    x_sre_rec := l_sre_rec;
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
  -----------------------------------------
  -- insert_row for:OKC_SUBCLASS_ROLES_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_rec                     IN srev_rec_type,
    x_srev_rec                     OUT NOCOPY srev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srev_rec                     srev_rec_type;
    l_def_srev_rec                 srev_rec_type;
    l_sre_rec                      sre_rec_type;
    lx_sre_rec                     sre_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_srev_rec	IN srev_rec_type
    ) RETURN srev_rec_type IS
      l_srev_rec	srev_rec_type := p_srev_rec;
    BEGIN
      l_srev_rec.CREATION_DATE := SYSDATE;
      l_srev_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_srev_rec.LAST_UPDATE_DATE := l_srev_rec.CREATION_DATE;
      l_srev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_srev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_srev_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKC_SUBCLASS_ROLES_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_srev_rec IN  srev_rec_type,
      x_srev_rec OUT NOCOPY srev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_srev_rec := p_srev_rec;
      x_srev_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_srev_rec := null_out_defaults(p_srev_rec);
    -- Set primary key value
    l_srev_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_srev_rec,                        -- IN
      l_def_srev_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_srev_rec := fill_who_columns(l_def_srev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_srev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_srev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_srev_rec, l_sre_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sre_rec,
      lx_sre_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sre_rec, l_def_srev_rec);
    -- Set OUT values
    x_srev_rec := l_def_srev_rec;
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
  -- PL/SQL TBL insert_row for:SREV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_tbl                     IN srev_tbl_type,
    x_srev_tbl                     OUT NOCOPY srev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_srev_tbl.COUNT > 0) THEN
      i := p_srev_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_srev_rec                     => p_srev_tbl(i),
          x_srev_rec                     => x_srev_tbl(i));
        EXIT WHEN (i = p_srev_tbl.LAST);
        i := p_srev_tbl.NEXT(i);
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
  -------------------------------------
  -- lock_row for:OKC_SUBCLASS_ROLES --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sre_rec                      IN sre_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_sre_rec IN sre_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_SUBCLASS_ROLES
     WHERE ID = p_sre_rec.id
       AND OBJECT_VERSION_NUMBER = p_sre_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_sre_rec IN sre_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_SUBCLASS_ROLES
    WHERE ID = p_sre_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ROLES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_SUBCLASS_ROLES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_SUBCLASS_ROLES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_sre_rec);
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
      OPEN lchk_csr(p_sre_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_sre_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_sre_rec.object_version_number THEN
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
  ---------------------------------------
  -- lock_row for:OKC_SUBCLASS_ROLES_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_rec                     IN srev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sre_rec                      sre_rec_type;
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
    migrate(p_srev_rec, l_sre_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sre_rec
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
  -- PL/SQL TBL lock_row for:SREV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_tbl                     IN srev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_srev_tbl.COUNT > 0) THEN
      i := p_srev_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_srev_rec                     => p_srev_tbl(i));
        EXIT WHEN (i = p_srev_tbl.LAST);
        i := p_srev_tbl.NEXT(i);
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
  ---------------------------------------
  -- update_row for:OKC_SUBCLASS_ROLES --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sre_rec                      IN sre_rec_type,
    x_sre_rec                      OUT NOCOPY sre_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ROLES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sre_rec                      sre_rec_type := p_sre_rec;
    l_def_sre_rec                  sre_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sre_rec	IN sre_rec_type,
      x_sre_rec	OUT NOCOPY sre_rec_type
    ) RETURN VARCHAR2 IS
      l_sre_rec                      sre_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sre_rec := p_sre_rec;
      -- Get current database values
      l_sre_rec := get_rec(p_sre_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sre_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_sre_rec.id := l_sre_rec.id;
      END IF;
      IF (x_sre_rec.scs_code = OKC_API.G_MISS_CHAR)
      THEN
        x_sre_rec.scs_code := l_sre_rec.scs_code;
      END IF;
      IF (x_sre_rec.rle_code = OKC_API.G_MISS_CHAR)
      THEN
        x_sre_rec.rle_code := l_sre_rec.rle_code;
      END IF;
      IF (x_sre_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sre_rec.object_version_number := l_sre_rec.object_version_number;
      END IF;
      IF (x_sre_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sre_rec.created_by := l_sre_rec.created_by;
      END IF;
      IF (x_sre_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sre_rec.creation_date := l_sre_rec.creation_date;
      END IF;
      IF (x_sre_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sre_rec.last_updated_by := l_sre_rec.last_updated_by;
      END IF;
      IF (x_sre_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sre_rec.last_update_date := l_sre_rec.last_update_date;
      END IF;
      IF (x_sre_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sre_rec.last_update_login := l_sre_rec.last_update_login;
      END IF;
      IF (x_sre_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_sre_rec.start_date := l_sre_rec.start_date;
      END IF;
      IF (x_sre_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_sre_rec.end_date := l_sre_rec.end_date;
      END IF;
      IF (x_sre_rec.access_level = OKC_API.G_MISS_CHAR)
      THEN
        x_sre_rec.access_level := l_sre_rec.access_level;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKC_SUBCLASS_ROLES --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_sre_rec IN  sre_rec_type,
      x_sre_rec OUT NOCOPY sre_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sre_rec := p_sre_rec;
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
      p_sre_rec,                         -- IN
      l_sre_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sre_rec, l_def_sre_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_SUBCLASS_ROLES
    SET SCS_CODE = l_def_sre_rec.scs_code,
        RLE_CODE = l_def_sre_rec.rle_code,
        OBJECT_VERSION_NUMBER = l_def_sre_rec.object_version_number,
        CREATED_BY = l_def_sre_rec.created_by,
        CREATION_DATE = l_def_sre_rec.creation_date,
        LAST_UPDATED_BY = l_def_sre_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_sre_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_sre_rec.last_update_login,
        START_DATE = l_def_sre_rec.start_date,
        END_DATE = l_def_sre_rec.end_date,
        ACCESS_LEVEL = l_def_sre_rec.access_level
    WHERE ID = l_def_sre_rec.id;

    x_sre_rec := l_def_sre_rec;
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
  -----------------------------------------
  -- update_row for:OKC_SUBCLASS_ROLES_V --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_rec                     IN srev_rec_type,
    x_srev_rec                     OUT NOCOPY srev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srev_rec                     srev_rec_type := p_srev_rec;
    l_def_srev_rec                 srev_rec_type;
    l_sre_rec                      sre_rec_type;
    lx_sre_rec                     sre_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_srev_rec	IN srev_rec_type
    ) RETURN srev_rec_type IS
      l_srev_rec	srev_rec_type := p_srev_rec;
    BEGIN
      l_srev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_srev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_srev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_srev_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_srev_rec	IN srev_rec_type,
      x_srev_rec	OUT NOCOPY srev_rec_type
    ) RETURN VARCHAR2 IS
      l_srev_rec                     srev_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_srev_rec := p_srev_rec;
      -- Get current database values
      l_srev_rec := get_rec(p_srev_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_srev_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_srev_rec.id := l_srev_rec.id;
      END IF;
      IF (x_srev_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_srev_rec.object_version_number := l_srev_rec.object_version_number;
      END IF;
      IF (x_srev_rec.rle_code = OKC_API.G_MISS_CHAR)
      THEN
        x_srev_rec.rle_code := l_srev_rec.rle_code;
      END IF;
      IF (x_srev_rec.scs_code = OKC_API.G_MISS_CHAR)
      THEN
        x_srev_rec.scs_code := l_srev_rec.scs_code;
      END IF;
      IF (x_srev_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_srev_rec.created_by := l_srev_rec.created_by;
      END IF;
      IF (x_srev_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_srev_rec.creation_date := l_srev_rec.creation_date;
      END IF;
      IF (x_srev_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_srev_rec.last_updated_by := l_srev_rec.last_updated_by;
      END IF;
      IF (x_srev_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_srev_rec.last_update_date := l_srev_rec.last_update_date;
      END IF;
      IF (x_srev_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_srev_rec.last_update_login := l_srev_rec.last_update_login;
      END IF;
      IF (x_srev_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_srev_rec.start_date := l_srev_rec.start_date;
      END IF;
      IF (x_srev_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_srev_rec.end_date := l_srev_rec.end_date;
      END IF;
      IF (x_srev_rec.access_level = OKC_API.G_MISS_CHAR)
      THEN
        x_srev_rec.access_level := l_srev_rec.access_level;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKC_SUBCLASS_ROLES_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_srev_rec IN  srev_rec_type,
      x_srev_rec OUT NOCOPY srev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_srev_rec := p_srev_rec;
      x_srev_rec.OBJECT_VERSION_NUMBER := NVL(x_srev_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_srev_rec,                        -- IN
      l_srev_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_srev_rec, l_def_srev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_srev_rec := fill_who_columns(l_def_srev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_srev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_srev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_srev_rec, l_sre_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sre_rec,
      lx_sre_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sre_rec, l_def_srev_rec);
    x_srev_rec := l_def_srev_rec;
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
  -- PL/SQL TBL update_row for:SREV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_tbl                     IN srev_tbl_type,
    x_srev_tbl                     OUT NOCOPY srev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_srev_tbl.COUNT > 0) THEN
      i := p_srev_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_srev_rec                     => p_srev_tbl(i),
          x_srev_rec                     => x_srev_tbl(i));
        EXIT WHEN (i = p_srev_tbl.LAST);
        i := p_srev_tbl.NEXT(i);
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
  ---------------------------------------
  -- delete_row for:OKC_SUBCLASS_ROLES --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sre_rec                      IN sre_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ROLES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sre_rec                      sre_rec_type:= p_sre_rec;
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
    DELETE FROM OKC_SUBCLASS_ROLES
     WHERE ID = l_sre_rec.id;

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
  -----------------------------------------
  -- delete_row for:OKC_SUBCLASS_ROLES_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_rec                     IN srev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srev_rec                     srev_rec_type := p_srev_rec;
    l_sre_rec                      sre_rec_type;
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
    migrate(l_srev_rec, l_sre_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sre_rec
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
  -- PL/SQL TBL delete_row for:SREV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srev_tbl                     IN srev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_srev_tbl.COUNT > 0) THEN
      i := p_srev_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_srev_rec                     => p_srev_tbl(i));
        EXIT WHEN (i = p_srev_tbl.LAST);
        i := p_srev_tbl.NEXT(i);
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
END OKC_SRE_PVT;

/
