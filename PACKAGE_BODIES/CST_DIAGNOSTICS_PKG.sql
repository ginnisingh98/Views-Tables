--------------------------------------------------------
--  DDL for Package Body CST_DIAGNOSTICS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_DIAGNOSTICS_PKG" AS
/* $Header: CSTDIAGB.pls 120.0.12000000.3 2007/09/25 00:07:47 anjha noship $ */

 /*---------------------------------------------------------------------------
|  FUNCTION     :   TEMP_PO_TAX
|  DESCRIPTION  :   Calculates po tax
----------------------------------------------------------------------------*/
FUNCTION TEMP_PO_TAX(i_txn_id in  number)
RETURN NUMBER IS

    l_tax number;
  BEGIN
    SELECT nvl((SUM( nvl(pod.nonrecoverable_tax,0))
					     /SUM(pod.quantity_ordered)),0)
      INTO l_tax
      FROM  po_distributions_all pod,
	    rcv_transactions rt9
     WHERE RT9.TRANSACTION_ID = i_txn_id
       AND (
	     (  RT9.PO_DISTRIBUTION_ID IS NOT NULL
		AND RT9.PO_DISTRIBUTION_ID = POD.PO_DISTRIBUTION_ID )
	    OR
	     (  RT9.PO_DISTRIBUTION_ID IS NULL
		AND RT9.PO_LINE_LOCATION_ID = POD.LINE_LOCATION_ID)
	   );

   RETURN l_tax;
END temp_po_tax;

/*---------------------------------------------------------------------------
|  PROCEDURE    :   TEMP_PO_RATE
|  DESCRIPTION  :   Calculates po_rate.
----------------------------------------------------------------------------*/

FUNCTION TEMP_PO_RATE(i_txn_id in  number)
RETURN NUMBER  IS

   l_rate number;

 BEGIN
   SELECT
	  SUM(pod.quantity_ordered*nvl(pod.rate,1))/SUM(pod.quantity_ordered)
	  INTO l_rate
     FROM po_distributions_all pod,
	  rcv_transactions rct,
	  po_headers_all poh
    WHERE rct.transaction_id = i_txn_id
      AND pod.po_header_id = poh.po_header_id
      AND (
	    (RCT.PO_DISTRIBUTION_ID IS NOT NULL
	       AND RCT.PO_DISTRIBUTION_ID = POD.PO_DISTRIBUTION_ID)
	 OR
	    (RCT.PO_DISTRIBUTION_ID IS NULL
	       AND RCT.PO_LINE_LOCATION_ID = POD.LINE_LOCATION_ID)
	  );

  RETURN l_rate;
END temp_po_rate;

/*---------------------------------------------------------------------------
|  PROCEDURE    :   Check_Orphaned
|  DESCRIPTION  :   Checks the orphaned transactions for a WIP flow schedule
|                   Completion transaction.
----------------------------------------------------------------------------*/
PROCEDURE CHECK_ORPHANED
                (TXN_ID         IN NUMBER,
                 L_ORG_ID       IN NUMBER) IS
L_C_TXN_ID          NUMBER:=NULL;
L_COSTED_FLAG       VARCHAR(2);

BEGIN
SELECT COMPLETION_TRANSACTION_ID
INTO   L_C_TXN_ID
FROM   MTL_MATERIAL_TRANSACTIONS
WHERE  TRANSACTION_ID     =TXN_ID
AND    ORGANIZATION_ID    =L_ORG_ID;

IF L_C_TXN_ID IS NULL
THEN
     INSERT INTO CST_DIAG_TXN_ERRORS (TRANSACTION_ID,
	ERROR_MESSAGE,RESOLUTION)
	VALUES(TXN_ID,'COMPLETION TRANSACTION_ID NOT STAMPED.',NULL);
ELSE
     SELECT COSTED_FLAG
       INTO L_COSTED_FLAG
       FROM MTL_MATERIAL_TRANSACTIONS
      WHERE COMPLETION_TRANSACTION_ID = L_C_TXN_ID
        AND TRANSACTION_SOURCE_TYPE_ID = 5
        AND TRANSACTION_ACTION_ID NOT IN (1, 27, 33, 34);

       IF ( L_COSTED_FLAG IS NULL) THEN
            INSERT INTO CST_DIAG_TXN_ERRORS(TRANSACTION_ID,
	    ERROR_MESSAGE,RESOLUTION)
            VALUES(TXN_ID,'COMPLETION COSTED-ORPHANED TRANSACTION',NULL);
   END IF;
END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
     INSERT INTO CST_DIAG_TXN_ERRORS (TRANSACTION_ID,
     ERROR_MESSAGE,RESOLUTION)
     VALUES(TXN_ID,'INCORRECT COMPLETION_TRANSACTION_ID',NULL);
 END;


/*---------------------------------------------------------------------------
|  PROCEDURE    :   Get_Stuck_Txn_Info
|  DESCRIPTION  :   Checks for the bottle neck transactions for Actual costing
|                   Organizations.
----------------------------------------------------------------------------*/
PROCEDURE Get_Stuck_Txn_Info AS
 CURSOR ALL_ACTUAL_COSTING_ORGS IS
   SELECT MP.ORGANIZATION_ID
    FROM MTL_PARAMETERS MP
   WHERE MP.PRIMARY_COST_METHOD IN (2,5,6);
 L_MIN_DATE DATE;
 L_MIN_TXN NUMBER;
 L_TXN_DATE DATE;
 L_TXN_ORG NUMBER;
 L_TXN_TXFR_ORG NUMBER;
 L_TXN_ACTION_ID NUMBER;
 L_TXN_SOURCE_TYPE_ID NUMBER;
 L_TXN_COST NUMBER;
 L_TXN_SHIPMENT_COSTED VARCHAR2(1);
 L_TXN_MOVE_TXN_ID NUMBER;
 L_TXN_COMP_TXN_ID NUMBER;
 L_TXN_COSTED_FLAG VARCHAR2(1);
 L_TXN_TXFR_TXN_ID NUMBER;
 L_LOGICAL_TXN_CRTD NUMBER;
BEGIN
  delete from CST_DIAG_ERRORED_TXNS;

  FOR ORG_REC IN ALL_ACTUAL_COSTING_ORGS LOOP
SELECT  /*+ INDEX (MMT MTL_MATERIAL_TRANSACTIONS_N10) */
                 TRUNC(NVL(MIN(TRANSACTION_DATE),(SYSDATE+1)))
              INTO    L_MIN_DATE
              FROM    mtl_material_transactions MMT
              WHERE
              nvl(parent_transaction_id, transaction_id) = transaction_id
              AND   costed_flag in ('N', 'E')
              AND
              (
                 (
                    organization_id = ORG_REC.ORGANIZATION_ID
                    AND
                    (
                       costed_flag = 'E'
                       OR
                       (
                          nvl(logical_transactions_created, 1) = 2
                          OR
                          EXISTS (
                                SELECT null
                                FROM mtl_material_transactions_temp MMTP
                                WHERE MMT.transaction_action_id IN (30, 31)
                                AND   MMT.organization_id = MMTP.organization_id
                                AND  (MMT.COMPLETION_TRANSACTION_ID = MMTP.COMPLETION_TRANSACTION_ID
                                      -- Added for bug 4256685
                                      OR MMT.MOVE_TRANSACTION_ID = MMTP.move_transaction_id)
                                UNION ALL
                                SELECT null
                                FROM wip_move_txn_interface WMTI
                                WHERE MMT.transaction_action_id IN (30, 31)
                                AND   WMTI.TRANSACTION_ID = MMT.MOVE_TRANSACTION_ID
                               )
                       )
                       OR
                       (
                          costed_flag = 'N'
                          AND
                          (
                             EXISTS (
                                   SELECT null
                                   FROM   mtl_parameters
                                   WHERE  organization_id = MMT.transfer_organization_id
                                   AND    primary_cost_method IN (2,5,6)
                                )
                             AND
                             (
                                (
                                   transaction_action_id = 3
                                   AND primary_quantity > 0
                                   AND transaction_cost IS NULL
                                )
                                OR
                                (
                                   exists (select null
                                           from mtl_interorg_parameters   MIP
                                           where transaction_action_id = 12
                                           AND MIP.to_organization_id = MMT.organization_id
                                           AND MIP.from_organization_id = MMT.transfer_organization_id
                                           AND NVL(MMT.fob_point,MIP.fob_point) = 2
                                           AND shipment_costed IS NULL
                                   )
                                )
                             )
                          )
                       )
                    )
                 )
                 OR
                 (
                    transfer_organization_id = ORG_REC.ORGANIZATION_ID
                    AND costed_flag = 'N'
                    AND
                    (
                       exists (select null
                               from mtl_interorg_parameters   MIP
                               where transaction_action_id = 21
                               AND MIP.to_organization_id = MMT.transfer_organization_id
                               AND MIP.from_organization_id = MMT.organization_id
                               AND NVL(MMT.fob_point,MIP.fob_point) = 1
                               AND shipment_costed IS NULL
                               AND EXISTS (
                                    SELECT null
                                    FROM   mtl_parameters
                                    WHERE  organization_id = MMT.organization_id
                                    AND    primary_cost_method IN (2,5,6)
                                  )
                       )
                       OR
                       (
                          EXISTS (
                               SELECT null
                               FROM   mtl_parameters
                               WHERE  organization_id = MMT.organization_id
                               AND    primary_cost_method = 1
                               AND    cost_cutoff_date is not null
                               AND    MMT.transaction_date >= cost_cutoff_date
                             )
                          AND
                          (
                             transaction_action_id = 3
                             AND primary_quantity < 0
                          )
                       )
                    )
                 )
                 OR
                 (
                    costed_flag = 'N'
                    AND
                    exists (select null
                            from mtl_interorg_parameters   MIP
                            where
                            (
                               transaction_action_id = 21
                               AND MIP.to_organization_id = MMT.transfer_organization_id
                               AND MIP.from_organization_id = MMT.organization_id
                               AND NVL(MMT.fob_point,MIP.fob_point) = 1
                            )
                            OR
                            (
                               transaction_action_id = 12
                               AND MIP.to_organization_id = MMT.organization_id
                               AND MIP.from_organization_id = MMT.transfer_organization_id
                               AND NVL(MMT.fob_point,MIP.fob_point) = 2
                            )
                    )
                    AND
                    EXISTS (
                         SELECT null
                         FROM   mtl_parameters
                         WHERE
                         primary_cost_method = 1
                         AND    cost_cutoff_date is not null
                         AND    MMT.transaction_date >= cost_cutoff_date
                         AND
                         (
                            (
                               MMT.organization_id = ORG_REC.ORGANIZATION_ID
                               AND organization_id = MMT.transfer_organization_id
                            )
                            OR
                            (
                               MMT.transfer_organization_id = ORG_REC.ORGANIZATION_ID
                               ANd organization_id = MMT.organization_id
                            )
                         )
                    )
                 )
              );


 SELECT  /*+ INDEX (MMT MTL_MATERIAL_TRANSACTIONS_N10) */
                      NVL(MIN(TRANSACTION_ID),-1)
              INTO    L_MIN_TXN
              FROM    mtl_material_transactions MMT
              WHERE
              transaction_date < (L_MIN_DATE+1)
              AND     transaction_date >= L_MIN_DATE
              AND     nvl(parent_transaction_id, transaction_id) = transaction_id
              AND   costed_flag in ('N', 'E')
              AND
              (
                 (
                    organization_id = ORG_REC.ORGANIZATION_ID
                    AND
                    (
                       costed_flag = 'E'
                       OR
                       (
                          nvl(logical_transactions_created, 1) = 2
                          OR
                          EXISTS (
                              SELECT null
                              FROM mtl_material_transactions_temp MMTP
                              WHERE MMT.transaction_action_id IN (30, 31)
                              AND   MMT.organization_id = MMTP.organization_id
                              AND  (MMT.COMPLETION_TRANSACTION_ID = MMTP.COMPLETION_TRANSACTION_ID
                                    -- Added for bug 4256685
                                    OR MMT.MOVE_TRANSACTION_ID = MMTP.move_transaction_id)
                              UNION ALL
                              SELECT null
                              FROM wip_move_txn_interface WMTI
                              WHERE MMT.transaction_action_id IN (30, 31)
                              AND   WMTI.TRANSACTION_ID = MMT.MOVE_TRANSACTION_ID
                          )
                       )
                       OR
                       (
                          costed_flag = 'N'
                          AND
                          (
                             EXISTS (
                                SELECT null
                                FROM   mtl_parameters
                                WHERE  organization_id = MMT.transfer_organization_id
                                AND    primary_cost_method IN (2,5,6)
                             )
                             AND
                             (
                                (
                                   transaction_action_id = 3
                                   AND primary_quantity > 0
                                   AND transaction_cost IS NULL
                                )
                                OR
                                (
                                   exists (
                                      select null
                                      from mtl_interorg_parameters   MIP
                                      where transaction_action_id = 12
                                      AND MIP.to_organization_id = MMT.organization_id
                                      AND MIP.from_organization_id = MMT.transfer_organization_id
                                      AND NVL(MMT.fob_point,MIP.fob_point) = 2
                                      AND shipment_costed IS NULL
                                   )
                                )
                             )
                          )
                       )
                    )
                 )
                 OR
                 (
                    transfer_organization_id = ORG_REC.ORGANIZATION_ID
                    AND costed_flag = 'N'
                    AND
                    (
                       exists (
                          select null
                          from mtl_interorg_parameters   MIP
                          where transaction_action_id = 21
                          AND MIP.to_organization_id = MMT.transfer_organization_id
                          AND MIP.from_organization_id = MMT.organization_id
                          AND NVL(MMT.fob_point,MIP.fob_point) = 1
                          AND shipment_costed IS NULL
                          AND EXISTS (
                               SELECT null
                               FROM   mtl_parameters
                               WHERE  organization_id = MMT.organization_id
                               AND    primary_cost_method IN (2,5,6)
                          )
                       )
                       OR
                       (
                          EXISTS (
                             SELECT null
                             FROM   mtl_parameters
                             WHERE  organization_id = MMT.organization_id
                             AND    primary_cost_method = 1
                             AND    cost_cutoff_date is not null
                             AND    MMT.transaction_date >= cost_cutoff_date
                          )
                          AND
                          (
                             transaction_action_id = 3
                             AND primary_quantity < 0
                          )
                       )
                    )
                 )
                 OR
                 (
                    costed_flag = 'N'
                    AND
                    exists (
                       select null
                       from mtl_interorg_parameters   MIP
                       where
                       (
                          transaction_action_id = 21
                          AND MIP.to_organization_id = MMT.transfer_organization_id
                          AND MIP.from_organization_id = MMT.organization_id
                          AND NVL(MMT.fob_point,MIP.fob_point) = 1
                       )
                       OR
                       (
                          transaction_action_id = 12
                          AND MIP.to_organization_id = MMT.organization_id
                          AND MIP.from_organization_id = MMT.transfer_organization_id
                          AND NVL(MMT.fob_point,MIP.fob_point) = 2
                       )
                    )
                    AND
                    EXISTS (
                       SELECT null
                       FROM   mtl_parameters
                       WHERE
                       primary_cost_method = 1
                       AND    cost_cutoff_date is not null
                       AND    MMT.transaction_date >= cost_cutoff_date
                       AND
                       (
                          (
                             MMT.organization_id = ORG_REC.ORGANIZATION_ID
                             AND organization_id = MMT.transfer_organization_id
                          )
                          OR
                          (
                             MMT.transfer_organization_id = ORG_REC.ORGANIZATION_ID
                             ANd organization_id = MMT.organization_id
                          )
                       )
                    )
                 )
              );

   IF ( L_MIN_TXN <>-1) THEN
      SELECT TRANSACTION_DATE,
             ORGANIZATION_ID,
             TRANSFER_ORGANIZATION_ID,
	     TRANSFER_TRANSACTION_ID,
             TRANSACTION_ACTION_ID,
             TRANSACTION_SOURCE_TYPE_ID,
             TRANSACTION_COST,
             SHIPMENT_COSTED,
             MOVE_TRANSACTION_ID,
             COMPLETION_TRANSACTION_ID,
             COSTED_FLAG,
	     nvl(logical_transactions_created, 1)
       INTO
             L_TXN_DATE,
             L_TXN_ORG,
             L_TXN_TXFR_ORG,
	     L_TXN_TXFR_TXN_ID,
             L_TXN_ACTION_ID,
             L_TXN_SOURCE_TYPE_ID,
             L_TXN_COST,
             L_TXN_SHIPMENT_COSTED,
             L_TXN_MOVE_TXN_ID,
             L_TXN_COMP_TXN_ID,
             L_TXN_COSTED_FLAG,
	           L_LOGICAL_TXN_CRTD
       FROM MTL_MATERIAL_TRANSACTIONS
      WHERE TRANSACTION_ID = L_MIN_TXN;



    INSERT INTO CST_DIAG_ERRORED_TXNS
     (  ORGANIZATION_ID,
	BOTTLE_NECK_TXN_ID,
	TRANSACTION_DATE,
	TRANSACTION_ORGANIZATION_ID,
	TRANSFER_ORGANIZATION_ID,
	TRANSFER_TRANSACTION_ID,
	TRANSACTION_ACTION_ID,
	TRANSACTION_SOURCE_TYPE_ID,
	TRANSACTION_COST,
	SHIPMENT_COSTED,
	MOVE_TRANSACTION_ID,
	COMPLETION_TRANSACTION_ID,
	COSTED_FLAG,
	WAITING_ORGANIZATION_ID,
	LOGICAL_TXN_CREATED
      )
      VALUES ( ORG_REC.ORGANIZATION_ID,
               L_MIN_TXN,
               L_TXN_DATE,
               L_TXN_ORG,
               L_TXN_TXFR_ORG,
	       L_TXN_TXFR_TXN_ID,
               L_TXN_ACTION_ID,
               L_TXN_SOURCE_TYPE_ID,
               L_TXN_COST,
               L_TXN_SHIPMENT_COSTED,
               L_TXN_MOVE_TXN_ID,
               L_TXN_COMP_TXN_ID,
               L_TXN_COSTED_FLAG,
	       DECODE(L_TXN_ACTION_ID,
	                 21,L_TXN_ORG,
			 3,L_TXN_TXFR_ORG,
			 12,L_TXN_TXFR_ORG,
		      NULL),
	       L_LOGICAL_TXN_CRTD
             );
   ELSE

       INSERT INTO CST_DIAG_ERRORED_TXNS
     (  ORGANIZATION_ID,
	BOTTLE_NECK_TXN_ID,
	TRANSACTION_DATE,
	TRANSACTION_ORGANIZATION_ID,
	TRANSFER_ORGANIZATION_ID,
	TRANSFER_TRANSACTION_ID,
	TRANSACTION_ACTION_ID,
	TRANSACTION_SOURCE_TYPE_ID,
	TRANSACTION_COST,
	SHIPMENT_COSTED,
	MOVE_TRANSACTION_ID,
	COMPLETION_TRANSACTION_ID,
	COSTED_FLAG,
	WAITING_ORGANIZATION_ID,
	LOGICAL_TXN_CREATED
      )
      VALUES ( ORG_REC.ORGANIZATION_ID,
               NULL,
               NULL,
               NULL,
	       NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
	       NULL,
	       NULL
             );

   END IF;


  END LOOP;
END  Get_Stuck_Txn_Info;

/*---------------------------------------------------------------------------
|  FUNCTION     :   Cost_Cutoff_Date
|  DESCRIPTION  :   Checks for the Cost Cut-Off date for the organizations
|                   for customers on and above release 11.5.7.
---------------------------------------------------------------------------*/

FUNCTION COST_CUTOFF_DATE(P_ORG_ID IN NUMBER) RETURN DATE IS
P_COST_CUTOFF_DATE  DATE;
L_RELEASE           VARCHAR2(10);
BEGIN

SELECT RELEASE_NAME
  INTO L_RELEASE
FROM FND_PRODUCT_GROUPS;

IF (L_RELEASE IN ('11.5.7','11.5.8','11.5.9','11.5.10'))
THEN
   SELECT NVL(COST_CUTOFF_DATE,SYSDATE+1)
     INTO P_COST_CUTOFF_DATE
     FROM MTL_PARAMETERS
    WHERE ORGANIZATION_ID = P_ORG_ID;
ELSE
    P_COST_CUTOFF_DATE :=SYSDATE+1;
END IF;

 RETURN(P_COST_CUTOFF_DATE);
END COST_CUTOFF_DATE;

/*---------------------------------------------------------------------------
|  PROCEDURE    :   Check_Transactions_MMT
|  DESCRIPTION  :   Spools the transactions of MMT and checks for
|                   the reason why costing is stuck for the transactions.
---------------------------------------------------------------------------*/

PROCEDURE Check_Transactions_MMT
( ORGANIZATION_ID       NUMBER)
AS
CURSOR C_UNCOSTED_TRANSACTIONS(ORG_ID NUMBER) IS
      SELECT TRANSACTION_ID,
	     INVENTORY_ITEM_ID,
	     TRANSACTION_DATE,
	     TRANSACTION_GROUP_ID,
	     TRANSACTION_ACTION_ID,
	     TRANSACTION_SOURCE_TYPE_ID,
	     COMPLETION_TRANSACTION_ID,
	     FLOW_SCHEDULE,
	     ORGANIZATION_ID,
	     TRANSFER_ORGANIZATION_ID,
       TRANSFER_TRANSACTION_ID,
	     COSTED_FLAG
      FROM MTL_MATERIAL_TRANSACTIONS
       WHERE ORGANIZATION_ID     =ORG_ID
       AND   COSTED_FLAG         ='N';

L_MIN_REQUEST_ID  NUMBER :=NULL;
COST_MANAGER_INACTIVE EXCEPTION;
L_ORGANIZATION_ID       NUMBER;
L_PRIMARY_COST_METHOD   NUMBER;
L_WSM_FLAG              VARCHAR2(1);
L_COST_CUTOFF_DATE      DATE;
L_RELEASE               VARCHAR2(20);
L_TXN_ACTION            VARCHAR2(200);
L_COSTED_FLAG           VARCHAR2(1);
L_MIN_TXN_DTE           DATE;
L_LOT_FLAG              NUMBER;
NOTE1                   VARCHAR2(300);
L_TRANSACTION_GROUP_ID  NUMBER;
L_BOTTLE_NECK_TXN_ID    NUMBER;
L_TXN_DATE              DATE;
L_TXN_ORG               NUMBER;
L_TXN_TXFR_ORG          NUMBER;
L_TXN_TXFR_TXN_ID       NUMBER;
L_TXN_ACTION_ID         NUMBER;
L_TXN_SOURCE_TYPE_ID    NUMBER;
L_TXN_COST              NUMBER;
L_TXN_SHIPMENT_COSTED   NUMBER;
L_TXN_MOVE_TXN_ID       NUMBER;
L_TXN_COMP_TXN_ID       NUMBER;
L_TXN_COSTED_FLAG       VARCHAR(2);
L_WAITING_ORG           NUMBER;
L_MMTT_COUNT            NUMBER;
L_TRANSFER_COST         NUMBER:=0;
L_SHIPMENT_COSTED       NUMBER:=0;
L_TRF_ORG_CST_METHOD    NUMBER:=NULL;
L_WMTI_COUNT            NUMBER;
L_LOGICAL_TXN_CRTD      NUMBER;

BEGIN
        DELETE FROM  CST_DIAG_TXN_ERRORS;

	SELECT MIN(FCR.REQUEST_ID)
	INTO L_MIN_REQUEST_ID
	FROM FND_CONCURRENT_REQUESTS FCR
	WHERE FCR.CONCURRENT_PROGRAM_ID IN
	(SELECT CONCURRENT_PROGRAM_ID
	FROM fnd_concurrent_programs
	WHERE concurrent_program_name ='CMCTCM')
	AND FCR.PROGRAM_APPLICATION_ID = 702
	AND FCR.PHASE_CODE <> 'C';

        ----DBMS_OUTPUT.PUT_LINE('CHECKING COST MANAGER ACTIVE');
	IF ( NVL(L_MIN_REQUEST_ID,0) = 0 )
	THEN
	     RAISE COST_MANAGER_INACTIVE;
	END IF;

	L_ORGANIZATION_ID:=ORGANIZATION_ID;

	SELECT  PRIMARY_COST_METHOD,
		NVL(WSM_ENABLED_FLAG,'N')
	  INTO  L_PRIMARY_COST_METHOD,
		L_WSM_FLAG
	FROM    MTL_PARAMETERS
	WHERE   ORGANIZATION_ID = L_ORGANIZATION_ID;

        --DBMS_OUTPUT.PUT_LINE('CHECKING COSTING METHOD: = '|| L_PRIMARY_COST_METHOD || 'WMS FLAG  = '|| L_WSM_FLAG );

	L_COST_CUTOFF_DATE :=COST_CUTOFF_DATE(L_ORGANIZATION_ID);

	--DBMS_OUTPUT.PUT_LINE('COST CUT-OFF DATE : = '|| L_COST_CUTOFF_DATE);

	--DBMS_OUTPUT.PUT_LINE('DELETE TEMP TABLE!!!');

	--DELETE FROM  CST_DIAG_TXN_ERRORS;


	IF (L_PRIMARY_COST_METHOD =1)
	THEN

	--DBMS_OUTPUT.PUT_LINE('STANDARD COSTING NON WSM ENABLED ORGANIZATION');

	FOR ITEM_REC IN C_UNCOSTED_TRANSACTIONS(L_ORGANIZATION_ID) LOOP

	    /* get transfer_org costing method only if TRANSFER_ORGANIZATION_ID is not null */
	    IF (ITEM_REC.TRANSFER_ORGANIZATION_ID is not null) THEN
		SELECT  PRIMARY_COST_METHOD
		  INTO  L_TRF_ORG_CST_METHOD
		FROM    MTL_PARAMETERS
		WHERE   ORGANIZATION_ID = ITEM_REC.TRANSFER_ORGANIZATION_ID;
	    END IF;

		 --DBMS_OUTPUT.PUT_LINE('TXN DATE :='||ITEM_REC.TRANSACTION_DATE);

		IF( ITEM_REC.TRANSACTION_GROUP_ID IS NOT NULL AND ITEM_REC.COSTED_FLAG ='N') THEN
		      --DBMS_OUTPUT.PUT_LINE('TRANSACTION_GROUP_ID IS NOT NULL FOR TRANSACTION WITH COSTED FLAG N');
		      INSERT INTO CST_DIAG_TXN_ERRORS(TRANSACTION_ID,
			ERROR_MESSAGE,RESOLUTION)
		      VALUES(ITEM_REC.TRANSACTION_ID,'TRANSACTION_GROUP_ID NOT NULL',NULL);

		ELSIF ( ITEM_REC.TRANSACTION_DATE >L_COST_CUTOFF_DATE) THEN

		      --DBMS_OUTPUT.PUT_LINE('COST CUTT OFF DATE CHECK');
		      INSERT INTO CST_DIAG_TXN_ERRORS(TRANSACTION_ID,
			ERROR_MESSAGE,RESOLUTION)
		      VALUES(ITEM_REC.TRANSACTION_ID,'TXN DATE IS LATER THEN COST CUTOFF DATE FOR ORG',NULL);
	     ELSIF /* A */
		   ( ITEM_REC.TRANSACTION_ACTION_ID IN (1, 27, 33, 34)
		 AND ITEM_REC.TRANSACTION_SOURCE_TYPE_ID =5
		 AND ITEM_REC.FLOW_SCHEDULE  ='Y' ) THEN
		     --DBMS_OUTPUT.PUT_LINE('ORPHAN CHECK');
		     CHECK_ORPHANED(ITEM_REC.TRANSACTION_ID,L_ORGANIZATION_ID);
	       ELSIF /* B */
		   ( ITEM_REC.TRANSACTION_ACTION_ID NOT IN (2,28,3,55,5)
		 AND ITEM_REC.TRANSFER_TRANSACTION_ID IS NOT NULL ) THEN
		   --DBMS_OUTPUT.PUT_LINE('TRANSFER TRANSACTION_ID CHECK');
		   INSERT INTO CST_DIAG_TXN_ERRORS(TRANSACTION_ID,
		   ERROR_MESSAGE,RESOLUTION)
		   VALUES(ITEM_REC.TRANSACTION_ID,'INCORRECT TRANSFER_TRANSACTION_ID',NULL);
	       ELSIF /* C */
		   ( ITEM_REC.TRANSACTION_ACTION_ID IN (3,21,12) AND NVL(L_TRF_ORG_CST_METHOD,1) <>1 ) THEN
		       --DBMS_OUTPUT.PUT_LINE('RUN CHECKS FOR TRANSFER ORGANIZATION_ID '|| ITEM_REC.TRANSFER_ORGANIZATION_ID);
		       INSERT INTO CST_DIAG_TXN_ERRORS(TRANSACTION_ID,
			ERROR_MESSAGE,RESOLUTION)
		       VALUES(NULL,'RUN CHECKS FOR TRANSFER ORGANIZATION_ID '|| ITEM_REC.TRANSFER_ORGANIZATION_ID,NULL);

		ELSIF /* F Only if WSM is enabled */
		   (L_WSM_FLAG ='Y' AND ITEM_REC.TRANSACTION_SOURCE_TYPE_ID =5) THEN

			  SELECT MIN(TXN_DT)
          INTO L_MIN_TXN_DTE
			    FROM
			   ( SELECT MIN(TRANSACTION_DATE) TXN_DT
			       FROM WIP_COST_TXN_INTERFACE WCTI
			      WHERE WCTI.ORGANIZATION_ID = L_ORGANIZATION_ID
				AND WCTI.ENTITY_TYPE = 5
				AND WCTI.PROCESS_STATUS = 3
			     UNION
			      SELECT MIN(TRANSACTION_DATE)
			    FROM MTL_MATERIAL_TRANSACTIONS MMT
			     WHERE MMT.TRANSACTION_SOURCE_TYPE_ID = 5
			       AND MMT.ORGANIZATION_ID = L_ORGANIZATION_ID
			       AND MMT.COSTED_FLAG = 'E'
			       AND EXISTS (SELECT 1
				  FROM WIP_ENTITIES WE
				  WHERE WE.WIP_ENTITY_ID = MMT.TRANSACTION_SOURCE_ID
				  AND WE.ORGANIZATION_ID = MMT.ORGANIZATION_ID
				  AND WE.ENTITY_TYPE = 5));
			  SELECT 1
			  INTO L_LOT_FLAG
			     FROM MTL_MATERIAL_TRANSACTIONS MMT,
				  WIP_ENTITIES WE
			     WHERE MMT.TRANSACTION_ID =ITEM_REC.TRANSACTION_ID
			       AND MMT.TRANSACTION_SOURCE_TYPE_ID = 5
			       AND WE.WIP_ENTITY_ID = MMT.TRANSACTION_SOURCE_ID
			       AND WE.ORGANIZATION_ID = MMT.ORGANIZATION_ID
			       AND WE.ENTITY_TYPE = 5;

		       IF ( L_LOT_FLAG =1 AND ITEM_REC.TRANSACTION_DATE < L_MIN_TXN_DTE ) THEN
		       INSERT INTO CST_DIAG_TXN_ERRORS(TRANSACTION_ID,
			ERROR_MESSAGE,RESOLUTION)
		       VALUES(ITEM_REC.TRANSACTION_ID,'ERRORED RECORDS IN MMT/WCTI FOR LOT BASED JOB',NULL);
		       END IF;

		 ELSIF( C_UNCOSTED_TRANSACTIONS%ROWCOUNT >0) THEN
		 --DBMS_OUTPUT.PUT_LINE('REPORT COSTING BUG');
		       INSERT INTO CST_DIAG_TXN_ERRORS(TRANSACTION_ID,
			ERROR_MESSAGE,RESOLUTION)
		       VALUES(ITEM_REC.TRANSACTION_ID,'REPORT A BUG WITH COSTING DEVELOPMENT',NULL);
                ELSE
		       INSERT INTO CST_DIAG_TXN_ERRORS(TRANSACTION_ID,
			ERROR_MESSAGE,RESOLUTION)
		       VALUES(NULL,'NO UNCOSTED TRANSACTIONS FOUND!!',NULL);
		 END IF;
	END LOOP;

	END IF;


	IF (L_PRIMARY_COST_METHOD <>1) /* ACTUAL COSTING ORGANIZATIONS*/
	THEN
	    --DBMS_OUTPUT.PUT_LINE('ACTUAL COSTING ORGANIZATIONS');
	    Get_Stuck_Txn_Info();

	    SELECT BOTTLE_NECK_TXN_ID,
		   TRANSACTION_DATE,
		   TRANSACTION_ORGANIZATION_ID,
		   TRANSFER_ORGANIZATION_ID,
		   TRANSFER_TRANSACTION_ID,
		   TRANSACTION_ACTION_ID,
		   TRANSACTION_SOURCE_TYPE_ID,
		   TRANSACTION_COST,
		   SHIPMENT_COSTED,
		   MOVE_TRANSACTION_ID,
		   COMPLETION_TRANSACTION_ID,
		   COSTED_FLAG,
		   WAITING_ORGANIZATION_ID,
		   LOGICAL_TXN_CREATED
	       INTO
		   L_BOTTLE_NECK_TXN_ID,
		   L_TXN_DATE          ,
		   L_TXN_ORG           ,
		   L_TXN_TXFR_ORG      ,
		   L_TXN_TXFR_TXN_ID   ,
		   L_TXN_ACTION_ID     ,
		   L_TXN_SOURCE_TYPE_ID,
		   L_TXN_COST          ,
		   L_TXN_SHIPMENT_COSTED,
		   L_TXN_MOVE_TXN_ID    ,
		   L_TXN_COMP_TXN_ID    ,
		   L_TXN_COSTED_FLAG    ,
		   L_WAITING_ORG        ,
		   L_LOGICAL_TXN_CRTD
	       FROM CST_DIAG_ERRORED_TXNS
	       WHERE ORGANIZATION_ID =L_ORGANIZATION_ID;

		--DBMS_OUTPUT.PUT_LINE('TXN DATE :='||L_TXN_DATE);

		IF (L_TXN_DATE >L_COST_CUTOFF_DATE)
		THEN
		      --DBMS_OUTPUT.PUT_LINE('COST CUTT OFF DATE CHECK');
		      INSERT INTO CST_DIAG_TXN_ERRORS(TRANSACTION_ID,
			ERROR_MESSAGE,RESOLUTION)
		      VALUES(L_BOTTLE_NECK_TXN_ID,'TXN DATE IS LATER THEN COST CUTOFF DATE FOR ORG',NULL);
		ELSIF (L_LOGICAL_TXN_CRTD = 2) THEN
                      INSERT INTO CST_DIAG_TXN_ERRORS(TRANSACTION_ID,
			ERROR_MESSAGE,RESOLUTION)
		      VALUES(L_BOTTLE_NECK_TXN_ID,'LOGICAL TRANSACTIONS FOR THIS TRANSACTION HAVE NOT BEEN CREATED',NULL);

		ELSIF /* A - CHECK MMTT FOR BACK FLUSH TRANSACTIONS*/
		     ( L_TXN_SOURCE_TYPE_ID =5 ) THEN

		       SELECT COUNT(MMTT.COMPLETION_TRANSACTION_ID)
			 INTO L_MMTT_COUNT
			FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT,
			     CST_DIAG_ERRORED_TXNS SC
		       WHERE SC.ORGANIZATION_ID =  L_ORGANIZATION_ID
			 AND SC.TRANSACTION_SOURCE_TYPE_ID = 5
			 AND MMTT.ORGANIZATION_ID = SC.ORGANIZATION_ID
			 AND (MMTT.COMPLETION_TRANSACTION_ID = SC.COMPLETION_TRANSACTION_ID
			      OR MMTT.MOVE_TRANSACTION_ID = SC.MOVE_TRANSACTION_ID);

		    IF (L_MMTT_COUNT > 0) THEN
		      --DBMS_OUTPUT.PUT_LINE('TRANSACTIONS STUCK IN MMTT');
		      INSERT INTO CST_DIAG_TXN_ERRORS(TRANSACTION_ID,
			ERROR_MESSAGE,RESOLUTION)
		      VALUES(L_BOTTLE_NECK_TXN_ID,L_MMTT_COUNT||' TRANSACTIONS ARE STUCK IN MMTT, CLEAR THEM BEFORE PROCEDDING',NULL);
		    END IF;

		     SELECT COUNT(1)
		        INTO L_WMTI_COUNT
		       FROM WIP_MOVE_TXN_INTERFACE WMTI
		      WHERE WMTI.TRANSACTION_ID = L_TXN_MOVE_TXN_ID ;
		    IF (L_WMTI_COUNT > 0) THEN

		      INSERT INTO CST_DIAG_TXN_ERRORS(TRANSACTION_ID,
			ERROR_MESSAGE,RESOLUTION)
		      VALUES(L_BOTTLE_NECK_TXN_ID,L_WMTI_COUNT||' TRANSACTIONS ARE STUCK IN WMTI, CLEAR THEM BEFORE PROCEDDING',NULL);
		    END IF;

		 ELSIF /* B - CHECK TRANSFER COST */
		     ( L_TXN_ACTION_ID =3 ) THEN
			  SELECT 1
			  INTO  L_TRANSFER_COST
			  FROM CST_DIAG_ERRORED_TXNS SC
			   WHERE SC.BOTTLE_NECK_TXN_ID IS NOT NULL
			   AND   SC.TRANSACTION_ACTION_ID = 3
			   AND SC.TRANSACTION_COST IS NULL
			   AND EXISTS ( SELECT 'X'
					FROM MTL_MATERIAL_TRANSACTIONS MMT
				       WHERE MMT.TRANSACTION_ID = SC.TRANSFER_TRANSACTION_ID
					 AND MMT.COSTED_FLAG IS NULL
				       )
			   AND SC.ORGANIZATION_ID =  L_ORGANIZATION_ID;

			   IF (L_TRANSFER_COST IS NOT NULL )
			     THEN
			       --DBMS_OUTPUT.PUT_LINE('TRANSFER COST IS NULL FOR DIRECT INTER_ORG TRANSFERS');
			       INSERT INTO CST_DIAG_TXN_ERRORS(TRANSACTION_ID,
				ERROR_MESSAGE,RESOLUTION)
			       VALUES(L_BOTTLE_NECK_TXN_ID,'TRANSFER COST IS NULL FOR DIRECT INTER_ORG TRANSFERS',NULL);
			      END IF;
		 ELSIF /* C - INTER ORGS  */
		     ( L_TXN_ACTION_ID IN (12,22) ) THEN

			  SELECT 1
			  INTO  L_SHIPMENT_COSTED
			   FROM CST_DIAG_ERRORED_TXNS SC
			   WHERE SC.TRANSACTION_ACTION_ID IN (12,21)
			    AND  SC.SHIPMENT_COSTED IS NULL
			    AND  EXISTS ( SELECT 'X'
					 FROM MTL_CST_TXN_COST_DETAILS MCTCD
					  WHERE MCTCD.TRANSACTION_ID = SC.BOTTLE_NECK_TXN_ID
					   AND MCTCD.ORGANIZATION_ID = SC.ORGANIZATION_ID
					)
			    AND SC.BOTTLE_NECK_TXN_ID IS NOT NULL
			    AND SC.ORGANIZATION_ID = L_ORGANIZATION_ID;

			    IF (L_SHIPMENT_COSTED IS NOT NULL )
			     THEN
			       --DBMS_OUTPUT.PUT_LINE('THE SHIPMENT COSTED SHOULD BE Y');
			       INSERT INTO CST_DIAG_TXN_ERRORS(TRANSACTION_ID,
				ERROR_MESSAGE,RESOLUTION)
			       VALUES(L_BOTTLE_NECK_TXN_ID,'THE SHIPMENT COSTED SHOULD BE Y',NULL);
			      END IF;

		 ELSIF /* D - ERRORED TRANSACTION  */
		     ( L_TXN_COSTED_FLAG ='E' ) THEN
			       --DBMS_OUTPUT.PUT_LINE('THE TRANSACTION ERRORED');
			       INSERT INTO CST_DIAG_TXN_ERRORS(TRANSACTION_ID,
				ERROR_MESSAGE,RESOLUTION)
			       VALUES(L_BOTTLE_NECK_TXN_ID,'TRANSACTION ERRORED NEEDS TO BE RESOLVED',NULL);
		  ELSIF  ( L_TXN_ACTION_ID IN (3,21,12)) THEN
		       --DBMS_OUTPUT.PUT_LINE('RUN CHECKS FOR TRANSFER ORGANIZATION_ID '|| L_TXN_TXFR_ORG);
		       INSERT INTO CST_DIAG_TXN_ERRORS(TRANSACTION_ID,
			ERROR_MESSAGE,RESOLUTION)
		       VALUES(NULL,'RUN CHECKS FOR TRANSFER ORGANIZATION_ID '|| L_TXN_TXFR_TXN_ID,NULL);
		ELSIF(L_BOTTLE_NECK_TXN_ID is NOT NULL) THEN
		       --DBMS_OUTPUT.PUT_LINE('REPORT COSTING BUG');
		       INSERT INTO CST_DIAG_TXN_ERRORS(TRANSACTION_ID,
			ERROR_MESSAGE,RESOLUTION)
		       VALUES(L_BOTTLE_NECK_TXN_ID,'REPORT A BUG WITH COSTING DEVELOPMENT',NULL);
                ELSE
		       INSERT INTO CST_DIAG_TXN_ERRORS(TRANSACTION_ID,
			ERROR_MESSAGE,RESOLUTION)
		       VALUES(NULL,'NO UNCOSTED TRANSACTIONS FOUND!!',NULL);

	 END IF;
   END IF;

EXCEPTION
	WHEN COST_MANAGER_INACTIVE THEN
	       INSERT INTO CST_DIAG_TXN_ERRORS(TRANSACTION_ID,
		ERROR_MESSAGE,RESOLUTION)
	       VALUES(NULL,'COST MANAGER IS INACTIVE','LAUNCH THE COST MANAGER TO GET THE TRANSACTIONS COSTED');
END Check_Transactions_MMT;

END CST_DIAGNOSTICS_PKG;

/
