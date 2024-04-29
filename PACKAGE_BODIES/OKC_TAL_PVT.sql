--------------------------------------------------------
--  DDL for Package Body OKC_TAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TAL_PVT" AS
/* $Header: OKCSTALB.pls 120.0 2005/05/25 18:40:45 appldev noship $ */

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
  -- FUNCTION get_rec for: OKC_TIMEVALUES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tve_rec                      IN tve_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tve_rec_type IS
    CURSOR tve_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SPN_ID,
            TVE_ID_OFFSET,
            DNZ_CHR_ID,
		  TZE_ID,
            TVE_ID_LIMITED,
            uom_code,
            CNH_ID,
            TVE_ID_GENERATED_BY,
            TVE_ID_STARTED,
            TVE_ID_ENDED,
            TVE_TYPE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            DURATION,
            OPERATOR,
            BEFORE_AFTER,
            DATETIME,
            MONTH,
            DAY,
            HOUR,
            MINUTE,
            SECOND,
            NTH,
            DAY_OF_WEEK,
            INTERVAL_YN,
            LAST_UPDATE_LOGIN,
            ATTRIBUTE_CATEGORY,
--Bug 3122962
            DESCRIPTION,
            SHORT_DESCRIPTION,
            COMMENTS,
            NAME,

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
      FROM Okc_Timevalues
     WHERE okc_timevalues.id  = p_id;
    l_tve_pk                       tve_pk_csr%ROWTYPE;
    l_tve_rec                      tve_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN tve_pk_csr (p_tve_rec.id);
    FETCH tve_pk_csr INTO
              l_tve_rec.ID,
              l_tve_rec.SPN_ID,
              l_tve_rec.TVE_ID_OFFSET,
              l_tve_rec.DNZ_CHR_ID,
              l_tve_rec.TZE_ID,
              l_tve_rec.TVE_ID_LIMITED,
              l_tve_rec.uom_code,
              l_tve_rec.CNH_ID,
              l_tve_rec.TVE_ID_GENERATED_BY,
              l_tve_rec.TVE_ID_STARTED,
              l_tve_rec.TVE_ID_ENDED,
              l_tve_rec.TVE_TYPE,
              l_tve_rec.OBJECT_VERSION_NUMBER,
              l_tve_rec.CREATED_BY,
              l_tve_rec.CREATION_DATE,
              l_tve_rec.LAST_UPDATED_BY,
              l_tve_rec.LAST_UPDATE_DATE,
              l_tve_rec.DURATION,
              l_tve_rec.OPERATOR,
              l_tve_rec.BEFORE_AFTER,
              l_tve_rec.DATETIME,
              l_tve_rec.MONTH,
              l_tve_rec.DAY,
              l_tve_rec.HOUR,
              l_tve_rec.MINUTE,
              l_tve_rec.SECOND,
              l_tve_rec.NTH,
              l_tve_rec.DAY_OF_WEEK,
              l_tve_rec.INTERVAL_YN,
              l_tve_rec.LAST_UPDATE_LOGIN,
              l_tve_rec.ATTRIBUTE_CATEGORY,
--Bug 3122962
              l_tve_rec.DESCRIPTION,
              l_tve_rec.SHORT_DESCRIPTION,
              l_tve_rec.COMMENTS,
              l_tve_rec.NAME,

              l_tve_rec.ATTRIBUTE1,
              l_tve_rec.ATTRIBUTE2,
              l_tve_rec.ATTRIBUTE3,
              l_tve_rec.ATTRIBUTE4,
              l_tve_rec.ATTRIBUTE5,
              l_tve_rec.ATTRIBUTE6,
              l_tve_rec.ATTRIBUTE7,
              l_tve_rec.ATTRIBUTE8,
              l_tve_rec.ATTRIBUTE9,
              l_tve_rec.ATTRIBUTE10,
              l_tve_rec.ATTRIBUTE11,
              l_tve_rec.ATTRIBUTE12,
              l_tve_rec.ATTRIBUTE13,
              l_tve_rec.ATTRIBUTE14,
              l_tve_rec.ATTRIBUTE15;
    x_no_data_found := tve_pk_csr%NOTFOUND;
    CLOSE tve_pk_csr;
    RETURN(l_tve_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tve_rec                      IN tve_rec_type
  ) RETURN tve_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tve_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_TIMEVALUES_TL
  ---------------------------------------------------------------------------
--Bug 3122962
/*
  FUNCTION get_rec (
    p_okc_timevalues_tl_rec        IN okc_timevalues_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_timevalues_tl_rec_type IS
    CURSOR tve_pktl_csr (p_id                 IN NUMBER,
                         p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            DESCRIPTION,
            SHORT_DESCRIPTION,
            COMMENTS,
            NAME,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Timevalues_Tl
     WHERE okc_timevalues_tl.id = p_id
       AND okc_timevalues_tl.language = p_language;
    l_tve_pktl                     tve_pktl_csr%ROWTYPE;
    l_okc_timevalues_tl_rec        okc_timevalues_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN tve_pktl_csr (p_okc_timevalues_tl_rec.id,
                       p_okc_timevalues_tl_rec.language);
    FETCH tve_pktl_csr INTO
              l_okc_timevalues_tl_rec.ID,
              l_okc_timevalues_tl_rec.LANGUAGE,
              l_okc_timevalues_tl_rec.SOURCE_LANG,
              l_okc_timevalues_tl_rec.SFWT_FLAG,
              l_okc_timevalues_tl_rec.DESCRIPTION,
              l_okc_timevalues_tl_rec.SHORT_DESCRIPTION,
              l_okc_timevalues_tl_rec.COMMENTS,
              l_okc_timevalues_tl_rec.NAME,
              l_okc_timevalues_tl_rec.CREATED_BY,
              l_okc_timevalues_tl_rec.CREATION_DATE,
              l_okc_timevalues_tl_rec.LAST_UPDATED_BY,
              l_okc_timevalues_tl_rec.LAST_UPDATE_DATE,
              l_okc_timevalues_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := tve_pktl_csr%NOTFOUND;
    CLOSE tve_pktl_csr;
    RETURN(l_okc_timevalues_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okc_timevalues_tl_rec        IN okc_timevalues_tl_rec_type
  ) RETURN okc_timevalues_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_timevalues_tl_rec, l_row_notfound));
  END get_rec;
*/
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_TIME_TPA_RELATIVE_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_talv_rec                     IN talv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN talv_rec_type IS
    CURSOR okc_talv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
--Bug 3122962            SFWT_FLAG,
            SPN_ID,
            TVE_ID_OFFSET,
            DNZ_CHR_ID,
            TZE_ID,
            TVE_ID_LIMITED,
            uom_code,
            DESCRIPTION,
            SHORT_DESCRIPTION,
            COMMENTS,
            DURATION,
            OPERATOR,
            BEFORE_AFTER,
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
      FROM Okc_Time_Tpa_Relative_V
     WHERE okc_time_tpa_relative_v.id = p_id;
    l_okc_talv_pk                  okc_talv_pk_csr%ROWTYPE;
    l_talv_rec                     talv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_talv_pk_csr (p_talv_rec.id);
    FETCH okc_talv_pk_csr INTO
              l_talv_rec.ID,
              l_talv_rec.OBJECT_VERSION_NUMBER,
--Bug 3122962              l_talv_rec.SFWT_FLAG,
              l_talv_rec.SPN_ID,
              l_talv_rec.TVE_ID_OFFSET,
              l_talv_rec.DNZ_CHR_ID,
              l_talv_rec.TZE_ID,
              l_talv_rec.TVE_ID_LIMITED,
              l_talv_rec.uom_code,
              l_talv_rec.DESCRIPTION,
              l_talv_rec.SHORT_DESCRIPTION,
              l_talv_rec.COMMENTS,
              l_talv_rec.DURATION,
              l_talv_rec.OPERATOR,
              l_talv_rec.BEFORE_AFTER,
              l_talv_rec.ATTRIBUTE_CATEGORY,
              l_talv_rec.ATTRIBUTE1,
              l_talv_rec.ATTRIBUTE2,
              l_talv_rec.ATTRIBUTE3,
              l_talv_rec.ATTRIBUTE4,
              l_talv_rec.ATTRIBUTE5,
              l_talv_rec.ATTRIBUTE6,
              l_talv_rec.ATTRIBUTE7,
              l_talv_rec.ATTRIBUTE8,
              l_talv_rec.ATTRIBUTE9,
              l_talv_rec.ATTRIBUTE10,
              l_talv_rec.ATTRIBUTE11,
              l_talv_rec.ATTRIBUTE12,
              l_talv_rec.ATTRIBUTE13,
              l_talv_rec.ATTRIBUTE14,
              l_talv_rec.ATTRIBUTE15,
              l_talv_rec.CREATED_BY,
              l_talv_rec.CREATION_DATE,
              l_talv_rec.LAST_UPDATED_BY,
              l_talv_rec.LAST_UPDATE_DATE,
              l_talv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_talv_pk_csr%NOTFOUND;
    CLOSE okc_talv_pk_csr;
    RETURN(l_talv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_talv_rec                     IN talv_rec_type
  ) RETURN talv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_talv_rec, l_row_notfound));
  END get_rec;

  -------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_TIME_TPA_RELATIVE_V --
  -------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_talv_rec	IN talv_rec_type
  ) RETURN talv_rec_type IS
    l_talv_rec	talv_rec_type := p_talv_rec;
  BEGIN
    IF (l_talv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.object_version_number := NULL;
    END IF;
--Bug 3122962
/*
    IF (l_talv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.sfwt_flag := NULL;
    END IF;
*/
    IF (l_talv_rec.spn_id = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.spn_id := NULL;
    END IF;
    IF (l_talv_rec.tve_id_offset = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.tve_id_offset := NULL;
    END IF;
    IF (l_talv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_talv_rec.tze_id = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.tze_id := NULL;
    END IF;
    IF (l_talv_rec.tve_id_limited = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.tve_id_limited := NULL;
    END IF;
    IF (l_talv_rec.uom_code = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.uom_code := NULL;
    END IF;
    IF (l_talv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.description := NULL;
    END IF;
    IF (l_talv_rec.short_description = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.short_description := NULL;
    END IF;
    IF (l_talv_rec.comments = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.comments := NULL;
    END IF;
    IF (l_talv_rec.duration = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.duration := NULL;
    END IF;
    IF (l_talv_rec.operator = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.operator := NULL;
    END IF;
    IF (l_talv_rec.before_after = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.before_after := NULL;
    END IF;
    IF (l_talv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute_category := NULL;
    END IF;
    IF (l_talv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute1 := NULL;
    END IF;
    IF (l_talv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute2 := NULL;
    END IF;
    IF (l_talv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute3 := NULL;
    END IF;
    IF (l_talv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute4 := NULL;
    END IF;
    IF (l_talv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute5 := NULL;
    END IF;
    IF (l_talv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute6 := NULL;
    END IF;
    IF (l_talv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute7 := NULL;
    END IF;
    IF (l_talv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute8 := NULL;
    END IF;
    IF (l_talv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute9 := NULL;
    END IF;
    IF (l_talv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute10 := NULL;
    END IF;
    IF (l_talv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute11 := NULL;
    END IF;
    IF (l_talv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute12 := NULL;
    END IF;
    IF (l_talv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute13 := NULL;
    END IF;
    IF (l_talv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute14 := NULL;
    END IF;
    IF (l_talv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute15 := NULL;
    END IF;
    IF (l_talv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.created_by := NULL;
    END IF;
    IF (l_talv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_talv_rec.creation_date := NULL;
    END IF;
    IF (l_talv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.last_updated_by := NULL;
    END IF;
    IF (l_talv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_talv_rec.last_update_date := NULL;
    END IF;
    IF (l_talv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_talv_rec);
  END null_out_defaults;

  --**** Change from TAPI Code---follow till end of change---------------
  ------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_TIMEVALUES_V --
  ------------------------------------------------------
  -- 1. Added null_out_defaults to overcome number initialization
  -- problem while populating optional columns for supertypes from a subtype
  -- 2. Moved all column validations (including FK) to Validate_column
  -- and is called from Validate_Attributes
  -- 3. Validate_Records will have tuple rule checks.

  FUNCTION null_out_defaults (
    p_tve_rec	IN tve_rec_type
  ) RETURN tve_rec_type IS
    l_tve_rec	tve_rec_type := p_tve_rec;
  BEGIN
    IF (l_tve_rec.cnh_id = OKC_API.G_MISS_NUM) THEN
      l_tve_rec.cnh_id := NULL;
    END IF;
    IF (l_tve_rec.tve_id_generated_by = OKC_API.G_MISS_NUM) THEN
      l_tve_rec.tve_id_generated_by := NULL;
    END IF;
    IF (l_tve_rec.tve_id_started = OKC_API.G_MISS_NUM) THEN
      l_tve_rec.tve_id_started := NULL;
    END IF;
    IF (l_tve_rec.tve_id_ended = OKC_API.G_MISS_NUM) THEN
      l_tve_rec.tve_id_ended := NULL;
    END IF;
    IF (l_tve_rec.datetime = OKC_API.G_MISS_DATE) THEN
      l_tve_rec.datetime := NULL;
    END IF;
    IF (l_tve_rec.month = OKC_API.G_MISS_NUM) THEN
      l_tve_rec.month := NULL;
    END IF;
    IF (l_tve_rec.day = OKC_API.G_MISS_NUM) THEN
      l_tve_rec.day := NULL;
    END IF;
    IF (l_tve_rec.hour = OKC_API.G_MISS_NUM) THEN
      l_tve_rec.hour := NULL;
    END IF;
    IF (l_tve_rec.minute = OKC_API.G_MISS_NUM) THEN
      l_tve_rec.minute := NULL;
    END IF;
    IF (l_tve_rec.second = OKC_API.G_MISS_NUM) THEN
      l_tve_rec.second := NULL;
    END IF;
    IF (l_tve_rec.nth = OKC_API.G_MISS_NUM) THEN
      l_tve_rec.nth := NULL;
    END IF;
    IF (l_tve_rec.day_of_week = OKC_API.G_MISS_CHAR) THEN
      l_tve_rec.day_of_week := NULL;
    END IF;
    IF (l_tve_rec.interval_yn = OKC_API.G_MISS_CHAR) THEN
      l_tve_rec.interval_yn := NULL;
    END IF;
--Bug 3122962
    IF (l_tve_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_tve_rec.description := NULL;
    END IF;
    IF (l_tve_rec.short_description = OKC_API.G_MISS_CHAR) THEN
      l_tve_rec.short_description := NULL;
    END IF;
    IF (l_tve_rec.comments = OKC_API.G_MISS_CHAR) THEN
      l_tve_rec.comments := NULL;
    END IF;
    IF (l_tve_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_tve_rec.name := NULL;
    END IF;

    RETURN(l_tve_rec);
  END null_out_defaults;
--Bug 3122962
/*
  FUNCTION null_out_defaults (
    p_tve_tl_rec	IN okc_timevalues_tl_rec_type
  ) RETURN okc_timevalues_tl_rec_type IS
    l_tve_tl_rec	okc_timevalues_tl_rec_type := p_tve_tl_rec;
  BEGIN
    IF (l_tve_tl_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_tve_tl_rec.name := NULL;
    END IF;
    RETURN(l_tve_tl_rec);
  END null_out_defaults;
*/
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate_Attributes for:OKC_TIME_TPA_RELATIVE_V --
  -----------------------------------------------------
  PROCEDURE Validate_Time_Zone_Id (
      x_return_status                OUT NOCOPY VARCHAR2,
      p_talv_rec                     IN talv_rec_type) IS
      item_not_found_error          EXCEPTION;
      l_row_notfound                 BOOLEAN := TRUE;
      l_row_found                    BOOLEAN := FALSE;
      CURSOR okx_timezones_v_pk_csr (p_tze_id       IN NUMBER) IS
      SELECT '1'
        FROM Okx_TimeZones_V
       WHERE okx_timezones_v.timezone_id = p_tze_id;
      l_okx_timezones_v_pk             okx_timezones_v_pk_csr%ROWTYPE;
    BEGIN
      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
      IF (p_talv_rec.TZE_ID IS NOT NULL AND
          p_talv_rec.TZE_ID <> OKC_API.G_MISS_NUM)
      THEN
        OPEN okx_timezones_v_pk_csr(p_talv_rec.TZE_ID);
        FETCH okx_timezones_v_pk_csr INTO l_okx_timezones_v_pk;
        l_row_notfound := okx_timezones_v_pk_csr%NOTFOUND;
        CLOSE okx_timezones_v_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TZE_ID');
          RAISE item_not_found_error;
        END IF;
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
                            p_token2_value => 'TZE_ID',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Validate_Time_Zone_Id ;

  PROCEDURE Validate_uom_code (
      x_return_status                OUT NOCOPY VARCHAR2,
      p_talv_rec                     IN talv_rec_type) IS
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
      IF (p_talv_rec.uom_code IS NOT NULL AND
          p_talv_rec.uom_code <> OKC_API.G_MISS_CHAR)
      THEN
        OPEN uom_pk_csr(p_talv_rec.uom_code);
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
      p_talv_rec                     IN talv_rec_type) IS
      item_not_found_error          EXCEPTION;
      l_row_notfound                 BOOLEAN := TRUE;
      CURSOR okc_spnv_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM Okc_Span
       WHERE id        = p_id;
      l_okc_spnv_pk                  okc_spnv_pk_csr%ROWTYPE;
    BEGIN
      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
      IF (p_talv_rec.SPN_ID IS NOT NULL AND
          p_talv_rec.SPN_ID <> OKC_API.G_MISS_NUM)
      THEN
        OPEN okc_spnv_pk_csr(p_talv_rec.SPN_ID);
        FETCH okc_spnv_pk_csr INTO l_okc_spnv_pk;
        l_row_notfound := okc_spnv_pk_csr%NOTFOUND;
        CLOSE okc_spnv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SPN_ID');
          RAISE item_not_found_error;
        END IF;
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

  PROCEDURE Validate_DNZ_Chr_ID (
      x_return_status                OUT NOCOPY VARCHAR2,
      p_talv_rec                     IN talv_rec_type) IS
      item_not_found_error          EXCEPTION;
      l_row_notfound                 BOOLEAN := TRUE;
      CURSOR okc_chrv_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM Okc_k_headers_b
       WHERE id = p_id;
      l_okc_chrv_pk                  okc_chrv_pk_csr%ROWTYPE;
    BEGIN
      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
      IF (p_talv_rec.dnz_chr_id IS NOT NULL AND
          p_talv_rec.dnz_chr_id <> OKC_API.G_MISS_NUM)
      THEN
        OPEN okc_chrv_pk_csr(p_talv_rec.dnz_chr_id);
        FETCH okc_chrv_pk_csr INTO l_okc_chrv_pk;
        l_row_notfound := okc_chrv_pk_csr%NOTFOUND;
        CLOSE okc_chrv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'DNZ_CHR_ID');
          RAISE item_not_found_error;
        END IF;
      ELSE
         OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'DNZ_CHR_ID');
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
                            p_token2_value => 'DNZ_CHR_ID',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Validate_DNZ_Chr_Id ;

  PROCEDURE Validate_Tve_Id_Offset (
      x_return_status                OUT NOCOPY VARCHAR2,
      p_talv_rec                     IN talv_rec_type) IS
      item_not_found_error          EXCEPTION;
      l_row_notfound                 BOOLEAN := TRUE;
      CURSOR okc_tvev_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM Okc_Timevalues
       WHERE id  = p_id;
      l_okc_tvev_pk                  okc_tvev_pk_csr%ROWTYPE;
    BEGIN
      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
      IF (p_talv_rec.TVE_ID_OFFSET IS NOT NULL AND
          p_talv_rec.TVE_ID_OFFSET <> OKC_API.G_MISS_NUM)
      THEN
        OPEN okc_tvev_pk_csr(p_talv_rec.TVE_ID_OFFSET);
        FETCH okc_tvev_pk_csr INTO l_okc_tvev_pk;
        l_row_notfound := okc_tvev_pk_csr%NOTFOUND;
        CLOSE okc_tvev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TVE_ID_OFFSET');
          RAISE item_not_found_error;
        END IF;
      ELSE
         OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'TVE_ID_OFFSET');
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
                            p_token2_value => 'TVE_ID_OFFSET',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Validate_Tve_Id_Offset ;

  PROCEDURE Validate_Tve_Id_Limited (
      x_return_status                OUT NOCOPY VARCHAR2,
      p_talv_rec                     IN talv_rec_type) IS
      item_not_found_error          EXCEPTION;
      l_row_notfound                 BOOLEAN := TRUE;
      CURSOR okc_tvev_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM Okc_Timevalues
       WHERE id  = p_id
        and tve_type in ('ISE','IGS');
      l_okc_tvev_pk                  okc_tvev_pk_csr%ROWTYPE;
    BEGIN
      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
      IF (p_talv_rec.TVE_ID_LIMITED IS NOT NULL AND
          p_talv_rec.TVE_ID_LIMITED <> OKC_API.G_MISS_NUM)
      THEN
        OPEN okc_tvev_pk_csr(p_talv_rec.TVE_ID_LIMITED);
        FETCH okc_tvev_pk_csr INTO l_okc_tvev_pk;
        l_row_notfound := okc_tvev_pk_csr%NOTFOUND;
        CLOSE okc_tvev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TVE_ID_LIMITED');
          RAISE item_not_found_error;
        END IF;
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
                            p_token2_value => 'TVE_ID_LIMITED',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Validate_Tve_Id_Limited ;

  PROCEDURE Validate_Duration (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN talv_rec_type) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_talv_rec.duration = OKC_API.G_MISS_NUM OR
        p_talv_rec.duration IS NULL) THEN
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

  PROCEDURE Validate_Before_After (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN talv_rec_type) IS
  BEGIN
    IF p_talv_rec.before_after IS NOT NULL AND
       p_talv_rec.before_after <> OKC_API.G_MISS_CHAR
    THEN
      IF upper(p_talv_rec.before_after) = 'B' OR
         upper(p_talv_rec.before_after) = 'A'
      THEN
        IF p_talv_rec.before_after = 'B' OR
           p_talv_rec.before_after = 'A'
        THEN
           x_return_status := OKC_API.G_RET_STS_SUCCESS;
        ELSE
           OKC_API.set_message(G_APP_NAME, G_UPPERCASE_REQUIRED,G_COL_NAME_TOKEN,'BEFORE_AFTER');
           x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
      ELSE
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'BEFORE_AFTER');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    END IF;
  END Validate_Before_After;

  PROCEDURE Validate_Operator (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN talv_rec_type) IS
  BEGIN
    IF p_talv_rec.operator IS NULL OR
       p_talv_rec.operator = OKC_API.G_MISS_CHAR OR
       p_talv_rec.operator = '=' OR
       p_talv_rec.operator = '<=' OR
       p_talv_rec.operator = '>=' OR
       p_talv_rec.operator = '>' OR
       p_talv_rec.operator = '<'
    THEN
       x_return_status := OKC_API.G_RET_STS_SUCCESS;
    ELSE
       OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'OPERATOR');
       x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  END Validate_Operator;

--Bug 3122962
/*
  PROCEDURE Validate_SFWT_Flag (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN talv_rec_type) IS
  BEGIN
    IF upper(p_talv_rec.sfwt_flag) = 'Y' OR
       upper(p_talv_rec.sfwt_flag) = 'N'
    THEN
       IF p_talv_rec.sfwt_flag = 'Y' OR
          p_talv_rec.sfwt_flag = 'N'
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
  FUNCTION Validate_Attributes (
    p_talv_rec IN  talv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_talv_rec.id = OKC_API.G_MISS_NUM OR
       p_talv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_talv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_talv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
--Bug 3122962
/*
    Validate_SFWT_Flag (l_return_status,
                        p_talv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
*/
    Validate_uom_code (l_return_status,
                           p_talv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
    IF p_talv_rec.dnz_chr_id <> 0 Then
      Validate_DNZ_Chr_Id (l_return_status,
                         p_talv_rec);
      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN -- need to leave
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
          x_return_status := l_return_status;   -- record that there was an error
        END IF;
      END IF;
    END IF;
    Validate_Tve_Id_Offset (l_return_status,
                            p_talv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
    IF p_talv_rec.tve_id_limited <> OKC_API.G_MISS_NUM AND
       p_talv_rec.tve_id_limited IS NOT NULL
    THEN
      Validate_Tve_Id_Limited (l_return_status,
                               p_talv_rec);
      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN -- need to leave
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
          x_return_status := l_return_status;  -- record that there was an error
        END IF;
      END IF;
    END IF;
    IF (p_talv_rec.TZE_ID IS NOT NULL AND
        p_talv_rec.TZE_ID <> OKC_API.G_MISS_NUM)
    THEN
      Validate_Time_Zone_Id (l_return_status,
                             p_talv_rec);
      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN -- need to leave
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
          x_return_status := l_return_status;   -- record that there was an error
        END IF;
      END IF;
    END IF;
    Validate_Duration (l_return_status,
                       p_talv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
    IF (p_talv_rec.before_after is NOT NULL) AND
       (p_talv_rec.before_after <> OKC_API.G_MISS_CHAR) THEN
      Validate_Before_After (l_return_status,
                             p_talv_rec);
      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
          x_return_status := l_return_status;   -- record that there was an error
        END IF;
      END IF;
    END IF;
    IF (p_talv_rec.spn_id is NOT NULL) AND
       (p_talv_rec.spn_id <> OKC_API.G_MISS_NUM) THEN
      Validate_Spn_Id (l_return_status,
                       p_talv_rec);
      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
          x_return_status := l_return_status;   -- record that there was an error
        END IF;
      END IF;
    END IF;
    IF (p_talv_rec.operator is NOT NULL) AND
       (p_talv_rec.operator <> OKC_API.G_MISS_CHAR) THEN
      Validate_Operator (l_return_status,
                         p_talv_rec);
      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
          x_return_status := l_return_status;   -- record that there was an error
        END IF;
      END IF;
    END IF;
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
  -------------------------------------------------
  -- Validate_Record for:OKC_TIME_TPA_RELATIVE_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_talv_rec IN talv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_talv_rec.operator is NULL or
        p_talv_rec.operator = OKC_API.G_MISS_CHAR) and
       (p_talv_rec.before_after is NULL or
        p_talv_rec.before_after = OKC_API.G_MISS_CHAR)
    THEN
       OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'operator',G_COL_NAME_TOKEN,'before_after');
       l_return_status  := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN (l_return_status);
  END Validate_Record;
 --**** End of Change -------------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN talv_rec_type,
    p_to	IN OUT NOCOPY tve_rec_type
  ) IS
    l_tve_rec tve_rec_type;
  BEGIN
-- **** The following line is added to populate record type for Supertype
    p_to.tve_type := 'TAL';
    p_to.id := p_from.id;
    p_to.spn_id := p_from.spn_id;
    p_to.tve_id_offset := p_from.tve_id_offset;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.tze_id := p_from.tze_id;
    p_to.tve_id_limited := p_from.tve_id_limited;
    p_to.uom_code := p_from.uom_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.duration := p_from.duration;
    p_to.operator := p_from.operator;
    p_to.before_after := p_from.before_after;
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
--Bug 3122962
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
--    p_to.name := p_from.name;
  -- **** Added null_out_defaults to overcome number initialization
  -- problem while populating optional columns for supertypes from a subtype
    l_tve_rec := null_out_defaults(p_to);
    p_to := l_tve_rec;
  END migrate;
  PROCEDURE migrate (
    p_from	IN tve_rec_type,
    p_to	IN OUT NOCOPY talv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.spn_id := p_from.spn_id;
    p_to.tve_id_offset := p_from.tve_id_offset;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.tze_id := p_from.tze_id;
    p_to.tve_id_limited := p_from.tve_id_limited;
    p_to.uom_code := p_from.uom_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.duration := p_from.duration;
    p_to.operator := p_from.operator;
    p_to.before_after := p_from.before_after;
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
--Bug 3122962
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
--    p_to.name := p_from.name;

  END migrate;
--Bug 3122962
/*
  PROCEDURE migrate (
    p_from	IN talv_rec_type,
    p_to	IN OUT NOCOPY okc_timevalues_tl_rec_type
  ) IS
  l_tve_tl_type          okc_timevalues_tl_rec_type;
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  -- **** Added null_out_defaults to overcome number initialization
  -- problem while populating optional columns for supertypes from a subtype
    l_tve_tl_type := null_out_defaults(p_to);
    p_to := l_tve_tl_type;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okc_timevalues_tl_rec_type,
    p_to	IN OUT NOCOPY talv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
*/
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- validate_row for:OKC_TIME_TPA_RELATIVE_V --
  ----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN talv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_talv_rec                     talv_rec_type := p_talv_rec;
    l_tve_rec                      tve_rec_type;
--Bug 3122962    l_okc_timevalues_tl_rec        okc_timevalues_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_talv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_talv_rec);
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
  -- PL/SQL TBL validate_row for:TALV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN talv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_talv_tbl.COUNT > 0) THEN
      i := p_talv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_talv_rec                     => p_talv_tbl(i));
        EXIT WHEN (i = p_talv_tbl.LAST);
        i := p_talv_tbl.NEXT(i);
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
  -- insert_row for:OKC_TIMEVALUES_B --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tve_rec                      IN tve_rec_type,
    x_tve_rec                      OUT NOCOPY tve_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tve_rec                      tve_rec_type := p_tve_rec;
    l_def_tve_rec                  tve_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKC_TIMEVALUES_B --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_tve_rec IN  tve_rec_type,
      x_tve_rec OUT NOCOPY tve_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tve_rec := p_tve_rec;
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
      p_tve_rec,                         -- IN
      l_tve_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_TIMEVALUES(
        id,
        spn_id,
        tve_id_offset,
        dnz_chr_id,
        tze_id,
        tve_id_limited,
        uom_code,
        cnh_id,
        tve_id_generated_by,
        tve_id_started,
        tve_id_ended,
        tve_type,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        duration,
        operator,
        before_after,
        datetime,
        month,
        day,
        hour,
        minute,
        second,
        nth,
        day_of_week,
        interval_yn,
        last_update_login,
        attribute_category,
--Bug 3122962
          description,
          short_description,
          comments,
          name,

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
        l_tve_rec.id,
        l_tve_rec.spn_id,
        l_tve_rec.tve_id_offset,
        l_tve_rec.dnz_chr_id,
        l_tve_rec.tze_id,
        l_tve_rec.tve_id_limited,
        l_tve_rec.uom_code,
        l_tve_rec.cnh_id,
        l_tve_rec.tve_id_generated_by,
        l_tve_rec.tve_id_started,
        l_tve_rec.tve_id_ended,
        l_tve_rec.tve_type,
        l_tve_rec.object_version_number,
        l_tve_rec.created_by,
        l_tve_rec.creation_date,
        l_tve_rec.last_updated_by,
        l_tve_rec.last_update_date,
        l_tve_rec.duration,
        l_tve_rec.operator,
        l_tve_rec.before_after,
        l_tve_rec.datetime,
        l_tve_rec.month,
        l_tve_rec.day,
        l_tve_rec.hour,
        l_tve_rec.minute,
        l_tve_rec.second,
        l_tve_rec.nth,
        l_tve_rec.day_of_week,
        l_tve_rec.interval_yn,
        l_tve_rec.last_update_login,
        l_tve_rec.attribute_category,
--Bug 3122962
          l_tve_rec.description,
          l_tve_rec.short_description,
          l_tve_rec.comments,
          l_tve_rec.name,

        l_tve_rec.attribute1,
        l_tve_rec.attribute2,
        l_tve_rec.attribute3,
        l_tve_rec.attribute4,
        l_tve_rec.attribute5,
        l_tve_rec.attribute6,
        l_tve_rec.attribute7,
        l_tve_rec.attribute8,
        l_tve_rec.attribute9,
        l_tve_rec.attribute10,
        l_tve_rec.attribute11,
        l_tve_rec.attribute12,
        l_tve_rec.attribute13,
        l_tve_rec.attribute14,
        l_tve_rec.attribute15);
    -- Set OUT values
    x_tve_rec := l_tve_rec;
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
  --------------------------------------
  -- insert_row for:OKC_TIMEVALUES_TL --
  --------------------------------------
/*
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_timevalues_tl_rec        IN okc_timevalues_tl_rec_type,
    x_okc_timevalues_tl_rec        OUT NOCOPY okc_timevalues_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_timevalues_tl_rec        okc_timevalues_tl_rec_type := p_okc_timevalues_tl_rec;
    l_def_okc_timevalues_tl_rec    okc_timevalues_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ------------------------------------------
    -- Set_Attributes for:OKC_TIMEVALUES_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_timevalues_tl_rec IN  okc_timevalues_tl_rec_type,
      x_okc_timevalues_tl_rec OUT NOCOPY okc_timevalues_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_timevalues_tl_rec := p_okc_timevalues_tl_rec;
      x_okc_timevalues_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      x_okc_timevalues_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
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
      p_okc_timevalues_tl_rec,           -- IN
      l_okc_timevalues_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_timevalues_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_TIMEVALUES_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          description,
          short_description,
          comments,
          name,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okc_timevalues_tl_rec.id,
          l_okc_timevalues_tl_rec.language,
          l_okc_timevalues_tl_rec.source_lang,
          l_okc_timevalues_tl_rec.sfwt_flag,
          l_okc_timevalues_tl_rec.description,
          l_okc_timevalues_tl_rec.short_description,
          l_okc_timevalues_tl_rec.comments,
          l_okc_timevalues_tl_rec.name,
          l_okc_timevalues_tl_rec.created_by,
          l_okc_timevalues_tl_rec.creation_date,
          l_okc_timevalues_tl_rec.last_updated_by,
          l_okc_timevalues_tl_rec.last_update_date,
          l_okc_timevalues_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_timevalues_tl_rec := l_okc_timevalues_tl_rec;
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
*/
  --------------------------------------------
  -- insert_row for:OKC_TIME_TPA_RELATIVE_V --
  --------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN talv_rec_type,
    x_talv_rec                     OUT NOCOPY talv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_talv_rec                     talv_rec_type;
    l_def_talv_rec                 talv_rec_type;
    l_tve_rec                      tve_rec_type;
    lx_tve_rec                     tve_rec_type;
--Bug 3122962    l_okc_timevalues_tl_rec        okc_timevalues_tl_rec_type;
--Bug 3122962    lx_okc_timevalues_tl_rec       okc_timevalues_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_talv_rec	IN talv_rec_type
    ) RETURN talv_rec_type IS
      l_talv_rec	talv_rec_type := p_talv_rec;
    BEGIN
      l_talv_rec.CREATION_DATE := SYSDATE;
      l_talv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_talv_rec.LAST_UPDATE_DATE := l_talv_rec.CREATION_DATE;
      l_talv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_talv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_talv_rec);
    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKC_TIME_TPA_RELATIVE_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_talv_rec IN  talv_rec_type,
      x_talv_rec OUT NOCOPY talv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_talv_rec := p_talv_rec;
-- ***** Added to overcome the Uppercase scenario
--      x_talv_rec.SFWT_FLAG := 'N';
      x_talv_rec.BEFORE_AFTER := upper(p_talv_rec.before_after);
      x_talv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_talv_rec := null_out_defaults(p_talv_rec);
    -- Set primary key value
    l_talv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_talv_rec,                        -- IN
      l_def_talv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_talv_rec := fill_who_columns(l_def_talv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_talv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_talv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_talv_rec, l_tve_rec);
--Bug 3122962    migrate(l_def_talv_rec, l_okc_timevalues_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tve_rec,
      lx_tve_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tve_rec, l_def_talv_rec);
/*
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_timevalues_tl_rec,
      lx_okc_timevalues_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_timevalues_tl_rec, l_def_talv_rec);
*/
    -- Set OUT values
    x_talv_rec := l_def_talv_rec;
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
  -- PL/SQL TBL insert_row for:TALV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN talv_tbl_type,
    x_talv_tbl                     OUT NOCOPY talv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_talv_tbl.COUNT > 0) THEN
      i := p_talv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_talv_rec                     => p_talv_tbl(i),
          x_talv_rec                     => x_talv_tbl(i));
        EXIT WHEN (i = p_talv_tbl.LAST);
        i := p_talv_tbl.NEXT(i);
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
  -- lock_row for:OKC_TIMEVALUES_B --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tve_rec                      IN tve_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_tve_rec IN tve_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_TIMEVALUES
     WHERE ID = p_tve_rec.id
       AND OBJECT_VERSION_NUMBER = p_tve_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_tve_rec IN tve_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_TIMEVALUES
    WHERE ID = p_tve_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_TIMEVALUES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_TIMEVALUES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_tve_rec);
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
      OPEN lchk_csr(p_tve_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_tve_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_tve_rec.object_version_number THEN
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
  ------------------------------------
  -- lock_row for:OKC_TIMEVALUES_TL --
  ------------------------------------
/*
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_timevalues_tl_rec        IN okc_timevalues_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_timevalues_tl_rec IN okc_timevalues_tl_rec_type) IS
    SELECT id
      FROM OKC_TIMEVALUES_TL
     WHERE ID = p_okc_timevalues_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
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
      OPEN lock_csr(p_okc_timevalues_tl_rec);
      FETCH lock_csr INTO l_lock_var;
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
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
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
*/
  ------------------------------------------
  -- lock_row for:OKC_TIME_TPA_RELATIVE_V --
  ------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN talv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tve_rec                      tve_rec_type;
--Bug 3122962    l_okc_timevalues_tl_rec        okc_timevalues_tl_rec_type;
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
    migrate(p_talv_rec, l_tve_rec);
--Bug 3122962    migrate(p_talv_rec, l_okc_timevalues_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tve_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
/*    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_timevalues_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
*/
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
  -- PL/SQL TBL lock_row for:TALV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN talv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_talv_tbl.COUNT > 0) THEN
      i := p_talv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_talv_rec                     => p_talv_tbl(i));
        EXIT WHEN (i = p_talv_tbl.LAST);
        i := p_talv_tbl.NEXT(i);
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
  -- update_row for:OKC_TIMEVALUES_B --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tve_rec                      IN tve_rec_type,
    x_tve_rec                      OUT NOCOPY tve_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tve_rec                      tve_rec_type := p_tve_rec;
    l_def_tve_rec                  tve_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tve_rec	IN tve_rec_type,
      x_tve_rec	OUT NOCOPY tve_rec_type
    ) RETURN VARCHAR2 IS
      l_tve_rec                      tve_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tve_rec := p_tve_rec;
      -- Get current database values
      l_tve_rec := get_rec(p_tve_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tve_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.id := l_tve_rec.id;
      END IF;
      IF (x_tve_rec.spn_id = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.spn_id := l_tve_rec.spn_id;
      END IF;
      IF (x_tve_rec.tve_id_offset = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.tve_id_offset := l_tve_rec.tve_id_offset;
      END IF;
      IF (x_tve_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.dnz_chr_id := l_tve_rec.dnz_chr_id;
      END IF;
      IF (x_tve_rec.tze_id = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.tze_id := l_tve_rec.tze_id;
      END IF;
      IF (x_tve_rec.tve_id_limited = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.tve_id_limited := l_tve_rec.tve_id_limited;
      END IF;
      IF (x_tve_rec.uom_code = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.uom_code := l_tve_rec.uom_code;
      END IF;
      IF (x_tve_rec.cnh_id = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.cnh_id := l_tve_rec.cnh_id;
      END IF;
      IF (x_tve_rec.tve_id_generated_by = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.tve_id_generated_by := l_tve_rec.tve_id_generated_by;
      END IF;
      IF (x_tve_rec.tve_id_started = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.tve_id_started := l_tve_rec.tve_id_started;
      END IF;
      IF (x_tve_rec.tve_id_ended = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.tve_id_ended := l_tve_rec.tve_id_ended;
      END IF;
      IF (x_tve_rec.tve_type = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.tve_type := l_tve_rec.tve_type;
      END IF;
      IF (x_tve_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.object_version_number := l_tve_rec.object_version_number;
      END IF;
      IF (x_tve_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.created_by := l_tve_rec.created_by;
      END IF;
      IF (x_tve_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_tve_rec.creation_date := l_tve_rec.creation_date;
      END IF;
      IF (x_tve_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.last_updated_by := l_tve_rec.last_updated_by;
      END IF;
      IF (x_tve_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_tve_rec.last_update_date := l_tve_rec.last_update_date;
      END IF;
      IF (x_tve_rec.duration = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.duration := l_tve_rec.duration;
      END IF;
      IF (x_tve_rec.operator = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.operator := l_tve_rec.operator;
      END IF;
      IF (x_tve_rec.before_after = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.before_after := l_tve_rec.before_after;
      END IF;
      IF (x_tve_rec.datetime = OKC_API.G_MISS_DATE)
      THEN
        x_tve_rec.datetime := l_tve_rec.datetime;
      END IF;
      IF (x_tve_rec.month = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.month := l_tve_rec.month;
      END IF;
      IF (x_tve_rec.day = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.day := l_tve_rec.day;
      END IF;
      IF (x_tve_rec.hour = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.hour := l_tve_rec.hour;
      END IF;
      IF (x_tve_rec.minute = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.minute := l_tve_rec.minute;
      END IF;
      IF (x_tve_rec.second = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.second := l_tve_rec.second;
      END IF;
      IF (x_tve_rec.nth = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.nth := l_tve_rec.nth;
      END IF;
      IF (x_tve_rec.day_of_week = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.day_of_week := l_tve_rec.day_of_week;
      END IF;
      IF (x_tve_rec.interval_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.interval_yn := l_tve_rec.interval_yn;
      END IF;
      IF (x_tve_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_tve_rec.last_update_login := l_tve_rec.last_update_login;
      END IF;
      IF (x_tve_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.attribute_category := l_tve_rec.attribute_category;
      END IF;
      IF (x_tve_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.attribute1 := l_tve_rec.attribute1;
      END IF;
      IF (x_tve_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.attribute2 := l_tve_rec.attribute2;
      END IF;
      IF (x_tve_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.attribute3 := l_tve_rec.attribute3;
      END IF;
      IF (x_tve_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.attribute4 := l_tve_rec.attribute4;
      END IF;
      IF (x_tve_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.attribute5 := l_tve_rec.attribute5;
      END IF;
      IF (x_tve_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.attribute6 := l_tve_rec.attribute6;
      END IF;
      IF (x_tve_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.attribute7 := l_tve_rec.attribute7;
      END IF;
      IF (x_tve_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.attribute8 := l_tve_rec.attribute8;
      END IF;
      IF (x_tve_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.attribute9 := l_tve_rec.attribute9;
      END IF;
      IF (x_tve_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.attribute10 := l_tve_rec.attribute10;
      END IF;
      IF (x_tve_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.attribute11 := l_tve_rec.attribute11;
      END IF;
      IF (x_tve_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.attribute12 := l_tve_rec.attribute12;
      END IF;
      IF (x_tve_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.attribute13 := l_tve_rec.attribute13;
      END IF;
      IF (x_tve_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.attribute14 := l_tve_rec.attribute14;
      END IF;
      IF (x_tve_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.attribute15 := l_tve_rec.attribute15;
      END IF;
--Bug 3122962
      IF (x_tve_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.description := l_tve_rec.description;
      END IF;
      IF (x_tve_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.short_description := l_tve_rec.short_description;
      END IF;
      IF (x_tve_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.comments := l_tve_rec.comments;
      END IF;
      IF (x_tve_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_tve_rec.name := l_tve_rec.name;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKC_TIMEVALUES_B --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_tve_rec IN  tve_rec_type,
      x_tve_rec OUT NOCOPY tve_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tve_rec := p_tve_rec;
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
      p_tve_rec,                         -- IN
      l_tve_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tve_rec, l_def_tve_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_TIMEVALUES
    SET SPN_ID = l_def_tve_rec.spn_id,
        TVE_ID_OFFSET = l_def_tve_rec.tve_id_offset,
        DNZ_CHR_ID = l_def_tve_rec.dnz_chr_id,
        TZE_ID = l_def_tve_rec.tze_id,
        TVE_ID_LIMITED = l_def_tve_rec.tve_id_limited,
        uom_code = l_def_tve_rec.uom_code,
        CNH_ID = l_def_tve_rec.cnh_id,
        TVE_ID_GENERATED_BY = l_def_tve_rec.tve_id_generated_by,
        TVE_ID_STARTED = l_def_tve_rec.tve_id_started,
        TVE_ID_ENDED = l_def_tve_rec.tve_id_ended,
        TVE_TYPE = l_def_tve_rec.tve_type,
        OBJECT_VERSION_NUMBER = l_def_tve_rec.object_version_number,
        CREATED_BY = l_def_tve_rec.created_by,
        CREATION_DATE = l_def_tve_rec.creation_date,
        LAST_UPDATED_BY = l_def_tve_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_tve_rec.last_update_date,
        DURATION = l_def_tve_rec.duration,
        OPERATOR = l_def_tve_rec.operator,
        BEFORE_AFTER = l_def_tve_rec.before_after,
        DATETIME = l_def_tve_rec.datetime,
        MONTH = l_def_tve_rec.month,
        DAY = l_def_tve_rec.day,
        HOUR = l_def_tve_rec.hour,
        MINUTE = l_def_tve_rec.minute,
        SECOND = l_def_tve_rec.second,
        NTH = l_def_tve_rec.nth,
        DAY_OF_WEEK = l_def_tve_rec.day_of_week,
        INTERVAL_YN = l_def_tve_rec.interval_yn,
        LAST_UPDATE_LOGIN = l_def_tve_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_tve_rec.attribute_category,
        ATTRIBUTE1 = l_def_tve_rec.attribute1,
        ATTRIBUTE2 = l_def_tve_rec.attribute2,
        ATTRIBUTE3 = l_def_tve_rec.attribute3,
        ATTRIBUTE4 = l_def_tve_rec.attribute4,
        ATTRIBUTE5 = l_def_tve_rec.attribute5,
        ATTRIBUTE6 = l_def_tve_rec.attribute6,
        ATTRIBUTE7 = l_def_tve_rec.attribute7,
        ATTRIBUTE8 = l_def_tve_rec.attribute8,
        ATTRIBUTE9 = l_def_tve_rec.attribute9,
        ATTRIBUTE10 = l_def_tve_rec.attribute10,
        ATTRIBUTE11 = l_def_tve_rec.attribute11,
        ATTRIBUTE12 = l_def_tve_rec.attribute12,
        ATTRIBUTE13 = l_def_tve_rec.attribute13,
        ATTRIBUTE14 = l_def_tve_rec.attribute14,
        ATTRIBUTE15 = l_def_tve_rec.attribute15,
--Bug 3122962
         DESCRIPTION = l_def_tve_rec.description,
        SHORT_DESCRIPTION = l_def_tve_rec.short_description,
        COMMENTS = l_def_tve_rec.comments,
        NAME = l_def_tve_rec.name

    WHERE ID = l_def_tve_rec.id;
    x_tve_rec := l_def_tve_rec;
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
  --------------------------------------
  -- update_row for:OKC_TIMEVALUES_TL --
  --------------------------------------
/*
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_timevalues_tl_rec        IN okc_timevalues_tl_rec_type,
    x_okc_timevalues_tl_rec        OUT NOCOPY okc_timevalues_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_timevalues_tl_rec        okc_timevalues_tl_rec_type := p_okc_timevalues_tl_rec;
    l_def_okc_timevalues_tl_rec    okc_timevalues_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_timevalues_tl_rec	IN okc_timevalues_tl_rec_type,
      x_okc_timevalues_tl_rec	OUT NOCOPY okc_timevalues_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okc_timevalues_tl_rec        okc_timevalues_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_timevalues_tl_rec := p_okc_timevalues_tl_rec;
      -- Get current database values
      l_okc_timevalues_tl_rec := get_rec(p_okc_timevalues_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_timevalues_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okc_timevalues_tl_rec.id := l_okc_timevalues_tl_rec.id;
      END IF;
      IF (x_okc_timevalues_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_timevalues_tl_rec.language := l_okc_timevalues_tl_rec.language;
      END IF;
      IF (x_okc_timevalues_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_timevalues_tl_rec.source_lang := l_okc_timevalues_tl_rec.source_lang;
      END IF;
      IF (x_okc_timevalues_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_timevalues_tl_rec.sfwt_flag := l_okc_timevalues_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_timevalues_tl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_timevalues_tl_rec.description := l_okc_timevalues_tl_rec.description;
      END IF;
      IF (x_okc_timevalues_tl_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_timevalues_tl_rec.short_description := l_okc_timevalues_tl_rec.short_description;
      END IF;
      IF (x_okc_timevalues_tl_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_timevalues_tl_rec.comments := l_okc_timevalues_tl_rec.comments;
      END IF;
      IF (x_okc_timevalues_tl_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_timevalues_tl_rec.name := l_okc_timevalues_tl_rec.name;
      END IF;
      IF (x_okc_timevalues_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_timevalues_tl_rec.created_by := l_okc_timevalues_tl_rec.created_by;
      END IF;
      IF (x_okc_timevalues_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_timevalues_tl_rec.creation_date := l_okc_timevalues_tl_rec.creation_date;
      END IF;
      IF (x_okc_timevalues_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_timevalues_tl_rec.last_updated_by := l_okc_timevalues_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_timevalues_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_timevalues_tl_rec.last_update_date := l_okc_timevalues_tl_rec.last_update_date;
      END IF;
      IF (x_okc_timevalues_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_timevalues_tl_rec.last_update_login := l_okc_timevalues_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKC_TIMEVALUES_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_timevalues_tl_rec IN  okc_timevalues_tl_rec_type,
      x_okc_timevalues_tl_rec OUT NOCOPY okc_timevalues_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_timevalues_tl_rec := p_okc_timevalues_tl_rec;
      x_okc_timevalues_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      x_okc_timevalues_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
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
      p_okc_timevalues_tl_rec,           -- IN
      l_okc_timevalues_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_timevalues_tl_rec, l_def_okc_timevalues_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_TIMEVALUES_TL
    SET DESCRIPTION = l_def_okc_timevalues_tl_rec.description,
        SHORT_DESCRIPTION = l_def_okc_timevalues_tl_rec.short_description,
        COMMENTS = l_def_okc_timevalues_tl_rec.comments,
        NAME = l_def_okc_timevalues_tl_rec.name,
        CREATED_BY = l_def_okc_timevalues_tl_rec.created_by,
        CREATION_DATE = l_def_okc_timevalues_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okc_timevalues_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okc_timevalues_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okc_timevalues_tl_rec.last_update_login
    WHERE ID = l_def_okc_timevalues_tl_rec.id
      AND USERENV('LANG') IN (SOURCE_LANG,LANGUAGE);

    UPDATE  OKC_TIMEVALUES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okc_timevalues_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');
    x_okc_timevalues_tl_rec := l_def_okc_timevalues_tl_rec;
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
*/
  --------------------------------------------
  -- update_row for:OKC_TIME_TPA_RELATIVE_V --
  --------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN talv_rec_type,
    x_talv_rec                     OUT NOCOPY talv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_talv_rec                     talv_rec_type := p_talv_rec;
    l_def_talv_rec                 talv_rec_type;
--Bug 3122962    l_okc_timevalues_tl_rec        okc_timevalues_tl_rec_type;
--Bug 3122962    lx_okc_timevalues_tl_rec       okc_timevalues_tl_rec_type;
    l_tve_rec                      tve_rec_type;
    lx_tve_rec                     tve_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_talv_rec	IN talv_rec_type
    ) RETURN talv_rec_type IS
      l_talv_rec	talv_rec_type := p_talv_rec;
    BEGIN
      l_talv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_talv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_talv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_talv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_talv_rec	IN talv_rec_type,
      x_talv_rec	OUT NOCOPY talv_rec_type
    ) RETURN VARCHAR2 IS
      l_talv_rec                     talv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_talv_rec := p_talv_rec;
      -- Get current database values
      l_talv_rec := get_rec(p_talv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_talv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.id := l_talv_rec.id;
      END IF;
      IF (x_talv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.object_version_number := l_talv_rec.object_version_number;
      END IF;
--Bug 3122962
/*      IF (x_talv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.sfwt_flag := l_talv_rec.sfwt_flag;
      END IF;
*/
      IF (x_talv_rec.spn_id = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.spn_id := l_talv_rec.spn_id;
      END IF;
      IF (x_talv_rec.tve_id_offset = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.tve_id_offset := l_talv_rec.tve_id_offset;
      END IF;
      IF (x_talv_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.dnz_chr_id := l_talv_rec.dnz_chr_id;
      END IF;
      IF (x_talv_rec.tze_id = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.tze_id := l_talv_rec.tze_id;
      END IF;
      IF (x_talv_rec.tve_id_limited = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.tve_id_limited := l_talv_rec.tve_id_limited;
      END IF;
      IF (x_talv_rec.uom_code = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.uom_code := l_talv_rec.uom_code;
      END IF;
      IF (x_talv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.description := l_talv_rec.description;
      END IF;
      IF (x_talv_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.short_description := l_talv_rec.short_description;
      END IF;
      IF (x_talv_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.comments := l_talv_rec.comments;
      END IF;
      IF (x_talv_rec.duration = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.duration := l_talv_rec.duration;
      END IF;
      IF (x_talv_rec.operator = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.operator := l_talv_rec.operator;
      END IF;
      IF (x_talv_rec.before_after = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.before_after := l_talv_rec.before_after;
      END IF;
      IF (x_talv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute_category := l_talv_rec.attribute_category;
      END IF;
      IF (x_talv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute1 := l_talv_rec.attribute1;
      END IF;
      IF (x_talv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute2 := l_talv_rec.attribute2;
      END IF;
      IF (x_talv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute3 := l_talv_rec.attribute3;
      END IF;
      IF (x_talv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute4 := l_talv_rec.attribute4;
      END IF;
      IF (x_talv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute5 := l_talv_rec.attribute5;
      END IF;
      IF (x_talv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute6 := l_talv_rec.attribute6;
      END IF;
      IF (x_talv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute7 := l_talv_rec.attribute7;
      END IF;
      IF (x_talv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute8 := l_talv_rec.attribute8;
      END IF;
      IF (x_talv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute9 := l_talv_rec.attribute9;
      END IF;
      IF (x_talv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute10 := l_talv_rec.attribute10;
      END IF;
      IF (x_talv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute11 := l_talv_rec.attribute11;
      END IF;
      IF (x_talv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute12 := l_talv_rec.attribute12;
      END IF;
      IF (x_talv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute13 := l_talv_rec.attribute13;
      END IF;
      IF (x_talv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute14 := l_talv_rec.attribute14;
      END IF;
      IF (x_talv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute15 := l_talv_rec.attribute15;
      END IF;
      IF (x_talv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.created_by := l_talv_rec.created_by;
      END IF;
      IF (x_talv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_talv_rec.creation_date := l_talv_rec.creation_date;
      END IF;
      IF (x_talv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.last_updated_by := l_talv_rec.last_updated_by;
      END IF;
      IF (x_talv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_talv_rec.last_update_date := l_talv_rec.last_update_date;
      END IF;
      IF (x_talv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.last_update_login := l_talv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKC_TIME_TPA_RELATIVE_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_talv_rec IN  talv_rec_type,
      x_talv_rec OUT NOCOPY talv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_talv_rec := p_talv_rec;
-- **** Added the following two lines for uppercasing *********
      x_talv_rec.BEFORE_AFTER := upper(p_talv_rec.BEFORE_AFTER);
--      x_talv_rec.SFWT_FLAG := upper(p_talv_rec.SFWT_FLAG);
      x_talv_rec.OBJECT_VERSION_NUMBER := NVL(x_talv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_talv_rec,                        -- IN
      l_talv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_talv_rec, l_def_talv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_talv_rec := fill_who_columns(l_def_talv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_talv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_talv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
--Bug 3122962    migrate(l_def_talv_rec, l_okc_timevalues_tl_rec);
    migrate(l_def_talv_rec, l_tve_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
/*    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_timevalues_tl_rec,
      lx_okc_timevalues_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_timevalues_tl_rec, l_def_talv_rec);
*/
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tve_rec,
      lx_tve_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tve_rec, l_def_talv_rec);
    x_talv_rec := l_def_talv_rec;
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
  -- PL/SQL TBL update_row for:TALV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN talv_tbl_type,
    x_talv_tbl                     OUT NOCOPY talv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_talv_tbl.COUNT > 0) THEN
      i := p_talv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_talv_rec                     => p_talv_tbl(i),
          x_talv_rec                     => x_talv_tbl(i));
        EXIT WHEN (i = p_talv_tbl.LAST);
        i := p_talv_tbl.NEXT(i);
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
  -- delete_row for:OKC_TIMEVALUES_B --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tve_rec                      IN tve_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tve_rec                      tve_rec_type:= p_tve_rec;
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
    DELETE FROM OKC_TIMEVALUES
     WHERE ID = l_tve_rec.id;

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
  --------------------------------------
  -- delete_row for:OKC_TIMEVALUES_TL --
  --------------------------------------
/*  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_timevalues_tl_rec        IN okc_timevalues_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_timevalues_tl_rec        okc_timevalues_tl_rec_type:= p_okc_timevalues_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ------------------------------------------
    -- Set_Attributes for:OKC_TIMEVALUES_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_timevalues_tl_rec IN  okc_timevalues_tl_rec_type,
      x_okc_timevalues_tl_rec OUT NOCOPY okc_timevalues_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_timevalues_tl_rec := p_okc_timevalues_tl_rec;
      x_okc_timevalues_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
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
      p_okc_timevalues_tl_rec,           -- IN
      l_okc_timevalues_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_TIMEVALUES_TL
     WHERE ID = l_okc_timevalues_tl_rec.id;

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
*/
  --------------------------------------------
  -- delete_row for:OKC_TIME_TPA_RELATIVE_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN talv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_talv_rec                     talv_rec_type := p_talv_rec;
--Bug 3122962    l_okc_timevalues_tl_rec        okc_timevalues_tl_rec_type;
    l_tve_rec                      tve_rec_type;
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
--Bug 3122962    migrate(l_talv_rec, l_okc_timevalues_tl_rec);
    migrate(l_talv_rec, l_tve_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
/*    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_timevalues_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
*/
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tve_rec
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
  -- PL/SQL TBL delete_row for:TALV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN talv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_talv_tbl.COUNT > 0) THEN
      i := p_talv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_talv_rec                     => p_talv_tbl(i));
        EXIT WHEN (i = p_talv_tbl.LAST);
        i := p_talv_tbl.NEXT(i);
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

END OKC_TAL_PVT;

/
