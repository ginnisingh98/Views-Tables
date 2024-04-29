--------------------------------------------------------
--  DDL for Package Body OKC_TERMS_SECTIONS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMS_SECTIONS_GRP" AS
/* $Header: OKCGSCNB.pls 120.1.12010000.3 2013/11/29 13:45:55 serukull ship $ */

    l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_TERMS_SECTIONS_GRP';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE	                     CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_RET_STS_SUCCESS            CONSTANT   varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   varchar2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
  G_AMEND_CODE_DELETED         CONSTANT   VARCHAR2(30) := 'DELETED';
  G_AMEND_CODE_ADDED           CONSTANT   VARCHAR2(30) := 'ADDED';
  G_AMEND_CODE_UPDATED         CONSTANT   VARCHAR2(30) := 'UPDATED';

  G_DBG_LEVEL							  NUMBER 		:= FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_PROC_LEVEL							  NUMBER		:= FND_LOG.LEVEL_PROCEDURE;
  G_EXCP_LEVEL							  NUMBER		:= FND_LOG.LEVEL_EXCEPTION;

  ---------------------------------------
  -- PROCEDURE validate_row  --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_section_sequence           IN NUMBER,
    p_label                      IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_heading                    IN VARCHAR2,
    p_description                IN VARCHAR2,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_scn_code                   IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_amendment_operation_code   IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_print_yn                   IN VARCHAR2,
    p_attribute_category         IN VARCHAR2,
    p_attribute1                 IN VARCHAR2,
    p_attribute2                 IN VARCHAR2,
    p_attribute3                 IN VARCHAR2,
    p_attribute4                 IN VARCHAR2,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2,
    p_attribute7                 IN VARCHAR2,
    p_attribute8                 IN VARCHAR2,
    p_attribute9                 IN VARCHAR2,
    p_attribute10                IN VARCHAR2,
    p_attribute11                IN VARCHAR2,
    p_attribute12                IN VARCHAR2,
    p_attribute13                IN VARCHAR2,
    p_attribute14                IN VARCHAR2,
    p_attribute15                IN VARCHAR2,
    p_object_version_number      IN NUMBER
  ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_validate_row';

  BEGIN

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered validate_row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '100: Entered validate_row' );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_validate_row_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Validation
    --------------------------------------------
    OKC_TERMS_SECTIONS_PVT.Validate_Row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      p_id                         => p_id,
      p_section_sequence           => p_section_sequence,
      p_label                      => p_label,
      p_scn_id                     => p_scn_id,
      p_heading                    => p_heading,
      p_description                => p_description,
      p_document_type              => p_document_type,
      p_document_id                => p_document_id,
      p_scn_code                   => p_scn_code,
      p_amendment_description      => p_amendment_description,
      p_amendment_operation_code   => p_amendment_operation_code,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_print_yn                   => p_print_yn,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      p_object_version_number      => p_object_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('200: Leaving validate_row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '200: Leaving validate_row' );
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving Validate_Row: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      	 FND_LOG.STRING(G_EXCP_LEVEL,
     	     G_PKG_NAME, '300: Leaving Validate_Row: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;
      ROLLBACK TO g_validate_row_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving Validate_Row: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      	 FND_LOG.STRING(G_EXCP_LEVEL,
     	     G_PKG_NAME, '400: Leaving Validate_Row: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
      END IF;
      ROLLBACK TO g_validate_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving Validate_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      	 FND_LOG.STRING(G_EXCP_LEVEL,
     	     G_PKG_NAME, '500: Leaving Validate_Row because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      ROLLBACK TO g_validate_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END validate_row;

  -------------------------------------
  -- PROCEDURE create_section
  -------------------------------------
  PROCEDURE create_section(
    p_api_version                IN NUMBER,
    p_init_msg_list              IN VARCHAR2 ,
    p_validation_level	         IN NUMBER,
    p_commit                     IN VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_mode                       IN VARCHAR2 , --'AMEND' or 'NORMAL'
    p_id                         IN NUMBER,
    p_section_sequence           IN NUMBER,
    p_label                      IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_heading                    IN VARCHAR2,
    p_description                IN VARCHAR2,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_scn_code                   IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_print_yn                   IN VARCHAR2,
    p_attribute_category         IN VARCHAR2,
    p_attribute1                 IN VARCHAR2,
    p_attribute2                 IN VARCHAR2,
    p_attribute3                 IN VARCHAR2,
    p_attribute4                 IN VARCHAR2,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2,
    p_attribute7                 IN VARCHAR2,
    p_attribute8                 IN VARCHAR2,
    p_attribute9                 IN VARCHAR2,
    p_attribute10                IN VARCHAR2,
    p_attribute11                IN VARCHAR2,
    p_attribute12                IN VARCHAR2,
    p_attribute13                IN VARCHAR2,
    p_attribute14                IN VARCHAR2,
    p_attribute15                IN VARCHAR2,
    x_id                         OUT NOCOPY NUMBER

  ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_create_section';
    l_object_version_number        OKC_SECTIONS_B.OBJECT_VERSION_NUMBER%TYPE := 1;
    l_amendment_operation_code     OKC_SECTIONS_B.AMENDMENT_OPERATION_CODE%TYPE;
    l_summary_amend_operation_code OKC_SECTIONS_B.SUMMARY_AMEND_OPERATION_CODE%TYPE;
    l_amendment_description        OKC_SECTIONS_B.AMENDMENT_DESCRIPTION%TYPE;

  BEGIN

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('600: Entered create_section', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '600: Entered create_section' );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_create_section_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_mode='AMEND' THEN
       l_amendment_description        := p_amendment_description;
       l_amendment_operation_code     := G_AMEND_CODE_ADDED;
       l_summary_amend_operation_code := OKC_TERMS_UTIL_PVT.get_summary_amend_code(p_existing_summary_code =>NULL,
   p_existing_operation_code=>NULL,
   p_amend_operation_code=>G_AMEND_CODE_ADDED);
    ELSE
       l_amendment_description        := NULL;
       l_amendment_operation_code     := NULL;
       l_summary_amend_operation_code := NULL;
    END IF;
    --------------------------------------------
    -- Calling Simple API for Creating A Row
    --------------------------------------------
    OKC_TERMS_SECTIONS_PVT.insert_row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      p_id                         => p_id,
      p_section_sequence           => p_section_sequence,
      p_label                      => p_label,
      p_scn_id                     => p_scn_id,
      p_heading                    => p_heading,
      p_description                => p_description,
      p_document_type              => p_document_type,
      p_document_id                => p_document_id,
      p_scn_code                   => p_scn_code,
      p_amendment_description      => l_amendment_description,
      p_amendment_operation_code   => l_amendment_operation_code,
      p_summary_amend_operation_code => l_summary_amend_operation_code,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_print_yn                   => p_print_yn,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      x_id                         => x_id
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('700: Leaving create_section', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '700: Leaving create_section' );
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('800: Leaving create_section: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
              G_PKG_NAME, '800: Leaving create_section: OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      ROLLBACK TO g_create_section_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('900: Leaving create_section: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
              G_PKG_NAME, '900: Leaving create_section: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      ROLLBACK TO g_create_section_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        okc_debug.log('1000: Leaving create_section because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
              G_PKG_NAME, '1000: Leaving create_section because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      ROLLBACK TO g_create_section_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END create_section;

  --------------------------------------------------------------------------
  -- PROCEDURE update_section
  ---------------------------------------------------------------------------
  PROCEDURE update_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER,
    p_validate_commit              IN VARCHAR2,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mode                       IN VARCHAR2 , --'AMEND' or 'NORMAL'
    p_id                         IN NUMBER,
    p_section_sequence           IN NUMBER,
    p_label                      IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_heading                    IN VARCHAR2,
    p_description                IN VARCHAR2,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_scn_code                   IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_print_yn                   IN VARCHAR2,
    p_attribute_category         IN VARCHAR2,
    p_attribute1                 IN VARCHAR2,
    p_attribute2                 IN VARCHAR2,
    p_attribute3                 IN VARCHAR2,
    p_attribute4                 IN VARCHAR2,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2,
    p_attribute7                 IN VARCHAR2,
    p_attribute8                 IN VARCHAR2,
    p_attribute9                 IN VARCHAR2,
    p_attribute10                IN VARCHAR2,
    p_attribute11                IN VARCHAR2,
    p_attribute12                IN VARCHAR2,
    p_attribute13                IN VARCHAR2,
    p_attribute14                IN VARCHAR2,
    p_attribute15                IN VARCHAR2,
    p_object_version_number      IN NUMBER,
    p_lock_terms_yn              IN VARCHAR2
   ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_update_section';
    l_ok_to_commit                 VARCHAR2(1);
    l_document_id                  NUMBER;
    l_document_type                VARCHAR2(30);
    l_scn_id                       okc_sections_b.id%type;
    l_cat_id                       okc_k_articles_b.id%type;
    l_ovn                          okc_sections_b.object_version_number%type;
    l_amendment_operation_code   OKC_SECTIONS_B.AMENDMENT_OPERATION_CODE%TYPE;
    l_summary_amend_operation_code OKC_SECTIONS_B.SUMMARY_AMEND_OPERATION_CODE%TYPE;
    l_existing_summary_code      OKC_SECTIONS_B.SUMMARY_AMEND_OPERATION_CODE%TYPE;
    l_existing_operation_code    OKC_SECTIONS_B.SUMMARY_AMEND_OPERATION_CODE%TYPE;
    l_amendment_description      OKC_SECTIONS_B.AMENDMENT_DESCRIPTION%TYPE;
    l_orig_system_reference_id1   NUMBER;

    CURSOR l_document_id_csr IS
    SELECT DOCUMENT_ID,DOCUMENT_TYPE,orig_system_reference_id1 FROM OKC_SECTIONS_B
    WHERE ID=P_ID;

    CURSOR l_get_summary_code_csr IS
    SELECT SUMMARY_AMEND_OPERATION_CODE ,amendment_operation_code
    FROM OKC_SECTIONS_B
    WHERE ID=P_ID;

  BEGIN

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('1600: Entered update_section', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	   G_PKG_NAME, '1600: Entered update_section' );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_update_section_GRP;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF p_document_id IS NULL OR p_document_type IS NULL OR p_orig_system_reference_id1 IS NULL THEN
          OPEN  l_document_id_csr;
          FETCH l_document_id_csr into l_document_id,l_document_type,l_orig_system_reference_id1;
          CLOSE l_document_id_csr;
    ELSE
        l_document_id := p_document_id;
        l_document_type := p_document_type;
        l_orig_system_reference_id1 := p_orig_system_reference_id1;
    END IF;

    IF FND_API.To_Boolean( p_validate_commit ) THEN
        IF NOT FND_API.To_Boolean(OKC_TERMS_UTIL_GRP.ok_to_commit (
                                         p_api_version => l_api_version,
                                         p_init_msg_list => FND_API.G_FALSE,
                                         p_doc_type	 => l_document_type,
                                         p_doc_id	 => l_document_id,
                                         p_validation_string => p_validation_string,
                                         x_return_status => x_return_status,
                                         x_msg_data	 => x_msg_data,
                                         x_msg_count	 => x_msg_count)                  ) THEN

             /*IF (l_debug = 'Y') THEN
                okc_debug.log('700: Issue with document header Record.Cannot commit', 2);
             END IF;*/

	     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	   	 FND_LOG.STRING(G_PROC_LEVEL,
  	   	     G_PKG_NAME, '700: Issue with document header Record.Cannot commit' );
   	     END IF;
             RAISE FND_API.G_EXC_ERROR ;
      END IF;
    END IF;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_mode='AMEND' THEN
       l_amendment_description    := p_amendment_description;

       OPEN  l_get_summary_code_csr;
       FETCH l_get_summary_code_csr INTO l_existing_summary_code,l_existing_operation_code;
       CLOSE l_get_summary_code_csr;

       l_amendment_operation_code := nvl(l_existing_operation_code,G_AMEND_CODE_UPDATED);
       l_summary_amend_operation_code := OKC_TERMS_UTIL_PVT.get_summary_amend_code(p_existing_summary_code =>l_existing_summary_code,
   p_existing_operation_code=>l_existing_operation_code,
   p_amend_operation_code=>G_AMEND_CODE_UPDATED);

    ELSE
       l_amendment_description    := NULL;
       l_amendment_operation_code := NULL;
       l_summary_amend_operation_code := NULL;
    END IF;

    -----------------------------------------------------------------
    -- Concurrent Mod Changes
    -- Call the Lock entity API only in AMEND mode
    --                  and when p_lock_terms_yn is 'Y' .
    -----------------------------------------------------------------
    IF (      p_mode='AMEND'
         AND  l_amendment_operation_code = G_AMEND_CODE_UPDATED
         AND  p_lock_terms_yn = 'Y'
         AND  l_orig_system_reference_id1 IS NOT null
        )
    THEN

       okc_k_entity_locks_grp.lock_entity
                      ( p_api_version     => 1,
                       p_init_msg_list    => FND_API.G_FALSE ,
                       p_commit           => FND_API.G_FALSE,
                       p_entity_name      => okc_k_entity_locks_grp.G_SECTION_ENTITY,
                       p_entity_pk1       => To_Char(l_orig_system_reference_id1),
                       P_LOCK_BY_ENTITY_ID => p_id,
                       p_LOCK_BY_DOCUMENT_TYPE => l_document_type,
                       p_LOCK_BY_DOCUMENT_ID => l_document_id,
                       X_RETURN_STATUS => X_RETURN_STATUS,
                       X_MSG_COUNT => X_MSG_COUNT,
                       X_MSG_DATA => X_MSG_DATA
                      );
        --------------------------------------------
         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
       --------------------------------------------
    END IF;

    --------------------------------------------
    -- Calling Simple API for Updating A Row
    --------------------------------------------

    OKC_TERMS_SECTIONS_PVT.update_row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      p_id                         => p_id,
      p_section_sequence           => p_section_sequence,
      p_label                      => p_label,
      p_scn_id                     => p_scn_id,
      p_heading                    => p_heading,
      p_description                => p_description,
      p_document_type              => p_document_type,
      p_document_id                => p_document_id,
      p_scn_code                   => p_scn_code,
      p_amendment_description      => l_amendment_description,
      p_amendment_operation_code   => l_amendment_operation_code,
      p_summary_amend_operation_code => l_summary_amend_operation_code,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_print_yn                   => p_print_yn,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      p_object_version_number      => p_object_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    /*IF (l_debug = 'Y') THEN
      okc_debug.log('1800: Leaving update_section', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
  	FND_LOG.STRING(G_PROC_LEVEL,
  	    G_PKG_NAME, '1800: Leaving update_section' );
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('1900: Leaving update_section: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '1900: Leaving update_section: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;

      IF l_document_id_csr%ISOPEN THEN
         CLOSE l_document_id_csr;
      END IF;

      ROLLBACK TO g_update_section_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('2000: Leaving update_section: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '2000: Leaving update_section: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
      END IF;

      IF l_document_id_csr%ISOPEN THEN
         CLOSE l_document_id_csr;
      END IF;

      ROLLBACK TO g_update_section_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        okc_debug.log('2100: Leaving update_section because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '2100: Leaving update_section because of EXCEPTION: '||sqlerrm );
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      IF l_document_id_csr%ISOPEN THEN
         CLOSE l_document_id_csr;
      END IF;

      ROLLBACK TO g_update_section_GRP;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END update_section;

  -------------------------------------------------------
  -- PROCEDURE add_section  :: To be called from UI
  -------------------------------------------------------
  PROCEDURE add_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER ,
    p_validate_commit              IN VARCHAR2 ,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 ,
    p_mode                         IN VARCHAR2 , -- 'NORMAL' or 'AMEND'
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_id                           IN NUMBER,
    p_ref_scn_id                 IN NUMBER ,
    p_ref_point                  IN VARCHAR2 ,
    p_heading                    IN VARCHAR2,
    p_description                IN VARCHAR2,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_scn_code                   IN VARCHAR2,
    p_print_yn                   IN VARCHAR2 ,
    p_amendment_description      IN VARCHAR2 ,
    p_attribute_category         IN VARCHAR2 ,
    p_attribute1                 IN VARCHAR2 ,
    p_attribute2                 IN VARCHAR2 ,
    p_attribute3                 IN VARCHAR2 ,
    p_attribute4                 IN VARCHAR2 ,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2 ,
    p_attribute7                 IN VARCHAR2 ,
    p_attribute8                 IN VARCHAR2 ,
    p_attribute9                 IN VARCHAR2 ,
    p_attribute10                IN VARCHAR2 ,
    p_attribute11                IN VARCHAR2 ,
    p_attribute12                IN VARCHAR2 ,
    p_attribute13                IN VARCHAR2 ,
    p_attribute14                IN VARCHAR2 ,
    p_attribute15                IN VARCHAR2 ,
    x_id                         OUT NOCOPY NUMBER
    ) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_add_section';
    l_object_version_number       OKC_SECTIONS_B.OBJECT_VERSION_NUMBER%TYPE := 1;
    l_ok_to_commit                VARCHAR2(1);
    i                             NUMBER := 0;
    l_ref_count                   NUMBER := 0;
    l_ref_sequence                NUMBER := 0;
    l_ref_sequence1               NUMBER := 0;
    l_sequence                    NUMBER := 0;
    l_ref_is_set                  BOOLEAN := FALSE;
    l_scn_id                      NUMBER ;

    --Fix for bug 3735048, added object_type
    TYPE scn_rec_type IS RECORD (
    id                        OKC_SECTIONS_B.id%type,
    display_sequence          OKC_SECTIONS_B.section_sequence%type,
    object_version_number     OKC_SECTIONS_B.object_version_number%type,
    object_type               VARCHAR2(30)
    );

   TYPE scn_tbl_type IS TABLE OF scn_rec_type INDEX BY BINARY_INTEGER;
   scn_tbl  scn_tbl_type;

   --Fix for bug 3735048, added UNION ALL to add articles
   --Also added object_type
-- Cursor to get sequence of all child section of a section
    CURSOR l_get_scn_csr(b_scn_id NUMBER) IS
    SELECT id,
           'SECTION' object_type,
           object_version_number,
           section_sequence display_sequence,
           scn_id
    FROM okc_sections_b
    WHERE document_type=p_document_type
    AND   document_id  = p_document_id
    AND ( (b_scn_id IS NOT NULL AND scn_id=b_scn_id) OR
            (b_scn_id IS NULL AND scn_id IS NULL)
          )
    UNION ALL
    SELECT id,
           'ARTICLE' object_type,
           object_version_number,
           display_sequence,
           scn_id
    FROM okc_k_articles_b
    WHERE document_type=p_document_type
    AND   document_id  = p_document_id
    AND ( (b_scn_id IS NOT NULL AND scn_id=b_scn_id) OR
            (b_scn_id IS NULL AND scn_id IS NULL)
          )
    ORDER BY display_sequence;

-- cursor to get paret of reference scn_id
CURSOR l_get_parent_csr IS
select scn_id from okc_sections_b
where document_type=p_document_type
    AND   document_id  = p_document_id
    AND   id=p_ref_scn_id;


-- Cursor to get sequence of last section in a hierarchy
cursor l_get_max_seq_csr(b_scn_id NUMBER) is
    SELECT nvl(max(SECTION_SEQUENCE),0) FROM OKC_SECTIONS_B
    WHERE  document_type=p_document_type
    AND    document_id=p_document_id
    and     (
               (b_scn_id is Null and scn_id is Null)
                 OR
               (b_scn_id is Not Null and scn_id=b_scn_id));
CURSOR l_get_max_art_seq(b_scn_id NUMBER) IS
    SELECT nvl(max(DISPLAY_SEQUENCE),0) FROM OKC_K_ARTICLES_B
    WHERE  document_type=p_document_type
    AND    document_id=p_document_id
    and    scn_id     =b_scn_id;

CURSOR l_get_child_art_crs(b_scn_id NUMBER,b_ref_sequence NUMBER) IS
   SELECT id,object_version_number
          FROM OKC_K_ARTICLES_B
          WHERE SCN_ID=b_scn_id
          AND   display_sequence >= b_ref_sequence
          Order by display_sequence;



BEGIN


    /*IF (l_debug = 'Y') THEN
       okc_debug.log('600: Entered add_section', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
  	FND_LOG.STRING(G_PROC_LEVEL,
  	    G_PKG_NAME, '600: Entered add_section' );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_add_section_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF FND_API.To_Boolean( p_validate_commit )  AND
       NOT FND_API.To_Boolean(OKC_TERMS_UTIL_GRP.ok_to_commit (
                                         p_api_version   => l_api_version,
                                         p_init_msg_list => FND_API.G_FALSE,
                                         p_doc_type	     => p_document_type,
                                         p_doc_id	     => p_document_id,
                                         p_validation_string => p_validation_string,
                                         x_return_status => x_return_status,
                                         x_msg_data	     => x_msg_data,
                                         x_msg_count	 => x_msg_count) ) THEN

             /*IF (l_debug = 'Y') THEN
                okc_debug.log('700: Issue with document header Record.Cannot commit', 2);
             END IF;*/

	     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	 	FND_LOG.STRING(G_PROC_LEVEL,
  		    G_PKG_NAME, '700: Issue with document header Record.Cannot commit' );
   	     END IF;
             RAISE FND_API.G_EXC_ERROR ;
    END IF;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_ref_point NOT IN ('A','B','S') THEN
         /*IF (l_debug = 'Y') THEN
           okc_debug.log('800: Error: Ref point should be either A,B or S', 2);
         END IF;*/

	 IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	     FND_LOG.STRING(G_PROC_LEVEL,
  		 G_PKG_NAME, '800: Error: Ref point should be either A,B or S' );
   	 END IF;

       Okc_Api.Set_Message( G_FND_APP, 'OKC_WRONG_REF_POINT');
       RAISE FND_API.G_EXC_ERROR ;

    END IF;


   IF p_ref_scn_id is NULL  THEN
    -- Case of Adding a section at TOP Level.This will be last section.

        OPEN l_get_max_seq_csr(Null);
        FETCH l_get_max_seq_csr into l_ref_sequence;
        CLOSE l_get_max_seq_csr;
        l_ref_is_set  := TRUE;
        l_scn_id := Null;
   END IF;

   IF p_ref_scn_id IS NOT NULL AND p_ref_point='S' THEN
     -- Case of Adding a subsection at TOP Level.This will be last section in the heirarchy.
        OPEN  l_get_max_seq_csr(p_ref_scn_id);
        FETCH l_get_max_seq_csr INTO l_ref_sequence;
        CLOSE l_get_max_seq_csr;

        OPEN  l_get_max_art_seq(p_ref_scn_id);
        FETCH l_get_max_art_seq INTO l_ref_sequence1;
        CLOSE l_get_max_art_seq;

        l_ref_is_set  := TRUE;
        l_scn_id := p_ref_scn_id;

        IF l_ref_sequence1 > l_ref_sequence THEN
           l_ref_sequence := l_ref_sequence1;
        END IF;

   END IF;

   scn_tbl.delete;

   IF NOT l_ref_is_set THEN
     OPEN  l_get_parent_csr;
     FETCH l_get_parent_csr into l_scn_id;
     CLOSE l_get_parent_csr ;

     FOR l_scn_rec IN l_get_scn_csr(l_scn_id) LOOP

        i := i +1;

        scn_tbl(i).id                    := l_scn_rec.id;
        scn_tbl(i).object_version_number := l_scn_rec.object_version_number;
        scn_tbl(i).display_sequence      := l_scn_rec.display_sequence;
        scn_tbl(i).object_type           := l_scn_rec.object_type;

-- Finding out reference below which subsection will be create

        IF  scn_tbl(i).id = p_ref_scn_id  THEN
                l_ref_count    := i;
                l_ref_sequence := scn_tbl(i).display_sequence;
                l_ref_is_set   := TRUE;
        END IF;

     END LOOP;
     IF l_ref_is_set THEN
          IF p_ref_point='B' THEN
                l_ref_count    := l_ref_count - 1 ;
                IF l_ref_count=0 THEN
                    l_ref_sequence := 0;
                 ELSE
                    l_ref_sequence := nvl(scn_tbl(l_ref_count).display_sequence,0);
                 END IF;
          END IF;
     ELSE
        /*IF (l_debug = 'Y') THEN
           okc_debug.log('900: Error: Reference not found', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	   FND_LOG.STRING(G_PROC_LEVEL,
  		G_PKG_NAME, '900: Error: Reference not found' );
   	END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
     END IF;
  END IF;


     l_sequence := l_ref_sequence + 10;
    --------------------------------------------
    -- Calling API for Creating A Section
    --------------------------------------------
    OKC_TERMS_SECTIONS_GRP.create_section(
      p_api_version                => 1,
      p_init_msg_list              => FND_API.G_FALSE,
      p_commit                     => FND_API.G_FALSE,
      p_mode                       => p_mode,
      p_validation_level           => p_validation_level,
      p_id                         => p_id,
      p_section_sequence           => l_sequence,
      p_scn_id                     => l_scn_id,
      p_heading                    => p_heading,
      p_description                => p_description,
      p_document_type              => p_document_type,
      p_document_id                => p_document_id,
      p_scn_code                   => p_scn_code,
      p_print_yn                   => p_print_yn,
      p_attribute_category         => p_attribute_category,
      p_amendment_description      => p_amendment_description,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data,
      x_id                         => x_id
    );

    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
    IF scn_tbl.COUNT > 0  THEN
       FOR k IN scn_tbl.FIRST..scn_tbl.LAST LOOP
           IF k > l_ref_count THEN

    -- Fix for bug 3735048, Added Update Articles
             l_sequence := l_sequence + 10;
               IF scn_tbl(k).object_type = 'SECTION' THEN

                 /*IF (l_debug = 'Y') THEN
                       okc_debug.log('1000: Updating Display Sequence of scn_id '||scn_tbl(k).id, 2);
                 END IF;*/

		 IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	   	    FND_LOG.STRING(G_PROC_LEVEL,
		  		G_PKG_NAME, '1000: Updating Display Sequence of scn_id '||scn_tbl(k).id );
  	  	 END IF;

                 OKC_TERMS_SECTIONS_GRP.update_section(
                       p_api_version          =>1,
                       p_init_msg_list        => OKC_API.G_FALSE,
                       x_return_status        => x_return_status,
                       x_msg_count            => x_msg_count,
                       x_msg_data             => x_msg_data,
                       p_mode                 => 'NORMAL',
                       p_id                   => scn_tbl(k).id,
                       p_section_sequence     => l_sequence,
                       p_object_version_number => scn_tbl(k).object_version_number
                                                );
               ELSIF scn_tbl(k).object_type = 'ARTICLE' THEN


                 /*IF (l_debug = 'Y') THEN
                  okc_debug.log('1200: Updating Display Sequence of cat_id '||scn_tbl(k).id, 2);
                 END IF;*/

		 IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	   	    FND_LOG.STRING(G_PROC_LEVEL,
		  		G_PKG_NAME, '1200: Updating Display Sequence of cat_id '||scn_tbl(k).id );
  	  	 END IF;

                 OKC_K_ARTICLES_GRP.update_article(
                       p_api_version           =>1,
                       p_init_msg_list         => OKC_API.G_FALSE,
                       x_return_status         => x_return_status,
                       x_msg_count             => x_msg_count,
                       x_msg_data              => x_msg_data,
                       p_mode                 => 'NORMAL',
                       p_id                    => scn_tbl(k).id,
                       p_display_sequence      => l_sequence,
                       p_object_version_number => scn_tbl(k).object_version_number
                                                );
               END IF;




                   --------------------------------------------
                  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR ;
                  END IF;
                   --------------------------------------------
           END IF;
       END LOOP;
    END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Leaving add_section', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	FND_LOG.STRING(G_PROC_LEVEL,
	    G_PKG_NAME, '1100: Leaving add_section' );
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('1200: Leaving add_section: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_EXCP_LEVEL,
             G_PKG_NAME, '1200: Leaving add_section: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;

      IF l_get_scn_csr%ISOPEN THEN
         CLOSE l_get_scn_csr;
      END IF;

      IF l_get_max_seq_csr%ISOPEN THEN
         CLOSE l_get_max_seq_csr;
      END IF;

      IF l_get_max_art_seq%ISOPEN THEN
         CLOSE l_get_max_art_seq;
      END IF;

      IF l_get_child_art_crs%ISOPEN THEN
         CLOSE l_get_child_art_crs;
      END IF;

      ROLLBACK TO g_add_section_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('1300: Leaving add_section: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_EXCP_LEVEL,
             G_PKG_NAME, '1300: Leaving add_section: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
      END IF;

      IF l_get_scn_csr%ISOPEN THEN
         CLOSE l_get_scn_csr;
      END IF;

      IF l_get_max_seq_csr%ISOPEN THEN
         CLOSE l_get_max_seq_csr;
      END IF;


      IF l_get_max_art_seq%ISOPEN THEN
         CLOSE l_get_max_art_seq;
      END IF;

      IF l_get_child_art_crs%ISOPEN THEN
         CLOSE l_get_child_art_crs;
      END IF;
      ROLLBACK TO g_add_section_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        okc_debug.log('1400: Leaving add_section because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_EXCP_LEVEL,
             G_PKG_NAME, '1400: Leaving add_section because of EXCEPTION: '||sqlerrm );
      END IF;

    Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);


      IF l_get_scn_csr%ISOPEN THEN
         CLOSE l_get_scn_csr;
      END IF;

      IF l_get_max_seq_csr%ISOPEN THEN
         CLOSE l_get_max_seq_csr;
      END IF;


      IF l_get_max_art_seq%ISOPEN THEN
         CLOSE l_get_max_art_seq;
      END IF;

      IF l_get_child_art_crs%ISOPEN THEN
         CLOSE l_get_child_art_crs;
      END IF;
      ROLLBACK TO g_add_section_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END add_section;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_object_version_number      IN NUMBER
   ) IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_lock_row';
  BEGIN

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Entered lock_row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '1100: Entered lock_row' );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_lock_row_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Calling Simple API for Locking A Row
    --------------------------------------------
    OKC_TERMS_SECTIONS_PVT.lock_row(
      x_return_status              =>   x_return_status,
      p_id                         => p_id,
      p_object_version_number      => p_object_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    /*IF (l_debug = 'Y') THEN
      okc_debug.log('1200: Leaving lock_row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '1200: Leaving lock_row' );
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('1300: Leaving lock_Row: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
              G_PKG_NAME, '1300: Leaving lock_Row: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;
      ROLLBACK TO g_lock_row_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('1400: Leaving lock_Row: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
              G_PKG_NAME, '1400: Leaving lock_Row: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
      END IF;
      ROLLBACK TO g_lock_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        okc_debug.log('1500: Leaving lock_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
              G_PKG_NAME, '1500: Leaving lock_Row because of EXCEPTION: '||sqlerrm );
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      ROLLBACK TO g_lock_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END lock_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_section
  ---------------------------------------------------------------------------
  PROCEDURE delete_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_validate_commit              IN VARCHAR2,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mode                         IN VARCHAR2,
    p_super_user_yn                IN VARCHAR2,
    p_amendment_description        IN VARCHAR2,
    p_id                           IN NUMBER,
    p_object_version_number        IN NUMBER,
    p_lock_terms_yn                IN VARCHAR2
  ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_delete_section';
    l_ok_to_commit                 VARCHAR2(1);
    l_document_id                  NUMBER;
    l_document_type                VARCHAR2(30);
    l_scn_id                       okc_sections_b.id%type;
    l_cat_id                       okc_k_articles_b.id%type;
    l_ovn                          okc_sections_b.object_version_number%type;
    l_summary_amend_operation_code OKC_SECTIONS_B.SUMMARY_AMEND_OPERATION_CODE%TYPE;
    l_existing_summary_code      OKC_SECTIONS_B.SUMMARY_AMEND_OPERATION_CODE%TYPE;
    l_existing_operation_code    OKC_SECTIONS_B.SUMMARY_AMEND_OPERATION_CODE%TYPE;
    l_delete_rec                 BOOLEAN :=FALSE;
    l_super_user_yn               VARCHAR2(1) ;

    l_orig_system_reference_id1 NUMBER;

    CURSOR l_document_id_csr IS
    SELECT DOCUMENT_ID,DOCUMENT_TYPE,orig_system_reference_id1 FROM OKC_SECTIONS_B
    WHERE ID=P_ID;

    CURSOR l_subsection_csr(b_scn_id Number) IS
    SELECT ID,OBJECT_VERSION_NUMBER FROM OKC_SECTIONS_B
    WHERE SCN_ID=b_scn_id;

    CURSOR l_get_article_csr(b_scn_id Number) IS
    SELECT ID,OBJECT_VERSION_NUMBER FROM OKC_K_ARTICLES_B
    WHERE SCN_ID=b_scn_id;

    CURSOR l_get_summary_code_csr IS
    SELECT SUMMARY_AMEND_OPERATION_CODE,AMENDMENT_OPERATION_CODE FROM OKC_SECTIONS_B
    WHERE ID=P_ID;


  BEGIN

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('2200: Entered delete_section', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '2200: Entered delete_section' );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_delete_section_GRP;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

       OPEN  l_document_id_csr;
       FETCH l_document_id_csr into l_document_id,l_document_type,l_orig_system_reference_id1;
       CLOSE l_document_id_csr;


     IF FND_API.To_Boolean( p_validate_commit ) THEN



       IF NOT FND_API.To_Boolean(OKC_TERMS_UTIL_GRP.ok_to_commit (
                                         p_api_version => l_api_version,
                                         p_init_msg_list => FND_API.G_FALSE,
                                         p_doc_type	 => l_document_type,
                                         p_doc_id	 => l_document_id,
                                         p_validation_string => p_validation_string,
                                         x_return_status => x_return_status,
                                         x_msg_data	 => x_msg_data,
                                         x_msg_count	 => x_msg_count)                  ) THEN

             /*IF (l_debug = 'Y') THEN
                okc_debug.log('2210: Issue with document header Record.Cannot commit', 2);
             END IF;*/

	     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	         FND_LOG.STRING(G_PROC_LEVEL,
 	             G_PKG_NAME, '2210: Issue with document header Record.Cannot commit' );
	     END IF;
             RAISE FND_API.G_EXC_ERROR ;
      END IF;
    END IF;

--Bug 3669528 Refresh settings to prevent function security caching problems
    IF fnd_function.test('OKC_TERMS_AUTHOR_SUPERUSER','N') AND  fnd_function.test('OKC_TERMS_AUTHOR_NON_STD','N') THEN
       l_super_user_yn := 'Y';
    ELSE
       l_super_user_yn := 'N';
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Following code will be deleteing all Subsection and its article.

    FOR cr IN l_subsection_csr(p_id) LOOP
        l_scn_id := cr.id;
        l_ovn    := cr.object_version_number;

      /*IF (l_debug = 'Y') THEN
           okc_debug.log('2220: Calling Delete API to delete Section '|| l_scn_id , 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
 	      G_PKG_NAME, '2220: Calling Delete API to delete Section '|| l_scn_id );
      END IF;

      OKC_TERMS_SECTIONS_GRP.delete_section(
                                      p_api_version       => p_api_version,
                                      p_init_msg_list     => FND_API.G_FALSE,
                                      p_commit            => FND_API.G_FALSE,
                                      x_return_status     => x_return_status,
                                      x_msg_count         => x_msg_count,
                                      x_msg_data          => x_msg_data,
                                      p_mode              => p_mode,
                                      p_id                => l_scn_id,
                                      p_amendment_description => NULL,
                                      p_object_version_number => l_ovn
                                      );
          --------------------------------------------
          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
          END IF;
          --------------------------------------------

         /*IF (l_debug = 'Y') THEN
                okc_debug.log('2230: Section '|| l_scn_id||' deleted' , 2);
         END IF;*/

         IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
            FND_LOG.STRING(G_PROC_LEVEL,
 	        G_PKG_NAME, '2230: Section '|| l_scn_id||' deleted' );
         END IF;
    END LOOP;
    IF l_subsection_csr%ISOPEN then
       CLOSE l_subsection_csr;
    END If;

-- Following code will be deleteing all articles of section.
     /*IF (l_debug = 'Y') THEN
         okc_debug.log('2230: Going to delete Articles of section '|| p_id , 2);
     END IF;*/

     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '2230: Going to delete Articles of section '|| p_id  );
     END IF;

     FOR l_article_rec IN l_get_article_csr(p_id) LOOP


     OKC_K_ARTICLES_GRP.delete_article(
                               p_api_version           => l_api_version,
                               p_init_msg_list         => FND_API.G_FALSE,
                               p_validate_commit       => FND_API.G_FALSE,
                               p_validation_string   => Null,
                               p_commit                => FND_API.G_FALSE,
                               x_return_status         => x_return_status,
                               x_msg_count             => x_msg_count,
                               x_msg_data              => x_msg_data,
                               p_mode                  => p_mode,
                               p_super_user_yn         => l_super_user_yn,
                               p_id                    => l_article_rec.id,
                               p_amendment_description => NULL,
                               p_object_version_number => l_article_rec.object_version_number,
                               p_lock_terms_yn         => p_lock_terms_yn );


           IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
           ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
           END IF;
     END LOOP;

     /*IF (l_debug = 'Y') THEN
           okc_debug.log('2240: Articles of section '|| p_id||' deleted' , 2);
     END IF;*/

     IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '2240: Articles of section '|| p_id||' deleted' );
     END IF;

    IF p_mode='AMEND' THEN

       OPEN  l_get_summary_code_csr;
       FETCH l_get_summary_code_csr INTO l_existing_summary_code,l_existing_operation_code;
       CLOSE l_get_summary_code_csr;

       IF nvl(l_existing_operation_code,'?') <> G_AMEND_CODE_ADDED THEN

              l_summary_amend_operation_code := OKC_TERMS_UTIL_PVT.get_summary_amend_code(p_existing_summary_code =>l_existing_summary_code,
          p_existing_operation_code=>l_existing_operation_code,
          p_amend_operation_code=>G_AMEND_CODE_DELETED);

               -----------------------------------------------------------------
              -- Concurrent Mod Changes
              -- Call the Lock entity API only in AMEND mode
              --                  and when p_lock_terms_yn is 'Y' .
              -----------------------------------------------------------------
              IF (     p_mode='AMEND'
                  AND  p_lock_terms_yn = 'Y'
                  AND  l_orig_system_reference_id1 IS NOT null
                  )
              THEN

                okc_k_entity_locks_grp.lock_entity
                                ( p_api_version     => 1,
                                p_init_msg_list    => FND_API.G_FALSE ,
                                p_commit           => FND_API.G_FALSE,
                                p_entity_name      => okc_k_entity_locks_grp.G_SECTION_ENTITY,
                                p_entity_pk1       => To_Char(l_orig_system_reference_id1),
                                P_LOCK_BY_ENTITY_ID => p_id,
                                p_LOCK_BY_DOCUMENT_TYPE => l_document_type,
                                p_LOCK_BY_DOCUMENT_ID => l_document_id,
                                X_RETURN_STATUS => X_RETURN_STATUS,
                                X_MSG_COUNT => X_MSG_COUNT,
                                X_MSG_DATA => X_MSG_DATA
                                );
                  --------------------------------------------
                  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR ;
                  END IF;
                --------------------------------------------
            END IF;



          --------------------------------------------
          -- Calling Simple API for Updating A Row
          --------------------------------------------

             OKC_TERMS_SECTIONS_PVT.update_row(
                    x_return_status            => x_return_status,
                    p_id                       => p_id,
                    p_amendment_description    => p_amendment_description,
                    p_amendment_operation_code => G_AMEND_CODE_DELETED,
                    p_summary_amend_operation_code => l_summary_amend_operation_code,
                    p_object_version_number    => p_object_version_number
                  );

            --------------------------------------------
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;
           --------------------------------------------
        ELSE
           l_delete_rec := TRUE;
        END IF;
   END IF;

   IF p_mode<>'AMEND' or l_delete_rec THEN
       -- Following Code will delete  the section

       OKC_TERMS_SECTIONS_PVT.delete_row(
              x_return_status              => x_return_status,
              p_id                         => p_id,
              p_object_version_number      => p_object_version_number
                                     );
       --------------------------------------------
       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
       END IF;
       --------------------------------------------
   END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    /*IF (l_debug = 'Y') THEN
       okc_debug.log('2300: Leaving delete_section', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
         FND_LOG.STRING(G_PROC_LEVEL,
             G_PKG_NAME, '2300: Leaving delete_section' );
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('2400: Leaving delete_section: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
   	     G_PKG_NAME, '2400: Leaving delete_section: OKC_API.G_EXCEPTION_ERROR Exception' );
      END IF;

      IF l_document_id_csr%ISOPEN THEN
         CLOSE l_document_id_csr;
      END IF;

      IF l_subsection_csr%ISOPEN then
         CLOSE l_subsection_csr;
      END If;

      IF l_get_article_csr%ISOPEN THEN
         CLOSE l_get_article_csr;
      END IF;

      ROLLBACK TO g_delete_section_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         okc_debug.log('2500: Leaving delete_section: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
   	     G_PKG_NAME, '2500: Leaving delete_section: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
      END IF;

      IF l_document_id_csr%ISOPEN THEN
         CLOSE l_document_id_csr;
      END IF;

      IF l_subsection_csr%ISOPEN then
         CLOSE l_subsection_csr;
      END If;

      IF l_get_article_csr%ISOPEN THEN
         CLOSE l_get_article_csr;
      END IF;

      ROLLBACK TO g_delete_section_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        okc_debug.log('2600: Leaving delete_section because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
   	     G_PKG_NAME, '2600: Leaving delete_section because of EXCEPTION: '||sqlerrm );
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      IF l_document_id_csr%ISOPEN THEN
         CLOSE l_document_id_csr;
      END IF;

      IF l_subsection_csr%ISOPEN then
         CLOSE l_subsection_csr;
      END If;

      IF l_get_article_csr%ISOPEN THEN
         CLOSE l_get_article_csr;
      END IF;

      ROLLBACK TO g_delete_section_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  END delete_section;

   PROCEDURE delete_sections(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2 := NULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mode                       IN VARCHAR2 := 'NORMAL', -- 'NORMAL' or 'AMEND'
    p_super_user_yn              IN  VARCHAR2 :='N',
    p_amendment_description        IN VARCHAR2 := NULL,
    p_id_tbl                         IN id_tbl_type,
    p_obj_vers_number_tbl      IN id_tbl_type,
    p_lock_terms_yn              IN VARCHAR2  := 'N'
    )
    IS
    l_amend_code VARCHAR2(240);
    l_amend_descr VARCHAR2(500) := p_amendment_description;
    l_mode VARCHAR2(240) := p_mode;
    BEGIN


      FOR i IN 1..p_id_tbl.Count()
       LOOP

      /* The following logic exists in  OA layer for a single object delete*/
       IF p_mode = 'AMEND'
       then

          SELECT   amendment_operation_code INTO  l_amend_code
          from okc_sections_b where id = p_id_tbl(i);

          IF  l_amend_code = 'ADDED' THEN
               l_amend_descr := NULL;
               l_mode :=  'NORMAL';
          END IF;

      END IF;
    delete_section(
    p_api_version        => p_api_version,
    p_init_msg_list       =>  p_init_msg_list,
    p_validate_commit           => p_validate_commit,
    p_validation_string          => p_validation_string,
    p_commit                => p_commit,
    x_return_status              => x_return_status,
    x_msg_count            => x_msg_count,
    x_msg_data              => x_msg_data,
    p_mode                  => l_mode, -- 'NORMAL' or 'AMEND'
    p_super_user_yn             => p_super_user_yn,
    p_amendment_description        => l_amend_descr,
    p_id                      => p_id_tbl(i),
    p_object_version_number     => p_obj_vers_number_tbl(i),
    p_lock_terms_yn           => p_lock_terms_yn
    );

       IF  x_return_status <> 'S' THEN
            EXIT;
        END IF;
       END LOOP;
    END delete_sections;


END OKC_TERMS_SECTIONS_GRP;

/
