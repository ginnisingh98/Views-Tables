--------------------------------------------------------
--  DDL for Package OKC_CONTRACT_DOCS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CONTRACT_DOCS_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGCONTRACTDOCS.pls 120.0 2005/05/25 19:22:59 appldev noship $ */

  G_COPY_PROGRAM_ID     CONSTANT        NUMBER := -99999;
  G_ATTACH_ENTITY_NAME  CONSTANT        VARCHAR2(100) := 'OKC_CONTRACT_DOCS';
  G_CURRENT_VERSION     CONSTANT        NUMBER := -99;


  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

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

    );



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
    p_primary_contract_doc_flag IN VARCHAR2 := NULL,
    p_mergeable_doc_flag        IN VARCHAR2 := NULL,
    p_object_version_number     IN NUMBER,
    p_versioning_flag           IN VARCHAR2 := 'N'
    );

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
    );



    -- Start of comments
          --    API name  : Version_Attachments
          --    Type      : Group
          --    Pre-reqs  : None.
          --    Function  : This API moves current attachments to the specified business
          --                document version..
          --    Parameters:
          --           IN :p_api_version               IN  NUMBER   Required
          --                    The API version number
          --               p_init_msg_list             IN  NUMBER
          --                    Message list initialization flag
          --               p_validation_level          IN  NUMBER
          --                    Validation level of in the API
          --               p_commit                    IN  NUMBER
          --                    Transaction commit flag
          --               p_business_document_type    IN  VARCHAR2 Required
          --                    The business document type.
          --               p_business_document_id      IN  NUMBER   Required
          --                    The business document identifier
          --               p_business_document_version IN  NUMBER   Required
          --                    The business document version
          --          OUT :x_return_status             OUT VARCHAR2
          --                    Overall return status
          --               x_msg_count                 OUT NUMBER
          --                    number of messages in the API message list
          --               x_msg_data                  OUT VARCHAR2
          --                    The message in an encoded format
          --       Version:Current version 1.0
          -- End of comments
          PROCEDURE Version_Attachments(
            p_api_version               IN NUMBER,
            p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level          IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
            p_commit                    IN VARCHAR2 := FND_API.G_FALSE,

            x_return_status             OUT NOCOPY VARCHAR2,
            x_msg_count                 OUT NOCOPY NUMBER,
            x_msg_data                  OUT NOCOPY VARCHAR2,

            p_business_document_type    IN VARCHAR2,
            p_business_document_id      IN NUMBER,
            p_business_document_version IN NUMBER,
            p_include_gen_attach IN VARCHAR2 DEFAULT 'Y'
            );



          -- Start of comments
          --    API name  : Delete_Doc_Attachments
          --    Type      : Group
          --    Pre-reqs  : None.
          --    Function  : Deletes attachments of all versions of a business document.
          --    Parameters:
          --           IN :p_api_version               IN  NUMBER   Required
          --                    The API version number
          --               p_init_msg_list             IN  NUMBER
          --                    Message list initialization flag
          --               p_validation_level          IN  NUMBER
          --                    Validation level of in the API
          --               p_commit                    IN  NUMBER
          --                    Transaction commit flag
          --               p_business_document_type    IN  VARCHAR2 Required
          --                    The business document type.
          --               p_business_document_id      IN  NUMBER   Required
          --                    The business document identifier
          --          OUT :x_return_status             OUT VARCHAR2
          --                    Overall return status
          --               x_msg_count                 OUT NUMBER
          --                    number of messages in the API message list
          --               x_msg_data                  OUT VARCHAR2
          --                    The message in an encoded format
          --       Version:Current version 1.0
          -- End of comments
          PROCEDURE Delete_Doc_Attachments(
            p_api_version               IN NUMBER,
            p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level          IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
            p_commit                    IN VARCHAR2 := FND_API.G_FALSE,

            x_return_status             OUT NOCOPY VARCHAR2,
            x_msg_count                 OUT NOCOPY NUMBER,
            x_msg_data                  OUT NOCOPY VARCHAR2,

            p_business_document_type    IN VARCHAR2,
            p_business_document_id      IN NUMBER

            );


          -- Start of comments
          --    API name  : Delete_Ver_Attachments
          --    Type      : Group
          --    Pre-reqs  : None.
          --    Function  : Deletes attachments of a business document version.
          --    Parameters:
          --           IN :p_api_version               IN  NUMBER   Required
          --                    The API version number
          --               p_init_msg_list             IN  NUMBER
          --                    Message list initialization flag
          --               p_validation_level          IN  NUMBER
          --                    Validation level of in the API
          --               p_commit                    IN  NUMBER
          --                    Transaction commit flag
          --               p_business_document_type    IN  VARCHAR2 Required
          --                    The business document type.
          --               p_business_document_id      IN  NUMBER   Required
          --                    The business document identifier
          --               p_business_document_version      IN  NUMBER   Required
          --                    The business document version
          --          OUT :x_return_status             OUT VARCHAR2
          --                    Overall return status
          --               x_msg_count                 OUT NUMBER
          --                    number of messages in the API message list
          --               x_msg_data                  OUT VARCHAR2
          --                    The message in an encoded format
          --       Version:Current version 1.0
          -- End of comments
          PROCEDURE Delete_Ver_Attachments(
            p_api_version               IN NUMBER,
            p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level          IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
            p_commit                    IN VARCHAR2 := FND_API.G_FALSE,

            x_return_status             OUT NOCOPY VARCHAR2,
            x_msg_count                 OUT NOCOPY NUMBER,
            x_msg_data                  OUT NOCOPY VARCHAR2,

            p_business_document_type    IN VARCHAR2,
            p_business_document_id      IN NUMBER,
            p_business_document_version IN NUMBER

            );

          -- Start of comments
          --    API name  : Copy_Attachments
          --    Type      : Group
          --    Pre-reqs  : None.
          --    Function  : Copies attachments of a business document version to another business
          --                document version.
          --              If p_copy_for_amendment = 'Y'
		  --                 copy all categories
		  --              else if  p_copy_primary_doc_flag = 'Y"
		  --                 Copy PCD (in ref copy)
		  --                 Copy contract category docs (in deep copy)
		  --              else if p_from_bus_doc_type = p_to_bus_doc_type
		  --                 Copy only Contract and Support documents
		  --              else
		  --                  copy all categories
          --    Parameters:
          --           IN :p_api_version               IN  NUMBER   Required
          --                    The API version number
          --               p_init_msg_list             IN  NUMBER
          --                    Message list initialization flag
          --               p_validation_level          IN  NUMBER
          --                    Validation level of in the API
          --               p_commit                    IN  NUMBER
          --                    Transaction commit flag
          --               p_from_bus_doc_type    IN  VARCHAR2 Required
          --                    The business document type of the document to be copied.
          --               p_from_bus_doc_id      IN  NUMBER   Required
          --                    The business document identifier of the document to be copied.
          --               p_from_bus_doc_version      IN  NUMBER   Required
          --                    The business document version of the document to be copied.
          --               p_to_bus_doc_type    IN  VARCHAR2 Required
          --                    The business document type of the new document.
          --               p_to_bus_doc_id      IN  NUMBER   Required
          --                    The business document identifier of the new document.
          --               p_to_bus_doc_version      IN  NUMBER   Required
          --                    The business document version of the document of the new document.
          --               p_copy_by_ref        IN  VARCHAR2  Optional
          --                    The flag indicates whether the destination sttachments should be
          --                    created as reference attachments.
          --               p_copy_primary_doc_flag        IN  VARCHAR2  Optional
          --                    p_copy_primary_doc_flag='Y' will now copy 'Contract' category documents only.
          --               p_copy_for_amendment IN  VARCHAR2  Optional
          --                    The flag indicates whether this API has been called for for creating
          --                    a new version in sourcing and quoting applications
          --          OUT :x_return_status             OUT VARCHAR2
          --                    Overall return status
          --               x_msg_count                 OUT NUMBER
          --                    number of messages in the API message list
          --               x_msg_data                  OUT VARCHAR2
          --                    The message in an encoded format
          --       Version:Current version 1.0
          -- End of comments
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
                p_copy_by_ref               IN VARCHAR2 := 'Y',
                p_copy_primary_doc_flag     IN VARCHAR2 := 'N',
                p_copy_for_amendment        IN VARCHAR2 := 'N'

        );


 PROCEDURE  qa_doc(
    p_api_version      IN NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,

    p_doc_type         IN VARCHAR2,
    p_doc_id           IN NUMBER,

    x_qa_result_tbl    OUT NOCOPY OKC_TERMS_QA_GRP.qa_result_tbl_type,
    x_qa_return_status OUT NOCOPY VARCHAR2
    );

FUNCTION Is_Primary_Terms_Doc_Mergeable(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Get_Primary_Terms_Doc_File_Id(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER
) RETURN NUMBER;

FUNCTION Has_Primary_Contract_Doc(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER
) RETURN VARCHAR2;

PROCEDURE Clear_Primary_Doc_Flag(
  p_document_type    IN VARCHAR2,
  p_document_id      IN  NUMBER,
  x_return_status    OUT NOCOPY VARCHAR2
 );

END OKC_CONTRACT_DOCS_GRP;

 

/
