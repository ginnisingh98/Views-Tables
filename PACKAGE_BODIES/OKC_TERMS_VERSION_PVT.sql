--------------------------------------------------------
--  DDL for Package Body OKC_TERMS_VERSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMS_VERSION_PVT" AS
/* $Header: OKCVDVRB.pls 120.2 2006/04/25 15:17:57 rvohra noship $ */
  l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_TERMS_VERSION_PVT';
  G_TMPL_DOC_TYPE              CONSTANT   VARCHAR2(30)  := OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE;
  G_AMEND_CODE_DELETED         CONSTANT   VARCHAR2(30)  := 'DELETED';
  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
  G_MISS_CHAR                  CONSTANT   VARCHAR2(1) := FND_API.G_MISS_CHAR;
  G_MISS_NUM                   CONSTANT   NUMBER      := FND_API.G_MISS_NUM;
  G_MISS_DATE                  CONSTANT   DATE        := FND_API.G_MISS_DATE;

  G_RET_STS_SUCCESS            CONSTANT   varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   varchar2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_DBG_LEVEL							  NUMBER 		:= FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_PROC_LEVEL							  NUMBER		:= FND_LOG.LEVEL_PROCEDURE;
  G_EXCP_LEVEL							  NUMBER		:= FND_LOG.LEVEL_EXCEPTION;

--<<<<<<<<<<<<<<<<<<<<<<<<<<< INTERNAL PROCEDURES <<<<<<<<<<<<<<<<<<<<<<<<<<<

-->>>>>>>>>>>>>>>>>>>>>>>>>>> INTERNAL PROCEDURES >>>>>>>>>>>>>>>>>>>>>>>>>>>

--<<<<<<<<<<<<<<<<<<<<<<<<<<< EXTERNAL PROCEDURES <<<<<<<<<<<<<<<<<<<<<<<<<<<
 Procedure clear_amendment (
    x_return_status    OUT NOCOPY VARCHAR2,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_keep_summary     IN  VARCHAR2
  ) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'clear_amendment';
    l_change_nonstd     okc_k_articles_b.change_nonstd_yn%TYPE;
    --Fix for bug# 3990983
    l_contract_source_code OKC_TEMPLATE_USAGES.CONTRACT_SOURCE_CODE%TYPE;

    CURSOR scn_crs IS
     SELECT id, object_version_number,amendment_operation_code,summary_amend_operation_code
       FROM okc_sections_b
      WHERE document_type = p_doc_type AND document_id = p_doc_id
       AND (amendment_operation_code IS NOT NULL OR amendment_description IS NOT NULL OR summary_amend_operation_code IS NOT NULL);

    CURSOR cat_crs IS
     SELECT kart.id, kart.object_version_number,kart.amendment_operation_code,kart.summary_amend_operation_code,
            DECODE(art.standard_yn,'N','Y',NULL) change_nonstd_yn
       FROM okc_k_articles_b kart,okc_articles_all art
      WHERE kart.document_type = p_doc_type AND kart.document_id = p_doc_id
       AND kart.sav_sae_id = art.article_id
       AND (kart.amendment_operation_code IS NOT NULL OR kart.amendment_description IS NOT NULL
            OR kart.summary_amend_operation_code IS NOT NULL OR art.standard_yn='N');

    CURSOR scn_incremental_crs IS
     SELECT id, object_version_number, amendment_operation_code
       FROM okc_sections_b
      WHERE document_type = p_doc_type AND document_id = p_doc_id
       AND (amendment_operation_code IS NOT NULL OR amendment_description IS NOT NULL);

    CURSOR l_del_scn_crs IS
     SELECT id, object_version_number
       FROM okc_sections_b
      WHERE document_type = p_doc_type AND document_id = p_doc_id
       AND amendment_operation_code = G_AMEND_CODE_DELETED
       AND SUMMARY_AMEND_OPERATION_CODE  IS NULL;

    CURSOR cat_incremental_crs IS
     SELECT id, kart.object_version_number, amendment_operation_code,standard_yn
       FROM okc_k_articles_b kart,okc_articles_all
      WHERE document_type = p_doc_type AND document_id = p_doc_id
       AND  sav_sae_id = article_id
       AND (amendment_operation_code IS NOT NULL
         OR standard_yn='N');

    CURSOR l_del_cat_crs IS
     SELECT id, object_version_number
       FROM okc_k_articles_b
      WHERE document_type = p_doc_type AND document_id = p_doc_id
       AND amendment_operation_code = G_AMEND_CODE_DELETED
       AND SUMMARY_AMEND_OPERATION_CODE  IS NULL;

-- Fix for bug# 3990983
-- Cursor to fetch the contract_source_code for the given document_type, document_id
    CURSOR l_ctrt_src_crs IS
      SELECT contract_source_code
	  FROM okc_template_usages
	  WHERE document_type = p_doc_type AND document_id = p_doc_id;
BEGIN
x_return_status :=  G_RET_STS_SUCCESS;
/* IF (l_debug = 'Y') THEN
    Okc_Debug.Log('100: Entered clear_amendment', 2);
END IF; */

IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '100: Entered clear_amendment' );
END IF;


IF p_keep_summary = 'N' THEN

/* IF (l_debug = 'Y') THEN
    Okc_Debug.Log('110: p_keep_summary=N', 2);
 END IF; */

IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '110: p_keep_summary=N' );
END IF;

 FOR cr in scn_crs LOOP
    IF cr.amendment_operation_code=G_AMEND_CODE_DELETED OR
       cr.summary_amend_operation_code=G_AMEND_CODE_DELETED THEN
        --------------------------------------------
        -- Delete section
        --------------------------------------------
        Okc_Terms_Sections_Pvt.delete_row(
          x_return_status         => x_return_status,
          p_id                    => cr.id,
          p_object_version_number => cr.object_version_number
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------

        --------------------------------------------
        -- Delete articles
        --------------------------------------------
        Okc_K_Articles_Pvt.Delete_Set(
          x_return_status         => x_return_status,
          p_scn_id                => cr.id
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------

        --------------------------------------------
        -- Delete variables
        --------------------------------------------
        Okc_K_Art_Variables_Pvt.Delete_Set(
          x_return_status         => x_return_status,
          p_scn_id                => cr.id
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
    ELSE
      --------------------------------------------
        -- Update section
        --------------------------------------------
        Okc_Terms_Sections_Pvt.Update_Row(
          x_return_status            => x_return_status,
          p_id                       => cr.id,
          p_amendment_operation_code => G_MISS_CHAR,
          p_summary_amend_operation_code => G_MISS_CHAR,
          p_amendment_description    => G_MISS_CHAR,
          p_last_amendment_date      => G_MISS_DATE,
          p_last_amended_by          => G_MISS_NUM,
          p_object_version_number    => cr.object_version_number
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------
    END IF;
  END LOOP;


 FOR cr in cat_crs LOOP
    IF cr.amendment_operation_code=G_AMEND_CODE_DELETED OR
       cr.summary_amend_operation_code=G_AMEND_CODE_DELETED THEN

        --------------------------------------------
        -- Delete article
        --------------------------------------------
        Okc_k_articles_pvt.delete_row(
          x_return_status         => x_return_status,
          p_id                    => cr.id,
          p_object_version_number => cr.object_version_number
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------

        --------------------------------------------
        -- Delete variables
        --------------------------------------------
        Okc_K_Art_Variables_Pvt.Delete_Set(
          x_return_status         => x_return_status,
          p_cat_id                => cr.id
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------
    ELSE
      --------------------------------------------
        -- Update article
        --------------------------------------------
        Okc_k_articles_pvt.Update_Row(
          x_return_status            => x_return_status,
          p_id                       => cr.id,
          p_amendment_operation_code => G_MISS_CHAR,
          p_change_nonstd_yn         => cr.change_nonstd_yn,
          p_summary_amend_operation_code => G_MISS_CHAR,
          p_amendment_description    => G_MISS_CHAR,
          p_last_amendment_date      => G_MISS_DATE,
          p_last_amended_by          => G_MISS_NUM,
          p_print_text_yn            => 'N',
          p_object_version_number    => cr.object_version_number
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------
    END IF;
  END LOOP;

ELSE  -- p_keep_summary = Y clear only inceramental amendments

/* IF (l_debug = 'Y') THEN
     Okc_Debug.Log('210: p_keep_summary=Y ', 2);
 END IF; */

IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '210: p_keep_summary=Y' );
END IF;

    FOR cr in l_del_scn_crs LOOP
        --------------------------------------------
        -- Delete section
        --------------------------------------------
        Okc_Terms_Sections_Pvt.delete_row(
          x_return_status         => x_return_status,
          p_id                    => cr.id,
          p_object_version_number => cr.object_version_number
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------

        --------------------------------------------
        -- Delete articles
        --------------------------------------------
        Okc_K_Articles_Pvt.Delete_Set(
          x_return_status         => x_return_status,
          p_scn_id                => cr.id
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------

        --------------------------------------------
        -- Delete variables
        --------------------------------------------
        Okc_K_Art_Variables_Pvt.Delete_Set(
          x_return_status         => x_return_status,
          p_scn_id                => cr.id
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;

    END LOOP;

    FOR cr in l_del_cat_crs LOOP
        --------------------------------------------
        -- Delete article
        --------------------------------------------
        Okc_K_Articles_Pvt.Delete_Row(
          x_return_status         => x_return_status,
          p_id                    => cr.id,
          p_object_version_number => cr.object_version_number
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------

        --------------------------------------------
        -- Delete variables
        --------------------------------------------
        Okc_K_Art_Variables_Pvt.Delete_Set(
          x_return_status         => x_return_status,
          p_cat_id                => cr.id
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------
    END LOOP;

    FOR cr IN scn_incremental_crs LOOP
        --------------------------------------------
        -- Update section
        --------------------------------------------
        Okc_Terms_Sections_Pvt.Update_Row(
          x_return_status            => x_return_status,
          p_id                       => cr.id,
          p_amendment_operation_code => G_MISS_CHAR,
          p_last_amendment_date      => G_MISS_DATE,
          p_last_amended_by          => G_MISS_NUM,
          p_object_version_number    => cr.object_version_number
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------
    END LOOP;

    FOR cr IN cat_incremental_crs LOOP
         select decode(cr.standard_yn,'N','Y',NULL)
                into l_change_nonstd from dual;
            --------------------------------------------
            -- Update article
            --------------------------------------------
            Okc_K_Articles_Pvt.Update_Row(
              x_return_status            => x_return_status,
              p_id                       => cr.id,
              p_amendment_operation_code => G_MISS_CHAR,
              p_change_nonstd_yn         => l_change_nonstd,
              p_last_amendment_date      => G_MISS_DATE,
              p_last_amended_by          => G_MISS_NUM,
              p_object_version_number    => cr.object_version_number
            );
           --------------------------------------------
           IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
           ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR ;
           END IF;
    END LOOP;


END IF;
    -------------------------------------------------------------------------------
       -- bug# 3990983 Update Template Usages for source_change_allowed_flag to 'N'
    -------------------------------------------------------------------------------

    OPEN l_ctrt_src_crs ;
       FETCH l_ctrt_src_crs into l_contract_source_code;
    CLOSE l_ctrt_src_crs;

    IF(l_contract_source_code = 'ATTACHED') THEN
       OKC_TEMPLATE_USAGES_PVT.update_row(
	      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
		 x_return_status => x_return_status,
	      p_document_type => p_doc_type,
		 p_document_id => p_doc_id,
		 p_source_change_allowed_flag => 'N');

    END IF;
    -------------------------------------------------------------------------------
       -- bug# 3990983 Update Template Usages for source_change_allowed_flag to 'N'
    -------------------------------------------------------------------------------



/*IF (l_debug = 'Y') THEN
     Okc_Debug.Log('300: Leaving clear_amendment', 2);
END IF; */

IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    FND_LOG.STRING(G_PROC_LEVEL,
        G_PKG_NAME, '300: Leaving clear_amendment' );
END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving clear_amendment : OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '400: Leaving clear_amendment : OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_ERROR ;
     IF l_ctrt_src_crs%ISOPEN THEN
	      CLOSE l_ctrt_src_crs;
     END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('500: Leaving clear_amendment : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '500: Leaving clear_amendment : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF l_ctrt_src_crs%ISOPEN THEN
	    CLOSE l_ctrt_src_crs;
	 END IF;
    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        okc_debug.log('600: Leaving clear_amendment because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '600: Leaving clear_amendment because of EXCEPTION: '||sqlerrm );
      END IF;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
	 IF l_ctrt_src_crs%ISOPEN THEN
	    CLOSE l_ctrt_src_crs;
      END IF;
END clear_amendment;

/*
-- This API will be used to version terms whenever a document is versioned.
*/
  PROCEDURE Version_Doc (
    x_return_status    OUT NOCOPY VARCHAR2,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_version_number   IN  NUMBER
   ) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'Version_Doc';
    l_msg_data          VARCHAR2(1000);
    l_msg_count         NUMBER;
    l_change_nonstd     okc_k_articles_b.change_nonstd_yn%TYPE;

    CURSOR scn_crs IS
     SELECT id, object_version_number, amendment_operation_code
       FROM okc_sections_b
      WHERE document_type = p_doc_type AND document_id = p_doc_id
       AND (amendment_operation_code IS NOT NULL OR amendment_description IS NOT NULL);

    CURSOR l_del_scn_crs IS
     SELECT id, object_version_number
       FROM okc_sections_b
      WHERE document_type = p_doc_type AND document_id = p_doc_id
       AND amendment_operation_code = G_AMEND_CODE_DELETED
       AND SUMMARY_AMEND_OPERATION_CODE  IS NULL;

    CURSOR cat_crs IS
     SELECT id, kart.object_version_number, amendment_operation_code,standard_yn
       FROM okc_k_articles_b kart,okc_articles_all
      WHERE document_type = p_doc_type AND document_id = p_doc_id
       AND  sav_sae_id = article_id
       AND (amendment_operation_code IS NOT NULL
         OR standard_yn='N');

    CURSOR l_del_cat_crs IS
     SELECT id, object_version_number
       FROM okc_k_articles_b
      WHERE document_type = p_doc_type AND document_id = p_doc_id
       AND amendment_operation_code = G_AMEND_CODE_DELETED
       AND SUMMARY_AMEND_OPERATION_CODE  IS NULL;
   BEGIN

    x_return_status :=  G_RET_STS_SUCCESS;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('100: Entered Version_Doc', 2);
       Okc_Debug.Log('100: Call Create_Version for sections', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: Entered Version_Doc' );
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: Call Create_Version for sections' );
    END IF;

    --------------------------------------------
    -- Call Create_Version for sections
    --------------------------------------------
    x_return_status := OKC_TERMS_SECTIONS_PVT.Create_Version(
      p_doc_type         => p_doc_type,
      p_doc_id           => p_doc_id,
      p_major_version    => p_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    --------------------------------------------
    -- Call Create_Version for articles
    --------------------------------------------
    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('100: Call Create_Version for articles', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: Call Create_Version for articles' );
    END IF;

    x_return_status := OKC_K_ARTICLES_PVT.Create_Version(
      p_doc_type         => p_doc_type,
      p_doc_id           => p_doc_id,
      p_major_version    => p_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    --------------------------------------------
    -- Call Create_Version for article variables
    --------------------------------------------
    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('100: Call Create_Version for article variables', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: Call Create_Version for article variables' );
    END IF;

    x_return_status := OKC_K_ART_VARIABLES_PVT.Create_Version(
      p_doc_type         => p_doc_type,
      p_doc_id           => p_doc_id,
      p_major_version    => p_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    --------------------------------------------
    -- Call Create_Version for template usages
    --------------------------------------------
    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('100: Call Create_Version for template usages', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: Call Create_Version for template usages' );
    END IF;

    x_return_status := OKC_TEMPLATE_USAGES_PVT.Create_Version(
      p_doc_type         => p_doc_type,
      p_doc_id           => p_doc_id,
      p_major_version    => p_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    /********************
     Commented out as this will be done in clear amendments
    FOR cr in l_del_scn_crs LOOP
        --------------------------------------------
        -- Delete section
        --------------------------------------------
        Okc_Terms_Sections_Pvt.delete_row(
          x_return_status         => x_return_status,
          p_id                    => cr.id,
          p_object_version_number => cr.object_version_number
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------

        --------------------------------------------
        -- Delete articles
        --------------------------------------------
        Okc_K_Articles_Pvt.Delete_Set(
          x_return_status         => x_return_status,
          p_scn_id                => cr.id
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------

        --------------------------------------------
        -- Delete variables
        --------------------------------------------
        Okc_K_Art_Variables_Pvt.Delete_Set(
          x_return_status         => x_return_status,
          p_scn_id                => cr.id
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;

    END LOOP;

    FOR cr in l_del_cat_crs LOOP
        --------------------------------------------
        -- Delete article
        --------------------------------------------
        Okc_K_Articles_Pvt.Delete_Row(
          x_return_status         => x_return_status,
          p_id                    => cr.id,
          p_object_version_number => cr.object_version_number
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------

        --------------------------------------------
        -- Delete variables
        --------------------------------------------
        Okc_K_Art_Variables_Pvt.Delete_Set(
          x_return_status         => x_return_status,
          p_cat_id                => cr.id
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------
    END LOOP;

    FOR cr IN scn_crs LOOP
        --------------------------------------------
        -- Update section
        --------------------------------------------
        Okc_Terms_Sections_Pvt.Update_Row(
          x_return_status            => x_return_status,
          p_id                       => cr.id,
          p_amendment_operation_code => G_MISS_CHAR,
          p_object_version_number    => cr.object_version_number
        );
        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        --------------------------------------------
    END LOOP;

    FOR cr IN cat_crs LOOP
         select decode(cr.standard_yn,'N','Y',NULL)
                into l_change_nonstd from dual;
            --------------------------------------------
            -- Update article
            --------------------------------------------
            Okc_K_Articles_Pvt.Update_Row(
              x_return_status            => x_return_status,
              p_id                       => cr.id,
              p_amendment_operation_code => G_MISS_CHAR,
              p_change_nonstd_yn         => l_change_nonstd,
              p_object_version_number    => cr.object_version_number
            );
           --------------------------------------------
           IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
           ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR ;
           END IF;
    END LOOP;
    ****************************************/


    -- Standard call to get message count and if count is 1, get message info.
    /*IF (l_debug = 'Y') THEN
     Okc_Debug.Log('300: Leaving Version_Doc', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '300: Leaving Version_Doc' );
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving Version_Doc : OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_EXCP_LEVEL,
             G_PKG_NAME, '400: Leaving Version_Doc : OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_ERROR ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('500: Leaving Version_Doc : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_EXCP_LEVEL,
             G_PKG_NAME, '500: Leaving Version_Doc : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        okc_debug.log('600: Leaving Version_Doc because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_EXCP_LEVEL,
             G_PKG_NAME, '600: Leaving Version_Doc because of EXCEPTION: '||sqlerrm );
      END IF;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
  END Version_Doc ;

/*
--This API will be used to restore a version terms whenever a version of
-- document is restored.It is a very OKS/OKC/OKO specific functionality
*/
  PROCEDURE Restore_Doc_Version (
    x_return_status    OUT NOCOPY VARCHAR2,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_version_number   IN  NUMBER
   ) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'Restore_Doc_Version';
   BEGIN
x_return_status :=  G_RET_STS_SUCCESS;
    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('100: Entered Restore_Doc_Version', 2);
       Okc_Debug.Log('100: Call Restore_Version for sections', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '100: Entered Restore_Doc_Version');
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '100: Call Restore_Version for sections' );
    END IF;

    --------------------------------------------
    -- Call Restore_Version for sections
    --------------------------------------------
    x_return_status := OKC_TERMS_SECTIONS_PVT.Restore_Version(
      p_doc_type         => p_doc_type,
      p_doc_id           => p_doc_id,
      p_major_version    => p_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    --------------------------------------------
    -- Call Restore_Version for articles
    --------------------------------------------
    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('100: Call Restore_Version for articles', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '100: Call Restore_Version for articles');
    END IF;

    x_return_status := OKC_K_ARTICLES_PVT.Restore_Version(
      p_doc_type         => p_doc_type,
      p_doc_id           => p_doc_id,
      p_major_version    => p_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    --------------------------------------------
    -- Call Restore_Version for article variables
    --------------------------------------------
    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('100: Call Restore_Version for article variables', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '100: Call Restore_Version for article variables');
    END IF;
    x_return_status := OKC_K_ART_VARIABLES_PVT.Restore_Version(
      p_doc_type         => p_doc_type,
      p_doc_id           => p_doc_id,
      p_major_version    => p_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    --------------------------------------------
    -- Call Restore_Version for template usages
    --------------------------------------------
    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('100: Call Restore_Version for template usages', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '100: Call Restore_Version for template usages');
    END IF;
    x_return_status := OKC_TEMPLATE_USAGES_PVT.Restore_Version(
      p_doc_type         => p_doc_type,
      p_doc_id           => p_doc_id,
      p_major_version    => p_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard call to get message count and if count is 1, get message info.
    /*IF (l_debug = 'Y') THEN
     Okc_Debug.Log('300: Leaving Restore_Doc_Version', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '300: Leaving Restore_Doc_Version');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving Restore_Doc_Version : OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '400: Leaving Restore_Doc_Version : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('500: Leaving Restore_Doc_Version : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_EXCP_LEVEL,
             G_PKG_NAME, '500: Leaving Restore_Doc_Version : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        okc_debug.log('600: Leaving Restore_Doc_Version because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_EXCP_LEVEL,
             G_PKG_NAME, '600: Leaving Restore_Doc_Version because of EXCEPTION: '||sqlerrm);
      END IF;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
  END Restore_Doc_Version ;

/*
--This API will be used to delete terms whenever a version of document is deleted.
*/
  Procedure Delete_Doc_Version (
    x_return_status    OUT NOCOPY VARCHAR2,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_version_number   IN  NUMBER
   ) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'Delete_Doc_Version';
   BEGIN
x_return_status :=  G_RET_STS_SUCCESS;
    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('100: Entered Delete_Doc_Version', 2);
       Okc_Debug.Log('100: Call Delete_Version for sections', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '100: Entered Delete_Doc_Version');
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '100: Call Delete_Version for sections');
    END IF;


    --------------------------------------------
    -- Call Delete_Version for sections
    --------------------------------------------
    x_return_status := OKC_TERMS_SECTIONS_PVT.Delete_Version(
      p_doc_type         => p_doc_type,
      p_doc_id           => p_doc_id,
      p_major_version    => p_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Bug 5171866 - Correct Sequence of call is
    -- OKC_K_ART_VARIABLES_PVT.Delete_Version();
    -- OKC_K_ARTICLE_PVT.Delete_Version();

    --------------------------------------------
    -- Call Delete_Version for article variables
    --------------------------------------------
    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '100: Call Delete_Version for article variables');
    END IF;
    x_return_status := OKC_K_ART_VARIABLES_PVT.Delete_Version(
      p_doc_type         => p_doc_type,
      p_doc_id           => p_doc_id,
      p_major_version    => p_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    --------------------------------------------
    -- Call Delete_Version for articles
    --------------------------------------------

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '100: Call Delete_Version for articles');
    END IF;
    x_return_status := OKC_K_ARTICLES_PVT.Delete_Version(
      p_doc_type         => p_doc_type,
      p_doc_id           => p_doc_id,
      p_major_version    => p_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    --------------------------------------------
    -- Call Delete_Version for template usages
    --------------------------------------------
    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('100: Call Delete_Version for template usages', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '100: Call Delete_Version for template usages' );
    END IF;
    x_return_status := OKC_TEMPLATE_USAGES_PVT.Delete_Version(
      p_doc_type         => p_doc_type,
      p_doc_id           => p_doc_id,
      p_major_version    => p_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard call to get message count and if count is 1, get message info.
    /*IF (l_debug = 'Y') THEN
     Okc_Debug.Log('300: Leaving Delete_Doc_Version', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '300: Leaving Delete_Doc_Version' );
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving Delete_Doc_Version : OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_EXCP_LEVEL,
             G_PKG_NAME, '400: Leaving Delete_Doc_Version : OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_ERROR ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('500: Leaving Delete_Doc_Version : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_EXCP_LEVEL,
             G_PKG_NAME, '500: Leaving Delete_Doc_Version : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        okc_debug.log('600: Leaving Delete_Doc_Version because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_EXCP_LEVEL,
             G_PKG_NAME, '600: Leaving Delete_Doc_Version because of EXCEPTION: '||sqlerrm );
      END IF;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
  END Delete_Doc_Version ;
-->>>>>>>>>>>>>>>>>>>>>>>>>>> EXTERNAL PROCEDURES >>>>>>>>>>>>>>>>>>>>>>>>>>>

END OKC_TERMS_VERSION_PVT;

/
