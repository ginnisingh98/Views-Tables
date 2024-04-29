--------------------------------------------------------
--  DDL for Package CSTPACIR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPACIR" AUTHID CURRENT_USER AS
/* $Header: CSTPACIS.pls 115.3 2002/11/08 23:24:44 awwang ship $ */
PROCEDURE issue (
          i_trx_id              IN      NUMBER,
          i_layer_id            IN      NUMBER,
          i_inv_item_id         IN      NUMBER,
          i_org_id              IN      NUMBER,
          i_wip_entity_id       IN      NUMBER,
          i_txn_qty             IN      NUMBER,
          i_op_seq_num          IN      NUMBER,
          i_user_id             IN      NUMBER,
          i_login_id            IN      NUMBER,
          i_request_id          IN      NUMBER,
	  i_prog_id		IN	NUMBER,
	  i_prog_appl_id	IN	NUMBER,
          err_num               OUT NOCOPY     NUMBER,
          err_code              OUT NOCOPY     VARCHAR2,
          err_msg               OUT NOCOPY     VARCHAR2);

END CSTPACIR;

 

/
