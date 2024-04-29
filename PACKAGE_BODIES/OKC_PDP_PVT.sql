--------------------------------------------------------
--  DDL for Package Body OKC_PDP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PDP_PVT" AS
/* $Header: OKCSPDPB.pls 120.0 2005/05/25 19:39:03 appldev noship $ */

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
    DELETE FROM OKC_PROCESS_DEF_PARMS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_PROCESS_DEF_PARMS_B B
         WHERE B.ID = T.ID
        );

    UPDATE OKC_PROCESS_DEF_PARMS_TL T SET (
        NAME,
        DESCRIPTION) = (SELECT
                                  B.NAME,
                                  B.DESCRIPTION
                                FROM OKC_PROCESS_DEF_PARMS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKC_PROCESS_DEF_PARMS_TL SUBB, OKC_PROCESS_DEF_PARMS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKC_PROCESS_DEF_PARMS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        NAME,
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
            B.DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_PROCESS_DEF_PARMS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_PROCESS_DEF_PARMS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_PROCESS_DEF_PARMS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_process_def_parms_tl_rec IN OkcProcessDefParmsTlRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OkcProcessDefParmsTlRecType IS
    CURSOR okc_process_def_parm1_csr (p_id                 IN NUMBER,
                                      p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            NAME,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Process_Def_Parms_Tl
     WHERE okc_process_def_parms_tl.id = p_id
       AND okc_process_def_parms_tl.language = p_language;
    l_okc_process_def_parms_tl_pk  okc_process_def_parm1_csr%ROWTYPE;
    l_okc_process_def_parms_tl_rec OkcProcessDefParmsTlRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_process_def_parm1_csr (p_okc_process_def_parms_tl_rec.id,
                                    p_okc_process_def_parms_tl_rec.language);
    FETCH okc_process_def_parm1_csr INTO
              l_okc_process_def_parms_tl_rec.ID,
              l_okc_process_def_parms_tl_rec.LANGUAGE,
              l_okc_process_def_parms_tl_rec.SOURCE_LANG,
              l_okc_process_def_parms_tl_rec.SFWT_FLAG,
              l_okc_process_def_parms_tl_rec.NAME,
              l_okc_process_def_parms_tl_rec.DESCRIPTION,
              l_okc_process_def_parms_tl_rec.CREATED_BY,
              l_okc_process_def_parms_tl_rec.CREATION_DATE,
              l_okc_process_def_parms_tl_rec.LAST_UPDATED_BY,
              l_okc_process_def_parms_tl_rec.LAST_UPDATE_DATE,
              l_okc_process_def_parms_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_process_def_parm1_csr%NOTFOUND;
    CLOSE okc_process_def_parm1_csr;
    RETURN(l_okc_process_def_parms_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okc_process_def_parms_tl_rec IN OkcProcessDefParmsTlRecType
  ) RETURN OkcProcessDefParmsTlRecType IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_process_def_parms_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_PROCESS_DEF_PARMS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pdp_rec                      IN pdp_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pdp_rec_type IS
    CURSOR okc_process_def_parms_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            PDF_ID,
            NAME,
            DATA_TYPE,
            REQUIRED_YN,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            DEFAULT_VALUE,
            LAST_UPDATE_LOGIN,
            APPLICATION_ID,
            SEEDED_FLAG,
            JTOT_OBJECT_CODE,
            NAME_COLUMN,
            DESCRIPTION_COLUMN
      FROM Okc_Process_Def_Parms_B
     WHERE okc_process_def_parms_b.id = p_id;
    l_okc_process_def_parms_b_pk   okc_process_def_parms_b_pk_csr%ROWTYPE;
    l_pdp_rec                      pdp_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_process_def_parms_b_pk_csr (p_pdp_rec.id);
    FETCH okc_process_def_parms_b_pk_csr INTO
              l_pdp_rec.ID,
              l_pdp_rec.PDF_ID,
              l_pdp_rec.NAME,
              l_pdp_rec.DATA_TYPE,
              l_pdp_rec.REQUIRED_YN,
              l_pdp_rec.OBJECT_VERSION_NUMBER,
              l_pdp_rec.CREATED_BY,
              l_pdp_rec.CREATION_DATE,
              l_pdp_rec.LAST_UPDATED_BY,
              l_pdp_rec.LAST_UPDATE_DATE,
              l_pdp_rec.DEFAULT_VALUE,
              l_pdp_rec.LAST_UPDATE_LOGIN,
              l_pdp_rec.APPLICATION_ID,
              l_pdp_rec.SEEDED_FLAG,
              l_pdp_rec.JTOT_OBJECT_CODE,
              l_pdp_rec.NAME_COLUMN,
              l_pdp_rec.DESCRIPTION_COLUMN;
    x_no_data_found := okc_process_def_parms_b_pk_csr%NOTFOUND;
    CLOSE okc_process_def_parms_b_pk_csr;
    RETURN(l_pdp_rec);
  END get_rec;

  FUNCTION get_rec (
    p_pdp_rec                      IN pdp_rec_type
  ) RETURN pdp_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pdp_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_PROCESS_DEF_PARAMETERS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pdpv_rec                     IN pdpv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pdpv_rec_type IS
    CURSOR okc_pdpv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            PDF_ID,
            NAME,
            USER_NAME,
            DATA_TYPE,
            DEFAULT_VALUE,
            REQUIRED_YN,
            DESCRIPTION,
            APPLICATION_ID,
            SEEDED_FLAG,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            JTOT_OBJECT_CODE,
            NAME_COLUMN,
            DESCRIPTION_COLUMN
      FROM Okc_Process_Def_Parameters_V
     WHERE okc_process_def_parameters_v.id = p_id;
    l_okc_pdpv_pk                  okc_pdpv_pk_csr%ROWTYPE;
    l_pdpv_rec                     pdpv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_pdpv_pk_csr (p_pdpv_rec.id);
    FETCH okc_pdpv_pk_csr INTO
              l_pdpv_rec.ID,
              l_pdpv_rec.OBJECT_VERSION_NUMBER,
              l_pdpv_rec.SFWT_FLAG,
              l_pdpv_rec.PDF_ID,
              l_pdpv_rec.NAME,
              l_pdpv_rec.USER_NAME,
              l_pdpv_rec.DATA_TYPE,
              l_pdpv_rec.DEFAULT_VALUE,
              l_pdpv_rec.REQUIRED_YN,
              l_pdpv_rec.DESCRIPTION,
              l_pdpv_rec.APPLICATION_ID,
              l_pdpv_rec.SEEDED_FLAG,
              l_pdpv_rec.CREATED_BY,
              l_pdpv_rec.CREATION_DATE,
              l_pdpv_rec.LAST_UPDATED_BY,
              l_pdpv_rec.LAST_UPDATE_DATE,
              l_pdpv_rec.LAST_UPDATE_LOGIN,
              l_pdpv_rec.JTOT_OBJECT_CODE,
              l_pdpv_rec.NAME_COLUMN,
              l_pdpv_rec.DESCRIPTION_COLUMN;
    x_no_data_found := okc_pdpv_pk_csr%NOTFOUND;
    CLOSE okc_pdpv_pk_csr;
    RETURN(l_pdpv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_pdpv_rec                     IN pdpv_rec_type
  ) RETURN pdpv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pdpv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_PROCESS_DEF_PARAMETERS_V --
  ------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_pdpv_rec	IN pdpv_rec_type
  ) RETURN pdpv_rec_type IS
    l_pdpv_rec	pdpv_rec_type := p_pdpv_rec;
  BEGIN
    IF (l_pdpv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_pdpv_rec.object_version_number := NULL;
    END IF;
    IF (l_pdpv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_pdpv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_pdpv_rec.pdf_id = OKC_API.G_MISS_NUM) THEN
      l_pdpv_rec.pdf_id := NULL;
    END IF;
    IF (l_pdpv_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_pdpv_rec.name := NULL;
    END IF;
    IF (l_pdpv_rec.user_name = OKC_API.G_MISS_CHAR) THEN
      l_pdpv_rec.user_name := NULL;
    END IF;
    IF (l_pdpv_rec.data_type = OKC_API.G_MISS_CHAR) THEN
      l_pdpv_rec.data_type := NULL;
    END IF;
    IF (l_pdpv_rec.default_value = OKC_API.G_MISS_CHAR) THEN
      l_pdpv_rec.default_value := NULL;
    END IF;
    IF (l_pdpv_rec.required_yn = OKC_API.G_MISS_CHAR) THEN
      l_pdpv_rec.required_yn := NULL;
    END IF;
    IF (l_pdpv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_pdpv_rec.description := NULL;
    END IF;
    IF (l_pdpv_rec.application_id = OKC_API.G_MISS_NUM) THEN
      l_pdpv_rec.application_id := NULL;
    END IF;
    IF (l_pdpv_rec.seeded_flag = OKC_API.G_MISS_CHAR) THEN
      l_pdpv_rec.seeded_flag := NULL;
    END IF;
    IF (l_pdpv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_pdpv_rec.created_by := NULL;
    END IF;
    IF (l_pdpv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_pdpv_rec.creation_date := NULL;
    END IF;
    IF (l_pdpv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_pdpv_rec.last_updated_by := NULL;
    END IF;
    IF (l_pdpv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_pdpv_rec.last_update_date := NULL;
    END IF;
    IF (l_pdpv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_pdpv_rec.last_update_login := NULL;
    END IF;
    IF (l_pdpv_rec.jtot_object_code = OKC_API.G_MISS_CHAR) THEN
      l_pdpv_rec.jtot_object_code := NULL;
    END IF;
    IF (l_pdpv_rec.NAME_COLUMN = OKC_API.G_MISS_CHAR) THEN
      l_pdpv_rec.NAME_COLUMN := NULL;
    END IF;
    IF (l_pdpv_rec.description_column = OKC_API.G_MISS_CHAR) THEN
      l_pdpv_rec.description_column := NULL;
    END IF;
    RETURN(l_pdpv_rec);
  END null_out_defaults;

  /******* Commented out nocopy generated code in favor of hand written code ******
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------------------
  -- Validate_Attributes for:OKC_PROCESS_DEF_PARAMETERS_V --
  ----------------------------------------------------------
  FUNCTION Validate_Attributes (
    p_pdpv_rec IN  pdpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_pdpv_rec.id = OKC_API.G_MISS_NUM OR
       p_pdpv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pdpv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_pdpv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pdpv_rec.pdf_id = OKC_API.G_MISS_NUM OR
          p_pdpv_rec.pdf_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pdf_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pdpv_rec.name = OKC_API.G_MISS_CHAR OR
          p_pdpv_rec.name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pdpv_rec.user_name = OKC_API.G_MISS_CHAR OR
          p_pdpv_rec.user_name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'user_name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pdpv_rec.data_type = OKC_API.G_MISS_CHAR OR
          p_pdpv_rec.data_type IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'data_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pdpv_rec.required_yn = OKC_API.G_MISS_CHAR OR
          p_pdpv_rec.required_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'required_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------------------
  -- Validate_Record for:OKC_PROCESS_DEF_PARAMETERS_V --
  ------------------------------------------------------
  FUNCTION Validate_Record (
    p_pdpv_rec IN pdpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_pdpv_rec IN pdpv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_pdfv_pk_csr (p_id                 IN NUMBER) IS
      SELECT 'x'
       FROM Okc_Process_Defs_V
       WHERE okc_process_defs_v.id = p_id;
      l_okc_pdfv_pk                  okc_pdfv_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_pdpv_rec.PDF_ID IS NOT NULL)
      THEN
        OPEN okc_pdfv_pk_csr(p_pdpv_rec.PDF_ID);
        FETCH okc_pdfv_pk_csr INTO l_okc_pdfv_pk;
        l_row_notfound := okc_pdfv_pk_csr%NOTFOUND;
        CLOSE okc_pdfv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PDF_ID');
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
    l_return_status := validate_foreign_keys (p_pdpv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ************************ End Commented out nocopy Generated Code ****************/

  /*********** Hand Written Code *******************************************/
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------------------
  -- Validate_Attributes for:OKC_PROCESS_DEF_PARAMETERS_V --
  ----------------------------------------------------------
   -- Start of comments
  -- Procedure Name  : validate_object_version_number
  -- Description     : Check if object version number is null
  -- Version         : 1.0
  -- End of comments

   PROCEDURE validate_object_version_number(
    	x_return_status 	OUT NOCOPY VARCHAR2,
        p_pdpv_rec              IN pdpv_rec_type) IS

   BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Check if the data is null
	IF p_pdpv_rec.object_version_number = OKC_API.G_MISS_NUM OR
		p_pdpv_rec.object_version_number IS NULL THEN
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
  -- Procedure Name  : validate_pdf_id
  -- Description     : Check if pdf id is null
  -- Version         : 1.0
  -- End of comments

   PROCEDURE validate_pdf_id(
    	x_return_status 	OUT NOCOPY VARCHAR2,
        p_pdpv_rec              IN pdpv_rec_type) IS

      CURSOR okc_pdfv_pk_csr IS
      SELECT '1'
      FROM Okc_Process_Defs_V
      WHERE okc_process_defs_v.id = p_pdpv_rec.pdf_id;

      l_dummy     VARCHAR2(1) := '?';

   BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Check if pdf_id is null
	IF p_pdpv_rec.pdf_id = OKC_API.G_MISS_NUM OR
		p_pdpv_rec.pdf_id IS NULL THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'pdf_id');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	-- Enforce foreign key
        OPEN okc_pdfv_pk_csr;
        FETCH okc_pdfv_pk_csr INTO l_dummy;
	CLOSE okc_pdfv_pk_csr;

	-- If l_dummy is still set to default, data was not found
        IF (l_dummy = '?') THEN
                OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_no_parent_record,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'pdf_id',
                        	    p_token2       => g_child_table_token,
                        	    p_token2_value => 'OKC_PROCESS_DEF_PARAMETERS_V',
                        	    p_token3       => g_parent_table_token,
                        	    p_token3_value => 'OKC_PROCESS_DEFS_V');

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

    END validate_pdf_id;

   -- Start of comments
   -- Procedure Name  : validate_name
   -- Description     : Checks for valid length, Uniqueness and upper case for column NAME
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_name(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdpv_rec              IN pdpv_rec_type) IS

        pdf_usage varchar2(60);
        pdf_type varchar2(30);

        CURSOR k1_csr is
          SELECT pdf.USAGE , pdf.pdf_type from okc_process_defs_v pdf
          where pdf.id = p_pdpv_rec.pdf_id ;

        k1_rec      k1_csr%ROWTYPE;

    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Checks if name is null
	IF p_pdpv_rec.name = OKC_API.G_MISS_CHAR OR
            	p_pdpv_rec.name IS NULL THEN
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_required_value,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'name');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	--Check if the data is in upper case
	IF p_pdpv_rec.name <> UPPER(p_pdpv_rec.name) THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           	    p_msg_name     => g_uppercase_required,
                           	    p_token1       => g_col_name_token,
                           	    p_token1_value => 'name');

		x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

       --- Check for duplicate standard parameters

             FOR k1_rec in k1_csr() LOOP
               pdf_usage := k1_rec.usage;
               pdf_type := k1_rec.pdf_type;
             END LOOP;

             IF UPPER(pdf_usage) IN ('OUTCOME') THEN
               IF UPPER(pdf_type) IN ('PPS') THEN
                 IF p_pdpv_rec.name IN ('P_INIT_MSG_LIST', 'X_MSG_DATA', 'X_MSG_COUNT', 'X_RETURN_STATUS') THEN
                   OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => 'PROCESS_DEF_PARMS_INVALID',
                            p_token1       => 'PARAM_NAME',
                            p_token1_value => p_pdpv_rec.name);
                   x_return_status := OKC_API.G_RET_STS_ERROR;
                   raise G_EXCEPTION_HALT_VALIDATION;
                 END IF;
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
    END validate_name;


   -- Start of comments
   -- Procedure Name  : validate_user_name
   -- Description     : Checks for valid length, Uniqueness and upper case for column USER_NAME
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_user_name(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdpv_rec              IN pdpv_rec_type) IS

    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Checks if user_name is null
	IF p_pdpv_rec.user_name = OKC_API.G_MISS_CHAR OR
            	p_pdpv_rec.user_name IS NULL THEN
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_required_value,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'user_name');
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
    END validate_user_name;


   -- Start of comments
   -- Procedure Name  : validate_data_type
   -- Description     : Checks for valid data type and uppercase
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_data_type(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdpv_rec              IN pdpv_rec_type) IS
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Check if data_type is null
	IF p_pdpv_rec.data_type = OKC_API.G_MISS_CHAR OR
            	p_pdpv_rec.data_type IS NULL THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            	    p_msg_name     => g_required_value,
                            	    p_token1       => g_col_name_token,
                            	    p_token1_value => 'data_type');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	-- Check for valid Data type
		IF (p_pdpv_rec.data_type NOT IN ('CHAR', 'NUMBER', 'DATE')) THEN
			OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           	            p_msg_name     => g_invalid_value,
                           	    	    p_token1       => g_col_name_token,
                           	    	    p_token1_value => 'data_type');
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise G_EXCEPTION_HALT_VALIDATION;
		END IF;

	--Check if the data is in upper case
	IF p_pdpv_rec.data_type <> UPPER(p_pdpv_rec.data_type) THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           	    p_msg_name     => g_uppercase_required,
                           	    p_token1       => g_col_name_token,
                           	    p_token1_value => 'data_type');
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
    END validate_data_type;

    -- Start of comments
   -- Procedure Name  : validate_required_yn
   -- Description     : Checks for valid data type and uppercase
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_required_yn(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdpv_rec              IN pdpv_rec_type) IS
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Check if data_type is null
	IF p_pdpv_rec.required_yn = OKC_API.G_MISS_CHAR OR
            	p_pdpv_rec.required_yn IS NULL THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            	    p_msg_name     => g_required_value,
                            	    p_token1       => g_col_name_token,
                            	    p_token1_value => 'required_yn');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	-- Check for valid required_yn
		IF (p_pdpv_rec.required_yn NOT IN ('Y', 'N')) THEN
			OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           	            p_msg_name     => g_invalid_value,
                           	    	    p_token1       => g_col_name_token,
                           	    	    p_token1_value => 'required_yn');
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise G_EXCEPTION_HALT_VALIDATION;
		END IF;

	--Check if the data is in upper case
	IF p_pdpv_rec.required_yn <> UPPER(p_pdpv_rec.required_yn) THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           	    p_msg_name     => g_uppercase_required,
                           	    p_token1       => g_col_name_token,
                           	    p_token1_value => 'required_yn');
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
    END validate_required_yn;

   -- Start of comments
   -- Procedure Name  : validate_sfwt_flag
   -- Description     : Checks if sfwt_flag is Y or N
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_sfwt_flag(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdpv_rec              IN pdpv_rec_type) IS

    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Check for valid sfwt_flag
		IF (p_pdpv_rec.sfwt_flag NOT IN ('Y', 'N')) THEN
			OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           	    	    p_msg_name     => g_invalid_value,
                           	    	    p_token1       => g_col_name_token,
                           	    	    p_token1_value => 'sfwt_flag');
			x_return_status := OKC_API.G_RET_STS_ERROR;
			RAISE G_EXCEPTION_HALT_VALIDATION;
		END IF;

	--Check if the data is in upper case
	IF p_pdpv_rec.sfwt_flag <> UPPER(p_pdpv_rec.sfwt_flag) THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           	    p_msg_name     => g_uppercase_required,
                           	    p_token1       => g_col_name_token,
                           	    p_token1_value => 'sfwt_flag');
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
    END validate_sfwt_flag;

   -- Start of comments
   -- Procedure Name  : validate_seeded_flag
   -- Description     : Checks if seeded_flag is Y or N
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_seeded_flag(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdpv_rec              IN pdpv_rec_type) IS

    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Check for valid seeded_flag
		IF (p_pdpv_rec.seeded_flag NOT IN ('Y', 'N')) THEN
			OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           	    	    p_msg_name     => g_invalid_value,
                           	    	    p_token1       => g_col_name_token,
                           	    	    p_token1_value => 'seeded_flag');
			x_return_status := OKC_API.G_RET_STS_ERROR;
			RAISE G_EXCEPTION_HALT_VALIDATION;
		END IF;

	--Check if the data is in upper case
	IF p_pdpv_rec.seeded_flag <> UPPER(p_pdpv_rec.seeded_flag) THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           	    p_msg_name     => g_uppercase_required,
                           	    p_token1       => g_col_name_token,
                           	    p_token1_value => 'seeded_flag');
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
    END validate_seeded_flag;

   -- Start of comments
   -- Procedure Name  : validate_application_id
   -- Description     : Checks if application_id exists in fnd_application
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_application_id(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_pdpv_rec              IN pdpv_rec_type) IS

    CURSOR application_id_cur(p_application_id IN NUMBER) IS
    SELECT '1'
    FROM fnd_application
    WHERE application_id = p_application_id;
    l_dummy    VARCHAR2(1) := '?';

    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_pdpv_rec.application_id IS NOT NULL THEN
	-- Check if application id exists in the fnd_application or not
	OPEN application_id_cur(p_pdpv_rec.application_id);
	FETCH application_id_cur INTO l_dummy;
	CLOSE application_id_cur;

	IF l_dummy = '?' THEN
			OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    	    p_msg_name     => g_invalid_value,
                       	    	    p_token1       => g_col_name_token,
                        	    	    p_token1_value => 'application_id');
			x_return_status := OKC_API.G_RET_STS_ERROR;
			RAISE G_EXCEPTION_HALT_VALIDATION;
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

    FUNCTION Validate_Attributes (
      p_pdpv_rec IN  pdpv_rec_type
    ) RETURN VARCHAR2 IS
      x_return_status   	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_return_status		VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

	validate_object_version_number(x_return_status
		   		      ,p_pdpv_rec);
      	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
		END IF;
      	END IF;

	validate_pdf_id(x_return_status
		        ,p_pdpv_rec);
      	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
		END IF;
      	END IF;

	validate_name(x_return_status
		     ,p_pdpv_rec);
      	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;

	validate_user_name(x_return_status
		          ,p_pdpv_rec);
      	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;

	validate_data_type(x_return_status
		          ,p_pdpv_rec);
      	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
		END IF;
      	END IF;

	validate_required_yn(x_return_status
		          ,p_pdpv_rec);
      	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
		END IF;
      	END IF;

	validate_sfwt_flag(x_return_status
		          ,p_pdpv_rec);
      	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
		END IF;
      	END IF;

	validate_seeded_flag(x_return_status
		          ,p_pdpv_rec);
      	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
		END IF;
      	END IF;

	validate_application_id(x_return_status
		                  ,p_pdpv_rec);
      	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
    	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
    		l_return_status := x_return_status;
    		RAISE G_EXCEPTION_HALT_VALIDATION;
     	ELSE
    		l_return_status := x_return_status;   -- record that there was an error
	END IF;
    	END IF;

	RETURN(l_return_status);
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
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
		RETURN(l_return_status);
    END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------------------
  -- Validate_Record for:OKC_PROCESS_DEF_PARAMETERS_V --
  ------------------------------------------------------
   FUNCTION Validate_Record (
    p_pdpv_rec IN pdpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy             Varchar2(1);
    l_row_found         Boolean;
    cursor c1 is
    SELECT 'x'
      FROM okc_process_def_parameters_v
     WHERE name = p_pdpv_rec.name
       AND pdf_id = p_pdpv_rec.pdf_id
       AND id <> p_pdpv_rec.id;
        -- OR p_pdfv_rec.id is null)
  BEGIN
    Open c1;
    Fetch c1 Into l_Dummy;
    l_row_found := c1%Found;
    Close c1;
    If l_row_found Then
      OKC_API.set_message(G_APP_NAME, 'OKC_DUPLICATE_PARMS_NAME');
      l_Return_status := OKC_API.G_RET_STS_ERROR;
    End If;
    RETURN(l_return_status);
  EXCEPTION
    When Others Then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);
      --  notify caller of an UNEXPECTED error
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Record;

  /**************** End Hand Written Code **********************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN pdpv_rec_type,
    p_to	OUT NOCOPY OkcProcessDefParmsTlRecType
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.user_name;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN OkcProcessDefParmsTlRecType,
    p_to	IN OUT NOCOPY pdpv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.user_name := p_from.name;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN pdpv_rec_type,
    p_to	OUT NOCOPY pdp_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.pdf_id := p_from.pdf_id;
    p_to.name := p_from.name;
    p_to.data_type := p_from.data_type;
    p_to.required_yn := p_from.required_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.default_value := p_from.default_value;
    p_to.last_update_login := p_from.last_update_login;
    p_to.application_id := p_from.application_id;
    p_to.seeded_flag := p_from.seeded_flag;
    p_to.jtot_object_code := p_from.jtot_object_code;
    p_to.NAME_COLUMN := p_from.NAME_COLUMN;
    p_to.description_column := p_from.description_column;
  END migrate;
  PROCEDURE migrate (
    p_from	IN pdp_rec_type,
    p_to	IN OUT NOCOPY pdpv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.pdf_id := p_from.pdf_id;
    p_to.name := p_from.name;
    p_to.data_type := p_from.data_type;
    p_to.required_yn := p_from.required_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.default_value := p_from.default_value;
    p_to.last_update_login := p_from.last_update_login;
    p_to.application_id := p_from.application_id;
    p_to.seeded_flag := p_from.seeded_flag;
    p_to.jtot_object_code := p_from.jtot_object_code;
    p_to.NAME_COLUMN := p_from.NAME_COLUMN;
    p_to.description_column := p_from.description_column;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- validate_row for:OKC_PROCESS_DEF_PARAMETERS_V --
  ---------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_rec                     IN pdpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdpv_rec                     pdpv_rec_type := p_pdpv_rec;
    l_okc_process_def_parms_tl_rec OkcProcessDefParmsTlRecType;
    l_pdp_rec                      pdp_rec_type;
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
    l_return_status := Validate_Attributes(l_pdpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_pdpv_rec);
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
  -- PL/SQL TBL validate_row for:PDPV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_tbl                     IN pdpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pdpv_tbl.COUNT > 0) THEN
      i := p_pdpv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pdpv_rec                     => p_pdpv_tbl(i));
        EXIT WHEN (i = p_pdpv_tbl.LAST);
        i := p_pdpv_tbl.NEXT(i);
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
  ---------------------------------------------
  -- insert_row for:OKC_PROCESS_DEF_PARMS_TL --
  ---------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_process_def_parms_tl_rec  IN OkcProcessDefParmsTlRecType,
    x_okc_process_def_parms_tl_rec  OUT NOCOPY OkcProcessDefParmsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_process_def_parms_tl_rec OkcProcessDefParmsTlRecType := p_okc_process_def_parms_tl_rec;
    ldefokcprocessdefparmstlrec    OkcProcessDefParmsTlRecType;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -------------------------------------------------
    -- Set_Attributes for:OKC_PROCESS_DEF_PARMS_TL --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_process_def_parms_tl_rec IN  OkcProcessDefParmsTlRecType,
      x_okc_process_def_parms_tl_rec OUT NOCOPY OkcProcessDefParmsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_process_def_parms_tl_rec := p_okc_process_def_parms_tl_rec;
      x_okc_process_def_parms_tl_rec.LANGUAGE := l_lang;
      x_okc_process_def_parms_tl_rec.SOURCE_LANG := l_lang;
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
      p_okc_process_def_parms_tl_rec,    -- IN
      l_okc_process_def_parms_tl_rec);   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_process_def_parms_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_PROCESS_DEF_PARMS_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          name,
          description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okc_process_def_parms_tl_rec.id,
          l_okc_process_def_parms_tl_rec.language,
          l_okc_process_def_parms_tl_rec.source_lang,
          l_okc_process_def_parms_tl_rec.sfwt_flag,
          l_okc_process_def_parms_tl_rec.name,
          l_okc_process_def_parms_tl_rec.description,
          l_okc_process_def_parms_tl_rec.created_by,
          l_okc_process_def_parms_tl_rec.creation_date,
          l_okc_process_def_parms_tl_rec.last_updated_by,
          l_okc_process_def_parms_tl_rec.last_update_date,
          l_okc_process_def_parms_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_process_def_parms_tl_rec := l_okc_process_def_parms_tl_rec;
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
  --------------------------------------------
  -- insert_row for:OKC_PROCESS_DEF_PARMS_B --
  --------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdp_rec                      IN pdp_rec_type,
    x_pdp_rec                      OUT NOCOPY pdp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdp_rec                      pdp_rec_type := p_pdp_rec;
    l_def_pdp_rec                  pdp_rec_type;
    ------------------------------------------------
    -- Set_Attributes for:OKC_PROCESS_DEF_PARMS_B --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_pdp_rec IN  pdp_rec_type,
      x_pdp_rec OUT NOCOPY pdp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pdp_rec := p_pdp_rec;
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
      p_pdp_rec,                         -- IN
      l_pdp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_PROCESS_DEF_PARMS_B(
        id,
        pdf_id,
        name,
        data_type,
        required_yn,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        default_value,
        last_update_login,
        application_id,
        seeded_flag,
        jtot_object_code,
        NAME_COLUMN,
        description_column)
      VALUES (
        l_pdp_rec.id,
        l_pdp_rec.pdf_id,
        l_pdp_rec.name,
        l_pdp_rec.data_type,
        l_pdp_rec.required_yn,
        l_pdp_rec.object_version_number,
        l_pdp_rec.created_by,
        l_pdp_rec.creation_date,
        l_pdp_rec.last_updated_by,
        l_pdp_rec.last_update_date,
        l_pdp_rec.default_value,
        l_pdp_rec.last_update_login,
        l_pdp_rec.application_id,
        l_pdp_rec.seeded_flag,
        l_pdp_rec.jtot_object_code,
        l_pdp_rec.NAME_COLUMN,
        l_pdp_rec.description_column);
    -- Set OUT values
    x_pdp_rec := l_pdp_rec;
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
  -------------------------------------------------
  -- insert_row for:OKC_PROCESS_DEF_PARAMETERS_V --
  -------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_rec                     IN pdpv_rec_type,
    x_pdpv_rec                     OUT NOCOPY pdpv_rec_type) IS

    l_id                           NUMBER;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdpv_rec                     pdpv_rec_type;
    l_def_pdpv_rec                 pdpv_rec_type;
    l_okc_process_def_parms_tl_rec OkcProcessDefParmsTlRecType;
    LxOkcProcessDefParmsTlRec      OkcProcessDefParmsTlRecType;
    l_pdp_rec                      pdp_rec_type;
    lx_pdp_rec                     pdp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pdpv_rec	IN pdpv_rec_type
    ) RETURN pdpv_rec_type IS
      l_pdpv_rec	pdpv_rec_type := p_pdpv_rec;
    BEGIN
      l_pdpv_rec.CREATION_DATE := SYSDATE;
      l_pdpv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_pdpv_rec.LAST_UPDATE_DATE := l_pdpv_rec.CREATION_DATE;
      l_pdpv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pdpv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pdpv_rec);
    END fill_who_columns;
    -----------------------------------------------------
    -- Set_Attributes for:OKC_PROCESS_DEF_PARAMETERS_V --
    -----------------------------------------------------
    FUNCTION Set_Attributes (
      p_pdpv_rec IN  pdpv_rec_type,
      x_pdpv_rec OUT NOCOPY pdpv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pdpv_rec := p_pdpv_rec;
      x_pdpv_rec.OBJECT_VERSION_NUMBER := 1;
      x_pdpv_rec.SFWT_FLAG := 'N';
      x_pdpv_rec.user_name := p_pdpv_rec.name;
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
    l_pdpv_rec := null_out_defaults(p_pdpv_rec);
    -- Set primary key value
    -- If parameters are created by seed the use sequence generated id
    IF l_pdpv_rec.CREATED_BY = 1 THEN
	  SELECT OKC_PROCESS_DEF_PARMS_S1.nextval INTO l_id FROM dual;
	  l_pdpv_rec.ID := l_id;
	  l_pdpv_rec.seeded_flag := 'Y';
    ELSE
	  l_pdpv_rec.ID := get_seq_id;
	  l_pdpv_rec.seeded_flag := 'N';
    END IF;
    --l_pdpv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_pdpv_rec,                        -- IN
      l_def_pdpv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pdpv_rec := fill_who_columns(l_def_pdpv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pdpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pdpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_pdpv_rec, l_okc_process_def_parms_tl_rec);
    migrate(l_def_pdpv_rec, l_pdp_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_process_def_parms_tl_rec,
      LxOkcProcessDefParmsTlRec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(LxOkcProcessDefParmsTlRec, l_def_pdpv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pdp_rec,
      lx_pdp_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pdp_rec, l_def_pdpv_rec);
    -- Set OUT values
    x_pdpv_rec := l_def_pdpv_rec;
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
  -- PL/SQL TBL insert_row for:PDPV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_tbl                     IN pdpv_tbl_type,
    x_pdpv_tbl                     OUT NOCOPY pdpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pdpv_tbl.COUNT > 0) THEN
      i := p_pdpv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pdpv_rec                     => p_pdpv_tbl(i),
          x_pdpv_rec                     => x_pdpv_tbl(i));
        EXIT WHEN (i = p_pdpv_tbl.LAST);
        i := p_pdpv_tbl.NEXT(i);
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
  -------------------------------------------
  -- lock_row for:OKC_PROCESS_DEF_PARMS_TL --
  -------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_process_def_parms_tl_rec  IN OkcProcessDefParmsTlRecType) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_process_def_parms_tl_rec IN OkcProcessDefParmsTlRecType) IS
    SELECT *
      FROM OKC_PROCESS_DEF_PARMS_TL
     WHERE ID = p_okc_process_def_parms_tl_rec.id
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
      OPEN lock_csr(p_okc_process_def_parms_tl_rec);
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
  ------------------------------------------
  -- lock_row for:OKC_PROCESS_DEF_PARMS_B --
  ------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdp_rec                      IN pdp_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_pdp_rec IN pdp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_PROCESS_DEF_PARMS_B
     WHERE ID = p_pdp_rec.id
       AND OBJECT_VERSION_NUMBER = p_pdp_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_pdp_rec IN pdp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_PROCESS_DEF_PARMS_B
    WHERE ID = p_pdp_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_PROCESS_DEF_PARMS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_PROCESS_DEF_PARMS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_pdp_rec);
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
      OPEN lchk_csr(p_pdp_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_pdp_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_pdp_rec.object_version_number THEN
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
  -----------------------------------------------
  -- lock_row for:OKC_PROCESS_DEF_PARAMETERS_V --
  -----------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_rec                     IN pdpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_process_def_parms_tl_rec OkcProcessDefParmsTlRecType;
    l_pdp_rec                      pdp_rec_type;
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
    migrate(p_pdpv_rec, l_okc_process_def_parms_tl_rec);
    migrate(p_pdpv_rec, l_pdp_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_process_def_parms_tl_rec
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
      l_pdp_rec
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
  -- PL/SQL TBL lock_row for:PDPV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_tbl                     IN pdpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pdpv_tbl.COUNT > 0) THEN
      i := p_pdpv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pdpv_rec                     => p_pdpv_tbl(i));
        EXIT WHEN (i = p_pdpv_tbl.LAST);
        i := p_pdpv_tbl.NEXT(i);
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
  ---------------------------------------------
  -- update_row for:OKC_PROCESS_DEF_PARMS_TL --
  ---------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_process_def_parms_tl_rec  IN OkcProcessDefParmsTlRecType,
    x_okc_process_def_parms_tl_rec  OUT NOCOPY OkcProcessDefParmsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_process_def_parms_tl_rec OkcProcessDefParmsTlRecType := p_okc_process_def_parms_tl_rec;
    ldefokcprocessdefparmstlrec    OkcProcessDefParmsTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_process_def_parms_tl_rec	IN OkcProcessDefParmsTlRecType,
      x_okc_process_def_parms_tl_rec	OUT NOCOPY OkcProcessDefParmsTlRecType
    ) RETURN VARCHAR2 IS
      l_okc_process_def_parms_tl_rec OkcProcessDefParmsTlRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_process_def_parms_tl_rec := p_okc_process_def_parms_tl_rec;
      -- Get current database values
      l_okc_process_def_parms_tl_rec := get_rec(p_okc_process_def_parms_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_process_def_parms_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okc_process_def_parms_tl_rec.id := l_okc_process_def_parms_tl_rec.id;
      END IF;
      IF (x_okc_process_def_parms_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_process_def_parms_tl_rec.language := l_okc_process_def_parms_tl_rec.language;
      END IF;
      IF (x_okc_process_def_parms_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_process_def_parms_tl_rec.source_lang := l_okc_process_def_parms_tl_rec.source_lang;
      END IF;
      IF (x_okc_process_def_parms_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_process_def_parms_tl_rec.sfwt_flag := l_okc_process_def_parms_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_process_def_parms_tl_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_process_def_parms_tl_rec.name := l_okc_process_def_parms_tl_rec.name;
      END IF;
      IF (x_okc_process_def_parms_tl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_process_def_parms_tl_rec.description := l_okc_process_def_parms_tl_rec.description;
      END IF;
      IF (x_okc_process_def_parms_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_process_def_parms_tl_rec.created_by := l_okc_process_def_parms_tl_rec.created_by;
      END IF;
      IF (x_okc_process_def_parms_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_process_def_parms_tl_rec.creation_date := l_okc_process_def_parms_tl_rec.creation_date;
      END IF;
      IF (x_okc_process_def_parms_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_process_def_parms_tl_rec.last_updated_by := l_okc_process_def_parms_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_process_def_parms_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_process_def_parms_tl_rec.last_update_date := l_okc_process_def_parms_tl_rec.last_update_date;
      END IF;
      IF (x_okc_process_def_parms_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_process_def_parms_tl_rec.last_update_login := l_okc_process_def_parms_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------------
    -- Set_Attributes for:OKC_PROCESS_DEF_PARMS_TL --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_process_def_parms_tl_rec IN  OkcProcessDefParmsTlRecType,
      x_okc_process_def_parms_tl_rec OUT NOCOPY OkcProcessDefParmsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_process_def_parms_tl_rec := p_okc_process_def_parms_tl_rec;
      x_okc_process_def_parms_tl_rec.LANGUAGE := l_lang;
      x_okc_process_def_parms_tl_rec.SOURCE_LANG := l_lang;
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
      p_okc_process_def_parms_tl_rec,    -- IN
      l_okc_process_def_parms_tl_rec);   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_process_def_parms_tl_rec, ldefokcprocessdefparmstlrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_PROCESS_DEF_PARMS_TL
    SET NAME = ldefokcprocessdefparmstlrec.name,
        DESCRIPTION = ldefokcprocessdefparmstlrec.description,
        CREATED_BY = ldefokcprocessdefparmstlrec.created_by,
        CREATION_DATE = ldefokcprocessdefparmstlrec.creation_date,
        LAST_UPDATED_BY = ldefokcprocessdefparmstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokcprocessdefparmstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokcprocessdefparmstlrec.last_update_login
    WHERE ID = ldefokcprocessdefparmstlrec.id
      AND USERENV('LANG') IN (SOURCE_LANG,LANGUAGE);
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKC_PROCESS_DEF_PARMS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokcprocessdefparmstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_process_def_parms_tl_rec := ldefokcprocessdefparmstlrec;
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
  --------------------------------------------
  -- update_row for:OKC_PROCESS_DEF_PARMS_B --
  --------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdp_rec                      IN pdp_rec_type,
    x_pdp_rec                      OUT NOCOPY pdp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdp_rec                      pdp_rec_type := p_pdp_rec;
    l_def_pdp_rec                  pdp_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pdp_rec	IN pdp_rec_type,
      x_pdp_rec	OUT NOCOPY pdp_rec_type
    ) RETURN VARCHAR2 IS
      l_pdp_rec                      pdp_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pdp_rec := p_pdp_rec;
      -- Get current database values
      l_pdp_rec := get_rec(p_pdp_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_pdp_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_pdp_rec.id := l_pdp_rec.id;
      END IF;
      IF (x_pdp_rec.pdf_id = OKC_API.G_MISS_NUM)
      THEN
        x_pdp_rec.pdf_id := l_pdp_rec.pdf_id;
      END IF;
      IF (x_pdp_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_pdp_rec.name := l_pdp_rec.name;
      END IF;
      IF (x_pdp_rec.data_type = OKC_API.G_MISS_CHAR)
      THEN
        x_pdp_rec.data_type := l_pdp_rec.data_type;
      END IF;
      IF (x_pdp_rec.required_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_pdp_rec.required_yn := l_pdp_rec.required_yn;
      END IF;
      IF (x_pdp_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_pdp_rec.object_version_number := l_pdp_rec.object_version_number;
      END IF;
      IF (x_pdp_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_pdp_rec.created_by := l_pdp_rec.created_by;
      END IF;
      IF (x_pdp_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_pdp_rec.creation_date := l_pdp_rec.creation_date;
      END IF;
      IF (x_pdp_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_pdp_rec.last_updated_by := l_pdp_rec.last_updated_by;
      END IF;
      IF (x_pdp_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_pdp_rec.last_update_date := l_pdp_rec.last_update_date;
      END IF;
      IF (x_pdp_rec.default_value = OKC_API.G_MISS_CHAR)
      THEN
        x_pdp_rec.default_value := l_pdp_rec.default_value;
      END IF;
      IF (x_pdp_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_pdp_rec.last_update_login := l_pdp_rec.last_update_login;
      END IF;
      IF (x_pdp_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_pdp_rec.application_id := l_pdp_rec.application_id;
      END IF;
      IF (x_pdp_rec.seeded_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_pdp_rec.seeded_flag := l_pdp_rec.seeded_flag;
      END IF;
      IF (x_pdp_rec.jtot_object_code = OKC_API.G_MISS_CHAR)
      THEN
        x_pdp_rec.jtot_object_code := l_pdp_rec.jtot_object_code;
      END IF;
      IF (x_pdp_rec.NAME_COLUMN = OKC_API.G_MISS_CHAR)
      THEN
        x_pdp_rec.NAME_COLUMN := l_pdp_rec.NAME_COLUMN;
      END IF;
      IF (x_pdp_rec.description_column = OKC_API.G_MISS_CHAR)
      THEN
        x_pdp_rec.description_column := l_pdp_rec.description_column;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKC_PROCESS_DEF_PARMS_B --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_pdp_rec IN  pdp_rec_type,
      x_pdp_rec OUT NOCOPY pdp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pdp_rec := p_pdp_rec;
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
      p_pdp_rec,                         -- IN
      l_pdp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pdp_rec, l_def_pdp_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_PROCESS_DEF_PARMS_B
    SET PDF_ID = l_def_pdp_rec.pdf_id,
        NAME = l_def_pdp_rec.name,
        DATA_TYPE = l_def_pdp_rec.data_type,
        REQUIRED_YN = l_def_pdp_rec.required_yn,
        OBJECT_VERSION_NUMBER = l_def_pdp_rec.object_version_number,
        CREATED_BY = l_def_pdp_rec.created_by,
        CREATION_DATE = l_def_pdp_rec.creation_date,
        LAST_UPDATED_BY = l_def_pdp_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_pdp_rec.last_update_date,
        DEFAULT_VALUE = l_def_pdp_rec.default_value,
        LAST_UPDATE_LOGIN = l_def_pdp_rec.last_update_login,
        APPLICATION_ID = l_def_pdp_rec.application_id,
        SEEDED_FLAG = l_def_pdp_rec.seeded_flag,
        JTOT_OBJECT_CODE = l_def_pdp_rec.jtot_object_code,
        NAME_COLUMN = l_def_pdp_rec.NAME_COLUMN,
        DESCRIPTION_COLUMN = l_def_pdp_rec.description_column
    WHERE ID = l_def_pdp_rec.id;

    x_pdp_rec := l_def_pdp_rec;
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
  -------------------------------------------------
  -- update_row for:OKC_PROCESS_DEF_PARAMETERS_V --
  -------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_rec                     IN pdpv_rec_type,
    x_pdpv_rec                     OUT NOCOPY pdpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdpv_rec                     pdpv_rec_type := p_pdpv_rec;
    l_def_pdpv_rec                 pdpv_rec_type;
    l_pdp_rec                      pdp_rec_type;
    lx_pdp_rec                     pdp_rec_type;
    l_okc_process_def_parms_tl_rec OkcProcessDefParmsTlRecType;
    LxOkcProcessDefParmsTlRec      OkcProcessDefParmsTlRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pdpv_rec	IN pdpv_rec_type
    ) RETURN pdpv_rec_type IS
      l_pdpv_rec	pdpv_rec_type := p_pdpv_rec;
    BEGIN
      l_pdpv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_pdpv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pdpv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pdpv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pdpv_rec	IN pdpv_rec_type,
      x_pdpv_rec	OUT NOCOPY pdpv_rec_type
    ) RETURN VARCHAR2 IS
      l_pdpv_rec                     pdpv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pdpv_rec := p_pdpv_rec;
      -- Get current database values
      l_pdpv_rec := get_rec(p_pdpv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_pdpv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_pdpv_rec.id := l_pdpv_rec.id;
      END IF;
      IF (x_pdpv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_pdpv_rec.object_version_number := l_pdpv_rec.object_version_number;
      END IF;
      IF (x_pdpv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_pdpv_rec.sfwt_flag := l_pdpv_rec.sfwt_flag;
      END IF;
      IF (x_pdpv_rec.pdf_id = OKC_API.G_MISS_NUM)
      THEN
        x_pdpv_rec.pdf_id := l_pdpv_rec.pdf_id;
      END IF;
      IF (x_pdpv_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_pdpv_rec.name := l_pdpv_rec.name;
      END IF;
      IF (x_pdpv_rec.user_name = OKC_API.G_MISS_CHAR)
      THEN
        x_pdpv_rec.user_name := l_pdpv_rec.user_name;
      END IF;
      IF (x_pdpv_rec.data_type = OKC_API.G_MISS_CHAR)
      THEN
        x_pdpv_rec.data_type := l_pdpv_rec.data_type;
      END IF;
      IF (x_pdpv_rec.default_value = OKC_API.G_MISS_CHAR)
      THEN
        x_pdpv_rec.default_value := l_pdpv_rec.default_value;
      END IF;
      IF (x_pdpv_rec.required_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_pdpv_rec.required_yn := l_pdpv_rec.required_yn;
      END IF;
      IF (x_pdpv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_pdpv_rec.description := l_pdpv_rec.description;
      END IF;
      IF (x_pdpv_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_pdpv_rec.application_id := l_pdpv_rec.application_id;
      END IF;
      IF (x_pdpv_rec.seeded_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_pdpv_rec.seeded_flag := l_pdpv_rec.seeded_flag;
      END IF;
      IF (x_pdpv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_pdpv_rec.created_by := l_pdpv_rec.created_by;
      END IF;
      IF (x_pdpv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_pdpv_rec.creation_date := l_pdpv_rec.creation_date;
      END IF;
      IF (x_pdpv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_pdpv_rec.last_updated_by := l_pdpv_rec.last_updated_by;
      END IF;
      IF (x_pdpv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_pdpv_rec.last_update_date := l_pdpv_rec.last_update_date;
      END IF;
      IF (x_pdpv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_pdpv_rec.last_update_login := l_pdpv_rec.last_update_login;
      END IF;
      IF (x_pdpv_rec.jtot_object_code = OKC_API.G_MISS_CHAR)
      THEN
        x_pdpv_rec.jtot_object_code := l_pdpv_rec.jtot_object_code;
      END IF;
      IF (x_pdpv_rec.NAME_COLUMN = OKC_API.G_MISS_CHAR)
      THEN
        x_pdpv_rec.NAME_COLUMN := l_pdpv_rec.NAME_COLUMN;
      END IF;
      IF (x_pdpv_rec.description_column = OKC_API.G_MISS_CHAR)
      THEN
        x_pdpv_rec.description_column := l_pdpv_rec.description_column;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------------
    -- Set_Attributes for:OKC_PROCESS_DEF_PARAMETERS_V --
    -----------------------------------------------------
    FUNCTION Set_Attributes (
      p_pdpv_rec IN  pdpv_rec_type,
      x_pdpv_rec OUT NOCOPY pdpv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pdpv_rec := p_pdpv_rec;
      x_pdpv_rec.OBJECT_VERSION_NUMBER := NVL(x_pdpv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      x_pdpv_rec.user_name := p_pdpv_rec.name;
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
    IF l_pdpv_rec.last_updated_by <> 1 THEN
       IF l_pdpv_rec.seeded_flag = 'Y' THEN
	     OKC_API.set_message(p_app_name => G_APP_NAME,
	   				     p_msg_name => 'OKC_NOT_DELETE_SEEDED');
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_pdpv_rec,                        -- IN
      l_pdpv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pdpv_rec, l_def_pdpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pdpv_rec := fill_who_columns(l_def_pdpv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pdpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pdpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_pdpv_rec, l_pdp_rec);
    migrate(l_def_pdpv_rec, l_okc_process_def_parms_tl_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pdp_rec,
      lx_pdp_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pdp_rec, l_def_pdpv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_process_def_parms_tl_rec,
      LxOkcProcessDefParmsTlRec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(LxOkcProcessDefParmsTlRec, l_def_pdpv_rec);
    x_pdpv_rec := l_def_pdpv_rec;
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
  -- PL/SQL TBL update_row for:PDPV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_tbl                     IN pdpv_tbl_type,
    x_pdpv_tbl                     OUT NOCOPY pdpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pdpv_tbl.COUNT > 0) THEN
      i := p_pdpv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pdpv_rec                     => p_pdpv_tbl(i),
          x_pdpv_rec                     => x_pdpv_tbl(i));
        EXIT WHEN (i = p_pdpv_tbl.LAST);
        i := p_pdpv_tbl.NEXT(i);
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
  ---------------------------------------------
  -- delete_row for:OKC_PROCESS_DEF_PARMS_TL --
  ---------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_process_def_parms_tl_rec  IN OkcProcessDefParmsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_process_def_parms_tl_rec OkcProcessDefParmsTlRecType:= p_okc_process_def_parms_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -------------------------------------------------
    -- Set_Attributes for:OKC_PROCESS_DEF_PARMS_TL --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_process_def_parms_tl_rec IN  OkcProcessDefParmsTlRecType,
      x_okc_process_def_parms_tl_rec OUT NOCOPY OkcProcessDefParmsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_process_def_parms_tl_rec := p_okc_process_def_parms_tl_rec;
      x_okc_process_def_parms_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okc_process_def_parms_tl_rec,    -- IN
      l_okc_process_def_parms_tl_rec);   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_PROCESS_DEF_PARMS_TL
     WHERE ID = l_okc_process_def_parms_tl_rec.id;

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
  --------------------------------------------
  -- delete_row for:OKC_PROCESS_DEF_PARMS_B --
  --------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdp_rec                      IN pdp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdp_rec                      pdp_rec_type:= p_pdp_rec;
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
    DELETE FROM OKC_PROCESS_DEF_PARMS_B
     WHERE ID = l_pdp_rec.id;

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
  -------------------------------------------------
  -- delete_row for:OKC_PROCESS_DEF_PARAMETERS_V --
  -------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_rec                     IN pdpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdpv_rec                     pdpv_rec_type := p_pdpv_rec;
    l_pdp_rec                      pdp_rec_type;
    l_okc_process_def_parms_tl_rec OkcProcessDefParmsTlRecType;
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
    IF l_pdpv_rec.last_updated_by <> 1 THEN
       IF l_pdpv_rec.seeded_flag = 'Y' THEN
	      OKC_API.set_message(p_app_name => G_APP_NAME,
					      p_msg_name => 'OKC_NOT_DELETE_SEEDED');
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_pdpv_rec, l_pdp_rec);
    migrate(l_pdpv_rec, l_okc_process_def_parms_tl_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pdp_rec
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
      l_okc_process_def_parms_tl_rec
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
  -- PL/SQL TBL delete_row for:PDPV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_tbl                     IN pdpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pdpv_tbl.COUNT > 0) THEN
      i := p_pdpv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pdpv_rec                     => p_pdpv_tbl(i));
        EXIT WHEN (i = p_pdpv_tbl.LAST);
        i := p_pdpv_tbl.NEXT(i);
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
END OKC_PDP_PVT;

/
