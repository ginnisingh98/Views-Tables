--------------------------------------------------------
--  DDL for Package OKC_XPRT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XPRT_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVXUTLS.pls 120.18.12010000.4 2012/06/14 11:44:55 nbingi ship $ */

TYPE expert_articles_tbl_type IS TABLE OF NUMBER -- column of article IDs
    INDEX BY BINARY_INTEGER;

-- Begin: Added for R12
TYPE expert_deviations_list IS TABLE OF NUMBER -- column of Deviation Rule IDs
    INDEX BY BINARY_INTEGER;

TYPE expert_dev_line_nbr_list IS TABLE OF NUMBER -- column of Deviation Rule Line Numbers
    INDEX BY BINARY_INTEGER;

TYPE dev_rule_rec_type IS RECORD (
  line_number		   varchar2(250),
  rule_id	           OKC_XPRT_RULE_HDRS_ALL.rule_id%TYPE
);

TYPE dev_rule_variables_rec_type IS RECORD (
  line_number		   varchar2(250),
  rule_id	           OKC_XPRT_RULE_HDRS_ALL.rule_id%TYPE,
  variable_id		   OKC_BUS_VARIABLES_B.variable_code%TYPE
);

TYPE dev_rule_questions_rec_type IS RECORD (
  --line_number		   varchar2(250),
  rule_id	           OKC_XPRT_RULE_HDRS_ALL.rule_id%TYPE,
  question_id		   OKC_XPRT_QUESTIONS_B.question_id%TYPE
);

TYPE dev_rule_var_values_rec_type IS RECORD (
  line_number		   varchar2(250),
  rule_id	           OKC_XPRT_RULE_HDRS_ALL.rule_id%TYPE,
  variable_id		   OKC_BUS_VARIABLES_B.variable_code%TYPE,
  variable_value	   VARCHAR2(40)
);

TYPE dev_rule_qst_values_rec_type IS RECORD (
  --line_number		   varchar2(250),
  rule_id	           OKC_XPRT_RULE_HDRS_ALL.rule_id%TYPE,
  question_id		   OKC_XPRT_QUESTIONS_B.question_id%TYPE,
  question_value	   VARCHAR2(40)
);

TYPE dev_rule_tbl_type IS TABLE OF dev_rule_rec_type
    INDEX BY BINARY_INTEGER;

TYPE dev_rule_variables_tbl_type IS TABLE OF dev_rule_variables_rec_type
    INDEX BY BINARY_INTEGER;

TYPE dev_rule_questions_tbl_type IS TABLE OF dev_rule_questions_rec_type
    INDEX BY BINARY_INTEGER;

TYPE dev_rule_var_values_tbl_type IS TABLE OF dev_rule_var_values_rec_type
    INDEX BY BINARY_INTEGER;

TYPE dev_rule_qst_values_tbl_type IS TABLE OF dev_rule_qst_values_rec_type
    INDEX BY BINARY_INTEGER;

-- End: Added for R12

---------------------------------------------------
--  Procedure:
---------------------------------------------------
PROCEDURE check_import_status
(
 p_run_id           IN NUMBER,
 p_import_status    IN VARCHAR2,
 p_model_type       IN VARCHAR2,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	    OUT	NOCOPY VARCHAR2,
 x_msg_count	    OUT	NOCOPY NUMBER
);

--Bug 4723548 Added new function
FUNCTION is_value_set_changed (
    p_object_code          IN VARCHAR2,
    p_object_value_set_id  IN NUMBER)
RETURN VARCHAR2;

FUNCTION get_value_set_id
(
 p_value_set_name    IN VARCHAR2
) RETURN NUMBER;

FUNCTION is_rule_line_level
(
 p_rule_id    IN NUMBER
) RETURN VARCHAR2;

FUNCTION xprt_enabled_template
(
 p_template_id       IN NUMBER
) RETURN VARCHAR2;

PROCEDURE create_test_publication
(
 x_return_status   OUT   NOCOPY VARCHAR2,
 x_msg_data	    OUT	NOCOPY VARCHAR2,
 x_msg_count	    OUT	NOCOPY NUMBER
);

PROCEDURE populate_questions_order
(
 p_Template_Id   IN NUMBER,
 p_Commit_Flag   IN VARCHAR2,
 p_Mode          IN VARCHAR2,
 x_Return_Status OUT NOCOPY VARCHAR2,
 x_Msg_Count     OUT NOCOPY NUMBER,
 x_Msg_Data      OUT NOCOPY VARCHAR2
);

FUNCTION Ok_To_Delete_Question
(
 p_question_id         IN NUMBER
) RETURN VARCHAR2;

PROCEDURE create_production_publication
(
 p_calling_mode    IN   VARCHAR2,
 p_template_id     IN   NUMBER,
 x_return_status   OUT  NOCOPY VARCHAR2,
 x_msg_data	    OUT	NOCOPY VARCHAR2,
 x_msg_count	    OUT	NOCOPY NUMBER
);

PROCEDURE validate_template_for_expert
(
 p_api_version                  IN NUMBER,
 p_init_msg_list                IN VARCHAR2,
 p_template_id                  IN NUMBER,
 x_qa_result_tbl                IN OUT NOCOPY OKC_TERMS_QA_GRP.qa_result_tbl_type,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2
);

PROCEDURE build_cz_xml_init_msg
(
 p_api_version                  IN NUMBER,
 p_init_msg_list                IN VARCHAR2,
 p_document_id                  IN NUMBER,
 p_document_type                IN VARCHAR2,
 p_config_header_id             IN NUMBER,
 p_config_rev_nbr               IN NUMBER,
 p_template_id                  IN NUMBER,
 x_cz_xml_init_msg              OUT NOCOPY LONG,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2
 );

PROCEDURE parse_cz_xml_terminate_msg
(
 p_api_version                  IN NUMBER,
 p_init_msg_list                IN VARCHAR2,
 p_cz_xml_terminate_msg         IN LONG,
 x_valid_config                 OUT NOCOPY VARCHAR2,
 x_complete_config              OUT NOCOPY VARCHAR2,
 x_config_header_id             OUT NOCOPY NUMBER,
 x_config_rev_nbr               OUT NOCOPY NUMBER,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2
);

PROCEDURE process_qa_result
(
 p_api_version                  IN NUMBER,
 p_init_msg_list                IN VARCHAR2,
 p_document_id                  IN NUMBER,
 p_document_type                IN VARCHAR2,
 p_config_header_id             IN NUMBER,
 p_config_rev_nbr               IN NUMBER,
 x_qa_result_tbl                IN OUT NOCOPY OKC_TERMS_QA_GRP.qa_result_tbl_type,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2
);

PROCEDURE get_expert_articles
(
 p_api_version                  IN NUMBER,
 p_init_msg_list                IN VARCHAR2,
 p_document_id                  IN NUMBER,
 p_document_type                IN VARCHAR2,
 p_config_header_id             IN NUMBER,
 p_config_rev_nbr               IN NUMBER,
 x_expert_articles_tbl          OUT NOCOPY expert_articles_tbl_type,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2
);

/*PROCEDURE contract_expert_bv
(
 p_api_version                  IN NUMBER,
 p_init_msg_list                IN VARCHAR2,
 p_document_id                  IN NUMBER,
 p_document_type                IN VARCHAR2,
 p_bv_mode                      IN VARCHAR2,
 p_sequence_id					IN NUMBER,
 x_qa_result_tbl                IN OUT NOCOPY OKC_TERMS_QA_GRP.qa_result_tbl_type,
 x_expert_articles_tbl          OUT NOCOPY expert_articles_tbl_type,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2
);*/

PROCEDURE update_ce_config
(
 p_api_version                  IN NUMBER,
 p_init_msg_list                IN VARCHAR2,
 p_document_id                  IN NUMBER,
 p_document_type                IN VARCHAR2,
 p_config_header_id             IN NUMBER,
 p_config_rev_nbr               IN NUMBER,
 p_doc_update_mode              IN VARCHAR2,
 x_count_articles_dropped       OUT NOCOPY NUMBER ,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2
 ,p_lock_xprt_yn            IN VARCHAR2 := 'N' -- Conc Mod changes
 ,p_lock_terms_yn           IN VARCHAR2 := 'N' -- Conc Mod changes
);

PROCEDURE update_config_id_rev_nbr
(
 p_api_version                  IN NUMBER,
 p_init_msg_list                IN VARCHAR2,
 p_document_id                  IN NUMBER,
 p_document_type                IN VARCHAR2,
 p_config_header_id             IN NUMBER,
 p_config_rev_nbr               IN NUMBER,
 p_template_id                  IN NUMBER,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2
 ,p_lock_xprt_yn         IN VARCHAR2 := 'N'   -- Conc Mod changes
);

PROCEDURE get_article_details
(
 p_api_version      IN  NUMBER,
 p_init_msg_list    IN  VARCHAR2,
 p_document_id      IN NUMBER,
 p_document_type    IN VARCHAR2,
 p_article_id       IN NUMBER,
 p_effectivity_date IN DATE,
 x_article_id       OUT NOCOPY NUMBER,
 x_article_version_id OUT NOCOPY NUMBER,
 x_doc_lib           OUT NOCOPY VARCHAR2,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2
);

  FUNCTION check_clause_exists (
    p_rule_id   IN NUMBER,
    p_clause_id IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION check_variable_exists (
    p_rule_id            IN NUMBER,
    p_variable_code      IN VARCHAR2)
  RETURN VARCHAR2;

  FUNCTION check_question_exists (
    p_rule_id            IN NUMBER,
    p_question_id      IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION check_template_exists(
    p_rule_id            IN NUMBER,
    p_template_id      IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION check_orgwide_rule_exists
  RETURN VARCHAR2;

  FUNCTION get_object_name (
    p_object_name      IN VARCHAR2,
    p_object_code      IN VARCHAR2)
  RETURN VARCHAR2;

  FUNCTION get_value_display (
    p_object_value_type      IN VARCHAR2,
    p_object_value_code      IN VARCHAR2,
    p_object_value_set_id    IN NUMBER,
    p_validation_type        IN VARCHAR2,
    p_longlist_flag          IN VARCHAR2,
    p_mode                   IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2;

  FUNCTION get_value_desc (
    p_object_value_type      IN VARCHAR2,
    p_object_value_code      IN VARCHAR2,
    p_object_value_set_id    IN NUMBER,
    p_validation_type        IN VARCHAR2,
    p_longlist_flag          IN VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_valueset_value (
    p_object_value_set_id    IN NUMBER,
    p_object_value_code      IN VARCHAR2,
    p_validation_type        IN VARCHAR2)
    RETURN VARCHAR2 ;

  FUNCTION get_valueset_value_desc (
    p_object_value_set_id    IN NUMBER,
    p_object_value_code      IN VARCHAR2,
    p_validation_type        IN VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_value_desc (
    p_rule_condition_id      IN NUMBER,
    p_object_value_code      IN VARCHAR2)
  RETURN VARCHAR2;

  FUNCTION get_value_display (
    p_rule_condition_id      IN NUMBER,
    p_object_value_code      IN VARCHAR2)
  RETURN VARCHAR2 ;

  -- Added for Policy Deviations Project
  FUNCTION get_concat_condition_values (
           p_rule_condition_id      IN NUMBER)
  RETURN VARCHAR2;

  -- Bug#4728299 Added for Policy Deviations Project
  FUNCTION get_deviation_document_value (
           p_rule_id          IN NUMBER,
           p_object_type      IN VARCHAR2,
           p_object_code      IN VARCHAR2,
           p_sequence_id      IN VARCHAR2,
           p_value_set_id     IN NUMBER,
           p_object_value_type IN VARCHAR2,
           p_object_value_code IN VARCHAR2,
	   p_line_number      IN VARCHAR2)
  RETURN VARCHAR2;

PROCEDURE publish_rule_with_no_tmpl
(
 p_calling_mode    IN   VARCHAR2,
 x_return_status   OUT  NOCOPY VARCHAR2,
 x_msg_data	    OUT	NOCOPY VARCHAR2,
 x_msg_count	    OUT	NOCOPY NUMBER
);

PROCEDURE check_rules_validity
(
 p_qa_mode		IN VARCHAR2,
 p_template_id      IN NUMBER,
 x_sequence_id      OUT NOCOPY NUMBER,
 x_qa_status        OUT NOCOPY VARCHAR2,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	     OUT	NOCOPY VARCHAR2,
 x_msg_count	     OUT	NOCOPY NUMBER
);

FUNCTION is_valid (
    p_object_id      IN NUMBER,
    p_object_type    IN VARCHAR2)
RETURN VARCHAR2 ;

FUNCTION is_value_valid (
    p_object_code          IN VARCHAR2,
    p_rule_condition_id    IN NUMBER)
RETURN VARCHAR2 ;

FUNCTION get_message(p_appl_name    IN VARCHAR2,
                     p_msg_name     IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE get_publication_id
(
 p_api_version                  IN NUMBER,
 p_init_msg_list                IN VARCHAR2,
 p_template_id                  IN NUMBER,
 x_publication_id               OUT NOCOPY NUMBER,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2
);

FUNCTION ok_to_delete_clause
(
 p_article_id         IN NUMBER
) RETURN VARCHAR2;

PROCEDURE get_qa_code_detail
(
 p_document_type      IN   VARCHAR2,
 p_qa_code            IN   VARCHAR2,
 x_perform_qa         OUT  NOCOPY VARCHAR2,
 x_qa_name            OUT  NOCOPY VARCHAR2,
 x_severity_flag      OUT  NOCOPY VARCHAR2,
 x_return_status      OUT  NOCOPY VARCHAR2
);

PROCEDURE enable_expert_button
(
 p_api_version                  IN NUMBER,
 p_init_msg_list                IN VARCHAR2,
 p_template_id                  IN NUMBER,
 p_document_id                  IN NUMBER,
 p_document_type                IN VARCHAR2,
 x_enable_expert_button         OUT NOCOPY VARCHAR2, -- FND_API.G_FALSE or G_TRUE
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2
);



--Under development - Arun
PROCEDURE contract_expert_bv
(
 p_api_version                  IN NUMBER,
 p_init_msg_list                IN VARCHAR2,
 p_document_id                  IN NUMBER,
 p_document_type                IN VARCHAR2,
 p_bv_mode                      IN VARCHAR2,
 p_sequence_id 			IN NUMBER DEFAULT NULL,
 x_qa_result_tbl                IN OUT NOCOPY OKC_TERMS_QA_GRP.qa_result_tbl_type,
 x_expert_articles_tbl          OUT NOCOPY expert_articles_tbl_type,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2
);

PROCEDURE get_expert_selections(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_document_id                  IN NUMBER,
    p_document_type                IN VARCHAR2,
    p_config_header_id             IN NUMBER,
    p_config_rev_nbr               IN NUMBER,
    x_expert_clauses_tbl           OUT NOCOPY expert_articles_tbl_type,
    x_expert_deviations_tbl        OUT NOCOPY dev_rule_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2);

PROCEDURE get_rule_details(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_dev_rule_tbl                 IN dev_rule_tbl_type,
    x_dev_rule_questions_tbl	   OUT NOCOPY dev_rule_questions_tbl_type,
    x_dev_rule_variables_tbl	   OUT NOCOPY dev_rule_variables_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2);

PROCEDURE get_rule_variable_values(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_sequence_id	           IN NUMBER,
    p_dev_rule_variables_tbl       IN dev_rule_variables_tbl_type,
    x_dev_rule_var_values_tbl	   OUT NOCOPY dev_rule_var_values_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2);

PROCEDURE get_rule_question_values(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_config_header_id             IN NUMBER,
    p_config_rev_nbr               IN NUMBER,
    p_dev_rule_questions_tbl       IN dev_rule_questions_tbl_type,
    x_dev_rule_qst_values_tbl	   OUT NOCOPY dev_rule_qst_values_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2);

PROCEDURE get_article_details(
    p_api_version      		IN  NUMBER,
    p_init_msg_list    		IN  VARCHAR2,
    p_document_id      		IN  NUMBER,
    p_document_type    		IN  VARCHAR2,
    p_article_id       		IN  NUMBER,
    p_effectivity_date 		IN  DATE,
    x_article_id       		OUT NOCOPY NUMBER,
    x_article_version_id 	OUT NOCOPY NUMBER,
    x_article_title		OUT NOCOPY VARCHAR2,
    x_article_description	OUT NOCOPY  VARCHAR2,
    x_doc_lib           	OUT NOCOPY VARCHAR2,
    x_scn_heading		OUT NOCOPY VARCHAR2,
    x_return_status    		OUT NOCOPY VARCHAR2,
    x_msg_count        		OUT NOCOPY NUMBER,
    x_msg_data         		OUT NOCOPY VARCHAR2);

PROCEDURE populate_terms_deviations_tbl(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_document_id                  IN NUMBER,
    p_document_type                IN VARCHAR2,
    p_sequence_id 	  	   IN NUMBER,
    p_config_header_id             IN NUMBER,
    p_config_rev_nbr               IN NUMBER,
    p_rule_qst_values_tbl	   IN dev_rule_qst_values_tbl_type,
    p_rule_var_values_tbl	   IN dev_rule_var_values_tbl_type,
    p_clause_tbl	           IN expert_articles_tbl_type,
    p_mode			   IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2);

PROCEDURE get_expert_results(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_document_id                  IN NUMBER,
    p_document_type                IN VARCHAR2,
    p_config_header_id             IN NUMBER,
    p_config_rev_nbr               IN NUMBER,
    p_mode			   IN VARCHAR2,
    p_sequence_id 	  	   IN OUT NOCOPY NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2);

-- Rajendra
PROCEDURE is_template_applied (
    p_api_version               IN            NUMBER,
    p_init_msg_list             IN            VARCHAR2,
    p_document_type             IN            VARCHAR2,
    p_document_id               IN            NUMBER,
    p_template_id               IN            NUMBER,
    x_template_applied_yn       OUT  NOCOPY   VARCHAR2,
    x_return_status             OUT  NOCOPY   VARCHAR2,
    x_msg_count                 OUT  NOCOPY   NUMBER,
    x_msg_data                  OUT  NOCOPY   VARCHAR2
);

PROCEDURE get_current_config_dtls (
    p_api_version               IN            NUMBER,
    p_init_msg_list             IN            VARCHAR2,
    p_document_type             IN            VARCHAR2,
    p_document_id               IN            NUMBER,
    p_template_id               IN            NUMBER,
    x_expert_enabled_yn         OUT  NOCOPY   VARCHAR2,
    x_config_header_id          OUT  NOCOPY   NUMBER,
    x_config_rev_nbr            OUT  NOCOPY   NUMBER,
    x_return_status             OUT  NOCOPY   VARCHAR2,
    x_msg_count                 OUT  NOCOPY   NUMBER,
    x_msg_data                  OUT  NOCOPY   VARCHAR2
);

FUNCTION check_rule_type_has_questions (
    p_template_id   IN NUMBER,
    p_rule_type IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE contract_expert_bv(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_document_id                  IN NUMBER,
    p_document_type                IN VARCHAR2,
    p_bv_mode                      IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2);

FUNCTION is_config_complete(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER
 ) RETURN VARCHAR2;

FUNCTION has_unanswered_questions(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER,
    p_rule_type             IN  VARCHAR2
 ) RETURN VARCHAR2;

PROCEDURE update_document(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_document_id                  IN NUMBER,
    p_document_type                IN VARCHAR2,
    p_doc_update_mode              IN VARCHAR2,
    x_count_articles_dropped       OUT NOCOPY NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_lock_xprt_yn            IN VARCHAR2 := 'N' -- Conc Mod changes
   ,p_lock_terms_yn           IN VARCHAR2 := 'N' -- Conc Mod changes
);

END OKC_XPRT_UTIL_PVT ;

/
