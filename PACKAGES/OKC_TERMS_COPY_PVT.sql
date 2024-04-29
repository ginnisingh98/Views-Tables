--------------------------------------------------------
--  DDL for Package OKC_TERMS_COPY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMS_COPY_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVDCPS.pls 120.1.12010000.4 2011/12/09 13:46:09 serukull ship $ */

procedure copy_tc(
                  p_api_version             IN	NUMBER,
                  p_init_msg_list	    IN	VARCHAR2 default FND_API.G_FALSE,
                  p_commit	            IN	VARCHAR2 default fnd_api.g_false,
                  p_source_doc_type	    IN	VARCHAR2,
                  p_source_doc_id	    IN	NUMBER,
                  p_target_doc_type	    IN	OUT NOCOPY VARCHAR2,
                  p_target_doc_id	    IN	OUT NOCOPY NUMBER,
                  p_keep_version	    IN	VARCHAR2 default 'N',
                  p_article_effective_date  IN	DATE,
                  p_target_template_rec	    IN	OKC_TERMS_TEMPLATES_PVT.template_rec_type,
                  p_document_number	    IN	VARCHAR2 default  Null,
                  p_retain_deliverable      IN  VARCHAR2 default 'N',
                  p_allow_duplicates        IN  VARCHAR2 default 'N',
                  p_keep_orig_ref           IN  VARCHAR2 default 'N',
                  x_return_status	    OUT	NOCOPY VARCHAR2,
                  x_msg_data	            OUT	NOCOPY VARCHAR2,
                  x_msg_count	            OUT	NOCOPY NUMBER,
                  p_copy_abstract_yn        IN VARCHAR default 'N',
		  p_copy_for_amendment      IN VARCHAR2 default 'N',
		          p_contract_admin_id IN NUMBER := NULL,
		          p_legal_contact_id IN NUMBER := NULL,
                  p_retain_clauses     IN  VARCHAR2 default 'N'           --kkolukul: CLM Changes
                  , p_retain_lock_terms_yn  IN  VARCHAR2 := 'N' -- conc Mod changes start
                  ,p_retain_lock_xprt_yn         IN VARCHAR2 := 'N' -- conc Mod changes start
                        );


procedure copy_archived_doc(
                        p_api_version             IN	NUMBER,
                        p_init_msg_list		  IN	VARCHAR2 default FND_API.G_FALSE,
                        p_commit	          IN	VARCHAR2 default fnd_api.g_false,
                        p_source_doc_type	  IN	VARCHAR2,
                        p_source_doc_id	          IN	NUMBER,
                        p_source_version_number   IN	NUMBER,
                        p_target_doc_type	  IN	VARCHAR2,
                        p_target_doc_id	          IN	NUMBER,
                        p_document_number	  IN	VARCHAR2 default  Null,
                        p_allow_duplicates        IN  VARCHAR2 default 'N',
                        x_return_status	          OUT	NOCOPY VARCHAR2,
                        x_msg_data	          OUT	NOCOPY VARCHAR2,
                        x_msg_count	          OUT	NOCOPY NUMBER
                        );

FUNCTION get_variable_value_id (
 p_cat_id               IN      NUMBER,
 p_variable_code        IN      VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_variable_value (
 p_cat_id               IN      NUMBER,
 p_variable_code        IN      VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_orig_var_val (
 p_cat_id               IN      NUMBER,
 p_variable_code        IN      VARCHAR2,
 p_source_doc_id        IN      NUMBER,
 p_source_doc_type      IN      VARCHAR2,
 p_value_type           IN      VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_orig_var_val_xml (
 p_cat_id               IN      NUMBER,
 p_variable_code        IN      VARCHAR2,
 p_source_doc_id        IN      NUMBER,
 p_source_doc_type      IN      VARCHAR2,
 p_value_type           IN      VARCHAR2)
RETURN CLOB;

END OKC_TERMS_COPY_PVT;

/
