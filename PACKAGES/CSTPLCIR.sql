--------------------------------------------------------
--  DDL for Package CSTPLCIR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPLCIR" AUTHID CURRENT_USER AS
/* $Header: CSTLCIRS.pls 115.3 2004/06/18 16:56:18 rzhu ship $ */


PROCEDURE component_issue (
  i_cost_method_id      IN      NUMBER,
  i_txn_id              IN      NUMBER,
  i_layer_id            IN      NUMBER,
  i_inv_item_id         IN      NUMBER,
  i_org_id              IN      NUMBER,
  i_wip_entity_id       IN      NUMBER,
  i_txn_qty             IN      NUMBER,
  i_op_seq_num          IN      NUMBER,
  i_cost_type_id        IN      NUMBER,
  i_exp_flag            IN      NUMBER,
  i_user_id             IN      NUMBER,
  i_login_id            IN      NUMBER,
  i_request_id          IN      NUMBER,
  i_prog_id             IN      NUMBER,
  i_prog_appl_id        IN      NUMBER,
  o_err_num             OUT NOCOPY     NUMBER,
  o_err_msg             OUT NOCOPY     VARCHAR2
);



PROCEDURE component_return (
  i_cost_method_id      IN      NUMBER,
  i_txn_id              IN      NUMBER,
  i_layer_id            IN      NUMBER,
  i_inv_item_id         IN      NUMBER,
  i_org_id              IN      NUMBER,
  i_wip_entity_id       IN      NUMBER,
  i_txn_qty             IN      NUMBER,
  i_op_seq_num          IN      NUMBER,
  i_user_id             IN      NUMBER,
  i_login_id            IN      NUMBER,
  i_request_id          IN      NUMBER,
  i_prog_id             IN      NUMBER,
  i_prog_appl_id        IN      NUMBER,
  o_err_num             OUT NOCOPY     NUMBER,
  o_err_msg             OUT NOCOPY     VARCHAR2
);



END CSTPLCIR;

 

/
