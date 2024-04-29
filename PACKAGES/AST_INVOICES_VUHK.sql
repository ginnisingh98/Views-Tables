--------------------------------------------------------
--  DDL for Package AST_INVOICES_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_INVOICES_VUHK" AUTHID CURRENT_USER AS
/* $Header: astvivvs.pls 115.3 2002/02/06 11:44:04 pkm ship   $ */

PROCEDURE Get_Invoices_PRE(
            p_api_version		IN NUMBER := 1.0,
            p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
            p_commit			IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
            x_return_status		OUT VARCHAR2,
            x_msg_count			OUT NUMBER,
            x_msg_data			OUT VARCHAR2,
		  p_transaction_ids	     IN  VARCHAR2);

PROCEDURE Get_Invoices_POST(
            p_api_version			IN NUMBER := 1.0,
            p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
            p_commit				IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
            x_return_status			OUT VARCHAR2,
            x_msg_count				OUT NUMBER,
            x_msg_data				OUT VARCHAR2,
		  p_transaction_ids	          IN  VARCHAR2);


END ast_INVOICES_VUHK;

 

/
