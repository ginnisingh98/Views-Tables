--------------------------------------------------------
--  DDL for Package CSTPALBR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPALBR" AUTHID CURRENT_USER AS
/* $Header: CSTALBRS.pls 120.1 2006/02/13 04:09:11 ggautam noship $ */
/*-----------------------------------------------------------------------
TYPE cst_ae_txn_rec_type IS RECORD (
	event_type_id			VARCHAR2(30),
	txn_action_id			NUMBER(15),
	txn_src_type_id			NUMBER(15),
        txn_src_id			NUMBER(15),
	txn_type_id			NUMBER(15),
	txn_type_flag			VARCHAR2(3),
	--wip_txn_type			NUMBER(15),
	txn_type			VARCHAR2(30),
	transaction_id			NUMBER(15),
	inventory_item_id		NUMBER(15),
	set_of_books_id			NUMBER(15),
	legal_entity_id			NUMBER(15),
	cost_type_id			NUMBER(15),
	cost_group_id			NUMBER(15),
	xfer_cost_group_id		NUMBER(15),
	primary_quantity		NUMBER,
	subinventory_code		VARCHAR2(10),
	xfer_organization_id		NUMBER(15),
	xfer_subinventory		VARCHAR2(10),
	xfer_transaction_id		NUMBER(15),
	dist_acct_id			NUMBER(15),
	currency_code			VARCHAR2(15),
	currency_conv_type		VARCHAR2(15),
	currency_conv_date		DATE,
	currency_conv_rate		NUMBER,
	ae_category			varchar2(15),
	accounting_period_id		NUMBER(15),
	accounting_period_name		VARCHAR2(15),
	accounting_date			DATE,
	organization_id			NUMBER(15),
	mat_account			NUMBER(15),
	mat_ovhd_account		NUMBER(15),
	res_account			NUMBER(15),
	osp_account			NUMBER(15),
	ovhd_account			NUMBER(15),
	flow_schedule			NUMBER(15),
	exp_item			NUMBER,
	category_id			NUMBER	,
	source_table			VARCHAR2(15),
	source_id			NUMBER,
	description			VARCHAR2(240),
        wip_entity_type                 NUMBER,
        line_id				NUMBER
);

TYPE cst_ae_line_rec_type IS RECORD (
	ae_line_type			NUMBER(5),
	description			VARCHAR2(240),
	account				NUMBER(15),
	currency_code			VARCHAR2(15),
	currency_conv_type		VARCHAR2(15),
	currency_conv_date		DATE,
	currency_conv_rate		NUMBER,
	entered_dr			NUMBER,
	entered_cr			NUMBER,
	accounted_dr			NUMBER,
	accounted_cr			NUMBER,
	source_table			VARCHAR2(30),
	source_id			NUMBER,
	rate_or_amount			NUMBER,
	basis_type			NUMBER,
	resource_id			NUMBER,
	cost_element_id			NUMBER,
	activity_id			NUMBER,
	repetitive_schedule_id		NUMBER,
	overhead_basis_factor		NUMBER,
	basis_resource_id		NUMBER,
	transaction_value		NUMBER,
	reference1			VARCHAR2(240),
	reference2			VARCHAR2(240),
	reference3			VARCHAR2(240),
	reference4			VARCHAR2(240),
	reference5			VARCHAR2(240),
	reference6			VARCHAR2(240),
	reference7			VARCHAR2(240),
	reference8			VARCHAR2(240),
	reference9			VARCHAR2(240),
	reference10			VARCHAR2(240)
	);

TYPE cst_ae_curr_rec_type IS RECORD (
	pri_currency			VARCHAR2(15),
	alt_currency			VARCHAR2(15),
	currency_conv_type		VARCHAR2(15),
	currency_conv_date		DATE,
	currency_conv_rate		NUMBER
);

TYPE cst_ae_acct_rec_type IS RECORD (
	account				NUMBER,
	mat_account			NUMBER,
	mat_ovhd_account		NUMBER,
	res_account			NUMBER,
	osp_account			NUMBER,
	ovhd_account			NUMBER
);

TYPE cst_ae_err_rec_type IS RECORD (
	l_err_num         		NUMBER,
	l_err_code        		VARCHAR2(240),
	l_err_msg       		VARCHAR2(240)
);

TYPE cst_ae_par_rec_type IS RECORD (
	legal_entity 			NUMBER,
	cost_type_id			NUMBER,
	cost_group_id			NUMBER,
	period_id			NUMBER
);


TYPE cst_ae_line_tbl_type IS TABLE OF cst_ae_line_rec_type;


TYPE cst_ae_lib_param_type IS RECORD (
	i_name          		VARCHAR2(50),
	i_num_value    			NUMBER,
	i_vchar_value  			VARCHAR2(500),
	i_char_value   			CHAR(500),
	i_date_value   			DATE,
	i_datatype			NUMBER,
	i_inout				NUMBER
);

TYPE cst_ae_lib_par_tbl_type IS TABLE OF cst_ae_lib_param_type;
-----------------------------------------------------------------------*/
PROCEDURE dyn_proc_call (
	i_proc_name     	IN      VARCHAR2,
	i_legal_entity  	IN      NUMBER,
	i_cost_type    		IN      NUMBER,
	i_cost_group   		IN      NUMBER,
	i_period_id    		IN      NUMBER,
	i_transaction_id        IN      NUMBER,
	i_event_type_id 	IN      VARCHAR2,
	i_txn_type_flag         IN      VARCHAR2, -- 4586534
	o_err_num       	OUT NOCOPY     NUMBER,
	o_err_code     		OUT NOCOPY     VARCHAR2,
	o_err_msg      		OUT NOCOPY     VARCHAR2
);
/*-------------------------------------------------------------------
PROCEDURE run_dyn_proc (
	i_num_params    	IN      NUMBER,
	i_proc_name     	IN      VARCHAR2,
	io_parameters  		IN OUT  CSTPALTY.CST_AE_LIB_PAR_TBL_TYPE,
	o_err			OUT	NUMBER
);
----------------------------------------------------------------------*/

PROCEDURE create_acct_entry (
	i_acct_lib_id		IN	NUMBER,
	i_legal_entity		IN	NUMBER,
	i_cost_type_id		IN	NUMBER,
	i_cost_group_id		IN	NUMBER,
	i_period_id		IN	NUMBER,
	i_mode			IN	NUMBER,
	o_err_num		OUT NOCOPY	NUMBER,
	o_err_code		OUT NOCOPY	VARCHAR2,
	o_err_msg		OUT NOCOPY	VARCHAR2
);

PROCEDURE insert_ae_lines (
	i_ae_txn_rec		IN	CSTPALTY.CST_AE_TXN_REC_TYPE,
	i_ae_line_rec_tbl	IN	CSTPALTY.CST_AE_LINE_TBL_TYPE,
	o_err_rec		OUT NOCOPY	CSTPALTY.CST_AE_ERR_REC_TYPE
);


END CSTPALBR;


 

/
