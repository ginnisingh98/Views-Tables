--------------------------------------------------------
--  DDL for Package Body OKL_IMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_IMS_PVT" AS
/* $Header: OKLSIMSB.pls 120.4 2008/02/04 13:17:44 nikshah ship $ */

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
    G_VIEW              CONSTANT   VARCHAR2(30)  := 'OKL_INVOICE_MSSGS_V';
    G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

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
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM OKL_INVOICE_MSSGS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_INVOICE_MSSGS_ALL_B  B      --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_INVOICE_MSSGS_TL T SET (
        NAME,
        MESSAGE_TEXT,
        DESCRIPTION) = (SELECT
                                  B.NAME,
                                  B.MESSAGE_TEXT,
                                  B.DESCRIPTION
                                FROM OKL_INVOICE_MSSGS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_INVOICE_MSSGS_TL SUBB, OKL_INVOICE_MSSGS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.MESSAGE_TEXT <> SUBT.MESSAGE_TEXT
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_INVOICE_MSSGS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        NAME,
        MESSAGE_TEXT,
        DESCRIPTION,
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
            B.MESSAGE_TEXT,
            B.DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_INVOICE_MSSGS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_INVOICE_MSSGS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INVOICE_MSSGS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ims_rec                      IN ims_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ims_rec_type IS
    CURSOR ims_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            ORG_ID,
            PRIORITY,
            OBJECT_VERSION_NUMBER,
            END_DATE,
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
            START_DATE,
            PKG_NAME,
            PROC_NAME
      FROM Okl_Invoice_Mssgs_B
     WHERE okl_invoice_mssgs_b.id = p_id;
    l_ims_pk                       ims_pk_csr%ROWTYPE;
    l_ims_rec                      ims_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN ims_pk_csr (p_ims_rec.id);
    FETCH ims_pk_csr INTO
              l_ims_rec.ID,
              l_ims_rec.ORG_ID,
              l_ims_rec.PRIORITY,
              l_ims_rec.OBJECT_VERSION_NUMBER,
              l_ims_rec.END_DATE,
              l_ims_rec.ATTRIBUTE_CATEGORY,
              l_ims_rec.ATTRIBUTE1,
              l_ims_rec.ATTRIBUTE2,
              l_ims_rec.ATTRIBUTE3,
              l_ims_rec.ATTRIBUTE4,
              l_ims_rec.ATTRIBUTE5,
              l_ims_rec.ATTRIBUTE6,
              l_ims_rec.ATTRIBUTE7,
              l_ims_rec.ATTRIBUTE8,
              l_ims_rec.ATTRIBUTE9,
              l_ims_rec.ATTRIBUTE10,
              l_ims_rec.ATTRIBUTE11,
              l_ims_rec.ATTRIBUTE12,
              l_ims_rec.ATTRIBUTE13,
              l_ims_rec.ATTRIBUTE14,
              l_ims_rec.ATTRIBUTE15,
              l_ims_rec.CREATED_BY,
              l_ims_rec.CREATION_DATE,
              l_ims_rec.LAST_UPDATED_BY,
              l_ims_rec.LAST_UPDATE_DATE,
              l_ims_rec.LAST_UPDATE_LOGIN,
              l_ims_rec.START_DATE,
              l_ims_rec.PKG_NAME,
              l_ims_rec.PROC_NAME;
    x_no_data_found := ims_pk_csr%NOTFOUND;
    CLOSE ims_pk_csr;
    RETURN(l_ims_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ims_rec                      IN ims_rec_type
  ) RETURN ims_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ims_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INVOICE_MSSGS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_invoice_mssgs_tl_rec     IN okl_invoice_mssgs_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_invoice_mssgs_tl_rec_type IS
    CURSOR okl_invoice_mssgs_tl_pk_csr (p_id                 IN NUMBER,
                                        p_language           IN VARCHAR2) IS
    SELECT
            ID,
            Okl_Invoice_Mssgs_Tl.LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            NAME,
            MESSAGE_TEXT,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Invoice_Mssgs_Tl
     WHERE okl_invoice_mssgs_tl.id = p_id
       AND okl_invoice_mssgs_tl.language = p_language;
    l_okl_invoice_mssgs_tl_pk      okl_invoice_mssgs_tl_pk_csr%ROWTYPE;
    l_okl_invoice_mssgs_tl_rec     okl_invoice_mssgs_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_invoice_mssgs_tl_pk_csr (p_okl_invoice_mssgs_tl_rec.id,
                                      p_okl_invoice_mssgs_tl_rec.language);
    FETCH okl_invoice_mssgs_tl_pk_csr INTO
              l_okl_invoice_mssgs_tl_rec.ID,
              l_okl_invoice_mssgs_tl_rec.LANGUAGE,
              l_okl_invoice_mssgs_tl_rec.SOURCE_LANG,
              l_okl_invoice_mssgs_tl_rec.SFWT_FLAG,
              l_okl_invoice_mssgs_tl_rec.NAME,
              l_okl_invoice_mssgs_tl_rec.MESSAGE_TEXT,
              l_okl_invoice_mssgs_tl_rec.DESCRIPTION,
              l_okl_invoice_mssgs_tl_rec.CREATED_BY,
              l_okl_invoice_mssgs_tl_rec.CREATION_DATE,
              l_okl_invoice_mssgs_tl_rec.LAST_UPDATED_BY,
              l_okl_invoice_mssgs_tl_rec.LAST_UPDATE_DATE,
              l_okl_invoice_mssgs_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_invoice_mssgs_tl_pk_csr%NOTFOUND;
    CLOSE okl_invoice_mssgs_tl_pk_csr;
    RETURN(l_okl_invoice_mssgs_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_invoice_mssgs_tl_rec     IN okl_invoice_mssgs_tl_rec_type
  ) RETURN okl_invoice_mssgs_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_invoice_mssgs_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INVOICE_MSSGS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_imsv_rec                     IN imsv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN imsv_rec_type IS
    CURSOR okl_imsv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            ORG_ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            NAME,
            MESSAGE_TEXT,
            PRIORITY,
            DESCRIPTION,
            END_DATE,
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
            START_DATE,
            PKG_NAME,
            PROC_NAME
      FROM Okl_Invoice_Mssgs_V
     WHERE okl_invoice_mssgs_v.id = p_id;
    l_okl_imsv_pk                  okl_imsv_pk_csr%ROWTYPE;
    l_imsv_rec                     imsv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_imsv_pk_csr (p_imsv_rec.id);
    FETCH okl_imsv_pk_csr INTO
              l_imsv_rec.ID,
              l_imsv_rec.ORG_ID,
              l_imsv_rec.OBJECT_VERSION_NUMBER,
              l_imsv_rec.SFWT_FLAG,
              l_imsv_rec.NAME,
              l_imsv_rec.MESSAGE_TEXT,
              l_imsv_rec.PRIORITY,
              l_imsv_rec.DESCRIPTION,
              l_imsv_rec.END_DATE,
              l_imsv_rec.ATTRIBUTE_CATEGORY,
              l_imsv_rec.ATTRIBUTE1,
              l_imsv_rec.ATTRIBUTE2,
              l_imsv_rec.ATTRIBUTE3,
              l_imsv_rec.ATTRIBUTE4,
              l_imsv_rec.ATTRIBUTE5,
              l_imsv_rec.ATTRIBUTE6,
              l_imsv_rec.ATTRIBUTE7,
              l_imsv_rec.ATTRIBUTE8,
              l_imsv_rec.ATTRIBUTE9,
              l_imsv_rec.ATTRIBUTE10,
              l_imsv_rec.ATTRIBUTE11,
              l_imsv_rec.ATTRIBUTE12,
              l_imsv_rec.ATTRIBUTE13,
              l_imsv_rec.ATTRIBUTE14,
              l_imsv_rec.ATTRIBUTE15,
              l_imsv_rec.CREATED_BY,
              l_imsv_rec.CREATION_DATE,
              l_imsv_rec.LAST_UPDATED_BY,
              l_imsv_rec.LAST_UPDATE_DATE,
              l_imsv_rec.LAST_UPDATE_LOGIN,
              l_imsv_rec.START_DATE,
              l_imsv_rec.PKG_NAME,
              l_imsv_rec.PROC_NAME;
    x_no_data_found := okl_imsv_pk_csr%NOTFOUND;
    CLOSE okl_imsv_pk_csr;
    RETURN(l_imsv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_imsv_rec                     IN imsv_rec_type
  ) RETURN imsv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_imsv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_INVOICE_MSSGS_V --
  ---------------------------------------------------------
  FUNCTION null_out_defaults (
    p_imsv_rec	IN imsv_rec_type
  ) RETURN imsv_rec_type IS
    l_imsv_rec	imsv_rec_type := p_imsv_rec;
  BEGIN
    IF (l_imsv_rec.object_version_number = OKL_API.G_MISS_NUM) THEN
      l_imsv_rec.object_version_number := NULL;
    END IF;
    IF (l_imsv_rec.sfwt_flag = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_imsv_rec.name = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.name := NULL;
    END IF;
    IF (l_imsv_rec.message_text = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.message_text := NULL;
    END IF;
    IF (l_imsv_rec.priority = OKL_API.G_MISS_NUM) THEN
      l_imsv_rec.priority := NULL;
    END IF;
    IF (l_imsv_rec.description = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.description := NULL;
    END IF;
    IF (l_imsv_rec.end_date = OKL_API.G_MISS_DATE) THEN
      l_imsv_rec.end_date := NULL;
    END IF;
    IF (l_imsv_rec.attribute_category = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.attribute_category := NULL;
    END IF;
    IF (l_imsv_rec.attribute1 = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.attribute1 := NULL;
    END IF;
    IF (l_imsv_rec.attribute2 = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.attribute2 := NULL;
    END IF;
    IF (l_imsv_rec.attribute3 = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.attribute3 := NULL;
    END IF;
    IF (l_imsv_rec.attribute4 = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.attribute4 := NULL;
    END IF;
    IF (l_imsv_rec.attribute5 = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.attribute5 := NULL;
    END IF;
    IF (l_imsv_rec.attribute6 = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.attribute6 := NULL;
    END IF;
    IF (l_imsv_rec.attribute7 = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.attribute7 := NULL;
    END IF;
    IF (l_imsv_rec.attribute8 = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.attribute8 := NULL;
    END IF;
    IF (l_imsv_rec.attribute9 = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.attribute9 := NULL;
    END IF;
    IF (l_imsv_rec.attribute10 = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.attribute10 := NULL;
    END IF;
    IF (l_imsv_rec.attribute11 = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.attribute11 := NULL;
    END IF;
    IF (l_imsv_rec.attribute12 = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.attribute12 := NULL;
    END IF;
    IF (l_imsv_rec.attribute13 = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.attribute13 := NULL;
    END IF;
    IF (l_imsv_rec.attribute14 = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.attribute14 := NULL;
    END IF;
    IF (l_imsv_rec.attribute15 = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.attribute15 := NULL;
    END IF;
    IF (l_imsv_rec.created_by = OKL_API.G_MISS_NUM) THEN
      l_imsv_rec.created_by := NULL;
    END IF;
    IF (l_imsv_rec.creation_date = OKL_API.G_MISS_DATE) THEN
      l_imsv_rec.creation_date := NULL;
    END IF;
    IF (l_imsv_rec.last_updated_by = OKL_API.G_MISS_NUM) THEN
      l_imsv_rec.last_updated_by := NULL;
    END IF;
    IF (l_imsv_rec.last_update_date = OKL_API.G_MISS_DATE) THEN
      l_imsv_rec.last_update_date := NULL;
    END IF;
    IF (l_imsv_rec.last_update_login = OKL_API.G_MISS_NUM) THEN
      l_imsv_rec.last_update_login := NULL;
    END IF;
    IF (l_imsv_rec.start_date = OKL_API.G_MISS_DATE) THEN
      l_imsv_rec.start_date := NULL;
    END IF;
    IF (l_imsv_rec.pkg_name = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.pkg_name := NULL;
    END IF;
    IF (l_imsv_rec.proc_name = OKL_API.G_MISS_CHAR) THEN
      l_imsv_rec.proc_name := NULL;
    END IF;
    RETURN(l_imsv_rec);
  END null_out_defaults;

  ----------------------------------------------------------------------------

  -- Checking Unique Constraint for Priority
  FUNCTION IS_UNIQUE_PRIO (p_imsv_rec imsv_rec_type) RETURN VARCHAR2
  IS
    CURSOR l_ims_csr IS
		 SELECT 'x'
		 FROM okl_invoice_mssgs_v  -- nikshah bug 6747706
		 WHERE PRIORITY = p_imsv_rec.priority;

    l_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_dummy             VARCHAR2(1);
    l_found             BOOLEAN;
  BEGIN
    -- check for unique product and location
        OPEN l_ims_csr;
        FETCH l_ims_csr INTO l_dummy;
	   l_found := l_ims_csr%FOUND;
	   CLOSE l_ims_csr;

    IF (l_found) THEN
  	    Okl_Api.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> ' OKL_IMS_Exists ',
					    p_token1		=> ' Priority ',
					    p_token1_value	=> p_imsv_rec.priority);
	  -- notify caller of an error
	  l_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    RETURN (l_return_status);

  EXCEPTION
    WHEN OTHERS THEN
	 RETURN (l_return_status);
  END IS_UNIQUE_PRIO;

-------------------------------------------------------------------------


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Id
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Id (
    x_return_status OUT NOCOPY VARCHAR2,
    p_imsv_rec		  IN  imsv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

    -- data is required
    IF p_imsv_rec.id = OKL_API.G_MISS_NUM
    OR p_imsv_rec.id IS NULL
    THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name		 => G_APP_NAME,
      	p_msg_name		 => G_REQUIRED_VALUE,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'id');

      -- notify caller of en error
      x_return_status := OKL_API.G_RET_STS_ERROR;
      -- halt furhter validation of the column
      raise G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; continue validation
      null;

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Object_Version_Number
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Object_Version_Number (
    x_return_status OUT NOCOPY VARCHAR2,
    p_imsv_rec		  IN  imsv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

    -- data is required
    IF p_imsv_rec.object_version_number = OKL_API.G_MISS_NUM
    OR p_imsv_rec.object_version_number IS NULL
    THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name		 => G_APP_NAME,
      	p_msg_name		 => G_REQUIRED_VALUE,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'object_version_number');

      -- notify caller of en error
      x_return_status := OKL_API.G_RET_STS_ERROR;
      -- halt furhter validation of the column
      raise G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; continue validation
      null;

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Name
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Name (
    x_return_status OUT NOCOPY VARCHAR2,
    p_imsv_rec		  IN  imsv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

    -- data is required
    IF p_imsv_rec.name = OKL_API.G_MISS_CHAR
    OR p_imsv_rec.name IS NULL
    THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name		 => G_APP_NAME,
      	p_msg_name		 => G_REQUIRED_VALUE,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'name');

      -- notify caller of en error
      x_return_status := OKL_API.G_RET_STS_ERROR;
      -- halt furhter validation of the column
      raise G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; continue validation
      null;

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Name;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Message_Text
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Message_Text (
    x_return_status OUT NOCOPY VARCHAR2,
    p_imsv_rec		  IN  imsv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

    -- data is required
    IF p_imsv_rec.message_text = OKL_API.G_MISS_CHAR
    OR p_imsv_rec.message_text IS NULL
    THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name		 => G_APP_NAME,
      	p_msg_name		 => G_REQUIRED_VALUE,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'message_text');

      -- notify caller of en error
      x_return_status := OKL_API.G_RET_STS_ERROR;
      -- halt furhter validation of the column
      raise G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; continue validation
      null;

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Message_Text;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Priority
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Priority (
    x_return_status OUT NOCOPY VARCHAR2,
    p_imsv_rec		  IN  imsv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

    -- data is required
    IF p_imsv_rec.priority = OKL_API.G_MISS_NUM
    OR p_imsv_rec.priority IS NULL
    THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name		 => G_APP_NAME,
      	p_msg_name		 => G_REQUIRED_VALUE,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'priority');

      -- notify caller of en error
      x_return_status := OKL_API.G_RET_STS_ERROR;
      -- halt furhter validation of the column
      raise G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION

    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; continue validation
      null;

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Priority;

  ---------------------------------------------------------------------------
  -- PROCEDURE Is_Unique
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------
  FUNCTION Is_Unique (
    p_imsv_rec IN imsv_rec_type
  ) RETURN VARCHAR2 IS

    CURSOR l_imsv_csr IS
		  SELECT 'x'
		  FROM   okl_invoice_mssgs_v
		  WHERE  name = p_imsv_rec.name
		  AND    id   <> nvl (p_imsv_rec.id, -99999);

    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy             VARCHAR2(1);
    l_found             BOOLEAN;

  BEGIN

    -- check for unique NAME
    OPEN     l_imsv_csr;
    FETCH    l_imsv_csr INTO l_dummy;
	  l_found  := l_imsv_csr%FOUND;
	  CLOSE    l_imsv_csr;

    IF (l_found) THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_NOT_SAME,
      	p_token1          => 'NAME',
      	p_token1_value    => p_imsv_rec.name);

      -- notify caller of an error
      l_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;

    -- return status to the caller
    RETURN l_return_status;

  EXCEPTION

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- verify the cursor is closed
      IF l_imsv_csr%ISOPEN THEN
         CLOSE l_imsv_csr;
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
  -- Validate_Attributes for:OKL_INVOICE_MSSGS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_imsv_rec IN  imsv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    -- call each column-level validation

    validate_id (
      x_return_status => l_return_status,
      p_imsv_rec      => p_imsv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_object_version_number (
      x_return_status => l_return_status,
      p_imsv_rec      => p_imsv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_name (
      x_return_status => l_return_status,
      p_imsv_rec      => p_imsv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_message_text (
      x_return_status => l_return_status,
      p_imsv_rec      => p_imsv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_priority (
      x_return_status => l_return_status,
      p_imsv_rec      => p_imsv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    RETURN x_return_status;

  EXCEPTION

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- return status to the caller
      RETURN x_return_status;

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  -- Post-Generation Change
  -- By RDRAGUIL on 24-APR-2001
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_INVOICE_MSSGS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_imsv_rec IN imsv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_return_status1 VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status1	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    -- call each record-level validation
    l_return_status1 := is_unique (p_imsv_rec);
    x_return_status1 := x_return_status;
    l_return_status := IS_UNIQUE_PRIO (p_imsv_rec);

    IF (l_return_status1 <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status1 <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status1 := l_return_status1;
       END IF;
    END IF;

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    IF (x_return_status1 <> OKL_API.G_RET_STS_SUCCESS) THEN
       x_return_status := x_return_status1;
    END IF;

    RETURN x_return_status;

  EXCEPTION

    when OTHERS then
      -- display error message
      OKL_API.set_message(
      	p_app_name        => G_APP_NAME,
      	p_msg_name        => G_UNEXPECTED_ERROR,
      	p_token1          => G_SQLCODE_TOKEN,
      	p_token1_value    => SQLCODE,
      	p_token2          => G_SQLERRM_TOKEN,
      	p_token2_value    => SQLERRM);
      -- notify caller of an unexpected error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- return status to the caller
      RETURN x_return_status;

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN imsv_rec_type,
    p_to	IN OUT NOCOPY ims_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.org_id := p_from.org_id;
    p_to.priority := p_from.priority;
    p_to.object_version_number := p_from.object_version_number;
    p_to.end_date := p_from.end_date;
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
    p_to.start_date := p_from.start_date;
    p_to.pkg_name := p_from.pkg_name;
    p_to.proc_name := p_from.proc_name;
  END migrate;
  PROCEDURE migrate (
    p_from	IN ims_rec_type,
    p_to	IN OUT NOCOPY imsv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.org_id := p_from.org_id;
    p_to.priority := p_from.priority;
    p_to.object_version_number := p_from.object_version_number;
    p_to.end_date := p_from.end_date;
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
    p_to.start_date := p_from.start_date;
    p_to.pkg_name := p_from.pkg_name;
    p_to.proc_name := p_from.proc_name;
  END migrate;
  PROCEDURE migrate (
    p_from	IN imsv_rec_type,
    p_to	IN OUT NOCOPY okl_invoice_mssgs_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.message_text := p_from.message_text;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okl_invoice_mssgs_tl_rec_type,
    p_to	IN OUT NOCOPY imsv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.message_text := p_from.message_text;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- validate_row for:OKL_INVOICE_MSSGS_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_imsv_rec                     IN imsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_imsv_rec                     imsv_rec_type := p_imsv_rec;
    l_ims_rec                      ims_rec_type;
    l_okl_invoice_mssgs_tl_rec     okl_invoice_mssgs_tl_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_imsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_imsv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:IMSV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_imsv_tbl                     IN imsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_imsv_tbl.COUNT > 0) THEN
      i := p_imsv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_imsv_rec                     => p_imsv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_imsv_tbl.LAST);
        i := p_imsv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_INVOICE_MSSGS_B --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ims_rec                      IN ims_rec_type,
    x_ims_rec                      OUT NOCOPY ims_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ims_rec                      ims_rec_type := p_ims_rec;
    l_def_ims_rec                  ims_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_MSSGS_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_ims_rec IN  ims_rec_type,
      x_ims_rec OUT NOCOPY ims_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ims_rec := p_ims_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_ims_rec,                         -- IN
      l_ims_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_INVOICE_MSSGS_B(
        id,
        org_id,
        priority,
        object_version_number,
        end_date,
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
        last_update_login,
        start_date,
        pkg_name,
        proc_name)
      VALUES (
        l_ims_rec.id,
        l_ims_rec.org_id,
        l_ims_rec.priority,
        l_ims_rec.object_version_number,
        l_ims_rec.end_date,
        l_ims_rec.attribute_category,
        l_ims_rec.attribute1,
        l_ims_rec.attribute2,
        l_ims_rec.attribute3,
        l_ims_rec.attribute4,
        l_ims_rec.attribute5,
        l_ims_rec.attribute6,
        l_ims_rec.attribute7,
        l_ims_rec.attribute8,
        l_ims_rec.attribute9,
        l_ims_rec.attribute10,
        l_ims_rec.attribute11,
        l_ims_rec.attribute12,
        l_ims_rec.attribute13,
        l_ims_rec.attribute14,
        l_ims_rec.attribute15,
        l_ims_rec.created_by,
        l_ims_rec.creation_date,
        l_ims_rec.last_updated_by,
        l_ims_rec.last_update_date,
        l_ims_rec.last_update_login,
        l_ims_rec.start_date,
        l_ims_rec.pkg_name,
        l_ims_rec.proc_name);
    -- Set OUT values
    x_ims_rec := l_ims_rec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_INVOICE_MSSGS_TL --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_invoice_mssgs_tl_rec     IN okl_invoice_mssgs_tl_rec_type,
    x_okl_invoice_mssgs_tl_rec     OUT NOCOPY okl_invoice_mssgs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_invoice_mssgs_tl_rec     okl_invoice_mssgs_tl_rec_type := p_okl_invoice_mssgs_tl_rec;
    ldefoklinvoicemssgstlrec       okl_invoice_mssgs_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_MSSGS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_invoice_mssgs_tl_rec IN  okl_invoice_mssgs_tl_rec_type,
      x_okl_invoice_mssgs_tl_rec OUT NOCOPY okl_invoice_mssgs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_invoice_mssgs_tl_rec := p_okl_invoice_mssgs_tl_rec;
      x_okl_invoice_mssgs_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_invoice_mssgs_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_invoice_mssgs_tl_rec,        -- IN
      l_okl_invoice_mssgs_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_invoice_mssgs_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_INVOICE_MSSGS_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          name,
          message_text,
          description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_invoice_mssgs_tl_rec.id,
          l_okl_invoice_mssgs_tl_rec.language,
          l_okl_invoice_mssgs_tl_rec.source_lang,
          l_okl_invoice_mssgs_tl_rec.sfwt_flag,
          l_okl_invoice_mssgs_tl_rec.name,
          l_okl_invoice_mssgs_tl_rec.message_text,
          l_okl_invoice_mssgs_tl_rec.description,
          l_okl_invoice_mssgs_tl_rec.created_by,
          l_okl_invoice_mssgs_tl_rec.creation_date,
          l_okl_invoice_mssgs_tl_rec.last_updated_by,
          l_okl_invoice_mssgs_tl_rec.last_update_date,
          l_okl_invoice_mssgs_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_invoice_mssgs_tl_rec := l_okl_invoice_mssgs_tl_rec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_INVOICE_MSSGS_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_imsv_rec                     IN imsv_rec_type,
    x_imsv_rec                     OUT NOCOPY imsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_imsv_rec                     imsv_rec_type;
    l_def_imsv_rec                 imsv_rec_type;
    l_ims_rec                      ims_rec_type;
    lx_ims_rec                     ims_rec_type;
    l_okl_invoice_mssgs_tl_rec     okl_invoice_mssgs_tl_rec_type;
    lx_okl_invoice_mssgs_tl_rec    okl_invoice_mssgs_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_imsv_rec	IN imsv_rec_type
    ) RETURN imsv_rec_type IS
      l_imsv_rec	imsv_rec_type := p_imsv_rec;
    BEGIN
      l_imsv_rec.CREATION_DATE := SYSDATE;
      l_imsv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_imsv_rec.LAST_UPDATE_DATE := l_imsv_rec.CREATION_DATE;
      l_imsv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_imsv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_imsv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_MSSGS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_imsv_rec IN  imsv_rec_type,
      x_imsv_rec OUT NOCOPY imsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_imsv_rec := p_imsv_rec;
      x_imsv_rec.OBJECT_VERSION_NUMBER := 1;
      x_imsv_rec.SFWT_FLAG := 'N';
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_imsv_rec := null_out_defaults(p_imsv_rec);
    -- Set primary key value
    l_imsv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_imsv_rec,                        -- IN
      l_def_imsv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_imsv_rec := fill_who_columns(l_def_imsv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_imsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_imsv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_imsv_rec, l_ims_rec);
    migrate(l_def_imsv_rec, l_okl_invoice_mssgs_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ims_rec,
      lx_ims_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ims_rec, l_def_imsv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_invoice_mssgs_tl_rec,
      lx_okl_invoice_mssgs_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_invoice_mssgs_tl_rec, l_def_imsv_rec);
    -- Set OUT values
    x_imsv_rec := l_def_imsv_rec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:IMSV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_imsv_tbl                     IN imsv_tbl_type,
    x_imsv_tbl                     OUT NOCOPY imsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_imsv_tbl.COUNT > 0) THEN
      i := p_imsv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_imsv_rec                     => p_imsv_tbl(i),
          x_imsv_rec                     => x_imsv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_imsv_tbl.LAST);
        i := p_imsv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_INVOICE_MSSGS_B --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ims_rec                      IN ims_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ims_rec IN ims_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INVOICE_MSSGS_B
     WHERE ID = p_ims_rec.id
       AND OBJECT_VERSION_NUMBER = p_ims_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_ims_rec IN ims_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INVOICE_MSSGS_B
    WHERE ID = p_ims_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_INVOICE_MSSGS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_INVOICE_MSSGS_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_ims_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_ims_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ims_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ims_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKL_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_INVOICE_MSSGS_TL --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_invoice_mssgs_tl_rec     IN okl_invoice_mssgs_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_invoice_mssgs_tl_rec IN okl_invoice_mssgs_tl_rec_type) IS
    SELECT *
      FROM OKL_INVOICE_MSSGS_TL
     WHERE ID = p_okl_invoice_mssgs_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_okl_invoice_mssgs_tl_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_INVOICE_MSSGS_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_imsv_rec                     IN imsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ims_rec                      ims_rec_type;
    l_okl_invoice_mssgs_tl_rec     okl_invoice_mssgs_tl_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_imsv_rec, l_ims_rec);
    migrate(p_imsv_rec, l_okl_invoice_mssgs_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ims_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_invoice_mssgs_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:IMSV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_imsv_tbl                     IN imsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_imsv_tbl.COUNT > 0) THEN
      i := p_imsv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_imsv_rec                     => p_imsv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_imsv_tbl.LAST);
        i := p_imsv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_INVOICE_MSSGS_B --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ims_rec                      IN ims_rec_type,
    x_ims_rec                      OUT NOCOPY ims_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ims_rec                      ims_rec_type := p_ims_rec;
    l_def_ims_rec                  ims_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ims_rec	IN ims_rec_type,
      x_ims_rec	OUT NOCOPY ims_rec_type
    ) RETURN VARCHAR2 IS
      l_ims_rec                      ims_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ims_rec := p_ims_rec;
      -- Get current database values
      l_ims_rec := get_rec(p_ims_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ims_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_ims_rec.id := l_ims_rec.id;
      END IF;
      IF (x_ims_rec.org_id = OKL_API.G_MISS_NUM)
      THEN
        x_ims_rec.org_id := l_ims_rec.org_id;
      END IF;
      IF (x_ims_rec.priority = OKL_API.G_MISS_NUM)
      THEN
        x_ims_rec.priority := l_ims_rec.priority;
      END IF;
      IF (x_ims_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_ims_rec.object_version_number := l_ims_rec.object_version_number;
      END IF;
      IF (x_ims_rec.end_date = OKL_API.G_MISS_DATE)
      THEN
        x_ims_rec.end_date := l_ims_rec.end_date;
      END IF;
      IF (x_ims_rec.attribute_category = OKL_API.G_MISS_CHAR)
      THEN
        x_ims_rec.attribute_category := l_ims_rec.attribute_category;
      END IF;
      IF (x_ims_rec.attribute1 = OKL_API.G_MISS_CHAR)
      THEN
        x_ims_rec.attribute1 := l_ims_rec.attribute1;
      END IF;
      IF (x_ims_rec.attribute2 = OKL_API.G_MISS_CHAR)
      THEN
        x_ims_rec.attribute2 := l_ims_rec.attribute2;
      END IF;
      IF (x_ims_rec.attribute3 = OKL_API.G_MISS_CHAR)
      THEN
        x_ims_rec.attribute3 := l_ims_rec.attribute3;
      END IF;
      IF (x_ims_rec.attribute4 = OKL_API.G_MISS_CHAR)
      THEN
        x_ims_rec.attribute4 := l_ims_rec.attribute4;
      END IF;
      IF (x_ims_rec.attribute5 = OKL_API.G_MISS_CHAR)
      THEN
        x_ims_rec.attribute5 := l_ims_rec.attribute5;
      END IF;
      IF (x_ims_rec.attribute6 = OKL_API.G_MISS_CHAR)
      THEN
        x_ims_rec.attribute6 := l_ims_rec.attribute6;
      END IF;
      IF (x_ims_rec.attribute7 = OKL_API.G_MISS_CHAR)
      THEN
        x_ims_rec.attribute7 := l_ims_rec.attribute7;
      END IF;
      IF (x_ims_rec.attribute8 = OKL_API.G_MISS_CHAR)
      THEN
        x_ims_rec.attribute8 := l_ims_rec.attribute8;
      END IF;
      IF (x_ims_rec.attribute9 = OKL_API.G_MISS_CHAR)
      THEN
        x_ims_rec.attribute9 := l_ims_rec.attribute9;
      END IF;
      IF (x_ims_rec.attribute10 = OKL_API.G_MISS_CHAR)
      THEN
        x_ims_rec.attribute10 := l_ims_rec.attribute10;
      END IF;
      IF (x_ims_rec.attribute11 = OKL_API.G_MISS_CHAR)
      THEN
        x_ims_rec.attribute11 := l_ims_rec.attribute11;
      END IF;
      IF (x_ims_rec.attribute12 = OKL_API.G_MISS_CHAR)
      THEN
        x_ims_rec.attribute12 := l_ims_rec.attribute12;
      END IF;
      IF (x_ims_rec.attribute13 = OKL_API.G_MISS_CHAR)
      THEN
        x_ims_rec.attribute13 := l_ims_rec.attribute13;
      END IF;
      IF (x_ims_rec.attribute14 = OKL_API.G_MISS_CHAR)
      THEN
        x_ims_rec.attribute14 := l_ims_rec.attribute14;
      END IF;
      IF (x_ims_rec.attribute15 = OKL_API.G_MISS_CHAR)
      THEN
        x_ims_rec.attribute15 := l_ims_rec.attribute15;
      END IF;
      IF (x_ims_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_ims_rec.created_by := l_ims_rec.created_by;
      END IF;
      IF (x_ims_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_ims_rec.creation_date := l_ims_rec.creation_date;
      END IF;
      IF (x_ims_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_ims_rec.last_updated_by := l_ims_rec.last_updated_by;
      END IF;
      IF (x_ims_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_ims_rec.last_update_date := l_ims_rec.last_update_date;
      END IF;
      IF (x_ims_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_ims_rec.last_update_login := l_ims_rec.last_update_login;
      END IF;
      IF (x_ims_rec.start_date = OKL_API.G_MISS_DATE)
      THEN
        x_ims_rec.start_date := l_ims_rec.start_date;
      END IF;
      IF (x_ims_rec.pkg_name = OKL_API.G_MISS_CHAR)
      THEN
        x_ims_rec.pkg_name := l_ims_rec.pkg_name;
      END IF;
      IF (x_ims_rec.proc_name = OKL_API.G_MISS_CHAR)
      THEN
        x_ims_rec.proc_name := l_ims_rec.proc_name;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_MSSGS_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_ims_rec IN  ims_rec_type,
      x_ims_rec OUT NOCOPY ims_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ims_rec := p_ims_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_ims_rec,                         -- IN
      l_ims_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ims_rec, l_def_ims_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_INVOICE_MSSGS_B
    SET PRIORITY = l_def_ims_rec.priority,
        OBJECT_VERSION_NUMBER = l_def_ims_rec.object_version_number,
        END_DATE = l_def_ims_rec.end_date,
        ATTRIBUTE_CATEGORY = l_def_ims_rec.attribute_category,
        ATTRIBUTE1 = l_def_ims_rec.attribute1,
        ATTRIBUTE2 = l_def_ims_rec.attribute2,
        ATTRIBUTE3 = l_def_ims_rec.attribute3,
        ATTRIBUTE4 = l_def_ims_rec.attribute4,
        ATTRIBUTE5 = l_def_ims_rec.attribute5,
        ATTRIBUTE6 = l_def_ims_rec.attribute6,
        ATTRIBUTE7 = l_def_ims_rec.attribute7,
        ATTRIBUTE8 = l_def_ims_rec.attribute8,
        ATTRIBUTE9 = l_def_ims_rec.attribute9,
        ATTRIBUTE10 = l_def_ims_rec.attribute10,
        ATTRIBUTE11 = l_def_ims_rec.attribute11,
        ATTRIBUTE12 = l_def_ims_rec.attribute12,
        ATTRIBUTE13 = l_def_ims_rec.attribute13,
        ATTRIBUTE14 = l_def_ims_rec.attribute14,
        ATTRIBUTE15 = l_def_ims_rec.attribute15,
        CREATED_BY = l_def_ims_rec.created_by,
        CREATION_DATE = l_def_ims_rec.creation_date,
        LAST_UPDATED_BY = l_def_ims_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ims_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ims_rec.last_update_login,
        START_DATE = l_def_ims_rec.start_date,
        PKG_NAME = l_def_ims_rec.pkg_name,
        PROC_NAME = l_def_ims_rec.proc_name
    WHERE ID = l_def_ims_rec.id;

    x_ims_rec := l_def_ims_rec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_INVOICE_MSSGS_TL --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_invoice_mssgs_tl_rec     IN okl_invoice_mssgs_tl_rec_type,
    x_okl_invoice_mssgs_tl_rec     OUT NOCOPY okl_invoice_mssgs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_invoice_mssgs_tl_rec     okl_invoice_mssgs_tl_rec_type := p_okl_invoice_mssgs_tl_rec;
    ldefoklinvoicemssgstlrec       okl_invoice_mssgs_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_invoice_mssgs_tl_rec	IN okl_invoice_mssgs_tl_rec_type,
      x_okl_invoice_mssgs_tl_rec	OUT NOCOPY okl_invoice_mssgs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_invoice_mssgs_tl_rec     okl_invoice_mssgs_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_invoice_mssgs_tl_rec := p_okl_invoice_mssgs_tl_rec;
      -- Get current database values
      l_okl_invoice_mssgs_tl_rec := get_rec(p_okl_invoice_mssgs_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_invoice_mssgs_tl_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_okl_invoice_mssgs_tl_rec.id := l_okl_invoice_mssgs_tl_rec.id;
      END IF;
      IF (x_okl_invoice_mssgs_tl_rec.language = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_invoice_mssgs_tl_rec.language := l_okl_invoice_mssgs_tl_rec.language;
      END IF;
      IF (x_okl_invoice_mssgs_tl_rec.source_lang = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_invoice_mssgs_tl_rec.source_lang := l_okl_invoice_mssgs_tl_rec.source_lang;
      END IF;
      IF (x_okl_invoice_mssgs_tl_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_invoice_mssgs_tl_rec.sfwt_flag := l_okl_invoice_mssgs_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_invoice_mssgs_tl_rec.name = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_invoice_mssgs_tl_rec.name := l_okl_invoice_mssgs_tl_rec.name;
      END IF;
      IF (x_okl_invoice_mssgs_tl_rec.message_text = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_invoice_mssgs_tl_rec.message_text := l_okl_invoice_mssgs_tl_rec.message_text;
      END IF;
      IF (x_okl_invoice_mssgs_tl_rec.description = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_invoice_mssgs_tl_rec.description := l_okl_invoice_mssgs_tl_rec.description;
      END IF;
      IF (x_okl_invoice_mssgs_tl_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_okl_invoice_mssgs_tl_rec.created_by := l_okl_invoice_mssgs_tl_rec.created_by;
      END IF;
      IF (x_okl_invoice_mssgs_tl_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_okl_invoice_mssgs_tl_rec.creation_date := l_okl_invoice_mssgs_tl_rec.creation_date;
      END IF;
      IF (x_okl_invoice_mssgs_tl_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_okl_invoice_mssgs_tl_rec.last_updated_by := l_okl_invoice_mssgs_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_invoice_mssgs_tl_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_okl_invoice_mssgs_tl_rec.last_update_date := l_okl_invoice_mssgs_tl_rec.last_update_date;
      END IF;
      IF (x_okl_invoice_mssgs_tl_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_okl_invoice_mssgs_tl_rec.last_update_login := l_okl_invoice_mssgs_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_MSSGS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_invoice_mssgs_tl_rec IN  okl_invoice_mssgs_tl_rec_type,
      x_okl_invoice_mssgs_tl_rec OUT NOCOPY okl_invoice_mssgs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_invoice_mssgs_tl_rec := p_okl_invoice_mssgs_tl_rec;
      x_okl_invoice_mssgs_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_invoice_mssgs_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_invoice_mssgs_tl_rec,        -- IN
      l_okl_invoice_mssgs_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_invoice_mssgs_tl_rec, ldefoklinvoicemssgstlrec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_INVOICE_MSSGS_TL
    SET NAME = ldefoklinvoicemssgstlrec.name,
        MESSAGE_TEXT = ldefoklinvoicemssgstlrec.message_text,
        DESCRIPTION = ldefoklinvoicemssgstlrec.description,
        SOURCE_LANG = ldefoklinvoicemssgstlrec.source_lang,
        CREATED_BY = ldefoklinvoicemssgstlrec.created_by,
        CREATION_DATE = ldefoklinvoicemssgstlrec.creation_date,
        LAST_UPDATED_BY = ldefoklinvoicemssgstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklinvoicemssgstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklinvoicemssgstlrec.last_update_login
    WHERE ID = ldefoklinvoicemssgstlrec.id
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_INVOICE_MSSGS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklinvoicemssgstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_invoice_mssgs_tl_rec := ldefoklinvoicemssgstlrec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_INVOICE_MSSGS_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_imsv_rec                     IN imsv_rec_type,
    x_imsv_rec                     OUT NOCOPY imsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_imsv_rec                     imsv_rec_type := p_imsv_rec;
    l_def_imsv_rec                 imsv_rec_type;
    l_okl_invoice_mssgs_tl_rec     okl_invoice_mssgs_tl_rec_type;
    lx_okl_invoice_mssgs_tl_rec    okl_invoice_mssgs_tl_rec_type;
    l_ims_rec                      ims_rec_type;
    lx_ims_rec                     ims_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_imsv_rec	IN imsv_rec_type
    ) RETURN imsv_rec_type IS
      l_imsv_rec	imsv_rec_type := p_imsv_rec;
    BEGIN
      l_imsv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_imsv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_imsv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_imsv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_imsv_rec	IN imsv_rec_type,
      x_imsv_rec	OUT NOCOPY imsv_rec_type
    ) RETURN VARCHAR2 IS
      l_imsv_rec                     imsv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_imsv_rec := p_imsv_rec;
      -- Get current database values
      l_imsv_rec := get_rec(p_imsv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_imsv_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_imsv_rec.id := l_imsv_rec.id;
      END IF;
      IF (x_imsv_rec.org_id = OKL_API.G_MISS_NUM)
      THEN
        x_imsv_rec.org_id := l_imsv_rec.org_id;
      END IF;
      IF (x_imsv_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_imsv_rec.object_version_number := l_imsv_rec.object_version_number;
      END IF;
      IF (x_imsv_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.sfwt_flag := l_imsv_rec.sfwt_flag;
      END IF;
      IF (x_imsv_rec.name = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.name := l_imsv_rec.name;
      END IF;
      IF (x_imsv_rec.message_text = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.message_text := l_imsv_rec.message_text;
      END IF;
      IF (x_imsv_rec.priority = OKL_API.G_MISS_NUM)
      THEN
        x_imsv_rec.priority := l_imsv_rec.priority;
      END IF;
      IF (x_imsv_rec.description = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.description := l_imsv_rec.description;
      END IF;
      IF (x_imsv_rec.end_date = OKL_API.G_MISS_DATE)
      THEN
        x_imsv_rec.end_date := l_imsv_rec.end_date;
      END IF;
      IF (x_imsv_rec.attribute_category = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.attribute_category := l_imsv_rec.attribute_category;
      END IF;
      IF (x_imsv_rec.attribute1 = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.attribute1 := l_imsv_rec.attribute1;
      END IF;
      IF (x_imsv_rec.attribute2 = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.attribute2 := l_imsv_rec.attribute2;
      END IF;
      IF (x_imsv_rec.attribute3 = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.attribute3 := l_imsv_rec.attribute3;
      END IF;
      IF (x_imsv_rec.attribute4 = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.attribute4 := l_imsv_rec.attribute4;
      END IF;
      IF (x_imsv_rec.attribute5 = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.attribute5 := l_imsv_rec.attribute5;
      END IF;
      IF (x_imsv_rec.attribute6 = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.attribute6 := l_imsv_rec.attribute6;
      END IF;
      IF (x_imsv_rec.attribute7 = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.attribute7 := l_imsv_rec.attribute7;
      END IF;
      IF (x_imsv_rec.attribute8 = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.attribute8 := l_imsv_rec.attribute8;
      END IF;
      IF (x_imsv_rec.attribute9 = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.attribute9 := l_imsv_rec.attribute9;
      END IF;
      IF (x_imsv_rec.attribute10 = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.attribute10 := l_imsv_rec.attribute10;
      END IF;
      IF (x_imsv_rec.attribute11 = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.attribute11 := l_imsv_rec.attribute11;
      END IF;
      IF (x_imsv_rec.attribute12 = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.attribute12 := l_imsv_rec.attribute12;
      END IF;
      IF (x_imsv_rec.attribute13 = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.attribute13 := l_imsv_rec.attribute13;
      END IF;
      IF (x_imsv_rec.attribute14 = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.attribute14 := l_imsv_rec.attribute14;
      END IF;
      IF (x_imsv_rec.attribute15 = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.attribute15 := l_imsv_rec.attribute15;
      END IF;
      IF (x_imsv_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_imsv_rec.created_by := l_imsv_rec.created_by;
      END IF;
      IF (x_imsv_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_imsv_rec.creation_date := l_imsv_rec.creation_date;
      END IF;
      IF (x_imsv_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_imsv_rec.last_updated_by := l_imsv_rec.last_updated_by;
      END IF;
      IF (x_imsv_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_imsv_rec.last_update_date := l_imsv_rec.last_update_date;
      END IF;
      IF (x_imsv_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_imsv_rec.last_update_login := l_imsv_rec.last_update_login;
      END IF;
      IF (x_imsv_rec.start_date = OKL_API.G_MISS_DATE)
      THEN
        x_imsv_rec.start_date := l_imsv_rec.start_date;
      END IF;
      IF (x_imsv_rec.pkg_name = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.pkg_name := l_imsv_rec.pkg_name;
      END IF;
      IF (x_imsv_rec.proc_name = OKL_API.G_MISS_CHAR)
      THEN
        x_imsv_rec.proc_name := l_imsv_rec.proc_name;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_MSSGS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_imsv_rec IN  imsv_rec_type,
      x_imsv_rec OUT NOCOPY imsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_imsv_rec := p_imsv_rec;
      x_imsv_rec.OBJECT_VERSION_NUMBER := NVL(x_imsv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_imsv_rec,                        -- IN
      l_imsv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_imsv_rec, l_def_imsv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_imsv_rec := fill_who_columns(l_def_imsv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_imsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_imsv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_imsv_rec, l_okl_invoice_mssgs_tl_rec);
    migrate(l_def_imsv_rec, l_ims_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_invoice_mssgs_tl_rec,
      lx_okl_invoice_mssgs_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_invoice_mssgs_tl_rec, l_def_imsv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ims_rec,
      lx_ims_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ims_rec, l_def_imsv_rec);
    x_imsv_rec := l_def_imsv_rec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:IMSV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_imsv_tbl                     IN imsv_tbl_type,
    x_imsv_tbl                     OUT NOCOPY imsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_imsv_tbl.COUNT > 0) THEN
      i := p_imsv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_imsv_rec                     => p_imsv_tbl(i),
          x_imsv_rec                     => x_imsv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_imsv_tbl.LAST);
        i := p_imsv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_INVOICE_MSSGS_B --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ims_rec                      IN ims_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ims_rec                      ims_rec_type:= p_ims_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_INVOICE_MSSGS_B
     WHERE ID = l_ims_rec.id;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_INVOICE_MSSGS_TL --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_invoice_mssgs_tl_rec     IN okl_invoice_mssgs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_invoice_mssgs_tl_rec     okl_invoice_mssgs_tl_rec_type:= p_okl_invoice_mssgs_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ---------------------------------------------
    -- Set_Attributes for:OKL_INVOICE_MSSGS_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_invoice_mssgs_tl_rec IN  okl_invoice_mssgs_tl_rec_type,
      x_okl_invoice_mssgs_tl_rec OUT NOCOPY okl_invoice_mssgs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_invoice_mssgs_tl_rec := p_okl_invoice_mssgs_tl_rec;
      x_okl_invoice_mssgs_tl_rec.LANGUAGE := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_invoice_mssgs_tl_rec,        -- IN
      l_okl_invoice_mssgs_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_INVOICE_MSSGS_TL
     WHERE ID = l_okl_invoice_mssgs_tl_rec.id;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_INVOICE_MSSGS_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_imsv_rec                     IN imsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_imsv_rec                     imsv_rec_type := p_imsv_rec;
    l_okl_invoice_mssgs_tl_rec     okl_invoice_mssgs_tl_rec_type;
    l_ims_rec                      ims_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_imsv_rec, l_okl_invoice_mssgs_tl_rec);
    migrate(l_imsv_rec, l_ims_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_invoice_mssgs_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ims_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:IMSV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_imsv_tbl                     IN imsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_imsv_tbl.COUNT > 0) THEN
      i := p_imsv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_imsv_rec                     => p_imsv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_imsv_tbl.LAST);
        i := p_imsv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END OKL_IMS_PVT;

/
