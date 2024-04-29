--------------------------------------------------------
--  DDL for Package Body OKC_PDF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PDF_PVT" AS
/* $Header: OKCSPDFB.pls 120.0 2005/05/25 22:40:58 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  ---------------------------------------------------------------------------
  -- Define a local variable to get the value of USERENV('LANG')
  ---------------------------------------------------------------------------
  l_lang      VARCHAR2(12) := OKC_UTIL.get_userenv_lang;

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
    DELETE FROM OKC_PROCESS_DEFS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_PROCESS_DEFS_B B
         WHERE B.ID = T.ID
        );

    UPDATE OKC_PROCESS_DEFS_TL T SET (
        NAME,
        DESCRIPTION,
        SHORT_DESCRIPTION,
        COMMENTS) = (SELECT
                                  B.NAME,
                                  B.DESCRIPTION,
                                  B.SHORT_DESCRIPTION,
                                  B.COMMENTS
                                FROM OKC_PROCESS_DEFS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKC_PROCESS_DEFS_TL SUBB, OKC_PROCESS_DEFS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR SUBB.SHORT_DESCRIPTION <> SUBT.SHORT_DESCRIPTION
                      OR SUBB.COMMENTS <> SUBT.COMMENTS
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
                      OR (SUBB.SHORT_DESCRIPTION IS NULL AND SUBT.SHORT_DESCRIPTION IS NOT NULL)
                      OR (SUBB.SHORT_DESCRIPTION IS NOT NULL AND SUBT.SHORT_DESCRIPTION IS NULL)
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
              ));

    INSERT INTO OKC_PROCESS_DEFS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        NAME,
        DESCRIPTION,
        SHORT_DESCRIPTION,
        COMMENTS,
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
            B.DESCRIPTION,
            B.SHORT_DESCRIPTION,
            B.COMMENTS,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_PROCESS_DEFS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_PROCESS_DEFS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_PROCESS_DEFS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_process_defs_tl_rec      IN okc_process_defs_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_process_defs_tl_rec_type IS
    CURSOR okc_process_defs_tl_pk_csr (p_id                 IN NUMBER,
                                       p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            NAME,
            DESCRIPTION,
            SHORT_DESCRIPTION,
            COMMENTS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Process_Defs_Tl
     WHERE okc_process_defs_tl.id = p_id
       AND okc_process_defs_tl.language = p_language;
    l_okc_process_defs_tl_pk       okc_process_defs_tl_pk_csr%ROWTYPE;
    l_okc_process_defs_tl_rec      okc_process_defs_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_process_defs_tl_pk_csr (p_okc_process_defs_tl_rec.id,
                                     p_okc_process_defs_tl_rec.language);
    FETCH okc_process_defs_tl_pk_csr INTO
              l_okc_process_defs_tl_rec.ID,
              l_okc_process_defs_tl_rec.LANGUAGE,
              l_okc_process_defs_tl_rec.SOURCE_LANG,
              l_okc_process_defs_tl_rec.SFWT_FLAG,
              l_okc_process_defs_tl_rec.NAME,
              l_okc_process_defs_tl_rec.DESCRIPTION,
              l_okc_process_defs_tl_rec.SHORT_DESCRIPTION,
              l_okc_process_defs_tl_rec.COMMENTS,
              l_okc_process_defs_tl_rec.CREATED_BY,
              l_okc_process_defs_tl_rec.CREATION_DATE,
              l_okc_process_defs_tl_rec.LAST_UPDATED_BY,
              l_okc_process_defs_tl_rec.LAST_UPDATE_DATE,
              l_okc_process_defs_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_process_defs_tl_pk_csr%NOTFOUND;
    CLOSE okc_process_defs_tl_pk_csr;
    RETURN(l_okc_process_defs_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okc_process_defs_tl_rec      IN okc_process_defs_tl_rec_type
  ) RETURN okc_process_defs_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_process_defs_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_PROCESS_DEFS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pdf_rec                      IN pdf_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pdf_rec_type IS
    CURSOR okc_process_defs_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            PDF_TYPE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            USAGE,
            CREATION_DATE,
            BEGIN_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            WF_NAME,
            WF_PROCESS_NAME,
            PROCEDURE_NAME,
            PACKAGE_NAME,
            LAST_UPDATE_LOGIN,
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
            APPLICATION_ID,
            SEEDED_FLAG,
	    MESSAGE_NAME,
	    SCRIPT_NAME
      FROM Okc_Process_Defs_B
     WHERE okc_process_defs_b.id = p_id;
    l_okc_process_defs_b_pk        okc_process_defs_b_pk_csr%ROWTYPE;
    l_pdf_rec                      pdf_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_process_defs_b_pk_csr (p_pdf_rec.id);
    FETCH okc_process_defs_b_pk_csr INTO
              l_pdf_rec.ID,
              l_pdf_rec.PDF_TYPE,
              l_pdf_rec.OBJECT_VERSION_NUMBER,
              l_pdf_rec.CREATED_BY,
              l_pdf_rec.USAGE,
              l_pdf_rec.CREATION_DATE,
              l_pdf_rec.BEGIN_DATE,
              l_pdf_rec.LAST_UPDATED_BY,
              l_pdf_rec.LAST_UPDATE_DATE,
              l_pdf_rec.WF_NAME,
              l_pdf_rec.WF_PROCESS_NAME,
              l_pdf_rec.PROCEDURE_NAME,
              l_pdf_rec.PACKAGE_NAME,
              l_pdf_rec.LAST_UPDATE_LOGIN,
              l_pdf_rec.END_DATE,
              l_pdf_rec.ATTRIBUTE_CATEGORY,
              l_pdf_rec.ATTRIBUTE1,
              l_pdf_rec.ATTRIBUTE2,
              l_pdf_rec.ATTRIBUTE3,
              l_pdf_rec.ATTRIBUTE4,
              l_pdf_rec.ATTRIBUTE5,
              l_pdf_rec.ATTRIBUTE6,
              l_pdf_rec.ATTRIBUTE7,
              l_pdf_rec.ATTRIBUTE8,
              l_pdf_rec.ATTRIBUTE9,
              l_pdf_rec.ATTRIBUTE10,
              l_pdf_rec.ATTRIBUTE11,
              l_pdf_rec.ATTRIBUTE12,
              l_pdf_rec.ATTRIBUTE13,
              l_pdf_rec.ATTRIBUTE14,
              l_pdf_rec.ATTRIBUTE15,
              l_pdf_rec.APPLICATION_ID,
              l_pdf_rec.SEEDED_FLAG,
	      l_pdf_rec.MESSAGE_NAME,
	      l_pdf_rec.SCRIPT_NAME;
    x_no_data_found := okc_process_defs_b_pk_csr%NOTFOUND;
    CLOSE okc_process_defs_b_pk_csr;
    RETURN(l_pdf_rec);
  END get_rec;

  FUNCTION get_rec (
    p_pdf_rec                      IN pdf_rec_type
  ) RETURN pdf_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pdf_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_PROCESS_DEFS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pdfv_rec                     IN pdfv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pdfv_rec_type IS
    CURSOR okc_pdfv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            DESCRIPTION,
            SHORT_DESCRIPTION,
            COMMENTS,
            USAGE,
            NAME,
            WF_NAME,
            WF_PROCESS_NAME,
            PROCEDURE_NAME,
            PACKAGE_NAME,
            PDF_TYPE,
            APPLICATION_ID,
            SEEDED_FLAG,
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
            BEGIN_DATE,
            END_DATE,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
	    MESSAGE_NAME,
	    SCRIPT_NAME
      FROM Okc_Process_Defs_V
     WHERE okc_process_defs_v.id = p_id;
    l_okc_pdfv_pk                  okc_pdfv_pk_csr%ROWTYPE;
    l_pdfv_rec                     pdfv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_pdfv_pk_csr (p_pdfv_rec.id);
    FETCH okc_pdfv_pk_csr INTO
              l_pdfv_rec.ID,
              l_pdfv_rec.OBJECT_VERSION_NUMBER,
              l_pdfv_rec.SFWT_FLAG,
              l_pdfv_rec.DESCRIPTION,
              l_pdfv_rec.SHORT_DESCRIPTION,
              l_pdfv_rec.COMMENTS,
              l_pdfv_rec.USAGE,
              l_pdfv_rec.NAME,
              l_pdfv_rec.WF_NAME,
              l_pdfv_rec.WF_PROCESS_NAME,
              l_pdfv_rec.PROCEDURE_NAME,
              l_pdfv_rec.PACKAGE_NAME,
              l_pdfv_rec.PDF_TYPE,
              l_pdfv_rec.APPLICATION_ID,
              l_pdfv_rec.SEEDED_FLAG,
              l_pdfv_rec.ATTRIBUTE_CATEGORY,
              l_pdfv_rec.ATTRIBUTE1,
              l_pdfv_rec.ATTRIBUTE2,
              l_pdfv_rec.ATTRIBUTE3,
              l_pdfv_rec.ATTRIBUTE4,
              l_pdfv_rec.ATTRIBUTE5,
              l_pdfv_rec.ATTRIBUTE6,
              l_pdfv_rec.ATTRIBUTE7,
              l_pdfv_rec.ATTRIBUTE8,
              l_pdfv_rec.ATTRIBUTE9,
              l_pdfv_rec.ATTRIBUTE10,
              l_pdfv_rec.ATTRIBUTE11,
              l_pdfv_rec.ATTRIBUTE12,
              l_pdfv_rec.ATTRIBUTE13,
              l_pdfv_rec.ATTRIBUTE14,
              l_pdfv_rec.ATTRIBUTE15,
              l_pdfv_rec.CREATED_BY,
              l_pdfv_rec.BEGIN_DATE,
              l_pdfv_rec.END_DATE,
              l_pdfv_rec.CREATION_DATE,
              l_pdfv_rec.LAST_UPDATED_BY,
              l_pdfv_rec.LAST_UPDATE_DATE,
              l_pdfv_rec.LAST_UPDATE_LOGIN,
	      l_pdfv_rec.MESSAGE_NAME,
	      l_pdfv_rec.SCRIPT_NAME;
    x_no_data_found := okc_pdfv_pk_csr%NOTFOUND;
    CLOSE okc_pdfv_pk_csr;
    RETURN(l_pdfv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_pdfv_rec                     IN pdfv_rec_type
  ) RETURN pdfv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pdfv_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_PROCESS_DEFS_V --
  --------------------------------------------------------
  FUNCTION null_out_defaults (
    p_pdfv_rec	IN pdfv_rec_type
  ) RETURN pdfv_rec_type IS
    l_pdfv_rec	pdfv_rec_type := p_pdfv_rec;
  BEGIN
    IF (l_pdfv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_pdfv_rec.object_version_number := NULL;
    END IF;
    IF (l_pdfv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_pdfv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.description := NULL;
    END IF;
    IF (l_pdfv_rec.short_description = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.short_description := NULL;
    END IF;
    IF (l_pdfv_rec.comments = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.comments := NULL;
    END IF;
    IF (l_pdfv_rec.usage = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.usage := NULL;
    END IF;
    IF (l_pdfv_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.name := NULL;
    END IF;
    IF (l_pdfv_rec.wf_name = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.wf_name := NULL;
    END IF;
    IF (l_pdfv_rec.wf_process_name = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.wf_process_name := NULL;
    END IF;
    IF (l_pdfv_rec.procedure_name = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.procedure_name := NULL;
    END IF;
    IF (l_pdfv_rec.package_name = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.package_name := NULL;
    END IF;
    IF (l_pdfv_rec.pdf_type = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.pdf_type := NULL;
    END IF;
    IF (l_pdfv_rec.application_id = OKC_API.G_MISS_NUM) THEN
      l_pdfv_rec.application_id := NULL;
    END IF;
    IF (l_pdfv_rec.seeded_flag = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.seeded_flag := NULL;
    END IF;
    IF (l_pdfv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.attribute_category := NULL;
    END IF;
    IF (l_pdfv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.attribute1 := NULL;
    END IF;
    IF (l_pdfv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.attribute2 := NULL;
    END IF;
    IF (l_pdfv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.attribute3 := NULL;
    END IF;
    IF (l_pdfv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.attribute4 := NULL;
    END IF;
    IF (l_pdfv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.attribute5 := NULL;
    END IF;
    IF (l_pdfv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.attribute6 := NULL;
    END IF;
    IF (l_pdfv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.attribute7 := NULL;
    END IF;
    IF (l_pdfv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.attribute8 := NULL;
    END IF;
    IF (l_pdfv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.attribute9 := NULL;
    END IF;
    IF (l_pdfv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.attribute10 := NULL;
    END IF;
    IF (l_pdfv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.attribute11 := NULL;
    END IF;
    IF (l_pdfv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.attribute12 := NULL;
    END IF;
    IF (l_pdfv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.attribute13 := NULL;
    END IF;
    IF (l_pdfv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.attribute14 := NULL;
    END IF;
    IF (l_pdfv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.attribute15 := NULL;
    END IF;
    IF (l_pdfv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_pdfv_rec.created_by := NULL;
    END IF;
    IF (l_pdfv_rec.begin_date = OKC_API.G_MISS_DATE) THEN
      l_pdfv_rec.begin_date := NULL;
    END IF;
    IF (l_pdfv_rec.end_date = OKC_API.G_MISS_DATE) THEN
      l_pdfv_rec.end_date := NULL;
    END IF;
    IF (l_pdfv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_pdfv_rec.creation_date := NULL;
    END IF;
    IF (l_pdfv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_pdfv_rec.last_updated_by := NULL;
    END IF;
    IF (l_pdfv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_pdfv_rec.last_update_date := NULL;
    END IF;
    IF (l_pdfv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_pdfv_rec.last_update_login := NULL;
    END IF;
    IF (l_pdfv_rec.message_name = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.message_name := NULL;
    END IF;
    IF (l_pdfv_rec.script_name = OKC_API.G_MISS_CHAR) THEN
      l_pdfv_rec.script_name := NULL;
    END IF;
    RETURN(l_pdfv_rec);
  END null_out_defaults;

  /******** Commented out nocopy generated code in favor of hand written code
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKC_PROCESS_DEFS_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_pdfv_rec IN  pdfv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_pdfv_rec.id = OKC_API.G_MISS_NUM OR
       p_pdfv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pdfv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_pdfv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pdfv_rec.usage = OKC_API.G_MISS_CHAR OR
          p_pdfv_rec.usage IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'usage');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pdfv_rec.name = OKC_API.G_MISS_CHAR OR
          p_pdfv_rec.name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pdfv_rec.pdf_type = OKC_API.G_MISS_CHAR OR
          p_pdfv_rec.pdf_type IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pdf_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pdfv_rec.begin_date = OKC_API.G_MISS_DATE OR
          p_pdfv_rec.begin_date IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'begin_date');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Record for:OKC_PROCESS_DEFS_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_pdfv_rec IN pdfv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ******************** End Generated Code **********************************/

  /******************* Begin Hand Written Code *****************************/
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKC_PROCESS_DEFS_V --
  ------------------------------------------------
  -- Start of comments
  -- Procedure Name  : validate_object_version_number
  -- Description     : Check if object_version_number is null
  -- Version         : 1.0
  -- End of comments

   PROCEDURE validate_object_version_number(
    	x_return_status 	OUT NOCOPY VARCHAR2,
        p_pdfv_rec              IN pdfv_rec_type) IS
   BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	--Check if the data is null
	IF p_pdfv_rec.object_version_number = OKC_API.G_MISS_NUM OR p_pdfv_rec.object_version_number IS NULL THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'object_version_number');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;
  EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => sqlcode,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => sqlerrm);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_object_version_number;

   -- Start of comments
   -- Procedure Name  : validate_sfwt_flag
   -- Description     : Checks if column SFWT_FLAG is 'Y' or 'N' only
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_sfwt_flag(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdfv_rec              IN pdfv_rec_type) IS
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	--Check if the data is null
	IF p_pdfv_rec.sfwt_flag = OKC_API.G_MISS_CHAR OR p_pdfv_rec.sfwt_flag IS NULL THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'sfwt_flag');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	-- Check if sfwt_flag is Y or N
	IF UPPER(p_pdfv_rec.sfwt_flag) NOT IN ('Y', 'N') THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'sfwt_flag');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	--Check if the data is in upper case
	IF p_pdfv_rec.sfwt_flag <> UPPER(p_pdfv_rec.sfwt_flag) THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_uppercase_required,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'sfwt_flag');
		x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;
    EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => sqlcode,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => sqlerrm);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_sfwt_flag;

   -- Start of comments
   -- Procedure Name  : validate_seeded_flag
   -- Description     : Checks if column SEEDED_FLAG is 'Y' or 'N' only
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_seeded_flag(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdfv_rec              IN pdfv_rec_type) IS
		l_y VARCHAR2(1) := 'Y';
		l_n VARCHAR2(1) := 'N';
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;
	-- Check if seeded_flag is Y or N
	IF UPPER(p_pdfv_rec.seeded_flag) NOT IN ('Y', 'N') THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'seeded_flag');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	--Check if the data is in upper case
	IF p_pdfv_rec.seeded_flag <> UPPER(p_pdfv_rec.seeded_flag) THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_uppercase_required,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'seeded_flag');
		x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;
    EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => sqlcode,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => sqlerrm);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_seeded_flag;

   -- Start of comments
   -- Procedure Name  : validate_application_id
   -- Description     : Checks if application_id exists in fnd_application
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_application_id(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdfv_rec              IN pdfv_rec_type) IS
	Cursor application_id_cur(p_application_id IN NUMBER) IS
	select '1'
	from fnd_application
	where application_id = p_application_id;
	l_dummy		VARCHAR2(1) := '?';
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	IF p_pdfv_rec.application_id IS NOT NULL THEN
	--Check if application id exists in the fnd_application or not
	OPEN application_id_cur(p_pdfv_rec.application_id);
	FETCH application_id_cur INTO l_dummy;
	CLOSE application_id_cur ;
	IF l_dummy = '?' THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'application_id');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;
     END IF;
    EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => sqlcode,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => sqlerrm);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_application_id;

   -- Start of comments
   -- Procedure Name  : validate_usage
   -- Description     : Checks for valid usage and uppercase
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_usage(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdfv_rec              IN pdfv_rec_type) IS

	Cursor usage_cur(p_usage IN VARCHAR2) IS
	select lookup_code
	from fnd_lookups
	where lookup_type = 'OKC_PROCESS_USAGE_TYPES'
	and lookup_code = p_usage;
	l_usage		VARCHAR2(250);
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	--Check if the data is null
 	IF p_pdfv_rec.usage = OKC_API.G_MISS_CHAR OR p_pdfv_rec.usage IS NULL THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'purpose');
		x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	-- Check for valid usage
	OPEN usage_cur(p_pdfv_rec.usage);
	FETCH usage_cur into l_usage;
	CLOSE usage_cur;
		IF l_usage IS NULL THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'purpose');
		x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
		END IF;

	--Check if the data is in upper case
	IF p_pdfv_rec.usage <> UPPER(p_pdfv_rec.usage) THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_uppercase_required,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'purpose');
		x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;
    EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => sqlcode,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => sqlerrm);

    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_usage;

   -- Start of comments
   -- Procedure Name  : validate_name
   -- Description     : Checks for unique name
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_name(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdfv_rec              IN pdfv_rec_type) IS

  CURSOR l_unq_cur(p_name VARCHAR2) IS
	    SELECT id FROM OKC_PROCESS_DEFS_V
	    WHERE name = p_name;

  l_id                    NUMBER       := OKC_API.G_MISS_NUM;
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	--Check if the data is null
 	IF p_pdfv_rec.name = OKC_API.G_MISS_CHAR OR p_pdfv_rec.name IS NULL THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'name');
		x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	--Check if the data is unique
	--Bug 1699203 - Removed check_unique
	OPEN l_unq_cur(p_pdfv_rec.name);
	FETCH l_unq_cur INTO l_id;
	CLOSE l_unq_cur;
	If (l_id <> OKC_API.G_MISS_NUM AND l_id <> nvl(p_pdfv_rec.id,0)) THEN
	   x_return_status := OKC_API.G_RET_STS_ERROR;
	   OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME,
					   p_msg_name => 'OKC_DUP_PROCESS_NAME');
     END IF;
	/*
	IF p_pdfv_rec.name IS NOT NULL THEN
		OKC_UTIL.check_Unique(G_VIEW
			      ,'NAME'
			      ,p_pdfv_rec.name
			      ,p_pdfv_rec.id
			      ,x_return_status);
    		If x_return_status<>OKC_API.G_RET_STS_SUCCESS Then
            		return;
    		End If;
	END IF;
    */

    EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => sqlcode,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => sqlerrm);

    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_name;

   -- Start of comments
   -- Procedure Name  : validate_wf_name
   -- Description     : Checks for valid length, Uniqueness and upper case for column WF_NAME
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_wf_name(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdfv_rec              IN pdfv_rec_type) IS
   BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	--Check if the data is in uppercase
	IF p_pdfv_rec.wf_name <> UPPER(p_pdfv_rec.wf_name) THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_uppercase_required,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'wf_name');
		x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;
    EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => sqlcode,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => sqlerrm);

    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_wf_name;

    -- Start of comments
    -- Procedure Name  : validate_wf_process_name
    -- Description     : Checks for valid length, Uniqueness and upper case for column WF_PROCESS_NAME
    -- Version         : 1.0
    -- End of comments

    PROCEDURE validate_wf_process_name(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdfv_rec              IN pdfv_rec_type) IS
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	--Check if the data is in upper case
	IF p_pdfv_rec.wf_process_name <> UPPER(p_pdfv_rec.wf_process_name) THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_uppercase_required,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'wf_process_name');
     		x_return_status := OKC_API.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;
    EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => sqlcode,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => sqlerrm);

    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_wf_process_name;

    -- Start of comments
    -- Procedure Name  : validate_procedure_name
    -- Description     : Checks for valid length, Uniqueness and upper case for column PROCEDURE_NAME
    -- Version         : 1.0
    -- End of comments

    PROCEDURE validate_procedure_name(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdfv_rec              IN pdfv_rec_type) IS

    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	--Check if the data is in upper case
		IF p_pdfv_rec.procedure_name <> UPPER(p_pdfv_rec.procedure_name) THEN
			OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_uppercase_required,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'procedure_name');
     			x_return_status := OKC_API.G_RET_STS_ERROR;
			RAISE G_EXCEPTION_HALT_VALIDATION;
		END IF;
    EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => sqlcode,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => sqlerrm);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_procedure_name;

    -- Start of comments
    -- Procedure Name  : validate_package_name
    -- Description     : Checks for valid length, Uniqueness and upper case for column PACKAGE_NAME
    -- Version         : 1.0
    -- End of comments

    PROCEDURE validate_package_name(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdfv_rec              IN pdfv_rec_type) IS

    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

       --Check if the data is in upper case
		IF p_pdfv_rec.package_name <> UPPER(p_pdfv_rec.package_name) THEN
			OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_uppercase_required,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'package_name');
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise G_EXCEPTION_HALT_VALIDATION;
		END IF;
     EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => sqlcode,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => sqlerrm);

    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_package_name;

  -- Start of comments
    -- Procedure Name  : validate_pdf_type
    -- Description     : Checks for valid pdf_type
    -- Version         : 1.0
    -- End of comments

   PROCEDURE validate_pdf_type(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdfv_rec              IN pdfv_rec_type) IS
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	--Check if pdf_type is null
	IF p_pdfv_rec.pdf_type IS NULL THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'type');
		x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
		END IF;

	-- Check if pdf_type is Workflow or plsql procedure
	If p_pdfv_rec.pdf_type not in ('PPS', 'WPS','ALERT', 'SCRIPT') then
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'type');
		x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;
    EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => sqlcode,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => sqlerrm);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_pdf_type;

  -- Start of comments
  -- Procedure Name  : validate_begin_date
  -- Description     : Check if begin_date is null
  -- Version         : 1.0
  -- End of comments

   PROCEDURE validate_begin_date(
    	x_return_status 	OUT NOCOPY VARCHAR2,
        p_pdfv_rec              IN pdfv_rec_type) IS
   BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Check if the data is null
	IF p_pdfv_rec.begin_date = OKC_API.G_MISS_DATE OR p_pdfv_rec.begin_date IS NULL THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'begin_date');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;
  EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => sqlcode,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => sqlerrm);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_begin_date;

    FUNCTION validate_attributes (
      p_pdfv_rec IN  pdfv_rec_type
    ) RETURN VARCHAR2 IS
         x_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	 l_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
	validate_object_version_number(x_return_status
		       		      ,p_pdfv_rec);
      	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
      		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
    	END IF;

	validate_sfwt_flag(x_return_status
		           ,p_pdfv_rec);
      	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
      		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
    	END IF;

	validate_seeded_flag(x_return_status
		           ,p_pdfv_rec);
      	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
      		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
    	END IF;

	validate_application_id(x_return_status
		           ,p_pdfv_rec);
      	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
      		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
    	END IF;

	validate_usage(x_return_status
		       ,p_pdfv_rec);
      	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
      		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
    	END IF;

	validate_name(x_return_status
		       ,p_pdfv_rec);
      	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
      		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
    	END IF;

	validate_wf_name(x_return_status
		       ,p_pdfv_rec);
      	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
      		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
    	END IF;

	validate_wf_process_name(x_return_status
		      		 ,p_pdfv_rec);
      	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
      		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
    	END IF;

	validate_procedure_name(x_return_status
		         	,p_pdfv_rec);
      	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
      		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
    	END IF;

	validate_package_name(x_return_status
		              ,p_pdfv_rec);
      	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
      		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
    	END IF;

	validate_pdf_type(x_return_status
		       	  ,p_pdfv_rec);
      	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
      		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
    	END IF;

	validate_begin_date(x_return_status
		       	   ,p_pdfv_rec);
      	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
      		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
    	END IF;

	RETURN (l_return_status);

	EXCEPTION
		When G_EXCEPTION_HALT_VALIDATION then
    		--just come out with return status
    		null;
		RETURN(l_return_status);

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);

    		-- notify caller of an UNEXPECTED error
    		l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
         	RETURN(l_return_status);
    END validate_attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Record for:OKC_PROCESS_DEFS_V --
  --------------------------------------------
--------------------------------------------------------------------------------
    -- Start of comments
    -- Procedure Name  : validate_unique_pack_proc
    -- Description     : Checks for unique procedure name and package name
    -- Version         : 1.0
    -- End of comments
--------------------------------------------------------------------------------

    PROCEDURE validate_unique_pack_proc(
    	x_return_status 	OUT NOCOPY VARCHAR2,
    	p_pdfv_rec              IN pdfv_rec_type) IS

	--l_return_status		VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  	--l_unq_tbl               OKC_UTIL.unq_tbl_type;
     l_dummy                 VARCHAR2(1);
     l_row_found             Boolean := False;
     CURSOR c1(p_package_name okc_process_defs_v.package_name%TYPE,
               p_procedure_name okc_process_defs_v.procedure_name%TYPE) is
     SELECT 1
     FROM okc_process_defs_b
     WHERE  package_name = p_package_name
     AND    procedure_name = p_procedure_name
	AND    id <> nvl(p_pdfv_rec.id,-99999);

  BEGIN

	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

  /*Bug 1636056:The following code commented out nocopy since it was not using bind
	    variables and parsing was taking place.Replaced with explicit cursor
	    as above
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- initialize columns of unique concatenated key
    	l_unq_tbl(1).p_col_name   := 'package_name';
    	l_unq_tbl(1).p_col_val    := p_pdfv_rec.package_name;
    	l_unq_tbl(2).p_col_name   := 'procedure_name';
    	l_unq_tbl(2).p_col_val    := p_pdfv_rec.procedure_name;

	If p_pdfv_rec.package_name is not null or p_pdfv_rec.procedure_name is not null then
		OKC_UTIL.check_comp_unique(G_VIEW
                              	    ,p_col_tbl   => l_unq_tbl
                              	    ,p_id        => p_pdfv_rec.id
                              	    ,x_return_status => l_return_status);
    		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       			x_return_status := OKC_API.G_RET_STS_ERROR;
    		END IF;
	End if;	*/
	If p_pdfv_rec.package_name is not null or p_pdfv_rec.procedure_name is not null then
    OPEN c1(p_pdfv_rec.package_name,
		  p_pdfv_rec.procedure_name);
    FETCH c1 into l_dummy;
    l_row_found := c1%FOUND;
    CLOSE c1;
    End if;
    IF l_row_found then
		--OKC_API.set_message(G_APP_NAME,G_UNQS,G_COL_NAME_TOKEN1,'procedure_name',G_COL_NAME_TOKEN2,'package_name');
		OKC_API.set_message(G_APP_NAME,G_UNQS1);
		x_return_status := OKC_API.G_RET_STS_ERROR;
     END IF;

    EXCEPTION
		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
   END validate_unique_pack_proc;
--------------------------------------------------------------------------------
    -- Start of comments
    -- Procedure Name  : validate_unique_wf_process
    -- Description     : Checks for unique workflow name and workflow process name
    -- Version         : 1.0
    -- End of comments
--------------------------------------------------------------------------------

    PROCEDURE validate_unique_wf_process(
    	x_return_status 	OUT NOCOPY VARCHAR2,
     p_pdfv_rec              IN pdfv_rec_type) IS

	--l_return_status		VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     --l_unq_tbl               OKC_UTIL.unq_tbl_type;
     l_dummy                 VARCHAR2(1);
     l_row_found             Boolean := False;
     CURSOR c1(p_wf_name okc_process_defs_v.wf_name%TYPE,
               p_wf_process_name okc_process_defs_v.wf_process_name%TYPE) is
     SELECT 1
     FROM okc_process_defs_v
     WHERE  wf_name = p_wf_name
     AND    wf_process_name = p_wf_process_name
	AND    id <> nvl(p_pdfv_rec.id,-99999);

    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;


  /*Bug 1636056:The following code commented out nocopy sinct it was not using bind
	    variables and parsing was taking place.Replced with explicit cursor
	    as above
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- initialize columns of unique concatenated key
    	l_unq_tbl(1).p_col_name   := 'wf_name';
    	l_unq_tbl(1).p_col_val    := p_pdfv_rec.wf_name;
    	l_unq_tbl(2).p_col_name   := 'wf_process_name';
    	l_unq_tbl(2).p_col_val    := p_pdfv_rec.wf_process_name;

	If p_pdfv_rec.wf_name is not null or p_pdfv_rec.wf_process_name is not null then
		OKC_UTIL.check_comp_unique(G_VIEW
                              	    ,p_col_tbl   => l_unq_tbl
                              	    ,p_id        => p_pdfv_rec.id
                              	    ,x_return_status => l_return_status);
    		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       			x_return_status := OKC_API.G_RET_STS_ERROR;
    		END IF;
	End if;
	*/
	If p_pdfv_rec.wf_name is not null or p_pdfv_rec.wf_process_name is not null then
    OPEN c1(p_pdfv_rec.wf_name,
		  p_pdfv_rec.wf_process_name);
    FETCH c1 into l_dummy;
    l_row_found := c1%FOUND;
    CLOSE c1;
    End if;
    IF l_row_found then
		--OKC_API.set_message(G_APP_NAME,G_UNQS,G_COL_NAME_TOKEN1,'wf_name',G_COL_NAME_TOKEN2,'wf_process_name');
		OKC_API.set_message(G_APP_NAME,G_UNQS2);
		x_return_status := OKC_API.G_RET_STS_ERROR;
     END IF;

    EXCEPTION
		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
   END validate_unique_wf_process;

    -- Start of comments
    -- Procedure Name  : validate_wf_plsql
    -- Description     : Checks if workflow and PL/SQL procedures are mutually exclusive
    -- Version         : 1.0
    -- End of comments

   PROCEDURE validate_wf_plsql(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdfv_rec              IN pdfv_rec_type) IS

	l_return_status		VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Check if Process definition type is either workflow or PL/SQL Process
	IF p_pdfv_rec.usage IN ( 'APPROVE', 'CHG_REQ_APPROVE', 'API') THEN
	   IF p_pdfv_rec.pdf_type IN ('PPS') THEN
		IF p_pdfv_rec.procedure_name IS NULL AND p_pdfv_rec.package_name IS NULL THEN
			OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_arc_mandatory,
                        	    p_token1       => g_col_name1,
                        	    p_token1_value => 'package',
				    p_token2       => g_col_name2,
                        	    p_token2_value => 'procedure');
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise G_EXCEPTION_HALT_VALIDATION;
		ELSIF p_pdfv_rec.procedure_name IS NULL AND p_pdfv_rec.package_name IS NOT NULL THEN
			OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'procedure');
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise G_EXCEPTION_HALT_VALIDATION;
		END IF;
	   END IF;
    	END IF;
	IF p_pdfv_rec.usage IN ( 'APPROVE', 'CHG_REQ_APPROVE', 'API') THEN
	   IF p_pdfv_rec.pdf_type IN ('WPS') THEN
		IF p_pdfv_rec.wf_name IS NULL AND p_pdfv_rec.wf_process_name IS NULL THEN
			OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_arc_mandatory,
                        	    p_token1       => g_col_name1,
                        	    p_token1_value => 'workflow name',
				    p_token2       => g_col_name2,
                        	    p_token2_value => 'workflow process');
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise G_EXCEPTION_HALT_VALIDATION;
		ELSIF p_pdfv_rec.wf_name IS NULL AND p_pdfv_rec.wf_process_name IS NOT NULL THEN
			OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'workflow name');
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise G_EXCEPTION_HALT_VALIDATION;
		END IF;
	   END IF;
    	END IF;
    EXCEPTION
		When G_EXCEPTION_HALT_VALIDATION then
    		--just come out with return status
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);

    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

   END validate_wf_plsql;

   -- Start of comments
   -- Procedure Name  : validate_outcome
   -- Description     : validation for outcome
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_outcome(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdfv_rec              IN pdfv_rec_type) IS

	l_return_status		VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Check if pdf_type = 'ALERT' or 'SCRIPT' then  wf and plsql should be null
	IF p_pdfv_rec.usage = 'OUTCOME' THEN
	        IF p_pdfv_rec.pdf_type = 'ALERT' THEN
                IF p_pdfv_rec.message_name is null THEN
		        	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'Alert Name');
			        x_return_status := OKC_API.G_RET_STS_ERROR;
			        raise G_EXCEPTION_HALT_VALIDATION;
		        END IF;
                -- if ALERT is the outcome then all other outcome types should be null
                IF p_pdfv_rec.wf_name IS NOT NULL OR p_pdfv_rec.wf_process_name IS NOT NULL
                OR p_pdfv_rec.procedure_name IS NOT NULL
                OR p_pdfv_rec.package_name IS NOT NULL
                OR p_pdfv_rec.script_name IS NOT NULL THEN
                    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'workflow name',
                                p_token2       => g_col_name_token,
                                p_token2_value => 'workflow process name',
                                p_token3       => g_col_name_token,
                                p_token3_value => 'procedure name',
                                p_token4       => g_col_name_token,
                                p_token4_value => 'package name',
                                p_token5       => g_col_name_token,
                                p_token5_value => 'script name'
                                );
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                    raise G_EXCEPTION_HALT_VALIDATION;
                END IF;

            END IF; -- p_pdfv_rec.pdf_type = 'ALERT'
	     IF p_pdfv_rec.pdf_type = 'SCRIPT' THEN
	        IF p_pdfv_rec.script_name is null THEN
			    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'Script name');
			    x_return_status := OKC_API.G_RET_STS_ERROR;
			    raise G_EXCEPTION_HALT_VALIDATION;
		    END IF;
                -- if SCRIPT is the outcome then all other outcome types should be null
                IF p_pdfv_rec.wf_name IS NOT NULL OR p_pdfv_rec.wf_process_name IS NOT NULL
                OR p_pdfv_rec.procedure_name IS NOT NULL
                OR p_pdfv_rec.package_name IS NOT NULL
                OR p_pdfv_rec.message_name IS NOT NULL THEN
                    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'workflow name',
                                p_token2       => g_col_name_token,
                                p_token2_value => 'workflow process name',
                                p_token3       => g_col_name_token,
                                p_token3_value => 'procedure name',
                                p_token4       => g_col_name_token,
                                p_token4_value => 'package name',
                                p_token5       => g_col_name_token,
                                p_token5_value => 'alert name'
                                );
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                    raise G_EXCEPTION_HALT_VALIDATION;
                END IF;


		 END IF; --  p_pdfv_rec.pdf_type = 'SCRIPT'

	   IF p_pdfv_rec.pdf_type = 'PPS' THEN
		    IF p_pdfv_rec.procedure_name IS NULL AND p_pdfv_rec.package_name IS NULL THEN
			    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_arc_mandatory,
                        	    p_token1       => g_col_name1,
                        	    p_token1_value => 'package',
				                p_token2       => g_col_name2,
                        	    p_token2_value => 'procedure');
			    x_return_status := OKC_API.G_RET_STS_ERROR;
			    raise G_EXCEPTION_HALT_VALIDATION;
		    ELSIF p_pdfv_rec.procedure_name IS NULL AND p_pdfv_rec.package_name IS NOT NULL THEN
			    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'procedure');
			    x_return_status := OKC_API.G_RET_STS_ERROR;
			    raise G_EXCEPTION_HALT_VALIDATION;
		    END IF;
                -- if PPS is the outcome then all other outcome types should be null
                IF p_pdfv_rec.wf_name IS NOT NULL OR p_pdfv_rec.wf_process_name IS NOT NULL
                OR p_pdfv_rec.script_name IS NOT NULL
                OR p_pdfv_rec.message_name IS NOT NULL THEN
                    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'workflow name',
                                p_token2       => g_col_name_token,
                                p_token2_value => 'workflow process name',
                                p_token3       => g_col_name_token,
                                p_token3_value => 'script name',
                                p_token4       => g_col_name_token,
                                p_token4_value => 'alert name'
                                );
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                    raise G_EXCEPTION_HALT_VALIDATION;
                END IF;

	   END IF; -- p_pdfv_rec.pdf_type = 'PPS'

       IF p_pdfv_rec.pdf_type = 'WPS' THEN
		IF p_pdfv_rec.wf_name IS NULL AND p_pdfv_rec.wf_process_name IS NULL THEN
			    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_arc_mandatory,
                        	    p_token1       => g_col_name1,
                        	    p_token1_value => 'workflow name',
				                p_token2       => g_col_name2,
                        	    p_token2_value => 'workflow process');
			    x_return_status := OKC_API.G_RET_STS_ERROR;
			    raise G_EXCEPTION_HALT_VALIDATION;
		ELSIF p_pdfv_rec.wf_name IS NULL AND p_pdfv_rec.wf_process_name IS NOT NULL THEN
			    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'workflow name');
			    x_return_status := OKC_API.G_RET_STS_ERROR;
			    raise G_EXCEPTION_HALT_VALIDATION;
		END IF;
                -- if WPS is the outcome then all other outcome types should be null
                IF p_pdfv_rec.procedure_name IS NOT NULL
                OR p_pdfv_rec.package_name IS NOT NULL
                OR p_pdfv_rec.script_name IS NOT NULL
                OR p_pdfv_rec.message_name IS NOT NULL THEN
                    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'script name',
                                p_token2       => g_col_name_token,
                                p_token2_value => 'procedure name',
                                p_token3       => g_col_name_token,
                                p_token3_value => 'package name',
                                p_token4       => g_col_name_token,
                                p_token4_value => 'alert name'
                                );
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                    raise G_EXCEPTION_HALT_VALIDATION;
                END IF;

	   END IF; --  p_pdfv_rec.pdf_type = 'WPS'
	END IF; -- p_pdfv_rec.usage = 'OUTCOME'
   EXCEPTION
		When G_EXCEPTION_HALT_VALIDATION then
    		--just come out with return status
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);

    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
   END validate_outcome;

   -- Start of comments
   -- Procedure Name  : validate_qa
   -- Description     : Checks if usage is QA then it has to be a PL/SQL process
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_qa(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdfv_rec              IN pdfv_rec_type) IS

	l_return_status		VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Check if QA Process is only PL/SQL
	IF p_pdfv_rec.usage IN ('QA','AUTONUMBERING') THEN
		IF p_pdfv_rec.procedure_name IS NULL
                   AND p_pdfv_rec.package_name IS NULL THEN
			OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_arc_mandatory,
                        	    p_token1       => g_col_name1,
                        	    p_token1_value => 'package',
				    p_token2	   => g_col_name2,
				    p_token2_value => 'procedure');
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise G_EXCEPTION_HALT_VALIDATION;
		ELSIF p_pdfv_rec.procedure_name IS NULL
                   AND p_pdfv_rec.package_name IS NOT NULL THEN
			OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'procedure');
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise G_EXCEPTION_HALT_VALIDATION;
		END IF;
	END IF;
   EXCEPTION
		When G_EXCEPTION_HALT_VALIDATION then
    		--just come out with return status
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);

    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

   END validate_qa;

   -- Start of comments
   -- Procedure Name  : validate_function
   -- Description     : Checks if usage is FUNCTION then it has to be a PL/SQL Function
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_function(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdfv_rec              IN pdfv_rec_type) IS

	l_return_status		VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Check if FUNCTION  is only PL/SQL Function
	IF p_pdfv_rec.usage = 'FUNCTION' THEN
		IF p_pdfv_rec.procedure_name IS NULL
		   AND p_pdfv_rec.package_name IS NULL THEN
			OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_arc_mandatory,
                        	    p_token1       => g_col_name1,
                        	    p_token1_value => 'package',
				    p_token2	   => g_col_name2,
				    p_token2_value => 'procedure');
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise G_EXCEPTION_HALT_VALIDATION;
		ELSIF p_pdfv_rec.procedure_name IS NULL
		   AND p_pdfv_rec.package_name IS NOT NULL THEN
			OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'procedure');
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise G_EXCEPTION_HALT_VALIDATION;
		END IF;
	END IF;
   EXCEPTION
		When G_EXCEPTION_HALT_VALIDATION then
    		--just come out with return status
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);

    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

   END validate_function;

   -- Start of comments
   -- Procedure Name  : validate_end_date
   -- Description     : Checks if end date is greater than begin date
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_end_date(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdfv_rec              IN pdfv_rec_type) IS

	l_return_status		VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Check if end date is greater than begin date
	IF p_pdfv_rec.end_date < p_pdfv_rec.begin_date  THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_end_date,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'begin_date',
				    p_token2	   => g_col_name_token,
				    p_token2_value => 'end_date');
		x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

    EXCEPTION
		When G_EXCEPTION_HALT_VALIDATION then
    		--just come out with return status
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);

    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_end_date;

    FUNCTION Validate_Record (
      p_pdfv_rec IN pdfv_rec_type
    ) RETURN VARCHAR2 IS
      x_return_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
	validate_unique_pack_proc(x_return_status
		         	   ,p_pdfv_rec);
      	 IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
      		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
    	END IF;

	validate_unique_wf_process(x_return_status
		         	   ,p_pdfv_rec);
      	 IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
      		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
    	END IF;

	validate_wf_plsql(x_return_status
		         ,p_pdfv_rec);
      	 IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
      		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
    	END IF;

	validate_outcome(x_return_status
		         ,p_pdfv_rec);
      	 IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
      		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
    	END IF;

	validate_qa(x_return_status
		       ,p_pdfv_rec);
      	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
      		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
    	END IF;

	validate_function(x_return_status
		       ,p_pdfv_rec);
      	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
      		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
    	END IF;

	validate_end_date(x_return_status
		         ,p_pdfv_rec);
      	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
      		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
   	END IF;
      RETURN (l_return_status);
    EXCEPTION
	When G_EXCEPTION_HALT_VALIDATION then
    		--just come out with return status
    		null;
		RETURN(l_return_status);

    	when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);

		l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
	RETURN (l_return_status);
    END Validate_Record;

  /******************* End Hand Written Code *****************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN pdfv_rec_type,
    p_to	OUT NOCOPY okc_process_defs_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okc_process_defs_tl_rec_type,
    p_to	IN OUT NOCOPY pdfv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN pdfv_rec_type,
    p_to	OUT NOCOPY pdf_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.pdf_type := p_from.pdf_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.usage := p_from.usage;
    p_to.creation_date := p_from.creation_date;
    p_to.begin_date := p_from.begin_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.wf_name := p_from.wf_name;
    p_to.wf_process_name := p_from.wf_process_name;
    p_to.procedure_name := p_from.procedure_name;
    p_to.package_name := p_from.package_name;
    p_to.last_update_login := p_from.last_update_login;
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
    p_to.application_id := p_from.application_id;
    p_to.seeded_flag := p_from.seeded_flag;
    p_to.message_name := p_from.message_name;
    p_to.script_name := p_from.script_name;
  END migrate;
  PROCEDURE migrate (
    p_from	IN pdf_rec_type,
    p_to	IN OUT NOCOPY pdfv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.pdf_type := p_from.pdf_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.usage := p_from.usage;
    p_to.creation_date := p_from.creation_date;
    p_to.begin_date := p_from.begin_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.wf_name := p_from.wf_name;
    p_to.wf_process_name := p_from.wf_process_name;
    p_to.procedure_name := p_from.procedure_name;
    p_to.package_name := p_from.package_name;
    p_to.last_update_login := p_from.last_update_login;
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
    p_to.application_id := p_from.application_id;
    p_to.seeded_flag := p_from.seeded_flag;
    p_to.message_name := p_from.message_name;
    p_to.script_name := p_from.script_name;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:OKC_PROCESS_DEFS_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_rec                     IN pdfv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdfv_rec                     pdfv_rec_type := p_pdfv_rec;
    l_okc_process_defs_tl_rec      okc_process_defs_tl_rec_type;
    l_pdf_rec                      pdf_rec_type;
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
    l_return_status := Validate_Attributes(l_pdfv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_pdfv_rec);
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
  -- PL/SQL TBL validate_row for:PDFV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_tbl                     IN pdfv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pdfv_tbl.COUNT > 0) THEN
      i := p_pdfv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pdfv_rec                     => p_pdfv_tbl(i));
        EXIT WHEN (i = p_pdfv_tbl.LAST);
        i := p_pdfv_tbl.NEXT(i);
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
  -- insert_row for:OKC_PROCESS_DEFS_TL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_process_defs_tl_rec      IN okc_process_defs_tl_rec_type,
    x_okc_process_defs_tl_rec      OUT NOCOPY okc_process_defs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_process_defs_tl_rec      okc_process_defs_tl_rec_type := p_okc_process_defs_tl_rec;
    ldefokcprocessdefstlrec        okc_process_defs_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    --------------------------------------------
    -- Set_Attributes for:OKC_PROCESS_DEFS_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_process_defs_tl_rec IN  okc_process_defs_tl_rec_type,
      x_okc_process_defs_tl_rec OUT NOCOPY okc_process_defs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_process_defs_tl_rec := p_okc_process_defs_tl_rec;
      x_okc_process_defs_tl_rec.LANGUAGE := l_lang;
      x_okc_process_defs_tl_rec.SOURCE_LANG := l_lang;
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
      p_okc_process_defs_tl_rec,         -- IN
      l_okc_process_defs_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_process_defs_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_PROCESS_DEFS_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          name,
          description,
          short_description,
          comments,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okc_process_defs_tl_rec.id,
          l_okc_process_defs_tl_rec.language,
          l_okc_process_defs_tl_rec.source_lang,
          l_okc_process_defs_tl_rec.sfwt_flag,
          l_okc_process_defs_tl_rec.name,
          l_okc_process_defs_tl_rec.description,
          l_okc_process_defs_tl_rec.short_description,
          l_okc_process_defs_tl_rec.comments,
          l_okc_process_defs_tl_rec.created_by,
          l_okc_process_defs_tl_rec.creation_date,
          l_okc_process_defs_tl_rec.last_updated_by,
          l_okc_process_defs_tl_rec.last_update_date,
          l_okc_process_defs_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_process_defs_tl_rec := l_okc_process_defs_tl_rec;
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
  -- insert_row for:OKC_PROCESS_DEFS_B --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdf_rec                      IN pdf_rec_type,
    x_pdf_rec                      OUT NOCOPY pdf_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdf_rec                      pdf_rec_type := p_pdf_rec;
    l_def_pdf_rec                  pdf_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKC_PROCESS_DEFS_B --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_pdf_rec IN  pdf_rec_type,
      x_pdf_rec OUT NOCOPY pdf_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pdf_rec := p_pdf_rec;
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
      p_pdf_rec,                         -- IN
      l_pdf_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_PROCESS_DEFS_B(
        id,
        pdf_type,
        object_version_number,
        created_by,
        usage,
        creation_date,
        begin_date,
        last_updated_by,
        last_update_date,
        wf_name,
        wf_process_name,
        procedure_name,
        package_name,
        last_update_login,
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
        application_id,
        seeded_flag,
	message_name,
	script_name)
      VALUES (
        l_pdf_rec.id,
        l_pdf_rec.pdf_type,
        l_pdf_rec.object_version_number,
        l_pdf_rec.created_by,
        l_pdf_rec.usage,
        l_pdf_rec.creation_date,
        l_pdf_rec.begin_date,
        l_pdf_rec.last_updated_by,
        l_pdf_rec.last_update_date,
        l_pdf_rec.wf_name,
        l_pdf_rec.wf_process_name,
        l_pdf_rec.procedure_name,
        l_pdf_rec.package_name,
        l_pdf_rec.last_update_login,
        l_pdf_rec.end_date,
        l_pdf_rec.attribute_category,
        l_pdf_rec.attribute1,
        l_pdf_rec.attribute2,
        l_pdf_rec.attribute3,
        l_pdf_rec.attribute4,
        l_pdf_rec.attribute5,
        l_pdf_rec.attribute6,
        l_pdf_rec.attribute7,
        l_pdf_rec.attribute8,
        l_pdf_rec.attribute9,
        l_pdf_rec.attribute10,
        l_pdf_rec.attribute11,
        l_pdf_rec.attribute12,
        l_pdf_rec.attribute13,
        l_pdf_rec.attribute14,
        l_pdf_rec.attribute15,
        l_pdf_rec.application_id,
        l_pdf_rec.seeded_flag,
	l_pdf_rec.message_name,
	l_pdf_rec.script_name);
    -- Set OUT values
    x_pdf_rec := l_pdf_rec;
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
  -- insert_row for:OKC_PROCESS_DEFS_V --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_rec                     IN pdfv_rec_type,
    x_pdfv_rec                     OUT NOCOPY pdfv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdfv_rec                     pdfv_rec_type;
    l_def_pdfv_rec                 pdfv_rec_type;
    l_okc_process_defs_tl_rec      okc_process_defs_tl_rec_type;
    lx_okc_process_defs_tl_rec     okc_process_defs_tl_rec_type;
    l_pdf_rec                      pdf_rec_type;
    l_id                           NUMBER;
    lx_pdf_rec                     pdf_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pdfv_rec	IN pdfv_rec_type
    ) RETURN pdfv_rec_type IS
      l_pdfv_rec	pdfv_rec_type := p_pdfv_rec;
    BEGIN
      l_pdfv_rec.CREATION_DATE := SYSDATE;
      l_pdfv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_pdfv_rec.LAST_UPDATE_DATE := l_pdfv_rec.CREATION_DATE;
      l_pdfv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pdfv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pdfv_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKC_PROCESS_DEFS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_pdfv_rec IN  pdfv_rec_type,
      x_pdfv_rec OUT NOCOPY pdfv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pdfv_rec := p_pdfv_rec;
      x_pdfv_rec.OBJECT_VERSION_NUMBER := 1;
      x_pdfv_rec.SFWT_FLAG := 'N';
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
    l_pdfv_rec := null_out_defaults(p_pdfv_rec);
    -- Set primary key value
    -- If process definition is created by seed then use sequence generated id
    IF l_pdfv_rec.CREATED_BY = 1 THEN
	  SELECT OKC_PROCESS_DEFS_S1.nextval INTO l_id FROM dual;
       l_pdfv_rec.ID := l_id;
       l_pdfv_rec.seeded_flag := 'Y';
    ELSE
       l_pdfv_rec.ID := get_seq_id;
       l_pdfv_rec.seeded_flag := 'N';
    END IF;
    --l_pdfv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_pdfv_rec,                        -- IN
      l_def_pdfv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pdfv_rec := fill_who_columns(l_def_pdfv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pdfv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pdfv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_pdfv_rec, l_okc_process_defs_tl_rec);
    migrate(l_def_pdfv_rec, l_pdf_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_process_defs_tl_rec,
      lx_okc_process_defs_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_process_defs_tl_rec, l_def_pdfv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pdf_rec,
      lx_pdf_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pdf_rec, l_def_pdfv_rec);
    -- Set OUT values
    x_pdfv_rec := l_def_pdfv_rec;
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
  -- PL/SQL TBL insert_row for:PDFV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_tbl                     IN pdfv_tbl_type,
    x_pdfv_tbl                     OUT NOCOPY pdfv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pdfv_tbl.COUNT > 0) THEN
      i := p_pdfv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pdfv_rec                     => p_pdfv_tbl(i),
          x_pdfv_rec                     => x_pdfv_tbl(i));
        EXIT WHEN (i = p_pdfv_tbl.LAST);
        i := p_pdfv_tbl.NEXT(i);
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
  -- lock_row for:OKC_PROCESS_DEFS_TL --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_process_defs_tl_rec      IN okc_process_defs_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_process_defs_tl_rec IN okc_process_defs_tl_rec_type) IS
    SELECT *
      FROM OKC_PROCESS_DEFS_TL
     WHERE ID = p_okc_process_defs_tl_rec.id
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
      OPEN lock_csr(p_okc_process_defs_tl_rec);
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
  -------------------------------------
  -- lock_row for:OKC_PROCESS_DEFS_B --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdf_rec                      IN pdf_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_pdf_rec IN pdf_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_PROCESS_DEFS_B
     WHERE ID = p_pdf_rec.id
       AND OBJECT_VERSION_NUMBER = p_pdf_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_pdf_rec IN pdf_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_PROCESS_DEFS_B
    WHERE ID = p_pdf_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_PROCESS_DEFS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_PROCESS_DEFS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_pdf_rec);
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
      OPEN lchk_csr(p_pdf_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_pdf_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_pdf_rec.object_version_number THEN
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
  -- lock_row for:OKC_PROCESS_DEFS_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_rec                     IN pdfv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_process_defs_tl_rec      okc_process_defs_tl_rec_type;
    l_pdf_rec                      pdf_rec_type;
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
    migrate(p_pdfv_rec, l_okc_process_defs_tl_rec);
    migrate(p_pdfv_rec, l_pdf_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_process_defs_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pdf_rec
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
  -- PL/SQL TBL lock_row for:PDFV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_tbl                     IN pdfv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pdfv_tbl.COUNT > 0) THEN
      i := p_pdfv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pdfv_rec                     => p_pdfv_tbl(i));
        EXIT WHEN (i = p_pdfv_tbl.LAST);
        i := p_pdfv_tbl.NEXT(i);
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
  -- update_row for:OKC_PROCESS_DEFS_TL --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_process_defs_tl_rec      IN okc_process_defs_tl_rec_type,
    x_okc_process_defs_tl_rec      OUT NOCOPY okc_process_defs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_process_defs_tl_rec      okc_process_defs_tl_rec_type := p_okc_process_defs_tl_rec;
    ldefokcprocessdefstlrec        okc_process_defs_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_process_defs_tl_rec	IN okc_process_defs_tl_rec_type,
      x_okc_process_defs_tl_rec	OUT NOCOPY okc_process_defs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okc_process_defs_tl_rec      okc_process_defs_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_process_defs_tl_rec := p_okc_process_defs_tl_rec;
      -- Get current database values
      l_okc_process_defs_tl_rec := get_rec(p_okc_process_defs_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_process_defs_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okc_process_defs_tl_rec.id := l_okc_process_defs_tl_rec.id;
      END IF;
      IF (x_okc_process_defs_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_process_defs_tl_rec.language := l_okc_process_defs_tl_rec.language;
      END IF;
      IF (x_okc_process_defs_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_process_defs_tl_rec.source_lang := l_okc_process_defs_tl_rec.source_lang;
      END IF;
      IF (x_okc_process_defs_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_process_defs_tl_rec.sfwt_flag := l_okc_process_defs_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_process_defs_tl_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_process_defs_tl_rec.name := l_okc_process_defs_tl_rec.name;
      END IF;
      IF (x_okc_process_defs_tl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_process_defs_tl_rec.description := l_okc_process_defs_tl_rec.description;
      END IF;
      IF (x_okc_process_defs_tl_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_process_defs_tl_rec.short_description := l_okc_process_defs_tl_rec.short_description;
      END IF;
      IF (x_okc_process_defs_tl_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_process_defs_tl_rec.comments := l_okc_process_defs_tl_rec.comments;
      END IF;
      IF (x_okc_process_defs_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_process_defs_tl_rec.created_by := l_okc_process_defs_tl_rec.created_by;
      END IF;
      IF (x_okc_process_defs_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_process_defs_tl_rec.creation_date := l_okc_process_defs_tl_rec.creation_date;
      END IF;
      IF (x_okc_process_defs_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_process_defs_tl_rec.last_updated_by := l_okc_process_defs_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_process_defs_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_process_defs_tl_rec.last_update_date := l_okc_process_defs_tl_rec.last_update_date;
      END IF;
      IF (x_okc_process_defs_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_process_defs_tl_rec.last_update_login := l_okc_process_defs_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKC_PROCESS_DEFS_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_process_defs_tl_rec IN  okc_process_defs_tl_rec_type,
      x_okc_process_defs_tl_rec OUT NOCOPY okc_process_defs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_process_defs_tl_rec := p_okc_process_defs_tl_rec;
      x_okc_process_defs_tl_rec.LANGUAGE := l_lang;
      x_okc_process_defs_tl_rec.SOURCE_LANG := l_lang;
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
      p_okc_process_defs_tl_rec,         -- IN
      l_okc_process_defs_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_process_defs_tl_rec, ldefokcprocessdefstlrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_PROCESS_DEFS_TL
    SET NAME = ldefokcprocessdefstlrec.name,
        SOURCE_LANG = ldefokcprocessdefstlrec.source_lang,
        DESCRIPTION = ldefokcprocessdefstlrec.description,
        SHORT_DESCRIPTION = ldefokcprocessdefstlrec.short_description,
        COMMENTS = ldefokcprocessdefstlrec.comments,
        CREATED_BY = ldefokcprocessdefstlrec.created_by,
        CREATION_DATE = ldefokcprocessdefstlrec.creation_date,
        LAST_UPDATED_BY = ldefokcprocessdefstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokcprocessdefstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokcprocessdefstlrec.last_update_login
    WHERE ID = ldefokcprocessdefstlrec.id
      AND USERENV('LANG') IN (SOURCE_LANG, LANGUAGE);
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKC_PROCESS_DEFS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokcprocessdefstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_process_defs_tl_rec := ldefokcprocessdefstlrec;
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
  -- update_row for:OKC_PROCESS_DEFS_B --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdf_rec                      IN pdf_rec_type,
    x_pdf_rec                      OUT NOCOPY pdf_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdf_rec                      pdf_rec_type := p_pdf_rec;
    l_def_pdf_rec                  pdf_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pdf_rec	IN pdf_rec_type,
      x_pdf_rec	OUT NOCOPY pdf_rec_type
    ) RETURN VARCHAR2 IS
      l_pdf_rec                      pdf_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pdf_rec := p_pdf_rec;
      -- Get current database values
      l_pdf_rec := get_rec(p_pdf_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_pdf_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_pdf_rec.id := l_pdf_rec.id;
      END IF;
      IF (x_pdf_rec.pdf_type = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.pdf_type := l_pdf_rec.pdf_type;
      END IF;
      IF (x_pdf_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_pdf_rec.object_version_number := l_pdf_rec.object_version_number;
      END IF;
      IF (x_pdf_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_pdf_rec.created_by := l_pdf_rec.created_by;
      END IF;
      IF (x_pdf_rec.usage = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.usage := l_pdf_rec.usage;
      END IF;
      IF (x_pdf_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_pdf_rec.creation_date := l_pdf_rec.creation_date;
      END IF;
      IF (x_pdf_rec.begin_date = OKC_API.G_MISS_DATE)
      THEN
        x_pdf_rec.begin_date := l_pdf_rec.begin_date;
      END IF;
      IF (x_pdf_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_pdf_rec.last_updated_by := l_pdf_rec.last_updated_by;
      END IF;
      IF (x_pdf_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_pdf_rec.last_update_date := l_pdf_rec.last_update_date;
      END IF;
      IF (x_pdf_rec.wf_name = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.wf_name := l_pdf_rec.wf_name;
      END IF;
      IF (x_pdf_rec.wf_process_name = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.wf_process_name := l_pdf_rec.wf_process_name;
      END IF;
      IF (x_pdf_rec.procedure_name = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.procedure_name := l_pdf_rec.procedure_name;
      END IF;
      IF (x_pdf_rec.package_name = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.package_name := l_pdf_rec.package_name;
      END IF;
      IF (x_pdf_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_pdf_rec.last_update_login := l_pdf_rec.last_update_login;
      END IF;
      IF (x_pdf_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_pdf_rec.end_date := l_pdf_rec.end_date;
      END IF;
      IF (x_pdf_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.attribute_category := l_pdf_rec.attribute_category;
      END IF;
      IF (x_pdf_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.attribute1 := l_pdf_rec.attribute1;
      END IF;
      IF (x_pdf_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.attribute2 := l_pdf_rec.attribute2;
      END IF;
      IF (x_pdf_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.attribute3 := l_pdf_rec.attribute3;
      END IF;
      IF (x_pdf_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.attribute4 := l_pdf_rec.attribute4;
      END IF;
      IF (x_pdf_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.attribute5 := l_pdf_rec.attribute5;
      END IF;
      IF (x_pdf_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.attribute6 := l_pdf_rec.attribute6;
      END IF;
      IF (x_pdf_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.attribute7 := l_pdf_rec.attribute7;
      END IF;
      IF (x_pdf_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.attribute8 := l_pdf_rec.attribute8;
      END IF;
      IF (x_pdf_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.attribute9 := l_pdf_rec.attribute9;
      END IF;
      IF (x_pdf_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.attribute10 := l_pdf_rec.attribute10;
      END IF;
      IF (x_pdf_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.attribute11 := l_pdf_rec.attribute11;
      END IF;
      IF (x_pdf_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.attribute12 := l_pdf_rec.attribute12;
      END IF;
      IF (x_pdf_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.attribute13 := l_pdf_rec.attribute13;
      END IF;
      IF (x_pdf_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.attribute14 := l_pdf_rec.attribute14;
      END IF;
      IF (x_pdf_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.attribute15 := l_pdf_rec.attribute15;
      END IF;
      IF (x_pdf_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_pdf_rec.application_id := l_pdf_rec.application_id;
      END IF;
      IF (x_pdf_rec.seeded_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.seeded_flag := l_pdf_rec.seeded_flag;
      END IF;
      IF (x_pdf_rec.message_name = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.message_name := l_pdf_rec.message_name;
      END IF;
      IF (x_pdf_rec.script_name = OKC_API.G_MISS_CHAR)
      THEN
        x_pdf_rec.script_name := l_pdf_rec.script_name;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKC_PROCESS_DEFS_B --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_pdf_rec IN  pdf_rec_type,
      x_pdf_rec OUT NOCOPY pdf_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pdf_rec := p_pdf_rec;
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
      p_pdf_rec,                         -- IN
      l_pdf_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pdf_rec, l_def_pdf_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_PROCESS_DEFS_B
    SET PDF_TYPE = l_def_pdf_rec.pdf_type,
        OBJECT_VERSION_NUMBER = l_def_pdf_rec.object_version_number,
        CREATED_BY = l_def_pdf_rec.created_by,
        USAGE = l_def_pdf_rec.usage,
        CREATION_DATE = l_def_pdf_rec.creation_date,
        BEGIN_DATE = l_def_pdf_rec.begin_date,
        LAST_UPDATED_BY = l_def_pdf_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_pdf_rec.last_update_date,
        WF_NAME = l_def_pdf_rec.wf_name,
        WF_PROCESS_NAME = l_def_pdf_rec.wf_process_name,
        PROCEDURE_NAME = l_def_pdf_rec.procedure_name,
        PACKAGE_NAME = l_def_pdf_rec.package_name,
        LAST_UPDATE_LOGIN = l_def_pdf_rec.last_update_login,
        END_DATE = l_def_pdf_rec.end_date,
        ATTRIBUTE_CATEGORY = l_def_pdf_rec.attribute_category,
        ATTRIBUTE1 = l_def_pdf_rec.attribute1,
        ATTRIBUTE2 = l_def_pdf_rec.attribute2,
        ATTRIBUTE3 = l_def_pdf_rec.attribute3,
        ATTRIBUTE4 = l_def_pdf_rec.attribute4,
        ATTRIBUTE5 = l_def_pdf_rec.attribute5,
        ATTRIBUTE6 = l_def_pdf_rec.attribute6,
        ATTRIBUTE7 = l_def_pdf_rec.attribute7,
        ATTRIBUTE8 = l_def_pdf_rec.attribute8,
        ATTRIBUTE9 = l_def_pdf_rec.attribute9,
        ATTRIBUTE10 = l_def_pdf_rec.attribute10,
        ATTRIBUTE11 = l_def_pdf_rec.attribute11,
        ATTRIBUTE12 = l_def_pdf_rec.attribute12,
        ATTRIBUTE13 = l_def_pdf_rec.attribute13,
        ATTRIBUTE14 = l_def_pdf_rec.attribute14,
        ATTRIBUTE15 = l_def_pdf_rec.attribute15,
        APPLICATION_ID = l_def_pdf_rec.application_id,
        SEEDED_FLAG = l_def_pdf_rec.seeded_flag,
        MESSAGE_NAME = l_def_pdf_rec.MESSAGE_NAME,
	SCRIPT_NAME = l_def_pdf_rec.SCRIPT_NAME
    WHERE ID = l_def_pdf_rec.id;

    x_pdf_rec := l_def_pdf_rec;
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
  -- update_row for:OKC_PROCESS_DEFS_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_rec                     IN pdfv_rec_type,
    x_pdfv_rec                     OUT NOCOPY pdfv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdfv_rec                     pdfv_rec_type := p_pdfv_rec;
    l_def_pdfv_rec                 pdfv_rec_type;
    l_pdf_rec                      pdf_rec_type;
    lx_pdf_rec                     pdf_rec_type;
    l_okc_process_defs_tl_rec      okc_process_defs_tl_rec_type;
    lx_okc_process_defs_tl_rec     okc_process_defs_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pdfv_rec	IN pdfv_rec_type
    ) RETURN pdfv_rec_type IS
      l_pdfv_rec	pdfv_rec_type := p_pdfv_rec;
    BEGIN
      l_pdfv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_pdfv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pdfv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pdfv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pdfv_rec	IN pdfv_rec_type,
      x_pdfv_rec	OUT NOCOPY pdfv_rec_type
    ) RETURN VARCHAR2 IS
      l_pdfv_rec                     pdfv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pdfv_rec := p_pdfv_rec;
      -- Get current database values
      l_pdfv_rec := get_rec(p_pdfv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_pdfv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_pdfv_rec.id := l_pdfv_rec.id;
      END IF;
      IF (x_pdfv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_pdfv_rec.object_version_number := l_pdfv_rec.object_version_number;
      END IF;
      IF (x_pdfv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.sfwt_flag := l_pdfv_rec.sfwt_flag;
      END IF;
      IF (x_pdfv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.description := l_pdfv_rec.description;
      END IF;
      IF (x_pdfv_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.short_description := l_pdfv_rec.short_description;
      END IF;
      IF (x_pdfv_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.comments := l_pdfv_rec.comments;
      END IF;
      IF (x_pdfv_rec.usage = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.usage := l_pdfv_rec.usage;
      END IF;
      IF (x_pdfv_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.name := l_pdfv_rec.name;
      END IF;
      IF (x_pdfv_rec.wf_name = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.wf_name := l_pdfv_rec.wf_name;
      END IF;
      IF (x_pdfv_rec.wf_process_name = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.wf_process_name := l_pdfv_rec.wf_process_name;
      END IF;
      IF (x_pdfv_rec.procedure_name = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.procedure_name := l_pdfv_rec.procedure_name;
      END IF;
      IF (x_pdfv_rec.package_name = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.package_name := l_pdfv_rec.package_name;
      END IF;
      IF (x_pdfv_rec.pdf_type = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.pdf_type := l_pdfv_rec.pdf_type;
      END IF;
      IF (x_pdfv_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_pdfv_rec.application_id := l_pdfv_rec.application_id;
      END IF;
      IF (x_pdfv_rec.seeded_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.seeded_flag := l_pdfv_rec.seeded_flag;
      END IF;
      IF (x_pdfv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.attribute_category := l_pdfv_rec.attribute_category;
      END IF;
      IF (x_pdfv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.attribute1 := l_pdfv_rec.attribute1;
      END IF;
      IF (x_pdfv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.attribute2 := l_pdfv_rec.attribute2;
      END IF;
      IF (x_pdfv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.attribute3 := l_pdfv_rec.attribute3;
      END IF;
      IF (x_pdfv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.attribute4 := l_pdfv_rec.attribute4;
      END IF;
      IF (x_pdfv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.attribute5 := l_pdfv_rec.attribute5;
      END IF;
      IF (x_pdfv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.attribute6 := l_pdfv_rec.attribute6;
      END IF;
      IF (x_pdfv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.attribute7 := l_pdfv_rec.attribute7;
      END IF;
      IF (x_pdfv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.attribute8 := l_pdfv_rec.attribute8;
      END IF;
      IF (x_pdfv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.attribute9 := l_pdfv_rec.attribute9;
      END IF;
      IF (x_pdfv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.attribute10 := l_pdfv_rec.attribute10;
      END IF;
      IF (x_pdfv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.attribute11 := l_pdfv_rec.attribute11;
      END IF;
      IF (x_pdfv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.attribute12 := l_pdfv_rec.attribute12;
      END IF;
      IF (x_pdfv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.attribute13 := l_pdfv_rec.attribute13;
      END IF;
      IF (x_pdfv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.attribute14 := l_pdfv_rec.attribute14;
      END IF;
      IF (x_pdfv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.attribute15 := l_pdfv_rec.attribute15;
      END IF;
      IF (x_pdfv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_pdfv_rec.created_by := l_pdfv_rec.created_by;
      END IF;
      IF (x_pdfv_rec.begin_date = OKC_API.G_MISS_DATE)
      THEN
        x_pdfv_rec.begin_date := l_pdfv_rec.begin_date;
      END IF;
      IF (x_pdfv_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_pdfv_rec.end_date := l_pdfv_rec.end_date;
      END IF;
      IF (x_pdfv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_pdfv_rec.creation_date := l_pdfv_rec.creation_date;
      END IF;
      IF (x_pdfv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_pdfv_rec.last_updated_by := l_pdfv_rec.last_updated_by;
      END IF;
      IF (x_pdfv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_pdfv_rec.last_update_date := l_pdfv_rec.last_update_date;
      END IF;
      IF (x_pdfv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_pdfv_rec.last_update_login := l_pdfv_rec.last_update_login;
      END IF;
      IF (x_pdfv_rec.message_name = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.message_name := l_pdfv_rec.message_name;
      END IF;
      IF (x_pdfv_rec.script_name = OKC_API.G_MISS_CHAR)
      THEN
        x_pdfv_rec.script_name := l_pdfv_rec.script_name;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKC_PROCESS_DEFS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_pdfv_rec IN  pdfv_rec_type,
      x_pdfv_rec OUT NOCOPY pdfv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pdfv_rec := p_pdfv_rec;
      x_pdfv_rec.OBJECT_VERSION_NUMBER := NVL(x_pdfv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
    --
    --  Seed data should not be updated unless it is updated by datamerge
    --
    IF  l_pdfv_rec.last_updated_by <> 1 THEN
       IF  l_pdfv_rec.seeded_flag = 'Y' THEN

		IF x_pdfv_rec.end_date = l_pdfv_rec.end_date THEN

	      OKC_API.set_message(p_app_name => G_APP_NAME,
	          			 p_msg_name => 'OKC_NOT_DELETE_SEEDED');
           RAISE OKC_API.G_EXCEPTION_ERROR;
		 END IF;
       END IF;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_pdfv_rec,                        -- IN
      l_pdfv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pdfv_rec, l_def_pdfv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pdfv_rec := fill_who_columns(l_def_pdfv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pdfv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pdfv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_pdfv_rec, l_pdf_rec);
    migrate(l_def_pdfv_rec, l_okc_process_defs_tl_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pdf_rec,
      lx_pdf_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pdf_rec, l_def_pdfv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_process_defs_tl_rec,
      lx_okc_process_defs_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_process_defs_tl_rec, l_def_pdfv_rec);
    x_pdfv_rec := l_def_pdfv_rec;
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
  -- PL/SQL TBL update_row for:PDFV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_tbl                     IN pdfv_tbl_type,
    x_pdfv_tbl                     OUT NOCOPY pdfv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pdfv_tbl.COUNT > 0) THEN
      i := p_pdfv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pdfv_rec                     => p_pdfv_tbl(i),
          x_pdfv_rec                     => x_pdfv_tbl(i));
        EXIT WHEN (i = p_pdfv_tbl.LAST);
        i := p_pdfv_tbl.NEXT(i);
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
  -- delete_row for:OKC_PROCESS_DEFS_TL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_process_defs_tl_rec      IN okc_process_defs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_process_defs_tl_rec      okc_process_defs_tl_rec_type:= p_okc_process_defs_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    --------------------------------------------
    -- Set_Attributes for:OKC_PROCESS_DEFS_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_process_defs_tl_rec IN  okc_process_defs_tl_rec_type,
      x_okc_process_defs_tl_rec OUT NOCOPY okc_process_defs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_process_defs_tl_rec := p_okc_process_defs_tl_rec;
      x_okc_process_defs_tl_rec.LANGUAGE := l_lang;
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
      p_okc_process_defs_tl_rec,         -- IN
      l_okc_process_defs_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_PROCESS_DEFS_TL
     WHERE ID = l_okc_process_defs_tl_rec.id;

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
  -- delete_row for:OKC_PROCESS_DEFS_B --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdf_rec                      IN pdf_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdf_rec                      pdf_rec_type:= p_pdf_rec;
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
    DELETE FROM OKC_PROCESS_DEFS_B
     WHERE ID = l_pdf_rec.id;

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
  -- delete_row for:OKC_PROCESS_DEFS_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_rec                     IN pdfv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdfv_rec                     pdfv_rec_type := p_pdfv_rec;
    l_pdf_rec                      pdf_rec_type;
    l_okc_process_defs_tl_rec      okc_process_defs_tl_rec_type;
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
    --
    --  Seed data should not be deleted unless it is deleted by datamerge
    --
    IF  l_pdfv_rec.last_updated_by <> 1 THEN
       IF  l_pdfv_rec.seeded_flag = 'Y' THEN
	      OKC_API.set_message(p_app_name => G_APP_NAME,
					      p_msg_name => 'OKC_NOT_DELETE_SEEDED');
           RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_pdfv_rec, l_pdf_rec);
    migrate(l_pdfv_rec, l_okc_process_defs_tl_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pdf_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_process_defs_tl_rec
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
  -- PL/SQL TBL delete_row for:PDFV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdfv_tbl                     IN pdfv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pdfv_tbl.COUNT > 0) THEN
      i := p_pdfv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pdfv_rec                     => p_pdfv_tbl(i));
        EXIT WHEN (i = p_pdfv_tbl.LAST);
        i := p_pdfv_tbl.NEXT(i);
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
END OKC_PDF_PVT;

/
