--------------------------------------------------------
--  DDL for Package Body CSTACOSN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTACOSN" AS
/* $Header: CSTACOSB.pls 115.4 2002/11/08 01:15:21 awwang ship $ */

FUNCTION op_snapshot(
          I_TXN_TEMP_ID       IN      NUMBER,
          ERR_NUM             OUT NOCOPY     NUMBER,
          ERR_CODE            OUT NOCOPY     VARCHAR2,
          ERR_MSG             OUT NOCOPY     VARCHAR2)
RETURN INTEGER
is
   stmt_num			NUMBER;
   l_txn_temp_id		NUMBER;
   l_wip_entity_id		NUMBER;
   l_primary_quantity	 	NUMBER;
   l_operation_seq_num		NUMBER;
   l_transaction_action_id	NUMBER;

   CURSOR completion IS
   SELECT
      transaction_temp_id,
      transaction_source_id,
      primary_quantity,
      operation_seq_num,
      transaction_action_id
   FROM
      mtl_material_transactions_temp
   WHERE
      transaction_temp_id = i_txn_temp_id;

BEGIN

   SAVEPOINT op_snapshot_1;

   OPEN completion;
   FETCH completion INTO l_txn_temp_id,
	    	         l_wip_entity_id,
			 l_primary_quantity,
			 l_operation_seq_num,
			 l_transaction_action_id;
   CLOSE completion;

   stmt_num := 10;

   INSERT INTO cst_comp_snap_temp
      (transaction_temp_id,
       wip_entity_id,
       operation_seq_num,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       new_operation_flag,
       primary_quantity,
       quantity_completed,
       prior_completion_quantity,
       prior_scrap_quantity,
       request_id,
       program_application_id,
       program_id,
       program_update_date)
   SELECT
      l_txn_temp_id,
      l_wip_entity_id,
      operation_seq_num,
      sysdate,
      -1,
      sysdate,
      -1,
      -1,
      2,
       --
       -- Bug 608310
       -- If the transaction is a scrap transaction
       -- Operation after the scrap operation should be
       -- primary_quantity of zero.
       --
       decode(l_transaction_action_id,
	      30,
	      decode(sign(operation_seq_num - l_operation_seq_num),
		     1,0,
		     l_primary_quantity),
	      l_primary_quantity),
       quantity_completed,
       0,
       0,
       -1,
       -1,
       -1,
       sysdate
    FROM
       wip_operations wo
    WHERE
       wo.wip_entity_id = l_wip_entity_id;


   RETURN(1);

 EXCEPTION

 WHEN OTHERS THEN

    ROLLBACK TO op_snapshot_1;
    err_num := SQLCODE;
    err_msg := 'CSTACOSN:op_snapshot' || to_char(stmt_num) || substr(SQLERRM,1,150);
    return(-999);

 END op_snapshot;

 END CSTACOSN;

/
