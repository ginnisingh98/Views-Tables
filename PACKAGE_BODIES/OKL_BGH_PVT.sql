--------------------------------------------------------
--  DDL for Package Body OKL_BGH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BGH_PVT" AS
/* $Header: OKLSBGHB.pls 120.3 2007/08/08 12:42:57 arajagop ship $ */

  ---------------------------------------------------------------------------
  -- Global Variables
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------
  --GLOBAL MESSAGES
     G_UNEXPECTED_ERROR CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
     G_NO_PARENT_RECORD CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
     G_SQLERRM_TOKEN    CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
     G_SQLCODE_TOKEN    CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
     G_NOT_SAME         CONSTANT   VARCHAR2(200) := 'OKL_CANNOT_BE_SAME';

  --GLOBAL VARIABLES
    G_VIEW              CONSTANT   VARCHAR2(30)  := 'OKL_BLLNG_CHRG_HDRS_V';
    G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

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
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM OKL_BLLNG_CHRG_HDRS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_BLNG_CHRG_HDRS_ALL_B B     --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_BLLNG_CHRG_HDRS_TL T SET (
        NAME,
        ORIGIN,
        DESTINATION) = (SELECT
                                  B.NAME,
                                  B.ORIGIN,
                                  B.DESTINATION
                                FROM OKL_BLLNG_CHRG_HDRS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_BLLNG_CHRG_HDRS_TL SUBB, OKL_BLLNG_CHRG_HDRS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.ORIGIN <> SUBT.ORIGIN
                      OR SUBB.DESTINATION <> SUBT.DESTINATION
                      OR (SUBB.ORIGIN IS NULL AND SUBT.ORIGIN IS NOT NULL)
                      OR (SUBB.ORIGIN IS NOT NULL AND SUBT.ORIGIN IS NULL)
                      OR (SUBB.DESTINATION IS NULL AND SUBT.DESTINATION IS NOT NULL)
                      OR (SUBB.DESTINATION IS NOT NULL AND SUBT.DESTINATION IS NULL)
              ));

    INSERT INTO OKL_BLLNG_CHRG_HDRS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        NAME,
        ORIGIN,
        DESTINATION,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.NAME,
            B.ORIGIN,
            B.DESTINATION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_BLLNG_CHRG_HDRS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_BLLNG_CHRG_HDRS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_BLLNG_CHRG_HDRS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_bgh_rec                      IN bgh_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN bgh_rec_type IS
    CURSOR bgh_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SEQUENCE_NUMBER,
            DATE_TRANSMISSION,
            OBJECT_VERSION_NUMBER,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORG_ID,
			TRX_STATUS_CODE,
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
      FROM Okl_Bllng_Chrg_Hdrs_B
     WHERE okl_bllng_chrg_hdrs_b.id = p_id;
    l_bgh_pk                       bgh_pk_csr%ROWTYPE;
    l_bgh_rec                      bgh_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN bgh_pk_csr (p_bgh_rec.id);
    FETCH bgh_pk_csr INTO
              l_bgh_rec.ID,
              l_bgh_rec.SEQUENCE_NUMBER,
              l_bgh_rec.DATE_TRANSMISSION,
              l_bgh_rec.OBJECT_VERSION_NUMBER,
              l_bgh_rec.REQUEST_ID,
              l_bgh_rec.PROGRAM_APPLICATION_ID,
              l_bgh_rec.PROGRAM_ID,
              l_bgh_rec.PROGRAM_UPDATE_DATE,
              l_bgh_rec.ORG_ID,
              l_bgh_rec.TRX_STATUS_CODE,
              l_bgh_rec.ATTRIBUTE_CATEGORY,
              l_bgh_rec.ATTRIBUTE1,
              l_bgh_rec.ATTRIBUTE2,
              l_bgh_rec.ATTRIBUTE3,
              l_bgh_rec.ATTRIBUTE4,
              l_bgh_rec.ATTRIBUTE5,
              l_bgh_rec.ATTRIBUTE6,
              l_bgh_rec.ATTRIBUTE7,
              l_bgh_rec.ATTRIBUTE8,
              l_bgh_rec.ATTRIBUTE9,
              l_bgh_rec.ATTRIBUTE10,
              l_bgh_rec.ATTRIBUTE11,
              l_bgh_rec.ATTRIBUTE12,
              l_bgh_rec.ATTRIBUTE13,
              l_bgh_rec.ATTRIBUTE14,
              l_bgh_rec.ATTRIBUTE15,
              l_bgh_rec.CREATED_BY,
              l_bgh_rec.CREATION_DATE,
              l_bgh_rec.LAST_UPDATED_BY,
              l_bgh_rec.LAST_UPDATE_DATE,
              l_bgh_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := bgh_pk_csr%NOTFOUND;
    CLOSE bgh_pk_csr;
    RETURN(l_bgh_rec);
  END get_rec;

  FUNCTION get_rec (
    p_bgh_rec                      IN bgh_rec_type
  ) RETURN bgh_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_bgh_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_BLLNG_CHRG_HDRS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_bllng_chrg_hdrs_tl_rec   IN OklBllngChrgHdrsTlRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OklBllngChrgHdrsTlRecType IS
    CURSOR okl_bllng_chrg_hdrs_tl_pk_csr (p_id                 IN NUMBER,
                                          p_language           IN VARCHAR2) IS
    SELECT
            ID,
            Okl_Bllng_Chrg_Hdrs_Tl.LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            NAME,
            ORIGIN,
            DESTINATION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Bllng_Chrg_Hdrs_Tl
     WHERE okl_bllng_chrg_hdrs_tl.id = p_id
       AND okl_bllng_chrg_hdrs_tl.LANGUAGE = p_language;
    l_okl_bllng_chrg_hdrs_tl_pk    okl_bllng_chrg_hdrs_tl_pk_csr%ROWTYPE;
    l_okl_bllng_chrg_hdrs_tl_rec   OklBllngChrgHdrsTlRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_bllng_chrg_hdrs_tl_pk_csr (p_okl_bllng_chrg_hdrs_tl_rec.id,
                                        p_okl_bllng_chrg_hdrs_tl_rec.LANGUAGE);
    FETCH okl_bllng_chrg_hdrs_tl_pk_csr INTO
              l_okl_bllng_chrg_hdrs_tl_rec.ID,
              l_okl_bllng_chrg_hdrs_tl_rec.LANGUAGE,
              l_okl_bllng_chrg_hdrs_tl_rec.SOURCE_LANG,
              l_okl_bllng_chrg_hdrs_tl_rec.SFWT_FLAG,
              l_okl_bllng_chrg_hdrs_tl_rec.NAME,
              l_okl_bllng_chrg_hdrs_tl_rec.ORIGIN,
              l_okl_bllng_chrg_hdrs_tl_rec.DESTINATION,
              l_okl_bllng_chrg_hdrs_tl_rec.CREATED_BY,
              l_okl_bllng_chrg_hdrs_tl_rec.CREATION_DATE,
              l_okl_bllng_chrg_hdrs_tl_rec.LAST_UPDATED_BY,
              l_okl_bllng_chrg_hdrs_tl_rec.LAST_UPDATE_DATE,
              l_okl_bllng_chrg_hdrs_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_bllng_chrg_hdrs_tl_pk_csr%NOTFOUND;
    CLOSE okl_bllng_chrg_hdrs_tl_pk_csr;
    RETURN(l_okl_bllng_chrg_hdrs_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_bllng_chrg_hdrs_tl_rec   IN OklBllngChrgHdrsTlRecType
  ) RETURN OklBllngChrgHdrsTlRecType IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_bllng_chrg_hdrs_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_BLLNG_CHRG_HDRS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_bghv_rec                     IN bghv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN bghv_rec_type IS
    CURSOR okl_bghv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            NAME,
            SEQUENCE_NUMBER,
            DATE_TRANSMISSION,
            ORIGIN,
            DESTINATION,
			TRX_STATUS_CODE,
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
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Bllng_Chrg_Hdrs_V
     WHERE okl_bllng_chrg_hdrs_v.id = p_id;
    l_okl_bghv_pk                  okl_bghv_pk_csr%ROWTYPE;
    l_bghv_rec                     bghv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_bghv_pk_csr (p_bghv_rec.id);
    FETCH okl_bghv_pk_csr INTO
              l_bghv_rec.ID,
              l_bghv_rec.OBJECT_VERSION_NUMBER,
              l_bghv_rec.SFWT_FLAG,
              l_bghv_rec.NAME,
              l_bghv_rec.SEQUENCE_NUMBER,
              l_bghv_rec.DATE_TRANSMISSION,
              l_bghv_rec.ORIGIN,
              l_bghv_rec.DESTINATION,
              l_bghv_rec.TRX_STATUS_CODE,
              l_bghv_rec.ATTRIBUTE_CATEGORY,
              l_bghv_rec.ATTRIBUTE1,
              l_bghv_rec.ATTRIBUTE2,
              l_bghv_rec.ATTRIBUTE3,
              l_bghv_rec.ATTRIBUTE4,
              l_bghv_rec.ATTRIBUTE5,
              l_bghv_rec.ATTRIBUTE6,
              l_bghv_rec.ATTRIBUTE7,
              l_bghv_rec.ATTRIBUTE8,
              l_bghv_rec.ATTRIBUTE9,
              l_bghv_rec.ATTRIBUTE10,
              l_bghv_rec.ATTRIBUTE11,
              l_bghv_rec.ATTRIBUTE12,
              l_bghv_rec.ATTRIBUTE13,
              l_bghv_rec.ATTRIBUTE14,
              l_bghv_rec.ATTRIBUTE15,
              l_bghv_rec.REQUEST_ID,
              l_bghv_rec.PROGRAM_APPLICATION_ID,
              l_bghv_rec.PROGRAM_ID,
              l_bghv_rec.PROGRAM_UPDATE_DATE,
              l_bghv_rec.ORG_ID,
              l_bghv_rec.CREATED_BY,
              l_bghv_rec.CREATION_DATE,
              l_bghv_rec.LAST_UPDATED_BY,
              l_bghv_rec.LAST_UPDATE_DATE,
              l_bghv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_bghv_pk_csr%NOTFOUND;
    CLOSE okl_bghv_pk_csr;
    RETURN(l_bghv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_bghv_rec                     IN bghv_rec_type
  ) RETURN bghv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_bghv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_BLLNG_CHRG_HDRS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_bghv_rec	IN bghv_rec_type
  ) RETURN bghv_rec_type IS
    l_bghv_rec	bghv_rec_type := p_bghv_rec;
  BEGIN
    IF (l_bghv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
      l_bghv_rec.object_version_number := NULL;
    END IF;
    IF (l_bghv_rec.sfwt_flag = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_bghv_rec.name = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.name := NULL;
    END IF;
    IF (l_bghv_rec.sequence_number = Okl_Api.G_MISS_NUM) THEN
      l_bghv_rec.sequence_number := NULL;
    END IF;
    IF (l_bghv_rec.date_transmission = Okl_Api.G_MISS_DATE) THEN
      l_bghv_rec.date_transmission := NULL;
    END IF;
    IF (l_bghv_rec.origin = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.origin := NULL;
    END IF;
    IF (l_bghv_rec.destination = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.destination := NULL;
    END IF;
    IF (l_bghv_rec.trx_status_code = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.trx_status_code := NULL;
    END IF;
    IF (l_bghv_rec.attribute_category = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.attribute_category := NULL;
    END IF;
    IF (l_bghv_rec.attribute1 = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.attribute1 := NULL;
    END IF;
    IF (l_bghv_rec.attribute2 = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.attribute2 := NULL;
    END IF;
    IF (l_bghv_rec.attribute3 = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.attribute3 := NULL;
    END IF;
    IF (l_bghv_rec.attribute4 = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.attribute4 := NULL;
    END IF;
    IF (l_bghv_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.attribute5 := NULL;
    END IF;
    IF (l_bghv_rec.attribute6 = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.attribute6 := NULL;
    END IF;
    IF (l_bghv_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.attribute7 := NULL;
    END IF;
    IF (l_bghv_rec.attribute8 = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.attribute8 := NULL;
    END IF;
    IF (l_bghv_rec.attribute9 = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.attribute9 := NULL;
    END IF;
    IF (l_bghv_rec.attribute10 = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.attribute10 := NULL;
    END IF;
    IF (l_bghv_rec.attribute11 = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.attribute11 := NULL;
    END IF;
    IF (l_bghv_rec.attribute12 = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.attribute12 := NULL;
    END IF;
    IF (l_bghv_rec.attribute13 = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.attribute13 := NULL;
    END IF;
    IF (l_bghv_rec.attribute14 = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.attribute14 := NULL;
    END IF;
    IF (l_bghv_rec.attribute15 = Okl_Api.G_MISS_CHAR) THEN
      l_bghv_rec.attribute15 := NULL;
    END IF;
    IF (l_bghv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
      l_bghv_rec.request_id := NULL;
    END IF;
    IF (l_bghv_rec.program_application_id = Okl_Api.G_MISS_NUM) THEN
      l_bghv_rec.program_application_id := NULL;
    END IF;
    IF (l_bghv_rec.program_id = Okl_Api.G_MISS_NUM) THEN
      l_bghv_rec.program_id := NULL;
    END IF;
    IF (l_bghv_rec.program_update_date = Okl_Api.G_MISS_DATE) THEN
      l_bghv_rec.program_update_date := NULL;
    END IF;
    IF (l_bghv_rec.org_id = Okl_Api.G_MISS_NUM) THEN
      l_bghv_rec.org_id := NULL;
    END IF;
    IF (l_bghv_rec.created_by = Okl_Api.G_MISS_NUM) THEN
      l_bghv_rec.created_by := NULL;
    END IF;
    IF (l_bghv_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
      l_bghv_rec.creation_date := NULL;
    END IF;
    IF (l_bghv_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
      l_bghv_rec.last_updated_by := NULL;
    END IF;
    IF (l_bghv_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
      l_bghv_rec.last_update_date := NULL;
    END IF;
    IF (l_bghv_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
      l_bghv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_bghv_rec);
  END null_out_defaults;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Id
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Id (
    x_return_status OUT NOCOPY VARCHAR2,
    p_bghv_rec		  IN  bghv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= Okl_Api.G_RET_STS_SUCCESS;

    -- data is required
    IF p_bghv_rec.id = Okl_Api.G_MISS_NUM
    OR p_bghv_rec.id IS NULL
    THEN

      -- display error message
      Okl_Api.set_message(
      	p_app_name		 => G_APP_NAME,
      	p_msg_name		 => G_REQUIRED_VALUE,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'id');

      -- notify caller of en error
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      -- halt furhter validation of the column
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; continue validation
      NULL;

    WHEN OTHERS THEN
      -- display error message
      Okl_Api.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Object_Version_Number
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Object_Version_Number (
    x_return_status OUT NOCOPY VARCHAR2,
    p_bghv_rec		  IN  bghv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= Okl_Api.G_RET_STS_SUCCESS;

    -- data is required
    IF p_bghv_rec.object_version_number = Okl_Api.G_MISS_NUM
    OR p_bghv_rec.object_version_number IS NULL
    THEN

      -- display error message
      Okl_Api.set_message(
      	p_app_name		 => G_APP_NAME,
      	p_msg_name		 => G_REQUIRED_VALUE,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'object_version_number');

      -- notify caller of en error
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      -- halt furhter validation of the column
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; continue validation
      NULL;

    WHEN OTHERS THEN
      -- display error message
      Okl_Api.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Name
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Name (
    x_return_status OUT NOCOPY VARCHAR2,
    p_bghv_rec		  IN  bghv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= Okl_Api.G_RET_STS_SUCCESS;

    -- data is required
    IF p_bghv_rec.name = Okl_Api.G_MISS_CHAR
    OR p_bghv_rec.name IS NULL
    THEN

      -- display error message
      Okl_Api.set_message(
      	p_app_name		 => G_APP_NAME,
      	p_msg_name		 => G_REQUIRED_VALUE,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'name');

      -- notify caller of en error
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      -- halt furhter validation of the column
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; continue validation
      NULL;

    WHEN OTHERS THEN
      -- display error message
      Okl_Api.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Name;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sequence_Number
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Sequence_Number (
    x_return_status OUT NOCOPY VARCHAR2,
    p_bghv_rec		  IN  bghv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= Okl_Api.G_RET_STS_SUCCESS;

    -- data is required
    IF p_bghv_rec.sequence_number = Okl_Api.G_MISS_NUM
    OR p_bghv_rec.sequence_number IS NULL
    THEN

      -- display error message
      Okl_Api.set_message(
      	p_app_name		 => G_APP_NAME,
      	p_msg_name		 => G_REQUIRED_VALUE,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'sequence_number');

      -- notify caller of en error
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      -- halt furhter validation of the column
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; continue validation
      NULL;

    WHEN OTHERS THEN
      -- display error message
      Okl_Api.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Sequence_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Date_Transmission
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Date_Transmission (
    x_return_status OUT NOCOPY VARCHAR2,
    p_bghv_rec		  IN  bghv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= Okl_Api.G_RET_STS_SUCCESS;

    -- data is required
    IF p_bghv_rec.date_transmission = Okl_Api.G_MISS_DATE
    OR p_bghv_rec.date_transmission IS NULL
    THEN

      -- display error message
      Okl_Api.set_message(
      	p_app_name		 => G_APP_NAME,
      	p_msg_name		 => G_REQUIRED_VALUE,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'date_transmission');

      -- notify caller of en error
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      -- halt furhter validation of the column
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; continue validation
      NULL;

    WHEN OTHERS THEN
      -- display error message
      Okl_Api.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Date_Transmission;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Org_Id
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Org_Id (
    x_return_status OUT NOCOPY VARCHAR2,
    p_bghv_rec		  IN  bghv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= Okl_Api.G_RET_STS_SUCCESS;

    -- check value
    --IF  p_bghv_rec.org_id <> OKL_API.G_MISS_NUM
    --AND p_bghv_rec.org_id IS NOT NULL
    --THEN
      x_return_status := Okl_Util.check_org_id (p_bghv_rec.org_id);
    --END IF;

  EXCEPTION

    WHEN OTHERS THEN
      -- display error message
      Okl_Api.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Org_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Is_Unique
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------
  FUNCTION Is_Unique (
    p_bghv_rec IN bghv_rec_type
  ) RETURN VARCHAR2 IS

    CURSOR l_bghv_csr IS
		  SELECT 'x'
		  FROM   okl_bllng_chrg_hdrs_v
		  WHERE  name            = p_bghv_rec.name
		  AND    sequence_number = p_bghv_rec.sequence_number
		  AND    id              <> NVL (p_bghv_rec.id, -99999);

    l_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_dummy             VARCHAR2(1);
    l_found             BOOLEAN;

  BEGIN

    -- check for unique NAME + SEQUENCE_NUMBER
    OPEN     l_bghv_csr;
    FETCH    l_bghv_csr INTO l_dummy;
	  l_found  := l_bghv_csr%FOUND;
	  CLOSE    l_bghv_csr;

    IF (l_found) THEN

      -- display error message
      Okl_Api.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_NOT_SAME,
      	p_token1          => 'NAME',
      	p_token1_value    => p_bghv_rec.name,
      	p_token2          => 'SEQUENCE_NUMBER',
      	p_token2_value    => p_bghv_rec.sequence_number);

      -- notify caller of an error
      l_return_status := Okl_Api.G_RET_STS_ERROR;

    END IF;

    -- return status to the caller
    RETURN l_return_status;

  EXCEPTION

    WHEN OTHERS THEN
      -- display error message
      Okl_Api.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      -- verify the cursor is closed
      IF l_bghv_csr%ISOPEN THEN
         CLOSE l_bghv_csr;
      END IF;
      -- return status to the caller
      RETURN l_return_status;

  END Is_Unique;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_BLLNG_CHRG_HDRS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_bghv_rec IN  bghv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN

    -- call each column-level validation

    validate_id (
      x_return_status => l_return_status,
      p_bghv_rec      => p_bghv_rec);

    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_object_version_number (
      x_return_status => l_return_status,
      p_bghv_rec      => p_bghv_rec);

    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_name (
      x_return_status => l_return_status,
      p_bghv_rec      => p_bghv_rec);

    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_sequence_number (
      x_return_status => l_return_status,
      p_bghv_rec      => p_bghv_rec);

    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_date_transmission (
      x_return_status => l_return_status,
      p_bghv_rec      => p_bghv_rec);

    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_org_id (
      x_return_status => l_return_status,
      p_bghv_rec      => p_bghv_rec);

    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    RETURN x_return_status;

  EXCEPTION

    WHEN OTHERS THEN
      -- display error message
      Okl_Api.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      -- return status to the caller
      RETURN x_return_status;

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_BLLNG_CHRG_HDRS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_bghv_rec IN bghv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN

    -- call each record-level validation
    l_return_status := is_unique (p_bghv_rec);

    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    RETURN x_return_status;

  EXCEPTION

    WHEN OTHERS THEN
      -- display error message
      Okl_Api.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      -- return status to the caller
      RETURN x_return_status;

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN bghv_rec_type,
    p_to	IN OUT NOCOPY bgh_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sequence_number := p_from.sequence_number;
    p_to.date_transmission := p_from.date_transmission;
    p_to.object_version_number := p_from.object_version_number;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.trx_status_code := p_from.trx_status_code;
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
    p_from	IN bgh_rec_type,
    p_to	IN OUT NOCOPY bghv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sequence_number := p_from.sequence_number;
    p_to.date_transmission := p_from.date_transmission;
    p_to.object_version_number := p_from.object_version_number;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
    p_to.trx_status_code := p_from.trx_status_code;
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
    p_from	IN bghv_rec_type,
    p_to	IN OUT NOCOPY OklBllngChrgHdrsTlRecType
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.origin := p_from.origin;
    p_to.destination := p_from.destination;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN OklBllngChrgHdrsTlRecType,
    p_to	IN OUT NOCOPY bghv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.origin := p_from.origin;
    p_to.destination := p_from.destination;
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
  -- validate_row for:OKL_BLLNG_CHRG_HDRS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bghv_rec                     IN bghv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_bghv_rec                     bghv_rec_type := p_bghv_rec;
    l_bgh_rec                      bgh_rec_type;
    l_okl_bllng_chrg_hdrs_tl_rec   OklBllngChrgHdrsTlRecType;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_bghv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_bghv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
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
  END validate_row;
  ------------------------------------------
  -- PL/SQL TBL validate_row for:BGHV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bghv_tbl                     IN bghv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bghv_tbl.COUNT > 0) THEN
      i := p_bghv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bghv_rec                     => p_bghv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_bghv_tbl.LAST);
        i := p_bghv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
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
  END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- insert_row for:OKL_BLLNG_CHRG_HDRS_B --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bgh_rec                      IN bgh_rec_type,
    x_bgh_rec                      OUT NOCOPY bgh_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_bgh_rec                      bgh_rec_type := p_bgh_rec;
    l_def_bgh_rec                  bgh_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_BLLNG_CHRG_HDRS_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_bgh_rec IN  bgh_rec_type,
      x_bgh_rec OUT NOCOPY bgh_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_bgh_rec := p_bgh_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_bgh_rec,                         -- IN
      l_bgh_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_BLLNG_CHRG_HDRS_B(
        id,
        sequence_number,
        date_transmission,
        object_version_number,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        org_id,
		trx_status_code,
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
        l_bgh_rec.id,
        l_bgh_rec.sequence_number,
        l_bgh_rec.date_transmission,
        l_bgh_rec.object_version_number,
        l_bgh_rec.request_id,
        l_bgh_rec.program_application_id,
        l_bgh_rec.program_id,
        l_bgh_rec.program_update_date,
        l_bgh_rec.org_id,
        l_bgh_rec.trx_status_code,
        l_bgh_rec.attribute_category,
        l_bgh_rec.attribute1,
        l_bgh_rec.attribute2,
        l_bgh_rec.attribute3,
        l_bgh_rec.attribute4,
        l_bgh_rec.attribute5,
        l_bgh_rec.attribute6,
        l_bgh_rec.attribute7,
        l_bgh_rec.attribute8,
        l_bgh_rec.attribute9,
        l_bgh_rec.attribute10,
        l_bgh_rec.attribute11,
        l_bgh_rec.attribute12,
        l_bgh_rec.attribute13,
        l_bgh_rec.attribute14,
        l_bgh_rec.attribute15,
        l_bgh_rec.created_by,
        l_bgh_rec.creation_date,
        l_bgh_rec.last_updated_by,
        l_bgh_rec.last_update_date,
        l_bgh_rec.last_update_login);
    -- Set OUT values
    x_bgh_rec := l_bgh_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
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
  END insert_row;
  -------------------------------------------
  -- insert_row for:OKL_BLLNG_CHRG_HDRS_TL --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_bllng_chrg_hdrs_tl_rec   IN OklBllngChrgHdrsTlRecType,
    x_okl_bllng_chrg_hdrs_tl_rec   OUT NOCOPY OklBllngChrgHdrsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_bllng_chrg_hdrs_tl_rec   OklBllngChrgHdrsTlRecType := p_okl_bllng_chrg_hdrs_tl_rec;
    ldefoklbllngchrghdrstlrec      OklBllngChrgHdrsTlRecType;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------------
    -- Set_Attributes for:OKL_BLLNG_CHRG_HDRS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_bllng_chrg_hdrs_tl_rec IN  OklBllngChrgHdrsTlRecType,
      x_okl_bllng_chrg_hdrs_tl_rec OUT NOCOPY OklBllngChrgHdrsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_bllng_chrg_hdrs_tl_rec := p_okl_bllng_chrg_hdrs_tl_rec;
      x_okl_bllng_chrg_hdrs_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_bllng_chrg_hdrs_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_bllng_chrg_hdrs_tl_rec,      -- IN
      l_okl_bllng_chrg_hdrs_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_bllng_chrg_hdrs_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_BLLNG_CHRG_HDRS_TL(
          id,
          LANGUAGE,
          source_lang,
          sfwt_flag,
          name,
          origin,
          destination,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_bllng_chrg_hdrs_tl_rec.id,
          l_okl_bllng_chrg_hdrs_tl_rec.LANGUAGE,
          l_okl_bllng_chrg_hdrs_tl_rec.source_lang,
          l_okl_bllng_chrg_hdrs_tl_rec.sfwt_flag,
          l_okl_bllng_chrg_hdrs_tl_rec.name,
          l_okl_bllng_chrg_hdrs_tl_rec.origin,
          l_okl_bllng_chrg_hdrs_tl_rec.destination,
          l_okl_bllng_chrg_hdrs_tl_rec.created_by,
          l_okl_bllng_chrg_hdrs_tl_rec.creation_date,
          l_okl_bllng_chrg_hdrs_tl_rec.last_updated_by,
          l_okl_bllng_chrg_hdrs_tl_rec.last_update_date,
          l_okl_bllng_chrg_hdrs_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_bllng_chrg_hdrs_tl_rec := l_okl_bllng_chrg_hdrs_tl_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
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
  END insert_row;
  ------------------------------------------
  -- insert_row for:OKL_BLLNG_CHRG_HDRS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bghv_rec                     IN bghv_rec_type,
    x_bghv_rec                     OUT NOCOPY bghv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_bghv_rec                     bghv_rec_type;
    l_def_bghv_rec                 bghv_rec_type;
    l_bgh_rec                      bgh_rec_type;
    lx_bgh_rec                     bgh_rec_type;
    l_okl_bllng_chrg_hdrs_tl_rec   OklBllngChrgHdrsTlRecType;
    lx_okl_bllng_chrg_hdrs_tl_rec  OklBllngChrgHdrsTlRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_bghv_rec	IN bghv_rec_type
    ) RETURN bghv_rec_type IS
      l_bghv_rec	bghv_rec_type := p_bghv_rec;
    BEGIN
      l_bghv_rec.CREATION_DATE := SYSDATE;
      l_bghv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_bghv_rec.LAST_UPDATE_DATE := l_bghv_rec.CREATION_DATE;
      l_bghv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_bghv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_bghv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_BLLNG_CHRG_HDRS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_bghv_rec IN  bghv_rec_type,
      x_bghv_rec OUT NOCOPY bghv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_bghv_rec := p_bghv_rec;
      x_bghv_rec.OBJECT_VERSION_NUMBER := 1;
      -- Begin Post-Generation Change
      SELECT
        DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
        DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
        DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
        DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
      INTO
        x_bghv_rec.request_id,
        x_bghv_rec.program_application_id,
        x_bghv_rec.program_id,
        x_bghv_rec.program_update_date
      FROM   dual;
      -- End Post-Generation Change
      x_bghv_rec.SFWT_FLAG := 'N';
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_bghv_rec := null_out_defaults(p_bghv_rec);
    -- Set primary key value
    l_bghv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_bghv_rec,                        -- IN
      l_def_bghv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_bghv_rec := fill_who_columns(l_def_bghv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_bghv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_bghv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_bghv_rec, l_bgh_rec);
    migrate(l_def_bghv_rec, l_okl_bllng_chrg_hdrs_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_bgh_rec,
      lx_bgh_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_bgh_rec, l_def_bghv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_bllng_chrg_hdrs_tl_rec,
      lx_okl_bllng_chrg_hdrs_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_bllng_chrg_hdrs_tl_rec, l_def_bghv_rec);
    -- Set OUT values
    x_bghv_rec := l_def_bghv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
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
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:BGHV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bghv_tbl                     IN bghv_tbl_type,
    x_bghv_tbl                     OUT NOCOPY bghv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bghv_tbl.COUNT > 0) THEN
      i := p_bghv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bghv_rec                     => p_bghv_tbl(i),
          x_bghv_rec                     => x_bghv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_bghv_tbl.LAST);
        i := p_bghv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
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
  END insert_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- lock_row for:OKL_BLLNG_CHRG_HDRS_B --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bgh_rec                      IN bgh_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_bgh_rec IN bgh_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_BLLNG_CHRG_HDRS_B
     WHERE ID = p_bgh_rec.id
       AND OBJECT_VERSION_NUMBER = p_bgh_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_bgh_rec IN bgh_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_BLLNG_CHRG_HDRS_B
    WHERE ID = p_bgh_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_BLLNG_CHRG_HDRS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_BLLNG_CHRG_HDRS_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_bgh_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okl_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_bgh_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_bgh_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_bgh_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okl_Api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
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
  END lock_row;
  -----------------------------------------
  -- lock_row for:OKL_BLLNG_CHRG_HDRS_TL --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_bllng_chrg_hdrs_tl_rec   IN OklBllngChrgHdrsTlRecType) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_bllng_chrg_hdrs_tl_rec IN OklBllngChrgHdrsTlRecType) IS
    SELECT *
      FROM OKL_BLLNG_CHRG_HDRS_TL
     WHERE ID = p_okl_bllng_chrg_hdrs_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_okl_bllng_chrg_hdrs_tl_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okl_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
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
  END lock_row;
  ----------------------------------------
  -- lock_row for:OKL_BLLNG_CHRG_HDRS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bghv_rec                     IN bghv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_bgh_rec                      bgh_rec_type;
    l_okl_bllng_chrg_hdrs_tl_rec   OklBllngChrgHdrsTlRecType;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_bghv_rec, l_bgh_rec);
    migrate(p_bghv_rec, l_okl_bllng_chrg_hdrs_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_bgh_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_bllng_chrg_hdrs_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
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
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:BGHV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bghv_tbl                     IN bghv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bghv_tbl.COUNT > 0) THEN
      i := p_bghv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bghv_rec                     => p_bghv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_bghv_tbl.LAST);
        i := p_bghv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
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
  END lock_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- update_row for:OKL_BLLNG_CHRG_HDRS_B --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bgh_rec                      IN bgh_rec_type,
    x_bgh_rec                      OUT NOCOPY bgh_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_bgh_rec                      bgh_rec_type := p_bgh_rec;
    l_def_bgh_rec                  bgh_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_bgh_rec	IN bgh_rec_type,
      x_bgh_rec	OUT NOCOPY bgh_rec_type
    ) RETURN VARCHAR2 IS
      l_bgh_rec                      bgh_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_bgh_rec := p_bgh_rec;
      -- Get current database values
      l_bgh_rec := get_rec(p_bgh_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_bgh_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_bgh_rec.id := l_bgh_rec.id;
      END IF;
      IF (x_bgh_rec.sequence_number = Okl_Api.G_MISS_NUM)
      THEN
        x_bgh_rec.sequence_number := l_bgh_rec.sequence_number;
      END IF;
      IF (x_bgh_rec.date_transmission = Okl_Api.G_MISS_DATE)
      THEN
        x_bgh_rec.date_transmission := l_bgh_rec.date_transmission;
      END IF;
      IF (x_bgh_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_bgh_rec.object_version_number := l_bgh_rec.object_version_number;
      END IF;
      IF (x_bgh_rec.request_id = Okl_Api.G_MISS_NUM)
      THEN
        x_bgh_rec.request_id := l_bgh_rec.request_id;
      END IF;
      IF (x_bgh_rec.program_application_id = Okl_Api.G_MISS_NUM)
      THEN
        x_bgh_rec.program_application_id := l_bgh_rec.program_application_id;
      END IF;
      IF (x_bgh_rec.program_id = Okl_Api.G_MISS_NUM)
      THEN
        x_bgh_rec.program_id := l_bgh_rec.program_id;
      END IF;
      IF (x_bgh_rec.program_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_bgh_rec.program_update_date := l_bgh_rec.program_update_date;
      END IF;
      IF (x_bgh_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_bgh_rec.org_id := l_bgh_rec.org_id;
      END IF;
      IF (x_bgh_rec.trx_status_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_bgh_rec.trx_status_code := l_bgh_rec.trx_status_code;
      END IF;
      IF (x_bgh_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_bgh_rec.attribute_category := l_bgh_rec.attribute_category;
      END IF;
      IF (x_bgh_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bgh_rec.attribute1 := l_bgh_rec.attribute1;
      END IF;
      IF (x_bgh_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bgh_rec.attribute2 := l_bgh_rec.attribute2;
      END IF;
      IF (x_bgh_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bgh_rec.attribute3 := l_bgh_rec.attribute3;
      END IF;
      IF (x_bgh_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bgh_rec.attribute4 := l_bgh_rec.attribute4;
      END IF;
      IF (x_bgh_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bgh_rec.attribute5 := l_bgh_rec.attribute5;
      END IF;
      IF (x_bgh_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bgh_rec.attribute6 := l_bgh_rec.attribute6;
      END IF;
      IF (x_bgh_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bgh_rec.attribute7 := l_bgh_rec.attribute7;
      END IF;
      IF (x_bgh_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bgh_rec.attribute8 := l_bgh_rec.attribute8;
      END IF;
      IF (x_bgh_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bgh_rec.attribute9 := l_bgh_rec.attribute9;
      END IF;
      IF (x_bgh_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bgh_rec.attribute10 := l_bgh_rec.attribute10;
      END IF;
      IF (x_bgh_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bgh_rec.attribute11 := l_bgh_rec.attribute11;
      END IF;
      IF (x_bgh_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bgh_rec.attribute12 := l_bgh_rec.attribute12;
      END IF;
      IF (x_bgh_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bgh_rec.attribute13 := l_bgh_rec.attribute13;
      END IF;
      IF (x_bgh_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bgh_rec.attribute14 := l_bgh_rec.attribute14;
      END IF;
      IF (x_bgh_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bgh_rec.attribute15 := l_bgh_rec.attribute15;
      END IF;
      IF (x_bgh_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_bgh_rec.created_by := l_bgh_rec.created_by;
      END IF;
      IF (x_bgh_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_bgh_rec.creation_date := l_bgh_rec.creation_date;
      END IF;
      IF (x_bgh_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_bgh_rec.last_updated_by := l_bgh_rec.last_updated_by;
      END IF;
      IF (x_bgh_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_bgh_rec.last_update_date := l_bgh_rec.last_update_date;
      END IF;
      IF (x_bgh_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_bgh_rec.last_update_login := l_bgh_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_BLLNG_CHRG_HDRS_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_bgh_rec IN  bgh_rec_type,
      x_bgh_rec OUT NOCOPY bgh_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_bgh_rec := p_bgh_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_bgh_rec,                         -- IN
      l_bgh_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_bgh_rec, l_def_bgh_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_BLLNG_CHRG_HDRS_B
    SET SEQUENCE_NUMBER = l_def_bgh_rec.sequence_number,
        DATE_TRANSMISSION = l_def_bgh_rec.date_transmission,
        OBJECT_VERSION_NUMBER = l_def_bgh_rec.object_version_number,
        REQUEST_ID = l_def_bgh_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_bgh_rec.program_application_id,
        PROGRAM_ID = l_def_bgh_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_bgh_rec.program_update_date,
        ORG_ID = l_def_bgh_rec.org_id,
        TRX_STATUS_CODE = l_def_bgh_rec.trx_status_code,
        ATTRIBUTE_CATEGORY = l_def_bgh_rec.attribute_category,
        ATTRIBUTE1 = l_def_bgh_rec.attribute1,
        ATTRIBUTE2 = l_def_bgh_rec.attribute2,
        ATTRIBUTE3 = l_def_bgh_rec.attribute3,
        ATTRIBUTE4 = l_def_bgh_rec.attribute4,
        ATTRIBUTE5 = l_def_bgh_rec.attribute5,
        ATTRIBUTE6 = l_def_bgh_rec.attribute6,
        ATTRIBUTE7 = l_def_bgh_rec.attribute7,
        ATTRIBUTE8 = l_def_bgh_rec.attribute8,
        ATTRIBUTE9 = l_def_bgh_rec.attribute9,
        ATTRIBUTE10 = l_def_bgh_rec.attribute10,
        ATTRIBUTE11 = l_def_bgh_rec.attribute11,
        ATTRIBUTE12 = l_def_bgh_rec.attribute12,
        ATTRIBUTE13 = l_def_bgh_rec.attribute13,
        ATTRIBUTE14 = l_def_bgh_rec.attribute14,
        ATTRIBUTE15 = l_def_bgh_rec.attribute15,
        CREATED_BY = l_def_bgh_rec.created_by,
        CREATION_DATE = l_def_bgh_rec.creation_date,
        LAST_UPDATED_BY = l_def_bgh_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_bgh_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_bgh_rec.last_update_login
    WHERE ID = l_def_bgh_rec.id;

    x_bgh_rec := l_def_bgh_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
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
  END update_row;
  -------------------------------------------
  -- update_row for:OKL_BLLNG_CHRG_HDRS_TL --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_bllng_chrg_hdrs_tl_rec   IN OklBllngChrgHdrsTlRecType,
    x_okl_bllng_chrg_hdrs_tl_rec   OUT NOCOPY OklBllngChrgHdrsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_bllng_chrg_hdrs_tl_rec   OklBllngChrgHdrsTlRecType := p_okl_bllng_chrg_hdrs_tl_rec;
    ldefoklbllngchrghdrstlrec      OklBllngChrgHdrsTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_bllng_chrg_hdrs_tl_rec	IN OklBllngChrgHdrsTlRecType,
      x_okl_bllng_chrg_hdrs_tl_rec	OUT NOCOPY OklBllngChrgHdrsTlRecType
    ) RETURN VARCHAR2 IS
      l_okl_bllng_chrg_hdrs_tl_rec   OklBllngChrgHdrsTlRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_bllng_chrg_hdrs_tl_rec := p_okl_bllng_chrg_hdrs_tl_rec;
      -- Get current database values
      l_okl_bllng_chrg_hdrs_tl_rec := get_rec(p_okl_bllng_chrg_hdrs_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_bllng_chrg_hdrs_tl_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_bllng_chrg_hdrs_tl_rec.id := l_okl_bllng_chrg_hdrs_tl_rec.id;
      END IF;
      IF (x_okl_bllng_chrg_hdrs_tl_rec.LANGUAGE = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_bllng_chrg_hdrs_tl_rec.LANGUAGE := l_okl_bllng_chrg_hdrs_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_bllng_chrg_hdrs_tl_rec.source_lang = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_bllng_chrg_hdrs_tl_rec.source_lang := l_okl_bllng_chrg_hdrs_tl_rec.source_lang;
      END IF;
      IF (x_okl_bllng_chrg_hdrs_tl_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_bllng_chrg_hdrs_tl_rec.sfwt_flag := l_okl_bllng_chrg_hdrs_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_bllng_chrg_hdrs_tl_rec.name = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_bllng_chrg_hdrs_tl_rec.name := l_okl_bllng_chrg_hdrs_tl_rec.name;
      END IF;
      IF (x_okl_bllng_chrg_hdrs_tl_rec.origin = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_bllng_chrg_hdrs_tl_rec.origin := l_okl_bllng_chrg_hdrs_tl_rec.origin;
      END IF;
      IF (x_okl_bllng_chrg_hdrs_tl_rec.destination = Okl_Api.G_MISS_CHAR)
      THEN
        x_okl_bllng_chrg_hdrs_tl_rec.destination := l_okl_bllng_chrg_hdrs_tl_rec.destination;
      END IF;
      IF (x_okl_bllng_chrg_hdrs_tl_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_bllng_chrg_hdrs_tl_rec.created_by := l_okl_bllng_chrg_hdrs_tl_rec.created_by;
      END IF;
      IF (x_okl_bllng_chrg_hdrs_tl_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_okl_bllng_chrg_hdrs_tl_rec.creation_date := l_okl_bllng_chrg_hdrs_tl_rec.creation_date;
      END IF;
      IF (x_okl_bllng_chrg_hdrs_tl_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_bllng_chrg_hdrs_tl_rec.last_updated_by := l_okl_bllng_chrg_hdrs_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_bllng_chrg_hdrs_tl_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_okl_bllng_chrg_hdrs_tl_rec.last_update_date := l_okl_bllng_chrg_hdrs_tl_rec.last_update_date;
      END IF;
      IF (x_okl_bllng_chrg_hdrs_tl_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_okl_bllng_chrg_hdrs_tl_rec.last_update_login := l_okl_bllng_chrg_hdrs_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKL_BLLNG_CHRG_HDRS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_bllng_chrg_hdrs_tl_rec IN  OklBllngChrgHdrsTlRecType,
      x_okl_bllng_chrg_hdrs_tl_rec OUT NOCOPY OklBllngChrgHdrsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_bllng_chrg_hdrs_tl_rec := p_okl_bllng_chrg_hdrs_tl_rec;
      x_okl_bllng_chrg_hdrs_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_bllng_chrg_hdrs_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_bllng_chrg_hdrs_tl_rec,      -- IN
      l_okl_bllng_chrg_hdrs_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_bllng_chrg_hdrs_tl_rec, ldefoklbllngchrghdrstlrec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_BLLNG_CHRG_HDRS_TL
    SET NAME = ldefoklbllngchrghdrstlrec.name,
        ORIGIN = ldefoklbllngchrghdrstlrec.origin,
        DESTINATION = ldefoklbllngchrghdrstlrec.destination,
        CREATED_BY = ldefoklbllngchrghdrstlrec.created_by,
        CREATION_DATE = ldefoklbllngchrghdrstlrec.creation_date,
        LAST_UPDATED_BY = ldefoklbllngchrghdrstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklbllngchrghdrstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklbllngchrghdrstlrec.last_update_login
    WHERE ID = ldefoklbllngchrghdrstlrec.id
      --AND SOURCE_LANG = USERENV('LANG');
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_BLLNG_CHRG_HDRS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklbllngchrghdrstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_bllng_chrg_hdrs_tl_rec := ldefoklbllngchrghdrstlrec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
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
  END update_row;
  ------------------------------------------
  -- update_row for:OKL_BLLNG_CHRG_HDRS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bghv_rec                     IN bghv_rec_type,
    x_bghv_rec                     OUT NOCOPY bghv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_bghv_rec                     bghv_rec_type := p_bghv_rec;
    l_def_bghv_rec                 bghv_rec_type;
    l_okl_bllng_chrg_hdrs_tl_rec   OklBllngChrgHdrsTlRecType;
    lx_okl_bllng_chrg_hdrs_tl_rec  OklBllngChrgHdrsTlRecType;
    l_bgh_rec                      bgh_rec_type;
    lx_bgh_rec                     bgh_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_bghv_rec	IN bghv_rec_type
    ) RETURN bghv_rec_type IS
      l_bghv_rec	bghv_rec_type := p_bghv_rec;
    BEGIN
      l_bghv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_bghv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_bghv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_bghv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_bghv_rec	IN bghv_rec_type,
      x_bghv_rec	OUT NOCOPY bghv_rec_type
    ) RETURN VARCHAR2 IS
      l_bghv_rec                     bghv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_bghv_rec := p_bghv_rec;
      -- Get current database values
      l_bghv_rec := get_rec(p_bghv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_bghv_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_bghv_rec.id := l_bghv_rec.id;
      END IF;
      IF (x_bghv_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_bghv_rec.object_version_number := l_bghv_rec.object_version_number;
      END IF;
      IF (x_bghv_rec.sfwt_flag = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.sfwt_flag := l_bghv_rec.sfwt_flag;
      END IF;
      IF (x_bghv_rec.name = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.name := l_bghv_rec.name;
      END IF;
      IF (x_bghv_rec.sequence_number = Okl_Api.G_MISS_NUM)
      THEN
        x_bghv_rec.sequence_number := l_bghv_rec.sequence_number;
      END IF;
      IF (x_bghv_rec.date_transmission = Okl_Api.G_MISS_DATE)
      THEN
        x_bghv_rec.date_transmission := l_bghv_rec.date_transmission;
      END IF;
      IF (x_bghv_rec.origin = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.origin := l_bghv_rec.origin;
      END IF;
      IF (x_bghv_rec.destination = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.destination := l_bghv_rec.destination;
      END IF;
      IF (x_bghv_rec.trx_status_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.trx_status_code := l_bghv_rec.trx_status_code;
      END IF;
      IF (x_bghv_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.attribute_category := l_bghv_rec.attribute_category;
      END IF;
      IF (x_bghv_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.attribute1 := l_bghv_rec.attribute1;
      END IF;
      IF (x_bghv_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.attribute2 := l_bghv_rec.attribute2;
      END IF;
      IF (x_bghv_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.attribute3 := l_bghv_rec.attribute3;
      END IF;
      IF (x_bghv_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.attribute4 := l_bghv_rec.attribute4;
      END IF;
      IF (x_bghv_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.attribute5 := l_bghv_rec.attribute5;
      END IF;
      IF (x_bghv_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.attribute6 := l_bghv_rec.attribute6;
      END IF;
      IF (x_bghv_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.attribute7 := l_bghv_rec.attribute7;
      END IF;
      IF (x_bghv_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.attribute8 := l_bghv_rec.attribute8;
      END IF;
      IF (x_bghv_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.attribute9 := l_bghv_rec.attribute9;
      END IF;
      IF (x_bghv_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.attribute10 := l_bghv_rec.attribute10;
      END IF;
      IF (x_bghv_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.attribute11 := l_bghv_rec.attribute11;
      END IF;
      IF (x_bghv_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.attribute12 := l_bghv_rec.attribute12;
      END IF;
      IF (x_bghv_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.attribute13 := l_bghv_rec.attribute13;
      END IF;
      IF (x_bghv_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.attribute14 := l_bghv_rec.attribute14;
      END IF;
      IF (x_bghv_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_bghv_rec.attribute15 := l_bghv_rec.attribute15;
      END IF;
      IF (x_bghv_rec.request_id = Okl_Api.G_MISS_NUM)
      THEN
        x_bghv_rec.request_id := l_bghv_rec.request_id;
      END IF;
      IF (x_bghv_rec.program_application_id = Okl_Api.G_MISS_NUM)
      THEN
        x_bghv_rec.program_application_id := l_bghv_rec.program_application_id;
      END IF;
      IF (x_bghv_rec.program_id = Okl_Api.G_MISS_NUM)
      THEN
        x_bghv_rec.program_id := l_bghv_rec.program_id;
      END IF;
      IF (x_bghv_rec.program_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_bghv_rec.program_update_date := l_bghv_rec.program_update_date;
      END IF;
      IF (x_bghv_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_bghv_rec.org_id := l_bghv_rec.org_id;
      END IF;
      IF (x_bghv_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_bghv_rec.created_by := l_bghv_rec.created_by;
      END IF;
      IF (x_bghv_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_bghv_rec.creation_date := l_bghv_rec.creation_date;
      END IF;
      IF (x_bghv_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_bghv_rec.last_updated_by := l_bghv_rec.last_updated_by;
      END IF;
      IF (x_bghv_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_bghv_rec.last_update_date := l_bghv_rec.last_update_date;
      END IF;
      IF (x_bghv_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_bghv_rec.last_update_login := l_bghv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_BLLNG_CHRG_HDRS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_bghv_rec IN  bghv_rec_type,
      x_bghv_rec OUT NOCOPY bghv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_bghv_rec := p_bghv_rec;
      x_bghv_rec.OBJECT_VERSION_NUMBER := NVL(x_bghv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      -- Begin Post-Generation Change
      SELECT
        NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
            x_bghv_rec.request_id),
        NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
            x_bghv_rec.program_application_id),
        NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
            x_bghv_rec.program_id),
        DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),
            NULL,x_bghv_rec.program_update_date,SYSDATE)
      INTO
        x_bghv_rec.request_id,
        x_bghv_rec.program_application_id,
        x_bghv_rec.program_id,
        x_bghv_rec.program_update_date
      FROM   dual;
      -- End Post-Generation Change
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_bghv_rec,                        -- IN
      l_bghv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_bghv_rec, l_def_bghv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_bghv_rec := fill_who_columns(l_def_bghv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_bghv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_bghv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_bghv_rec, l_okl_bllng_chrg_hdrs_tl_rec);
    migrate(l_def_bghv_rec, l_bgh_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_bllng_chrg_hdrs_tl_rec,
      lx_okl_bllng_chrg_hdrs_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_bllng_chrg_hdrs_tl_rec, l_def_bghv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_bgh_rec,
      lx_bgh_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_bgh_rec, l_def_bghv_rec);
    x_bghv_rec := l_def_bghv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
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
  END update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:BGHV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bghv_tbl                     IN bghv_tbl_type,
    x_bghv_tbl                     OUT NOCOPY bghv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bghv_tbl.COUNT > 0) THEN
      i := p_bghv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bghv_rec                     => p_bghv_tbl(i),
          x_bghv_rec                     => x_bghv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_bghv_tbl.LAST);
        i := p_bghv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
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
  END update_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- delete_row for:OKL_BLLNG_CHRG_HDRS_B --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bgh_rec                      IN bgh_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_bgh_rec                      bgh_rec_type:= p_bgh_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_BLLNG_CHRG_HDRS_B
     WHERE ID = l_bgh_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
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
  -------------------------------------------
  -- delete_row for:OKL_BLLNG_CHRG_HDRS_TL --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_bllng_chrg_hdrs_tl_rec   IN OklBllngChrgHdrsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_bllng_chrg_hdrs_tl_rec   OklBllngChrgHdrsTlRecType:= p_okl_bllng_chrg_hdrs_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -----------------------------------------------
    -- Set_Attributes for:OKL_BLLNG_CHRG_HDRS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_bllng_chrg_hdrs_tl_rec IN  OklBllngChrgHdrsTlRecType,
      x_okl_bllng_chrg_hdrs_tl_rec OUT NOCOPY OklBllngChrgHdrsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_bllng_chrg_hdrs_tl_rec := p_okl_bllng_chrg_hdrs_tl_rec;
      x_okl_bllng_chrg_hdrs_tl_rec.LANGUAGE := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_bllng_chrg_hdrs_tl_rec,      -- IN
      l_okl_bllng_chrg_hdrs_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_BLLNG_CHRG_HDRS_TL
     WHERE ID = l_okl_bllng_chrg_hdrs_tl_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
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
  ------------------------------------------
  -- delete_row for:OKL_BLLNG_CHRG_HDRS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bghv_rec                     IN bghv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_bghv_rec                     bghv_rec_type := p_bghv_rec;
    l_okl_bllng_chrg_hdrs_tl_rec   OklBllngChrgHdrsTlRecType;
    l_bgh_rec                      bgh_rec_type;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_bghv_rec, l_okl_bllng_chrg_hdrs_tl_rec);
    migrate(l_bghv_rec, l_bgh_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_bllng_chrg_hdrs_tl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_bgh_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
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
  ----------------------------------------
  -- PL/SQL TBL delete_row for:BGHV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bghv_tbl                     IN bghv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bghv_tbl.COUNT > 0) THEN
      i := p_bghv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bghv_rec                     => p_bghv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
       EXIT WHEN (i = p_bghv_tbl.LAST);
        i := p_bghv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
     END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
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
END Okl_Bgh_Pvt;

/
