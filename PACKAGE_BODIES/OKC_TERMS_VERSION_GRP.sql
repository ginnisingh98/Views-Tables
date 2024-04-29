--------------------------------------------------------
--  DDL for Package Body OKC_TERMS_VERSION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMS_VERSION_GRP" AS
/* $Header: OKCGDVRB.pls 120.0.12010000.2 2011/12/09 13:33:10 serukull ship $ */


  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_TERMS_VERSION_GRP';
  G_MODULE                     CONSTANT   VARCHAR2(200) := 'okc.plsql.'||G_PKG_NAME||'.';
  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_RET_STS_SUCCESS            CONSTANT   varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   varchar2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

--<<<<<<<<<<<<<<<<<<<<<<<<<<< EXTERNAL PROCEDURES <<<<<<<<<<<<<<<<<<<<<<<<<<<
/*
-- This API will be used to version terms whenever a document is versioned.
*/
  PROCEDURE Version_Doc (
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_version_number   IN  NUMBER,
    p_clear_amendment  IN  VARCHAR2,
    p_include_gen_attach IN VARCHAR2 DEFAULT 'Y'
  ) IS
    l_api_version       CONSTANT NUMBER := 1;
    l_api_name          CONSTANT VARCHAR2(30) := 'Version_Doc';
    l_contract_source   VARCHAR2(30);

   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered Version_Doc');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'110: p_init_msg_list='||p_init_msg_list);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'120: p_commit='||p_commit);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'130: p_doc_type='||p_doc_type);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'140: p_doc_id='||p_doc_id);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'150: p_version_number='||p_version_number);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'160: p_clear_amendment='||p_clear_amendment);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'170: p_include_gen_attach='||p_include_gen_attach);
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT g_Version_Doc;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;


-- Added for 10+ word integration
    l_contract_source := OKC_TERMS_UTIL_GRP.Get_Contract_Source_Code(
                            p_document_type    => p_doc_type,
                            p_document_id      => p_doc_id
                         );
    IF l_contract_source = 'STRUCTURED' THEN

      --------------------------------------------
      -- Call internal Version_Doc
      --------------------------------------------
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Call Private Version_Doc ');
      END IF;

      OKC_TERMS_VERSION_PVT.Version_Doc(
        x_return_status    => x_return_status,

        p_doc_type         => p_doc_type,
        p_doc_id           => p_doc_id,
        p_version_number   => p_version_number
      );
      --------------------------------------------
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;

    ELSIF l_contract_source = 'ATTACHED' THEN

--Only need to version usages record in case of offline authoring
      --------------------------------------------
      -- Call Create_Version for template usages
      --------------------------------------------
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: Call Create_Version for template usages');
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

    END IF;

    --------------------------------------------
    -- Call private version_deliverables
    --------------------------------------------
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Call Private Version_Doc ');
    END IF;
    OKC_DELIVERABLE_PROCESS_PVT.Version_Deliverables (
      p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      x_return_status    => x_return_status,
      x_msg_data         => x_msg_data,
      x_msg_count        => x_msg_count,

      p_doc_type         => p_doc_type,
      p_doc_id           => p_doc_id,
      p_doc_version      => p_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
    --------------------------------------------
    -- Call private version_attachements
    --------------------------------------------
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Call Private version_Attachments ');
    END IF;
    OKC_CONTRACT_DOCS_GRP.version_Attachments (
      p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
      p_commit           => FND_API.G_FALSE,
      x_return_status    => x_return_status,
      x_msg_data         => x_msg_data,
      x_msg_count        => x_msg_count,

      p_business_document_type   => p_doc_type,
      p_business_document_id     => p_doc_id,
      p_business_document_version=> p_version_number,
      p_include_gen_attach => p_include_gen_attach
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;


   IF p_clear_amendment='Y' THEN
    clear_amendment (
               p_api_version =>1,
               p_commit      => FND_API.G_FALSE,
               x_return_status    => x_return_status,
               x_msg_data         => x_msg_data,
               x_msg_count        => x_msg_count,
               p_doc_type         => p_doc_type,
               p_doc_id           => p_doc_id
                     );
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
   END IF;

    -- commit changes if asked
    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: Leaving Version_Doc');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO g_Version_Doc;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'400: Leaving Version_Doc : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO g_Version_Doc;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving Version_Doc : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      ROLLBACK TO g_Version_Doc;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'600: Leaving Version_Doc because of EXCEPTION: '||sqlerrm);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  END Version_Doc ;

/*
--This API will be used to restore a version terms whenever a version of
-- document is restored.It is a very OKS/OKC/OKO specific functionality
*/
  PROCEDURE Restore_Doc_Version (
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_version_number   IN  NUMBER
  ) IS
    l_api_version       CONSTANT NUMBER := 1;
    l_api_name          CONSTANT VARCHAR2(30) := 'Restore_Doc_Version';
   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered Restore_Doc_Version');
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT g_Restore_Doc_Version;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Delete current document terms
    --------------------------------------------
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Delete current document terms');
    END IF;
    OKC_TERMS_UTIL_PVT.Delete_Doc(
      x_return_status    => x_return_status,

      p_doc_type         => p_doc_type,
      p_doc_id           => p_doc_id
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    --------------------------------------------
    -- Call internal Restore_Doc_Version
    --------------------------------------------
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Call Private Restore_Doc_Version ');
    END IF;

    OKC_TERMS_VERSION_PVT.Restore_Doc_Version(
      x_return_status    => x_return_status,

      p_doc_type         => p_doc_type,
      p_doc_id           => p_doc_id,
      p_version_number   => p_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- commit changes if asked
    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: Leaving Restore_Doc_Version');
    END IF;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO g_Restore_Doc_Version;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'400: Leaving Restore_Doc_Version : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO g_Restore_Doc_Version;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving Restore_Doc_Version : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      ROLLBACK TO g_Restore_Doc_Version;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'600: Leaving Restore_Doc_Version because of EXCEPTION: '||sqlerrm);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  END Restore_Doc_Version ;

/*
--This API will be used to delete terms whenever a version of document is deleted.
*/
  Procedure Delete_Doc_Version (
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_version_number   IN  NUMBER
  ) IS
    l_api_version       CONSTANT NUMBER := 1;
    l_api_name          CONSTANT VARCHAR2(30) := 'Delete_Doc_Version';
   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered Delete_Doc_Version');
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT g_Delete_Doc_Version;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Call internal Delete_Doc_Version
    --------------------------------------------
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Call Private Delete_Doc_Version ');
    END IF;

    OKC_TERMS_VERSION_PVT.Delete_Doc_Version(
      x_return_status    => x_return_status,

      p_doc_type         => p_doc_type,
      p_doc_id           => p_doc_id,
      p_version_number   => p_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
    --  Call Deliverable API to delete delevirable from the document.
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3900: Delete delevirable for the doc version');
    END IF;
    OKC_DELIVERABLE_PROCESS_PVT.Delete_Deliverables(
      p_api_version    => l_api_version,
      p_init_msg_list  => FND_API.G_FALSE,
      p_doc_type       => p_doc_type,
      p_doc_id         => p_doc_id,
      p_doc_version    => p_version_number,
      x_msg_data       => x_msg_data,
      x_msg_count      => x_msg_count,
      x_return_status  => x_return_status
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
    --------------------------------------------
    -- Call private Delete_All_Version_Attach
    --------------------------------------------
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Call Private version_Attachments ');
    END IF;
    OKC_CONTRACT_DOCS_GRP.Delete_Ver_Attachments(
      p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
      p_commit           => FND_API.G_FALSE,
      x_return_status    => x_return_status,
      x_msg_data         => x_msg_data,
      x_msg_count        => x_msg_count,

      p_business_document_type   => p_doc_type,
      p_business_document_id     => p_doc_id,
      p_business_document_version=> p_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;

    -- commit changes if asked
    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: Leaving Delete_Doc_Version');
    END IF;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO g_Delete_Doc_Version;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'400: Leaving Delete_Doc_Version : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO g_Delete_Doc_Version;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving Delete_Doc_Version : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      ROLLBACK TO g_Delete_Doc_Version;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'600: Leaving Delete_Doc_Version because of EXCEPTION: '||sqlerrm);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  END Delete_Doc_Version ;
/* This API will be used to clear amendment related columns */

  Procedure clear_amendment (
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_keep_summary     IN  VARCHAR2
  ) IS
    l_api_version       CONSTANT NUMBER := 1;
    l_api_name          CONSTANT VARCHAR2(30) := 'clear_amendment';
   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered clear_amendment');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'110: p_init_msg_list='||p_init_msg_list);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'120: p_commit='||p_commit);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'130: p_doc_type='||p_doc_type);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'140: p_doc_id='||p_doc_id);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'150: p_keep_summary='||p_keep_summary);
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT g_clear_amendment;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;
    --------------------------------------------
    -- Call internal clear_amendment
    --------------------------------------------
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Call Private clear_amendment ');
    END IF;

    OKC_TERMS_VERSION_PVT.clear_amendment(
      x_return_status    => x_return_status,
      p_doc_type         => p_doc_type,
      p_doc_id           => p_doc_id,
      p_keep_summary     => p_keep_summary
    );

    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: calling deliverables clear_amendment_operation');
END IF;

OKC_DELIVERABLE_PROCESS_PVT.clear_amendment_operation (
        p_api_version   => 1,
        p_init_msg_list => FND_API.G_FALSE,
        p_doc_id        => p_doc_id,
        p_doc_type      => p_doc_type,
        p_keep_summary  => p_keep_summary,
        x_msg_data      => x_msg_data,
        x_msg_count     => x_msg_count,
        x_return_status => x_return_status);

 --------------------------------------------
 IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
 ELSIF (x_return_status = G_RET_STS_ERROR) THEN
       RAISE FND_API.G_EXC_ERROR ;
 END IF;
 --------------------------------------------
IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: leaving deliverables clear_amendment_operation');
END IF;

    -- commit changes if asked
    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: Leaving clear_amendment');
    END IF;


EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO g_clear_amendment;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'400: Leaving clear_amendment : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO g_clear_amendment;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving clear_amendment : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN OTHERS THEN
      ROLLBACK TO g_clear_amendment;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'600: Leaving clear_amendment because of EXCEPTION: '||sqlerrm);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END clear_amendment;

-->>>>>>>>>>>>>>>>>>>>>>>>>>> EXTERNAL PROCEDURES >>>>>>>>>>>>>>>>>>>>>>>>>>>

END OKC_TERMS_VERSION_GRP;

/
