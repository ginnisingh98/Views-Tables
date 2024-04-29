--------------------------------------------------------
--  DDL for Package CSTPLCAC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPLCAC" AUTHID CURRENT_USER AS
/* $Header: CSTLCACS.pls 115.3 2004/06/18 16:42:42 rzhu ship $ */


PROCEDURE assembly_completion (
  i_cost_method_id      IN      NUMBER,
  i_txn_id              IN      NUMBER,
  i_txn_date            IN      DATE,
  i_layer_id            IN      NUMBER,
  i_inv_item_id         IN      NUMBER,
  i_org_id              IN      NUMBER,
  i_wip_entity_id       IN      NUMBER,
  i_txn_qty             IN      NUMBER,
  i_final_comp_flag     IN      VARCHAR2,
  i_cost_type_id        IN      NUMBER,
  i_res_cost_type_id    IN      NUMBER,
  i_cost_group_id       IN      NUMBER,
  i_acct_period_id      IN      NUMBER,
  i_user_id             IN      NUMBER,
  i_login_id            IN      NUMBER,
  i_request_id          IN      NUMBER,
  i_prog_id             IN      NUMBER,
  i_prog_appl_id        IN      NUMBER,
  o_movhd_cost_type_id  OUT NOCOPY     NUMBER,
  o_err_num             OUT NOCOPY     NUMBER,
  o_err_msg             OUT NOCOPY     VARCHAR2
);



PROCEDURE assembly_return (
  i_cost_method_id      IN      NUMBER,
  i_txn_id              IN      NUMBER,
  i_layer_id            IN      NUMBER,
  i_inv_item_id         IN      NUMBER,
  i_org_id              IN      NUMBER,
  i_wip_entity_id       IN      NUMBER,
  i_txn_qty             IN      NUMBER,
  i_user_id             IN      NUMBER,
  i_login_id            IN      NUMBER,
  i_request_id          IN      NUMBER,
  i_prog_id             IN      NUMBER,
  i_prog_appl_id        IN      NUMBER,
  o_err_num             OUT NOCOPY     NUMBER,
  o_err_msg             OUT NOCOPY     VARCHAR2
);



END CSTPLCAC;

 

/
