--------------------------------------------------------
--  DDL for Package Body OKC_SCN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_SCN_PVT" AS
/* $Header: OKCSSCNB.pls 120.0 2005/05/25 22:50:29 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  /************************ HAND-CODED *********************************/
  FUNCTION Validate_Attributes (p_scnv_rec in scnv_rec_type) RETURN VARCHAR2;

  l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  -- Start of comments
  --
  -- Procedure Name  : validate_scn_type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_scn_type(x_return_status OUT NOCOPY   VARCHAR2,
                              p_scnv_rec      IN    scnv_rec_type) is

  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('100: Entered validate_scn_type', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_scnv_rec.scn_type = OKC_API.G_MISS_CHAR or
  	   p_scnv_rec.scn_type IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'Section Type');
	   -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- check allowed values
    If (upper(p_scnv_rec.scn_type) NOT IN ('CHR','SAT')) Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_invalid_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'Section Type');
	   -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
    End If;


 IF (l_debug = 'Y') THEN
    okc_debug.log('200: Leaving  validate_scn_type', 2);
    okc_debug.Reset_Indentation;
 END IF;

  exception
    when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('300: Exiting validate_scn_type:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('400: Exiting validate_scn_type:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  end validate_scn_type;

  -- Start of comments
  --
  -- Procedure Name  : validate_chr_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_chr_id(x_return_status OUT NOCOPY   VARCHAR2,
                        	   p_scnv_rec      IN    scnv_rec_type) is

    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_chr_csr Is
  	  select 'x'
	  from OKC_K_HEADERS_B
  	  where id = p_scnv_rec.chr_id;

  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('500: Entered validate_chr_id', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    --
    -- enforce foreign key (chr_id is logically optional
    -- mutually exclusive with SAT_CODE)
    --
    If (p_scnv_rec.scn_type = 'CHR') Then
       Open l_chr_csr;
       Fetch l_chr_csr Into l_dummy_var;
       Close l_chr_csr;
       -- if l_dummy_var still set to default, data was not found
       If (l_dummy_var = '?') Then
  	     OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
				          p_msg_name	=> g_no_parent_record,
					     p_token1		=> g_col_name_token,
					     p_token1_value	=> 'Header ID',
					     p_token2		=> g_child_table_token,
					     p_token2_value	=> 'OKC_K_HEADERS_B',
					     p_token3		=> g_parent_table_token,
					     p_token3_value	=> G_VIEW);
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Leaving  validate_chr_id', 2);
       okc_debug.Reset_Indentation;
    END IF;
  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('700: Exiting validate_chr_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_chr_csr%ISOPEN then
	      close l_chr_csr;
        end if;

  End validate_chr_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_sat_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_sat_code(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_scnv_rec      IN    scnv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_satv_csr IS
      SELECT 'x'
        FROM FND_LOOKUP_VALUES satv
       WHERE satv.LOOKUP_CODE = p_scnv_rec.sat_code
         AND satv.lookup_type = 'OKC_ARTICLE_SET';
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('800: Entered validate_sat_code', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required if scn_type = 'SAT'
    If (p_scnv_rec.scn_type = 'SAT') Then
      IF (p_scnv_rec.sat_code = OKC_API.G_MISS_CHAR OR
          p_scnv_rec.sat_code IS NULL) THEN
        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_REQUIRED_VALUE,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'rgd_code');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

        -- halt validation
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- enforce foreign key
      OPEN  l_satv_csr;
      FETCH l_satv_csr INTO l_dummy_var;
      CLOSE l_satv_csr;

      -- if l_dummy_var still set to default, data was not found
      IF (l_dummy_var = '?') THEN
         --set error message in message stack
        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_INVALID_VALUE,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'rgd_code');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('900: Leaving  validate_sat_code', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1000: Exiting validate_sat_code:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Exiting validate_sat_code:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => g_app_name,
      p_msg_name        => g_unexpected_error,
      p_token1	        => g_sqlcode_token,
      p_token1_value    => sqlcode,
      p_token2          => g_sqlerrm_token,
      p_token2_value    => sqlerrm);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_satv_csr%ISOPEN THEN
      CLOSE l_satv_csr;
    END IF;

  END validate_sat_code;

  -- Start of comments
  --
  -- Procedure Name  : validate_section_sequence
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_section_sequence(x_return_status OUT NOCOPY   VARCHAR2,
                   		             p_scnv_rec      IN    scnv_rec_type) is

  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('1200: Entered validate_section_sequence', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    If (p_scnv_rec.section_sequence = OKC_API.G_MISS_NUM or
  	   p_scnv_rec.section_sequence IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'section_sequence');
	   -- set error flag
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1300: Leaving  validate_section_sequence', 2);
       okc_debug.Reset_Indentation;
    END IF;
  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1400: Exiting validate_section_sequence:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_section_sequence;

  -- Start of comments
  --
  -- Procedure Name  : validate_sfwt_flag
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_sfwt_flag(x_return_status OUT NOCOPY   VARCHAR2,
                               p_scnv_rec      IN    scnv_rec_type) is

  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('1500: Entered validate_sfwt_flag', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_scnv_rec.sfwt_flag = OKC_API.G_MISS_CHAR or
  	   p_scnv_rec.sfwt_flag IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'sfwt_flag');
	   -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- check allowed values
    If (upper(p_scnv_rec.sfwt_flag) NOT IN ('Y','N')) Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_invalid_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'sfwt_flag');
	   -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1600: Leaving  validate_sfwt_flag', 2);
       okc_debug.Reset_Indentation;
    END IF;

  exception
    when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1700: Exiting validate_sfwt_flag:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1800: Exiting validate_sfwt_flag:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  end validate_sfwt_flag;

  -- Start of comments
  --
  -- Procedure Name  : validate_scn_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_scn_id(x_return_status OUT NOCOPY   VARCHAR2,
                   		   p_scnv_rec      IN    scnv_rec_type) is

    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_scnv_csr Is
  	  select 'x'
	  from OKC_SECTIONS_B
  	  where id = p_scnv_rec.scn_id;

  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('1900: Entered validate_scn_id', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key (scn_id is optional)
    If (p_scnv_rec.scn_id <> OKC_API.G_MISS_NUM and
  	   p_scnv_rec.scn_id IS NOT NULL)
    Then
       Open l_scnv_csr;
       Fetch l_scnv_csr Into l_dummy_var;
       Close l_scnv_csr;
       -- if l_dummy_var still set to default, data was not found
       If (l_dummy_var = '?') Then
  	     OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				          p_msg_name		=> g_no_parent_record,
					     p_token1		=> g_col_name_token,
					     p_token1_value	=> 'scn_id',
					     p_token2		=> g_child_table_token,
					     p_token2_value	=> G_VIEW,
					     p_token3		=> g_parent_table_token,
					     p_token3_value	=> G_VIEW);
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2000: Leaving  validate_scn_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2100: Exiting validate_scn_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_scnv_csr%ISOPEN then
	      close l_scnv_csr;
        end if;

  End validate_scn_id;

  /*********************** END HAND-CODED ******************************/
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN

    RETURN(okc_p_util.raw_to_number(sys_guid()));

  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('2300: Entered add_language', 2);
    END IF;

    DELETE FROM OKC_SECTIONS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_SECTIONS_B B
         WHERE B.ID = T.ID
        );

    UPDATE OKC_SECTIONS_TL T SET (
        HEADING) = (SELECT
                                  B.HEADING
                                FROM OKC_SECTIONS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKC_SECTIONS_TL SUBB, OKC_SECTIONS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.HEADING <> SUBT.HEADING
                      OR (SUBB.HEADING IS NULL AND SUBT.HEADING IS NOT NULL)
                      OR (SUBB.HEADING IS NOT NULL AND SUBT.HEADING IS NULL)
              ));

    INSERT INTO OKC_SECTIONS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        HEADING,
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
            B.HEADING,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_SECTIONS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_SECTIONS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
    DELETE FROM OKC_SECTIONS_TLH T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_SECTIONS_BH B
         WHERE B.ID = T.ID
           AND B.MAJOR_VERSION = T.MAJOR_VERSION
        );

    UPDATE OKC_SECTIONS_TLH T SET (
        HEADING) = (SELECT
                                  B.HEADING
                                FROM OKC_SECTIONS_TLH B
                               WHERE B.ID = T.ID
                                 AND B.MAJOR_VERSION = T.MAJOR_VERSION
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.MAJOR_VERSION,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.MAJOR_VERSION,
                  SUBT.LANGUAGE
                FROM OKC_SECTIONS_TLH SUBB, OKC_SECTIONS_TLH SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.MAJOR_VERSION = SUBT.MAJOR_VERSION
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.HEADING <> SUBT.HEADING
                      OR (SUBB.HEADING IS NULL AND SUBT.HEADING IS NOT NULL)
                      OR (SUBB.HEADING IS NOT NULL AND SUBT.HEADING IS NULL)
              ));

    INSERT INTO OKC_SECTIONS_TLH (
        ID,
        LANGUAGE,
        MAJOR_VERSION,
        SOURCE_LANG,
        SFWT_FLAG,
        HEADING,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.MAJOR_VERSION,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.HEADING,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_SECTIONS_TLH B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_SECTIONS_TLH T
                     WHERE T.ID = B.ID
                        AND T.MAJOR_VERSION = B.MAJOR_VERSION
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );



IF (l_debug = 'Y') THEN
   okc_debug.log('11950: Leaving  add_language ', 2);
   okc_debug.Reset_Indentation;
END IF;
  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_SECTIONS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_scn_rec                      IN scn_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN scn_rec_type IS
    CURSOR okc_sections_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SCN_TYPE,
            CHR_ID,
            SAT_CODE,
            SECTION_SEQUENCE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            LABEL,
            SCN_ID,
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
      FROM Okc_Sections_B
     WHERE okc_sections_b.id    = p_id;
    l_okc_sections_b_pk            okc_sections_b_pk_csr%ROWTYPE;
    l_scn_rec                      scn_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('2400: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_sections_b_pk_csr (p_scn_rec.id);
    FETCH okc_sections_b_pk_csr INTO
              l_scn_rec.ID,
              l_scn_rec.SCN_TYPE,
              l_scn_rec.CHR_ID,
              l_scn_rec.SAT_CODE,
              l_scn_rec.SECTION_SEQUENCE,
              l_scn_rec.OBJECT_VERSION_NUMBER,
              l_scn_rec.CREATED_BY,
              l_scn_rec.CREATION_DATE,
              l_scn_rec.LAST_UPDATED_BY,
              l_scn_rec.LAST_UPDATE_DATE,
              l_scn_rec.LAST_UPDATE_LOGIN,
              l_scn_rec.LABEL,
              l_scn_rec.SCN_ID,
              l_scn_rec.ATTRIBUTE_CATEGORY,
              l_scn_rec.ATTRIBUTE1,
              l_scn_rec.ATTRIBUTE2,
              l_scn_rec.ATTRIBUTE3,
              l_scn_rec.ATTRIBUTE4,
              l_scn_rec.ATTRIBUTE5,
              l_scn_rec.ATTRIBUTE6,
              l_scn_rec.ATTRIBUTE7,
              l_scn_rec.ATTRIBUTE8,
              l_scn_rec.ATTRIBUTE9,
              l_scn_rec.ATTRIBUTE10,
              l_scn_rec.ATTRIBUTE11,
              l_scn_rec.ATTRIBUTE12,
              l_scn_rec.ATTRIBUTE13,
              l_scn_rec.ATTRIBUTE14,
              l_scn_rec.ATTRIBUTE15;
    x_no_data_found := okc_sections_b_pk_csr%NOTFOUND;
    CLOSE okc_sections_b_pk_csr;

IF (l_debug = 'Y') THEN
   okc_debug.log('900: Leaving  Fn  Get_Rec ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_scn_rec);

  END get_rec;

  FUNCTION get_rec (
    p_scn_rec                      IN scn_rec_type
  ) RETURN scn_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_scn_rec, l_row_notfound));

  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_SECTIONS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_sections_tl_rec          IN okc_sections_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_sections_tl_rec_type IS
    CURSOR okc_sections_tl_pk_csr (p_id                 IN NUMBER,
                                   p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            HEADING,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Sections_Tl
     WHERE okc_sections_tl.id   = p_id
       AND okc_sections_tl.language = p_language;
    l_okc_sections_tl_pk           okc_sections_tl_pk_csr%ROWTYPE;
    l_okc_sections_tl_rec          okc_sections_tl_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('2600: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_sections_tl_pk_csr (p_okc_sections_tl_rec.id,
                                 p_okc_sections_tl_rec.language);
    FETCH okc_sections_tl_pk_csr INTO
              l_okc_sections_tl_rec.ID,
              l_okc_sections_tl_rec.LANGUAGE,
              l_okc_sections_tl_rec.SOURCE_LANG,
              l_okc_sections_tl_rec.SFWT_FLAG,
              l_okc_sections_tl_rec.HEADING,
              l_okc_sections_tl_rec.CREATED_BY,
              l_okc_sections_tl_rec.CREATION_DATE,
              l_okc_sections_tl_rec.LAST_UPDATED_BY,
              l_okc_sections_tl_rec.LAST_UPDATE_DATE,
              l_okc_sections_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_sections_tl_pk_csr%NOTFOUND;
    CLOSE okc_sections_tl_pk_csr;
IF (l_debug = 'Y') THEN
   okc_debug.log('900: Leaving  Fn  Get_Rec ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_okc_sections_tl_rec);

  END get_rec;

  FUNCTION get_rec (
    p_okc_sections_tl_rec          IN okc_sections_tl_rec_type
  ) RETURN okc_sections_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_okc_sections_tl_rec, l_row_notfound));

  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_SECTIONS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_scnv_rec                     IN scnv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN scnv_rec_type IS

-- TAPI generator code MISSING FROM HERE - JOHN (added)
    CURSOR okc_scnv_pk_csr (p_id IN NUMBER) IS
    SELECT
		ID,
		SCN_TYPE,
		CHR_ID,
		SAT_CODE,
		SECTION_SEQUENCE,
		LABEL,
		HEADING,
		SCN_ID,
		OBJECT_VERSION_NUMBER,
		SFWT_FLAG,
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
	FROM okc_sections_v
	WHERE okc_sections_v.id = p_id;

	l_okc_scnv_pk	okc_scnv_pk_csr%ROWTYPE;
-- UPTO THIS (JOHN)

    l_scnv_rec                     scnv_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('2800: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;

-- TAPI generator code missing from here - added JOHN

    -- Get current database values
    OPEN okc_scnv_pk_csr (p_scnv_rec.id);
    FETCH okc_scnv_pk_csr INTO
		l_scnv_rec.ID,
		l_scnv_rec.SCN_TYPE,
		l_scnv_rec.CHR_ID,
		l_scnv_rec.SAT_CODE,
		l_scnv_rec.SECTION_SEQUENCE,
		l_scnv_rec.LABEL,
		l_scnv_rec.HEADING,
		l_scnv_rec.SCN_ID,
		l_scnv_rec.OBJECT_VERSION_NUMBER,
		l_scnv_rec.SFWT_FLAG,
		l_scnv_rec.CREATED_BY,
		l_scnv_rec.CREATION_DATE,
		l_scnv_rec.LAST_UPDATED_BY,
		l_scnv_rec.LAST_UPDATE_DATE,
		l_scnv_rec.LAST_UPDATE_LOGIN,
		l_scnv_rec.ATTRIBUTE_CATEGORY,
		l_scnv_rec.ATTRIBUTE1,
		l_scnv_rec.ATTRIBUTE2,
		l_scnv_rec.ATTRIBUTE3,
		l_scnv_rec.ATTRIBUTE4,
		l_scnv_rec.ATTRIBUTE5,
		l_scnv_rec.ATTRIBUTE6,
		l_scnv_rec.ATTRIBUTE7,
		l_scnv_rec.ATTRIBUTE8,
		l_scnv_rec.ATTRIBUTE9,
		l_scnv_rec.ATTRIBUTE10,
		l_scnv_rec.ATTRIBUTE11,
		l_scnv_rec.ATTRIBUTE12,
		l_scnv_rec.ATTRIBUTE13,
		l_scnv_rec.ATTRIBUTE14,
		l_scnv_rec.ATTRIBUTE15;

	x_no_data_found := okc_scnv_pk_csr%NOTFOUND;
	CLOSE okc_scnv_pk_csr;

-- UPTO THIS - JOHN
IF (l_debug = 'Y') THEN
   okc_debug.log('900: Leaving  Fn  Get_Rec ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_scnv_rec);

  END get_rec;

  FUNCTION get_rec (
    p_scnv_rec                     IN scnv_rec_type
  ) RETURN scnv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_scnv_rec, l_row_notfound));

  END get_rec;

  ----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_SECTIONS_V --
  ----------------------------------------------------
  FUNCTION null_out_defaults (
    p_scnv_rec	IN scnv_rec_type
  ) RETURN scnv_rec_type IS
    l_scnv_rec	scnv_rec_type := p_scnv_rec;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('3000: Entered null_out_defaults', 2);
    END IF;

    IF (l_scnv_rec.id = OKC_API.G_MISS_NUM) THEN
      l_scnv_rec.id := NULL;
    END IF;
    IF (l_scnv_rec.scn_type = OKC_API.G_MISS_CHAR) THEN
      l_scnv_rec.scn_type := NULL;
    END IF;
    IF (l_scnv_rec.chr_id = OKC_API.G_MISS_NUM) THEN
      l_scnv_rec.chr_id := NULL;
    END IF;
    IF (l_scnv_rec.sat_code = OKC_API.G_MISS_CHAR) THEN
      l_scnv_rec.sat_code := NULL;
    END IF;
    IF (l_scnv_rec.section_sequence = OKC_API.G_MISS_NUM) THEN
      l_scnv_rec.section_sequence := NULL;
    END IF;
    IF (l_scnv_rec.label = OKC_API.G_MISS_CHAR) THEN
      l_scnv_rec.label := NULL;
    END IF;
    IF (l_scnv_rec.heading = OKC_API.G_MISS_CHAR) THEN
      l_scnv_rec.heading := NULL;
    END IF;
    IF (l_scnv_rec.scn_id = OKC_API.G_MISS_NUM) THEN
      l_scnv_rec.scn_id := NULL;
    END IF;
    IF (l_scnv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_scnv_rec.object_version_number := NULL;
    END IF;
    IF (l_scnv_rec.sfwt_flag  = OKC_API.G_MISS_CHAR) THEN
	 l_scnv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_scnv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_scnv_rec.created_by := NULL;
    END IF;
    IF (l_scnv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_scnv_rec.creation_date := NULL;
    END IF;
    IF (l_scnv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_scnv_rec.last_updated_by := NULL;
    END IF;
    IF (l_scnv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_scnv_rec.last_update_date := NULL;
    END IF;
    IF (l_scnv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_scnv_rec.last_update_login := NULL;
    END IF;
    IF (l_scnv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_scnv_rec.attribute_category := NULL;
    END IF;
    IF (l_scnv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_scnv_rec.attribute1 := NULL;
    END IF;
    IF (l_scnv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_scnv_rec.attribute2 := NULL;
    END IF;
    IF (l_scnv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_scnv_rec.attribute3 := NULL;
    END IF;
    IF (l_scnv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_scnv_rec.attribute4 := NULL;
    END IF;
    IF (l_scnv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_scnv_rec.attribute5 := NULL;
    END IF;
    IF (l_scnv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_scnv_rec.attribute6 := NULL;
    END IF;
    IF (l_scnv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_scnv_rec.attribute7 := NULL;
    END IF;
    IF (l_scnv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_scnv_rec.attribute8 := NULL;
    END IF;
    IF (l_scnv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_scnv_rec.attribute9 := NULL;
    END IF;
    IF (l_scnv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_scnv_rec.attribute10 := NULL;
    END IF;
    IF (l_scnv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_scnv_rec.attribute11 := NULL;
    END IF;
    IF (l_scnv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_scnv_rec.attribute12 := NULL;
    END IF;
    IF (l_scnv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_scnv_rec.attribute13 := NULL;
    END IF;
    IF (l_scnv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_scnv_rec.attribute14 := NULL;
    END IF;
    IF (l_scnv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_scnv_rec.attribute15 := NULL;
    END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('500: Leaving  null_out_defaults ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_scnv_rec);

  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Attributes for:OKC_SECTIONS_V --
  --------------------------------------------
  FUNCTION Validate_Attributes (
    p_scnv_rec IN  scnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('3100: Entered Validate_Attributes', 2);
    END IF;

    /************************ HAND-CODED *********************************/
    validate_scn_type
			(x_return_status => l_return_status,
			 p_scnv_rec      => p_scnv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_chr_id
			(x_return_status => l_return_status,
			 p_scnv_rec      => p_scnv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_sat_code
			(x_return_status => l_return_status,
			 p_scnv_rec      => p_scnv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_section_sequence
			(x_return_status => l_return_status,
			 p_scnv_rec      => p_scnv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_sfwt_flag
			(x_return_status => l_return_status,
			 p_scnv_rec      => p_scnv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_scn_id
			(x_return_status => l_return_status,
			 p_scnv_rec      => p_scnv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

IF (l_debug = 'Y') THEN
   okc_debug.log('3200: Leaving  Validate_Attributes', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(x_return_status);

  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3300: Exiting Validate_Attributes:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);

	   -- notify caller of an UNEXPETED error
	   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- return status to caller
        RETURN(x_return_status);

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- Validate_Record for:OKC_SECTIONS_V --
  ----------------------------------------
  FUNCTION Validate_Record (
    p_scnv_rec IN scnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
--  l_unq_tbl   OKC_UTIL.unq_tbl_type;

 -- ------------------------------------------------------
 -- To check for any matching row, for unique check
 -- The cursor includes id check filter to handle updates
 -- for case K2 should not overwrite already existing K1
 -- Two cursors with and without SCN_ID null condition
 -- ------------------------------------------------------
    CURSOR cur_scn_1 IS
    SELECT 'x'
    FROM   okc_sections_v
    WHERE  chr_id           = p_scnv_rec.CHR_ID
    AND    sat_code         = p_scnv_rec.SAT_CODE
    AND    section_sequence = p_scnv_rec.SECTION_SEQUENCE
    AND    scn_id           = p_scnv_rec.SCN_ID
    AND    id              <> NVL(p_scnv_rec.ID,-9999);

    CURSOR cur_scn_2 IS
    SELECT 'x'
    FROM   okc_sections_b
    WHERE  chr_id           = p_scnv_rec.CHR_ID
    AND    sat_code         = p_scnv_rec.SAT_CODE
    AND    section_sequence = p_scnv_rec.SECTION_SEQUENCE
    AND    scn_id          IS NULL
    AND    id              <> NVL(p_scnv_rec.ID,-9999);

    l_row_found   BOOLEAN := False;
    l_dummy       VARCHAR2(1);

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('3400: Entered Validate_Record', 2);
    END IF;


    -- ---------------------------------------------------------------------
    -- Bug 1636056 related changes - Shyam
    -- OKC_UTIL.check_comp_unique call earlier was not using
    -- the bind variables and parses everytime, replaced with
    -- the explicit cursors above, for identical function to
    -- check uniqueness for CHR_ID + SAT_CODE + SECTION_SEQUENCE
    -- chr_id and sat_code are mutually exclusive (in actual values)
    -- if chr_id >0, sat_code is -99, else sat code should be valid(<> -99)
    -- ---------------------------------------------------------------------
       IF (     p_scnv_rec.SCN_ID IS NOT NULL
            AND p_scnv_rec.SCN_ID <> OKC_API.G_MISS_NUM )
       THEN
	      OPEN  cur_scn_1;
           FETCH cur_scn_1 INTO l_dummy;
           l_row_found := cur_scn_1%FOUND;
		 CLOSE cur_scn_1;
       ELSE
		 -- check any matched row with scn_id as null
	      OPEN  cur_scn_2;
           FETCH cur_scn_2 INTO l_dummy;
           l_row_found := cur_scn_2%FOUND;
           CLOSE cur_scn_2;
       END IF;

       IF (l_row_found)
       THEN
	     -- Display the newly defined error message
	     OKC_API.set_message(G_APP_NAME,
	                        'OKC_DUP_SEQUENCE_NUMBER');
          l_return_status := OKC_API.G_RET_STS_ERROR;
	  END IF;

       -- if contract number not unique, raise exception
       IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
  	     RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3500: Leaving  Validate_Record', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN (l_return_status);

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('3600: Exiting Validate_Record:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      RETURN (l_return_status);

  END Validate_Record;

 /*********************** END HAND-CODED ********************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN scnv_rec_type,
    p_to	IN OUT NOCOPY scn_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.scn_type := p_from.scn_type;
    p_to.chr_id := p_from.chr_id;
    p_to.sat_code := p_from.sat_code;
    p_to.section_sequence := p_from.section_sequence;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.label := p_from.label;
    p_to.scn_id := p_from.scn_id;
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
    p_from	IN scn_rec_type,
    p_to	IN OUT NOCOPY scnv_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.scn_type := p_from.scn_type;
    p_to.chr_id := p_from.chr_id;
    p_to.sat_code := p_from.sat_code;
    p_to.section_sequence := p_from.section_sequence;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.label := p_from.label;
    p_to.scn_id := p_from.scn_id;
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
    p_from	IN scnv_rec_type,
    p_to	IN OUT NOCOPY okc_sections_tl_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.heading := p_from.heading;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;

  END migrate;


  PROCEDURE migrate (
    p_from	IN okc_sections_tl_rec_type,
    p_to	IN OUT NOCOPY scnv_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.heading := p_from.heading;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;

  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- validate_row for:OKC_SECTIONS_V --
  -------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_rec                     IN scnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scnv_rec                     scnv_rec_type := p_scnv_rec;
    l_scn_rec                      scn_rec_type;
    l_okc_sections_tl_rec          okc_sections_tl_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('4100: Entered validate_row', 2);
    END IF;

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
    l_return_status := Validate_Attributes(l_scnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_scnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('4200: Leaving  validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4300: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('4400: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('4500: Exiting validate_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL validate_row for:SCNV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_tbl                     IN scnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('4600: Entered validate_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_scnv_tbl.COUNT > 0) THEN
      i := p_scnv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_scnv_rec                     => p_scnv_tbl(i));
        EXIT WHEN (i = p_scnv_tbl.LAST);
        i := p_scnv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('4700: Leaving  validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4800: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('4900: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5000: Exiting validate_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

  -----------------------------------
  -- insert_row for:OKC_SECTIONS_B --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scn_rec                      IN scn_rec_type,
    x_scn_rec                      OUT NOCOPY scn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scn_rec                      scn_rec_type := p_scn_rec;
    l_def_scn_rec                  scn_rec_type;
    ---------------------------------------
    -- Set_Attributes for:OKC_SECTIONS_B --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_scn_rec IN  scn_rec_type,
      x_scn_rec OUT NOCOPY scn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_scn_rec := p_scn_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('5200: Entered insert_row', 2);
    END IF;

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
      p_scn_rec,                         -- IN
      l_scn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_SECTIONS_B(
        id,
        scn_type,
        chr_id,
        sat_code,
        section_sequence,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        label,
        scn_id,
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
        l_scn_rec.id,
        l_scn_rec.scn_type,
        l_scn_rec.chr_id,
        l_scn_rec.sat_code,
        l_scn_rec.section_sequence,
        l_scn_rec.object_version_number,
        l_scn_rec.created_by,
        l_scn_rec.creation_date,
        l_scn_rec.last_updated_by,
        l_scn_rec.last_update_date,
        l_scn_rec.last_update_login,
        l_scn_rec.label,
        l_scn_rec.scn_id,
        l_scn_rec.attribute_category,
        l_scn_rec.attribute1,
        l_scn_rec.attribute2,
        l_scn_rec.attribute3,
        l_scn_rec.attribute4,
        l_scn_rec.attribute5,
        l_scn_rec.attribute6,
        l_scn_rec.attribute7,
        l_scn_rec.attribute8,
        l_scn_rec.attribute9,
        l_scn_rec.attribute10,
        l_scn_rec.attribute11,
        l_scn_rec.attribute12,
        l_scn_rec.attribute13,
        l_scn_rec.attribute14,
        l_scn_rec.attribute15);
    -- Set OUT values
    x_scn_rec := l_scn_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);


    IF (l_debug = 'Y') THEN
       okc_debug.log('5300: Leaving  insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5400: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5500: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5600: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ------------------------------------
  -- insert_row for:OKC_SECTIONS_TL --
  ------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_sections_tl_rec          IN okc_sections_tl_rec_type,
    x_okc_sections_tl_rec          OUT NOCOPY okc_sections_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_sections_tl_rec          okc_sections_tl_rec_type := p_okc_sections_tl_rec;
    l_def_okc_sections_tl_rec      okc_sections_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ----------------------------------------
    -- Set_Attributes for:OKC_SECTIONS_TL --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okc_sections_tl_rec IN  okc_sections_tl_rec_type,
      x_okc_sections_tl_rec OUT NOCOPY okc_sections_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_okc_sections_tl_rec := p_okc_sections_tl_rec;
      x_okc_sections_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      x_okc_sections_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('5800: Entered insert_row', 2);
    END IF;

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
      p_okc_sections_tl_rec,             -- IN
      l_okc_sections_tl_rec);            -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_sections_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_SECTIONS_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          heading,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okc_sections_tl_rec.id,
          l_okc_sections_tl_rec.language,
          l_okc_sections_tl_rec.source_lang,
          l_okc_sections_tl_rec.sfwt_flag,
          l_okc_sections_tl_rec.heading,
          l_okc_sections_tl_rec.created_by,
          l_okc_sections_tl_rec.creation_date,
          l_okc_sections_tl_rec.last_updated_by,
          l_okc_sections_tl_rec.last_update_date,
          l_okc_sections_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_sections_tl_rec := l_okc_sections_tl_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('5900: Leaving  insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6000: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6100: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6200: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -----------------------------------
  -- insert_row for:OKC_SECTIONS_V --
  -----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_rec                     IN scnv_rec_type,
    x_scnv_rec                     OUT NOCOPY scnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scnv_rec                     scnv_rec_type;
    l_def_scnv_rec                 scnv_rec_type;
    l_scn_rec                      scn_rec_type;
    lx_scn_rec                     scn_rec_type;
    l_okc_sections_tl_rec          okc_sections_tl_rec_type;
    lx_okc_sections_tl_rec         okc_sections_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_scnv_rec	IN scnv_rec_type
    ) RETURN scnv_rec_type IS
      l_scnv_rec	scnv_rec_type := p_scnv_rec;
    BEGIN

      l_scnv_rec.CREATION_DATE := SYSDATE;
      l_scnv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_scnv_rec.LAST_UPDATE_DATE := l_scnv_rec.CREATION_DATE;
      l_scnv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_scnv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_scnv_rec);

    END fill_who_columns;
    ---------------------------------------
    -- Set_Attributes for:OKC_SECTIONS_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_scnv_rec IN  scnv_rec_type,
      x_scnv_rec OUT NOCOPY scnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_scnv_rec := p_scnv_rec;
      x_scnv_rec.OBJECT_VERSION_NUMBER := 1;
	 /************************ HAND-CODED *********************************/
      -- set scn_type to upper
	 x_scnv_rec.SCN_TYPE := UPPER(x_scnv_rec.SCN_TYPE);

      -- Default CHR_ID or SAT_CODE
	 If (x_scnv_rec.SCN_TYPE  = 'CHR') Then
          x_scnv_rec.SAT_CODE := '-99';
	 Elsif (x_scnv_rec.SCN_TYPE = 'SAT') Then
		x_scnv_rec.CHR_ID := -99;
	 End If;
	 /*********************** END HAND-CODED ******************************/
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('6500: Entered insert_row', 2);
    END IF;

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
    l_scnv_rec := null_out_defaults(p_scnv_rec);
    -- Set primary key value
    l_scnv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_scnv_rec,                        -- IN
      l_def_scnv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_scnv_rec := fill_who_columns(l_def_scnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_scnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_scnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_scnv_rec, l_scn_rec);
    migrate(l_def_scnv_rec, l_okc_sections_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_scn_rec,
      lx_scn_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_scn_rec, l_def_scnv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_sections_tl_rec,
      lx_okc_sections_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_sections_tl_rec, l_def_scnv_rec);
    -- Set OUT values
    x_scnv_rec := l_def_scnv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('6600: Leaving  insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6700: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6800: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6900: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL insert_row for:SCNV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_tbl                     IN scnv_tbl_type,
    x_scnv_tbl                     OUT NOCOPY scnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('7000: Entered insert_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_scnv_tbl.COUNT > 0) THEN
      i := p_scnv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_scnv_rec                     => p_scnv_tbl(i),
          x_scnv_rec                     => x_scnv_tbl(i));
        EXIT WHEN (i = p_scnv_tbl.LAST);
        i := p_scnv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('7100: Leaving  insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7200: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7300: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7400: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ---------------------------------
  -- lock_row for:OKC_SECTIONS_B --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scn_rec                      IN scn_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_scn_rec IN scn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_SECTIONS_B
     WHERE ID = p_scn_rec.id
       AND OBJECT_VERSION_NUMBER = p_scn_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_scn_rec IN scn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_SECTIONS_B
    WHERE ID = p_scn_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_SECTIONS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_SECTIONS_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('7500: Entered lock_row', 2);
    END IF;

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

--    okc_debug.Set_Indentation('OKC_SCN_PVT');
--    okc_debug.log('7600: Entered lock_row', 2);

      OPEN lock_csr(p_scn_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

    EXCEPTION
      WHEN E_Resource_Busy THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7800: Exiting lock_row:E_Resource_Busy Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_scn_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_scn_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_scn_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('7900: Leaving  lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8000: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8100: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8200: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ----------------------------------
  -- lock_row for:OKC_SECTIONS_TL --
  ----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_sections_tl_rec          IN okc_sections_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_sections_tl_rec IN okc_sections_tl_rec_type) IS
    SELECT *
      FROM OKC_SECTIONS_TL
     WHERE ID = p_okc_sections_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('8300: Entered lock_row', 2);
    END IF;

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

--    okc_debug.Set_Indentation('OKC_SCN_PVT');
--    okc_debug.log('8400: Entered lock_row', 2);

      OPEN lock_csr(p_okc_sections_tl_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

    EXCEPTION
      WHEN E_Resource_Busy THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8600: Exiting lock_row:E_Resource_Busy Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8700: Exiting lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8800: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8900: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9000: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ---------------------------------
  -- lock_row for:OKC_SECTIONS_V --
  ---------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_rec                     IN scnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scn_rec                      scn_rec_type;
    l_okc_sections_tl_rec          okc_sections_tl_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('9100: Entered lock_row', 2);
    END IF;

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
    migrate(p_scnv_rec, l_scn_rec);
    migrate(p_scnv_rec, l_okc_sections_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_scn_rec
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
      l_okc_sections_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('9200: Leaving  lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9300: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9400: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9500: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL lock_row for:SCNV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_tbl                     IN scnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('9600: Entered lock_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_scnv_tbl.COUNT > 0) THEN
      i := p_scnv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_scnv_rec                     => p_scnv_tbl(i));
        EXIT WHEN (i = p_scnv_tbl.LAST);
        i := p_scnv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('9700: Leaving  lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9800: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9900: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10000: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -----------------------------------
  -- update_row for:OKC_SECTIONS_B --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scn_rec                      IN scn_rec_type,
    x_scn_rec                      OUT NOCOPY scn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scn_rec                      scn_rec_type := p_scn_rec;
    l_def_scn_rec                  scn_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_scn_rec	IN scn_rec_type,
      x_scn_rec	OUT NOCOPY scn_rec_type
    ) RETURN VARCHAR2 IS
      l_scn_rec                      scn_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('10100: Entered populate_new_record', 2);
    END IF;

      x_scn_rec := p_scn_rec;
      -- Get current database values
      l_scn_rec := get_rec(p_scn_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_scn_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_scn_rec.id := l_scn_rec.id;
      END IF;
      IF (x_scn_rec.scn_type = OKC_API.G_MISS_CHAR)
      THEN
        x_scn_rec.scn_type := l_scn_rec.scn_type;
      END IF;
      IF (x_scn_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_scn_rec.chr_id := l_scn_rec.chr_id;
      END IF;
      IF (x_scn_rec.sat_code = OKC_API.G_MISS_CHAR)
      THEN
        x_scn_rec.sat_code := l_scn_rec.sat_code;
      END IF;
      IF (x_scn_rec.section_sequence = OKC_API.G_MISS_NUM)
      THEN
        x_scn_rec.section_sequence := l_scn_rec.section_sequence;
      END IF;
      IF (x_scn_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_scn_rec.object_version_number := l_scn_rec.object_version_number;
      END IF;
      IF (x_scn_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_scn_rec.created_by := l_scn_rec.created_by;
      END IF;
      IF (x_scn_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_scn_rec.creation_date := l_scn_rec.creation_date;
      END IF;
      IF (x_scn_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_scn_rec.last_updated_by := l_scn_rec.last_updated_by;
      END IF;
      IF (x_scn_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_scn_rec.last_update_date := l_scn_rec.last_update_date;
      END IF;
      IF (x_scn_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_scn_rec.last_update_login := l_scn_rec.last_update_login;
      END IF;
      IF (x_scn_rec.label = OKC_API.G_MISS_CHAR)
      THEN
        x_scn_rec.label := l_scn_rec.label;
      END IF;
      IF (x_scn_rec.scn_id = OKC_API.G_MISS_NUM)
      THEN
        x_scn_rec.scn_id := l_scn_rec.scn_id;
      END IF;
      IF (x_scn_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_scn_rec.attribute_category := l_scn_rec.attribute_category;
      END IF;
      IF (x_scn_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_scn_rec.attribute1 := l_scn_rec.attribute1;
      END IF;
      IF (x_scn_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_scn_rec.attribute2 := l_scn_rec.attribute2;
      END IF;
      IF (x_scn_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_scn_rec.attribute3 := l_scn_rec.attribute3;
      END IF;
      IF (x_scn_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_scn_rec.attribute4 := l_scn_rec.attribute4;
      END IF;
      IF (x_scn_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_scn_rec.attribute5 := l_scn_rec.attribute5;
      END IF;
      IF (x_scn_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_scn_rec.attribute6 := l_scn_rec.attribute6;
      END IF;
      IF (x_scn_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_scn_rec.attribute7 := l_scn_rec.attribute7;
      END IF;
      IF (x_scn_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_scn_rec.attribute8 := l_scn_rec.attribute8;
      END IF;
      IF (x_scn_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_scn_rec.attribute9 := l_scn_rec.attribute9;
      END IF;
      IF (x_scn_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_scn_rec.attribute10 := l_scn_rec.attribute10;
      END IF;
      IF (x_scn_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_scn_rec.attribute11 := l_scn_rec.attribute11;
      END IF;
      IF (x_scn_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_scn_rec.attribute12 := l_scn_rec.attribute12;
      END IF;
      IF (x_scn_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_scn_rec.attribute13 := l_scn_rec.attribute13;
      END IF;
      IF (x_scn_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_scn_rec.attribute14 := l_scn_rec.attribute14;
      END IF;
      IF (x_scn_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_scn_rec.attribute15 := l_scn_rec.attribute15;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('11950: Leaving  populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKC_SECTIONS_B --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_scn_rec IN  scn_rec_type,
      x_scn_rec OUT NOCOPY scn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_scn_rec := p_scn_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('10300: Entered update_row', 2);
    END IF;

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
      p_scn_rec,                         -- IN
      l_scn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_scn_rec, l_def_scn_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_SECTIONS_B
    SET SCN_TYPE = l_def_scn_rec.scn_type,
        CHR_ID = l_def_scn_rec.chr_id,
        SAT_CODE = l_def_scn_rec.sat_code,
        SECTION_SEQUENCE = l_def_scn_rec.section_sequence,
        OBJECT_VERSION_NUMBER = l_def_scn_rec.object_version_number,
        CREATED_BY = l_def_scn_rec.created_by,
        CREATION_DATE = l_def_scn_rec.creation_date,
        LAST_UPDATED_BY = l_def_scn_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_scn_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_scn_rec.last_update_login,
        LABEL = l_def_scn_rec.label,
        SCN_ID = l_def_scn_rec.scn_id,
        ATTRIBUTE_CATEGORY = l_def_scn_rec.attribute_category,
        ATTRIBUTE1 = l_def_scn_rec.attribute1,
        ATTRIBUTE2 = l_def_scn_rec.attribute2,
        ATTRIBUTE3 = l_def_scn_rec.attribute3,
        ATTRIBUTE4 = l_def_scn_rec.attribute4,
        ATTRIBUTE5 = l_def_scn_rec.attribute5,
        ATTRIBUTE6 = l_def_scn_rec.attribute6,
        ATTRIBUTE7 = l_def_scn_rec.attribute7,
        ATTRIBUTE8 = l_def_scn_rec.attribute8,
        ATTRIBUTE9 = l_def_scn_rec.attribute9,
        ATTRIBUTE10 = l_def_scn_rec.attribute10,
        ATTRIBUTE11 = l_def_scn_rec.attribute11,
        ATTRIBUTE12 = l_def_scn_rec.attribute12,
        ATTRIBUTE13 = l_def_scn_rec.attribute13,
        ATTRIBUTE14 = l_def_scn_rec.attribute14,
        ATTRIBUTE15 = l_def_scn_rec.attribute15
    WHERE ID = l_def_scn_rec.id;

    x_scn_rec := l_def_scn_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('10400: Leaving  update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10500: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10600: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10700: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ------------------------------------
  -- update_row for:OKC_SECTIONS_TL --
  ------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_sections_tl_rec          IN okc_sections_tl_rec_type,
    x_okc_sections_tl_rec          OUT NOCOPY okc_sections_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_sections_tl_rec          okc_sections_tl_rec_type := p_okc_sections_tl_rec;
    l_def_okc_sections_tl_rec      okc_sections_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_sections_tl_rec	IN okc_sections_tl_rec_type,
      x_okc_sections_tl_rec	OUT NOCOPY okc_sections_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okc_sections_tl_rec          okc_sections_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('10800: Entered populate_new_record', 2);
    END IF;

      x_okc_sections_tl_rec := p_okc_sections_tl_rec;
      -- Get current database values
      l_okc_sections_tl_rec := get_rec(p_okc_sections_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_sections_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okc_sections_tl_rec.id := l_okc_sections_tl_rec.id;
      END IF;
      IF (x_okc_sections_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_sections_tl_rec.language := l_okc_sections_tl_rec.language;
      END IF;
      IF (x_okc_sections_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_sections_tl_rec.source_lang := l_okc_sections_tl_rec.source_lang;
      END IF;
      IF (x_okc_sections_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_sections_tl_rec.sfwt_flag := l_okc_sections_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_sections_tl_rec.heading = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_sections_tl_rec.heading := l_okc_sections_tl_rec.heading;
      END IF;
      IF (x_okc_sections_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_sections_tl_rec.created_by := l_okc_sections_tl_rec.created_by;
      END IF;
      IF (x_okc_sections_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_sections_tl_rec.creation_date := l_okc_sections_tl_rec.creation_date;
      END IF;
      IF (x_okc_sections_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_sections_tl_rec.last_updated_by := l_okc_sections_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_sections_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_sections_tl_rec.last_update_date := l_okc_sections_tl_rec.last_update_date;
      END IF;
      IF (x_okc_sections_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_sections_tl_rec.last_update_login := l_okc_sections_tl_rec.last_update_login;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('11950: Leaving  populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKC_SECTIONS_TL --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okc_sections_tl_rec IN  okc_sections_tl_rec_type,
      x_okc_sections_tl_rec OUT NOCOPY okc_sections_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_okc_sections_tl_rec := p_okc_sections_tl_rec;
      x_okc_sections_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      x_okc_sections_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('11000: Entered update_row', 2);
    END IF;

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
      p_okc_sections_tl_rec,             -- IN
      l_okc_sections_tl_rec);            -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_sections_tl_rec, l_def_okc_sections_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_SECTIONS_TL
    SET HEADING = l_def_okc_sections_tl_rec.heading,
        CREATED_BY = l_def_okc_sections_tl_rec.created_by,
        CREATION_DATE = l_def_okc_sections_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okc_sections_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okc_sections_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okc_sections_tl_rec.last_update_login
    WHERE ID = l_def_okc_sections_tl_rec.id
      AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKC_SECTIONS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okc_sections_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_sections_tl_rec := l_def_okc_sections_tl_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);


    IF (l_debug = 'Y') THEN
       okc_debug.log('11100: Leaving  update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('11200: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11300: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11400: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -----------------------------------
  -- update_row for:OKC_SECTIONS_V --
  -----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_rec                     IN scnv_rec_type,
    x_scnv_rec                     OUT NOCOPY scnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scnv_rec                     scnv_rec_type := p_scnv_rec;
    l_def_scnv_rec                 scnv_rec_type;
    l_okc_sections_tl_rec          okc_sections_tl_rec_type;
    lx_okc_sections_tl_rec         okc_sections_tl_rec_type;
    l_scn_rec                      scn_rec_type;
    lx_scn_rec                     scn_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_scnv_rec	IN scnv_rec_type
    ) RETURN scnv_rec_type IS
      l_scnv_rec	scnv_rec_type := p_scnv_rec;
    BEGIN

      l_scnv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_scnv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_scnv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_scnv_rec);

    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_scnv_rec	IN scnv_rec_type,
      x_scnv_rec	OUT NOCOPY scnv_rec_type
    ) RETURN VARCHAR2 IS
      l_scnv_rec                     scnv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('11600: Entered populate_new_record', 2);
    END IF;

      x_scnv_rec := p_scnv_rec;
      -- Get current database values
      l_scnv_rec := get_rec(p_scnv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_scnv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_scnv_rec.id := l_scnv_rec.id;
      END IF;
      IF (x_scnv_rec.scn_type = OKC_API.G_MISS_CHAR)
      THEN
        x_scnv_rec.scn_type := l_scnv_rec.scn_type;
      END IF;
      IF (x_scnv_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_scnv_rec.chr_id := l_scnv_rec.chr_id;
      END IF;
      IF (x_scnv_rec.sat_code = OKC_API.G_MISS_CHAR)
      THEN
        x_scnv_rec.sat_code := l_scnv_rec.sat_code;
      END IF;
      IF (x_scnv_rec.section_sequence = OKC_API.G_MISS_NUM)
      THEN
        x_scnv_rec.section_sequence := l_scnv_rec.section_sequence;
      END IF;
      IF (x_scnv_rec.label = OKC_API.G_MISS_CHAR)
      THEN
        x_scnv_rec.label := l_scnv_rec.label;
      END IF;
      IF (x_scnv_rec.heading = OKC_API.G_MISS_CHAR)
      THEN
        x_scnv_rec.heading := l_scnv_rec.heading;
      END IF;
      IF (x_scnv_rec.scn_id = OKC_API.G_MISS_NUM)
      THEN
        x_scnv_rec.scn_id := l_scnv_rec.scn_id;
      END IF;
      IF (x_scnv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_scnv_rec.object_version_number := l_scnv_rec.object_version_number;
      END IF;
	 IF (x_scnv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
	 THEN
	   x_scnv_rec.sfwt_flag := l_scnv_rec.sfwt_flag;
      END IF;
      IF (x_scnv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_scnv_rec.created_by := l_scnv_rec.created_by;
      END IF;
      IF (x_scnv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_scnv_rec.creation_date := l_scnv_rec.creation_date;
      END IF;
      IF (x_scnv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_scnv_rec.last_updated_by := l_scnv_rec.last_updated_by;
      END IF;
      IF (x_scnv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_scnv_rec.last_update_date := l_scnv_rec.last_update_date;
      END IF;
      IF (x_scnv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_scnv_rec.last_update_login := l_scnv_rec.last_update_login;
      END IF;
      IF (x_scnv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_scnv_rec.attribute_category := l_scnv_rec.attribute_category;
      END IF;
      IF (x_scnv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_scnv_rec.attribute1 := l_scnv_rec.attribute1;
      END IF;
      IF (x_scnv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_scnv_rec.attribute2 := l_scnv_rec.attribute2;
      END IF;
      IF (x_scnv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_scnv_rec.attribute3 := l_scnv_rec.attribute3;
      END IF;
      IF (x_scnv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_scnv_rec.attribute4 := l_scnv_rec.attribute4;
      END IF;
      IF (x_scnv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_scnv_rec.attribute5 := l_scnv_rec.attribute5;
      END IF;
      IF (x_scnv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_scnv_rec.attribute6 := l_scnv_rec.attribute6;
      END IF;
      IF (x_scnv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_scnv_rec.attribute7 := l_scnv_rec.attribute7;
      END IF;
      IF (x_scnv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_scnv_rec.attribute8 := l_scnv_rec.attribute8;
      END IF;
      IF (x_scnv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_scnv_rec.attribute9 := l_scnv_rec.attribute9;
      END IF;
      IF (x_scnv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_scnv_rec.attribute10 := l_scnv_rec.attribute10;
      END IF;
      IF (x_scnv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_scnv_rec.attribute11 := l_scnv_rec.attribute11;
      END IF;
      IF (x_scnv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_scnv_rec.attribute12 := l_scnv_rec.attribute12;
      END IF;
      IF (x_scnv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_scnv_rec.attribute13 := l_scnv_rec.attribute13;
      END IF;
      IF (x_scnv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_scnv_rec.attribute14 := l_scnv_rec.attribute14;
      END IF;
      IF (x_scnv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_scnv_rec.attribute15 := l_scnv_rec.attribute15;
      END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('11100: Leaving  update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

      RETURN(l_return_status);

    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKC_SECTIONS_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_scnv_rec IN  scnv_rec_type,
      x_scnv_rec OUT NOCOPY scnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_scnv_rec := p_scnv_rec;
      x_scnv_rec.OBJECT_VERSION_NUMBER := NVL(x_scnv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('11800: Entered update_row', 2);
    END IF;

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
      p_scnv_rec,                        -- IN
      l_scnv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_scnv_rec, l_def_scnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_scnv_rec := fill_who_columns(l_def_scnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_scnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_scnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_scnv_rec, l_okc_sections_tl_rec);
    migrate(l_def_scnv_rec, l_scn_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_sections_tl_rec,
      lx_okc_sections_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_sections_tl_rec, l_def_scnv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_scn_rec,
      lx_scn_rec
    );

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_scn_rec, l_def_scnv_rec);
    x_scnv_rec := l_def_scnv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('11900: Leaving  update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('12000: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('12100: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('12200: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL update_row for:SCNV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_tbl                     IN scnv_tbl_type,
    x_scnv_tbl                     OUT NOCOPY scnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('12300: Entered update_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_scnv_tbl.COUNT > 0) THEN
      i := p_scnv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_scnv_rec                     => p_scnv_tbl(i),
          x_scnv_rec                     => x_scnv_tbl(i));
        EXIT WHEN (i = p_scnv_tbl.LAST);
        i := p_scnv_tbl.NEXT(i);
      END LOOP;
    END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('12400: Leaving  update_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('12500: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('12600: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('12700: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -----------------------------------
  -- delete_row for:OKC_SECTIONS_B --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scn_rec                      IN scn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scn_rec                      scn_rec_type:= p_scn_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('12800: Entered delete_row', 2);
    END IF;

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_SECTIONS_B
     WHERE ID = l_scn_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('12900: Leaving  delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('13000: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('13100: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('13200: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ------------------------------------
  -- delete_row for:OKC_SECTIONS_TL --
  ------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_sections_tl_rec          IN okc_sections_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_sections_tl_rec          okc_sections_tl_rec_type:= p_okc_sections_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------------
    -- Set_Attributes for:OKC_SECTIONS_TL --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okc_sections_tl_rec IN  okc_sections_tl_rec_type,
      x_okc_sections_tl_rec OUT NOCOPY okc_sections_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_okc_sections_tl_rec := p_okc_sections_tl_rec;
      x_okc_sections_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('13400: Entered delete_row', 2);
    END IF;

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
      p_okc_sections_tl_rec,             -- IN
      l_okc_sections_tl_rec);            -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_SECTIONS_TL
     WHERE ID = l_okc_sections_tl_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('13500: Leaving  delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('13600: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('13700: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('13800: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -----------------------------------
  -- delete_row for:OKC_SECTIONS_V --
  -----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_rec                     IN scnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scnv_rec                     scnv_rec_type := p_scnv_rec;
    l_okc_sections_tl_rec          okc_sections_tl_rec_type;
    l_scn_rec                      scn_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('13900: Entered delete_row', 2);
    END IF;

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
    migrate(l_scnv_rec, l_okc_sections_tl_rec);
    migrate(l_scnv_rec, l_scn_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_sections_tl_rec
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
      l_scn_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('14000: Leaving  delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('14100: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('14200: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('14300: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL delete_row for:SCNV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_tbl                     IN scnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('14400: Entered delete_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_scnv_tbl.COUNT > 0) THEN
      i := p_scnv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_scnv_rec                     => p_scnv_tbl(i));
        EXIT WHEN (i = p_scnv_tbl.LAST);
        i := p_scnv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('14500: Leaving  delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('14600: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('14700: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('14800: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

--This function is called from versioning API OKC_VERSION_PVT
--Old Location: OKCRVERB.pls
--New Location: Base Table API

FUNCTION create_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS


  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('14900: Entered create_version', 2);
    END IF;

INSERT INTO okc_sections_bh
  (
      major_version,
      id,
      scn_type,
      chr_id,
      sat_code,
      section_sequence,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      label,
      scn_id,
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
      attribute15
)
  SELECT
      p_major_version,
      id,
      scn_type,
      chr_id,
      sat_code,
      section_sequence,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      label,
      scn_id,
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
      attribute15
  FROM okc_sections_b
WHERE chr_id = p_chr_id;

--------------------------
-- Versioning TL Table
--------------------------

INSERT INTO okc_sections_tlh
  (
      major_version,
      id,
      language,
      source_lang,
      sfwt_flag,
      heading,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
)
  SELECT
      p_major_version,
      id,
      language,
      source_lang,
      sfwt_flag,
      heading,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  FROM okc_sections_tl
WHERE id in (SELECT id
			FROM okc_sections_b
		    WHERE chr_id= p_chr_id);

    IF (l_debug = 'Y') THEN
       okc_debug.log('15000: Leaving  create_version', 2);
       okc_debug.Reset_Indentation;
    END IF;

RETURN l_return_status;


  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('15100: Exiting create_version:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;

END create_version;

--This Function is called from Versioning API OKC_VERSION_PVT
--Old Location:OKCRVERB.pls
--New Location:Base Table API

FUNCTION restore_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCN_PVT');
       okc_debug.log('15200: Entered restore_version', 2);
    END IF;

INSERT INTO okc_sections_tl
  (
      id,
      language,
      source_lang,
      sfwt_flag,
      heading,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
)
  SELECT
      id,
      language,
      source_lang,
      sfwt_flag,
      heading,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  FROM okc_sections_tlh
WHERE id in (SELECT id
			FROM okc_sections_bh
		    WHERE chr_id = p_chr_id)
  AND major_version = p_major_version;

-----------------------------
-- Restoring for Base Table
-----------------------------

INSERT INTO okc_sections_b
  (
      id,
      scn_type,
      chr_id,
      sat_code,
      section_sequence,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      label,
      scn_id,
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
      attribute15
)
  SELECT
      id,
      scn_type,
      chr_id,
      sat_code,
      section_sequence,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      label,
      scn_id,
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
      attribute15
  FROM okc_sections_bh
WHERE chr_id = p_chr_id
  AND major_version = p_major_version;

    IF (l_debug = 'Y') THEN
       okc_debug.log('15300: Leaving  restore_version', 2);
       okc_debug.Reset_Indentation;
    END IF;

RETURN l_return_status;

  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('15400: Exiting restore_version:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;

END restore_version;
--

END OKC_SCN_PVT;

/
