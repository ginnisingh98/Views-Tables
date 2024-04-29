--------------------------------------------------------
--  DDL for Package CSTPACWP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPACWP" AUTHID CURRENT_USER AS
/* $Header: CSTPACPS.pls 115.3 2002/11/09 00:24:30 awwang ship $ */

-- Procedure
-- to cost wip transactions.
--
-- INPUT PARAMETERS
-- trx_id is the transaction_id of the transaction that is to be
-- costed from mtl_material_transactions.
--

PROCEDURE cost_wip_trx (
 l_trx_id       IN      NUMBER,
 l_comm_iss_flag IN	NUMBER,
 l_cost_type_id IN	NUMBER,
 l_cost_method  IN	NUMBER,
 l_rates_cost_type_id	IN	NUMBER,
 l_cost_grp_id	IN	NUMBER,
 l_txfr_cost_grp_id	IN	NUMBER,
 l_exp_flag	IN	NUMBER,
 l_exp_item_flag 	IN	NUMBER,
 l_flow_schedule	IN	NUMBER,
 l_user_id      IN      NUMBER,
 l_login_id     IN      NUMBER,
 l_request_id	IN	NUMBER,
 l_prog_id	IN	NUMBER,
 l_prog_app_id	IN	NUMBER,
 err_num	OUT NOCOPY	NUMBER,
 err_code	OUT NOCOPY	VARCHAR2,
 err_msg	OUT NOCOPY	VARCHAR2);

END CSTPACWP;

 

/
