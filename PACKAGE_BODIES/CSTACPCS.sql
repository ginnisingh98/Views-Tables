--------------------------------------------------------
--  DDL for Package Body CSTACPCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTACPCS" AS
/* $Header: CSTACPCB.pls 115.21 2003/06/20 15:51:44 rthng ship $ */

PROCEDURE summarize_value(
	  i_org_id		IN		NUMBER,
	  i_acct_period_id	IN		NUMBER,
	  i_last_period_id	IN		NUMBER,
	  i_user_id		IN		NUMBER,
	  i_prog_id		IN		NUMBER,
	  i_prog_appl_id	IN		NUMBER,
 	  err_num		OUT NOCOPY		NUMBER,
	  err_code		OUT NOCOPY		VARCHAR2,
	  err_msg		OUT NOCOPY		VARCHAR2)

is
	  l_last_close_date	DATE;
	  l_acct_close_date	DATE;
	  l_stmt_num		NUMBER;
	  l_intransit_exists	NUMBER;
          l_sum_period_qty      NUMBER;
          l_item_id             NUMBER;
          l_subinv_code         VARCHAR2(10);
          l_cost_group_id       NUMBER;
          l_wms_flg	        NUMBER;
          l_msg_count	        NUMBER;
          l_return_status       VARCHAR2(11);
          l_msg_data            VARCHAR(2000);
          l_default_cost_group_id NUMBER;
          l_trans_id            NUMBER;
	  l_last_period_id	NUMBER;

	  process_error		EXCEPTION;

CURSOR cur_mmt_qty(c_last_period_id NUMBER,c_acct_period_id NUMBER,c_org_id NUMBER) IS
           SELECT
              sum(mmt.primary_quantity),
              MMT.COST_GROUP_ID,
              MMT.INVENTORY_ITEM_ID,
              MMT.SUBINVENTORY_CODE
           FROM
              MTL_PER_CLOSE_DTLS MPSD ,
              MTL_MATERIAL_TRANSACTIONS MMT,
              ORG_ACCT_PERIODS OAP
           WHERE
              MPSD.ACCT_PERIOD_ID               = C_ACCT_PERIOD_ID         AND
              MPSD.ORGANIZATION_ID              = C_ORG_ID                 AND
              MMT.COST_GROUP_ID                 = MPSD.COST_GROUP_ID       AND
              MMT.ORGANIZATION_ID               = MPSD.ORGANIZATION_ID     AND
	      MMT.ORGANIZATION_ID		= nvl(MMT.OWNING_ORGANIZATION_ID, MMT.ORGANIZATION_ID) AND
	      NVL(MMT.OWNING_TP_TYPE,2)		= 2			   AND
              MMT.INVENTORY_ITEM_ID             = MPSD.INVENTORY_ITEM_ID   AND
              MMT.SUBINVENTORY_CODE             = MPSD.SECONDARY_INVENTORY AND
              MMT.ORGANIZATION_ID               = C_ORG_ID                 AND
              MMT.SUBINVENTORY_CODE             IS NOT NULL                AND
              MMT.COSTED_FLAG                   IS NULL                    AND
              MMT.TRANSACTION_DATE              >= OAP.PERIOD_START_DATE   AND
              MMT.TRANSACTION_DATE              <= (trunc(OAP.SCHEDULE_CLOSE_DATE) + 0.99999)
									   AND
              MMT.ACCT_PERIOD_ID                > C_LAST_PERIOD_ID AND
              MMT.ACCT_PERIOD_ID                <= C_ACCT_PERIOD_ID        AND
              MMT.ACCT_PERIOD_ID                = OAP.ACCT_PERIOD_ID       AND
              OAP.ORGANIZATION_ID               = C_ORG_ID
           GROUP BY
              MMT.COST_GROUP_ID,MMT.INVENTORY_ITEM_ID,MMT.SUBINVENTORY_CODE;

	CURSOR cur_per_close_dtls(
		c_org_id NUMBER,
		c_acct_period_id NUMBER)
	IS
		SELECT	DISTINCT
                        COST_GROUP_ID,
			INVENTORY_ITEM_ID
		FROM	MTL_PER_CLOSE_DTLS
		WHERE	ORGANIZATION_ID = c_org_id
		AND	ACCT_PERIOD_ID = c_acct_period_id;

	CURSOR cur_get_mcacd_id(
		c_item_id 		IN 	NUMBER,
		c_org_id		IN	NUMBER,
		c_cg_id			IN	NUMBER,
		c_last_period_id	IN	NUMBER,
		c_acct_period_id	IN	NUMBER,
		c_last_close_date	IN	DATE,
		c_acct_close_date	IN	DATE)
	IS
  		SELECT	MCACD.TRANSACTION_ID
		FROM	MTL_CST_ACTUAL_COST_DETAILS MCACD,
			CST_QUANTITY_LAYERS CQL,
			MTL_MATERIAL_TRANSACTIONS MMT,
			MTL_SECONDARY_INVENTORIES MSI
		WHERE	MCACD.INVENTORY_ITEM_ID = c_item_id
		AND	MCACD.ORGANIZATION_ID = c_org_id
		AND	MCACD.LAYER_ID = CQL.LAYER_ID
		AND	CQL.COST_GROUP_ID = c_cg_id
		AND	MCACD.TRANSACTION_ID = MMT.TRANSACTION_ID
		AND	MMT.TRANSACTION_ACTION_ID <> 30
		AND	(
				(	MMT.ORGANIZATION_ID = c_org_id
				AND	MMT.ACCT_PERIOD_ID > c_last_period_id
				AND	MMT.ACCT_PERIOD_ID <= c_acct_period_id)
			OR	(	MMT.ORGANIZATION_ID <> c_org_id
				AND	MMT.TRANSACTION_DATE > NVL(c_last_close_date, MMT.TRANSACTION_DATE-1)
				AND	MMT.TRANSACTION_DATE <= trunc(c_acct_close_date)+0.99999))
		AND	MMT.SUBINVENTORY_CODE = MSI.SECONDARY_INVENTORY_NAME(+)
		AND	NVL(MSI.ORGANIZATION_ID,c_org_id) = c_org_id
		AND	NVL(MSI.ASSET_INVENTORY,1) = 1
		ORDER
		BY	MCACD.TRANSACTION_COSTED_DATE DESC,
			MCACD.TRANSACTION_ID DESC;
BEGIN

	err_num:=0;

	l_stmt_num:=5;

        IF (wms_install.check_install(l_return_status, l_msg_count, l_msg_data, I_org_id))
        THEN
           l_wms_flg := 1;
        ELSE
           l_wms_flg := 0;
        END IF;

        IF (l_wms_flg = 1)
        THEN
           DELETE FROM MTL_PERIOD_CG_SUMMARY
	           WHERE
	           ORGANIZATION_ID =       I_ORG_ID        AND
 	           ACCT_PERIOD_ID  =       I_ACCT_PERIOD_ID;
        ELSE

	   DELETE FROM MTL_PERIOD_SUMMARY
	   	   WHERE
		   ORGANIZATION_ID =	I_ORG_ID	AND
		   ACCT_PERIOD_ID	=	I_ACCT_PERIOD_ID;

        END IF;

	l_stmt_num:=7;

        DELETE FROM MTL_PER_CLOSE_DTLS
        WHERE
        ORGANIZATION_ID =       I_ORG_ID        AND
        ACCT_PERIOD_ID  =       I_ACCT_PERIOD_ID;

        /* added for bug 2769970 */
        l_stmt_num :=8;

        select default_cost_group_id
          into l_default_cost_group_id
        from mtl_parameters
        where organization_id = i_org_id;


	IF i_last_period_id IS NULL THEN
		l_last_period_id := -1;
	ELSE
		l_last_period_id := i_last_period_id;
	END IF;

	l_stmt_num:=10;

       /*Added For Bug 1478959 in 11.0 .... Porting the changes to 11.5 Bug 1521581*/
        /*------------------------------------------+
        | Pick up the schedule_close_date of the current
        | period that was closed ...
        |--------------------------------------*/

        SELECT
        SCHEDULE_CLOSE_DATE
        INTO l_acct_close_date
                FROM
        ORG_ACCT_PERIODS
        WHERE
        ORGANIZATION_ID         =       I_ORG_ID        AND
        ACCT_PERIOD_ID          =       I_ACCT_PERIOD_ID;
       /*End of Addition for 1478959 in 11.0 .... Porting the changes to 11.5 Bug 1521581*/

	/*-----------------------------------------------------------+
	| First, copy over from the prior period all the unique
	| combinations of cost group, Item and subinventory.
	|--------------------------------------------------------+*/

	INSERT INTO MTL_PER_CLOSE_DTLS
	(COST_GROUP_ID,
	 ACCT_PERIOD_ID,
 	 SECONDARY_INVENTORY,
	 INVENTORY_ITEM_ID,
	 ORGANIZATION_ID,
	 PERIOD_END_QUANTITY,
	 period_end_unit_cost,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATED_BY,
	 CREATION_DATE,
	 PROGRAM_ID,
	 PROGRAM_APPLICATION_ID,
	 LOGIN_ID)
	select
	 COST_GROUP_ID,
	 i_acct_period_id,
	 SECONDARY_INVENTORY,
	 INVENTORY_ITEM_ID,
	 ORGANIZATION_ID,
	 NVL(PERIOD_END_QUANTITY,0),
	 NVL(period_end_unit_cost,0),
	 SYSDATE,
  	 i_user_id,
	 i_user_id,
	 SYSDATE,
	 i_prog_id,
	 i_prog_appl_id,
	 i_user_id
	FROM MTL_PER_CLOSE_DTLS OLD
	WHERE
	OLD.ACCT_PERIOD_ID	=	l_last_period_id	AND
        OLD.SECONDARY_INVENTORY IS NOT NULL  AND
	OLD.ORGANIZATION_ID	=	i_org_id
        /*Added for 1478959 in 11.0 .... Porting the changes to 11.5 Bug 1521581*/
        UNION ALL
        select
         l_default_cost_group_id, /*1, commented for bug 2769970*/
         i_acct_period_id,
         NULL,
         SUP.ITEM_ID,
         i_org_id,
         SUM(DECODE(TO_ORGANIZATION_ID,I_ORG_ID,TO_ORG_PRIMARY_QUANTITY,
                    QUANTITY)),
         0,
         SYSDATE,
         i_user_id,
         i_user_id,
         SYSDATE,
         i_prog_id,
         i_prog_appl_id,
         i_user_id
         FROM MTL_SUPPLY SUP,
         RCV_SHIPMENT_HEADERS RSH
         WHERE
         SUP.ITEM_ID IN
        (select inventory_item_id from mtl_per_close_dtls OLD
         where
         OLD.ACCT_PERIOD_ID           =     l_last_period_id    AND
         old.cost_group_id            =     l_default_cost_group_id     AND --2769970
         OLD.SECONDARY_INVENTORY      IS    NULL                        AND
         OLD.ORGANIZATION_ID          =     i_org_id)                   AND
         INTRANSIT_OWNING_ORG_ID      =     i_org_id                    AND
        SUP.SUPPLY_TYPE_CODE          IN    ('SHIPMENT','RECEIVING')    AND
       (SUP.TO_ORGANIZATION_ID          =   i_org_id            OR
        SUP.FROM_ORGANIZATION_ID        =       I_ORG_ID)               AND
        SUP.SHIPMENT_HEADER_ID + 0 = RSH.SHIPMENT_HEADER_ID AND
        EXISTS
        (SELECT 'X'
         FROM MTL_MATERIAL_TRANSACTIONS MMT
         WHERE
         MMT.INVENTORY_ITEM_ID         =     SUP.ITEM_ID                AND
         ((SUP.FROM_ORGANIZATION_ID    =     MMT.ORGANIZATION_ID        AND
         SUP.TO_ORGANIZATION_ID        =     MMT.TRANSFER_ORGANIZATION_ID
                                                                        AND
         SUP.INTRANSIT_OWNING_ORG_ID    =       MMT.TRANSFER_ORGANIZATION_ID)
         OR
        (SUP.FROM_ORGANIZATION_ID       =       MMT.ORGANIZATION_ID     AND
         SUP.INTRANSIT_OWNING_ORG_ID    =       MMT.ORGANIZATION_ID     AND
         SUP.TO_ORGANIZATION_ID         =       MMT.TRANSFER_ORGANIZATION_ID))
                                                                        AND
         MMT.SHIPMENT_NUMBER = RSH.SHIPMENT_NUM AND
         MMT.COSTED_FLAG IS NULL AND
         MMT.TRANSACTION_DATE          <= (trunc(nvl(L_ACCT_CLOSE_DATE,
                                            mmt.transaction_date-1)) + 0.99999))
									AND
        SUP.INTRANSIT_OWNING_ORG_ID = I_ORG_ID
        GROUP BY SUP.ITEM_ID;

        /*Update the period end cost of previous period transactions..*/
        UPDATE MTL_PER_CLOSE_DTLS MPSD
        SET MPSD.PERIOD_END_UNIT_COST =
        (SELECT OLD.PERIOD_END_UNIT_COST FROM
         MTL_PER_CLOSE_DTLS OLD
         WHERE OLD.ACCT_PERIOD_ID       = l_last_period_id      AND
         OLD.INVENTORY_ITEM_ID          = MPSD.INVENTORY_ITEM_ID        AND
         OLD.COST_GROUP_ID              =       l_default_cost_group_id AND --2769970
         OLD.SECONDARY_INVENTORY        IS NULL                         AND
         OLD.ORGANIZATION_ID            =       I_ORG_ID)
        WHERE MPSD.SECONDARY_INVENTORY  IS NULL                         AND
        MPSD.COST_GROUP_ID              =       l_default_cost_group_id AND --2769970
        MPSD.ACCT_PERIOD_ID             =       I_ACCT_PERIOD_ID        AND
        MPSD.ORGANIZATION_ID            =       I_ORG_ID;

	l_stmt_num:=20; /* last tuned in bug 2881225 */


	/*----------------------------------------------------
	| Insert into the details table, all new and unique
	| combinations of Cost Grp/Item/Sub from the transactions
	| table.
	| We need to insert only data relevant to asset sub-
	| inventories. So we need to join to mtl_secondary_
	| inventories to check this.
	|
	| Open Issue:
	| Go through the entire transaction set and see if we
	| need to exclude any transactions here. By specifying
 	| subinventory_code is not null, we have ensured that
	| scrap and avg cost update do not get considered.
	|------------------------------------------------------+*/


	INSERT INTO MTL_PER_CLOSE_DTLS
        (COST_GROUP_ID,
         ACCT_PERIOD_ID,
         SECONDARY_INVENTORY,
         INVENTORY_ITEM_ID,
         ORGANIZATION_ID,
         PERIOD_END_QUANTITY,
         period_end_unit_cost,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATED_BY,
         CREATION_DATE,
         PROGRAM_ID,
         PROGRAM_APPLICATION_ID,
         LOGIN_ID)
	SELECT
	 NVL(COST_GROUP_ID,-9999),
	 I_ACCT_PERIOD_ID,
	 SUBINVENTORY_CODE,
 	 INVENTORY_ITEM_ID,
	 I_ORG_ID,
	 0,
	 0,
 	 SYSDATE,
	 i_user_id,
	 i_user_id,
	 SYSDATE,
 	 i_prog_id,
	 i_prog_appl_id,
	 i_user_id
	FROM
	MTL_MATERIAL_TRANSACTIONS MMT,
	MTL_SECONDARY_INVENTORIES SUB
	WHERE
	MMT.ORGANIZATION_ID		=	I_ORG_ID		AND
	MMT.ORGANIZATION_ID		= nvl(MMT.OWNING_ORGANIZATION_ID, MMT.ORGANIZATION_ID) AND
	NVL(MMT.OWNING_TP_TYPE,2)	= 2				AND
	MMT.ACCT_PERIOD_ID		>	l_LAST_PERIOD_ID AND
	MMT.ACCT_PERIOD_ID		<=	I_ACCT_PERIOD_ID	AND
	MMT.SUBINVENTORY_CODE		IS NOT NULL			AND
	MMT.COSTED_FLAG			IS NULL				AND
	MMT.SUBINVENTORY_CODE		=	SUB.SECONDARY_INVENTORY_NAME
									AND
	MMT.ORGANIZATION_ID		=	SUB.ORGANIZATION_ID	AND
	SUB.ASSET_INVENTORY		=	1
        MINUS
        SELECT
          NVL(COST_GROUP_ID,-9999),
          i_acct_period_id,
          SECONDARY_INVENTORY,
          INVENTORY_ITEM_ID,
          i_org_id,
          0,
          0,
          SYSDATE,
          i_user_id,
          i_user_id,
          SYSDATE,
  	  i_prog_id,
	  i_prog_appl_id,
	  i_user_id
        FROM
          MTL_PER_CLOSE_DTLS MPCD
        WHERE
          MPCD.organization_id = i_org_id AND
          MPCD.acct_period_id = i_acct_period_id AND
          MPCD.secondary_inventory IS NOT NULL;

	l_stmt_num:=30;

	/*-------------------------------------------------------++
	| Update quantities from the transaction table, for all
	| rows in MTL_PER_CLOSE_DTLS table, based on all
	| the transactions that have occured during the period.
	|-------------------------------------------------------+*/


        l_sum_period_qty := 0;
        l_cost_group_id := 0;
        l_item_id := 0;
        l_subinv_code := NULL;

        open cur_mmt_qty(l_LAST_PERIOD_ID,I_ACCT_PERIOD_ID,I_ORG_ID);
        LOOP
                FETCH cur_mmt_qty INTO l_sum_period_qty,l_cost_group_id,l_item_id,l_subinv_code;

                EXIT WHEN cur_mmt_qty%NOTFOUND;

                UPDATE MTL_PER_CLOSE_DTLS MPSD
                SET PERIOD_END_QUANTITY = NVL(l_sum_period_qty,0)+NVL(PERIOD_END_QUANTITY,0)
                WHERE
                        MPSD.ACCT_PERIOD_ID             = I_ACCT_PERIOD_ID
                AND     MPSD.ORGANIZATION_ID            = I_ORG_ID
                AND     MPSD.COST_GROUP_ID              = l_cost_group_id
                AND     MPSD.INVENTORY_ITEM_ID          = l_item_id
                AND     MPSD.SECONDARY_INVENTORY        = l_subinv_code;

        END LOOP;
        close cur_mmt_qty;



	l_stmt_num:=32;

	/*------------------------------------------+
	| Pick up the schedule_close_date of the last
	| period that was closed ...
	|--------------------------------------*/

	IF (i_last_period_id is NOT NULL AND i_last_period_id>0) THEN

	SELECT
	SCHEDULE_CLOSE_DATE
	INTO l_last_close_date
	FROM
	ORG_ACCT_PERIODS
	WHERE
	ORGANIZATION_ID		=	I_ORG_ID	AND
	ACCT_PERIOD_ID		=	I_LAST_PERIOD_ID;

	END IF;

	l_stmt_num := 33;

	l_stmt_num := 37;

	/*-----------------------------------------------------
	| Populate Org related Intransit information :
	| This includes
 	| (i) Items 'in transit' that have been
	| shipped to this Org from other orgs, obviously,
	| the fob point being shipment in this case
	| and
	| (ii)Items 'in transit' that hav been shipped from
	|     this org to another org and the fob is
	|     receipt in this case.
	| Note : We dont have to verify the fob because
	|        MTL_SUPPLY stores the intransit_owning_org_id.
	| Note : We take a fresh snapshot of Intransit info
	|	 for each run, therefore, sum from the beginning
	| 	 of time until now.
	|-----------------------------------------------------*/

        INSERT INTO MTL_PER_CLOSE_DTLS
        (COST_GROUP_ID,
         ACCT_PERIOD_ID,
         SECONDARY_INVENTORY,
         INVENTORY_ITEM_ID,
         ORGANIZATION_ID,
         PERIOD_END_QUANTITY,
         period_end_unit_cost,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATED_BY,
         CREATION_DATE,
         PROGRAM_ID,
         PROGRAM_APPLICATION_ID,
         LOGIN_ID)
	SELECT
	 l_default_cost_group_id, /*1, commented for bug 2769970*/
	 I_ACCT_PERIOD_ID,
	 NULL,
	 SUP.ITEM_ID,
	 I_ORG_ID,
	 SUM(DECODE(TO_ORGANIZATION_ID,I_ORG_ID,TO_ORG_PRIMARY_QUANTITY,
		    QUANTITY)),
	 0,
	 SYSDATE,
	 i_user_id,
	 i_user_id,
	 SYSDATE,
	 i_prog_id,
	 i_prog_appl_id,
	 i_user_id
	FROM MTL_SUPPLY SUP,
	     RCV_SHIPMENT_HEADERS RSH
	WHERE
	INTRANSIT_OWNING_ORG_ID		=	I_ORG_ID		AND
	SUP.SUPPLY_TYPE_CODE		IN ('SHIPMENT','RECEIVING')	AND
       (SUP.TO_ORGANIZATION_ID		=	I_ORG_ID		OR
	SUP.FROM_ORGANIZATION_ID	=	I_ORG_ID)		AND
	RSH.SHIPMENT_HEADER_ID		=	SUP.SHIPMENT_HEADER_ID	AND
	EXISTS
	(SELECT 'X'
	 FROM
	 MTL_MATERIAL_TRANSACTIONS MMT
	 WHERE
	 SUP.ITEM_ID			=	MMT.INVENTORY_ITEM_ID	AND
        (       --Added for Bug #1478959 in 11.0 .... Porting the changes to 11.5 Bug 1521581*/
	(SUP.FROM_ORGANIZATION_ID	=	MMT.ORGANIZATION_ID	AND
	 SUP.TO_ORGANIZATION_ID		=	MMT.TRANSFER_ORGANIZATION_ID
									AND
	 SUP.INTRANSIT_OWNING_ORG_ID	=	MMT.TRANSFER_ORGANIZATION_ID)
	 OR
	(SUP.FROM_ORGANIZATION_ID	=	MMT.ORGANIZATION_ID	AND
	 SUP.INTRANSIT_OWNING_ORG_ID	=	MMT.ORGANIZATION_ID	AND
	 SUP.TO_ORGANIZATION_ID		=	MMT.TRANSFER_ORGANIZATION_ID)
        )       --Added for Bug #1478959 in 11.0 .... Porting the changes to 11.5 Bug 1521581*/
	 								AND
	 RSH.SHIPMENT_NUM		=	MMT.SHIPMENT_NUMBER	AND
	 MMT.COSTED_FLAG		IS	NULL			AND
	 MMT.TRANSACTION_DATE		<=	(trunc(L_ACCT_CLOSE_DATE) + 0.99999))
									AND
	 SUP.INTRANSIT_OWNING_ORG_ID	=	I_ORG_ID		AND
	 NOT EXISTS
	 (SELECT 'X'
	  FROM
	  MTL_PER_CLOSE_DTLS MPSD
	  WHERE
	  MPSD.INVENTORY_ITEM_ID	=	SUP.ITEM_ID		AND
	  MPSD.ORGANIZATION_ID		=	I_ORG_ID		AND
	  MPSD.COST_GROUP_ID		=	l_default_cost_group_id AND --2769970
	  MPSD.ACCT_PERIOD_ID		=	I_ACCT_PERIOD_ID	AND
	  MPSD.SECONDARY_INVENTORY	IS	NULL)
	 GROUP BY SUP.ITEM_ID;




	l_stmt_num:=40; /* last tuned in bug 2881225 */

	/*---------------------------------------------------------
	| Update the period_end_unit_cost for rows in MPSD. The logic
 	| for updating this is below:
	| The value in any subinventory, of a given item, at period
	| end is the quantity valued at the 'Avg cost of the item
	| after the last transaction in that period'. The last
	| transaction for an item in a period is identfied by the
	| transaction that has the latest transaction_costed_date
	| for that item in the period. The new_cost corresponding to
 	| this transaction represents the cost we need.
	|
	| Open issue: make sure that cost processor updates this
	| column in MMT for every transaction and also make sure
	| that no transaction needs to be excluded from this list.
	|
	| Inter-Org shipments
	| -------------------
	|
	| When an inter-org intransit transaction is performed
	| to an average costing organization, with fob = SHIP,
	| the cost in the destination org gets averaged at the
	| the time of shipment. Such a txn needs to be considered
	| when looking for the max(txn_costed_date).
	| In a project scenario, where multiple cost groups
	| could exist, intransit is always belonging to the
	| common cost group ==> when checking if a shipment
	| transaction is the last txn, we check only if Cg = 1.
	| Also, we should check for such a txn only if that
	| txn has been costed on a date that falls within the
	| current period in the org for which the period is
	| being closed.
	|
	|-----------------------------------------------------*/

	/*--------------------------------------------------------
	| Txfr txn cost processing architecture is now going to
	| involve creating 2 rows in MACD, onr for each Cost grp
 	| involved in the txn. The following considerations are
	| pertinent:
	| * For Direct Org txfrs, both sides of the txn will have
	|   corresponding rows in MACD.
	| * For intransit shipments(fob=RCV), Intransit Receipts
	|   (fob=SHP), Sub txfrs --> The same txn will have 2
	|   sets of rows in MACD, one for each CG involved.
	|   Both these rows are for the same org however.
	|   In the case of the Intransit txns, there is only 1
	|   physical txn, however in the case of the sub txfr,
	|   there are 2 physical txn_id's in MMT. The txn with
	|   -ve qtty gets costed.
	| * For Intransit shipments (fob=ship) and Intransit
	|   receipts (fob=rcv) --> There will be 1 physical
	|   txn in MMT, yet 2 rows in MACD. The 2 rows will
	|   be for 2 different orgs. Note that the cost workers
	|   of both orgs process this txn. ==> When the first
	|   worker finishes with the txn, it sets
	|   the shipment_costed flag = 'y' in MMT.
	|   ##For the shipment case, after the shipping org
	|   worker finishes the txn, the ship_cstd = 'y', and
	|   then the rcv org worker processes the txn,after
	|   which the costed_flag is set to NULL. However,
	|   since the txn in MMT is with org_id = SHip org,
	|   the period in the shipment org cannot be closed
	|   till the costed_flag = NULL. Also, the rcv org
	|   costs/books get affected only when the costed_flag
	|   is set to NULL ==> we dont have to bother with the'
	|   shipment_costed in this case.
	|   ##For the receipt case the physical txn is against
	|   the recv org. The shipping org worker first processes
	|   the txn and then sets shipment_costed='y'; at this
	|   point, it is possible to close the sending org
	|   period, and this txn would have affected the books
	|   for the SND org though the costed_flag = NULL and
 	|   the rcv org books have not been affected.
	|   Txn			Action_id
	|   ---			---------
	|   Direct Org		 3
	|   Intransit ship	 21
	|   Intransit Rcv	 12
	|   Sub Txfr  		 2
	|
	|   Fob_pt 		 1 ==> SHP
	|   Fob_pt		 2 ==> RCV
	|--------------------------------------------------------------+*/

        OPEN cur_per_close_dtls(i_org_id,i_acct_period_id);
	LOOP
		FETCH cur_per_close_dtls INTO l_cost_group_id, l_item_id;
		EXIT WHEN cur_per_close_dtls%NOTFOUND;

		OPEN cur_get_mcacd_id(l_item_id,i_org_id,l_cost_group_id,l_last_period_id,i_acct_period_id,l_last_close_date,l_acct_close_date);
		FETCH cur_get_mcacd_id INTO l_trans_id;
		IF cur_get_mcacd_id%NOTFOUND THEN
			l_trans_id := -1;
		END IF;
		CLOSE cur_get_mcacd_id;

		IF l_trans_id >= 0 THEN

	UPDATE mtl_per_close_dtls mpsd
        SET
	(period_end_unit_cost
	 ) =
	(SELECT
	 nvl(sum(macd.new_cost),period_end_unit_cost)
	 FROM
	 mtl_cst_actual_cost_details macd,
	 cst_quantity_layers layer
	 WHERE
	 macd.inventory_item_id	=	mpsd.inventory_item_id	AND
	 macd.organization_id	=	i_org_id		AND
	 macd.layer_id		=	layer.layer_id		AND
	 layer.cost_group_id	=	mpsd.cost_group_id	AND
	 macd.transaction_id    = l_trans_id
	 GROUP BY macd.transaction_id)
	WHERE
	mpsd.organization_id		=	i_org_id		AND
	mpsd.acct_period_id		=	i_acct_period_id	AND
	mpsd.cost_group_id = l_cost_group_id AND
	mpsd.inventory_item_id = l_item_id;
	END IF;

	END LOOP;
	CLOSE cur_per_close_dtls;

	l_stmt_num:=50;

	IF (l_wms_flg = 1)
	THEN
    	   INSERT INTO MTL_PERIOD_CG_SUMMARY
        	(ACCT_PERIOD_ID,
         	ORGANIZATION_ID,
         	INVENTORY_TYPE,
         	COST_GROUP_ID,
         	LAST_UPDATE_DATE,
         	LAST_UPDATED_BY,
         	CREATION_DATE,
         	CREATED_BY,
         	LAST_UPDATE_LOGIN,
         	INVENTORY_VALUE,
         	REQUEST_ID,
         	PROGRAM_APPLICATION_ID,
         	PROGRAM_ID,
         	PROGRAM_UPDATE_DATE)
          SELECT
         	I_ACCT_PERIOD_ID,
         	I_ORG_ID,
         	1,
         	COST_GROUP_ID,
         	SYSDATE,
         	i_user_id,
         	SYSDATE,
         	i_user_id,
         	i_user_id,
         	SUM(NVL(PERIOD_END_QUANTITY,0)*NVL(period_end_unit_cost,0)),
         	NULL,
         	i_prog_id,
         	i_prog_appl_id,
         	SYSDATE
          FROM
                MTL_PER_CLOSE_DTLS
          WHERE
        	ACCT_PERIOD_ID          =       I_ACCT_PERIOD_ID        AND
        	ORGANIZATION_ID         =       I_ORG_ID
          GROUP BY COST_GROUP_ID;

     ELSE

	INSERT INTO MTL_PERIOD_SUMMARY
	(ACCT_PERIOD_ID,
	 ORGANIZATION_ID,
	 INVENTORY_TYPE,
	 SECONDARY_INVENTORY,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN,
	 INVENTORY_VALUE,
	 REQUEST_ID,
	 PROGRAM_APPLICATION_ID,
	 PROGRAM_ID,
	 PROGRAM_UPDATE_DATE)
	SELECT
	 I_ACCT_PERIOD_ID,
	 I_ORG_ID,
	 1,
	 SECONDARY_INVENTORY,
 	 SYSDATE,
	 i_user_id,
	 SYSDATE,
         i_user_id,
         i_user_id,
	 SUM(NVL(PERIOD_END_QUANTITY,0)*NVL(period_end_unit_cost,0)),
	 NULL,
	 i_prog_id,
	 i_prog_appl_id,
	 SYSDATE
	FROM
	MTL_PER_CLOSE_DTLS
	WHERE
	ACCT_PERIOD_ID		=	I_ACCT_PERIOD_ID	AND
	ORGANIZATION_ID		=	I_ORG_ID
	GROUP BY SECONDARY_INVENTORY;

     END IF;

	l_stmt_num:=60;

	commit;

   EXCEPTION

        WHEN OTHERS THEN
        err_num := SQLCODE;
        err_msg := 'CSTACPCS:' || to_char(l_stmt_num) || substr(SQLERRM,1,150);

	rollback;

END summarize_value;

END CSTACPCS;

/
