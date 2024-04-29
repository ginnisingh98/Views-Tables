--------------------------------------------------------
--  DDL for Package CSTPACIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPACIT" AUTHID CURRENT_USER as
/* $Header: CSTACITS.pls 115.3 2002/11/08 00:44:59 awwang ship $ */

procedure cost_det_validate (
  i_txn_interface_id        in number,
  i_org_id		    in number,
  i_item_id		    in number,
  i_new_avg_cost	    in number,
  i_per_change		    in number,
  i_val_change		    in number,
  i_mat_accnt		    in number,
  i_mat_ovhd_accnt	    in number,
  i_res_accnt		    in number,
  i_osp_accnt		    in number,
  i_ovhd_accnt		    in number,
  o_err_num                 out NOCOPY number,
  o_err_code		    out NOCOPY varchar2,
  o_err_msg                 out NOCOPY varchar2
);


procedure cost_det_move (
  i_txn_id                  in number,
  i_txn_interface_id        in number,
  i_txn_action_id           in number,
  i_org_id	            in number,
  i_item_id		    in number,
  i_cost_group_id	    in number,
  i_txn_cost		    in number,
  i_new_avg_cost	    in number,
  i_per_change		    in number,
  i_val_change		    in number,
  i_mat_accnt		    in number,
  i_mat_ovhd_accnt	    in number,
  i_res_accnt		    in number,
  i_osp_accnt		    in number,
  i_ovhd_accnt		    in number,
  i_user_id                 in number,
  i_login_id                in number,
  i_request_id              in number,
  i_prog_appl_id            in number,
  i_prog_id                 in number,
  o_err_num                 out NOCOPY number,
  o_err_code		    out NOCOPY varchar2,
  o_err_msg                 out NOCOPY varchar2
);

procedure cost_det_new_insert (
  i_txn_id                  in number,
  i_txn_action_id           in number,
  i_org_id	            in number,
  i_item_id		    in number,
  i_cost_group_id	    in number,
  i_txn_cost		    in number,
  i_new_avg_cost	    in number,
  i_per_change		    in number,
  i_val_change		    in number,
  i_mat_accnt		    in number,
  i_mat_ovhd_accnt	    in number,
  i_res_accnt		    in number,
  i_osp_accnt		    in number,
  i_ovhd_accnt		    in number,
  i_user_id                 in number,
  i_login_id                in number,
  i_request_id              in number,
  i_prog_appl_id            in number,
  i_prog_id                 in number,
  o_err_num                 out NOCOPY number,
  o_err_code		    out NOCOPY varchar2,
  o_err_msg                 out NOCOPY varchar2
);


end cstpacit;

 

/
