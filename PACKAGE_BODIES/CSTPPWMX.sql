--------------------------------------------------------
--  DDL for Package Body CSTPPWMX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPWMX" AS
/* $Header: CSTPPWMB.pls 120.1 2008/01/11 23:11:26 ipineda ship $ */

/*==================================================================*/
/* function for WIP material issue                                  */
/*==================================================================*/

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
RETURN integer
IS
    l_round_unit          NUMBER;
    l_precision           NUMBER;
    l_ext_precision       NUMBER;

    /* EAM Acct Enh Project */
    l_debug			VARCHAR(80);
    l_zero_cost_flag		NUMBER := -1;
    l_return_status		VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_msg_count			NUMBER := 0;
    l_msg_data            		VARCHAR2(8000) := '';
    l_api_message		VARCHAR2(8000);
    /* Added for bug6709905 */
    CURSOR wpb_rep_sch IS
    SELECT wpb.pl_material_in
    FROM   wip_period_balances wpb
    WHERE  wpb.acct_period_id = i_period_id
      AND  wpb.organization_id = i_org_id
      AND  wpb.wip_entity_id = i_entity_id
      AND  wpb.repetitive_schedule_id in
           (SELECT mmta.repetitive_schedule_id
            FROM   mtl_material_txn_allocations mmta
            WHERE  mmta.transaction_id = i_txn_id)
              AND    EXISTS
                     (SELECT 'Check if the item has cost'
                      FROM   cst_item_costs cic, mtl_parameters mp
                      WHERE  cic.inventory_item_id = i_item_id
                        AND    mp.organization_id = i_org_id
                        AND    cic.organization_id = mp.cost_organization_id
                        AND    cic.cost_type_id = i_cost_type_id)
      FOR UPDATE OF pl_material_in;

  BEGIN

    /*  Obtain round unit */

    CSTPUTIL.CSTPUGCI (i_org_id, l_round_unit, l_precision, l_ext_precision);

    /* Update WIP_PERIOD_BALANCES */

    IF i_entity_type <> 2   THEN
	/* EAM Acct Enh Project */
	CST_Utility_PUB.get_zeroCostIssue_flag (
	  p_api_version		=>	1.0,
  	  x_return_status	=>	l_return_status,
	  x_msg_count		=>	l_msg_count,
	  x_msg_data		=>	l_msg_data,
	  p_txn_id		=>	i_txn_id,
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

	l_debug := FND_PROFILE.VALUE('MRP_DEBUG');

	if (l_debug = 'Y') then
	  FND_FILE.PUT_LINE(FND_FILE.LOG, 'zero_cost_flag: '||to_char(l_zero_cost_flag));
	end if;

	if (l_zero_cost_flag = 1) then

	/* update wip_period_balances WHO columns */
	  UPDATE wip_period_balances b
	  SET LAST_UPDATE_DATE = sysdate,
	    LAST_UPDATED_BY = i_user_id,
	    LAST_UPDATE_LOGIN = i_login_id,
	    REQUEST_ID = DECODE(i_req_id, -1, NULL, i_req_id),
	    PROGRAM_APPLICATION_ID = DECODE(i_prg_appl_id, -1, NULL, i_prg_appl_id),
	    PROGRAM_ID = DECODE(i_prg_id, -1, NULL, i_prg_id),
	    PROGRAM_UPDATE_DATE = DECODE(i_req_id, -1, NULL, SYSDATE)
	  WHERE acct_period_id = i_period_id
	    AND    organization_id = i_org_id
	    AND    wip_entity_id = i_entity_id;
	else

          UPDATE wip_period_balances b
          SET (LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
            REQUEST_ID,PROGRAM_APPLICATION_ID,PROGRAM_ID,PROGRAM_UPDATE_DATE,
            pl_material_in,
            pl_material_overhead_in,
            pl_resource_in,
            pl_outside_processing_in,
            pl_overhead_in )=
          (SELECT
              SYSDATE, i_user_id, i_login_id,
              DECODE(i_req_id, -1, NULL, i_req_id),
              DECODE(i_prg_appl_id, -1, NULL, i_prg_appl_id),
              DECODE(i_prg_id, -1, NULL, i_prg_id),
              DECODE(i_req_id, -1, NULL, SYSDATE),
              nvl(b.pl_material_in,0) +
                (ROUND((NVL(material_cost,0) * -1 * i_txn_qty) /
                l_round_unit) * l_round_unit),
              nvl(b.pl_material_overhead_in,0) +
                (ROUND((NVL(material_overhead_cost,0) * -1 * i_txn_qty) /
                 l_round_unit) * l_round_unit),
              nvl(b.pl_resource_in,0) +
                (ROUND((NVL(resource_cost,0) * -1 * i_txn_qty) /
                 l_round_unit) * l_round_unit),
              nvl(b.pl_outside_processing_in,0)+
                (ROUND((NVL(outside_processing_cost,0) * -1 * i_txn_qty) /
                l_round_unit) * l_round_unit),
              nvl(b.pl_overhead_in,0) +
                (ROUND((NVL(overhead_cost,0) * -1 * i_txn_qty) /
                l_round_unit) * l_round_unit)
           FROM  cst_item_costs cic,  mtl_parameters mp
           WHERE cic.inventory_item_id = i_item_id
           AND   cic.organization_id = mp.cost_organization_id
           AND   mp.organization_id = i_org_id
           AND   cic.cost_type_id = i_cost_type_id
          )
          WHERE  acct_period_id = i_period_id
          AND    organization_id = i_org_id
          AND    wip_entity_id = i_entity_id
          AND    EXISTS
            (SELECT 'Check if the item has cost'
             FROM   CST_ITEM_COSTS CIC, MTL_PARAMETERS MP
             WHERE  CIC.INVENTORY_ITEM_ID = i_item_id
             AND    CIC.ORGANIZATION_ID = MP.COST_ORGANIZATION_ID
             AND    MP.ORGANIZATION_ID = i_org_id
             AND    CIC.COST_TYPE_ID = i_cost_type_id);
	end if;  /* l_zero_cost_flag */
      ELSE

	/* i_entity_type = 2 */
        /* bug 6709905, introduced loop to cursor to prevent deadlock
           scenario*/
    FOR wpb_rec IN wpb_rep_sch LOOP
        UPDATE wip_period_balances b
        SET (LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
            REQUEST_ID,PROGRAM_APPLICATION_ID,PROGRAM_ID,PROGRAM_UPDATE_DATE,
            pl_material_in,
            pl_material_overhead_in,
            pl_resource_in,
            pl_outside_processing_in,
            pl_overhead_in) =
        (SELECT
            SYSDATE, i_user_id, i_login_id,
            DECODE(i_req_id, -1, NULL, i_req_id),
            DECODE(i_prg_appl_id, -1, NULL, i_prg_appl_id),
            DECODE(i_prg_id, -1, NULL, i_prg_id),
            DECODE(i_req_id, -1, NULL, SYSDATE),
            nvl(b.pl_material_in,0) +
              ROUND((NVL(material_cost,0) * -1 * alloc.primary_quantity)/
                l_round_unit) * l_round_unit,
            nvl(b.pl_material_overhead_in,0) +
              ROUND((NVL(material_overhead_cost,0) * -1 *
                alloc.primary_quantity)/l_round_unit) * l_round_unit,
            nvl(b.pl_resource_in,0) +
              ROUND((NVL(resource_cost,0) * -1 * alloc.primary_quantity)/
                l_round_unit) * l_round_unit,
            nvl(b.pl_outside_processing_in,0)+
              ROUND((NVL(outside_processing_cost,0) * -1 *
                alloc.primary_quantity)/l_round_unit)* l_round_unit,
            nvl(b.pl_overhead_in,0) +
              ROUND((NVL(overhead_cost,0) * -1 * alloc.primary_quantity)/
                l_round_unit) * l_round_unit
        FROM cst_item_costs cic,
	     mtl_parameters mp,
             mtl_material_txn_allocations alloc
        WHERE NVL(alloc.repetitive_schedule_id, -99) =
              NVL(b.repetitive_schedule_id, -99)
        AND   alloc.transaction_id = i_txn_id
        AND   cic.inventory_item_id = i_item_id
        AND   cic.organization_id = mp.cost_organization_id
        AND   mp.organization_id = i_org_id
        AND   cic.cost_type_id = 1
        )
        WHERE  CURRENT OF wpb_rep_sch;
        /* bug 6709905
        WHERE  acct_period_id = i_period_id
        AND    organization_id = i_org_id
        AND    wip_entity_id = i_entity_id
        AND    repetitive_schedule_id in
               (SELECT repetitive_schedule_id
                FROM mtl_material_txn_allocations
                WHERE transaction_id = i_txn_id)
        AND    EXISTS
            (SELECT 'Check if the item has cost'
             FROM   CST_ITEM_COSTS CIC, MTL_PARAMETERS MP
             WHERE  INVENTORY_ITEM_ID = i_item_id
             AND    MP.ORGANIZATION_ID = i_org_id
             AND    CIC.ORGANIZATION_ID = MP.COST_ORGANIZATION_ID
             AND    COST_TYPE_ID = i_cost_type_id);*/
    END LOOP;


      END IF;

      IF SQL%ROWCOUNT > 0 THEN
         return (1);
      ELSE
         return (-999);
      END IF;

  /* exception handlers */
  EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20001, SQLERRM);
            return (0);
  END issue;

/*==================================================================*/
/* function for WIP completion                                      */
/*==================================================================*/

FUNCTION complete (
        i_cost_type_id     IN   NUMBER,
        i_txn_id           IN   NUMBER,
        i_org_id           IN   NUMBER,
        i_period_id        IN   NUMBER,
        i_item_id          IN   NUMBER,
        i_txn_qty          IN   NUMBEr,
        i_entity_id        IN   NUMBER,
        i_entity_type      IN   NUMBER,
        i_user_id          IN   NUMBER,
        i_login_id         IN   NUMBER,
        i_prg_appl_id      IN   NUMBER,
        i_prg_id           IN   NUMBER,
        i_req_id           IN   NUMBER)
RETURN integer
IS
    l_round_unit              NUMBER;
    l_precision               NUMBER;
    l_ext_precision           NUMBER;
    x_realoc_yld_cost         NUMBER;
    x_op_yield_cost           NUMBER := 0;
    x_pl_mat_yld_cost         NUMBER := 0;
    x_tl_mat_yld_cost         NUMBER := 0;
    x_pl_mat_ovhd_yld_cost    NUMBER := 0;
    x_tl_mat_ovhd_yld_cost    NUMBER := 0;
    x_pl_osp_yld_cost         NUMBER := 0;
    x_tl_osp_yld_cost         NUMBER := 0;
    x_pl_res_yld_cost         NUMBER := 0;
    x_tl_res_yld_cost         NUMBER := 0;
    x_pl_ovhd_yld_cost        NUMBER := 0;
    x_tl_ovhd_yld_cost        NUMBER := 0;

    /* Changes for Optional Scrap */
    x_est_scrap_acct_flag     NUMBER := 0;
    l_err_num		      NUMBER := 0;
    l_err_msg		      VARCHAR2(240) := '';
    WSM_ESA_PKG_ERROR         EXCEPTION;


    CURSOR c_op_yld_cost  IS
         SELECT  SUM(NVL(yielded_cost, 0)) yielded_cost,
                 cost_element_id,
                 level_type
           FROM  cst_item_cost_details
           WHERE  inventory_item_id = i_item_id
             AND  organization_id = i_org_id
             AND  cost_type_id = 1

        GROUP BY cost_element_id, level_type;

       /* Added for bug6709905*/
    CURSOR wpb_rep_sch IS
        SELECT wpb.pl_material_out
        FROM   wip_period_balances wpb
        WHERE  wpb.acct_period_id = i_period_id
          AND  wpb.organization_id = i_org_id
          AND  wpb.wip_entity_id = i_entity_id
          AND  wpb.repetitive_schedule_id in
                  (SELECT mmta.repetitive_schedule_id
                   FROM mtl_material_txn_allocations mmta
                   WHERE mmta.transaction_id = i_txn_id)
          AND  EXISTS
               (SELECT 'Check if the item has cost'
                FROM   cst_item_costs cic, mtl_parameters mp
                WHERE  cic.inventory_item_id = i_item_id
                AND    mp.organization_id = i_org_id
                AND    cic.organization_id = mp.cost_organization_id
                AND    cic.cost_type_id = i_cost_type_id)
    FOR UPDATE OF pl_material_out;

  BEGIN
    /*  Obtain round unit */

    CSTPUTIL.CSTPUGCI (i_org_id, l_round_unit, l_precision, l_ext_precision);

    /*  Update TL, PL (OUT) costs to WIP_PERIOD_BALANCES for the assembly */
    /*  Separte SQL statement for job and schedule for faster performance */
    /*  Complete into INV take positive quantity */

      IF i_entity_type <> 2 THEN   /* discrete job */
        /*----------------------------------------------
         | Check if reallocation of operation yield cost |
         | is to be done. This was added by Sujit Dalai  |
         ------------------------------------------------- */

         SELECT  DECODE (entity_type, 5, 1, 0)
           INTO x_realoc_yld_cost
           FROM wip_entities
          WHERE wip_entity_id = i_entity_id
            AND organization_id = i_org_id ;

	/* Changes for Optional Scrap */
	IF x_realoc_yld_cost = 1 THEN
	    x_est_scrap_acct_flag := WSMPUTIL.WSM_ESA_ENABLED(i_entity_id,
						     	      l_err_num,
						     	      l_err_msg);

	    IF (x_est_scrap_acct_flag = 0) THEN
        	RAISE WSM_ESA_PKG_ERROR;
            END IF;

	    IF(x_est_scrap_acct_flag <> 1) THEN
	       x_realoc_yld_cost := 0;
	    END IF;
	END IF;

        /*---------------------------------------------------
         | If reallocation is to be done then get elemental |
         | yielded cost.     This was added by Sujit Dalai  |
         ------------------------------------------------- */

         IF (x_realoc_yld_cost = 1) THEN

           FOR rec_op_yld_cost in c_op_yld_cost LOOP

             IF (rec_op_yld_cost.cost_element_id = 1 AND
                 rec_op_yld_cost.level_type = 1) THEN

                 x_tl_mat_yld_cost := rec_op_yld_cost.yielded_cost;
            ELSIF (rec_op_yld_cost.cost_element_id = 1 AND
                   rec_op_yld_cost.level_type = 2) THEN

                   x_pl_mat_yld_cost := rec_op_yld_cost.yielded_cost;

            ELSIF (rec_op_yld_cost.cost_element_id = 2 AND
                   rec_op_yld_cost.level_type = 1) THEN

                  x_tl_mat_ovhd_yld_cost := rec_op_yld_cost.yielded_cost;

            ELSIF (rec_op_yld_cost.cost_element_id = 2 AND
                   rec_op_yld_cost.level_type = 2) THEN

                 x_pl_mat_ovhd_yld_cost :=  rec_op_yld_cost.yielded_cost;
            ELSIF (rec_op_yld_cost.cost_element_id = 3 AND
                   rec_op_yld_cost.level_type = 1) THEN

              x_tl_res_yld_cost :=  rec_op_yld_cost.yielded_cost;

            ELSIF (rec_op_yld_cost.cost_element_id = 3 AND
                   rec_op_yld_cost.level_type = 2) THEN

              x_pl_res_yld_cost := rec_op_yld_cost.yielded_cost;

            ELSIF (rec_op_yld_cost.cost_element_id = 4 AND
                   rec_op_yld_cost.level_type = 1) THEN

                x_tl_osp_yld_cost :=  rec_op_yld_cost.yielded_cost;

            ELSIF (rec_op_yld_cost.cost_element_id = 4 AND
                   rec_op_yld_cost.level_type = 2) THEN

                   x_pl_osp_yld_cost  := rec_op_yld_cost.yielded_cost;

            ELSIF (rec_op_yld_cost.cost_element_id = 5 AND
                   rec_op_yld_cost.level_type = 1) THEN

              x_tl_ovhd_yld_cost := rec_op_yld_cost.yielded_cost;

            ELSE

             x_pl_ovhd_yld_cost := rec_op_yld_cost.yielded_cost;

            END IF;

            x_op_yield_cost := x_op_yield_cost + rec_op_yld_cost.yielded_cost;

           END LOOP;

        END IF;


        UPDATE wip_period_balances b
        SET (LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
            REQUEST_ID,PROGRAM_APPLICATION_ID,PROGRAM_ID,PROGRAM_UPDATE_DATE,
            pl_material_out,
            pl_material_overhead_out,
            pl_resource_out,
            pl_outside_processing_out,
            pl_overhead_out,
            tl_material_out,
            tl_material_overhead_out,
            tl_resource_out,
            tl_outside_processing_out,
            tl_overhead_out,
            tl_scrap_out) =
        (SELECT
            SYSDATE, i_user_id, i_login_id,
            DECODE(i_req_id, -1, NULL, i_req_id),
            DECODE(i_prg_appl_id, -1, NULL, i_prg_appl_id),
            DECODE(i_prg_id, -1, NULL, i_prg_id),
            DECODE(i_req_id, -1, NULL, SYSDATE),
            nvl(b.pl_material_out,0) +
              ROUND(((NVL(pl_material,0) - x_pl_mat_yld_cost) * i_txn_qty)/l_round_unit)*
                l_round_unit,
            nvl(b.pl_material_overhead_out,0) +
              ROUND(((NVL(pl_material_overhead,0) - x_pl_mat_ovhd_yld_cost) * i_txn_qty)/l_round_unit)*
                l_round_unit,
            nvl(b.pl_resource_out,0) +
              ROUND(((NVL(pl_resource,0)  - x_pl_res_yld_cost)* i_txn_qty)/l_round_unit)*
                l_round_unit,
            nvl(b.pl_outside_processing_out,0) +
              ROUND(((NVL(pl_outside_processing,0) - x_pl_osp_yld_cost) * i_txn_qty)/l_round_unit)*
                l_round_unit,
            nvl(b.pl_overhead_out,0) +
              ROUND(((NVL(pl_overhead,0) - x_pl_ovhd_yld_cost) * i_txn_qty)/l_round_unit)*
                l_round_unit,
            nvl(b.tl_material_out,0)+
              ROUND(((NVL(tl_material,0) - x_tl_mat_yld_cost) * i_txn_qty)/l_round_unit)*
                l_round_unit,
            nvl(b.tl_material_overhead_out,0)+
            /* code change for bug 2090740 - decode modified for osfm jobs(class_type = 5) */
                /* if standard job or repetitive or osfm job, do not credit the job
                    tl matl ovhd ;
                 if non-std job, credit the job tl matl ovhd */
              DECODE(b.class_type, 1, 0, 2, 0, 5, 0,
                 ROUND(((NVL(tl_material_overhead,0) - x_tl_mat_ovhd_yld_cost) * i_txn_qty)/
                   l_round_unit)* l_round_unit),
            nvl(b.tl_resource_out,0) +
              ROUND(((NVL(tl_resource,0) - x_tl_res_yld_cost) * i_txn_qty)/l_round_unit)*
                l_round_unit,
            nvl(b.tl_outside_processing_out,0) +
              ROUND(((NVL(tl_outside_processing,0) - x_tl_osp_yld_cost) * i_txn_qty)/l_round_unit)*
                l_round_unit,
            nvl(b.tl_overhead_out,0) +
              ROUND(((NVL(tl_overhead,0) - x_tl_ovhd_yld_cost) * i_txn_qty)/l_round_unit)*
                l_round_unit,
            nvl(b.tl_scrap_out,0) +
              DECODE(b.class_type, 5 , ROUND(((x_op_yield_cost - x_tl_mat_ovhd_yld_cost) * i_txn_qty)
                                       /l_round_unit)*l_round_unit,
                                   0)


        FROM   cst_item_costs cic , mtl_parameters mp
        WHERE  cic.inventory_item_id = i_item_id
        AND    cic.organization_id = mp.cost_organization_id
        AND    mp.organization_id = i_org_id
        AND    cic.cost_type_id = 1
        )
        WHERE  b.acct_period_id = i_period_id
        AND    b.organization_id = i_org_id
        AND    b.wip_entity_id = i_entity_id
        AND    EXISTS
            (SELECT 'Check if the item has cost'
             FROM   CST_ITEM_COSTS CIC, MTL_PARAMETERS MP
             WHERE  INVENTORY_ITEM_ID = i_item_id
             AND    MP.ORGANIZATION_ID = i_org_id
             AND    CIC.ORGANIZATION_ID = MP.COST_ORGANIZATION_ID
             AND    COST_TYPE_ID = i_cost_type_id);

     ELSE       /* repetitive schedules */

    FOR wpb_rec IN wpb_rep_sch LOOP
        UPDATE wip_period_balances b
        SET (LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
            REQUEST_ID,PROGRAM_APPLICATION_ID,PROGRAM_ID,PROGRAM_UPDATE_DATE,
            pl_material_out,
            pl_material_overhead_out,
            pl_resource_out,
            pl_outside_processing_out,
            pl_overhead_out,
            tl_material_out,
            tl_resource_out,
            tl_outside_processing_out,
            tl_overhead_out) =
        (SELECT
            SYSDATE, i_user_id, i_login_id,
            DECODE(i_req_id, -1, NULL, i_req_id),
            DECODE(i_prg_appl_id, -1, NULL, i_prg_appl_id),
            DECODE(i_prg_id, -1, NULL, i_prg_id),
            DECODE(i_req_id, -1, NULL, SYSDATE),
            nvl(b.pl_material_out,0) +
              ROUND((NVL(pl_material,0) * alloc.primary_quantity)/
                l_round_unit)* l_round_unit,
            nvl(b.pl_material_overhead_out,0) +
              ROUND((NVL(pl_material_overhead,0) *alloc.primary_quantity)
                   /l_round_unit)* l_round_unit,
            nvl(b.pl_resource_out,0) +
              ROUND((NVL(pl_resource,0) *alloc.primary_quantity)
                   /l_round_unit)* l_round_unit,
            nvl(b.pl_outside_processing_out,0) +
              ROUND((NVL(pl_outside_processing,0) *alloc.primary_quantity)
                   /l_round_unit)* l_round_unit,
            nvl(b.pl_overhead_out,0) +
              ROUND((NVL(pl_overhead,0) * alloc.primary_quantity)/
                   l_round_unit)* l_round_unit,
            nvl(b.tl_material_out,0)+
              ROUND((NVL(tl_material,0) * alloc.primary_quantity)/
                   l_round_unit)* l_round_unit,
            nvl(b.tl_resource_out,0) +
              ROUND((NVL(tl_resource,0) * alloc.primary_quantity)/
                   l_round_unit)* l_round_unit,
            nvl(b.tl_outside_processing_out,0) +
             ROUND((NVL(tl_outside_processing,0)*alloc.primary_quantity)
                  /l_round_unit)* l_round_unit,
            nvl(b.tl_overhead_out,0) +
              ROUND((NVL(tl_overhead,0) * alloc.primary_quantity)/
                  l_round_unit)* l_round_unit
        FROM   cst_item_costs cic,
	       mtl_parameters mp,
               mtl_material_txn_allocations alloc
        WHERE  cic.inventory_item_id = i_item_id
        AND    cic.organization_id = mp.cost_organization_id
        AND    mp.organization_id = i_org_id
        AND    cic.cost_type_id = 1
        AND   alloc.transaction_id = i_txn_id
        AND   NVL(alloc.repetitive_schedule_id, -99) =
              NVL(b.repetitive_schedule_id, -99)
        )
        WHERE CURRENT OF wpb_rep_sch;
        /* Changes introduced for bug 6709905 to prevent deadlock scenario
        WHERE  b.acct_period_id = i_period_id
        AND    b.organization_id = i_org_id
        AND    b.wip_entity_id = i_entity_id
        AND    b.repetitive_schedule_id in
               (SELECT repetitive_schedule_id
                FROM mtl_material_txn_allocations
                WHERE transaction_id = i_txn_id)
        AND    EXISTS
            (SELECT 'Check if the item has cost'
             FROM   CST_ITEM_COSTS CIC, MTL_PARAMETERS MP
             WHERE  INVENTORY_ITEM_ID = i_item_id
             AND    MP.ORGANIZATION_ID = i_org_id
             AND    CIC.ORGANIZATION_ID = MP.COST_ORGANIZATION_ID
             AND    COST_TYPE_ID = i_cost_type_id);*/
    END LOOP;

      END IF;

      IF SQL%ROWCOUNT > 0 THEN
         return (1);
      ELSE
         return (-999);
      END IF;

  /*  exception handlers */
  EXCEPTION
        WHEN WSM_ESA_PKG_ERROR THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Failure in WSM_ESA_ENABLED : '||'wip_entity_id : '||
                                            i_entity_id || ' : ' || l_err_num || ' : ' ||l_err_msg);
            raise_application_error(-20001,l_err_msg);
            return (0);

        WHEN OTHERS THEN
                raise_application_error(-20001, SQLERRM);
                return (0);
  END complete;

END CSTPPWMX;

/
