--------------------------------------------------------
--  DDL for Package CSTPLCIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPLCIN" AUTHID CURRENT_USER as
/* $Header: CSTLCINS.pls 115.4 2003/02/07 00:12:35 rthng ship $ */

procedure cost_inv_txn (
  i_txn_id                  in number,
  i_org_id		    in number,
  i_cost_group_id      	    in number,
  i_txfr_cost_group_id	    in number,
  i_cost_type_id	    in number,
  i_cost_method		    in number,
  i_rates_ct_id  	    in number,
  i_user_id                 in number,
  i_login_id                in number,
  i_request_id              in number,
  i_prog_id                 in number,
  i_prog_appl_id            in number,
  i_item_id	    	    in number,
  i_txn_qty		    in number,
  i_txn_action_id	    in number,
  i_txn_src_type_id	    in number,
  i_txn_org_id		    in number,
  i_txfr_org_id		    in number,
  i_fob_point		    in number,
  i_exp_flag		    in number,
  i_exp_item		    in number,
  i_citw_flag		    in number,
  i_flow_schedule	    in number,
  i_tprice_option           in number DEFAULT 0,
  i_txf_price               in number DEFAULT 0,
  o_err_num                 out NOCOPY number,
  o_err_code                out NOCOPY varchar2,
  o_err_msg                 out NOCOPY varchar2
);

end cstplcin;

 

/
