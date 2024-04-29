--------------------------------------------------------
--  DDL for Package Body OKC_K_ARTICLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_K_ARTICLE_PUB" as
/* $Header: OKCPCATB.pls 120.0.12010000.3 2011/02/02 08:03:19 nvvaidya ship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_K_ARTICLE_PUB';
  G_API_VERSION               CONSTANT NUMBER := 1;
  G_SCOPE				CONSTANT varchar2(4) := '_PUB';
  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
  G_MISS_NUM                   CONSTANT   NUMBER      := FND_API.G_MISS_NUM;
  G_MISS_CHAR                  CONSTANT   VARCHAR2(1) := FND_API.G_MISS_CHAR;
  G_MISS_DATE                  CONSTANT   DATE        := FND_API.G_MISS_DATE;
  G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  -- ??? should be moved to OKC_TERMS_UTIL_PVT
  G_UNASSIGNED_SECTION_CODE    CONSTANT   VARCHAR2(30)  := 'UNASSIGNED';

  TYPE catv_11510_rec_type IS RECORD (
    id                             NUMBER,
    chr_id                         NUMBER,
    cle_id                         NUMBER,
    cat_id                         NUMBER,
    object_version_number          NUMBER,
    sfwt_flag                      OKC_K_ARTICLES_V.SFWT_FLAG%TYPE,
    sav_sae_id                     NUMBER,
    sav_sav_release                OKC_K_ARTICLES_V.SAV_SAV_RELEASE%TYPE,
    sbt_code                       OKC_K_ARTICLES_V.SBT_CODE%TYPE,
    dnz_chr_id                     NUMBER,
    comments                       OKC_K_ARTICLES_V.COMMENTS%TYPE,
    fulltext_yn                    OKC_K_ARTICLES_V.FULLTEXT_YN%TYPE,
    variation_description          OKC_K_ARTICLES_V.VARIATION_DESCRIPTION%TYPE,
    name                           OKC_K_ARTICLES_V.NAME%TYPE,
-- text ... commented out to treat empty CLOB as an of empty content:
-- if need to nullify it then nullify contents, not the pointer
--  text                           OKC_K_ARTICLES_V.TEXT%TYPE := OKC_API.G_MISS_CHAR,
--+Hand code start
    text                           OKC_K_ARTICLES_V.TEXT%TYPE,
--+Hand code end
    attribute_category             OKC_K_ARTICLES_V.ATTRIBUTE_CATEGORY%TYPE,
    attribute1                     OKC_K_ARTICLES_V.ATTRIBUTE1%TYPE,
    attribute2                     OKC_K_ARTICLES_V.ATTRIBUTE2%TYPE,
    attribute3                     OKC_K_ARTICLES_V.ATTRIBUTE3%TYPE,
    attribute4                     OKC_K_ARTICLES_V.ATTRIBUTE4%TYPE,
    attribute5                     OKC_K_ARTICLES_V.ATTRIBUTE5%TYPE,
    attribute6                     OKC_K_ARTICLES_V.ATTRIBUTE6%TYPE,
    attribute7                     OKC_K_ARTICLES_V.ATTRIBUTE7%TYPE,
    attribute8                     OKC_K_ARTICLES_V.ATTRIBUTE8%TYPE,
    attribute9                     OKC_K_ARTICLES_V.ATTRIBUTE9%TYPE,
    attribute10                    OKC_K_ARTICLES_V.ATTRIBUTE10%TYPE,
    attribute11                    OKC_K_ARTICLES_V.ATTRIBUTE11%TYPE,
    attribute12                    OKC_K_ARTICLES_V.ATTRIBUTE12%TYPE,
    attribute13                    OKC_K_ARTICLES_V.ATTRIBUTE13%TYPE,
    attribute14                    OKC_K_ARTICLES_V.ATTRIBUTE14%TYPE,
    attribute15                    OKC_K_ARTICLES_V.ATTRIBUTE15%TYPE,
    cat_type                       OKC_K_ARTICLES_V.CAT_TYPE%TYPE,
    created_by                     NUMBER,
    creation_date                  OKC_K_ARTICLES_V.CREATION_DATE%TYPE,
    last_updated_by                NUMBER,
    last_update_date               OKC_K_ARTICLES_V.LAST_UPDATE_DATE%TYPE,
    last_update_login              NUMBER,
  -- new 11i10 columns
    -- defaulted during insert based on App_Id
    document_type                  OKC_K_ARTICLES_B.DOCUMENT_TYPE%TYPE,
    document_id                    NUMBER ,

    source_flag                    VARCHAR2(1) ,
    mandatory_yn                   OKC_K_ARTICLES_B.mandatory_yn%TYPE ,
    scn_id                         NUMBER ,
    label                          OKC_K_ARTICLES_B.label%TYPE ,
    amendment_description          OKC_K_ARTICLES_B.amendment_description%TYPE ,
    amendment_operation_code       OKC_K_ARTICLES_B.amendment_operation_code%TYPE ,
    article_version_id             NUMBER ,
    change_nonstd_yn               OKC_K_ARTICLES_B.change_nonstd_yn%TYPE ,
    orig_system_reference_code     OKC_K_ARTICLES_B.orig_system_reference_code%TYPE ,
    orig_system_reference_id1      NUMBER ,
    orig_system_reference_id2      NUMBER ,
    display_sequence               NUMBER ,
    print_text_yn                  OKC_K_ARTICLES_B.print_text_yn%TYPE ,
    summary_amend_operation_code   OKC_K_ARTICLES_B.summary_amend_operation_code%TYPE ,
    ref_article_id                 NUMBER ,
    ref_article_version_id         NUMBER,
    b_sav_sae_id                   NUMBER,
    last_amended_by            OKC_K_ARTICLES_B.LAST_AMENDED_BY%TYPE,
    last_amendment_date        OKC_K_ARTICLES_B.LAST_AMENDMENT_DATE%TYPE,
     mandatory_rwa                   OKC_K_ARTICLES_B.mandatory_rwa%TYPE
  );
  gi_catv_rec 			catv_11510_rec_type;

/*
--
--	reset some columns procedures after "before user hooks"
--
procedure reset(p_catv_rec IN catv_rec_type) is
begin
    gi_catv_rec.id                    := p_catv_rec.id;
    gi_catv_rec.object_version_number := p_catv_rec.object_version_number;
    gi_catv_rec.created_by            := p_catv_rec.created_by;
    gi_catv_rec.creation_date         := p_catv_rec.creation_date;
    gi_catv_rec.last_updated_by       := p_catv_rec.last_updated_by;
    gi_catv_rec.last_update_date      := p_catv_rec.last_update_date;
    gi_catv_rec.last_update_login     := p_catv_rec.last_update_login;
end reset;
procedure reset(p_atnv_rec IN atnv_rec_type) is
begin
    g_atnv_rec.id                    := p_atnv_rec.id;
    g_atnv_rec.object_version_number := p_atnv_rec.object_version_number;
    g_atnv_rec.created_by            := p_atnv_rec.created_by;
    g_atnv_rec.creation_date         := p_atnv_rec.creation_date;
    g_atnv_rec.last_updated_by       := p_atnv_rec.last_updated_by;
    g_atnv_rec.last_update_date      := p_atnv_rec.last_update_date;
    g_atnv_rec.last_update_login     := p_atnv_rec.last_update_login;
end reset;
*/
  PROCEDURE Flip_GMISS_Record ;

  PROCEDURE Dump_Rec( p_catv_rec catv_11510_rec_type ) IS
    PROCEDURE Print( str VARCHAR2 ) IS
     BEGIN
      okc_debug.log( str, 2 );
--      Dbms_Output.Put_line( str );
    END;
   BEGIN
    Print( '-----------------------------------------------------------------');
    Print( 'Dump of CATV_REC structure:');
    Print( ' id=['||p_catv_rec.id||']');
    Print( ' chr_id=['||p_catv_rec.chr_id||']');
    Print( ' cle_id=['||p_catv_rec.cle_id||']');
    Print( ' cat_id=['||p_catv_rec.cat_id||']');
    Print( ' object_version_number=['||p_catv_rec.object_version_number||']');
    Print( ' sfwt_flag=['||p_catv_rec.sfwt_flag||']');
    Print( ' sav_sae_id=['||p_catv_rec.sav_sae_id||']');
    Print( ' sav_sav_release=['||p_catv_rec.sav_sav_release||']');
    Print( ' sbt_code=['||p_catv_rec.sbt_code||']');
    Print( ' dnz_chr_id=['||p_catv_rec.dnz_chr_id||']');
    Print( ' comments=['||p_catv_rec.comments||']');
    Print( ' fulltext_yn=['||p_catv_rec.fulltext_yn||']');
    Print( ' variation_description=['||p_catv_rec.variation_description||']');
    Print( ' name=['||p_catv_rec.name||']');
    Print( ' text=['||Dbms_Lob.Substr(p_catv_rec.text,80,1)||'...]');
    Print( ' cat_type=['||p_catv_rec.cat_type||']');
    Print( ' document_type=['||p_catv_rec.document_type||']');
    Print( ' document_id=['||p_catv_rec.document_id||']');
    Print( ' source_flag=['||p_catv_rec.source_flag||']');
    Print( ' mandatory_yn=['||p_catv_rec.mandatory_yn||']');
    Print( ' mandatory_rwa=['||p_catv_rec.mandatory_rwa||']');
    Print( ' scn_id=['||p_catv_rec.scn_id||']');
    Print( ' label=['||p_catv_rec.label||']');
    Print( ' amendment_description=['||p_catv_rec.amendment_description||']');
    Print( ' amendment_operation_code=['||p_catv_rec.amendment_operation_code||']');
    Print( ' article_version_id=['||p_catv_rec.article_version_id||']');
    Print( ' change_nonstd_yn=['||p_catv_rec.change_nonstd_yn||']');
    Print( ' orig_system_reference_code=['||p_catv_rec.orig_system_reference_code||']');
    Print( ' orig_system_reference_id1=['||p_catv_rec.orig_system_reference_id1||']');
    Print( ' orig_system_reference_id2=['||p_catv_rec.orig_system_reference_id2||']');
    Print( ' display_sequence=['||p_catv_rec.display_sequence||']');
    Print( ' print_text_yn=['||p_catv_rec.print_text_yn||']');
    Print( ' summary_amend_operation_code=['||p_catv_rec.summary_amend_operation_code||']');
    Print( ' ref_article_id=['||p_catv_rec.ref_article_id||']');
    Print( ' ref_article_version_id=['||p_catv_rec.ref_article_version_id||']');
    Print( ' b_sav_sae_id=['||p_catv_rec.b_sav_sae_id||']');
  END;

  PROCEDURE Dump_Rec( p_catv_rec catv_rec_type ) IS
    PROCEDURE Print( str VARCHAR2 ) IS
     BEGIN
      okc_debug.log( str, 2 );
--      Dbms_Output.Put_line( str );
    END;
   BEGIN
    Print( '-----------------------------------------------------------------');
    Print( 'Dump of CATV_REC structure:');
    Print( ' id=['||p_catv_rec.id||']');
    Print( ' chr_id=['||p_catv_rec.chr_id||']');
    Print( ' cle_id=['||p_catv_rec.cle_id||']');
    Print( ' cat_id=['||p_catv_rec.cat_id||']');
    Print( ' object_version_number=['||p_catv_rec.object_version_number||']');
    Print( ' sfwt_flag=['||p_catv_rec.sfwt_flag||']');
    Print( ' sav_sae_id=['||p_catv_rec.sav_sae_id||']');
    Print( ' sav_sav_release=['||p_catv_rec.sav_sav_release||']');
    Print( ' sbt_code=['||p_catv_rec.sbt_code||']');
    Print( ' dnz_chr_id=['||p_catv_rec.dnz_chr_id||']');
    Print( ' comments=['||p_catv_rec.comments||']');
    Print( ' fulltext_yn=['||p_catv_rec.fulltext_yn||']');
    Print( ' variation_description=['||p_catv_rec.variation_description||']');
    Print( ' name=['||p_catv_rec.name||']');
    Print( ' text=['||Dbms_Lob.Substr(p_catv_rec.text,80,1)||'...]');
    Print( ' cat_type=['||p_catv_rec.cat_type||']');
  END;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_ARTICLES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_id                     IN NUMBER,
    p_major_version          IN NUMBER := NULL,
    x_no_data_found          OUT NOCOPY BOOLEAN
  ) RETURN catv_rec_type IS
    CURSOR okc_catv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            CHR_ID,
            CLE_ID,
            CAT_ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            SAV_SAE_ID,
            SAV_SAV_RELEASE,
            SBT_CODE,
            DNZ_CHR_ID,
            COMMENTS,
            FULLTEXT_YN,
            VARIATION_DESCRIPTION,
            NAME,
            TEXT,
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
            CAT_TYPE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_K_Articles_V
     WHERE id  = p_id;
    CURSOR okc_catv_h_pk_csr (p_id IN NUMBER, p_major_version NUMBER) IS
    SELECT
            ID,
            CHR_ID,
            CLE_ID,
            CAT_ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            SAV_SAE_ID,
            SAV_SAV_RELEASE,
            SBT_CODE,
            DNZ_CHR_ID,
            COMMENTS,
            FULLTEXT_YN,
            VARIATION_DESCRIPTION,
            NAME,
            TEXT,
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
            CAT_TYPE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_K_Articles_HV
     WHERE id = p_id AND major_version=p_major_version;
    l_catv_rec catv_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('KART');
       okc_debug.log('1000: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    IF p_major_version IS NULL THEN
      OPEN okc_catv_pk_csr (p_id);
      FETCH okc_catv_pk_csr INTO
              l_catv_rec.ID,
              l_catv_rec.CHR_ID,
              l_catv_rec.CLE_ID,
              l_catv_rec.CAT_ID,
              l_catv_rec.OBJECT_VERSION_NUMBER,
              l_catv_rec.SFWT_FLAG,
              l_catv_rec.SAV_SAE_ID,
              l_catv_rec.SAV_SAV_RELEASE,
              l_catv_rec.SBT_CODE,
              l_catv_rec.DNZ_CHR_ID,
              l_catv_rec.COMMENTS,
              l_catv_rec.FULLTEXT_YN,
              l_catv_rec.VARIATION_DESCRIPTION,
              l_catv_rec.NAME,
              l_catv_rec.TEXT,
              l_catv_rec.ATTRIBUTE_CATEGORY,
              l_catv_rec.ATTRIBUTE1,
              l_catv_rec.ATTRIBUTE2,
              l_catv_rec.ATTRIBUTE3,
              l_catv_rec.ATTRIBUTE4,
              l_catv_rec.ATTRIBUTE5,
              l_catv_rec.ATTRIBUTE6,
              l_catv_rec.ATTRIBUTE7,
              l_catv_rec.ATTRIBUTE8,
              l_catv_rec.ATTRIBUTE9,
              l_catv_rec.ATTRIBUTE10,
              l_catv_rec.ATTRIBUTE11,
              l_catv_rec.ATTRIBUTE12,
              l_catv_rec.ATTRIBUTE13,
              l_catv_rec.ATTRIBUTE14,
              l_catv_rec.ATTRIBUTE15,
              l_catv_rec.CAT_TYPE,
              l_catv_rec.CREATED_BY,
              l_catv_rec.CREATION_DATE,
              l_catv_rec.LAST_UPDATED_BY,
              l_catv_rec.LAST_UPDATE_DATE,
              l_catv_rec.LAST_UPDATE_LOGIN;
      x_no_data_found := okc_catv_pk_csr%NOTFOUND;
      CLOSE okc_catv_pk_csr;
     ELSE
      OPEN okc_catv_h_pk_csr (p_id, p_major_version);
      FETCH okc_catv_h_pk_csr INTO
              l_catv_rec.ID,
              l_catv_rec.CHR_ID,
              l_catv_rec.CLE_ID,
              l_catv_rec.CAT_ID,
              l_catv_rec.OBJECT_VERSION_NUMBER,
              l_catv_rec.SFWT_FLAG,
              l_catv_rec.SAV_SAE_ID,
              l_catv_rec.SAV_SAV_RELEASE,
              l_catv_rec.SBT_CODE,
              l_catv_rec.DNZ_CHR_ID,
              l_catv_rec.COMMENTS,
              l_catv_rec.FULLTEXT_YN,
              l_catv_rec.VARIATION_DESCRIPTION,
              l_catv_rec.NAME,
              l_catv_rec.TEXT,
              l_catv_rec.ATTRIBUTE_CATEGORY,
              l_catv_rec.ATTRIBUTE1,
              l_catv_rec.ATTRIBUTE2,
              l_catv_rec.ATTRIBUTE3,
              l_catv_rec.ATTRIBUTE4,
              l_catv_rec.ATTRIBUTE5,
              l_catv_rec.ATTRIBUTE6,
              l_catv_rec.ATTRIBUTE7,
              l_catv_rec.ATTRIBUTE8,
              l_catv_rec.ATTRIBUTE9,
              l_catv_rec.ATTRIBUTE10,
              l_catv_rec.ATTRIBUTE11,
              l_catv_rec.ATTRIBUTE12,
              l_catv_rec.ATTRIBUTE13,
              l_catv_rec.ATTRIBUTE14,
              l_catv_rec.ATTRIBUTE15,
              l_catv_rec.CAT_TYPE,
              l_catv_rec.CREATED_BY,
              l_catv_rec.CREATION_DATE,
              l_catv_rec.LAST_UPDATED_BY,
              l_catv_rec.LAST_UPDATE_DATE,
              l_catv_rec.LAST_UPDATE_LOGIN;
      x_no_data_found := okc_catv_h_pk_csr%NOTFOUND;
      CLOSE okc_catv_h_pk_csr;
    END IF;

    IF (l_debug = 'Y') THEN
      okc_debug.log('1000: Leaving  Get_Rec ', 2);
      okc_debug.Reset_Indentation;
    END IF;

    RETURN(l_catv_rec);

  END get_rec;

  FUNCTION get_rec (
    p_id                     IN NUMBER,
    p_major_version          IN NUMBER := NULL
  ) RETURN catv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN( get_rec(p_id, p_major_version, l_row_notfound) );
  END get_rec;

  FUNCTION migrate(
    p_catv_rec	IN	catv_rec_type,
    p_major_version          IN NUMBER := NULL
   ) RETURN catv_11510_rec_type IS
    x_catv_rec catv_11510_rec_type;
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
   BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('KART');
       okc_debug.log('1000: Entered migrate1', 2);
    END IF;

    IF p_catv_rec.ID IS NOT NULL AND p_catv_rec.id <> G_MISS_NUM THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('1000: cat_id IS NOT NULL('||p_catv_rec.ID||')', 2);
      END IF;
      -- Get current database values
      l_return_status := OKC_K_ARTICLES_PVT.Get_Rec(
        p_id                         => p_catv_rec.id,
        p_major_version              => p_major_version,
        x_document_type              => x_catv_rec.document_type,
        x_document_id                => x_catv_rec.document_id,
        x_source_flag                => x_catv_rec.source_flag,
        x_mandatory_yn               => x_catv_rec.mandatory_yn,
        x_scn_id                     => x_catv_rec.scn_id,
        x_label                      => x_catv_rec.label,
        x_amendment_description      => x_catv_rec.amendment_description,
        x_amendment_operation_code   => x_catv_rec.amendment_operation_code,
        x_article_version_id         => x_catv_rec.article_version_id,
        x_change_nonstd_yn           => x_catv_rec.change_nonstd_yn,
        x_orig_system_reference_code => x_catv_rec.orig_system_reference_code,
        x_orig_system_reference_id1  => x_catv_rec.orig_system_reference_id1,
        x_orig_system_reference_id2  => x_catv_rec.orig_system_reference_id2,
        x_display_sequence           => x_catv_rec.display_sequence,
        x_print_text_yn              => x_catv_rec.print_text_yn,
        x_summary_amend_operation_code => x_catv_rec.summary_amend_operation_code,
        x_ref_article_id               => x_catv_rec.ref_article_id,
        x_ref_article_version_id       => x_catv_rec.ref_article_version_id,
  -- setting rest of attributes to the same record - but they will be overwritten below
        x_cle_id                     => x_catv_rec.cle_id,
        x_sav_sae_id                 => x_catv_rec.b_sav_sae_id,
        x_attribute_category         => x_catv_rec.attribute_category,
        x_attribute1                 => x_catv_rec.attribute1,
        x_attribute2                 => x_catv_rec.attribute2,
        x_attribute3                 => x_catv_rec.attribute3,
        x_attribute4                 => x_catv_rec.attribute4,
        x_attribute5                 => x_catv_rec.attribute5,
        x_attribute6                 => x_catv_rec.attribute6,
        x_attribute7                 => x_catv_rec.attribute7,
        x_attribute8                 => x_catv_rec.attribute8,
        x_attribute9                 => x_catv_rec.attribute9,
        x_attribute10                => x_catv_rec.attribute10,
        x_attribute11                => x_catv_rec.attribute11,
        x_attribute12                => x_catv_rec.attribute12,
        x_attribute13                => x_catv_rec.attribute13,
        x_attribute14                => x_catv_rec.attribute14,
        x_attribute15                => x_catv_rec.attribute15,
        x_object_version_number      => x_catv_rec.object_version_number,
        x_created_by                 => x_catv_rec.created_by,
        x_creation_date              => x_catv_rec.creation_date,
        x_last_updated_by            => x_catv_rec.last_updated_by,
        x_last_update_login          => x_catv_rec.last_update_login,
        x_last_update_date           => x_catv_rec.last_update_date,
        x_last_amended_by            => x_catv_rec.last_amended_by,
        x_last_amendment_date        => x_catv_rec.last_amendment_date,
        x_mandatory_rwa               => x_catv_rec.mandatory_rwa
      );
    END IF;
    x_catv_rec.ID := p_catv_rec.ID;
    x_catv_rec.CHR_ID := p_catv_rec.CHR_ID;
    x_catv_rec.CLE_ID := p_catv_rec.CLE_ID;
    x_catv_rec.CAT_ID := p_catv_rec.CAT_ID;
    x_catv_rec.object_version_number := p_catv_rec.object_version_number;
    x_catv_rec.SFWT_FLAG := p_catv_rec.SFWT_FLAG;
    x_catv_rec.SAV_SAE_ID := p_catv_rec.SAV_SAE_ID;
    x_catv_rec.SAV_SAV_RELEASE := p_catv_rec.SAV_SAV_RELEASE;
    x_catv_rec.SBT_CODE := p_catv_rec.SBT_CODE;
    x_catv_rec.DNZ_CHR_ID := p_catv_rec.DNZ_CHR_ID;
    x_catv_rec.COMMENTS := p_catv_rec.COMMENTS;
    x_catv_rec.FULLTEXT_YN := p_catv_rec.FULLTEXT_YN;
    x_catv_rec.VARIATION_DESCRIPTION := p_catv_rec.VARIATION_DESCRIPTION;
    x_catv_rec.NAME := p_catv_rec.NAME;
    x_catv_rec.TEXT := p_catv_rec.TEXT;
    x_catv_rec.ATTRIBUTE_CATEGORY := p_catv_rec.ATTRIBUTE_CATEGORY;
    x_catv_rec.ATTRIBUTE1 := p_catv_rec.ATTRIBUTE1;
    x_catv_rec.ATTRIBUTE2 := p_catv_rec.ATTRIBUTE2;
    x_catv_rec.ATTRIBUTE3 := p_catv_rec.ATTRIBUTE3;
    x_catv_rec.ATTRIBUTE4 := p_catv_rec.ATTRIBUTE4;
    x_catv_rec.ATTRIBUTE5 := p_catv_rec.ATTRIBUTE5;
    x_catv_rec.ATTRIBUTE6 := p_catv_rec.ATTRIBUTE6;
    x_catv_rec.ATTRIBUTE7 := p_catv_rec.ATTRIBUTE7;
    x_catv_rec.ATTRIBUTE8 := p_catv_rec.ATTRIBUTE8;
    x_catv_rec.ATTRIBUTE9 := p_catv_rec.ATTRIBUTE9;
    x_catv_rec.ATTRIBUTE10 := p_catv_rec.ATTRIBUTE10;
    x_catv_rec.ATTRIBUTE11 := p_catv_rec.ATTRIBUTE11;
    x_catv_rec.ATTRIBUTE12 := p_catv_rec.ATTRIBUTE12;
    x_catv_rec.ATTRIBUTE13 := p_catv_rec.ATTRIBUTE13;
    x_catv_rec.ATTRIBUTE14 := p_catv_rec.ATTRIBUTE14;
    x_catv_rec.ATTRIBUTE15 := p_catv_rec.ATTRIBUTE15;
    x_catv_rec.CAT_TYPE := p_catv_rec.CAT_TYPE;
    x_catv_rec.CREATED_BY := p_catv_rec.CREATED_BY;
    x_catv_rec.CREATION_DATE := p_catv_rec.CREATION_DATE;
    x_catv_rec.LAST_UPDATED_BY := p_catv_rec.LAST_UPDATED_BY;
    x_catv_rec.LAST_UPDATE_DATE := p_catv_rec.LAST_UPDATE_DATE;
    x_catv_rec.LAST_UPDATE_LOGIN := p_catv_rec.LAST_UPDATE_LOGIN;

    IF (l_debug = 'Y') THEN
      okc_debug.log('1000: Leaving  migrate1', 2);
      okc_debug.Reset_Indentation;
    END IF;

    RETURN x_catv_rec;
  END migrate;

  FUNCTION migrate(p_catv_rec	IN	catv_11510_rec_type) RETURN catv_rec_type IS
    x_catv_rec catv_rec_type;
   BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('KART');
       okc_debug.log('1000: Entered migrate2', 2);
    END IF;
    x_catv_rec.ID := p_catv_rec.ID;
    x_catv_rec.CHR_ID := p_catv_rec.CHR_ID;
    x_catv_rec.CLE_ID := p_catv_rec.CLE_ID;
    x_catv_rec.CAT_ID := p_catv_rec.CAT_ID;
    x_catv_rec.object_version_number := p_catv_rec.object_version_number;
    x_catv_rec.SFWT_FLAG := p_catv_rec.SFWT_FLAG;
    x_catv_rec.SAV_SAE_ID := p_catv_rec.SAV_SAE_ID;
    x_catv_rec.SAV_SAV_RELEASE := p_catv_rec.SAV_SAV_RELEASE;
    x_catv_rec.SBT_CODE := p_catv_rec.SBT_CODE;
    x_catv_rec.DNZ_CHR_ID := p_catv_rec.DNZ_CHR_ID;
    x_catv_rec.COMMENTS := p_catv_rec.COMMENTS;
    x_catv_rec.FULLTEXT_YN := p_catv_rec.FULLTEXT_YN;
    x_catv_rec.VARIATION_DESCRIPTION := p_catv_rec.VARIATION_DESCRIPTION;
    x_catv_rec.NAME := p_catv_rec.NAME;
    x_catv_rec.TEXT := p_catv_rec.TEXT;
    x_catv_rec.ATTRIBUTE_CATEGORY := p_catv_rec.ATTRIBUTE_CATEGORY;
    x_catv_rec.ATTRIBUTE1 := p_catv_rec.ATTRIBUTE1;
    x_catv_rec.ATTRIBUTE2 := p_catv_rec.ATTRIBUTE2;
    x_catv_rec.ATTRIBUTE3 := p_catv_rec.ATTRIBUTE3;
    x_catv_rec.ATTRIBUTE4 := p_catv_rec.ATTRIBUTE4;
    x_catv_rec.ATTRIBUTE5 := p_catv_rec.ATTRIBUTE5;
    x_catv_rec.ATTRIBUTE6 := p_catv_rec.ATTRIBUTE6;
    x_catv_rec.ATTRIBUTE7 := p_catv_rec.ATTRIBUTE7;
    x_catv_rec.ATTRIBUTE8 := p_catv_rec.ATTRIBUTE8;
    x_catv_rec.ATTRIBUTE9 := p_catv_rec.ATTRIBUTE9;
    x_catv_rec.ATTRIBUTE10 := p_catv_rec.ATTRIBUTE10;
    x_catv_rec.ATTRIBUTE11 := p_catv_rec.ATTRIBUTE11;
    x_catv_rec.ATTRIBUTE12 := p_catv_rec.ATTRIBUTE12;
    x_catv_rec.ATTRIBUTE13 := p_catv_rec.ATTRIBUTE13;
    x_catv_rec.ATTRIBUTE14 := p_catv_rec.ATTRIBUTE14;
    x_catv_rec.ATTRIBUTE15 := p_catv_rec.ATTRIBUTE15;
    x_catv_rec.CAT_TYPE := p_catv_rec.CAT_TYPE;
    x_catv_rec.CREATED_BY := p_catv_rec.CREATED_BY;
    x_catv_rec.CREATION_DATE := p_catv_rec.CREATION_DATE;
    x_catv_rec.LAST_UPDATED_BY := p_catv_rec.LAST_UPDATED_BY;
    x_catv_rec.LAST_UPDATE_DATE := p_catv_rec.LAST_UPDATE_DATE;
    x_catv_rec.LAST_UPDATE_LOGIN := p_catv_rec.LAST_UPDATE_LOGIN;
    IF (l_debug = 'Y') THEN
      okc_debug.log('1000: Leaving  migrate2', 2);
      okc_debug.Reset_Indentation;
    END IF;

    RETURN x_catv_rec;
  END migrate;

  -- Start of comments
  --
  -- Procedure Name  : add_language
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE add_language is
  BEGIN
    NULL;
--    OKC_K_ARTICLE_PVT.add_language_k_article;
  END add_language;

  FUNCTION Get_Unassign_Section_ID(
    p_api_version     IN  NUMBER,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_count       OUT NOCOPY NUMBER,
    x_msg_data        OUT NOCOPY VARCHAR2,
    p_doc_id          IN NUMBER,
    p_doc_type        IN VARCHAR2
  ) RETURN NUMBER IS
    l_doc_type VARCHAR2(20);
    l_doc_id NUMBER;
    l_scn_id NUMBER;
    l_tmpl_id NUMBER;
    l_tmpl_name  VARCHAR2(100);
    l_org_id     NUMBER;
    CURSOR org_id_crs IS
      SELECT authoring_org_id
        FROM OKC_K_HEADERS_B WHERE document_id=p_doc_id;
    CURSOR get_unasgn_scn_id_crs IS
      SELECT ID FROM OKC_SECTIONS_B
       WHERE document_type = p_doc_type AND document_id = p_doc_id
         AND scn_code = G_UNASSIGNED_SECTION_CODE;
    CURSOR get_doc_usage_crs IS
      SELECT TEMPLATE_ID FROM okc_template_usages_v
       WHERE document_type = p_doc_type AND document_id = p_doc_id ;
    CURSOR get_apps_upg_tmpl_id_crs IS
      SELECT TEMPLATE_ID FROM okc_terms_templates_all
       WHERE template_name = l_tmpl_name and nvl(org_id,-99)=nvl(l_org_id,-99);
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation(G_PKG_NAME);
       okc_debug.log('1000: Entered Get_Unassign_Section_ID', 2);
    END IF;

    x_return_status	:= G_RET_STS_SUCCESS;

    OPEN get_unasgn_scn_id_crs;
    FETCH get_unasgn_scn_id_crs INTO l_scn_id;
    CLOSE get_unasgn_scn_id_crs;
    IF l_scn_id IS NULL THEN
      OKC_TERMS_UTIL_PVT.create_unassigned_section(
        p_api_version   => p_api_version,
        p_init_msg_list => FND_API.G_FALSE,
        p_commit        => FND_API.G_FALSE,
        x_return_status => x_return_status,
        x_msg_data      => x_msg_data,
        x_msg_count     => x_msg_count,
        p_doc_type      => p_doc_type,
        p_doc_id        => p_doc_id,
        x_scn_id        => l_scn_id
      );
      IF (x_return_status <> G_RET_STS_SUCCESS) then
        IF (l_debug = 'Y') THEN
          okc_debug.log('11400: Leaving Get_Unassign_Section_ID because of an exception in OKC_TERMS_UTIL_PVT.create_unassigned_section', 2);
          okc_debug.Reset_Indentation;
        END IF;
        RETURN NULL;
      END IF;
    END IF;
    OPEN get_doc_usage_crs;
    FETCH get_doc_usage_crs INTO l_tmpl_id;
    CLOSE get_doc_usage_crs;
    IF l_tmpl_id IS NULL THEN
      OPEN org_id_crs;
      FETCH org_id_crs INTO l_org_id;
      CLOSE org_id_crs;

      l_tmpl_name := p_doc_type || '_11510_UPG_TEMPLATE';

      OPEN get_apps_upg_tmpl_id_crs;
      FETCH get_apps_upg_tmpl_id_crs INTO l_tmpl_id;
      CLOSE get_apps_upg_tmpl_id_crs;
      IF l_tmpl_id IS NULL THEN
        SELECT OKC_TERMS_TEMPLATES_ALL_S.NEXTVAL
          INTO l_tmpl_id FROM DUAL;
        INSERT INTO OKC_TERMS_TEMPLATES_ALL(
          TEMPLATE_NAME,
          TEMPLATE_ID,
          WORKING_COPY_FLAG,
          INTENT,
          STATUS_CODE,
          START_DATE,
          GLOBAL_FLAG,
          CONTRACT_EXPERT_ENABLED,
          DESCRIPTION,
          ORG_ID,
          ORIG_SYSTEM_REFERENCE_CODE,
          HIDE_YN,
          OBJECT_VERSION_NUMBER,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          LAST_UPDATE_DATE)
        VALUES (
          l_tmpl_name,
          l_tmpl_id,
          'N',
          Decode( p_doc_type,'OKC_BUY','B','OKE_BUY','B', 'S'),
          'APPROVED',
          to_date('01-01-1951','DD-MM-YYYY'),
          'N',
          'N',
          'Dummy Template for 11.5.10 Upgrade',
          l_org_id,
          decode (p_doc_type,'OKE_SELL', 'OKC11510UPG:OKE', 'OKE_BUY', 'OKC11510UPG:OKE', 'OKC11510UPG'),
          decode(p_doc_type,'OKS','N','Y'),
          1,
          Fnd_Global.User_Id,
          trunc(sysdate),
          Fnd_Global.User_Id,
          Fnd_Global.Login_Id,
          trunc(sysdate)
        );

      INSERT INTO OKC_ALLOWED_TMPL_USAGES(
        ALLOWED_TMPL_USAGES_ID,
        TEMPLATE_ID,
        DOCUMENT_TYPE,
        DEFAULT_YN,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE)
      VALUES (
        OKC_ALLOWED_TMPL_USAGES_S.NEXTVAL,
        l_tmpl_id,
        p_doc_type,
        'N',
        1,
        Fnd_Global.User_Id,
        trunc(sysdate),
        Fnd_Global.User_Id,
        Fnd_Global.Login_Id,
        trunc(sysdate)
        );
      END IF;
      IF l_tmpl_id IS NOT NULL THEN
        OKC_TEMPLATE_USAGES_GRP.create_template_usages(
          p_api_version   => p_api_version,
          p_init_msg_list => FND_API.G_FALSE,
          p_commit        => FND_API.G_FALSE,
          x_return_status => x_return_status,
          x_msg_data      => x_msg_data,
          x_msg_count     => x_msg_count,
          p_document_type => p_doc_type,
          p_document_id   => p_doc_id,
          p_template_id   => l_tmpl_id,
          p_doc_numbering_scheme => NULL,
          p_document_number => NULL,
          p_article_effective_date => sysdate,
          p_config_header_id => NULL,
          p_config_revision_number => NULL,
          p_valid_config_yn => NULL,
          x_document_type => l_doc_type,
          x_document_id => l_doc_id
        );
        IF (x_return_status <> G_RET_STS_SUCCESS) then
          IF (l_debug = 'Y') THEN
            okc_debug.log('11400: Leaving Get_Unassign_Section_ID because of an exception in OKC_TEMPLATE_USAGES_GRP.create_template_usages', 2);
            okc_debug.Reset_Indentation;
          END IF;
          RETURN NULL;
        END IF;
       ELSE
        -- It shouldn't ever happend
        IF (l_debug = 'Y') THEN
          okc_debug.log('11400: Leaving Get_Unassign_Section_ID because there is no UPGRADE template for '||p_doc_type, 2);
          okc_debug.Reset_Indentation;
        END IF;
        OKC_API.SET_MESSAGE('OKC', 'OKC_NOTDEFINED_11510_UPG_TMPL','DOC_TYPE', p_doc_type);
        x_return_status := G_RET_STS_UNEXP_ERROR;
        RETURN NULL;
      END IF;
    END IF;

    IF (l_debug = 'Y') THEN
      okc_debug.log('1000: Leaving  Get_Unassign_Section_ID ', 2);
      okc_debug.Reset_Indentation;
    END IF;

    RETURN l_scn_id;
  END Get_Unassign_Section_ID;

  FUNCTION get_art_ver_id(p_art_id NUMBER,p_ver_num VARCHAR2)
   RETURN NUMBER IS
    l_art_ver_id NUMBER;
    CURSOR get_art_ver_id_crs IS
      SELECT article_version_id
       FROM okc_article_versions
       WHERE article_id=p_art_id
        AND (nvl(sav_release, To_Char(article_version_number))=p_ver_num
          OR p_ver_num IS NULL AND SYSDATE BETWEEN Start_date AND nvl(end_date,sysdate)
            )
    ;
   BEGIN
    OPEN get_art_ver_id_crs;
    FETCH get_art_ver_id_crs INTO l_art_ver_id;
    CLOSE get_art_ver_id_crs;
    RETURN l_art_ver_id;
   EXCEPTION
    WHEN OTHERS THEN RETURN NULL;
  END;

  PROCEDURE Process_Non_Std_Article(
        p_api_version	IN	NUMBER,
        x_return_status	OUT NOCOPY	VARCHAR2,
        x_msg_count	OUT NOCOPY	NUMBER,
        x_msg_data	OUT NOCOPY	VARCHAR2,
        p_catv_rec	IN	catv_11510_rec_type,
        x_art_id     OUT NOCOPY	NUMBER,
        x_art_ver_id OUT NOCOPY	NUMBER,
        x_std_art_id     OUT NOCOPY	NUMBER,
        x_std_art_ver_id OUT NOCOPY	NUMBER
    ) IS
     l_api_version CONSTANT NUMBER := 1;
     l_api_name    CONSTANT VARCHAR2(30) := 'Process_Non_Std_Article';
     l_art_id     NUMBER;
     l_art_number VARCHAR2(240);
     l_art_ver_id NUMBER;
     l_std_yn     VARCHAR2(3) := 'Y';
     l_intent     VARCHAR2(1);
     l_txt        CLOB;
     CURSOR art_id_crs (p_id NUMBER) IS
      SELECT t.sav_sae_id, t.article_version_id, a.standard_yn
        FROM okc_terms_articles_v t, okc_articles_all a
        WHERE t.id=p_id AND t.sav_sae_id=a.article_id;
     CURSOR l_get_intent_csr(p_doc_type VARCHAR2) IS
      SELECT intent FROM OKC_BUS_DOC_TYPES_B
        WHERE DOCUMENT_TYPE=p_doc_type;
   BEGIN
    IF (l_debug = 'Y') THEN
      okc_debug.log('11400: Entering Process_Non_Std_Article', 2);
    END IF;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_catv_rec.id IS NOT NULL ) THEN
      -- 1. Check current db state (is there std or nonstd)
      OPEN art_id_crs(p_catv_rec.id);
      FETCH art_id_crs INTO l_art_id, l_art_ver_id, l_std_yn;
      CLOSE art_id_crs;
    END IF;
    -- if the procedure is called - we have non-std article
    IF p_catv_rec.b_sav_sae_id <> G_MISS_NUM THEN
      l_art_id := p_catv_rec.b_sav_sae_id;
    END IF;
    IF p_catv_rec.article_version_id <> G_MISS_NUM THEN
      l_art_ver_id := p_catv_rec.article_version_id;
    END IF;
    -- if current DB art type is std - create nonstd else update it.
    IF ( p_catv_rec.id IS NULL OR l_std_yn='Y' /*OR l_art_id<>p_catv_rec.sav_sae_id*/) THEN
      OPEN  l_get_intent_csr(p_catv_rec.document_type);
      FETCH l_get_intent_csr INTO l_intent;
      CLOSE l_get_intent_csr;

      IF l_art_ver_id IS NULL THEN
        l_art_ver_id := Get_Art_Ver_Id(p_catv_rec.sav_sae_id,p_catv_rec.sav_sav_release);
      END IF;

      IF (p_catv_rec.TEXT IS NULL) THEN
        Dbms_Lob.createtemporary( l_txt, TRUE, Dbms_Lob.Session);
        Dbms_Lob.writeappend( l_txt, 1, ' ');
       ELSE
        l_txt := p_catv_rec.TEXT;
      END IF;

      IF (l_debug = 'Y') THEN
        okc_debug.log('11400: non-std article is to be created.Version id of StdArt is '||l_art_ver_id, 2);
      END IF;

      OKC_ARTICLES_GRP.create_article(
         p_api_version                  => 1,
         p_init_msg_list                => FND_API.G_FALSE,
         p_validation_level	      => FND_API.G_VALID_LEVEL_FULL,
         p_commit                       => FND_API.G_FALSE,
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,

         p_article_title                => p_catv_rec.name,
         p_article_number               => NULL,
         p_standard_yn                  => 'N',
         p_article_intent               => l_intent,
         p_article_language             => USERENV('LANG'),
         p_article_type                 => p_catv_rec.sbt_code,
         p_orig_system_reference_code   => p_catv_rec.orig_system_reference_code,
         p_orig_system_reference_id1    => NULL,
         p_orig_system_reference_id2    => NULL,
         p_cz_transfer_status_flag      => 'N',
         x_article_id                   => x_art_id,
         x_article_number               => l_art_number,
         -- Article Version Attributes
         p_article_text                 => l_txt,
         p_provision_yn                 => 'N',
         p_insert_by_reference          => 'N',
         p_lock_text                    => 'N',
         p_global_yn                    => 'N',
         p_article_status               => NULL,
         p_sav_release                  => p_catv_rec.sav_sav_release,
         p_start_date                   => NULL,
         p_end_date                     => NULL,
         p_std_article_version_id       => l_art_ver_id,
         p_display_name                 => p_catv_rec.name,
         p_translated_yn                => 'N',
         p_article_description          => p_catv_rec.comments,
         p_date_approved                => NULL,
         p_default_section              => NULL,
         p_reference_source             => NULL,
         p_reference_text               => NULL,
         p_additional_instructions      => NULL,
         p_variation_description        => p_catv_rec.variation_description,
         p_v_orig_system_reference_code => p_catv_rec.orig_system_reference_code,
         p_v_orig_system_reference_id1  => NULL,
         p_v_orig_system_reference_id2  => NULL,
         p_global_article_version_id    => NULL,
         x_article_version_id           => x_art_ver_id
      );
      x_std_art_id := l_art_id;
      x_std_art_ver_id := l_art_ver_id;
      IF Dbms_Lob.istemporary( l_txt )=1 THEN
        Dbms_Lob.freetemporary( l_txt );
      END IF;
      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------

      IF (l_debug = 'Y') THEN
          okc_debug.log('300: non-std article created.Version id is '||x_art_ver_id, 2);
      END IF;

     ELSE
      x_art_id := l_art_id;
      x_art_ver_id := l_art_ver_id;

      IF (l_debug = 'Y') THEN
        okc_debug.log('11400: non-std article is to be updated.Version id is '||l_art_ver_id, 2);
      END IF;

      OKC_ARTICLES_GRP.update_article(
         p_api_version                  => 1,
         p_init_msg_list                => FND_API.G_FALSE,
         p_validation_level	            => FND_API.G_VALID_LEVEL_FULL,
         p_commit                       => FND_API.G_FALSE,
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_article_id                   => l_art_id,
         p_article_title                => p_catv_rec.name,
         p_article_number               => NULL,
         p_standard_yn                  => NULL,
         p_article_intent               => NULL,
         p_article_language             => NULL,
         p_article_type                 => p_catv_rec.sbt_code,
         p_orig_system_reference_code   => NULL,
         p_orig_system_reference_id1    => NULL,
         p_orig_system_reference_id2    => NULL,
         p_cz_transfer_status_flag      => NULL,
         -- Article Version Attributes
         p_article_version_id           => l_art_ver_id,
         p_article_text                 => p_catv_rec.text,
         p_provision_yn                 => NULL,
         p_insert_by_reference          => NULL,
         p_lock_text                    => NULL,
         p_global_yn                    => NULL,
         p_article_status               => NULL,
         p_sav_release                  => NULL,
         p_start_date                   => NULL,
         p_end_date                     => NULL,
         p_std_article_version_id       => NULL,
         p_display_name                 => p_catv_rec.name,
         p_translated_yn                => NULL,
         p_article_description          => p_catv_rec.comments,
         p_date_approved                => NULL,
         p_default_section              => NULL,
         p_reference_source             => NULL,
         p_reference_text               => NULL,
         p_additional_instructions      => NULL,
         p_variation_description        => NULL,
         p_v_orig_system_reference_code => NULL,
         p_v_orig_system_reference_id1  => NULL,
         p_v_orig_system_reference_id2  => NULL
      );
      x_std_art_id := p_catv_rec.ref_article_id;
      x_std_art_ver_id := p_catv_rec.ref_article_version_id;
      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --------------------------------------------

      IF (l_debug = 'Y') THEN
          okc_debug.log('300: non-std article updated.', 2);
      END IF;

    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    IF (l_debug = 'Y') THEN
         okc_debug.log('900: Leaving Process_Non_Std_Article.', 2);
    END IF;

  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    IF (l_debug = 'Y') THEN
        okc_debug.log('300: Leaving Process_Non_Std_Article: G_EXCEPTION_ERROR Exception', 2);
    END IF;

    IF l_get_intent_csr%ISOPEN THEN
       CLOSE l_get_intent_csr;
    END IF;

    x_return_status := G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving Process_Non_Std_Article: G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
    END IF;

    IF l_get_intent_csr%ISOPEN THEN
       CLOSE l_get_intent_csr;
    END IF;

    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.log('500: Leaving Process_Non_Std_Article because of EXCEPTION: '||sqlerrm, 2);
    END IF;

    IF l_get_intent_csr%ISOPEN THEN
       CLOSE l_get_intent_csr;
    END IF;

    IF l_txt IS NOT NULL THEN
      IF Dbms_Lob.istemporary( l_txt )=1 THEN
        Dbms_Lob.freetemporary( l_txt );
      END IF;
    END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END Process_Non_Std_Article;


  -------------------------------------------------
  -- PROCEDURE Null_Out_Record - set default values -
  -------------------------------------------------
  PROCEDURE Null_Out_Record (
    p_api_version	IN	NUMBER,
    x_return_status	OUT NOCOPY	VARCHAR2,
    x_msg_count	OUT NOCOPY	NUMBER,
    x_msg_data	OUT NOCOPY	VARCHAR2
  ) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (l_debug = 'Y') THEN
      okc_debug.Set_Indentation(G_PKG_NAME);
      okc_debug.log('11300: Entered Null_Out_Record', 2);
    END IF;

    -- Primary key - Should be NULL
    gi_catv_rec.id := NULL;

    IF (gi_catv_rec.sav_sae_id = G_MISS_NUM) THEN
      gi_catv_rec.sav_sae_id := NULL;
    END IF;

    IF (gi_catv_rec.sav_sav_release = G_MISS_CHAR) THEN
      gi_catv_rec.sav_sav_release := NULL;
    END IF;

    IF (gi_catv_rec.comments = G_MISS_CHAR) THEN
      gi_catv_rec.comments := NULL;
    END IF;

    IF (gi_catv_rec.variation_description = G_MISS_CHAR) THEN
      gi_catv_rec.variation_description := NULL;
    END IF;

    IF (gi_catv_rec.name = G_MISS_CHAR) THEN
      gi_catv_rec.name := NULL;
    END IF;

    IF (gi_catv_rec.sbt_code = G_MISS_CHAR) THEN
      gi_catv_rec.sbt_code := NULL;
    END IF;

    IF (gi_catv_rec.cat_type = G_MISS_CHAR) THEN
      gi_catv_rec.cat_type := NULL;
    END IF;

    IF (gi_catv_rec.chr_id = G_MISS_NUM) THEN
      gi_catv_rec.chr_id := NULL;
    END IF;

    IF (gi_catv_rec.cle_id = G_MISS_NUM) THEN
      gi_catv_rec.cle_id := NULL;
    END IF;

    IF (gi_catv_rec.cat_id = G_MISS_NUM) THEN
      gi_catv_rec.cat_id := NULL;
    END IF;

    IF (gi_catv_rec.dnz_chr_id = G_MISS_NUM) THEN
      gi_catv_rec.dnz_chr_id := NULL;
    END IF;

    IF (gi_catv_rec.fulltext_yn = G_MISS_CHAR) THEN
      gi_catv_rec.fulltext_yn := NULL;
    END IF;

    IF (gi_catv_rec.document_type = G_MISS_CHAR) THEN
      gi_catv_rec.document_type := NULL;
    END IF;

    IF (gi_catv_rec.document_id = G_MISS_NUM) THEN
      gi_catv_rec.document_id := NULL;
    END IF;

    IF (gi_catv_rec.source_flag = G_MISS_CHAR) THEN
      gi_catv_rec.source_flag := NULL;
    END IF;

    IF (gi_catv_rec.mandatory_yn = G_MISS_CHAR) THEN
      gi_catv_rec.mandatory_yn := NULL;
    END IF;

    IF (gi_catv_rec.scn_id = G_MISS_NUM) THEN
      gi_catv_rec.scn_id := NULL;
    END IF;

    IF (gi_catv_rec.label = G_MISS_CHAR) THEN
      gi_catv_rec.label := NULL;
    END IF;

    IF (gi_catv_rec.amendment_description = G_MISS_CHAR) THEN
      gi_catv_rec.amendment_description := NULL;
    END IF;

    IF (gi_catv_rec.amendment_operation_code = G_MISS_CHAR) THEN
      gi_catv_rec.amendment_operation_code := NULL;
    END IF;

    IF (gi_catv_rec.article_version_id = G_MISS_NUM) THEN
      gi_catv_rec.article_version_id := NULL;
    END IF;

    IF (gi_catv_rec.change_nonstd_yn = G_MISS_CHAR) THEN
      gi_catv_rec.change_nonstd_yn := NULL;
    END IF;

 IF (gi_catv_rec.mandatory_rwa = G_MISS_CHAR) THEN
      gi_catv_rec.mandatory_rwa := NULL;
    END IF;

    IF (gi_catv_rec.orig_system_reference_code = G_MISS_CHAR) THEN
      gi_catv_rec.orig_system_reference_code := NULL;
    END IF;

    IF (gi_catv_rec.orig_system_reference_id1 = G_MISS_NUM) THEN
      gi_catv_rec.orig_system_reference_id1 := NULL;
    END IF;

    IF (gi_catv_rec.orig_system_reference_id2 = G_MISS_NUM) THEN
      gi_catv_rec.orig_system_reference_id2 := NULL;
    END IF;

    IF (gi_catv_rec.display_sequence = G_MISS_NUM) THEN
      gi_catv_rec.display_sequence := NULL;
    END IF;

    IF (gi_catv_rec.print_text_yn = G_MISS_CHAR) THEN
      gi_catv_rec.print_text_yn := NULL;
    END IF;

    IF (gi_catv_rec.summary_amend_operation_code = G_MISS_CHAR) THEN
      gi_catv_rec.summary_amend_operation_code := NULL;
    END IF;

    IF (gi_catv_rec.ref_article_id = G_MISS_NUM) THEN
      gi_catv_rec.ref_article_id := NULL;
    END IF;

    IF (gi_catv_rec.ref_article_version_id = G_MISS_NUM) THEN
      gi_catv_rec.ref_article_version_id := NULL;
    END IF;

    IF (gi_catv_rec.attribute_category = G_MISS_CHAR) THEN
      gi_catv_rec.attribute_category := NULL;
    END IF;

    IF (gi_catv_rec.attribute1 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute1 := NULL;
    END IF;

    IF (gi_catv_rec.attribute2 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute2 := NULL;
    END IF;

    IF (gi_catv_rec.attribute3 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute3 := NULL;
    END IF;

    IF (gi_catv_rec.attribute4 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute4 := NULL;
    END IF;

    IF (gi_catv_rec.attribute5 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute5 := NULL;
    END IF;

    IF (gi_catv_rec.attribute6 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute6 := NULL;
    END IF;

    IF (gi_catv_rec.attribute7 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute7 := NULL;
    END IF;

    IF (gi_catv_rec.attribute8 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute8 := NULL;
    END IF;

    IF (gi_catv_rec.attribute9 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute9 := NULL;
    END IF;

    IF (gi_catv_rec.attribute10 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute10 := NULL;
    END IF;

    IF (gi_catv_rec.attribute11 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute11 := NULL;
    END IF;

    IF (gi_catv_rec.attribute12 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute12 := NULL;
    END IF;

    IF (gi_catv_rec.attribute13 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute13 := NULL;
    END IF;

    IF (gi_catv_rec.attribute14 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute14 := NULL;
    END IF;

    IF (gi_catv_rec.attribute15 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute15 := NULL;
    END IF;

    IF (l_debug = 'Y') THEN
      okc_debug.log('11400: Leaving  Null_Out_Record ', 2);
      okc_debug.Reset_Indentation;
    END IF;

  END Null_Out_Record;

  -------------------------------------------------
  -- PROCEDURE Default_Record - set default values -
  -------------------------------------------------
  PROCEDURE Default_Record (
    p_api_version	IN	NUMBER,
    x_return_status	OUT NOCOPY	VARCHAR2,
    x_msg_count	OUT NOCOPY	NUMBER,
    x_msg_data	OUT NOCOPY	VARCHAR2
  ) IS
    Cursor l_get_max_seq_csr(p_doc_type VARCHAR2, p_doc_id NUMBER,p_scn_id NUMBER) IS
      SELECT nvl(max(display_sequence),0)+10
      FROM OKC_K_ARTICLES_B
      WHERE DOCUMENT_TYPE= p_doc_type
      AND   DOCUMENT_ID  = p_doc_id
      AND   SCN_ID = p_scn_id;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (l_debug = 'Y') THEN
      okc_debug.Set_Indentation(G_PKG_NAME);
      okc_debug.log('11300: Entered Default_Record', 2);
    END IF;

    -------------------------------------------------
    -- Populating/Defaulting new API attributes
    -------------------------------------------------
    IF (gi_catv_rec.document_type IS NULL) THEN
      OKC_TERMS_UTIL_GRP.Get_Contract_Document_Type_Id(
        p_api_version   => p_api_version,
        x_return_status => x_return_status,
        x_msg_data      => x_msg_data,
        x_msg_count     => x_msg_count,
        p_chr_id        => gi_catv_rec.dnz_chr_id,
        x_doc_id        => gi_catv_rec.document_id,
        x_doc_type      => gi_catv_rec.document_type
      );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
        IF (l_debug = 'Y') THEN
          okc_debug.log('11400: Leaving Default_Record because of an exception in Get_Contract_Document_Type', 2);
          okc_debug.Reset_Indentation;
        END IF;
        RETURN;
      END IF;
    END IF;

    IF (gi_catv_rec.document_id IS NULL) THEN
      gi_catv_rec.document_id := gi_catv_rec.dnz_chr_id;
    END IF;

    IF (gi_catv_rec.mandatory_yn IS NULL) THEN
      gi_catv_rec.mandatory_yn := 'N';
    END IF;

    -- if article is unassigned (it should be always for old API) it should
    -- be assigned to 'UNASSIGNED' section fo document
    IF ( gi_catv_rec.scn_id IS NULL ) THEN
      gi_catv_rec.scn_id := Get_Unassign_Section_ID(
        p_api_version   => p_api_version,
        x_return_status => x_return_status,
        x_msg_data      => x_msg_data,
        x_msg_count     => x_msg_count,
        p_doc_id        => gi_catv_rec.document_id,
        p_doc_type      => gi_catv_rec.document_type
      );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
        IF (l_debug = 'Y') THEN
          okc_debug.log('11400: Leaving Default_Record because of an exception in Get_Unassign_Section_ID', 2);
          okc_debug.Reset_Indentation;
        END IF;
        RETURN;
      END IF;
    END IF;

    IF (gi_catv_rec.DISPLAY_SEQUENCE IS NULL) THEN
      OPEN  l_get_max_seq_csr(gi_catv_rec.document_type,gi_catv_rec.document_id,gi_catv_rec.scn_id);
      FETCH l_get_max_seq_csr INTO gi_catv_rec.DISPLAY_SEQUENCE;
      CLOSE l_get_max_seq_csr;
    END IF;

    IF (gi_catv_rec.TEXT IS NOT NULL OR gi_catv_rec.sav_sae_id IS NULL
     OR gi_catv_rec.cat_type = 'NSD' OR gi_catv_rec.document_type LIKE 'OKE%') THEN
      IF (gi_catv_rec.name IS NULL) THEN
        gi_catv_rec.name := 'NONSTANDARD';
      END IF;
      IF (gi_catv_rec.cat_type = 'STA' and gi_catv_rec.document_type LIKE 'OKE%') THEN
        gi_catv_rec.orig_system_reference_code := 'OKE';
      END IF;

      Process_Non_Std_Article(
        p_api_version   => p_api_version,
        x_return_status => x_return_status,
        x_msg_data      => x_msg_data,
        x_msg_count     => x_msg_count,
        p_catv_rec      => gi_catv_rec,
        x_art_id        => gi_catv_rec.b_sav_sae_id,
        x_art_ver_id    => gi_catv_rec.article_version_id,
        x_std_art_id     => gi_catv_rec.ref_article_id,
        x_std_art_ver_id => gi_catv_rec.ref_article_version_id
      );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
        IF (l_debug = 'Y') THEN
          okc_debug.log('11400: Leaving Default_Record because of an exception in Process_Non_Std_Article', 2);
          okc_debug.Reset_Indentation;
        END IF;
        RETURN;
      END IF;

      gi_catv_rec.FULLTEXT_YN := NULL;
      gi_catv_rec.VARIATION_DESCRIPTION := NULL;
     ELSE
      IF gi_catv_rec.article_version_id IS NULL THEN
        gi_catv_rec.article_version_id := Get_Art_Ver_Id(gi_catv_rec.sav_sae_id,gi_catv_rec.sav_sav_release);
      END IF;
      IF gi_catv_rec.b_sav_sae_id IS NULL THEN
        gi_catv_rec.b_sav_sae_id := gi_catv_rec.sav_sae_id;
      END IF;
    END IF;

    -------------------------------------------------

    IF (l_debug = 'Y') THEN
      okc_debug.log('11400: Leaving Default_Record ', 2);
      okc_debug.Reset_Indentation;
    END IF;

  END Default_Record;

-- Start of comments
--
-- Procedure Name  : create_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure create_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_rec	IN	catv_rec_type,
                              x_catv_rec	OUT NOCOPY	catv_rec_type) is
    l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_K_ARTICLE';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
--    l_clob 			clob;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --
    -- code for temporary clob ... start
    --
--    if (dbms_lob.istemporary(p_catv_rec.TEXT) = 1) then
--      DBMS_LOB.CREATETEMPORARY(gi_catv_rec.TEXT,FALSE,DBMS_LOB.CALL);
--      l_clob := p_catv_rec.TEXT;
--      DBMS_LOB.OPEN(l_clob, DBMS_LOB.LOB_READONLY);
--      DBMS_LOB.OPEN(gi_catv_rec.TEXT, DBMS_LOB.LOB_READWRITE);
--      DBMS_LOB.COPY(dest_lob => gi_catv_rec.TEXT,src_lob => l_clob,
--    			amount => dbms_lob.getlength(l_clob));
--      DBMS_LOB.CLOSE(gi_catv_rec.TEXT);
--      DBMS_LOB.CLOSE(l_clob);
--      DBMS_LOB.freetemporary(l_clob);
--    end if;
    --
    -- code for temporary clob ... end
    --

    IF (l_debug = 'Y') THEN
       okc_debug.log('1000: Entered '||l_api_name, 2);
    END IF;

    gi_catv_rec := Migrate( p_catv_rec );

    IF (l_debug = 'Y') THEN
       Dump_Rec( gi_catv_rec );
    END IF;
    --
    -- Prepare record for Create article new group API
    --
    Null_Out_Record(
      p_api_version                => p_api_version,
      x_return_status              => l_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    Default_Record(
      p_api_version                => p_api_version,
      x_return_status              => l_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF (l_debug = 'Y') THEN
       Dump_Rec( gi_catv_rec );
    END IF;
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    --Bug 3341342 Included cat_type
    OKC_K_ARTICLES_GRP.create_article(
      p_api_version                => p_api_version,
      p_init_msg_list              => FND_API.G_FALSE,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data,
      p_id                         => gi_catv_rec.id,
      p_sav_sae_id                 => gi_catv_rec.b_sav_sae_id,
      p_cat_type                   => gi_catv_rec.cat_type,  --Bug 3341342
      p_document_type              => gi_catv_rec.document_type,
      p_document_id                => gi_catv_rec.document_id,
      p_source_flag                => gi_catv_rec.source_flag,
      p_mandatory_yn               => gi_catv_rec.mandatory_yn,
      p_scn_id                     => gi_catv_rec.scn_id,
      p_cle_id                     => gi_catv_rec.cle_id,
      p_label                      => gi_catv_rec.label,
      p_amendment_description      => gi_catv_rec.amendment_description,
      p_article_version_id         => gi_catv_rec.article_version_id,
      p_change_nonstd_yn           => gi_catv_rec.change_nonstd_yn,
      p_orig_system_reference_code => gi_catv_rec.orig_system_reference_code,
      p_orig_system_reference_id1  => gi_catv_rec.orig_system_reference_id1,
      p_orig_system_reference_id2  => gi_catv_rec.orig_system_reference_id2,
      p_display_sequence           => gi_catv_rec.display_sequence,
      p_attribute_category         => gi_catv_rec.attribute_category,
      p_attribute1                 => gi_catv_rec.attribute1,
      p_attribute2                 => gi_catv_rec.attribute2,
      p_attribute3                 => gi_catv_rec.attribute3,
      p_attribute4                 => gi_catv_rec.attribute4,
      p_attribute5                 => gi_catv_rec.attribute5,
      p_attribute6                 => gi_catv_rec.attribute6,
      p_attribute7                 => gi_catv_rec.attribute7,
      p_attribute8                 => gi_catv_rec.attribute8,
      p_attribute9                 => gi_catv_rec.attribute9,
      p_attribute10                => gi_catv_rec.attribute10,
      p_attribute11                => gi_catv_rec.attribute11,
      p_attribute12                => gi_catv_rec.attribute12,
      p_attribute13                => gi_catv_rec.attribute13,
      p_attribute14                => gi_catv_rec.attribute14,
      p_attribute15                => gi_catv_rec.attribute15,
      p_print_text_yn              => gi_catv_rec.print_text_yn,
      p_ref_article_id             => gi_catv_rec.ref_article_id,
      p_ref_article_version_id     => gi_catv_rec.ref_article_version_id,
      x_id                         => gi_catv_rec.id,
      p_mandatory_rwa               => gi_catv_rec.mandatory_rwa
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Set OUT values
    x_catv_rec := get_rec( gi_catv_rec.id );
    g_catv_rec := x_catv_rec;

    IF (l_debug = 'Y') THEN
      okc_debug.log('1000: Leaving '||l_api_name, 2);
      Dump_Rec( x_catv_rec );
    END IF;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
end create_k_article;

-- Start of comments
--
-- Procedure Name  : create_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure create_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_tbl	IN	catv_tbl_type,
                              x_catv_tbl	OUT NOCOPY	catv_tbl_type) is
  c 	NUMBER;
  i 	NUMBER;
  l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    x_return_status:= OKC_API.G_RET_STS_SUCCESS;
    c:=p_catv_tbl.COUNT;
    if (c>0) then
      i := p_catv_tbl.FIRST;
      LOOP
	  create_k_article
       (
			p_api_version	=> p_api_version,
                  p_init_msg_list	=> OKC_API.G_FALSE,
                  x_return_status	=> l_return_status,
                  x_msg_count		=> x_msg_count,
                  x_msg_data		=> x_msg_data,
                  p_catv_rec		=> p_catv_tbl(i),
                  x_catv_rec		=> x_catv_tbl(i)
        );
        if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
          x_return_status := l_return_status;
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
          x_return_status := l_return_status;
        end if;
        c:=c-1;
        EXIT WHEN (c=0);
        i := p_catv_tbl.NEXT(i);
      END LOOP;
    end if;
exception
when others then NULL;
end create_k_article;

-- Start of comments
--
-- Procedure Name  : lock_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure lock_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_rec	IN	catv_rec_type) is
    l_api_name                     CONSTANT VARCHAR2(30) := 'LOCK_K_ARTICLE';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_K_ARTICLES_GRP.lock_row(
      p_api_version 	=> p_api_version,
      p_init_msg_list 	=> OKC_API.G_FALSE,
      x_return_status 	=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      p_id          => p_catv_rec.id,
      p_object_version_number => p_catv_rec.object_version_number
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
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
end lock_k_article;

-- Start of comments
--
-- Procedure Name  : lock_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure lock_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_tbl	IN	catv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
  OKC_API.init_msg_list(p_init_msg_list);
  x_return_status:= OKC_API.G_RET_STS_SUCCESS;
  if (p_catv_tbl.COUNT>0) then
    i := p_catv_tbl.FIRST;
    LOOP
      lock_k_article(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_catv_rec=>p_catv_tbl(i));
      if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
          x_return_status := l_return_status;
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
          x_return_status := l_return_status;
      end if;
      EXIT WHEN (i=p_catv_tbl.LAST);
      i := p_catv_tbl.NEXT(i);
    END LOOP;
  end if;
exception
when others then NULL;
end lock_k_article;

  -------------------------------------------------
  -- PROCEDURE Flip_GMISS_Record - set default values -
  -------------------------------------------------
  PROCEDURE Flip_GMISS_Record IS
  BEGIN

    IF (l_debug = 'Y') THEN
      okc_debug.Set_Indentation(G_PKG_NAME);
      okc_debug.log('11300: Entered Flip_GMISS_Record', 2);
    END IF;

    ----------------------------------------------------------------
    -- Start of GMISS logic flipping
    ----------------------------------------------------------------
    IF (gi_catv_rec.chr_id = G_MISS_NUM) THEN
      gi_catv_rec.chr_id := NULL;
     ELSIF (gi_catv_rec.chr_id IS NULL) THEN
      gi_catv_rec.chr_id := G_MISS_NUM;
    END IF;

    IF (gi_catv_rec.cle_id = G_MISS_NUM) THEN
      gi_catv_rec.cle_id := NULL;
     ELSIF (gi_catv_rec.cle_id IS NULL) THEN
      gi_catv_rec.cle_id := G_MISS_NUM;
    END IF;

    IF (gi_catv_rec.cat_id = G_MISS_NUM) THEN
      gi_catv_rec.cat_id := NULL;
     ELSIF (gi_catv_rec.cat_id IS NULL) THEN
      gi_catv_rec.cat_id := G_MISS_NUM;
    END IF;

    IF (gi_catv_rec.sfwt_flag = G_MISS_CHAR) THEN
      gi_catv_rec.sfwt_flag := NULL;
     ELSIF (gi_catv_rec.sfwt_flag IS NULL) THEN
      gi_catv_rec.sfwt_flag := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.sav_sae_id = G_MISS_NUM) THEN
      gi_catv_rec.sav_sae_id := NULL;
     ELSIF (gi_catv_rec.sav_sae_id IS NULL) THEN
      gi_catv_rec.sav_sae_id := G_MISS_NUM;
    END IF;

    IF (gi_catv_rec.sav_sav_release = G_MISS_CHAR) THEN
      gi_catv_rec.sav_sav_release := NULL;
     ELSIF (gi_catv_rec.sav_sav_release IS NULL) THEN
      gi_catv_rec.sav_sav_release := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.sbt_code = G_MISS_CHAR) THEN
      gi_catv_rec.sbt_code := NULL;
     ELSIF (gi_catv_rec.sbt_code IS NULL) THEN
      gi_catv_rec.sbt_code := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.dnz_chr_id = G_MISS_NUM) THEN
      gi_catv_rec.dnz_chr_id := NULL;
     ELSIF (gi_catv_rec.dnz_chr_id IS NULL) THEN
      gi_catv_rec.dnz_chr_id := G_MISS_NUM;
    END IF;

    IF (gi_catv_rec.comments = G_MISS_CHAR) THEN
      gi_catv_rec.comments := NULL;
     ELSIF (gi_catv_rec.comments IS NULL) THEN
      gi_catv_rec.comments := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.fulltext_yn = G_MISS_CHAR) THEN
      gi_catv_rec.fulltext_yn := NULL;
     ELSIF (gi_catv_rec.fulltext_yn IS NULL) THEN
      gi_catv_rec.fulltext_yn := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.variation_description = G_MISS_CHAR) THEN
      gi_catv_rec.variation_description := NULL;
     ELSIF (gi_catv_rec.variation_description IS NULL) THEN
      gi_catv_rec.variation_description := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.name = G_MISS_CHAR) THEN
      gi_catv_rec.name := NULL;
     ELSIF (gi_catv_rec.name IS NULL) THEN
      gi_catv_rec.name := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.cat_type = G_MISS_CHAR) THEN
      gi_catv_rec.cat_type := NULL;
     ELSIF (gi_catv_rec.cat_type IS NULL) THEN
      gi_catv_rec.cat_type := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.document_type = G_MISS_CHAR) THEN
      gi_catv_rec.document_type := NULL;
     ELSIF (gi_catv_rec.document_type IS NULL) THEN
      gi_catv_rec.document_type := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.document_id = G_MISS_NUM) THEN
      gi_catv_rec.document_id := NULL;
     ELSIF (gi_catv_rec.document_id IS NULL) THEN
      gi_catv_rec.document_id := G_MISS_NUM;
    END IF;

    IF (gi_catv_rec.source_flag = G_MISS_CHAR) THEN
      gi_catv_rec.source_flag := NULL;
     ELSIF (gi_catv_rec.source_flag IS NULL) THEN
      gi_catv_rec.source_flag := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.mandatory_yn = G_MISS_CHAR) THEN
      gi_catv_rec.mandatory_yn := NULL;
     ELSIF (gi_catv_rec.mandatory_yn IS NULL) THEN
      gi_catv_rec.mandatory_yn := G_MISS_CHAR;
    END IF;

IF (gi_catv_rec.mandatory_rwa = G_MISS_CHAR) THEN
      gi_catv_rec.mandatory_rwa := NULL;
     ELSIF (gi_catv_rec.mandatory_rwa IS NULL) THEN
      gi_catv_rec.mandatory_rwa := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.scn_id = G_MISS_NUM) THEN
      gi_catv_rec.scn_id := NULL;
     ELSIF (gi_catv_rec.scn_id IS NULL) THEN
      gi_catv_rec.scn_id := G_MISS_NUM;
    END IF;

    IF (gi_catv_rec.label = G_MISS_CHAR) THEN
      gi_catv_rec.label := NULL;
     ELSIF (gi_catv_rec.label IS NULL) THEN
      gi_catv_rec.label := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.amendment_description = G_MISS_CHAR) THEN
      gi_catv_rec.amendment_description := NULL;
     ELSIF (gi_catv_rec.amendment_description IS NULL) THEN
      gi_catv_rec.amendment_description := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.amendment_operation_code = G_MISS_CHAR) THEN
      gi_catv_rec.amendment_operation_code := NULL;
     ELSIF (gi_catv_rec.amendment_operation_code IS NULL) THEN
      gi_catv_rec.amendment_operation_code := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.article_version_id = G_MISS_NUM) THEN
      gi_catv_rec.article_version_id := NULL;
     ELSIF (gi_catv_rec.article_version_id IS NULL) THEN
      gi_catv_rec.article_version_id := G_MISS_NUM;
    END IF;

    IF (gi_catv_rec.change_nonstd_yn = G_MISS_CHAR) THEN
      gi_catv_rec.change_nonstd_yn := NULL;
     ELSIF (gi_catv_rec.change_nonstd_yn IS NULL) THEN
      gi_catv_rec.change_nonstd_yn := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.orig_system_reference_code = G_MISS_CHAR) THEN
      gi_catv_rec.orig_system_reference_code := NULL;
     ELSIF (gi_catv_rec.orig_system_reference_code IS NULL) THEN
      gi_catv_rec.orig_system_reference_code := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.orig_system_reference_id1 = G_MISS_NUM) THEN
      gi_catv_rec.orig_system_reference_id1 := NULL;
     ELSIF (gi_catv_rec.orig_system_reference_id1 IS NULL) THEN
      gi_catv_rec.orig_system_reference_id1 := G_MISS_NUM;
    END IF;

    IF (gi_catv_rec.orig_system_reference_id2 = G_MISS_NUM) THEN
      gi_catv_rec.orig_system_reference_id2 := NULL;
     ELSIF (gi_catv_rec.orig_system_reference_id2 IS NULL) THEN
      gi_catv_rec.orig_system_reference_id2 := G_MISS_NUM;
    END IF;

    IF (gi_catv_rec.display_sequence = G_MISS_NUM) THEN
      gi_catv_rec.display_sequence := NULL;
     ELSIF (gi_catv_rec.display_sequence IS NULL) THEN
      gi_catv_rec.display_sequence := G_MISS_NUM;
    END IF;

    IF (gi_catv_rec.print_text_yn = G_MISS_CHAR) THEN
      gi_catv_rec.print_text_yn := NULL;
     ELSIF (gi_catv_rec.print_text_yn IS NULL) THEN
      gi_catv_rec.print_text_yn := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.summary_amend_operation_code = G_MISS_CHAR) THEN
      gi_catv_rec.summary_amend_operation_code := NULL;
     ELSIF (gi_catv_rec.summary_amend_operation_code IS NULL) THEN
      gi_catv_rec.summary_amend_operation_code := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.ref_article_id = G_MISS_NUM) THEN
      gi_catv_rec.ref_article_id := NULL;
     ELSIF (gi_catv_rec.ref_article_id IS NULL) THEN
      gi_catv_rec.ref_article_id := G_MISS_NUM;
    END IF;

    IF (gi_catv_rec.ref_article_version_id = G_MISS_NUM) THEN
      gi_catv_rec.ref_article_version_id := NULL;
     ELSIF (gi_catv_rec.ref_article_version_id IS NULL) THEN
      gi_catv_rec.ref_article_version_id := G_MISS_NUM;
    END IF;

    IF (gi_catv_rec.attribute_category = G_MISS_CHAR) THEN
      gi_catv_rec.attribute_category := NULL;
     ELSIF (gi_catv_rec.attribute_category IS NULL) THEN
      gi_catv_rec.attribute_category := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.attribute1 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute1 := NULL;
     ELSIF (gi_catv_rec.attribute1 IS NULL) THEN
      gi_catv_rec.attribute1 := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.attribute2 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute2 := NULL;
     ELSIF (gi_catv_rec.attribute2 IS NULL) THEN
      gi_catv_rec.attribute2 := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.attribute3 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute3 := NULL;
     ELSIF (gi_catv_rec.attribute3 IS NULL) THEN
      gi_catv_rec.attribute3 := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.attribute4 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute4 := NULL;
     ELSIF (gi_catv_rec.attribute4 IS NULL) THEN
      gi_catv_rec.attribute4 := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.attribute5 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute5 := NULL;
     ELSIF (gi_catv_rec.attribute5 IS NULL) THEN
      gi_catv_rec.attribute5 := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.attribute6 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute6 := NULL;
     ELSIF (gi_catv_rec.attribute6 IS NULL) THEN
      gi_catv_rec.attribute6 := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.attribute7 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute7 := NULL;
     ELSIF (gi_catv_rec.attribute7 IS NULL) THEN
      gi_catv_rec.attribute7 := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.attribute8 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute8 := NULL;
     ELSIF (gi_catv_rec.attribute8 IS NULL) THEN
      gi_catv_rec.attribute8 := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.attribute9 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute9 := NULL;
     ELSIF (gi_catv_rec.attribute9 IS NULL) THEN
      gi_catv_rec.attribute9 := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.attribute10 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute10 := NULL;
     ELSIF (gi_catv_rec.attribute10 IS NULL) THEN
      gi_catv_rec.attribute10 := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.attribute11 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute11 := NULL;
     ELSIF (gi_catv_rec.attribute11 IS NULL) THEN
      gi_catv_rec.attribute11 := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.attribute12 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute12 := NULL;
     ELSIF (gi_catv_rec.attribute12 IS NULL) THEN
      gi_catv_rec.attribute12 := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.attribute13 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute13 := NULL;
     ELSIF (gi_catv_rec.attribute13 IS NULL) THEN
      gi_catv_rec.attribute13 := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.attribute14 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute14 := NULL;
     ELSIF (gi_catv_rec.attribute14 IS NULL) THEN
      gi_catv_rec.attribute14 := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.attribute15 = G_MISS_CHAR) THEN
      gi_catv_rec.attribute15 := NULL;
     ELSIF (gi_catv_rec.attribute15 IS NULL) THEN
      gi_catv_rec.attribute15 := G_MISS_CHAR;
    END IF;

    IF (gi_catv_rec.object_version_number = G_MISS_NUM) THEN
      gi_catv_rec.object_version_number := NULL;
    END IF;
    ----------------------------------------------------------------
    -- End of GMISS logic flipping
    ----------------------------------------------------------------

    IF (l_debug = 'Y') THEN
      okc_debug.log('11400: Leaving  Flip_GMISS_Record ', 2);
      okc_debug.Reset_Indentation;
    END IF;

  END Flip_GMISS_Record;

-- Start of comments
--
-- Procedure Name  : update_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure update_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_rec	IN	catv_rec_type,
                              x_catv_rec	OUT NOCOPY	catv_rec_type) is
    l_api_name                CONSTANT VARCHAR2(30) := 'UPDATE_K_ARTICLE';
    l_return_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_catv_rec                catv_rec_type;
  begin
    l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                                G_PKG_NAME,
                                                p_init_msg_list,
                                                G_API_VERSION,
                                                p_api_version,
                                                G_SCOPE,
                                                x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --
    -- code for temporary clob ... start
    --
--    if (dbms_lob.istemporary(p_catv_rec.TEXT) = 1) then
--      DBMS_LOB.CREATETEMPORARY(gi_catv_rec.TEXT,FALSE,DBMS_LOB.CALL);
--      l_clob := p_catv_rec.TEXT;
--      DBMS_LOB.OPEN(l_clob, DBMS_LOB.LOB_READONLY);
--      DBMS_LOB.OPEN(gi_catv_rec.TEXT, DBMS_LOB.LOB_READWRITE);
--      DBMS_LOB.COPY(dest_lob => gi_catv_rec.TEXT,src_lob => l_clob,
--    			amount => dbms_lob.getlength(l_clob));
--      DBMS_LOB.CLOSE(gi_catv_rec.TEXT);
--      DBMS_LOB.CLOSE(l_clob);
--      DBMS_LOB.freetemporary(l_clob);
--    end if;
    --
    -- code for temporary clob ... end
    --
    IF (l_debug = 'Y') THEN
       okc_debug.log('1000: Entered '||l_api_name, 2);
       Dump_Rec( p_catv_rec );
    END IF;

    g_catv_rec := p_catv_rec;
    gi_catv_rec := Migrate( p_catv_rec );
    --
    -- Prepare record for Create article new group API
    --
    Default_Record(
      p_api_version                => p_api_version,
      x_return_status              => l_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    Flip_GMISS_Record;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1000: before update_article', 2);
       Dump_Rec( gi_catv_rec );
    END IF;

    OKC_K_ARTICLES_GRP.update_article(
      p_api_version                => p_api_version,
      p_init_msg_list              => OKC_API.G_FALSE,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data,
      p_id                         => gi_catv_rec.id,
      p_sav_sae_id                 => gi_catv_rec.b_sav_sae_id,
      p_document_type              => gi_catv_rec.document_type,
      p_document_id                => gi_catv_rec.document_id,
      p_source_flag                => gi_catv_rec.source_flag,
      p_mandatory_yn               => gi_catv_rec.mandatory_yn,
      p_scn_id                     => gi_catv_rec.scn_id,
      p_label                      => gi_catv_rec.label,
      p_amendment_description      => gi_catv_rec.amendment_description,
      p_article_version_id         => gi_catv_rec.article_version_id,
      p_change_nonstd_yn           => gi_catv_rec.change_nonstd_yn,
      p_orig_system_reference_code => gi_catv_rec.orig_system_reference_code,
      p_orig_system_reference_id1  => gi_catv_rec.orig_system_reference_id1,
      p_orig_system_reference_id2  => gi_catv_rec.orig_system_reference_id2,
      p_display_sequence           => gi_catv_rec.display_sequence,
      p_attribute_category         => gi_catv_rec.attribute_category,
      p_attribute1                 => gi_catv_rec.attribute1,
      p_attribute2                 => gi_catv_rec.attribute2,
      p_attribute3                 => gi_catv_rec.attribute3,
      p_attribute4                 => gi_catv_rec.attribute4,
      p_attribute5                 => gi_catv_rec.attribute5,
      p_attribute6                 => gi_catv_rec.attribute6,
      p_attribute7                 => gi_catv_rec.attribute7,
      p_attribute8                 => gi_catv_rec.attribute8,
      p_attribute9                 => gi_catv_rec.attribute9,
      p_attribute10                => gi_catv_rec.attribute10,
      p_attribute11                => gi_catv_rec.attribute11,
      p_attribute12                => gi_catv_rec.attribute12,
      p_attribute13                => gi_catv_rec.attribute13,
      p_attribute14                => gi_catv_rec.attribute14,
      p_attribute15                => gi_catv_rec.attribute15,
      p_print_text_yn              => gi_catv_rec.print_text_yn,
      p_ref_article_id              => gi_catv_rec.ref_article_id,
      p_ref_article_version_id      => gi_catv_rec.ref_article_version_id,
      p_object_version_number      => gi_catv_rec.object_version_number,
       p_mandatory_rwa              => gi_catv_rec.mandatory_rwa

  	);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Set OUT values
    x_catv_rec := get_rec( gi_catv_rec.id );
    g_catv_rec := x_catv_rec;

    IF (l_debug = 'Y') THEN
      okc_debug.log('1000: Leaving '||l_api_name, 2);
      Dump_Rec( x_catv_rec );
    END IF;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       IF (l_debug = 'Y') THEN
         okc_debug.log('1000: Leaving '||l_api_name||' because of G_EXCEPTION_ERROR ', 2);
       END IF;
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       IF (l_debug = 'Y') THEN
         okc_debug.log('1000: Leaving '||l_api_name||' because of G_EXCEPTION_UNEXPECTED_ERROR ', 2);
       END IF;
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
       IF (l_debug = 'Y') THEN
         okc_debug.log('500: Leaving '||l_api_name||' because of EXCEPTION: '||sqlerrm, 2);
       END IF;
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
end update_k_article;

-- Start of comments
--
-- Procedure Name  : update_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure update_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_tbl	IN	catv_tbl_type,
                              x_catv_tbl	OUT NOCOPY	catv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_catv_tbl.COUNT>0) then
        i := p_catv_tbl.FIRST;
        LOOP

	    update_k_article(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_catv_rec=> p_catv_tbl(i),
                              x_catv_rec=>x_catv_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_catv_tbl.LAST);
          i := p_catv_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end update_k_article;

-- Start of comments
--
-- Procedure Name  : delete_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure delete_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_rec	IN	catv_rec_type) is
    l_api_name                     CONSTANT VARCHAR2(30) := 'DELETE_K_ARTICLE';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  begin
    l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                                G_PKG_NAME,
                                                p_init_msg_list,
                                                G_API_VERSION,
                                                p_api_version,
                                                G_SCOPE,
                                                x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_K_ARTICLES_GRP.delete_article(
        p_api_version 	=> p_api_version,
        p_init_msg_list 	=> OKC_API.G_FALSE,
        x_return_status 	=> x_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data,
        p_validation_string  => NULL,
        p_id          => p_catv_rec.id,
        p_object_version_number => p_catv_rec.object_version_number
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
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
end delete_k_article;

-- Start of comments
--
-- Procedure Name  : delete_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure delete_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_tbl	IN	catv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
  OKC_API.init_msg_list(p_init_msg_list);
  x_return_status:= OKC_API.G_RET_STS_SUCCESS;
  if (p_catv_tbl.COUNT>0) then
    i := p_catv_tbl.FIRST;
    LOOP
      delete_k_article(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_catv_rec=>p_catv_tbl(i));
      if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
          x_return_status := l_return_status;
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
          x_return_status := l_return_status;
      end if;
      EXIT WHEN (i=p_catv_tbl.LAST);
      i := p_catv_tbl.NEXT(i);
    END LOOP;
  end if;
exception
when others then NULL;
end delete_k_article;

-- Start of comments
--
-- Procedure Name  : validate_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_rec	IN	catv_rec_type) is
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALIDATE_K_ARTICLE';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  begin
    l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                                G_PKG_NAME,
                                                p_init_msg_list,
                                                G_API_VERSION,
                                                p_api_version,
                                                G_SCOPE,
                                                x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    gi_catv_rec := Migrate( p_catv_rec );

    OKC_K_ARTICLES_GRP.validate_row(
      p_api_version                => p_api_version,
      p_init_msg_list              => OKC_API.G_FALSE,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data,
      p_id                         => gi_catv_rec.id,
      p_sav_sae_id                 => gi_catv_rec.sav_sae_id,
      p_document_type              => gi_catv_rec.document_type,
      p_document_id                => gi_catv_rec.document_id,
      p_source_flag                => gi_catv_rec.source_flag,
      p_mandatory_yn               => gi_catv_rec.mandatory_yn,
      p_mandatory_rwa              => gi_catv_rec.mandatory_rwa,
      p_scn_id                     => gi_catv_rec.scn_id,
      p_label                      => gi_catv_rec.label,
      p_amendment_description      => gi_catv_rec.amendment_description,
      p_amendment_operation_code   => gi_catv_rec.amendment_operation_code,
      p_article_version_id         => gi_catv_rec.article_version_id,
      p_change_nonstd_yn           => gi_catv_rec.change_nonstd_yn,
      p_orig_system_reference_code => gi_catv_rec.orig_system_reference_code,
      p_orig_system_reference_id1  => gi_catv_rec.orig_system_reference_id1,
      p_orig_system_reference_id2  => gi_catv_rec.orig_system_reference_id2,
      p_display_sequence           => gi_catv_rec.display_sequence,
      p_attribute_category         => gi_catv_rec.attribute_category,
      p_attribute1                 => gi_catv_rec.attribute1,
      p_attribute2                 => gi_catv_rec.attribute2,
      p_attribute3                 => gi_catv_rec.attribute3,
      p_attribute4                 => gi_catv_rec.attribute4,
      p_attribute5                 => gi_catv_rec.attribute5,
      p_attribute6                 => gi_catv_rec.attribute6,
      p_attribute7                 => gi_catv_rec.attribute7,
      p_attribute8                 => gi_catv_rec.attribute8,
      p_attribute9                 => gi_catv_rec.attribute9,
      p_attribute10                => gi_catv_rec.attribute10,
      p_attribute11                => gi_catv_rec.attribute11,
      p_attribute12                => gi_catv_rec.attribute12,
      p_attribute13                => gi_catv_rec.attribute13,
      p_attribute14                => gi_catv_rec.attribute14,
      p_attribute15                => gi_catv_rec.attribute15,
      p_print_text_yn              => gi_catv_rec.print_text_yn,
      p_summary_amend_operation_code => gi_catv_rec.summary_amend_operation_code,
      p_ref_article_id              => gi_catv_rec.ref_article_id,
      p_ref_article_version_id      => gi_catv_rec.ref_article_version_id,
      p_object_version_number      => gi_catv_rec.object_version_number
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
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
end validate_k_article;

-- Start of comments
--
-- Procedure Name  : validate_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_tbl	IN	catv_tbl_type) is
  c 	NUMBER;
  i 	NUMBER;
  l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    x_return_status:= OKC_API.G_RET_STS_SUCCESS;
    c:=p_catv_tbl.COUNT;
    if (c>0) then
      i := p_catv_tbl.FIRST;
      LOOP
	  validate_k_article(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_catv_rec=>p_catv_tbl(i));
        if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
          x_return_status := l_return_status;
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
          x_return_status := l_return_status;
        end if;
        c:=c-1;
        EXIT WHEN (c=0);
        i := p_catv_tbl.NEXT(i);
      END LOOP;
    end if;
end validate_k_article;

-- Start of comments
--
-- Procedure Name  : create_article_translation
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  procedure create_article_translation(p_api_version	 IN	NUMBER,
                         p_init_msg_list IN	VARCHAR2 ,
                         x_return_status OUT NOCOPY	VARCHAR2,
                         x_msg_count	 OUT NOCOPY	NUMBER,
                         x_msg_data	 OUT NOCOPY	VARCHAR2,
                         p_atnv_rec	 IN	atnv_rec_type,
                         x_atnv_rec	 OUT NOCOPY	atnv_rec_type) is
   begin
    OKC_API.init_msg_list(p_init_msg_list);
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('400: Entered create_article_translation - DUMMY procedure', 2);
    END IF;
--    We won't create a record - keep g_atnv_rec empty
--    g_atnv_rec := p_atnv_rec;
--    x_atnv_rec := p_atnv_rec;
    x_msg_count := 0;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
  end create_article_translation;

-- Start of comments
--
-- Procedure Name  : create_article_translation
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  procedure create_article_translation(p_api_version	 IN	NUMBER,
                         p_init_msg_list IN	VARCHAR2 ,
                         x_return_status OUT NOCOPY	VARCHAR2,
                         x_msg_count	 OUT NOCOPY	NUMBER,
                         x_msg_data	 OUT NOCOPY	VARCHAR2,
                         p_atnv_tbl	 IN	atnv_tbl_type,
                         x_atnv_tbl	 OUT NOCOPY	atnv_tbl_type) is
   begin
    OKC_API.init_msg_list(p_init_msg_list);
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('400: Entered create_article_translation - DUMMY procedure', 2);
    END IF;
--    We won't create a record - keep g_atnv_rec empty
--    g_atnv_rec := p_atnv_rec;
--    x_atnv_rec := p_atnv_rec;
    x_msg_count := 0;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
  end create_article_translation;

-- Start of comments
--
-- Procedure Name  : lock_article_translation
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  procedure lock_article_translation(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_atnv_rec	IN	atnv_rec_type) is
   begin
    OKC_API.init_msg_list(p_init_msg_list);
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('400: Entered lock_article_translation - DUMMY procedure', 2);
    END IF;
    x_msg_count := 0;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
  end lock_article_translation;

-- Start of comments
--
-- Procedure Name  : lock_article_translation
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  procedure lock_article_translation(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_atnv_tbl	IN	atnv_tbl_type) is
   begin
    OKC_API.init_msg_list(p_init_msg_list);
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('400: Entered lock_article_translation - DUMMY procedure', 2);
    END IF;
    x_msg_count := 0;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
  end lock_article_translation;

-- Start of comments
--
-- Procedure Name  : delete_article_translation
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  procedure delete_article_translation(p_api_version	 IN	NUMBER,
                         p_init_msg_list IN	VARCHAR2 ,
                         x_return_status OUT NOCOPY	VARCHAR2,
                         x_msg_count	 OUT NOCOPY	NUMBER,
                         x_msg_data	 OUT NOCOPY	VARCHAR2,
                         p_atnv_rec	 IN	atnv_rec_type) is
   begin
    OKC_API.init_msg_list(p_init_msg_list);
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('400: Entered delete_article_translation - DUMMY procedure', 2);
    END IF;
    x_msg_count := 0;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
  end delete_article_translation;

-- Start of comments
--
-- Procedure Name  : delete_article_translation
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  procedure delete_article_translation(p_api_version	 IN	NUMBER,
                         p_init_msg_list IN	VARCHAR2 ,
                         x_return_status OUT NOCOPY	VARCHAR2,
                         x_msg_count	 OUT NOCOPY	NUMBER,
                         x_msg_data	 OUT NOCOPY	VARCHAR2,
                         p_atnv_tbl	 IN	atnv_tbl_type) is
   begin
    OKC_API.init_msg_list(p_init_msg_list);
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('400: Entered delete_article_translation - DUMMY procedure', 2);
    END IF;
    x_msg_count := 0;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
  end delete_article_translation;

-- Start of comments
--
-- Procedure Name  : validate_article_translation
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  procedure validate_article_translation(p_api_version   IN	NUMBER,
                           p_init_msg_list IN	VARCHAR2 ,
                           x_return_status OUT NOCOPY	VARCHAR2,
                           x_msg_count	   OUT NOCOPY	NUMBER,
                           x_msg_data	   OUT NOCOPY	VARCHAR2,
                           p_atnv_rec	   IN	atnv_rec_type) is
   begin
    OKC_API.init_msg_list(p_init_msg_list);
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('400: Entered validate_article_translation - DUMMY procedure', 2);
    END IF;
    x_msg_count := 0;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
  end validate_article_translation;

-- Start of comments
--
-- Procedure Name  : validate_article_translation
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  procedure validate_article_translation(p_api_version   IN	NUMBER,
                           p_init_msg_list IN	VARCHAR2 ,
                           x_return_status OUT NOCOPY	VARCHAR2,
                           x_msg_count	   OUT NOCOPY	NUMBER,
                           x_msg_data	   OUT NOCOPY	VARCHAR2,
                           p_atnv_tbl	   IN	atnv_tbl_type) is
   begin
    OKC_API.init_msg_list(p_init_msg_list);
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('400: Entered validate_article_translation - DUMMY procedure', 2);
    END IF;
    x_msg_count := 0;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
  end validate_article_translation;

-- Start of comments
--
-- Procedure Name  : std_art_name
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
function std_art_name(p_sav_sae_id IN NUMBER) return varchar2 is
l_name varchar2(150);
cursor c1 is
  select name
  from OKC_STD_ARTICLES_V
  where ID = p_sav_sae_id;
begin
  open c1;
  fetch c1 into l_name;
  close c1;
  return l_name;
end std_art_name;

end OKC_K_ARTICLE_PUB;

/
