--------------------------------------------------------
--  DDL for Package CSTPACWC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPACWC" AUTHID CURRENT_USER AS
/* $Header: CSTPACCS.pls 115.4 2002/11/08 23:24:13 awwang ship $ */

PROCEDURE complete (
 i_trx_id		IN	NUMBER,
 i_txn_qty		IN	NUMBER,
 i_txn_date		IN	DATE,
 i_acct_period_id	IN	NUMBER,
 i_wip_entity_id	IN	NUMBER,
 i_org_id		IN	NUMBER,
 i_inv_item_id		IN	NUMBER,
 i_cost_type_id		IN	NUMBER,
 i_res_cost_type_id	IN	NUMBER,
 i_final_comp_flag	IN	VARCHAR2,
 i_layer_id		IN	NUMBER,
 i_movhd_cost_type_id	OUT NOCOPY	NUMBER,
 i_cost_group_id	IN	NUMBER,
 i_user_id		IN      NUMBER,
 i_login_id		IN      NUMBER,
 i_request_id		IN      NUMBER,
 i_prog_id		IN      NUMBER,
 i_prog_appl_id		IN      NUMBER,
 err_num		OUT NOCOPY	NUMBER,
 err_code		OUT NOCOPY	VARCHAR2,
 err_msg		OUT NOCOPY	VARCHAR2);

 PROCEDURE neg_final_completion (
 i_org_id  	 	IN      NUMBER,
 i_txn_date 	        IN      DATE,
 i_wip_entity_id 	IN      NUMBER,
 i_wcti_txn_id        	IN      NUMBER,
 i_txn_qty		IN	NUMBER,
 i_trx_id		IN 	NUMBER,
 i_acct_period_id	IN	NUMBER,
 i_user_id		IN      NUMBER,
 i_login_id 		IN      NUMBER,
 i_request_id 		IN      NUMBER,
 i_prog_id 		IN      NUMBER,
 i_prog_appl_id 	IN      NUMBER,
 err_num		OUT NOCOPY     NUMBER,
 err_code		OUT NOCOPY     VARCHAR2,
 err_msg		OUT NOCOPY     VARCHAR2);


PROCEDURE assembly_return (
 i_trx_id               IN      NUMBER,
 i_txn_qty              IN      NUMBER,
 i_wip_entity_id        IN      NUMBER,
 i_org_id               IN      NUMBER,
 i_inv_item_id          IN      NUMBER,
 i_cost_type_id         IN      NUMBER,
 i_layer_id		IN	NUMBER,
 i_movhd_cost_type_id   OUT NOCOPY	NUMBER,
 i_res_cost_type_id	IN	NUMBER,
 i_user_id              IN      NUMBER,
 i_login_id             IN      NUMBER,
 i_request_id           IN      NUMBER,
 i_prog_id              IN      NUMBER,
 i_prog_appl_id         IN      NUMBER,
 err_num                OUT NOCOPY     NUMBER,
 err_code               OUT NOCOPY     VARCHAR2,
 err_msg                OUT NOCOPY     VARCHAR2);

END CSTPACWC;

 

/
