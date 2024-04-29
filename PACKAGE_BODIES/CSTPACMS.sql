--------------------------------------------------------
--  DDL for Package Body CSTPACMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPACMS" AS
/* $Header: CSTACMSB.pls 115.9 2002/11/08 00:57:38 awwang ship $ */

FUNCTION move_snapshot(
         l_txn_temp_id       IN   NUMBER,
         l_txn_id            IN   NUMBER,
         err_num             OUT NOCOPY  NUMBER,
         err_code            OUT NOCOPY  VARCHAR2,
         err_msg             OUT NOCOPY  VARCHAR2)
RETURN INTEGER
IS
        stmt_num             NUMBER;

BEGIN
        stmt_num := 10;

        /*
           Transfer info from cst_comp_snap_temp to cst_comp_snapshot
           with transaction_id from MTL_MATERIAL_TRANSACTIONS
        */
        INSERT INTO cst_comp_snapshot
        (transaction_id,
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
        l_txn_id,
        codt.wip_entity_id,
        codt.operation_seq_num,
        sysdate,
        -1,
        sysdate,
        -1,
        -1,
        codt.new_operation_flag,
        codt.primary_quantity,
        codt.quantity_completed,
        codt.prior_completion_quantity,
        codt.prior_scrap_quantity,
        -1,
        -1,
        -1,
        sysdate
        FROM
        cst_comp_snap_temp codt
        WHERE
        transaction_temp_id = l_txn_temp_id;

        stmt_num := 20;


        /*
          Delete temporary info from cst_comp_snap_temp
        */
        DELETE FROM cst_comp_snap_temp
        WHERE
        transaction_temp_id = l_txn_temp_id;

        stmt_num := 30;

        /*
          Update prior_completion_quantity and prior_scrap_quantity
          as the sum of previous primary_quantity of
          all the previous transactions of the same job and
          same operation
        */
        UPDATE  cst_comp_snapshot cocd1
        SET
           (prior_completion_quantity, prior_scrap_quantity) =
           (SELECT
               NVL
                  (SUM(
		       DECODE(mmt.transaction_action_id,
                              30,0,
                              cocd2.primary_quantity)
                      ),
                   0),
               NVL(SUM(
                       DECODE(mmt.transaction_action_id,
 			      31,0,
 			      32,0,
                              cocd2.primary_quantity)
                      ),
                   0)
            FROM
               cst_comp_snapshot         cocd2,
               mtl_material_transactions mmt
         WHERE
             cocd2.transaction_id    < cocd1.transaction_id
         AND cocd2.transaction_id    = mmt.transaction_id
         AND cocd2.wip_entity_id     = cocd1.wip_entity_id
         AND cocd2.operation_seq_num = cocd1.operation_seq_num
         GROUP BY
         cocd2.operation_seq_num
         )
         WHERE
         cocd1.transaction_id = l_txn_id
         AND
         EXISTS
            (
            SELECT 'x'
            FROM cst_comp_snapshot cocd3
            WHERE
                  cocd3.transaction_id    < l_txn_id
            AND   cocd3.wip_entity_id     = cocd1.wip_entity_id
            AND   cocd3.operation_seq_num = cocd1.operation_seq_num
            );

         stmt_num := 40;

         /*
	  *  Update cst_comp_snapshot
          *  by setting new_operation_flag to 1
          *  if it is a new operation
          *  ie. operation_seq_num is smaller than the latter ones
          *  but the quantity_completed is also smaller.
          */
         UPDATE cst_comp_snapshot cocd1
         SET
         new_operation_flag = 1
         WHERE
             cocd1.transaction_id = l_txn_id
         AND cocd1.operation_seq_num IN
             (SELECT cocd2.operation_seq_num
              FROM
                cst_comp_snapshot cocd2,
                cst_comp_snapshot cocd3
              WHERE
                  cocd2.transaction_id     = l_txn_id
              AND cocd2.transaction_id     = cocd3.transaction_id
              AND cocd2.operation_seq_num  < cocd3.operation_seq_num
              AND cocd2.quantity_completed < cocd3.quantity_completed
         );

         return(1);

EXCEPTION

WHEN OTHERS THEN
   err_num := SQLCODE;
   err_msg := 'CSTPACMS:move_snapshot' || to_char(stmt_num) || substr(SQLERRM,1,150);
   return(-999);

END move_snapshot;


FUNCTION validate_move_snap_to_temp(
	 l_txn_interface_id      IN   NUMBER,
         l_txn_temp_id           IN   NUMBER,
         l_interface_table       IN   NUMBER,
         l_primary_quantity      IN   NUMBER,
         err_num                 OUT NOCOPY  NUMBER,
         err_code                OUT NOCOPY  VARCHAR2,
         err_msg                 OUT NOCOPY  VARCHAR2)
RETURN INTEGER
IS
   stmt_num                NUMBER;

BEGIN
   stmt_num := 10;

   IF (CSTPACMS.validate_snap_interface(l_txn_interface_id,
				        l_interface_table,
					l_primary_quantity,
				        err_num,
  				        err_code,
			 	        err_msg) = 1) THEN
       RETURN(CSTPACMS.move_snapshot_to_temp(l_txn_interface_id,
					     l_txn_temp_id,
					     l_interface_table,
					     err_num,
					     err_code,
					     err_msg));
   ELSE
      RETURN(-999);
   END IF;

EXCEPTION
WHEN OTHERS THEN
   err_num := SQLCODE;
   err_msg := 'CSTPACMS:validate_move_snap_to_temp' || to_char(stmt_num) || substr(SQLERRM,1,150);
   return(-999);
END validate_move_snap_to_temp;


FUNCTION validate_snap_interface(
         l_txn_interface_id      IN   NUMBER,
	 l_interface_table	 IN   NUMBER,
         l_primary_quantity      IN   NUMBER,
         err_num                 OUT NOCOPY  NUMBER,
         err_code                OUT NOCOPY  VARCHAR2,
         err_msg                 OUT NOCOPY  VARCHAR2)
RETURN INTEGER
IS
        stmt_num                NUMBER;
	dummy		        VARCHAR2(1);
	v_count1	        NUMBER;
        v_count2	        NUMBER;
	v_operation_seq_num     NUMBER;
        i_wip_entity_id         NUMBER;
        i_primary_quantity      NUMBER;
        i_operation_seq_num     NUMBER;
        i_transaction_action_id NUMBER;
        l_wop_count		NUMBER;
   	e_primary_quantity      EXCEPTION;

	CURSOR c_find_missing_op IS
           SELECT
	   operation_seq_num
	   FROM wip_operations
	   WHERE wip_entity_id = i_wip_entity_id;

	CURSOR c_mti IS
           SELECT
           transaction_source_id,
	   l_primary_quantity,
	   transaction_action_id
	   FROM mtl_transactions_interface
	   WHERE transaction_interface_id = l_txn_interface_id;

	CURSOR c_wt IS
           SELECT
           wip_entity_id,
	   primary_quantity,
	   to_operation_seq_num,
	   decode(transaction_type,1,30,2,31,3,32)
	   FROM wip_move_txn_interface
	   WHERE transaction_id = l_txn_interface_id;

BEGIN

  stmt_num := 5;

  /* if l_interface_table = 1, information is passed from MTI
     if l_interface_table = 2, information is passed from WIP_MOVE_TXN_INTERFACE */
  IF l_interface_table = 1 THEN
     OPEN c_mti;
     FETCH c_mti INTO i_wip_entity_id,
		      i_primary_quantity,
 	  	      i_transaction_action_id;
     CLOSE c_mti;
  ELSE
     OPEN c_wt;
     FETCH c_wt INTO i_wip_entity_id,
		     i_primary_quantity,
   	             i_operation_seq_num,
		     i_transaction_action_id;
     CLOSE c_wt;
  END IF;

   l_wop_count := 0;
   /* If nothing in WIP operations, ignore row validation in cst_comp_snap_interface */
   SELECT count(*)
   INTO l_wop_count
   FROM wip_operations
   WHERE wip_entity_id = i_wip_entity_id;

   IF (l_wop_count = 0) THEN
     return(1);
   END IF;

   /* 	Check if the transaction_interface_id is the same
	as MTI or WIP_MOVE_TXN_INTERFACE    */
   stmt_num := 10;
   SELECT  'x'
   INTO  dummy
   FROM	 cst_comp_snap_interface codt
   WHERE transaction_interface_id = l_txn_interface_id
   AND   rownum = 1;

   /*	Check if the wip_entity_id is the same as
	MTI or WIP_MOVE_TXN_INTERFACE    */
   stmt_num := 20;
   SELECT  'x'
   INTO  dummy
   FROM  cst_comp_snap_interface codt
   WHERE transaction_interface_id = l_txn_interface_id
   AND 	 wip_entity_id 	     	  = i_wip_entity_id
   AND   rownum = 1;

   /* Make sure OPERATION_SEQ_NUM in WIP_OPERATION
      exists in CST_COMP_SNAP_INTERFACE */
   stmt_num := 30;
   OPEN c_find_missing_op;
   LOOP
   FETCH c_find_missing_op INTO v_operation_seq_num;
   /* exit loop when there are no more rows to fetch */
   EXIT WHEN c_find_missing_op%NOTFOUND;

   SELECT 'x'
   INTO dummy
   FROM cst_comp_snap_interface codt
   WHERE
         codt.transaction_interface_id = l_txn_interface_id
   AND   codt.wip_entity_id	       = i_wip_entity_id
   AND   codt.operation_seq_num	       = v_operation_seq_num;

   END LOOP;
   /* free resources used by the cursor */
   CLOSE c_find_missing_op;

   stmt_num := 40;

   /* Primary_quantity should be the all the same
      and equal to primary_quantity in mmtt
      except in for scrap transaction.
      For scrap transaction, primary_quantity should be
      the same until last operation seq num */

   IF i_transaction_action_id = 30 THEN
      SELECT count(*)
      INTO v_count1
      FROM cst_comp_snap_interface
      WHERE transaction_interface_id  = l_txn_interface_id
      AND   wip_entity_id             = i_wip_entity_id
      AND   operation_seq_num        <= i_operation_seq_num;

      SELECT count(*)
      INTO v_count2
      FROM cst_comp_snap_interface
      WHERE transaction_interface_id  = l_txn_interface_id
      AND   wip_entity_id             = i_wip_entity_id
      AND   operation_seq_num        <= i_operation_seq_num
      AND   primary_quantity          = i_primary_quantity;
   ELSE
      SELECT count(*)
      INTO v_count1
      FROM cst_comp_snap_interface
      WHERE transaction_interface_id  = l_txn_interface_id
      AND   wip_entity_id             = i_wip_entity_id;

      SELECT count(*)
      INTO v_count2
      FROM cst_comp_snap_interface
      WHERE transaction_interface_id  = l_txn_interface_id
      AND   wip_entity_id             = i_wip_entity_id
      AND   primary_quantity          = i_primary_quantity;
   END IF;

   IF v_count1 <> v_count2 THEN
      RAISE e_primary_quantity;
   END IF;


   /* Following should be done by move_snapshot_to_temp */

   /*
   stmt_num = 60;
   UPDATE cst_comp_snap_interface
   SET primary_quantity =
         decode(i_transaction_action_id,
                30,
                decode(sign(operation_seq_num - i_operation_seq_num),
                       1,0,
                       i_primary_quantity),
                i_primary_quantity)
   WHERE transaction_interface_id = l_txn_interface_id
   AND   wip_entity_id            = i_wip_entity_id;
   */

   RETURN(1);


EXCEPTION
   WHEN NO_DATA_FOUND THEN
      err_num := SQLCODE;
      IF (stmt_num = 10) THEN
         fnd_message.set_name('BOM','CST_COMP_SNAP_INTERFACE_FAIL');
         fnd_message.set_token(
				token           => 'COLUMN',
              		        value           => 'TRANSACTION_INTERFACE_ID',
 				translate       =>  FALSE);
         err_msg := 'CSTPACMS:validate_snap_interface ' ||
		     to_char(stmt_num) || ' : ' ||
                     fnd_message.get;

      ELSIF (stmt_num = 20) THEN
         fnd_message.set_name('BOM','CST_COMP_SNAP_INTERFACE_FAIL');
         fnd_message.set_token(
                                token           => 'COLUMN',
                                value           => 'WIP_ENTITY_ID',
                                translate       =>  FALSE);
         err_msg := 'CSTPACMS:validate_snap_interface ' ||
                     to_char(stmt_num) || ' : ' ||
                     fnd_message.get;

      ELSIF (stmt_num = 30) THEN
         fnd_message.set_name('BOM','CST_COMP_SNAP_INTERFACE_FAIL');
         fnd_message.set_token(
                                token           => 'COLUMN',
                                value           => 'OPERATION_SEQ_NUM',
                                translate       =>  FALSE);
         err_msg := 'CSTPACMS:validate_snap_interface ' ||
                     to_char(stmt_num) || ' : ' ||
                     fnd_message.get;

      END IF;
   RETURN(-999);

   WHEN e_primary_quantity THEN
      err_num := SQLCODE;
      fnd_message.set_name('BOM','CST_COMP_SNAP_INTERFACE_FAIL');
      fnd_message.set_token(
                            token           => 'COLUMN',
                            value           => 'PRIMARY_QUANTITY',
                            translate       =>  FALSE);
      err_msg := 'CSTPACMS:validate_snap_interface ' ||
                  to_char(stmt_num) || ' : ' ||
                  fnd_message.get;
   RETURN(-999);

   WHEN OTHERS THEN
      err_num := SQLCODE;
      err_msg := 'CSTPACMS:validate_snap_interface ' ||
	   to_char(stmt_num) ||' '|| substr(SQLERRM,1,150);
   RETURN(-999);

END validate_snap_interface;



FUNCTION move_snapshot_to_temp(
         l_txn_interface_id      IN   NUMBER,
         l_txn_temp_id           IN   NUMBER,
 	 l_interface_table	 IN   NUMBER,
         err_num                 OUT NOCOPY  NUMBER,
         err_code                OUT NOCOPY  VARCHAR2,
         err_msg                 OUT NOCOPY  VARCHAR2)
RETURN INTEGER
IS
        stmt_num                NUMBER;
        i_operation_seq_num     NUMBER;
 	i_transaction_action_id NUMBER;

        CURSOR c_mti IS
           SELECT
           transaction_action_id
           FROM mtl_transactions_interface
           WHERE transaction_interface_id = l_txn_interface_id;

        CURSOR c_wt IS
           SELECT
           to_operation_seq_num,
           decode(transaction_type,1,30,2,31,3,32)
           FROM wip_move_txn_interface
           WHERE transaction_id = l_txn_interface_id;


BEGIN
        stmt_num := 10;
        IF l_interface_table = 1 THEN
           OPEN c_mti;
           FETCH c_mti INTO i_transaction_action_id;
           CLOSE c_mti;
        ELSE
           OPEN c_wt;
           FETCH c_wt INTO i_operation_seq_num,
                           i_transaction_action_id;
           CLOSE c_wt;
        END IF;

        stmt_num := 15;
        /*
           Transfer info from cst_comp_snap_interface to cst_comp_snap_temp
           with transaction_id from MTL_MATERIAL_TRANSACTIONS
        */
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
        codt.wip_entity_id,
        codt.operation_seq_num,
        sysdate,
        -1,
        sysdate,
        -1,
        -1,
         --codt.new_operation_flag,
         -- we assume this is not new operation flag
	 -- the following package will change it if necessary.
        2,
         --
         -- Bug 608310
         -- If the transaction is a scrap transaction
         -- Operation after the scrap operation should be
         -- primary_quantity of zero.
         --
         decode(i_transaction_action_id,
                30,
                decode(sign(operation_seq_num - i_operation_seq_num),
                       1,0,
                       codt.primary_quantity),
                codt.primary_quantity),
        codt.quantity_completed,
        codt.prior_completion_quantity,
        codt.prior_scrap_quantity,
        -1,
        -1,
        -1,
        sysdate
        FROM
        cst_comp_snap_interface codt
        WHERE
        transaction_interface_id = l_txn_interface_id;

        stmt_num := 20;
        /*
          Delete temporary info from cst_comp_snap_interface
        */
        DELETE FROM cst_comp_snap_interface
        WHERE
        transaction_interface_id = l_txn_interface_id;

        RETURN(1);

EXCEPTION
WHEN OTHERS THEN
   err_num := SQLCODE;
   err_msg := 'CSTPACMS:move_snapshot_to_temp' || to_char(stmt_num) || substr(SQLERRM,1,150);
   RETURN(-999);
END move_snapshot_to_temp;

END CSTPACMS;

/
