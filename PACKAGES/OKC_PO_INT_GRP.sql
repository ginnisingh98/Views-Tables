--------------------------------------------------------
--  DDL for Package OKC_PO_INT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_PO_INT_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGIPOS.pls 120.0.12010000.2 2010/03/04 13:35:45 nvvaidya ship $ */


SUBTYPE sys_var_value_tbl_type IS OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type;
SUBTYPE category_tbl_type IS OKC_TERMS_UTIL_GRP.category_tbl_type;
SUBTYPE item_tbl_type IS OKC_TERMS_UTIL_GRP.item_tbl_type;
SUBTYPE sys_var_tbl_type IS  OKC_TERMS_UTIL_GRP.variable_code_tbl_type;

Procedure get_article_variable_values(
                        p_api_version             IN	Number,
                        p_init_msg_list		  IN	Varchar2 default FND_API.G_FALSE,
                        p_doc_type	          IN	Varchar2,
                        p_doc_id	          IN	Number,
                        p_sys_var_value_tbl       IN OUT NOCOPY sys_var_value_tbl_type,
                        x_return_status	          OUT	NOCOPY Varchar2,
                        x_msg_data	          OUT	NOCOPY Varchar2,
                        x_msg_count	          OUT	NOCOPY Number
                        );

Procedure get_changed_variables(
                        p_api_version             IN	Number,
                        p_init_msg_list		  IN	Varchar2 default FND_API.G_FALSE,
                        p_doc_type	          IN	Varchar2,
                        p_doc_id	          IN	Number,
                        p_sys_var_tbl            IN OUT  NOCOPY sys_var_tbl_type,
                        x_return_status	          OUT	NOCOPY Varchar2,
                        x_msg_data	          OUT	NOCOPY Varchar2,
                        x_msg_count	          OUT	NOCOPY Number
                        );

Procedure get_item_dtl_for_expert(
                        p_api_version             IN	Number,
                        p_init_msg_list		  IN	Varchar2 default FND_API.G_FALSE,
                        p_doc_type	          IN	Varchar2,
                        p_doc_id	          IN	Number,
                        x_category_tbl            OUT   NOCOPY item_tbl_type,
                        x_item_tbl                OUT   NOCOPY item_tbl_type,
                        x_return_status	          OUT	NOCOPY Varchar2,
                        x_msg_data	          OUT	NOCOPY Varchar2,
                        x_msg_count	          OUT	NOCOPY Number
                        );

Function ok_to_commit   (
                        p_api_version             IN	Number,
                        p_init_msg_list		  IN	Varchar2 default FND_API.G_FALSE,
                        p_doc_type	          IN	Varchar2,
                        p_doc_id	          IN	Number,
                        p_tmpl_change             IN    Varchar2 default NULL,
                        p_validation_string       IN    Varchar2 default NULL,
                        x_return_status	          OUT	NOCOPY Varchar2,
                        x_msg_data	          OUT	NOCOPY Varchar2,
                        x_msg_count	          OUT	NOCOPY Number
                        )
Return Varchar2;

PROCEDURE Get_Last_Signed_Revision (
                          p_api_version            IN NUMBER,
                          p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                          p_doc_type               IN VARCHAR2,
                          p_doc_id                 IN NUMBER,
                          p_revision_num           IN NUMBER,
                          x_signed_revision_num    OUT NOCOPY NUMBER,
                          x_return_status          OUT NOCOPY VARCHAR2,
                          x_msg_data               OUT NOCOPY VARCHAR2,
                          x_msg_count              OUT NOCOPY NUMBER);

END OKC_PO_INT_GRP;

/
