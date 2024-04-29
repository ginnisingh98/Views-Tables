--------------------------------------------------------
--  DDL for Package Body OKC_CONTRACT_DOCS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CONTRACT_DOCS_GRP" AS
/* $Header: OKCGCONTRACTDOCB.pls 120.3.12010000.6 2013/03/22 14:58:37 harchand ship $ */


  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------



  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                            CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_RET_STS_SUCCESS            CONSTANT   varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   varchar2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
  G_CONTRACT_DOC_CATEGORY      CONSTANT   VARCHAR2(200) := 'OKC_REPO_CONTRACT';
  G_CONTRACT_IMAGE_CATEGORY    CONSTANT   VARCHAR2(200) := 'OKC_REPO_CONTRACT_IMAGE';
  G_APP_ABSTRACT_CATEGORY      CONSTANT   VARCHAR2(200) := 'OKC_REPO_APP_ABSTRACT';
  G_SUPPORTING_DOC_CATEGORY    CONSTANT   VARCHAR2(200) := 'OKC_REPO_SUPPORTING_DOC';
  G_PKG_NAME                   CONSTANT   VARCHAR2(40)  := 'OKC_CONTRACT_DOCS_GRP';
  G_MODULE                     CONSTANT   VARCHAR2(200) := 'okc.plsql.'||G_PKG_NAME ||'.';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_COPY_ALL_DOCS              CONSTANT   VARCHAR2(30)  := 'OKC_REP_COPY_ALL_CON_DOCS';


  G_QA_STS_SUCCESS             CONSTANT   varchar2(1) := 'S';
  G_QA_STS_ERROR               CONSTANT   varchar2(1) := 'E';
  G_QA_STS_WARNING             CONSTANT   varchar2(1) := 'W';

  -------------------------------------
  -- PROCEDURE Insert_Contract_Doc
  -------------------------------------
  PROCEDURE Insert_Contract_Doc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_business_document_type    IN VARCHAR2,
    p_business_document_id      IN NUMBER,
    p_business_document_version IN NUMBER,
    p_attached_document_id      IN NUMBER,
    p_external_visibility_flag  IN VARCHAR2,
    p_effective_from_type       IN VARCHAR2,
    p_effective_from_id         IN NUMBER,
    p_effective_from_version    IN NUMBER,
    p_include_for_approval_flag IN VARCHAR2 := 'N',
    p_create_fnd_attach         IN VARCHAR2 := 'Y',
    p_program_id                IN NUMBER,
    p_program_application_id    IN NUMBER,
    p_request_id                IN NUMBER,
    p_program_update_date       IN DATE,
    p_parent_attached_doc_id    IN NUMBER := NULL,
    p_generated_flag            IN VARCHAR2 := 'N',
    p_delete_flag               IN VARCHAR2 := 'N',

    p_primary_contract_doc_flag IN VARCHAR2 := 'N',
    p_mergeable_doc_flag        IN VARCHAR2 := 'N',
    p_versioning_flag           IN VARCHAR2 := 'N',

    x_business_document_type    OUT NOCOPY VARCHAR2,
    x_business_document_id      OUT NOCOPY NUMBER,
    x_business_document_version OUT NOCOPY NUMBER,
    x_attached_document_id      OUT NOCOPY NUMBER

  ) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'Insert_Contract_Doc';
    l_object_version_number     OKC_CONTRACT_DOCS.OBJECT_VERSION_NUMBER%TYPE := 1;
    l_created_by                OKC_CONTRACT_DOCS.CREATED_BY%TYPE;
    l_creation_date             OKC_CONTRACT_DOCS.CREATION_DATE%TYPE;
    l_last_updated_by           OKC_CONTRACT_DOCS.LAST_UPDATED_BY%TYPE;
    l_last_update_login         OKC_CONTRACT_DOCS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date          OKC_CONTRACT_DOCS.LAST_UPDATE_DATE%TYPE;
    l_attached_document_id      OKC_CONTRACT_DOCS.ATTACHED_DOCUMENT_ID%TYPE := p_attached_document_id;
    l_media_id                  FND_DOCUMENTS.MEDIA_ID%TYPE;
    l_pk2_value                 FND_ATTACHED_DOCUMENTS.pk2_value%TYPE;


    -- The following variables are required for updating the pk3_value in fnd_attached_documents table
        l_rowid                     VARCHAR2(120);
        l_document_id               FND_DOCUMENTS.DOCUMENT_ID%TYPE;
        l_new_attachment_id         FND_ATTACHED_DOCUMENTS.ATTACHED_DOCUMENT_ID%TYPE;
        l_parent_attached_doc_id    FND_ATTACHED_DOCUMENTS.ATTACHED_DOCUMENT_ID%TYPE := p_parent_attached_doc_id;
        l_seq_num                   FND_ATTACHED_DOCUMENTS.SEQ_NUM%TYPE := 0;

      CURSOR l_attachment_id_csr IS
         SELECT fnd_attached_documents_s.nextval FROM dual;

      CURSOR seq_csr(l_entity_name VARCHAR2, l_pk1_value VARCHAR2,
                 l_pk2_value NUMBER, l_pk3_value NUMBER) IS
          SELECT max(seq_num) s_num
          FROM FND_ATTACHED_DOCUMENTS
          WHERE entity_name = l_entity_name
          AND   pk1_value = l_pk1_value
          AND   pk2_value = to_char(l_pk2_value)
          AND   pk3_value = to_char(l_pk3_value);



  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '600: Entered Insert_Contract_Doc');
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '601: p_business_document_type : ' || p_business_document_type );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '602: p_business_document_id : ' || p_business_document_id );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '603: p_business_document_version : ' || p_business_document_version );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '604: p_attached_document_id : ' || p_attached_document_id );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '605: p_external_visibility_flag : ' || p_external_visibility_flag );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '606: p_effective_from_type : ' || p_effective_from_type );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '607: p_effective_from_id : ' || p_effective_from_id );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '608: p_effective_from_version : ' || p_effective_from_version );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '609: p_include_for_approval_flag : ' || p_include_for_approval_flag );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '610: p_create_fnd_attach : ' || p_create_fnd_attach );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '611: p_program_id : ' || p_program_id );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '612: p_program_application_id : ' || p_program_application_id );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '613: p_request_id : ' || p_request_id );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '614: p_program_update_date : ' || p_program_update_date );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '615: p_parent_attached_doc_id : ' || p_parent_attached_doc_id );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '616: p_generated_flag : ' || p_generated_flag );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '617: p_delete_flag : ' || p_delete_flag );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '618: p_primary_contract_doc_flag : ' || p_primary_contract_doc_flag );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '619: p_mergeable_doc_flag : ' || p_mergeable_doc_flag );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '620: p_versioning_flag : ' || p_versioning_flag );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_Insert_Contract_Doc_GRP;
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

    -- Do Not Update Primary Flag when Copying or Versioning
    IF p_primary_contract_doc_flag = 'Y' AND p_versioning_flag = 'N'
    THEN
        Clear_Primary_Doc_Flag(
                          p_document_type => p_business_document_type,
                          p_document_id => p_business_document_id,
                          x_return_status => x_return_status);
    END IF;
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Set the value for l_parent_attached_doc_id.
    IF (p_parent_attached_doc_id IS NULL) THEN
        IF (p_business_document_version <> p_effective_from_version) THEN
                l_parent_attached_doc_id := p_attached_document_id;
        END IF;
    END IF;

    l_creation_date := Sysdate;
    l_created_by := Fnd_Global.User_Id;
    l_last_update_date := l_creation_date;
    l_last_updated_by := l_created_by;
    l_last_update_login := Fnd_Global.Login_Id;

    -- ADD LOGIC FOR CREATING RECORDS IN FND_ATTACHED_DOCUMENT table
    IF (p_create_fnd_attach = 'Y') THEN

        --Fetch new attachment id.
        OPEN l_attachment_id_csr;
        FETCH l_attachment_id_csr INTO l_new_attachment_id;
        IF (l_attachment_id_csr%notfound) THEN
            RAISE NO_DATA_FOUND;
        END IF;
        CLOSE l_attachment_id_csr;


        -- Get document_id from FND_ATTACHED_DOCUMENTS table
        SELECT document_id INTO l_document_id
               FROM FND_ATTACHED_DOCUMENTS
               WHERE attached_document_id = p_attached_document_id;

        -- Get SEQ_NUM for the new record being added
        FOR seq_rec IN seq_csr(G_ATTACH_ENTITY_NAME, p_business_document_type, p_business_document_id,
                               p_business_document_version)
          LOOP
              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'640: Max seq is: ' || seq_rec.s_num);
              END IF;
              l_seq_num := seq_rec.s_num;
          END LOOP;
        IF (l_seq_num IS NULL) THEN
                l_seq_num := 0;
        END IF;

        -- Add 1 to the max value returned
        l_seq_num := l_seq_num + 1;
        -- If we are adding a soft-deleted document, we need to add 'D' to pk2_value
        IF (p_delete_flag = 'Y') THEN
        	l_pk2_value := to_char(p_business_document_id) || 'D';
        ELSE
        	l_pk2_value := to_char(p_business_document_id);
        END IF; -- (delete_flag = 'Y')
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'651: document_id is: ' || l_document_id);
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'652: New seq_num is: ' || l_seq_num);
         END IF;
         fnd_attached_documents_pkg.insert_row(
              x_rowid => l_rowid,
              x_attached_document_id => l_new_attachment_id,
              x_document_id => l_document_id,
              x_creation_date => l_creation_date,
              x_created_by    => l_created_by,
              x_last_update_date => l_last_update_date,
              x_last_updated_by => l_last_updated_by,
              x_last_update_login => l_last_update_login,
              x_seq_num => l_seq_num,
              x_entity_name => G_ATTACH_ENTITY_NAME,
              x_column1 => NULL,
              x_pk1_value => p_business_document_type,
              x_pk2_value => l_pk2_value,
              x_pk3_value => to_char(p_business_document_version),
              x_pk4_value => NULL,
              x_pk5_value => NULL,
              x_automatically_added_flag => 'N',
              x_datatype_id => NULL,
              x_category_id => NULL,
              x_security_type => NULL,
              x_publish_flag => NULL,
              x_usage_type => NULL,
              x_language => NULL,
              x_media_id => l_media_id,
              x_doc_attribute_category => NULL,
              x_doc_attribute1 => NULL,
              x_doc_attribute2 => NULL,
              x_doc_attribute3 => NULL,
              x_doc_attribute4 => NULL,
              x_doc_attribute5 => NULL,
              x_doc_attribute6 => NULL,
              x_doc_attribute7 => NULL,
              x_doc_attribute8 => NULL,
              x_doc_attribute9 => NULL,
              x_doc_attribute10 => NULL,
              x_doc_attribute11 => NULL,
              x_doc_attribute12 => NULL,
              x_doc_attribute13 => NULL,
              x_doc_attribute14 => NULL,
              x_doc_attribute15 => NULL,
              X_create_doc => 'N'
          );
          l_attached_document_id := l_new_attachment_id;

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'653: new_attached_doc_id is: ' || l_new_attachment_id);
          END IF;

    END IF;


    --------------------------------------------
    -- Calling Simple API for Creating A Row
    --------------------------------------------
    OKC_CONTRACT_DOCS_PVT.Insert_Row(
      p_validation_level           =>   p_validation_level,
      x_return_status              =>   x_return_status,
      p_business_document_type    => p_business_document_type,
      p_business_document_id      => p_business_document_id,
      p_business_document_version => p_business_document_version,
      p_attached_document_id      => l_attached_document_id,
      p_external_visibility_flag  => p_external_visibility_flag,
      p_effective_from_type       => p_effective_from_type,
      p_effective_from_id         => p_effective_from_id,
      p_effective_from_version    => p_effective_from_version,
      p_include_for_approval_flag => p_include_for_approval_flag,
      p_program_id                => p_program_id,
      p_program_application_id    => p_program_application_id,
      p_request_id                => p_request_id,
      p_program_update_date       => p_program_update_date,
      p_parent_attached_doc_id    => l_parent_attached_doc_id,
      p_generated_flag            => p_generated_flag,
      p_delete_flag               => p_delete_flag,

      p_primary_contract_doc_flag => p_primary_contract_doc_flag,
      p_mergeable_doc_flag        => p_mergeable_doc_flag,

      x_business_document_type    => x_business_document_type,
      x_business_document_id      => x_business_document_id,
      x_business_document_version => x_business_document_version,
      x_attached_document_id      => x_attached_document_id
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
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'700: Leaving Insert_Contract_Doc');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'800: Leaving Insert_Contract_Doc: OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      IF l_attachment_id_csr%ISOPEN THEN
         CLOSE l_attachment_id_csr;
      END IF;
      ROLLBACK TO g_Insert_Contract_Doc_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'900: Leaving Insert_Contract_Doc: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      IF l_attachment_id_csr%ISOPEN THEN
         CLOSE l_attachment_id_csr;
      END IF;
      ROLLBACK TO g_Insert_Contract_Doc_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1000: Leaving Insert_Contract_Doc because of EXCEPTION: '||sqlerrm);
      END IF;
      IF l_attachment_id_csr%ISOPEN THEN
        CLOSE l_attachment_id_csr;
      END IF;
      ROLLBACK TO g_Insert_Contract_Doc_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END Insert_Contract_Doc;






  ---------------------------------------------------------------------------
  -- PROCEDURE Update_Contract_Doc
  ---------------------------------------------------------------------------
  PROCEDURE Update_Contract_Doc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_business_document_type    IN VARCHAR2,
    p_business_document_id      IN NUMBER,
    p_business_document_version IN NUMBER,
    p_attached_document_id      IN NUMBER,
    p_external_visibility_flag  IN VARCHAR2,
    p_effective_from_type       IN VARCHAR2,
    p_effective_from_id         IN NUMBER,
    p_effective_from_version    IN NUMBER,
    p_include_for_approval_flag IN VARCHAR2 := 'N',
    p_program_id                IN NUMBER,
    p_program_application_id    IN NUMBER,
    p_request_id                IN NUMBER,
    p_program_update_date       IN DATE,
    p_parent_attached_doc_id    IN NUMBER,
    p_generated_flag            IN VARCHAR2 := 'N',
    p_delete_flag               IN VARCHAR2 := 'N',
    p_primary_contract_doc_flag IN VARCHAR2,
    p_mergeable_doc_flag        IN VARCHAR2,
    p_object_version_number     IN NUMBER,
    p_versioning_flag           IN VARCHAR2 := 'N'

   ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'Update_Contract_Doc';

    l_primary_doc_yn            VARCHAR2(1);

    CURSOR contract_doc_csr IS
      SELECT primary_contract_doc_flag
      FROM OKC_CONTRACT_DOCS
      WHERE business_document_type = p_business_document_type
       AND business_document_id = p_business_document_id
       AND business_document_version = p_business_document_version
       AND attached_document_id = p_attached_document_id;


  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '1600: Entered Update_Contract_Doc');
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '1601: p_business_document_type : ' || p_business_document_type );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '1602: p_business_document_id : ' || p_business_document_id );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '1603: p_business_document_version : ' || p_business_document_version );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '1604: p_attached_document_id : ' || p_attached_document_id );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '1605: p_external_visibility_flag : ' || p_external_visibility_flag );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '1606: p_effective_from_type : ' || p_effective_from_type );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '1607: p_effective_from_id : ' || p_effective_from_id );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '1608: p_effective_from_version : ' || p_effective_from_version );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '1609: p_include_for_approval_flag : ' || p_include_for_approval_flag );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '1611: p_program_id : ' || p_program_id );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '1612: p_program_application_id : ' || p_program_application_id );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '1613: p_request_id : ' || p_request_id );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '1614: p_program_update_date : ' || p_program_update_date );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '1615: p_parent_attached_doc_id : ' || p_parent_attached_doc_id );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '1616: p_generated_flag : ' || p_generated_flag );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '1617: p_delete_flag : ' || p_delete_flag );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '1618: p_primary_contract_doc_flag : ' || p_primary_contract_doc_flag );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '1619: p_mergeable_doc_flag : ' || p_mergeable_doc_flag );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '1620: p_versioning_flag : ' || p_versioning_flag );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_Update_Contract_Doc_GRP;
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

    -- Get the doc's primary_contract_doc_flag
    OPEN contract_doc_csr;
    FETCH contract_doc_csr INTO l_primary_doc_yn;
    IF(contract_doc_csr%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
    END IF;
    -- Do Not Clear Primary Flag when Copying or Versioning
	-- or if the doc being modified is primary
    IF p_primary_contract_doc_flag = 'Y' AND p_versioning_flag = 'N' AND l_primary_doc_yn = 'N'
    THEN
       -- Remove existing primary document flag.
       Clear_Primary_Doc_Flag(
                          p_document_type => p_business_document_type,
                          p_document_id   => p_business_document_id,
                          x_return_status => x_return_status);

    END IF;
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
    CLOSE contract_doc_csr;

    --------------------------------------------
    -- Calling Simple API for Updating A Row
    --------------------------------------------
    OKC_CONTRACT_DOCS_PVT.Update_Row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      p_business_document_type    => p_business_document_type,
      p_business_document_id      => p_business_document_id,
      p_business_document_version => p_business_document_version,
      p_attached_document_id      => p_attached_document_id,
      p_external_visibility_flag  => p_external_visibility_flag,
      p_effective_from_type       => p_effective_from_type,
      p_effective_from_id         => p_effective_from_id,
      p_effective_from_version    => p_effective_from_version,
      p_include_for_approval_flag => p_include_for_approval_flag,
      p_program_id                => p_program_id,
      p_program_application_id    => p_program_application_id,
      p_request_id                => p_request_id,
      p_program_update_date       => p_program_update_date,
      p_parent_attached_doc_id    => p_parent_attached_doc_id,
      p_generated_flag            => p_generated_flag,
      p_delete_flag               => p_delete_flag,
      p_object_version_number     => p_object_version_number,
      p_primary_contract_doc_flag => p_primary_contract_doc_flag,
      p_mergeable_doc_flag        => p_mergeable_doc_flag
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
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: Leaving Update_Contract_Doc');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1900: Leaving Update_Contract_Doc: OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      IF (contract_doc_csr%ISOPEN) THEN
         CLOSE contract_doc_csr ;
      END IF;
      ROLLBACK TO g_Update_Contract_Doc_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2000: Leaving Update_Contract_Doc: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      IF (contract_doc_csr%ISOPEN) THEN
         CLOSE contract_doc_csr ;
      END IF;
      ROLLBACK TO g_Update_Contract_Doc_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2100: Leaving Update_Contract_Doc because of EXCEPTION: '||sqlerrm);
      END IF;
      IF (contract_doc_csr%ISOPEN) THEN
         CLOSE contract_doc_csr ;
      END IF;
      ROLLBACK TO g_Update_Contract_Doc_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END Update_Contract_Doc;



  ---------------------------------------------------------------------------
  -- PROCEDURE Delete_Contract_Doc
  ---------------------------------------------------------------------------
  PROCEDURE Delete_Contract_Doc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_business_document_type    IN VARCHAR2,
    p_business_document_id      IN NUMBER,
    p_business_document_version IN NUMBER,
    p_attached_document_id      IN NUMBER,
    p_doc_approved_flag         IN VARCHAR2 := 'N',
    p_object_version_number     IN NUMBER
  ) IS
    l_api_version               CONSTANT NUMBER := 1;
    l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Contract_Doc';
    l_effective_from_type       OKC_CONTRACT_DOCS.EFFECTIVE_FROM_TYPE%TYPE;
    l_effective_from_id         OKC_CONTRACT_DOCS.EFFECTIVE_FROM_ID%TYPE;
    l_effective_from_version    OKC_CONTRACT_DOCS.EFFECTIVE_FROM_VERSION%TYPE;
    l_datatype_id               FND_DOCUMENTS.DATATYPE_ID%TYPE := -1;
    l_attached_document_id      FND_ATTACHED_DOCUMENTS.ATTACHED_DOCUMENT_ID%TYPE := -1;
    l_object_version_number     NUMBER := -1;
    l_doc_approved_flag         VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_parent_attached_doc_id    OKC_CONTRACT_DOCS.PARENT_ATTACHED_DOC_ID%TYPE;
    l_pk2_value                 FND_ATTACHED_DOCUMENTS.pk2_value%TYPE;

    CURSOR attach_csr(l_bus_doc_type VARCHAR2, l_bus_doc_id NUMBER, l_bus_doc_version NUMBER, l_attached_doc_id NUMBER) IS
                        SELECT * FROM OKC_CONTRACT_DOCS
                        WHERE business_document_type = l_bus_doc_type
                        AND   business_document_id = l_bus_doc_id
                        AND   business_document_version = l_bus_doc_version
                        AND   attached_document_id = l_attached_doc_id
                        AND   delete_flag = 'N';

    CURSOR child_ref_attach_csr(l_bus_doc_type VARCHAR2, l_bus_doc_id NUMBER, l_bus_doc_version NUMBER, l_attached_doc_id NUMBER) IS
                        SELECT * FROM OKC_CONTRACT_DOCS
                        WHERE business_document_type = l_bus_doc_type
                        AND   business_document_id = l_bus_doc_id
                        AND   effective_from_version = l_bus_doc_version
                        AND   parent_attached_doc_id = l_attached_doc_id;

    CURSOR rel_ref_attach_csr(l_bus_doc_type VARCHAR2, l_bus_doc_id NUMBER, l_parent_attached_doc_id NUMBER) IS
                           SELECT * FROM OKC_CONTRACT_DOCS
                        WHERE business_document_type = l_bus_doc_type
                        AND   business_document_id = l_bus_doc_id
                        AND   business_document_version = G_CURRENT_VERSION
                        AND   parent_attached_doc_id = l_parent_attached_doc_id
                        AND   delete_flag = 'N';

    CURSOR fnd_attached_doc_csr IS
      SELECT fad.rowid, fad.*
      FROM FND_ATTACHED_DOCUMENTS fad
      WHERE attached_document_id = p_attached_document_id;


    CURSOR fnd_doc_csr(l_document_id NUMBER) IS
     SELECT
       B.datatype_id datatype_id,
       B.category_id category_id,
       B.security_type security_type,
       B.security_id security_id,
       B.publish_flag publish_flag,
       B.image_type image_type,
       B.storage_type storage_type,
       B.usage_type usage_type,
       B.start_date_active start_date_active,
       B.end_date_active end_date_active,
       TL.language language,
       TL.description description,
       B.file_name file_name,
       B.url url,
       B.media_id media_id
     FROM fnd_documents B, fnd_documents_tl TL
     WHERE B.document_id = l_document_id
      AND   TL.document_id = l_document_id
      AND   TL.language =  USERENV('LANG');


    fnd_attached_doc_rec       fnd_attached_doc_csr%ROWTYPE;
    fnd_doc_rec                fnd_doc_csr%ROWTYPE;

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '2200: Entered Delete_Contract_Doc');
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '2201: p_business_document_type : ' || p_business_document_type );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '2202: p_business_document_id : ' || p_business_document_id );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '2203: p_business_document_version : ' || p_business_document_version );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '2204: p_attached_document_id : ' || p_attached_document_id );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '2205: p_doc_approved_flag : ' || p_doc_approved_flag );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '2206: p_object_version_number : ' || p_object_version_number );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_Delete_Contract_Doc_GRP;
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

    -- Get the parent attached_doc_id
    SELECT parent_attached_doc_id
           INTO l_parent_attached_doc_id
    FROM OKC_CONTRACT_DOCS
    WHERE business_document_type = p_business_document_type
        AND business_document_id = p_business_document_id
        AND business_document_version = p_business_document_version
        AND attached_document_id = p_attached_document_id;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2258: parent attached doc id is: ' || l_parent_attached_doc_id);
    END IF;

    -- Check to see if are deleting an archived record before deleting it's references in -99 version.
       FOR child_ref_attach_rec IN child_ref_attach_csr(p_business_document_type, p_business_document_id,
                            p_business_document_version, p_attached_document_id)
            LOOP
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2259-1: Fetching child reference record');
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2260-1:doc type is: ' || child_ref_attach_rec.business_document_type);
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2261-1:doc id is: ' || child_ref_attach_rec.business_document_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2262-1:doc version is: ' || child_ref_attach_rec.business_document_version);
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2263-1:attached_document_id is: ' || child_ref_attach_rec.attached_document_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2264-1:effective_from_version is: ' || child_ref_attach_rec.effective_from_version);
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2265-1:delete_flag is: ' || child_ref_attach_rec.delete_flag);
                END IF;

                OKC_CONTRACT_DOCS_GRP.delete_contract_doc(
                                 p_api_version => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         p_business_document_type => child_ref_attach_rec.business_document_type,
                                         p_business_document_id => child_ref_attach_rec.business_document_id,
                                         p_business_document_version => child_ref_attach_rec.business_document_version,
                                         p_attached_document_id => child_ref_attach_rec.attached_document_id,
                                         p_doc_approved_flag => p_doc_approved_flag,
                                         p_object_version_number => child_ref_attach_rec.object_version_number,
                                         x_msg_data                  => l_msg_data,
                                         x_msg_count                 => l_msg_count,
                                         x_return_status             => l_return_status);
                IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                 ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                      RAISE FND_API.G_EXC_ERROR ;
                 END IF;

            END LOOP;

    -- If we are deleting a record in an archived version, we need to delete it's related records in -99 version.
    IF ((p_business_document_version <> G_CURRENT_VERSION) AND (l_parent_attached_doc_id is not NULL)) THEN
       FOR rel_ref_attach_rec IN rel_ref_attach_csr(p_business_document_type, p_business_document_id,
                                   l_parent_attached_doc_id)
            LOOP
               IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2259-2: Fetching related reference record');
                   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2260-2:doc type is: ' || rel_ref_attach_rec.business_document_type);
                   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2261-2:doc id is: ' || rel_ref_attach_rec.business_document_id);
                   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2262-2:doc version is: ' || rel_ref_attach_rec.business_document_version);
                   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2263-2:attached_document_id is: ' || rel_ref_attach_rec.attached_document_id);
                   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2264-2:effective_from_version is: ' || rel_ref_attach_rec.effective_from_version);
                   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2265-2:delete_flag is: ' || rel_ref_attach_rec.delete_flag);
               END IF;

               OKC_CONTRACT_DOCS_GRP.delete_contract_doc(
                                 p_api_version => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         p_business_document_type => rel_ref_attach_rec.business_document_type,
                                         p_business_document_id => rel_ref_attach_rec.business_document_id,
                                         p_business_document_version => rel_ref_attach_rec.business_document_version,
                                         p_attached_document_id => rel_ref_attach_rec.attached_document_id,
                                         p_doc_approved_flag => p_doc_approved_flag,
                                         p_object_version_number => rel_ref_attach_rec.object_version_number,
                                         x_msg_data                  => l_msg_data,
                                         x_msg_count                 => l_msg_count,
                                         x_return_status             => l_return_status);
                 IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                 ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                      RAISE FND_API.G_EXC_ERROR ;
                 END IF;

            END LOOP;

    END IF;


        SELECT effective_from_type, effective_from_id, effective_from_version
                        INTO l_effective_from_type, l_effective_from_id, l_effective_from_version
                        FROM OKC_CONTRACT_DOCS
                        WHERE business_document_type = p_business_document_type
                          AND business_document_id = p_business_document_id
                          AND business_document_version = p_business_document_version
                          AND attached_document_id = p_attached_document_id;

    -- For MS Word integration, we need to soft delete the ref. attachments. Using  l_parent_attached_doc_id to check
    -- for reference
    if ((p_doc_approved_flag = 'Y') OR
       (NVL(l_parent_attached_doc_id, p_attached_document_id) <> p_attached_document_id)) THEN
       -- (l_effective_from_type = p_business_document_type AND
       --  l_effective_from_id = p_business_document_id AND
       --   l_effective_from_version <> p_business_document_version) THEN
        -- DO not delete anything. Just update the OKC_CONTRACT_DOCS record to delete_flag='Y' and
        -- add 'D' suffix to FND_ATTACHED_DOCUMENTS record's pk2_value column.
        FOR attach_rec IN attach_csr(p_business_document_type, p_business_document_id,
                            p_business_document_version, p_attached_document_id)
            LOOP
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2260:doc type is: ' || attach_rec.business_document_type);
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2261:doc id is: ' || attach_rec.business_document_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2262:doc version is: ' || attach_rec.business_document_version);
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2263:attached_document_id is: ' || attach_rec.attached_document_id);
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2264:effective_from_version is: ' || attach_rec.effective_from_version);
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2265:delete_flag is: ' || attach_rec.delete_flag);
                END IF;
                -- Open the fnd_attached_doc_csr and fnd_doc_csr cursors to fetch the FND attachment record to be updated.
                OPEN fnd_attached_doc_csr;
                FETCH fnd_attached_doc_csr INTO fnd_attached_doc_rec;
                IF(fnd_attached_doc_csr%NOTFOUND) THEN
                    RAISE NO_DATA_FOUND;
                END IF;

                OPEN fnd_doc_csr(fnd_attached_doc_rec.document_id);
                FETCH fnd_doc_csr INTO fnd_doc_rec;
                IF(fnd_doc_csr%NOTFOUND) THEN
                    RAISE NO_DATA_FOUND;
                END IF;

                -- Append 'D' to pk2_value
                l_pk2_value := fnd_attached_doc_rec.pk2_value || 'D';
                -- Update the corresponding record in FND_ATTACHED_DOCUMENTS tables. Add 'D' to pk2_value column.
                fnd_attached_documents_pkg.Update_Row(
				     X_Rowid                        => fnd_attached_doc_rec.rowid,
                     X_attached_document_id         => fnd_attached_doc_rec.attached_document_id,
                     X_document_id                  => fnd_attached_doc_rec.document_id,
                     X_last_update_date             => fnd_attached_doc_rec.last_update_date,
                     X_last_updated_by              => fnd_attached_doc_rec.last_updated_by,
                     X_last_update_login            => fnd_attached_doc_rec.last_update_login,
                     X_seq_num                      => fnd_attached_doc_rec.seq_num,
                     X_entity_name                  => fnd_attached_doc_rec.entity_name,
                     X_column1                      => fnd_attached_doc_rec.column1,
                     X_pk1_value                    => fnd_attached_doc_rec.pk1_value,
                     X_pk2_value                    => l_pk2_value,
                     X_pk3_value                    => fnd_attached_doc_rec.pk3_value,
                     X_pk4_value                    => fnd_attached_doc_rec.pk4_value,
                     X_pk5_value                    => fnd_attached_doc_rec.pk5_value,
	                 X_automatically_added_flag     => fnd_attached_doc_rec.automatically_added_flag,
                     X_request_id                   => fnd_attached_doc_rec.request_id,
                     X_program_application_id       => fnd_attached_doc_rec.program_application_id,
                     X_program_id                   => fnd_attached_doc_rec.program_id,
                     /*  columns necessary for updating a fnd_document*/
                     X_datatype_id                  => fnd_doc_rec.datatype_id,
                     X_category_id                  => fnd_doc_rec.category_id,
                     X_security_type                => fnd_doc_rec.security_type,
                     X_security_id                  => fnd_doc_rec.security_id,
                     X_publish_flag                 => fnd_doc_rec.publish_flag,
                     X_image_type                   => fnd_doc_rec.image_type,
                     X_storage_type                 => fnd_doc_rec.storage_type,
                     X_usage_type                   => fnd_doc_rec.usage_type,
                     X_start_date_active            => fnd_doc_rec.start_date_active,
                     X_end_date_active              => fnd_doc_rec.end_date_active,
                     X_language                     => fnd_doc_rec.language,
                     X_description                  => fnd_doc_rec.description,
                     X_file_name                    => fnd_doc_rec.file_name,
                     X_url                          => fnd_doc_rec.url,
                     X_media_id                     => fnd_doc_rec.media_id);

                -- Close cursors.
                CLOSE fnd_attached_doc_csr;
                CLOSE fnd_doc_csr;

                -- Update the record in OKC_CONTRACT_DOCS table, set delete_flag='Y'
                OKC_CONTRACT_DOCS_PVT.Update_Row(
                         x_return_status             => l_return_status,
                         p_business_document_type    => attach_rec.business_document_type,
                         p_business_document_id      => attach_rec.business_document_id,
                         p_business_document_version => attach_rec.business_document_version,
                         p_attached_document_id      => attach_rec.attached_document_id,
                         p_external_visibility_flag  => attach_rec.external_visibility_flag,
                         p_effective_from_type       => attach_rec.effective_from_type,
                         p_effective_from_id         => attach_rec.effective_from_id,
                         p_effective_from_version    => attach_rec.effective_from_version,
                         p_include_for_approval_flag => attach_rec.include_for_approval_flag,
                         p_program_id                => attach_rec.program_id,
                         p_program_application_id    => attach_rec.program_application_id,
                         p_request_id                => attach_rec.request_id,
                         p_program_update_date       => attach_rec.program_update_date,
                         p_parent_attached_doc_id    => attach_rec.parent_attached_doc_id,
                         p_generated_flag            => attach_rec.generated_flag,
                         p_primary_contract_doc_flag => attach_rec.primary_contract_doc_flag,
                         p_mergeable_doc_flag        => attach_rec.mergeable_doc_flag,
                         p_delete_flag               => 'Y',
                         p_object_version_number     => p_object_version_number
                         );
                 IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                 ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                      RAISE FND_API.G_EXC_ERROR ;
                 END IF;
            END LOOP;
    ELSE
        -- Delete the record
        SELECT d.datatype_id INTO l_datatype_id
                        FROM fnd_documents d, fnd_attached_documents ad
                        WHERE d.document_id = ad.document_id
                                  AND ad.attached_document_id = p_attached_document_id;

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2250: p_business_document_type is: ' || p_business_document_type);
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2251: p_business_document_id is: ' || p_business_document_id);
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2252: p_business_document_version is: ' || p_business_document_version);
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2253: p_attached_document_id is: ' || p_attached_document_id);
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2254: l_effective_from_type is: ' || l_effective_from_type);
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2255: l_effective_from_id is: ' || l_effective_from_id);
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2256: l_effective_from_version is: ' || l_effective_from_version);
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2257: l_datatype_id is: ' || l_datatype_id);
            END IF;
            -- If current document, delete data in FND tables.
                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2258: Deleting FND Attachments');
                        END IF;
                         -- Call FND delete attachment API to delete Media as well
                            FND_ATTACHED_DOCUMENTS3_PKG.DELETE_ROW(
                                X_attached_document_id => p_attached_document_id,
                                X_datatype_id          => l_datatype_id,
                                delete_document_flag   => 'Y');

            --------------------------------------------------------------------
            -- Calling Simple API for Deleting A Row
            --------------------------------------------------------------------
            OKC_CONTRACT_DOCS_PVT.Delete_Row(
             x_return_status              =>   x_return_status,
             p_business_document_type    => p_business_document_type,
             p_business_document_id      => p_business_document_id,
             p_business_document_version => p_business_document_version,
             p_attached_document_id      => p_attached_document_id,
             p_object_version_number     => p_object_version_number
            );
    END IF;

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
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2300: Leaving Delete_Contract_Doc');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2400: Leaving Delete_Contract_Doc: OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      --close cursors
      IF (fnd_attached_doc_csr%ISOPEN) THEN
         CLOSE fnd_attached_doc_csr ;
      END IF;
      IF (fnd_doc_csr%ISOPEN) THEN
         CLOSE fnd_doc_csr ;
      END IF;
      ROLLBACK TO g_Delete_Contract_Doc_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2500: Leaving Delete_Contract_Doc: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      IF (fnd_attached_doc_csr%ISOPEN) THEN
         CLOSE fnd_attached_doc_csr ;
      END IF;
      IF (fnd_doc_csr%ISOPEN) THEN
         CLOSE fnd_doc_csr ;
      END IF;
      ROLLBACK TO g_Delete_Contract_Doc_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2600: Leaving Delete_Contract_Doc because of EXCEPTION: '||sqlerrm);
      END IF;
      IF (fnd_attached_doc_csr%ISOPEN) THEN
         CLOSE fnd_attached_doc_csr ;
      END IF;
      IF (fnd_doc_csr%ISOPEN) THEN
         CLOSE fnd_doc_csr ;
      END IF;
      ROLLBACK TO g_Delete_Contract_Doc_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END Delete_Contract_Doc;




---------------------------------------------------------------------------
  -- PROCEDURE Version_Attachments
---------------------------------------------------------------------------
PROCEDURE Version_Attachments(
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                    IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,

    p_business_document_type    IN VARCHAR2,
    p_business_document_id      IN NUMBER,
    p_business_document_version IN NUMBER,
    p_include_gen_attach IN VARCHAR2 DEFAULT 'Y'
    ) IS l_api_name              CONSTANT VARCHAR2(30) := 'Version_Attachments';
 l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

 l_msg_count             NUMBER;
 l_msg_data              FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
 l_api_version           NUMBER := 1;
 l_business_document_type     OKC_CONTRACT_DOCS.BUSINESS_DOCUMENT_TYPE%TYPE;
 l_business_document_id       OKC_CONTRACT_DOCS.BUSINESS_DOCUMENT_ID%TYPE;
 l_business_document_version  OKC_CONTRACT_DOCS.BUSINESS_DOCUMENT_VERSION%TYPE;
 l_attached_document_id       FND_ATTACHED_DOCUMENTS.ATTACHED_DOCUMENT_ID%TYPE;
 l_datatype_id                FND_DOCUMENTS.DATATYPE_ID%TYPE;
 l_effective_from_version     OKC_CONTRACT_DOCS.effective_from_version%TYPE;
 l_parent_attached_doc_id     OKC_CONTRACT_DOCS.parent_attached_doc_id%TYPE;
 l_non_ref_attachment_created VARCHAR2(1);


  -- Attachment cursor
  CURSOR attach_csr(l_bus_doc_type VARCHAR2, l_bus_doc_id NUMBER, l_bus_doc_version NUMBER) IS
        SELECT * FROM OKC_CONTRACT_DOCS
        WHERE business_document_type = l_bus_doc_type
        AND   business_document_id = l_bus_doc_id
        AND   business_document_version = l_bus_doc_version;
        -- AND   delete_flag = 'N';

  -- cursor for deleting prev. version deleted ref. attachments in -99
  CURSOR ref_del_csr(l_bus_doc_type VARCHAR2, l_bus_doc_id NUMBER,
                     l_bus_doc_version NUMBER, l_curr_version NUMBER) IS
        SELECT * FROM OKC_CONTRACT_DOCS
        WHERE business_document_type = l_bus_doc_type
        AND   business_document_id = l_bus_doc_id
        AND   business_document_version = l_curr_version
        AND   effective_from_type = l_bus_doc_type
        AND   effective_from_id = l_bus_doc_id
        AND   effective_from_version < l_bus_doc_version
        AND   effective_from_version <> l_curr_version
        AND   delete_flag = 'Y';

  -- data_type cursor, will be required for deleting current version generated doc.
  CURSOR datatype_csr (l_attached_document_id NUMBER) IS
        SELECT d.datatype_id
        FROM fnd_documents d, fnd_attached_documents ad
        WHERE d.document_id = ad.document_id
        AND ad.attached_document_id = l_attached_document_id;

BEGIN
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '2700: Entered Version_Attachments');
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '2701: p_business_document_type : ' || p_business_document_type );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '2702: p_business_document_id : ' || p_business_document_id );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '2703: p_business_document_version : ' || p_business_document_version );
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	      '2704: p_include_gen_attach : ' || p_include_gen_attach );
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT Version_Attachments_GRP;
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

  FOR attach_rec IN attach_csr(p_business_document_type, p_business_document_id,G_CURRENT_VERSION)  LOOP
     l_non_ref_attachment_created := 'N';
     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2710:doc version is: ' || attach_rec.business_document_version);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2720:attch doc id is: ' || attach_rec.attached_document_id);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2730:effective_from_type is: ' || attach_rec.effective_from_type);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2730:effective_from_id is: ' || attach_rec.effective_from_id);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2730:effective_from_version is: ' || attach_rec.effective_from_version);
     END IF;
     -- Set the value of effective_from_version column
     IF (attach_rec.effective_from_version = G_CURRENT_VERSION) THEN
         l_effective_from_version := p_business_document_version;
     ELSE
     	 l_effective_from_version := attach_rec.effective_from_version;
     END IF;  -- (attach_rec.effective_from_version = G_CURRENT_VERSION)
	 -- Copy the existing current version attachment to the specific version
     IF (attach_rec.effective_from_version <> G_CURRENT_VERSION) THEN
         -- Create version attachment with p_parent_attached_doc_id
         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2731: Inserting New Ref recpord');
         END IF;
         Insert_Contract_Doc (
           p_api_version               => l_api_version,
           p_init_msg_list             => FND_API.G_FALSE,
           p_business_document_type    => attach_rec.business_document_type,
           p_business_document_id      => attach_rec.business_document_id,
           p_business_document_version => p_business_document_version,
           p_attached_document_id      => attach_rec.attached_document_id,
           p_external_visibility_flag  => attach_rec.external_visibility_flag,
           p_effective_from_type       => attach_rec.effective_from_type,
           p_effective_from_id         => attach_rec.effective_from_id,
           p_effective_from_version    => l_effective_from_version,
           p_include_for_approval_flag => attach_rec.include_for_approval_flag,
           p_generated_flag            => attach_rec.generated_flag,
           p_primary_contract_doc_flag => attach_rec.primary_contract_doc_flag,
           p_mergeable_doc_flag        => attach_rec.mergeable_doc_flag,
           p_delete_flag               => attach_rec.delete_flag,
           p_create_fnd_attach         => 'Y',
           p_program_id                => NULL,
           p_program_application_id    => NULL,
           p_request_id                => NULL,
           p_program_update_date       => NULL,
           p_parent_attached_doc_id    => attach_rec.parent_attached_doc_id,
           p_versioning_flag           => 'Y',
           x_msg_data                  => l_msg_data,
           x_msg_count                 => l_msg_count,
           x_return_status             => l_return_status,
           x_business_document_type    => l_business_document_type,
           x_business_document_id      => l_business_document_id,
           x_business_document_version => l_business_document_version,
           x_attached_document_id      => l_attached_document_id);
     ELSE
         -- Create version attachment without p_parent_attached_doc_id
         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2732: Inserting New Non-Ref recpord');
         END IF;
         Insert_Contract_Doc (
           p_api_version               => l_api_version,
           p_init_msg_list             => FND_API.G_FALSE,
           p_business_document_type    => attach_rec.business_document_type,
           p_business_document_id      => attach_rec.business_document_id,
           p_business_document_version => p_business_document_version,
           p_attached_document_id      => attach_rec.attached_document_id,
           p_external_visibility_flag  => attach_rec.external_visibility_flag,
           p_effective_from_type       => attach_rec.effective_from_type,
           p_effective_from_id         => attach_rec.effective_from_id,
           p_effective_from_version    => l_effective_from_version,
           p_include_for_approval_flag => attach_rec.include_for_approval_flag,
           p_generated_flag            => attach_rec.generated_flag,
           p_primary_contract_doc_flag => attach_rec.primary_contract_doc_flag,
           p_mergeable_doc_flag        => attach_rec.mergeable_doc_flag,
           p_delete_flag               => attach_rec.delete_flag,
           p_create_fnd_attach         => 'Y',
           p_program_id                => NULL,
           p_program_application_id    => NULL,
           p_request_id                => NULL,
           p_program_update_date       => NULL,
           p_versioning_flag           => 'Y',
           x_msg_data                  => l_msg_data,
           x_msg_count                 => l_msg_count,
           x_return_status             => l_return_status,
           x_business_document_type    => l_business_document_type,
           x_business_document_id      => l_business_document_id,
           x_business_document_version => l_business_document_version,
           x_attached_document_id      => l_attached_document_id);

        l_non_ref_attachment_created := 'Y';

     END IF;  -- (attach_rec.effective_from_version = G_CURRENT_VERSION)
     --  Check for errors
   	 IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Set the value of parent_attached_doc_id column of new current version attachments
     IF (l_non_ref_attachment_created = 'Y') THEN
         l_parent_attached_doc_id := l_attached_document_id;
     ELSE
     	 l_parent_attached_doc_id := attach_rec.parent_attached_doc_id;
     END IF;  -- (attach_rec.effective_from_version = G_CURRENT_VERSION)



     IF NOT (p_include_gen_attach = 'N' AND attach_rec.generated_flag = 'Y') THEN
       -- Updated current version record's effective_from_version and parent_attached_doc_id columns
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2733: Updating Current attachment');
       END IF;
       Update_Contract_Doc (
         p_api_version               => l_api_version,
         p_init_msg_list             => p_init_msg_list,
         p_validation_level          => p_validation_level,
         p_business_document_type    => attach_rec.business_document_type,
         p_business_document_id      => attach_rec.business_document_id,
         p_business_document_version => attach_rec.business_document_version,
         p_attached_document_id      => attach_rec.attached_document_id,
         p_external_visibility_flag  => attach_rec.external_visibility_flag,
         p_effective_from_type       => attach_rec.effective_from_type,
         p_effective_from_id         => attach_rec.effective_from_id,
         p_effective_from_version    => l_effective_from_version,
         p_include_for_approval_flag => attach_rec.include_for_approval_flag,
         p_generated_flag            => attach_rec.generated_flag,
         p_primary_contract_doc_flag => attach_rec.primary_contract_doc_flag,
         p_mergeable_doc_flag        => attach_rec.mergeable_doc_flag,
         p_delete_flag               => attach_rec.delete_flag,
         p_program_id                => NULL,
         p_program_application_id    => NULL,
         p_request_id                => NULL,
         p_program_update_date       => NULL,
         p_parent_attached_doc_id    => l_parent_attached_doc_id,
         p_object_version_number     => attach_rec.object_version_number,
         p_versioning_flag           => 'Y',
         x_msg_data                  => l_msg_data,
         x_msg_count                 => l_msg_count,
         x_return_status             => l_return_status);
        -- Check for errors
        IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF (l_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
     ELSE
       -- Delete the current generated record.
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2734: Deleting generated Current attachment');
       END IF;

       -- get the value of FND's datatype_id. Needed for
       OPEN datatype_csr(attach_rec.attached_document_id);
       FETCH datatype_csr INTO l_datatype_id;
       IF(datatype_csr%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
       END IF;
       CLOSE datatype_csr;
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2736: Deleting FND Attachments');
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2735: l_datatype_id is: '
			        || l_datatype_id);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2735: attached_document_id is: '
			        || attach_rec.attached_document_id);
       END IF;
       -- Call FND delete attachment API to delete just the FND_ATTACHED_DOCUMENTS record
       FND_ATTACHED_DOCUMENTS3_PKG.DELETE_ROW(
          X_attached_document_id => attach_rec.attached_document_id,
          X_datatype_id          => l_datatype_id,
          delete_document_flag   => 'N');  -- Don't delete FND_DOCUMENTS records

	   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2737: Deleting OKC_CONTRACT_DOCS record');
       END IF;
       -- Delete record in OKC_CONTRACT_DOCS table
       OKC_CONTRACT_DOCS_PVT.Delete_Row(
          x_return_status             => l_return_status,
          p_business_document_type    => attach_rec.business_document_type,
          p_business_document_id      => attach_rec.business_document_id,
          p_business_document_version => attach_rec.business_document_version,
          p_attached_document_id      => attach_rec.attached_document_id,
          p_object_version_number     => attach_rec.object_version_number
          );
        -- Check for errors
        IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF (l_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;  -- NOT (p_include_gen_attach = 'N' AND attach_rec.generated_flag = 'Y')
  END LOOP;


  -- Loop to delete the older ref. attachments in current version
  FOR ref_del_rec IN ref_del_csr(p_business_document_type, p_business_document_id,
     p_business_document_version, G_CURRENT_VERSION)  LOOP
     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2740:doc version is: ' || ref_del_rec.business_document_version);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2741:attch doc id is: ' || ref_del_rec.attached_document_id);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2742:effective_from_type is: ' || ref_del_rec.effective_from_type);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2743:effective_from_id is: ' || ref_del_rec.effective_from_id);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2744:effective_from_version is: ' || ref_del_rec.effective_from_version);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2745: Deleting OKC_CONTRACT_DOCS ref. records');
     END IF;
	 -- get the value of FND's datatype_id. Needed for
     OPEN datatype_csr(ref_del_rec.attached_document_id);
     FETCH datatype_csr INTO l_datatype_id;
	 -- For Bug 7045227
	 -- IF(datatype_csr%NOTFOUND) THEN
     IF(datatype_csr%NOTFOUND AND ref_del_rec.delete_flag <> 'Y') THEN
        RAISE NO_DATA_FOUND;
     END IF;
     CLOSE datatype_csr;
     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2746: Deleting FND Attachments');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2747: l_datatype_id is: '
	        || l_datatype_id);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2748: attached_document_id is: '
            || ref_del_rec.attached_document_id);
     END IF;
     -- Call FND delete attachment API to delete just the FND_ATTACHED_DOCUMENTS record
     FND_ATTACHED_DOCUMENTS3_PKG.DELETE_ROW(
       X_attached_document_id => ref_del_rec.attached_document_id,
       X_datatype_id          => l_datatype_id,
       delete_document_flag   => 'N');  -- Don't delete FND_DOCUMENTS records
     -- Delete record in OKC_CONTRACT_DOCS table
     OKC_CONTRACT_DOCS_PVT.Delete_Row(
        x_return_status             => l_return_status,
        p_business_document_type    => ref_del_rec.business_document_type,
        p_business_document_id      => ref_del_rec.business_document_id,
        p_business_document_version => ref_del_rec.business_document_version,
        p_attached_document_id      => ref_del_rec.attached_document_id,
        p_object_version_number     => ref_del_rec.object_version_number
        );
     -- Check for errors
     IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;
  END LOOP;

  -- Standard check of p_commit
   IF FND_API.To_Boolean( p_commit ) THEN
     COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2800: Leaving Version_Attachments');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2900: Leaving Version_Attachments: OKC_API.G_EXCEPTION_ERROR Exception');
     END IF;
     IF (datatype_csr%ISOPEN) THEN
         CLOSE datatype_csr ;
     END IF;
     ROLLBACK TO Version_Attachments_GRP;
     x_return_status := G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3000: Leaving Version_Attachments: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
     END IF;
     IF (datatype_csr%ISOPEN) THEN
         CLOSE datatype_csr ;
     END IF;
     ROLLBACK TO Version_Attachments_GRP;
     x_return_status := G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

   WHEN OTHERS THEN
     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3100: Leaving Version_Attachments because of EXCEPTION: '||sqlerrm);
     END IF;
     IF (datatype_csr%ISOPEN) THEN
         CLOSE datatype_csr ;
     END IF;
     ROLLBACK TO Version_Attachments_GRP;
     x_return_status := G_RET_STS_UNEXP_ERROR ;
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
     END IF;
     FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );
END Version_Attachments;










    ---------------------------------------------------------------------------
        -- PROCEDURE Delete_Ver_Attachments
    ---------------------------------------------------------------------------
    PROCEDURE Delete_Ver_Attachments(
          p_api_version               IN NUMBER,
          p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE,
          p_validation_level        IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
          p_commit                    IN VARCHAR2 := FND_API.G_FALSE,

          x_return_status             OUT NOCOPY VARCHAR2,
          x_msg_count                 OUT NOCOPY NUMBER,
          x_msg_data                  OUT NOCOPY VARCHAR2,

          p_business_document_type    IN VARCHAR2,
          p_business_document_id      IN NUMBER,
          p_business_document_version IN NUMBER

          ) IS
       l_api_name              CONSTANT VARCHAR2(30) := 'Delete_Ver_Attachments';
       l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
       l_msg_count             NUMBER;
       l_msg_data              FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
       l_api_version           NUMBER := 1;

       -- Attachment cursor
       CURSOR attach_csr(l_bus_doc_type VARCHAR2, l_bus_doc_id NUMBER, l_bus_doc_version NUMBER) IS
                SELECT * FROM OKC_CONTRACT_DOCS
                WHERE business_document_type = l_bus_doc_type
                AND   business_document_id = l_bus_doc_id
                AND   business_document_version = l_bus_doc_version;


      BEGIN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	          '3200: Entered Delete_Ver_Attachments');
	       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	          '3201: p_business_document_type : ' || p_business_document_type );
	       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	          '3202: p_business_document_id : ' || p_business_document_id );
	       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
	          '3203: p_business_document_version : ' || p_business_document_version );
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT Delete_Ver_Attachments_GRP;

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

        FOR attach_rec IN attach_csr(p_business_document_type, p_business_document_id,
                            p_business_document_version)  LOOP
                  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3210:doc version is: ' || attach_rec.business_document_version);
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3220:attch doc id is: ' || attach_rec.attached_document_id);
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3230:effective_from_version is: ' || attach_rec.effective_from_version);
                  END IF;

                  -- Delete OKC_CONTRACT_DOCS record
                  Delete_Contract_Doc (
                   p_api_version               => l_api_version,
                   p_init_msg_list             => p_init_msg_list,

                   p_business_document_type    => p_business_document_type,
                   p_business_document_id      => p_business_document_id,
                   p_business_document_version => p_business_document_version,

                   p_attached_document_id      => attach_rec.attached_document_id,
                   p_object_version_number     => NULL,
                   x_msg_data                  => l_msg_data,
                   x_msg_count                 => l_msg_count,
                   x_return_status             => l_return_status);

                  -- Check for errors
                  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                       RAISE FND_API.G_EXC_ERROR;
                  END IF;
          END LOOP;

      -- Standard check of p_commit
       IF FND_API.To_Boolean( p_commit ) THEN
         COMMIT WORK;
       END IF;
       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3300: Leaving Delete_Ver_Attachments');
       END IF;

      EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3400: Leaving Delete_Ver_Attachments: OKC_API.G_EXCEPTION_ERROR Exception');
         END IF;
         ROLLBACK TO Delete_Ver_Attachments_GRP;
         x_return_status := G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3500: Leaving Delete_Ver_Attachments: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
         END IF;
         ROLLBACK TO Delete_Ver_Attachments_GRP;
         x_return_status := G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

       WHEN OTHERS THEN
         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3600: Leaving Delete_Ver_Attachments because of EXCEPTION: '||sqlerrm);
         END IF;

         ROLLBACK TO Delete_Ver_Attachments_GRP;
         x_return_status := G_RET_STS_UNEXP_ERROR ;
         IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
         END IF;
         FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    END Delete_Ver_Attachments;






    ---------------------------------------------------------------------------
      -- PROCEDURE Delete_Doc_Attachments
    ---------------------------------------------------------------------------
    PROCEDURE Delete_Doc_Attachments(
        p_api_version               IN NUMBER,
        p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE,
        p_validation_level        IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
        p_commit                    IN VARCHAR2 := FND_API.G_FALSE,

        x_return_status             OUT NOCOPY VARCHAR2,
        x_msg_count                 OUT NOCOPY NUMBER,
        x_msg_data                  OUT NOCOPY VARCHAR2,

        p_business_document_type    IN VARCHAR2,
        p_business_document_id      IN NUMBER

        ) IS
         l_api_name              CONSTANT VARCHAR2(30) := 'Delete_Doc_Attachments';
         l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
         l_msg_count             NUMBER;
         l_msg_data              FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
         l_api_version           NUMBER := 1;

         -- Attachment cursor
         CURSOR attach_csr(l_bus_doc_type VARCHAR2, l_bus_doc_id NUMBER) IS
                  SELECT distinct business_document_version FROM OKC_CONTRACT_DOCS
                WHERE business_document_type = l_bus_doc_type
                AND   business_document_id = l_bus_doc_id
                AND   business_document_version <> -99
                ORDER by  business_document_version DESC ;


    BEGIN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
			    '3900: Entered Delete_Doc_Attachments');
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
			    '3901: p_business_document_type: ' || p_business_document_type);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
			    '3902: p_business_document_id: ' || p_business_document_id);
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT Delete_Doc_Attachments_GRP;
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



        -- Call delete version attachments for -99
        Delete_Ver_Attachments (
             p_api_version               => l_api_version,
             p_init_msg_list             => p_init_msg_list,
             p_validation_level          => p_validation_level,
             p_commit                    => FND_API.G_FALSE,

             p_business_document_type    => p_business_document_type,
             p_business_document_id      => p_business_document_id,
             p_business_document_version => -99,

             x_msg_data                  => l_msg_data,
             x_msg_count                 => l_msg_count,
             x_return_status             => l_return_status);

         -- Check for errors
         IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF (l_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR;
         END IF;

         FOR attach_rec IN attach_csr(p_business_document_type, p_business_document_id)  LOOP

                   -- Call delete version attachments for other versions
                   Delete_Ver_Attachments (
                   p_api_version               => l_api_version,
                   p_init_msg_list             => p_init_msg_list,
                   p_validation_level          => p_validation_level,
                   p_commit                    => FND_API.G_FALSE,

                   p_business_document_type    => p_business_document_type,
                   p_business_document_id      => p_business_document_id,
                   p_business_document_version => attach_rec.business_document_version,

                   x_msg_data                  => l_msg_data,
                   x_msg_count                 => l_msg_count,
                   x_return_status             => l_return_status);

                    -- Check for errors
                    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                         RAISE FND_API.G_EXC_ERROR;
                    END IF;
         END LOOP;

         -- Standard check of p_commit
         IF FND_API.To_Boolean( p_commit ) THEN
           COMMIT WORK;
         END IF;
         -- Standard call to get message count and if count is 1, get message info.
         FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3900: Leaving Delete_Doc_Attachments');
         END IF;

        EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
           IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4000: Leaving Delete_Doc_Attachments: OKC_API.G_EXCEPTION_ERROR Exception');
           END IF;
           ROLLBACK TO Delete_Doc_Attachments_GRP;
           x_return_status := G_RET_STS_ERROR ;
           FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4100: Leaving Delete_Doc_Attachments: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
           END IF;
           ROLLBACK TO Delete_Doc_Attachments_GRP;
           x_return_status := G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

         WHEN OTHERS THEN
           IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4200: Leaving Delete_Doc_Attachments because of EXCEPTION: '||sqlerrm);
           END IF;

           ROLLBACK TO Delete_Doc_Attachments_GRP;
           x_return_status := G_RET_STS_UNEXP_ERROR ;
           IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
           END IF;
           FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );
    END Delete_Doc_Attachments;











        ---------------------------------------------------------------------------
        -- PROCEDURE Copy_Attachment_Docs - Deep copy for the attachments
        -- As part of the fix for bug 4115960, p_copy_primary_doc_flag='Y' will
        -- copy Contract category documents only.
          --              If p_copy_for_amendment = 'Y'
		  --                 copy all categories
		  --              else if  p_copy_primary_doc_flag = 'Y"
		  --                 Copy PCD (in ref copy)
		  --                 Copy contract category docs (in deep copy)
		  --              else if p_from_bus_doc_type = p_to_bus_doc_type
		  --                 Copy only Contract and Support documents
		  --              else
		  --                  copy all categories
      ---------------------------------------------------------------------------
      PROCEDURE Copy_Attachment_Docs(
          p_api_version               IN NUMBER,
          p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE,
          p_validation_level           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

          x_return_status             OUT NOCOPY VARCHAR2,
          x_msg_count                 OUT NOCOPY NUMBER,
          x_msg_data                  OUT NOCOPY VARCHAR2,

          p_from_bus_doc_type    IN VARCHAR2,
          p_from_bus_doc_id      IN NUMBER,
          p_from_bus_doc_version IN NUMBER := G_CURRENT_VERSION,
          p_to_bus_doc_type    IN VARCHAR2,
          p_to_bus_doc_id      IN NUMBER,
          p_to_bus_doc_version IN NUMBER := G_CURRENT_VERSION,
          p_copy_primary_doc_flag IN VARCHAR2 := 'N',
          p_copy_for_amendment IN VARCHAR2 := 'N'

          ) IS l_api_name              CONSTANT VARCHAR2(30) := 'Copy_Attachment_Docs';
           l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
           l_datatype_id           NUMBER;
           l_msg_count             NUMBER;
           l_msg_data              FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
           l_api_version           NUMBER := 1;
           l_business_document_type     OKC_CONTRACT_DOCS.BUSINESS_DOCUMENT_TYPE%TYPE;
           l_business_document_id       OKC_CONTRACT_DOCS.BUSINESS_DOCUMENT_ID%TYPE;
           l_business_document_version  OKC_CONTRACT_DOCS.BUSINESS_DOCUMENT_VERSION%TYPE;
           l_from_version               OKC_CONTRACT_DOCS.EFFECTIVE_FROM_VERSION%TYPE;
           l_attached_document_id       FND_ATTACHED_DOCUMENTS.ATTACHED_DOCUMENT_ID%TYPE;
           l_contract_category_id       FND_DOCUMENT_CATEGORIES.CATEGORY_ID%TYPE;
           l_supporting_category_id     FND_DOCUMENT_CATEGORIES.CATEGORY_ID%TYPE;
           l_copy_all_docs_yn      VARCHAR2(1);
--Fix for bug 6468721 : Added code to copy SYSTEM-GENERATED ATTACHMENTS to the target Business Document.
	   l_from_bus_doc_version_latest NUMBER;
           l_doc_version_view_name   VARCHAR2(45);
           l_version_query VARCHAR2(1000);


           CURSOR  doc_version_view_name_csr (l_from_bus_doc_type VARCHAR2) IS
             SELECT
               doc_version_view
               FROM okc_bus_doc_types_b
               WHERE document_type = l_from_bus_doc_type;


           CURSOR attach_csr(l_from_bus_doc_type VARCHAR2, l_from_bus_doc_id NUMBER,
                             l_from_bus_doc_version NUMBER, l_to_bus_doc_type VARCHAR2,
                             l_to_bus_doc_id NUMBER, l_to_bus_doc_version NUMBER,
                             l_entity_name VARCHAR2, l_program_id NUMBER) IS
              SELECT
                KDOC.attached_document_id  from_attached_document_id,
                KDOC.external_visibility_flag external_visibility_flag,
                KDOC.parent_attached_doc_id parent_attached_doc_id,
                KDOC.include_for_approval_flag include_for_approval_flag,
                KDOC.generated_flag generated_flag,
                KDOC.delete_flag delete_flag,
                FADB2.attached_document_id  to_attached_document_id,
                KDOC.primary_contract_doc_flag,
                KDOC.mergeable_doc_flag
                FROM FND_ATTACHED_DOCUMENTS FADB1, OKC_CONTRACT_DOCS KDOC,
                     FND_ATTACHED_DOCUMENTS FADB2,
                     FND_DOCUMENTS_vl doc1,
                     FND_DOCUMENTS_vl doc2
                WHERE
                KDOC.business_document_type = l_from_bus_doc_type
                AND KDOC.business_document_id = l_from_bus_doc_id
                AND KDOC.business_document_version = l_from_bus_doc_version
                AND KDOC.attached_document_id = FADB1.attached_document_id
                AND NVL(KDOC.delete_flag,'N') = 'N'
                AND FADB2.entity_name = l_entity_name
                AND FADB2.pk1_value = l_to_bus_doc_type
                AND FADB2.pk2_value = to_char(l_to_bus_doc_id)
                AND FADB2.pk3_value = to_char(l_to_bus_doc_version)
                AND FADB2.program_id = l_program_id
            --Bug 16240419     AND FADB1.seq_num = FADB2.seq_num;
                AND FADB1.document_id = doc1.document_id
                AND FADB2.document_id = doc2.document_id
                AND doc1.datatype_name = doc2.datatype_name
                AND Nvl(doc1.file_name,'@') = Nvl(doc2.file_name,'@')
                AND doc1.category_id = doc2.category_id
                AND Nvl(doc1.url,'@') = Nvl(doc2.url,'@');

           -- Will fetch only contract and supporting docs
           CURSOR category_csr1 IS
                                    SELECT category_id from FND_DOCUMENT_CATEGORIES
                                    WHERE name in (G_CONTRACT_DOC_CATEGORY, G_SUPPORTING_DOC_CATEGORY);

           -- Will fetch all seeded contract doc. categories
           CURSOR category_csr2 IS
                                    SELECT category_id from FND_DOCUMENT_CATEGORIES
                                    WHERE name in (G_CONTRACT_DOC_CATEGORY, G_SUPPORTING_DOC_CATEGORY, G_APP_ABSTRACT_CATEGORY, G_CONTRACT_IMAGE_CATEGORY);

           -- Will fetch only 'Contract' category. Used if p_copy_primary_doc_flag='Y'
           CURSOR category_csr3 IS
                                    SELECT category_id from FND_DOCUMENT_CATEGORIES
                                    WHERE name in (G_CONTRACT_DOC_CATEGORY);
           -- Will fetch all seeded and custom (starting with 'OKC_REPO%') categories
           CURSOR category_csr4 IS
                                    SELECT category_id from FND_DOCUMENT_CATEGORIES
                                    WHERE name like 'OKC_REPO_%';
              BEGIN
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '4800: Entered Copy_Attachment_Docs');
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '4801: p_from_bus_doc_type: ' || p_from_bus_doc_type);
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '4802: p_from_bus_doc_id: ' || p_from_bus_doc_id);
					  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '4803: p_from_bus_doc_version: ' || p_from_bus_doc_version);
					  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '4804: p_to_bus_doc_type: ' || p_to_bus_doc_type);
					  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '4805: p_to_bus_doc_id: ' || p_to_bus_doc_id);
					  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '4806: p_to_bus_doc_version: ' || p_to_bus_doc_version);
					  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '4807: p_copy_primary_doc_flag: ' || p_copy_primary_doc_flag);
					  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '4808: p_copy_for_amendment: ' || p_copy_for_amendment);
                END IF;

                -- Standard call to check for call compatibility.
                IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                --  Initialize API return status to success
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                l_from_bus_doc_version_latest := p_from_bus_doc_version;	--For bug 6468721

                IF (p_copy_for_amendment = 'Y') THEN    -- Copy called for amendment. Need to copy all categories


                	FOR category_rec2 IN category_csr2
                    LOOP
                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4820: Category Id : ' || category_rec2.category_id);
                        END IF;
                        -- Copy FND Attachments. Program Id is set to -9999.
                        FND_ATTACHED_DOCUMENTS2_PKG.Copy_Attachments(
                            X_from_entity_name     => G_ATTACH_ENTITY_NAME,
                            X_from_pk1_value       => p_from_bus_doc_type,
                            X_from_pk2_value       => p_from_bus_doc_id,
 	                    X_from_pk3_value       => p_from_bus_doc_version,
                            X_to_entity_name     => G_ATTACH_ENTITY_NAME,
                            X_to_pk1_value       => p_to_bus_doc_type,
                            X_to_pk2_value       => p_to_bus_doc_id,
                            X_to_pk3_value       => p_to_bus_doc_version,
                            X_program_id         => G_COPY_PROGRAM_ID,
                            X_from_category_id   => category_rec2.category_id,
                            X_to_category_id   => category_rec2.category_id);
                    END LOOP; -- category_rec2 IN category_csr2
                ELSIF (p_copy_primary_doc_flag = 'Y') THEN    -- Copy Contract caregory only
                	FOR category_rec3 IN category_csr3
                    LOOP
                       	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                           	FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4820: Category Id : ' || category_rec3.category_id);
                       	END IF;
                       	-- Copy FND Attachments. Program Id is set to -9999.
                       	FND_ATTACHED_DOCUMENTS2_PKG.Copy_Attachments(
                            X_from_entity_name     => G_ATTACH_ENTITY_NAME,
                            X_from_pk1_value       => p_from_bus_doc_type,
                            X_from_pk2_value       => p_from_bus_doc_id,
                            X_from_pk3_value       => p_from_bus_doc_version,
                            X_to_entity_name     => G_ATTACH_ENTITY_NAME,
                            X_to_pk1_value       => p_to_bus_doc_type,
                            X_to_pk2_value       => p_to_bus_doc_id,
                            X_to_pk3_value       => p_to_bus_doc_version,
                            X_program_id         => G_COPY_PROGRAM_ID,
                            X_from_category_id   => category_rec3.category_id,
                            X_to_category_id   => category_rec3.category_id);
                    END LOOP; -- category_rec3 IN category_csr3
                ELSIF (p_from_bus_doc_type = p_to_bus_doc_type) THEN
                  FND_PROFILE.GET(NAME => G_COPY_ALL_DOCS, VAL => l_copy_all_docs_yn);
                  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                       'Profile OKC_REP_COPY_ALL_CON_DOCS value is: '||l_copy_all_docs_yn);
                  END IF;
                  IF (l_copy_all_docs_yn = 'Y') THEN -- Need to copy all seeded and custom categories.

		-- Fix for bug 6468721
		-- Get the doc_version_view name from okc_bus_doc_types_b
                -- to decide if l_version_query needs to be run
                    IF NOT doc_version_view_name_csr%ISOPEN THEN
                    OPEN doc_version_view_name_csr(p_from_bus_doc_type);
                      FETCH doc_version_view_name_csr into l_doc_version_view_name;
                    CLOSE doc_version_view_name_csr;
                    END IF;

		-- Get the value of l_from_bus_doc_version_latest only if the view name
		-- got from the previous step is not NULL.


                   IF (l_doc_version_view_name IS NOT NULL) THEN

                   l_version_query := ' SELECT decode(a.archived_yn,''Y'',a.document_version,-99) latest_doc_version
               FROM '||l_doc_version_view_name||' a
               WHERE decode(a.document_version ,
                             (SELECT max(b.document_version)
                              FROM '||l_doc_version_view_name||' b
                              WHERE b.document_type = a.document_type
                              AND b.document_id = a.document_id) ,''Y'' ,''N'' ) = ''Y''
                     AND  a.document_type = '''||p_from_bus_doc_type||'''
                     AND  a.document_id = '''||p_from_bus_doc_id||'''';


           EXECUTE IMMEDIATE l_version_query INTO l_from_bus_doc_version_latest;

                   END IF;

                    FOR category_rec4 IN category_csr4
                    LOOP
                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4820: Category Id : ' || category_rec4.category_id);
                        END IF;
                        -- Copy FND Attachments. Program Id is set to -9999.
                        FND_ATTACHED_DOCUMENTS2_PKG.Copy_Attachments(
                            X_from_entity_name     => G_ATTACH_ENTITY_NAME,
                            X_from_pk1_value       => p_from_bus_doc_type,
                            X_from_pk2_value       => p_from_bus_doc_id,
                            X_from_pk3_value       => l_from_bus_doc_version_latest,
                            X_to_entity_name     => G_ATTACH_ENTITY_NAME,
                            X_to_pk1_value       => p_to_bus_doc_type,
                            X_to_pk2_value       => p_to_bus_doc_id,
                            X_to_pk3_value       => p_to_bus_doc_version,
                            X_program_id         => G_COPY_PROGRAM_ID,
                            X_from_category_id   => category_rec4.category_id,
                            X_to_category_id   => category_rec4.category_id);
                    END LOOP; -- category_rec4 IN category_csr4
                  ELSE
                    FOR category_rec1 IN category_csr1 -- Copy only contract and supporting documents
                    LOOP
                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4820: Category Id : ' || category_rec1.category_id);
                        END IF;
                        -- Copy FND Attachments. Program Id is set to -9999.
                        FND_ATTACHED_DOCUMENTS2_PKG.Copy_Attachments(
                            X_from_entity_name     => G_ATTACH_ENTITY_NAME,
                            X_from_pk1_value       => p_from_bus_doc_type,
                            X_from_pk2_value       => p_from_bus_doc_id,
                            X_from_pk3_value       => p_from_bus_doc_version,
                            X_to_entity_name     => G_ATTACH_ENTITY_NAME,
                            X_to_pk1_value       => p_to_bus_doc_type,
                            X_to_pk2_value       => p_to_bus_doc_id,
                            X_to_pk3_value       => p_to_bus_doc_version,
                            X_program_id         => G_COPY_PROGRAM_ID,
                            X_from_category_id   => category_rec1.category_id,
                            X_to_category_id   => category_rec1.category_id);
                    END LOOP; -- category_rec1 IN category_csr1
                  END IF; -- l_copy_all_docs_yn = 'Y
               	ELSE                                          -- Copy all categories
            	    FOR category_rec2 IN category_csr2
                    LOOP
                       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4820: Category Id : ' || category_rec2.category_id);
                       END IF;
                       -- Copy FND Attachments. Program Id is set to -9999.
                       FND_ATTACHED_DOCUMENTS2_PKG.Copy_Attachments(
                           X_from_entity_name     => G_ATTACH_ENTITY_NAME,
                           X_from_pk1_value       => p_from_bus_doc_type,
                           X_from_pk2_value       => p_from_bus_doc_id,
                           X_from_pk3_value       => p_from_bus_doc_version,
                           X_to_entity_name     => G_ATTACH_ENTITY_NAME,
                           X_to_pk1_value       => p_to_bus_doc_type,
                           X_to_pk2_value       => p_to_bus_doc_id,
                           X_to_pk3_value       => p_to_bus_doc_version,
                           X_program_id         => G_COPY_PROGRAM_ID,
                           X_from_category_id   => category_rec2.category_id,
                           X_to_category_id   => category_rec2.category_id);
                    END LOOP; -- category_rec2 IN category_csr2
                END IF; -- (p_copy_for_amendment = 'Y')

                -- Loop through the newly create record to get attached_doc_id in a table structure.
                FOR attach_rec IN attach_csr(p_from_bus_doc_type, p_from_bus_doc_id,
                                    l_from_bus_doc_version_latest, p_to_bus_doc_type, p_to_bus_doc_id,
                                    p_to_bus_doc_version, G_ATTACH_ENTITY_NAME, G_COPY_PROGRAM_ID)
                LOOP

                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4830:doc type is: ' || p_to_bus_doc_type);
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4831:doc id is: ' || p_to_bus_doc_id);
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4832:doc version is: ' || p_to_bus_doc_version);
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4833:The attached_doc_id being copied is: '
                                      || attach_rec.from_attached_document_id);
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4834:The new attached_doc_id is: '
                                      || attach_rec.to_attached_document_id);
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4835:The delete_flag is: '
                                      || attach_rec.delete_flag);
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4836:The generated_flag is: '
                                      || attach_rec.generated_flag);
                        END IF;
                        Insert_Contract_Doc (
                                p_api_version               => l_api_version,
                                p_init_msg_list             => p_init_msg_list,
                                p_validation_level          => p_validation_level,
                                p_business_document_type    => p_to_bus_doc_type,
                                p_business_document_id      => p_to_bus_doc_id,
                                p_business_document_version => p_to_bus_doc_version,
                                p_attached_document_id      => attach_rec.to_attached_document_id,
                                p_external_visibility_flag  => attach_rec.external_visibility_flag,
                                p_effective_from_type       => p_to_bus_doc_type,
                                p_effective_from_id         => p_to_bus_doc_id,
                                p_effective_from_version    => p_to_bus_doc_version,
                                p_include_for_approval_flag => attach_rec.include_for_approval_flag,
                                p_generated_flag            => attach_rec.generated_flag,
                                p_primary_contract_doc_flag => attach_rec.primary_contract_doc_flag,
                                p_mergeable_doc_flag        => attach_rec.mergeable_doc_flag,
                                p_delete_flag               => attach_rec.delete_flag,
                                p_create_fnd_attach         => 'N',
                                p_program_id                => NULL,
                                p_program_application_id    => NULL,
                                p_request_id                => NULL,
                                p_program_update_date       => NULL,
                                p_versioning_flag           => 'Y', -- Do Not Update Primary Flag when Copying or Versioning
                                x_msg_data                  => l_msg_data,
                                x_msg_count                 => l_msg_count,
                                x_return_status             => l_return_status,
                                x_business_document_type    => l_business_document_type,
                                x_business_document_id      => l_business_document_id,
                                x_business_document_version => l_business_document_version,
                                x_attached_document_id      => l_attached_document_id);

                       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                           RAISE FND_API.G_EXC_ERROR;
                       END IF;
                END LOOP;

                -- Standard call to get message count and if count is 1, get message info.
                FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4900: Leaving Copy_Attachment_Docs');
                END IF;

                EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4840: Leaving Copy_Attachment_Docs: OKC_API.G_EXCEPTION_ERROR Exception');
                        END IF;

			--Bug 6468721
			IF (doc_version_view_name_csr%ISOPEN) THEN
                            CLOSE doc_version_view_name_csr;
                        END IF;

                        x_return_status := G_RET_STS_ERROR ;
                        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

                WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4841: Leaving Copy_Attachment_Docs: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
                        END IF;

			--Bug 6468721
			IF (doc_version_view_name_csr%ISOPEN) THEN
                            CLOSE doc_version_view_name_csr;
                        END IF;

                        x_return_status := G_RET_STS_UNEXP_ERROR ;
                        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

                WHEN OTHERS THEN
                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'482: Leaving Copy_Attachment_Docs because of EXCEPTION: '||sqlerrm);
                        END IF;

			--Bug 6468721
			IF (doc_version_view_name_csr%ISOPEN) THEN
                            CLOSE doc_version_view_name_csr;
                        END IF;

                        x_return_status := G_RET_STS_UNEXP_ERROR ;
                        IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                                   END IF;
                        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );


  END Copy_Attachment_Docs;




      ---------------------------------------------------------------------------
        -- PROCEDURE Copy_Attachment_Refs - Reference copy for the attachments
        -- THIS API will be called by sourcing.
          --              If p_copy_for_amendment = 'Y'
		  --                 copy all categories
		  --              else if  p_copy_primary_doc_flag = 'Y"
		  --                 Copy PCD (in ref copy)
		  --                 Copy contract category docs (in deep copy)
		  --              else if p_from_bus_doc_type = p_to_bus_doc_type
		  --                 Copy only Contract and Support documents
		  --              else
		  --                  copy all categories
      ---------------------------------------------------------------------------
      PROCEDURE Copy_Attachment_Refs(
          p_api_version               IN NUMBER,
          p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE,
          p_validation_level           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
          p_commit                    IN VARCHAR2 := FND_API.G_FALSE,

          x_return_status             OUT NOCOPY VARCHAR2,
          x_msg_count                 OUT NOCOPY NUMBER,
          x_msg_data                  OUT NOCOPY VARCHAR2,

          p_from_bus_doc_type    IN VARCHAR2,
          p_from_bus_doc_id      IN NUMBER,
          p_from_bus_doc_version IN NUMBER := G_CURRENT_VERSION,
          p_to_bus_doc_type    IN VARCHAR2,
          p_to_bus_doc_id      IN NUMBER,
          p_to_bus_doc_version IN NUMBER := G_CURRENT_VERSION,
          p_copy_primary_doc_flag IN VARCHAR2 := 'N',
          p_copy_for_amendment IN VARCHAR2 := 'N'

          ) IS l_api_name              CONSTANT VARCHAR2(30) := 'Copy_Attachment_Refs';

           l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
           l_datatype_id           NUMBER;
           l_msg_count             NUMBER;
           l_msg_data              FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
           l_api_version           NUMBER := 1;
           l_business_document_type     OKC_CONTRACT_DOCS.BUSINESS_DOCUMENT_TYPE%TYPE;
           l_business_document_id       OKC_CONTRACT_DOCS.BUSINESS_DOCUMENT_ID%TYPE;
           l_business_document_version  OKC_CONTRACT_DOCS.BUSINESS_DOCUMENT_VERSION%TYPE;
           l_from_version               OKC_CONTRACT_DOCS.EFFECTIVE_FROM_VERSION%TYPE;
           l_attached_document_id       FND_ATTACHED_DOCUMENTS.ATTACHED_DOCUMENT_ID%TYPE;
           l_category_name              FND_DOCUMENT_CATEGORIES.NAME%TYPE;
           l_parent_attached_doc_id    FND_ATTACHED_DOCUMENTS.ATTACHED_DOCUMENT_ID%TYPE;


           -- Attachment cursor to get the attachments for a given doc type, id and version
           CURSOR attach_csr(l_bus_doc_type VARCHAR2, l_bus_doc_id NUMBER, l_bus_doc_version NUMBER) IS
                    SELECT * FROM OKC_CONTRACT_DOCS
                WHERE business_document_type = l_bus_doc_type
                AND   business_document_id = l_bus_doc_id
                AND   business_document_version = l_bus_doc_version
                AND   delete_flag = 'N';

           -- Get the category code for a given fnd attachment.
           CURSOR category_csr (l_attached_document_id NUMBER) IS
                    SELECT fdc.name
                    FROM fnd_attached_documents fad, fnd_documents fd, fnd_document_categories fdc
                    WHERE fad.attached_document_id = l_attached_document_id
					AND   fad.document_id = fd.document_id
                    AND   fd.category_id = fdc.category_id;

          BEGIN
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '5000: Entered Copy_Attachment_Refs');
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '5001: p_from_bus_doc_type: ' || p_from_bus_doc_type);
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '5002: p_from_bus_doc_id: ' || p_from_bus_doc_id);
					  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '5003: p_from_bus_doc_version: ' || p_from_bus_doc_version);
					  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '5004: p_to_bus_doc_type: ' || p_to_bus_doc_type);
					  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '5005: p_to_bus_doc_id: ' || p_to_bus_doc_id);
					  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '5006: p_to_bus_doc_version: ' || p_to_bus_doc_version);
					  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '5007: p_copy_primary_doc_flag: ' || p_copy_primary_doc_flag);
					  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '5008: p_copy_for_amendment: ' || p_copy_for_amendment);
            END IF;

            -- Standard call to check for call compatibility.
            IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            --  Initialize API return status to success
            x_return_status := FND_API.G_RET_STS_SUCCESS;


            -- Loop through the existing attachments to create new attachments
            FOR attach_rec IN attach_csr(p_from_bus_doc_type, p_from_bus_doc_id,
                                    p_from_bus_doc_version)
                LOOP
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5030:doc type is: ' || p_to_bus_doc_type);
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5040:doc id is: ' || p_to_bus_doc_id);
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5050:doc version is: ' || p_to_bus_doc_version);
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5060:attached_document_id is: ' || attach_rec.attached_document_id);
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5070:effective_from_version is: ' || attach_rec.effective_from_version);
                    END IF;
                    -- Get the category name of the attachment being copied.
                    OPEN category_csr(attach_rec.attached_document_id);
                    FETCH category_csr INTO l_category_name;
                    IF(category_csr%NOTFOUND) THEN
                        RAISE NO_DATA_FOUND;
                    END IF;

                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5071: Category name is: ' || l_category_name);
                    END IF;

                    -- Insert the record in OKC_CONTRACT_DOCS
                    -- If p_copy_for_amendment = 'Y' copy everything
                    -- p_copy_primary_doc_flag = 'Y' - copy only primary contract
                    -- Do not copy attachments if source doc. type is same as destination doc. type and
					-- category is Approval abstract or Contract Image
                    IF ((p_copy_for_amendment = 'Y')  -- Copy everything
					     OR
					    ((p_copy_primary_doc_flag = 'N' OR attach_rec.primary_contract_doc_flag = 'Y'  ) AND  -- IF p_copy_primary_doc_flag, copy PCD
					     (NOT ((p_from_bus_doc_type = p_to_bus_doc_type)      -- IF doc types are same, copy only contract and supporting docs.
						      AND (l_category_name = G_APP_ABSTRACT_CATEGORY OR  l_category_name = G_CONTRACT_IMAGE_CATEGORY)))
						)
					   ) THEN
					  IF (attach_rec.parent_attached_doc_id IS NOT NULL) THEN
					  	l_parent_attached_doc_id := attach_rec.parent_attached_doc_id;
					  ELSE
					  	l_parent_attached_doc_id := attach_rec.attached_document_id;
					  END IF; -- attach_rec.parent_attached_doc_id <> NULL
                      Insert_Contract_Doc (
                         p_api_version               => l_api_version,
                         p_init_msg_list             => p_init_msg_list,
                         p_validation_level          => p_validation_level,
                         p_business_document_type    => p_to_bus_doc_type,
                         p_business_document_id      => p_to_bus_doc_id,
                         p_business_document_version => p_to_bus_doc_version,
                         p_attached_document_id      => attach_rec.attached_document_id,
                         p_external_visibility_flag  => attach_rec.external_visibility_flag,
                         p_effective_from_type       => attach_rec.effective_from_type,
                         p_effective_from_id         => attach_rec.effective_from_id,
                         p_effective_from_version    => attach_rec.effective_from_version,
                         p_include_for_approval_flag => attach_rec.include_for_approval_flag,
                         p_generated_flag            => attach_rec.generated_flag,
                         p_primary_contract_doc_flag => attach_rec.primary_contract_doc_flag,
                         p_mergeable_doc_flag        => attach_rec.mergeable_doc_flag,
                         p_delete_flag               => attach_rec.delete_flag,
                         p_create_fnd_attach         => 'Y',
                         p_program_id                => NULL,
                         p_program_application_id    => NULL,
                         p_request_id                => NULL,
                         p_program_update_date       => NULL,
                         p_parent_attached_doc_id    => l_parent_attached_doc_id,
                         x_msg_data                  => l_msg_data,
                         x_msg_count                 => l_msg_count,
                         x_return_status             => l_return_status,
                         x_business_document_type    => l_business_document_type,
                         x_business_document_id      => l_business_document_id,
                         x_business_document_version => l_business_document_version,
                         x_attached_document_id      => l_attached_document_id);
                END IF;   -- ((p_copy_for_amendment = 'Y') ......
                CLOSE category_csr;
                -- Check for errors
                IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
          END LOOP;


           -- Standard call to get message count and if count is 1, get message info.
           FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );
           IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5100: Leaving Copy_Attachment_Refs');
           END IF;

           EXCEPTION
           WHEN FND_API.G_EXC_ERROR THEN
                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5081: Leaving Copy_Attachment_Refs: OKC_API.G_EXCEPTION_ERROR Exception');
                   END IF;
                   IF (category_csr%ISOPEN) THEN
                        CLOSE category_csr ;
                   END IF;
                   x_return_status := G_RET_STS_ERROR ;
                   FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5082: Leaving Copy_Attachment_Refs: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
                   END IF;
                   IF (category_csr%ISOPEN) THEN
                        CLOSE category_csr ;
                   END IF;
                   x_return_status := G_RET_STS_UNEXP_ERROR ;
                   FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

           WHEN OTHERS THEN
                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5083: Leaving Copy_Attachment_Refs because of EXCEPTION: '||sqlerrm);
                   END IF;
                   IF (category_csr%ISOPEN) THEN
                        CLOSE category_csr ;
                   END IF;
                   x_return_status := G_RET_STS_UNEXP_ERROR ;
                   IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
                   END IF;
                   FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END Copy_Attachment_Refs;









        ---------------------------------------------------------------------------
          -- PROCEDURE Copy_Attachments - Copy attachments API
          --              If p_copy_for_amendment = 'Y'
		  --                 copy all categories
		  --              else if  p_copy_primary_doc_flag = 'Y"
		  --                 Copy PCD (in ref copy)
		  --                 Copy contract category docs (in deep copy)
		  --              else if p_from_bus_doc_type = p_to_bus_doc_type
		  --                 Copy only Contract and Support documents
		  --              else
		  --                  copy all categories
        ---------------------------------------------------------------------------
        PROCEDURE Copy_Attachments(
            p_api_version               IN NUMBER,
            p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level          IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
            p_commit                    IN VARCHAR2 := FND_API.G_FALSE,

            x_return_status             OUT NOCOPY VARCHAR2,
            x_msg_count                 OUT NOCOPY NUMBER,
            x_msg_data                  OUT NOCOPY VARCHAR2,

            p_from_bus_doc_type         IN VARCHAR2,
            p_from_bus_doc_id           IN NUMBER,
            p_from_bus_doc_version      IN NUMBER := G_CURRENT_VERSION,
            p_to_bus_doc_type           IN VARCHAR2,
            p_to_bus_doc_id             IN NUMBER,
            p_to_bus_doc_version        IN NUMBER := G_CURRENT_VERSION,
            p_copy_by_ref               IN VARCHAR2,
            p_copy_primary_doc_flag     IN VARCHAR2,
            p_copy_for_amendment        IN VARCHAR2

            ) IS
            l_api_name              CONSTANT VARCHAR2(30) := 'Copy_Attachments';
            l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
            l_datatype_id           FND_DOCUMENTS.DATATYPE_ID%TYPE;
            l_msg_count             NUMBER;
            l_msg_data              FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
            l_api_version           NUMBER:= 1;


            BEGIN
                  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '5100: Entered Copy_Attachments');
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '5101: p_from_bus_doc_type: ' || p_from_bus_doc_type);
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '5102: p_from_bus_doc_id: ' || p_from_bus_doc_id);
					  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '5103: p_from_bus_doc_version: ' || p_from_bus_doc_version);
					  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '5104: p_to_bus_doc_type: ' || p_to_bus_doc_type);
					  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '5105: p_to_bus_doc_id: ' || p_to_bus_doc_id);
					  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '5106: p_to_bus_doc_version: ' || p_to_bus_doc_version);
					  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '5107: p_copy_by_ref: ' || p_copy_by_ref);
					  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '5108: p_copy_primary_doc_flag: ' || p_copy_primary_doc_flag);
					  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
					       '5109: p_copy_for_amendment: ' || p_copy_for_amendment);
                  END IF;

                  -- Standard Start of API savepoint
                  SAVEPOINT Copy_Attachments_GRP;
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

            IF (p_copy_by_ref = 'Y') THEN
                Copy_Attachment_Refs(
                   p_api_version               => l_api_version,
                   p_init_msg_list             => p_init_msg_list,
                   p_validation_level          => p_validation_level,
                   x_msg_data                  => l_msg_data,
                   x_msg_count                 => l_msg_count,
                   x_return_status             => l_return_status,
                   p_from_bus_doc_type         => p_from_bus_doc_type,
                   p_from_bus_doc_id           => p_from_bus_doc_id,
                   p_from_bus_doc_version      => p_from_bus_doc_version,
                   p_to_bus_doc_type           => p_to_bus_doc_type,
                   p_to_bus_doc_id             => p_to_bus_doc_id,
                   p_to_bus_doc_version        => p_to_bus_doc_version,
                   p_copy_primary_doc_flag     => p_copy_primary_doc_flag,
                   p_copy_for_amendment        => p_copy_for_amendment
                     );
            END IF;
            IF (p_copy_by_ref = 'N') THEN


               Copy_Attachment_Docs(
                           p_api_version               => l_api_version,
                           p_init_msg_list             => p_init_msg_list,
                           p_validation_level          => p_validation_level,
                           x_msg_data                  => l_msg_data,
                           x_msg_count                 => l_msg_count,
                           x_return_status             => l_return_status,
                           p_from_bus_doc_type         => p_from_bus_doc_type,
                           p_from_bus_doc_id           => p_from_bus_doc_id,
                           p_from_bus_doc_version      => p_from_bus_doc_version,
                           p_to_bus_doc_type           => p_to_bus_doc_type,
                           p_to_bus_doc_id             => p_to_bus_doc_id,
                           p_to_bus_doc_version        => p_to_bus_doc_version,
                           p_copy_primary_doc_flag     => p_copy_primary_doc_flag,
                           p_copy_for_amendment        => p_copy_for_amendment
                     );
            END IF;


            -- Check for errors
            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            -- Standard check of p_commit
             IF FND_API.To_Boolean( p_commit ) THEN
               COMMIT WORK;
             END IF;
             -- Standard call to get message count and if count is 1, get message info.
             FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );
             IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4400: Leaving Copy_Attachments');
             END IF;

            EXCEPTION
             WHEN FND_API.G_EXC_ERROR THEN
               IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4500: Leaving Copy_Attachments: OKC_API.G_EXCEPTION_ERROR Exception');
               END IF;
               ROLLBACK TO Copy_Attachments_GRP;
               x_return_status := G_RET_STS_ERROR ;
               FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

             WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
               IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4600: Leaving Copy_Attachments: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
               END IF;
               ROLLBACK TO Copy_Attachments_GRP;
               x_return_status := G_RET_STS_UNEXP_ERROR ;
               FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

             WHEN OTHERS THEN
               IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4700: Leaving Copy_Attachments because of EXCEPTION: '||sqlerrm);
               END IF;
               ROLLBACK TO Copy_Attachments_GRP;
               x_return_status := G_RET_STS_UNEXP_ERROR ;
               IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
               END IF;
               FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );
      END Copy_Attachments;


PROCEDURE qa_doc(
p_api_version      IN NUMBER,
x_return_status    OUT NOCOPY VARCHAR2,
x_msg_count        OUT NOCOPY NUMBER,
x_msg_data         OUT NOCOPY VARCHAR2,

p_doc_type         IN VARCHAR2,
p_doc_id           IN NUMBER,

x_qa_result_tbl    OUT NOCOPY OKC_TERMS_QA_GRP.qa_result_tbl_type,
x_qa_return_status OUT NOCOPY VARCHAR2

) IS

l_api_name              CONSTANT VARCHAR2(30) := 'qa_doc';
l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count             NUMBER;
l_msg_data              FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
l_api_version           NUMBER:= 1;
l_qa_name               FND_LOOKUPS.MEANING%TYPE;
l_severity_flag         VARCHAR2(1) := 'W';
l_perform_qa            VARCHAR2(1) := 'N';
l_indx              NUMBER;

CURSOR l_get_qa_detail_csr IS

    SELECT LOOKUPS.meaning qa_name,
        nvl(qa.severity_flag,G_QA_STS_WARNING) severity_flag ,
        decode(LOOKUPS.enabled_flag,'N','N','Y',decode(qa.enable_qa_yn,'N','N','Y'),'Y') perform_qa
    FROM OKC_LOOKUPS_V LOOKUPS, OKC_DOC_QA_LISTS QA
    WHERE QA.DOCUMENT_TYPE(+)=p_doc_type
        AND   QA.QA_CODE(+) = LOOKUPS.LOOKUP_CODE
        AND   LOOKUPS.LOOKUP_TYPE = 'OKC_TERM_QA_LIST'
        AND   LOOKUPS.LOOKUP_CODE='CHECK_PRIMARY_CONTRACT';

BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4300: Entered qa_doc');
    END IF;

    x_return_status    := G_RET_STS_SUCCESS;
    x_qa_return_status := G_QA_STS_SUCCESS;
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    OPEN l_get_qa_detail_csr;
    FETCH l_get_qa_detail_csr INTO l_qa_name,l_severity_flag,l_perform_qa;
    CLOSE l_get_qa_detail_csr;

    IF l_perform_qa = 'Y' THEN
         IF (OKC_TERMS_UTIL_GRP.get_contract_source_code(p_doc_type,p_doc_id) = 'ATTACHED' AND
             Has_Primary_Contract_Doc(p_doc_type,p_doc_id) = 'N' ) THEN

             l_indx := x_qa_result_tbl.COUNT + 1;

             x_qa_result_tbl(l_indx).document_type        := p_doc_type;
             x_qa_result_tbl(l_indx).document_id          := p_doc_id;
             x_qa_result_tbl(l_indx).error_record_type    := 'DOCUMENT';
             x_qa_result_tbl(l_indx).article_id           := Null;
             x_qa_result_tbl(l_indx).deliverable_id       := Null;
             x_qa_result_tbl(l_indx).title                := OKC_UTIL.DECODE_LOOKUP('OKC_CONTRACT_TERMS_SOURCES','ATTACHED');
             x_qa_result_tbl(l_indx).section_name         := Null;
             x_qa_result_tbl(l_indx).qa_code              := 'CHECK_PRIMARY_CONTRACT';
             x_qa_result_tbl(l_indx).message_name         := 'OKC_REPO_DOC_QA_NO_PRIMARY';
             x_qa_result_tbl(l_indx).suggestion           := OKC_TERMS_UTIL_PVT.Get_Message('OKC','OKC_REPO_DOC_QA_NO_PRIMARY_S');
             x_qa_result_tbl(l_indx).error_severity       := l_severity_flag;
             x_qa_result_tbl(l_indx).problem_short_desc   := l_qa_name;
             x_qa_result_tbl(l_indx).problem_details_short:= OKC_TERMS_UTIL_PVT.Get_Message('OKC', 'OKC_REPO_DOC_QA_NO_PRIMARY');
             x_qa_result_tbl(l_indx).problem_details      := OKC_TERMS_UTIL_PVT.Get_Message('OKC', 'OKC_REPO_DOC_QA_NO_PRIMARY');
             x_qa_result_tbl(l_indx).creation_date        := SYSDATE;
             x_qa_return_status := l_severity_flag;
        END IF;


     END IF;

     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2300: Leaving QA_Doc');
     END IF;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2400: Leaving QA_Doc : OKC_API.G_EXCEPTION_ERROR Exception');
        END IF;
        IF (l_get_qa_detail_csr%ISOPEN) THEN
           CLOSE l_get_qa_detail_csr ;
        END IF;
        ROLLBACK TO g_QA_Doc;
        x_return_status := G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO g_QA_Doc;
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2500: Leaving QA_Doc : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
        END IF;
        IF (l_get_qa_detail_csr%ISOPEN) THEN
           CLOSE l_get_qa_detail_csr ;
        END IF;
        ROLLBACK TO g_QA_Doc;
        x_return_status := G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2600: Leaving QA_Doc because of EXCEPTION: '||sqlerrm);
        END IF;
        IF (l_get_qa_detail_csr%ISOPEN) THEN
           CLOSE l_get_qa_detail_csr ;
        END IF;
        ROLLBACK TO g_QA_Doc;
        x_return_status := G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
        END IF;
END QA_Doc;

-- Returns 'Y' - Attached document is oracle generated and mergeable.
--         'N' - Non recognised format, non mergeable.
--         'E' - Error.
FUNCTION Is_Primary_Terms_Doc_Mergeable(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER
) RETURN VARCHAR2 IS
 l_api_name                     CONSTANT VARCHAR2(30) := 'Is_Primary_Terms_Doc_mergeable';
 CURSOR contract_doc_csr IS
     SELECT 'Y'
     FROM okc_contract_docs
     WHERE business_document_type = p_document_type
       AND business_document_id = p_document_id
       AND mergeable_doc_flag='Y'
       AND primary_contract_doc_flag='Y'
       AND NVL(delete_flag,'N') = 'N'
       AND business_document_version = -99;

 l_value VARCHAR2(1);

BEGIN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: Entering Is_Primary_Terms_Doc_Mergeable');
   END IF;
   IF ( OKC_TERMS_UTIL_GRP.get_contract_source_code( p_document_type, p_document_id ) <> 'ATTACHED'
        OR OKC_TERMS_UTIL_GRP.get_authoring_party_code( p_document_type, p_document_id ) <> 'INTERNAL_ORG' )
   THEN
     RETURN 'N';
   END IF;
   OPEN contract_doc_csr;
   FETCH contract_doc_csr into l_value;
   CLOSE contract_doc_csr;

   IF l_value = 'Y' THEN
      RETURN 'Y';
   ELSE
      RETURN 'N';
   END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2000: Leaving Is_Primary_Terms_Doc_Mergeable because of EXCEPTION: '||sqlerrm);
   END IF;
   IF (contract_doc_csr%ISOPEN) THEN
         CLOSE contract_doc_csr ;
   END IF;
 RETURN 'E';
END Is_Primary_Terms_Doc_Mergeable;

-- Returns FND_DOCUMENTS_TL.media_id of the Primary contract file for the current version of the document if it is non mergeable.
-- 0 if document is mergeable.
-- -1 if no primary document exists.
FUNCTION Get_Primary_Terms_Doc_File_Id(
  p_document_type    IN VARCHAR2,
  p_document_id      IN  NUMBER
 ) RETURN NUMBER IS
 l_api_name               CONSTANT VARCHAR2(30) := 'Get_Primary_Terms_doc_File_Id';
 l_mergeable_doc_flag     VARCHAR2(1) := '?';
 l_media_id               FND_DOCUMENTS.MEDIA_ID%TYPE := -1;

 CURSOR contract_doc_csr IS

     SELECT b.media_id , docs.mergeable_doc_flag
     FROM  OKC_CONTRACT_DOCS docs, FND_ATTACHED_DOCUMENTS fnd, FND_DOCUMENTS b
     WHERE docs.primary_contract_doc_flag = 'Y'
       AND NVL(docs.delete_flag,'N') = 'N'
       AND docs.business_document_version = -99
       AND docs.business_document_type = p_document_type
       AND docs.business_document_id = p_document_id
       AND docs.attached_document_id = fnd.attached_document_id
       AND fnd.document_id = b.document_id;

BEGIN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: Entering Get_Primary_Terms_Doc_File_Id');
   END IF;
   OPEN  contract_doc_csr;
   FETCH contract_doc_csr into l_media_id,l_mergeable_doc_flag;
   CLOSE contract_doc_csr;

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1900: Return File id value:'||l_media_id);
   END IF;

   -- Start of fix for Bug 4085597
   IF OKC_TERMS_UTIL_GRP.get_contract_source_code( p_document_type, p_document_id ) = 'STRUCTURED'
      OR ( OKC_TERMS_UTIL_GRP.get_contract_source_code( p_document_type, p_document_id ) = 'ATTACHED'
           AND OKC_TERMS_UTIL_GRP.get_authoring_party_code( p_document_type, p_document_id ) = 'INTERNAL_ORG'
           AND l_mergeable_doc_flag = 'Y' )
   THEN
       l_media_id := 0;
   END IF;
   -- End of fix for Bug 4085597

   RETURN l_media_id;

EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2000: Leaving Get_Primary_Terms_Doc_File_Id because of EXCEPTION: '||sqlerrm);
   END IF;
   IF (contract_doc_csr%ISOPEN) THEN
         CLOSE contract_doc_csr ;
   END IF;
 RETURN -1;
END Get_Primary_Terms_Doc_File_Id;

FUNCTION Has_Primary_Contract_Doc(
  p_document_type    IN VARCHAR2,
  p_document_id      IN  NUMBER
 ) RETURN VARCHAR2 IS
 l_api_name                     CONSTANT VARCHAR2(30) := 'Has_Primary_Contract_Doc';
 CURSOR contract_doc_csr IS
     SELECT '!'
     FROM OKC_CONTRACT_DOCS
     WHERE business_document_type = p_document_type
       AND business_document_id = p_document_id
       AND primary_contract_doc_flag = 'Y'
       AND NVL(delete_flag,'N') = 'N'
       AND business_document_version = -99;

 l_result VARCHAR2(1) ;

BEGIN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: Entering Has_Primary_Contract_Doc');
   END IF;
   OPEN  contract_doc_csr;
   FETCH contract_doc_csr into l_result;

   IF contract_doc_csr%FOUND THEN
       CLOSE contract_doc_csr;
       RETURN 'Y';
   ELSE
       CLOSE contract_doc_csr;
       RETURN 'N';
   END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2000: Leaving Has_Primary_Contract_Doc because of EXCEPTION: '||sqlerrm);
   END IF;
   IF (contract_doc_csr%ISOPEN) THEN
         CLOSE contract_doc_csr ;
   END IF;
 RETURN 'E';
END Has_Primary_Contract_Doc;

--Removes the Primary contract flag on the attachment for the latest business document version.
PROCEDURE Clear_Primary_Doc_Flag(
  p_document_type    IN VARCHAR2,
  p_document_id      IN  NUMBER,

  x_return_status    OUT NOCOPY VARCHAR2
 ) IS
 l_api_name                     CONSTANT VARCHAR2(30) := 'Clear_Primary_Doc_Flag';
 CURSOR primary_doc_csr IS
     SELECT attached_document_id,object_version_number
     FROM OKC_CONTRACT_DOCS
     WHERE business_document_type = p_document_type
       AND business_document_id = p_document_id
       AND primary_contract_doc_flag = 'Y'
       AND NVL(delete_flag,'N') = 'N'
       AND business_document_version = -99;

  l_attached_document_id      OKC_CONTRACT_DOCS.ATTACHED_DOCUMENT_ID%TYPE := NULL;
  l_object_version_number     OKC_CONTRACT_DOCS.object_version_number%TYPE;

BEGIN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: Entering Clear_Primary_Doc_Flag');
   END IF;
   x_return_status    := G_RET_STS_SUCCESS;

   OPEN  primary_doc_csr;
   FETCH primary_doc_csr into l_attached_document_id,l_object_version_number;
   CLOSE primary_doc_csr;

   IF l_attached_document_id IS NOT NULL THEN
       OKC_CONTRACT_DOCS_PVT.update_row(
          x_return_status             => x_return_status,
          p_business_document_type    => p_document_type,
          p_business_document_id      => p_document_id,
          p_business_document_version => -99,
          p_attached_document_id      => l_attached_document_id,
          p_primary_contract_doc_flag => 'N',
          p_object_version_number     => l_object_version_number );
   END IF;


EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2000: Leaving Clear_Primary_Doc_Flag because of EXCEPTION: '||sqlerrm);
   END IF;
   IF (primary_doc_csr%ISOPEN) THEN
         CLOSE primary_doc_csr ;
   END IF;
   x_return_status := G_RET_STS_UNEXP_ERROR ;
END Clear_Primary_Doc_Flag;


END OKC_CONTRACT_DOCS_GRP;

/
