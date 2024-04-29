--------------------------------------------------------
--  DDL for Package Body CSTPACIR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPACIR" AS
/* $Header: CSTPACIB.pls 115.4 2003/07/29 22:35:36 lsoo ship $ */

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
          err_msg               OUT NOCOPY     VARCHAR2)
is
	  stmt_num			NUMBER;

   	  /* EAM Acct Enh Project */
	  l_debug           	VARCHAR2(80);
	  l_zero_cost_flag	NUMBER := -1;
	  l_return_status	VARCHAR2(1) := fnd_api.g_ret_sts_success;
	  l_msg_count		NUMBER := 0;
	  l_msg_data            VARCHAR2(8000) := '';
	  l_api_message		VARCHAR2(8000);

   BEGIN

	err_num := 0;
	l_debug := FND_PROFILE.VALUE('MRP_DEBUG');
	stmt_num := 10;


	/***********************************************************
 	* 1. If a new cost element exists in cst_layer_cost_details*
	*    which did not exist during the last update, or        *
	* 2. This is the first issue being costed for the job, then*
	*    INSERT is required.				   *
	***********************************************************/


	INSERT INTO WIP_REQ_OPERATION_COST_DETAILS
	(WIP_ENTITY_ID,
	 OPERATION_SEQ_NUM,
	 ORGANIZATION_ID,
	 INVENTORY_ITEM_ID,
	 COST_ELEMENT_ID,
	 APPLIED_MATL_VALUE,
	 LAST_UPDATED_BY,
	 LAST_UPDATE_DATE,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN,
	 REQUEST_ID,
	 PROGRAM_APPLICATION_ID,
	 PROGRAM_ID,
	 PROGRAM_UPDATE_DATE)
	SELECT
	 i_wip_entity_id,
	 i_op_seq_num,
	 i_org_id,
	 i_inv_item_id,
	 c.COST_ELEMENT_ID,
	 0,
	 i_user_id,
	 SYSDATE,
	 SYSDATE,
	 i_user_id,
	 i_login_id,
	 i_request_id,
	 i_prog_id,
	 i_prog_appl_id,
	 SYSDATE
	from CST_LAYER_COST_DETAILS c
	WHERE
	 c.LAYER_ID = i_layer_id AND
	 NOT EXISTS
	(
	 SELECT 'X'
	 FROM
	 WIP_REQ_OPERATION_COST_DETAILS W2
	 WHERE
	 W2.COST_ELEMENT_ID	=	C.COST_ELEMENT_ID	AND
	 W2.WIP_ENTITY_ID	=	i_wip_entity_id		AND
	 W2.ORGANIZATION_ID	=	i_org_id		AND
	 W2.INVENTORY_ITEM_ID	=	i_inv_item_id		AND
	 W2.OPERATION_SEQ_NUM	=	i_op_seq_num
         )
	group by
	c.COST_ELEMENT_ID;

	stmt_num := 15;
	CST_Utility_PUB.get_zeroCostIssue_flag (
	  p_api_version		=>	1.0,
	  x_return_status	=>	l_return_status,
	  x_msg_count		=>	l_msg_count,
	  x_msg_data		=>	l_msg_data,
	  p_txn_id		=>	i_trx_id,
	  x_zero_cost_flag	=>	l_zero_cost_flag
	  );

   	if (l_return_status <> fnd_api.g_ret_sts_success) then
	  FND_FILE.put_line(FND_FILE.log, l_msg_data);
	  l_api_message := 'get_zeroCostIssue_flag returned unexpected error';
	  FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
	  FND_MESSAGE.set_token('TEXT', l_api_message);
	  FND_MSG_pub.add;
	  raise fnd_api.g_exc_unexpected_error;
	end if;

	if (l_debug = 'Y') then
	  FND_FILE.PUT_LINE(FND_FILE.LOG,'zero_cost_flag:'|| to_char(l_zero_cost_flag));
	end if;

	stmt_num := 20;

	/**************************************************
        * update wip_req_op_cost_details,per cost element *
        * for the item that has been issued/returned.     *
        **************************************************/

        UPDATE WIP_REQ_OPERATION_COST_DETAILS w
        SET (LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
            PROGRAM_APPLICATION_ID,PROGRAM_ID,PROGRAM_UPDATE_DATE,
            applied_matl_value )=
        (SELECT
            i_user_id, i_login_id,
            i_prog_appl_id,
            i_prog_id,
            SYSDATE,
            nvl(w.applied_matl_value,0)+
               (-1*i_txn_qty)*SUM(decode(l_zero_cost_flag, 1, 0, ITEM_COST))
            from
            CST_LAYER_COST_DETAILS c
            WHERE
            c.LAYER_ID = i_layer_id AND
            c.COST_ELEMENT_ID=w.COST_ELEMENT_ID
            GROUP BY c.COST_ELEMENT_ID
        )
        WHERE
        w.WIP_ENTITY_ID=i_wip_entity_id and
        w.INVENTORY_ITEM_ID=i_inv_item_id and
        w.ORGANIZATION_ID=i_org_id and
        w.OPERATION_SEQ_NUM=i_op_seq_num
        AND exists
        (select 'layer exists' from
         CST_LAYER_COST_DETAILS c2
         where c2.LAYER_ID = i_layer_id
        and     c2.cost_element_id = w.cost_element_id);


	/****************************************************
	* Insert into cst_txn_cst_details ...		    *
	* is not required since this occurs at current avg  *
        * cost.						    *
	*****************************************************/



   EXCEPTION

	WHEN OTHERS THEN
	err_num := SQLCODE;
	err_msg := 'CSTPACIR:' || to_char(stmt_num) || substr(SQLERRM,1,150);


   END issue;


END CSTPACIR;

/
