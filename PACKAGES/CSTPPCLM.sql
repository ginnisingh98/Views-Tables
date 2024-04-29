--------------------------------------------------------
--  DDL for Package CSTPPCLM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPCLM" AUTHID CURRENT_USER AS
/* $Header: CSTPCLMS.pls 115.6 2002/11/09 00:41:37 awwang ship $ */

PROCEDURE layer_id (
  i_pac_period_id           IN	NUMBER,
  i_legal_entity            IN 	NUMBER,
  i_item_id                 IN 	NUMBER,
  i_cost_group_id           IN 	NUMBER,
  o_cost_layer_id	    OUT NOCOPY NUMBER,
  o_quantity_layer_id       OUT NOCOPY NUMBER,
  o_err_num                 OUT NOCOPY NUMBER,
  o_err_code                OUT NOCOPY VARCHAR2,
  o_err_msg                 OUT NOCOPY VARCHAR2
);

PROCEDURE create_layer (
  i_pac_period_id           IN 	NUMBER,
  i_legal_entity            IN 	NUMBER,
  i_item_id                 IN 	NUMBER,
  i_cost_group_id           IN 	NUMBER,
  i_user_id                 IN 	NUMBER,
  i_login_id                IN 	NUMBER,
  i_request_id              IN 	NUMBER,
  i_prog_id                 IN 	NUMBER,
  i_prog_appl_id            IN 	NUMBER,
  o_cost_layer_id	    OUT NOCOPY NUMBER,
  o_quantity_layer_id       OUT NOCOPY NUMBER,
  o_err_num                 OUT NOCOPY NUMBER,
  o_err_code                OUT NOCOPY VARCHAR2,
  o_err_msg                 OUT NOCOPY VARCHAR2
);

END CSTPPCLM;

 

/
