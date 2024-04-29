--------------------------------------------------------
--  DDL for Package Body AST_INVOICES_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_INVOICES_VUHK" AS
/* $Header: astvivvb.pls 115.3 2002/02/06 11:44:01 pkm ship   $ */

PROCEDURE Get_Invoices_PRE(
            p_api_version		IN NUMBER := 1.0,
            p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
            p_commit			IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
            x_return_status		OUT VARCHAR2,
            x_msg_count			OUT NUMBER,
            x_msg_data			OUT VARCHAR2,
		  p_transaction_ids	     IN  VARCHAR2)
AS

BEGIN
	/* Vertical to add the customization procedures here - for pre processing */
	null;
END;

PROCEDURE Get_Invoices_POST(
            p_api_version			IN NUMBER := 1.0,
            p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
            p_commit				IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
            x_return_status			OUT VARCHAR2,
            x_msg_count				OUT NUMBER,
            x_msg_data				OUT VARCHAR2,
		  p_transaction_ids	          IN  VARCHAR2)
AS

BEGIN
	/* Vertical to add the customization procedures here - for post processing */
	null;
END;



end ast_INVOICES_VUHK;

/
