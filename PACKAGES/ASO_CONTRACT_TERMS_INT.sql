--------------------------------------------------------
--  DDL for Package ASO_CONTRACT_TERMS_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_CONTRACT_TERMS_INT" AUTHID CURRENT_USER AS
/* $Header: asoiktcs.pls 120.1 2005/06/29 12:33:37 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_Contract_Terms_INT
-- Purpose          :
-- History          :
--    10-29-2002 hyang - created
-- NOTE             :
-- End of Comments



  PROCEDURE Get_Article_Variable_Values (
    p_api_version               IN        NUMBER,
    p_init_msg_list             IN        VARCHAR2 := fnd_api.g_false,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    p_doc_id                    IN        NUMBER,
    p_sys_var_value_tbl         IN OUT NOCOPY /* file.sql.39 change */    OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type
  );

  PROCEDURE Get_Line_Variable_Values (
    p_api_version               IN        NUMBER,
    p_init_msg_list             IN        VARCHAR2 := fnd_api.g_false,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    p_doc_id                    IN        NUMBER,
    p_variables_tbl             IN        OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type,
    x_line_var_value_tbl        OUT NOCOPY /* file.sql.39 change */       OKC_TERMS_UTIL_GRP.item_dtl_tbl
  );

  FUNCTION OK_To_Commit (
    p_api_version               IN        NUMBER,
    p_init_msg_list             IN        VARCHAR2 := fnd_api.g_false,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    p_doc_id                    IN        NUMBER,
    p_doc_type                  IN        VARCHAR2 := 'QUOTE',
    p_validation_string         IN        VARCHAR2
  ) RETURN VARCHAR2 ;

END ASO_Contract_Terms_INT;

 

/
