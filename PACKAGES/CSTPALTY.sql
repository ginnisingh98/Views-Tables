--------------------------------------------------------
--  DDL for Package CSTPALTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPALTY" AUTHID CURRENT_USER AS
/* $Header: CSTALTYS.pls 120.2.12010000.3 2008/11/25 09:01:12 anjha ship $ */

TYPE cst_ae_txn_rec_type IS RECORD (
	event_type_id			VARCHAR2(30),
	txn_action_id			NUMBER(15),
	txn_src_type_id			NUMBER(15),
        txn_src_id			NUMBER(15),
	txn_type_id			NUMBER(15),
	txn_type_flag			VARCHAR2(10),
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
	currency_conv_type		VARCHAR2(30),
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
-- Retro Changes -------------------------------------------
        credit_account                  NUMBER DEFAULT NULL,
        unit_price                      NUMBER DEFAULT NULL,
        prior_unit_price                NUMBER DEFAULT NULL,
        po_distribution_id              NUMBER DEFAULT NULL,
------------------------------------------------------------
	flow_schedule			NUMBER(15),
	exp_item			NUMBER,
	category_id			NUMBER	,
	source_table			VARCHAR2(15),
	source_id			NUMBER,
	description			VARCHAR2(240),
        wip_entity_type                 NUMBER,
        line_id				NUMBER,
        encum_amount			NUMBER,
	encum_account			NUMBER,
	encum_type_id			NUMBER,
    -- Added for Revenue / COGS Matching --
    so_issue_acct_type  NUMBER,
    om_line_id          NUMBER,
    cogs_percentage     NUMBER,
    expense_account_id  NUMBER,
    lcm_flag            VARCHAR2(1),
    debit_account       NUMBER
);

TYPE cst_ae_line_rec_type IS RECORD (
	ae_line_type			NUMBER(5),
	description			VARCHAR2(240),
	account				NUMBER(15),
	currency_code			VARCHAR2(15),
	currency_conv_type		VARCHAR2(30),
	currency_conv_date		DATE,
	currency_conv_rate		NUMBER,
-- Retroactive Pricing - Patchset J ------------
        accounted_value                 NUMBER,
        entered_value                   NUMBER,
------------------------------------------------
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
        actual_flag                     VARCHAR2(1),
        encum_type_id			NUMBER,
        po_distribution_id              NUMBER,
        wip_entity_id                   NUMBER,
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
	currency_conv_type		VARCHAR2(30),
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

END CSTPALTY;


/
