--------------------------------------------------------
--  DDL for Package CSTPALPC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPALPC" AUTHID CURRENT_USER AS
/* $Header: CSTALPCS.pls 120.1 2006/02/13 04:14:26 ggautam noship $ */


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

PROCEDURE create_dist_entry (
	i_acct_lib_id		IN	NUMBER,
	i_legal_entity		IN	NUMBER,
	i_cost_type_id		IN	NUMBER,
	i_cost_group_id		IN	NUMBER,
	i_period_id		IN	NUMBER,
	o_err_num		OUT NOCOPY	NUMBER,
	o_err_code		OUT NOCOPY	VARCHAR2,
	o_err_msg		OUT NOCOPY	VARCHAR2
);

PROCEDURE create_per_end_entry (
	i_acct_lib_id		IN	NUMBER,
	i_legal_entity		IN	NUMBER,
	i_cost_type_id		IN	NUMBER,
	i_cost_group_id		IN	NUMBER,
	i_period_id		IN	NUMBER,
	o_err_num		OUT NOCOPY	NUMBER,
	o_err_code		OUT NOCOPY	VARCHAR2,
	o_err_msg		OUT NOCOPY	VARCHAR2
);

PROCEDURE insert_ae_lines (
	i_ae_txn_rec		IN	CSTPALTY.CST_AE_TXN_REC_TYPE,
	i_ae_line_rec_tbl	IN	CSTPALTY.CST_AE_LINE_TBL_TYPE,
	o_err_rec		OUT NOCOPY	CSTPALTY.CST_AE_ERR_REC_TYPE
);


END CSTPALPC;


 

/
