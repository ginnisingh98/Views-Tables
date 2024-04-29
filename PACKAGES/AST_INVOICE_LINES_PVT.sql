--------------------------------------------------------
--  DDL for Package AST_INVOICE_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_INVOICE_LINES_PVT" AUTHID CURRENT_USER AS
/* $Header: astvinls.pls 115.3 2002/02/06 11:21:07 pkm ship      $ */

	TYPE line_id_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
	TYPE line_number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
	TYPE item_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
	TYPE units_tbl_type IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
	TYPE quantity_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
	TYPE price_per_unit_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
	TYPE original_amount_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--Removed By JYPark	TYPE dispute_quantity_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--Removed By JYPark	TYPE dispute_amount_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

	PROCEDURE Get_Invoice_Lines(
		p_api_version		IN  NUMBER,
		p_init_msg_list		IN  VARCHAR2 := FND_API.G_FALSE,
		p_commit		IN  VARCHAR2 := FND_API.G_FALSE,
		p_validation_level	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
		x_return_status		OUT VARCHAR2,
		x_msg_count		OUT NUMBER,
		x_msg_data		OUT VARCHAR2,
		p_invoice_id		IN  NUMBER,
		x_line_id_t		OUT line_id_tbl_type,
		x_line_number_t		OUT line_number_tbl_type,
		x_item_t		OUT item_tbl_type,
		x_units_t		OUT units_tbl_type,
		x_quantity_t		OUT quantity_tbl_type,
		x_price_per_unit_t	OUT price_per_unit_tbl_type,
		x_original_amount_t	OUT original_amount_tbl_type
--Removed By JYPark		x_dispute_quantity_t	OUT dispute_quantity_tbl_type,
--Removed By JYPark		x_dispute_amount_t	OUT dispute_amount_tbl_type
            );
END;

 

/
