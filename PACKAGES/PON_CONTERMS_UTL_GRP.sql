--------------------------------------------------------
--  DDL for Package PON_CONTERMS_UTL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_CONTERMS_UTL_GRP" AUTHID CURRENT_USER as
/* $Header: PONCTDVS.pls 120.0 2005/06/01 16:39:09 appldev noship $ */

FUNCTION is_contracts_installed RETURN VARCHAR2;

FUNCTION get_contracts_document_type(
		p_doctype_id	IN	NUMBER,
		p_is_response	IN	VARCHAR2)
	RETURN VARCHAR2;

PROCEDURE ok_to_commit(
		p_api_version            IN NUMBER,
		p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_doctype_id		 IN VARCHAR2,
		p_doc_id                 IN NUMBER,
		x_update_allowed         OUT NOCOPY VARCHAR2,
		x_return_status          OUT NOCOPY VARCHAR2,
		x_msg_data               OUT NOCOPY VARCHAR2,
		x_msg_count              OUT NOCOPY NUMBER
);

PROCEDURE get_article_variable_values(
		p_api_version            IN NUMBER,
		p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_doctype_id		 IN VARCHAR2,
		p_doc_id                 IN NUMBER,
		p_sys_var_value_tbl	 IN OUT NOCOPY OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type,
		x_return_status          OUT NOCOPY VARCHAR2,
		x_msg_data               OUT NOCOPY VARCHAR2,
		x_msg_count              OUT NOCOPY NUMBER
);

PROCEDURE get_changed_variables(
		p_api_version            IN NUMBER,
		p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_doctype_id		 IN VARCHAR2,
		p_doc_id                 IN NUMBER,
		p_sys_var_tbl	 	 IN OUT NOCOPY OKC_TERMS_UTIL_GRP.variable_code_tbl_type,
		x_return_status          OUT NOCOPY VARCHAR2,
		x_msg_data               OUT NOCOPY VARCHAR2,
		x_msg_count              OUT NOCOPY NUMBER
);

PROCEDURE get_item_category(
		p_api_version            IN NUMBER,
		p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_doctype_id             IN VARCHAR2,
		p_doc_id                 IN NUMBER,
		x_category_tbl           OUT NOCOPY OKC_TERMS_UTIL_GRP.item_tbl_type,
		x_item_tbl               OUT NOCOPY OKC_TERMS_UTIL_GRP.item_tbl_type,
		x_return_status          OUT NOCOPY VARCHAR2,
		x_msg_data               OUT NOCOPY VARCHAR2,
		x_msg_count              OUT NOCOPY NUMBER
);

END PON_CONTERMS_UTL_GRP;

 

/
