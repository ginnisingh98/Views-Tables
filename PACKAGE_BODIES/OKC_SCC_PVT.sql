--------------------------------------------------------
--  DDL for Package Body OKC_SCC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_SCC_PVT" AS
/* $Header: OKCSSCCB.pls 120.0 2005/05/25 19:27:42 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  /************************ HAND-CODED *********************************/
  FUNCTION Validate_Attributes (p_sccv_rec in sccv_rec_type) RETURN VARCHAR2;

  l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  -- Start of comments
  --
  -- Procedure Name  : validate_scn_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_scn_id(x_return_status OUT NOCOPY   VARCHAR2,
                   		   p_sccv_rec      IN    sccv_rec_type) is

    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_scnv_csr Is
  	  select 'x'
	  from OKC_SECTIONS_B
  	  where id = p_sccv_rec.scn_id;

  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('100: Entered validate_scn_id', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_sccv_rec.scn_id = OKC_API.G_MISS_NUM or
  	   p_sccv_rec.scn_id IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'scn_id');
	   -- set error flag
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- enforce foreign key
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
					  p_token3_value	=> 'OKC_SECTIONS_V');

	  -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;
    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('200: Leaving  validate_scn_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('300: Exiting validate_scn_id:OTHERS Exception', 2);
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

  -- Start of comments
  --
  -- Procedure Name  : validate_cat_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_cat_id(x_return_status OUT NOCOPY   VARCHAR2,
                   		   p_sccv_rec      IN    sccv_rec_type) is

    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_catv_csr Is
  	  select 'x'
	  from OKC_K_ARTICLES_B
  	  where id = p_sccv_rec.cat_id;

  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('400: Entered validate_cat_id', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key (cat_id is optional)
    If (p_sccv_rec.cat_id <> OKC_API.G_MISS_NUM and
  	   p_sccv_rec.cat_id IS NOT NULL)
    Then
       Open l_catv_csr;
       Fetch l_catv_csr Into l_dummy_var;
       Close l_catv_csr;
       -- if l_dummy_var still set to default, data was not found
       If (l_dummy_var = '?') Then
  	     OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				          p_msg_name		=> g_no_parent_record,
					     p_token1		=> g_col_name_token,
					     p_token1_value	=> 'cat_id',
					     p_token2		=> g_child_table_token,
					     p_token2_value	=> G_VIEW,
					     p_token3		=> g_parent_table_token,
					     p_token3_value	=> 'OKC_K_ARTICLES_V');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('500: Leaving  validate_cat_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Exiting validate_cat_id:OTHERS Exception', 2);
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
        if l_catv_csr%ISOPEN then
	      close l_catv_csr;
        end if;

  End validate_cat_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_cle_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_cle_id(x_return_status OUT NOCOPY   VARCHAR2,
                   		   p_sccv_rec      IN    sccv_rec_type) is

    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_clev_csr Is
  	  select 'x'
	  from OKC_K_LINES_B
  	  where id = p_sccv_rec.cle_id;

  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('700: Entered validate_cle_id', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key (cle_id is optional)
    If (p_sccv_rec.cle_id <> OKC_API.G_MISS_NUM and
  	   p_sccv_rec.cle_id IS NOT NULL)
    Then
       Open l_clev_csr;
       Fetch l_clev_csr Into l_dummy_var;
       Close l_clev_csr;
       -- if l_dummy_var still set to default, data was not found
       If (l_dummy_var = '?') Then
  	     OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				          p_msg_name		=> g_no_parent_record,
					     p_token1		=> g_col_name_token,
					     p_token1_value	=> 'cle_id',
					     p_token2		=> g_child_table_token,
					     p_token2_value	=> G_VIEW,
					     p_token3		=> g_parent_table_token,
					     p_token3_value	=> 'OKC_K_LINES_V');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('800: Leaving  validate_cle_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('900: Exiting validate_cle_id:OTHERS Exception', 2);
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
        if l_clev_csr%ISOPEN then
	      close l_clev_csr;
        end if;

  End validate_cle_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_sae_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_sae_id(x_return_status OUT NOCOPY   VARCHAR2,
                   		   p_sccv_rec      IN    sccv_rec_type) is

    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_saev_csr Is
  	  select 'x'
	  from OKC_STD_ARTICLES_B
  	  where id = p_sccv_rec.sae_id;

  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('1000: Entered validate_sae_id', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key (sae_id is optional)
    If (p_sccv_rec.sae_id <> OKC_API.G_MISS_NUM and
  	   p_sccv_rec.sae_id IS NOT NULL)
    Then
       Open l_saev_csr;
       Fetch l_saev_csr Into l_dummy_var;
       Close l_saev_csr;
       -- if l_dummy_var still set to default, data was not found
       If (l_dummy_var = '?') Then
  	     OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				          p_msg_name		=> g_no_parent_record,
					     p_token1		=> g_col_name_token,
					     p_token1_value	=> 'sae_id',
					     p_token2		=> g_child_table_token,
					     p_token2_value	=> G_VIEW,
					     p_token3		=> g_parent_table_token,
					     p_token3_value	=> 'OKC_STD_ARTICLES_V');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Leaving  validate_sae_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1200: Exiting validate_sae_id:OTHERS Exception', 2);
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
        if l_saev_csr%ISOPEN then
	      close l_saev_csr;
        end if;

  End validate_sae_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_content_sequence
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_content_sequence(x_return_status OUT NOCOPY   VARCHAR2,
                   		             p_sccv_rec      IN    sccv_rec_type) is

   l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
-- l_unq_tbl   OKC_UTIL.unq_tbl_type;

    -- ------------------------------------------------------
    -- To check for any matching row, for unique check
    -- The cursor includes id check filter to handle updates
    -- for case K2 should not overwrite already existing K1
    -- ------------------------------------------------------
    CURSOR cur_vcs IS
    SELECT 'x'
    FROM   okc_section_contents
    WHERE  scn_id           = p_sccv_rec.SCN_ID
    AND    content_sequence = p_sccv_rec.CONTENT_SEQUENCE
    AND    id <> NVL(p_sccv_rec.ID,-9999);

    l_row_found   BOOLEAN := False;
    l_dummy       VARCHAR2(1);

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('1300: Entered validate_content_sequence', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- -------------------------------------------------------------------
    -- Bug 1636056 related changes - Shyam
    -- OKC_UTIL.check_comp_unique call earlier was not using
    -- the bind variables and parses everytime, replaced with
    -- the explicit cursors above, for identical function
    -- to check uniqueness for SCN_ID + CONTENT_SEQUENCE
    -- chr_id and sat_code are mutually exclusive (in actual values)
    -- if chr_id >0, sat_code is -99, else sat code should be valid(<> -99)
    -- -------------------------------------------------------------------

    IF (     p_sccv_rec.content_sequence IS NOT NULL
	    AND p_sccv_rec.content_sequence <> OKC_API.G_MISS_NUM )
    THEN
	    -- check for any matching value in the database
         OPEN  cur_vcs;
         FETCH cur_vcs INTO l_dummy;
         l_row_found := cur_vcs%FOUND;
	    CLOSE cur_vcs;
    ELSE
	  -- display the alert for missing required-value
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'content_sequence');

	   -- set error flag and halt validation
        x_return_status := OKC_API.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (l_row_found)
    THEN
	   -- Display the newly defined error message
        OKC_API.set_message(G_APP_NAME,
					   'OKC_DUP_SEQUENCE_NUMBER');

	   -- set error flag and halt validation
	   x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1400: Leaving  validate_content_sequence', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1500: Exiting validate_content_sequence:OTHERS Exception', 2);
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


  END validate_content_sequence;

  /*********************** END HAND-CODED ******************************/

  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN

    RETURN(okc_p_util.raw_to_number(sys_guid()));

  END get_seq_id;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_SECTION_CONTENTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_scc_rec                      IN scc_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN scc_rec_type IS
    CURSOR okc_section_contents_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SCN_ID,
            CONTENT_SEQUENCE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            LABEL,
            CAT_ID,
            CLE_ID,
            SAE_ID,
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
      FROM Okc_Section_Contents
     WHERE okc_section_contents.id = p_id;
    l_okc_section_contents_pk      okc_section_contents_pk_csr%ROWTYPE;
    l_scc_rec                      scc_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('1700: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_section_contents_pk_csr (p_scc_rec.id);
    FETCH okc_section_contents_pk_csr INTO
              l_scc_rec.ID,
              l_scc_rec.SCN_ID,
              l_scc_rec.CONTENT_SEQUENCE,
              l_scc_rec.OBJECT_VERSION_NUMBER,
              l_scc_rec.CREATED_BY,
              l_scc_rec.CREATION_DATE,
              l_scc_rec.LAST_UPDATED_BY,
              l_scc_rec.LAST_UPDATE_DATE,
              l_scc_rec.LAST_UPDATE_LOGIN,
              l_scc_rec.LABEL,
              l_scc_rec.CAT_ID,
              l_scc_rec.CLE_ID,
              l_scc_rec.SAE_ID,
              l_scc_rec.ATTRIBUTE_CATEGORY,
              l_scc_rec.ATTRIBUTE1,
              l_scc_rec.ATTRIBUTE2,
              l_scc_rec.ATTRIBUTE3,
              l_scc_rec.ATTRIBUTE4,
              l_scc_rec.ATTRIBUTE5,
              l_scc_rec.ATTRIBUTE6,
              l_scc_rec.ATTRIBUTE7,
              l_scc_rec.ATTRIBUTE8,
              l_scc_rec.ATTRIBUTE9,
              l_scc_rec.ATTRIBUTE10,
              l_scc_rec.ATTRIBUTE11,
              l_scc_rec.ATTRIBUTE12,
              l_scc_rec.ATTRIBUTE13,
              l_scc_rec.ATTRIBUTE14,
              l_scc_rec.ATTRIBUTE15;
    x_no_data_found := okc_section_contents_pk_csr%NOTFOUND;
    CLOSE okc_section_contents_pk_csr;

IF (l_debug = 'Y') THEN
   okc_debug.log('900: Leaving  Fn  Get_Rec ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_scc_rec);

  END get_rec;

  FUNCTION get_rec (
    p_scc_rec                      IN scc_rec_type
  ) RETURN scc_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_scc_rec, l_row_notfound));

  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_SECTION_CONTENTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sccv_rec                     IN sccv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sccv_rec_type IS

-- TAPI generator code MISSING FROM HERE - JOHN (added)
    CURSOR okc_sccv_pk_csr (p_id IN NUMBER) IS
    SELECT
		ID,
		SCN_ID,
		LABEL,
		CAT_ID,
		CLE_ID,
		SAE_ID,
		CONTENT_SEQUENCE,
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
    FROM okc_section_contents_v
    WHERE okc_section_contents_v.id = p_id;

    l_okc_sccv_pk  okc_sccv_pk_csr%ROWTYPE;

-- UPTO THIS (JOHN)

    l_sccv_rec                     sccv_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('1900: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;

-- TAPI generator code missing from here - added JOHN

    -- Get current database values
    OPEN okc_sccv_pk_csr (p_sccv_rec.id);
    FETCH okc_sccv_pk_csr INTO
		l_sccv_rec.ID,
		l_sccv_rec.SCN_ID,
		l_sccv_rec.LABEL,
		l_sccv_rec.CAT_ID,
		l_sccv_rec.CLE_ID,
		l_sccv_rec.SAE_ID,
		l_sccv_rec.CONTENT_SEQUENCE,
		l_sccv_rec.OBJECT_VERSION_NUMBER,
		l_sccv_rec.CREATED_BY,
		l_sccv_rec.CREATION_DATE,
		l_sccv_rec.LAST_UPDATED_BY,
		l_sccv_rec.LAST_UPDATE_DATE,
		l_sccv_rec.LAST_UPDATE_LOGIN,
		l_sccv_rec.ATTRIBUTE_CATEGORY,
		l_sccv_rec.ATTRIBUTE1,
		l_sccv_rec.ATTRIBUTE2,
		l_sccv_rec.ATTRIBUTE3,
		l_sccv_rec.ATTRIBUTE4,
		l_sccv_rec.ATTRIBUTE5,
		l_sccv_rec.ATTRIBUTE6,
		l_sccv_rec.ATTRIBUTE7,
		l_sccv_rec.ATTRIBUTE8,
		l_sccv_rec.ATTRIBUTE9,
		l_sccv_rec.ATTRIBUTE10,
		l_sccv_rec.ATTRIBUTE11,
		l_sccv_rec.ATTRIBUTE12,
		l_sccv_rec.ATTRIBUTE13,
		l_sccv_rec.ATTRIBUTE14,
		l_sccv_rec.ATTRIBUTE15;

    x_no_data_found := okc_sccv_pk_csr%NOTFOUND;
    CLOSE okc_sccv_pk_csr;

-- UPTO THIS - JOHN

IF (l_debug = 'Y') THEN
   okc_debug.log('900: Leaving  Fn  Get_Rec ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_sccv_rec);

  END get_rec;

  FUNCTION get_rec (
    p_sccv_rec                     IN sccv_rec_type
  ) RETURN sccv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_sccv_rec, l_row_notfound));

  END get_rec;

  ------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_SECTION_CONTENTS_V --
  ------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_sccv_rec	IN sccv_rec_type
  ) RETURN sccv_rec_type IS
    l_sccv_rec	sccv_rec_type := p_sccv_rec;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('2100: Entered null_out_defaults', 2);
    END IF;

    IF (l_sccv_rec.id = OKC_API.G_MISS_NUM) THEN
      l_sccv_rec.id := NULL;
    END IF;
    IF (l_sccv_rec.scn_id = OKC_API.G_MISS_NUM) THEN
      l_sccv_rec.scn_id := NULL;
    END IF;
    IF (l_sccv_rec.label = OKC_API.G_MISS_CHAR) THEN
      l_sccv_rec.label := NULL;
    END IF;
    IF (l_sccv_rec.cat_id = OKC_API.G_MISS_NUM) THEN
      l_sccv_rec.cat_id := NULL;
    END IF;
    IF (l_sccv_rec.cle_id = OKC_API.G_MISS_NUM) THEN
      l_sccv_rec.cle_id := NULL;
    END IF;
    IF (l_sccv_rec.sae_id = OKC_API.G_MISS_NUM) THEN
      l_sccv_rec.sae_id := NULL;
    END IF;
    IF (l_sccv_rec.content_sequence = OKC_API.G_MISS_NUM) THEN
      l_sccv_rec.content_sequence := NULL;
    END IF;
    IF (l_sccv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_sccv_rec.object_version_number := NULL;
    END IF;
    IF (l_sccv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_sccv_rec.created_by := NULL;
    END IF;
    IF (l_sccv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_sccv_rec.creation_date := NULL;
    END IF;
    IF (l_sccv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_sccv_rec.last_updated_by := NULL;
    END IF;
    IF (l_sccv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_sccv_rec.last_update_date := NULL;
    END IF;
    IF (l_sccv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_sccv_rec.last_update_login := NULL;
    END IF;
    IF (l_sccv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_sccv_rec.attribute_category := NULL;
    END IF;
    IF (l_sccv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_sccv_rec.attribute1 := NULL;
    END IF;
    IF (l_sccv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_sccv_rec.attribute2 := NULL;
    END IF;
    IF (l_sccv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_sccv_rec.attribute3 := NULL;
    END IF;
    IF (l_sccv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_sccv_rec.attribute4 := NULL;
    END IF;
    IF (l_sccv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_sccv_rec.attribute5 := NULL;
    END IF;
    IF (l_sccv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_sccv_rec.attribute6 := NULL;
    END IF;
    IF (l_sccv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_sccv_rec.attribute7 := NULL;
    END IF;
    IF (l_sccv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_sccv_rec.attribute8 := NULL;
    END IF;
    IF (l_sccv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_sccv_rec.attribute9 := NULL;
    END IF;
    IF (l_sccv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_sccv_rec.attribute10 := NULL;
    END IF;
    IF (l_sccv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_sccv_rec.attribute11 := NULL;
    END IF;
    IF (l_sccv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_sccv_rec.attribute12 := NULL;
    END IF;
    IF (l_sccv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_sccv_rec.attribute13 := NULL;
    END IF;
    IF (l_sccv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_sccv_rec.attribute14 := NULL;
    END IF;
    IF (l_sccv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_sccv_rec.attribute15 := NULL;
    END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('900: Leaving  Fn  Get_Rec ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_sccv_rec);

  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------------
  -- Validate_Attributes for:OKC_SECTION_CONTENTS_V --
  ----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_sccv_rec IN  sccv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('2200: Entered Validate_Attributes', 2);
    END IF;

    /************************ HAND-CODED *********************************/
    validate_scn_id
			(x_return_status => l_return_status,
			 p_sccv_rec      => p_sccv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_cat_id
			(x_return_status => l_return_status,
			 p_sccv_rec      => p_sccv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_cle_id
			(x_return_status => l_return_status,
			 p_sccv_rec      => p_sccv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_sae_id
			(x_return_status => l_return_status,
			 p_sccv_rec      => p_sccv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_content_sequence
			(x_return_status => l_return_status,
			 p_sccv_rec      => p_sccv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2300: Leaving  Validate_Attributes', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(x_return_status);

  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2400: Exiting Validate_Attributes:OTHERS Exception', 2);
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
  /*********************** END HAND-CODED ********************************/

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Record for:OKC_SECTION_CONTENTS_V --
  ------------------------------------------------
  FUNCTION Validate_Record (
    p_sccv_rec IN sccv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_counter NUMBER := 0;

    Cursor l_sccv_csr Is
		SELECT count(*)
		FROM okc_section_contents_v
		WHERE cat_id = p_sccv_rec.CAT_ID
		AND scn_id IN (SELECT id
				     FROM okc_sections_b
					WHERE chr_id = (SELECT chr_id
								 FROM okc_sections_b
								 WHERE id = p_sccv_rec.SCN_ID))
          AND id <> p_sccv_rec.id;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('2500: Entered Validate_Record', 2);
    END IF;

    Open l_sccv_csr;
    Fetch l_sccv_csr Into l_counter;
    Close l_sccv_csr;

    If (l_counter > 0 ) Then
	  l_return_status := OKC_API.G_RET_STS_ERROR;
	  OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
					  p_msg_name      =>  'OKC_VALUE_NOT_UNIQUE',
					  p_token1        =>  G_COL_NAME_TOKEN,
					  p_token1_value  =>  'Article');
    End If;

IF (l_debug = 'Y') THEN
   okc_debug.log('500: Leaving  Validate_Record ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN (l_return_status);

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN sccv_rec_type,
    p_to	OUT NOCOPY scc_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.scn_id := p_from.scn_id;
    p_to.content_sequence := p_from.content_sequence;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.label := p_from.label;
    p_to.cat_id := p_from.cat_id;
    p_to.cle_id := p_from.cle_id;
    p_to.sae_id := p_from.sae_id;
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
    p_from	IN scc_rec_type,
    p_to	OUT NOCOPY sccv_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.scn_id := p_from.scn_id;
    p_to.content_sequence := p_from.content_sequence;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.label := p_from.label;
    p_to.cat_id := p_from.cat_id;
    p_to.cle_id := p_from.cle_id;
    p_to.sae_id := p_from.sae_id;
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
  ---------------------------------------------
  -- validate_row for:OKC_SECTION_CONTENTS_V --
  ---------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_rec                     IN sccv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sccv_rec                     sccv_rec_type := p_sccv_rec;
    l_scc_rec                      scc_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('2800: Entered validate_row', 2);
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
    l_return_status := Validate_Attributes(l_sccv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_sccv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('2900: Leaving  validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('3000: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('3100: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('3200: Exiting validate_row:OTHERS Exception', 2);
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
  -- PL/SQL TBL validate_row for:SCCV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_tbl                     IN sccv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('3300: Entered validate_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sccv_tbl.COUNT > 0) THEN
      i := p_sccv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sccv_rec                     => p_sccv_tbl(i));
        EXIT WHEN (i = p_sccv_tbl.LAST);
        i := p_sccv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3400: Leaving  validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('3500: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('3600: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('3700: Exiting validate_row:OTHERS Exception', 2);
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

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- insert_row for:OKC_SECTION_CONTENTS --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scc_rec                      IN scc_rec_type,
    x_scc_rec                      OUT NOCOPY scc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CONTENTS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scc_rec                      scc_rec_type := p_scc_rec;
    l_def_scc_rec                  scc_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKC_SECTION_CONTENTS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_scc_rec IN  scc_rec_type,
      x_scc_rec OUT NOCOPY scc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_scc_rec := p_scc_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('3900: Entered insert_row', 2);
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
      p_scc_rec,                         -- IN
      l_scc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_SECTION_CONTENTS(
        id,
        scn_id,
        content_sequence,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        label,
        cat_id,
        cle_id,
        sae_id,
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
        l_scc_rec.id,
        l_scc_rec.scn_id,
        l_scc_rec.content_sequence,
        l_scc_rec.object_version_number,
        l_scc_rec.created_by,
        l_scc_rec.creation_date,
        l_scc_rec.last_updated_by,
        l_scc_rec.last_update_date,
        l_scc_rec.last_update_login,
        l_scc_rec.label,
        l_scc_rec.cat_id,
        l_scc_rec.cle_id,
        l_scc_rec.sae_id,
        l_scc_rec.attribute_category,
        l_scc_rec.attribute1,
        l_scc_rec.attribute2,
        l_scc_rec.attribute3,
        l_scc_rec.attribute4,
        l_scc_rec.attribute5,
        l_scc_rec.attribute6,
        l_scc_rec.attribute7,
        l_scc_rec.attribute8,
        l_scc_rec.attribute9,
        l_scc_rec.attribute10,
        l_scc_rec.attribute11,
        l_scc_rec.attribute12,
        l_scc_rec.attribute13,
        l_scc_rec.attribute14,
        l_scc_rec.attribute15);
    -- Set OUT values
    x_scc_rec := l_scc_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('4000: Leaving  insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4100: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('4200: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('4300: Exiting insert_row:OTHERS Exception', 2);
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
  -------------------------------------------
  -- insert_row for:OKC_SECTION_CONTENTS_V --
  -------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_rec                     IN sccv_rec_type,
    x_sccv_rec                     OUT NOCOPY sccv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sccv_rec                     sccv_rec_type;
    l_def_sccv_rec                 sccv_rec_type;
    l_scc_rec                      scc_rec_type;
    lx_scc_rec                     scc_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sccv_rec	IN sccv_rec_type
    ) RETURN sccv_rec_type IS
      l_sccv_rec	sccv_rec_type := p_sccv_rec;
    BEGIN

      l_sccv_rec.CREATION_DATE := SYSDATE;
      l_sccv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_sccv_rec.LAST_UPDATE_DATE := l_sccv_rec.CREATION_DATE;
      l_sccv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sccv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sccv_rec);

    END fill_who_columns;
    -----------------------------------------------
    -- Set_Attributes for:OKC_SECTION_CONTENTS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_sccv_rec IN  sccv_rec_type,
      x_sccv_rec OUT NOCOPY sccv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_sccv_rec := p_sccv_rec;
      x_sccv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('4600: Entered insert_row', 2);
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
    l_sccv_rec := null_out_defaults(p_sccv_rec);
    -- Set primary key value
    l_sccv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_sccv_rec,                        -- IN
      l_def_sccv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sccv_rec := fill_who_columns(l_def_sccv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sccv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sccv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_sccv_rec, l_scc_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_scc_rec,
      lx_scc_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_scc_rec, l_def_sccv_rec);
    -- Set OUT values
    x_sccv_rec := l_def_sccv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('4700: Leaving  insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4800: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('4900: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('5000: Exiting insert_row:OTHERS Exception', 2);
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
  -- PL/SQL TBL insert_row for:SCCV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_tbl                     IN sccv_tbl_type,
    x_sccv_tbl                     OUT NOCOPY sccv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('5100: Entered insert_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sccv_tbl.COUNT > 0) THEN
      i := p_sccv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sccv_rec                     => p_sccv_tbl(i),
          x_sccv_rec                     => x_sccv_tbl(i));
        EXIT WHEN (i = p_sccv_tbl.LAST);
        i := p_sccv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('5200: Leaving  insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5300: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('5400: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('5500: Exiting insert_row:OTHERS Exception', 2);
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
  ---------------------------------------
  -- lock_row for:OKC_SECTION_CONTENTS --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scc_rec                      IN scc_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_scc_rec IN scc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_SECTION_CONTENTS
     WHERE ID = p_scc_rec.id
       AND OBJECT_VERSION_NUMBER = p_scc_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_scc_rec IN scc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_SECTION_CONTENTS
    WHERE ID = p_scc_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CONTENTS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_SECTION_CONTENTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_SECTION_CONTENTS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('5600: Entered lock_row', 2);
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

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('5700: Entered lock_row', 2);
    END IF;

      OPEN lock_csr(p_scc_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.log('5800: Leaving  lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

    EXCEPTION
      WHEN E_Resource_Busy THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5900: Exiting lock_row:E_Resource_Busy Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_scc_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_scc_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_scc_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('6000: Leaving  lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6100: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('6200: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('6300: Exiting lock_row:OTHERS Exception', 2);
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
  -----------------------------------------
  -- lock_row for:OKC_SECTION_CONTENTS_V --
  -----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_rec                     IN sccv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scc_rec                      scc_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('6400: Entered lock_row', 2);
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
    migrate(p_sccv_rec, l_scc_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_scc_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('6500: Leaving  lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6600: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('6700: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('6800: Exiting lock_row:OTHERS Exception', 2);
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
  -- PL/SQL TBL lock_row for:SCCV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_tbl                     IN sccv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('6900: Entered lock_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sccv_tbl.COUNT > 0) THEN
      i := p_sccv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sccv_rec                     => p_sccv_tbl(i));
        EXIT WHEN (i = p_sccv_tbl.LAST);
        i := p_sccv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('7000: Leaving  lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7100: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('7200: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('7300: Exiting lock_row:OTHERS Exception', 2);
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
  -----------------------------------------
  -- update_row for:OKC_SECTION_CONTENTS --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scc_rec                      IN scc_rec_type,
    x_scc_rec                      OUT NOCOPY scc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CONTENTS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scc_rec                      scc_rec_type := p_scc_rec;
    l_def_scc_rec                  scc_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_scc_rec	IN scc_rec_type,
      x_scc_rec	OUT NOCOPY scc_rec_type
    ) RETURN VARCHAR2 IS
      l_scc_rec                      scc_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('7400: Entered populate_new_record', 2);
    END IF;

      x_scc_rec := p_scc_rec;
      -- Get current database values
      l_scc_rec := get_rec(p_scc_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_scc_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_scc_rec.id := l_scc_rec.id;
      END IF;
      IF (x_scc_rec.scn_id = OKC_API.G_MISS_NUM)
      THEN
        x_scc_rec.scn_id := l_scc_rec.scn_id;
      END IF;
      IF (x_scc_rec.content_sequence = OKC_API.G_MISS_NUM)
      THEN
        x_scc_rec.content_sequence := l_scc_rec.content_sequence;
      END IF;
      IF (x_scc_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_scc_rec.object_version_number := l_scc_rec.object_version_number;
      END IF;
      IF (x_scc_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_scc_rec.created_by := l_scc_rec.created_by;
      END IF;
      IF (x_scc_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_scc_rec.creation_date := l_scc_rec.creation_date;
      END IF;
      IF (x_scc_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_scc_rec.last_updated_by := l_scc_rec.last_updated_by;
      END IF;
      IF (x_scc_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_scc_rec.last_update_date := l_scc_rec.last_update_date;
      END IF;
      IF (x_scc_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_scc_rec.last_update_login := l_scc_rec.last_update_login;
      END IF;
      IF (x_scc_rec.label = OKC_API.G_MISS_CHAR)
      THEN
        x_scc_rec.label := l_scc_rec.label;
      END IF;
      IF (x_scc_rec.cat_id = OKC_API.G_MISS_NUM)
      THEN
        x_scc_rec.cat_id := l_scc_rec.cat_id;
      END IF;
      IF (x_scc_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_scc_rec.cle_id := l_scc_rec.cle_id;
      END IF;
      IF (x_scc_rec.sae_id = OKC_API.G_MISS_NUM)
      THEN
        x_scc_rec.sae_id := l_scc_rec.sae_id;
      END IF;
      IF (x_scc_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_scc_rec.attribute_category := l_scc_rec.attribute_category;
      END IF;
      IF (x_scc_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_scc_rec.attribute1 := l_scc_rec.attribute1;
      END IF;
      IF (x_scc_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_scc_rec.attribute2 := l_scc_rec.attribute2;
      END IF;
      IF (x_scc_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_scc_rec.attribute3 := l_scc_rec.attribute3;
      END IF;
      IF (x_scc_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_scc_rec.attribute4 := l_scc_rec.attribute4;
      END IF;
      IF (x_scc_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_scc_rec.attribute5 := l_scc_rec.attribute5;
      END IF;
      IF (x_scc_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_scc_rec.attribute6 := l_scc_rec.attribute6;
      END IF;
      IF (x_scc_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_scc_rec.attribute7 := l_scc_rec.attribute7;
      END IF;
      IF (x_scc_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_scc_rec.attribute8 := l_scc_rec.attribute8;
      END IF;
      IF (x_scc_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_scc_rec.attribute9 := l_scc_rec.attribute9;
      END IF;
      IF (x_scc_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_scc_rec.attribute10 := l_scc_rec.attribute10;
      END IF;
      IF (x_scc_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_scc_rec.attribute11 := l_scc_rec.attribute11;
      END IF;
      IF (x_scc_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_scc_rec.attribute12 := l_scc_rec.attribute12;
      END IF;
      IF (x_scc_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_scc_rec.attribute13 := l_scc_rec.attribute13;
      END IF;
      IF (x_scc_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_scc_rec.attribute14 := l_scc_rec.attribute14;
      END IF;
      IF (x_scc_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_scc_rec.attribute15 := l_scc_rec.attribute15;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('11950: Leaving  populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN(l_return_status);

    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKC_SECTION_CONTENTS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_scc_rec IN  scc_rec_type,
      x_scc_rec OUT NOCOPY scc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_scc_rec := p_scc_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('7600: Entered update_row', 2);
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
      p_scc_rec,                         -- IN
      l_scc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_scc_rec, l_def_scc_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_SECTION_CONTENTS
    SET SCN_ID = l_def_scc_rec.scn_id,
        CONTENT_SEQUENCE = l_def_scc_rec.content_sequence,
        OBJECT_VERSION_NUMBER = l_def_scc_rec.object_version_number,
        CREATED_BY = l_def_scc_rec.created_by,
        CREATION_DATE = l_def_scc_rec.creation_date,
        LAST_UPDATED_BY = l_def_scc_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_scc_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_scc_rec.last_update_login,
        LABEL = l_def_scc_rec.label,
        CAT_ID = l_def_scc_rec.cat_id,
        CLE_ID = l_def_scc_rec.cle_id,
        SAE_ID = l_def_scc_rec.sae_id,
        ATTRIBUTE_CATEGORY = l_def_scc_rec.attribute_category,
        ATTRIBUTE1 = l_def_scc_rec.attribute1,
        ATTRIBUTE2 = l_def_scc_rec.attribute2,
        ATTRIBUTE3 = l_def_scc_rec.attribute3,
        ATTRIBUTE4 = l_def_scc_rec.attribute4,
        ATTRIBUTE5 = l_def_scc_rec.attribute5,
        ATTRIBUTE6 = l_def_scc_rec.attribute6,
        ATTRIBUTE7 = l_def_scc_rec.attribute7,
        ATTRIBUTE8 = l_def_scc_rec.attribute8,
        ATTRIBUTE9 = l_def_scc_rec.attribute9,
        ATTRIBUTE10 = l_def_scc_rec.attribute10,
        ATTRIBUTE11 = l_def_scc_rec.attribute11,
        ATTRIBUTE12 = l_def_scc_rec.attribute12,
        ATTRIBUTE13 = l_def_scc_rec.attribute13,
        ATTRIBUTE14 = l_def_scc_rec.attribute14,
        ATTRIBUTE15 = l_def_scc_rec.attribute15
    WHERE ID = l_def_scc_rec.id;

    x_scc_rec := l_def_scc_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('7700: Leaving  update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7800: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('7900: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('8000: Exiting update_row:OTHERS Exception', 2);
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
  -------------------------------------------
  -- update_row for:OKC_SECTION_CONTENTS_V --
  -------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_rec                     IN sccv_rec_type,
    x_sccv_rec                     OUT NOCOPY sccv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sccv_rec                     sccv_rec_type := p_sccv_rec;
    l_def_sccv_rec                 sccv_rec_type;
    l_scc_rec                      scc_rec_type;
    lx_scc_rec                     scc_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sccv_rec	IN sccv_rec_type
    ) RETURN sccv_rec_type IS
      l_sccv_rec	sccv_rec_type := p_sccv_rec;
    BEGIN

      l_sccv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sccv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sccv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sccv_rec);

    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sccv_rec	IN sccv_rec_type,
      x_sccv_rec	OUT NOCOPY sccv_rec_type
    ) RETURN VARCHAR2 IS
      l_sccv_rec                     sccv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('8200: Entered populate_new_record', 2);
    END IF;

      x_sccv_rec := p_sccv_rec;
      -- Get current database values
      l_sccv_rec := get_rec(p_sccv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sccv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_sccv_rec.id := l_sccv_rec.id;
      END IF;
      IF (x_sccv_rec.scn_id = OKC_API.G_MISS_NUM)
      THEN
        x_sccv_rec.scn_id := l_sccv_rec.scn_id;
      END IF;
      IF (x_sccv_rec.label = OKC_API.G_MISS_CHAR)
      THEN
        x_sccv_rec.label := l_sccv_rec.label;
      END IF;
      IF (x_sccv_rec.cat_id = OKC_API.G_MISS_NUM)
      THEN
        x_sccv_rec.cat_id := l_sccv_rec.cat_id;
      END IF;
      IF (x_sccv_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_sccv_rec.cle_id := l_sccv_rec.cle_id;
      END IF;
      IF (x_sccv_rec.sae_id = OKC_API.G_MISS_NUM)
      THEN
        x_sccv_rec.sae_id := l_sccv_rec.sae_id;
      END IF;
      IF (x_sccv_rec.content_sequence = OKC_API.G_MISS_NUM)
      THEN
        x_sccv_rec.content_sequence := l_sccv_rec.content_sequence;
      END IF;
      IF (x_sccv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sccv_rec.object_version_number := l_sccv_rec.object_version_number;
      END IF;
      IF (x_sccv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sccv_rec.created_by := l_sccv_rec.created_by;
      END IF;
      IF (x_sccv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sccv_rec.creation_date := l_sccv_rec.creation_date;
      END IF;
      IF (x_sccv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sccv_rec.last_updated_by := l_sccv_rec.last_updated_by;
      END IF;
      IF (x_sccv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sccv_rec.last_update_date := l_sccv_rec.last_update_date;
      END IF;
      IF (x_sccv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sccv_rec.last_update_login := l_sccv_rec.last_update_login;
      END IF;
      IF (x_sccv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_sccv_rec.attribute_category := l_sccv_rec.attribute_category;
      END IF;
      IF (x_sccv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_sccv_rec.attribute1 := l_sccv_rec.attribute1;
      END IF;
      IF (x_sccv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_sccv_rec.attribute2 := l_sccv_rec.attribute2;
      END IF;
      IF (x_sccv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_sccv_rec.attribute3 := l_sccv_rec.attribute3;
      END IF;
      IF (x_sccv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_sccv_rec.attribute4 := l_sccv_rec.attribute4;
      END IF;
      IF (x_sccv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_sccv_rec.attribute5 := l_sccv_rec.attribute5;
      END IF;
      IF (x_sccv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_sccv_rec.attribute6 := l_sccv_rec.attribute6;
      END IF;
      IF (x_sccv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_sccv_rec.attribute7 := l_sccv_rec.attribute7;
      END IF;
      IF (x_sccv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_sccv_rec.attribute8 := l_sccv_rec.attribute8;
      END IF;
      IF (x_sccv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_sccv_rec.attribute9 := l_sccv_rec.attribute9;
      END IF;
      IF (x_sccv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_sccv_rec.attribute10 := l_sccv_rec.attribute10;
      END IF;
      IF (x_sccv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_sccv_rec.attribute11 := l_sccv_rec.attribute11;
      END IF;
      IF (x_sccv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_sccv_rec.attribute12 := l_sccv_rec.attribute12;
      END IF;
      IF (x_sccv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_sccv_rec.attribute13 := l_sccv_rec.attribute13;
      END IF;
      IF (x_sccv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_sccv_rec.attribute14 := l_sccv_rec.attribute14;
      END IF;
      IF (x_sccv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_sccv_rec.attribute15 := l_sccv_rec.attribute15;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('11950: Leaving  populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN(l_return_status);

    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKC_SECTION_CONTENTS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_sccv_rec IN  sccv_rec_type,
      x_sccv_rec OUT NOCOPY sccv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_sccv_rec := p_sccv_rec;
      x_sccv_rec.OBJECT_VERSION_NUMBER := NVL(x_sccv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('8400: Entered update_row', 2);
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
      p_sccv_rec,                        -- IN
      l_sccv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sccv_rec, l_def_sccv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sccv_rec := fill_who_columns(l_def_sccv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sccv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sccv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_sccv_rec, l_scc_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_scc_rec,
      lx_scc_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_scc_rec, l_def_sccv_rec);
    x_sccv_rec := l_def_sccv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('8500: Leaving  update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8600: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('8700: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('8800: Exiting update_row:OTHERS Exception', 2);
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
  -- PL/SQL TBL update_row for:SCCV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_tbl                     IN sccv_tbl_type,
    x_sccv_tbl                     OUT NOCOPY sccv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('8900: Entered update_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sccv_tbl.COUNT > 0) THEN
      i := p_sccv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sccv_rec                     => p_sccv_tbl(i),
          x_sccv_rec                     => x_sccv_tbl(i));
        EXIT WHEN (i = p_sccv_tbl.LAST);
        i := p_sccv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('9000: Leaving  update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9100: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('9200: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('9300: Exiting update_row:OTHERS Exception', 2);
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
  -----------------------------------------
  -- delete_row for:OKC_SECTION_CONTENTS --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scc_rec                      IN scc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CONTENTS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scc_rec                      scc_rec_type:= p_scc_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('9400: Entered delete_row', 2);
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
    DELETE FROM OKC_SECTION_CONTENTS
     WHERE ID = l_scc_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('9500: Leaving  delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9600: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('9700: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('9800: Exiting delete_row:OTHERS Exception', 2);
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
  -------------------------------------------
  -- delete_row for:OKC_SECTION_CONTENTS_V --
  -------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_rec                     IN sccv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sccv_rec                     sccv_rec_type := p_sccv_rec;
    l_scc_rec                      scc_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('9900: Entered delete_row', 2);
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
    migrate(l_sccv_rec, l_scc_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_scc_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('10000: Leaving  delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10100: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('10200: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('10300: Exiting delete_row:OTHERS Exception', 2);
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
  -- PL/SQL TBL delete_row for:SCCV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_tbl                     IN sccv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('10400: Entered delete_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sccv_tbl.COUNT > 0) THEN
      i := p_sccv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sccv_rec                     => p_sccv_tbl(i));
        EXIT WHEN (i = p_sccv_tbl.LAST);
        i := p_sccv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('10500: Leaving  delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10600: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('10700: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('10800: Exiting delete_row:OTHERS Exception', 2);
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
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('10900: Entered create_version', 2);
    END IF;

INSERT INTO okc_section_contents_h
  (
      major_version,
      id,
      scn_id,
      content_sequence,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      label,
      cat_id,
      cle_id,
      sae_id,
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
      scn_id,
      content_sequence,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      label,
      cat_id,
      cle_id,
      sae_id,
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
  FROM okc_section_contents
WHERE scn_id in (SELECT id
			    FROM okc_sections_b
			   WHERE CHR_ID=p_chr_id);

    IF (l_debug = 'Y') THEN
       okc_debug.log('11000: Leaving  create_version', 2);
       okc_debug.Reset_Indentation;
    END IF;
RETURN l_return_status;

  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('11100: Exiting create_version:OTHERS Exception', 2);
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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11000: Leaving  create_version', 2);
       okc_debug.Reset_Indentation;
    END IF;
END create_version;

-----
--
----

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
       okc_debug.Set_Indentation('OKC_SCC_PVT');
       okc_debug.log('11200: Entered restore_version', 2);
    END IF;

INSERT INTO okc_section_contents
  (
      id,
      scn_id,
      content_sequence,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      label,
      cat_id,
      cle_id,
      sae_id,
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
      scn_id,
      content_sequence,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      label,
      cat_id,
      cle_id,
      sae_id,
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
  FROM okc_section_contents_h
WHERE scn_id in (SELECT id
			    FROM okc_sections_bh
			   WHERE chr_id = p_chr_id)
  AND major_version = p_major_version;

    IF (l_debug = 'Y') THEN
       okc_debug.log('11300: Leaving  restore_version', 2);
       okc_debug.Reset_Indentation;
    END IF;
RETURN l_return_status;

  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('11400: Exiting restore_version:OTHERS Exception', 2);
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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11300: Leaving  restore_version', 2);
       okc_debug.Reset_Indentation;
    END IF;
END restore_version;

END OKC_SCC_PVT;

/
