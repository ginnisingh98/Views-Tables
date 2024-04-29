--------------------------------------------------------
--  DDL for Package OKC_XPRT_REP_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XPRT_REP_INT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVXREPINTS.pls 120.0 2008/03/28 06:31:44 kkolukul noship $ */

TYPE line_var_tbl_type       IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;


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

   END OKC_XPRT_REP_INT_PVT;

/
