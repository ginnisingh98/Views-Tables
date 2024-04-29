--------------------------------------------------------
--  DDL for Package AST_INVOICE_LINES_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_INVOICE_LINES_CUHK" AUTHID CURRENT_USER AS
/* $Header: astvilus.pls 115.3 2002/02/06 11:20:58 pkm ship      $ */

PROCEDURE Get_Invoice_Lines_PRE(
            p_api_version		IN NUMBER := 1.0,
            p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
            p_commit			IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level  IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
            x_return_status		OUT VARCHAR2,
            x_msg_count			OUT NUMBER,
            x_msg_data			OUT VARCHAR2,
			p_invoice_id            IN  NUMBER);

PROCEDURE Get_Invoice_Lines_POST(
            p_api_version			IN NUMBER := 1.0,
            p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
            p_commit				IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
            x_return_status			OUT VARCHAR2,
            x_msg_count				OUT NUMBER,
            x_msg_data				OUT VARCHAR2,
			p_invoice_id            IN  NUMBER);

FUNCTION OK_TO_LAUNCH_WORKFLOW(
            p_api_version IN NUMBER := 1.0,
            p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
            p_commit IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level IN NUMBER :=
            FND_API.G_VALID_LEVEL_FULL,
            x_return_status OUT VARCHAR2,
            x_msg_count OUT NUMBER,
            x_msg_data OUT VARCHAR2) RETURN BOOLEAN;


FUNCTION OK_TO_GENERATE_MSG(
            p_api_version IN NUMBER := 1.0,
            p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
            p_commit IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level IN NUMBER :=
            FND_API.G_VALID_LEVEL_FULL,
            x_return_status OUT VARCHAR2,
            x_msg_count OUT NUMBER,
            x_msg_data OUT VARCHAR2) RETURN BOOLEAN;

END ast_INVOICE_LINES_CUHK;

 

/
