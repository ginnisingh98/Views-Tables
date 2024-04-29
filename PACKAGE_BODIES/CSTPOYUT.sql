--------------------------------------------------------
--  DDL for Package Body CSTPOYUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPOYUT" AS
/* $Header: CSTOYUTB.pls 115.5 2002/11/08 23:23:08 awwang ship $ */

----------------------------------------------------------------------------
-- FUNCTION                                                               --
--   update_mat_cost                                                      --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this function to update operation cost in WIP_OPERATION_YIELDS   --
--   from material cost manager.                                          --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.1                                        --
--                                                                        --
-- PARAMETERS:                                                            --
--  i_cost_type_id    : Cost Type id                                      --
--  i_txn_id          : Material Transaction Id                           --
--  i_org_id          : Organization Id                                   --
--  i_op_seq_num      : Operation Sequence Number                         --
--  i_item_id         : Inventory Item id                                 --
--  i_txn_qty         : Transaction quanity                               --
--  i_entity_id       : WIP Entity Id                                     --
--  i_entity_type     : WIP Entity Type                                   --
--                                                                        --
-- HISTORY:                                                               --
--    03/02/00     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------

Function update_mat_cost (i_cost_type_id            IN   NUMBER,
                          i_txn_id                  IN   NUMBER,
                          i_org_id                  IN   NUMBER,
                          i_op_seq_num              IN   NUMBER,
                          i_item_id                 IN   NUMBER,
                          i_txn_qty                 IN   NUMBER,
                          i_entity_id               IN   NUMBER,
                          i_entity_type             IN   NUMBER,
                          i_user_id                 IN   NUMBER,
                          i_login_id                IN   NUMBER,
                          i_prg_appl_id             IN   NUMBER,
                          i_prg_id                  IN   NUMBER,
                          i_req_id                  IN   NUMBER)
RETURN Number IS

/* Changes for Optional Scrap */
x_est_scrap_acct_flag		NUMBER := 0;
l_err_num                  	NUMBER := 0;
l_err_msg                 	VARCHAR2(240) := '';
WSM_ESA_PKG_ERROR     		EXCEPTION;


BEGIN

    /* Changes for Optional Scrap */
    x_est_scrap_acct_flag := WSMPUTIL.WSM_ESA_ENABLED(i_entity_id, l_err_num, l_err_msg);
    IF (x_est_scrap_acct_flag = 0) THEN
	RAISE WSM_ESA_PKG_ERROR;
    END IF;

    IF x_est_scrap_acct_flag <> 1 THEN
	FND_FILE.PUT_LINE(FND_FILE.LOG,
			  'Estimated Scrap Accounting flag is disabled');
	RETURN 1;
    END IF;


    /* Update WIP_OPERATION_YIELDS */

        UPDATE wip_operation_yields woy
        SET (LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
            REQUEST_ID,PROGRAM_APPLICATION_ID,PROGRAM_ID,PROGRAM_UPDATE_DATE,
            operation_cost,
            status )=
        (SELECT
            SYSDATE, i_user_id, i_login_id,
            DECODE(i_req_id, -1, NULL, i_req_id),
            DECODE(i_prg_appl_id, -1, NULL, i_prg_appl_id),
            DECODE(i_prg_id, -1, NULL, i_prg_id),
            DECODE(i_req_id, -1, NULL, SYSDATE),
            (NVL(woy.operation_cost, 0) +
            (NVL(cic.material_cost,0) +
             NVL(cic.material_overhead_cost,0)  +
             NVL(cic.resource_cost,0)  +
             NVL(cic.outside_processing_cost,0) +
             NVL(cic.overhead_cost,0)) * -1 * i_txn_qty) ,
               1
        FROM  cst_item_costs cic,  mtl_parameters mp
        WHERE cic.inventory_item_id = i_item_id
        AND   cic.organization_id = mp.cost_organization_id
        AND   mp.organization_id = i_org_id
        AND   cic.cost_type_id = i_cost_type_id
        )
        WHERE  woy.wip_entity_id = i_entity_id
        AND    woy.organization_id = i_org_id
        AND    woy.operation_seq_num = i_op_seq_num
        AND    EXISTS
            (SELECT 'Check if the item has cost'
             FROM   CST_ITEM_COSTS CIC, MTL_PARAMETERS MP
             WHERE  CIC.INVENTORY_ITEM_ID = i_item_id
             AND    CIC.ORGANIZATION_ID = MP.COST_ORGANIZATION_ID
             AND    MP.ORGANIZATION_ID = i_org_id
             AND    CIC.COST_TYPE_ID = i_cost_type_id);

       IF SQL%ROWCOUNT > 0 THEN
         return (1);
      ELSE
         return (-1);
      END IF;

 EXCEPTION
	WHEN WSM_ESA_PKG_ERROR THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Failure in WSM_ESA_ENABLED : '||'wip_entity_id : '||
                                            i_entity_id || ' : ' || l_err_num || ' : ' ||l_err_msg);
	    raise_application_error(-20001,l_err_msg);
	    return (0);

        WHEN OTHERS THEN
            raise_application_error(-20001, SQLERRM);
            return (0);
END update_mat_cost;

---------------------------------------------------------------------------
-- FUNCTION                                                               --
--  update_wip_cost                                                       --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this function to update operation cost in WIP_OPERATION_YIELDS   --
--   from WIP cost manager.                                               --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.1                                        --
--                                                                        --
-- PARAMETERS:                                                            --
--            i_group_id     : group_id                                   --
-- RETURNS                                                                --
--     1 : Success                                                        --
--     0 : Failure                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    03/02/00     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------
Function update_wip_cost (i_group_id       IN   NUMBER,
                          i_user_id        IN   NUMBER,
                          i_login_id       IN   NUMBER,
                          i_prg_appl_id    IN   NUMBER,
                          i_prg_id         IN   NUMBER,
                          i_req_id         IN   NUMBER,
                          o_err_msg      OUT NOCOPY  VARCHAR2)
return Number IS

/* Changes for Optional Scrap */
x_err_num NUMBER := 0;
x_err_msg varchar2(240);
x_est_scrap_acct_flag NUMBER;
WSM_ESA_PKG_ERROR               EXCEPTION;

CURSOR c_wip_entities IS
SELECT distinct we.wip_entity_id
FROM wip_entities we, wip_transactions wt
WHERE we.wip_entity_id = wt.wip_entity_id
AND we.entity_type = 5
AND wt.group_id = i_group_id;

BEGIN

	FOR c_we_rec IN c_wip_entities LOOP
         /* Update Wip_operation_yields */

 	 /* Changes for Optional Scrap */
    	 x_est_scrap_acct_flag := WSMPUTIL.WSM_ESA_ENABLED(c_we_rec.wip_entity_id, x_err_num, x_err_msg);
         IF (x_est_scrap_acct_flag = 0) THEN
             RAISE WSM_ESA_PKG_ERROR;
         END IF;

	 IF(x_est_scrap_acct_flag = 1) THEN
           UPDATE wip_operation_yields woy
           SET    (operation_cost,
                status,
                REQUEST_ID, PROGRAM_APPLICATION_ID,
                PROGRAM_ID, PROGRAM_UPDATE_DATE,
                LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN) =
           (SELECT NVL(woy.operation_cost, 0) +
                    NVL(sum(acct.base_transaction_value), 0), 1,
                    i_req_id, i_prg_appl_id, i_prg_id, SYSDATE,
                    SYSDATE, i_user_id, i_login_id
            FROM    wip_transaction_accounts acct,
                    wip_transactions wt,
                    wip_entities we
            WHERE   we.wip_entity_id=c_we_rec.wip_entity_id
            AND     we.wip_entity_id = wt.wip_entity_id
	    AND     we.entity_type = 5
            AND     wt.wip_entity_id = woy.wip_entity_id
            AND     wt.organization_id = woy.organization_id
            AND     wt.operation_seq_num = woy.operation_seq_num
            AND     wt.transaction_id = acct.transaction_id
            AND     acct.accounting_line_type = 7
	    AND     wt.group_id = i_group_id
            )
            WHERE
                (woy.wip_entity_id, woy.operation_seq_num,
                 woy.organization_id )
            IN
                (SELECT wt.wip_entity_id, wt.operation_seq_num,
                        wt.organization_id
                 FROM   wip_transactions wt,
                        wip_transaction_accounts acct,
			wip_entities we
                 WHERE  wt.wip_entity_id=c_we_rec.wip_entity_id
                 AND    wt.transaction_id = acct.transaction_id
		 AND    acct.accounting_line_type = 7
		 AND    we.wip_entity_id = wt.wip_entity_id
		 AND    we.entity_type = 5
		 AND    wt.group_id = i_group_id
                 );
	  END IF;
	END LOOP;

  return 1;
EXCEPTION
   WHEN WSM_ESA_PKG_ERROR THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Failure in WSM_ESA_ENABLED : '
                                         || x_err_num || ' : ' ||x_err_msg);
        raise_application_error(-20001,x_err_msg);
        return (0);

   when others then
        o_err_msg := 'CSTPOYUT.update_wip_cost' ||
                        substr(SQLERRM,1,150);
        return 0;
END update_wip_cost;

 ---------------------------------------------------------------------------
-- FUNCTION                                                               --
--  update_woy_status                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this function to update status of WIP_OPERATION_YIELDS when      --
--   scrap transaction takes place.                                       --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.1                                        --
--                                                                        --
-- PARAMETERS:                                                            --
--            i_org_id        : Organization Id                           --
--            i_wip_entity_id : WIP Entity Id                             --
--            i_op_seq_num    : Operation Sequence Number                 --
-- RETURNS                                                                --
--     1 : Success                                                        --
--     0 : Failure                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    02/12/00     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------
Function update_woy_status (i_org_id              NUMBER,
                            i_wip_entity_id       NUMBER,
                            i_op_seq_num          NUMBER,
                            i_user_id        IN   NUMBER,
                            i_login_id       IN   NUMBER,
                            i_prg_appl_id    IN   NUMBER,
                            i_prg_id         IN   NUMBER,
                            i_req_id         IN   NUMBER,
                            o_err_num        OUT NOCOPY  NUMBER,
                            o_err_code     OUT NOCOPY  VARCHAR2,
                            o_err_msg      OUT NOCOPY  VARCHAR2)
return NUMBER IS

/* Changes for Optional Scrap */
x_est_scrap_acct_flag	NUMBER := 0;
x_err_num		NUMBER := 0;
x_err_msg		VARCHAR2(240) := '';
WSM_ESA_PKG_ERROR       EXCEPTION;

BEGIN
 o_err_code := '';
 o_err_num := 0;
 o_err_msg := '';

    /* Changes for Optional Scrap */
    x_est_scrap_acct_flag := WSMPUTIL.WSM_ESA_ENABLED(i_wip_entity_id,x_err_num,x_err_msg);
    IF (x_est_scrap_acct_flag = 0) THEN
	RAISE WSM_ESA_PKG_ERROR;
    END IF;


    IF x_est_scrap_acct_flag <> 1 THEN
    	    RETURN 1;
    END IF;

    /* Update WIP_OPERATION_YIELDS */

        UPDATE wip_operation_yields
        SET  LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATED_BY = i_user_id,
             LAST_UPDATE_LOGIN = i_login_id,
             REQUEST_ID = DECODE(i_req_id, -1, NULL, i_req_id),
             PROGRAM_APPLICATION_ID = DECODE(i_prg_appl_id, -1, NULL, i_prg_appl_id),
             PROGRAM_ID = DECODE(i_prg_id, -1, NULL, i_prg_id),
             PROGRAM_UPDATE_DATE = DECODE(i_req_id, -1, NULL, SYSDATE),
             status  = 1
        WHERE  wip_entity_id = i_wip_entity_id
        AND    organization_id = i_org_id
        AND    operation_seq_num = i_op_seq_num ;

       IF SQL%ROWCOUNT > 0 THEN
         return (1);
      ELSE
         return (0);
      END IF;

EXCEPTION
   WHEN WSM_ESA_PKG_ERROR THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Failure in WSM_ESA_ENABLED : '||'wip_entity_id : '||
                                       i_wip_entity_id || ' : ' || x_err_num || ' : ' ||x_err_msg);
      o_err_num := x_err_num;
      o_err_msg := 'CSTPOYUT.update_woy_status:' || substrb(o_err_msg,1,150);
      return 0;
  when others then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPOYUT.update_woy_status:' || substrb(SQLERRM,1,150);
    return 0;
END update_woy_status;


end CSTPOYUT;

/
