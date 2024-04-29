--------------------------------------------------------
--  DDL for Package Body AST_INVOICE_LINES_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_INVOICE_LINES_VUHK" AS
/* $Header: astvilvb.pls 115.3 2002/02/06 11:21:00 pkm ship      $ */

PROCEDURE Get_Invoice_Lines_PRE(
            p_api_version		IN NUMBER := 1.0,
            p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
            p_commit			IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level  IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
            x_return_status		OUT VARCHAR2,
            x_msg_count			OUT NUMBER,
            x_msg_data			OUT VARCHAR2,
			p_invoice_id            IN  NUMBER)
AS

BEGIN
	/* Vertical to add the customization procedures here - for pre processing */
	null;
END;

PROCEDURE Get_Invoice_Lines_POST(
            p_api_version			IN NUMBER := 1.0,
            p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
            p_commit				IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
            x_return_status			OUT VARCHAR2,
            x_msg_count				OUT NUMBER,
            x_msg_data				OUT VARCHAR2,
			p_invoice_id            IN  NUMBER)
AS

BEGIN
	/* Vertical to add the customization procedures here - for post processing */
	null;
END;



end ast_INVOICE_LINES_VUHK;

/
