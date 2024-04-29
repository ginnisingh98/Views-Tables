--------------------------------------------------------
--  DDL for Package OKC_TERMS_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMS_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVDUTS.pls 120.9.12010000.6 2013/02/26 06:24:23 serukull ship $ */


    /*
    -- PROCEDURE Delete_Doc
    -- To be used to delete Terms whenever a document is deleted.
    */
    PROCEDURE Delete_Doc (
        x_return_status    OUT NOCOPY VARCHAR2,
        p_doc_type         IN  VARCHAR2,
        p_doc_id           IN  NUMBER
        ,p_retain_lock_terms_yn        IN VARCHAR2 := 'N'
        ,p_retain_lock_xprt_yn         IN VARCHAR2 := 'N'
   );

    /*
    -- PROCEDURE Delete_Doc_version
    -- To be used to delete Terms whenever a document is deleted.
    */
    PROCEDURE Delete_Doc_version (
        x_return_status    OUT NOCOPY VARCHAR2,
        p_doc_type         IN  VARCHAR2,
        p_doc_id           IN  NUMBER,
        p_version_number   IN  NUMBER );

    /*
    -- PROCEDURE Mark_Amendment
    -- This API will be used to mark any article as amended if any of variables have been changed.
    */
    PROCEDURE Mark_Amendment (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 :=  FND_API.G_FALSE,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_data          OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,

        p_doc_type          IN  VARCHAR2,
        p_doc_id            IN  NUMBER,
        p_variable_code     IN  VARCHAR2);

    /*
    -- PROCEDURE Merge_Template_Working_Copy
    -- To be used to merge a working copy of a template is approved and old copy
    -- and working copy
    -- 11.5.10+ changes
        1. Store the parent template id in a package global variable. This will retrieved
            and returned by the overaloaded procedure.
        2. Update the table OKC_TMPL_DRAFT_CLAUSES with the merged/parent template id.
    */
    PROCEDURE Merge_Template_Working_Copy (
        p_api_version      IN  NUMBER,
        p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,

        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_data         OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,

        p_template_id      IN  NUMBER );

    /*
    -- PROCEDURE Get_System_Variables
    -- Based on doc type this API will call different integrating API and will
    -- get values of all variables being used in Terms and Conditions of a document
    */
    PROCEDURE Get_System_Variables (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 :=  FND_API.G_FALSE,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_data          OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,

        p_doc_type          IN  VARCHAR2,
        p_doc_id            IN  NUMBER,
        p_only_doc_variables IN  VARCHAR2 := FND_API.G_TRUE,

        x_sys_var_value_tbl OUT NOCOPY OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type );

    /*
    -- PROCEDURE Substitute_Var_Value_Globally
    -- to be called from T and C authoring UI to substitute variable value of any value
    -- for every occurance of variable on document
    */
    PROCEDURE Substitute_Var_Value_Globally (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 :=  FND_API.G_FALSE,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_data          OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,

        p_doc_type          IN  VARCHAR2,
        p_doc_id            IN  NUMBER,
        p_variable_code     IN  VARCHAR2,
        p_variable_value    IN  VARCHAR2,
        p_variable_value_id IN  VARCHAR2,
        p_mode              IN  VARCHAR2,
        p_validate_commit   IN  VARCHAR2 := FND_API.G_TRUE,
        p_validation_string IN VARCHAR2 := NULL );

    /*
    -- PROCEDURE Create_Unassigned_Section
    -- creating un-assigned sections in a document
    */
    PROCEDURE Create_Unassigned_Section (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 :=  FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 :=  FND_API.G_FALSE,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_data          OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,

        p_doc_type          IN  VARCHAR2,
        p_doc_id            IN  NUMBER,

        x_scn_id            OUT NOCOPY NUMBER );

    /*
    -- To Check if document type is valid
    */
    FUNCTION is_doc_type_valid(
        p_doc_type      IN  VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 ;

    /*
    -- FUNCTION Get_Message
    -- to be used to put tokens in messages code and return translated messaged.
    -- It will be mainly used by QA API.
    */
    FUNCTION Get_Message (
        p_app_name       IN VARCHAR2,
        p_msg_name       IN VARCHAR2,
        p_token1         IN VARCHAR2 :=NULL,
        p_token1_value   IN VARCHAR2 :=NULL,
        p_token2         IN VARCHAR2 :=NULL,
        p_token2_value   IN VARCHAR2 :=NULL,
        p_token3         IN VARCHAR2 :=NULL,
        p_token3_value   IN VARCHAR2 :=NULL,
        p_token4         IN VARCHAR2 :=NULL,
        p_token4_value   IN VARCHAR2 :=NULL,
        p_token5         IN VARCHAR2 :=NULL,
        p_token5_value   IN VARCHAR2 :=NULL,
        p_token6         IN VARCHAR2 :=NULL,
        p_token6_value   IN VARCHAR2 :=NULL,
        p_token7         IN VARCHAR2 :=NULL,
        p_token7_value   IN VARCHAR2 :=NULL,
        p_token8         IN VARCHAR2 :=NULL,
        p_token8_value   IN VARCHAR2 :=NULL,
        p_token9         IN VARCHAR2 :=NULL,
        p_token9_value   IN VARCHAR2 :=NULL,
        p_token10        IN VARCHAR2 :=NULL,
        p_token10_value  IN VARCHAR2 :=NULL ) RETURN VARCHAR2;


    /* This function will be used in view OKS_TERMS_STRUCTURES_V */
    Function GET_LATEST_ART_VERSION(
        p_article_id  IN NUMBER,
        p_org_id IN NUMBER,
        p_eff_date IN DATE) RETURN Varchar2;

    /* This function will be used in view OKS_TERMS_STRUCTURES_V */
    FUNCTION GET_ALTERNATE_YN (
        p_article_id  IN NUMBER,
        p_org_id IN NUMBER) RETURN Varchar2;

    FUNCTION Tmpl_Intent_editable (
        p_template_id  IN NUMBER) RETURN Varchar2;

    FUNCTION HAS_ALTERNATES (
        p_article_id  IN NUMBER,
        p_eff_date IN DATE,
        p_document_type IN VARCHAR2) RETURN Varchar2;

    FUNCTION Has_Alternates(
        p_article_id  IN NUMBER,
        p_start_date IN DATE,
        p_end_date IN DATE,
        p_org_id IN NUMBER,
        p_document_type IN VARCHAR2) RETURN Varchar2;

    FUNCTION Has_amendments(
        p_document_id  IN NUMBER,
        p_document_type IN VARCHAR2,
     p_document_version IN NUMBER) RETURN Varchar2; -- Fix for bug# 4313546

    FUNCTION get_summary_amend_code(
        p_existing_summary_code IN VARCHAR2,
        p_existing_operation_code IN VARCHAR2,
        p_amend_operation_code  IN VARCHAR2 ) return  VARCHAR2;

    /* Wraps get_summary_amend_code and replaces G_MISS_CHAR with NULL in return value */
    FUNCTION get_actual_summary_amend_code(
        p_existing_summary_code     IN VARCHAR2,
        p_existing_operation_code   IN VARCHAR2,
        p_amend_operation_code      IN VARCHAR2 ) return  VARCHAR2;

    FUNCTION get_article_version_number(
        p_art_version_id IN NUMBER) RETURN Varchar2;

    FUNCTION get_section_label(
        p_scn_id IN NUMBER) RETURN Varchar2;

    -- bug #4059806
    -- Added function to get default section from article version
    -- or expert enabled template.
    FUNCTION GET_SECTION_NAME(
        p_article_version_id IN NUMBER) RETURN VARCHAR2;

    FUNCTION GET_SECTION_NAME(
         p_article_version_id IN NUMBER,
     p_template_id        IN NUMBER) RETURN VARCHAR2;

    FUNCTION get_latest_art_version_no(
        p_article_id IN NUMBER,
        p_document_type IN VARCHAR2,
        p_document_id IN NUMBER ) RETURN Varchar2 ;

    FUNCTION get_latest_art_version_id(
        p_article_id IN NUMBER,
        p_document_type IN VARCHAR2,
        p_document_id IN NUMBER ) RETURN NUMBER ;

    FUNCTION Get_latest_tmpl_art_version_id(
        p_article_id  IN NUMBER,
        p_eff_date IN DATE) RETURN NUMBER;

   /* 11.5.10+ obsolete, added 2 new in params
    FUNCTION Get_latest_tmpl_art_version_id(
        p_article_id  IN NUMBER,
        p_start_date IN DATE,
        p_end_date IN DATE,
        p_status_code IN VARCHAR2) RETURN NUMBER;
  */
    FUNCTION get_article_name(
        p_article_id IN NUMBER,
        p_article_version_id IN NUMBER) RETURN Varchar2;

    FUNCTION GET_SECTION_NAME(
        p_CONTEXT IN VARCHAR2,
        p_ID IN NUMBER) RETURN VARCHAR2;

    FUNCTION  GET_VALUE_SET_VARIABLE_VALUE (
        p_CONTEXT            IN VARCHAR2,
        p_VALUE_SET_ID  IN NUMBER,
        p_FLEX_VALUE_ID        IN VARCHAR2 ) RETURN VARCHAR2;

    PROCEDURE get_latest_article_details(
        p_article_id IN NUMBER,
        p_document_type IN VARCHAR2,
        p_document_id IN NUMBER,
        x_article_version_id OUT NOCOPY NUMBER,
        x_article_version_number OUT NOCOPY VARCHAR2,
        x_local_article_id OUT NOCOPY NUMBER,
        x_adoption_type OUT NOCOPY VARCHAR2 );

    FUNCTION get_local_article_id(
        p_article_id IN NUMBER,
        p_document_type IN VARCHAR2,
        p_document_id IN NUMBER ) RETURN NUMBER ;

    FUNCTION get_adoption_type(
        p_article_id IN NUMBER,
        p_document_type IN VARCHAR2,
        p_document_id IN NUMBER ) RETURN Varchar2 ;

    FUNCTION get_print_template_name(
        p_print_template_id IN NUMBER) RETURN VARCHAR2;

    FUNCTION get_current_org_id(
        p_doc_type   IN  VARCHAR2,
        p_doc_id     IN  NUMBER ) RETURN NUMBER;

    FUNCTION get_template_model_name (
        p_template_id           IN  NUMBER,
        p_template_model_id     IN  NUMBER) RETURN VARCHAR2;

    FUNCTION get_tmpl_model_published_by(
        p_template_id           IN  NUMBER,
        p_template_model_id     IN  NUMBER ) RETURN VARCHAR2;

    FUNCTION get_tmpl_model_publish_date(
        p_template_id           IN  NUMBER,
        p_template_model_id     IN  NUMBER ) RETURN DATE;

    FUNCTION get_chr_id_for_doc_id(
        p_document_id    IN  NUMBER ) RETURN NUMBER;

    --Checks if the given function is accessible to the user and returns 'Y' if accessible else 'N'
    FUNCTION is_Function_Accessible(
        p_function_name    IN VARCHAR2
        ) RETURN VARCHAR2;

    PROCEDURE get_template_details (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 :=  FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 :=  FND_API.G_FALSE,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_data          OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,

        p_document_type          IN  VARCHAR2,
        p_document_id            IN  NUMBER,

        p_mode in VARCHAR2,
        p_eff_date IN DATE,
        p_org_id   IN NUMBER,
        x_template_exists OUT NOCOPY VARCHAR2,
        x_template_id OUT NOCOPY NUMBER,
        x_template_name OUT NOCOPY VARCHAR2,
        x_enable_expert_button OUT NOCOPY VARCHAR2,
        x_template_org_id OUT NOCOPY NUMBER,
        x_doc_numbering_scheme OUT NOCOPY VARCHAR2,
        x_config_header_id OUT NOCOPY NUMBER,
        x_config_revision_number OUT NOCOPY NUMBER,
        x_valid_config_yn OUT NOCOPY VARCHAR2
        );

    --Checks if the given section is deleted
    FUNCTION is_section_deleted(
        p_scn_id    IN NUMBER
        ) RETURN VARCHAR2;

    --Checks if the given article is deleted
    FUNCTION is_article_deleted(
        p_cat_id    IN NUMBER,
        p_article_id IN NUMBER
        ) RETURN VARCHAR2;

    --Checks if the given article has deliverable type variables and the deliverable is amended
    --To be used by the Printing program
    FUNCTION deliverable_amendment_exists(
        p_cat_id    IN NUMBER,
        p_document_id IN NUMBER,
        p_document_type IN VARCHAR2
        ) RETURN VARCHAR2;

    /*
    -- PROCEDURE purge_qa_results
    -- Called by concurrent program to purge old QA error data.
    -- Parameter p_num_days is how far in the past to end the purge
    */
    PROCEDURE purge_qa_results (
        errbuf  OUT NOCOPY VARCHAR2,
        retcode OUT NOCOPY VARCHAR2,
        p_num_days IN NUMBER default 3);


    /*
    -- 11.5.10+
    -- 2004/8/20 ANJKUMAR: overloaded function with additional params
    -- p_doc_type and p_doc_id, changes logic only for p_doc_type = 'TEMPLATE'
    -- looks first in the new table OKC_TMPL_DRAFT_CLAUSES if status is
    -- DRAFT/REJECTED/PENDING_APPROVAL to get article versions
    -- Added p_org_id param for bug fix 15875890
    */
    FUNCTION get_latest_tmpl_art_version_id(
        p_article_id    IN NUMBER,
        p_start_date    IN DATE,
        p_end_date        IN DATE,
        p_status_code    IN VARCHAR2,
        p_doc_type        IN VARCHAR2 DEFAULT NULL,
        p_doc_id        IN NUMBER DEFAULT NULL,
        p_org_id        IN NUMBER DEFAULT NULL) RETURN NUMBER;

    /*
    --11.5.10+
    --finds draft clauses to be submitted with template and creates rows in OKC_TMPL_DRAFT_CLAUSES
    --returns whether there is a draft clause through x_drafts_present
    */
    PROCEDURE create_tmpl_clauses_to_submit  (
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2,
        p_template_id                  IN VARCHAR2,
        p_template_start_date          IN DATE DEFAULT NULL,
        p_template_end_date            IN DATE DEFAULT NULL,
        p_org_id                       IN NUMBER,
        x_drafts_present               OUT NOCOPY VARCHAR2,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2
        );

    /*
    -- PROCEDURE Merge_Template_Working_Copy 11.5.10+ overloaded version
    -- To be used to merge a working copy of a template is approved and old copy
    -- and working copy
    -- new out parameter x_parent_template_id returns the template id of the merged template
    */
    PROCEDURE Merge_Template_Working_Copy (
        p_api_version           IN  NUMBER,
        p_init_msg_list         IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,

        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,

        p_template_id           IN  NUMBER,
        x_parent_template_id    OUT NOCOPY NUMBER);

    FUNCTION unadopted_art_exist_on_tmpl(
        p_template_id          IN NUMBER,
     p_org_id               IN NUMBER DEFAULT NULL)
     RETURN VARCHAR2;


    -- Record types used by Update Contract Administrator API
    TYPE doc_ids_tbl IS TABLE OF okc_template_usages.document_id%TYPE NOT NULL
          INDEX BY PLS_INTEGER;

    TYPE doc_types_tbl IS TABLE OF okc_template_usages.document_type%TYPE NOT NULL
          INDEX BY PLS_INTEGER;

    TYPE new_con_admin_user_ids_tbl IS TABLE OF okc_template_usages.contract_admin_id%TYPE NOT NULL
          INDEX BY PLS_INTEGER;


    -- Start of comments
    --API name      : update_contract_admin
    --Type          : Private.
    --Function      : API to update Contract Administrator of Blanket Sales
    --                Agreements, Sales Orders and Sales Quotes
    --Pre-reqs      : None.
    --Parameters    :
    --IN            : p_api_version         IN NUMBER       Required
    --              : p_init_msg_list       IN VARCHAR2     Optional
    --                   Default = FND_API.G_FALSE
    --              : p_commit              IN VARCHAR2     Optional
    --                   Default = FND_API.G_FALSE
    --              : p_doc_ids_tbl         IN doc_ids_tbl       Required
    --                   List of document ids whose Contract Administrator to be changed
    --              : p_doc_types_tbl       IN doc_types_tbl       Required
    --                   List of document types whose Contract Administrator to be changed
    --              : p_new_con_admin_user_ids_tbl IN new_con_admin_user_ids_tbl       Required
    --                   List of new Contract Administrator ids
    --OUT           : x_return_status       OUT  VARCHAR2(1)
    --              : x_msg_count           OUT  NUMBER
    --              : x_msg_data            OUT  VARCHAR2(2000)
    --Note          :
    -- End of comments
    PROCEDURE update_contract_admin(
      p_api_version     IN   NUMBER,
      p_init_msg_list   IN   VARCHAR2,
      p_commit          IN   VARCHAR2,
      p_doc_ids_tbl     IN   doc_ids_tbl,
      p_doc_types_tbl              IN   doc_types_tbl,
      p_new_con_admin_user_ids_tbl IN   new_con_admin_user_ids_tbl,
      x_return_status   OUT  NOCOPY  VARCHAR2,
      x_msg_count       OUT  NOCOPY  NUMBER,
      x_msg_data        OUT  NOCOPY  VARCHAR2
    );


    -- Start of comments
    --API name      : get_sales_group_con_admin
    --Type          : Private.
    --Function      : API to get Contract Administrator of a business document
    --                according to Sales Group Assignment
    --Pre-reqs      : None.
    --Parameters    :
    --IN            : p_api_version         IN NUMBER       Required
    --              : p_init_msg_list       IN VARCHAR2     Optional
    --                   Default = FND_API.G_FALSE
    --              : p_doc_id         IN NUMBER       Required
    --                   Id of document whose Contract Administrator is required
    --              : p_doc_type       IN VARCHAR2       Required
    --                   Type of document whose Contract Administrator is required
    --OUT           : x_new_con_admin_user_id OUT NUMBER
    --                   New Contract Administrator id
    --              : x_return_status       OUT  VARCHAR2(1)
    --              : x_msg_count           OUT  NUMBER
    --              : x_msg_data            OUT  VARCHAR2(2000)
    --Note          :
    -- End of comments
    PROCEDURE get_sales_group_con_admin(
      p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2,
      p_doc_id                  IN  NUMBER,
      p_doc_type                IN  VARCHAR2,
      x_new_con_admin_user_id   OUT NOCOPY  NUMBER,
      x_return_status           OUT NOCOPY  VARCHAR2,
      x_msg_count               OUT NOCOPY  NUMBER,
      x_msg_data                OUT NOCOPY  VARCHAR2
    );

    FUNCTION has_uploaded_terms(
    p_document_type IN VARCHAR2,
    p_document_id   IN NUMBER)
    RETURN Varchar2;

    FUNCTION is_terms_locked(
    p_document_type IN VARCHAR2,
    p_document_id   IN NUMBER)
    RETURN Varchar2;

    FUNCTION get_layout_template_code(
    p_doc_type IN VARCHAR2,
    p_doc_type_class IN VARCHAR2,
    p_doc_id   IN NUMBER,
    p_org_id IN NUMBER)
    RETURN Varchar2;

--For R12: MSWord2WaySync
PROCEDURE lock_contract(
  p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 :=  FND_API.G_FALSE,

  p_commit               IN  Varchar2,
  p_document_type        IN  VARCHAR2,
  p_document_id           IN  NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_data             OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER
);

--For R12: MSWord2WaySync
PROCEDURE unlock_contract(
  p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 :=  FND_API.G_FALSE,

  p_commit               IN  Varchar2,
  p_document_type        IN  VARCHAR2,
  p_document_id           IN  NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_data             OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER
);

PROCEDURE get_default_contract_admin(
  p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 :=  FND_API.G_FALSE,

  p_document_type        IN  VARCHAR2,
  p_document_id           IN  NUMBER,
  x_has_default_contract_admin OUT NOCOPY VARCHAR2,
  x_def_contract_admin_name OUT NOCOPY VARCHAR2,
  x_def_contract_admin_id OUT NOCOPY NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_data             OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER

);
FUNCTION get_default_contract_admin_id(
  p_document_type IN VARCHAR2,
  p_document_id IN NUMBER)
  RETURN NUMBER;

FUNCTION get_contract_admin_name(
  p_contract_admin_id IN NUMBER)
  RETURN VARCHAR2;

FUNCTION get_sys_last_upd_date(
p_document_type IN VARCHAR2,
p_document_id IN NUMBER)
RETURN DATE;

-- Fix for bug# 5235082. Changed parameter from p_article_id to p_id
FUNCTION get_revert_art_version_id(
         p_id IN NUMBER,
	    p_document_type IN VARCHAR2,
	    p_document_id IN NUMBER ) RETURN NUMBER ;

--For R12.1: User defined variables with procedures
PROCEDURE set_udv_with_procedures (
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_document_type     IN  VARCHAR2,
    p_document_id       IN  NUMBER,
    p_output_error	IN  VARCHAR2 :=  FND_API.G_TRUE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER
  );

PROCEDURE get_udv_with_proc_value (
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER,
    p_variable_code         IN  VARCHAR2,
    p_output_error          IN  VARCHAR2 :=  FND_API.G_FALSE,
    x_variable_value        OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_data              OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER
);

END OKC_TERMS_UTIL_PVT;

/
