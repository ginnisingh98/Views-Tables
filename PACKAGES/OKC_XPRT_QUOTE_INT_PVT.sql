--------------------------------------------------------
--  DDL for Package OKC_XPRT_QUOTE_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XPRT_QUOTE_INT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVXQUOTEINTS.pls 120.2 2005/12/14 16:13:56 arsundar noship $ */

SUBTYPE sys_var_value_tbl_type IS OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type;
TYPE line_var_tbl_type       IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

G_QUOTE_DOC_TYPE       CHAR(5) := 'QUOTE';  --global constant for a Quote

  PROCEDURE Get_clause_Variable_Values (
    p_api_version               IN            NUMBER,
    p_init_msg_list             IN            VARCHAR2,
    x_return_status             OUT  NOCOPY   VARCHAR2,
    x_msg_count                 OUT  NOCOPY   NUMBER,
    x_msg_data                  OUT  NOCOPY   VARCHAR2,
    p_doc_id                    IN            NUMBER,
    p_sys_var_value_tbl         IN OUT NOCOPY OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type
  );

  PROCEDURE Get_clause_Variable_Values (
    p_api_version               IN            NUMBER,
    p_init_msg_list             IN            VARCHAR2,
    x_return_status             OUT  NOCOPY   VARCHAR2,
    x_msg_count                 OUT  NOCOPY   NUMBER,
    x_msg_data                  OUT  NOCOPY   VARCHAR2,
    p_doc_id                    IN            NUMBER,
    p_variables_tbl             IN            OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type,
    x_line_var_value_tbl        OUT  NOCOPY   OKC_TERMS_UTIL_GRP.item_dtl_tbl
  );

  PROCEDURE Get_Line_Variable_Values (
    p_api_version               IN            NUMBER,
    p_init_msg_list             IN            VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_doc_id                    IN            NUMBER,
    x_return_status             OUT  NOCOPY   VARCHAR2,
    x_msg_count                 OUT  NOCOPY   NUMBER,
    x_msg_data                  OUT  NOCOPY   VARCHAR2,
    x_line_sys_var_value_tbl    OUT  NOCOPY   OKC_XPRT_XRULE_VALUES_PVT.line_sys_var_value_tbl_type,
    x_line_count                OUT  NOCOPY   NUMBER,
    x_line_variables_count      OUT  NOCOPY   NUMBER
  );


END OKC_XPRT_QUOTE_INT_PVT;

 

/
