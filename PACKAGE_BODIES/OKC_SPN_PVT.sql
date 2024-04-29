--------------------------------------------------------
--  DDL for Package Body OKC_SPN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_SPN_PVT" AS
/* $Header: OKCSSPNB.pls 120.0 2005/05/26 09:51:28 appldev noship $ */

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
  -- FUNCTION get_rec for: OKC_SPAN
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_spn_rec                      IN spn_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN spn_rec_type IS
    CURSOR spn_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            TVE_ID,
            uom_code,
            SPN_ID,
            DURATION,
            ACTIVE_YN,
            NAME,
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
      FROM Okc_Span
     WHERE okc_span.id          = p_id;
    l_spn_pk                       spn_pk_csr%ROWTYPE;
    l_spn_rec                      spn_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN spn_pk_csr (p_spn_rec.id);
    FETCH spn_pk_csr INTO
              l_spn_rec.ID,
              l_spn_rec.TVE_ID,
              l_spn_rec.uom_code,
              l_spn_rec.SPN_ID,
              l_spn_rec.DURATION,
              l_spn_rec.ACTIVE_YN,
              l_spn_rec.NAME,
              l_spn_rec.OBJECT_VERSION_NUMBER,
              l_spn_rec.CREATED_BY,
              l_spn_rec.CREATION_DATE,
              l_spn_rec.LAST_UPDATED_BY,
              l_spn_rec.LAST_UPDATE_DATE,
              l_spn_rec.LAST_UPDATE_LOGIN,
              l_spn_rec.ATTRIBUTE_CATEGORY,
              l_spn_rec.ATTRIBUTE1,
              l_spn_rec.ATTRIBUTE2,
              l_spn_rec.ATTRIBUTE3,
              l_spn_rec.ATTRIBUTE4,
              l_spn_rec.ATTRIBUTE5,
              l_spn_rec.ATTRIBUTE6,
              l_spn_rec.ATTRIBUTE7,
              l_spn_rec.ATTRIBUTE8,
              l_spn_rec.ATTRIBUTE9,
              l_spn_rec.ATTRIBUTE10,
              l_spn_rec.ATTRIBUTE11,
              l_spn_rec.ATTRIBUTE12,
              l_spn_rec.ATTRIBUTE13,
              l_spn_rec.ATTRIBUTE14,
              l_spn_rec.ATTRIBUTE15;
    x_no_data_found := spn_pk_csr%NOTFOUND;
    CLOSE spn_pk_csr;
    RETURN(l_spn_rec);
  END get_rec;

  FUNCTION get_rec (
    p_spn_rec                      IN spn_rec_type
  ) RETURN spn_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_spn_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_SPAN_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_spnv_rec                     IN spnv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN spnv_rec_type IS
    CURSOR okc_spnv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            TVE_ID,
            uom_code,
            SPN_ID,
            NAME,
            DURATION,
            ACTIVE_YN,
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
      FROM Okc_Span_V
     WHERE okc_span_v.id        = p_id;
    l_okc_spnv_pk                  okc_spnv_pk_csr%ROWTYPE;
    l_spnv_rec                     spnv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_spnv_pk_csr (p_spnv_rec.id);
    FETCH okc_spnv_pk_csr INTO
              l_spnv_rec.ID,
              l_spnv_rec.OBJECT_VERSION_NUMBER,
              l_spnv_rec.TVE_ID,
              l_spnv_rec.uom_code,
              l_spnv_rec.SPN_ID,
              l_spnv_rec.NAME,
              l_spnv_rec.DURATION,
              l_spnv_rec.ACTIVE_YN,
              l_spnv_rec.ATTRIBUTE_CATEGORY,
              l_spnv_rec.ATTRIBUTE1,
              l_spnv_rec.ATTRIBUTE2,
              l_spnv_rec.ATTRIBUTE3,
              l_spnv_rec.ATTRIBUTE4,
              l_spnv_rec.ATTRIBUTE5,
              l_spnv_rec.ATTRIBUTE6,
              l_spnv_rec.ATTRIBUTE7,
              l_spnv_rec.ATTRIBUTE8,
              l_spnv_rec.ATTRIBUTE9,
              l_spnv_rec.ATTRIBUTE10,
              l_spnv_rec.ATTRIBUTE11,
              l_spnv_rec.ATTRIBUTE12,
              l_spnv_rec.ATTRIBUTE13,
              l_spnv_rec.ATTRIBUTE14,
              l_spnv_rec.ATTRIBUTE15,
              l_spnv_rec.CREATED_BY,
              l_spnv_rec.CREATION_DATE,
              l_spnv_rec.LAST_UPDATED_BY,
              l_spnv_rec.LAST_UPDATE_DATE,
              l_spnv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_spnv_pk_csr%NOTFOUND;
    CLOSE okc_spnv_pk_csr;
    RETURN(l_spnv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_spnv_rec                     IN spnv_rec_type
  ) RETURN spnv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_spnv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_SPAN_V --
  ------------------------------------------------
  FUNCTION null_out_defaults (
    p_spnv_rec	IN spnv_rec_type
  ) RETURN spnv_rec_type IS
    l_spnv_rec	spnv_rec_type := p_spnv_rec;
  BEGIN
    IF (l_spnv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_spnv_rec.object_version_number := NULL;
    END IF;
    IF (l_spnv_rec.tve_id = OKC_API.G_MISS_NUM) THEN
      l_spnv_rec.tve_id := NULL;
    END IF;
    IF (l_spnv_rec.uom_code = OKC_API.G_MISS_CHAR) THEN
      l_spnv_rec.uom_code := NULL;
    END IF;
    IF (l_spnv_rec.spn_id = OKC_API.G_MISS_NUM) THEN
      l_spnv_rec.spn_id := NULL;
    END IF;
    IF (l_spnv_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_spnv_rec.name := NULL;
    END IF;
    IF (l_spnv_rec.duration = OKC_API.G_MISS_NUM) THEN
      l_spnv_rec.duration := NULL;
    END IF;
    IF (l_spnv_rec.active_yn = OKC_API.G_MISS_CHAR) THEN
      l_spnv_rec.active_yn := NULL;
    END IF;
    IF (l_spnv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_spnv_rec.attribute_category := NULL;
    END IF;
    IF (l_spnv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_spnv_rec.attribute1 := NULL;
    END IF;
    IF (l_spnv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_spnv_rec.attribute2 := NULL;
    END IF;
    IF (l_spnv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_spnv_rec.attribute3 := NULL;
    END IF;
    IF (l_spnv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_spnv_rec.attribute4 := NULL;
    END IF;
    IF (l_spnv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_spnv_rec.attribute5 := NULL;
    END IF;
    IF (l_spnv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_spnv_rec.attribute6 := NULL;
    END IF;
    IF (l_spnv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_spnv_rec.attribute7 := NULL;
    END IF;
    IF (l_spnv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_spnv_rec.attribute8 := NULL;
    END IF;
    IF (l_spnv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_spnv_rec.attribute9 := NULL;
    END IF;
    IF (l_spnv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_spnv_rec.attribute10 := NULL;
    END IF;
    IF (l_spnv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_spnv_rec.attribute11 := NULL;
    END IF;
    IF (l_spnv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_spnv_rec.attribute12 := NULL;
    END IF;
    IF (l_spnv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_spnv_rec.attribute13 := NULL;
    END IF;
    IF (l_spnv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_spnv_rec.attribute14 := NULL;
    END IF;
    IF (l_spnv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_spnv_rec.attribute15 := NULL;
    END IF;
    IF (l_spnv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_spnv_rec.created_by := NULL;
    END IF;
    IF (l_spnv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_spnv_rec.creation_date := NULL;
    END IF;
    IF (l_spnv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_spnv_rec.last_updated_by := NULL;
    END IF;
    IF (l_spnv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_spnv_rec.last_update_date := NULL;
    END IF;
    IF (l_spnv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_spnv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_spnv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --**** Change from TAPI Code---follow till end of change---------------
  -- 1. Moved all column validations (including FK) to Validate_column
  -- and is called from Validate_Attributes
  -- 2. Validate_Records will have tuple rule checks.

  -----------------------------------------------------
  -- Validate_Attributes for:OKC_SPAN_V --
  -----------------------------------------------------

  PROCEDURE Validate_uom_code (
      x_return_status                OUT NOCOPY VARCHAR2,
      p_spnv_rec                     IN spnv_rec_type) IS
      item_not_found_error          EXCEPTION;
      l_row_notfound                 BOOLEAN := TRUE;
      CURSOR uom_pk_csr (p_uom_code IN okx_units_of_measure_v.uom_code%type) IS
      SELECT  '1'
        FROM OKC_Timeunit_v
       WHERE uom_code        = p_uom_code
         and nvl(inactive_date,trunc(sysdate)) >= trunc(sysdate);
      l_uom_pk                  uom_pk_csr%ROWTYPE;
    BEGIN
      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
      IF (p_spnv_rec.uom_code IS NOT NULL AND
          p_spnv_rec.uom_code <> OKC_API.G_MISS_CHAR)
      THEN
        OPEN uom_pk_csr(p_spnv_rec.uom_code);
        FETCH uom_pk_csr INTO l_uom_pk;
        l_row_notfound := uom_pk_csr%NOTFOUND;
        CLOSE uom_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'uom_code');
          RAISE item_not_found_error;
        END IF;
      ELSE
         OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'uom_code');
         x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    EXCEPTION
      WHEN item_not_found_error THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'uom_code',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Validate_uom_code ;

  PROCEDURE Validate_Spn_Id (
      x_return_status                OUT NOCOPY VARCHAR2,
      p_spnv_rec                     IN spnv_rec_type) IS
      item_not_found_error          EXCEPTION;
      l_row_notfound                 BOOLEAN := TRUE;
      CURSOR okc_spnv_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM Okc_Span
       WHERE id        = p_id;

  CURSOR l_unq_cur(p_spn_id NUMBER) IS
	    SELECT id FROM OKC_SPAN_V
	    WHERE  spn_id = p_spn_id;

    l_id                  NUMBER       := OKC_API.G_MISS_NUM;
    l_okc_spnv_pk         okc_spnv_pk_csr%ROWTYPE;
    BEGIN
      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
      IF (p_spnv_rec.SPN_ID IS NOT NULL AND
          p_spnv_rec.SPN_ID <> OKC_API.G_MISS_NUM)
      THEN
        OPEN okc_spnv_pk_csr(p_spnv_rec.SPN_ID);
        FETCH okc_spnv_pk_csr INTO l_okc_spnv_pk;
        l_row_notfound := okc_spnv_pk_csr%NOTFOUND;
        CLOSE okc_spnv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SPN_ID');
          RAISE item_not_found_error;
        END IF;
	   -- check for uniqueness
	   -- Bug 1699203 - Removed Check_Unique
	   OPEN l_unq_cur(p_spnv_rec.spn_id);
	   FETCH l_unq_cur INTO l_id;
	   CLOSE l_unq_cur;
	   IF (l_id <> OKC_API.G_MISS_NUM AND l_id <> nvl(p_spnv_rec.id,0)) THEN
		 x_return_status := OKC_API.G_RET_STS_ERROR;
		 OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME,
						 p_msg_name => 'OKC_DUP_SPN_ID');
        END IF;
	   /*
        OKC_UTIL.Check_Unique(p_view_name => 'OKC_SPAN_V',
                     p_col_name	=> 'SPN_ID',
                     p_col_value => p_spnv_rec.SPN_ID,
                     p_id => p_spnv_rec.ID,
                     x_return_status => x_return_status);*/

      END IF;
    EXCEPTION
      WHEN item_not_found_error THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'SPN_ID',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Validate_Spn_Id ;

  PROCEDURE Validate_Tve_Id (
      x_return_status                OUT NOCOPY VARCHAR2,
      p_spnv_rec                     IN spnv_rec_type) IS
      item_not_found_error          EXCEPTION;
      l_row_notfound                 BOOLEAN := TRUE;
      CURSOR okc_tvev_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM Okc_Timevalues
       WHERE id  = p_id
        and tve_type = 'CYL';
      l_okc_tvev_pk                  okc_tvev_pk_csr%ROWTYPE;
    BEGIN
      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
      IF (p_spnv_rec.TVE_ID IS NOT NULL AND
          p_spnv_rec.TVE_ID <> OKC_API.G_MISS_NUM)
      THEN
        OPEN okc_tvev_pk_csr(p_spnv_rec.TVE_ID);
        FETCH okc_tvev_pk_csr INTO l_okc_tvev_pk;
        l_row_notfound := okc_tvev_pk_csr%NOTFOUND;
        CLOSE okc_tvev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TVE_ID');
          RAISE item_not_found_error;
        END IF;
      ELSE
        OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'TVE_ID');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    EXCEPTION
      WHEN item_not_found_error THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'TVE_ID',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Validate_Tve_Id ;

  PROCEDURE Validate_Duration (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_spnv_rec                     IN spnv_rec_type) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_spnv_rec.duration = OKC_API.G_MISS_NUM OR
        p_spnv_rec.duration IS NULL) THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'duration');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
       OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'DURATION',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Validate_Duration;

  PROCEDURE Validate_Active_YN (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_spnv_rec                     IN spnv_rec_type) IS
  BEGIN
    IF upper(p_spnv_rec.active_yn) = 'Y' OR
       upper(p_spnv_rec.active_yn) = 'N'
    THEN
      IF p_spnv_rec.active_yn = 'Y' OR
         p_spnv_rec.active_yn = 'N'
      THEN
         x_return_status := OKC_API.G_RET_STS_SUCCESS;
      ELSE
         OKC_API.set_message(G_APP_NAME, G_UPPERCASE_REQUIRED,G_COL_NAME_TOKEN,'ACTIVE_YN');
         x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    ELSE
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'BEFORE_AFTER');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  END Validate_Active_YN;
/*
  PROCEDURE Validate_SFWT_Flag (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_spnv_rec                     IN spnv_rec_type) IS
  BEGIN
    IF upper(p_spnv_rec.sfwt_flag) = 'Y' OR
       upper(p_spnv_rec.sfwt_flag) = 'N'
    THEN
       IF p_spnv_rec.sfwt_flag = 'Y' OR
          p_spnv_rec.sfwt_flag = 'N'
       THEN
         x_return_status := OKC_API.G_RET_STS_SUCCESS;
       ELSE
         OKC_API.set_message(G_APP_NAME, G_UPPERCASE_REQUIRED,G_COL_NAME_TOKEN,'SFWT_FLAG');
         x_return_status := OKC_API.G_RET_STS_ERROR;
       END IF;
    ELSE
       OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SFWT_FLAG');
       x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  END Validate_SFWT_Flag;
*/
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- Validate_Attributes for:OKC_SPAN_V --
  ----------------------------------------
  FUNCTION Validate_Attributes (
    p_spnv_rec IN  spnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_spnv_rec.id = OKC_API.G_MISS_NUM OR
       p_spnv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_spnv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_spnv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    Validate_uom_code (l_return_status,
                                  p_spnv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
    Validate_Tve_Id (l_return_status,
                   p_spnv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
    Validate_Duration (l_return_status,
                       p_spnv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
    Validate_Active_YN (l_return_status,
                        p_spnv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
    IF (p_spnv_rec.spn_id is NOT NULL) AND
       (p_spnv_rec.spn_id <> OKC_API.G_MISS_NUM) THEN
      Validate_Spn_Id (l_return_status,
                       p_spnv_rec);
      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
          x_return_status := l_return_status;   -- record that there was an error
        END IF;
      END IF;
    END IF;
/*    Validate_SFWT_Flag (l_return_status,
                        p_spnv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
    */
  RETURN(x_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(x_return_status);

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
      RETURN(x_return_status);

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------
  -- Validate_Record for:OKC_SPAN_V --
  ------------------------------------
  FUNCTION Validate_Record (
    p_spnv_rec IN spnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  /* ************** End of Change ******/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN spnv_rec_type,
    p_to	OUT NOCOPY spn_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.tve_id := p_from.tve_id;
    p_to.uom_code := p_from.uom_code;
    p_to.spn_id := p_from.spn_id;
    p_to.duration := p_from.duration;
    p_to.active_yn := p_from.active_yn;
    p_to.name := p_from.name;
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
    p_from	IN spn_rec_type,
    p_to	OUT NOCOPY spnv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.tve_id := p_from.tve_id;
    p_to.uom_code := p_from.uom_code;
    p_to.spn_id := p_from.spn_id;
    p_to.duration := p_from.duration;
    p_to.active_yn := p_from.active_yn;
    p_to.name := p_from.name;
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
  ---------------------------------
  -- validate_row for:OKC_SPAN_V --
  ---------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spnv_rec                     IN spnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_spnv_rec                     spnv_rec_type := p_spnv_rec;
    l_spn_rec                      spn_rec_type;
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
    l_return_status := Validate_Attributes(l_spnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_spnv_rec);
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
  -- PL/SQL TBL validate_row for:SPNV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spnv_tbl                     IN spnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_spnv_tbl.COUNT > 0) THEN
      i := p_spnv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_spnv_rec                     => p_spnv_tbl(i));
        EXIT WHEN (i = p_spnv_tbl.LAST);
        i := p_spnv_tbl.NEXT(i);
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
  -----------------------------
  -- insert_row for:OKC_SPAN --
  -----------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spn_rec                      IN spn_rec_type,
    x_spn_rec                      OUT NOCOPY spn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SPAN_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_spn_rec                      spn_rec_type := p_spn_rec;
    l_def_spn_rec                  spn_rec_type;
    ---------------------------------
    -- Set_Attributes for:OKC_SPAN --
    ---------------------------------
    FUNCTION Set_Attributes (
      p_spn_rec IN  spn_rec_type,
      x_spn_rec OUT NOCOPY spn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_spn_rec := p_spn_rec;
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
      p_spn_rec,                         -- IN
      l_spn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_SPAN(
        id,
        tve_id,
        uom_code,
        spn_id,
        duration,
        active_yn,
        name,
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
        l_spn_rec.id,
        l_spn_rec.tve_id,
        l_spn_rec.uom_code,
        l_spn_rec.spn_id,
        l_spn_rec.duration,
        l_spn_rec.active_yn,
        l_spn_rec.name,
        l_spn_rec.object_version_number,
        l_spn_rec.created_by,
        l_spn_rec.creation_date,
        l_spn_rec.last_updated_by,
        l_spn_rec.last_update_date,
        l_spn_rec.last_update_login,
        l_spn_rec.attribute_category,
        l_spn_rec.attribute1,
        l_spn_rec.attribute2,
        l_spn_rec.attribute3,
        l_spn_rec.attribute4,
        l_spn_rec.attribute5,
        l_spn_rec.attribute6,
        l_spn_rec.attribute7,
        l_spn_rec.attribute8,
        l_spn_rec.attribute9,
        l_spn_rec.attribute10,
        l_spn_rec.attribute11,
        l_spn_rec.attribute12,
        l_spn_rec.attribute13,
        l_spn_rec.attribute14,
        l_spn_rec.attribute15);
    -- Set OUT values
    x_spn_rec := l_spn_rec;
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
  -------------------------------
  -- insert_row for:OKC_SPAN_V --
  -------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spnv_rec                     IN spnv_rec_type,
    x_spnv_rec                     OUT NOCOPY spnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_spnv_rec                     spnv_rec_type;
    l_def_spnv_rec                 spnv_rec_type;
    l_spn_rec                      spn_rec_type;
    lx_spn_rec                     spn_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_spnv_rec	IN spnv_rec_type
    ) RETURN spnv_rec_type IS
      l_spnv_rec	spnv_rec_type := p_spnv_rec;
    BEGIN
      l_spnv_rec.CREATION_DATE := SYSDATE;
      l_spnv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_spnv_rec.LAST_UPDATE_DATE := l_spnv_rec.CREATION_DATE;
      l_spnv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_spnv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_spnv_rec);
    END fill_who_columns;
    -----------------------------------
    -- Set_Attributes for:OKC_SPAN_V --
    -----------------------------------
    FUNCTION Set_Attributes (
      p_spnv_rec IN  spnv_rec_type,
      x_spnv_rec OUT NOCOPY spnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_spnv_rec := p_spnv_rec;
      x_spnv_rec.OBJECT_VERSION_NUMBER := 1;
-- **** Added the following line(s) for uppercasing *****
      x_spnv_rec.ACTIVE_YN := upper(p_spnv_rec.ACTIVE_YN);
--      x_spnv_rec.SFWT_FLAG := 'N';
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
    l_spnv_rec := null_out_defaults(p_spnv_rec);
    -- Set primary key value
    l_spnv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_spnv_rec,                        -- IN
      l_def_spnv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_spnv_rec := fill_who_columns(l_def_spnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_spnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_spnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_spnv_rec, l_spn_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_spn_rec,
      lx_spn_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_spn_rec, l_def_spnv_rec);
    -- Set OUT values
    x_spnv_rec := l_def_spnv_rec;
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
  -- PL/SQL TBL insert_row for:SPNV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spnv_tbl                     IN spnv_tbl_type,
    x_spnv_tbl                     OUT NOCOPY spnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_spnv_tbl.COUNT > 0) THEN
      i := p_spnv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_spnv_rec                     => p_spnv_tbl(i),
          x_spnv_rec                     => x_spnv_tbl(i));
        EXIT WHEN (i = p_spnv_tbl.LAST);
        i := p_spnv_tbl.NEXT(i);
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
  ---------------------------
  -- lock_row for:OKC_SPAN --
  ---------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spn_rec                      IN spn_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_spn_rec IN spn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_SPAN
     WHERE ID = p_spn_rec.id
       AND OBJECT_VERSION_NUMBER = p_spn_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_spn_rec IN spn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_SPAN
    WHERE ID = p_spn_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SPAN_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_SPAN.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_SPAN.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_spn_rec);
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
      OPEN lchk_csr(p_spn_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_spn_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_spn_rec.object_version_number THEN
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
  -----------------------------
  -- lock_row for:OKC_SPAN_V --
  -----------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spnv_rec                     IN spnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_spn_rec                      spn_rec_type;
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
    migrate(p_spnv_rec, l_spn_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_spn_rec
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
  -- PL/SQL TBL lock_row for:SPNV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spnv_tbl                     IN spnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_spnv_tbl.COUNT > 0) THEN
      i := p_spnv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_spnv_rec                     => p_spnv_tbl(i));
        EXIT WHEN (i = p_spnv_tbl.LAST);
        i := p_spnv_tbl.NEXT(i);
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
  -----------------------------
  -- update_row for:OKC_SPAN --
  -----------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spn_rec                      IN spn_rec_type,
    x_spn_rec                      OUT NOCOPY spn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SPAN_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_spn_rec                      spn_rec_type := p_spn_rec;
    l_def_spn_rec                  spn_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_spn_rec	IN spn_rec_type,
      x_spn_rec	OUT NOCOPY spn_rec_type
    ) RETURN VARCHAR2 IS
      l_spn_rec                      spn_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_spn_rec := p_spn_rec;
      -- Get current database values
      l_spn_rec := get_rec(p_spn_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_spn_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_spn_rec.id := l_spn_rec.id;
      END IF;
      IF (x_spn_rec.tve_id = OKC_API.G_MISS_NUM)
      THEN
        x_spn_rec.tve_id := l_spn_rec.tve_id;
      END IF;
      IF (x_spn_rec.uom_code = OKC_API.G_MISS_CHAR)
      THEN
        x_spn_rec.uom_code := l_spn_rec.uom_code;
      END IF;
      IF (x_spn_rec.spn_id = OKC_API.G_MISS_NUM)
      THEN
        x_spn_rec.spn_id := l_spn_rec.spn_id;
      END IF;
      IF (x_spn_rec.duration = OKC_API.G_MISS_NUM)
      THEN
        x_spn_rec.duration := l_spn_rec.duration;
      END IF;
      IF (x_spn_rec.active_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_spn_rec.active_yn := l_spn_rec.active_yn;
      END IF;
      IF (x_spn_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_spn_rec.name := l_spn_rec.name;
      END IF;
      IF (x_spn_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_spn_rec.object_version_number := l_spn_rec.object_version_number;
      END IF;
      IF (x_spn_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_spn_rec.created_by := l_spn_rec.created_by;
      END IF;
      IF (x_spn_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_spn_rec.creation_date := l_spn_rec.creation_date;
      END IF;
      IF (x_spn_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_spn_rec.last_updated_by := l_spn_rec.last_updated_by;
      END IF;
      IF (x_spn_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_spn_rec.last_update_date := l_spn_rec.last_update_date;
      END IF;
      IF (x_spn_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_spn_rec.last_update_login := l_spn_rec.last_update_login;
      END IF;
      IF (x_spn_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_spn_rec.attribute_category := l_spn_rec.attribute_category;
      END IF;
      IF (x_spn_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_spn_rec.attribute1 := l_spn_rec.attribute1;
      END IF;
      IF (x_spn_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_spn_rec.attribute2 := l_spn_rec.attribute2;
      END IF;
      IF (x_spn_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_spn_rec.attribute3 := l_spn_rec.attribute3;
      END IF;
      IF (x_spn_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_spn_rec.attribute4 := l_spn_rec.attribute4;
      END IF;
      IF (x_spn_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_spn_rec.attribute5 := l_spn_rec.attribute5;
      END IF;
      IF (x_spn_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_spn_rec.attribute6 := l_spn_rec.attribute6;
      END IF;
      IF (x_spn_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_spn_rec.attribute7 := l_spn_rec.attribute7;
      END IF;
      IF (x_spn_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_spn_rec.attribute8 := l_spn_rec.attribute8;
      END IF;
      IF (x_spn_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_spn_rec.attribute9 := l_spn_rec.attribute9;
      END IF;
      IF (x_spn_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_spn_rec.attribute10 := l_spn_rec.attribute10;
      END IF;
      IF (x_spn_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_spn_rec.attribute11 := l_spn_rec.attribute11;
      END IF;
      IF (x_spn_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_spn_rec.attribute12 := l_spn_rec.attribute12;
      END IF;
      IF (x_spn_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_spn_rec.attribute13 := l_spn_rec.attribute13;
      END IF;
      IF (x_spn_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_spn_rec.attribute14 := l_spn_rec.attribute14;
      END IF;
      IF (x_spn_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_spn_rec.attribute15 := l_spn_rec.attribute15;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------
    -- Set_Attributes for:OKC_SPAN --
    ---------------------------------
    FUNCTION Set_Attributes (
      p_spn_rec IN  spn_rec_type,
      x_spn_rec OUT NOCOPY spn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_spn_rec := p_spn_rec;
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
      p_spn_rec,                         -- IN
      l_spn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_spn_rec, l_def_spn_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_SPAN
    SET TVE_ID = l_def_spn_rec.tve_id,
        uom_code = l_def_spn_rec.uom_code,
        SPN_ID = l_def_spn_rec.spn_id,
        DURATION = l_def_spn_rec.duration,
        ACTIVE_YN = l_def_spn_rec.active_yn,
        NAME = l_def_spn_rec.name,
        OBJECT_VERSION_NUMBER = l_def_spn_rec.object_version_number,
        CREATED_BY = l_def_spn_rec.created_by,
        CREATION_DATE = l_def_spn_rec.creation_date,
        LAST_UPDATED_BY = l_def_spn_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_spn_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_spn_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_spn_rec.attribute_category,
        ATTRIBUTE1 = l_def_spn_rec.attribute1,
        ATTRIBUTE2 = l_def_spn_rec.attribute2,
        ATTRIBUTE3 = l_def_spn_rec.attribute3,
        ATTRIBUTE4 = l_def_spn_rec.attribute4,
        ATTRIBUTE5 = l_def_spn_rec.attribute5,
        ATTRIBUTE6 = l_def_spn_rec.attribute6,
        ATTRIBUTE7 = l_def_spn_rec.attribute7,
        ATTRIBUTE8 = l_def_spn_rec.attribute8,
        ATTRIBUTE9 = l_def_spn_rec.attribute9,
        ATTRIBUTE10 = l_def_spn_rec.attribute10,
        ATTRIBUTE11 = l_def_spn_rec.attribute11,
        ATTRIBUTE12 = l_def_spn_rec.attribute12,
        ATTRIBUTE13 = l_def_spn_rec.attribute13,
        ATTRIBUTE14 = l_def_spn_rec.attribute14,
        ATTRIBUTE15 = l_def_spn_rec.attribute15
    WHERE ID = l_def_spn_rec.id;

    x_spn_rec := l_def_spn_rec;
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
  -------------------------------
  -- update_row for:OKC_SPAN_V --
  -------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spnv_rec                     IN spnv_rec_type,
    x_spnv_rec                     OUT NOCOPY spnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_spnv_rec                     spnv_rec_type := p_spnv_rec;
    l_def_spnv_rec                 spnv_rec_type;
    l_spn_rec                      spn_rec_type;
    lx_spn_rec                     spn_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_spnv_rec	IN spnv_rec_type
    ) RETURN spnv_rec_type IS
      l_spnv_rec	spnv_rec_type := p_spnv_rec;
    BEGIN
      l_spnv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_spnv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_spnv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_spnv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_spnv_rec	IN spnv_rec_type,
      x_spnv_rec	OUT NOCOPY spnv_rec_type
    ) RETURN VARCHAR2 IS
      l_spnv_rec                     spnv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_spnv_rec := p_spnv_rec;
      -- Get current database values
      l_spnv_rec := get_rec(p_spnv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_spnv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_spnv_rec.id := l_spnv_rec.id;
      END IF;
      IF (x_spnv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_spnv_rec.object_version_number := l_spnv_rec.object_version_number;
      END IF;
      IF (x_spnv_rec.tve_id = OKC_API.G_MISS_NUM)
      THEN
        x_spnv_rec.tve_id := l_spnv_rec.tve_id;
      END IF;
      IF (x_spnv_rec.uom_code = OKC_API.G_MISS_CHAR)
      THEN
        x_spnv_rec.uom_code := l_spnv_rec.uom_code;
      END IF;
      IF (x_spnv_rec.spn_id = OKC_API.G_MISS_NUM)
      THEN
        x_spnv_rec.spn_id := l_spnv_rec.spn_id;
      END IF;
      IF (x_spnv_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_spnv_rec.name := l_spnv_rec.name;
      END IF;
      IF (x_spnv_rec.duration = OKC_API.G_MISS_NUM)
      THEN
        x_spnv_rec.duration := l_spnv_rec.duration;
      END IF;
      IF (x_spnv_rec.active_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_spnv_rec.active_yn := l_spnv_rec.active_yn;
      END IF;
      IF (x_spnv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_spnv_rec.attribute_category := l_spnv_rec.attribute_category;
      END IF;
      IF (x_spnv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_spnv_rec.attribute1 := l_spnv_rec.attribute1;
      END IF;
      IF (x_spnv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_spnv_rec.attribute2 := l_spnv_rec.attribute2;
      END IF;
      IF (x_spnv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_spnv_rec.attribute3 := l_spnv_rec.attribute3;
      END IF;
      IF (x_spnv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_spnv_rec.attribute4 := l_spnv_rec.attribute4;
      END IF;
      IF (x_spnv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_spnv_rec.attribute5 := l_spnv_rec.attribute5;
      END IF;
      IF (x_spnv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_spnv_rec.attribute6 := l_spnv_rec.attribute6;
      END IF;
      IF (x_spnv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_spnv_rec.attribute7 := l_spnv_rec.attribute7;
      END IF;
      IF (x_spnv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_spnv_rec.attribute8 := l_spnv_rec.attribute8;
      END IF;
      IF (x_spnv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_spnv_rec.attribute9 := l_spnv_rec.attribute9;
      END IF;
      IF (x_spnv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_spnv_rec.attribute10 := l_spnv_rec.attribute10;
      END IF;
      IF (x_spnv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_spnv_rec.attribute11 := l_spnv_rec.attribute11;
      END IF;
      IF (x_spnv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_spnv_rec.attribute12 := l_spnv_rec.attribute12;
      END IF;
      IF (x_spnv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_spnv_rec.attribute13 := l_spnv_rec.attribute13;
      END IF;
      IF (x_spnv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_spnv_rec.attribute14 := l_spnv_rec.attribute14;
      END IF;
      IF (x_spnv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_spnv_rec.attribute15 := l_spnv_rec.attribute15;
      END IF;
      IF (x_spnv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_spnv_rec.created_by := l_spnv_rec.created_by;
      END IF;
      IF (x_spnv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_spnv_rec.creation_date := l_spnv_rec.creation_date;
      END IF;
      IF (x_spnv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_spnv_rec.last_updated_by := l_spnv_rec.last_updated_by;
      END IF;
      IF (x_spnv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_spnv_rec.last_update_date := l_spnv_rec.last_update_date;
      END IF;
      IF (x_spnv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_spnv_rec.last_update_login := l_spnv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------
    -- Set_Attributes for:OKC_SPAN_V --
    -----------------------------------
    FUNCTION Set_Attributes (
      p_spnv_rec IN  spnv_rec_type,
      x_spnv_rec OUT NOCOPY spnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_spnv_rec := p_spnv_rec;
-- **** Added the following line(s) for uppercasing *****
      x_spnv_rec.ACTIVE_YN := upper(p_spnv_rec.ACTIVE_YN);
--      x_spnv_rec.SFWT_FLAG := upper(p_spnv_rec.SFWT_FLAG);
      x_spnv_rec.OBJECT_VERSION_NUMBER := NVL(x_spnv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_spnv_rec,                        -- IN
      l_spnv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_spnv_rec, l_def_spnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_spnv_rec := fill_who_columns(l_def_spnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_spnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_spnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_spnv_rec, l_spn_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_spn_rec,
      lx_spn_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_spn_rec, l_def_spnv_rec);
    x_spnv_rec := l_def_spnv_rec;
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
  -- PL/SQL TBL update_row for:SPNV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spnv_tbl                     IN spnv_tbl_type,
    x_spnv_tbl                     OUT NOCOPY spnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_spnv_tbl.COUNT > 0) THEN
      i := p_spnv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_spnv_rec                     => p_spnv_tbl(i),
          x_spnv_rec                     => x_spnv_tbl(i));
        EXIT WHEN (i = p_spnv_tbl.LAST);
        i := p_spnv_tbl.NEXT(i);
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
  -----------------------------
  -- delete_row for:OKC_SPAN --
  -----------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spn_rec                      IN spn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SPAN_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_spn_rec                      spn_rec_type:= p_spn_rec;
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
    DELETE FROM OKC_SPAN
     WHERE ID = l_spn_rec.id;

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
  -------------------------------
  -- delete_row for:OKC_SPAN_V --
  -------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spnv_rec                     IN spnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_spnv_rec                     spnv_rec_type := p_spnv_rec;
    l_spn_rec                      spn_rec_type;
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
    migrate(l_spnv_rec, l_spn_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_spn_rec
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
  -- PL/SQL TBL delete_row for:SPNV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spnv_tbl                     IN spnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_spnv_tbl.COUNT > 0) THEN
      i := p_spnv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_spnv_rec                     => p_spnv_tbl(i));
        EXIT WHEN (i = p_spnv_tbl.LAST);
        i := p_spnv_tbl.NEXT(i);
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

END OKC_SPN_PVT;

/
