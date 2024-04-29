--------------------------------------------------------
--  DDL for Package CSTPACWS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPACWS" AUTHID CURRENT_USER AS
/* $Header: CSTPACSS.pls 115.4 2004/06/18 16:41:06 rzhu ship $ */
PROCEDURE scrap (
 i_trx_id		IN	NUMBER,
 i_txn_qty		IN	NUMBER,
 i_wip_entity_id	IN	NUMBER,
 i_inv_item_id		IN	NUMBER,
 i_org_id		IN	NUMBER,
 i_cost_group_id	IN	NUMBER,
 i_op_seq_num           IN      NUMBER,
 i_cost_type_id         IN      NUMBER,
 i_res_cost_type_id	IN	NUMBER,
 err_num                OUT NOCOPY     NUMBER,
 err_code               OUT NOCOPY     VARCHAR2,
 err_msg                OUT NOCOPY     VARCHAR2);

PROCEDURE scrap_return (
 i_trx_id               IN      NUMBER,
 i_txn_qty              IN      NUMBER,
 i_wip_entity_id        IN      NUMBER,
 i_inv_item_id          IN      NUMBER,
 i_org_id               IN      NUMBER,
 i_op_seq_num           IN      NUMBER,
 i_cost_type_id         IN      NUMBER,
 err_num                OUT NOCOPY     NUMBER,
 err_code               OUT NOCOPY     VARCHAR2,
 err_msg                OUT NOCOPY     VARCHAR2);


END CSTPACWS;

 

/
