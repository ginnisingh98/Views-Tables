--------------------------------------------------------
--  DDL for Package CSTPLMWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPLMWI" AUTHID CURRENT_USER AS
/* $Header: CSTLMWIS.pls 115.3 2002/11/12 18:08:54 awwang ship $ */


-- cost method IDs
FIFO    CONSTANT NUMBER := 5;
LIFO    CONSTANT NUMBER := 6;

-- direction constants
NORMAL  CONSTANT NUMBER := 0;
REVERSE CONSTANT NUMBER := 1;



TYPE LayerQtyRec IS RECORD
(
  layer_id  NUMBER(15),
  layer_qty NUMBER
);

TYPE LayerQtyRecTable IS TABLE OF LayerQtyRec;

TYPE REF_CURSOR_TYPE IS REF CURSOR;


----------------------------------------------------------------
-- wip_layer_create
--   This function takes a LayerQtyRecTable containing the INV
--   layer IDs and quantities, and creates corresponding WIP
--   layers using the given INV layer costs.
----------------------------------------------------------------
FUNCTION wip_layer_create (
  i_wip_entity_id       IN      NUMBER,
  i_op_seq_num          IN      NUMBER,
  i_inv_item_id         IN      NUMBER,
  i_txn_id              IN      NUMBER,
  i_layer_qty_table     IN      LayerQtyRecTable,
  i_user_id             IN      NUMBER,
  i_login_id            IN      NUMBER,
  i_request_id          IN      NUMBER,
  i_prog_id             IN      NUMBER,
  i_prog_appl_id        IN      NUMBER,
  o_err_num             OUT NOCOPY     NUMBER,
  o_err_msg             OUT NOCOPY     VARCHAR2
) RETURN NUMBER;



---------------------------------------------------------------
-- init_wip_layers
--   This function initializes WROCD, CWL, and CWLCD for
--   a particular WIP entity/op/Item combination.  It will
--   create default rows in these tables if they don't exist.
---------------------------------------------------------------
PROCEDURE init_wip_layers (
  i_wip_entity_id       IN      NUMBER,
  i_op_seq_num          IN      NUMBER,
  i_inv_item_id         IN      NUMBER,
  i_org_id              IN      NUMBER,
  i_txn_id              IN      NUMBER,
  i_layer_id            IN      NUMBER,
  i_user_id             IN      NUMBER,
  i_login_id            IN      NUMBER,
  i_request_id          IN      NUMBER,
  i_prog_id             IN      NUMBER,
  i_prog_appl_id        IN      NUMBER,
  o_err_num             OUT NOCOPY     NUMBER,
  o_err_msg             OUT NOCOPY     VARCHAR2
);


----------------------------------------------------------------
-- wip_layer_consume_sql
--   This function returns the dynamic SQL statement for
--   consuming the WIP layers using the provided WHERE clause,
--   as well as the order mode (FIFO or LIFO).
----------------------------------------------------------------
FUNCTION wip_layer_consume_sql (
  i_where_clause   IN VARCHAR2,
  i_cost_method_id IN NUMBER,
  i_direction_mode IN NUMBER
) RETURN VARCHAR2;



-----------------------------------------------------------------
-- get_last_layer
--   This function returns the last (most recent) WIP layer for
--   a particular WIP entity/op/item combination.
-----------------------------------------------------------------
FUNCTION get_last_layer (
  i_wip_entity_id IN  NUMBER,
  i_op_seq_num    IN  NUMBER,
  i_inv_item_id   IN  NUMBER,
  o_err_num       OUT NOCOPY NUMBER,
  o_err_msg       OUT NOCOPY VARCHAR2
) RETURN cst_wip_layers%ROWTYPE;



-----------------------------------------------------------------
-- reset_temp_columns
--   This function resets the temp_relieve_value/qty
--   columns in WROCD, WOO, WOR, and CWL.
-----------------------------------------------------------------
PROCEDURE reset_temp_columns (
  i_wip_entity_id       IN      NUMBER,
  o_err_num             OUT NOCOPY     NUMBER,
  o_err_msg             OUT NOCOPY     VARCHAR2
);



END CSTPLMWI;

 

/
