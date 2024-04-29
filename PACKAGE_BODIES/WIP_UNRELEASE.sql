--------------------------------------------------------
--  DDL for Package Body WIP_UNRELEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_UNRELEASE" AS
 /* $Header: wippunrb.pls 120.2.12010000.5 2010/05/14 20:59:00 pding ship $ */

PROCEDURE UNRELEASE(x_org_id        IN NUMBER,
                    x_wip_id        IN NUMBER,
                    x_rep_id        IN NUMBER DEFAULT -1,
                    x_line_id       IN NUMBER DEFAULT -1,
                    x_ent_type      IN NUMBER) IS

 ops_exist VARCHAR2(2);
 charges_exist VARCHAR2(2);
 po_req_exist VARCHAR2(20);

 cursor check_discrete_charges is
        SELECT  DISTINCT 'X'
        FROM    WIP_DISCRETE_JOBS DJ, WIP_PERIOD_BALANCES WPB
        WHERE   DJ.WIP_ENTITY_ID = WPB.WIP_ENTITY_ID
                AND DJ.ORGANIZATION_ID = WPB.ORGANIZATION_ID
                AND DJ.WIP_ENTITY_ID = x_wip_id
                AND DJ.ORGANIZATION_ID = x_org_id
                AND (DJ.QUANTITY_COMPLETED <> 0
                        OR DJ.QUANTITY_SCRAPPED <> 0
						OR VERIFY_WPB(x_org_id, x_wip_id) <>0 /*Added for BUG 7325661 (FP 6721407)*/
 	                    /*Commented for BUG 7325661 (FP 6721407) OR WPB.TL_RESOURCE_IN <> 0
                        OR WPB.TL_OVERHEAD_IN <> 0
                        OR WPB.TL_OUTSIDE_PROCESSING_IN <> 0
                        OR WPB.PL_MATERIAL_IN <> 0
                        OR WPB.PL_MATERIAL_OVERHEAD_IN <> 0
                        OR WPB.PL_RESOURCE_IN <> 0
                        OR WPB.PL_OVERHEAD_IN <> 0
                        OR WPB.PL_OUTSIDE_PROCESSING_IN <> 0
                        OR WPB.TL_MATERIAL_OUT <> 0
                        OR WPB.TL_RESOURCE_OUT <> 0
                        OR WPB.TL_OVERHEAD_OUT <> 0
                        OR WPB.TL_OUTSIDE_PROCESSING_OUT <> 0
                        OR WPB.PL_MATERIAL_OUT <> 0
                        OR WPB.PL_MATERIAL_OVERHEAD_OUT <> 0
                        OR WPB.PL_RESOURCE_OUT <> 0
                        OR WPB.PL_OVERHEAD_OUT <> 0
                        OR WPB.PL_OUTSIDE_PROCESSING_OUT <> 0*/
        OR EXISTS (SELECT 'X'
                         FROM WIP_REQUIREMENT_OPERATIONS
                        WHERE ORGANIZATION_ID = x_org_id
                         AND WIP_ENTITY_ID = x_wip_id
                          AND QUANTITY_ISSUED <> 0)
        OR EXISTS (SELECT 'X'
                         FROM WIP_MOVE_TXN_INTERFACE
                        WHERE ORGANIZATION_ID = x_org_id
                          AND WIP_ENTITY_ID = x_wip_id)
        OR EXISTS (SELECT 'X'
                         FROM WIP_COST_TXN_INTERFACE
                        WHERE ORGANIZATION_ID = x_org_id
                          AND WIP_ENTITY_ID = x_wip_id)
        OR EXISTS (SELECT 'X'
                         FROM MTL_MATERIAL_TRANSACTIONS_TEMP
                        WHERE ORGANIZATION_ID = x_org_id
			  AND TRANSACTION_SOURCE_TYPE_ID = 5
                          AND TRANSACTION_SOURCE_ID = x_wip_id)
        OR EXISTS (SELECT 'X'
                         FROM WIP_OPERATION_RESOURCES
                        WHERE ORGANIZATION_ID = x_org_id
                          AND WIP_ENTITY_ID = x_wip_id
                          AND APPLIED_RESOURCE_UNITS <> 0)
        OR EXISTS (SELECT 'X'    /*Bug 5462655 - Added to check uncosted/erred out transactions in MMT. */
                         FROM MTL_MATERIAL_TRANSACTIONS
                        WHERE ORGANIZATION_ID = x_org_id
                          AND TRANSACTION_SOURCE_TYPE_ID = 5
                          AND TRANSACTION_SOURCE_ID = x_wip_id
                          AND COSTED_FLAG IN ('N', 'E'))
 	         /* Fix for Bug - 7197320(FP of 6691421) - Added to check if move transaction exist for job (Check if quantites
 	            are present in any intra-operation step, other than first operation's Queue) */
 	         OR EXISTS (SELECT 'X' FROM
 	                      (SELECT Decode (
 	                          (Sum(Decode(PREVIOUS_OPERATION_SEQ_NUM,NULL,0,QUANTITY_IN_QUEUE)) +
 	                           Sum(QUANTITY_RUNNING) +
 	                           Sum(QUANTITY_WAITING_TO_MOVE) +
 	                           Sum(QUANTITY_REJECTED) +
 	                           Sum(QUANTITY_SCRAPPED)), NULL, 'Y', 0, NULL, 'X') Result
 	                           FROM WIP_OPERATIONS
 	                           WHERE ORGANIZATION_ID = x_org_id
 	                           AND WIP_ENTITY_ID = x_wip_id) WHERE Result = 'X' ));

 cursor check_repetitive_charges is
                SELECT 'X'
                FROM    WIP_REPETITIVE_SCHEDULES RS, WIP_PERIOD_BALANCES WPB
                WHERE   RS.WIP_ENTITY_ID = WPB.WIP_ENTITY_ID
                        AND RS.ORGANIZATION_ID = WPB.ORGANIZATION_ID
                        AND RS.REPETITIVE_SCHEDULE_ID =
                                                WPB.REPETITIVE_SCHEDULE_ID
                        AND RS.WIP_ENTITY_ID = x_wip_id
                        AND RS.ORGANIZATION_ID = x_org_id
                        AND RS.REPETITIVE_SCHEDULE_ID = x_rep_id
                        AND (RS.QUANTITY_COMPLETED <> 0
						OR VERIFY_WPB(x_org_id, x_wip_id,x_rep_id) <>0   /*Added for bug 7325661 (FP 6721407)*/
						/*OR WPB.TL_RESOURCE_IN <> 0 Removed for bug 7325661 (FP 6721407)
                                OR WPB.TL_OVERHEAD_IN <> 0
                                OR WPB.TL_OUTSIDE_PROCESSING_IN <> 0
                                OR WPB.PL_MATERIAL_IN <> 0
                                OR WPB.PL_MATERIAL_OVERHEAD_IN <> 0
                                OR WPB.PL_RESOURCE_IN <> 0
                                OR WPB.PL_OVERHEAD_IN <> 0
                                OR WPB.PL_OUTSIDE_PROCESSING_IN <> 0
                                OR WPB.TL_MATERIAL_OUT <> 0
                                OR WPB.TL_RESOURCE_OUT <> 0
                                OR WPB.TL_OVERHEAD_OUT <> 0
                                OR WPB.TL_OUTSIDE_PROCESSING_OUT <> 0
                                OR WPB.PL_MATERIAL_OUT <> 0
                                OR WPB.PL_MATERIAL_OVERHEAD_OUT <> 0
                                OR WPB.PL_RESOURCE_OUT <> 0
                                OR WPB.PL_OVERHEAD_OUT <> 0
                                OR WPB.PL_OUTSIDE_PROCESSING_OUT <> 0*/
                                OR EXISTS
                                 (SELECT 'X'
                                    FROM WIP_REQUIREMENT_OPERATIONS
                                   WHERE ORGANIZATION_ID = x_org_id
                                     AND WIP_ENTITY_ID = x_wip_id
                                     AND REPETITIVE_SCHEDULE_ID = x_rep_id
                                     AND QUANTITY_ISSUED <> 0)
                                OR EXISTS
                                 (SELECT 'X'
                                    FROM WIP_MOVE_TXN_INTERFACE
                                   WHERE ORGANIZATION_ID = x_org_id
                                     AND WIP_ENTITY_ID = x_wip_id
                                     AND LINE_ID = x_line_id)
                                OR EXISTS
                                 (SELECT 'X'
                                    FROM WIP_COST_TXN_INTERFACE
                                   WHERE ORGANIZATION_ID = x_org_id
                                     AND WIP_ENTITY_ID = x_wip_id
                                     AND LINE_ID = x_line_id)
                                OR EXISTS
                                 (SELECT 'X'
                                    FROM MTL_MATERIAL_TRANSACTIONS_TEMP
                                   WHERE ORGANIZATION_ID = x_org_id
                                     AND TRANSACTION_SOURCE_ID = x_wip_id
			  	     AND TRANSACTION_SOURCE_TYPE_ID = 5
                                     AND REPETITIVE_LINE_ID = x_line_id)
                                OR EXISTS
                                 (SELECT 'X'
                                    FROM WIP_OPERATIONS
                                   WHERE WIP_ENTITY_ID = x_wip_id
                                     AND ORGANIZATION_ID = x_org_id
                                     AND REPETITIVE_SCHEDULE_ID = x_rep_id
                                     AND QUANTITY_SCRAPPED <> 0)
                                OR EXISTS
                                 (SELECT 'X'
                                    FROM WIP_OPERATION_RESOURCES
                                   WHERE ORGANIZATION_ID = x_org_id
                                     AND WIP_ENTITY_ID = x_wip_id
                                     AND REPETITIVE_SCHEDULE_ID = x_rep_id
                                     AND APPLIED_RESOURCE_UNITS <> 0));
  -- for bug fix 8977276 (FP 8946106)
  CURSOR c_lock
    IS select '1'
    FROM  WIP_OPERATIONS
    WHERE WIP_ENTITY_ID = x_wip_id
    AND ORGANIZATION_ID = x_org_id
    for update nowait;

BEGIN

  open c_lock; -- for bug fix 8977276 (FP 8946106)

  IF (WIP_OSP.PO_REQ_EXISTS( p_wip_entity_id	=> x_wip_id
		    	    ,p_rep_sched_id	=> x_rep_id
		    	    ,p_organization_id	=> x_org_id
		            ,p_entity_type 	=> x_ent_type	) = TRUE) THEN
	FND_MESSAGE.SET_NAME('WIP','WIP_UNRLS_JOB/SCHED_OPEN_PO');
	raise fnd_api.g_exc_unexpected_error;/*Bug 9709677 */
  END IF;

  IF (x_ent_type = 1) THEN
    open check_discrete_charges;
    fetch check_discrete_charges into charges_exist;

    IF (check_discrete_charges%NOTFOUND) THEN

      UPDATE WIP_OPERATIONS
         SET QUANTITY_WAITING_TO_MOVE = 0,
             QUANTITY_SCRAPPED = 0,
             QUANTITY_REJECTED = 0,
             QUANTITY_IN_QUEUE = 0,
             QUANTITY_RUNNING = 0,
             QUANTITY_COMPLETED = 0,
             CUMULATIVE_SCRAP_QUANTITY = 0,     /*Enh#2864382*/
             PROGRESS_PERCENTAGE = NULL         /* Bug#3318428*/
       WHERE WIP_ENTITY_ID = x_wip_id
         AND ORGANIZATION_ID = x_org_id;
    ELSE
      FND_MESSAGE.SET_NAME('WIP','WIP_UNRLS_JOB/SCHED');
      raise fnd_api.g_exc_unexpected_error;/*Bug 9709677 */
      close  check_discrete_charges;
      RETURN;
    END IF;

    close  check_discrete_charges;

  ELSIF (x_ent_type = 2) THEN

    open check_repetitive_charges;
    fetch check_repetitive_charges into charges_exist;

    IF (check_repetitive_charges%NOTFOUND) THEN
      UPDATE WIP_OPERATIONS
         SET QUANTITY_WAITING_TO_MOVE = 0,
             QUANTITY_SCRAPPED = 0,
             QUANTITY_REJECTED = 0,
             QUANTITY_IN_QUEUE = 0,
             QUANTITY_RUNNING = 0,
             QUANTITY_COMPLETED = 0,
             CUMULATIVE_SCRAP_QUANTITY = 0     /*Enh#2864382*/
      WHERE  WIP_ENTITY_ID = x_wip_id
         AND ORGANIZATION_ID = x_org_id
         AND REPETITIVE_SCHEDULE_ID = x_rep_id;
    ELSE
      FND_MESSAGE.SET_NAME('WIP','WIP_UNRLS_JOB/SCHED');
      raise fnd_api.g_exc_unexpected_error;/*Bug 9709677 */
      close  check_repetitive_charges;
      RETURN;
    END IF;

    close check_repetitive_charges;

  END IF; -- end ent_type

  DELETE FROM wip_period_balances
  WHERE wip_entity_id = x_wip_id
  AND NVL(repetitive_schedule_id, -1) =
      NVL(x_rep_id, -1)
  AND organization_id = x_org_id;

  -- Undo changes to WRO as a result of Overcompletion
   wip_overcompletion.undo_overcompletion
	( p_org_id 		=> x_org_id,
	  p_wip_entity_id 	=> x_wip_id,
	  p_rep_id 		=> x_rep_id);

  close c_lock;-- for bug fix 8977276 (FP 8946106)

   -- for bug fix 8977276 (FP 8946106)
 EXCEPTION
    WHEN wip_constants.records_locked THEN
      if(c_lock%ISOPEN) then
          close c_lock;
      end if;
      fnd_message.set_name('WIP', 'WIP_LOCKED_ROW_ALREADY_LOCKED');
      APP_EXCEPTION.RAISE_EXCEPTION;

    /*Bug 9709677 */
   WHEN fnd_api.g_exc_unexpected_error THEN
      if(check_discrete_charges%ISOPEN) then
          close check_discrete_charges;
      end if;
      if(check_repetitive_charges%ISOPEN) then
          close check_repetitive_charges;
      end if;
      APP_EXCEPTION.RAISE_EXCEPTION;

   when others then
      if(c_lock%ISOPEN) then
          close c_lock;
      end if;
      fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
      fnd_message.set_token('ERROR_TEXT', 'WIP_UNRELEASE.UNRELEASE: ' || SQLERRM);
      APP_EXCEPTION.RAISE_EXCEPTION;/*Bug 9709677 */

END unrelease;

PROCEDURE UNRELEASE_MES_WRAPPER
    (P_wip_entity_id NUMBER,
     P_organization_id NUMBER
    ) IS

    X_user_id NUMBER := FND_GLOBAL.USER_ID;
    X_login_id NUMBER := FND_GLOBAL.LOGIN_ID;
BEGIN
     UNRELEASE(x_org_id =>P_organization_id,
               x_wip_id =>P_wip_entity_id,
               x_ent_type =>WIP_CONSTANTS.DISCRETE);


    UPDATE WIP_DISCRETE_JOBS
       SET STATUS_TYPE = WIP_CONSTANTS.UNRELEASED,
           DATE_RELEASED = NVL(DATE_RELEASED, SYSDATE),
           LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = X_user_id,
           LAST_UPDATE_LOGIN = X_login_id
     WHERE WIP_ENTITY_ID = P_wip_entity_id
       AND ORGANIZATION_ID = P_organization_id;

END UNRELEASE_MES_WRAPPER;

 /*Added FUNCTION VERIFY_WPB for bug 7325661 (FP 6721407)*/
 	 FUNCTION VERIFY_WPB(x_org_id IN NUMBER,
 	                     x_wip_id IN NUMBER,
 	                     x_rep_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS

 	   L_TL_RESOURCE_IN               NUMBER;
 	   L_TL_OVERHEAD_IN               NUMBER;
 	   L_TL_OUTSIDE_PROCESSING_IN     NUMBER;
 	   L_PL_MATERIAL_IN               NUMBER;
 	   L_PL_MATERIAL_OVERHEAD_IN      NUMBER;
 	   L_PL_RESOURCE_IN               NUMBER;
 	   L_PL_OVERHEAD_IN               NUMBER;
 	   L_PL_OUTSIDE_PROCESSING_IN     NUMBER;
 	   L_TL_MATERIAL_OUT              NUMBER;
 	   L_TL_RESOURCE_OUT              NUMBER;
 	   L_TL_OVERHEAD_OUT              NUMBER;
 	   L_TL_OUTSIDE_PROCESSING_OUT    NUMBER;
 	   L_PL_MATERIAL_OUT              NUMBER;
 	   L_PL_MATERIAL_OVERHEAD_OUT     NUMBER;
 	   L_PL_RESOURCE_OUT              NUMBER;
 	   L_PL_OVERHEAD_OUT              NUMBER;
 	   L_PL_OUTSIDE_PROCESSING_OUT    NUMBER;

 	 BEGIN

 	   SELECT sum(TL_RESOURCE_IN),
 	          sum(TL_OVERHEAD_IN),
 	          sum(TL_OUTSIDE_PROCESSING_IN),
 	          sum(PL_MATERIAL_IN),
 	          sum(PL_MATERIAL_OVERHEAD_IN),
 	          sum(PL_RESOURCE_IN),
 	          sum(PL_OVERHEAD_IN),
 	          sum(PL_OUTSIDE_PROCESSING_IN),
 	          sum(TL_MATERIAL_OUT),
 	          sum(TL_RESOURCE_OUT),
 	          sum(TL_OVERHEAD_OUT),
 	          sum(TL_OUTSIDE_PROCESSING_OUT),
 	          sum(PL_MATERIAL_OUT),
 	          sum(PL_MATERIAL_OVERHEAD_OUT),
 	          sum(PL_RESOURCE_OUT),
 	          sum(PL_OVERHEAD_OUT),
 	          sum(PL_OUTSIDE_PROCESSING_OUT)
 	    INTO   L_TL_RESOURCE_IN               ,
 	           L_TL_OVERHEAD_IN               ,
 	           L_TL_OUTSIDE_PROCESSING_IN     ,
 	           L_PL_MATERIAL_IN               ,
 	           L_PL_MATERIAL_OVERHEAD_IN      ,
 	           L_PL_RESOURCE_IN               ,
 	           L_PL_OVERHEAD_IN               ,
 	           L_PL_OUTSIDE_PROCESSING_IN     ,
 	           L_TL_MATERIAL_OUT              ,
 	           L_TL_RESOURCE_OUT              ,
 	           L_TL_OVERHEAD_OUT              ,
 	           L_TL_OUTSIDE_PROCESSING_OUT    ,
 	           L_PL_MATERIAL_OUT              ,
 	           L_PL_MATERIAL_OVERHEAD_OUT     ,
 	           L_PL_RESOURCE_OUT              ,
 	           L_PL_OVERHEAD_OUT              ,
 	           L_PL_OUTSIDE_PROCESSING_OUT
 	   FROM wip_period_balances
 	  WHERE wip_entity_id = x_wip_id
 	    AND organization_id=x_org_id
 	    AND nvl(repetitive_schedule_id , -1) = nvl(x_rep_id, -1);

 	    IF (L_TL_RESOURCE_IN             = 0 AND
 	        L_TL_OVERHEAD_IN             = 0 AND
 	        L_TL_OUTSIDE_PROCESSING_IN   = 0 AND
 	        L_PL_MATERIAL_IN             = 0 AND
 	        L_PL_MATERIAL_OVERHEAD_IN    = 0 AND
 	        L_PL_RESOURCE_IN             = 0 AND
 	        L_PL_OVERHEAD_IN             = 0 AND
 	        L_PL_OUTSIDE_PROCESSING_IN   = 0 AND
 	        L_TL_MATERIAL_OUT            = 0 AND
 	        L_TL_RESOURCE_OUT            = 0 AND
 	        L_TL_OVERHEAD_OUT            = 0 AND
 	        L_TL_OUTSIDE_PROCESSING_OUT  = 0 AND
 	        L_PL_MATERIAL_OUT            = 0 AND
 	        L_PL_MATERIAL_OVERHEAD_OUT   = 0 AND
 	        L_PL_RESOURCE_OUT            = 0 AND
 	        L_PL_OVERHEAD_OUT            = 0 AND
 	        L_PL_OUTSIDE_PROCESSING_OUT  = 0 ) THEN
 	      RETURN 0;
 	    ELSE
 	     RETURN 1;
 	    END IF;

 	  EXCEPTION
 	   WHEN OTHERS THEN
 	     RETURN 1;
 	 END;

END WIP_UNRELEASE;

/
