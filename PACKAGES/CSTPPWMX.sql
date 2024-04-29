--------------------------------------------------------
--  DDL for Package CSTPPWMX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPWMX" AUTHID CURRENT_USER AS
/* $Header: CSTPPWMS.pls 115.4 2002/11/11 21:25:36 awwang ship $ */

FUNCTION issue (
        i_cost_type_id     IN   NUMBER,
        i_txn_id           IN   NUMBER,
        i_org_id           IN   NUMBER,
        i_period_id        IN   NUMBER,
        i_item_id          IN   NUMBER,
        i_txn_qty          IN   NUMBER,
        i_entity_id        IN   NUMBER,
        i_entity_type      IN   NUMBER,
        i_user_id          IN   NUMBER,
        i_login_id         IN   NUMBER,
        i_prg_appl_id      IN   NUMBER,
        i_prg_id           IN   NUMBER,
        i_req_id           IN   NUMBER)
RETURN integer;

FUNCTION complete (
        i_cost_type_id     IN   NUMBER,
        i_txn_id           IN   NUMBER,
        i_org_id           IN   NUMBER,
        i_period_id        IN   NUMBER,
        i_item_id          IN   NUMBER,
        i_txn_qty          IN   NUMBER,
        i_entity_id        IN   NUMBER,
        i_entity_type      IN   NUMBER,
        i_user_id          IN   NUMBER,
        i_login_id         IN   NUMBER,
        i_prg_appl_id      IN   NUMBER,
        i_prg_id           IN   NUMBER,
        i_req_id           IN   NUMBER)
RETURN integer;

end CSTPPWMX;

 

/
