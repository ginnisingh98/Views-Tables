--------------------------------------------------------
--  DDL for Package CSTPACLM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPACLM" AUTHID CURRENT_USER as
/* $Header: CSTACLMS.pls 115.3 2002/11/08 00:45:16 awwang ship $ */

function layer_id (
  i_org_id                  in number,
  i_item_id       	    in number,
  i_cost_group_id      	    in number,
  o_err_num                 out NOCOPY number,
  o_err_code                out NOCOPY varchar2,
  o_err_msg                 out NOCOPY varchar2
)
return integer;

function layer_det_exist (
  i_org_id                  in number,
  i_item_id                 in number,
  i_cost_group_id     	    in number,
  o_err_num                 out NOCOPY number,
  o_err_code                out NOCOPY varchar2,
  o_err_msg                 out NOCOPY varchar2
)
return integer;

function create_layer (
  i_org_id                  in number,
  i_item_id	            in number,
  i_cost_group_id      	    in number,
  i_user_id		    in number,
  i_request_id              in number,
  i_prog_id                 in number,
  i_prog_appl_id            in number,
  i_txn_id  	            in number,
  o_err_num                 out NOCOPY number,
  o_err_code                out NOCOPY varchar2,
  o_err_msg                 out NOCOPY varchar2
)
return integer;

end cstpaclm;

 

/
