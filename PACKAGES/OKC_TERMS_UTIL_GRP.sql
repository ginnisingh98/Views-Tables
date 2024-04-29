--------------------------------------------------------
--  DDL for Package OKC_TERMS_UTIL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMS_UTIL_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGDUTS.pls 120.2.12010000.2 2011/12/09 13:31:27 serukull ship $ */

  G_TMPL_DOC_TYPE             CONSTANT   VARCHAR2(30) := 'TEMPLATE';

  G_ONLY_STANDARD_ART_EXIST   CONSTANT   VARCHAR2(30) := 'ONLY_STANDARD';
  G_NON_STANDARD_ART_EXIST    CONSTANT   VARCHAR2(30) := 'NON_STANDARD';
  G_NO_ARTICLE_EXIST          CONSTANT   VARCHAR2(30) := 'NONE';

  G_ONLY_STANDARD_ART_AMENDED CONSTANT   VARCHAR2(30) := 'ONLY_STANDARD';
  G_NON_STANDARD_ART_AMENDED  CONSTANT   VARCHAR2(30) := 'NON_STANDARD';
  G_NO_ARTICLE_AMENDED        CONSTANT   VARCHAR2(30) := 'NONE';
  G_PRIMARY_KDOC_AMENDED      CONSTANT   VARCHAR2(30) := 'PRIMARY_DOCUMENT';

  G_NO_CHANGE                 CONSTANT   VARCHAR2(30) := 'NO_CHANGE';
  G_ARTICLES_CHANGED          CONSTANT   VARCHAR2(30) := 'ARTICLES_CHANGED';
  G_DELIVERABLES_CHANGED      CONSTANT   VARCHAR2(30) := 'DELIVERABLES_CHANGED';
  G_ART_AND_DELIV_CHANGED     CONSTANT   VARCHAR2(30) := 'ALL_CHANGED';

  TYPE template_rec_type IS RECORD (
    template_name           VARCHAR2(240),
    intent                  VARCHAR2(1),
    status_code             VARCHAR2(30),
    start_date              DATE,
    end_date                DATE,
    instruction_text        VARCHAR2(2000),
    description             VARCHAR2(2000),
    global_flag             VARCHAR2(1),
    contract_expert_enabled VARCHAR2(1),
    org_id                  NUMBER);

  TYPE doc_rec_type IS RECORD (
     doc_type VARCHAR2(30),
     doc_id Number
  );

  TYPE category_rec_type IS RECORD (
     category_name Varchar2(2000)
  );

  TYPE item_rec_type IS RECORD (
     name Varchar2(2000)
  );


  TYPE var_value_rec_type IS RECORD (
      Variable_code            VARCHAR2(30),
      Variable_value_id        VARCHAR2(2000)
   );


  TYPE var_value_dtl_rec_type IS RECORD (
      Variable_code            VARCHAR2(30),
      Variable_value           VARCHAR2(2000),
      Variable_value_id        VARCHAR2(2000)
   );

  TYPE sys_var_value_tbl_type IS TABLE OF var_value_rec_type INDEX BY BINARY_INTEGER;

  TYPE variable_code_tbl_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

  TYPE category_tbl_type IS TABLE OF category_rec_type INDEX BY BINARY_INTEGER;
  TYPE item_tbl_type IS TABLE OF item_rec_type INDEX BY BINARY_INTEGER;

  TYPE doc_tbl_type IS TABLE OF doc_rec_type INDEX BY BINARY_INTEGER;

  TYPE variable_value_dtl_tbl IS TABLE of var_value_dtl_rec_type  INDEX BY BINARY_INTEGER;

--  Quoting Team wanted this record defination.
   TYPE item_tab is table of varchar2(2000) ;
   TYPE category_tab is table of varchar2(2000) ;

   TYPE item_dtl_tbl IS RECORD (
       category category_tab,
       item item_tab
      );
/*
-- To be used to delete Terms whenever a document is deleted.
*/
  PROCEDURE Delete_Doc (
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_commit           IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_validate_commit  IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_string IN VARCHAR2 := NULL,
    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
    -- Conc Mod Changes Start
   ,p_retain_lock_terms_yn        IN VARCHAR2 := 'N'
   ,p_retain_lock_xprt_yn         IN VARCHAR2 := 'N'
   ,p_retain_lock_deliverables_yn IN VARCHAR2 := 'N'

   ,p_retain_deliverables_yn IN VARCHAR2 := 'N'
   ,P_RELEASE_LOCKS_YN  IN VARCHAR2 := 'N'
   -- Conc Mod Changes End
  );

/*
-- To be used when doing bulk deletes of document.A very PO specific scenario.
*/
  PROCEDURE Purge_Doc (
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_commit           IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_tbl          IN  doc_tbl_type
  );

/*
-- To be used in amend flow to mark articles as amended if any of system
-- variables used in article has been changed in source document during amendment.
*/
  PROCEDURE Mark_Variable_Based_Amendment (
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_commit           IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
  );

/*
--To be used to find out if a document is using articles.If yes then what type.
--Possible return values NONE,ONLY_STANDARD_EXIST ,NON_STANDARD_EXIST .
*/

  FUNCTION Is_Article_Exist(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
  ) RETURN VARCHAR2;

  FUNCTION Is_Article_Exist(
    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
  ) RETURN VARCHAR2;

/*
-- To be used to find out if Terms and deliverable has deviate any deviation as
-- compared to template that was used in the document.ocument has used.
-- Possible return values NO_CHANGE,ARTICLES_CHANGED,DELIVERABLES_CHANGED,
-- ARTICLES_AND_DELIVERABLES_CHANGED
*/
  FUNCTION Deviation_From_Standard(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
  ) RETURN VARCHAR2;

FUNCTION Deviation_From_Standard(
    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
  ) RETURN VARCHAR2;
/*
--To be used to find out if template used in document has expired.Possible return values Y,N.
-- Possible return values are
--   FND_API.G_TRUE  = Template expired
--   FND_API.G_FALSE = Template not expired.
*/
  FUNCTION Is_Template_Expired(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
  ) RETURN VARCHAR2;

/*
--To be used to find out if any deliverable exists on document.If Yes then what
-- type.Possible values NONE,ONLY_CONTRACTUAL,ONLY_INTERNAL,CONTRACTUAL_AND_INTERNAL
*/

  FUNCTION Is_Deliverable_Exist(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
  ) RETURN VARCHAR2;


/*
--To be used in amend flow to find out if any article is amended.If Yes then what
-- type of article is amended.Possible values NO_ARTICLE_AMENDED,ONLY_STANDARD_AMENDED ,NON_STANDARD_AMENDED
*/

  FUNCTION Is_Article_Amended(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
  ) RETURN VARCHAR2;

/*
-- To be used in amend flow to find out if any deliverable is amended.
-- If Yes then what type.Possible values
-- NONE,ONLY_CONTRACTUAL,ONLY_INTERNAL,CONTRACTUAL_AND_INTERNAL
*/

  FUNCTION Is_Deliverable_Amended(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
  ) RETURN VARCHAR2;

--This API is deprecated. Use GET_CONTRACT_DETAILS() instead.
  PROCEDURE Get_Terms_Template(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    x_template_id      OUT NOCOPY NUMBER,
    x_template_name    OUT NOCOPY VARCHAR2
  );

/*
-- To be used to find out document type when document is of contract family.
*/
  FUNCTION Get_Contract_Document_Type(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_chr_id           IN  NUMBER
  ) RETURN VARCHAR2;

  PROCEDURE Get_Contract_Document_Type_ID(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_chr_id           IN  NUMBER,
    x_doc_id           OUT NOCOPY NUMBER,
    x_doc_type         OUT NOCOPY VARCHAR2
   );
/*
-- To be used to find out document type when document is of contract family.
*/
  PROCEDURE Get_Last_Update_Date(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,

    x_deliverable_changed_date OUT NOCOPY DATE,
    x_terms_changed_date OUT NOCOPY DATE
  );

  FUNCTION Ok_To_Commit (
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_tmpl_change      IN  VARCHAR2 := NULL,
    p_validation_string IN VARCHAR2 := NULL,
    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
  ) RETURN VARCHAR2;

 FUNCTION is_manual_article_exist(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
   ) RETURN VARCHAR2;

  FUNCTION Get_Template_Name(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_template_id      IN  NUMBER,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER
  ) RETURN VARCHAR2;

--This API is deprecated. Use GET_CONTRACT_DETAILS() instead.
  Function Get_Terms_Template(
    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
  ) Return varchar2;

  PROCEDURE get_item_dtl_for_expert(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    x_category_tbl     OUT NOCOPY item_tbl_type,
    x_item_tbl         OUT NOCOPY item_tbl_type
  );

 FUNCTION get_last_signed_revision(
    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_revision_num     IN NUMBER
  ) RETURN NUMBER;

Procedure Get_Terms_Template_dtl(
     p_template_id           IN  NUMBER,
     p_template_rec          OUT NOCOPY template_rec_type,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_data              OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER
  ) ;

FUNCTION empclob RETURN CLOB;
FUNCTION tempblob RETURN BLOB;

--This API is deprecated. Use GET_CONTRACT_DETAILS_ALL() instead.
Procedure Get_Terms_Template_dtl(
     p_doc_id               IN  NUMBER,
     p_doc_type             IN  VARCHAR,
        x_template_id          OUT NOCOPY NUMBER,
     x_template_name        OUT NOCOPY VARCHAR2,
     x_template_description OUT NOCOPY VARCHAR2,
     x_template_instruction OUT NOCOPY VARCHAR2,
     x_return_status        OUT NOCOPY VARCHAR2,
     x_msg_data             OUT NOCOPY VARCHAR2,
     x_msg_count            OUT NOCOPY NUMBER
  ) ;


FUNCTION enable_update(
  p_object_type    IN VARCHAR2,
  p_document_type  IN VARCHAR2,
  p_standard_yn    IN VARCHAR2
 ) RETURN VARCHAR2;

FUNCTION enable_update(
  p_object_type    IN VARCHAR2,
  p_document_type  IN VARCHAR2,
  p_standard_yn    IN VARCHAR2,
  p_kart_sec_id     in number
 ) RETURN VARCHAR2;

 /* FUNCTION enable_update(
  p_object_type    IN VARCHAR2,
  p_document_type  IN VARCHAR2,
  p_standard_yn    IN VARCHAR2,
  p_kart_sec_id     in NUMBER,
  p_lockingEnabledYn IN VARCHAR2
 ) RETURN VARCHAR2;  */






FUNCTION enable_delete(
  p_object_type    IN VARCHAR2,
  p_mandatory_yn   IN VARCHAR2,
  p_standard_yn    IN VARCHAR2,
  p_document_type  IN VARCHAR2 := NULL
 ) RETURN VARCHAR2;

 FUNCTION enable_delete(
  p_object_type    IN VARCHAR2,
  p_mandatory_yn   IN VARCHAR2,
  p_standard_yn    IN VARCHAR2,
  p_document_type  IN VARCHAR2 := NULL ,
  p_kart_sec_id     in number
 ) RETURN VARCHAR2;

 /* FUNCTION enable_delete(
  p_object_type    IN VARCHAR2,
  p_mandatory_yn   IN VARCHAR2,
  p_standard_yn    IN VARCHAR2,
  p_document_type  IN VARCHAR2 := NULL ,
  p_kart_sec_id     in NUMBER,
  p_lockingEnabledYn IN VARCHAR2
 ) RETURN VARCHAR2;   */



  FUNCTION Is_Document_Updatable(
    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_validation_string IN VARCHAR2
   ) RETURN VARCHAR2; -- 'T' - updatable, 'F'- non-updatable, 'E' - error or doesn't exist


/* Following API's are added for 11.5.10+ projects*/


FUNCTION Is_Primary_Terms_Doc_Mergeable(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Get_Primary_Terms_Doc_File_Id(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER
) RETURN NUMBER;


FUNCTION Has_Terms(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER
) RETURN VARCHAR2;

Procedure Get_Contract_Details(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_data              OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,

    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER,

    x_authoring_party       OUT NOCOPY VARCHAR2,
    x_contract_source       OUT NOCOPY VARCHAR2,
    x_template_name         OUT NOCOPY VARCHAR2,
    x_template_description  OUT NOCOPY VARCHAR2
);

Procedure Get_Contract_Details_All(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_data              OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,

    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER,
    p_document_version      IN  NUMBER := NULL,

    x_has_terms                 OUT NOCOPY  VARCHAR2,
    x_authoring_party_code      OUT NOCOPY  VARCHAR2,
    x_authoring_party           OUT NOCOPY  VARCHAR2,
    x_contract_source_code      OUT NOCOPY  VARCHAR2,
    x_contract_source           OUT NOCOPY  VARCHAR2,
    x_template_id               OUT NOCOPY  NUMBER,
    x_template_name             OUT NOCOPY  VARCHAR2,
    x_template_description      OUT NOCOPY  VARCHAR2,
    x_template_instruction      OUT NOCOPY  VARCHAR2,
    x_has_primary_doc           OUT NOCOPY  VARCHAR2,
    x_is_primary_doc_mergeable  OUT NOCOPY  VARCHAR2,
    x_primary_doc_file_id       OUT NOCOPY  VARCHAR2

);

FUNCTION Get_Authoring_Party_Code(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Get_Contract_Source_Code(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Has_Valid_Terms(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Is_Terms_Template_Valid(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_template_id      IN  NUMBER,
    p_doc_type         IN  VARCHAR2,
    p_org_id           IN  NUMBER,
    p_valid_date       IN  DATE DEFAULT SYSDATE
) RETURN VARCHAR2;

PROCEDURE Get_Contract_Defaults(
  p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 :=  FND_API.G_FALSE,

  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_data             OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,

  p_template_id          IN  VARCHAR2,
  p_document_type        IN  VARCHAR2,

  x_authoring_party      OUT NOCOPY   VARCHAR2,
  x_contract_source      OUT NOCOPY   VARCHAR2,
  x_template_name        OUT NOCOPY   VARCHAR2,
  x_template_description OUT NOCOPY   VARCHAR2
  );

PROCEDURE Get_Default_Template(
  p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 :=  FND_API.G_FALSE,

  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_data             OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,

  p_document_type        IN  VARCHAR2,
  p_org_id               IN  NUMBER DEFAULT NULL,
  p_valid_date           IN  DATE DEFAULT SYSDATE,

  x_template_id          OUT NOCOPY   NUMBER,
  x_template_name        OUT NOCOPY   VARCHAR2,
  x_template_description OUT NOCOPY   VARCHAR2);

FUNCTION Auto_Generate_Deviations(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER
) RETURN VARCHAR2;


FUNCTION Get_Deviations_File_Id(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER
) RETURN VARCHAR2;

PROCEDURE Has_Uploaded_Deviations_Doc(
  p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 :=  FND_API.G_FALSE,

  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_data             OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,

  p_document_type         IN  VARCHAR2,
  p_document_Id           IN  NUMBER,
  x_contract_source       OUT NOCOPY VARCHAR2,
  x_has_deviation_report  OUT NOCOPY VARCHAR2
);

FUNCTION is_Deviations_enabled(
  p_document_type    IN VARCHAR2,
  p_document_id      IN  NUMBER
) RETURN VARCHAR2;

  FUNCTION Contract_Terms_Amended(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER
  ) RETURN VARCHAR2;

--For Multi language support
PROCEDURE get_translated_template(
  p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 :=  FND_API.G_FALSE,

  p_template_id          IN  NUMBER,
  p_language             IN  VARCHAR2,
  p_document_type        IN  VARCHAR2,
  p_validity_date        IN  DATE := SYSDATE,

  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_data             OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,

  x_template_id          OUT NOCOPY NUMBER
);


END OKC_TERMS_UTIL_GRP;

/
