--------------------------------------------------------
--  DDL for Package INV_LABEL_PVT10
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LABEL_PVT10" AUTHID CURRENT_USER AS
/* $Header: INVLA10S.pls 115.3 2002/12/01 01:57:03 rbande ship $ */
G_PKG_NAME	CONSTANT VARCHAR2(50) := 'INV_LABEL_PVT10';

PROCEDURE get_variable_data(
        x_variable_content      OUT NOCOPY INV_LABEL.label_tbl_type
,	x_msg_count			OUT NOCOPY NUMBER
,	x_msg_data			OUT NOCOPY VARCHAR2
,	x_return_status		OUT NOCOPY VARCHAR2
,	p_label_type_info	IN INV_LABEL.label_type_rec DEFAULT NULL
,	p_transaction_id	IN NUMBER DEFAULT NULL
,	p_input_param		IN MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE DEFAULT NULL
,       p_transaction_identifier IN NUMBER DEFAULT 0
);
END INV_LABEL_PVT10;

 

/
