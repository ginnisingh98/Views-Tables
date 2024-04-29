--------------------------------------------------------
--  DDL for Package Body OKC_AST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_AST_PVT" AS
/* $Header: OKCSASTB.pls 120.1 2005/09/13 03:10:29 npalepu noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
   FUNCTION get_seq_id RETURN NUMBER IS
    l_id Number;
-- for datamerge's data (for seeded date id should be greater than or equal to
--11000 and less than 50000)
    cursor seed_c is
      select
         nvl(max(id), 11000) + 1
      from
         OKC_ASSENTS_V
      where
         id >= 11000 AND id < 50000;
  BEGIN
   if fnd_global.user_id = 1 then
      open seed_c;
      fetch seed_c into l_id;
      close seed_c;
      return(l_id);
   else
    RETURN(okc_p_util.raw_to_number(sys_guid()));
   end if;
  END get_Seq_id;

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
  -- FUNCTION get_rec for: OKC_ASSENTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ast_rec                      IN ast_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ast_rec_type IS
    CURSOR ast_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            STS_CODE,
            OPN_CODE,
            STE_CODE,
            SCS_CODE,
            ALLOWED_YN,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
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
            ATTRIBUTE15
      FROM Okc_Assents
     WHERE okc_assents.id       = p_id;
    l_ast_pk                       ast_pk_csr%ROWTYPE;
    l_ast_rec                      ast_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN ast_pk_csr (p_ast_rec.id);
    FETCH ast_pk_csr INTO
              l_ast_rec.ID,
              l_ast_rec.STS_CODE,
              l_ast_rec.OPN_CODE,
              l_ast_rec.STE_CODE,
              l_ast_rec.SCS_CODE,
              l_ast_rec.ALLOWED_YN,
              l_ast_rec.OBJECT_VERSION_NUMBER,
              l_ast_rec.CREATED_BY,
              l_ast_rec.CREATION_DATE,
              l_ast_rec.LAST_UPDATED_BY,
              l_ast_rec.LAST_UPDATE_DATE,
              l_ast_rec.LAST_UPDATE_LOGIN,
              l_ast_rec.ATTRIBUTE_CATEGORY,
              l_ast_rec.ATTRIBUTE1,
              l_ast_rec.ATTRIBUTE2,
              l_ast_rec.ATTRIBUTE3,
              l_ast_rec.ATTRIBUTE4,
              l_ast_rec.ATTRIBUTE5,
              l_ast_rec.ATTRIBUTE6,
              l_ast_rec.ATTRIBUTE7,
              l_ast_rec.ATTRIBUTE8,
              l_ast_rec.ATTRIBUTE9,
              l_ast_rec.ATTRIBUTE10,
              l_ast_rec.ATTRIBUTE11,
              l_ast_rec.ATTRIBUTE12,
              l_ast_rec.ATTRIBUTE13,
              l_ast_rec.ATTRIBUTE14,
              l_ast_rec.ATTRIBUTE15;
    x_no_data_found := ast_pk_csr%NOTFOUND;
    CLOSE ast_pk_csr;
    RETURN(l_ast_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ast_rec                      IN ast_rec_type
  ) RETURN ast_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ast_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_ASSENTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_astv_rec                     IN astv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN astv_rec_type IS
    CURSOR okc_astv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            STS_CODE,
            OPN_CODE,
            STE_CODE,
            SCS_CODE,
            OBJECT_VERSION_NUMBER,
            ALLOWED_YN,
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
      FROM Okc_Assents_V
     WHERE okc_assents_v.id     = p_id;
    l_okc_astv_pk                  okc_astv_pk_csr%ROWTYPE;
    l_astv_rec                     astv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_astv_pk_csr (p_astv_rec.id);
    FETCH okc_astv_pk_csr INTO
              l_astv_rec.ID,
              l_astv_rec.STS_CODE,
              l_astv_rec.OPN_CODE,
              l_astv_rec.STE_CODE,
              l_astv_rec.SCS_CODE,
              l_astv_rec.OBJECT_VERSION_NUMBER,
              l_astv_rec.ALLOWED_YN,
              l_astv_rec.ATTRIBUTE_CATEGORY,
              l_astv_rec.ATTRIBUTE1,
              l_astv_rec.ATTRIBUTE2,
              l_astv_rec.ATTRIBUTE3,
              l_astv_rec.ATTRIBUTE4,
              l_astv_rec.ATTRIBUTE5,
              l_astv_rec.ATTRIBUTE6,
              l_astv_rec.ATTRIBUTE7,
              l_astv_rec.ATTRIBUTE8,
              l_astv_rec.ATTRIBUTE9,
              l_astv_rec.ATTRIBUTE10,
              l_astv_rec.ATTRIBUTE11,
              l_astv_rec.ATTRIBUTE12,
              l_astv_rec.ATTRIBUTE13,
              l_astv_rec.ATTRIBUTE14,
              l_astv_rec.ATTRIBUTE15,
              l_astv_rec.CREATED_BY,
              l_astv_rec.CREATION_DATE,
              l_astv_rec.LAST_UPDATED_BY,
              l_astv_rec.LAST_UPDATE_DATE,
              l_astv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_astv_pk_csr%NOTFOUND;
    CLOSE okc_astv_pk_csr;
    RETURN(l_astv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_astv_rec                     IN astv_rec_type
  ) RETURN astv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_astv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_ASSENTS_V --
  ---------------------------------------------------
  FUNCTION null_out_defaults (
    p_astv_rec	IN astv_rec_type
  ) RETURN astv_rec_type IS
    l_astv_rec	astv_rec_type := p_astv_rec;
  BEGIN
    IF (l_astv_rec.sts_code = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.sts_code := NULL;
    END IF;
    IF (l_astv_rec.opn_code = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.opn_code := NULL;
    END IF;
    IF (l_astv_rec.ste_code = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.ste_code := NULL;
    END IF;
    IF (l_astv_rec.scs_code = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.scs_code := NULL;
    END IF;
    IF (l_astv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_astv_rec.object_version_number := NULL;
    END IF;
    IF (l_astv_rec.allowed_yn = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.allowed_yn := NULL;
    END IF;
    IF (l_astv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.attribute_category := NULL;
    END IF;
    IF (l_astv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.attribute1 := NULL;
    END IF;
    IF (l_astv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.attribute2 := NULL;
    END IF;
    IF (l_astv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.attribute3 := NULL;
    END IF;
    IF (l_astv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.attribute4 := NULL;
    END IF;
    IF (l_astv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.attribute5 := NULL;
    END IF;
    IF (l_astv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.attribute6 := NULL;
    END IF;
    IF (l_astv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.attribute7 := NULL;
    END IF;
    IF (l_astv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.attribute8 := NULL;
    END IF;
    IF (l_astv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.attribute9 := NULL;
    END IF;
    IF (l_astv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.attribute10 := NULL;
    END IF;
    IF (l_astv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.attribute11 := NULL;
    END IF;
    IF (l_astv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.attribute12 := NULL;
    END IF;
    IF (l_astv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.attribute13 := NULL;
    END IF;
    IF (l_astv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.attribute14 := NULL;
    END IF;
    IF (l_astv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_astv_rec.attribute15 := NULL;
    END IF;
    IF (l_astv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_astv_rec.created_by := NULL;
    END IF;
    IF (l_astv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_astv_rec.creation_date := NULL;
    END IF;
    IF (l_astv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_astv_rec.last_updated_by := NULL;
    END IF;
    IF (l_astv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_astv_rec.last_update_date := NULL;
    END IF;
    IF (l_astv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_astv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_astv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------------------
  --Attribute Level Validattion Procedures Starts(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id(
    p_astv_rec          IN astv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_astv_rec.id = OKC_API.G_MISS_NUM OR
       p_astv_rec.id IS NULL
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
  -- PROCEDURE Validate_sts_code
  ---------------------------------------------------------------------------
  PROCEDURE validate_sts_code(
    p_astv_rec          IN astv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_astv_rec.sts_code = OKC_API.G_MISS_CHAR OR
       p_astv_rec.sts_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sts_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_sts_code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_opn_code
  ---------------------------------------------------------------------------
  PROCEDURE validate_opn_code(
    p_astv_rec          IN astv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_astv_rec.opn_code = OKC_API.G_MISS_CHAR OR
       p_astv_rec.opn_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'opn_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_opn_code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_ste_code
  ---------------------------------------------------------------------------
  PROCEDURE validate_ste_code(
    p_astv_rec          IN astv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_astv_rec.ste_code = OKC_API.G_MISS_CHAR OR
       p_astv_rec.ste_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ste_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_ste_code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_scs_code
  ---------------------------------------------------------------------------
  PROCEDURE validate_scs_code(
    p_astv_rec          IN astv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_astv_rec.scs_code = OKC_API.G_MISS_CHAR OR
       p_astv_rec.scs_code IS NULL
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
  -- PROCEDURE Validate_object_version_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_object_version_number(
    p_astv_rec          IN astv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_astv_rec.object_version_number = OKC_API.G_MISS_NUM OR
       p_astv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
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
  END validate_object_version_number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_allowed_yn
  ---------------------------------------------------------------------------
  PROCEDURE validate_allowed_yn(
    p_astv_rec          IN astv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Check if allowed_yn is Not null, Y or N, and in upper case.
    IF p_astv_rec.allowed_yn = OKC_API.G_MISS_CHAR OR
       p_astv_rec.allowed_yn IS NULL THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'allowed_yn');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (UPPER(p_astv_rec.allowed_yn) IN ('Y', 'N')) THEN
      IF p_astv_rec.allowed_yn <> UPPER(p_astv_rec.allowed_yn) THEN
        OKC_API.set_message(G_APP_NAME, G_UPPERCASE_REQUIRED, G_COL_NAME_TOKEN, 'allowed_yn');
	l_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    ELSE
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'allowed_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
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

  END validate_allowed_yn;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- Validate_Attributes for:OKC_ASSENTS_V --
  -------------------------------------------
  FUNCTION Validate_Attributes (
    p_astv_rec IN  astv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
  ---------------------------------------------------------------------------------------
  --Attribute Level Validation Procedure Calls Starts(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------
    VALIDATE_id(p_astv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_sts_code(p_astv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_opn_code(p_astv_rec,l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_ste_code(p_astv_rec,l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_scs_code(p_astv_rec,l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_object_version_number(p_astv_rec,l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_allowed_yn(p_astv_rec,l_return_status);
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
  ---------------------------------------
  -- Validate_Record for:OKC_ASSENTS_V --
  ---------------------------------------
  FUNCTION Validate_Record (
    p_astv_rec IN astv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_astv_rec IN astv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      l_dummy VARCHAR2(1);
      CURSOR okc_stsv_pk_csr (p_code               IN VARCHAR2) IS
      SELECT 'x'
        FROM Okc_Statuses_V
       WHERE okc_statuses_v.code  = p_code;
      CURSOR okc_iopv_pk_csr (p_opn_code           IN VARCHAR2,
                              p_ste_code           IN VARCHAR2) IS
      SELECT 'x'
        FROM Okc_Included_Operations_V
       WHERE okc_included_operations_v.ste_code = p_ste_code
         AND okc_included_operations_v.opn_code = p_opn_code;
      CURSOR okc_scsv_pk_csr (p_code               IN VARCHAR2) IS
      SELECT 'x'
        FROM Okc_Subclasses_V
       WHERE okc_subclasses_v.code = p_code;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_astv_rec.STS_CODE IS NOT NULL)
      THEN
        OPEN okc_stsv_pk_csr(p_astv_rec.STS_CODE);
        FETCH okc_stsv_pk_csr INTO l_dummy;
        l_row_notfound := okc_stsv_pk_csr%NOTFOUND;
        CLOSE okc_stsv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'STS_CODE');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF ((p_astv_rec.OPN_CODE IS NOT NULL) AND
          (p_astv_rec.STE_CODE IS NOT NULL))
      THEN
        OPEN okc_iopv_pk_csr(p_astv_rec.OPN_CODE,
                             p_astv_rec.STE_CODE);
        FETCH okc_iopv_pk_csr INTO l_dummy;
        l_row_notfound := okc_iopv_pk_csr%NOTFOUND;
        CLOSE okc_iopv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'OPN_CODE');
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'STE_CODE');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_astv_rec.SCS_CODE IS NOT NULL)
      THEN
        OPEN okc_scsv_pk_csr(p_astv_rec.SCS_CODE);
        FETCH okc_scsv_pk_csr INTO l_dummy;
        l_row_notfound := okc_scsv_pk_csr%NOTFOUND;
        CLOSE okc_scsv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'SCS_CODE');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
    ------------------------------------
    -- FUNCTION validate_unique_keys --
    ------------------------------------
    FUNCTION validate_unique_keys (
      p_astv_rec IN astv_rec_type
    ) RETURN VARCHAR2 IS
      unique_key_error          EXCEPTION;
      l_dummy                   VARCHAR2(1);
      l_row_found               BOOLEAN;
      l_return_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      CURSOR c1 (p_id       IN okc_assents_v.id%TYPE,
                 p_scs_code IN okc_assents_v.scs_code%TYPE,
                 p_sts_code IN okc_assents_v.sts_code%TYPE,
                 p_opn_code IN okc_assents_v.opn_code%TYPE,
                 p_ste_code IN okc_assents_v.ste_code%TYPE) IS
      SELECT 'x'
        FROM Okc_Assents_V
       WHERE scs_code = p_scs_code
         AND sts_code = p_sts_code
         AND opn_code = p_opn_code
         AND ste_code = p_ste_code
         AND ((p_id IS NULL)
          OR  (p_id IS NOT NULL
         AND   id <> p_id));
    BEGIN
      OPEN c1(p_astv_rec.id,
              p_astv_rec.scs_code,
              p_astv_rec.sts_code,
              p_astv_rec.opn_code,
              p_astv_rec.ste_code);
      FETCH c1 INTO l_dummy;
      l_row_found := c1%FOUND;
      CLOSE c1;
      IF (l_row_found) THEN
	     OKC_API.set_message(G_APP_NAME, 'OKC_DUPLICATE_STS_OPN');
          --old code OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'SCS_CODE');
          --old code   OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'STS_CODE');
          --old code  OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'OPN_CODE');
          --old code  OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'STE_CODE');
        RAISE unique_key_error;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN unique_key_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_unique_keys;
  BEGIN
    l_return_status := validate_foreign_keys (p_astv_rec);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    l_return_status := validate_unique_keys (p_astv_rec);
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
    p_from	IN astv_rec_type,
    p_to	OUT NOCOPY ast_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sts_code := p_from.sts_code;
    p_to.opn_code := p_from.opn_code;
    p_to.ste_code := p_from.ste_code;
    p_to.scs_code := p_from.scs_code;
    p_to.allowed_yn := p_from.allowed_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
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
  END migrate;
  PROCEDURE migrate (
    p_from	IN ast_rec_type,
    p_to	OUT NOCOPY astv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sts_code := p_from.sts_code;
    p_to.opn_code := p_from.opn_code;
    p_to.ste_code := p_from.ste_code;
    p_to.scs_code := p_from.scs_code;
    p_to.allowed_yn := p_from.allowed_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
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
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------
  -- validate_row for:OKC_ASSENTS_V --
  ------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_astv_rec                     IN astv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_astv_rec                     astv_rec_type := p_astv_rec;
    l_ast_rec                      ast_rec_type;
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
    l_return_status := Validate_Attributes(l_astv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_astv_rec);
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
  -- PL/SQL TBL validate_row for:ASTV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_astv_tbl                     IN astv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_astv_tbl.COUNT > 0) THEN
      i := p_astv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_astv_rec                     => p_astv_tbl(i));
        EXIT WHEN (i = p_astv_tbl.LAST);
        i := p_astv_tbl.NEXT(i);
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
  --------------------------------
  -- insert_row for:OKC_ASSENTS --
  --------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ast_rec                      IN ast_rec_type,
    x_ast_rec                      OUT NOCOPY ast_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ASSENTS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ast_rec                      ast_rec_type := p_ast_rec;
    l_def_ast_rec                  ast_rec_type;
    ------------------------------------
    -- Set_Attributes for:OKC_ASSENTS --
    ------------------------------------
    FUNCTION Set_Attributes (
      p_ast_rec IN  ast_rec_type,
      x_ast_rec OUT NOCOPY ast_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ast_rec := p_ast_rec;
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
      p_ast_rec,                         -- IN
      l_ast_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_ASSENTS(
        id,
        sts_code,
        opn_code,
        ste_code,
        scs_code,
        allowed_yn,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
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
        attribute15)
      VALUES (
        l_ast_rec.id,
        l_ast_rec.sts_code,
        l_ast_rec.opn_code,
        l_ast_rec.ste_code,
        l_ast_rec.scs_code,
        l_ast_rec.allowed_yn,
        l_ast_rec.object_version_number,
        l_ast_rec.created_by,
        l_ast_rec.creation_date,
        l_ast_rec.last_updated_by,
        l_ast_rec.last_update_date,
        l_ast_rec.last_update_login,
        l_ast_rec.attribute_category,
        l_ast_rec.attribute1,
        l_ast_rec.attribute2,
        l_ast_rec.attribute3,
        l_ast_rec.attribute4,
        l_ast_rec.attribute5,
        l_ast_rec.attribute6,
        l_ast_rec.attribute7,
        l_ast_rec.attribute8,
        l_ast_rec.attribute9,
        l_ast_rec.attribute10,
        l_ast_rec.attribute11,
        l_ast_rec.attribute12,
        l_ast_rec.attribute13,
        l_ast_rec.attribute14,
        l_ast_rec.attribute15);
    -- Set OUT values
    x_ast_rec := l_ast_rec;
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
  ----------------------------------
  -- insert_row for:OKC_ASSENTS_V --
  ----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_astv_rec                     IN astv_rec_type,
    x_astv_rec                     OUT NOCOPY astv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_astv_rec                     astv_rec_type;
    l_def_astv_rec                 astv_rec_type;
    l_ast_rec                      ast_rec_type;
    lx_ast_rec                     ast_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_astv_rec	IN astv_rec_type
    ) RETURN astv_rec_type IS
      l_astv_rec	astv_rec_type := p_astv_rec;
    BEGIN
      l_astv_rec.CREATION_DATE := SYSDATE;
      l_astv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_astv_rec.LAST_UPDATE_DATE := l_astv_rec.CREATION_DATE;
      l_astv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_astv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_astv_rec);
    END fill_who_columns;
    --------------------------------------
    -- Set_Attributes for:OKC_ASSENTS_V --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_astv_rec IN  astv_rec_type,
      x_astv_rec OUT NOCOPY astv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_astv_rec := p_astv_rec;
      x_astv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_astv_rec := null_out_defaults(p_astv_rec);
    -- Set primary key value
    l_astv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_astv_rec,                        -- IN
      l_def_astv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_astv_rec := fill_who_columns(l_def_astv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_astv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_astv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_astv_rec, l_ast_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ast_rec,
      lx_ast_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ast_rec, l_def_astv_rec);
    -- Set OUT values
    x_astv_rec := l_def_astv_rec;
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
  -- PL/SQL TBL insert_row for:ASTV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_astv_tbl                     IN astv_tbl_type,
    x_astv_tbl                     OUT NOCOPY astv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_astv_tbl.COUNT > 0) THEN
      i := p_astv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_astv_rec                     => p_astv_tbl(i),
          x_astv_rec                     => x_astv_tbl(i));
        EXIT WHEN (i = p_astv_tbl.LAST);
        i := p_astv_tbl.NEXT(i);
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
  ------------------------------
  -- lock_row for:OKC_ASSENTS --
  ------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ast_rec                      IN ast_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ast_rec IN ast_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_ASSENTS
     WHERE ID = p_ast_rec.id
       AND OBJECT_VERSION_NUMBER = p_ast_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_ast_rec IN ast_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_ASSENTS
    WHERE ID = p_ast_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ASSENTS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_ASSENTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_ASSENTS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_ast_rec);
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
      OPEN lchk_csr(p_ast_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ast_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ast_rec.object_version_number THEN
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
  --------------------------------
  -- lock_row for:OKC_ASSENTS_V --
  --------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_astv_rec                     IN astv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ast_rec                      ast_rec_type;
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
    migrate(p_astv_rec, l_ast_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ast_rec
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
  -- PL/SQL TBL lock_row for:ASTV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_astv_tbl                     IN astv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_astv_tbl.COUNT > 0) THEN
      i := p_astv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_astv_rec                     => p_astv_tbl(i));
        EXIT WHEN (i = p_astv_tbl.LAST);
        i := p_astv_tbl.NEXT(i);
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
  --------------------------------
  -- update_row for:OKC_ASSENTS --
  --------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ast_rec                      IN ast_rec_type,
    x_ast_rec                      OUT NOCOPY ast_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ASSENTS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ast_rec                      ast_rec_type := p_ast_rec;
    l_def_ast_rec                  ast_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ast_rec	IN ast_rec_type,
      x_ast_rec	OUT NOCOPY ast_rec_type
    ) RETURN VARCHAR2 IS
      l_ast_rec                      ast_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ast_rec := p_ast_rec;
      -- Get current database values
      l_ast_rec := get_rec(p_ast_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ast_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_ast_rec.id := l_ast_rec.id;
      END IF;
      IF (x_ast_rec.sts_code = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.sts_code := l_ast_rec.sts_code;
      END IF;
      IF (x_ast_rec.opn_code = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.opn_code := l_ast_rec.opn_code;
      END IF;
      IF (x_ast_rec.ste_code = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.ste_code := l_ast_rec.ste_code;
      END IF;
      IF (x_ast_rec.scs_code = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.scs_code := l_ast_rec.scs_code;
      END IF;
      IF (x_ast_rec.allowed_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.allowed_yn := l_ast_rec.allowed_yn;
      END IF;
      IF (x_ast_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_ast_rec.object_version_number := l_ast_rec.object_version_number;
      END IF;
      IF (x_ast_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_ast_rec.created_by := l_ast_rec.created_by;
      END IF;
      IF (x_ast_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_ast_rec.creation_date := l_ast_rec.creation_date;
      END IF;
      IF (x_ast_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_ast_rec.last_updated_by := l_ast_rec.last_updated_by;
      END IF;
      IF (x_ast_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ast_rec.last_update_date := l_ast_rec.last_update_date;
      END IF;
      IF (x_ast_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_ast_rec.last_update_login := l_ast_rec.last_update_login;
      END IF;
      IF (x_ast_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.attribute_category := l_ast_rec.attribute_category;
      END IF;
      IF (x_ast_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.attribute1 := l_ast_rec.attribute1;
      END IF;
      IF (x_ast_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.attribute2 := l_ast_rec.attribute2;
      END IF;
      IF (x_ast_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.attribute3 := l_ast_rec.attribute3;
      END IF;
      IF (x_ast_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.attribute4 := l_ast_rec.attribute4;
      END IF;
      IF (x_ast_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.attribute5 := l_ast_rec.attribute5;
      END IF;
      IF (x_ast_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.attribute6 := l_ast_rec.attribute6;
      END IF;
      IF (x_ast_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.attribute7 := l_ast_rec.attribute7;
      END IF;
      IF (x_ast_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.attribute8 := l_ast_rec.attribute8;
      END IF;
      IF (x_ast_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.attribute9 := l_ast_rec.attribute9;
      END IF;
      IF (x_ast_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.attribute10 := l_ast_rec.attribute10;
      END IF;
      IF (x_ast_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.attribute11 := l_ast_rec.attribute11;
      END IF;
      IF (x_ast_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.attribute12 := l_ast_rec.attribute12;
      END IF;
      IF (x_ast_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.attribute13 := l_ast_rec.attribute13;
      END IF;
      IF (x_ast_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.attribute14 := l_ast_rec.attribute14;
      END IF;
      IF (x_ast_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_ast_rec.attribute15 := l_ast_rec.attribute15;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------
    -- Set_Attributes for:OKC_ASSENTS --
    ------------------------------------
    FUNCTION Set_Attributes (
      p_ast_rec IN  ast_rec_type,
      x_ast_rec OUT NOCOPY ast_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ast_rec := p_ast_rec;
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
      p_ast_rec,                         -- IN
      l_ast_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ast_rec, l_def_ast_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_ASSENTS
    SET STS_CODE = l_def_ast_rec.sts_code,
        OPN_CODE = l_def_ast_rec.opn_code,
        STE_CODE = l_def_ast_rec.ste_code,
        SCS_CODE = l_def_ast_rec.scs_code,
        ALLOWED_YN = l_def_ast_rec.allowed_yn,
        OBJECT_VERSION_NUMBER = l_def_ast_rec.object_version_number,
        CREATED_BY = l_def_ast_rec.created_by,
        CREATION_DATE = l_def_ast_rec.creation_date,
        LAST_UPDATED_BY = l_def_ast_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ast_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ast_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_ast_rec.attribute_category,
        ATTRIBUTE1 = l_def_ast_rec.attribute1,
        ATTRIBUTE2 = l_def_ast_rec.attribute2,
        ATTRIBUTE3 = l_def_ast_rec.attribute3,
        ATTRIBUTE4 = l_def_ast_rec.attribute4,
        ATTRIBUTE5 = l_def_ast_rec.attribute5,
        ATTRIBUTE6 = l_def_ast_rec.attribute6,
        ATTRIBUTE7 = l_def_ast_rec.attribute7,
        ATTRIBUTE8 = l_def_ast_rec.attribute8,
        ATTRIBUTE9 = l_def_ast_rec.attribute9,
        ATTRIBUTE10 = l_def_ast_rec.attribute10,
        ATTRIBUTE11 = l_def_ast_rec.attribute11,
        ATTRIBUTE12 = l_def_ast_rec.attribute12,
        ATTRIBUTE13 = l_def_ast_rec.attribute13,
        ATTRIBUTE14 = l_def_ast_rec.attribute14,
        ATTRIBUTE15 = l_def_ast_rec.attribute15
    WHERE ID = l_def_ast_rec.id;

    x_ast_rec := l_def_ast_rec;
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
  ----------------------------------
  -- update_row for:OKC_ASSENTS_V --
  ----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_astv_rec                     IN astv_rec_type,
    x_astv_rec                     OUT NOCOPY astv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_astv_rec                     astv_rec_type := p_astv_rec;
    l_def_astv_rec                 astv_rec_type;
    l_ast_rec                      ast_rec_type;
    lx_ast_rec                     ast_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_astv_rec	IN astv_rec_type
    ) RETURN astv_rec_type IS
      l_astv_rec	astv_rec_type := p_astv_rec;
    BEGIN
      l_astv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_astv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_astv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_astv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_astv_rec	IN astv_rec_type,
      x_astv_rec	OUT NOCOPY astv_rec_type
    ) RETURN VARCHAR2 IS
      l_astv_rec                     astv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_astv_rec := p_astv_rec;
      -- Get current database values
      l_astv_rec := get_rec(p_astv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_astv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_astv_rec.id := l_astv_rec.id;
      END IF;
      IF (x_astv_rec.sts_code = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.sts_code := l_astv_rec.sts_code;
      END IF;
      IF (x_astv_rec.opn_code = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.opn_code := l_astv_rec.opn_code;
      END IF;
      IF (x_astv_rec.ste_code = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.ste_code := l_astv_rec.ste_code;
      END IF;
      IF (x_astv_rec.scs_code = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.scs_code := l_astv_rec.scs_code;
      END IF;
      IF (x_astv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_astv_rec.object_version_number := l_astv_rec.object_version_number;
      END IF;
      IF (x_astv_rec.allowed_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.allowed_yn := l_astv_rec.allowed_yn;
      END IF;
      IF (x_astv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.attribute_category := l_astv_rec.attribute_category;
      END IF;
      IF (x_astv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.attribute1 := l_astv_rec.attribute1;
      END IF;
      IF (x_astv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.attribute2 := l_astv_rec.attribute2;
      END IF;
      IF (x_astv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.attribute3 := l_astv_rec.attribute3;
      END IF;
      IF (x_astv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.attribute4 := l_astv_rec.attribute4;
      END IF;
      IF (x_astv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.attribute5 := l_astv_rec.attribute5;
      END IF;
      IF (x_astv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.attribute6 := l_astv_rec.attribute6;
      END IF;
      IF (x_astv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.attribute7 := l_astv_rec.attribute7;
      END IF;
      IF (x_astv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.attribute8 := l_astv_rec.attribute8;
      END IF;
      IF (x_astv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.attribute9 := l_astv_rec.attribute9;
      END IF;
      IF (x_astv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.attribute10 := l_astv_rec.attribute10;
      END IF;
      IF (x_astv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.attribute11 := l_astv_rec.attribute11;
      END IF;
      IF (x_astv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.attribute12 := l_astv_rec.attribute12;
      END IF;
      IF (x_astv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.attribute13 := l_astv_rec.attribute13;
      END IF;
      IF (x_astv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.attribute14 := l_astv_rec.attribute14;
      END IF;
      IF (x_astv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_astv_rec.attribute15 := l_astv_rec.attribute15;
      END IF;
      IF (x_astv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_astv_rec.created_by := l_astv_rec.created_by;
      END IF;
      IF (x_astv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_astv_rec.creation_date := l_astv_rec.creation_date;
      END IF;
      IF (x_astv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_astv_rec.last_updated_by := l_astv_rec.last_updated_by;
      END IF;
      IF (x_astv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_astv_rec.last_update_date := l_astv_rec.last_update_date;
      END IF;
      IF (x_astv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_astv_rec.last_update_login := l_astv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKC_ASSENTS_V --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_astv_rec IN  astv_rec_type,
      x_astv_rec OUT NOCOPY astv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_astv_rec := p_astv_rec;
      x_astv_rec.OBJECT_VERSION_NUMBER := NVL(x_astv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_astv_rec,                        -- IN
      l_astv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_astv_rec, l_def_astv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_astv_rec := fill_who_columns(l_def_astv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_astv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_astv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_astv_rec, l_ast_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ast_rec,
      lx_ast_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ast_rec, l_def_astv_rec);
    x_astv_rec := l_def_astv_rec;
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
  -- PL/SQL TBL update_row for:ASTV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_astv_tbl                     IN astv_tbl_type,
    x_astv_tbl                     OUT NOCOPY astv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_astv_tbl.COUNT > 0) THEN
      i := p_astv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_astv_rec                     => p_astv_tbl(i),
          x_astv_rec                     => x_astv_tbl(i));
        EXIT WHEN (i = p_astv_tbl.LAST);
        i := p_astv_tbl.NEXT(i);
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
  --------------------------------
  -- delete_row for:OKC_ASSENTS --
  --------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ast_rec                      IN ast_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ASSENTS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ast_rec                      ast_rec_type:= p_ast_rec;
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
    DELETE FROM OKC_ASSENTS
     WHERE ID = l_ast_rec.id;

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
  ----------------------------------
  -- delete_row for:OKC_ASSENTS_V --
  ----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_astv_rec                     IN astv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_astv_rec                     astv_rec_type := p_astv_rec;
    l_ast_rec                      ast_rec_type;
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
    migrate(l_astv_rec, l_ast_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ast_rec
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
  -- PL/SQL TBL delete_row for:ASTV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_astv_tbl                     IN astv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_astv_tbl.COUNT > 0) THEN
      i := p_astv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_astv_rec                     => p_astv_tbl(i));
        EXIT WHEN (i = p_astv_tbl.LAST);
        i := p_astv_tbl.NEXT(i);
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

  FUNCTION header_operation_allowed(
    p_header_id                    IN NUMBER,
    p_opn_code                     IN VARCHAR2,
    p_crt_id                       IN NUMBER ) return varchar2 IS
    l_dummy varchar2(1);
    l_row_found BOOLEAN;
    l_cr_locked BOOLEAN := FALSE;
    l_another_cr_locked BOOLEAN := FALSE;
    l_user_in_cr BOOLEAN := FALSE;
    l_return_status Varchar2(1);
    l_user_id okc_k_processes.user_id%TYPE;
    --NPALEPU for bug # 4597099 on 13-AUG-2005
    /* l_scs_code okc_k_headers_b.scs_code%TYPE;
    l_sts_code okc_k_headers_b.sts_code%TYPE; */
    l_scs_code okc_k_headers_all_b.scs_code%TYPE;
    l_sts_code okc_k_headers_all_b.sts_code%TYPE;
    --END NPALEPU
    l_cur_user okc_change_requests_b.user_id%TYPE := FND_GLOBAL.USER_ID;

    l_date_approved DATE;
    l_date_signed   DATE;
    --
    cursor hdr_csr is
    select sts_code, scs_code,date_approved, date_signed
    --NPALEPU for bug # 4597099 on 13-AUG-2005
    /* from okc_k_headers_b */
    from okc_k_headers_all_b
    --END NPALEPU
    where id = p_header_id;
    --
    cursor ast_csr (p_allowed_yn okc_assents_v.allowed_yn%TYPE) is
    select 'x'
      from okc_assents
     where scs_code = l_scs_code
       and sts_code = l_sts_code
       and opn_code = p_opn_code
       and allowed_yn = p_allowed_yn;
    --
    cursor lock_csr (p_in_process_yn okc_k_processes.in_process_yn%TYPE) is
    select prc.user_id
      from okc_k_processes prc,
           okc_change_requests_b crq
     where crq.id = p_crt_id
       and crq.chr_id = p_header_id
       and crq.datetime_applied is null
       and crq.id = prc.crt_id
       and upper(substr(prc.in_process_yn, 1, 1)) = p_in_process_yn;
    --
    cursor proc_csr (p_in_process_yn okc_k_processes.in_process_yn%TYPE) is
    select prc.user_id
      from okc_k_processes prc,
           okc_change_requests_b crq
     where crq.chr_id = p_header_id
       and crq.datetime_applied is null
       and crq.id = prc.crt_id
       and upper(substr(prc.in_process_yn, 1, 1)) = p_in_process_yn;
    --
    cursor user_csr is
    select 'x'
      from okc_change_requests_b crq
     where crq.id = p_crt_id
       and crq.chr_id = p_header_id
       and crq.datetime_applied is null
       and crq.user_id = l_cur_user;

  BEGIN
    open hdr_csr;
    fetch hdr_csr into l_sts_code, l_scs_code, l_date_approved, l_date_signed;
    close hdr_csr;
    l_row_found := true;
    if l_sts_code <> 'QA_HOLD' then
      open ast_csr('Y');
      fetch ast_csr into l_dummy;
      l_row_found := ast_csr%FOUND;
      close ast_csr;
    end if;
    if l_row_found then
      -- Special treatment for Update Online and Update via CR
      if p_opn_code = 'CHG_REQ' then
        if p_crt_id is null then
          -- p_crt_id null means the check is being done while creating
          -- a change request. So if the assent data allows that, simply
          -- return with true.
          l_return_status := OKC_API.G_TRUE;
        else
          -- Not null means the check is being done while applying a
          -- change request. Check whether the CR has been locked by the
          -- supplied p_crt_id.
          open lock_csr('Y');
          fetch lock_csr into l_user_id;
          l_cr_locked := lock_csr%FOUND;
          close lock_csr;
          if l_cr_locked then
            -- Check whether or not the current user is holding the key
            if l_user_id = l_cur_user then
              l_return_status := OKC_API.G_TRUE;
            else
              -- Current user does not hold the key, so return False.
              l_return_status := OKC_API.G_FALSE;
            end if;
          else
            -- If not locked by the supplied crt_id, check if locked by
            -- some other Change Request
            open proc_csr('Y');
            fetch proc_csr into l_user_id;
            l_another_cr_locked := proc_csr%FOUND;
            close proc_csr;
            -- If locked by some other CR, return false
            if l_another_cr_locked Then
              l_return_status := OKC_API.G_FALSE;
            else
              -- If not, check whether the current user is in the CR list
              -- for the given contract.
              open user_csr;
              fetch user_csr into l_dummy;
              l_user_in_cr := user_csr%FOUND;
              close user_csr;
              if l_user_in_cr Then
                -- The authoring form needs to issue the key to the user in this
                -- case, kind of overhead since it will have to do similar check.
			 if l_sts_code = 'QA_HOLD' then
                  l_return_status := OKC_API.G_FALSE;
			 else
                  l_return_status := OKC_API.G_TRUE;
			 end if;
              else
                l_return_status := OKC_API.G_FALSE;
              end if;
            end if;
          end if;
        end if;
      elsif p_opn_code = 'UPDATE' Then
        -- In case of Update Online, Check whether or not any CR
        -- has locked this contract
        open proc_csr('Y');
        fetch proc_csr into l_user_id;
        l_another_cr_locked := proc_csr%FOUND;
        close proc_csr;
        -- If locked by some CR, return true if locked by the current user
        if l_another_cr_locked Then
          if l_user_id = l_cur_user then
            l_return_status := OKC_API.G_TRUE;
          else
            l_return_status := OKC_API.G_FALSE;
          end if;
        else
		-- If the Contract is APPROVED, but not SIGNED, no updat allowed
		-- This is implemented to fix bug #1800071
          if l_date_approved is not null and l_date_signed is null then
		   l_return_status := OKC_API.G_FALSE;
		else
             -- otherwise, return true
             l_return_status := OKC_API.G_TRUE;
          end if;
        end if;
      else
        -- For all other operations, return True.
        l_return_status := OKC_API.G_TRUE;
      end if;
    else
      -- Do not allow the operation since no assent data exists.
      l_return_status := OKC_API.G_FALSE;
    end if;
    return(l_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN,
                          SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      Return(l_return_status);
  END header_operation_allowed;

  FUNCTION line_operation_allowed(
    p_line_id                     IN NUMBER,
    p_opn_code                    IN VARCHAR2) return varchar2 is
    l_dummy varchar2(1);
    l_row_notfound BOOLEAN;
    l_return_status Varchar2(1);
    l_lse_id okc_k_lines_v.lse_id%TYPE;
    cursor c1(p_allowed_yn okc_assents_v.allowed_yn%TYPE) is
    select 'x'
      from okc_k_lines_b L,
           --NPALEPU for Bug # 4597099 on 13-AUG-2005
           /* okc_k_headers_b K, */
           OKC_K_HEADERS_ALL_B K,
           --END NPALEPU
	   okc_assents A
     where L.ID = p_line_id
       and L.DNZ_CHR_ID = K.ID
       and A.SCS_CODE = K.SCS_CODE
       and A.STS_CODE = L.STS_CODE
       and A.OPN_CODE = p_opn_code
       and A.ALLOWED_YN = p_allowed_yn;
    cursor c2 is
    select lse_id
      from okc_k_lines_b
     where id = p_line_id
       and chr_id is not null;
    cursor c3 is
    select a.lse_id
      from okc_k_lines_b a,
           okc_ancestrys b
     where b.cle_id = p_line_id
       and b.level_sequence = 1
       and a.id = b.cle_id_ascendant;
    cursor c4(p_lse_id okc_val_line_operations_v.lse_id%TYPE) is
    select 'x'
      from okc_val_line_operations
     where lse_id = p_lse_id
       and opn_code = p_opn_code;
    operation_allowed     Exception;
    operation_not_allowed Exception;
    invalid_data          Exception;
  BEGIN
    --
    -- There are 2 steps to check whether or not an operation is allowed for a line.
    -- First make sure it is allowed from assent table, taking the subclass from the header.
    --
    Open c1('Y');
    Fetch c1 Into l_dummy;
    l_row_notfound := c1%NOTFOUND;
    Close c1;
    --
    -- If it is not allowed, return immediately.
    --
    If l_row_notfound Then
      Raise operation_not_allowed;
    End If;
    --
    -- If allowed, then in the next step, check whether or not that operation is
    -- valid for the top line style. To get the top line, if the chr_id is not null,
    -- that line itself is top line.
    --
    Open c2;
    Fetch c2 Into l_lse_id;
    l_row_notfound := c2%NOTFOUND;
    Close c2;
    --
    -- Otherwise we need to explore the ancestory table to get the top line.
    --
    If l_row_notfound Then
      Open c3;
      Fetch c3 Into l_lse_id;
      l_row_notfound := c3%NOTFOUND;
      Close c3;
      --
      -- We should be able to get the top line from here. If not, there is some invalid data.
      --
      If l_row_notfound Then
        Raise invalid_data;
      End If;
    End If;
    --
    -- Finally check from the valid line operation table,
    -- if the operation is valid for the top line style.
    --
    Open c4(l_lse_id);
    Fetch c4 Into l_dummy;
    l_row_notfound := c4%NOTFOUND;
    Close c4;
    If l_row_notfound Then
      Raise operation_not_allowed;
    Else
      Raise operation_allowed;
    End If;
  EXCEPTION
    WHEN operation_allowed THEN
      l_return_status := OKC_API.G_TRUE;
      Return(l_return_status);
    WHEN operation_not_allowed THEN
      l_return_status := OKC_API.G_FALSE;
      Return(l_return_status);
    WHEN invalid_data THEN
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'line_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
      Return(l_return_status);
    WHEN OTHERS THEN
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN,
                          SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      Return(l_return_status);
  END line_operation_allowed;

END OKC_AST_PVT;

/
