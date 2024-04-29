--------------------------------------------------------
--  DDL for Package INV_LABEL_PVT9
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LABEL_PVT9" AUTHID CURRENT_USER AS
/* $Header: INVLAP9S.pls 120.0.12010000.1 2008/07/24 01:37:54 appldev ship $ */
G_PKG_NAME	CONSTANT VARCHAR2(50) := 'INV_LABEL_PVT9';

PROCEDURE get_variable_data(
	x_variable_content 	OUT NOCOPY LONG
,	x_msg_count			OUT NOCOPY NUMBER
,	x_msg_data			OUT NOCOPY VARCHAR2
,	x_return_status		OUT NOCOPY VARCHAR2
,	p_label_type_info	IN INV_LABEL.label_type_rec DEFAULT NULL
,	p_transaction_id	IN NUMBER DEFAULT NULL
,	p_input_param		IN MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE DEFAULT NULL
,  p_transaction_identifier IN NUMBER DEFAULT 0
);

PROCEDURE get_variable_data(
   x_variable_content   OUT NOCOPY INV_LABEL.label_tbl_type
,  x_msg_count       OUT NOCOPY NUMBER
,  x_msg_data        OUT NOCOPY VARCHAR2
,  x_return_status      OUT NOCOPY VARCHAR2
,  p_label_type_info IN INV_LABEL.label_type_rec DEFAULT NULL
,  p_transaction_id  IN NUMBER DEFAULT NULL
,  p_input_param     IN MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE DEFAULT NULL
,  p_transaction_identifier IN NUMBER DEFAULT 0
);

END INV_LABEL_PVT9;

/
