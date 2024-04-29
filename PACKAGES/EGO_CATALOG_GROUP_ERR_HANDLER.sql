--------------------------------------------------------
--  DDL for Package EGO_CATALOG_GROUP_ERR_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_CATALOG_GROUP_ERR_HANDLER" AUTHID CURRENT_USER AS
/* $Header: EGOCGEHS.pls 115.1 2002/12/12 19:20:50 rfarook noship $ */
    G_PKG_NAME      CONSTANT VARCHAR2(30)   := 'EGO_Catalog_Group_Err_Handler';

     PROCEDURE Log_Error
    (  p_Mesg_Token_tbl          IN  Error_Handler.Mesg_Token_Tbl_Type
                                     := Error_Handler.G_MISS_MESG_TOKEN_TBL
     , p_error_status            IN  VARCHAR2
     , p_error_scope             IN  VARCHAR2 := NULL
     , p_other_message           IN  VARCHAR2 := NULL
     , p_other_mesg_appid        IN  VARCHAR2 := 'EGO'
     , p_other_status            IN  VARCHAR2 := NULL
     , p_other_token_tbl         IN  Error_Handler.Token_Tbl_Type
                                     := Error_Handler.G_MISS_TOKEN_TBL
     , p_error_level             IN  NUMBER
     , p_entity_index            IN  NUMBER := 1  -- := NULL
    );

END EGO_Catalog_Group_Err_Handler;

 

/
