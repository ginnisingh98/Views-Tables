--------------------------------------------------------
--  DDL for Package OKC_XPRT_OM_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XPRT_OM_INT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVXOMINTS.pls 120.2 2005/12/14 16:15:23 arsundar noship $ */

TYPE line_var_tbl_type       IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

G_BSA_DOC_TYPE         CHAR(1) := 'B';      --global constant for document type of Blanket Sales Agreement.
G_SO_DOC_TYPE          CHAR(1) := 'O';      --global constant for document type of Sales Order

PROCEDURE get_clause_variable_values
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2,

   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   p_sys_var_value_tbl          IN OUT NOCOPY OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2 );


--this overloaded signature is called from the contract expert
PROCEDURE get_clause_variable_values
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2,

   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   p_line_var_tbl               IN  line_var_tbl_type,

   x_line_var_value_tbl         OUT NOCOPY OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2 );

PROCEDURE Get_Line_Variable_Values (
   p_api_version               IN            NUMBER,
   p_init_msg_list             IN            VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_doc_type                  IN            VARCHAR2,
   p_doc_id                    IN            NUMBER,
   x_return_status             OUT  NOCOPY   VARCHAR2,
   x_msg_count                 OUT  NOCOPY   NUMBER,
   x_msg_data                  OUT  NOCOPY   VARCHAR2,
   x_line_sys_var_value_tbl    OUT  NOCOPY   OKC_XPRT_XRULE_VALUES_PVT.line_sys_var_value_tbl_type,
   x_line_count                OUT  NOCOPY   NUMBER,
   x_line_variables_count      OUT  NOCOPY   NUMBER
  );


END OKC_XPRT_OM_INT_PVT;

 

/
