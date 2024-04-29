--------------------------------------------------------
--  DDL for Package Body CSTPSMUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPSMUT" AS
/* $Header: CSTSMUTB.pls 120.9.12010000.2 2008/12/16 21:39:30 hyu ship $ */

G_PKG_NAME CONSTANT VARCHAR2(240) := 'CSTPSMUT';
l_debug_flag CONSTANT VARCHAR2(1) := FND_PROFILE.VALUE('MRP_DEBUG');

----------------------------------------------------------------------------
-- FUNCTION                                                              --
--  INSERT_WOO
--                                                                        --
-- DESCRIPTION                                                            --
--  This function inserts records in WIP_OPERATION_OVERHEADS for
--  newly created jobs during Split/Merge/Bonus
--
--                                                                        --
-- PURPOSE:                                                               --
--  OSFM Lot Transactions Costing for Oracle Applications Rel 11i.8
--                                                                        --
-- PARAMETERS:                                                            --
--  p_wip_entity_id       Job for which records are to be inserted
--  p_organization_id     Organization
--  p_login_id
--  p_user_id             Concurrent WHO Parameters
--  p_request_id          Request ID of calling worker
--  p_prog_appl_id
--  p_program_id
-- HISTORY:                                                               --
--  September-2002      Vinit                       Creation              --
----------------------------------------------------------------------------

FUNCTION INSERT_WOO (p_wip_entity_id      IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_operation_seq_num  IN NUMBER,
                     p_user_id            IN NUMBER,
                     p_login_id           IN NUMBER,
                     p_request_id         IN NUMBER,
                     p_prog_appl_id       IN NUMBER,
                     p_program_id         IN NUMBER )
         RETURN BOOLEAN IS
l_num_rows NUMBER;
l_return   BOOLEAN := TRUE;
BEGIN
  IF (l_debug_flag = 'Y') THEN
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'INSERT_WOO <<<');
  END IF;

  INSERT INTO WIP_OPERATION_OVERHEADS
        (WIP_ENTITY_ID,
         OPERATION_SEQ_NUM,
         RESOURCE_SEQ_NUM,
         ORGANIZATION_ID,
         OVERHEAD_ID,
         BASIS_TYPE,
         APPLIED_OVHD_UNITS,
         APPLIED_OVHD_VALUE,
         RELIEVED_OVHD_COMPLETION_UNITS,
         RELIEVED_OVHD_SCRAP_UNITS,
         RELIEVED_OVHD_COMPLETION_VALUE,
         RELIEVED_OVHD_SCRAP_VALUE,
         TEMP_RELIEVED_VALUE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE,
         LAST_UPDATE_DATE)
	(SELECT /* Resource Unit And Value Based Overheads */
           WO.wip_entity_id,
           WO.operation_seq_num,
           WOR.resource_seq_num,
           WO.organization_id,
           CDO.overhead_id,
           CDO.basis_type,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
	   p_user_id,
           sysdate,
	   p_user_id,
	   p_login_id,
	   p_request_id,
	   p_prog_appl_id,
	   p_program_id,
	   sysdate,
	   sysdate
        FROM
            cst_department_overheads CDO,
            cst_resource_overheads CRO,
            wip_operation_resources WOR,
            wip_operations WO
        WHERE
             WO.wip_entity_id     = p_wip_entity_id
        AND  WOR.wip_entity_id    = WO.wip_entity_id
        AND  WOR.organization_id  = WO.organization_id
        AND  CDO.organization_id  = WO.organization_id
        AND  WO.organization_id   = p_organization_id
        AND  CDO.department_id    = WO.department_id
        AND  CDO.overhead_id      = CRO.overhead_id
        AND  CRO.resource_id      = WOR.resource_id
        AND  CRO.cost_type_id     = 1
        AND  CDO.cost_type_id     = 1
        AND  CDO.basis_type       in (3,4)
        AND  WO.operation_seq_num = WOR.operation_seq_num
        AND  WO.operation_seq_num <= p_operation_seq_num
        /* Don't insert if a row already exists 5364135 */
        AND  NOT EXISTS (SELECT 'Not exists'
                         FROM   wip_operation_overheads woo
                         WHERE  woo.wip_entity_id     = WO.wip_entity_id
                         AND    woo.operation_seq_num = WO.operation_seq_num
                         AND    woo.resource_seq_num  = WOR.resource_seq_num
                         AND    woo.organization_id   = WO.organization_id
                         AND    woo.overhead_id       = CDO.overhead_id
                         AND    woo.basis_type        = CDO.basis_type)
        UNION ALL
        SELECT /* Department Based Overheads */
           WO.wip_entity_id,
           WO.operation_seq_num,
           -1,
           WO.organization_id,
           CDO.overhead_id,
           CDO.basis_type,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
	   p_user_id,
           sysdate,
	   p_user_id,
	   p_login_id,
	   p_request_id,
	   p_prog_appl_id,
	   p_program_id,
	   sysdate,
	   sysdate
        FROM
            cst_department_overheads CDO,
            wip_operations WO
        WHERE
             WO.wip_entity_id     = p_wip_entity_id
        AND  CDO.department_id    = WO.department_id
        AND  CDO.organization_id  = WO.organization_id
        AND  CDO.cost_type_id     = 1
        AND  CDO.basis_type       in (1,2)
        AND  WO.organization_id   = p_organization_id
        AND  WO.operation_seq_num <= p_operation_seq_num
        /* Don't insert if a row already exists 5364135 */
        AND  NOT EXISTS (SELECT 'Not exists'
                            FROM   wip_operation_overheads woo
                            WHERE  woo.wip_entity_id     = WO.wip_entity_id
                            AND    woo.operation_seq_num = WO.operation_seq_num
                            AND    woo.resource_seq_num  = -1
                            AND    woo.organization_id   = WO.organization_id
                            AND    woo.overhead_id       = CDO.overhead_id
                            AND    woo.basis_type        = CDO.basis_type));

  l_num_rows := SQL%ROWCOUNT;

  IF(l_debug_flag = 'Y') THEN
    FND_FILE.put_line(fnd_file.log, to_char(l_num_rows)||' rows inserted into WOO for Job: '||to_char(p_wip_entity_id));
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'INSERT_WOO >>>');
  END IF;
  RETURN l_return;

EXCEPTION
  WHEN OTHERS THEN
    IF(l_debug_flag = 'Y') THEN
      FND_FILE.put_line(fnd_file.log, 'Failed to Insert into WOO: '||SQLERRM);
    END IF;
    RETURN FALSE;

END INSERT_WOO;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--  COST_SPLIT_TXN                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--  This procedure costs a lot split transaction. It inserts entries in
--  MTA, WT and WTA. It also updates the WPB for all the involved jobs.
--                                                                        --
-- PURPOSE:                                                               --
--  OSFM Lot Transactions Costing for Oracle Applications Rel 11i.8
--                                                                        --
-- PARAMETERS:                                                            --
--  p_app_version         API version
--  p_transaction_id      Transaction ID from WSMT
--  p_mmt_transaction_id  Transaction ID form MMT
--  p_request_id          Request ID of calling worker
--  p_transaction_date    Transaction Date
--  p_prog_application_id
--  p_program_id
--  p_login_id
--  p_user_id             Concurrent WHO Parameters
--  o_err_num             Error Number
--  o_err_code            Error Code                                      --
--  o_err_msg             Error Message                                   --
-- HISTORY:                                                               --
--  August-2002         Vinit                       Creation              --
----------------------------------------------------------------------------
PROCEDURE COST_SPLIT_TXN (p_api_version            IN NUMBER,
                          p_transaction_id         IN NUMBER,
                          p_mmt_transaction_id     IN NUMBER,
                          p_transaction_date       IN DATE,
                          p_prog_application_id    IN NUMBER,
                          p_program_id             IN NUMBER,
                          p_request_id             IN NUMBER,
                          p_login_id               IN NUMBER,
                          p_user_id                IN NUMBER,
                          x_err_num                IN OUT NOCOPY NUMBER,
                          x_err_code               IN OUT NOCOPY VARCHAR2,
                          x_err_msg                IN OUT NOCOPY VARCHAR2) IS

/* Parameters */
l_transaction_type        NUMBER;
l_organization_id         NUMBER;
l_transaction_date        DATE;
l_min_acct_unit           NUMBER      := 0;
l_ext_prec                NUMBER(2)   := 0;
l_wip_transaction_id      NUMBER;
l_acct_period_id          NUMBER;

/* Local Variables */
l_stmt_num                NUMBER      := 0;
l_ins_woo                 BOOLEAN     := TRUE;
l_le_transaction_date     DATE;

/* API */
l_api_name    CONSTANT    VARCHAR2(240)  := 'COST_SPLIT_TXN';
l_api_version CONSTANT    NUMBER      := 1.0;

/* Representative Lot Information */
l_rep_wip_entity_id       NUMBER;
l_available_quantity      NUMBER;
l_job_start_quantity      NUMBER;
l_operation_seq_num       NUMBER;
l_intraoperation_step     NUMBER;


/* Resulting Jobs */
l_total_resulting_qty     NUMBER;

/* Job Charges */
l_pl_mtl_cost_in          NUMBER      := 0;
l_pl_mto_cost_in          NUMBER      := 0;
l_pl_res_cost_in          NUMBER      := 0;
l_pl_ovh_cost_in          NUMBER      := 0;
l_pl_osp_cost_in          NUMBER      := 0;
l_tl_res_cost_in          NUMBER      := 0;
l_tl_ovh_cost_in          NUMBER      := 0;
l_tl_osp_cost_in          NUMBER      := 0;

/* Relieved Costs */
l_pl_mtl_cost_out         NUMBER      := 0;
l_pl_mto_cost_out         NUMBER      := 0;
l_pl_res_cost_out         NUMBER      := 0;
l_pl_ovh_cost_out         NUMBER      := 0;
l_pl_osp_cost_out         NUMBER      := 0;
l_tl_res_cost_out         NUMBER      := 0;
l_tl_ovh_cost_out         NUMBER      := 0;
l_tl_osp_cost_out         NUMBER      := 0;


/* Net Cost and Total Costs */
l_pl_mtl_net              NUMBER      := 0;
l_pl_mto_net              NUMBER      := 0;
l_pl_res_net              NUMBER      := 0;
l_pl_ovh_net              NUMBER      := 0;
l_pl_osp_net              NUMBER      := 0;
l_tl_res_net              NUMBER      := 0;
l_tl_ovh_net              NUMBER      := 0;
l_tl_osp_net              NUMBER      := 0;

l_total_tl_res            NUMBER      := 0;
l_total_tl_ovh            NUMBER      := 0;
l_total_tl_osp            NUMBER      := 0;
l_total_pl_mtl            NUMBER      := 0;
l_total_pl_mto            NUMBER      := 0;
l_total_pl_res            NUMBER      := 0;
l_total_pl_ovh            NUMBER      := 0;
l_total_pl_osp            NUMBER      := 0;

l_total_qty               NUMBER      := 0;

/* Exceptions */

GET_JOB_VALUE_FAILURE          EXCEPTION;
FAILED_INSERTING_START_LOT     EXCEPTION;
FAILED_BALANCING_ACCT          EXCEPTION;
FAILED_INSERTING_WT            EXCEPTION;
FAILED_INSERTING_WTA           EXCEPTION;
FAILED_INSERTING_MTA           EXCEPTION;
FAILED_INSERTING_RESULT_LOT    EXCEPTION;
INSERT_WOO_ERROR               EXCEPTION;

/* Accounting Line Types */
SPLIT_RESULT_ACT_LTYPE         NUMBER := 22;
SPLIT_START_ACT_LTYPE          NUMBER := 21;

/* SLA Event Seeding */
l_return_status      VARCHAR2(1);
l_wta_exists         NUMBER;
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
l_trx_info           CST_XLA_PVT.t_xla_wip_trx_info;



CURSOR c_start_lot IS
SELECT available_quantity, wip_entity_id
FROM wsm_sm_starting_jobs
WHERE transaction_id = p_transaction_id;

CURSOR c_result_lot  IS
SELECT start_quantity, wip_entity_id,
        nvl(starting_operation_seq_num,10) starting_operation_seq_num,
        nvl(starting_intraoperation_step, WIP_CONSTANTS.QUEUE) starting_intraoperation_step,
	common_routing_sequence_id
FROM wsm_sm_resulting_jobs
WHERE transaction_id = p_transaction_id;

CURSOR c_new_jobs IS
SELECT wip_entity_id
FROM wsm_sm_resulting_jobs
WHERE transaction_id = p_transaction_id
AND   wip_entity_id not in
      ( SELECT wip_entity_id
        FROM wsm_sm_starting_jobs
        WHERE transaction_id = p_transaction_id );


BEGIN
  /* Check API Compatibility */
  l_stmt_num := 10;

  IF(l_debug_flag = 'Y') THEN
   FND_FILE.put_line(fnd_file.log, 'CSTPSMUT.COST_SPLIT_TXN <<<');
   fnd_file.put_line(fnd_file.log, 'Costing Transaction: '||to_char(p_transaction_id));
  END IF;

  IF NOT FND_API.COMPATIBLE_API_CALL (
                               l_api_version,
                               p_api_version,
                               l_api_name,
                               G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;



  /* Get Transaction Information from WSMT */

  l_stmt_num := 20;
  SELECT organization_id,
         transaction_type_id,
         transaction_date
  INTO   l_organization_id,
         l_transaction_type,
         l_transaction_date
  FROM   WSM_SPLIT_MERGE_TRANSACTIONS
  WHERE transaction_id = p_transaction_id;

  /* Get Currency Information and Precision */

  l_stmt_num := 30;

  SELECT NVL(FC.minimum_accountable_unit, POWER(10,NVL(-precision,0))),
         NVL(FC.extended_precision,NVL(FC.precision,0))
  INTO l_min_acct_unit,
       l_ext_prec
  FROM fnd_currencies FC,
       CST_ORGANIZATION_DEFINITIONS O
  WHERE O.organization_id = l_organization_id
  AND   O.currency_code = FC.currency_code;

  /* Accounting Period */
  l_stmt_num := 35;

  l_le_transaction_date := INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_INV_ORG(
                           l_transaction_date,
                           l_organization_id);

  l_stmt_num := 40;

  SELECT acct_period_id
  INTO   l_acct_period_id
  FROM   org_acct_periods
  WHERE  organization_id = l_organization_id
  AND    l_le_transaction_date
         between period_start_date and schedule_close_date;


  /* Get Information from WSSJ */

  l_stmt_num := 50;
  SELECT wip_entity_id,
         operation_seq_num,
         intraoperation_step,
         job_start_quantity,
         available_quantity
  INTO   l_rep_wip_entity_id,
         l_operation_seq_num,
         l_intraoperation_step,
         l_job_start_quantity,
         l_available_quantity
  FROM   WSM_SM_STARTING_JOBS
  WHERE  transaction_id      = p_transaction_id
  AND    representative_flag = 'Y';


  /* Obtain Total Resulting Quantity */
  l_stmt_num := 60;
  SELECT SUM(start_quantity)
  INTO   l_total_resulting_qty
  FROM   WSM_SM_RESULTING_JOBS
  WHERE  transaction_id = p_transaction_id;


  /* Get the Job Charges */

  l_stmt_num := 70;

  CSTPSMUT.GET_JOB_VALUE ( p_api_version       => 1.0,
                           p_lot_size          => l_job_start_quantity,
                           p_run_mode          => 1,           -- CHARGE
                           p_entity_id         => l_rep_wip_entity_id,
                           p_intraop_step      => l_intraoperation_step,
                           p_operation_seq_num => l_operation_seq_num,
                           p_transaction_id    => p_transaction_id,
                           p_txn_type          => WSMPCNST.SPLIT,
                           p_org_id            => l_organization_id,
                           x_err_num           => x_err_num,
                           x_err_code          => x_err_code,
                           x_err_msg           => x_err_msg,
                           x_pl_mtl_cost       => l_pl_mtl_cost_in,
                           x_pl_mto_cost       => l_pl_mto_cost_in,
                           x_pl_res_cost       => l_pl_res_cost_in,
                           x_pl_ovh_cost       => l_pl_ovh_cost_in,
                           x_pl_osp_cost       => l_pl_osp_cost_in,
                           x_tl_res_cost       => l_tl_res_cost_in,
                           x_tl_ovh_cost       => l_tl_ovh_cost_in,
                           x_tl_osp_cost       => l_tl_osp_cost_in );



  /* Get the Costs Relieved from the job */
  l_stmt_num := 80;

  CSTPSMUT.GET_JOB_VALUE ( p_api_version       => 1.0,
                           p_lot_size          => l_job_start_quantity,
                           p_run_mode          => 2,           -- SCRAP
                           p_entity_id         => l_rep_wip_entity_id,
                           p_intraop_step      => l_intraoperation_step,
                           p_operation_seq_num => l_operation_seq_num,
                           p_transaction_id    => p_transaction_id,
                           p_txn_type          => WSMPCNST.SPLIT,
                           p_org_id            => l_organization_id,
                           x_err_num           => x_err_num,
                           x_err_code          => x_err_code,
                           x_err_msg           => x_err_msg,
                           x_pl_mtl_cost       => l_pl_mtl_cost_out,
                           x_pl_mto_cost       => l_pl_mto_cost_out,
                           x_pl_res_cost       => l_pl_res_cost_out,
                           x_pl_ovh_cost       => l_pl_ovh_cost_out,
                           x_pl_osp_cost       => l_pl_osp_cost_out,
                           x_tl_res_cost       => l_tl_res_cost_out,
                           x_tl_ovh_cost       => l_tl_ovh_cost_out,
                           x_tl_osp_cost       => l_tl_osp_cost_out );


  l_stmt_num := 90;

  l_pl_mtl_net := l_pl_mtl_cost_in - l_pl_mtl_cost_out;
  l_pl_mto_net := l_pl_mto_cost_in - l_pl_mto_cost_out;
  l_pl_res_net := l_pl_res_cost_in - l_pl_res_cost_out;
  l_pl_ovh_net := l_pl_ovh_cost_in - l_pl_ovh_cost_out;
  l_pl_osp_net := l_pl_osp_cost_in - l_pl_osp_cost_out;

  l_tl_res_net := l_tl_res_cost_in - l_tl_res_cost_out;
  l_tl_ovh_net := l_tl_ovh_cost_in - l_tl_ovh_cost_out;
  l_tl_osp_net := l_tl_osp_cost_in - l_tl_osp_cost_out;

  l_stmt_num := 100;

  get_wip_txn_id(l_wip_transaction_id,
                      x_err_num,
                      x_err_code,
                      x_err_msg);


  l_stmt_num := 110;

  FOR c_result in c_result_lot LOOP
    IF (l_rep_wip_entity_id <> c_result.wip_entity_id) THEN

       l_stmt_num := 90;

       CSTPSMUT.INSERT_MAT_TXN_ACCT(
		   l_transaction_date,
		   l_min_acct_unit,
		   l_ext_prec,
		   l_transaction_type,
		   p_mmt_transaction_id,
		   l_organization_id,
		   c_result.wip_entity_id,
		   SPLIT_RESULT_ACT_LTYPE,
                   c_result.start_quantity,
		   (c_result.start_quantity / l_total_resulting_qty * l_pl_mtl_net),
		   (c_result.start_quantity / l_total_resulting_qty * l_pl_mto_net),
		   (c_result.start_quantity / l_total_resulting_qty * l_pl_res_net),
		   (c_result.start_quantity / l_total_resulting_qty * l_pl_ovh_net),
		   (c_result.start_quantity / l_total_resulting_qty * l_pl_osp_net),
                   p_user_id,
                   p_login_id,
                   p_request_id,
                   p_prog_application_id,
                   p_program_id,
                   l_debug_flag,
                   x_err_num,
                   x_err_code,
                   x_err_msg);

       IF x_err_num <> 0 then
         RAISE FAILED_INSERTING_MTA;
       END IF;

       /* Insert into WTA */

       l_stmt_num := 110;

       CSTPSMUT.INSERT_WIP_TXN_ACCT(
         l_transaction_date,
         l_min_acct_unit,
         l_ext_prec,
         p_transaction_id,
         l_transaction_type,
         l_wip_transaction_id,
         l_organization_id,
         c_result.wip_entity_id,
         SPLIT_RESULT_ACT_LTYPE,
         c_result.start_quantity,
         0, -- This Level Material Cost
         0, -- This Level Material Ovhd Cost
        (c_result.start_quantity / l_total_resulting_qty * l_tl_res_net),
        (c_result.start_quantity / l_total_resulting_qty * l_tl_ovh_net),
        (c_result.start_quantity / l_total_resulting_qty * l_tl_osp_net),
         p_user_id,
         p_login_id,
         p_request_id,
         p_prog_application_id,
         p_program_id,
         l_debug_flag,
         x_err_num,
         x_err_code,
         x_err_msg);

       IF x_err_num <> 0 then
         RAISE FAILED_INSERTING_WTA;
       END IF;

       /* Update WPB of resulting Lot */

       l_stmt_num := 120;

      CSTPSMUT.RESULT_LOT(
			p_mmt_transaction_id,
			l_wip_transaction_id,
			c_result.wip_entity_id,
			l_acct_period_id,
                        p_user_id,
                        p_login_id,
                        p_request_id,
                        p_prog_application_id,
                        p_program_id,
                        l_debug_flag,
                        x_err_num,
                        x_err_code,
                        x_err_msg);
        IF x_err_num <> 0 then
          RAISE FAILED_INSERTING_RESULT_LOT;
        END IF;

        l_stmt_num := 130;

        /* Update the Amount to be relieved from the parent */

        l_total_tl_res := l_total_tl_res + (ROUND(c_result.start_quantity / l_total_resulting_qty * l_tl_res_net / l_min_acct_unit) * l_min_acct_unit);
        l_total_tl_ovh := l_total_tl_ovh + (ROUND(c_result.start_quantity / l_total_resulting_qty * l_tl_ovh_net / l_min_acct_unit) * l_min_acct_unit);
        l_total_tl_osp := l_total_tl_osp + (ROUND(c_result.start_quantity / l_total_resulting_qty * l_tl_osp_net / l_min_acct_unit) * l_min_acct_unit);
        l_total_pl_mtl := l_total_pl_mtl + (ROUND(c_result.start_quantity / l_total_resulting_qty * l_pl_mtl_net / l_min_acct_unit) * l_min_acct_unit);
        l_total_pl_mto := l_total_pl_mto + (ROUND(c_result.start_quantity / l_total_resulting_qty * l_pl_mto_net / l_min_acct_unit) * l_min_acct_unit);
        l_total_pl_res := l_total_pl_res + (ROUND(c_result.start_quantity / l_total_resulting_qty * l_pl_res_net / l_min_acct_unit) * l_min_acct_unit);
        l_total_pl_ovh := l_total_pl_ovh + (ROUND(c_result.start_quantity / l_total_resulting_qty * l_pl_ovh_net / l_min_acct_unit) * l_min_acct_unit);
        l_total_pl_osp := l_total_pl_osp + (ROUND(c_result.start_quantity / l_total_resulting_qty * l_pl_osp_net / l_min_acct_unit) * l_min_acct_unit);
        l_total_qty    := l_total_qty + c_result.start_quantity;

    END IF;  -- Non Representative Lot

  END LOOP;  -- End Resulting Lots

  IF(l_debug_flag = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'Net Cost to be Relieved from Rep. Lot: ');
    fnd_file.put_line(fnd_file.log, 'PL_MTL: '||to_char(l_total_pl_mtl));
    fnd_file.put_line(fnd_file.log, 'PL_MOH: '||to_char(l_total_pl_mto));
    fnd_file.put_line(fnd_file.log, 'PL_RES: '||to_char(l_total_pl_res));
    fnd_file.put_line(fnd_file.log, 'PL_OVH: '||to_char(l_total_pl_ovh));
    fnd_file.put_line(fnd_file.log, 'TL_RES: '||to_char(l_total_tl_res));
    fnd_file.put_line(fnd_file.log, 'TL_OVH: '||to_char(l_total_tl_ovh));
  END IF;

  /* Only One Lot in Starting Jobs but cursor can be used since it is already there */
  FOR C_start in c_start_lot LOOP
    l_stmt_num := 140;

    /* Insert into MTA for Representative Lot */

    CSTPSMUT.INSERT_MAT_TXN_ACCT(
	l_transaction_date,
	l_min_acct_unit,
	l_ext_prec,
	l_transaction_type,
	p_mmt_transaction_id,
	l_organization_id,
	c_start.wip_entity_id,
	SPLIT_START_ACT_LTYPE,
        -l_total_qty,
        -l_total_pl_mtl,
        -l_total_pl_mto,
        -l_total_pl_res,
        -l_total_pl_ovh,
        -l_total_pl_osp,
        p_user_id,
        p_login_id,
        p_request_id,
        p_prog_application_id,
        p_program_id,
        l_debug_flag,
        x_err_num,
        x_err_code,
        x_err_msg);

    IF x_err_num <> 0 then
      RAISE FAILED_INSERTING_MTA;
    END IF;

    l_stmt_num := 150;

    /* Insert TL Accounting into WTA */

    CSTPSMUT.INSERT_WIP_TXN_ACCT(
		   l_transaction_date,
		   l_min_acct_unit,
		   l_ext_prec,
                   p_transaction_id,
		   l_transaction_type,
		   l_wip_transaction_id,
		   l_organization_id,
		   c_start.wip_entity_id,
		   SPLIT_START_ACT_LTYPE,
                   -l_total_qty,
		   0, -- This Level Material Cost
		   0, -- This Level Material Ovhd Cost
                   -l_total_tl_res,
                   -l_total_tl_ovh,
                   -l_total_tl_osp,
                   p_user_id,
                   p_login_id,
                   p_request_id,
                   p_prog_application_id,
                   p_program_id,
                   l_debug_flag,
                   x_err_num,
                   x_err_code,
                   x_err_msg);

    IF x_err_num <> 0 then
      RAISE FAILED_INSERTING_WTA;
    END IF;

    /* Insert Transaction into WT */

    l_stmt_num := 160;
    CSTPSMUT.INSERT_WIP_TXN(
		        l_transaction_date,
                        p_transaction_id,
                        l_wip_transaction_id,
                        l_acct_period_id,
                        c_start.wip_entity_id,
                        l_operation_seq_num,
                        11,      -- WIP Transaction type
                        p_user_id,
                        p_login_id,
                        p_request_id,
                        p_prog_application_id,
                        p_program_id,
                        l_debug_flag,
                        x_err_num,
                        x_err_code,
                        x_err_msg,
                        p_mmt_transaction_id); -- Added for Bug#4307365

    IF x_err_num <> 0 then
      RAISE FAILED_INSERTING_WT;
    END IF;

    /* Make sure the Debit/Credit for Representative Lot and Resulting Lots
       are balanced */

    l_stmt_num := 170;
    CSTPSMUT.BALANCE_ACCOUNTING(p_mmt_transaction_id,
                                l_wip_transaction_id,
                                l_transaction_type,
                                x_err_msg,
                                x_err_code,
                                x_err_num);
    IF x_err_num <> 0 then
      RAISE FAILED_BALANCING_ACCT;
    END IF;

    /* Update WPB of Representative Lot */
    l_stmt_num := 180;
    CSTPSMUT.START_LOT(
                        p_mmt_transaction_id,
                        l_wip_transaction_id,
                        c_start.wip_entity_id,
                        l_acct_period_id,
                        p_user_id,
                        p_login_id,
                        p_request_id,
                        p_prog_application_id,
                        p_program_id,
                        x_err_num,
                        x_err_code,
                        x_err_msg);
    IF x_err_num <> 0 then
      RAISE FAILED_INSERTING_START_LOT;
    END IF;

  END LOOP;

  l_stmt_num := 190;

  FOR new_job in c_new_jobs LOOP
    l_ins_woo := INSERT_WOO (
                   new_job.wip_entity_id,
                   l_organization_id,
                   l_operation_seq_num,
                   p_user_id,
                   p_login_id,
                   p_request_id,
                   p_prog_application_id,
                   p_program_id );
    IF l_ins_woo = FALSE THEN
      RAISE INSERT_WOO_ERROR;
    END IF;
  END LOOP;

  l_stmt_num := 200;

  SELECT count(*)
  INTO   l_wta_exists
  FROM   WIP_TRANSACTION_ACCOUNTS
  WHERE  transaction_id = l_wip_transaction_id
  and    rownum=1;

  IF l_wta_exists > 0 THEN
    /* SLA Event Seeding */
    l_trx_info.TRANSACTION_ID := l_wip_transaction_id;
    l_trx_info.INV_ORGANIZATION_ID := l_organization_id;
    l_trx_info.WIP_RESOURCE_ID     := -1;
    l_trx_info.WIP_BASIS_TYPE_ID   := -1;
    l_trx_info.TXN_TYPE_ID    := 11;
    l_trx_info.TRANSACTION_DATE := l_transaction_date;


    l_stmt_num := 210;

    CST_XLA_PVT.Create_WIPXLAEvent(
      p_api_version      => 1.0,
      p_init_msg_list    => FND_API.G_FALSE,
      p_commit           => FND_API.G_FALSE,
      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data,
      p_trx_info         => l_trx_info);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

  END IF;
  IF(l_debug_flag = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'CSTPSMUT.COST_SPLIT_TXN >>>');
  END IF;


EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_err_num  := -1;
    x_err_code := 'Inconsistent API Version';--FND_API.G_RET_SYS_ERROR;
    x_err_msg  := 'Inconsistent API Version: CSTPSMUT.COST_SPLIT_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
    FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
 WHEN GET_JOB_VALUE_FAILURE THEN
    x_err_num  := -1;
    x_err_code := 'Error getting Job Charges/Scrap';
    x_err_msg  := 'Error getting Job Charges/Scrap: CSTPSMUT.COST_SPLIT_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
    FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
 WHEN FAILED_INSERTING_START_LOT THEN
    x_err_num  := -1;
    x_err_code := 'Error Inserting WPB Information for Starting Lot';
    x_err_msg  := 'Error Inserting WPB Information for Starting Lot: CSTPSMUT.COST_SPLIT_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_BALANCING_ACCT THEN
    x_err_num  := -1;
    x_err_code := 'Error Balancing Accounts';
    x_err_msg  := 'Error Balancing Accounts: CSTPSMUT.COST_SPLIT_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_INSERTING_WT THEN
    x_err_num  := -1;
    x_err_code := 9999;
    x_err_msg  := 'Error inserting into Wip Transactions: CSTPSMUT.COST_SPLIT_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_INSERTING_WTA THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into Wip Transaction Accounts';
    x_err_msg  := 'Error inserting into Wip Transaction Accounts: CSTPSMUT.COST_SPLIT_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_INSERTING_MTA THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into MTL Transaction Accounts';
    x_err_msg  := 'Error inserting into MTL Transaction Accounts: CSTPSMUT.COST_SPLIT_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_INSERTING_RESULT_LOT THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into WPB for Resulting Lot';
    x_err_msg  := 'Error inserting into WPB for Resulting Lot: CSTPSMUT.COST_SPLIT_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);

 WHEN INSERT_WOO_ERROR THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into WOO';
    x_err_msg  := 'Error inserting into WOO: CSTPSMUT.COST_SPLIT_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN OTHERS THEN
    x_err_num  := -1;
    x_err_code := 'Error in CSTPSMUT.COST_SPLIT_TXN';
    x_err_msg  := 'Error in CSTPSMUT.COST_SPLIT_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
END COST_SPLIT_TXN;



----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--  COST_MERGE_TXN                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--  This procedure costs a lot merge transaction. It inserts entries in
--  MTA, WT and WTA. It also updates the WPB for all the involved jobs.
--                                                                        --
-- PURPOSE:                                                               --
--  OSFM Lot Transactions Costing for Oracle Applications Rel 11i.8
--                                                                        --
-- PARAMETERS:                                                            --
--  p_app_version         API version
--  p_transaction_id      Transaction ID from WSMT
--  p_mmt_transaction_id  Transaction ID form MMT
--  p_request_id          Request ID of calling worker
--  p_transaction_date    Transaction Date
--  p_prog_application_id
--  p_program_id
--  p_login_id
--  p_user_id             Concurrent WHO Parameters
--  x_err_num             Error Number
--  x_err_code            Error Code                                      --
--  x_err_msg             Error Message                                   --
-- HISTORY:                                                               --
--  August-2002         Vinit                       Creation              --
----------------------------------------------------------------------------
PROCEDURE COST_MERGE_TXN (p_api_version            IN NUMBER,
                          p_transaction_id         IN NUMBER,
                          p_mmt_transaction_id     IN NUMBER,
                          p_transaction_date       IN DATE,
                          p_prog_application_id    IN NUMBER,
                          p_program_id             IN NUMBER,
                          p_request_id             IN NUMBER,
                          p_login_id               IN NUMBER,
                          p_user_id                IN NUMBER,
                          x_err_num                IN OUT NOCOPY NUMBER,
                          x_err_code               IN OUT NOCOPY VARCHAR2,
                          x_err_msg                IN OUT NOCOPY VARCHAR2) IS

/* Parameters */
l_transaction_type        NUMBER;
l_organization_id         NUMBER;
l_transaction_date        DATE;
l_min_acct_unit           NUMBER      := 0;
l_ext_prec                NUMBER(2)   := 0;
l_wip_transaction_id      NUMBER;
l_acct_period_id          NUMBER;

/* Local Variables */
l_stmt_num                NUMBER      := 0;
l_ins_woo                 BOOLEAN     := TRUE;
l_le_transaction_date     DATE;

/* API */
l_api_name    CONSTANT    VARCHAR2(240)  := 'COST_MERGE_TXN';
l_api_version CONSTANT    NUMBER      := 1.0;

/* Representative Lot Information */
l_rep_wip_entity_id       NUMBER;
l_available_quantity      NUMBER;
l_job_start_quantity      NUMBER;
l_operation_seq_num       NUMBER;
l_intraoperation_step     NUMBER;


/* Resulting Jobs */
l_total_resulting_qty     NUMBER;
l_result_wip_entity_id    NUMBER;

/* Job Charges */
l_pl_mtl_cost_in          NUMBER      := 0;
l_pl_mto_cost_in          NUMBER      := 0;
l_pl_res_cost_in          NUMBER      := 0;
l_pl_ovh_cost_in          NUMBER      := 0;
l_pl_osp_cost_in          NUMBER      := 0;
l_tl_res_cost_in          NUMBER      := 0;
l_tl_ovh_cost_in          NUMBER      := 0;
l_tl_osp_cost_in          NUMBER      := 0;

/* Relieved Costs */
l_pl_mtl_cost_out         NUMBER      := 0;
l_pl_mto_cost_out         NUMBER      := 0;
l_pl_res_cost_out         NUMBER      := 0;
l_pl_ovh_cost_out         NUMBER      := 0;
l_pl_osp_cost_out         NUMBER      := 0;
l_tl_res_cost_out         NUMBER      := 0;
l_tl_ovh_cost_out         NUMBER      := 0;
l_tl_osp_cost_out         NUMBER      := 0;



/* Representative Job Charges */
l_pl_rep_mtl_cost_in          NUMBER      := 0;
l_pl_rep_mto_cost_in          NUMBER      := 0;
l_pl_rep_res_cost_in          NUMBER      := 0;
l_pl_rep_ovh_cost_in          NUMBER      := 0;
l_pl_rep_osp_cost_in          NUMBER      := 0;
l_tl_rep_res_cost_in          NUMBER      := 0;
l_tl_rep_ovh_cost_in          NUMBER      := 0;
l_tl_rep_osp_cost_in          NUMBER      := 0;

/* Representative Job Relieved Costs */
l_pl_rep_mtl_cost_out         NUMBER      := 0;
l_pl_rep_mto_cost_out         NUMBER      := 0;
l_pl_rep_res_cost_out         NUMBER      := 0;
l_pl_rep_ovh_cost_out         NUMBER      := 0;
l_pl_rep_osp_cost_out         NUMBER      := 0;
l_tl_rep_res_cost_out         NUMBER      := 0;
l_tl_rep_ovh_cost_out         NUMBER      := 0;
l_tl_rep_osp_cost_out         NUMBER      := 0;

/* Net Cost and Total Costs */
l_pl_mtl_net              NUMBER      := 0;
l_pl_mto_net              NUMBER      := 0;
l_pl_res_net              NUMBER      := 0;
l_pl_ovh_net              NUMBER      := 0;
l_pl_osp_net              NUMBER      := 0;
l_tl_res_net              NUMBER      := 0;
l_tl_ovh_net              NUMBER      := 0;
l_tl_osp_net              NUMBER      := 0;

l_total_tl_res            NUMBER      := 0;
l_total_tl_ovh            NUMBER      := 0;
l_total_tl_osp            NUMBER      := 0;
l_total_pl_mtl            NUMBER      := 0;
l_total_pl_mto            NUMBER      := 0;
l_total_pl_res            NUMBER      := 0;
l_total_pl_ovh            NUMBER      := 0;
l_total_pl_osp            NUMBER      := 0;

l_total_qty               NUMBER      := 0;

/* Exceptions */

GET_JOB_VALUE_FAILURE          EXCEPTION;
FAILED_INSERTING_START_LOT     EXCEPTION;
FAILED_BALANCING_ACCT          EXCEPTION;
FAILED_INSERTING_WT            EXCEPTION;
FAILED_INSERTING_WTA           EXCEPTION;
FAILED_INSERTING_MTA           EXCEPTION;
FAILED_INSERTING_RESULT_LOT    EXCEPTION;
INSERT_WOO_ERROR               EXCEPTION;

/* Accounting Line Types */
MERGE_RESULT_ACT_LTYPE         NUMBER := 24;
MERGE_START_ACT_LTYPE          NUMBER := 23;

/* SLA Event Seeding */
l_wta_exists         NUMBER;
l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
l_trx_info           CST_XLA_PVT.t_xla_wip_trx_info;


CURSOR c_start_lot IS
SELECT available_quantity, wip_entity_id
FROM wsm_sm_starting_jobs
WHERE transaction_id = p_transaction_id;

CURSOR c_result_lot  IS
SELECT start_quantity, wip_entity_id,
        nvl(starting_operation_seq_num,10) starting_operation_seq_num,
        nvl(starting_intraoperation_step, WIP_CONSTANTS.QUEUE) starting_intraoperation_step,
	common_routing_sequence_id
FROM wsm_sm_resulting_jobs
WHERE transaction_id = p_transaction_id;

CURSOR c_new_jobs IS
SELECT wip_entity_id
FROM wsm_sm_resulting_jobs
WHERE transaction_id = p_transaction_id
AND   wip_entity_id not in
      ( SELECT wip_entity_id
        FROM wsm_sm_starting_jobs
        WHERE transaction_id = p_transaction_id );

BEGIN

  /* Check API Compatibility */
  l_stmt_num := 10;

  IF(l_debug_flag = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'CSTPSMUT.COST_MERGE_TXN ... <<< ');
    fnd_file.put_line(fnd_file.log, 'Costing Transaction: '||to_char(p_transaction_id));
  END IF;

  IF NOT FND_API.COMPATIBLE_API_CALL (
                               l_api_version,
                               p_api_version,
                               l_api_name,
                               G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  /* Get Transaction Information from WSMT */

  l_stmt_num := 20;
  SELECT organization_id,
         transaction_type_id,
         transaction_date
  INTO   l_organization_id,
         l_transaction_type,
         l_transaction_date
  FROM   WSM_SPLIT_MERGE_TRANSACTIONS
  WHERE transaction_id = p_transaction_id;

  /* Get Currency Information and Precision */
  l_stmt_num := 30;
  SELECT NVL(FC.minimum_accountable_unit, POWER(10,NVL(-precision,0))),
         NVL(FC.extended_precision,NVL(FC.precision,0))
  INTO l_min_acct_unit,
       l_ext_prec
  FROM fnd_currencies FC,
       CST_ORGANIZATION_DEFINITIONS O
  WHERE O.organization_id = l_organization_id
  AND   O.currency_code = FC.currency_code;

  /* Accounting Period */
  l_stmt_num := 35;

  l_le_transaction_date := INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_INV_ORG(
                           l_transaction_date,
                           l_organization_id);

  l_stmt_num := 40;

  SELECT acct_period_id
  INTO   l_acct_period_id
  FROM   org_acct_periods
  WHERE  organization_id = l_organization_id
  AND    l_le_transaction_date
         between period_start_date and schedule_close_date;


  /* Get Information from WSSJ */

  l_stmt_num := 50;
  SELECT wip_entity_id,
         operation_seq_num,
         intraoperation_step,
         job_start_quantity,
         available_quantity
  INTO   l_rep_wip_entity_id,
         l_operation_seq_num,
         l_intraoperation_step,
         l_job_start_quantity,
         l_available_quantity
  FROM   WSM_SM_STARTING_JOBS
  WHERE  transaction_id      = p_transaction_id
  AND    representative_flag = 'Y';

  SELECT wip_entity_id
  INTO   l_result_wip_entity_id
  FROM   wsm_sm_resulting_jobs
  WHERE  transaction_id  = p_transaction_id;


  /* Get the Job Charges */

  l_stmt_num := 60;

  CSTPSMUT.GET_JOB_VALUE ( p_api_version       => 1.0,
                           p_lot_size          => l_job_start_quantity,
                           p_run_mode          => 1,           -- CHARGE
                           p_entity_id         => l_rep_wip_entity_id,
                           p_intraop_step      => l_intraoperation_step,
                           p_operation_seq_num => l_operation_seq_num,
                           p_transaction_id    => p_transaction_id,
                           p_txn_type          => WSMPCNST.MERGE,
                           p_org_id            => l_organization_id,
                           x_err_num           => x_err_num,
                           x_err_code          => x_err_code,
                           x_err_msg           => x_err_msg,
                           x_pl_mtl_cost       => l_pl_mtl_cost_in,
                           x_pl_mto_cost       => l_pl_mto_cost_in,
                           x_pl_res_cost       => l_pl_res_cost_in,
                           x_pl_ovh_cost       => l_pl_ovh_cost_in,
                           x_pl_osp_cost       => l_pl_osp_cost_in,
                           x_tl_res_cost       => l_tl_res_cost_in,
                           x_tl_ovh_cost       => l_tl_ovh_cost_in,
                           x_tl_osp_cost       => l_tl_osp_cost_in );

  IF x_err_num <> 0 THEN
    RAISE GET_JOB_VALUE_FAILURE;
  END IF;

  /* Get the Costs Relieved from the job */
  l_stmt_num := 70;

  CSTPSMUT.GET_JOB_VALUE ( p_api_version       => 1.0,
                           p_lot_size          => l_job_start_quantity,
                           p_run_mode          => 2,           -- SCRAP
                           p_entity_id         => l_rep_wip_entity_id,
                           p_intraop_step      => l_intraoperation_step,
                           p_operation_seq_num => l_operation_seq_num,
                           p_transaction_id    => p_transaction_id,
                           p_txn_type          => WSMPCNST.MERGE,
                           p_org_id            => l_organization_id,
                           x_err_num           => x_err_num,
                           x_err_code          => x_err_code,
                           x_err_msg           => x_err_msg,
                           x_pl_mtl_cost       => l_pl_mtl_cost_out,
                           x_pl_mto_cost       => l_pl_mto_cost_out,
                           x_pl_res_cost       => l_pl_res_cost_out,
                           x_pl_ovh_cost       => l_pl_ovh_cost_out,
                           x_pl_osp_cost       => l_pl_osp_cost_out,
                           x_tl_res_cost       => l_tl_res_cost_out,
                           x_tl_ovh_cost       => l_tl_ovh_cost_out,
                           x_tl_osp_cost       => l_tl_osp_cost_out );

  l_stmt_num := 80;

  l_pl_mtl_net := l_pl_mtl_cost_in - l_pl_mtl_cost_out;
  l_pl_mto_net := l_pl_mto_cost_in - l_pl_mto_cost_out;
  l_pl_res_net := l_pl_res_cost_in - l_pl_res_cost_out;
  l_pl_ovh_net := l_pl_ovh_cost_in - l_pl_ovh_cost_out;
  l_pl_osp_net := l_pl_osp_cost_in - l_pl_osp_cost_out;


  l_tl_res_net := l_tl_res_cost_in - l_tl_res_cost_out;
  l_tl_ovh_net := l_tl_ovh_cost_in - l_tl_ovh_cost_out;
  l_tl_osp_net := l_tl_osp_cost_in - l_tl_osp_cost_out;

  l_stmt_num := 90;

  get_wip_txn_id(l_wip_transaction_id,
                      x_err_num,
                      x_err_code,
                      x_err_msg);


  l_stmt_num := 100;

  FOR c_start in c_start_lot LOOP
    IF (l_rep_wip_entity_id <> c_start.wip_entity_id) THEN
      l_stmt_num := 110;
      IF(l_debug_flag = 'Y') THEN
        fnd_file.put_line(fnd_file.log, 'Processing Job: '||to_char(c_start.wip_entity_id));
      END IF;

      CSTPSMUT.INSERT_MAT_TXN_ACCT(
		   l_transaction_date,
		   l_min_acct_unit,
		   l_ext_prec,
		   l_transaction_type,
		   p_mmt_transaction_id,
		   l_organization_id,
		   c_start.wip_entity_id,
		   MERGE_START_ACT_LTYPE,
                   -c_start.available_quantity,
		   -c_start.available_quantity / l_available_quantity * l_pl_mtl_net,
		   -c_start.available_quantity / l_available_quantity * l_pl_mto_net,
		   -c_start.available_quantity / l_available_quantity * l_pl_res_net,
		   -c_start.available_quantity / l_available_quantity * l_pl_ovh_net,
		   -c_start.available_quantity / l_available_quantity * l_pl_osp_net,
                   p_user_id,
                   p_login_id,
                   p_request_id,
                   p_prog_application_id,
                   p_program_id,
                   l_debug_flag,
                   x_err_num,
                   x_err_code,
                   x_err_msg);

       IF x_err_num <> 0 then
         RAISE FAILED_INSERTING_MTA;
       END IF;

       /* Insert into WTA */

       l_stmt_num := 110;

       CSTPSMUT.INSERT_WIP_TXN_ACCT(
		   l_transaction_date,
		   l_min_acct_unit,
		   l_ext_prec,
                   p_transaction_id,
		   l_transaction_type,
		   l_wip_transaction_id,
		   l_organization_id,
		   c_start.wip_entity_id,
		   MERGE_START_ACT_LTYPE,
                   -c_start.available_quantity,
		   0, -- This Level Material Cost
		   0, -- This Level Material Ovhd Cost
		   -c_start.available_quantity / l_available_quantity * l_tl_res_net,
		   -c_start.available_quantity / l_available_quantity * l_tl_ovh_net,
		   -c_start.available_quantity / l_available_quantity * l_tl_osp_net,
                   p_user_id,
                   p_login_id,
                   p_request_id,
                   p_prog_application_id,
                   p_program_id,
                   l_debug_flag,
                   x_err_num,
                   x_err_code,
                   x_err_msg);

       IF x_err_num <> 0 then
         RAISE FAILED_INSERTING_WTA;
       END IF;

       /* Update WPB */

       l_stmt_num := 120;

       CSTPSMUT.START_LOT(
			p_mmt_transaction_id,
			l_wip_transaction_id,
			c_start.wip_entity_id,
			l_acct_period_id,
                        p_user_id,
                        p_login_id,
                        p_request_id,
                        p_prog_application_id,
                        p_program_id,
                        x_err_num,
                        x_err_code,
                        x_err_msg);
        IF x_err_num <> 0 then
          RAISE FAILED_INSERTING_RESULT_LOT;
        END IF;

        l_stmt_num := 130;

        /* Update the Amount to be relieved */

        l_total_tl_res := l_total_tl_res + (ROUND(c_start.available_quantity / l_available_quantity * l_tl_res_net / l_min_acct_unit) * l_min_acct_unit);
        l_total_tl_ovh := l_total_tl_ovh + (ROUND(c_start.available_quantity / l_available_quantity * l_tl_ovh_net / l_min_acct_unit) * l_min_acct_unit);
        l_total_tl_osp := l_total_tl_osp + (ROUND(c_start.available_quantity / l_available_quantity * l_tl_osp_net / l_min_acct_unit) * l_min_acct_unit);
        l_total_pl_mtl := l_total_pl_mtl + (ROUND(c_start.available_quantity / l_available_quantity * l_pl_mtl_net / l_min_acct_unit) * l_min_acct_unit);
        l_total_pl_mto := l_total_pl_mto + (ROUND(c_start.available_quantity / l_available_quantity * l_pl_mto_net / l_min_acct_unit) * l_min_acct_unit);
        l_total_pl_res := l_total_pl_res + (ROUND(c_start.available_quantity / l_available_quantity * l_pl_res_net / l_min_acct_unit) * l_min_acct_unit);
        l_total_pl_ovh := l_total_pl_ovh + (ROUND(c_start.available_quantity / l_available_quantity * l_pl_ovh_net / l_min_acct_unit) * l_min_acct_unit);
        l_total_pl_osp := l_total_pl_osp + (ROUND(c_start.available_quantity / l_available_quantity * l_pl_osp_net / l_min_acct_unit) * l_min_acct_unit);
        l_total_qty    := l_total_qty + c_start.available_quantity;

    END IF;  -- Non Representative Lot

  END LOOP;  -- End Starting Lots

  /* If the resulting job is not the representative lot,
     - Get the net job costs from the representative lot
       and add it to the total. This is the amount relieved
       from the representative lot itself.
     To get net job value (including lot based resources) call
     GET_JOB_VALUE with transaction_type split.
   */


  IF( l_rep_wip_entity_id <> l_result_wip_entity_id ) THEN
    /* Get the Job Charges */

    l_stmt_num := 140;

    CSTPSMUT.GET_JOB_VALUE ( p_api_version       => 1.0,
                           p_lot_size          => l_job_start_quantity,
                           p_run_mode          => 1,           -- CHARGE
                           p_entity_id         => l_rep_wip_entity_id,
                           p_intraop_step      => l_intraoperation_step,
                           p_operation_seq_num => l_operation_seq_num,
                           p_transaction_id    => p_transaction_id,
                           p_txn_type          => WSMPCNST.SPLIT,
                           p_org_id            => l_organization_id,
                           x_err_num           => x_err_num,
                           x_err_code          => x_err_code,
                           x_err_msg           => x_err_msg,
                           x_pl_mtl_cost       => l_pl_rep_mtl_cost_in,
                           x_pl_mto_cost       => l_pl_rep_mto_cost_in,
                           x_pl_res_cost       => l_pl_rep_res_cost_in,
                           x_pl_ovh_cost       => l_pl_rep_ovh_cost_in,
                           x_pl_osp_cost       => l_pl_rep_osp_cost_in,
                           x_tl_res_cost       => l_tl_rep_res_cost_in,
                           x_tl_ovh_cost       => l_tl_rep_ovh_cost_in,
                           x_tl_osp_cost       => l_tl_rep_osp_cost_in );

    IF x_err_num <> 0 THEN
      RAISE GET_JOB_VALUE_FAILURE;
    END IF;

    /* Get the Costs Relieved from the job */
    l_stmt_num := 150;

    CSTPSMUT.GET_JOB_VALUE ( p_api_version       => 1.0,
                           p_lot_size          => l_job_start_quantity,
                           p_run_mode          => 2,           -- SCRAP
                           p_entity_id         => l_rep_wip_entity_id,
                           p_intraop_step      => l_intraoperation_step,
                           p_operation_seq_num => l_operation_seq_num,
                           p_transaction_id    => p_transaction_id,
                           p_txn_type          => WSMPCNST.SPLIT,
                           p_org_id            => l_organization_id,
                           x_err_num           => x_err_num,
                           x_err_code          => x_err_code,
                           x_err_msg           => x_err_msg,
                           x_pl_mtl_cost       => l_pl_rep_mtl_cost_out,
                           x_pl_mto_cost       => l_pl_rep_mto_cost_out,
                           x_pl_res_cost       => l_pl_rep_res_cost_out,
                           x_pl_ovh_cost       => l_pl_rep_ovh_cost_out,
                           x_pl_osp_cost       => l_pl_rep_osp_cost_out,
                           x_tl_res_cost       => l_tl_rep_res_cost_out,
                           x_tl_ovh_cost       => l_tl_rep_ovh_cost_out,
                           x_tl_osp_cost       => l_tl_rep_osp_cost_out );

    /* Update MTA and WTA for representative start lot */
    /* Relieve everything that has been charged */

    CSTPSMUT.INSERT_MAT_TXN_ACCT(
		   l_transaction_date,
		   l_min_acct_unit,
		   l_ext_prec,
		   l_transaction_type,
		   p_mmt_transaction_id,
		   l_organization_id,
		   l_rep_wip_entity_id,
		   MERGE_START_ACT_LTYPE,
                   -l_available_quantity,
		   -(l_pl_rep_mtl_cost_in - l_pl_rep_mtl_cost_out),
		   -(l_pl_rep_mto_cost_in - l_pl_rep_mto_cost_out),
		   -(l_pl_rep_res_cost_in - l_pl_rep_res_cost_out),
		   -(l_pl_rep_ovh_cost_in - l_pl_rep_ovh_cost_out),
		   -(l_pl_rep_osp_cost_in - l_pl_rep_osp_cost_out),
                   p_user_id,
                   p_login_id,
                   p_request_id,
                   p_prog_application_id,
                   p_program_id,
                   l_debug_flag,
                   x_err_num,
                   x_err_code,
                   x_err_msg);

    IF x_err_num <> 0 then
      RAISE FAILED_INSERTING_MTA;
    END IF;

    /* Insert into WTA */

    l_stmt_num := 160;

    CSTPSMUT.INSERT_WIP_TXN_ACCT(
		   l_transaction_date,
		   l_min_acct_unit,
		   l_ext_prec,
                   p_transaction_id,
		   l_transaction_type,
		   l_wip_transaction_id,
		   l_organization_id,
		   l_rep_wip_entity_id,
		   MERGE_START_ACT_LTYPE,
                   -l_available_quantity,
		   0, -- This Level Material Cost
		   0, -- This Level Material Ovhd Cost
		   -(l_tl_rep_res_cost_in - l_tl_rep_res_cost_out),
		   -(l_tl_rep_ovh_cost_in - l_tl_rep_ovh_cost_out),
		   -(l_tl_rep_osp_cost_in - l_tl_rep_osp_cost_out),
                   p_user_id,
                   p_login_id,
                   p_request_id,
                   p_prog_application_id,
                   p_program_id,
                   l_debug_flag,
                   x_err_num,
                   x_err_code,
                   x_err_msg);

   IF x_err_num <> 0 then
     RAISE FAILED_INSERTING_WTA;
   END IF;

   /* Update WPB */

   l_stmt_num := 170;

   CSTPSMUT.START_LOT(
        		p_mmt_transaction_id,
			l_wip_transaction_id,
			l_rep_wip_entity_id,
			l_acct_period_id,
                        p_user_id,
                        p_login_id,
                        p_request_id,
                        p_prog_application_id,
                        p_program_id,
                        x_err_num,
                        x_err_code,
                        x_err_msg);
    IF x_err_num <> 0 then
      RAISE FAILED_INSERTING_RESULT_LOT;
    END IF;


    l_stmt_num := 180;

    l_total_tl_res := l_total_tl_res + ROUND((l_tl_rep_res_cost_in - l_tl_rep_res_cost_out)/l_min_acct_unit) * l_min_acct_unit;
    l_total_tl_ovh := l_total_tl_ovh + ROUND((l_tl_rep_ovh_cost_in - l_tl_rep_ovh_cost_out)/l_min_acct_unit) * l_min_acct_unit;
    l_total_tl_osp := l_total_tl_osp + ROUND((l_tl_rep_osp_cost_in - l_tl_rep_osp_cost_out)/l_min_acct_unit) * l_min_acct_unit;
    l_total_pl_mtl := l_total_pl_mtl + ROUND((l_pl_rep_mtl_cost_in - l_pl_rep_mtl_cost_out)/l_min_acct_unit) * l_min_acct_unit;
    l_total_pl_mto := l_total_pl_mto + ROUND((l_pl_rep_mto_cost_in - l_pl_rep_mto_cost_out)/l_min_acct_unit) * l_min_acct_unit;
    l_total_pl_res := l_total_pl_res + ROUND((l_pl_rep_res_cost_in - l_pl_rep_res_cost_out)/l_min_acct_unit) * l_min_acct_unit;
    l_total_pl_ovh := l_total_pl_ovh + ROUND((l_pl_rep_ovh_cost_in - l_pl_rep_ovh_cost_out)/l_min_acct_unit) * l_min_acct_unit;
    l_total_pl_osp := l_total_pl_osp + ROUND((l_pl_rep_osp_cost_in - l_pl_rep_osp_cost_out)/l_min_acct_unit) * l_min_acct_unit;
    l_total_qty    := l_total_qty + ROUND(l_available_quantity/l_min_acct_unit) * l_min_acct_unit;

  END IF;

  /* Only One Lot in Starting Jobs but cursor can be used since it is already there */
  IF(l_debug_flag = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'Net Charges in Resulting Job: ');
    fnd_file.put_line(fnd_file.log, 'PL_MTL: '||to_char(l_total_pl_mtl));
    fnd_file.put_line(fnd_file.log, 'PL_MOH: '||to_char(l_total_pl_mto));
    fnd_file.put_line(fnd_file.log, 'PL_RES: '||to_char(l_total_pl_res));
    fnd_file.put_line(fnd_file.log, 'PL_OVH: '||to_char(l_total_pl_ovh));
    fnd_file.put_line(fnd_file.log, 'TL_RES: '||to_char(l_total_tl_res));
    fnd_file.put_line(fnd_file.log, 'TL_OVH: '||to_char(l_total_tl_ovh));
  END IF;


  l_stmt_num := 200;
  IF(l_debug_flag = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'Processing Result Lot: '||to_char(l_result_wip_entity_id));
  END IF;

  /* Insert into MTA for Result Lot */
  CSTPSMUT.INSERT_MAT_TXN_ACCT(
	l_transaction_date,
	l_min_acct_unit,
	l_ext_prec,
	l_transaction_type,
	p_mmt_transaction_id,
	l_organization_id,
	l_result_wip_entity_id,
	MERGE_RESULT_ACT_LTYPE,
        l_total_qty,
        l_total_pl_mtl,
        l_total_pl_mto,
        l_total_pl_res,
        l_total_pl_ovh,
        l_total_pl_osp,
        p_user_id,
        p_login_id,
        p_request_id,
        p_prog_application_id,
        p_program_id,
        l_debug_flag,
        x_err_num,
        x_err_code,
        x_err_msg);

  IF x_err_num <> 0 then
    RAISE FAILED_INSERTING_MTA;
  END IF;

  l_stmt_num := 210;

  /* Insert TL Accounting into WTA */

  CSTPSMUT.INSERT_WIP_TXN_ACCT(
		   l_transaction_date,
		   l_min_acct_unit,
		   l_ext_prec,
                   p_transaction_id,
		   l_transaction_type,
		   l_wip_transaction_id,
		   l_organization_id,
		   l_result_wip_entity_id,
		   MERGE_RESULT_ACT_LTYPE,
                   l_total_qty,
		   0, -- This Level Material Cost
		   0, -- This Level Material Ovhd Cost
                   l_total_tl_res,
                   l_total_tl_ovh,
                   l_total_tl_osp,
                   p_user_id,
                   p_login_id,
                   p_request_id,
                   p_prog_application_id,
                   p_program_id,
                   l_debug_flag,
                   x_err_num,
                   x_err_code,
                   x_err_msg);

  IF x_err_num <> 0 then
    RAISE FAILED_INSERTING_WTA;
  END IF;

  /* Insert Transaction into WT */

  l_stmt_num := 220;
  CSTPSMUT.INSERT_WIP_TXN(
		        l_transaction_date,
                        p_transaction_id,
                        l_wip_transaction_id,
                        l_acct_period_id,
                        l_result_wip_entity_id,
                        l_operation_seq_num,
                        12,      -- WIP Transaction type
                        p_user_id,
                        p_login_id,
                        p_request_id,
                        p_prog_application_id,
                        p_program_id,
                        l_debug_flag,
                        x_err_num,
                        x_err_code,
                        x_err_msg,
                        p_mmt_transaction_id); -- Added for Bug#4307365

  IF x_err_num <> 0 then
    RAISE FAILED_INSERTING_WT;
  END IF;

  /* Make sure the Debit/Credit for Representative Lot and Resulting Lots
     are balanced */

  l_stmt_num := 190;
  CSTPSMUT.BALANCE_ACCOUNTING(p_mmt_transaction_id,
                                l_wip_transaction_id,
                                l_transaction_type,
                                x_err_msg,
                                x_err_code,
                                x_err_num);
  IF x_err_num <> 0 then
    RAISE FAILED_BALANCING_ACCT;
  END IF;

    /* Update WPB of Result Lot */

    l_stmt_num := 200;
    CSTPSMUT.RESULT_LOT(
                        p_mmt_transaction_id,
                        l_wip_transaction_id,
                        l_result_wip_entity_id,
                        l_acct_period_id,
                        p_user_id,
                        p_login_id,
                        p_request_id,
                        p_prog_application_id,
                        p_program_id,
                        l_debug_flag,
                        x_err_num,
                        x_err_code,
                        x_err_msg);
    IF x_err_num <> 0 then
      RAISE FAILED_INSERTING_START_LOT;
    END IF;

  /* Insert into WOO for each of the new jobs created due to the split */

  FOR new_job in c_new_jobs LOOP
    l_ins_woo := INSERT_WOO (
                   new_job.wip_entity_id,
                   l_organization_id,
		   l_operation_seq_num,
                   p_user_id,
                   p_login_id,
                   p_request_id,
                   p_prog_application_id,
                   p_program_id );
    IF l_ins_woo = FALSE THEN
      RAISE INSERT_WOO_ERROR;
    END IF;
  END LOOP;

  l_stmt_num := 200;

  SELECT count(*)
  INTO   l_wta_exists
  FROM   WIP_TRANSACTION_ACCOUNTS
  WHERE  transaction_id = l_wip_transaction_id
  and    rownum=1;

  IF l_wta_exists > 0 THEN
    /* SLA Event Seeding */
    l_trx_info.TRANSACTION_ID := l_wip_transaction_id;
    l_trx_info.INV_ORGANIZATION_ID := l_organization_id;
    l_trx_info.WIP_RESOURCE_ID     := -1;
    l_trx_info.WIP_BASIS_TYPE_ID   := -1;
    l_trx_info.TXN_TYPE_ID    := 12;
    l_trx_info.TRANSACTION_DATE := l_transaction_date;

    l_stmt_num := 210;

    CST_XLA_PVT.Create_WIPXLAEvent(
      p_api_version      => 1.0,
      p_init_msg_list    => FND_API.G_FALSE,
      p_commit           => FND_API.G_FALSE,
      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data,
      p_trx_info         => l_trx_info);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

  END IF;


  IF(l_debug_flag = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'CSTPSMUT.COST_MERGE_TXN ... >>> ');
  END IF;

EXCEPTION

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_err_num  := -1;
    x_err_code := 'Inconsistent API Version';--FND_API.G_RET_SYS_ERROR;
    x_err_msg  := 'Inconsistent API Version: CSTPSMUT.COST_MERGE_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
    FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
 WHEN GET_JOB_VALUE_FAILURE THEN
    x_err_num  := -1;
    x_err_code := 'Error getting Job Charges/Scrap';
    x_err_msg  := 'Error getting Job Charges/Scrap: CSTPSMUT.COST_MERGE_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
    FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
 WHEN FAILED_INSERTING_START_LOT THEN
    x_err_num  := -1;
    x_err_code := 'Error Inserting WPB Information for Starting Lot';
    x_err_msg  := 'Error Inserting WPB Information for Starting Lot: CSTPSMUT.COST_MERGE_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_BALANCING_ACCT THEN
    x_err_num  := -1;
    x_err_code := 'Error Balancing Accounts';
    x_err_msg  := 'Error Balancing Accounts: CSTPSMUT.COST_MERGE_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_INSERTING_WT THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into Wip Transactions';
    x_err_msg  := 'Error inserting into Wip Transactions: CSTPSMUT.COST_MERGE_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_INSERTING_WTA THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into Wip Transaction Accounts';
    x_err_msg  := 'Error inserting into Wip Transaction Accounts: CSTPSMUT.COST_MERGE_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_INSERTING_MTA THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into MTL Transaction Accounts';
    x_err_msg  := 'Error inserting into MTL Transaction Accounts: CSTPSMUT.COST_MERGE_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_INSERTING_RESULT_LOT THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into WPB for Resulting Lot';
    x_err_msg  := 'Error inserting into WPB for Resulting Lot: CSTPSMUT.COST_MERGE_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);

 WHEN INSERT_WOO_ERROR THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into WOO';
    x_err_msg  := 'Error inserting into WOO: CSTPSMUT.COST_MERGE_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);

END COST_MERGE_TXN;


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--  COST_UPDATE_QTY_TXN                                                   --
--                                                                        --
-- DESCRIPTION                                                            --
--  This procedure costs a update lot quantity transaction.
--  It inserts entries in MTA, WT and WTA. It also updates the WPB for
--  all the involved jobs.
--                                                                        --
-- PURPOSE:                                                               --
--  OSFM Lot Transactions Costing for Oracle Applications Rel 11i.8
--                                                                        --
-- PARAMETERS:                                                            --
--  p_api_version         API version
--  p_transaction_id      Transaction ID from WSMT
--  p_mmt_transaction_id  Transaction ID form MMT
--  p_request_id          Request ID of calling worker
--  p_transaction_date    Transaction Date
--  p_prog_application_id
--  p_program_id
--  p_login_id
--  p_user_id             Concurrent WHO Parameters
--  x_err_num             Error Number
--  x_err_code            Error Code                                      --
--  x_err_msg             Error Message                                   --
-- HISTORY:                                                               --
--  August-2002         Vinit                       Creation              --
----------------------------------------------------------------------------
PROCEDURE COST_UPDATE_QTY_TXN
                         (p_api_version            IN NUMBER,
                          p_transaction_id         IN NUMBER,
                          p_mmt_transaction_id     IN NUMBER,
                          p_transaction_date       IN DATE,
                          p_prog_application_id    IN NUMBER,
                          p_program_id             IN NUMBER,
                          p_request_id             IN NUMBER,
                          p_login_id               IN NUMBER,
                          p_user_id                IN NUMBER,
                          x_err_num                IN OUT NOCOPY NUMBER,
                          x_err_code               IN OUT NOCOPY VARCHAR2,
                          x_err_msg                IN OUT NOCOPY VARCHAR2) IS

/* Parameters */
l_transaction_type        NUMBER;
l_organization_id         NUMBER;
l_transaction_date        DATE;
l_min_acct_unit           NUMBER      := 0;
l_ext_prec                NUMBER(2)   := 0;
l_wip_transaction_id      NUMBER;
l_acct_period_id          NUMBER;


/* Local Variables */
l_stmt_num                NUMBER      := 0;
l_factor                  NUMBER      := 0;
l_le_transaction_date     DATE;

/* API */
l_api_name    CONSTANT    VARCHAR2(240)  := 'COST_UPDATE_QTY_TXN';
l_api_version CONSTANT    NUMBER      := 1.0;

/* Representative Lot Information */
l_wip_entity_id           NUMBER;
l_start_quantity          NUMBER;
l_operation_seq_num       NUMBER;
l_intraoperation_step     NUMBER      := 1;
l_job_start_quantity      NUMBER;
l_available_quantity      NUMBER;

/* Intraoperation Step  Not Needed */

/* Job Charges */
l_pl_mtl_cost_in          NUMBER      := 0;
l_pl_mto_cost_in          NUMBER      := 0;
l_pl_res_cost_in          NUMBER      := 0;
l_pl_ovh_cost_in          NUMBER      := 0;
l_pl_osp_cost_in          NUMBER      := 0;
l_tl_res_cost_in          NUMBER      := 0;
l_tl_ovh_cost_in          NUMBER      := 0;
l_tl_osp_cost_in          NUMBER      := 0;


/* Relieved Costs */
l_pl_mtl_cost_out         NUMBER      := 0;
l_pl_mto_cost_out         NUMBER      := 0;
l_pl_res_cost_out         NUMBER      := 0;
l_pl_ovh_cost_out         NUMBER      := 0;
l_pl_osp_cost_out         NUMBER      := 0;
l_tl_res_cost_out         NUMBER      := 0;
l_tl_ovh_cost_out         NUMBER      := 0;
l_tl_osp_cost_out         NUMBER      := 0;


/* Net Cost and Total Costs */
l_pl_mtl_net              NUMBER      := 0;
l_pl_mto_net              NUMBER      := 0;
l_pl_res_net              NUMBER      := 0;
l_pl_ovh_net              NUMBER      := 0;
l_pl_osp_net              NUMBER      := 0;
l_tl_res_net              NUMBER      := 0;
l_tl_ovh_net              NUMBER      := 0;
l_tl_osp_net              NUMBER      := 0;


/* Exceptions */

GET_JOB_VALUE_FAILURE          EXCEPTION;
FAILED_INSERTING_START_LOT     EXCEPTION;
FAILED_BALANCING_ACCT          EXCEPTION;
FAILED_INSERTING_WT            EXCEPTION;
FAILED_INSERTING_WTA           EXCEPTION;
FAILED_INSERTING_MTA           EXCEPTION;
FAILED_INSERTING_RESULT_LOT    EXCEPTION;
FAILED_INSERTING_BONUS_WTA     EXCEPTION;
FAILED_INSERTING_BONUS_MTA     EXCEPTION;

/* Accounting Line Types */
UPD_QTY_RESULT_ACT_LTYPE       NUMBER := 28;
UPD_QTY_START_ACT_LTYPE        NUMBER := 27;

/* SLA Event Seeding */
l_wta_exists         NUMBER;
l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
l_trx_info           CST_XLA_PVT.t_xla_wip_trx_info;

BEGIN
  /* Check API Compatibility */
  l_stmt_num := 10;

  IF NOT FND_API.COMPATIBLE_API_CALL (
                               l_api_version,
                               p_api_version,
                               l_api_name,
                               G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  /* Get Transaction Information from WSMT */

  l_stmt_num := 20;
  SELECT organization_id,
         transaction_type_id,
         transaction_date
  INTO   l_organization_id,
         l_transaction_type,
         l_transaction_date
  FROM   WSM_SPLIT_MERGE_TRANSACTIONS
  WHERE transaction_id = p_transaction_id;

  /* Get Currency Information and Precision */
  l_stmt_num := 30;
  SELECT NVL(FC.minimum_accountable_unit, POWER(10,NVL(-precision,0))),
         NVL(FC.extended_precision,NVL(FC.precision,0))
  INTO l_min_acct_unit,
       l_ext_prec
  FROM fnd_currencies FC,
       CST_ORGANIZATION_DEFINITIONS O
  WHERE O.organization_id = l_organization_id
  AND   O.currency_code = FC.currency_code;

  /* Accounting Period */
  l_stmt_num := 35;

  l_le_transaction_date := INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_INV_ORG(
                           l_transaction_date,
                           l_organization_id);

  l_stmt_num := 40;

  SELECT acct_period_id
  INTO   l_acct_period_id
  FROM   org_acct_periods
  WHERE  organization_id = l_organization_id
  AND    l_le_transaction_date
         between period_start_date and schedule_close_date;


  /* Get Information from WSSJ */

  l_stmt_num := 50;

  SELECT wip_entity_id,
         operation_seq_num,
         intraoperation_step,
         available_quantity,
         job_start_quantity
  INTO   l_wip_entity_id,
         l_operation_seq_num,
         l_intraoperation_step,
         l_available_quantity,
         l_job_start_quantity
  FROM   WSM_SM_STARTING_JOBS
  WHERE transaction_id = p_transaction_id;

  /* Get Information from WSRJ */

  l_stmt_num := 60;

  SELECT start_quantity
  INTO   l_start_quantity
  FROM   WSM_SM_RESULTING_JOBS
  WHERE  transaction_id  = p_transaction_id;


  /* Get the Job Charges */

  l_stmt_num := 70;

  CSTPSMUT.GET_JOB_VALUE ( p_api_version       => 1.0,
                           p_lot_size          => l_start_quantity,
                           p_run_mode          => 1,           -- CHARGE
                           p_entity_id         => l_wip_entity_id,
                           p_intraop_step      => l_intraoperation_step,
                           p_operation_seq_num => l_operation_seq_num,
                           p_transaction_id    => p_transaction_id,
                           p_txn_type          => WSMPCNST.UPDATE_QUANTITY,
                           p_org_id            => l_organization_id,
                           x_err_num           => x_err_num,
                           x_err_code          => x_err_code,
                           x_err_msg           => x_err_msg,
                           x_pl_mtl_cost       => l_pl_mtl_cost_in,
                           x_pl_mto_cost       => l_pl_mto_cost_in,
                           x_pl_res_cost       => l_pl_res_cost_in,
                           x_pl_ovh_cost       => l_pl_ovh_cost_in,
                           x_pl_osp_cost       => l_pl_osp_cost_in,
                           x_tl_res_cost       => l_tl_res_cost_in,
                           x_tl_ovh_cost       => l_tl_ovh_cost_in,
                           x_tl_osp_cost       => l_tl_osp_cost_in );


  IF x_err_num <> 0 THEN
    RAISE GET_JOB_VALUE_FAILURE;
  END IF;

  /* Job Relief */

  l_stmt_num := 75;

  CSTPSMUT.GET_JOB_VALUE ( p_api_version       => 1.0,
                           p_lot_size          => l_start_quantity,
                           p_run_mode          => 2,           -- SCRAP
                           p_entity_id         => l_wip_entity_id,
                           p_intraop_step      => l_intraoperation_step,
                           p_operation_seq_num => l_operation_seq_num,
                           p_transaction_id    => p_transaction_id,
                           p_txn_type          => WSMPCNST.UPDATE_QUANTITY,
                           p_org_id            => l_organization_id,
                           x_err_num           => x_err_num,
                           x_err_code          => x_err_code,
                           x_err_msg           => x_err_msg,
                           x_pl_mtl_cost       => l_pl_mtl_cost_out,
                           x_pl_mto_cost       => l_pl_mto_cost_out,
                           x_pl_res_cost       => l_pl_res_cost_out,
                           x_pl_ovh_cost       => l_pl_ovh_cost_out,
                           x_pl_osp_cost       => l_pl_osp_cost_out,
                           x_tl_res_cost       => l_tl_res_cost_out,
                           x_tl_ovh_cost       => l_tl_ovh_cost_out,
                           x_tl_osp_cost       => l_tl_osp_cost_out );

  IF x_err_num <> 0 THEN
    RAISE GET_JOB_VALUE_FAILURE;
  END IF;

  l_pl_mtl_net := l_pl_mtl_cost_in - l_pl_mtl_cost_out;
  l_pl_mto_net := l_pl_mto_cost_in - l_pl_mto_cost_out;
  l_pl_res_net := l_pl_res_cost_in - l_pl_res_cost_out;
  l_pl_ovh_net := l_pl_ovh_cost_in - l_pl_ovh_cost_out;
  l_pl_osp_net := l_pl_osp_cost_in - l_pl_osp_cost_out;


  l_tl_res_net := l_tl_res_cost_in - l_tl_res_cost_out;
  l_tl_ovh_net := l_tl_ovh_cost_in - l_tl_ovh_cost_out;
  l_tl_osp_net := l_tl_osp_cost_in - l_tl_osp_cost_out;


  l_stmt_num := 80;

  l_factor := (l_start_quantity - l_available_quantity)/l_available_quantity;

  CSTPSMUT.INSERT_MAT_TXN_ACCT(
		   l_transaction_date,
		   l_min_acct_unit,
		   l_ext_prec,
		   l_transaction_type,
		   p_mmt_transaction_id,
		   l_organization_id,
		   l_wip_entity_id,
		   UPD_QTY_RESULT_ACT_LTYPE,   -- Accounting Line Type
                   (l_start_quantity - l_available_quantity),
		   l_pl_mtl_net * l_factor,
		   l_pl_mto_net * l_factor,
		   l_pl_res_net * l_factor,
		   l_pl_ovh_net * l_factor,
		   l_pl_osp_net * l_factor,
                   p_user_id,
                   p_login_id,
                   p_request_id,
                   p_prog_application_id,
                   p_program_id,
                   l_debug_flag,
                   x_err_num,
                   x_err_code,
                   x_err_msg);

  IF x_err_num <> 0 then
    RAISE FAILED_INSERTING_MTA;
  END IF;

  l_stmt_num := 90;

  get_wip_txn_id(l_wip_transaction_id,
                 x_err_num,
                 x_err_code,
                 x_err_msg);

  /* Insert into MTA */

  l_stmt_num := 100;

  CSTPSMUT.INSERT_WIP_TXN_ACCT(
		   l_transaction_date,
		   l_min_acct_unit,
		   l_ext_prec,
                   p_transaction_id,
		   l_transaction_type,
		   l_wip_transaction_id,
		   l_organization_id,
		   l_wip_entity_id,
                   UPD_QTY_RESULT_ACT_LTYPE,  -- Accounting Line Type
                   (l_start_quantity - l_available_quantity),
		   0, -- This Level Material Cost
		   0, -- This Level Material Ovhd Cost
		   l_factor * l_tl_res_net,
		   l_factor * l_tl_ovh_net,
		   l_factor * l_tl_osp_net,
                   p_user_id,
                   p_login_id,
                   p_request_id,
                   p_prog_application_id,
                   p_program_id,
                   l_debug_flag,
                   x_err_num,
                   x_err_code,
                   x_err_msg);

  IF x_err_num <> 0 then
     RAISE FAILED_INSERTING_WTA;
  END IF;


  /* Insert Transaction into WT */

  l_stmt_num := 110;

  CSTPSMUT.INSERT_WIP_TXN(
		        l_transaction_date,
                        p_transaction_id,
                        l_wip_transaction_id,
                        l_acct_period_id,
                        l_wip_entity_id,
                        l_operation_seq_num,
                        14,      -- WIP Transaction type
                        p_user_id,
                        p_login_id,
                        p_request_id,
                        p_prog_application_id,
                        p_program_id,
                        l_debug_flag,
                        x_err_num,
                        x_err_code,
                        x_err_msg,
                        p_mmt_transaction_id); -- Added for Bug#4307365

    IF x_err_num <> 0 then
      RAISE FAILED_INSERTING_WT;
    END IF;

    /* Insert credit into Bonus Account */

    l_stmt_num := 120;

    CSTPSMUT.BONUS_MAT_TXN_ACCT(
		        l_transaction_date,
                        l_ext_prec,
			l_min_acct_unit,
			l_transaction_type,
                        p_transaction_id,
                        p_mmt_transaction_id,
                        l_organization_id,
                        l_wip_entity_id,
                        UPD_QTY_START_ACT_LTYPE,
                        -(ROUND( l_factor * l_pl_mtl_net /
				l_min_acct_unit) * l_min_acct_unit +
			  ROUND( l_factor * l_pl_mto_net /
                                l_min_acct_unit) * l_min_acct_unit +
			  ROUND( l_factor * l_pl_res_net /
                                l_min_acct_unit) * l_min_acct_unit +
			  ROUND( l_factor * l_pl_osp_net /
                                l_min_acct_unit) * l_min_acct_unit +
			  ROUND( l_factor * l_pl_ovh_net /
                                l_min_acct_unit) * l_min_acct_unit),
                        p_user_id,
                        p_login_id,
                        p_request_id,
                        p_prog_application_id,
                        p_program_id,
                        l_debug_flag,
                        x_err_num,
                        x_err_code,
                        x_err_msg);

 /* Insert credit into Bonus Account */

    l_stmt_num := 130;

    CSTPSMUT.BONUS_WIP_TXN_ACCT(
		        l_transaction_date,
                        l_ext_prec,
			l_min_acct_unit,
                        p_transaction_id,
			l_transaction_type,
                        l_wip_transaction_id,
                        l_organization_id,
                        l_wip_entity_id,
                        UPD_QTY_START_ACT_LTYPE,
                        -(ROUND( l_factor * l_tl_res_net /
                                l_min_acct_unit) * l_min_acct_unit +
			  ROUND( l_factor * l_tl_osp_net /
                                l_min_acct_unit) * l_min_acct_unit +
			  ROUND( l_factor * l_tl_ovh_net /
                                l_min_acct_unit) * l_min_acct_unit),
                        p_user_id,
                        p_login_id,
                        p_request_id,
                        p_prog_application_id,
                        p_program_id,
                        l_debug_flag,
                        x_err_num,
                        x_err_code,
                        x_err_msg);

    /* Make sure the Debit/Credit for Representative Lot and Resulting Lots
       are balanced */

    l_stmt_num := 140;
    CSTPSMUT.BALANCE_ACCOUNTING(p_mmt_transaction_id,
                                l_wip_transaction_id,
                                l_transaction_type,
                                x_err_msg,
                                x_err_code,
                                x_err_num);
    IF x_err_num <> 0 then
      RAISE FAILED_BALANCING_ACCT;
    END IF;

    /* Update WPB of Representative Lot */

    l_stmt_num := 150;
    CSTPSMUT.RESULT_LOT(
                        p_mmt_transaction_id,
                        l_wip_transaction_id,
                        l_wip_entity_id,
                        l_acct_period_id,
                        p_user_id,
                        p_login_id,
                        p_request_id,
                        p_prog_application_id,
                        p_program_id,
                        l_debug_flag,
                        x_err_num,
                        x_err_code,
                        x_err_msg);
    IF x_err_num <> 0 then
      RAISE FAILED_INSERTING_START_LOT;
    END IF;

  l_stmt_num := 155;

  SELECT count(*)
  INTO   l_wta_exists
  FROM   WIP_TRANSACTION_ACCOUNTS
  WHERE  transaction_id = l_wip_transaction_id
  and    rownum=1;



  IF l_wta_exists > 0 THEN
    /* SLA Event Seeding */
    l_trx_info.TRANSACTION_ID := l_wip_transaction_id;
    l_trx_info.INV_ORGANIZATION_ID := l_organization_id;
    l_trx_info.WIP_RESOURCE_ID     := -1;
    l_trx_info.WIP_BASIS_TYPE_ID   := -1;
    l_trx_info.TXN_TYPE_ID    := 14;
    l_trx_info.TRANSACTION_DATE := l_transaction_date;

    l_stmt_num := 160;

    CST_XLA_PVT.Create_WIPXLAEvent(
      p_api_version      => 1.0,
      p_init_msg_list    => FND_API.G_FALSE,
      p_commit           => FND_API.G_FALSE,
      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data,
      p_trx_info         => l_trx_info);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

  END IF;
EXCEPTION

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_err_num  := -1;
    x_err_code := 'Inconsistent API Version';--FND_API.G_RET_SYS_ERROR;
    x_err_msg  := 'Inconsistent API Version: CSTPSMUT.COST_UPDATE_QTY_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
    FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
 WHEN GET_JOB_VALUE_FAILURE THEN
    x_err_num  := -1;
    x_err_code := 'Error getting Job Charges/Scrap';
    x_err_msg  := 'Error getting Job Charges/Scrap: CSTPSMUT.COST_UPDATE_QTY_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
    FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
 WHEN FAILED_INSERTING_START_LOT THEN
    x_err_num  := -1;
    x_err_code := 'Error Inserting WPB Information for Starting Lot';
    x_err_msg  := 'Error Inserting WPB Information for Starting Lot: CSTPSMUT.COST_UPDATE_QTY_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_BALANCING_ACCT THEN
    x_err_num  := -1;
    x_err_code := 'Error Balancing Accounts';
    x_err_msg  := 'Error Balancing Accounts: CSTPSMUT.COST_UPDATE_QTY_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_INSERTING_WT THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into Wip Transactions';
    x_err_msg  := 'Error inserting into Wip Transactions: CSTPSMUT.COST_UPDATE_QTY_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_INSERTING_WTA THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into Wip Transaction Accounts';
    x_err_msg  := 'Error inserting into Wip Transaction Accounts: CSTPSMUT.COST_UPDATE_QTY_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_INSERTING_MTA THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into MTL Transaction Accounts';
    x_err_msg  := 'Error inserting into MTL Transaction Accounts: CSTPSMUT.COST_UPDATE_QTY_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_INSERTING_BONUS_MTA THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into MTL Bonus Accounts';
    x_err_msg  := 'Error inserting into MTL Bonus Accounts: CSTPSMUT.COST_UPDATE_QTY_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_INSERTING_BONUS_WTA THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into WIP Bonus Accounts';
    x_err_msg  := 'Error inserting into WIP Bonus Accounts: CSTPSMUT.COST_UPDATE_QTY_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);

 WHEN FAILED_INSERTING_RESULT_LOT THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into WPB for Resulting Lot';
    x_err_msg  := 'Error inserting into WPB for Resulting Lot: CSTPSMUT.COST_UPDATE_QTY_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);

END COST_UPDATE_QTY_TXN;



----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--  COST_BONUS_TXN                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--  This procedure costs a lot bonus transaction. It inserts entries in
--  MTA, WT and WTA. It also updates the WPB for all the involved jobs.
--                                                                        --
-- PURPOSE:                                                               --
--  OSFM Lot Transactions Costing for Oracle Applications Rel 11i.8
--                                                                        --
-- PARAMETERS:                                                            --
--  p_api_version         API version
--  p_transaction_id      Transaction ID from WSMT
--  p_mmt_transaction_id  Transaction ID form MMT
--  p_request_id          Request ID of calling worker
--  p_transaction_date    Transaction Date
--  p_prog_application_id
--  p_program_id
--  p_login_id
--  p_user_id             Concurrent WHO Parameters
--  x_err_num             Error Number
--  x_err_code            Error Code                                      --
--  x_err_msg             Error Message                                   --
-- HISTORY:                                                               --
--  August-2002         Vinit                       Creation              --
----------------------------------------------------------------------------
PROCEDURE COST_BONUS_TXN (p_api_version            IN NUMBER,
                          p_transaction_id         IN NUMBER,
                          p_mmt_transaction_id     IN NUMBER,
                          p_transaction_date       IN DATE,
                          p_prog_application_id    IN NUMBER,
                          p_program_id             IN NUMBER,
                          p_request_id             IN NUMBER,
                          p_login_id               IN NUMBER,
                          p_user_id                IN NUMBER,
                          x_err_num                IN OUT NOCOPY NUMBER,
                          x_err_code               IN OUT NOCOPY VARCHAR2,
                          x_err_msg                IN OUT NOCOPY VARCHAR2) IS

/* Parameters */
l_transaction_type        NUMBER;
l_organization_id         NUMBER;
l_transaction_date        DATE;
l_min_acct_unit           NUMBER      := 0;
l_ext_prec                NUMBER(2)   := 0;
l_wip_transaction_id      NUMBER;
l_acct_period_id          NUMBER;

/* Local Variables */
l_stmt_num                NUMBER      := 0;
ins_woo                   BOOLEAN     := TRUE;
l_le_transaction_date     DATE;

/* API */
l_api_name    CONSTANT    VARCHAR2(240)  := 'COST_BONUS_TXN';
l_api_version CONSTANT    NUMBER      := 1.0;

/* Representative Lot Information */
l_wip_entity_id              NUMBER;
l_start_quantity             NUMBER;
l_operation_seq_num          NUMBER;
l_intraoperation_step        NUMBER      := 1;
l_min_op_seq_num             NUMBER;


/* Intraoperation Step  Not Needed */

/* Job Charges */
l_pl_mtl_cost_in          NUMBER      := 0;
l_pl_mto_cost_in          NUMBER      := 0;
l_pl_res_cost_in          NUMBER      := 0;
l_pl_ovh_cost_in          NUMBER      := 0;
l_pl_osp_cost_in          NUMBER      := 0;
l_tl_res_cost_in          NUMBER      := 0;
l_tl_ovh_cost_in          NUMBER      := 0;
l_tl_osp_cost_in          NUMBER      := 0;


/* Exceptions */

GET_JOB_VALUE_FAILURE          EXCEPTION;
FAILED_INSERTING_START_LOT     EXCEPTION;
FAILED_BALANCING_ACCT          EXCEPTION;
FAILED_INSERTING_WT            EXCEPTION;
FAILED_INSERTING_WTA           EXCEPTION;
FAILED_INSERTING_MTA           EXCEPTION;
FAILED_INSERTING_RESULT_LOT    EXCEPTION;
FAILED_INSERTING_BONUS_WTA     EXCEPTION;
FAILED_INSERTING_BONUS_MTA     EXCEPTION;
INSERT_WOO_ERROR               EXCEPTION;

/* Accounting Line Types */
BONUS_RESULT_ACT_LTYPE         NUMBER := 26;
BONUS_START_ACT_LTYPE          NUMBER := 25;

/* SLA Event Seeding */
l_wta_exists         NUMBER;
l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
l_trx_info           CST_XLA_PVT.t_xla_wip_trx_info;

BEGIN
  /* Check API Compatibility */
  l_stmt_num := 10;
  IF (l_debug_flag = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'CSTPSMUT.COST_BONUS_TXN <<<');
  END IF;

  IF NOT FND_API.COMPATIBLE_API_CALL (
                               l_api_version,
                               p_api_version,
                               l_api_name,
                               G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  /* Get Transaction Information from WSMT */

  l_stmt_num := 20;
  SELECT organization_id,
         transaction_type_id,
         transaction_date
  INTO   l_organization_id,
         l_transaction_type,
         l_transaction_date
  FROM   WSM_SPLIT_MERGE_TRANSACTIONS
  WHERE transaction_id = p_transaction_id;



  /* Get Currency Information and Precision */
  l_stmt_num := 30;
  SELECT NVL(FC.minimum_accountable_unit, POWER(10,NVL(-precision,0))),
         NVL(FC.extended_precision,NVL(FC.precision,0))
  INTO l_min_acct_unit,
       l_ext_prec
  FROM fnd_currencies FC,
       CST_ORGANIZATION_DEFINITIONS O
  WHERE O.organization_id = l_organization_id
  AND   O.currency_code = FC.currency_code;

  /* Accounting Period */
  l_stmt_num := 35;

  l_le_transaction_date := INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_INV_ORG(
                           l_transaction_date,
                           l_organization_id);

  l_stmt_num := 40;

  SELECT acct_period_id
  INTO   l_acct_period_id
  FROM   org_acct_periods
  WHERE  organization_id = l_organization_id
  AND    l_le_transaction_date
         between period_start_date and schedule_close_date;


  /* Get Information from WSRJ */
  /* Note that the starting_operation_seq_num in WSRJ
     is NOT the operation_seq_num where the Bonus
     transaction took place */


  l_stmt_num := 50;

  SELECT wip_entity_id,
         job_operation_seq_num,
         nvl(starting_intraoperation_step, WIP_CONSTANTS.QUEUE),
         start_quantity
  INTO   l_wip_entity_id,
         l_operation_seq_num,
         l_intraoperation_step,
         l_start_quantity
  FROM   WSM_SM_RESULTING_JOBS
  WHERE  transaction_id  = p_transaction_id;

  /* Scenario applicable for jobs that are upgraded
     from 11i.8 and below. JOB_OPERATION_SEQ_NUM is not
     stamped. Hence, we use BOM_OPERATION_SEQUENCES and
     starting_operation_seq_num on the transaction in WSRJ to get
     this information */

  IF  l_operation_seq_num IS NULL  THEN
    l_stmt_num := 52;
    SELECT wo.operation_seq_num
    INTO   l_operation_seq_num
    FROM   WIP_OPERATIONS WO,
           WSM_SM_RESULTING_JOBS WSRJ,
           BOM_OPERATION_SEQUENCES BOS
    WHERE  WSRJ.transaction_id                       = p_transaction_id
    AND    nvl(wsrj.starting_intraoperation_step, 1) = 1
    AND    wsrj.common_routing_sequence_id           = bos.routing_sequence_id
    AND    wsrj.starting_operation_seq_num           = bos.operation_seq_num
    AND    bos.operation_sequence_id                 = wo.operation_sequence_id
    AND    bos.EFFECTIVITY_DATE                      <= p_transaction_date
    AND    NVL( bos.DISABLE_DATE, p_transaction_date + 1) > p_transaction_date
    AND    wo.wip_entity_id                          = wsrj.wip_entity_id
    AND    wo.organization_id                        = l_organization_id;
  END IF;

  IF ( l_debug_flag = 'Y' ) THEN
    fnd_file.put_line(fnd_file.log, 'WIP ENTITY       : '||to_char(l_wip_entity_id));
    fnd_file.put_line(fnd_file.log, 'OPERATION_SEQ_NUM: '||to_char(l_operation_seq_num));
  END IF;

  /* Return success if Bonus occurs at the Queue Intraoperation step
     of the first operation of the job.
     Calling routine sets the status to costed. */

  l_stmt_num := 55;

  SELECT min(operation_seq_num)
  INTO   l_min_op_seq_num
  FROM   wip_operations
  WHERE  wip_entity_id   = l_wip_entity_id
  AND    organization_id = l_organization_id;


  IF (l_operation_seq_num = l_min_op_seq_num
      AND l_intraoperation_step = 1) THEN
     RETURN;
  END IF;

  /* Get the Job Charges */

  l_stmt_num := 60;

  CSTPSMUT.GET_JOB_VALUE ( p_api_version       => 1.0,
                           p_lot_size          => l_start_quantity,
                           p_run_mode          => 1,           -- CHARGE
                           p_entity_id         => l_wip_entity_id,
                           p_intraop_step      => l_intraoperation_step,
                           p_operation_seq_num => l_operation_seq_num,
                           p_transaction_id    => p_transaction_id,
                           p_txn_type          => WSMPCNST.BONUS,
                           p_org_id            => l_organization_id,
                           x_err_num           => x_err_num,
                           x_err_code          => x_err_code,
                           x_err_msg           => x_err_msg,
                           x_pl_mtl_cost       => l_pl_mtl_cost_in,
                           x_pl_mto_cost       => l_pl_mto_cost_in,
                           x_pl_res_cost       => l_pl_res_cost_in,
                           x_pl_ovh_cost       => l_pl_ovh_cost_in,
                           x_pl_osp_cost       => l_pl_osp_cost_in,
                           x_tl_res_cost       => l_tl_res_cost_in,
                           x_tl_ovh_cost       => l_tl_ovh_cost_in,
                           x_tl_osp_cost       => l_tl_osp_cost_in );


  IF x_err_num <> 0 THEN
    RAISE GET_JOB_VALUE_FAILURE;
  END IF;

  l_stmt_num := 70;

  CSTPSMUT.INSERT_MAT_TXN_ACCT(
		   l_transaction_date,
		   l_min_acct_unit,
		   l_ext_prec,
		   l_transaction_type,
		   p_mmt_transaction_id,
		   l_organization_id,
		   l_wip_entity_id,
		   BONUS_RESULT_ACT_LTYPE,   -- Accounting Line Type for Bonus
                   l_start_quantity,
		   l_pl_mtl_cost_in * l_start_quantity,
		   l_pl_mto_cost_in * l_start_quantity,
		   l_pl_res_cost_in * l_start_quantity,
		   l_pl_ovh_cost_in * l_start_quantity,
		   l_pl_osp_cost_in * l_start_quantity,
                   p_user_id,
                   p_login_id,
                   p_request_id,
                   p_prog_application_id,
                   p_program_id,
                   l_debug_flag,
                   x_err_num,
                   x_err_code,
                   x_err_msg);

  IF x_err_num <> 0 then
    RAISE FAILED_INSERTING_MTA;
  END IF;

  l_stmt_num := 80;

  get_wip_txn_id(l_wip_transaction_id,
                 x_err_num,
                 x_err_code,
                 x_err_msg);

  -- dbms_output.put_line('Wip Transaction ID: '||to_char(l_wip_transaction_id));

  /* Insert into MTA */

  l_stmt_num := 90;

  CSTPSMUT.INSERT_WIP_TXN_ACCT(
		   l_transaction_date,
		   l_min_acct_unit,
		   l_ext_prec,
                   p_transaction_id,
		   l_transaction_type,
		   l_wip_transaction_id,
		   l_organization_id,
		   l_wip_entity_id,
                   BONUS_RESULT_ACT_LTYPE,  -- Accounting Line Type for Bonus
                   l_start_quantity,
		   0, -- This Level Material Cost
		   0, -- This Level Material Ovhd Cost
		   (l_start_quantity * l_tl_res_cost_in),
		   (l_start_quantity * l_tl_ovh_cost_in),
		   (l_start_quantity * l_tl_osp_cost_in),
                   p_user_id,
                   p_login_id,
                   p_request_id,
                   p_prog_application_id,
                   p_program_id,
                   l_debug_flag,
                   x_err_num,
                   x_err_code,
                   x_err_msg);

  IF x_err_num <> 0 then
    RAISE FAILED_INSERTING_WTA;
  END IF;


  /* Insert Transaction into WT */

  l_stmt_num := 100;
  CSTPSMUT.INSERT_WIP_TXN(
		        l_transaction_date,
                        p_transaction_id,
                        l_wip_transaction_id,
                        l_acct_period_id,
                        l_wip_entity_id,
                        l_operation_seq_num,
                        13,      -- WIP Transaction type
                        p_user_id,
                        p_login_id,
                        p_request_id,
                        p_prog_application_id,
                        p_program_id,
                        l_debug_flag,
                        x_err_num,
                        x_err_code,
                        x_err_msg,
                        p_mmt_transaction_id); -- Added for Bug#4307365

  IF x_err_num <> 0 then
    RAISE FAILED_INSERTING_WT;
  END IF;

  /* Insert Credit Information */

  l_stmt_num := 110;

  CSTPSMUT.BONUS_MAT_TXN_ACCT(
		        l_transaction_date,
		        l_ext_prec,
			l_min_acct_unit,
			l_transaction_type,
			p_transaction_id,
			p_mmt_transaction_id,
			l_organization_id,
			l_wip_entity_id,
			BONUS_START_ACT_LTYPE,
			-((ROUND(l_pl_mtl_cost_in * l_start_quantity /
				 l_min_acct_unit) * l_min_acct_unit) +
			  (ROUND(l_pl_mto_cost_in * l_start_quantity /
				 l_min_acct_unit) * l_min_acct_unit) +
			  (ROUND(l_pl_res_cost_in * l_start_quantity /
				 l_min_acct_unit) * l_min_acct_unit) +
			  (ROUND(l_pl_osp_cost_in * l_start_quantity /
				 l_min_acct_unit) * l_min_acct_unit) +
			  (ROUND(l_pl_ovh_cost_in * l_start_quantity /
				 l_min_acct_unit) * l_min_acct_unit)),
                        p_user_id,
                        p_login_id,
                        p_request_id,
                        p_prog_application_id,
                        p_program_id,
                        l_debug_flag,
                        x_err_num,
                        x_err_code,
                        x_err_msg);
  IF x_err_num <> 0 then
    RAISE FAILED_INSERTING_BONUS_MTA;
  END IF;


  l_stmt_num := 120;

  CSTPSMUT.BONUS_WIP_TXN_ACCT(
		        l_transaction_date,
		        l_ext_prec,
			l_min_acct_unit,
			p_transaction_id,
			l_transaction_type,
			l_wip_transaction_id,
			l_organization_id,
			l_wip_entity_id,
			BONUS_START_ACT_LTYPE,
			-((ROUND(l_tl_res_cost_in * l_start_quantity /
				 l_min_acct_unit) * l_min_acct_unit) +
			  (ROUND(l_tl_osp_cost_in * l_start_quantity /
				 l_min_acct_unit) * l_min_acct_unit) +
			  (ROUND(l_tl_ovh_cost_in * l_start_quantity /
				 l_min_acct_unit) * l_min_acct_unit)),
                        p_user_id,
                        p_login_id,
                        p_request_id,
                        p_prog_application_id,
                        p_program_id,
                        l_debug_flag,
                        x_err_num,
                        x_err_code,
                        x_err_msg);
  IF x_err_num <> 0 then
    RAISE FAILED_INSERTING_BONUS_WTA;
  END IF;

  /* Make sure the Debit/Credit for Representative Lot and Resulting Lots
     are balanced */

  l_stmt_num := 130;
  CSTPSMUT.BALANCE_ACCOUNTING(p_mmt_transaction_id,
                              l_wip_transaction_id,
                              l_transaction_type,
                              x_err_msg,
                              x_err_code,
                              x_err_num);
  IF x_err_num <> 0 then
    RAISE FAILED_BALANCING_ACCT;
  END IF;

  /* Update WPB of Representative Lot */

  l_stmt_num := 140;
  CSTPSMUT.RESULT_LOT(
                        p_mmt_transaction_id,
                        l_wip_transaction_id,
                        l_wip_entity_id,
                        l_acct_period_id,
                        p_user_id,
                        p_login_id,
                        p_request_id,
                        p_prog_application_id,
                        p_program_id,
                        l_debug_flag,
                        x_err_num,
                        x_err_code,
                        x_err_msg);
  IF x_err_num <> 0 then
    RAISE FAILED_INSERTING_START_LOT;
  END IF;

  l_stmt_num := 150;

  ins_woo := INSERT_WOO (
                 l_wip_entity_id,
                 l_organization_id,
                 l_operation_seq_num,
                 p_user_id,
                 p_login_id,
                 p_request_id,
                 p_prog_application_id,
                 p_program_id );
  IF ins_woo = FALSE THEN
    RAISE INSERT_WOO_ERROR;
  END IF;

  l_stmt_num := 155;

  SELECT count(*)
  INTO   l_wta_exists
  FROM   WIP_TRANSACTION_ACCOUNTS
  WHERE  transaction_id = l_wip_transaction_id
  and    rownum=1;

  IF l_wta_exists > 0 THEN

    /* SLA Event Seeding */
    l_trx_info.TRANSACTION_ID := l_wip_transaction_id;
    l_trx_info.INV_ORGANIZATION_ID := l_organization_id;
    l_trx_info.WIP_RESOURCE_ID     := -1;
    l_trx_info.WIP_BASIS_TYPE_ID   := -1;
    l_trx_info.TXN_TYPE_ID    := 13;
    l_trx_info.TRANSACTION_DATE := l_transaction_date;

    l_stmt_num := 160;

    CST_XLA_PVT.Create_WIPXLAEvent(
      p_api_version      => 1.0,
      p_init_msg_list    => FND_API.G_FALSE,
      p_commit           => FND_API.G_FALSE,
      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data,
      p_trx_info         => l_trx_info);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;
  END IF;

  IF (l_debug_flag = 'Y') THEN
    fnd_file.put_line(fnd_file.log, 'CSTPSMUT.COST_BONUS_TXN >>>');
  END IF;

EXCEPTION

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_err_num  := -1;
    x_err_code := 'Inconsistent API Version';--FND_API.G_RET_SYS_ERROR;
    x_err_msg  := 'Inconsistent API Version: CSTPSMUT.COST_BONUS_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
    FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
 WHEN GET_JOB_VALUE_FAILURE THEN
    x_err_num  := -1;
    x_err_code := 'Error getting Job Charges/Scrap';
    x_err_msg  := 'Error getting Job Charges/Scrap: CSTPSMUT.COST_BONUS_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
    FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
 WHEN FAILED_INSERTING_START_LOT THEN
    x_err_num  := -1;
    x_err_code := 'Error Inserting WPB Information for Starting Lot';
    x_err_msg  := 'Error Inserting WPB Information for Starting Lot: CSTPSMUT.COST_BONUS_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_BALANCING_ACCT THEN
    x_err_num  := -1;
    x_err_code := 'Error Balancing Accounts';
    x_err_msg  := 'Error Balancing Accounts: CSTPSMUT.COST_BONUS_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_INSERTING_WT THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into Wip Transactions';
    x_err_msg  := 'Error inserting into Wip Transactions: CSTPSMUT.COST_BONUS_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_INSERTING_WTA THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into Wip Transaction Accounts';
    x_err_msg  := 'Error inserting into Wip Transaction Accounts: CSTPSMUT.COST_BONUS_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_INSERTING_MTA THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into MTL Transaction Accounts';
    x_err_msg  := 'Error inserting into MTL Transaction Accounts: CSTPSMUT.COST_BONUS_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_INSERTING_BONUS_MTA THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into MTL Bonus Accounts';
    x_err_msg  := 'Error inserting into MTL Bonus Accounts: CSTPSMUT.COST_BONUS_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_INSERTING_BONUS_WTA THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into WIP Bonus Accounts';
    x_err_msg  := 'Error inserting into WIP Bonus Accounts: CSTPSMUT.COST_BONUS_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);
 WHEN FAILED_INSERTING_RESULT_LOT THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into WPB for Resulting Lot';
    x_err_msg  := 'Error inserting into WPB for Resulting Lot: CSTPSMUT.COST_BONUS_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);

 WHEN INSERT_WOO_ERROR THEN
    x_err_num  := -1;
    x_err_code := 'Error inserting into WOO';
    x_err_msg  := 'Error inserting into WOO: CSTPSMUT.COST_BONUS_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);

 WHEN OTHERS THEN
    x_err_code := 'Unexpected Error';
    x_err_msg  := 'CSTPSMUT.COST_BONUS_TXN('||to_char(l_stmt_num)||'):' || x_err_msg || substr(SQLERRM, 1, 200);

END COST_BONUS_TXN;


PROCEDURE GET_WIP_TXN_ID( x_wip_txn_id OUT NOCOPY    NUMBER,
                          x_err_num    IN OUT NOCOPY NUMBER,
                          x_err_code   IN OUT NOCOPY VARCHAR2,
                          x_err_msg    IN OUT NOCOPY VARCHAR2 ) IS
l_stmt_num number;

BEGIN
  l_stmt_num := 10;
  x_err_num := 0;

  SELECT wip_transactions_s.nextval
  INTO   x_wip_txn_id
  FROM   dual;

  EXCEPTION
    WHEN others THEN
      ROLLBACK;
      x_err_num := sqlcode;
      x_err_code := 'Failed Getting Wip Transaction ID';
      x_err_msg := 'Failed Getting Wip Transaction ID: CSTPSMUT.GET_WIP_TXN_ID: ' || to_char(l_stmt_num) || '): ' || x_err_msg ;

END GET_WIP_TXN_ID;


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--  GET_JOB_VALUE
--                                                                        --
-- DESCRIPTION                                                            --
--  This procedure returns the total charges or relief from a job
--  depending on the run_mode it is called with.
--  It should be noted that when this procedure is called while
--  costing a merge/update quantity transaction, lot based
--  resources are excluded from job values both in computing
--  amount charged and relieved from the resource. This is necessary
--  as lot based resources/overheads are not scaled. The amount
--  applied in resulting lots is independent of lot_size.

--  This procedure called with transaction_type of 1 (SPLIT)
--  and operation_seq_num as the final op_seq_num of job would
--  give the total charges/relief (WPB Values) for that job.

--  Procedure replaces GET_CHARGE_VAL and GET_SCRAP_VAL from prior
--  versions
--                                                                        --
-- PURPOSE:                                                               --
--  OSFM Lot Transactions Costing for Oracle Applications Rel 11i.8

-- PARAMETERS:                                                            --
--  p_api_version          API version
--  p_lot_size             (Only Used for Bonus Txns)
--                         Resulting Bonus Lot Size
--  p_run_mode             Charge(1)/Scrap(2)
--  p_entity_id	           Wip Entity ID of Job
--  p_intraop_step	   Intraoperation Step
--  p_operation_seq_num	   Operation Sequence Number
--  p_txn_type             Transaction Type being processed
--  p_transaction_id       Transaction ID (WSMT)
--  p_org_id		   Organization ID
--  p_err_num	           Error Number
--  p_err_code	           Error Code
--  p_err_msg	    	   Error Message
--  x_pl_mtl_cost
--  x_pl_mto_cost
--  x_pl_res_cost
--  x_pl_ovh_cost          Various Elemental Costs (Levelwise)
--  x_pl_osp_cost
--  x_tl_res_cost
--  x_tl_ovh_cost
--  x_tl_osp_cost

-- HISTORY:                                                               --
--  August-2002         Vinit                       Creation              --
----------------------------------------------------------------------------

PROCEDURE GET_JOB_VALUE
	(p_api_version          in              number,
         p_lot_size             in		number,
         p_run_mode             in              number,
	 p_entity_id	        in		number,
	 p_intraop_step		in		number,
	 p_operation_seq_num	in		number,
         p_transaction_id       in              number,
         p_txn_type             in              number,
	 p_org_id		in		number,
	 x_err_num	        IN OUT NOCOPY	number,
	 x_err_code	        IN OUT NOCOPY	varchar2,
	 x_err_msg	    	IN OUT NOCOPY	varchar2,
	 x_pl_mtl_cost		IN OUT NOCOPY	number,
	 x_pl_mto_cost		IN OUT NOCOPY	number,
	 x_pl_res_cost		IN OUT NOCOPY	number,
	 x_pl_ovh_cost		IN OUT NOCOPY	number,
	 x_pl_osp_cost		IN OUT NOCOPY	number,
	 x_tl_res_cost		IN OUT NOCOPY	number,
	 x_tl_ovh_cost		IN OUT NOCOPY	number,
	 x_tl_osp_cost		IN OUT NOCOPY	number)
IS
     l_stmt_num 	  number := 0;
     l_tl_ovh_dept_cost   number := 0;
     l_operation_seq_num  number := 0;
     l_first_op_seq_num   number := 0;
     l_prev_op_seq_num    number := 0;

     /* Transaction Information */
     l_transaction_date   DATE;
     l_include_comp_yield NUMBER;

BEGIN

   x_err_num := 0;

   x_tl_res_cost:= 0;
   x_tl_ovh_cost:= 0;
   x_tl_osp_cost:= 0;
   x_pl_mtl_cost:= 0;
   x_pl_mto_cost:= 0;
   x_pl_res_cost:= 0;
   x_pl_ovh_cost:= 0;
   x_pl_osp_cost:= 0;

   l_stmt_num := 10;

   SELECT operation_seq_num
   INTO   l_first_op_seq_num
   FROM   wip_operations
   WHERE  wip_entity_id = p_entity_id
   AND    previous_operation_seq_num is null;

   l_operation_seq_num := p_operation_seq_num;

    /* Get the value of Include Component yield flag,
    which will determine whether to include or not
    component yield factor in quantity per assembly */
    l_stmt_num := 12;
    SELECT  NVL(include_component_yield, 1)
    INTO    l_include_comp_yield
    FROM    wip_parameters
    WHERE   organization_id = p_org_id;

   /* Get the transaction_date. This will be use to
      restrict the operations processed in WO. Only operations
      less than the disable date would be processed
    */
   l_stmt_num := 15;

   SELECT transaction_date
   INTO   l_transaction_date
   FROM   WSM_SPLIT_MERGE_TRANSACTIONS
   WHERE  transaction_id = p_transaction_id;

   l_stmt_num := 18;

   /* For Bonus transactions, no manual charges at Queue are possible. Hence
      calculate charges upto previous op seq num */
   if(p_txn_type = 4) then
     SELECT MAX( OPERATION_SEQ_NUM )
       INTO l_operation_seq_num
       FROM wip_operations
      WHERE wip_entity_id = p_entity_id
        AND operation_seq_num < p_operation_seq_num
        AND organization_id = p_org_id;
   end if;

   if (l_operation_seq_num is null) then
     l_operation_seq_num := l_first_op_seq_num;
   end if;

  /* If RUN_MODE = CHARGE (1)
        IF TXN_TYPE = BONUS
           Use WOR.quantity_per_assembly*CIC.Item_Cost (by CE)
        ELSE
           Use WOR.quantity_issued*CIC.Item_Cost (by CE)
     ELSE IF RUN_MODE = SCRAP
        IF TXN_TYPE <> BONUS (Bonus has no scrap)
	   Use WOR.quantity_relieved etc.
   */

   /* OSFM Makes sure that WRO.costed_quantity_issued and WRO.costed_quantity_releived
      are initialized to zero. Remove NVL's after UT */

   l_stmt_num := 20;

	SELECT
	nvl(SUM(NVL(DECODE(p_run_mode, 1,
                      DECODE(p_txn_type, 4,           /* LBM project Changes */
                       (DECODE(NVL(WRO.basis_type,1),2, WRO.quantity_per_assembly/p_lot_size,
                                                 WRO.quantity_per_assembly)/
                            DECODE(l_include_comp_yield,
                                   1, nvl(WRO.component_yield_factor,1),
                                   1)),
                        nvl(WRO.COSTED_QUANTITY_ISSUED, 0)) ,
                          DECODE(sign(NVL(WRO.COSTED_QUANTITY_RELIEVED, 0)), 1,
                                      NVL(WRO.COSTED_QUANTITY_RELIEVED, 0), 0))
		             * CIC.MATERIAL_COST,0)),0),

	nvl(SUM(NVL(DECODE(p_run_mode, 1,
		      DECODE(p_txn_type, 4, 	 /* LBM project Changes */
		        (DECODE(NVL(WRO.basis_type,1),2, WRO.quantity_per_assembly/p_lot_size,
                                                 WRO.quantity_per_assembly)/
                            DECODE(l_include_comp_yield,
                                   1, nvl(WRO.component_yield_factor,1),
                                   1)),
		        nvl(WRO.COSTED_QUANTITY_ISSUED, 0)),
		          DECODE(sign(NVL(WRO.COSTED_QUANTITY_RELIEVED, 0)), 1,
                                      NVL(WRO.COSTED_QUANTITY_RELIEVED, 0), 0))
  		             * CIC.MATERIAL_OVERHEAD_COST,0)),0),

	nvl(SUM(NVL(DECODE(p_run_mode, 1,
		      DECODE(p_txn_type, 4, 	/* LBM project Changes */
		        (DECODE(NVL(WRO.basis_type,1),2, WRO.quantity_per_assembly/p_lot_size,
                                                 WRO.quantity_per_assembly)/
                            DECODE(l_include_comp_yield,
                                   1, nvl(WRO.component_yield_factor,1),
                                   1)),
		        nvl(WRO.COSTED_QUANTITY_ISSUED, 0)),
		          DECODE(sign(NVL(WRO.COSTED_QUANTITY_RELIEVED, 0)), 1,
                                      NVL(WRO.COSTED_QUANTITY_RELIEVED, 0), 0))
 		             * CIC.RESOURCE_COST,0)),0),

	nvl(SUM(NVL(DECODE(p_run_mode, 1,
		      DECODE(p_txn_type, 4,    /* LBM project Changes */
		        (DECODE(NVL(WRO.basis_type,1),2, WRO.quantity_per_assembly/p_lot_size,
                                                 WRO.quantity_per_assembly)/
                            DECODE(l_include_comp_yield,
                                   1, nvl(WRO.component_yield_factor,1),
                                   1)),
                        nvl(WRO.COSTED_QUANTITY_ISSUED, 0)),
		          DECODE(sign(NVL(WRO.COSTED_QUANTITY_RELIEVED, 0)), 1,
                                      NVL(WRO.COSTED_QUANTITY_RELIEVED, 0), 0))
		             * CIC.OUTSIDE_PROCESSING_COST,0)),0),

	nvl(SUM(NVL(DECODE(p_run_mode, 1,
		      DECODE(p_txn_type, 4,     /* LBM project Changes */
		        (DECODE(NVL(WRO.basis_type,1),2, WRO.quantity_per_assembly/p_lot_size,
                                                 WRO.quantity_per_assembly)/
                            DECODE(l_include_comp_yield,
                                   1, nvl(WRO.component_yield_factor,1),
                                   1)),
		        nvl(WRO.COSTED_QUANTITY_ISSUED, 0)),
		          DECODE(sign(NVL(WRO.COSTED_QUANTITY_RELIEVED, 0)), 1,
                                      NVL(WRO.COSTED_QUANTITY_RELIEVED, 0), 0))
		             * CIC.OVERHEAD_COST,0)),0)
	INTO
		x_pl_mtl_cost,
		x_pl_mto_cost,
		x_pl_res_cost,
		x_pl_osp_cost,
		x_pl_ovh_cost
	FROM
		wip_requirement_operations WRO,
		cst_item_costs CIC
	WHERE
		CIC.INVENTORY_ITEM_ID	= WRO.INVENTORY_ITEM_ID
	AND	WRO.ORGANIZATION_ID	= p_org_id
	AND	CIC.ORGANIZATION_ID	= WRO.ORGANIZATION_ID
	AND	CIC.COST_TYPE_ID	= 1
	AND	WRO.WIP_ENTITY_ID	= p_entity_id
	AND	WRO.OPERATION_SEQ_NUM 	<= l_operation_seq_num
	/* Changes for Lot Based Materials project */
	AND  (NVL(WRO.BASIS_TYPE,1) <> 2 OR (p_txn_type  IN (1,4)))
	AND     ((p_txn_type = 4) OR
	(abs(nvl(WRO.COSTED_QUANTITY_ISSUED, 0)) >= abs(nvl(WRO.COSTED_QUANTITY_RELIEVED, 0)))) /* Added abs() for bug 6774122 */
        /* LBM Changes end*/
	AND  ( WRO.WIP_SUPPLY_TYPE not in (2, 4, 5, 6) or p_txn_type <> 4 )
	AND  not exists (select 'obsolete operation'
			    from  wip_operations WO
		            where WO.wip_entity_id     = WRO.wip_entity_id
			    and   WO.organization_id   = WRO.organization_id
			    and   WO.operation_seq_num = WRO.operation_seq_num
  	                    and   WO.disable_date      <= l_transaction_date );


   /*
    Exclude Assembly Pull(2), Bulk Items(4), Phantom(6) and () for Bonus Txn
    */
   l_stmt_num := 20;
   /*
    The following select statement is to calculate this level resource charge
    and this level outside processing charge.
   */
   SELECT
	NVL(SUM(DECODE(BR.COST_ELEMENT_ID,
		3, DECODE(p_run_mode,
                    1,  DECODE(p_txn_type, 4,
                               NVL((DECODE(WOR.basis_type,
		                           1,WOR.usage_rate_or_amount,
 		                           2,WOR.usage_rate_or_amount/p_lot_size,
 		                           WOR.usage_rate_or_amount) *
		                    DECODE(BR.functional_currency_flag,
		                           1,1, nvl(CRC.resource_rate,0))),0),
                               NVL(WOR.APPLIED_RESOURCE_VALUE,0)),
                    DECODE(sign(nvl(WOR.relieved_res_value, 0)), 1, nvl(WOR.relieved_res_value, 0), 0)),
                0)),0),
	NVL(SUM(DECODE(BR.COST_ELEMENT_ID,
		4, DECODE(p_run_mode,
                    1,  DECODE(p_txn_type, 4,
                               NVL((DECODE(WOR.basis_type,
		                           1,WOR.usage_rate_or_amount,
 		                           2,WOR.usage_rate_or_amount/p_lot_size,
 		                           WOR.usage_rate_or_amount) *
		                    DECODE(BR.functional_currency_flag,
		                           1,1,nvl(CRC.resource_rate,0))),0),
                               NVL(WOR.APPLIED_RESOURCE_VALUE,0)),
                    DECODE(sign(nvl(WOR.relieved_res_value, 0)), 1, nvl(WOR.relieved_res_value, 0), 0)),
		0)),0)
   INTO
	x_tl_res_cost,
	x_tl_osp_cost
   FROM cst_resource_costs CRC,
	wip_operation_resources WOR,
	bom_resources BR
   WHERE
	CRC.COST_TYPE_ID(+)	= 1
   AND	CRC.RESOURCE_ID(+)	= WOR.RESOURCE_ID
   AND 	WOR.OPERATION_SEQ_NUM	<= l_operation_seq_num
   AND	BR.RESOURCE_ID		= WOR.RESOURCE_ID
   AND	WOR.WIP_ENTITY_ID	= p_entity_id
   AND	WOR.ORGANIZATION_ID	= p_org_id
   AND  (WOR.basis_type <> 2 or p_txn_type in (1, 4))
   AND  ((p_txn_type = 4) OR
         nvl(WOR.applied_resource_value, 0) >= nvl(WOR.relieved_res_value, 0))
   AND  not exists (select 'obsolete operation'
		    from  wip_operations WO
	            where WO.wip_entity_id     = WOR.wip_entity_id
		    and   WO.organization_id   = WOR.organization_id
		    and   WO.operation_seq_num = WOR.operation_seq_num
                    and   WO.disable_date      <= l_transaction_date );

   l_stmt_num := 30;
/*
IF run_mode = CHARGE
  IF txn_type = BONUS
    Overhead = CDO.rate_or_amount * WOR.usage_rate_or_amount * CRC.resource_rate
  ELSE
    Overhead = CDO.rate_or_amount * WOR.costed_applied_resource_units * CRC.resource_rate
ELSE -- run_mode = SCRAP (never called for BONUS)
    Overhead = CDO.rate_or_amount * WOR.RELIEVED_RES_VALUE
*/

  IF (p_txn_type = 4) THEN
    SELECT NVL(SUM(NVL(CDO.rate_or_amount *
                   DECODE(WOR.basis_type,
                               1,WOR.usage_rate_or_amount,
                               2,WOR.usage_rate_or_amount/p_lot_size,
                               WOR.usage_rate_or_amount) *
                   DECODE(CDO.basis_type, 3, 1,
                               DECODE(BR.functional_currency_flag,
                                      1,1,nvl(CRC.resource_rate,0))), 0)), 0)

    INTO
        x_tl_ovh_cost
    FROM
        wip_operations WO,
        wip_operation_resources WOR,
        cst_resource_overheads CRO,
        cst_department_overheads CDO,
        bom_resources BR,
        cst_resource_costs CRC
    WHERE
        WO.wip_entity_id = p_entity_id
    AND WOR.resource_id = BR.resource_id
    AND CRC.resource_id(+) = BR.resource_id
    AND WO.operation_seq_num = WOR.operation_seq_num
    AND NVL(WO.DISABLE_DATE, l_transaction_date) <= l_transaction_date
    AND WOR.organization_id = p_org_id
    AND WOR.wip_entity_id = p_entity_id
    AND WOR.operation_seq_num <= l_operation_seq_num
    AND WOR.organization_id = p_org_id
    AND CDO.department_id = WO.department_id
    AND CDO.basis_type in (3, 4)
    AND CDO.overhead_id = CRO.overhead_id
    AND CRO.resource_id = WOR.resource_id
    AND CRC.cost_type_id(+) = 1
    AND CRO.cost_type_id = 1
    AND CDO.cost_type_id = 1;

    /* Department based overheads for Bonus */

    SELECT NVL(SUM(NVL(DECODE(CDO.basis_type,
                      1,CDO.rate_or_amount,
                      2,CDO.rate_or_amount/p_lot_size),0)), 0)
    INTO l_tl_ovh_dept_cost
    FROM wip_operations                  WO,
         cst_department_overheads        CDO
    WHERE
         WO.wip_entity_id     = p_entity_id
    AND  WO.operation_seq_num <= l_operation_seq_num
    AND  WO.organization_id   = p_org_id
    AND  nvl(WO.DISABLE_DATE, l_transaction_date) <= l_transaction_date
    AND  CDO.department_id    = WO.department_id
    AND  CDO.organization_id  = WO.organization_id
    AND  CDO.basis_type       in (1,2)
    AND  CDO.cost_type_id     = 1;

    x_tl_ovh_cost := x_tl_ovh_cost + l_tl_ovh_dept_cost;

  /* For non bonus transactions use WIP_OPERATION_OVERHEADS to calculate overheads */

  ELSE
    SELECT  nvl(DECODE(p_run_mode,
	        1, SUM(NVL(WOO.applied_ovhd_value,0)),
		2, SUM(NVL(WOO.relieved_ovhd_value,0))),0)
    INTO x_tl_ovh_cost
    FROM   wip_operation_overheads  WOO,
           cst_resource_overheads   CRO,
           wip_operation_resources  WOR
    WHERE
           WOO.operation_seq_num <= l_operation_seq_num
    AND    WOO.wip_entity_id     = p_entity_id
    AND    WOO.organization_id   = p_org_id
    AND    CRO.overhead_id       = WOO.overhead_id
    AND    CRO.resource_id       = WOR.resource_id
    AND    WOR.operation_seq_num = WOO.operation_seq_num
    AND    WOR.resource_seq_num  = WOO.resource_seq_num
    AND    WOR.wip_entity_id     = WOO.wip_entity_id
    AND    WOR.organization_id   = p_org_id
    AND    CRO.cost_type_id      = 1
    AND    WOO.basis_type in (3, 4)
    AND    nvl(WOR.applied_resource_value, 0) >= nvl(WOR.relieved_res_value, 0)
    AND    not exists
         ( SELECT 1
           FROM   wip_operations WO
           WHERE  WO.DISABLE_DATE      <= l_transaction_date
           AND    WO.operation_seq_num = WOO.operation_seq_num
           AND    WO.wip_entity_id     = p_entity_id )
    AND  ( WOR.basis_type <> 2 or p_txn_type = 1 );

    SELECT  nvl(DECODE(p_run_mode,
	        1, SUM(NVL(WOO.applied_ovhd_value,0)),
		2, SUM(NVL(WOO.relieved_ovhd_value,0))),0)
    INTO l_tl_ovh_dept_cost
    FROM   wip_operation_overheads  WOO
    WHERE
           WOO.operation_seq_num <= l_operation_seq_num
    AND    WOO.wip_entity_id     = p_entity_id
    AND    WOO.organization_id   = p_org_id
    AND    WOO.basis_type in (1, 2)
    AND    not exists
         ( SELECT 1
           FROM   wip_operations WO
           WHERE   WO.DISABLE_DATE     <= l_transaction_date
           AND    WO.operation_seq_num = WOO.operation_seq_num
           AND    WO.wip_entity_id     = p_entity_id )
    AND  ( WOO.basis_type <> 2 or p_txn_type = 1 );

    x_tl_ovh_cost := x_tl_ovh_cost + l_tl_ovh_dept_cost;

  END IF;

  IF(l_debug_flag = 'Y') THEN
    FND_FILE.put_line(fnd_file.log,'CSTPSMUT.GET_JOB_VALUE <<<');
    FND_FILE.put_line(fnd_file.log,'Job: '||to_char(p_entity_id));
    FND_FILE.put_line(fnd_file.log,'Run Mode(1-Charge, 2-Scrap): ' ||to_char(p_run_mode));
    FND_FILE.put_line(fnd_file.log,'Transaction Type: ' ||to_char(p_txn_type));
    FND_FILE.put_line(fnd_file.log,'PL MTL COST: '||to_char(x_pl_mtl_cost));
    FND_FILE.put_line(fnd_file.log,'PL MOH COST: '||to_char(x_pl_mto_cost));
    FND_FILE.put_line(fnd_file.log,'PL RES COST: '||to_char(x_pl_res_cost));
    FND_FILE.put_line(fnd_file.log,'PL OSP COST: '||to_char(x_pl_osp_cost));
    FND_FILE.put_line(fnd_file.log,'PL OVH COST: '||to_char(x_pl_ovh_cost));
    FND_FILE.put_line(FND_FILE.log,'TL RES COST: '||to_char(x_tl_res_cost));
    FND_FILE.put_line(FND_FILE.log,'TL OSP COST: '||to_char(x_tl_osp_cost));
    FND_FILE.put_line(FND_FILE.log,'TL OVH COST: '||to_char(x_tl_ovh_cost));
    FND_FILE.put_line(fnd_file.log,'CSTPSMUT.GET_JOB_VALUE >>>');
  END IF;

EXCEPTION
	when others then
           x_err_code:= null;
           x_err_num := SQLCODE;
           x_err_msg := 'CSTPSMUT: GET_JOB_VALUE- '||l_stmt_num||'.'||SQLERRM;

END GET_JOB_VALUE;


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--  UPDATE_JOB_QUANTITY                                                   --
--                                                                        --
-- DESCRIPTION                                                            --
--  The procedure is called by the routines costing a lot transaction.
--  It updates COSTED_QUANTITY in WRO, APPLIED_RESOURCE_UNITS and
--  APPLIED_RESOURCE_VALUE in WOR and APPLIED_OVHD_UNITS and
--  APPLIED_OVHD_VALUE in WOO
--
--                                                                        --
-- PURPOSE:                                                               --
--  OSFM Lot Transactions Costing for Oracle Applications Rel 11i.8
--                                                                        --
-- PARAMETERS:                                                            --
--  p_api_version 	API version
--  p_txn_id		Transaction ID from MMT
--  x_err_num           Error Number
--  x_err_code          Error Code                                        --
--  x_err_msg           Error Message                                     --

-- HISTORY:                                                               --
--  August-2002         Vinit                       Redesign              --
----------------------------------------------------------------------------

PROCEDURE UPDATE_JOB_QUANTITY ( p_api_version          IN NUMBER,
                                p_txn_id               IN NUMBER,
                                x_err_num              IN OUT NOCOPY NUMBER,
                                x_err_code             IN OUT NOCOPY VARCHAR2,
                                x_err_msg              IN OUT NOCOPY VARCHAR2 ) IS

l_api_name  	CONSTANT  VARCHAR2(240)  := 'UPDATE_JOB_QUANTITY';
l_api_version   CONSTANT  NUMBER      := 1.0;

l_min_acct_unit           NUMBER    := NULL;
l_org_id                  NUMBER    := NULL;

l_stmt_num                NUMBER    := 0;

/* Transaction Information */
l_txn_type                NUMBER;
l_transaction_date        DATE;
l_operation_seq_num       NUMBER;
l_intraoperation_step     NUMBER;
l_available_quantity      NUMBER;
l_job_start_quantity      NUMBER;
l_rep_wip_entity_id       NUMBER;

/* Other */
l_scale_factor            NUMBER;
l_resulting_job           NUMBER := 0;
l_resulting_scale_factor  NUMBER := 0;
l_include_comp_yield      NUMBER;

CURSOR C_RJ IS SELECT *
            FROM   wsm_sm_resulting_jobs
            WHERE  transaction_id = p_txn_id;

CURSOR C_SJ IS SELECT *
            FROM   wsm_sm_starting_jobs
            WHERE  transaction_id = p_txn_id;


BEGIN
  l_stmt_num := 10;
  IF(l_debug_flag = 'Y') THEN
    FND_FILE.put_line(fnd_file.log,'CSTPSMUT.UPDATE_JOB_QUANTITY <<<');
  END IF;

  IF NOT FND_API.COMPATIBLE_API_CALL (
                               l_api_version,
                               p_api_version,
                               l_api_name,
                               G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  /* Obtain Transaction Information */
  l_stmt_num := 20;

  SELECT organization_id,
         transaction_type_id,
         transaction_date
  INTO   l_org_id,
         l_txn_type,
         l_transaction_date
  FROM   WSM_SPLIT_MERGE_TRANSACTIONS
  WHERE transaction_id = p_txn_id;

  /* Get the value of Include Component yield flag,
  which will determine whether to include or not
  component yield factor in quantity per assembly */
  l_stmt_num := 25;
  SELECT  NVL(include_component_yield, 1)
  INTO    l_include_comp_yield
  FROM    wip_parameters
  WHERE   organization_id = l_org_id;

  l_stmt_num := 30;

  /* Get Minimum Accounting Unit */

  SELECT   NVL(FC.minimum_accountable_unit, POWER(10,NVL(-precision,0)))
  INTO     l_min_acct_unit
  FROM     fnd_currencies fc,
	   cst_organization_definitions o
  WHERE    o.organization_id = l_org_id
  AND      o.currency_code = fc.currency_code;

  IF (l_txn_type = WSMPCNST.BONUS) THEN
    FOR C_result in C_RJ LOOP

      l_operation_seq_num := C_result.JOB_OPERATION_SEQ_NUM;

    /* Only for jobs created before 11i.8, we need to use
       STARTING_OPERATION_SEQ_NUM to get the operation_seq_num for
       Bonus. For such jobs, JOB_OPERATION_SEQ_NUM is NULL */

      l_stmt_num := 35;

      IF l_operation_seq_num IS NULL THEN
        SELECT wo.operation_seq_num
        INTO   l_operation_seq_num
        FROM   WIP_OPERATIONS WO,
               WSM_SM_RESULTING_JOBS WSRJ,
               BOM_OPERATION_SEQUENCES BOS
        WHERE  WSRJ.transaction_id                       = p_txn_id
        AND    nvl(wsrj.starting_intraoperation_step, 1) = 1
        AND    wsrj.common_routing_sequence_id           = bos.routing_sequence_id
        AND    wsrj.starting_operation_seq_num           = bos.operation_seq_num
        AND    bos.operation_sequence_id                 = wo.operation_sequence_id
        AND    bos.EFFECTIVITY_DATE                      <= l_transaction_date
        AND    NVL( bos.DISABLE_DATE, l_transaction_date + 1) > l_transaction_date
        AND    wo.wip_entity_id                          = wsrj.wip_entity_id
        AND    wo.organization_id                        = l_org_id;
      END IF;

     /* Update applied resource units and  applied resource value. */
     l_stmt_num := 40;


     UPDATE wip_operation_resources wor
     SET    wor.applied_resource_units = ROUND((C_result.start_quantity *
                                         decode(wor.basis_type,
                                                1,wor.usage_rate_or_amount,
                                                2,wor.usage_rate_or_amount/C_result.start_quantity,
                                                wor.usage_rate_or_amount)), 6),
            wor.applied_resource_value = (SELECT
                                          ROUND((nvl(max(C_result.start_quantity *
                                          decode(wor.basis_type,
                                                 1,wor.usage_rate_or_amount,
                                                 2,wor.usage_rate_or_amount/C_result.start_quantity,
                                                  wor.usage_rate_or_amount)*
                                          decode (br.functional_currency_flag,
                                                  1, 1,
                                                  nvl(crc.resource_rate,0)))
                                          ,0))/l_min_acct_unit) * l_min_acct_unit
                                          FROM bom_resources br,
                                               cst_resource_costs crc
                                          WHERE
                                               br.resource_id      = wor.resource_id
                                          AND  br.organization_id  = l_org_id
                                          AND  crc.cost_type_id    = 1
                                          AND  crc.organization_id = l_org_id
                                          AND  crc.resource_id     = wor.resource_id )
     WHERE wor.wip_entity_id = C_result.wip_entity_id
     AND wor.operation_seq_num < l_operation_seq_num;

     /* Update quantity issued. */

     l_stmt_num := 50;

     UPDATE wip_requirement_operations wro
     SET  costed_quantity_issued = ROUND((C_result.start_quantity *
                                                DECODE(nvl(wro.basis_type,1),
                                                       2, wro.quantity_per_assembly/C_result.start_quantity,
                                                       wro.quantity_per_assembly) /
                                                DECODE(l_include_comp_yield,
                                                       1, nvl(wro.component_yield_factor,1),
                                                       1)), 6)
     WHERE  wip_entity_id = C_result.wip_entity_id
     AND    operation_seq_num < l_operation_seq_num
     AND    wip_supply_type not in (2, 4, 5, 6);

     /* Update WOO */

     l_stmt_num := 55;

     /* Resource Unit and Value Based Overheads */
     UPDATE wip_operation_overheads woo
     SET    ( applied_ovhd_units,
              applied_ovhd_value ) =
            ( SELECT decode(woo.basis_type,
                                 3, NVL(WOR.applied_resource_units,0),
                                 4, NVL(WOR.APPLIED_RESOURCE_VALUE,0)),
                     decode(woo.basis_type,
                                 3, NVL(CDO.rate_or_amount* WOR.applied_resource_units,0),
                                 4, NVL(CDO.rate_or_amount*
                                        NVL(WOR.APPLIED_RESOURCE_VALUE,0), 0))
             FROM wip_operation_resources WOR,
                  cst_resource_overheads CRO,
                  cst_department_overheads CDO,
                  wip_operations WO
             WHERE
                  WOR.wip_entity_id     = C_result.wip_entity_id
             AND  WOR.organization_id   = l_org_id
             AND  WOR.operation_seq_num = WOO.operation_seq_num
             AND  WOR.resource_seq_num  = WOO.resource_seq_num
             AND  WOR.resource_id       = CRO.resource_id
             AND  CRO.overhead_id       = CDO.overhead_id
             AND  CDO.overhead_id       = WOO.overhead_id
             AND  CDO.department_id     = WO.department_id
             AND  WO.wip_entity_id      = C_result.wip_entity_id
             AND  WO.organization_id    = l_org_id
             AND  WO.operation_seq_num  = WOO.operation_seq_num
             AND  CRO.cost_type_id      = 1
             AND  CDO.cost_type_id      = 1
             AND  CDO.basis_type        = WOO.basis_type
             )
    WHERE
         wip_entity_id     = C_result.wip_entity_id
    AND  organization_id   = l_org_id
    AND  operation_seq_num < l_operation_seq_num
    AND  basis_type        in (3,4);

    l_stmt_num := 58;

    /* Department Based Overheads */

    UPDATE wip_operation_overheads woo
    SET    ( applied_ovhd_units,
             applied_ovhd_value ) =
           ( SELECT decode(woo.basis_type, 1, C_result.start_quantity,
                                 2, 1),
                    decode(woo.basis_type, 1, CDO.rate_or_amount * C_result.start_quantity,
                                 2, CDO.rate_or_amount)
             FROM  wip_operations WO,
                   cst_department_overheads CDO
             WHERE
                   woo.operation_seq_num = wo.operation_seq_num
             AND   WO.wip_entity_id      = C_result.wip_entity_id
             AND   WO.organization_id    = l_org_id
             AND   CDO.department_id     = WO.department_id
             AND   CDO.overhead_id       = WOO.overhead_id
             AND   CDO.cost_type_id      = 1
             AND   CDO.basis_type        = WOO.basis_type )
    WHERE wip_entity_id     = C_result.wip_entity_id
    AND  organization_id    = l_org_id
    AND  operation_seq_num < l_operation_seq_num
    AND  basis_type        in (1,2);

    END LOOP;
     x_err_num := 0;
     x_err_code := NULL;

  ELSE
     /*  Update Quantity/Split/Merge */
     /* Obtain Information from WSM_SM_STARTING_JOBS
        for representative Lot. */
     l_stmt_num := 60;

     SELECT operation_seq_num,
            intraoperation_step,
            wip_entity_id,
            available_quantity,
            job_start_quantity
     INTO   l_operation_seq_num,
            l_intraoperation_step,
            l_rep_wip_entity_id,
            l_available_quantity,
            l_job_start_quantity
     FROM   WSM_SM_STARTING_JOBS
     WHERE  transaction_id      = p_txn_id
     AND    representative_flag = 'Y';

     FOR C_rec IN C_RJ LOOP
       l_stmt_num := 70;

       l_scale_factor := C_rec.start_quantity/l_available_quantity;

       UPDATE wip_operation_resources wor
       SET   ( wor.applied_resource_units,
              wor.applied_resource_value ) =
            ( SELECT (nvl(wor1.applied_resource_units, 0) - DECODE(sign(nvl(wor1.relieved_res_units, 0)), 1, nvl(wor1.relieved_res_units, 0), 0))  *
                     DECODE(sign(nvl(wor1.applied_resource_units, 0) - DECODE(sign(nvl(wor1.relieved_res_units, 0)), 1, nvl(wor1.relieved_res_units, 0), 0)),
                            1, 1, 0),
                     (nvl(wor1.applied_resource_value,0) - DECODE(sign(nvl(wor1.relieved_res_value, 0)), 1, nvl(wor1.relieved_res_value, 0), 0))  *
                     DECODE(sign(nvl(wor1.applied_resource_value,0) - DECODE(sign(nvl(wor1.relieved_res_value, 0)), 1, nvl(wor1.relieved_res_value, 0), 0)),
                            1, 1, 0)
              FROM   wip_operation_resources wor1
              WHERE  wor1.operation_seq_num = wor.operation_seq_num
              AND    wor1.wip_entity_id     = l_rep_wip_entity_id
              AND    wor1.organization_id   = wor.organization_id
              AND    wor1.resource_seq_num  = wor.resource_seq_num )

       WHERE  	wor.wip_entity_id     =  C_rec.wip_entity_id
       AND      wor.organization_id   =  l_org_id
       AND    	wor.wip_entity_id     <> l_rep_wip_entity_id
       AND      not exists (select 'obsolete operation'
			    from wip_operations wo
			    where wo.wip_entity_id     = wor.wip_entity_id
			    and   wo.organization_id   = wor.organization_id
			    and   wo.operation_seq_num = wor.operation_seq_num
                            and   wo.disable_date      <= l_transaction_date )
       /* Make sure the operation exists in the Parent */
       AND      exists (select 'operation exists'
                        from wip_operation_resources wor2
                        WHERE  wor2.operation_seq_num = wor.operation_seq_num
                        AND    wor2.wip_entity_id     = l_rep_wip_entity_id
                        AND    wor2.organization_id   = wor.organization_id
                        AND    wor2.resource_seq_num  = wor.resource_seq_num);

       l_stmt_num := 75;

       UPDATE wip_requirement_operations wro
       SET    wro.costed_quantity_issued =
             ( SELECT (NVL(wro1.costed_quantity_issued,0) - DECODE(sign(NVL(WRO1.COSTED_QUANTITY_RELIEVED, 0)), 1, NVL(WRO1.COSTED_QUANTITY_RELIEVED, 0), 0) )*
                       /* LBM changes (This is cond like basis_type<>2 or l_txn_type=1) Bugs 5202282*/
                       decode(l_txn_type, 1, l_scale_factor, decode(nvl(wro.basis_type,1), 2, 1, l_scale_factor)) *
                       DECODE(sign(nvl(wro1.costed_quantity_issued,0) - DECODE(sign(NVL(WRO1.COSTED_QUANTITY_RELIEVED, 0)), 1, NVL(WRO1.COSTED_QUANTITY_RELIEVED, 0), 0)),
                              1, 1, 0)
               FROM   wip_requirement_operations wro1
               WHERE  wro1.wip_entity_id     = l_rep_wip_entity_id
               AND    wro1.inventory_item_id = wro.inventory_item_id
               AND    wro1.organization_id   = wro.organization_id
               AND    wro1.operation_seq_num = wro.operation_seq_num )
       WHERE  wro.wip_entity_id     = C_rec.wip_entity_id
       AND    wro.organization_id   = l_org_id
       AND    wro.wip_entity_id     <> l_rep_wip_entity_id
       AND    not exists (select 'obsolete operation'
                         from  wip_operations wo
                         where wo.wip_entity_id     = wro.wip_entity_id
                         and   wo.organization_id   = wro.organization_id
                         and   wo.operation_seq_num = wro.operation_seq_num
                         and   wo.disable_date      <= l_transaction_date )
       /* Make sure the operation exists in the Parent */
       AND    exists (select 'operation exists'
                      from   wip_requirement_operations wro2
                      WHERE  wro2.wip_entity_id     = l_rep_wip_entity_id
                      AND    wro2.inventory_item_id = wro.inventory_item_id
                      AND    wro2.organization_id   = wro.organization_id
                      AND    wro2.operation_seq_num = wro.operation_seq_num );

       l_stmt_num := 80;

       /* For WOO, the strategy is different */
       /* For Lot and Item based overheads,
          Update WOO using the values for corresponding fields in the
          representative lot
          For resource unit and resource value based overheads,
          set applied_ovhd_units = applied_res_units (Res Unit based ovhd)
                                 = applied_res_value (Res Value based ovhd)
          from WOR.
              applied_ovhd_value  = CDO.rate_or_amount * applied_ovhd_units
        */

       /* For Item and Lot based Ovhd's, Initialize the Ovhd's */
       UPDATE wip_operation_overheads woo
       SET    ( woo.applied_ovhd_units,
                woo.applied_ovhd_value ) =
              ( SELECT (NVL(woo1.applied_ovhd_units,0) - DECODE(sign(nvl(woo1.relieved_ovhd_units, 0)), 1, nvl(woo1.relieved_ovhd_units, 0), 0) )  *
                       DECODE(sign(nvl(woo1.applied_ovhd_units,0) - DECODE(sign(nvl(woo1.relieved_ovhd_units, 0)), 1, nvl(woo1.relieved_ovhd_units, 0), 0)),
                              1, 1, 0),
                       (NVL(woo1.applied_ovhd_value,0) - DECODE(sign(nvl(woo1.relieved_ovhd_value, 0)), 1, nvl(woo1.relieved_ovhd_value, 0), 0) )  *
                       DECODE(sign(nvl(woo1.applied_ovhd_value,0) - DECODE(sign(nvl(woo1.relieved_ovhd_value, 0)), 1, nvl(woo1.relieved_ovhd_value, 0), 0)),
                              1, 1, 0)
                FROM   wip_operation_overheads woo1
                WHERE  woo1.wip_entity_id     = l_rep_wip_entity_id
                AND    woo1.overhead_id       = woo.overhead_id
                AND    woo1.organization_id   = woo.organization_id
                AND    woo1.operation_seq_num = woo.operation_seq_num
                AND    woo1.resource_seq_num  = woo.resource_seq_num)
       WHERE  woo.wip_entity_id     = C_rec.wip_entity_id
       AND    woo.organization_id   = l_org_id
       AND    woo.wip_entity_id     <> l_rep_wip_entity_id
       AND    not exists (select 'obsolete operation'
                          from wip_operations wo
                          where wo.wip_entity_id     = woo.wip_entity_id
                          and   wo.organization_id   = woo.organization_id
                          and   wo.operation_seq_num = woo.operation_seq_num
                          and   wo.disable_date      <= l_transaction_date )
       AND    woo.basis_type in (1,2)
       /* Make sure the operation and overhead exist in the Parent */
       AND    exists (select 'operation exists'
                      from   wip_operation_overheads woo2
                      WHERE  woo2.wip_entity_id     = l_rep_wip_entity_id
                      AND    woo2.overhead_id       = woo.overhead_id
                      AND    woo2.organization_id   = woo.organization_id
                      AND    woo2.operation_seq_num = woo.operation_seq_num
                      AND    woo2.resource_seq_num  = woo.resource_seq_num);
   END LOOP;

   FOR C_rec1 IN C_RJ LOOP
     l_scale_factor := C_rec1.start_quantity/l_available_quantity;

     IF(l_debug_flag = 'Y') THEN
       FND_FILE.put_line(fnd_file.log, 'Job: '||to_char(C_rec1.wip_entity_id));
       FND_FILE.put_line(fnd_file.log,'Updating the Non Representative Lots by the scale factor: '||to_char(l_scale_factor));
     END IF;

     IF C_rec1.wip_entity_id = l_rep_wip_entity_id THEN
       l_resulting_job := 1;
       l_resulting_scale_factor := l_scale_factor;
     END IF;

     l_stmt_num := 92;

     UPDATE wip_operation_resources wor
     SET   wor.applied_resource_units = wor.applied_resource_units * l_scale_factor,
           wor.applied_resource_value = wor.applied_resource_value * l_scale_factor
     WHERE wor.wip_entity_id     =  C_rec1.wip_entity_id
     AND   wor.organization_id   =  l_org_id
     AND   wor.wip_entity_id     <> l_rep_wip_entity_id
     AND   not exists (select 'obsolete operation'
			from  wip_operations wo
			where wo.wip_entity_id     = wor.wip_entity_id
			and   wo.organization_id   = wor.organization_id
			and   wo.operation_seq_num = wor.operation_seq_num
                        and   wo.disable_date      <= l_transaction_date )
     AND    ( basis_type <> 2 or l_txn_type = 1 );

     l_stmt_num := 95;

     /* For Item and Lot based Ovhds, scale them depending on Txn Type
        Lot based ovhds not scaled for merge/update_qty
      */

     UPDATE wip_operation_overheads woo
     SET    woo.applied_ovhd_units = woo.applied_ovhd_units * l_scale_factor,
            woo.applied_ovhd_value = woo.applied_ovhd_value * l_scale_factor
     WHERE  woo.wip_entity_id     = C_rec1.wip_entity_id
     AND    woo.organization_id   = l_org_id
     AND    woo.wip_entity_id     <> l_rep_wip_entity_id
     AND    not exists (select 'obsolete operation'
                        from wip_operations wo
                        where wo.wip_entity_id     = woo.wip_entity_id
                        and   wo.organization_id   = woo.organization_id
                        and   wo.operation_seq_num = woo.operation_seq_num
                        and   wo.disable_date      <= l_transaction_date )
     AND    ( basis_type <> 2 or l_txn_type = 1 )
     AND    basis_type in (1, 2);

     /* Update WOO for Resource Unit and Value based Ovhds */

     l_stmt_num := 98;

     UPDATE wip_operation_overheads woo
     SET    ( applied_ovhd_units,
              applied_ovhd_value ) =
            ( SELECT decode(woo.basis_type,
                                 3, NVL(WOR.applied_resource_units,0),
                                 4, NVL(WOR.APPLIED_RESOURCE_VALUE,0)),
                     decode(woo.basis_type,
                                 3, NVL(CDO.rate_or_amount* NVL(WOR.applied_resource_units, 0) , 0),
                                 4, NVL(CDO.rate_or_amount*
                                        NVL(WOR.APPLIED_RESOURCE_VALUE,0), 0))
             FROM wip_operation_resources WOR,
                  cst_resource_overheads CRO,
                  cst_department_overheads CDO,
                  wip_operations WO
             WHERE
                  WOR.wip_entity_id     = C_rec1.wip_entity_id
             AND  WOR.organization_id   = l_org_id
             AND  WOR.operation_seq_num = WOO.operation_seq_num
             AND  WOR.resource_seq_num  = WOO.resource_seq_num
             AND  WOR.resource_id       = CRO.resource_id
             AND  CRO.overhead_id       = CDO.overhead_id
             AND  CDO.overhead_id       = WOO.overhead_id
             AND  CDO.department_id     = WO.department_id
             AND  WO.wip_entity_id      = C_rec1.wip_entity_id
             AND  WO.organization_id    = l_org_id
             AND  WO.operation_seq_num  = WOO.operation_seq_num
             AND  CRO.cost_type_id      = 1
             AND  CDO.cost_type_id      = 1
             AND  CDO.basis_type        = WOO.basis_type
             )
    WHERE
         wip_entity_id     = C_rec1.wip_entity_id
    AND  wip_entity_id     <> l_rep_wip_entity_id
    AND  organization_id   = l_org_id
    AND  basis_type        in (3, 4);

    END LOOP;  -- end looping resulting lots


    /* If resulting job is the same as the starting job,
       add the relieved quantity to the quantity issued. */

    IF (l_resulting_job = 1) THEN

    IF(l_debug_flag = 'Y') THEN
       FND_FILE.put_line(fnd_file.log,'Updating Resulting Job that is part of Start Job:(App-Rel)*F + Rel: '||to_char(l_resulting_scale_factor));
     END IF;
     l_stmt_num := 100;

     UPDATE wip_operation_resources wor
     SET    wor.applied_resource_units = (NVL(wor.applied_resource_units,0) -
                                          DECODE(sign(nvl(wor.relieved_res_units, 0)), 1, nvl(wor.relieved_res_units, 0), 0))
                                          * l_resulting_scale_factor +
                                          DECODE(sign(nvl(wor.relieved_res_units, 0)), 1, nvl(wor.relieved_res_units, 0), 0),
            wor.applied_resource_value = (NVL(wor.applied_resource_value,0) -
                                          DECODE(sign(nvl(wor.relieved_res_value, 0)), 1, nvl(wor.relieved_res_value, 0), 0))
                                         * l_resulting_scale_factor +
                                         DECODE(sign(nvl(wor.relieved_res_value, 0)), 1, nvl(wor.relieved_res_value, 0), 0)
     WHERE  wor.wip_entity_id      = l_rep_wip_entity_id
     AND    not exists (select 'obsolete operation'
                        from wip_operations wo
                        where wo.wip_entity_id     = wor.wip_entity_id
                        and   wo.organization_id   = wor.organization_id
                        and   wo.operation_seq_num = wor.operation_seq_num
                        and   wo.disable_date      <= l_transaction_date )
     AND    nvl(wor.applied_resource_units, 0) >= nvl(wor.relieved_res_units, 0)
     AND    nvl(wor.applied_resource_value, 0) >= nvl(wor.relieved_res_value, 0)
     AND    (wor.basis_type <> 2 or l_txn_type = 1 );

     UPDATE wip_requirement_operations wro
     SET    wro.costed_quantity_issued = (NVL(wro.costed_quantity_issued, 0) -
                                          DECODE(sign(NVL(WRO.COSTED_QUANTITY_RELIEVED, 0)), 1, NVL(WRO.COSTED_QUANTITY_RELIEVED, 0), 0))
                                     * l_resulting_scale_factor +
                                     DECODE(sign(NVL(WRO.COSTED_QUANTITY_RELIEVED, 0)), 1, NVL(WRO.COSTED_QUANTITY_RELIEVED, 0), 0)
     WHERE  wro.wip_entity_id      = l_rep_wip_entity_id
     AND    not exists (select 'obsolete operation'
                        from wip_operations wo
                        where wo.wip_entity_id     = wro.wip_entity_id
                        and   wo.organization_id   = wro.organization_id
                        and   wo.operation_seq_num = wro.operation_seq_num
                        and   wo.disable_date      <= l_transaction_date )
     AND    nvl(wro.costed_quantity_issued, 0) >= nvl(wro.costed_quantity_relieved, 0)
     AND    (nvl(wro.basis_type,1) <> 2 or l_txn_type = 1 ); /* LBM Changes for Merge Bug 5202282 */

     /* Update WOO in a similar manner */
     UPDATE wip_operation_overheads woo
     SET    applied_ovhd_units =
            (NVL(woo.applied_ovhd_units, 0) - DECODE(sign(nvl(relieved_ovhd_units, 0)), 1, nvl(relieved_ovhd_units, 0), 0)) * l_resulting_scale_factor
           + DECODE(sign(nvl(relieved_ovhd_units, 0)), 1, nvl(relieved_ovhd_units, 0), 0),
            applied_ovhd_value =
            (NVL(woo.applied_ovhd_value, 0) - DECODE(sign(nvl(relieved_ovhd_value, 0)), 1, nvl(relieved_ovhd_value, 0), 0)) * l_resulting_scale_factor
           + DECODE(sign(nvl(relieved_ovhd_value, 0)), 1, nvl(relieved_ovhd_value, 0), 0)
     WHERE  woo.wip_entity_id      = l_rep_wip_entity_id
     AND    woo.organization_id    = l_org_id
     AND    not exists (select 'obsolete operation'
                        from wip_operations wo
                        where wo.wip_entity_id     = woo.wip_entity_id
                        and   wo.organization_id   = woo.organization_id
                        and   wo.operation_seq_num = woo.operation_seq_num
                        and   wo.disable_date      <= l_transaction_date )
     AND    (NVL(woo.applied_ovhd_units, 0) - NVL(relieved_ovhd_units, 0)) >= 0
     AND    (NVL(woo.applied_ovhd_value, 0) - NVL(relieved_ovhd_value, 0)) >= 0
     AND    (woo.basis_type <> 2 or l_txn_type = 1 )
     AND    woo.basis_type in (1, 2);

     UPDATE wip_operation_overheads woo
     SET    ( applied_ovhd_units,
              applied_ovhd_value ) =
            (SELECT decode(woo.basis_type,
                                 3, NVL(WOR.applied_resource_units,0),
                                 4, NVL(WOR.APPLIED_RESOURCE_VALUE,0)),
                     decode(woo.basis_type,
                                 3, NVL(CDO.rate_or_amount* WOR.applied_resource_units,0),
                                 4, NVL(CDO.rate_or_amount*
                                        NVL(WOR.APPLIED_RESOURCE_VALUE,0), 0))
             FROM wip_operation_resources WOR,
                  cst_resource_overheads CRO,
                  cst_department_overheads CDO,
                  wip_operations WO
             WHERE
                  WOR.wip_entity_id     = l_rep_wip_entity_id
             AND  WOR.organization_id   = l_org_id
             AND  WOR.operation_seq_num = WOO.operation_seq_num
             AND  WOR.resource_seq_num	= WOO.resource_seq_num
             AND  WOR.resource_id       = CRO.resource_id
             AND  CRO.overhead_id       = CDO.overhead_id
             AND  CDO.overhead_id       = WOO.overhead_id
             AND  CDO.department_id     = WO.department_id
             AND  WO.wip_entity_id      = l_rep_wip_entity_id
             AND  WO.organization_id    = l_org_id
             AND  WO.operation_seq_num  = WOO.operation_seq_num
             AND  CRO.cost_type_id      = 1
             AND  CDO.cost_type_id      = 1
             AND  CDO.basis_type        = WOO.basis_type
            )
    WHERE
         wip_entity_id     = l_rep_wip_entity_id
    AND  organization_id   = l_org_id
    AND  basis_type        in (3,4);

    END IF;


    /* In Starting Jobs, for Jobs that are not resulting jobs,
       set WRO.costed_quantity_issued = WRO.quantity_relieved
           WOR.applied_resource_units = WOR.relieved_resource_units
           WOR.applied_resource_value = WOR.relieved_resource_value
     */


     l_resulting_job := 0;

     FOR S_rec IN C_SJ LOOP
       BEGIN
       l_stmt_num := 110;
       SELECT 1
       INTO   l_resulting_job
       FROM   sys.dual
       WHERE EXISTS (SELECT 1
                     FROM   wsm_sm_resulting_jobs
                     WHERE  transaction_id = p_txn_id
                     AND    wip_entity_id  = S_rec.wip_entity_id);
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
         l_resulting_job := 0;

       END;
       IF ( l_resulting_job = 0 ) THEN

         IF(l_debug_flag = 'Y') THEN
           FND_FILE.put_line(fnd_file.log,'Updating Resulting Job that is not part of Start Job:App = Rel: '||to_char(S_rec.wip_entity_id));
         END IF;

         l_stmt_num := 120;

         UPDATE wip_operation_resources wor
         SET    applied_resource_units = round(DECODE(sign(nvl(relieved_res_units, 0)), 1, nvl(relieved_res_units, 0), 0),6),
                applied_resource_value = round(DECODE(sign(nvl(relieved_res_value, 0)), 1, nvl(relieved_res_value, 0), 0),6)
         WHERE  wip_entity_id = S_rec.wip_entity_id
         AND    nvl(applied_resource_units, 0) >= nvl(relieved_res_units, 0)
         AND    nvl(applied_resource_value, 0) >= nvl(relieved_res_value, 0)
         AND    not exists (select 'obsolete operation'
                            from wip_operations wo
                            where wo.wip_entity_id = wor.wip_entity_id
                            and   wo.organization_id = wor.organization_id
                            and   wo.operation_seq_num = wor.operation_seq_num
                            and   wo.disable_date      <= l_transaction_date );

         l_stmt_num := 130;

         UPDATE wip_requirement_operations wro
         SET    costed_quantity_issued = round(DECODE(sign(NVL(WRO.COSTED_QUANTITY_RELIEVED, 0)), 1, NVL(WRO.COSTED_QUANTITY_RELIEVED, 0), 0),6)
         WHERE  wip_entity_id                   = S_rec.wip_entity_id
         AND    nvl(costed_quantity_issued, 0) >= nvl(costed_quantity_relieved, 0)
         AND    not exists (select 'obsolete operation'
                            from wip_operations wo
                            where wo.wip_entity_id = wro.wip_entity_id
                            and   wo.organization_id = wro.organization_id
                            and   wo.operation_seq_num = wro.operation_seq_num
                            and   wo.disable_date      <= l_transaction_date );



         l_stmt_num := 135;
         UPDATE wip_operation_overheads woo
         SET    applied_ovhd_units = DECODE(sign(nvl(relieved_ovhd_units, 0)), 1, nvl(relieved_ovhd_units, 0), 0),
                applied_ovhd_value = DECODE(sign(nvl(relieved_ovhd_value, 0)), 1, nvl(relieved_ovhd_value, 0), 0)
         WHERE  woo.wip_entity_id  = S_rec.wip_entity_id
         AND    woo.organization_id= l_org_id
         AND    not exists (select 'obsolete operation'
                            from wip_operations wo
                            where wo.wip_entity_id     = woo.wip_entity_id
                            and   wo.organization_id   = woo.organization_id
                            and   wo.operation_seq_num = woo.operation_seq_num
                            and   wo.disable_date      <= l_transaction_date )
         AND    (NVL(woo.applied_ovhd_units, 0) - NVL(relieved_ovhd_units, 0)) >= 0
         AND    (NVL(woo.applied_ovhd_value, 0) - NVL(relieved_ovhd_value, 0)) >= 0;
      END IF;

    END LOOP;

  END IF; -- Non Bonus Transaction

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_err_num  := -1;
    x_err_code := 'Inconsistent API Version';--FND_API.G_RET_SYS_ERROR;
    x_err_msg  := 'CSTPSMUT.UPDATE_JOB_QUANTITY('||to_char(l_stmt_num)||'):'|| x_err_msg || substr(SQLERRM, 1, 200);
    FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
 WHEN OTHERS THEN
    x_err_num  := -1;
    x_err_code := 'Error Updating Quantity';
    x_err_msg  := 'CSTPSMUT.UPDATE_JOB_QUANTITY('||to_char(l_stmt_num)||'): ' || substr(SQLERRM, 1, 200);
    FND_FILE.PUT_LINE(FND_FILE.LOG, x_err_msg);
END update_job_quantity;

-------------------------------------------------------------------------
------------------- END CHANGES FOR OSFM_I ------------------------------
-------------------------------------------------------------------------


-- the following parameters are
-- from fespsmas
--x_lot_size 		number	:= 0;
--p_min_acct_unit		number	:= 0;
--x_ext_prec		number(2):= 0;
-- end fespsmas


PROCEDURE BALANCE_ACCOUNTING (p_mtl_txn_id IN number,
                              p_wip_txn_id IN number,
                              p_txn_type IN number,
                              p_err_msg IN OUT NOCOPY VARCHAR2,
                              p_err_code IN OUT NOCOPY VARCHAR2,
                              p_err_num IN OUT NOCOPY NUMBER) IS
       l_mta_total_sum  NUMBER:=0;
       l_wta_total_sum  NUMBER:=0;
       l_mta_temp_value NUMBER;
       l_wta_temp_value NUMBER;
       l_stmt_num       NUMBER;

    BEGIN
       p_err_num := 0;
       l_stmt_num := 10;

       -- find out if the credit and debit are balanced in MTA
       SELECT sum(base_transaction_value)
       INTO   l_mta_total_sum
       FROM   mtl_transaction_accounts
       WHERE  transaction_id in (p_mtl_txn_id);

       l_stmt_num := 20;
       IF l_mta_total_sum <> 0 THEN
          IF (p_txn_type = 1) THEN -- split
          -- if not balanced, get the sum of all credit and debit
          -- except the representative lot's highest cost element elemental cost.

             l_stmt_num := 23;
-- Get the sum of all child lots

--             SELECT sum(base_transaction_value)
--             INTO   temp_value
--             FROM   mtl_transaction_accounts
--             WHERE  transaction_id in (p_mtl_txn_id)
--             AND    base_transaction_value > 0;

-- get the sum of debit/credit except the rep. lot highest cost element.

             l_stmt_num := 30;
             SELECT  sum(base_transaction_value)
             INTO    l_mta_temp_value
             FROM    mtl_transaction_accounts
             WHERE   transaction_id in (p_mtl_txn_id)
             AND NOT (cost_element_id = (SELECT MAX(mta1.cost_element_id)
                                         FROM   mtl_transaction_accounts mta1
                                         WHERE  mta1.transaction_id = p_mtl_txn_id
                                         AND    mta1.base_transaction_value < 0 )
                                         AND    base_transaction_value < 0);

          -- update the base txn value for the variance
             l_stmt_num := 40;
             UPDATE mtl_transaction_accounts mta
             SET    base_transaction_value = -1 * (l_mta_temp_value)
             WHERE  mta.transaction_id = p_mtl_txn_id
             AND    mta.cost_element_id = (SELECT MAX(mta1.cost_element_id)
                                           FROM   mtl_transaction_accounts mta1
                                           WHERE  mta1.transaction_id = p_mtl_txn_id
                                           AND    mta.base_transaction_value < 0)
             AND    mta.base_transaction_value < 0;

          ELSIF p_txn_type = 2 THEN -- merge txn
          -- if not balanced, get the sum of all credit and debit
          -- except the resulting lot's last cost element

-- Get the sum of all child lots

             l_stmt_num := 60;
             SELECT  sum(base_transaction_value)
             INTO    l_mta_temp_value
             FROM    mtl_transaction_accounts
             WHERE   transaction_id in (p_mtl_txn_id)
             AND NOT (cost_element_id = (SELECT MAX(mta1.cost_element_id)
                                         FROM   mtl_transaction_accounts mta1
                                         WHERE  mta1.transaction_id = p_mtl_txn_id
                                         AND    mta1.base_transaction_value > 0 )
                                         AND    base_transaction_value > 0);

             l_stmt_num := 70;
          -- update the base txn value for the variance
             UPDATE mtl_transaction_accounts mta
             SET    base_transaction_value = -1 * (l_mta_temp_value)
             WHERE  mta.transaction_id = p_mtl_txn_id
             AND    mta.cost_element_id = (SELECT MAX(mta1.cost_element_id)
                                           FROM   mtl_transaction_accounts mta1
                                           WHERE  mta1.transaction_id = p_mtl_txn_id
                                           AND    mta1.base_transaction_value > 0)
             AND    mta.base_transaction_value > 0;

          ELSIF p_txn_type in( 4, 6) THEN -- update qty, bonus transaction
          -- if not balanced, get the sum of all debit

             l_stmt_num := 80;
             SELECT  sum(base_transaction_value)
             INTO    l_mta_temp_value
             FROM    mtl_transaction_accounts
             WHERE   transaction_id in (p_mtl_txn_id)
             AND     base_transaction_value > 0;

             l_stmt_num := 90;
             UPDATE mtl_transaction_accounts mta
             SET    base_transaction_value = -1 * (l_mta_temp_value)
             WHERE  mta.transaction_id = p_mtl_txn_id
             AND    mta.cost_element_id is null;

          END IF;
      END IF; -- MTA TOTAL SUM <> 0

      l_stmt_num := 100;
      -- balance credit / debit in wta
      SELECT sum(base_transaction_value)
      INTO   l_wta_total_sum
      FROM   wip_transaction_accounts wta
      WHERE  transaction_id in (p_wip_txn_id);


      l_stmt_num := 110;
      IF l_wta_total_sum <> 0 THEN
         IF (p_txn_type = 1) THEN

            l_stmt_num := 120;
--            SELECT sum(base_transaction_value)
--            INTO   temp_value
--            FROM   wip_transaction_accounts
--            WHERE  transaction_id in (p_wip_txn_id)
--            AND    base_transaction_value > 0;

            l_stmt_num := 130;
            SELECT sum(base_transaction_value)
            INTO   l_wta_temp_value
            FROM   wip_transaction_accounts wta
            WHERE  transaction_id in (p_wip_txn_id)
            AND NOT ( cost_element_id = (SELECT MAX(cost_element_id)
                                         FROM   wip_transaction_accounts wta1
                                         WHERE  wta1.transaction_id = p_wip_txn_id
                                         AND    wta1.base_transaction_value < 0  )
                                         AND    wta.base_transaction_value < 0);

            l_stmt_num := 140;
            UPDATE wip_transaction_accounts wta
            SET    wta.base_transaction_value = -1*(l_wta_temp_value)
            WHERE  transaction_id in (p_wip_txn_id)
            AND    (base_transaction_value < 0
                    and cost_element_id=(SELECT MAX(cost_element_id)
                                         FROM   wip_transaction_accounts wta1
                                         WHERE  wta1.transaction_id = p_wip_txn_id
                                         AND    wta1.base_transaction_value < 0 ));
         ELSIF (p_txn_type = 2)  THEN

            l_stmt_num := 160;
            SELECT sum(base_transaction_value)
            INTO   l_wta_temp_value
            FROM   wip_transaction_accounts wta
            WHERE  transaction_id in (p_wip_txn_id)
            AND NOT ( cost_element_id = (SELECT MAX(cost_element_id)
                                         FROM   wip_transaction_accounts wta1
                                         WHERE  wta1.transaction_id = p_wip_txn_id
                                         AND    wta1.base_transaction_value > 0)
                                         AND    base_transaction_value > 0);

            l_stmt_num := 170;
            UPDATE wip_transaction_accounts wta
            SET    wta.base_transaction_value = -1*(l_wta_temp_value)
            WHERE  transaction_id in (p_wip_txn_id)
            AND    (base_transaction_value > 0
                    and cost_element_id=(SELECT MAX(cost_element_id)
                                         FROM   wip_transaction_accounts wta1
                                         WHERE  wta1.transaction_id = p_wip_txn_id));
         ELSIF p_txn_type in (4,6) THEN
            l_stmt_num := 180;
             SELECT  sum(base_transaction_value)
             INTO    l_wta_temp_value
             FROM    wip_transaction_accounts
             WHERE   transaction_id in (p_wip_txn_id)
             AND     base_transaction_value > 0;

            l_stmt_num := 190;
             UPDATE wip_transaction_accounts wta
             SET    base_transaction_value = -1 * (l_wta_temp_value)
             WHERE  wta.transaction_id = p_wip_txn_id
             AND    wta.cost_element_id is null;
         END IF; -- end handling different cases for different transaction types

      END IF; -- wta total sum

   EXCEPTION
       when others then
          -- rollback;
          p_err_num := SQLCODE;
          p_err_msg := 'CSTPSMUT.BALANCE_ACCOUNTING: ' || to_char (l_stmt_num) || ');';
          p_err_code := null;
END BALANCE_ACCOUNTING;  -- BALANCE_MTA

    PROCEDURE INSERT_MAT_TXN( p_date              IN DATE,
                              p_sm_txn_id         IN NUMBER,
			      p_mtl_txn_id        IN NUMBER,
			      p_acct_period_id    IN NUMBER,
			      p_txn_qty           IN NUMBER,
			      p_action_id         IN NUMBER,
			      p_source_type_id    IN NUMBER,
			      p_txn_type_name     IN VARCHAR2,
			      p_wip_entity_id     IN NUMBER,
			      p_operation_seq_num IN NUMBER,
                              p_user_id           IN NUMBER,
                              p_login_id          IN NUMBER,
                              p_request_id        IN NUMBER,
                              p_prog_appl_id      IN NUMBER,
                              p_program_id        IN NUMBER,
                              p_debug             IN VARCHAR2,
                              p_err_num		  IN OUT NOCOPY NUMBER,
                              p_err_code          IN OUT NOCOPY VARCHAR2,
                              p_err_msg           IN OUT NOCOPY VARCHAR2) IS

	  l_rows_inserted number;
          l_stmt_num number;


    BEGIN

          l_stmt_num := 5;
          p_err_num := 0;

          l_stmt_num := 10;
	  INSERT INTO mtl_material_transactions
	    (TRANSACTION_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
	     CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
	     PROGRAM_APPLICATION_ID, PROGRAM_ID,	PROGRAM_UPDATE_DATE,
	     INVENTORY_ITEM_ID, ORGANIZATION_ID, TRANSACTION_TYPE_ID,
	     TRANSACTION_ACTION_ID, TRANSACTION_SOURCE_TYPE_ID,
	     TRANSACTION_SOURCE_ID, TRANSACTION_SOURCE_NAME,
	     TRANSACTION_QUANTITY, TRANSACTION_UOM, PRIMARY_QUANTITY,
	     TRANSACTION_DATE, ACCT_PERIOD_ID, COSTED_FLAG, OPERATION_SEQ_NUM,
	     SOURCE_LINE_ID)
	  SELECT
	    	p_mtl_txn_id, sysdate, p_user_id, sysdate,
		p_user_id, p_login_id, p_request_id,
		p_prog_appl_id, p_program_id, sysdate,
		we.primary_item_id, we.organization_id, mtt.transaction_type_id,
		mtt.transaction_action_id, mtt.transaction_source_type_id,
		p_wip_entity_id, we.wip_entity_name,
		p_txn_qty, msi.primary_uom_code, p_txn_qty,
		p_date, p_acct_period_id, null, p_operation_seq_num,
		p_sm_txn_id
	  FROM
		mtl_transaction_types mtt,
		mtl_system_items msi,
		wip_entities we
	  WHERE we.wip_entity_id = p_wip_entity_id
	  AND we.primary_item_id = msi.inventory_item_id
	  AND we.organization_id = msi.organization_id
	  AND mtt.transaction_action_id = p_action_id
	  AND mtt.transaction_source_type_id = p_source_type_id
	  AND exists
	    ( SELECT null
		FROM mtl_transaction_accounts
		WHERE transaction_id = p_mtl_txn_id);

        l_rows_inserted := SQL%ROWCOUNT;

        IF (l_rows_inserted > 0 ) and (p_debug = 'Y') THEN
	  FND_FILE.put_line(FND_FILE.LOG,to_char(l_rows_inserted)
                            || ' row(s) inserted '
                            || 'into mtl_material_transactions.'
                            || ', mtl_txn_id: '
                            || p_mtl_txn_id
                            || ', action_id: '
                            || p_action_id
                            || ', wip_entity_id: '
                            || p_wip_entity_id);
	END IF;
        l_rows_inserted := 0;

    EXCEPTION
        when others then
           p_err_num := SQLCODE;
           p_err_msg := 'CSTPSMUT.INSERT_MAT_TXN: '
                           || to_char (l_stmt_num) || ');';
           p_err_code := null;
    END INSERT_MAT_TXN;

    PROCEDURE INSERT_WIP_TXN(   p_date              IN DATE,
				p_sm_txn_id         IN NUMBER,
				p_wip_txn_id        IN NUMBER,
				p_acct_period_id    IN NUMBER,
				p_wip_entity_id     IN NUMBER,
				p_operation_seq_num IN NUMBER,
                                p_lookup_code       IN NUMBER,
                                p_user_id           IN NUMBER,
                                p_login_id          IN NUMBER,
                                p_request_id        IN NUMBER,
                                p_prog_appl_id      IN NUMBER,
                                p_program_id        IN NUMBER,
                                p_debug             IN VARCHAR2,
                                p_err_num           IN OUT NOCOPY NUMBER,
                                p_err_code          IN OUT NOCOPY VARCHAR2,
                                p_err_msg           IN OUT NOCOPY VARCHAR2,
                                p_txn_id            IN NUMBER) IS -- Added for bug#4307365
	  l_rows_inserted number;
          l_stmt_num number;
          l_txn_uom VARCHAR2(3);
          l_pr_uom VARCHAR2(3);

    BEGIN
        p_err_num:= 0;

        l_stmt_num:= 10;

        SAVEPOINT insert_wip_txn;

        SELECT MMT.TRANSACTION_UOM, MSI.PRIMARY_UOM_CODE
        INTO   l_txn_uom, l_pr_uom
        FROM   MTL_SYSTEM_ITEMS MSI,
               MTL_MATERIAL_TRANSACTIONS MMT
        WHERE  MMT.TRANSACTION_ID = p_txn_id
        AND    MSI.INVENTORY_ITEM_ID = MMT.INVENTORY_ITEM_ID
        AND    MSI.ORGANIZATION_ID = MMT.ORGANIZATION_ID;

        INSERT INTO wip_transactions
	    (TRANSACTION_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
	     CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
	     REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID,
	     PROGRAM_UPDATE_DATE,
	     ORGANIZATION_ID, WIP_ENTITY_ID, ACCT_PERIOD_ID,
	     TRANSACTION_TYPE, TRANSACTION_DATE, OPERATION_SEQ_NUM,
	     SOURCE_LINE_ID, TRANSACTION_UOM, PRIMARY_UOM,
         --{BUG#7314513
	     primary_item_id
         --}
		  )
        SELECT
      		p_wip_txn_id, sysdate, p_user_id,
		sysdate, p_user_id, p_login_id,
		p_request_id, p_prog_appl_id, p_program_id,
		sysdate,
		we.organization_id, we.wip_entity_id, p_acct_period_id,
		p_lookup_code, p_date, p_operation_seq_num,
                p_sm_txn_id, l_txn_uom, l_pr_uom,
        we.primary_item_id
	  FROM  wip_entities we
	  WHERE we.wip_entity_id = p_wip_entity_id
	  AND exists
              ( SELECT null
                FROM   wip_transaction_accounts
		WHERE  transaction_id = p_wip_txn_id);

        l_rows_inserted := SQL%ROWCOUNT;
        IF (l_rows_inserted > 0 and p_debug = 'Y') THEN
           FND_FILE.put_line(FND_FILE.LOG,to_char(l_rows_inserted)
                             || ' row(s) inserted ' ||
		             'into wip_transactions.');
	END IF;
        l_rows_inserted := 0;

    EXCEPTION
       WHEN OTHERS THEN
         /* Changes for Bug #1877576. Using savepoint to prevent "Fetch out of
            sequence error */
         ROLLBACK TO insert_wip_txn;
          p_err_num := SQLCODE;
          p_err_msg := 'CSTPSMUT.INSERT_WIP_TXN: (' || to_char (l_stmt_num) || ');';
          p_err_code := null;
    END INSERT_WIP_TXN;

PROCEDURE INSERT_MTA(
            p_date            IN DATE,
            p_min_acct_unit   IN NUMBER,
            p_ext_prec        IN NUMBER,
            p_sm_txn_type     IN NUMBER,
            p_mtl_txn_id      IN NUMBER,
            p_org_id          IN NUMBER,
            p_wip_id          IN NUMBER,
            p_acct_ltype      IN NUMBER,
            p_txn_qty         IN NUMBER,
            p_tl_mtl_cost     IN NUMBER,
            p_tl_mto_cost     IN NUMBER,
            p_tl_res_cost     IN NUMBER,
            p_tl_ovh_cost     IN NUMBER,
            p_tl_osp_cost     IN NUMBER,
            p_cost_element_id IN NUMBER,
            p_user_id         IN NUMBER,
            p_login_id        IN NUMBER,
            p_request_id      IN NUMBER,
            p_prog_appl_id    IN NUMBER,
            p_program_id      IN NUMBER,
            p_debug           IN VARCHAR2,
            p_err_num         IN OUT NOCOPY NUMBER,
            p_err_code        IN OUT NOCOPY VARCHAR2,
            p_err_msg         IN OUT NOCOPY VARCHAR2) is

l_rows_inserted number := 0;
l_stmt_num number;

BEGIN

 l_stmt_num := 10;


  INSERT into mtl_transaction_accounts (
    TRANSACTION_ID,
    REFERENCE_ACCOUNT,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    TRANSACTION_DATE,
    TRANSACTION_SOURCE_ID,
    TRANSACTION_SOURCE_TYPE_ID,
    COST_ELEMENT_ID,
    ACCOUNTING_LINE_TYPE,
    CONTRA_SET_ID,
    BASE_TRANSACTION_VALUE,
    PRIMARY_QUANTITY)
  SELECT
    p_mtl_txn_id,
    DECODE(p_cost_element_id,
    1,dj.material_account,
    2,dj.material_overhead_account,
    3,dj.resource_account,
    4,dj.outside_processing_account,
    5,dj.overhead_account),
    sysdate,
    p_user_id, sysdate, p_user_id,
    p_login_id, p_request_id, p_prog_appl_id,
    p_program_id, sysdate, mmt.inventory_item_id,
    p_org_id, p_date, p_wip_id,
    5, p_cost_element_id, p_acct_ltype, 1,
    ROUND(DECODE(p_cost_element_id,
         1, p_tl_mtl_cost,
         2, p_tl_mto_cost,
         3, p_tl_res_cost,
         4, p_tl_osp_cost,
         5, p_tl_ovh_cost)/p_min_acct_unit) * p_min_acct_unit,
              p_txn_qty
    FROM  wip_discrete_jobs dj,
          mtl_material_transactions mmt
    WHERE dj.wip_entity_id   = p_wip_id
    AND   mmt.transaction_id = p_mtl_txn_id
    HAVING ROUND(DECODE(p_cost_element_id,
                   1, p_tl_mtl_cost,
                   2, p_tl_mto_cost,
                   3, p_tl_res_cost,
                   4, p_tl_osp_cost,
                   5, p_tl_ovh_cost)/p_min_acct_unit) * p_min_acct_unit <> 0;

  l_rows_inserted := l_rows_inserted + SQL%ROWCOUNT;

  /* R12 - Sub Ledger Unique Identifier */
  UPDATE MTL_TRANSACTION_ACCOUNTS
  SET    INV_SUB_LEDGER_ID = CST_INV_SUB_LEDGER_ID_S.NEXTVAL
  WHERE  TRANSACTION_ID   = p_mtl_txn_id;

  IF (l_rows_inserted > 0)  and (p_debug = 'Y')THEN
             FND_FILE.PUT_LINE(FND_FILE.LOG,to_char(l_rows_inserted)
                               || ' row(s) inserted '
                               || 'into mtl_transaction_accounts.'
                               || ',mtl_txn_id: '
                               || p_mtl_txn_id
                               || ', cost element id: '
                               || p_cost_element_id
                               );
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    p_err_num := SQLCODE;
    p_err_msg := 'CSTPSMUT.INSERT_MAT: ' || to_char (l_stmt_num) || ');';
    p_err_code := null;

END INSERT_MTA;

    PROCEDURE INSERT_MAT_TXN_ACCT(p_date          IN DATE,
                                  p_min_acct_unit IN NUMBER,
				  p_ext_prec      IN NUMBER,
				  p_sm_txn_type   IN NUMBER,
				  p_mtl_txn_id    IN NUMBER,
				  p_org_id        IN NUMBER,
				  p_wip_id        IN NUMBER,
				  p_acct_ltype    IN NUMBER,
                                  p_txn_qty       IN NUMBER,
				  p_tl_mtl_cost   IN NUMBER,
				  p_tl_mto_cost   IN NUMBER,
				  p_tl_res_cost   IN NUMBER,
				  p_tl_ovh_cost   IN NUMBER,
				  p_tl_osp_cost   IN NUMBER,
                                  p_user_id       IN NUMBER,
                                  p_login_id      IN NUMBER,
                                  p_request_id    IN NUMBER,
                                  p_prog_appl_id  IN NUMBER,
                                  p_program_id    IN NUMBER,
                                  p_debug         IN VARCHAR2,
                                  p_err_num       IN OUT NOCOPY NUMBER,
                                  p_err_code      IN OUT NOCOPY VARCHAR2,
                                  p_err_msg       IN OUT NOCOPY VARCHAR2) IS
          l_stmt_num number;
          l_acct_summary number;
          l_mta_row number;

          CURSOR c_elements IS
	  SELECT cost_element_id
	  FROM cst_cost_elements;
    BEGIN


      l_stmt_num := 5;
      p_err_num := 0;


      l_stmt_num := 10;
      FOR c1 IN c_elements LOOP

                  INSERT_MTA(p_date,
                         p_min_acct_unit,
                         p_ext_prec,
                         p_sm_txn_type,
                         p_mtl_txn_id,
                         p_org_id,
                         p_wip_id,
                         p_acct_ltype,
                         p_txn_qty,
                         p_tl_mtl_cost,
                         p_tl_mto_cost,
                         p_tl_res_cost,
                         p_tl_ovh_cost,
                         p_tl_osp_cost,
                         c1.cost_element_id,
                         p_user_id,
                         p_login_id,
                         p_request_id,
                         p_prog_appl_id,
                         p_program_id,
                         p_debug,
                         p_err_num,
                         p_err_code,
                         p_err_msg);

      END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
          --rollback;
          p_err_num := SQLCODE;
          p_err_msg := 'CSTPSMUT.INSERT_MAT_TXN_ACCT: ' || to_char (l_stmt_num) || ');';
          p_err_code := null;

    END INSERT_MAT_TXN_ACCT;

    PROCEDURE INSERT_WIP_TXN_ACCT (p_date          IN DATE,
                                   p_min_acct_unit IN NUMBER,
				   p_ext_prec      IN NUMBER,
				   p_sm_txn_id     IN NUMBER,
				   p_sm_txn_type   IN NUMBER,
			  	   p_wip_txn_id    IN NUMBER,
				   p_org_id        IN NUMBER,
				   p_wip_id        IN NUMBER,
				   p_acct_ltype    IN NUMBER,
                                   p_txn_qty       IN NUMBER,
				   p_pl_mtl_cost   IN NUMBER,
                                   p_pl_mto_cost   IN NUMBER,
                                   p_pl_res_cost   IN NUMBER,
                                   p_pl_ovh_cost   IN NUMBER,
                                   p_pl_osp_cost   IN NUMBER,
                                   p_user_id       IN NUMBER,
                                   p_login_id      IN NUMBER,
                                   p_request_id    IN NUMBER,
                                   p_prog_appl_id  IN NUMBER,
                                   p_program_id    IN NUMBER,
                                   p_debug         IN VARCHAR2,
                                   p_err_num       IN OUT NOCOPY NUMBER,
                                   p_err_code      IN OUT NOCOPY VARCHAR2,
                                   p_err_msg       IN OUT NOCOPY VARCHAR2) IS
        l_rows_inserted number := 0;
        l_stmt_num number;
	CURSOR c_elements IS
	SELECT cost_element_id
	FROM cst_cost_elements;
    BEGIN
       p_err_num := 0;
       l_stmt_num := 10;

      IF (p_debug = 'Y') THEN
         FND_FILE.put_line(FND_FILE.LOG,'CSTPSMUT.INSERT_WIP_TXN_ACCT: wip_txn_id: '|| p_wip_txn_id);
      END IF;

      FOR c1 IN c_elements LOOP
	INSERT INTO WIP_TRANSACTION_ACCOUNTS
	    (
	      TRANSACTION_ID, REFERENCE_ACCOUNT, LAST_UPDATE_DATE,
 	      LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,
	      LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_APPLICATION_ID,
	      PROGRAM_ID, PROGRAM_UPDATE_DATE, ORGANIZATION_ID,
	      TRANSACTION_DATE, WIP_ENTITY_ID, ACCOUNTING_LINE_TYPE,
	      BASE_TRANSACTION_VALUE, COST_ELEMENT_ID,
              PRIMARY_QUANTITY
   	    )
	  SELECT
            p_wip_txn_id,
	    DECODE(c1.cost_element_id,
		   1,dj.material_account,
		   2,dj.material_overhead_account,
		   3,dj.resource_account,
		   4,dj.outside_processing_account,
		   5,dj.overhead_account),
	    sysdate,
  	    p_user_id, sysdate, p_user_id,
	    p_login_id, p_request_id, p_prog_appl_id, p_program_id,
	    sysdate, p_org_id, p_date,
	    p_wip_id, p_acct_ltype,
	    ROUND(DECODE(c1.cost_element_id,
		 	 1,p_pl_mtl_cost,
			 2,p_pl_mto_cost,
			 3,p_pl_res_cost,
			 4,p_pl_osp_cost,
			 5,p_pl_ovh_cost)/p_min_acct_unit)*p_min_acct_unit,
	    c1.cost_element_id,
            p_txn_qty
	  FROM wip_discrete_jobs dj
	  WHERE dj.wip_entity_id = p_wip_id
	  HAVING ROUND(DECODE(c1.cost_element_id,
                         1,p_pl_mtl_cost,
                         2,p_pl_mto_cost,
                         3,p_pl_res_cost,
                         4,p_pl_osp_cost,
                         5,p_pl_ovh_cost)/p_min_acct_unit)*p_min_acct_unit <> 0;

         UPDATE WIP_TRANSACTION_ACCOUNTS
         SET    WIP_SUB_LEDGER_ID = CST_WIP_SUB_LEDGER_ID_S.NEXTVAL
         WHERE  TRANSACTION_ID   = p_wip_txn_id;
          l_rows_inserted := l_rows_inserted + SQL%ROWCOUNT;
        END LOOP;

        IF (l_rows_inserted > 0)  and (p_debug = 'Y') THEN
       	  FND_FILE.put_line(FND_FILE.LOG,to_char(l_rows_inserted)
                            || 'row(s) inserted '
                            || 'into wip_transaction_accounts.'
                            || ', wip_entity_id: '
                            || p_wip_id);
  	END IF;


       EXCEPTION
       when others then
          --rollback;
          p_err_num := SQLCODE;
          p_err_msg := 'CSTPSMUT.INSERT_WIP_TXN_ACCT: '
                       || to_char (l_stmt_num)
                       || '); ,'
                       || to_char(p_err_num);
          p_err_code := null;
          IF ( p_debug = 'Y' ) THEN
            fnd_file.put_line(fnd_file.log, 'Insert into MTA Failed: '||p_err_msg || substr(SQLERRM, 1, 250));
          END IF;
    END INSERT_WIP_TXN_ACCT;

    PROCEDURE BONUS_MAT_TXN_ACCT(p_date          IN DATE,
                                 p_ext_prec      IN NUMBER,
				 p_min_acct_unit IN NUMBER,
				 p_sm_txn_type   IN NUMBER,
				 p_sm_txn_id     IN NUMBER,
                                 p_mtl_txn_id    IN NUMBER,
                                 p_org_id        IN NUMBER,
                                 p_wip_id        IN NUMBER,
                                 p_acct_ltype    IN NUMBER,
                                 p_total_cost    IN NUMBER,
                                 p_user_id       IN NUMBER,
                                 p_login_id      IN NUMBER,
                                 p_request_id    IN NUMBER,
                                 p_prog_appl_id  IN NUMBER,
                                 p_program_id    IN NUMBER,
                                 p_debug         IN VARCHAR2,
                                 p_err_num       IN OUT NOCOPY NUMBER,
                                 p_err_code      IN OUT NOCOPY VARCHAR2,
                                 p_err_msg       IN OUT NOCOPY VARCHAR2) IS
      l_rows_inserted NUMBER;
      l_stmt_num NUMBER;

    BEGIN
      l_stmt_num := 10;
      p_err_num := 0;


      INSERT into mtl_transaction_accounts
               (
	        TRANSACTION_ID, REFERENCE_ACCOUNT, LAST_UPDATE_DATE,
                LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,
                LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_APPLICATION_ID,
                PROGRAM_ID, PROGRAM_UPDATE_DATE, INVENTORY_ITEM_ID,
                ORGANIZATION_ID, TRANSACTION_DATE, TRANSACTION_SOURCE_ID,
                TRANSACTION_SOURCE_TYPE_ID, COST_ELEMENT_ID,
                ACCOUNTING_LINE_TYPE, CONTRA_SET_ID, BASE_TRANSACTION_VALUE)
      SELECT
             p_mtl_txn_id,
	     bonus_acct_id,
             sysdate,
             p_user_id, sysdate, p_user_id,
             p_login_id, p_request_id, p_prog_appl_id,
             p_program_id, sysdate, primary_item_id,
             p_org_id, p_date, p_wip_id,
             5, NULL, p_acct_ltype, 1,
	     ROUND(p_total_cost/p_min_acct_unit)*p_min_acct_unit
          FROM  wsm_sm_resulting_jobs
          WHERE transaction_id = p_sm_txn_id
	  HAVING ROUND(p_total_cost/p_min_acct_unit)*p_min_acct_unit <> 0;
      l_rows_inserted := SQL%ROWCOUNT;

      UPDATE MTL_TRANSACTION_ACCOUNTS
      SET    INV_SUB_LEDGER_ID = CST_INV_SUB_LEDGER_ID_S.NEXTVAL
      WHERE  TRANSACTION_ID   = p_mtl_txn_id;

      IF (l_rows_inserted > 0 and p_debug = 'Y') THEN
          FND_FILE.put_line(FND_FILE.LOG,to_char(l_rows_inserted)
                            || ' row(s) inserted '
                            || 'into mtl_transaction_accounts '
                            || ', mtl_txn_id: '
                            || p_mtl_txn_id);
      END IF;

       EXCEPTION
       when others then
          --rollback;
          p_err_num := SQLCODE;
          p_err_msg := 'CSTPSMUT.BONUS_MAT_TXN_ACCT: ' || to_char (l_stmt_num) || ');';
          p_err_code := null;

    END BONUS_MAT_TXN_ACCT;

    PROCEDURE BONUS_WIP_TXN_ACCT(p_date          IN DATE,
				 p_ext_prec      IN NUMBER,
				 p_min_acct_unit IN NUMBER,
                                 p_sm_txn_id     IN NUMBER,
                                 p_sm_txn_type   IN NUMBER,
                                 p_wip_txn_id    IN NUMBER,
                                 p_org_id        IN NUMBER,
                                 p_wip_id        IN NUMBER,
                                 p_acct_ltype    IN NUMBER,
                                 p_total_cost    IN NUMBER,
                                 p_user_id       IN NUMBER,
                                 p_login_id      IN NUMBER,
                                 p_request_id    IN NUMBER,
                                 p_prog_appl_id  IN NUMBER,
                                 p_program_id    IN NUMBER,
                                 p_debug         IN VARCHAR2,
                                 p_err_num       IN OUT NOCOPY NUMBER,
                                 p_err_code      IN OUT NOCOPY VARCHAR2,
                                 p_err_msg       IN OUT NOCOPY VARCHAR2) IS

      l_rows_inserted NUMBER;
      l_stmt_num NUMBER;

    BEGIN
      l_stmt_num := 10;
      p_err_num := 0;


          INSERT INTO WIP_TRANSACTION_ACCOUNTS
            (
	      TRANSACTION_ID, REFERENCE_ACCOUNT, LAST_UPDATE_DATE,
              LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,
              LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_APPLICATION_ID,
              PROGRAM_ID, PROGRAM_UPDATE_DATE, ORGANIZATION_ID,
              TRANSACTION_DATE, WIP_ENTITY_ID, ACCOUNTING_LINE_TYPE,
              BASE_TRANSACTION_VALUE
            )
          SELECT p_wip_txn_id, res.bonus_acct_id, sysdate,
            p_user_id, sysdate, p_user_id,
            p_login_id, p_request_id, p_prog_appl_id, p_program_id,
            sysdate, p_org_id, p_date,
            p_wip_id, p_acct_ltype,
	    NVL(ROUND(p_total_cost/p_min_acct_unit)*p_min_acct_unit,0)
          FROM wsm_sm_resulting_jobs res
          WHERE res.transaction_id = p_sm_txn_id
	  HAVING NVL(ROUND(p_total_cost/p_min_acct_unit)*p_min_acct_unit,0) <> 0;

         UPDATE WIP_TRANSACTION_ACCOUNTS
         SET    WIP_SUB_LEDGER_ID = CST_WIP_SUB_LEDGER_ID_S.NEXTVAL
         WHERE  TRANSACTION_ID   = p_wip_txn_id;
	  l_rows_inserted := SQL%ROWCOUNT;
	  IF (l_rows_inserted > 0 and p_debug = 'Y') THEN
            FND_FILE.put_line(FND_FILE.LOG,to_char(l_rows_inserted) || 'row(s) inserted ' ||
                'into wip_transaction_accounts.');
          END IF;
    END BONUS_WIP_TXN_ACCT;



    PROCEDURE START_LOT (
			p_sl_mtl_txn_id IN NUMBER,
			p_sl_wip_txn_id IN NUMBER,
			p_sl_wip_id IN NUMBER,
			p_acct_period_id IN NUMBER,
                        p_user_id      IN NUMBER,
                        p_login_id     IN NUMBER,
                        p_request_id   IN NUMBER,
                        p_prog_appl_id IN NUMBER,
                        p_program_id   IN NUMBER,
                        p_err_num in OUT NOCOPY number,
                        p_err_code in OUT NOCOPY varchar2,
                        p_err_msg in OUT NOCOPY varchar2) IS
	  l_rows_inserted number := 0;
          l_stmt_num number;
    BEGIN
          p_err_num := 0;
          l_stmt_num := 10;
	  UPDATE wip_period_balances wpb
	  SET (	request_id, program_application_id, program_id,
                program_update_date, last_update_date, last_updated_by,
                last_update_login, pl_material_out, pl_material_overhead_out,
                pl_resource_out, pl_outside_processing_out,
		pl_overhead_out) = (
	  SELECT p_request_id, p_prog_appl_id, p_program_id,
		 sysdate, sysdate, p_user_id,
		 p_login_id,
		 nvl(wpb.pl_material_out, 0) +
			 nvl(SUM(DECODE(mta.cost_element_id,1,
				-mta.base_transaction_value, 0)), 0),
		 nvl(wpb.pl_material_overhead_out, 0) +
		 	 nvl(SUM(DECODE(mta.cost_element_id,2,
				-mta.base_transaction_value, 0)), 0),
	 	 nvl(wpb.pl_resource_out, 0) +
		 	 nvl(SUM(DECODE(mta.cost_element_id,3,
				-mta.base_transaction_value, 0)), 0),
		 nvl(wpb.pl_outside_processing_out, 0) +
	 	 	 nvl(SUM(DECODE(mta.cost_element_id,4,
				-mta.base_transaction_value, 0)), 0),
		 nvl(wpb.pl_overhead_out, 0) +
		 	 nvl(SUM(DECODE(mta.cost_element_id,5,
			 	-mta.base_transaction_value, 0)), 0)
	  FROM mtl_transaction_accounts mta
	  WHERE mta.transaction_id = p_sl_mtl_txn_id
          AND mta.transaction_source_id = p_sl_wip_id)
--	  AND mta.accounting_line_type <> 31)
	  WHERE wpb.wip_entity_id = p_sl_wip_id
	  AND wpb.acct_period_id = p_acct_period_id
          AND exists
            ( SELECT null
                FROM mtl_transaction_accounts
                WHERE transaction_id = p_sl_mtl_txn_id);

          l_rows_inserted := SQL%ROWCOUNT;
--	  dbms_output.put_line(to_char(l_rows_inserted) || 'row(s) updated ' ||
--	    'in wip_period_balances for starting lot from mtl txn acct');
	  l_rows_inserted := 0;

          l_stmt_num := 20;
	  UPDATE wip_period_balances wpb
	  SET (	request_id, program_application_id, program_id,
                program_update_date, last_update_date, last_updated_by,
                last_update_login, tl_material_out, tl_material_overhead_out,
                tl_resource_out, tl_outside_processing_out,
		tl_overhead_out ) =
	  ( SELECT p_request_id, p_prog_appl_id, p_program_id,
		   sysdate, sysdate, p_user_id,
		   p_login_id,
		   nvl(wpb.tl_material_out, 0) +
			nvl(SUM(DECODE(wta.cost_element_id,1,
					-wta.base_transaction_value, 0)), 0),
		   nvl(wpb.tl_material_overhead_out, 0) +
			nvl(SUM(DECODE(wta.cost_element_id,2,
				        -wta.base_transaction_value, 0)), 0),
		   nvl(wpb.tl_resource_out, 0) +
			nvl(SUM(DECODE(wta.cost_element_id,3,
				        -wta.base_transaction_value, 0)), 0),
		   nvl(wpb.tl_outside_processing_out, 0) +
			nvl(SUM(DECODE(wta.cost_element_id,4,
				        -wta.base_transaction_value, 0)), 0),
		   nvl(wpb.tl_overhead_out, 0) +
			nvl(SUM(DECODE(wta.cost_element_id,5,
				    	-wta.base_transaction_value, 0)), 0)
	    FROM wip_transaction_accounts wta
	    WHERE wta.transaction_id = p_sl_wip_txn_id
            AND wta.wip_entity_id = p_sl_wip_id)
--	    AND wta.accounting_line_type <> 31)
	 WHERE wpb.wip_entity_id = p_sl_wip_id
	 AND wpb.acct_period_id = p_acct_period_id
         AND exists
            ( SELECT null
                FROM wip_transaction_accounts
                WHERE transaction_id = p_sl_wip_txn_id);

        l_rows_inserted := SQL%ROWCOUNT;
--	dbms_output.put_line(to_char(l_rows_inserted) || 'row(s) updated ' ||
--	    'in wip_period_balances for starting lot from wip txn acct.');
	l_rows_inserted := 0;

EXCEPTION
	when others then
           --rollback;
           p_err_code:= null;
           p_err_num := SQLCODE;
           p_err_msg  := 'CSTPSMUT: START_LOT- '||l_stmt_num||'.'||SQLERRM;


    END START_LOT;
/*------------------------------------------------------------------
  Procedure: Result_lot

  This procedure updates WPB of the resulting lots.  It handles
  the *_in of the WPB, not *_outs.

-------------------------------------------------------------------*/

    PROCEDURE RESULT_LOT(
			p_rl_mtl_txn_id IN NUMBER,
			p_rl_wip_txn_id IN NUMBER,
			p_rl_wip_id IN NUMBER,
			p_acct_period_id IN NUMBER,
                        p_user_id      IN NUMBER,
                        p_login_id     IN NUMBER,
                        p_request_id   IN NUMBER,
                        p_prog_appl_id IN NUMBER,
                        p_program_id   IN NUMBER,
                        p_debug        IN VARCHAR2,
                        p_err_num in OUT NOCOPY number,
                        p_err_code in OUT NOCOPY varchar2,
                        p_err_msg in OUT NOCOPY varchar2) IS
	  l_rows_inserted number;
          l_stmt_num number;

    BEGIN

	  --
	  -- Update resulting lot period balances
	  --
          p_err_num := 0;
          l_stmt_num := 5;

          l_stmt_num := 10;

	  UPDATE wip_period_balances wpb
	  SET (	request_id, program_application_id, program_id,
                program_update_date, last_update_date, last_updated_by,
                last_update_login, pl_material_in, pl_material_overhead_in,
                pl_resource_in, pl_outside_processing_in,
		pl_overhead_in) = (
	  SELECT p_request_id, p_prog_appl_id, p_program_id,
		 sysdate, sysdate, p_user_id,
		 p_login_id,
		 nvl(wpb.pl_material_in, 0) +
			nvl(SUM(DECODE(mta.cost_element_id,1,
				  mta.base_transaction_value, 0)), 0),
		 nvl(wpb.pl_material_overhead_in, 0) +
			nvl(SUM(DECODE(mta.cost_element_id,2,
				  mta.base_transaction_value, 0)), 0),
		 nvl(wpb.pl_resource_in, 0) +
			nvl(SUM(DECODE(mta.cost_element_id,3,
				  mta.base_transaction_value, 0)), 0),
		 nvl(wpb.pl_outside_processing_in, 0) +
			nvl(SUM(DECODE(mta.cost_element_id,4,
				  mta.base_transaction_value, 0)), 0),
		 nvl(wpb.pl_overhead_in, 0) +
			nvl(SUM(DECODE(mta.cost_element_id,5,
				  mta.base_transaction_value, 0)), 0)
	  FROM mtl_transaction_accounts mta
	  WHERE mta.transaction_id = p_rl_mtl_txn_id
          AND mta.transaction_source_id = p_rl_wip_id)
      WHERE wpb.wip_entity_id = p_rl_wip_id
      AND wpb.acct_period_id = p_acct_period_id
      AND exists
            ( SELECT null
                FROM mtl_transaction_accounts
                WHERE transaction_id = p_rl_mtl_txn_id);

      l_rows_inserted := SQL%ROWCOUNT;
      IF (p_debug = 'Y') and (l_rows_inserted > 0)  THEN
         FND_FILE.put_line(FND_FILE.LOG,to_char(l_rows_inserted)
                           || ' row(s) updated '
                           || 'in wip_period_balances for mtl txn acct.');
      END IF;
      l_rows_inserted := 0;

      l_stmt_num := 20;
      UPDATE wip_period_balances wpb
      SET (	request_id, program_application_id, program_id,
                program_update_date, last_update_date, last_updated_by,
                last_update_login,
                tl_resource_in, tl_outside_processing_in,
		tl_overhead_in ) = (
      SELECT p_request_id, p_prog_appl_id, p_program_id,
	     sysdate, sysdate, p_user_id,
	     p_login_id,
	     nvl(wpb.tl_resource_in, 0) +
		nvl(SUM(DECODE(wta.cost_element_id,3,
			       wta.base_transaction_value, 0)), 0),
	     nvl(wpb.tl_outside_processing_in, 0) +
		nvl(SUM(DECODE(wta.cost_element_id,4,
			       wta.base_transaction_value, 0)), 0),
	     nvl(wpb.tl_overhead_in, 0) +
		nvl(SUM(DECODE(wta.cost_element_id,5,
			       wta.base_transaction_value, 0)), 0)
      FROM wip_transaction_accounts wta
      WHERE wta.transaction_id = p_rl_wip_txn_id
      AND   wta.wip_entity_id = p_rl_wip_id)
--      AND wta.accounting_line_type <> 31)
  WHERE wpb.wip_entity_id = p_rl_wip_id
  AND wpb.acct_period_id = p_acct_period_id
  AND exists
            ( SELECT null
                FROM wip_transaction_accounts
                WHERE transaction_id = p_rl_wip_txn_id);

  l_rows_inserted := SQL%ROWCOUNT;

  IF (p_debug = 'Y') and (l_rows_inserted > 0 ) THEN
      FND_FILE.put_line(FND_FILE.log,to_char(l_rows_inserted)
                        || ' row(s) updated '
                        || 'in wip_period_balances for wip txn acct.');
  END IF;
  l_rows_inserted := 0;
EXCEPTION
	when others then
           --rollback;
           p_err_code:= null;
           p_err_num := SQLCODE;
           p_err_msg  := 'CSTPSMUT: RESULT_LOT- '||l_stmt_num||'.'||SQLERRM;


 END RESULT_LOT;

END CSTPSMUT;

/
