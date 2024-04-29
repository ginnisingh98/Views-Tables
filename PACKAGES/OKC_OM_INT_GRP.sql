--------------------------------------------------------
--  DDL for Package OKC_OM_INT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_OM_INT_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGIOMS.pls 120.0 2005/05/25 23:02:00 appldev noship $ */

SUBTYPE sys_var_value_tbl_type IS OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type;
SUBTYPE item_tbl_type IS OKC_TERMS_UTIL_GRP.item_tbl_type;

Procedure get_article_variable_values(
                        p_api_version             IN	Number,
                        p_init_msg_list		  IN	Varchar2,
                        p_doc_type	          IN	Varchar2,
                        p_doc_id	          IN	Number,
                        p_sys_var_value_tbl       IN OUT NOCOPY sys_var_value_tbl_type,
                        x_return_status	          OUT	NOCOPY Varchar2,
                        x_msg_data	          OUT	NOCOPY Varchar2,
                        x_msg_count	          OUT	NOCOPY Number
                        );

Function ok_to_commit   (
                        p_api_version             IN    Number,
                        p_init_msg_list           IN    Varchar2,
                        p_doc_id                  IN    Number,
                        p_tmpl_change             IN    Varchar2,
                        p_validation_string       IN    Varchar2,
                        x_return_status           OUT   NOCOPY Varchar2,
                        x_msg_data                OUT   NOCOPY Varchar2,
                        x_msg_count               OUT   NOCOPY Number
                        )
Return Varchar2;

Procedure get_item_dtl_for_expert(
                        p_api_version             IN    Number,
                        p_init_msg_list           IN    Varchar2,
                        p_doc_type                IN    Varchar2,
                        p_doc_id                  IN    Number,
                        x_category_tbl            OUT   NOCOPY item_tbl_type,
                        x_item_tbl                OUT   NOCOPY item_tbl_type,
                        x_return_status           OUT   NOCOPY Varchar2,
                        x_msg_data                OUT   NOCOPY Varchar2,
                        x_msg_count               OUT   NOCOPY Number
                        );

END OKC_OM_INT_GRP;

 

/
