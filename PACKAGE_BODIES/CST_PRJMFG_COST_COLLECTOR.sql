--------------------------------------------------------
--  DDL for Package Body CST_PRJMFG_COST_COLLECTOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_PRJMFG_COST_COLLECTOR" as
/* $Header: CSTPPCCB.pls 120.17.12010000.11 2010/04/13 00:09:44 ipineda ship $*/

/*----------------------------------------------------------------------------*
 |  PRIVATE FUNCTION/PROCEDURES                                               |
 *----------------------------------------------------------------------------*/

  PROCEDURE  pm_process_txn_mmt (
                                 p_Group_Id                     NUMBER,
                                 p_transaction_id                NUMBER,
                                 p_organization_id                NUMBER,
                                 p_transaction_action_id        NUMBER,
                                 p_transaction_source_type_id        NUMBER,
                                 p_type_class                        NUMBER,
                                 p_project_id                        NUMBER,
                                 p_task_id                        NUMBER,
                                 p_transaction_date                DATE,
                                 p_primary_quantity                NUMBER,
                                 p_expenditure_type                VARCHAR2,
                                 p_item_description                VARCHAR2,
                                 p_cost_group_id                NUMBER,
                                 p_transfer_cost_group_id        NUMBER,
                                 p_inventory_item_id                NUMBER,
                                 p_transaction_source_id        NUMBER,
                                 p_to_project_id                NUMBER,
                                 p_to_task_id                        NUMBER,
                                 p_source_project_id                NUMBER,
                                 p_source_task_id                NUMBER,
                                 p_transfer_transaction_id        NUMBER,
                                 p_primary_cost_method                NUMBER,
                                 p_std_cg_acct                  NUMBER, -- Added for bug 3495967
                                 p_acct_period_id                NUMBER,
                                 p_exp_org_id                        NUMBER,
                                 p_distribution_account_id        NUMBER,
                                 p_proj_job_ind                        NUMBER,
                                 p_first_matl_se_exp_type        VARCHAR2,
                                 p_inv_txn_source_literal        VARCHAR2,
                                 p_cap_txn_source_literal        VARCHAR2,
                                 p_inv_syslink_literal                VARCHAR2,
                                 p_bur_syslink_literal                VARCHAR2,
                                 p_wip_syslink_literal                VARCHAR2,
                                 p_user_def_exp_type            NUMBER,
                                 O_err_num                  OUT        NOCOPY NUMBER,
                                 O_err_code                  OUT        NOCOPY VARCHAR2,
                                 O_err_msg                  OUT        NOCOPY VARCHAR2,
                                 p_transfer_organization_id     NUMBER,
                                 p_flow_schedule                VARCHAR2,
                                 p_si_asset_yes_no                NUMBER,
                                 p_transfer_si_asset_yes_no        NUMBER,
                                 p_denom_currency_code          VARCHAR2);

  PROCEDURE  pm_check_error_mmt (
                                 p_transaction_id               NUMBER,
                                 p_organization_id                NUMBER,
                                 p_cost_method                        NUMBER,
                                 p_inventory_item_id                NUMBER,
                                 p_avg_rates_cost_type_id        NUMBER,
                                 p_transaction_action_id        NUMBER,
                                 p_transaction_source_type_id        NUMBER,
                                 p_type_class                        NUMBER,
                                 p_project_id                        NUMBER,
                                 p_task_id                        NUMBER,
                                 p_to_project_id                NUMBER,
                                 p_to_task_id                        NUMBER,
                                 p_source_project_id                NUMBER,
                                 p_source_task_id                NUMBER,
                                 p_transaction_source_id        NUMBER,
                                 p_proj_job_ind                   OUT         NOCOPY NUMBER,
                                 p_process_yn                   OUT         NOCOPY NUMBER,
                                 p_first_matl_se_exp_type  OUT         NOCOPY VARCHAR2,
                                 p_user_id                        NUMBER,
                                 p_login_id                        NUMBER,
                                 p_req_id                        NUMBER,
                                 p_prg_appl_id                         NUMBER,
                                 p_prg_id                         NUMBER,
                                 O_err_num                   OUT        NOCOPY NUMBER,
                                 O_err_code                   OUT        NOCOPY VARCHAR2,
                                 O_err_msg                   OUT        NOCOPY VARCHAR2,
                                 p_flow_schedule                VARCHAR2,
                                 p_cost_group_id                NUMBER);

  PROCEDURE pm_mark_error_mmt (
                                p_transaction_id        NUMBER,
                                p_error_code                VARCHAR2,
                                p_error_explanation        VARCHAR2,
                                p_user_id                NUMBER,
                                p_login_id                NUMBER,
                                p_req_id                NUMBER,
                                p_prg_appl_id                 NUMBER,
                                p_prg_id                 NUMBER,
                                O_err_num            OUT        NOCOPY NUMBER,
                                O_err_code            OUT        NOCOPY VARCHAR2,
                                O_err_msg            OUT        NOCOPY VARCHAR2);


  PROCEDURE  pm_process_txn_wt (
                                p_Group_Id                      NUMBER,
                                p_business_group_name           VARCHAR2,
                                p_transaction_id                NUMBER,
                                p_organization_id                NUMBER,
                                p_employee_number                VARCHAR2,
                                p_department_id                        NUMBER,
                                p_project_id                        NUMBER,
                                p_task_id                        NUMBER,
                                p_transaction_date                DATE,
                                p_base_transaction_value        NUMBER,
                                p_primary_quantity                NUMBER,
                                p_acct_period_id                NUMBER,
                                p_expenditure_type                VARCHAR2,
                                p_resource_description                VARCHAR2,
                                p_wt_transaction_type                NUMBER,
                                p_cost_element_id                NUMBER,
                                p_exp_org_name                        VARCHAR2,
                                p_wip_txn_source_literal        VARCHAR2,
                                p_wip_straight_time_literal     VARCHAR2,
                                p_wip_syslink_literal                VARCHAR2,
                                p_bur_syslink_literal                VARCHAR2,
                                O_err_num                 OUT        NOCOPY NUMBER,
                                O_err_code                 OUT        NOCOPY VARCHAR2,
                                O_err_msg                 OUT        NOCOPY VARCHAR2,
                                p_reference_account                NUMBER,
                                p_cr_account                        NUMBER,
                                p_wip_dr_sub_ledger_id              NUMBER,
                                p_wip_cr_sub_ledger_id              NUMBER,
                                p_wip_entity_id                        NUMBER,
                                p_resource_id                        NUMBER,
                                p_basis_resource_id                NUMBER,
                                p_denom_currency_code           VARCHAR2);

  PROCEDURE  pm_check_error_wt (
                                p_transaction_id                NUMBER,
                                     p_project_id                        NUMBER,
                                     p_task_id                        NUMBER,
                                     p_expenditure_type                VARCHAR2,
                                     p_organization_id                NUMBER,
                                     p_department_id                        NUMBER,
                                     p_employee_number                VARCHAR2,
                                     p_exp_org_name               OUT        NOCOPY VARCHAR2,
                                     p_process_yn                 OUT         NOCOPY NUMBER,
                                p_user_id                        NUMBER,
                                p_login_id                        NUMBER,
                                p_req_id                        NUMBER,
                                p_prg_appl_id                         NUMBER,
                                p_prg_id                         NUMBER,
                                     O_err_num                 OUT        NOCOPY NUMBER,
                                     O_err_code                 OUT        NOCOPY VARCHAR2,
                                     O_err_msg                 OUT        NOCOPY VARCHAR2);

  PROCEDURE  pm_mark_error_wt (
                                p_transaction_id                NUMBER,
                                p_error_code                        VARCHAR2,
                                p_error_explanation                VARCHAR2,
                                p_user_id                        NUMBER,
                                p_login_id                        NUMBER,
                                p_req_id                        NUMBER,
                                p_prg_appl_id                         NUMBER,
                                p_prg_id                         NUMBER,
                                     O_err_num                 OUT        NOCOPY NUMBER,
                                     O_err_code                 OUT        NOCOPY VARCHAR2,
                                     O_err_msg                 OUT        NOCOPY VARCHAR2);

  PROCEDURE  pm_insert_pti_pvt
                  (p_transaction_source                        VARCHAR2,
                      p_batch_name                                VARCHAR2,
                      p_expenditure_ending_date                DATE,
                      p_employee_number                        VARCHAR2,
                      p_organization_name                        VARCHAR2,
                      p_expenditure_item_date                DATE,
                      p_project_number                        VARCHAR2,
                      p_task_number                        VARCHAR2,
                      p_expenditure_type                        VARCHAR2,
                      p_pa_quantity                        NUMBER,
                      p_raw_cost                                NUMBER,
                      p_expenditure_comment                VARCHAR2,
                      p_orig_transaction_reference                VARCHAR2,
                      p_raw_cost_rate                        NUMBER,
                      p_unmatched_negative_txn_flag        VARCHAR2,
                      p_gl_date                                DATE,
                   p_org_id                                NUMBER,
                   p_burdened_cost                        NUMBER,
                   p_burdened_cost_rate                        NUMBER,
                   p_system_linkage                        VARCHAR2,
                   p_transaction_status_code                VARCHAR2,
                   p_denom_currency_code                VARCHAR2,

                   p_transaction_id                     NUMBER,
                   p_transaction_action_id              NUMBER,
                   p_transaction_source_type_id         NUMBER,
                   p_organization_id                    NUMBER,
                   p_inventory_item_id                  NUMBER,
                   p_cost_element_id                    NUMBER,
                   p_resource_id                        NUMBER,
                   p_source_flag                        NUMBER,
                   p_variance_flag                      NUMBER,
                   p_primary_quantity                   NUMBER,
                   p_transfer_organization_id           NUMBER,
                   p_fob_point                          NUMBER,
                   p_wip_entity_id                      NUMBER,
                   p_basis_resource                     NUMBER,

                   p_type_class                         NUMBER,
                   p_project_id                         NUMBER,
                   p_task_id                            NUMBER,
                   p_transaction_date                   DATE,
                   p_cost_group_id                      NUMBER,
                   p_transfer_cost_group_id             NUMBER,
                   p_transaction_source_id              NUMBER,
                   p_to_project_id                        NUMBER,
                   p_to_task_id                         NUMBER,
                   p_source_project_id                  NUMBER,
                   p_source_task_id                     NUMBER,
                   p_transfer_transaction_id            NUMBER,
                   p_primary_cost_method                NUMBER,
                   p_acct_period_id                     NUMBER,
                   p_exp_org_id                         NUMBER,
                   p_distribution_account_id            NUMBER,
                   p_proj_job_ind                       NUMBER,
                   p_first_matl_se_exp_type             VARCHAR2,
                   p_inv_txn_source_literal             VARCHAR2,
                   p_cap_txn_source_literal             VARCHAR2,
                   p_inv_syslink_literal                VARCHAR2,
                   p_bur_syslink_literal                VARCHAR2,
                   p_wip_syslink_literal                VARCHAR2,
                   p_user_def_exp_type                  VARCHAR2,
                   p_flow_schedule                      VARCHAR2,
                   p_si_asset_yes_no                    NUMBER,
                   p_transfer_si_asset_yes_no           NUMBER,

                   O_err_num                  OUT       NOCOPY NUMBER,
                   O_err_code                 OUT       NOCOPY VARCHAR2,
                   O_err_msg                  OUT       NOCOPY VARCHAR2
                  );

/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    pm_mark_non_project_world_txns                                          |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This procedure would mark all non-project world transactions as Cost    |
 |    Collected for the Given Organization and Upto the Given Date.           |
 |                                                                            |
 |    For MMT trasactions, all transactions that are not selected by the view |
 |    'cst_pm_matl_txn_v' and satisfy the date and org criteria are marked as |
 |    cost collected with no exception.                                       |
 |                                                                            |
 |    For WIP trasactions, transactions falling into either of these category |
 |    are marked as cost collected.                                           |
 |    -- All wip transaction records that refer to a non-project costed job   |
 |    -- All wt records with transaction type as other than (1,2,3) and refer |
 |       to a project costed job                                              |
 |    -- All wt records with transaction type as (1,2,3) but have no records  |
 |       in WTA because their standard_rate_flag was 2 and auto_charge_type as|
 |       any thing other than manual resulting in the resource having no cost.|
 |    -- All ipv transfer transactions (source_code = 'IPV'                   |
 |                                                                            |
 | PARAMETERS                                                                 |
 |       Organization_Id,                                                     |
 |       UpToDate,                                                            |
 |       p_user_id,                                                           |
 |       p_login_id,                                                          |
 |       p_req_id,                                                            |
 |       p_prg_appl_id,                                                       |
 |       p_prg_id,                                                            |
 |       O_err_num,                                                              |
 |       O_err_code,                                                          |
 |       O_err_msg                                                               */

PROCEDURE pm_mark_non_project_world_txns (
          p_Org_Id      NUMBER,
          p_prior_days  NUMBER,
          p_user_id     NUMBER,
          p_login_id    NUMBER,
          p_req_id      NUMBER,
          p_prg_appl_id NUMBER,
          p_prg_id      NUMBER,
          O_err_num     OUT     NOCOPY NUMBER,
          O_err_code    OUT     NOCOPY VARCHAR2,
          O_err_msg     OUT     NOCOPY VARCHAR2)
IS

l_err_num                NUMBER;
l_err_code               VARCHAR2(240);
l_err_msg                VARCHAR2(240);
l_stmt_num               NUMBER;
l_return_status  VARCHAR2(1);
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(30);

l_primary_cost_method  NUMBER;
l_std_cg_acct            NUMBER;
l_debug                  VARCHAR2(80);

CST_FAILED_STD_CG_FLAG EXCEPTION;

BEGIN
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
        l_stmt_num := 5;

        l_debug := FND_PROFILE.VALUE('MRP_DEBUG');
  if (l_debug = 'Y') then
    FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Reached#: pm_mark_non_project_world_txns');
        end if;

-- The query is to mark all non-project world txns satisfying the
-- arguments provided, as processed.

------------------------------------------------------------------
-- Mark all transactions as NULL for non-CG ACCT Std Organizations
-- Except the Proj Misc Txns.
------------------------------------------------------------------

  l_stmt_num := 10;

  SELECT  mp.primary_cost_method
  INTO    l_primary_cost_method
  FROM    mtl_parameters mp
  WHERE   mp.organization_id = p_org_id;

  l_stmt_num := 15;

  CST_Utility_Pub.GET_STD_CG_ACCT_FLAG
                           (p_api_version        =>  1.0,
                            p_organization_id    =>  p_org_id,
                            x_cg_acct_flag       =>  l_std_cg_acct,
                            x_return_status      =>  l_return_status,
                            x_msg_count          =>  l_msg_count,
                            x_msg_data           =>  l_msg_data );

  IF (l_return_status = FND_API.G_RET_STS_ERROR OR
      l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE CST_FAILED_STD_CG_FLAG;
  END IF;

  IF (l_primary_cost_method = 1 AND l_std_cg_acct <> 1) THEN
        ------------------------------------------------------------------
        -- Logical Expense Requisition Receipts are an Exception
        -- These are cost collected regardless of whether the organization
        -- is PJM enabled
        ------------------------------------------------------------------
    l_stmt_num := 20;

    UPDATE mtl_material_transactions mmt
    SET mmt.pm_cost_collected      = NULL,
        mmt.last_update_date       = sysdate,
              mmt.last_updated_by        = p_user_id,
              mmt.last_update_login      = p_login_id,
              mmt.request_id             = p_req_id,
              mmt.program_application_id = p_prg_appl_id,
              mmt.program_id             = p_prg_id,
        mmt.program_update_date    = sysdate
    WHERE NOT EXISTS
        ( SELECT NULL
                      FROM mtl_transaction_types mtt
                      WHERE mtt.type_class = 1
          AND   mtt.transaction_type_id = mmt.transaction_type_id )
          AND   mmt.organization_id = p_Org_Id
          AND   mmt.transaction_date <= ((trunc(sysdate) - p_prior_days) + 0.99999)
          AND   mmt.costed_flag is NULL
          AND   mmt.pm_cost_collected = 'N'
          AND   mmt.transaction_action_id <> 17; -- See Note about exception above
  ELSE

   l_stmt_num := 25;

   UPDATE mtl_material_transactions mmt
   SET mmt.pm_cost_collected      = NULL,
       mmt.last_update_date       = sysdate,
             mmt.last_updated_by        = p_user_id,
             mmt.last_update_login      = p_login_id,
             mmt.request_id             = p_req_id,
             mmt.program_application_id = p_prg_appl_id,
             mmt.program_id             = p_prg_id,
       mmt.program_update_date    = sysdate
   WHERE NOT EXISTS
       ( SELECT NULL
                     FROM cst_pm_matl_txn_v cpmtv
                     WHERE cpmtv.transaction_id = mmt.transaction_id )
         AND mmt.organization_id = p_Org_Id
         AND mmt.transaction_date <= ((trunc(sysdate) - p_prior_days) + 0.99999)
         AND mmt.costed_flag is NULL
         AND mmt.pm_cost_collected = 'N';

  END IF;

  if (l_debug = 'Y') then
    FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: NP Count MMT is #: '||to_char(SQL%ROWCOUNT) );
  end if;

       /* Changes for consigned inventory */
       /* Mark all transactions not owned by the current org as cost collected */

  l_stmt_num := 30;

  UPDATE
    mtl_material_transactions mmt
  SET mmt.pm_cost_collected = NULL,
      mmt.last_update_date = sysdate,
      mmt.last_updated_by = p_user_id,
      mmt.last_update_login = p_login_id,
      mmt.request_id = p_req_id,
      mmt.program_application_id = p_prg_appl_id,
      mmt.program_id = p_prg_id,
      mmt.program_update_date = sysdate
  WHERE
  (
    mmt.organization_id <> nvl(mmt.owning_organization_id, mmt.organization_id)
    OR nvl(mmt.owning_tp_type, 2) <> 2
  )
  AND mmt.pm_cost_collected = 'N'
  AND mmt.organization_id = p_Org_Id
  AND mmt.transaction_date <= ((trunc(sysdate) - p_prior_days) + 0.99999)
  AND mmt.costed_flag is null;

  if (l_debug = 'Y') then
     FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Count of consigned txns in MMT - no cost collection -  is #: '||to_char(SQL%ROWCOUNT) );
  end if;

  l_stmt_num := 35;

/*     changes to support PJM Blue Print organizations.All logical transactions  */
/*     except Logical PO receipt in the case of a true ship case will be set to  */
/*     cost collected. Retroactive price updates will laso be set as cost  */
/*     collected  */

  UPDATE
    mtl_material_transactions mmt
  SET mmt.pm_cost_collected = NULL,
    mmt.last_update_date = sysdate,
    mmt.last_updated_by = p_user_id,
    mmt.last_update_login = p_login_id,
    mmt.request_id = p_req_id,
    mmt.program_application_id = p_prg_appl_id,
    mmt.program_id = p_prg_id,
    mmt.program_update_date = sysdate
  WHERE mmt.pm_cost_collected = 'N'
  AND mmt.organization_id = p_org_id
  AND mmt.transaction_date <= ((trunc(sysdate) - p_prior_days) + 0.99999)
  AND mmt.costed_flag is null
  AND
  (
    (
      (
        NVL(mmt.logical_transaction,2) = 1
      )
      AND NOT ( MMT.TRANSACTION_TYPE_ID = 19
      AND MMT.TRANSACTION_ACTION_ID = 26
      AND MMT.TRANSACTION_SOURCE_TYPE_ID = 1
      AND NVL(MMT.LOGICAL_TRX_TYPE_CODE,5) = 2
      AND EXISTS
      (
      SELECT
        1
      FROM rcv_transactions rcv
      WHERE rcv.transaction_id = NVL(mmt.rcv_transaction_id,-9999)
        AND rcv.organization_id = p_org_id
      )
      )
      AND NOT (mmt.transaction_action_id = 17 and mmt.transaction_source_type_id = 7) /*Bug 7120525*/
    )
    OR NVL(mmt.logical_trx_type_code,5) = 4
  );

  if (l_debug = 'Y') then
    FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Count of logical txns or retroactive price updates in MMT - no cost collection -  is #: '||to_char(SQL%ROWCOUNT) );
  end if;


  l_stmt_num := 40;

/*    Bug # 589460  PJM AUTO TASK API  */
/*    Check WIP Transactions Table for Prj/Tsk Ref Rather than the Job Header  */
  UPDATE
    wip_transactions wt
    SET wt.pm_cost_collected = NULL,
    wt.last_update_date = sysdate,
    wt.last_updated_by = p_user_id,
    wt.last_update_login = p_login_id,
    wt.request_id = p_req_id,
    wt.program_application_id = p_prg_appl_id,
    wt.program_id = p_prg_id,
    wt.program_update_date = sysdate
  WHERE wt.organization_id = p_Org_Id
  AND wt.transaction_date <= ((trunc(sysdate) - p_prior_days) + 0.99999)
  AND wt.pm_cost_collected = 'N'
  AND
  (
    (
      NOT wt.transaction_type in (1,2,3,17)
      AND wt.project_id IS NOT NULL
    )
    OR wt.project_id IS NULL
    OR
    (
      wt.transaction_type in (1,2,3)
      AND NOT EXISTS
      (
      SELECT
        NULL
      FROM wip_transaction_accounts wta
      WHERE wta.transaction_id = wt.transaction_id
      )
    )
    OR wt.source_code = 'IPV' -- Bug 2130771
  );



EXCEPTION
  WHEN CST_FAILED_STD_CG_FLAG THEN
    rollback;
    O_err_num := 2001;
    O_err_code := 'Failed CST_UTILITY_PUB.GET_STD_CG_ACCT_FLAG()'
                                ||' Organization_Id: '
                                ||p_org_id;
    O_err_msg := 'CSTPPCCB.pm_mark_non_project_world_txns('
                                || to_char(l_stmt_num)
                                || '): ';
        WHEN OTHERS THEN
                rollback;
                O_err_num := SQLCODE;
                O_err_code := NULL;
                O_err_msg := 'CSTPPCCB.pm_mark_non_project_world_txns('
                                || to_char(l_stmt_num)
                                || '): '
                                || substr(SQLERRM,1,200);
END pm_mark_non_project_world_txns;

/*----------------------------------------------------------------------------*
 | PRIVATE PROCEDURE                                                          |
 |       assign_groups_to_mmt_txns                                            |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This procedure would for every record selected from the view, update the|
 |    MMT record to assign a group_id. The number of records to be updated is |
 |    determined by the user_spec_group_size.                                 |
 |                                                                            |
 |    Every Transaction that satisfies the conditions mentioned below gets    |
 |    a group id assigned to itself.                                          |
 |                                                                            |
 |    - All Project related transactions from the Project World               |
 |                                                                            |
 |    - All Project related transactions from the Non-Proj World              |
 |      - Select Txns: Capital Projects related txns in the NPW               |
 |      - Select Txns: Component Issue to Project Job from a NPW              |
 |      - Select Txns: Component Return from Project Job to NPW               |
 |                                                                            |
 |    - Ensure that the transaction has not yet got any group assigned        |
 |                                                                            |
 |    - Ensure that the transaction took place before the Date upto which the |
 |      Cost Collection was desired                                           |
 |                                                                            |
 |    - Ensure that the transaction took place in the Org for which the cost  |
 |      Cost Collection was desired                                           |
 |                                                                            |
 | PARAMETERS                                                                 |
 |      p_Org_Id,                                                             |
 |      p_prior_days,                                                          |
 |      p_user_spec_group_size,                                               |
 |      p_rows_processed,                                                      |
 |      p_group_id OUT,                                                       |
 |      p_user_id,                                                            |
 |      p_login_id,                                                           |
 |      p_req_id,                                                             |
 |      p_prg_appl_id,                                                        |
 |      p_prg_id,                                                             |
 |      p_proj_misc_txn_only,                                                 |
 |      O_err_num,                                                              |
 |      O_err_code,                                                           |
 |      O_err_msg                                                             |
 |                                                                            |
 | HISTORY                                                                    |
 |    07-SEP-96  Bhaskar Dasari Created.                                      |
 *----------------------------------------------------------------------------*/
  PROCEDURE assign_groups_to_mmt_txns ( p_Org_Id                NUMBER,
                                        p_prior_days            NUMBER,
                                        p_user_spec_group_size        NUMBER,
                                        p_rows_processed OUT        NOCOPY NUMBER,
                                        p_group_id         OUT        NOCOPY NUMBER,
                                        p_user_id                NUMBER,
                                        p_login_id                NUMBER,
                                        p_req_id                NUMBER,
                                        p_prg_appl_id                 NUMBER,
                                        p_prg_id                 NUMBER,
                                        p_proj_misc_txn_only        NUMBER,
                                        O_err_num        OUT        NOCOPY NUMBER,
                                        O_err_code        OUT        NOCOPY VARCHAR2,
                                        O_err_msg        OUT        NOCOPY VARCHAR2)
  IS

  CURSOR sel_mmt_trx (c_Org_Id               NUMBER,
                      c_prior_days           NUMBER,
                      c_proj_misc_txn_only   NUMBER,
                      c_user_spec_group_size NUMBER) IS
         SELECT  NULL
           FROM  mtl_material_transactions mmt
          WHERE  mmt.transaction_id  in (
                  SELECT  cpmtv.transaction_id
                    FROM  cst_pm_matl_txn_v cpmtv
                   WHERE  cpmtv.organization_id = c_Org_Id
                     AND  cpmtv.transaction_date <=
                                ((trunc(sysdate) - c_prior_days) + 0.99999)
                     AND  cpmtv.pm_cost_collector_group_id is NULL
                     AND  rownum <= c_user_spec_group_size
                     AND ( cpmtv.type_class =  decode(c_proj_misc_txn_only,1,1,cpmtv.type_class)
                           OR cpmtv.transaction_action_id=17)
                )
            FOR UPDATE OF mmt.pm_cost_collected NOWAIT;
  l_err_num             NUMBER;
  l_err_code            VARCHAR2(240);
  l_err_msg             VARCHAR2(240);
  l_stmt_num            NUMBER;
  l_rows                NUMBER;
  l_debug               VARCHAR2(80);
  BEGIN
        -- initialize local variables
        l_err_num := 0;
        l_err_code := '';
        l_err_msg := '';
        p_rows_processed := 0;
        l_stmt_num := 1;

        l_debug := FND_PROFILE.VALUE('MRP_DEBUG');
        if (l_debug = 'Y') then
            FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Reached#: assign_groups_to_mmt_txns');
        end if;


        l_stmt_num := 10;

        SELECT mtl_material_transactions_s.nextval
          INTO p_group_id
          FROM dual;

        l_stmt_num := 20;

        FOR sel_mmt_rec IN sel_mmt_trx( p_Org_Id,
                                        p_prior_days,
                                        p_proj_misc_txn_only,
                                        p_user_spec_group_size) LOOP


        UPDATE  mtl_material_transactions mmt
           SET  mmt.pm_cost_collector_group_id = p_group_id,
                mmt.last_update_date            = sysdate,
                mmt.last_updated_by        = p_user_id,
                mmt.last_update_login      = p_login_id,
                mmt.request_id             = p_req_id,
                mmt.program_application_id = p_prg_appl_id,
                mmt.program_id             = p_prg_id,
                mmt.program_update_date    = sysdate
         WHERE  current of sel_mmt_trx;


        p_rows_processed := sel_mmt_trx%ROWCOUNT;
        l_rows := sel_mmt_trx%ROWCOUNT;

        END LOOP;


  EXCEPTION
        WHEN OTHERS THEN
                rollback;
                O_err_num := SQLCODE;
                O_err_code := NULL;
                O_err_msg := 'CSTPPCCB.assign_groups_to_mmt_txns('
                                || to_char(l_stmt_num)
                                || '): '
                                || substr(SQLERRM,1,200);
  END assign_groups_to_mmt_txns;
/*----------------------------------------------------------------------------*
 | PRIVATE PROCEDURE                                                          |
 |    pm_cc_worker_mmt                                                        |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This procedure would Cost Collect the given transaction id. The code    |
 |    would check if the transaction is with errors. If none, the code would  |
 |    to make a call to a procedure that would process the transaction. On    |
 |    successful return from the process_txn procedure, the transaction being |
 |    is flagged as successfully cost collected by marking the flag           |
 |    'pm_cost_collected' as NULL.                                            |
 |                                                                            |
 | PARAMETERS                                                                 |
 |      Transaction_id                                                        |
 |      Org_id                                                                   |
 |      p_std_cg_acct    Added for bug 3495967                                |
 |      p_inv_txn_source_literal                                              |
 |      p_cap_txn_source_literal                                              |
 |      p_inv_syslink_literal                                                 |
 |      p_bur_syslink_literal                                                 |
 |      p_wip_syslink_literal                                                 |
 |      p_user_id,                                                            |
 |      p_user_def_exp_type                                                   |
 |      p_login_id,                                                           |
 |      p_req_id,                                                             |
 |      p_prg_appl_id,                                                        |
 |      p_prg_id,                                                             |
 |      O_err_num,                                                              |
 |      O_err_code,                                                           |
 |      O_err_msg                                                             |
 |                                                                            |
 | HISTORY                                                                    |
 |    07-SEP-96  Bhaskar Dasari Created.                                      |
 |                                                                            |
 |    30-JUL-97  Hemant Gosain Modified to pass transfer_organization_id      |
 |               so that fob point can be determined to pass accounting info  |
 |               to Projects.                                                 |
 *----------------------------------------------------------------------------*/
  PROCEDURE pm_cc_worker_mmt (
                                p_transaction_id                NUMBER,
                                p_Org_Id                        NUMBER,
                                p_std_cg_acct                   NUMBER, -- Added for bug 3495967
                                p_inv_txn_source_literal        VARCHAR2,
                                p_cap_txn_source_literal        VARCHAR2,
                                p_inv_syslink_literal                VARCHAR2,
                                p_bur_syslink_literal                VARCHAR2,
                                p_wip_syslink_literal                VARCHAR2,
                                p_denom_currency_code           VARCHAR2,
                                p_user_def_exp_type             NUMBER,
                                p_user_id                        NUMBER,
                                p_login_id                        NUMBER,
                                p_req_id                        NUMBER,
                                p_prg_appl_id                         NUMBER,
                                p_prg_id                         NUMBER,
                                O_err_num                OUT        NOCOPY NUMBER,
                                O_err_code                OUT        NOCOPY VARCHAR2,
                                O_err_msg                OUT        NOCOPY VARCHAR2)
  IS

  CURSOR sel_mmt_trx_to_cost (c_Transaction_Id  NUMBER,
                              c_Organization_Id NUMBER) IS
         SELECT cpmtv.transaction_action_id,
                cpmtv.transaction_source_type_id,
                cpmtv.type_class,
                cpmtv.expenditure_type,
                cpmtv.transaction_date,
                cpmtv.project_id,
                cpmtv.task_id,
                cpmtv.inventory_item_id,
                cpmtv.primary_quantity,
                cpmtv.costed_flag,
                cpmtv.primary_cost_method,
                cpmtv.avg_rates_cost_type_id,
                cpmtv.item_description,
                cpmtv.cost_group_id,
                cpmtv.transfer_cost_group_id,
                cpmtv.transaction_source_id,
                cpmtv.to_project_id,
                cpmtv.to_task_id,
                cpmtv.source_project_id,
                cpmtv.source_task_id,
                cpmtv.transfer_transaction_id,
                cpmtv.acct_period_id,
                cpmtv.pm_cost_collector_group_id,
                cpmtv.exp_org_id,
                cpmtv.distribution_account_id,
                cpmtv.transfer_organization_id,
                cpmtv.flow_schedule,
                cpmtv.si_asset_yes_no,
                cpmtv.transfer_si_asset_yes_no
           FROM cst_pm_matl_txn_v cpmtv
          WHERE cpmtv.transaction_id = c_Transaction_Id
            AND cpmtv.organization_id = c_Organization_Id;

        l_proj_job_ind                NUMBER;
        l_process_yn                         NUMBER;
        l_first_matl_se_exp_type         VARCHAR2(30);
        l_err_num                        NUMBER;
        l_err_code                        VARCHAR2(240);
        l_err_msg                        VARCHAR2(240);
        l_err_msg_temp                        VARCHAR2(240);

        l_error_code                    VARCHAR2(240);
        l_error_explanation             VARCHAR2(240);
        PROCESS_ERROR                        EXCEPTION;
        l_stmt_num                        NUMBER;
        rec_to_proc                        NUMBER;
        l_debug                         VARCHAR2(80);
        l_count NUMBER;
  BEGIN


        -- initialize local variables
        l_err_num := 0;
        l_err_code := '';
        l_err_msg := '';
        l_err_msg_temp := '';
        l_stmt_num := 1;
        l_count := 0;

        l_error_code := '';
        l_error_explanation := '';

        l_debug := FND_PROFILE.VALUE('MRP_DEBUG');
        if (l_debug = 'Y') then
           FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Reached#: pm_cc_worker_mmt ...');
        end if;

        l_stmt_num := 10;

        /* The transaction may not need to be cost collected. This is because
           the task auto assignment may have resulted in the task_id being equal
           to the source_task_id. In this case, set the cost_collected flag to
           NULL and return. */
        SELECT count(*)
        INTO l_count
        FROM cst_pm_matl_txn_v
        WHERE transaction_id = p_transaction_id;

        IF (l_count = 0)
        THEN
             if (l_debug = 'Y') then
               FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Transfer between same project and task.' ||
                                                ' No need to collect cost');
            end if;

            UPDATE mtl_material_transactions mmt
            SET mmt.pm_cost_collected      = NULL,
                mmt.pm_cost_collector_group_id = NULL,
                mmt.last_update_date       = sysdate,
                mmt.last_updated_by        = p_user_id,
                mmt.last_update_login      = p_login_id,
                mmt.request_id             = p_req_id,
                mmt.program_application_id = p_prg_appl_id,
                mmt.program_id             = p_prg_id,
                mmt.program_update_date    = sysdate
            WHERE
                mmt.transaction_id =p_transaction_id;

        END IF;

        FOR cpmtv_rec IN sel_mmt_trx_to_cost(p_transaction_id,
                                             p_Org_Id) LOOP

        if (l_debug = 'Y') then
           FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Processing transaction : '||to_char(p_transaction_id));
        end if;

        savepoint pm_cc_worker_mmt;

        pm_check_error_mmt( p_transaction_id,
                            p_Org_Id,
                            cpmtv_rec.primary_cost_method,
                            cpmtv_rec.inventory_item_id,
                            cpmtv_rec.avg_rates_cost_type_id,
                            cpmtv_rec.transaction_action_id,
                            cpmtv_rec.transaction_source_type_id,
                            cpmtv_rec.type_class,
                            cpmtv_rec.project_id,
                            cpmtv_rec.task_id,
                            cpmtv_rec.to_project_id,
                            cpmtv_rec.to_task_id,
                            cpmtv_rec.source_project_id,
                            cpmtv_rec.source_task_id,
                            cpmtv_rec.transaction_source_id,
                            l_proj_job_ind ,
                            l_process_yn ,
                            l_first_matl_se_exp_type ,
                            p_user_id,
                            p_login_id,
                            p_req_id,
                            p_prg_appl_id,
                            p_prg_id,
                            l_err_num,
                            l_err_code,
                            l_err_msg,
                            cpmtv_rec.flow_schedule,
                            cpmtv_rec.cost_group_id
                            );

        IF (l_err_num <> 0) THEN
             -- Error occured
             raise PROCESS_ERROR;
        END IF;

        IF l_process_yn = 1 THEN

                pm_process_txn_mmt( cpmtv_rec.pm_cost_collector_group_id,
                                    p_transaction_id,
                                    p_Org_Id,
                                    cpmtv_rec.transaction_action_id,
                                    cpmtv_rec.transaction_source_type_id,
                                    cpmtv_rec.type_class,
                                    cpmtv_rec.project_id,
                                    cpmtv_rec.task_id,
                                    cpmtv_rec.transaction_date,
                                    cpmtv_rec.primary_quantity,
                                    cpmtv_rec.expenditure_type,
                                    cpmtv_rec.item_description,
                                    cpmtv_rec.cost_group_id,
                                    cpmtv_rec.transfer_cost_group_id,
                                    cpmtv_rec.inventory_item_id,
                                    cpmtv_rec.transaction_source_id,
                                    cpmtv_rec.to_project_id,
                                    cpmtv_rec.to_task_id,
                                    cpmtv_rec.source_project_id,
                                    cpmtv_rec.source_task_id,
                                    cpmtv_rec.transfer_transaction_id,
                                    cpmtv_rec.primary_cost_method,
                                    p_std_cg_acct, -- Added for bug 3495967
                                    cpmtv_rec.acct_period_id,
                                    cpmtv_rec.exp_org_id,
                                    cpmtv_rec.distribution_account_id,
                                    l_proj_job_ind,
                                    l_first_matl_se_exp_type,
                                    p_inv_txn_source_literal,
                                    p_cap_txn_source_literal,
                                    p_inv_syslink_literal,
                                    p_bur_syslink_literal,
                                    p_wip_syslink_literal,
                                    p_user_def_exp_type,
                                    l_err_num,
                                    l_err_code,
                                    l_err_msg,
                                    cpmtv_rec.transfer_organization_id,
                                    cpmtv_rec.flow_schedule,
                                    cpmtv_rec.si_asset_yes_no,
                                    cpmtv_rec.transfer_si_asset_yes_no,
                                    p_denom_currency_code);

                IF (l_err_num <> 0) THEN
                   -- Error occured
                   raise PROCESS_ERROR;
                ELSE

                        l_stmt_num := 20;

                        /* Bug 5241396.Need to update the pm_cost_collected to NULL only for direct interorg and sub
                           inventory txfrs and not for intransit receipts that will have a txnfr txn ID */

                        /* Bug #2623627. Updating group_id for the transfer transaction_id so
                           the transfer to projects field does not show "Not Applicable" */

                        If cpmtv_rec.transaction_action_id <> 12 then

                         UPDATE mtl_material_transactions mmt
                           SET  mmt.pm_cost_collected = NULL,
                                mmt.pm_cost_collector_group_id = cpmtv_rec.pm_cost_collector_group_id,
                                mmt.last_update_date = sysdate,
                                mmt.last_updated_by        = p_user_id,
                                mmt.last_update_login      = p_login_id,
                                mmt.request_id             = p_req_id,
                                mmt.program_application_id = p_prg_appl_id,
                                mmt.program_id             = p_prg_id,
                                mmt.program_update_date = sysdate
                           WHERE         mmt.transaction_id IN (p_transaction_id, cpmtv_rec.transfer_transaction_id);

                        else

                          UPDATE  mtl_material_transactions mmt
                           SET  mmt.pm_cost_collected = NULL,
                                mmt.pm_cost_collector_group_id = cpmtv_rec.pm_cost_collector_group_id,
                                mmt.last_update_date = sysdate,
                                mmt.last_updated_by        = p_user_id,
                                mmt.last_update_login      = p_login_id,
                                mmt.request_id             = p_req_id,
                                mmt.program_application_id = p_prg_appl_id,
                                mmt.program_id             = p_prg_id,
                                mmt.program_update_date = sysdate
                         WHERE  mmt.transaction_id = p_transaction_id;

                        end If;

                END IF;

        END IF;

        END LOOP;

  EXCEPTION

        WHEN PROCESS_ERROR THEN
                IF l_err_num = 30000 THEN
                   /* Bug 2386069 - This situation will arise when a receiving txn
                      has not yet been costed but the sending txn is being cost collected.                      The sending txn is being updated with a warning but
                      pm_cost_collected flag is not being updated to error to prevent
                      user from manually resubmitting the txn for cost collection */
                   rollback to pm_cc_worker_mmt;

                   O_err_num := l_err_num;
                   O_err_code := l_err_code;
                   l_err_msg_temp := l_err_msg;
                   l_err_num := 0;

                   BEGIN

                   UPDATE  mtl_material_transactions mmt
                   SET
                        mmt.error_explanation      = l_err_msg,
                        mmt.pm_cost_collector_group_id = null,
                        mmt.last_update_date       = sysdate,
                        mmt.last_updated_by        = p_user_id,
                        mmt.last_update_login      = p_login_id,
                        mmt.request_id             = p_req_id,
                        mmt.program_application_id = p_prg_appl_id,
                        mmt.program_id             = p_prg_id,
                        mmt.program_update_date    = sysdate
                 WHERE mmt.transaction_id = p_transaction_id;

                 O_err_msg := SUBSTR(l_err_msg_temp
                                                ||' * '
                                                ||'TXN MARKED IN MMT.'
                                                ,1,240);
                 EXCEPTION
                    WHEN OTHERS THEN

                       O_err_msg := SUBSTR(l_err_msg_temp
                                                ||' * '
                                                ||l_err_msg
                                                ||' * '
                                                ||l_err_code
                                                ||' * '
                                                ||'TXN NOT MARKED IN MMT!'
                                                ,1,240);

                 END;
                ELSE
                 DECLARE
                   l_actual_cost_profile VARCHAR2(80);
                 BEGIN

                   IF l_err_num < 20000 THEN
                        rollback to cmlcci_assign_task;      --At  MAT worker
                 END IF;

                 O_err_num := l_err_num;
                 O_err_code := l_err_code;
                 l_err_msg_temp := l_err_msg;
                 l_err_num := 0;

                 /* bug 3551579.Same IN and Out variables were being used */

                 l_error_explanation := substr(l_err_msg,1,240) ;
                 l_error_code := l_err_code;

                 /* Fix for Bug#4239769
                  * Need to check the profile value to determine if the zero
                  * actual cost transactions should be marked as 'E' or not.
                  */
                 IF O_err_num = 20002 THEN
                  l_actual_cost_profile := FND_PROFILE.VALUE('CST_ERROR_ZERO_ACTUAL_COST_TO_PROJECTS');
                 END IF;

                 IF (  (O_err_num = 20002 and l_actual_cost_profile = 1)
                      OR
                    (O_err_num <> 20002)
                 ) then

                 pm_mark_error_mmt(p_transaction_id,
                                  l_error_code,
                                  l_error_explanation,
                                  p_user_id,
                                  p_login_id,
                                  p_req_id,
                                  p_prg_appl_id,
                                  p_prg_id,
                                  l_err_num,
                                  l_err_code,
                                  l_err_msg);
                 IF (l_err_num <> 0) THEN
                        O_err_msg := SUBSTR(l_err_msg_temp
                                                ||' * '
                                                ||l_err_msg
                                                ||' * '
                                                ||l_err_code
                                                ||' * '
                                                ||'TXN NOT MARKED IN MMT!'
                                                ,1,240);
                 ELSE
                        O_err_msg := SUBSTR(l_err_msg_temp
                                                ||' * '
                                                ||'TXN MARKED IN MMT.'
                                                ,1,240);

                 END IF;

                ELSE

                  UPDATE mtl_material_transactions mmt
                   SET mmt.pm_cost_collected      = NULL,
                       mmt.pm_cost_collector_group_id = NULL,
                       mmt.last_update_date       = sysdate,
                       mmt.last_updated_by        = p_user_id,
                       mmt.last_update_login      = p_login_id,
                       mmt.request_id             = p_req_id,
                       mmt.program_application_id = p_prg_appl_id,
                       mmt.program_id             = p_prg_id,
                       mmt.program_update_date    = sysdate
                 WHERE mmt.transaction_id =p_transaction_id;

                 O_err_msg := SUBSTR(l_err_msg_temp ||'Zero Cost Txn. but not marked as error in MMT' ,1,240);

                END IF;
                END;

               END IF;

        WHEN OTHERS THEN
                rollback to cmlcci_assign_task;      --At MAT worker
                O_err_num := SQLCODE;
                O_err_code := NULL;
                l_err_msg_temp := 'CSTPPCCB.pm_cc_worker_mmt('
                                || to_char(l_stmt_num)
                                || '): '
                                || substr(SQLERRM,1,150);
                l_err_num := 0;

                /* bug 3551579.Same IN and Out variables were being used */

                l_error_explanation := substr(l_err_msg,1,240) ;
                l_error_code := l_err_code;

                pm_mark_error_mmt(p_transaction_id,
                                  l_error_code,
                                  l_error_explanation,
                                  p_user_id,
                                  p_login_id,
                                  p_req_id,
                                  p_prg_appl_id,
                                  p_prg_id,
                                  l_err_num,
                                  l_err_code,
                                  l_err_msg);
                IF (l_err_num <> 0) THEN
                        O_err_msg := SUBSTR(l_err_msg_temp
                                                ||' * '
                                                ||l_err_msg
                                                ||' * '
                                                ||l_err_code
                                                ||' * '
                                                ||'TXN NOT MARKED IN MMT!'
                                                ,1,240);
                ELSE
                        O_err_msg := SUBSTR(l_err_msg_temp
                                                ||' * '
                                                ||'TXN MARKED IN MMT.'
                                                ,1,240);

                END IF;
  END pm_cc_worker_mmt;

/*----------------------------------------------------------------------------*
 | PRIVATE PROCEDURE                                                          |
 |       assign_groups_to_wt_txns                                            |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This procedure would for every record selected from the view, update the|
 |    WT  record to assign a group_id. The number of records to be updated is |
 |    determined by the user_spec_group_size. Delete all 'WITE' records if any|
 |    for the transactions that were assigned the group_id.                   |
 |                                                                            |
 |    Every Transaction that satisfies the conditions mentioned below gets    |
 |    a group id assigned to itself.                                          |
 |                                                                            |
 |    - All transactions resulting from a job that is Project related         |
 |                                                                            |
 |      - Select Txns: Resource, O/P and Overhead                             |
 |                                                                            |
 |    - Ensure that the transaction has not yet been assigned a group_id      |
 |                                                                            |
 |    - Ensure that the transaction took place before the Date upto which the |
 |      Cost Collection was desired                                           |
 |                                                                            |
 |    - Ensure that the transaction took place in Org for which the Cost Coll |
 |      was desired                                                           |
 |                                                                            |
 | PARAMETERS                                                                 |
 |      p_Org_Id,                                                             |
 |      p_prior_days,                                                          |
 |      p_user_spec_group_size,                                               |
 |      p_rows_processed,                                                      |
 |      p_group_id OUT,                                                       |
 |      p_user_id,                                                            |
 |      p_login_id,                                                           |
 |      p_req_id,                                                             |
 |      p_prg_appl_id,                                                        |
 |      p_prg_id,                                                             |
 |      O_err_num,                                                              |
 |      O_err_code,                                                           |
 |      O_err_msg                                                             |
 |                                                                            |
 | HISTORY                                                                    |
 |    07-SEP-96  Bhaskar Dasari Created.                                      |
 |                                                                            |
 |    21-NOV-97  Hemant Gosain Modified. Refer Bug# 589460 Regarding          |
 |               PJM Auto Task API. Get Prj/Tsk Ref from Table WT.            |
 *----------------------------------------------------------------------------*/
  PROCEDURE assign_groups_to_wt_txns (
                                      p_Org_Id                       NUMBER,
                                      p_prior_days                   NUMBER,
                                      p_user_spec_group_size             NUMBER,
                                      p_rows_processed                 OUT  NOCOPY NUMBER,
                                      p_group_id                 OUT  NOCOPY NUMBER,
                                      p_user_id                             NUMBER,
                                      p_login_id                     NUMBER,
                                      p_req_id                             NUMBER,
                                      p_prg_appl_id                      NUMBER,
                                      p_prg_id                              NUMBER,
                                      O_err_num                        OUT  NOCOPY NUMBER,
                                      O_err_code                OUT  NOCOPY VARCHAR2,
                                      O_err_msg                        OUT  NOCOPY VARCHAR2)
  IS

  CURSOR sel_wt_trx ( c_Org_Id               NUMBER,
                      c_prior_days           NUMBER,
                      c_user_spec_group_size NUMBER) IS
         SELECT  NULL
           FROM         wip_transactions wt
          WHERE  wt.organization_id = c_Org_Id
            AND  wt.transaction_date <= ((trunc(sysdate) - c_prior_days) + 0.99999)
            AND  wt.pm_cost_collected = 'N'
            AND  wt.transaction_type in (1,2,3,17)
            AND  wt.project_id IS NOT NULL -- Bug #589460
            AND  wt.pm_cost_collector_group_id is NULL
            AND  rownum <= c_user_spec_group_size

            FOR UPDATE OF wt.pm_cost_collected NOWAIT;

  l_group_id            NUMBER;
  l_err_num             NUMBER;
  l_err_code            VARCHAR2(240);
  l_err_msg             VARCHAR2(240);
  l_stmt_num            NUMBER;
  l_rows                NUMBER;
  l_debug               VARCHAR2(80);

  BEGIN

        -- initialize local variables
        l_err_num := 0;
        l_err_code := '';
        l_err_msg := '';
        p_rows_processed := 0;
        l_stmt_num := 1;

        l_debug := FND_PROFILE.VALUE('MRP_DEBUG');
        if (l_debug = 'Y') then
           FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Reached#: assign_groups_to_wt_txns ...');
        end if;

        l_stmt_num := 10;

        SELECT wip_transactions_S.nextval
          INTO l_group_id
          FROM dual;

        p_group_id := l_group_id;
        l_stmt_num := 20;

        FOR sel_wt_rec IN sel_wt_trx(   p_Org_Id,
                                        p_prior_days,
                                        p_user_spec_group_size) LOOP

        UPDATE  wip_transactions wt
           SET  wt.pm_cost_collector_group_id = l_group_id,
                wt.last_update_date = sysdate,
                wt.last_updated_by        = p_user_id,
                wt.last_update_login      = p_login_id,
                wt.request_id             = p_req_id,
                wt.program_application_id = p_prg_appl_id,
                wt.program_id             = p_prg_id,
                wt.program_update_date = sysdate
         WHERE  CURRENT of sel_wt_trx;

        p_rows_processed := sel_wt_trx%ROWCOUNT;
        l_rows := sel_wt_trx%ROWCOUNT;

        END LOOP;

        l_stmt_num := 30;

        DELETE wip_txn_interface_errors wite
         WHERE wite.transaction_id in
                ( SELECT wt.transaction_id
                    FROM wip_transactions wt
                   WHERE wt.pm_cost_collector_group_id = l_group_id
                     AND wt.pm_cost_collected = 'N' )
           AND wite.error_column = 'PM_COST_COLLECTED';


        EXCEPTION
                WHEN OTHERS THEN
                        rollback;
                        O_err_num := SQLCODE;
                        O_err_code := NULL;
                        O_err_msg := 'CSTPPCCB.assign_groups_to_wt_txns('
                                        || to_char(l_stmt_num)
                                        || '): '
                                        || substr(SQLERRM,1,200);

  END assign_groups_to_wt_txns;
/*----------------------------------------------------------------------------*
 | PRIVATE PROCEDURE                                                          |
 |    pm_cc_worker_wt                                                         |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This procedure would Cost Collect the given transaction id. The code    |
 |    would check if the transaction is with errors. If none, the code would  |
 |    to make a call to a procedure that would process the transaction. On    |
 |    successful return from the process_txn procedure, the transaction being |
 |    is flagged as successfully cost collected by marking the flag           |
 |    'pm_cost_collected' as NULL.                                            |
 |                                                                            |
 | PARAMETERS                                                                 |
 |      p_transaction_id                                                      |
 |      p_wip_txn_source_literal                                              |
 |      p_wip_syslink_literal                                                 |
 |      p_bur_syslink_literal                                                 |
 |      p_denom_currency_code                                                 |
 |      p_user_id,                                                            |
 |      p_login_id,                                                           |
 |      p_req_id,                                                             |
 |      p_prg_appl_id,                                                        |
 |      p_prg_id,                                                             |
 |      O_err_num,                                                              |
 |      O_err_code,                                                           |
 |      O_err_msg                                                             |
 |                                                                            |
 | HISTORY                                                                    |
 |    07-SEP-96  Bhaskar Dasari Created.                                      |
 |                                                                            |
 |    30-JUL-97  Hemant Gosain Modified.                                      |
 |               Enhanced Selection criteria to include WTA reference account |
 |               to support Project Capitalization.                              |
 |                                                                            |
 |    21-NOV-97  Hemant Gosain Modified.                                      |
 |               Refer Bug# 589460. Get Prj/Tsk form WT Table.                |
 *----------------------------------------------------------------------------*/
  PROCEDURE pm_cc_worker_wt  (
                                p_transaction_id                NUMBER,
                                p_Org_Id                        NUMBER,
                                p_wip_txn_source_literal        VARCHAR2,
                                p_wip_straight_time_literal     VARCHAR2,
                                p_wip_syslink_literal           VARCHAR2,
                                p_bur_syslink_literal                VARCHAR2,
                                p_denom_currency_code           VARCHAR2,
                                p_user_id                        NUMBER,
                                p_login_id                        NUMBER,
                                p_req_id                        NUMBER,
                                p_prg_appl_id                         NUMBER,
                                p_prg_id                         NUMBER,
                                O_err_num                 OUT        NOCOPY NUMBER,
                                O_err_code                 OUT        NOCOPY VARCHAR2,
                                O_err_msg                 OUT        NOCOPY VARCHAR2)
  IS
/* The CURSOR has been changed owing to Bug#589460 and the UNION of WDJ and CFM
    has been removed because we pick the prj/task reference from the WT Table
    rather than from the Entity Definition.
*/

/* Added DISTINCT clause because ppf could have multiple records based on
   effectivity dates for the same person_id  Bug # 703956 */

/*Included the business_group_id parameter in the cursor bug 2124765 */

  CURSOR sel_wt_trx_to_cost (C_transaction_id  NUMBER,
                             C_organization_id NUMBER) IS
         SELECT        DISTINCT wta.transaction_date                c_transaction_date,
                ppf.business_group_id           c_business_group_id,
                ppf.employee_number                c_employee_number,
                wta.base_transaction_value        c_base_transaction_value,
                wt.primary_quantity                c_primary_quantity,
                wta.resource_id                        c_resource_id,
                br.description                        c_resource_description,
                br.expenditure_type                c_expenditure_type,
                wt.project_id                        c_project_id,
                wt.task_id                        c_task_id,
                bd.pa_expenditure_org_id        c_pa_expenditure_org_id,
                wt.acct_period_id                c_acct_period_id,
                wt.pm_cost_collector_group_id        c_group_id,
                wt.department_id                c_department_id,
                wt.transaction_type                c_transaction_type,
                wta.cost_element_id                c_cost_element_id,
                wt.wip_entity_id                c_wip_entity_id,
                wta.accounting_line_type        c_accounting_line_type,
                wt.primary_uom                        c_primary_uom,
                wta.basis_resource_id                c_basis_resource_id,
                wta.reference_account                c_reference_account,
                wta.wip_sub_ledger_id                c_wip_dr_sub_ledger_id
           FROM wip_transaction_accounts wta,
                wip_transactions wt,
                bom_resources br,
                bom_departments bd,
                per_people_f ppf
          WHERE wt.transaction_type in (1,2,3)
            AND wta.accounting_line_type = 7
            AND wt.transaction_id = wta.transaction_id
            AND br.resource_id = wta.resource_id
            AND bd.department_id = wt.department_id
            AND bd.organization_id = wt.organization_id
            AND wt.transaction_id = C_transaction_id
            AND wt.organization_id = C_organization_id
            AND ppf.person_id (+) = wt.employee_id
               /* Bug:2395906*/
            AND ppf.effective_start_date(+) <= trunc(sysdate)
            AND ppf.effective_end_date(+) >= trunc(sysdate)
            AND (ppf.employee_number is not null or ppf.person_id is null)

      /*Added the above and condition to check if the employee_number
        is not null.This is modified for porting bug #1573297 in 11.0
        to 11.5 Bug 1660313*/
       /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
         Removed the join with PJM_PROJECT_PARAMETERS  for  bug  7328006
         all the logic for the expenditure type  will  be handled by the
         already existing API CST_eamCost_PUB.get_ExpType_for_DirectItem
         which has been enhanced
       ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
         UNION
         SELECT DISTINCT wta.transaction_date        	c_transaction_date,
                to_number(NULL)                      	c_business_group_id,
                NULL                                 	c_employee_number,
                wta.base_transaction_value        	c_base_transaction_value,
                wt.primary_quantity                	c_primary_quantity,
                wta.resource_id                        	c_resource_id,
                pla.item_description                   	c_resource_description,
                NULL	        			c_expenditure_type,
                wt.project_id                        	c_project_id,
                wt.task_id                        	c_task_id,
                wt.organization_id              	c_pa_expenditure_org_id,
                wt.acct_period_id                	c_acct_period_id,
                wt.pm_cost_collector_group_id        	c_group_id,
                wt.department_id                	c_department_id,
                wt.transaction_type                	c_transaction_type,
                wta.cost_element_id                	c_cost_element_id,
                wt.wip_entity_id                	c_wip_entity_id,
                wta.accounting_line_type        	c_accounting_line_type,
                wt.primary_uom                        	c_primary_uom,
                wta.basis_resource_id                	c_basis_resource_id,
                wta.reference_account                	c_reference_account,
                wta.wip_sub_ledger_id                	c_wip_dr_sub_ledger_id
           FROM wip_transaction_accounts wta,
                wip_transactions wt,
                pjm_project_parameters ppp,
                po_lines_all pla
          WHERE wt.transaction_type = 17
            AND pla.po_line_id = wt.po_line_id
            AND wta.accounting_line_type = 7
            AND wt.transaction_id = wta.transaction_id
            AND wt.transaction_id = C_transaction_id
            AND wt.organization_id = C_organization_id;

        l_process_yn                         NUMBER;
        l_err_num                        NUMBER;
        l_err_code                        VARCHAR2(240);
        l_err_msg                        VARCHAR2(240);
        l_err_msg_temp                        VARCHAR2(240);
        l_exp_org_name                        VARCHAR2(60);
        PROCESS_ERROR                        EXCEPTION;
        l_stmt_num                        NUMBER;
        l_accounting_line_type                NUMBER;
        l_cr_code_combination_id        NUMBER;
        l_wip_cr_sub_ledger_id          NUMBER;
        l_debug                                VARCHAR2(80);
        l_business_group_name           VARCHAR2(80) ;

        /* Direct Item Enh Project */
        l_expenditure_type                VARCHAR2(30) ;
        l_return_status                        VARCHAR2(1) ;
        l_msg_count                        NUMBER := 0;
        l_msg_data                            VARCHAR2(8000) ;
        l_api_message                        VARCHAR2(8000);

        l_err_in_code                   VARCHAR2(240);
        l_err_in_msg                    VARCHAR2(240);
        l_cross_bg_profile		VARCHAR(1);

  BEGIN

        -- initialize local variables
        l_err_num := 0;
        l_err_code := '';
        l_err_msg := '';
        l_err_msg_temp := '';
        l_exp_org_name := '';
        l_accounting_line_type := 0;
        l_cr_code_combination_id := 0;
        l_stmt_num := 1;
        l_return_status := fnd_api.g_ret_sts_success;
        l_cross_bg_profile := pa_utils.IsCrossBGProfile_WNPS; /*Added or bug 8398299, using wrapping function to get profile value*/

        l_debug := FND_PROFILE.VALUE('MRP_DEBUG');
        if (l_debug = 'Y') then
            FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Reached#: pm_cc_worker_wt');
        end if;

        l_stmt_num := 10;

        FOR wt_rec IN sel_wt_trx_to_cost(p_transaction_id, p_Org_Id) LOOP

        if (l_debug = 'Y') then
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing transaction : '||to_char(p_transaction_id));
        end if;

        savepoint pm_cc_worker_wt;

         l_stmt_num := 11;
	 /* Check to see if there is a defined expenditure type for the direct item procurement txn */
         /*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
           Moving call to API   CST_eamCost_PUB.get_ExpType_for_DirectItem
           before the validation  pm_check_error_wt for bug 7328006
           ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	if (wt_rec.c_transaction_type = 17) then
            CST_eamCost_PUB.get_ExpType_for_DirectItem(
                p_api_version        =>        1.0,
                x_return_status      =>        l_return_status,
                x_msg_count          =>        l_msg_count,
                x_msg_data           =>        l_msg_data,
                p_txn_id             =>        p_transaction_id,
                x_expenditure_type   =>        l_expenditure_type
                );
                if (l_return_status <> fnd_api.g_ret_sts_success) then
                   FND_FILE.put_line(FND_FILE.log, l_msg_data);
                   l_api_message := 'get_ExpType_for_DirectItem returned unexpected error';
                   FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
                   FND_MESSAGE.set_token('TEXT', l_api_message);
                   FND_MSG_pub.add;
                   raise fnd_api.g_exc_unexpected_error;
                elsif (l_expenditure_type is not null and l_expenditure_type <> to_char(-1)) then
                   wt_rec.c_expenditure_type := l_expenditure_type;
                end if;
        end if;

        pm_check_error_wt ( p_transaction_id,
                            wt_rec.c_project_id,
                            wt_rec.c_task_id,
                            wt_rec.c_expenditure_type,
                            p_Org_Id,
                            wt_rec.c_department_id,
                            wt_rec.c_employee_number,
                            l_exp_org_name,
                            l_process_yn ,
                            p_user_id,
                            p_login_id,
                            p_req_id,
                            p_prg_appl_id,
                            p_prg_id,
                            l_err_num,
                            l_err_code,
                            l_err_msg);

        IF (l_err_num <> 0) THEN
           -- Error occured
           raise PROCESS_ERROR;
        END IF;

        IF l_process_yn = 1 THEN

                /* START WIP TXN CR ACCT */
                l_stmt_num := 12;
                -- Get the Cr Account for this Transaction
                SELECT decode(wt_rec.c_transaction_type,
                              17, 5,                        --Rcv Inspection(Direct Item)
                              decode(wt_rec.c_cost_element_id,
                                        3, 4,                --RES ABSO;RES
                                        4, 4,                --RES ABSO;OSP
                                        5, 3,                 --OVHD ABSO
                                        4))
                INTO l_accounting_line_type
                FROM DUAL;

                l_stmt_num := 14;

                /* Bug 2599649
                   Added check for resource_id also to make
                   sure to the correct overhead absorption account
                   for a particular overhead is picked up
               */

                SELECT NVL(reference_account,-99)
                INTO l_cr_code_combination_id
                FROM wip_transaction_accounts
                WHERE         transaction_id = p_transaction_id
                AND        organization_id = p_org_id
                AND        cost_element_id = wt_rec.c_cost_element_id
                AND        accounting_line_type = l_accounting_line_type
                AND     NVL(resource_id,-99) = NVL(wt_rec.c_resource_id,-99);

               /* changes to get the WIP credit sub Ledger ID from WTA */

                l_stmt_num := 16;

                SELECT MAX(WIP_SUB_LEDGER_ID)
                  INTO l_wip_cr_sub_ledger_id
                  FROM wip_transaction_accounts wta
                 WHERE transaction_id = p_transaction_id
                   AND reference_account = l_cr_code_combination_id
                   AND organization_id = p_org_id
                   AND cost_element_id = wt_rec.c_cost_element_id
                   AND accounting_line_type = l_accounting_line_type
                   AND NVL(resource_id,-99) = NVL(wt_rec.c_resource_id,-99);


                -- if CR account could not be obtained then
                -- set Cr account = dr account.
                l_stmt_num := 16;
                IF l_cr_code_combination_id = -99 THEN
                        l_cr_code_combination_id := wt_rec.c_reference_account;
                        l_wip_cr_sub_ledger_id   := wt_rec.c_wip_dr_sub_ledger_id;
                END IF;
                /* END WIP TXN CR ACCT */
                l_stmt_num := 18;

              /*Get the Business group Name from the business group Id and  pass it
                for insertion into PA_TRANSACTION_INTERFACE.Bug Fix for
                Bug 2124765   */

                if wt_rec.c_business_group_id is not null THEN
                   Select haout.name into l_business_group_name
                   From hr_all_organization_units_tl haout
                   WHERE
                        haout.organization_id = wt_rec.c_business_group_id
                        AND haout.language = USERENV('LANG');
                else /* Modified for bug 8398299 to ensure we pass the business group name
                        when the Cross Business Group profile has been activated*/
                        IF l_cross_bg_profile = 'Y' THEN
                       		SELECT 	HAOUT.name
				INTO   	l_business_group_name
       				FROM   	hr_all_organization_units_tl HAOUT
        			WHERE 	HAOUT.organization_id =
                                        	(SELECT COD.business_group_id
                                         	FROM	cst_organization_definitions COD
				     		 WHERE  COD.organization_id = p_org_id)
   				AND 	haout.language = USERENV('LANG');
			END IF;
                end if;

                l_stmt_num := 19;

                pm_process_txn_wt( wt_rec.c_group_id,
                                   l_business_group_name,
                                   p_transaction_id,
                                   p_Org_Id,
                                   wt_rec.c_employee_number,
                                   wt_rec.c_department_id,
                                   wt_rec.c_project_id,
                                   wt_rec.c_task_id,
                                   wt_rec.c_transaction_date,
                                   wt_rec.c_base_transaction_value,
                                   wt_rec.c_primary_quantity,
                                   wt_rec.c_acct_period_id,
                                   wt_rec.c_expenditure_type,
                                   wt_rec.c_resource_description,
                                   wt_rec.c_transaction_type,
                                   wt_rec.c_cost_element_id,
                                   l_exp_org_name,
                                   p_wip_txn_source_literal,
                                   p_wip_straight_time_literal,
                                   p_wip_syslink_literal,
                                   p_bur_syslink_literal,
                                   l_err_num,
                                   l_err_code,
                                   l_err_msg,
                                   wt_rec.c_reference_account,
                                   l_cr_code_combination_id,
                                   wt_rec.c_wip_dr_sub_ledger_id,
                                   l_wip_cr_sub_ledger_id,
                                   wt_rec.c_wip_entity_id,
                                   wt_rec.c_resource_id,
                                   wt_rec.c_basis_resource_id,
                                   p_denom_currency_code);

                IF (l_err_num <> 0) THEN
                   -- Error occured
                   raise PROCESS_ERROR;
                ELSE

                        l_stmt_num := 20;

                        UPDATE         wip_transactions wt
                                 SET         wt.pm_cost_collected = NULL,
                                wt.last_update_date = sysdate,
                                wt.last_updated_by        = p_user_id,
                                wt.last_update_login      = p_login_id,
                                wt.request_id             = p_req_id,
                                wt.program_application_id = p_prg_appl_id,
                                wt.program_id             = p_prg_id,
                                wt.program_update_date = sysdate
                           WHERE         wt.transaction_id = p_transaction_id;
                END IF;
        END IF;

        END LOOP;

        EXCEPTION

                WHEN PROCESS_ERROR THEN
                        IF l_err_num < 20000 THEN
                                rollback to cmlccw_assign_task; --At WIP worker
                        END IF;
                        O_err_num := l_err_num;
                        O_err_code := l_err_code;
                        l_err_msg_temp := l_err_msg;
                        l_err_num := 0;
                        l_err_in_code := l_err_code;
                        l_err_in_msg := l_err_msg;
                        pm_mark_error_wt(p_transaction_id,
                                  l_err_in_code,
                                  l_err_in_msg,
                                  p_user_id,
                                  p_login_id,
                                  p_req_id,
                                  p_prg_appl_id,
                                  p_prg_id,
                                  l_err_num,
                                  l_err_code,
                                  l_err_msg);
                        IF (l_err_num <> 0) THEN
                                O_err_msg := SUBSTR(l_err_msg_temp
                                                ||' * '
                                                ||l_err_msg
                                                ||' * '
                                                ||l_err_code
                                                ||' * '
                                                ||'TXN NOT MARKED IN WTIE!'
                                                ,1,240);
                        ELSE
                                O_err_msg := SUBSTR(l_err_msg_temp
                                                ||' * '
                                                ||'TXN MARKED IN WTIE.'
                                                ,1,240);

                        END IF;

                WHEN OTHERS THEN
                        rollback to cmlccw_assign_task;  --At WIP Worker
                        O_err_num := SQLCODE;
                        O_err_code := NULL;
                        l_err_msg_temp := 'CSTPPCCB.pm_cc_worker_wt('
                                        || to_char(l_stmt_num)
                                        || '): '
                                        || substr(SQLERRM,1,150);

                        l_err_num := 0;
                        l_err_in_code := l_err_code;
                        l_err_in_msg := l_err_msg;

                        pm_mark_error_wt(p_transaction_id,
                                  l_err_in_code,
                                  l_err_in_msg,
                                  p_user_id,
                                  p_login_id,
                                  p_req_id,
                                  p_prg_appl_id,
                                  p_prg_id,
                                  l_err_num,
                                  l_err_code,
                                  l_err_msg);
                        IF (l_err_num <> 0) THEN
                                O_err_msg := SUBSTR(l_err_msg_temp
                                                ||' * '
                                                ||l_err_msg
                                                ||' * '
                                                ||l_err_code
                                                ||' * '
                                                ||'TXN NOT MARKED IN WTIE!'
                                                ,1,240);
                        ELSE
                                O_err_msg := SUBSTR(l_err_msg_temp
                                                ||' * '
                                                ||'TXN MARKED IN WTIE.'
                                                ,1,240);

                        END IF;
  END pm_cc_worker_wt;
 /*----------------------------------------------------------------------------*
 | PRIVATE PROCEDURE                                                          |
 |    pm_process_txn_mmt                                                      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    The procedure cost collects the given transaction. The manner of cost   |
 |    collection is decided based  on the type of transaction at hand. Below  |
 |    are the various transaction groups and their differences w.r.t cost     |
 |    collection.                                                             |
 |                                                                            |
 |      -- get the project costed flag for job if the txn is a job related    |
 |      -- assign transaction org as expenditure org                          |
 |      -- get the schedule close date from acct_periods                      |
 |                                                                            |
 |    All Transactions in a Standard Costing Organization with transaction    |
 |    type having its type_class set to 1 implying that it refers to a Capital|
 |    Project. Cost Collection is done at the specified cost at transaction   |
 |    time.                                                                   |
 |                                                                            |
 | PARAMETERS                                                                 |
 |                                                                            |
 |                        p_Group_Id,                                         |
 |                        p_transaction_id,                                   |
 |                        p_organization_id,                                  |
 |                        p_transaction_action_id,                            |
 |                        p_transaction_source_type_id,                       |
 |                        p_type_class,                                       |
 |                        p_project_id,                                       |
 |                        p_task_id                                           |
 |                        p_transaction_date                                  |
 |                        p_primary_quantity                                  |
 |                        p_expenditure_type                                  |
 |                        p_item_description                                  |
 |                        p_cost_group_id                                     |
 |                        p_transfer_cost_group_id                            |
 |                        p_inventory_item_id                                 |
 |                        p_transaction_source_id                             |
 |                        p_to_project_id,                                    |
 |                        p_to_task_id                                        |
 |                        p_source_project_id,                                |
 |                        p_source_task_id,                                   |
 |                        p_transfer_transaction_id,                          |
 |                        p_primary_cost_method,                              |
 |                        p_std_cg_acct,    Added for bug 3495967             |
 |                        p_acct_period_id,                                   |
 |                        p_exp_org_id,                                       |
 |                        p_distribution_account_id,                          |
 |                        p_proj_job_ind                                      |
 |                        p_first_matl_se_exp_type                            |
 |                        p_inv_txn_source_literal                            |
 |                        p_cap_txn_source_literal                            |
 |                        p_inv_syslink_literal                               |
 |                        p_bur_syslink_literal                               |
 |                        p_wip_syslink_literal                               |
 |                        p_user_def_exp_type                                 |
 |                        O_err_num,                                              |
 |                        O_err_code,                                              |
 |                        O_err_msg,                                              |
 |                        p_transfer_organization_id,                         |
 |                        p_flow_schedule,                                    |
 |                        p_si_asset_yes_no,                                  |
 |                        p_transfer_si_asset_yes_no                          |
 |                        p_denom_currency_code                               |
 |                                                                            |
 | CALLED FROM                                                                |
 |    pm_cc_worker_mmt()                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |    07-SEP-96  Bhaskar Dasari Created.                                      |
 |                                                                            |
 |    30-JUL-97  Hemant Gosain Modified.                                      |
 |               Added Capitalization Support.                                      |
 |               Added support for -ve WIP component Transactions.              |
 |                                                                            |
 |    20-AUG-97  Hemant Gosain Modified.                                      |
 |               Added support for CFM.                                              |
 |               Changed Logic for Prj. Misc Txn.                              |
 |                                                                            |
 |    21-NOV-97  Hemant Gosain Modified.                                      |
 |               Changed Logic for Direct IO Xfer.                                 |
 |                                                                            |
 |    22-APR-01  Hemant Gosain Modified.                                      |
 |               Added Support for Std PJM.                                         |
 *----------------------------------------------------------------------------*/

  PROCEDURE  pm_process_txn_mmt (
                                 p_Group_Id                     NUMBER,
                                 p_transaction_id                NUMBER,
                                 p_organization_id                NUMBER,
                                 p_transaction_action_id        NUMBER,
                                 p_transaction_source_type_id        NUMBER,
                                 p_type_class                        NUMBER,
                                 p_project_id                        NUMBER,
                                 p_task_id                        NUMBER,
                                 p_transaction_date                DATE,
                                 p_primary_quantity                NUMBER,
                                 p_expenditure_type                VARCHAR2,
                                 p_item_description                VARCHAR2,
                                 p_cost_group_id                NUMBER,
                                 p_transfer_cost_group_id        NUMBER,
                                 p_inventory_item_id                NUMBER,
                                 p_transaction_source_id        NUMBER,
                                 p_to_project_id                NUMBER,
                                 p_to_task_id                        NUMBER,
                                 p_source_project_id                NUMBER,
                                 p_source_task_id                NUMBER,
                                 p_transfer_transaction_id        NUMBER,
                                 p_primary_cost_method                NUMBER,
                                 p_std_cg_acct                  NUMBER, -- Added for bug 3495967
                                 p_acct_period_id                NUMBER,
                                 p_exp_org_id                        NUMBER,
                                 p_distribution_account_id      NUMBER,
                                 p_proj_job_ind                NUMBER,
                                 p_first_matl_se_exp_type        VARCHAR2,
                                 p_inv_txn_source_literal        VARCHAR2,
                                 p_cap_txn_source_literal        VARCHAR2,
                                 p_inv_syslink_literal                VARCHAR2,
                                 p_bur_syslink_literal                VARCHAR2,
                                 p_wip_syslink_literal                VARCHAR2,
                                 p_user_def_exp_type            NUMBER,
                                 O_err_num                  OUT        NOCOPY NUMBER,
                                 O_err_code                  OUT        NOCOPY VARCHAR2,
                                 O_err_msg                  OUT        NOCOPY VARCHAR2,
                                 p_transfer_organization_id     NUMBER,
                                 p_flow_schedule                VARCHAR2,
                                 p_si_asset_yes_no                NUMBER,
                                 p_transfer_si_asset_yes_no        NUMBER,
                                 p_denom_currency_code          VARCHAR2)

  IS

  l_err_num                     NUMBER;
  l_err_code                    VARCHAR2(240);
  l_err_msg                     VARCHAR2(240);
  l_stmt_num                    NUMBER;

  l_batch                       VARCHAR2(15); --Increased width for Bug#2218654
-- UTF8 changes  l_organization_name            VARCHAR2(60);
  l_organization_name           hr_organization_units.name%TYPE;
--  l_xfer_organization_name    VARCHAR2(60);
  l_xfer_organization_name      hr_organization_units.name%TYPE;
  l_proj_org_id                 NUMBER;
  l_to_proj_org_id              NUMBER;
  l_source_proj_org_id          NUMBER;
  l_project_number              VARCHAR2(25);
  l_to_project_number           VARCHAR2(25);
  l_source_project_number       VARCHAR2(25);
  l_task_number                  VARCHAR2(25);
  l_to_task_number              VARCHAR2(25);
  l_source_task_number          VARCHAR2(25);
  /*l_gl_date                   DATE;*/ /* Commented for bug 6266553 */
  l_exp_end_date                DATE;
  l_txn_of_misc_family          NUMBER;
  l_rownum                      NUMBER;
  l_fob_point                   NUMBER;
  l_earn_moh                    NUMBER;
  l_earn_tomoh                  NUMBER;
  l_exp_type                    VARCHAR2(30);
  l_xfer_currency_code          VARCHAR2(15);
  l_txn_type                    NUMBER;
  l_default_project             NUMBER;
  /* Bug 2386069 */
  l_costed_flag                 VARCHAR2(1);
  ROW_NOT_COSTED                EXCEPTION;
  /* Bug 2386069 */
  NO_ROWS_TO_INSERT             EXCEPTION;
  CST_FAILED_GET_EXPENDDATE     EXCEPTION;
  CST_FAILED_PROJTSK_VALID      EXCEPTION;
  CST_FAILED_GET_EXP_TYPE       EXCEPTION;
  CST_FAILED_INSERT_PTI         EXCEPTION;
  CST_FAILED_STD_CG_FLAG        EXCEPTION;
  CST_FAILED_TXN_SRC            EXCEPTION;

-- UTF8 changes  l_recv_iss_organization_name  VARCHAR2(60);
  l_recv_iss_organization_name  hr_all_organization_units.name%TYPE;
  l_primary_cost_method_snd     NUMBER ;
  l_cost_collection_enabled_snd NUMBER ;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(30);

  l_std_cg_acct_snd             NUMBER;

  l_org_id                      NUMBER;
  l_inv_txn_src_literal         VARCHAR2(30);
  l_transaction_source          VARCHAR2(30);
  l_cap_inv_txn_src_literal     VARCHAR2(30);
  l_blue_print_enabled_flag     VARCHAR2(1);
  l_autoaccounting_flag         VARCHAR2(1);


  ppv_txfr_flag                 NUMBER;

  l_no_row_c_sel_prj            NUMBER;
  l_no_row_c_sel_toprj          NUMBER;
  l_no_ppv                      NUMBER;
  l_operating_unit              NUMBER;



/* Cursor for STANDARD ORG Proj. Misc Txn */
/* If the user does not specify an expenditure_type, it will be derived */
/* from the Cost Element Associations */
/* PJMSTD SUPPORT------------------------------ */
/* This cursor is for Std Orgs which are not PJ enabled and hence only */
/* Proj Misc transactions will be cost collected */
/* PJMSTD SUPPORT------------------------------ */
  CURSOR c_sel_std_misc IS
                SELECT        p_cap_txn_source_literal transaction_source,
                        l_batch batch_name,
                        l_exp_end_date expenditure_ending_date,
                        NULL employee_number,
                        l_organization_name organization_name,
                        p_transaction_date expenditure_item_date,
                        l_source_project_number project_number,
                        l_source_task_number task_number,
                        decode(mcacd.cost_element_id,
                                2,0,
                                5,0,
                                (-1) * p_primary_quantity) quantity,
                        decode(mcacd.cost_element_id,
                                2,0,
                                5,0,
                                (-1)*sum(p_primary_quantity * mcacd.actual_cost))
                                                                 raw_cost,
                        p_item_description expenditure_comment,
                        to_char(p_transaction_id) orig_transaction_reference,
                        decode(mcacd.cost_element_id,
                                2,0,
                                5,0,
                                sum(mcacd.actual_cost)) raw_cost_rate,
                        'Y' unmatched_negative_txn_flag,
                        -999999 dr_code_combination_id,
                        -999999 cr_code_combination_id,
                        NULL cdl_system_reference1,
                        NULL cdl_system_reference2,
                        NULL cdl_system_reference3,
                        /*l_gl_date*/ /* Commented for bug 6266553 */ p_transaction_date gl_date,
                        l_source_proj_org_id org_id,
                        (-1)*sum(p_primary_quantity *
                                            mcacd.actual_cost) burdened_cost,
                        sum(mcacd.actual_cost) burdened_cost_rate,
                        decode( mcacd.cost_element_id,
                                        2, p_bur_syslink_literal,
                                        3, p_wip_syslink_literal,
                                        4, p_wip_syslink_literal,
                                        5, p_bur_syslink_literal,
                                        p_inv_syslink_literal) system_linkage,
                        'P' transaction_status_code,
                         mcacd.cost_element_id cost_element_id,
                        p_denom_currency_code denom_currency_code
                  FROM  mtl_cst_actual_cost_details mcacd,
                        mtl_material_transactions mmt
                 WHERE  mmt.transaction_id = p_transaction_id
                   AND  mmt.transaction_id = mcacd.transaction_id
                   AND  mcacd.organization_id = p_organization_id
                   AND  mcacd.inventory_item_id = p_inventory_item_id
                   AND  mcacd.actual_cost <> 0
              GROUP BY         p_transaction_id,
                        mcacd.cost_element_id;

/* Cursor for gathering Material Overhead Costs for txns like: */
/* WIP-CFM Assy Comp/Return, InterOrg or PO */
  CURSOR c_sel_moh_txn IS
                SELECT        p_inv_txn_source_literal transaction_source,
                        l_batch batch_name,
                        l_exp_end_date expenditure_ending_date,
                        NULL employee_number,
                        l_organization_name organization_name,
                        p_transaction_date expenditure_item_date,
                        l_project_number project_number,
                        l_task_number task_number,
                        br.EXPENDITURE_TYPE expenditure_type,
                        0 quantity,           /* Qty=0 if l=burden */
                        0 raw_cost,          /* RawCost=0 if l=burden */
                        br.description expenditure_comment,
                        to_char(p_transaction_id) orig_transaction_reference,
                        0 raw_cost_rate,  /*RawCostrate=0 if l=burden */
                        'Y' unmatched_negative_txn_flag,
                        -999999 dr_code_combination_id,
                        -999999 cr_code_combination_id,
                        NULL cdl_system_reference1,
                        NULL cdl_system_reference2,
                        NULL cdl_system_reference3,
                        /*l_gl_date*/ /* Commented for bug 6266553 */ p_transaction_date gl_date,
                        l_proj_org_id org_id,
                        macs.ACTUAL_COST*p_primary_quantity burdened_cost,
                        macs.ACTUAL_COST burdened_cost_rate,
                        p_bur_syslink_literal system_linkage,
                        'P' transaction_status_code,
                        br.resource_id resource_id,
                        macs.cost_element_id cost_element_id,
                        p_denom_currency_code denom_currency_code
                FROM    mtl_actual_cost_subelement macs,
                        bom_resources br,
                        mtl_parameters mp
                WHERE     macs.transaction_id = p_transaction_id
                    AND   macs.ORGANIZATION_ID = mp.ORGANIZATION_ID
                    AND   mp.cost_organization_id = br.organization_id
                    AND   macs.cost_element_id = 2
                    AND   macs.level_type = 1
                    AND   macs.RESOURCE_ID = br.RESOURCE_ID
                    AND   macs.ACTUAL_COST <> 0;

/* Cursor for gathering the receiving side MOH absorption */

CURSOR c_sel_tomoh IS
SELECT                  p_inv_txn_source_literal transaction_source,
                        l_batch batch_name,
                        l_exp_end_date expenditure_ending_date,
                        NULL employee_number,
                        l_xfer_organization_name organization_name,
                        p_transaction_date expenditure_item_date,
                        l_to_project_number project_number,
                        l_to_task_number task_number,
                        br.EXPENDITURE_TYPE expenditure_type,
                        0 quantity,           /* Qty=0 if l=burden */
                        0 raw_cost,          /* RawCost=0 if l=burden */
                        br.description expenditure_comment,
                        to_char(p_transfer_transaction_id) orig_transaction_reference,
                        0 raw_cost_rate,  /*RawCostrate=0 if l=burden */
                        'Y' unmatched_negative_txn_flag,
                        -999999 dr_code_combination_id,
                        -999999 cr_code_combination_id,
                        NULL cdl_system_reference1,
                        NULL cdl_system_reference2,
                        NULL cdl_system_reference3,
                        /*l_gl_date*/ /* Commented for bug 6266553 */ p_transaction_date gl_date,
                        l_to_proj_org_id org_id,
                        (-1)*macs.ACTUAL_COST*p_primary_quantity burdened_cost,
                        macs.ACTUAL_COST burdened_cost_rate,
                        p_bur_syslink_literal system_linkage,
                        'P' transaction_status_code,
                        br.resource_id resource_id,
                        macs.cost_element_id cost_element_id,
                        l_xfer_currency_code denom_currency_code
                FROM    mtl_actual_cost_subelement macs,
                        bom_resources br
                WHERE   macs.transaction_id = p_transfer_transaction_id
                  AND   macs.ORGANIZATION_ID = br.ORGANIZATION_ID
                  AND   macs.cost_element_id = 2
                  AND   macs.level_type = 1
                  AND   macs.RESOURCE_ID = br.RESOURCE_ID
                  AND   macs.ACTUAL_COST <> 0;


/* Cursor for gathering Project related Locator txn costs for any txn */
/* Bug#2580132 - Changed the join between ccicv and mcacd to outer join */
  CURSOR c_sel_prj_txn IS
                SELECT        decode(p_type_class,1,
                        p_cap_txn_source_literal,
                        p_inv_txn_source_literal) transaction_source,
                        l_batch batch_name,
                        l_exp_end_date expenditure_ending_date,
                        NULL employee_number,
                        l_organization_name organization_name,
                        p_transaction_date expenditure_item_date,
                        l_project_number project_number,
                        l_task_number task_number,
          decode(mcacd.cost_element_id,2,0,
            decode(mcacd.cost_element_id,5,0,p_primary_quantity
                  )) quantity,

          decode(mcacd.cost_element_id,2,0,
            decode(mcacd.cost_element_id,5,0,
                sum(mcacd.ACTUAL_COST)*p_primary_quantity
                   )) raw_cost,

                        p_item_description expenditure_comment,
                        to_char(p_transaction_id) orig_transaction_reference,

          decode(mcacd.cost_element_id,2,0,
            decode(mcacd.cost_element_id,5,0,sum(mcacd.ACTUAL_COST)
                   )) raw_cost_rate,
                        'Y' unmatched_negative_txn_flag,
                        -999999 dr_code_combination_id,
                        -999999 cr_code_combination_id,
                        NULL cdl_system_reference1,
                        NULL cdl_system_reference2,
                        NULL cdl_system_reference3,
                        /*l_gl_date*/ /* Commented for bug 6266553 */ p_transaction_date gl_date,
                        l_proj_org_id org_id,
                        ((sum(mcacd.ACTUAL_COST)*p_primary_quantity) - (NVL((sum(temp.actual_cost)*p_primary_quantity),0))) burdened_cost,
                          (sum(mcacd.ACTUAL_COST)-(NVL(sum(temp.actual_cost),0))) burdened_cost_rate,

                  decode(mcacd.cost_element_id,2, p_bur_syslink_literal,
                   decode(mcacd.cost_element_id,3, p_wip_syslink_literal,
                    decode(mcacd.cost_element_id,4, p_wip_syslink_literal,
                     decode(mcacd.cost_element_id,5, p_bur_syslink_literal,
                                p_inv_syslink_literal)))) system_linkage,

                        'P' transaction_status_code ,
                        mcacd.cost_element_id cost_element_id,
                        p_denom_currency_code denom_currency_code
                  FROM         mtl_cst_actual_cost_details mcacd,
                        (Select SUM(actual_cost) actual_cost,
                               transaction_id,
                               organization_id,
                               cost_element_id,
                               level_type,
                               layer_id
                        from mtl_actual_cost_subelement macs
                        where transaction_id = p_transaction_id
                          and organization_id = p_organization_id
                        group by transaction_id,
                                 organization_id,
                                 cost_element_id,
                                 level_type,
                                 layer_id
                        ) temp,
                        cst_cg_item_costs_view ccicv --PJMSTD
                 WHERE        mcacd.transaction_id  = p_transaction_id
                   AND         mcacd.organization_id = p_organization_id
                AND         mcacd.inventory_item_id = p_inventory_item_id
                AND        mcacd.actual_cost <> 0
                AND        mcacd.layer_id    = decode(p_primary_cost_method,
                                                1, -1,ccicv.layer_id) --PJMSTD
                AND     temp.transaction_id(+) =
                                        mcacd.transaction_id
                AND     temp.organization_id(+) = mcacd.organization_id
                AND     temp.cost_element_id(+) = mcacd.cost_element_id
                AND     temp.level_type(+) = mcacd.level_type
                AND        ccicv.organization_id  = p_organization_id
                AND        ccicv.inventory_item_id = p_inventory_item_id
                AND        ccicv.cost_group_id = decode(p_primary_cost_method,
                                                 1, 1, p_cost_group_id) --PJMSTD
                      GROUP BY mcacd.transaction_id,
                             mcacd.cost_element_id
        UNION ALL /* BUG #2972878, 2580132 */
                SELECT  decode(p_type_class,1,
                        p_cap_txn_source_literal,
                        p_inv_txn_source_literal) transaction_source,
                        l_batch batch_name,
                        l_exp_end_date expenditure_ending_date,
                        NULL employee_number,
                        l_organization_name organization_name,
                        p_transaction_date expenditure_item_date,
                        l_project_number project_number,
                        l_task_number task_number,
          decode(mcacd.cost_element_id,2,0,
            decode(mcacd.cost_element_id,5,0,p_primary_quantity)) quantity,

          decode(mcacd.cost_element_id,2,0,
            decode(mcacd.cost_element_id,5,0,
                sum(mcacd.ACTUAL_COST)*p_primary_quantity
                   ))raw_cost,

                        p_item_description expenditure_comment,
                        to_char(p_transaction_id) orig_transaction_reference,

          decode(mcacd.cost_element_id,2,0,
            decode(mcacd.cost_element_id,5,0,sum(mcacd.ACTUAL_COST)
                 )) raw_cost_rate,

                        'Y' unmatched_negative_txn_flag,
                        -999999 dr_code_combination_id,
                        -999999 cr_code_combination_id,
                        NULL cdl_system_reference1,
                        NULL cdl_system_reference2,
                        NULL cdl_system_reference3,
                        /*l_gl_date*/ /* Commented for bug 6266553 */ p_transaction_date gl_date,
                        l_proj_org_id org_id,
                        ((sum(mcacd.ACTUAL_COST)*p_primary_quantity) - (NVL((sum(temp.actual_cost)*p_primary_quantity),0))) burdened_cost,
                        (sum(mcacd.ACTUAL_COST)-(NVL(sum(temp.actual_cost),0)))                                             burdened_cost_rate,

                  decode(mcacd.cost_element_id,2, p_bur_syslink_literal,
                   decode(mcacd.cost_element_id,3, p_wip_syslink_literal,
                    decode(mcacd.cost_element_id,4, p_wip_syslink_literal,
                     decode(mcacd.cost_element_id,5, p_bur_syslink_literal,
                                p_inv_syslink_literal)))) system_linkage,

                        'P' transaction_status_code ,
                        mcacd.cost_element_id cost_element_id,
                        p_denom_currency_code denom_currency_code
                FROM    mtl_cst_actual_cost_details mcacd,
                        (Select SUM(actual_cost) actual_cost,
                               transaction_id,
                               organization_id,
                               cost_element_id,
                               level_type,
                               layer_id
                        from mtl_actual_cost_subelement macs
                        where transaction_id = p_transaction_id
                          and organization_id = p_organization_id
                        group by transaction_id,
                                 organization_id,
                                 cost_element_id,
                                 level_type,
                                 layer_id
                        ) temp,
                        mtl_system_items msi
                WHERE   mcacd.transaction_id  = p_transaction_id
                AND     mcacd.organization_id = p_organization_id
                AND     mcacd.inventory_item_id = p_inventory_item_id
                AND     mcacd.inventory_item_id = msi.inventory_item_id
                AND     mcacd.organization_id = msi.organization_id
                AND     msi.costing_enabled_flag = 'N'
                AND     mcacd.actual_cost <> 0
              /*  AND     NOT EXISTS (
                        SELECT null
                        FROM mtl_actual_cost_subelement macs
                        WHERE macs.transaction_id =
                                        mcacd.transaction_id
                          AND macs.organization_id  =
                                        mcacd.organization_id
                          AND macs.cost_element_id =
                                        mcacd.cost_element_id
                          AND macs.level_type = mcacd.level_type
                        )*/
                AND     temp.transaction_id(+) = mcacd.transaction_id
                AND     temp.organization_id(+) = mcacd.organization_id
                AND     temp.cost_element_id(+) = mcacd.cost_element_id
                AND     temp.level_type(+) = mcacd.level_type
                GROUP BY mcacd.transaction_id,
                         mcacd.cost_element_id;

-- bug#1036498  Changed below cursor . If sending org is std (proj enabled , cost
-- collection not enabled) then need to collect matl cost for it.  This will
-- be done when cost collector is run on the receiving org.

--    std org                       -->  avg org
--    PJ enabled                         PJ enabled
--    cost collection disabled           cost collection disabled
--    from Project P1                    to project P2

-- the change made in this cursor is that joining to CQL is removed
-- since for std org. there is no data in CQL.

-- Cursor changed for Alcatel Enhancements. Both Internal Order Issue
-- to Expense and Receipt are cost collected.
/* Cursor for gathering Transfer Side Locator Project Costs in Xfer Txns */
/* Like Subinventory Xfer or Direct IO Xfer where TO_PROJECT_ID is populated */
/* the cursor c_sel_tomoh has been put in to gather MOH absorption costs on the
   receiving side.SO the following cursor will be made to exclude those cost */

  CURSOR c_sel_toprj_txn IS
                SELECT        p_inv_txn_source_literal transaction_source,
                        l_batch batch_name,
                        l_exp_end_date expenditure_ending_date,
                        NULL employee_number,
                        decode(p_transaction_action_id,
                                3, l_xfer_organization_name,
                                l_organization_name) organization_name,
                        p_transaction_date expenditure_item_date,
                        l_to_project_number project_number,
                        l_to_task_number task_number,
        decode(sign(p_primary_quantity),1, cceet.EXPENDITURE_TYPE_OUT,
               cceet.EXPENDITURE_TYPE_IN) expenditure_type,
        decode(mcacd.cost_element_id,2,0, decode(mcacd.cost_element_id,5,0,
           (-1) * p_primary_quantity)) quantity,
        decode(mcacd.cost_element_id,2,0,
           decode(mcacd.cost_element_id,5,0,
                (-1) * sum(mcacd.ACTUAL_COST)*p_primary_quantity)) raw_cost,
                        p_item_description expenditure_comment,
                        to_char(p_transfer_transaction_id)
                                                orig_transaction_reference,
          decode(mcacd.cost_element_id,2,0,
           decode(mcacd.cost_element_id,5,0,sum(mcacd.ACTUAL_COST)))
                                                raw_cost_rate,
                        'Y' unmatched_negative_txn_flag,
                        -999999 dr_code_combination_id,
                        -999999 cr_code_combination_id,
                        NULL cdl_system_reference1,
                        NULL cdl_system_reference2,
                        NULL cdl_system_reference3,
                        /*l_gl_date*/ /* Commented for bug 6266553 */ p_transaction_date gl_date,
                        l_to_proj_org_id org_id,
                        (-1)*((sum(mcacd.ACTUAL_COST)*p_primary_quantity)-
                            (NVL(sum(macs.actual_cost)*p_primary_quantity,0)))
                                                burdened_cost,
                          (sum(mcacd.ACTUAL_COST)-
                         (NVL(sum(macs.actual_cost),0))) burdened_cost_rate,
          decode(mcacd.cost_element_id,2, p_bur_syslink_literal,
           decode(mcacd.cost_element_id,3, p_wip_syslink_literal,
            decode(mcacd.cost_element_id,4, p_wip_syslink_literal,
             decode(mcacd.cost_element_id,5, p_bur_syslink_literal,
                                p_inv_syslink_literal)))) system_linkage,
                        'P' transaction_status_code,
                         mcacd.cost_element_id cost_element_id,
                        decode(p_transaction_action_id,
                                3, l_xfer_currency_code,
                                p_denom_currency_code) denom_currency_code
                  FROM         mtl_cst_actual_cost_details mcacd,
                        cst_cost_elem_exp_types cceet,
                        mtl_actual_cost_subelement macs
                 WHERE        mcacd.transaction_id  = decode(p_transaction_action_id,
                                                3, p_transfer_transaction_id ,
                                                p_transaction_id)
                  AND   mcacd.organization_id = decode(p_transaction_action_id,
                                                       3, p_transfer_organization_id,
                                                       p_organization_id)
                  AND        cceet.cost_element_id = mcacd.cost_element_id
                     AND         mcacd.actual_cost <> 0
                  AND   ((l_primary_cost_method_snd = 1)
                         OR
                          EXISTS
                            ( SELECT 'X' from cst_quantity_layers cql
                              where   mcacd.layer_id = cql.layer_id
                              AND     cql.organization_id = mcacd.organization_id
                              AND     cql.inventory_item_id = p_inventory_item_id
                              AND     cql.cost_group_id = nvl(p_transfer_cost_group_id,1)
                            )
                         )
                  AND  macs.transaction_id(+) = mcacd.transaction_id
                  AND  macs.organization_id(+) = mcacd.organization_id
                  AND  macs.cost_element_id(+) = mcacd.cost_element_id
                  AND  macs.level_type(+) = mcacd.level_type
                 GROUP BY mcacd.cost_element_id,
                         cceet.expenditure_type_in,
                         cceet.expenditure_type_out;

/* CURSOR for source_side projects in txns like Misc Proj, WIP Comp iss/Rec */
/* For Misc Txn, if exp_type is NULL then default associations are used. */
  CURSOR c_sel_src_txn IS
                SELECT        decode(p_type_class,1,p_cap_txn_source_literal,
                                  p_inv_txn_source_literal) transaction_source,
                        l_batch batch_name,
                        l_exp_end_date expenditure_ending_date,
                        NULL employee_number,
                        l_organization_name organization_name,
                        p_transaction_date expenditure_item_date,
                        l_source_project_number project_number,
                        l_source_task_number task_number,
        decode(mcacd.cost_element_id,2,0,
         decode(mcacd.cost_element_id,5,0,(-1) * p_primary_quantity)) quantity,

        decode(mcacd.cost_element_id,2,0,
          decode(mcacd.cost_element_id,5,0,
                    (-1) * sum(mcacd.ACTUAL_COST) * p_primary_quantity)) raw_cost,

                        p_item_description expenditure_comment,
                        to_char(p_transaction_id) orig_transaction_reference,

        decode(mcacd.cost_element_id,2,0,
        decode(mcacd.cost_element_id,5,0,sum(mcacd.ACTUAL_COST))) raw_cost_rate,

                        'Y' unmatched_negative_txn_flag,
                        -999999 dr_code_combination_id,
                        -999999 cr_code_combination_id,
                        NULL cdl_system_reference1,
                        NULL cdl_system_reference2,
                        NULL cdl_system_reference3,
                        /*l_gl_date*/ /* Commented for bug 6266553 */ p_transaction_date gl_date,
                        l_source_proj_org_id org_id,
                (-1) * sum(mcacd.ACTUAL_COST)*p_primary_quantity burdened_cost,
                        sum(mcacd.ACTUAL_COST) burdened_cost_rate,

          decode(mcacd.cost_element_id,2, p_bur_syslink_literal,
           decode(mcacd.cost_element_id,3, p_wip_syslink_literal,
            decode(mcacd.cost_element_id,4, p_wip_syslink_literal,
             decode(mcacd.cost_element_id,5, p_bur_syslink_literal,
                                p_inv_syslink_literal)))) system_linkage,

                        'P' transaction_status_code,
                        mcacd.cost_element_id cost_element_id,
                        p_denom_currency_code denom_currency_code
                FROM         mtl_cst_actual_cost_details mcacd,
                        cst_cg_item_costs_view ccicv
                WHERE        mcacd.transaction_id  = p_transaction_id
                  AND         mcacd.organization_id = p_organization_id
                  AND   mcacd.inventory_item_id = p_inventory_item_id
                     AND         mcacd.actual_cost <> 0
                  AND   mcacd.layer_id = decode(p_primary_cost_method,
                                                 1, -1, ccicv.layer_id) --PJMSTD
                  AND         NOT EXISTS (
                          SELECT null
                            FROM mtl_actual_cost_subelement macs
                           WHERE macs.transaction_id =
                                        mcacd.transaction_id
                                   AND macs.organization_id  =
                                        mcacd.organization_id
                                 AND macs.cost_element_id =
                                                mcacd.cost_element_id
                                       AND macs.level_type = mcacd.level_type )
                  AND        ccicv.organization_id = p_organization_id
                  AND        ccicv.inventory_item_id = p_inventory_item_id
                  AND        ccicv.cost_group_id = decode(p_primary_cost_method,
                                                  1,1, p_cost_group_id) --PJMSTD
                GROUP BY mcacd.transaction_id,
                         mcacd.cost_element_id;

-- borrow / payback
  CURSOR c_sel_bp_txn IS
                SELECT        p_inv_txn_source_literal transaction_source,
                        l_batch batch_name,
                        l_exp_end_date expenditure_ending_date,
                        NULL employee_number,
                        l_organization_name organization_name,
                        p_transaction_date expenditure_item_date,
                        l_project_number project_number,
                        l_task_number task_number,
        decode(sign(p_primary_quantity),1, cceet.EXPENDITURE_TYPE_OUT,
               cceet.EXPENDITURE_TYPE_IN) expenditure_type,
-- bug 923134
          decode(mcacd.cost_element_id,
                 2,0,
                 5,0,p_primary_quantity) quantity,

          decode(mcacd.cost_element_id,
                 2,0,
                 5,0,
                 sum(mcacd.payback_variance_amount)* abs(p_primary_quantity))
                                                        raw_cost,
                        p_item_description expenditure_comment,
                        to_char(p_transaction_id) orig_transaction_reference,

          decode(mcacd.cost_element_id,
                 2,0,
                 5,0,
                 sum(mcacd.payback_variance_amount)) raw_cost_rate,
                        'Y' unmatched_negative_txn_flag,
                        -999999 dr_code_combination_id,
                        -999999 cr_code_combination_id,
                        NULL cdl_system_reference1,
                        NULL cdl_system_reference2,
                        NULL cdl_system_reference3,
                        /*l_gl_date*/ /* Commented for bug 6266553 */ p_transaction_date gl_date,
                        l_proj_org_id org_id,
                        sum(mcacd.payback_variance_amount)* abs(p_primary_quantity)
                                                        burdened_cost,
                          sum(mcacd.payback_variance_amount) burdened_cost_rate,

                  decode(mcacd.cost_element_id,2, p_bur_syslink_literal,
                   decode(mcacd.cost_element_id,3, p_wip_syslink_literal,
                    decode(mcacd.cost_element_id,4, p_wip_syslink_literal,
                     decode(mcacd.cost_element_id,5, p_bur_syslink_literal,
                                p_inv_syslink_literal)))) system_linkage,

                        'P' transaction_status_code ,
                        mcacd.cost_element_id cost_element_id,
                        p_denom_currency_code denom_currency_code
                  FROM         mtl_cst_actual_cost_details mcacd,
                        cst_cost_elem_exp_types cceet,
                        cst_cg_item_costs_view ccicv
                 WHERE        mcacd.transaction_id  = p_transaction_id
                   AND         mcacd.organization_id = p_organization_id
                AND         mcacd.inventory_item_id = p_inventory_item_id
                AND        mcacd.payback_variance_amount <> 0
                AND        mcacd.layer_id    = decode(p_primary_cost_method,
                                                1, -1, ccicv.layer_id) --PJMSTD
                AND        cceet.cost_element_id = mcacd.cost_element_id
                AND        ccicv.organization_id  = p_organization_id
                AND        ccicv.inventory_item_id = p_inventory_item_id
                AND        ccicv.cost_group_id = decode(p_primary_cost_method,
                                                1,1, p_cost_group_id) --PJMSTD
                      GROUP BY mcacd.transaction_id,
                             mcacd.cost_element_id,
                         cceet.expenditure_type_in,
                         cceet.expenditure_type_out;


-- borrow /payback end

  ----------------------------------------------------------------------------
  -- PJMSTD
  -- This Cursor is for PO and IO Organization of Standard Cost Organizations
  -- The PPV is passed to project under Inventory system linkage (Material)
  -- Need to see how this will work for IO transactions
  -- For IO MMT.Variance_amount will be NOT NULL depending on FOB Point
  ----------------------------------------------------------------------------

  CURSOR c_sel_ppv IS
                SELECT        decode(p_type_class,1,
                        p_cap_txn_source_literal,
                        p_inv_txn_source_literal) transaction_source,
                        l_batch batch_name,
                        l_exp_end_date expenditure_ending_date,
                        NULL employee_number,
                        decode(sign(p_primary_quantity),-1,
                                        decode(p_transaction_action_id,
                                                1, l_organization_name,
                                                29, l_organization_name, l_xfer_organization_name),
                                        l_organization_name) organization_name,
                        p_transaction_date expenditure_item_date,
                        decode(sign(p_primary_quantity),-1,
                                 decode(p_transaction_action_id,
                                 1, l_project_number,
                                 29, l_project_number, l_to_project_number),
                                 l_project_number) project_number,
                        decode(sign(p_primary_quantity),-1,
                                 decode(p_transaction_action_id,
                                 1, l_task_number,
                                 29, l_task_number, l_to_task_number),
                                 l_task_number) task_number,
                        nvl(ppp.ppv_expenditure_type, pop.ppv_expenditure_type) expenditure_type,
                        decode(sign(p_primary_quantity),-1,
                                decode(p_transaction_action_id,
                                1, p_primary_quantity,
                                29, p_primary_quantity, (-1)*p_primary_quantity),
                                p_primary_quantity) quantity,
                        mmt.variance_amount raw_cost,
                        p_item_description expenditure_comment,
                        decode(sign(p_primary_quantity),-1,
                                         decode(p_transaction_action_id,
                                         1, to_char(p_transaction_id),
                                         29, to_char(p_transaction_id),
					 21, to_char(p_transaction_id),
                                         to_char(p_transfer_transaction_id)),
                                        to_char(p_transaction_id)) orig_transaction_reference,
                        decode(sign(p_primary_quantity),-1,
                                        decode(p_transaction_action_id,
                                        1, mmt.variance_amount/p_primary_quantity,
                                        29, mmt.variance_amount/p_primary_quantity,
                                        (-1)*mmt.variance_amount/p_primary_quantity),
                                        mmt.variance_amount/p_primary_quantity) raw_cost_rate,
                        'Y' unmatched_negative_txn_flag,
                        -999999 dr_code_combination_id,
                        -999999 cr_code_combination_id,
                        NULL cdl_system_reference1,
                        NULL cdl_system_reference2,
                        NULL cdl_system_reference3,
                        /*l_gl_date*/ /* Commented for bug 6266553 */ p_transaction_date gl_date,
                        l_proj_org_id org_id,
                        mmt.variance_amount burdened_cost,
                        decode(sign(p_primary_quantity),-1,
                                         decode(p_transaction_action_id,
                                         1, mmt.variance_amount/p_primary_quantity,
                                         29, mmt.variance_amount/p_primary_quantity,
                                         (-1)* mmt.variance_amount/p_primary_quantity),
                                         mmt.variance_amount/p_primary_quantity) burdened_cost_rate,
                        p_inv_syslink_literal system_linkage,
                        'P' transaction_status_code ,
                        NULL cost_element_id,
                        p_denom_currency_code denom_currency_code
                  FROM         mtl_material_transactions mmt,
                        pjm_project_parameters ppp,
                        pjm_org_parameters pop
                 WHERE        mmt.transaction_id  = decode(ppv_txfr_flag,1, p_transfer_transaction_id,
                                                p_transaction_id)
                   AND         mmt.organization_id = decode(ppv_txfr_flag,1,p_transfer_organization_id,
                                                p_organization_id)
                AND        NVL(mmt.variance_amount,0) <> 0
                AND     pop.organization_id = decode(sign(p_primary_quantity),-1,
                                                decode( p_transaction_action_id,
                                                        1, p_organization_id,
                                                        29, p_organization_id,
                                                        p_transfer_organization_id),
                                                p_organization_id)
                AND         ppp.organization_id (+) = pop.organization_id
                AND     ppp.project_id (+) = decode(sign(p_primary_quantity),-1,
                                                decode( p_transaction_action_id,
                                                        1, p_project_id,
                                                        29, p_project_id, p_to_project_id),
                                                p_project_id);
    l_debug             VARCHAR2(80);

  BEGIN
        -- initialize local variables
        l_err_num := 0;
        l_err_code := '';
        l_err_msg := '';
        l_rownum := 0;
        l_fob_point := 0;
        l_earn_moh := 0;
        l_earn_tomoh := 0;
        l_stmt_num := 1;
        ppv_txfr_flag := 0;
        l_costed_flag := null;


        /* bug 3978501 Set the variables to 0 and 1 accordingly */
        l_no_row_c_sel_prj := 0;
        l_no_row_c_sel_toprj := 0;
        l_no_ppv := 1;


        l_debug := FND_PROFILE.VALUE('MRP_DEBUG');
        if (l_debug = 'Y') then
           FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Reached#: pm_process_txn_mmt ...');
           FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Transaction ID: '||to_char(p_transaction_id));
        end if;



        l_stmt_num := 05;

        -- bug #1036498, need to find out the costing method of the from org.
        -- bug 2095581, need pm_cost_collection_enabled flag for sending org.
        -- bug 3150050 staging Txfrs
        IF (p_transaction_action_id IN (2,3,12,28) ) THEN
             SELECT primary_cost_method, decode(pm_cost_collection_enabled, 1, 1, 0)
             INTO   l_primary_cost_method_snd, l_cost_collection_enabled_snd
             FROM   mtl_parameters
             WHERE  organization_id = p_transfer_organization_id ;
        END IF;

        -- Initialize the batch name as CC followed by group_id

        l_stmt_num := 10;
        -- Modified for Bug#2218654
        -- Changed for Bug #2260708. PA import fails when you use a 15 character
        -- batch name. Instead I am using the last 8 characters of the group id
        -- so the batch name remains less than 10 chars. The likelihood of two
        -- batch numbers being the same is very low.

        SELECT 'CC'|| substr( replace( lpad(
                      to_char(p_Group_Id,'9999999999999'),14,'0') ,' ','0'),-8)
        INTO l_batch
        FROM DUAL;



        -- Initialize local variable to be used in a decode later in the code,
        -- if  the transaction is of Misc Family

        l_stmt_num := 15;
        IF    p_transaction_action_id in (1,27)
          AND p_transaction_source_type_id in (3,13,6) THEN
                l_txn_of_misc_family := 1;
        ELSE
                l_txn_of_misc_family := 0;
        END IF;

        -- get exp ending date for the current transaction's transaction_date

        l_stmt_num := 16;
        select org_information3
        into l_operating_unit
        from hr_organization_information
        where organization_id = p_organization_id
        and org_information_context ='Accounting Information';

        l_stmt_num :=17;
        begin
         mo_global.set_policy_context('S',l_operating_unit);
        end;

        l_stmt_num := 20;

        l_exp_end_date := pa_utils.GetWeekEnding(p_transaction_date);

        IF l_exp_end_date is NULL THEN
                RAISE CST_FAILED_GET_EXPENDDATE;
        END IF;

        ----------------------------------------------------------------------
        -- bug 1036822
        -- get default project info;
           l_stmt_num := 20;
        -- bug 1291409, max is added to take care customer who
        -- does not have pjm installed but still wants to run cost collector
        ----------------------------------------------------------------------

         l_stmt_num := 25;

         SELECT max(pop.common_project_id)
         INTO l_default_project
         FROM pjm_org_parameters pop,
              mtl_material_transactions mmt
         WHERE pop.organization_id = mmt.organization_id
         AND mmt.transaction_id = p_transaction_id;

        ----------------------------------------------------------------------
        -- assign transaction org as expenditure org
        -- Bug: 1350945 Use hr_organization_units instead of
        -- hr_all_organization_units. hou is a view on top of
        -- haou and haou_tl (haou is a multilingual table, it shouldnt
        -- even have the translated column "name" as an attribute)
        ----------------------------------------------------------------------

        l_stmt_num := 30;
        SELECT         hou.name
          INTO         l_organization_name
          FROM         hr_organization_units hou
         WHERE         hou.organization_id = p_exp_org_id;

        --bug2623664

        l_stmt_num := 31;
        l_recv_iss_organization_name  := null ;
        IF ( (p_transaction_action_id = 27 OR p_transaction_action_id = 1 OR
              p_transaction_action_id = 6)
              AND p_type_class = 1 )  THEN
        SELECT  haou.name
        INTO    l_recv_iss_organization_name
        FROM    hr_all_organization_units haou
        WHERE   haou.organization_id = p_organization_id;
        END IF;


        /* For Dir IO Xfer with TO_PROJECT_ID Populated */
        l_stmt_num := 35;
        IF (p_transfer_organization_id IS NOT NULL
          AND p_transaction_action_id = 3 AND p_to_project_id IS NOT NULL) THEN
                SELECT         hou.name
                  INTO         l_xfer_organization_name
                  FROM         hr_organization_units hou
                 WHERE         hou.organization_id = p_transfer_organization_id;

                l_stmt_num := 40;

		 SELECT   currency_code
		 INTO     l_xfer_currency_code
		 FROM     cst_organization_definitions cod
		 WHERE    cod.organization_id = p_transfer_organization_id;

        END IF;

        ----------------------------------------------------------------------
        -- assign multi_org_id

        -- Get Proj/Task Numbers for Proj/Task ids.
        -- This is added because between the time the transaction was done
        -- and cost collection was run the Project/Task could have become
        -- Obsolete.  Therefore, we need to catch if there is an exception.

        -- ** Query from PJM_PROJECTS_V  and PJM_TASKS_V
        --instead of MTL_PROJECT_V bnd MTL_TASK_V because
        -- MTL_PROJECT_V shows only those projects that have been associated
        -- with a CG (in Project Parameters).  However, for Capital Txns
        -- we need all valid projects irrespective of whether they are
        -- set up in Project Parameters (PJM_PROJECT_PARAMETERS) or not.
        -- Refer to Bug# 571127 **
        ----------------------------------------------------------------------

        ----------------------------------------------------------------------
        -- MOAC Changes for R12:
        -- References to PJM_PROJECTS_V and PJM_TASKS_V has been removed and
        -- their base table pa_projects_all and pa_tasks are used instead.
        ----------------------------------------------------------------------

        BEGIN
                l_stmt_num := 45;
                IF p_project_id is NOT NULL then
                        SELECT         ppa.org_id,
                                       ppa.segment1 -- project number
                         INTO         l_proj_org_id,
                                      l_project_number
                         FROM         pa_projects_all ppa
                         WHERE        ppa.project_id = p_project_id;
 /*               l_stmt_num := 50;
                        SELECT  segment1 -- project number
                          INTO        l_project_number
                          FROM  pa_projects_all
                         WHERE         project_id = p_project_id; */
                l_stmt_num := 55;
                        SELECT  task_number
                          INTO        l_task_number
                          FROM  pa_tasks
                         WHERE         project_id = p_project_id
                           AND         task_id = p_task_id;
                END IF;

                l_stmt_num := 60;

                IF p_to_project_id is NOT NULL then
                        SELECT       ppa.org_id,
                                     ppa.segment1 -- project number
                        INTO         l_to_proj_org_id,
                                     l_to_project_number
                        FROM         pa_projects_all ppa
                        WHERE         ppa.project_id = p_to_project_id;
 /*               l_stmt_num := 65;
                        SELECT  segment1 -- project number
                          INTO        l_to_project_number
                          FROM  pa_projects_all
                         WHERE         project_id = p_to_project_id; */
                l_stmt_num := 70;
                        SELECT  task_number
                          INTO        l_to_task_number
                          FROM  pa_tasks
                         WHERE         project_id = p_to_project_id
                           AND         task_id = p_to_task_id;
                END IF;

                l_stmt_num := 75;
                IF p_source_project_id is NOT NULL then
                        SELECT     ppa.org_id,
                                   segment1
                        INTO       l_source_proj_org_id,
                                   l_source_project_number
                        FROM       pa_projects_all ppa
                        WHERE      ppa.project_id = p_source_project_id;
/*                l_stmt_num := 80;
                        SELECT  segment1 -- project number
                          INTO        l_source_project_number
                          FROM  pa_projects_all
                         WHERE         project_id = p_source_project_id; */
                l_stmt_num := 85;
                        SELECT  task_number
                          INTO        l_source_task_number
                          FROM  pa_tasks
                         WHERE         project_id = p_source_project_id
                           AND         task_id = p_source_task_id;
                END IF;
        EXCEPTION
        WHEN OTHERS THEN
                l_err_msg := SUBSTR(SQLERRM,1,200);
                RAISE CST_FAILED_PROJTSK_VALID;
        END;

        -- get FOB POINT for Intransit Transactions

        l_stmt_num := 90;

        -- Modified for fob stamping project
        IF (p_transfer_organization_id IS NOT NULL) THEN
           IF p_transaction_action_id = 21 THEN /* Intransit Shipment */
                  SELECT nvl(MMT.fob_point, MSNV.fob_point) INTO l_fob_point
                  FROM mtl_shipping_network_view MSNV, mtl_material_transactions MMT
                  WHERE MSNV.from_organization_id = p_organization_id
                  AND MSNV.to_organization_id = p_transfer_organization_id
                  AND MMT.transaction_id = p_transaction_id;
           ELSIF p_transaction_action_id = 12 THEN /* Intransit Receipt */
                  SELECT nvl(MMT.fob_point, MSNV.fob_point) INTO l_fob_point
                  FROM mtl_shipping_network_view MSNV, mtl_material_transactions MMT
                  WHERE MSNV.from_organization_id = p_transfer_organization_id
                  AND MSNV.to_organization_id = p_organization_id
                  AND MMT.transaction_id = p_transaction_id;
           END IF;

           -- PJMSTD

           l_stmt_num := 95;

           CST_Utility_Pub.GET_STD_CG_ACCT_FLAG
                           (p_api_version        =>  1.0,
                            p_organization_id    =>  p_transfer_organization_id,
                            x_cg_acct_flag       =>  l_std_cg_acct_snd,
                            x_return_status      =>  l_return_status,
                            x_msg_count          =>  l_msg_count,
                            x_msg_data           =>  l_msg_data );

           IF (l_return_status = FND_API.G_RET_STS_ERROR OR
            l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)

           THEN

             RAISE CST_FAILED_STD_CG_FLAG;

           END IF;


        END IF;

        -- get the schedule close date from acct_periods

        /* Commented for bug 6266553
        l_stmt_num := 100;
        SELECT        schedule_close_date
          INTO  l_gl_date
          FROM         org_acct_periods oac
         WHERE         oac.organization_id = p_organization_id
           AND         oac.acct_period_id = p_acct_period_id;*/

        ----------------------------------------------------------------------
        --This Select Statement is added to ascertain whether "This
        --Level MOH" is earned by the transaction.  If it is not
        --earned then there is no need to go through CURSOR
        --c_sel_moh_txn. It is necessary to
        --bypass the cursor if the transaction did not
        --earn "This Level MOH" (say no MOH subelements were
        --defaulted or defined for the item) because the Cursor then
        --raises the Exception NO_ROWS_TO_INSERT and abandons the txn.
        ----------------------------------------------------------------------

        l_stmt_num := 105;

        /* Bug #1944099. Only this level MOH costs are collected. */
        SELECT NVL(MAX(macs.transaction_id),-99)
        INTO l_earn_moh
        FROM mtl_actual_cost_subelement macs
        WHERE  macs.transaction_id = p_transaction_id
           AND macs.organization_id = p_organization_id
           AND macs.actual_cost <> 0
           AND macs.level_type = 1
           AND macs.cost_element_id = 2;

        /* If it is a direct interorg then check if the c_sel_tomoh has
           anything to insert */
        /* bug 4655264. Need to make sure that p_to_project_id is not nULL before transferring */
         l_stmt_num := 106;

        If (p_transaction_action_id = 3 AND p_to_project_id is not NULL) then
           select NVL(MAX(macs.transaction_id),-99)
           into l_earn_tomoh
           from mtl_actual_cost_subelement macs
           WHERE  macs.transaction_id = p_transfer_transaction_id
           AND macs.organization_id = p_transfer_organization_id
           AND macs.actual_cost <> 0
           AND macs.level_type = 1
           AND macs.cost_element_id = 2;

        else
          l_earn_tomoh := -99;

        end if;


        l_stmt_num := 110;
        SELECT transaction_type_id
          INTO l_txn_type
          FROM mtl_material_transactions
         WHERE transaction_id = p_transaction_id;

        l_stmt_num := 120;

        IF    (    p_primary_cost_method = 1
               AND p_type_class = 1
               AND p_std_cg_acct <> 1 --PJMSTD
              )
        THEN

              ----------------------------------------------------------------
                /* START:CC ALL ELE AS PER FROZEN COST IN STD COST ORG */

                -- All Transactions in a Standard Costing Organization with
                -- transaction type having its type_class set to 1 implying that
                -- it refers to a Capital Project.

                -- If no expenditure_type is specified at the time of txn
                -- CC will report elemental costs by deriving the default
                -- CE-ET associations defined in Costing SetUp.

                -- Check is added for std_cg_acct so that only std orgs that
                -- are not CG Acct enabled will use this cursor
              ----------------------------------------------------------------

                l_rownum   := 0;

                l_stmt_num := 125;

                if (l_debug = 'Y') then
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Processing Project Miscellaneous Transactions ...');
                end if;

                FOR c_rec1 IN c_sel_std_misc  LOOP

                    ----------------------------------------------------------
                    -- bug 888190
                    -- the condition is for capital project,
                    -- if expenditure type is user entered, get it from
                    -- p_expenditure_type otherwise derived it
                    -- from the system using cceet.
                    -- 0 System derived
                    -- 1 User Entered
                    ----------------------------------------------------------
                    l_stmt_num := 130;

                    IF (p_user_def_exp_type = 1) THEN

                      IF (p_expenditure_type is null) THEN

                        RAISE CST_FAILED_GET_EXP_TYPE;

                      ELSE

                        l_exp_type := p_expenditure_type;

                      END IF;

                    ELSE -- system derived

                      l_stmt_num := 135;

                      SELECT
                          DECODE(sign(p_primary_quantity),1,
                                 cceet.EXPENDITURE_TYPE_OUT,
                                 cceet.EXPENDITURE_TYPE_IN)
                      INTO l_exp_type
                      FROM cst_cost_elem_exp_types cceet
                      WHERE cceet.cost_element_id = c_rec1.cost_element_id;

                    END IF;

                    l_rownum := l_rownum + 1;

                    l_stmt_num := 140;

                    pm_insert_pti_pvt
                        (p_transaction_source         =>
                                             c_rec1.transaction_source,
                         p_batch_name                 =>c_rec1.batch_name,
                         p_expenditure_ending_date    =>
                                             c_rec1.expenditure_ending_date,
                         p_employee_number            =>c_rec1.employee_number,
                         p_organization_name          =>
                                             c_rec1.organization_name,
                         p_expenditure_item_date      =>
                                             c_rec1.expenditure_item_date,
                         p_project_number             =>c_rec1.project_number,
                         p_task_number                =>c_rec1.task_number,
                         p_expenditure_type           =>l_exp_type,
                         p_pa_quantity                =>c_rec1.quantity,
                         p_raw_cost                   =>c_rec1.raw_cost,
                         p_expenditure_comment        =>
                                             c_rec1.expenditure_comment,
                         p_orig_transaction_reference =>
                                             c_rec1.orig_transaction_reference,
                         p_raw_cost_rate              =>c_rec1.raw_cost_rate,
                         p_unmatched_negative_txn_flag=>
                                             c_rec1.unmatched_negative_txn_flag,
                         p_gl_date                    =>c_rec1.gl_date,
                         p_org_id                     =>c_rec1.org_id,
                         p_burdened_cost              =>c_rec1.burdened_cost,
                         p_burdened_cost_rate         =>
                                             c_rec1.burdened_cost_rate,
                         p_system_linkage             =>c_rec1.system_linkage,
                         p_transaction_status_code    =>
                                             c_rec1.transaction_status_code,
                         p_denom_currency_code        =>
                                             c_rec1.denom_currency_code,
                         p_transaction_id             =>p_transaction_id,

                         p_transaction_action_id      =>p_transaction_action_id,
                         p_transaction_source_type_id =>
                                             p_transaction_source_type_id,
                         p_organization_id            =>p_organization_id,
                         p_inventory_item_id          =>p_inventory_item_id,
                         p_cost_element_id            =>c_rec1.cost_element_id,
                         p_resource_id                =>NULL,
                         p_source_flag                =>1,
                         p_variance_flag              =>-1,
                         p_primary_quantity           =>p_primary_quantity ,
                         p_transfer_organization_id   =>
                                             p_transfer_organization_id,
                         p_fob_point                  =>l_fob_point,
                         p_wip_entity_id              =>NULL,
                         p_basis_resource             =>NULL,

                         p_type_class                 =>p_type_class,
                         p_project_id                 =>p_project_id,
                         p_task_id                    =>p_task_id,
                         p_transaction_date           =>p_transaction_date,
                         p_cost_group_id              =>p_cost_group_id,
                         p_transfer_cost_group_id     =>
                                             p_transfer_cost_group_id,
                         p_transaction_source_id      =>
                                             p_transaction_source_id,
                         p_to_project_id              =>p_to_project_id,
                         p_to_task_id                 =>p_to_task_id,
                         p_source_project_id          =>p_source_project_id,
                         p_source_task_id             =>p_source_task_id,
                         p_transfer_transaction_id    =>
                                             p_transfer_transaction_id,
                         p_primary_cost_method        =>p_primary_cost_method,
                         p_acct_period_id             =>p_acct_period_id,
                         p_exp_org_id                 =>p_exp_org_id,
                         p_distribution_account_id    =>
                                             p_distribution_account_id,
                         p_proj_job_ind               =>p_proj_job_ind,
                         p_first_matl_se_exp_type     =>
                                             p_first_matl_se_exp_type,
                         p_inv_txn_source_literal     =>
                                             p_inv_txn_source_literal,
                         p_cap_txn_source_literal     =>
                                             p_cap_txn_source_literal,
                         p_inv_syslink_literal        =>p_inv_syslink_literal,
                         p_bur_syslink_literal        =>p_bur_syslink_literal,
                         p_wip_syslink_literal        =>p_wip_syslink_literal,
                         p_user_def_exp_type          =>p_user_def_exp_type,
                         p_flow_schedule              =>p_flow_schedule,
                         p_si_asset_yes_no            =>p_si_asset_yes_no,
                         p_transfer_si_asset_yes_no   =>
                                             p_transfer_si_asset_yes_no,

                         O_err_num                    =>l_err_num,
                         O_err_code                   =>l_err_code,
                         O_err_msg                    =>l_err_msg
                     );

                    IF (l_err_num <> 0) THEN

                      RAISE CST_FAILED_INSERT_PTI;

                    END IF;

                END LOOP;

                IF l_rownum = 0 THEN

                  RAISE NO_ROWS_TO_INSERT;

                END IF;


              /* END: CC ALL ELE AS PER FROZEN COST IN STD COST ORG */

        ELSE
                /* START: CC ALL TXNS OF AN CGSTD + AVG COSTING ORG */



                                                          /*CC MO SE ET START*/

                -- CASE 1: Those Assy Completion/Rtn Transactions involving an
                --         Issue / Rtn from/to a Sub that project costed as 'Y'
                --           which implies that this level MO is reported on a
                --         SE basis.
                --
                -- CASE 2: Direct or Intransit receipt transactions into an
                --         asset SI of the receiving Organization irrespective
                --         of type of SI the shipment transaction refers to,
                --         imply that  this level MO is reported on a SE basis.
                --
                -- CASE 3: TXNS ARE: PO Delivery,adjustment,RTV
                --
                -- CASE 4: Consigned ownership transfer transactions
                --
/*
   QUESTION: Should CASE 3 restrict itself to the asset items and asset SI,
   as MO is earned or unearned only on a PO family transaction involving an
   asset item and an asset SI

   ADD INTERORG CONDITION if MO is to be earned only when receipt refers
   a asset sub-inventory and not if referring to an exp sub
        CONFIRMED BY JENNY that txns involving expense subs do not earn MO

   For both the questions above, the decision is to not make any explicit
   check in the CC code, since the Cost processor would create rows in
   macs for records only when above stated conditions are satisfied.
*/
                IF  (l_earn_moh <> -99)                        /* MOH was earned */
                    AND (
                           ( p_transaction_action_id in (31,32)  /* CASE 1 */
                              AND p_project_id is not null
                           )
                                   OR  p_transaction_action_id in (12,3)  /* CASE 2 */
                               OR  p_transaction_source_type_id = 1  /* CASE 3 */
                           OR  p_transaction_action_id = 6 /* CASE 4 ownership transfer transaction */
                        )
                THEN

                  l_rownum   := 0;

                  l_stmt_num := 145;

                  if (l_debug = 'Y') then
                     FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Collecting MOH costs ...');
                  end if;

                  FOR c_rec2 IN c_sel_moh_txn  LOOP

                    l_rownum := l_rownum + 1;

                    l_stmt_num := 150;

                    pm_insert_pti_pvt
                        (p_transaction_source         =>
                                             c_rec2.transaction_source,
                         p_batch_name                 =>c_rec2.batch_name,
                         p_expenditure_ending_date    =>
                                             c_rec2.expenditure_ending_date,
                         p_employee_number            =>c_rec2.employee_number,
                         p_organization_name          =>
                                             c_rec2.organization_name,
                         p_expenditure_item_date      =>
                                             c_rec2.expenditure_item_date,
                         p_project_number             =>c_rec2.project_number,
                         p_task_number                =>c_rec2.task_number,
                         p_expenditure_type           =>c_rec2.expenditure_type,
                         p_pa_quantity                =>c_rec2.quantity,
                         p_raw_cost                   =>c_rec2.raw_cost,
                         p_expenditure_comment        =>
                                             c_rec2.expenditure_comment,
                         p_orig_transaction_reference =>
                                             c_rec2.orig_transaction_reference,
                         p_raw_cost_rate              =>c_rec2.raw_cost_rate,
                         p_unmatched_negative_txn_flag=>
                                             c_rec2.unmatched_negative_txn_flag,
                         p_gl_date                    =>c_rec2.gl_date,
                         p_org_id                     =>c_rec2.org_id,
                         p_burdened_cost              =>c_rec2.burdened_cost,
                         p_burdened_cost_rate         =>
                                             c_rec2.burdened_cost_rate,
                         p_system_linkage             =>c_rec2.system_linkage,
                         p_transaction_status_code    =>
                                             c_rec2.transaction_status_code,
                         p_denom_currency_code        =>
                                             c_rec2.denom_currency_code,
                         p_transaction_id             =>p_transaction_id,

                         p_transaction_action_id      =>p_transaction_action_id,
                         p_transaction_source_type_id =>
                                             p_transaction_source_type_id,
                         p_organization_id            =>p_organization_id,
                         p_inventory_item_id          =>p_inventory_item_id,
                         p_cost_element_id            =>c_rec2.cost_element_id,
                         p_resource_id                =>c_rec2.resource_id,
                         p_source_flag                =>-1,
                         p_variance_flag              =>-1,
                         p_primary_quantity           =>p_primary_quantity ,
                         p_transfer_organization_id   =>
                                             p_transfer_organization_id,
                         p_fob_point                  =>l_fob_point,
                         p_wip_entity_id              =>NULL,
                         p_basis_resource             =>NULL,

                         p_type_class                 =>p_type_class,
                         p_project_id                 =>p_project_id,
                         p_task_id                    =>p_task_id,
                         p_transaction_date           =>p_transaction_date,
                         p_cost_group_id              =>p_cost_group_id,
                         p_transfer_cost_group_id     =>
                                             p_transfer_cost_group_id,
                         p_transaction_source_id      =>
                                             p_transaction_source_id,
                         p_to_project_id              =>p_to_project_id,
                         p_to_task_id                 =>p_to_task_id,
                         p_source_project_id          =>p_source_project_id,
                         p_source_task_id             =>p_source_task_id,
                         p_transfer_transaction_id    =>
                                             p_transfer_transaction_id,
                         p_primary_cost_method        =>p_primary_cost_method,
                         p_acct_period_id             =>p_acct_period_id,
                         p_exp_org_id                 =>p_exp_org_id,
                         p_distribution_account_id    =>
                                             p_distribution_account_id,
                         p_proj_job_ind               =>p_proj_job_ind,
                         p_first_matl_se_exp_type     =>
                                             p_first_matl_se_exp_type,
                         p_inv_txn_source_literal     =>
                                             p_inv_txn_source_literal,
                         p_cap_txn_source_literal     =>
                                             p_cap_txn_source_literal,
                         p_inv_syslink_literal        =>p_inv_syslink_literal,
                         p_bur_syslink_literal        =>p_bur_syslink_literal,
                         p_wip_syslink_literal        =>p_wip_syslink_literal,
                         p_user_def_exp_type          =>p_user_def_exp_type,
                         p_flow_schedule              =>p_flow_schedule,
                         p_si_asset_yes_no            =>p_si_asset_yes_no,
                         p_transfer_si_asset_yes_no   =>
                                             p_transfer_si_asset_yes_no,

                         O_err_num                    =>l_err_num,
                         O_err_code                   =>l_err_code,
                         O_err_msg                    =>l_err_msg
                     );

                    IF (l_err_num <> 0) THEN

                      RAISE CST_FAILED_INSERT_PTI;

                    END IF;

                  END LOOP;

                        IF l_rownum = 0 THEN

                    RAISE NO_ROWS_TO_INSERT;

                        END IF;

                END IF;  /*CC MO SE ET END*/

    /* Insert Material Overhead absorption for the receiving side in a direct
       interorg transaction */

     If (l_earn_tomoh <> -99 AND p_transaction_id <> -99 ) then

      FND_FILE.PUT_LINE(FND_FILE.LOG,'Collecting the MOH absorption on the receiving side');

             l_rownum := 0;

             For c_rec9 in c_sel_tomoh LOOP

                l_rownum := l_rownum + 1;

                l_stmt_num := 151;


          /* changes to support the Blue print organizations */

                  /* get the org ID on the transfer Txn */
                   select organization_id into l_org_id
                   from mtl_material_transactions
                   where transaction_id = c_rec9.orig_transaction_reference;

                 /* set the transaction source accordingly if the org is BP */

                    select NVL(pa_posting_flag,'N'),
                           NVL(pa_autoaccounting_flag,'N')
                    into l_blue_print_enabled_flag,
                         l_autoaccounting_flag
                    from pjm_org_parameters
                    where organization_id = l_org_id ;

            If l_blue_print_enabled_flag = 'Y' then

              FND_FILE.PUT_LINE(FND_FILE.LOG,'Blue print org ' || l_org_id);
               If l_autoaccounting_flag = 'Y' then

                    /* BP and autoaccounting  */
                    Select pts1.transaction_source,
                           pts1.transaction_source,
                           pts1.transaction_source
                     into  l_transaction_source,
                           l_inv_txn_src_literal,
                           l_cap_inv_txn_src_literal
                     From  pa_transaction_sources pts1
                    Where  pts1.transaction_source = 'PJM_CSTBP_INV_NO_ACCOUNTS';
                   If (l_transaction_source is NULL) then

                      RAISE CST_FAILED_TXN_SRC;

                   end If;
               else
               /* BP and no autoaccounting */
                    Select pts1.transaction_source,
                           pts1.transaction_source,
                           pts1.transaction_source
                     into  l_transaction_source,
                           l_inv_txn_src_literal,
                           l_cap_inv_txn_src_literal
                     From  pa_transaction_sources pts1
                    Where  pts1.transaction_source = 'PJM_CSTBP_INV_ACCOUNTS';

                       If (l_transaction_source is NULL ) then

                        RAISE CST_FAILED_TXN_SRC;

                       end If;
               end if; /* end of check for auto accounting */

             ELSE /* non BP org */

               SELECT   pts1.transaction_source,
                        pts1.transaction_source,
                        pts2.transaction_source
               INTO     l_inv_txn_src_literal,
                        l_transaction_source,
                        l_cap_inv_txn_src_literal
               FROM     pa_transaction_sources pts1,
                        pa_transaction_sources pts2
               WHERE  pts1.transaction_source = 'Inventory'
               AND  pts2.transaction_source = 'Inventory Misc';

             END IF; /* check for BP org */

             l_stmt_num := 152;

        /* Now call insert routine to insert into interface */

                    pm_insert_pti_pvt
                        (p_transaction_source         =>
                                             l_transaction_source,
                         p_batch_name                 =>c_rec9.batch_name,
                         p_expenditure_ending_date    =>
                                             c_rec9.expenditure_ending_date,
                         p_employee_number            =>c_rec9.employee_number,
                         p_organization_name          =>
                                             c_rec9.organization_name,
                         p_expenditure_item_date      =>
                                             c_rec9.expenditure_item_date,
                         p_project_number             =>c_rec9.project_number,
                         p_task_number                =>c_rec9.task_number,
                         p_expenditure_type           =>c_rec9.expenditure_type,
                         p_pa_quantity                =>c_rec9.quantity,
                         p_raw_cost                   =>c_rec9.raw_cost,
                         p_expenditure_comment        =>
                                             c_rec9.expenditure_comment,
                         p_orig_transaction_reference =>
                                             c_rec9.orig_transaction_reference,
                         p_raw_cost_rate              =>c_rec9.raw_cost_rate,
                         p_unmatched_negative_txn_flag=>
                                             c_rec9.unmatched_negative_txn_flag,
                         p_gl_date                    =>c_rec9.gl_date,
                         p_org_id                     =>c_rec9.org_id,
                         p_burdened_cost              =>c_rec9.burdened_cost,
                         p_burdened_cost_rate         =>
                                             c_rec9.burdened_cost_rate,
                         p_system_linkage             =>c_rec9.system_linkage,
                         p_transaction_status_code    =>
                                             c_rec9.transaction_status_code,
                         p_denom_currency_code        =>
                                             c_rec9.denom_currency_code,
                         p_transaction_id             =>p_transaction_id,
                         p_transaction_action_id      =>p_transaction_action_id,
                         p_transaction_source_type_id =>
                                             p_transaction_source_type_id,
                         p_organization_id            =>p_organization_id,
                         p_inventory_item_id          =>p_inventory_item_id,
                         p_cost_element_id            =>c_rec9.cost_element_id,
                         p_resource_id                =>c_rec9.resource_id,
                         p_source_flag                =>1,
                         p_variance_flag              =>-1,
                         p_primary_quantity           =>p_primary_quantity ,
                         p_transfer_organization_id   =>
                                             p_transfer_organization_id,
                         p_fob_point                  =>l_fob_point,
                         p_wip_entity_id              =>NULL,
                         p_basis_resource             =>NULL,
                         p_type_class                 =>p_type_class,
                         p_project_id                 =>p_project_id,
                         p_task_id                    =>p_task_id,
                         p_transaction_date           =>p_transaction_date,
                         p_cost_group_id              =>p_cost_group_id,
                         p_transfer_cost_group_id     =>
                                             p_transfer_cost_group_id,
                         p_transaction_source_id      =>
                                             p_transaction_source_id,
                         p_to_project_id              =>p_to_project_id,
                         p_to_task_id                 =>p_to_task_id,
                         p_source_project_id          =>p_source_project_id,
                         p_source_task_id             =>p_source_task_id,
                         p_transfer_transaction_id    =>
                                             p_transfer_transaction_id,
                         p_primary_cost_method        =>p_primary_cost_method,
                         p_acct_period_id             =>p_acct_period_id,
                         p_exp_org_id                 =>p_exp_org_id,
                         p_distribution_account_id    =>
                                             p_distribution_account_id,
                         p_proj_job_ind               =>p_proj_job_ind,
                         p_first_matl_se_exp_type     =>
                                             p_first_matl_se_exp_type,
                         p_inv_txn_source_literal     =>
                                             l_inv_txn_src_literal,
                         p_cap_txn_source_literal     =>
                                             l_cap_inv_txn_src_literal,
                         p_inv_syslink_literal        =>p_inv_syslink_literal,
                         p_bur_syslink_literal        =>p_bur_syslink_literal,
                         p_wip_syslink_literal        =>p_wip_syslink_literal,
                         p_user_def_exp_type          =>p_user_def_exp_type,
                         p_flow_schedule              =>p_flow_schedule,
                         p_si_asset_yes_no            =>p_si_asset_yes_no,
                         p_transfer_si_asset_yes_no   =>
                                             p_transfer_si_asset_yes_no,

                         O_err_num                    =>l_err_num,
                         O_err_code                   =>l_err_code,
                         O_err_msg                    =>l_err_msg
                     );

                    IF (l_err_num <> 0) THEN

                      RAISE CST_FAILED_INSERT_PTI;

                    END IF;

                  END LOOP;

                  l_stmt_num := 154;

                        IF l_rownum = 0 THEN

                    RAISE NO_ROWS_TO_INSERT;

                        END IF;

   END IF; /* end of check for l_earn_tomoh */

                --------------------------------------------------------------
                -- CASE 0: All Transactions having the SI as project costed 'Y'
                --           Misc Family Transactions referring a Proj SI
                --           PO Family referring Proj SI
                --           WIP Component Issue/Rtn referring a Proj SI
                --           Issue side of a Sub-Trf referring a Proj SI
                --                                        ( only neg Txn )
                --           Cycle Count referring a Proj SI
                --           Physical Inv referring a Proj SI
                --           Issue side of Direct Org Trf referring a Proj SI
                --           Receipt side of Direct Org Trf referring a Proj SI
                --           Issue/Receipt side of Inter Org Trf referring a Proj
                --           SI and being cost collected Organization
                --
                --         Exclude all Assy Completion and Returns that have
                --         both the Job and SI as Project Costed 'Y' in which
                --         case one needs earn only the MO earnings. The same
                --         is being taken care in the previous IF statement.
                --
                -- CASE 1: Those Assy Completion/Rtn Transactions involving an
                --         Issue / Rtn from/to a Sub that project costed as 'Y'
                --         and the job as not to be project costed which
                --           implies that this level MO is reported on a SE basis
                --           and all the elements other than this level MO
                --         are reported elementally.
                --

                -- It is assumed that cost_element_id will not be null in
                -- mta for accounting_line_type = 1 for an average cost org.
                --------------------------------------------------------------


                --------------------------------------------------------------
                -- this part is added for bug 1036822
                -- this if statement is one level higher
                -- then the older code because
                -- it is trying to exclude the
                -- DEFAULT PROJECT ASSEMBLY COMPLETION/RETURN
                -- transactions which would be pick up by CASE 0 in the follow.
                -- so this one level higher if statement will exclude those
                -- transaction before it got picked up by CASE 0
                -- bug#1036498
                -- For Direct Interorg trf , sending org is std
                --(no cost collection enabled,
                -- proj ref enab)
                -- and recv org is average  (cc enabled , proj ref enabled)
                -- then can trf
                -- betwn same proj and task.
                -- Because cost collection is disabled from sending org,
                -- so cost collection
                -- has to be done on the receiving org.
                ---------------------------------------------------------------

                ---------------------------------------------------------------
                -- for bug 781967, make sure that txn within the same project
                -- will not get posted into pa_transaction_interface_all
                -- bug 862689
                -- bug 1036822
                -- with DEFAULT
                -- PROJECT OPTION set, the WIP COMPLETION from a common job
                -- does notget pick up by cost collector.
                ---------------------------------------------------------------

                IF NOT(    l_default_project is not null
                  AND p_transaction_action_id in (31,32)
                  AND p_proj_job_ind = 0)
                THEN


                  l_stmt_num := 155;
                -- Bug 2095581
                -- In case of an interorg transfer,
                -- Cost Collection is done if sending organization in the
                -- interorg transfer is not cost collection enabled.

                /* Bug #2349027. Interorg transfers should be cost collected
                   even if the project_id = to_project_id because expenditure
                   orgs are different. */

                  IF    ((p_transaction_action_id in (3,12,21) and
                          p_project_id is not null)
                              -- p_to_project_id is not null  and
                       -- l_cost_collection_enabled_snd <> 1)
                       -- l_primary_cost_method_snd = 1)
                      OR
                      --bug#1036498
                      (    p_project_id is not null     /* CASE 0 */
                       AND NOT (    p_transaction_action_id in (31,32)
                                AND p_project_id is not null
                                AND p_proj_job_ind = 1
                               )
                       AND NOT( p_project_id = nvl(p_to_project_id,-9)
                                and p_task_id = nvl(p_to_task_id,-9)
                              )
                      )
                      OR
                      /* Consigned ownership trasfers */
                      ( p_project_id is not null
                         AND p_transaction_action_id = 6)

                      /* changes for the PJM Blue print project and drop ship*/
                      OR
                      ( p_project_id is not null
                        AND p_transaction_action_id = 26
                      )

                         OR (    p_transaction_action_id in (31,32)
                       AND p_project_id is not null
                       AND p_proj_job_ind = 0        /* CASE 1 */
                       AND l_default_project is NULL
                      ))
                  THEN
                        /* CC ELE ET START INCLUSIVE OF All Filetered 31,32*/

                    l_rownum   := 0;


                    /* bug 3978501 */
                    l_no_row_c_sel_prj := 0;

                    l_stmt_num := 160;


                    if (l_debug = 'Y') then
                       FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Collecting Project related Locator txn costs ...');
                    end if;

                    FOR c_rec3 IN c_sel_prj_txn  LOOP

                      --------------------------------------------------------
                      -- bug 888190
                      -- if it is capital project and expenditure type
                      -- is user entered,
                      -- then get it from p_expenditure_type
                      -- otherwise derived it from the system using cceet.
                      -- proj. misc txn with user entered expenditure type
                      -- p_user_def_exp_type: 0 is system derived,
                      -- 1 is user entered
                      --------------------------------------------------------

                      IF (p_type_class = 1) and (p_user_def_exp_type = 1) THEN

                        IF (p_expenditure_type is null) THEN

                         RAISE CST_FAILED_GET_EXP_TYPE;

                        ELSE

                         l_exp_type := p_expenditure_type;

                        END IF;

                      ELSE

                        l_stmt_num := 165;
                        IF p_transaction_action_id = 17 THEN
                          SELECT
                            EXPENDITURE_TYPE
                          INTO
                            l_exp_type
                          FROM
                            MTL_MATERIAL_TRANSACTIONS
                          WHERE
                              transaction_id = p_transaction_id;
                        ELSE
                          SELECT
                            decode(c_rec3.cost_element_id,1,
                              decode(p_transaction_source_type_id,1,
                                             p_first_matl_se_exp_type,
                                decode(sign(p_primary_quantity),1,
                                  cceet.EXPENDITURE_TYPE_IN,
                                  cceet.EXPENDITURE_TYPE_OUT)),
                              decode(sign(p_primary_quantity),1,
                                cceet.EXPENDITURE_TYPE_IN,
                                cceet.EXPENDITURE_TYPE_OUT))
                          INTO l_exp_type
                          FROM cst_cost_elem_exp_types cceet
                          WHERE cceet.cost_element_id = c_rec3.cost_element_id;
                        END IF; -- action_id = 7

                      END IF;

                      l_rownum := l_rownum + 1;

                      l_stmt_num := 170;


                   If c_rec3.burdened_cost = 0 then
                      fnd_file.put_line(fnd_file.log,'Burdened cost is zero');
                   end if;

                   If c_rec3.burdened_cost <> 0 then

                      pm_insert_pti_pvt
                        (p_transaction_source         =>
                                             c_rec3.transaction_source,
                         p_batch_name                 =>c_rec3.batch_name,
                         p_expenditure_ending_date    =>
                                             c_rec3.expenditure_ending_date,
                         p_employee_number            =>c_rec3.employee_number,
                         p_organization_name          =>
                                            NVL(l_recv_iss_organization_name,
                                             c_rec3.organization_name),
                         p_expenditure_item_date      =>
                                             c_rec3.expenditure_item_date,
                         p_project_number             =>c_rec3.project_number,
                         p_task_number                =>c_rec3.task_number,
                         p_expenditure_type           =>l_exp_type,
                         p_pa_quantity                =>c_rec3.quantity,
                         p_raw_cost                   =>c_rec3.raw_cost,
                         p_expenditure_comment        =>
                                             c_rec3.expenditure_comment,
                         p_orig_transaction_reference =>
                                             c_rec3.orig_transaction_reference,
                         p_raw_cost_rate              =>c_rec3.raw_cost_rate,
                         p_unmatched_negative_txn_flag=>
                                             c_rec3.unmatched_negative_txn_flag,
                         p_gl_date                    =>c_rec3.gl_date,
                         p_org_id                     =>c_rec3.org_id,
                         p_burdened_cost              =>c_rec3.burdened_cost,
                         p_burdened_cost_rate         =>
                                             c_rec3.burdened_cost_rate,
                         p_system_linkage             =>c_rec3.system_linkage,
                         p_transaction_status_code    =>
                                             c_rec3.transaction_status_code,
                         p_denom_currency_code        =>
                                             c_rec3.denom_currency_code,
                         p_transaction_id             =>p_transaction_id,

                         p_transaction_action_id      =>p_transaction_action_id,
                         p_transaction_source_type_id =>
                                             p_transaction_source_type_id,
                         p_organization_id            =>p_organization_id,
                         p_inventory_item_id          =>p_inventory_item_id,
                         p_cost_element_id            =>c_rec3.cost_element_id,
                         p_resource_id                =>NULL,
                         p_source_flag                =>-1,
                         p_variance_flag              =>-1,
                         p_primary_quantity           =>p_primary_quantity ,
                         p_transfer_organization_id   =>
                                             p_transfer_organization_id,
                         p_fob_point                  =>l_fob_point,
                         p_wip_entity_id              =>NULL,
                         p_basis_resource             =>NULL,

                         p_type_class                 =>p_type_class,
                         p_project_id                 =>p_project_id,
                         p_task_id                    =>p_task_id,
                         p_transaction_date           =>p_transaction_date,
                         p_cost_group_id              =>p_cost_group_id,
                         p_transfer_cost_group_id     =>
                                             p_transfer_cost_group_id,
                         p_transaction_source_id      =>
                                             p_transaction_source_id,
                         p_to_project_id              =>p_to_project_id,
                         p_to_task_id                 =>p_to_task_id,
                         p_source_project_id          =>p_source_project_id,
                         p_source_task_id             =>p_source_task_id,
                         p_transfer_transaction_id    =>
                                             p_transfer_transaction_id,
                         p_primary_cost_method        =>p_primary_cost_method,
                         p_acct_period_id             =>p_acct_period_id,
                         p_exp_org_id                 =>p_exp_org_id,
                         p_distribution_account_id    =>
                                             p_distribution_account_id,
                         p_proj_job_ind               =>p_proj_job_ind,
                         p_first_matl_se_exp_type     =>
                                             p_first_matl_se_exp_type,
                         p_inv_txn_source_literal     =>
                                             p_inv_txn_source_literal,
                         p_cap_txn_source_literal     =>
                                             p_cap_txn_source_literal,
                         p_inv_syslink_literal        =>p_inv_syslink_literal,
                         p_bur_syslink_literal        =>p_bur_syslink_literal,
                         p_wip_syslink_literal        =>p_wip_syslink_literal,
                         p_user_def_exp_type          =>p_user_def_exp_type,
                         p_flow_schedule              =>p_flow_schedule,
                         p_si_asset_yes_no            =>p_si_asset_yes_no,
                         p_transfer_si_asset_yes_no   =>
                                             p_transfer_si_asset_yes_no,

                         O_err_num                    =>l_err_num,
                         O_err_code                   =>l_err_code,
                         O_err_msg                    =>l_err_msg
                     );

                      IF (l_err_num <> 0) THEN

                        RAISE CST_FAILED_INSERT_PTI;

                      END IF;

                    END IF; /* end of check for burdened cost to be 0 */

                    END LOOP;

                          IF l_rownum = 0 THEN

                    /* bug 3978501 commenting out the excpetion raise as there maybe PPV to insert */

                     /* RAISE NO_ROWS_TO_INSERT; */
                    l_no_row_c_sel_prj := 1;

                          END IF;

                  END IF;

                END IF;  -- bug 1036822

                ---------------------------------------------------------------
                -- for bug 781967, make sure that txn within the same
                -- project won't
                -- get posted into pa_transaction_interface_all
                -- bug 930565, added nvl to take care sub-inventory transaction
                -- from common subinventory to project subinventory
                ---------------------------------------------------------------

                IF    (-- p_transaction_action_id IN (2 , 3)
                              p_to_project_id is not null         /* CASE 0 */
                       AND ((p_transaction_action_id = 2
                            AND NOT( nvl(p_project_id,-9) = p_to_project_id
                                     and nvl(p_task_id,-9) = p_to_task_id
                                   )
                            )
                            OR
                            p_transaction_action_id = 3
                          /* bug fix for bug 3150050 */
                            OR
                            p_transaction_action_id = 28
                           )
                            )
                THEN
                                   /* CC ELE ET START FILTERED 2 TRFSIDE */

                        ------------------------------------------------------
                        -- CASE 0: All Transactions having the TRF SI as
                        --         project costed 'Y' . Transaction is looked
                        --         from the receiving SI perspective. The SI
                        --         would be the Transfer SI for a -ve qty Txn.
                        --         Only the -ve qty txns are picked since the
                        --         is based on them and not the +ve ones.
                        --
                        -- Direct IO Xfer with TO_PROJECT NOT NULL
                        ------------------------------------------------------

                  l_rownum   := 0;

                 /* bug 3978501 set the variable to 0 to start off */

                  l_no_row_c_sel_toprj := 0;

                  l_stmt_num := 175;

                  if (l_debug = 'Y') then
                     FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Collecting Transfer Side Locator Project costs ...');
                  end if;

            FOR c_rec4 IN c_sel_toprj_txn  LOOP

                    l_rownum := l_rownum + 1;
                    /* Get Expenditure Type from MMT for Internal SO
                       Issue and Receipt to Expense */
                    l_stmt_num := 177;

                    IF( ( p_transaction_action_id = 1 AND p_transaction_source_type_id = 8 )
                        OR p_transaction_action_id = 17 ) THEN
                      SELECT EXPENDITURE_TYPE
                      INTO   c_rec4.EXPENDITURE_TYPE
                      FROM   MTL_MATERIAL_TRANSACTIONS
                      WHERE  transaction_id = p_transaction_id;
                    END IF;

                    l_stmt_num := 180;

        /* changes to support the Blue print organizations */

                  /* get the org ID on the transfer Txn */
                   select organization_id into l_org_id
                   from mtl_material_transactions
                   where transaction_id = c_rec4.orig_transaction_reference;

                 /* set the transaction source accordingly if the org is BP */

                    select NVL(pa_posting_flag,'N'),
                           NVL(pa_autoaccounting_flag,'N')
                    into l_blue_print_enabled_flag,
                         l_autoaccounting_flag
                    from pjm_org_parameters
                    where organization_id = l_org_id ;

          If l_blue_print_enabled_flag = 'Y' then

               If l_autoaccounting_flag = 'Y' then

                    /* BP and autoaccounting  */
                    Select pts1.transaction_source,
                           pts1.transaction_source,
                           pts1.transaction_source
                     into  l_transaction_source,
                           l_inv_txn_src_literal,
                           l_cap_inv_txn_src_literal
                     From  pa_transaction_sources pts1
                    Where  pts1.transaction_source = 'PJM_CSTBP_INV_NO_ACCOUNTS';
                   If (l_transaction_source is NULL) then

                      RAISE CST_FAILED_TXN_SRC;

                   end If;
               else

                    /* BP and no autoaccounting */
                    Select pts1.transaction_source,
                           pts1.transaction_source,
                           pts1.transaction_source
                     into  l_transaction_source,
                           l_inv_txn_src_literal,
                           l_cap_inv_txn_src_literal
                     From  pa_transaction_sources pts1
                    Where  pts1.transaction_source = 'PJM_CSTBP_INV_ACCOUNTS';

                       If (l_transaction_source is NULL ) then

                        RAISE CST_FAILED_TXN_SRC;

                       end If;
               end if; /* end of check for auto accounting */

           ELSE /* non BP org */

               SELECT   pts1.transaction_source,
                        pts1.transaction_source,
                        pts2.transaction_source
               INTO     l_inv_txn_src_literal,
                        l_transaction_source,
                        l_cap_inv_txn_src_literal
               FROM     pa_transaction_sources pts1,
                        pa_transaction_sources pts2
               WHERE  pts1.transaction_source = 'Inventory'
               AND  pts2.transaction_source = 'Inventory Misc';

          END IF; /* check for BP org */

                If c_rec4.burdened_cost = 0 then
                 fnd_file.put_line(fnd_file.log,'Burdened cost is zero');
                end if;

                If c_rec4.burdened_cost <> 0 then

                    pm_insert_pti_pvt
                        (p_transaction_source         =>
                                             l_transaction_source,
                         p_batch_name                 =>c_rec4.batch_name,
                         p_expenditure_ending_date    =>
                                             c_rec4.expenditure_ending_date,
                         p_employee_number            =>c_rec4.employee_number,
                         p_organization_name          =>
                                             c_rec4.organization_name,
                         p_expenditure_item_date      =>
                                             c_rec4.expenditure_item_date,
                         p_project_number             =>c_rec4.project_number,
                         p_task_number                =>c_rec4.task_number,
                         p_expenditure_type           =>c_rec4.expenditure_type,
                         p_pa_quantity                =>c_rec4.quantity,
                         p_raw_cost                   =>c_rec4.raw_cost,
                         p_expenditure_comment        =>
                                             c_rec4.expenditure_comment,
                         p_orig_transaction_reference =>
                                             c_rec4.orig_transaction_reference,
                         p_raw_cost_rate              =>c_rec4.raw_cost_rate,
                         p_unmatched_negative_txn_flag=>
                                             c_rec4.unmatched_negative_txn_flag,
                         p_gl_date                    =>c_rec4.gl_date,
                         p_org_id                     =>c_rec4.org_id,
                         p_burdened_cost              =>c_rec4.burdened_cost,
                         p_burdened_cost_rate         =>
                                             c_rec4.burdened_cost_rate,
                         p_system_linkage             =>c_rec4.system_linkage,
                         p_transaction_status_code    =>
                                             c_rec4.transaction_status_code,
                         p_denom_currency_code        =>
                                             c_rec4.denom_currency_code,
                         p_transaction_id             =>p_transaction_id,

                         p_transaction_action_id      =>p_transaction_action_id,
                         p_transaction_source_type_id =>
                                             p_transaction_source_type_id,
                         p_organization_id            =>p_organization_id,
                         p_inventory_item_id          =>p_inventory_item_id,
                         p_cost_element_id            =>c_rec4.cost_element_id,
                         p_resource_id                =>NULL,
                         p_source_flag                =>1,
                         p_variance_flag              =>-1,
                         p_primary_quantity           =>p_primary_quantity ,
                         p_transfer_organization_id   =>
                                             p_transfer_organization_id,
                         p_fob_point                  =>l_fob_point,
                         p_wip_entity_id              =>NULL,
                         p_basis_resource             =>NULL,

                         p_type_class                 =>p_type_class,
                         p_project_id                 =>p_project_id,
                         p_task_id                    =>p_task_id,
                         p_transaction_date           =>p_transaction_date,
                         p_cost_group_id              =>p_cost_group_id,
                         p_transfer_cost_group_id     =>
                                             p_transfer_cost_group_id,
                         p_transaction_source_id      =>
                                             p_transaction_source_id,
                         p_to_project_id              =>p_to_project_id,
                         p_to_task_id                 =>p_to_task_id,
                         p_source_project_id          =>p_source_project_id,
                         p_source_task_id             =>p_source_task_id,
                         p_transfer_transaction_id    =>
                                             p_transfer_transaction_id,
                         p_primary_cost_method        =>p_primary_cost_method,
                         p_acct_period_id             =>p_acct_period_id,
                         p_exp_org_id                 =>p_exp_org_id,
                         p_distribution_account_id    =>
                                             p_distribution_account_id,
                         p_proj_job_ind               =>p_proj_job_ind,
                         p_first_matl_se_exp_type     =>
                                             p_first_matl_se_exp_type,
                         p_inv_txn_source_literal     =>
                                             l_inv_txn_src_literal,
                         p_cap_txn_source_literal     =>
                                             l_cap_inv_txn_src_literal,
                         p_inv_syslink_literal        =>p_inv_syslink_literal,
                         p_bur_syslink_literal        =>p_bur_syslink_literal,
                         p_wip_syslink_literal        =>p_wip_syslink_literal,
                         p_user_def_exp_type          =>p_user_def_exp_type,
                         p_flow_schedule              =>p_flow_schedule,
                         p_si_asset_yes_no            =>p_si_asset_yes_no,
                         p_transfer_si_asset_yes_no   =>
                                             p_transfer_si_asset_yes_no,

                         O_err_num                    =>l_err_num,
                         O_err_code                   =>l_err_code,
                         O_err_msg                    =>l_err_msg
                     );

                    IF (l_err_num <> 0) THEN

                      RAISE CST_FAILED_INSERT_PTI;

                    END IF;

                 END IF; /* End of check for burdened cost to be 0 */

                  END LOOP;

                        IF l_rownum = 0 THEN
                    /* Bug 2386069
                       If the receiving txn has not been costed yet, update MMT with a
                      warning but do not reset the pm_cost_collected flag to error.
                     */
                    SELECT mmt.costed_flag
                    INTO   l_costed_flag
                    FROM   mtl_material_transactions mmt
                    WHERE  mmt.transaction_id  = decode(p_transaction_action_id,
                                                3, p_transfer_transaction_id ,
                                                p_transaction_id)
                    AND   mmt.organization_id = decode(p_transaction_action_id,
                                                3, p_transfer_organization_id,
                                                p_organization_id);

                    IF (l_costed_flag = 'N') THEN
                       if (l_debug = 'Y') then
                         fnd_file.put_line(fnd_file.log, 'Receving Txn not yet costed!!!!');
                       end if;
                       RAISE ROW_NOT_COSTED;
                    ELSE

                     /* bug 3978501 commenting out the excpetion part as there may be PPV to insert */

                     /* RAISE NO_ROWS_TO_INSERT; */
                     l_no_row_c_sel_toprj := 1;

                    END IF;

                        END IF;

                END IF; /* CC ALL ELE ET START FILTERED 2 TRFSIDE */

                ---------------------------------------------------------------
                    /* CC ALL ELE ET START FILTERED WIPCompIss/Rtn,31,32 TRFSIDE */

                        -- CASE 1: All WIP/CFM Issue/Return and -ve WIP/CFM
                        --         Issue/Return Transactions having the
                        --         JOB as project costed 'Y', imply their CC
                        --         w.r.t the source project and task
                        --
                        -- CASE 2: All Transactions having the JOB/CFM project
                        --         costed 'Y' and SI as project costed 'N' ,
                        --         belonging to group of WIP Assy Completion
                        --         or Returns, implying their CC w.r.t the
                        --           source project and task
                        --
                        -- CASE 3: All Misc Family Transactions belonging to
                        --         Capital Project transaction type
                        --         ( User given project and task information
                        --           at transaction time are stored in the
                        --           source project and source task fields )
                        --          If user does not specify an expenditure_type
                        --          the default associations will be used.
                        --
                        -- NOTE: The Cost Group being used is cost_group_id and
                        --       the transfer_cost_group_id although the project
                        --       and task being used are source project and
                        --       source task, because MCACD has one for the Txn
                        --       and that is w.r.t the SI's cost_group
                        --
                ---------------------------------------------------------------


                IF    (    p_transaction_action_id in (1,27,33,34)
                              AND p_transaction_source_type_id = 5
                              AND p_proj_job_ind = 1            /* CASE 1 */
                      )
                      OR (    p_transaction_action_id in (31,32)
                              AND p_transaction_source_type_id = 5
                       AND p_project_id is null
                       AND p_proj_job_ind = 1            /* CASE 2 */
                      )
                   OR (p_type_class = 1)                 /* CASE 3 */

                THEN

                  l_rownum   := 0;

                  l_stmt_num := 185;

                  if (l_debug = 'Y') then
                     FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Collecting source side project costs ...');
                  end if;

                  FOR c_rec5 IN c_sel_src_txn  LOOP

                    ---------------------------------------------------------
                    -- bug 888190
                    -- if it is capital project and expenditure type is user
                    -- entered,
                    -- then get it from p_expenditure_type
                    -- otherwise derived it from the system using cceet.
                    ---------------------------------------------------------

                    IF (p_type_class = 1) and (p_user_def_exp_type = 1) THEN

                      -- proj. misc txn with user entered expenditure type
                      -- p_user_def_exp_type: 0 is system derived,
                      -- 1 is user entered

                      IF (p_expenditure_type is null) THEN

                         RAISE CST_FAILED_GET_EXP_TYPE;

                      ELSE

                         l_exp_type := p_expenditure_type;

                      END IF;

                    ELSE

                      SELECT
                         decode(sign(p_primary_quantity),1,
                                cceet.EXPENDITURE_TYPE_OUT,
                         cceet.EXPENDITURE_TYPE_IN)
                      INTO l_exp_type
                      FROM cst_cost_elem_exp_types cceet
                      WHERE cceet.cost_element_id = c_rec5.cost_element_id;

                    END IF;

                    l_rownum := l_rownum + 1;

                    l_stmt_num := 190;

                    pm_insert_pti_pvt
                        (p_transaction_source         =>
                                             c_rec5.transaction_source,
                         p_batch_name                 =>c_rec5.batch_name,
                         p_expenditure_ending_date    =>
                                             c_rec5.expenditure_ending_date,
                         p_employee_number            =>c_rec5.employee_number,
                         p_organization_name          =>
                                             c_rec5.organization_name,
                         p_expenditure_item_date      =>
                                             c_rec5.expenditure_item_date,
                         p_project_number             =>c_rec5.project_number,
                         p_task_number                =>c_rec5.task_number,
                         p_expenditure_type           =>l_exp_type,
                         p_pa_quantity                =>c_rec5.quantity,
                         p_raw_cost                   =>c_rec5.raw_cost,
                         p_expenditure_comment        =>
                                             c_rec5.expenditure_comment,
                         p_orig_transaction_reference =>
                                             c_rec5.orig_transaction_reference,
                         p_raw_cost_rate              =>c_rec5.raw_cost_rate,
                         p_unmatched_negative_txn_flag=>
                                             c_rec5.unmatched_negative_txn_flag,
                         p_gl_date                    =>c_rec5.gl_date,
                         p_org_id                     =>c_rec5.org_id,
                         p_burdened_cost              =>c_rec5.burdened_cost,
                         p_burdened_cost_rate         =>
                                             c_rec5.burdened_cost_rate,
                         p_system_linkage             =>c_rec5.system_linkage,
                         p_transaction_status_code    =>
                                             c_rec5.transaction_status_code,
                         p_denom_currency_code        =>
                                             c_rec5.denom_currency_code,
                         p_transaction_id             =>p_transaction_id,

                         p_transaction_action_id      =>p_transaction_action_id,
                         p_transaction_source_type_id =>
                                             p_transaction_source_type_id,
                         p_organization_id            =>p_organization_id,
                         p_inventory_item_id          =>p_inventory_item_id,
                         p_cost_element_id            =>c_rec5.cost_element_id,
                         p_resource_id                =>NULL,
                         p_source_flag                =>1,
                         p_variance_flag              =>-1,
                         p_primary_quantity           =>p_primary_quantity ,
                         p_transfer_organization_id   =>
                                             p_transfer_organization_id,
                         p_fob_point                  =>l_fob_point,
                         p_wip_entity_id              =>NULL,
                         p_basis_resource             =>NULL,

                         p_type_class                 =>p_type_class,
                         p_project_id                 =>p_project_id,
                         p_task_id                    =>p_task_id,
                         p_transaction_date           =>p_transaction_date,
                         p_cost_group_id              =>p_cost_group_id,
                         p_transfer_cost_group_id     =>
                                             p_transfer_cost_group_id,
                         p_transaction_source_id      =>
                                             p_transaction_source_id,
                         p_to_project_id              =>p_to_project_id,
                         p_to_task_id                 =>p_to_task_id,
                         p_source_project_id          =>p_source_project_id,
                         p_source_task_id             =>p_source_task_id,
                         p_transfer_transaction_id    =>
                                             p_transfer_transaction_id,
                         p_primary_cost_method        =>p_primary_cost_method,
                         p_acct_period_id             =>p_acct_period_id,
                         p_exp_org_id                 =>p_exp_org_id,
                         p_distribution_account_id    =>
                                             p_distribution_account_id,
                         p_proj_job_ind               =>p_proj_job_ind,
                         p_first_matl_se_exp_type     =>
                                             p_first_matl_se_exp_type,
                         p_inv_txn_source_literal     =>
                                             p_inv_txn_source_literal,
                         p_cap_txn_source_literal     =>
                                             p_cap_txn_source_literal,
                         p_inv_syslink_literal        =>p_inv_syslink_literal,
                         p_bur_syslink_literal        =>p_bur_syslink_literal,
                         p_wip_syslink_literal        =>p_wip_syslink_literal,
                         p_user_def_exp_type          =>p_user_def_exp_type,
                         p_flow_schedule              =>p_flow_schedule,
                         p_si_asset_yes_no            =>p_si_asset_yes_no,
                         p_transfer_si_asset_yes_no   =>
                                             p_transfer_si_asset_yes_no,

                         O_err_num                    =>l_err_num,
                         O_err_code                   =>l_err_code,
                         O_err_msg                    =>l_err_msg
                     );


                    IF (l_err_num <> 0) THEN

                      RAISE CST_FAILED_INSERT_PTI;

                    END IF;

                  END LOOP;

                        IF l_rownum = 0 THEN

                    RAISE NO_ROWS_TO_INSERT;

                        END IF;

                END IF; /*CC ALL ELE END FILTERED WIPCompIss/Rtn,31,32 TRFSIDE*/

                ---- borrow payback

                /* Borrow Payback Enhancements - Bug 2665290 */

                IF    (p_transaction_action_id = 2) AND (l_txn_type = 68)
                  /*AND (p_cost_group_id <> p_transfer_cost_group_id) */
                THEN

                  l_rownum   := 0;
                  l_stmt_num := 200;

                  if (l_debug = 'Y') then
                     FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Collecting Borrow Payback transactions ...');
                  end if;

                  FOR c_rec6 IN c_sel_bp_txn  LOOP

                    l_rownum := l_rownum + 1;

                    l_stmt_num := 205;

                    pm_insert_pti_pvt
                        (p_transaction_source         =>
                                             c_rec6.transaction_source,
                         p_batch_name                 =>c_rec6.batch_name,
                         p_expenditure_ending_date    =>
                                             c_rec6.expenditure_ending_date,
                         p_employee_number            =>c_rec6.employee_number,
                         p_organization_name          =>
                                             c_rec6.organization_name,
                         p_expenditure_item_date      =>
                                             c_rec6.expenditure_item_date,
                         p_project_number             =>c_rec6.project_number,
                         p_task_number                =>c_rec6.task_number,
                         p_expenditure_type           =>c_rec6.expenditure_type,
                         p_pa_quantity                =>c_rec6.quantity,
                         p_raw_cost                   =>c_rec6.raw_cost,
                         p_expenditure_comment        =>
                                             c_rec6.expenditure_comment,
                         p_orig_transaction_reference =>
                                             c_rec6.orig_transaction_reference,
                         p_raw_cost_rate              =>c_rec6.raw_cost_rate,
                         p_unmatched_negative_txn_flag=>
                                             c_rec6.unmatched_negative_txn_flag,
                         p_gl_date                    =>c_rec6.gl_date,
                         p_org_id                     =>c_rec6.org_id,
                         p_burdened_cost              =>c_rec6.burdened_cost,
                         p_burdened_cost_rate         =>
                                             c_rec6.burdened_cost_rate,
                         p_system_linkage             =>c_rec6.system_linkage,
                         p_transaction_status_code    =>
                                             c_rec6.transaction_status_code,
                         p_denom_currency_code        =>
                                             c_rec6.denom_currency_code,
                         p_transaction_id             =>p_transaction_id,

                         p_transaction_action_id      =>p_transaction_action_id,
                         p_transaction_source_type_id =>
                                             p_transaction_source_type_id,
                         p_organization_id            =>p_organization_id,
                         p_inventory_item_id          =>p_inventory_item_id,
                         p_cost_element_id            =>c_rec6.cost_element_id,
                         p_resource_id                =>NULL,
                         p_source_flag                =>-1,
                         p_variance_flag              =>1,
                         p_primary_quantity           =>p_primary_quantity ,
                         p_transfer_organization_id   =>
                                             p_transfer_organization_id,
                         p_fob_point                  =>l_fob_point,
                         p_wip_entity_id              =>NULL,
                         p_basis_resource             =>NULL,

                         p_type_class                 =>p_type_class,
                         p_project_id                 =>p_project_id,
                         p_task_id                    =>p_task_id,
                         p_transaction_date           =>p_transaction_date,
                         p_cost_group_id              =>p_cost_group_id,
                         p_transfer_cost_group_id     =>
                                             p_transfer_cost_group_id,
                         p_transaction_source_id      =>
                                             p_transaction_source_id,
                         p_to_project_id              =>p_to_project_id,
                         p_to_task_id                 =>p_to_task_id,
                         p_source_project_id          =>p_source_project_id,
                         p_source_task_id             =>p_source_task_id,
                         p_transfer_transaction_id    =>
                                             p_transfer_transaction_id,
                         p_primary_cost_method        =>p_primary_cost_method,
                         p_acct_period_id             =>p_acct_period_id,
                         p_exp_org_id                 =>p_exp_org_id,
                         p_distribution_account_id    =>
                                             p_distribution_account_id,
                         p_proj_job_ind               =>p_proj_job_ind,
                         p_first_matl_se_exp_type     =>
                                             p_first_matl_se_exp_type,
                         p_inv_txn_source_literal     =>
                                             p_inv_txn_source_literal,
                         p_cap_txn_source_literal     =>
                                             p_cap_txn_source_literal,
                         p_inv_syslink_literal        =>p_inv_syslink_literal,
                         p_bur_syslink_literal        =>p_bur_syslink_literal,
                         p_wip_syslink_literal        =>p_wip_syslink_literal,
                         p_user_def_exp_type          =>p_user_def_exp_type,
                         p_flow_schedule              =>p_flow_schedule,
                         p_si_asset_yes_no            =>p_si_asset_yes_no,
                         p_transfer_si_asset_yes_no   =>
                                             p_transfer_si_asset_yes_no,

                         O_err_num                    =>l_err_num,
                         O_err_code                   =>l_err_code,
                         O_err_msg                    =>l_err_msg
                     );

                    /* For standard costing orgs, the borrow payback variance has to
                       be applied to both the borrowing and the lending projects*/
/* Patchset J - Borrow Payback Enhancements - In actual organizations, BPV
   against payback transactions across the same cost group has to be collected
   against both the borrowing and lending project  Adding OR condition*/
                    IF ((p_std_cg_acct = 1 AND p_primary_cost_method = 1) OR
                        (p_primary_cost_method <> 1 and p_cost_group_id = p_transfer_cost_group_id))
                    THEN

                        SELECT
                                 decode(sign(-1 * p_primary_quantity),1,
                                        cceet.EXPENDITURE_TYPE_OUT,
                                         cceet.EXPENDITURE_TYPE_IN)
                        INTO l_exp_type
                        FROM cst_cost_elem_exp_types cceet
                        WHERE cceet.cost_element_id = c_rec6.cost_element_id;

                        pm_insert_pti_pvt
                                (p_transaction_source         =>
                                             c_rec6.transaction_source,
                                p_batch_name                 =>c_rec6.batch_name,
                                p_expenditure_ending_date    =>
                                                     c_rec6.expenditure_ending_date,
                                p_employee_number            =>c_rec6.employee_number,
                                p_organization_name          =>
                                             c_rec6.organization_name,
                                p_expenditure_item_date      =>
                                             c_rec6.expenditure_item_date,
                                p_project_number             =>l_to_project_number,
                                p_task_number                =>l_to_task_number,
                                p_expenditure_type           =>l_exp_type,
                                p_pa_quantity                =>-1 * c_rec6.quantity,
                                p_raw_cost                   =>-1 * c_rec6.raw_cost,
                                p_expenditure_comment        =>
                                             c_rec6.expenditure_comment,
                                p_orig_transaction_reference =>to_char(p_transfer_transaction_id),
                                p_raw_cost_rate              =>-1 * c_rec6.raw_cost_rate,
                                p_unmatched_negative_txn_flag=>
                                             c_rec6.unmatched_negative_txn_flag,
                                p_gl_date                    =>c_rec6.gl_date,
                                p_org_id                     =>l_to_proj_org_id,
                                p_burdened_cost              =>-1 * c_rec6.burdened_cost,
                                p_burdened_cost_rate         =>
                                             -1 * c_rec6.burdened_cost_rate,
                                p_system_linkage             =>c_rec6.system_linkage,
                                p_transaction_status_code    =>
                                             c_rec6.transaction_status_code,
                                p_denom_currency_code        =>
                                             c_rec6.denom_currency_code,
                                p_transaction_id             =>p_transaction_id,

                                p_transaction_action_id      =>p_transaction_action_id,
                                p_transaction_source_type_id =>
                                             p_transaction_source_type_id,
                                p_organization_id            =>p_organization_id,
                                p_inventory_item_id          =>p_inventory_item_id,
                                  p_cost_element_id            =>c_rec6.cost_element_id,
                                p_resource_id                =>NULL,
                                p_source_flag                =>-1,
                                p_variance_flag              =>1,
                                p_primary_quantity           =>-1 * p_primary_quantity ,
                                p_transfer_organization_id   =>
                                                    p_organization_id,
                                p_fob_point                  =>l_fob_point,
                                p_wip_entity_id              =>NULL,
                                p_basis_resource             =>NULL,

                                p_type_class                 =>p_type_class,
                                p_project_id                 =>p_to_project_id,
                                p_task_id                    =>p_to_task_id,
                                p_transaction_date           =>p_transaction_date,
                                p_cost_group_id              =>p_transfer_cost_group_id,
                                p_transfer_cost_group_id     =>
                                             p_cost_group_id,
                                p_transaction_source_id      =>
                                                    p_transaction_source_id,
                                p_to_project_id              =>p_project_id,
                                p_to_task_id                 =>p_task_id,
                                p_source_project_id          =>p_source_project_id,
                                p_source_task_id             =>p_source_task_id,
                                p_transfer_transaction_id    =>
                                                    p_transaction_id,
                                p_primary_cost_method        =>p_primary_cost_method,
                                p_acct_period_id             =>p_acct_period_id,
                                p_exp_org_id                 =>p_exp_org_id,
                                p_distribution_account_id    =>
                                             p_distribution_account_id,
                                p_proj_job_ind               =>p_proj_job_ind,
                                p_first_matl_se_exp_type     =>
                                             p_first_matl_se_exp_type,
                                p_inv_txn_source_literal     =>
                                             p_inv_txn_source_literal,
                                p_cap_txn_source_literal     =>
                                             p_cap_txn_source_literal,
                                p_inv_syslink_literal        =>p_inv_syslink_literal,
                                p_bur_syslink_literal        =>p_bur_syslink_literal,
                                p_wip_syslink_literal        =>p_wip_syslink_literal,
                                p_user_def_exp_type          =>p_user_def_exp_type,
                                p_flow_schedule              =>p_flow_schedule,
                                p_si_asset_yes_no            =>p_si_asset_yes_no,
                                p_transfer_si_asset_yes_no   =>
                                                    p_transfer_si_asset_yes_no,

                                O_err_num                    =>l_err_num,
                                O_err_code                   =>l_err_code,
                                O_err_msg                    =>l_err_msg
                        );
                    END IF;

                    IF (l_err_num <> 0) THEN

                      RAISE CST_FAILED_INSERT_PTI;

                    END IF;

                  END LOOP;

                  /* Commenting this out -  borrow payback transactions need not
                  have borrow payback variance. */

                        /* IF l_rownum = 0 THEN

                    RAISE NO_ROWS_TO_INSERT;

                        END IF;*/

                END IF; /*CC ALL BORROW PAYBACK TXN */


                l_no_ppv := 1; --bug 3978501 setting the variable to 1 initially

                -- PJMSTD_PPV
                /* Bug # 2349027. For interorg transfers, collect PPV if project_id is the same
                   as to_project_id since the expenditure orgs are different. */
                IF (((p_std_cg_acct = 1 AND p_primary_cost_method = 1) OR
                     (l_primary_cost_method_snd = 1)) AND
                      (
                        /* Transfer org does not have cost collection enabled */
                        /*(p_transaction_action_id in (3,12,21) and
                         p_to_project_id is not null  and
                         l_cost_collection_enabled_snd <> 1)
                         OR */
                         /* PO Receipt */
                         p_transaction_source_type_id = 1
                         OR
                         /* Interorg transfer between two different project/tasks. */
                         (p_transaction_action_id IN (12,21,3)
                         /* AND NOT( p_project_id = nvl(p_to_project_id,-9)
                                and p_task_id = nvl(p_to_task_id,-9))*/
                         )
                        OR
                        /* Consigned ownership transfer transaction */
                        p_transaction_action_id = 6
                        ))
                THEN
                  /* For direct interorg transfers from standard org to a standard org,
                     the PPV is always generated against the sending organization.
                     For direct interorg transfers from average org to a standard org,
                     the PPV is always generated against the receiving organization.
                  */
                  IF (
                        (p_primary_cost_method=1 AND l_primary_cost_method_snd = 1 AND
                         p_transaction_action_id=3 AND p_primary_quantity >0) OR
                        (p_primary_cost_method <> 1 AND l_primary_cost_method_snd = 1 AND
                         p_transaction_action_id  = 3 AND p_primary_quantity < 0)) THEN
                        ppv_txfr_flag := 1;
                  ELSE
                        ppv_txfr_flag := 0;
                  END IF;

                  l_rownum := 0;

                  if (l_debug = 'Y') then
                     FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Collecting purchase price variances ...');
                     FND_FILE.PUT_LINE(FND_FILE.LOG,'ppv_txfr_flag : '||ppv_txfr_flag||
                                                 'p_primary_cost_method : '||p_primary_cost_method||
                                                 'l_primary_cost_method_snd : '||l_primary_cost_method_snd||
                                                 ' p_organization_id : '||p_organization_id||
                                                 ' p_transaction_id : '||p_transaction_id||
                                                 ' p_transfer_organization_id : '||p_transfer_organization_id||
                                                 ' p_transfer_transaction_id : '||p_transfer_transaction_id||
                                                 ' p_primary_quantity : '||p_primary_quantity||
                                                 ' p_project_id : '||p_project_id||
                                                 ' p_to_project_id : '||p_to_project_id);
                end if;

                  FOR c_rec7 IN c_sel_ppv LOOP

                    l_rownum := l_rownum + 1;

                    l_stmt_num := 210;


 /* changes to support the Blue print organizations */

 /* get the org ID on the transfer Txn if direct interorg*/

   If p_transaction_action_id = 3 then

                   select organization_id into l_org_id
                   from mtl_material_transactions
                   where transaction_id = c_rec7.orig_transaction_reference;

                 /* set the transaction source accordingly if the org is BP */

                    select NVL(pa_posting_flag,'N'),
                           NVL(pa_autoaccounting_flag,'N')
                    into l_blue_print_enabled_flag,
                         l_autoaccounting_flag
                    from pjm_org_parameters
                    where organization_id = l_org_id ;

          If l_blue_print_enabled_flag = 'Y' then

               If l_autoaccounting_flag = 'Y' then

                    /* BP and autoaccounting  */
                    Select pts1.transaction_source,
                           pts1.transaction_source,
                           pts1.transaction_source
                     into  l_transaction_source,
                           l_inv_txn_src_literal,
                           l_cap_inv_txn_src_literal
                     From  pa_transaction_sources pts1
                    Where  pts1.transaction_source = 'PJM_CSTBP_INV_NO_ACCOUNTS';
                   If (l_transaction_source is NULL) then

                      RAISE CST_FAILED_TXN_SRC;

                   end If;
               else
                    /* BP and no autoaccounting */
                    Select pts1.transaction_source,
                           pts1.transaction_source,
                           pts1.transaction_source
                     into  l_transaction_source,
                           l_inv_txn_src_literal,
                           l_cap_inv_txn_src_literal
                     From  pa_transaction_sources pts1
                    Where  pts1.transaction_source = 'PJM_CSTBP_INV_ACCOUNTS';

                       If (l_transaction_source is NULL ) then

                        RAISE CST_FAILED_TXN_SRC;

                       end If;
               end if; /* end of check for auto accounting */

           ELSE /* non BP org */

               SELECT   pts1.transaction_source,
                        pts2.transaction_source
               INTO     l_inv_txn_src_literal,
                        l_cap_inv_txn_src_literal
               FROM     pa_transaction_sources pts1,
                        pa_transaction_sources pts2
               WHERE  pts1.transaction_source = 'Inventory'
               AND  pts2.transaction_source = 'Inventory Misc';

               SELECT  decode(p_type_class,1,
                        l_cap_inv_txn_src_literal,
                        l_inv_txn_src_literal)
               INTO   l_transaction_source
               from dual;


          END IF; /* check for BP org */

    ELSE /* transaction action iD <> 3 */

     l_transaction_source := c_rec7.transaction_source ;
     l_inv_txn_src_literal := p_inv_txn_source_literal ;
     l_cap_inv_txn_src_literal := p_cap_txn_source_literal;

    END IF ; /* check for direct inter org txns */


                    pm_insert_pti_pvt
                        (p_transaction_source         =>
                                             l_transaction_source,
                         p_batch_name                 =>c_rec7.batch_name,
                         p_expenditure_ending_date    =>
                                             c_rec7.expenditure_ending_date,
                         p_employee_number            =>c_rec7.employee_number,
                         p_organization_name          =>
                                             c_rec7.organization_name,
                         p_expenditure_item_date      =>
                                             c_rec7.expenditure_item_date,
                         p_project_number             =>c_rec7.project_number,
                         p_task_number                =>c_rec7.task_number,
                         p_expenditure_type           =>c_rec7.expenditure_type,
                         p_pa_quantity                =>c_rec7.quantity,
                         p_raw_cost                   =>c_rec7.raw_cost,
                         p_expenditure_comment        =>
                                             c_rec7.expenditure_comment,
                         p_orig_transaction_reference =>
                                             c_rec7.orig_transaction_reference,
                         p_raw_cost_rate              =>c_rec7.raw_cost_rate,
                         p_unmatched_negative_txn_flag=>
                                             c_rec7.unmatched_negative_txn_flag,
                         p_gl_date                    =>c_rec7.gl_date,
                         p_org_id                     =>c_rec7.org_id,
                         p_burdened_cost              =>c_rec7.burdened_cost,
                         p_burdened_cost_rate         =>
                                             c_rec7.burdened_cost_rate,
                         p_system_linkage             =>c_rec7.system_linkage,
                         p_transaction_status_code    =>
                                             c_rec7.transaction_status_code,
                         p_denom_currency_code        =>
                                             c_rec7.denom_currency_code,
                         p_transaction_id             =>p_transaction_id,

                         p_transaction_action_id      =>p_transaction_action_id,
                         p_transaction_source_type_id =>
                                             p_transaction_source_type_id,
                         p_organization_id            =>p_organization_id,
                         p_inventory_item_id          =>p_inventory_item_id,
                         p_cost_element_id            =>c_rec7.cost_element_id,
                         p_resource_id                =>NULL,
                         p_source_flag                =>-1,
                         p_variance_flag              =>1,
                         p_primary_quantity           =>p_primary_quantity ,
                         p_transfer_organization_id   =>
                                             p_transfer_organization_id,
                         p_fob_point                  =>l_fob_point,
                         p_wip_entity_id              =>NULL,
                         p_basis_resource             =>NULL,

                         p_type_class                 =>p_type_class,
                         p_project_id                 =>p_project_id,
                         p_task_id                    =>p_task_id,
                         p_transaction_date           =>p_transaction_date,
                         p_cost_group_id              =>p_cost_group_id,
                         p_transfer_cost_group_id     =>
                                             p_transfer_cost_group_id,
                         p_transaction_source_id      =>
                                             p_transaction_source_id,
                         p_to_project_id              =>p_to_project_id,
                         p_to_task_id                 =>p_to_task_id,
                         p_source_project_id          =>p_source_project_id,
                         p_source_task_id             =>p_source_task_id,
                         p_transfer_transaction_id    =>
                                             p_transfer_transaction_id,
                         p_primary_cost_method        =>p_primary_cost_method,
                         p_acct_period_id             =>p_acct_period_id,
                         p_exp_org_id                 =>p_exp_org_id,
                         p_distribution_account_id    =>
                                             p_distribution_account_id,
                         p_proj_job_ind               =>p_proj_job_ind,
                         p_first_matl_se_exp_type     =>
                                             p_first_matl_se_exp_type,
                         p_inv_txn_source_literal     =>
                                             l_inv_txn_src_literal,
                         p_cap_txn_source_literal     =>
                                             l_cap_inv_txn_src_literal,
                         p_inv_syslink_literal        =>p_inv_syslink_literal,
                         p_bur_syslink_literal        =>p_bur_syslink_literal,
                         p_wip_syslink_literal        =>p_wip_syslink_literal,
                         p_user_def_exp_type          =>p_user_def_exp_type,
                         p_flow_schedule              =>p_flow_schedule,
                         p_si_asset_yes_no            =>p_si_asset_yes_no,
                         p_transfer_si_asset_yes_no   =>
                                             p_transfer_si_asset_yes_no,

                         O_err_num                    =>l_err_num,
                         O_err_code                   =>l_err_code,
                         O_err_msg                    =>l_err_msg
                     );

                    IF (l_err_num <> 0) THEN

                      RAISE CST_FAILED_INSERT_PTI;

                    END IF;

                  END LOOP; --c_rec7


                /* bug 3978501. check to see if r have been inserted and update l_no_ppv */

                 if l_rownum <> 0 then

                    l_no_ppv := 0;

                 end If;


                END IF; -- Check for PPV of PO or IO Txn


            /* bug 3978501 check to see the 3 flags and decide whether to raise the no rows exception or not */

             IF l_no_ppv = 1 then
               IF l_no_row_c_sel_prj = 1 or l_no_row_c_sel_toprj = 1 then
                    RAISE NO_ROWS_TO_INSERT;
               END IF;
             END IF;


        END IF;        /* END: CC ALL TXNS OF AN AVG+PJMSTD COSTING ORG */

        EXCEPTION

                WHEN CST_FAILED_GET_EXPENDDATE THEN

                        O_err_num := 20001;

                        fnd_message.set_name('BOM','CST_FAILED_GET_EXPENDDATE');
                        l_err_msg := fnd_message.get ;
                        O_err_msg := substr(l_err_msg,1,240) ;

                        O_err_code := 'CSTPPCCB.pm_process_txn_mmt('
                                        || to_char(l_stmt_num)
                                        || '): ';

                WHEN NO_ROWS_TO_INSERT THEN

                        O_err_num := 20002;

                        fnd_message.set_name('BOM',
                                                'CST_NO_PROJ_COSTS_REPORTED');
                        l_err_msg := fnd_message.get ;
                        O_err_msg := substr(l_err_msg,1,240) ;

                        O_err_code := 'CSTPPCCB.pm_process_txn_mmt('
                                        || to_char(l_stmt_num)
                                        || '): ';

                WHEN ROW_NOT_COSTED THEN

                        O_err_num := 30000;

                        fnd_message.set_name('BOM',
                                                'CST_TXN_NOT_COSTED');
                        l_err_msg := fnd_message.get ;
                        O_err_msg := substr(l_err_msg,1,240) ;

                        O_err_code := 'CSTPPCCB.pm_process_txn_mmt('
                                        || to_char(l_stmt_num)
                                        || '): ';


                WHEN CST_FAILED_PROJTSK_VALID THEN

                        O_err_num := 20003;

 /*                     fnd_message.set_name('BOM','CST_FAILED_PROJTSK_VALID');
                        l_err_msg := fnd_message.get ;
                        O_err_msg := substr(l_err_msg,1,240) ;
*/
                        O_err_msg:='Project/Task Invalid for Cost Collection.';
                        O_err_code  := SUBSTR('CSTPPCCB.pm_process_txn_mmt('
                                ||to_char(l_stmt_num)
                                ||'): '
                                ||l_err_msg,1,240);

                -- bug 888190, new exception is added
                -- to handle expenditure type not found
                WHEN CST_FAILED_GET_EXP_TYPE THEN
                        O_err_num := 20004;
                        O_err_code := NULL;
                        O_err_msg := SUBSTR('CSTPPCCB.pm_process_txn_mmt('
                                   ||to_char(l_stmt_num)
                                   ||'):  '
                                   ||'Failed to get expenditure type.',1,240);

                WHEN CST_FAILED_INSERT_PTI THEN
                        O_err_num := 20005;
                        O_err_code := SUBSTR('CSTPPCCB.pm_process_txn_mmt('
                                   ||to_char(l_stmt_num)
                                   ||'):  '
                                   ||l_err_code, 1,240);
                        O_err_msg := SUBSTR(l_err_msg,1,240);

                WHEN CST_FAILED_STD_CG_FLAG THEN

                        O_err_num := 20006;
                        O_err_code := SUBSTR('CSTPPCCB.pm_process_txn_mmt('
                                   ||to_char(l_stmt_num)
                                   ||'):  ',1,240);
                        O_err_msg :=
                                  'Failed CST_UTILITY_PUB.GET_STD_CG_ACCT_FLAG';

               WHEN CST_FAILED_TXN_SRC THEN

                        O_err_num := 20007;
                        O_err_code := SUBSTR('CSTPPCCB.pm_process_txn_mmt('
                                    || to_char(l_stmt_num)
                                    ||'): ',1,240);
                        O_err_msg := 'failed to get TXN source' ;



                WHEN OTHERS THEN

                        O_err_num := SQLCODE;
                        O_err_code := NULL;
                        O_err_msg := SUBSTR('CSTPPCCB.pm_process_txn_mmt('
                                        || to_char(l_stmt_num)
                                        || '): '
                                        ||SQLERRM,1,240);

END pm_process_txn_mmt;

 /*----------------------------------------------------------------------------*
 | PRIVATE PROCEDURE                                                          |
 |    pm_check_error_mmt                                                      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    The procedure validates the transaction to cost collect. The validations|
 |    it performs are                                                         |
 |    1. Both the project and task columns for the txn are NOT NULL           |
 |    2. If the txn is of PO family,the first material SE Exp_type is NOT NULL|
 |    3. If the txn is Assy Rtn or Completion or PO Family, the MO SE should  |
 |       all be having their expenditure_type as NOT NULL                     |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 | PARAMETERS                                                                 |
 |                                                                            |
 |                        p_transaction_id,                                   |
 |                        p_organization_id,                                  |
 |                        p_inventory_item_id,                                |
 |                        p_avg_rates_cost_type_id,                           |
 |                        p_transaction_action_id,                            |
 |                        p_transaction_source_type_id,                       |
 |                        p_type_class,                                       |
 |                        p_project_id,                                       |
 |                        p_task_id                                           |
 |                        p_to_project_id,                                    |
 |                        p_to_task_id                                        |
 |                        p_source_project_id,                                |
 |                        p_source_task_id                                    |
 |                        p_transaction_source_id                             |
 |                        p_proj_job_ind                                   |
 |                        p_process_yn                                        |
 |                        p_first_matl_se_exp_type                            |
 |                        p_user_id,                                          |
 |                        p_login_id,                                         |
 |                        p_req_id,                                           |
 |                        p_prg_appl_id,                                      |
 |                        p_prg_id,                                           |
 |                        O_err_num,                                              |
 |                        O_err_code,                                              |
 |                        O_err_msg,                                              |
 |                        p_flow_schedule                                     |
 |                        p_cost_group_id                                     |
 |                                                                            |
 | CALLED FROM                                                                |
 |    pm_cc_worker_mmt()                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |    07-SEP-96  Bhaskar Dasari Created.                                      |
 |                                                                            |
 |    20-AUG-97  Hemant Gosain Modified.                                      |
 |               Added CFM Support by passing parameter p_flow_schedule.      |
 *----------------------------------------------------------------------------*/

  PROCEDURE  pm_check_error_mmt (
                                 p_transaction_id               NUMBER,
                                 p_organization_id                NUMBER,
                                 p_cost_method                        NUMBER,
                                 p_inventory_item_id                NUMBER,
                                 p_avg_rates_cost_type_id        NUMBER,
                                 p_transaction_action_id        NUMBER,
                                 p_transaction_source_type_id        NUMBER,
                                 p_type_class                        NUMBER,
                                 p_project_id                        NUMBER,
                                 p_task_id                        NUMBER,
                                 p_to_project_id                NUMBER,
                                 p_to_task_id                        NUMBER,
                                 p_source_project_id                NUMBER,
                                 p_source_task_id                NUMBER,
                                 p_transaction_source_id        NUMBER,
                                 p_proj_job_ind           OUT         NOCOPY  NUMBER,
                                 p_process_yn                   OUT         NOCOPY  NUMBER,
                                 p_first_matl_se_exp_type  OUT         NOCOPY  VARCHAR2,
                                 p_user_id                        NUMBER,
                                 p_login_id                        NUMBER,
                                 p_req_id                        NUMBER,
                                 p_prg_appl_id                         NUMBER,
                                 p_prg_id                         NUMBER,
                                 O_err_num                   OUT        NOCOPY  NUMBER,
                                 O_err_code                   OUT        NOCOPY  VARCHAR2,
                                 O_err_msg                   OUT        NOCOPY  VARCHAR2,
                                 p_flow_schedule                VARCHAR2,
                                 p_cost_group_id                NUMBER)--PJMSTD
  IS

  l_err_num             NUMBER;
  l_err_code            VARCHAR2(240);
  l_err_msg             VARCHAR2(240);
  l_err_msg_temp        VARCHAR2(240);
  l_stmt_num            NUMBER;
  l_proj_job_ind        NUMBER;

  l_exp_type            VARCHAR2(30);
  l_error_code          VARCHAR2(240);
  l_error_explanation   VARCHAR2(240);

  PROCESS_ERROR         EXCEPTION;
  SE_EXP_TYPE_NULL      EXCEPTION;
  NO_FMSE_DEFINED       EXCEPTION;
  l_debug               VARCHAR2(80);

  BEGIN
        -- initialize local variables
        l_err_num := 0;
        l_err_code := '';
        l_err_msg := '';
        l_err_msg_temp := '';
        l_stmt_num := 1;

        l_debug := FND_PROFILE.VALUE('MRP_DEBUG');
        if (l_debug = 'Y') then
            FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Reached#: pm_check_error_mmt');
        end if;

        IF(p_transaction_source_type_id = 5 AND p_source_project_id IS NOT NULL) THEN
           l_proj_job_ind := 1;
        ELSE
           l_proj_job_ind := 0;
        END IF;

        p_proj_job_ind := l_proj_job_ind;

        p_process_yn := 1; /* 1 Implies Process the Txn */
        --
        -- GENERIC CHECKS
        --
        -- TXNS demanding knowledge of both project and task ie. NOT NULL

        IF     p_project_id is not null AND
               p_task_id is NULL THEN

                l_stmt_num := 20;
                fnd_message.set_name('BOM','CST_NO_PROJ_OR_TASK');
                l_err_msg := fnd_message.get ;
                l_err_code := 'CSTPPCCB.pm_check_error_mmt('
                                || to_char(l_stmt_num)
                                || '): ';

                l_error_explanation := substr(l_err_msg,1,240) ;
                l_error_code := l_err_code;


                pm_mark_error_mmt ( p_transaction_id,
                                    l_error_code,
                                    l_error_explanation,
                                    p_user_id,
                                    p_login_id,
                                    p_req_id,
                                    p_prg_appl_id,
                                    p_prg_id,
                                    l_err_num,
                                    l_err_code,
                                    l_err_msg);

                IF (l_err_num <> 0) THEN
                        -- Error occured
                        raise PROCESS_ERROR;
                ELSE
                        p_process_yn := 2;
                        l_err_num := 20003;
                        l_err_code   := l_error_code;
                        l_err_msg    := l_error_explanation;
                        raise PROCESS_ERROR;
                END IF;
        END IF;


        IF     p_to_project_id is not null AND
               p_to_task_id is NULL   THEN

                l_stmt_num := 30;
                fnd_message.set_name('BOM','CST_NO_TRF_PROJ_OR_TASK');
                l_err_msg := fnd_message.get ;
                l_err_code := 'CSTPPCCB.pm_check_error_mmt('
                                || to_char(l_stmt_num)
                                || '): ';

                l_error_explanation := substr(l_err_msg,1,240) ;
                l_error_code := l_err_code;

                pm_mark_error_mmt ( p_transaction_id,
                                    l_error_code,
                                    l_error_explanation,
                                    p_user_id,
                                    p_login_id,
                                    p_req_id,
                                    p_prg_appl_id,
                                    p_prg_id,
                                    l_err_num,
                                    l_err_code,
                                    l_err_msg);

                IF (l_err_num <> 0) THEN
                           -- Error occured
                           raise PROCESS_ERROR;
                ELSE
                        p_process_yn := 2;
                        l_err_num := 20004;
                        l_err_code   := l_error_code;
                        l_err_msg    := l_error_explanation;
                        raise PROCESS_ERROR;
                END IF;
        END IF;

        IF     ( p_type_class = 1 OR l_proj_job_ind = 1 )
           AND ( p_source_project_id is null OR p_source_task_id is NULL ) THEN

                l_stmt_num := 40;
                fnd_message.set_name('BOM','CST_NO_SOURCE_PROJ_OR_TASK');
                l_err_msg := fnd_message.get ;
                l_err_code := 'CSTPPCCB.pm_check_error_mmt('
                                || to_char(l_stmt_num)
                                || '): ';

                l_error_explanation := substr(l_err_msg,1,240) ;
                l_error_code := l_err_code;

                pm_mark_error_mmt ( p_transaction_id,
                                    l_error_code,
                                    l_error_explanation,
                                    p_user_id,
                                    p_login_id,
                                    p_req_id,
                                    p_prg_appl_id,
                                    p_prg_id,
                                    l_err_num,
                                    l_err_code,
                                    l_err_msg);

                IF (l_err_num <> 0) THEN
                           -- Error occured
                           raise PROCESS_ERROR;
                ELSE
                        p_process_yn := 2;
                        l_err_num := 20005;
                        l_err_code   := l_error_code;
                        l_err_msg    := l_error_explanation;
                        raise PROCESS_ERROR;
                END IF;
        END IF;

        -- PJMSTD
        IF (p_cost_group_id IS NULL) THEN

                l_stmt_num := 45;
                fnd_message.set_name('BOM','CST_PAC_CG_INVALID');
                l_err_msg := fnd_message.get ;
                l_err_code := 'CSTPPCCB.pm_check_error_mmt('
                                || to_char(l_stmt_num)
                                || '): ';

                l_error_explanation := substr(l_err_msg,1,240) ;
                l_error_code := l_err_code;

                pm_mark_error_mmt ( p_transaction_id,
                                    l_error_code,
                                    l_error_explanation,
                                    p_user_id,
                                    p_login_id,
                                    p_req_id,
                                    p_prg_appl_id,
                                    p_prg_id,
                                    l_err_num,
                                    l_err_code,
                                    l_err_msg);

                IF (l_err_num <> 0) THEN
                           -- Error occured
                           raise PROCESS_ERROR;
                ELSE
                        p_process_yn := 2;
                        l_err_num := 20008;
                        l_err_code   := l_error_code;
                        l_err_msg    := l_error_explanation;
                        raise PROCESS_ERROR;
                END IF;

        END IF; -- check for NULL CG

        --
        -- TRANSACTION SPECIFIC CHECKS ----
        --
        -- TXN requires using the first matl SE logic and the routine returns
        -- no valid expenditure type
        --
        IF (p_transaction_source_type_id = 1
            OR p_transaction_action_id = 6)
                                                 THEN /*PO Famly FMSE logic,
                                                  consigned ownership transfer transaction
                                                  --START*/

                l_exp_type := NULL;
                l_stmt_num := 50;

                BEGIN

                    SELECT decode(br.expenditure_type,NULL,
                                 decode(br1.expenditure_type,NULL,'NO VALUE',
                                                br1.expenditure_type),
                                     br.expenditure_type)
                      INTO  l_exp_type
                      FROM  mtl_parameters mp,
                            cst_item_cost_details cicd,
                            bom_resources br,
                            bom_resources br1
                     WHERE  mp.organization_id = p_organization_id
                       AND  mp.cost_organization_id = cicd.organization_id (+)
                       AND  cicd.inventory_item_id (+) = p_inventory_item_id
                       AND  cicd.cost_type_id (+) = decode(p_cost_method, 1, 1,
                                                        p_avg_rates_cost_type_id)
                       AND  cicd.cost_element_id (+) = 1
                       AND  cicd.organization_id = br.organization_id (+)
                       AND  cicd.resource_id = br.resource_id (+)
                       AND  mp.cost_organization_id = br1.organization_id (+)
                       AND  mp.default_material_cost_id = br1.resource_id (+)
                       AND  rownum=1;

                EXCEPTION
                        when NO_DATA_FOUND then
                                l_exp_type := 'NO VALUE';
                END;

                IF l_exp_type = 'NO VALUE' THEN

                        RAISE NO_FMSE_DEFINED;
                ELSE
                        p_first_matl_se_exp_type := l_exp_type;

                END IF;

        END IF; /* PO Family FMSE logic -- END */

        -- TXN demands cost collecting the mo sub-elementally and the ET for
        -- the SE was found to be NULL
        -- TXNS ARE: PO receipt,adjustment,RTV,Assy completion and Return
        -- Consigned ownership transfer transactions

        IF         (p_transaction_action_id in (31,32)
            OR         p_transaction_source_type_id = 1
            OR  p_transaction_action_id = 6)
                                                             THEN /*Check MO SE ET START*/


                l_stmt_num := 60;
                l_exp_type := NULL;

                BEGIN
                        SELECT  'NO VALUE'
                          INTO  l_exp_type
                          FROM  mtl_actual_cost_subelement macs,
                                bom_resources br
                         WHERE  macs.transaction_id   = p_transaction_id
                           AND  macs.organization_id  = p_organization_id
                             AND  macs.cost_element_id = 2
                             AND  macs.level_type = 1
                           AND  br.RESOURCE_ID = macs.RESOURCE_ID
                           AND  br.ORGANIZATION_ID  = macs.ORGANIZATION_ID
                           AND  br.expenditure_type IS NULL;
                        EXCEPTION
                                when NO_DATA_FOUND then
                                        l_exp_type := NULL;
                END;

                IF l_exp_type = 'NO VALUE' THEN
                        RAISE SE_EXP_TYPE_NULL;
                END IF;

        END IF;  /*Check MO SE ET END*/

        EXCEPTION
                WHEN SE_EXP_TYPE_NULL THEN

                        fnd_message.set_name('BOM','CST_SE_ET_IS_NULL');
                        l_err_msg := fnd_message.get ;
                        l_err_code := 'CSTPPCCB.pm_check_error_mmt('
                                        || to_char(l_stmt_num)
                                        || '): ';

                        l_error_explanation := substr(l_err_msg,1,240) ;
                        l_error_code := l_err_code;

                        pm_mark_error_mmt ( p_transaction_id,
                                                l_error_code,
                                                l_error_explanation,
                                                p_user_id,
                                                p_login_id,
                                                p_req_id,
                                                p_prg_appl_id,
                                                p_prg_id,
                                                l_err_num,
                                                l_err_code,
                                                l_err_msg);

                        IF (l_err_num <> 0) THEN
                                O_err_num := l_err_num;
                                O_err_code := l_err_code;
                                O_err_msg := l_err_msg;
                        ELSE
                                p_process_yn := 2;
                                O_err_num := 20006;
                                O_err_code   := l_error_code;
                                O_err_msg    := l_error_explanation;
                        END IF;

                WHEN NO_FMSE_DEFINED THEN

                        fnd_message.set_name('BOM','CST_NO_FMSE_DEFINED');
                        l_err_msg := fnd_message.get ;
                        l_err_code := 'CSTPPCCB.pm_check_error_mmt('
                                        || to_char(l_stmt_num)
                                        || '): ';

                        l_error_explanation := substr(l_err_msg,1,240) ;
                        l_error_code := l_err_code;

                        pm_mark_error_mmt ( p_transaction_id,
                                            l_error_code,
                                            l_error_explanation,
                                            p_user_id,
                                            p_login_id,
                                            p_req_id,
                                            p_prg_appl_id,
                                            p_prg_id,
                                            l_err_num,
                                            l_err_code,
                                            l_err_msg);
                        p_process_yn := 2;

                        IF (l_err_num <> 0) THEN
                                O_err_num := l_err_num;
                                O_err_code := l_err_code;
                                O_err_msg := l_err_msg;
                        ELSE
                                p_process_yn := 2;
                                O_err_num := 20007;
                                O_err_code   := l_error_code;
                                O_err_msg    := l_error_explanation;
                        END IF;

                WHEN PROCESS_ERROR THEN
                        O_err_num := l_err_num;
                        O_err_code := l_err_code;
                        O_err_msg := l_err_msg;

                WHEN OTHERS THEN
                        O_err_num := SQLCODE;
                        O_err_code := NULL;
                        l_err_msg_temp := 'CSTPPCCB.pm_check_error_mmt('
                                || to_char(l_stmt_num)
                                || '): '
                                || substr(SQLERRM,1,150);

                        l_err_num := 0;

                        l_error_explanation := substr(l_err_msg,1,240) ;
                        l_error_code := l_err_code;

                        pm_mark_error_mmt(p_transaction_id,
                                  l_error_code,
                                  l_error_explanation,
                                  p_user_id,
                                  p_login_id,
                                  p_req_id,
                                  p_prg_appl_id,
                                  p_prg_id,
                                  l_err_num,
                                  l_err_code,
                                  l_err_msg);
                        IF (l_err_num <> 0) THEN
                                O_err_msg := SUBSTR(l_err_msg_temp
                                                ||' * '
                                                ||l_err_msg
                                                ||' * '
                                                ||l_err_code
                                                ||' * '
                                                ||'TXN NOT MARKED IN MMT!'
                                                ,1,240);
                        ELSE
                                O_err_msg := SUBSTR(l_err_msg_temp
                                                ||' * '
                                                ||'TXN MARKED IN MMT.'
                                                ,1,240);

                        END IF;
END pm_check_error_mmt;

 /*----------------------------------------------------------------------------*
 | PRIVATE PROCEDURE                                                          |
 |    pm_mark_error_mmt                                                       |
 |                                                                            |
 | DESCRIPTION                                                                |
 |                                                                            |
 |                                                                            |
 | PARAMETERS                                                                 |
 |                                                                            |
 |                        p_transaction_id,                                   |
 |                        p_error_code,                                       |
 |                        p_error_explanation,                                |
 |                        p_user_id,                                          |
 |                        p_login_id,                                         |
 |                        p_req_id,                                           |
 |                        p_prg_appl_id,                                      |
 |                        p_prg_id,                                           |
 |                        O_err_num,                                              |
 |                        O_err_code,                                              |
 |                        O_err_msg                                              |
 |                                                                            |
 | CALLED FROM                                                                |
 |    pm_check_error_mmt()                                                    |
 |                                                                            |
 | HISTORY                                                                    |
 |    07-SEP-96  Bhaskar Dasari Created.                                      |
 *----------------------------------------------------------------------------*/

  PROCEDURE  pm_mark_error_mmt (
                                 p_transaction_id               NUMBER,
                                 p_error_code                        VARCHAR2,
                                 p_error_explanation                VARCHAR2,
                                 p_user_id                        NUMBER,
                                 p_login_id                        NUMBER,
                                 p_req_id                        NUMBER,
                                 p_prg_appl_id                         NUMBER,
                                 p_prg_id                         NUMBER,
                                 O_err_num                OUT        NOCOPY NUMBER,
                                 O_err_code                OUT        NOCOPY VARCHAR2,
                                 O_err_msg                OUT        NOCOPY VARCHAR2 )

  IS

  l_err_num             NUMBER;
  l_err_code            VARCHAR2(240);
  l_err_msg             VARCHAR2(240);
  l_stmt_num            NUMBER;
  l_debug               VARCHAR2(80);

  BEGIN
        -- initialize local variables
        l_err_num := 0;
        l_err_code := '';
        l_err_msg := '';


        l_debug := FND_PROFILE.VALUE('MRP_DEBUG');
        if (l_debug = 'Y') then
            FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Reached#: pm_mark_error_mmt');
        end if;

        l_stmt_num := 10;

        /* update the errorcode and error_explanation fields inspite of the
           maintenance of the log file */

                UPDATE         mtl_material_transactions mmt
                      SET         mmt.pm_cost_collected      = 'E',
                        mmt.error_code             = p_error_code,
                        mmt.error_explanation      = p_error_explanation,
                        mmt.last_update_date       = sysdate,
                        mmt.last_updated_by        = p_user_id,
                        mmt.last_update_login      = p_login_id,
                        mmt.request_id             = p_req_id,
                        mmt.program_application_id = p_prg_appl_id,
                        mmt.program_id             = p_prg_id,
                        mmt.program_update_date    = sysdate
                  WHERE mmt.transaction_id = p_transaction_id ;
        EXCEPTION
                WHEN OTHERS THEN
                        O_err_num := SQLCODE;
                        O_err_code := NULL;
                        O_err_msg := 'CSTPPCCB.pm_mark_error_mmt('
                                || to_char(l_stmt_num)
                                || '): '
                                || substr(SQLERRM,1,200);
  END pm_mark_error_mmt;

 /*----------------------------------------------------------------------------*
 | PRIVATE PROCEDURE                                                          |
 |    pm_process_txn_wt                                                       |
 |                                                                            |
 | DESCRIPTION                                                                |
 |                                                                            |
 |                                                                            |
 | PARAMETERS                                                                 |
 |                                                                            |
 |                        p_Group_Id,
                          p_business_group_name,                                     |
 |                        p_transaction_id,                                   |
 |                        p_organization_id,                                  |
 |                        p_employee_number,                                  |
 |                        p_department_id,                                    |
 |                        p_project_id,                                       |
 |                        p_task_id,                                          |
 |                        p_transaction_date,                                 |
 |                        p_base_transaction_value,                           |
 |                        p_primary_quantity,                                 |
 |                        p_acct_period_id,                                   |
 |                        p_expenditure_type,                                 |
 |                        p_resource_description,                             |
 |                        p_wt_transaction_type,                              |
 |                        p_cost_element_id                                      |
 |                        p_exp_org_name,                                     |
 |                        p_wip_txn_source_literal,                           |
 |                        p_wip_syslink_literal,                              |
 |                        p_bur_syslink_literal,                              |
 |                        O_err_num,                                              |
 |                        O_err_code,                                         |
 |                        O_err_msg,                                          |
 |                        p_reference_account,                                |
 |                        p_cr_account,                                       |
 |                        p_wip_entity_id,                                    |
 |                        p_resource_id,                                      |
 |                        p_basis_resource_id,                                |
 |                        p_denom_currency_code                               |
 |                                                                            |
 | CALLED FROM                                                                |
 |    pm_cc_worker_wt()                                                       |
 |                                                                            |
 | HISTORY                                                                    |
 |    07-SEP-96  Bhaskar Dasari Created.                                      |
 |                                                                            |
 |    30-JUL-97  Hemant Gosain Modified.                                      |
 |               Enhanced to pass accounting information parameters as support|
 |               for capitalization of projects.                              |
 *----------------------------------------------------------------------------*/

  PROCEDURE  pm_process_txn_wt (
                                p_Group_Id                      NUMBER,
                                p_business_group_name           VARCHAR2,
                                p_transaction_id                NUMBER,
                                p_organization_id                NUMBER,
                                p_employee_number                VARCHAR2,
                                p_department_id                        NUMBER,
                                p_project_id                        NUMBER,
                                p_task_id                        NUMBER,
                                p_transaction_date                DATE,
                                p_base_transaction_value        NUMBER,
                                p_primary_quantity                NUMBER,
                                p_acct_period_id                NUMBER,
                                p_expenditure_type                VARCHAR2,
                                p_resource_description                VARCHAR2,
                                p_wt_transaction_type                NUMBER,
                                p_cost_element_id                     NUMBER,
                                     p_exp_org_name                       VARCHAR2,
                                p_wip_txn_source_literal        VARCHAR2,
                                p_wip_straight_time_literal     VARCHAR2,
                                p_wip_syslink_literal                VARCHAR2,
                                p_bur_syslink_literal                VARCHAR2,
                                O_err_num                  OUT        NOCOPY NUMBER,
                                O_err_code                  OUT        NOCOPY VARCHAR2,
                                O_err_msg                  OUT        NOCOPY VARCHAR2,
                                p_reference_account                NUMBER,
                                p_cr_account                        NUMBER,
                                p_wip_dr_sub_ledger_id              NUMBER,
                                p_wip_cr_sub_ledger_id              NUMBER,
                                p_wip_entity_id                        NUMBER,
                                p_resource_id                        NUMBER,
                                p_basis_resource_id                NUMBER,
                                p_denom_currency_code           VARCHAR2)

  IS

  l_err_num             NUMBER;
  l_err_code            VARCHAR2(240);
  l_err_msg             VARCHAR2(240);
  l_stmt_num            NUMBER;
  PROCESS_ERROR                 EXCEPTION;
  CST_FAILED_GET_EXPENDDATE     EXCEPTION;
  CST_FAILED_HOOK_ACCT          EXCEPTION;
  CST_FAILED_PROJTSK_VALID      EXCEPTION;
  l_batch               VARCHAR2(15);--Increased width for Bug2218654
  l_multi_org_id        NUMBER;
  /*l_gl_date             DATE;*/ /* Commented for bug 6266553 */
  l_exp_end_date        DATE;
  l_project_number      VARCHAR2(25);
  l_task_number         VARCHAR2(25);
  l_use_hook_acct       BOOLEAN;
  l_debug               VARCHAR2(80);

  l_transaction_source  VARCHAR2(30);
  l_raw_cost            NUMBER;
  l_raw_cost_rate       NUMBER;
  l_burdened_cost_rate  NUMBER;
  l_burdened_cost       NUMBER;
  l_dr_code_combination_id NUMBER;
  l_cr_code_combination_id NUMBER;
  l_wip_cr_sub_ledger_id  NUMBER;
  l_wip_dr_sub_ledger_id  NUMBER;
  l_syslinkage          VARCHAR2(240);

  l_uom_code            VARCHAR2(30) ;
  l_cc_rate             NUMBER;
  l_txn_value           NUMBER;
  l_operating_unit      NUMBER;

   /* For service line types delivered to shop floor, stamp the amount
      in the quantity column and set the cost_rate to 1
      (eAM Requirements Project - R12) */

  CURSOR c_sel_wt IS

        SELECT        p_wip_txn_source_literal        transaction_source,
                l_batch                                batch_name,
                l_exp_end_date                        expenditure_ending_date,
                p_employee_number                employee_number,
                p_exp_org_name                        organization_name,
                p_transaction_date                expenditure_item_date,
                l_project_number                project_number,
                l_task_number                        task_number,
                p_expenditure_type                expenditure_type,
                p_denom_currency_code           denom_currency_code,

                decode(p_cost_element_id,
                       5,0,
                       decode(p_primary_quantity,
                         NULL,p_base_transaction_value,
                          p_primary_quantity)) quantity,
                decode(p_cost_element_id,5,0, p_base_transaction_value)
                                                  raw_cost,

                p_resource_description                expenditure_comment,
                to_char(p_transaction_id)        orig_transaction_reference,

                decode(p_cost_element_id,
                  5,0,
                  decode(p_primary_quantity,
                   NULL, 1,
                   0, p_base_transaction_value,
                   p_base_transaction_value / p_primary_quantity))
                                                raw_cost_rate,

                'Y'                                unmatched_negative_txn_flag,
                p_reference_account                dr_code_combination_id,
                p_cr_account                        cr_code_combination_id,
                p_wip_dr_sub_ledger_id              wip_dr_sub_ledger_id,
                p_wip_cr_sub_ledger_id              wip_cr_sub_ledger_id,
                NULL                                cdl_system_reference1,
                NULL                                cdl_system_reference2,
                NULL                                cdl_system_reference3,
                /*l_gl_date*/ /* Commented for bug 6266553 */ p_transaction_date                        gl_date,
                l_multi_org_id                        org_id,

                p_base_transaction_value        burdened_cost,

                   decode(p_base_transaction_value,0,0,
                    decode(p_primary_quantity,
                        NULL,1,
                        0,p_base_transaction_value,
                        p_base_transaction_value/p_primary_quantity))
                                                burdened_cost_rate,

                  decode(p_cost_element_id,5,
                        p_bur_syslink_literal, p_wip_syslink_literal)
                                                system_linkage,

                'P'                                transaction_status_code

          FROM         dual
          WHERE  p_base_transaction_value <> 0;

  BEGIN
        -- initialize local variables
        l_err_num := 0;
        l_err_code := '';
        l_err_msg := '';
        l_use_hook_acct := FALSE;
        l_stmt_num := 1;

        l_debug := FND_PROFILE.VALUE('MRP_DEBUG');
        if (l_debug = 'Y') then
            FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Reached#: pm_process_txn_wt');
        end if;

        -- Initialize the batch name as CC followed by group_id

        l_stmt_num := 10;
        -- Modified for Bug#2218654
        -- Changed for Bug #2260708. PA import fails when you use a 15 character
        -- batch name. Instead I am using the last 8 characters of the group id
        -- so the batch name remains less than 10 chars. The likelihood of two
        -- batch numbers being the same is very low.

        SELECT 'CC'|| substr( replace( lpad(
                      to_char(p_Group_Id,'9999999999999'),14,'0') ,' ','0'),-8)
        INTO l_batch
        FROM DUAL;

        -- get exp ending date for the current transaction's transaction_date
        /* Bug 5308514 - Setting the OU context for the current organization */
        l_stmt_num := 16;
        select org_information3
        into l_operating_unit
        from hr_organization_information
        where organization_id = p_organization_id
        and org_information_context ='Accounting Information';

        l_stmt_num :=17;
        begin
         mo_global.set_policy_context('S',l_operating_unit);
        end;

        l_stmt_num := 20;
        l_exp_end_date := pa_utils.GetWeekEnding(p_transaction_date);

        IF l_exp_end_date is NULL THEN
                RAISE CST_FAILED_GET_EXPENDDATE;
        END IF;

        /* Commented for bug 6266553
        l_stmt_num := 30;
        SELECT schedule_close_date
          INTO l_gl_date
          FROM org_acct_periods oap
         WHERE oap.organization_id = p_organization_id
           AND oap.acct_period_id = p_acct_period_id;*/

        -- Get Proj/Task Number for Proj/Task Ids.
        -- Query from PJM_PROJECTS_V and PJM_TASKS_V
        -- Refer to Bug# 571127

        ----------------------------------------------------------------------
        -- MOAC Changes for R12:
        -- References to PJM_PROJECTS_V and PJM_TASKS_V has been removed and
        -- their base table pa_projects_all and pa_tasks are used instead.
        ----------------------------------------------------------------------

        BEGIN
                l_stmt_num := 35;
                IF p_project_id is NOT NULL then
                        SELECT  segment1 -- project number
                           INTO  l_project_number
                           FROM  pa_projects_all
                          WHERE  project_id = p_project_id;

                        l_stmt_num := 36;

                        SELECT  task_number
                        INTO  l_task_number
                        FROM  pa_tasks
                        WHERE  project_id = p_project_id
                        AND  task_id = p_task_id;
                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                        l_err_msg := SUBSTR(SQLERRM,1,200);
                        RAISE CST_FAILED_PROJTSK_VALID;
        END;

        -- assign multi_org_id

        l_stmt_num := 40;

        /* bug 3742735. The org_id passed should be the org_id where the transaction happened and not the OU on the project. */

        select to_number(org_information3)
        into l_multi_org_id
        from hr_organization_information
        where organization_id = p_organization_id
        and org_information_context ='Accounting Information';


        l_stmt_num := 50;

       FOR c_rec IN c_sel_wt LOOP

/* The following changes are for the support of blue print enabled organizations */
       If (p_wip_txn_source_literal = 'PJM_CSTBP_WIP_ACCOUNTS')
          OR (p_wip_txn_source_literal = 'PJM_CSTBP_WIP_NO_ACCOUNTS') then
           /* Blue print enabled org, so pass as raw */

           l_raw_cost_rate := c_rec.burdened_cost_rate;
           l_raw_cost := c_rec.burdened_cost;
           l_burdened_cost_rate := NULL;
           l_burdened_cost := NULL;

       Else /* non BP org */

           l_raw_cost_rate := c_rec.raw_cost_rate;
           l_raw_cost := c_rec.raw_cost;
           l_burdened_cost_rate := c_rec.burdened_cost_rate;
           l_burdened_cost := c_rec.burdened_cost;

       End If;

      l_stmt_num := 56;

   /* check for the transaction source to be "WIP with No Accounts". If it is
      then dont send the accounts */

      If p_wip_txn_source_literal = 'PJM_CSTBP_WIP_NO_ACCOUNTS' then

          l_dr_code_combination_id := NULL;
          l_cr_code_combination_id := NULL;

          l_wip_dr_sub_ledger_id := NULL;
          l_wip_cr_sub_ledger_id := NULL;

      else

         l_dr_code_combination_id := c_rec.dr_code_combination_id;
         l_cr_code_combination_id := c_rec.cr_code_combination_id;

         l_wip_dr_sub_ledger_id := c_rec.wip_dr_sub_ledger_id;
         l_wip_cr_sub_ledger_id := c_rec.wip_cr_sub_ledger_id;

      end if;

    l_stmt_num := 57;

    /* now check if the transaction has an employee on it .If yes then stamp it with "Straight time" source*/


       /* Bug #3449856. Use the transaction source of straight time only for
        * resource cost element. If there is a resource based overhead, it
        * should be passed with a transaction source of WIP. */
       If c_rec.employee_number is NOT NULL and p_cost_element_id <> 5 then

        fnd_file.put_line(fnd_file.log,'Setting Straight time');
        fnd_file.put_line(fnd_file.log,p_wip_straight_time_literal);
        l_transaction_source := p_wip_straight_time_literal ;

        /* set the sys linkage to the system linkage to which this transaction source maps to
           (usually this transaction source should map to the straight time system linkage) */

        Select NVL(system_linkage_function,c_rec.system_linkage) into l_syslinkage
        from pa_transaction_sources
        where transaction_source = l_transaction_source;

       else

        l_transaction_source := p_wip_txn_source_literal ;
        l_syslinkage := c_rec.system_linkage;

       End If;

     l_stmt_num := 60;

    /* bug 3345746 for Blue Print organizations the system linkage should be WIP even for overhead costs(BTC) as the
       transaction sources do not allow burdening in MFG (allow_burden_flag = 'N') */

      If (l_transaction_source = 'PJM_CSTBP_WIP_ACCOUNTS') OR (l_transaction_source = 'PJM_CSTBP_WIP_NO_ACCOUNTS')
         OR (l_transaction_source = 'PJM_CSTBP_ST_ACCOUNTS') OR (l_transaction_source = 'PJM_CSTBP_ST_NO_ACCOUNTS') then

         If l_syslinkage = p_bur_syslink_literal then
           l_syslinkage := p_wip_syslink_literal ;
         end if;

      end If;



     l_stmt_num := 62;


   /* This following insert statement into pa_transaction_interface will be changes to insert into pa_transaction_interface_all */

     /* modify the insert statement to insert the wip_resource_id and primary UOM code bug 3298023 */

        /* get the primary UOM code directly from the transaction */

        select primary_uom into l_uom_code
        from wip_transactions
        where transaction_id = p_transaction_id ;

        /*Bug 7622583*/
        select wta.currency_conversion_rate, wta.transaction_value
          into l_cc_rate, l_txn_value
          from wip_transaction_accounts wta
         where wta.transaction_id = p_transaction_id
           and accounting_line_type <> 15 /*Changes for encumbrance SF project */
           and rownum<2;

	If l_txn_value is NULL then
         l_cc_rate := 1;
        end If;

        If l_debug = 'Y' then
         fnd_file.put_line(fnd_file.log,' UOM code for the WIP txn : ' || l_uom_code);
         fnd_file.put_line(fnd_file.log,' Quantity : ' || c_rec.quantity);
         fnd_file.put_line(fnd_file.log,' Raw Cost Rate : ' ||  l_raw_cost_rate);
         fnd_file.put_line(fnd_file.log,' Currency Conversion Rate : ' ||  l_cc_rate);
        end If;

/* This following insert statement into pa_transaction_interface will be changes to insert into pa_transaction_interface_all */

        INSERT INTO pa_transaction_interface_all
        (  transaction_source,
           batch_name,
           expenditure_ending_date,
           employee_number,
           organization_name,
           expenditure_item_date,
           project_number,
           task_number,
           expenditure_type,
           quantity,
           denom_raw_cost,
           acct_raw_cost,
           expenditure_comment,
           orig_transaction_reference,
           raw_cost_rate,
           unmatched_negative_txn_flag,
           dr_code_combination_id,
           cr_code_combination_id,
           cdl_system_reference1,
           cdl_system_reference2,
           cdl_system_reference3,
           gl_date,
           org_id,
           denom_burdened_cost,
           acct_burdened_cost,
           burdened_cost_rate,
           system_linkage,
           transaction_status_code,
           denom_currency_code,
           person_business_group_name,
           wip_resource_id,
           unit_of_measure,
           cdl_system_reference4,  --WIP cr. sub Ledger ID
           cdl_system_reference5   --WIP Dr. sub LEDGER ID
        )
        VALUES
        (  l_transaction_source,
           c_rec.batch_name,
           c_rec.expenditure_ending_date,
           c_rec.employee_number,
           c_rec.organization_name,
           c_rec.expenditure_item_date,
           c_rec.project_number,
           c_rec.task_number,
           c_rec.expenditure_type,
           c_rec.quantity,
           (l_raw_cost/l_cc_rate), /*Bug 7622583*/
           l_raw_cost,
           c_rec.expenditure_comment,
           c_rec.orig_transaction_reference,
           l_raw_cost_rate,
           c_rec.unmatched_negative_txn_flag,
           l_dr_code_combination_id,
           l_cr_code_combination_id,
           c_rec.cdl_system_reference1,
           c_rec.cdl_system_reference2,
           c_rec.cdl_system_reference3,
           c_rec.gl_date,
           c_rec.org_id,
           (l_burdened_cost/l_cc_rate), /*Bug 7622583*/
           l_burdened_cost,
           l_burdened_cost_rate,
           l_syslinkage,
           c_rec.transaction_status_code,
           c_rec.denom_currency_code,
           p_business_group_name,
           p_resource_id,
           l_uom_code,
           l_wip_cr_sub_ledger_id,
           l_wip_dr_sub_ledger_id
        );
        END LOOP;

        EXCEPTION
                WHEN CST_FAILED_GET_EXPENDDATE THEN
                        O_err_num := 20001;

                        fnd_message.set_name('BOM','CST_FAILED_GET_EXPENDDATE');
                        l_err_msg := fnd_message.get ;
                        O_err_msg := substr(l_err_msg,1,240) ;

                        O_err_code := 'CSTPPCCB.pm_process_txn_wt('
                                        || to_char(l_stmt_num)
                                        || '): ';

                WHEN PROCESS_ERROR THEN
                        O_err_num := l_err_num;
                        O_err_code := l_err_code;
                        O_err_msg := l_err_msg;

                WHEN CST_FAILED_HOOK_ACCT THEN
                        O_err_num := 20002;

                        fnd_message.set_name('BOM','CST_FAILED_HOOK_ACCT');
                        l_err_msg := fnd_message.get ;
                        O_err_msg := substr(l_err_msg,1,240) ;

                        O_err_code := 'CSTPPCCB.pm_process_txn_wt('
                                        || to_char(l_stmt_num)
                                        || '): '
                                        || ' WIP Transaction_Id: '
                                        || to_char(p_transaction_id)
                                        || ' Organization_Id: '
                                        || to_char(p_organization_id);

                WHEN CST_FAILED_PROJTSK_VALID THEN
                        O_err_num := 20003;
/*
                        fnd_message.set_name('BOM','CST_FAILED_PROJTSK_VALID');
                        l_err_msg := fnd_message.get ;
                        O_err_msg := substr(l_err_msg,1,240) ;
*/
                        O_err_msg := 'Proj/Task Invalid for Cost Collection.';
                        O_err_code := SUBSTR('CSTPPCCB.pm_process_txn_wt('
                                || to_char(l_stmt_num)
                                || '): '
                                ||l_err_msg,1,240);


                WHEN OTHERS THEN
                        O_err_num := SQLCODE;
                        O_err_code := NULL;
                        O_err_msg := SUBSTR('CSTPPCCB.pm_process_txn_wt('
                                        || to_char(l_stmt_num)
                                        || '): '
                                        || SQLERRM,1,240);
END pm_process_txn_wt;

 /*----------------------------------------------------------------------------*
 | PRIVATE PROCEDURE                                                          |
 |    pm_check_error_wt                                                       |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    The procedure validates the transaction to cost collect. The validations|
 |    it performs are                                                         |
 |    1. Both the project and task columns for the txn are NOT NULL           |
 |    2. If the expenditure type for the Transactions Resource Id is not NULL |
 |    3. If the employee id is null, pa is informed the pa_expenditure_org_id |
 |       which needs to be NOT NULL  for the department in which the non labor|
 |       resource was used                                                    |
 |                                                                            |
 | PARAMETERS                                                                 |
 |                        p_transaction_id,                                   |
 |                        p_project_id,                                       |
 |                        p_task_id                                           |
 |                        p_expenditure_type                                  |
 |                        p_organization_id                                      |
 |                        p_department_id                                      |
 |                        p_employee_number                                      |
 |                        p_user_id,                                          |
 |                        p_login_id,                                         |
 |                        p_req_id,                                           |
 |                        p_prg_appl_id,                                      |
 |                        p_prg_id,                                           |
 |                        O_err_num,                                              |
 |                        O_err_code,                                         |
 |                        O_err_msg                                           |
 |                                                                            |
 | CALLED FROM                                                                |
 |    pm_cc_worker_wt()                                                       |
 |                                                                            |
 | HISTORY                                                                    |
 |    07-SEP-96  Bhaskar Dasari Created.                                      |
 *----------------------------------------------------------------------------*/

  PROCEDURE  pm_check_error_wt (
                                p_transaction_id                NUMBER,
                                     p_project_id                        NUMBER,
                                     p_task_id                        NUMBER,
                                     p_expenditure_type                VARCHAR2,
                                     p_organization_id                NUMBER,
                                     p_department_id                        NUMBER,
                                     p_employee_number                VARCHAR2,
                                     p_exp_org_name               OUT        NOCOPY VARCHAR2,
                                     p_process_yn                 OUT         NOCOPY NUMBER,
                                p_user_id                        NUMBER,
                                p_login_id                        NUMBER,
                                p_req_id                        NUMBER,
                                p_prg_appl_id                         NUMBER,
                                p_prg_id                         NUMBER,
                                     O_err_num                 OUT        NOCOPY NUMBER,
                                     O_err_code                 OUT        NOCOPY VARCHAR2,
                                     O_err_msg                 OUT        NOCOPY VARCHAR2)
  IS

  l_dummy               NUMBER;
  l_err_num             NUMBER;
  l_err_code            VARCHAR2(240);
  l_err_msg             VARCHAR2(240);
  l_err_msg_temp        VARCHAR2(240);
  l_stmt_num            NUMBER;
  PROCESS_ERROR                 EXCEPTION;
  CST_NO_EXP_ORG_FOR_DEPT       EXCEPTION;

--UTF8 changes  l_organization_name     VARCHAR2(60);
  l_organization_name   hr_organization_units.name%TYPE;
  l_exp_type            VARCHAR2(30);
  l_error_code          VARCHAR2(240);
  l_error_explanation   VARCHAR2(240);
  l_debug               VARCHAR2(80);

  l_err_in_code         VARCHAR2(240);
  l_err_in_msg          VARCHAR2(240);

  BEGIN
        -- initialize local variables
        l_err_num := 0;
        l_err_code := '';
        l_err_msg := '';
        l_err_msg_temp := '';
        l_organization_name := '';

        l_debug := FND_PROFILE.VALUE('MRP_DEBUG');
        if (l_debug = 'Y') then
            FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Reached#: pm_check_error_wt');
        end if;

        p_process_yn := 1; /* 1 Implies Process the Txn */
        --
        -- GENERIC CHECKS
        --
        -- TXNS demanding knowledge of both project and task ie. NOT NULL

        l_stmt_num := 10;
        IF p_task_id is NULL THEN

                fnd_message.set_name('BOM','CST_NO_PROJ_OR_TASK');
                l_err_msg := fnd_message.get ;
                l_err_code := 'CSTPPCCB.pm_check_error_wt('
                                || to_char(l_stmt_num)
                                || '): ';

                l_error_explanation := substr(l_err_msg,1,240) ;
                l_error_code := l_err_code;

                pm_mark_error_wt ( p_transaction_id,
                                   l_error_code,
                                   l_error_explanation,
                                   p_user_id,
                                   p_login_id,
                                   p_req_id,
                                   p_prg_appl_id,
                                   p_prg_id,
                                   l_err_num,
                                   l_err_code,
                                   l_err_msg);

                IF (l_err_num <> 0) THEN
                           -- Error occured
                           raise PROCESS_ERROR;
                ELSE
                        p_process_yn := 2;
                        l_err_num := 20003;
                        l_err_code   := l_error_code;
                        l_err_msg    := l_error_explanation;
                        raise PROCESS_ERROR;
                END IF;
        END IF;

        l_stmt_num := 20;
        IF p_expenditure_type is NULL THEN

                fnd_message.set_name('BOM','CST_SE_ET_IS_NULL');
                l_err_msg := fnd_message.get ;
                l_err_code := 'CSTPPCCB.pm_check_error_wt('
                                || to_char(l_stmt_num)
                                || '): ';

                l_error_explanation := substr(l_err_msg,1,240) ;
                l_error_code := l_err_code;

                pm_mark_error_wt ( p_transaction_id,
                                   l_error_code,
                                   l_error_explanation,
                                   p_user_id,
                                   p_login_id,
                                   p_req_id,
                                   p_prg_appl_id,
                                   p_prg_id,
                                   l_err_num,
                                   l_err_code,
                                   l_err_msg);

                IF (l_err_num <> 0) THEN
                           -- Error occured
                           raise PROCESS_ERROR;
                ELSE
                        p_process_yn := 2;
                        l_err_num := 20006;
                        l_err_code   := l_error_code;
                        l_err_msg    := l_error_explanation;
                        raise PROCESS_ERROR;
                END IF;
        END IF;

        l_organization_name := NULL;
        if p_employee_number is NULL THEN
                BEGIN
                        l_stmt_num := 30;
                        SELECT         hou.name
                              INTO         l_organization_name
                              FROM         bom_departments bd,
                                hr_organization_units hou
                           WHERE         hou.organization_id =
                                                bd.pa_expenditure_org_id
                                 AND         bd.organization_id = p_organization_id
                                 AND         bd.department_id = p_department_id;
                EXCEPTION
                        when NO_DATA_FOUND then
                                l_organization_name := 'NO VALUE';
                END;
        END IF;

        IF l_organization_name = 'NO VALUE'  THEN
                RAISE         CST_NO_EXP_ORG_FOR_DEPT;
        ELSE
                p_exp_org_name := l_organization_name;
        END IF;

        EXCEPTION

                WHEN CST_NO_EXP_ORG_FOR_DEPT THEN

                        fnd_message.set_name('BOM','CST_NO_EXP_ORG_FOR_DEPT');
                        l_err_msg := fnd_message.get ;
                        l_err_code := 'CSTPPCCB.pm_check_error_wt('
                                        || to_char(l_stmt_num)
                                        || '): ';

                        l_error_explanation := substr(l_err_msg,1,240) ;
                        l_error_code := l_err_code;

                        pm_mark_error_wt ( p_transaction_id,
                                            l_error_code,
                                            l_error_explanation,
                                            p_user_id,
                                            p_login_id,
                                            p_req_id,
                                            p_prg_appl_id,
                                            p_prg_id,
                                            l_err_num,
                                            l_err_code,
                                            l_err_msg);

                        IF (l_err_num <> 0) THEN
                                O_err_num := l_err_num;
                                O_err_code := l_err_code;
                                O_err_msg := l_err_msg;
                        ELSE
                                p_process_yn := 2;
                                O_err_num := 20008;
                                O_err_code   := l_error_code;
                                O_err_msg    := l_error_explanation;
                        END IF;

                WHEN PROCESS_ERROR THEN

                        O_err_num := l_err_num;
                        O_err_code := l_err_code;
                        O_err_msg := l_err_msg;

                WHEN OTHERS THEN
                        O_err_num := SQLCODE;
                        O_err_code := NULL;
                        l_err_msg_temp := 'CSTPPCCB.pm_check_error_wt('
                                || to_char(l_stmt_num)
                                || '): '
                                || substr(SQLERRM,1,150);

                        l_err_num := 0;

                        l_err_in_code := l_err_code;
                        l_err_in_msg := l_err_msg;

                        pm_mark_error_wt(p_transaction_id,
                                  l_err_in_code,
                                  l_err_in_msg,
                                  p_user_id,
                                  p_login_id,
                                  p_req_id,
                                  p_prg_appl_id,
                                  p_prg_id,
                                  l_err_num,
                                  l_err_code,
                                  l_err_msg);
                        IF (l_err_num <> 0) THEN
                                O_err_msg := SUBSTR(l_err_msg_temp
                                                ||' * '
                                                ||l_err_msg
                                                ||' * '
                                                ||l_err_code
                                                ||' * '
                                                ||'TXN NOT MARKED IN WTIE!'
                                                ,1,240);
                        ELSE
                                O_err_msg := SUBSTR(l_err_msg_temp
                                                ||' * '
                                                ||'TXN MARKED IN WTIE.'
                                                ,1,240);

                        END IF;
END pm_check_error_wt;

 /*----------------------------------------------------------------------------*
 | PRIVATE PROCEDURE                                                          |
 |    pm_mark_error_wt                                                       |
 |                                                                            |
 | DESCRIPTION                                                                |
 |                                                                            |
 |                                                                            |
 | PARAMETERS                                                                 |
 |                                                                            |
 |                        p_transaction_id,                                   |
 |                        p_error_code,                                       |
 |                        p_error_explanation,                                |
 |                        p_user_id,                                          |
 |                        p_login_id,                                         |
 |                        p_req_id,                                           |
 |                        p_prg_appl_id,                                      |
 |                        p_prg_id,                                           |
 |                        O_err_num,                                              |
 |                        O_err_code,                                         |
 |                        O_err_msg                                           |
 |                                                                            |
 | CALLED FROM                                                                |
 |    pm_check_error_wt()                                                    |
 |                                                                            |
 | HISTORY                                                                    |
 |    07-SEP-96  Bhaskar Dasari Created.                                      |
 *----------------------------------------------------------------------------*/

  PROCEDURE  pm_mark_error_wt (
                                p_transaction_id                NUMBER,
                                     p_error_code                              VARCHAR2,
                                     p_error_explanation                      VARCHAR2,
                                p_user_id                        NUMBER,
                                p_login_id                        NUMBER,
                                p_req_id                        NUMBER,
                                p_prg_appl_id                         NUMBER,
                                p_prg_id                         NUMBER,
                                     O_err_num              OUT        NOCOPY NUMBER,
                                     O_err_code              OUT        NOCOPY VARCHAR2,
                                     O_err_msg              OUT        NOCOPY VARCHAR2)

  IS

  l_err_num             NUMBER;
  l_err_code            VARCHAR2(240);
  l_err_msg             VARCHAR2(240);
  l_stmt_num            NUMBER;
  l_debug               VARCHAR2(80);

  BEGIN
        -- initialize local variables
        l_err_num := 0;
        l_err_code := '';
        l_err_msg := '';
        l_stmt_num := 1;

        l_debug := FND_PROFILE.VALUE('MRP_DEBUG');
        if (l_debug = 'Y') then
            FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Reached#: pm_mark_error_wt ' );
        end if;


        l_stmt_num := 10;

        UPDATE         wip_transactions wt
           SET         wt.pm_cost_collected = 'E',
                        wt.last_update_date = sysdate,
                        wt.last_updated_by = p_user_id,
                        wt.last_update_login = p_login_id,
                        wt.request_id = p_req_id,
                        wt.program_application_id = p_prg_appl_id,
                        wt.program_id = p_prg_id,
                        wt.program_update_date = sysdate
                  WHERE         wt.transaction_id = p_transaction_id ;

        l_stmt_num := 20;
        UPDATE         wip_txn_interface_errors wtie
           SET         wtie.error_message = p_error_explanation,
                wtie.last_update_date = sysdate,
                wtie.last_updated_by = p_user_id,
                wtie.last_update_login = p_login_id,
                wtie.request_id = p_req_id,
                wtie.program_application_id = p_prg_appl_id,
                wtie.program_id = p_prg_id,
                wtie.program_update_date = sysdate
         WHERE         wtie.error_column='PM_COST_COLLECTED'
           AND  wtie.transaction_id = p_transaction_id;

        IF SQL%NOTFOUND THEN

                l_stmt_num := 30;
                INSERT INTO wip_txn_interface_errors
                ( transaction_id,
                  error_message,
                  error_column,
                  last_update_date,
                  last_updated_by,
                  creation_date,
                  created_by,
                  last_update_login,
                  request_id,
                  program_application_id,
                  program_id,
                  program_update_date
                )
                VALUES ( p_transaction_id,
                         p_error_explanation,
                         'PM_COST_COLLECTED',
                         sysdate,
                         p_user_id,
                         sysdate,
                         p_user_id,
                         p_login_id,
                         p_req_id,
                         p_prg_appl_id,
                         p_prg_id,
                         sysdate
                        );
        END IF;

        EXCEPTION
                WHEN OTHERS THEN
                        O_err_num  := SQLCODE;
                        O_err_code := NULL;
                        O_err_msg  := 'CSTPPCCB.pm_mark_error_wt('
                                || to_char(l_stmt_num)
                                || '): '
                                || substr(SQLERRM,1,200);
  END pm_mark_error_wt;

 /*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    pm_get_mta_accts()                                                      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |               This procedure returns the ccid from the manufacturing       |
 |               accounting distribution table (MTA).  The parameters         |
 |               passed to this procedure relate to records in mcacd/cicd.    |
 |               Since project interface is only concerned with the dr column,|
 |               the accounting information is extracted from mta based on    |
 |               the sign of primary transaction quantity.  Based on          |
 |               transaction specific distribution, accounting line type is   |
 |               passed to obtain the account that will be populated in the   |
 |               credit column of project interface table.                    |
 |                                                                            |
 |                                                                            |
 | CALLED FROM                                                                |
 |    pm_process_txn_mmt()                                                    |
 -----------------------------------------------------------------------------*/

PROCEDURE pm_get_mta_accts  (
    p_transaction_id         NUMBER,
    p_cost_element_id        NUMBER,
    p_resource_id            NUMBER,
    p_source_flag            NUMBER,
    p_variance_flag          NUMBER,
    O_dr_code_combination_id IN OUT NOCOPY NUMBER,
    O_cr_code_combination_id IN OUT NOCOPY NUMBER,
    O_inv_cr_sub_ledger_id   OUT NOCOPY  NUMBER,
    O_inv_dr_sub_ledger_id   OUT NOCOPY  NUMBER,
    O_cc_rate                OUT NOCOPY  NUMBER,
    O_err_num                OUT NOCOPY  NUMBER,
    O_err_code               OUT NOCOPY  VARCHAR2,
    O_err_msg                OUT NOCOPY  VARCHAR2)
IS

l_transaction_action_id       NUMBER;
l_transaction_source_type_id  NUMBER;
l_organization_id             NUMBER;
l_mta_organization_id         NUMBER;
l_mta_transaction_id          NUMBER;
l_source_flag                 NUMBER;
l_citw_flag                   NUMBER;
l_xfer_organization_id        NUMBER;
l_xfer_transaction_id         NUMBER;
l_subinventory_code           VARCHAR2(11);
l_transfer_subinventory       VARCHAR2(11);
l_inventory_item_id           NUMBER;
l_type_class                  NUMBER;
l_fob_point                   NUMBER;
l_si_asset_yes_no             NUMBER;
l_transfer_si_asset_yes_no    NUMBER;
l_exp_flag                    NUMBER;
l_exp_item                    NUMBER;
l_xfer_exp_flag               NUMBER;
l_accounting_line_type        NUMBER;
l_cost_element_id             NUMBER;
l_mta_primary_quantity        NUMBER;
l_mmt_primary_quantity        NUMBER;
l_resource_id                 NUMBER;
l_cg_id                       NUMBER;
l_xfer_cg_id                  NUMBER;
l_stmt_num                    NUMBER;
l_txn_type_id                 NUMBER;
l_debug                       VARCHAR2(80);
l_cost_method                 NUMBER;
l_xfer_cost_method            NUMBER;
l_blue_print_enabled          VARCHAR2(1);
l_autoaccounting_flag         VARCHAR2(1);
l_wip_txn_source_type         NUMBER;
l_cc_rate                     NUMBER;
l_txn_value                   NUMBER;

CST_NO_ACCOUNT_FOUND            EXCEPTION;

BEGIN

  O_dr_code_combination_id := -999999;
  O_cr_code_combination_id := -999999;
  l_accounting_line_type := -99;
  l_cost_element_id      := -99;
  l_mmt_primary_quantity :=   0;
  l_stmt_num := 0;
  l_xfer_cost_method := 0;
  l_wip_txn_source_type := '';

  l_debug := FND_PROFILE.VALUE('MRP_DEBUG');
  if (l_debug = 'Y') then
    FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Reached#: pm_get_mta_accts');
  end if;

  BEGIN
        /******   Get Transaction Information ******/
  l_stmt_num := 5;
  SELECT
    mmt.transaction_action_id,
    mmt.transaction_source_type_id,
    mmt.organization_id,
    mmt.transfer_organization_id,
    mmt.transfer_transaction_id,
    mmt.cost_group_id,
    mmt.transfer_cost_group_id,
    mmt.transfer_subinventory,
    mmt.inventory_item_id,
    mmt.primary_quantity,
    mmt.transaction_type_id,
    mtt.type_class
  INTO l_transaction_action_id,
    l_transaction_source_type_id,
    l_organization_id,
    l_xfer_organization_id,
    l_xfer_transaction_id,
    l_cg_id,
    l_xfer_cg_id,
    l_transfer_subinventory,
    l_inventory_item_id,
    l_mmt_primary_quantity,
    l_txn_type_id,
    l_type_class
  FROM mtl_material_transactions mmt,
       mtl_transaction_types mtt
  WHERE mmt.transaction_id = p_transaction_id
  AND mtt.transaction_type_id = mmt.transaction_type_id;

  IF l_transaction_action_id <> 17 THEN
    l_stmt_num := 10;
    SELECT mmt.subinventory_code,
           msi.asset_inventory
    INTO
      l_subinventory_code,
      l_si_asset_yes_no
    FROM MTL_MATERIAL_TRANSACTIONS mmt,
         MTL_SECONDARY_INVENTORIES msi
    WHERE
    mmt.transaction_id = p_transaction_id
    AND msi.secondary_inventory_name = mmt.subinventory_code
    AND msi.organization_id          = mmt.organization_id;

    l_stmt_num := 15;
          -- Get Item Expense  Flag
    SELECT decode(inventory_asset_flag, 'Y',0,1)
    INTO l_exp_item
    FROM mtl_system_items msi
    WHERE msi.inventory_item_id = l_inventory_item_id
    AND   msi.organization_id =  l_organization_id;

    l_stmt_num := 20;
    -- Set Expense Flag
    SELECT decode(l_exp_item,1,1,decode(l_si_asset_yes_no,1,0,1))
    INTO l_exp_flag
    FROM mtl_secondary_inventories msi
    WHERE msi.secondary_inventory_name = l_subinventory_code
    AND   msi.organization_id = l_organization_id;
  ELSE
   l_subinventory_code := NULL;
   l_si_asset_yes_no   := 0;
   l_exp_item := 1;
   l_exp_flag := 1;
  END IF;


  l_stmt_num := 25;
  /******  Set l_xfer_exp_flag ******/
  IF (l_transfer_subinventory IS NOT NULL) THEN
    SELECT msub.asset_inventory,
           decode(mitems.inventory_asset_flag,
           'Y', decode(msub.asset_inventory,1,0,1), 1)
    INTO l_transfer_si_asset_yes_no,
         l_xfer_exp_flag
    FROM mtl_secondary_inventories msub,
         mtl_system_items mitems
    WHERE msub.secondary_inventory_name = l_transfer_subinventory
    AND   msub.organization_id = l_xfer_organization_id
    AND   mitems.inventory_item_id = l_inventory_item_id
    AND   mitems.organization_id   = l_xfer_organization_id;
  END IF;

  -- Modified for fob stamping project
  l_stmt_num := 30;
  /******   Get FOB POINT ******/
  IF (l_xfer_organization_id IS NOT NULL) THEN
    IF l_transaction_action_id = 21 THEN /* Intransit Shipment */
      SELECT nvl(MMT.fob_point, MSNV.fob_point) INTO l_fob_point
      FROM mtl_shipping_network_view MSNV,
           mtl_material_transactions MMT
      WHERE MSNV.from_organization_id = l_organization_id
      AND MSNV.to_organization_id = l_xfer_organization_id
      AND MMT.transaction_id = p_transaction_id;
    ELSIF l_transaction_action_id = 12 THEN /* Intransit Receipt */
      SELECT nvl(MMT.fob_point, MSNV.fob_point)
      INTO l_fob_point
      FROM mtl_shipping_network_view MSNV,
           mtl_material_transactions MMT
      WHERE MSNV.from_organization_id = l_xfer_organization_id
      AND MSNV.to_organization_id = l_organization_id
      AND MMT.transaction_id = p_transaction_id;
    END IF;
  END IF;

  l_stmt_num := 35;
  /* Bug #2128760. CITW only applies to average costing orgs */
  SELECT primary_cost_method
  INTO l_cost_method
  FROM mtl_parameters
  WHERE organization_id = l_organization_id;

  l_stmt_num := 40;
  /* Check for standard to standard direct interorg transfers. In this case
     the accounting entries are all made against the sending transaction_id. */
  IF (l_xfer_organization_id IS NOT NULL) THEN
    SELECT primary_cost_method
    INTO l_xfer_cost_method
    FROM mtl_parameters
    WHERE organization_id = l_xfer_organization_id;
  END IF;

  l_stmt_num := 45;
  /******   Set CITW FLAG ******/
  IF (l_transaction_action_id = 1 AND l_transaction_source_type_id = 5
      AND l_cg_id <> NVL(l_xfer_cg_id,-9)
      AND l_xfer_cg_id IS NOT NULL
      AND l_cost_method = 2) THEN
    l_citw_flag := 1;
  ELSE
                  l_citw_flag := -1;
  END IF;

  l_stmt_num := 50;
        /******   Start Dr Account Processing ******/
  l_source_flag := p_source_flag;
  l_mta_transaction_id := p_transaction_id;
  l_mta_organization_id := l_organization_id;

  IF (l_source_flag = 1) THEN
    IF l_type_class = 1 THEN
      l_accounting_line_type := 2;
      l_cost_element_id := -99;
    ELSIF (l_citw_flag = 1) THEN
      l_accounting_line_type := 1; -- Project CG is Dr
      l_wip_txn_source_type := 13; --INV txn SRC
      l_cost_element_id := NVL(p_cost_element_id, -99);
    ELSIF (l_transaction_action_id = 3) THEN
                /* If direct interorg is between standard costing orgs,
                         no need for this as all mta entries will be against
                         the sending transaction */
      IF ( l_cost_method <> 1 OR
           l_xfer_cost_method <> 1 OR
           l_mmt_primary_quantity>0) THEN
        l_mta_transaction_id := l_xfer_transaction_id;
      END IF;
      l_mta_organization_id := l_xfer_organization_id;
      IF (l_xfer_exp_flag = 0) THEN
        l_accounting_line_type := 1;
      ELSE
        l_accounting_line_type := 2;
      END IF;
      If ( NVL(p_cost_element_id,-99)= 2 AND
           NVL(p_resource_id,-99) <> -99) then
        l_cost_element_id :=2 ; /* Mat Abs at receiving */
      ELSE
        l_cost_element_id := NVL(p_cost_element_id,-99); /* NOT Always MAT at REC ORG */
      End If;
    ELSIF l_transaction_source_type_id = 5 THEN --WIP/CFM
      l_accounting_line_type := 7;
      l_cost_element_id := NVL(p_cost_element_id, -99);
    /* bug 3150050 include staging Txfrs */
    ELSIF l_transaction_action_id in (2,28) THEN --SUB Xfer
      IF l_xfer_exp_flag = 0 THEN
        l_accounting_line_type := 1;
      ELSE
        l_accounting_line_type := 2;
      END IF;

         l_cost_element_id := NVL(p_cost_element_id, -99);
        -- =====================================================
        -- FP BUG 8614146 fix : set l_cost_element_id to -99 when
	-- source flag is 1, txn_action_id in 2,28 and
	-- expense flag is 1 (expense item or expense sub inv)
	-- for standard costing method
	-- NOTE: In MTA, it is OK to have cost_element_id NULL
	-- for accounting_line_type 2 for expense destination
	-- =====================================================
        If (l_xfer_exp_flag = 1 AND l_cost_method = 1) then
           l_cost_element_id := -99;
        End If;

    /* Logical Expense Requisition Receipt */
    ELSIF (l_transaction_action_id = 17) THEN
      L_accounting_line_type := 2; -- Account
    END IF;
    l_mta_primary_quantity := -1 * l_mmt_primary_quantity;

  ELSE /* Not Src_Flag */
    IF (l_transaction_action_id = 3 AND
        l_cost_method = 1 AND
        l_xfer_cost_method = 1 AND
        l_mmt_primary_quantity > 0) THEN
      l_mta_transaction_id := l_xfer_transaction_id;
    END IF;
    IF ( l_transaction_action_id = 2 )
        AND ( l_cg_id <> l_xfer_cg_id)
        AND (l_txn_type_id = 68)
        AND (p_variance_flag = 1) THEN
      l_accounting_line_type := 13; -- Payback Transaction
    -- STD PJM
    ELSIF ( p_variance_flag = 1 AND
          ( l_transaction_source_type_id = 1
            OR l_transaction_action_id IN (12,21,3)
            OR (l_transaction_action_id = 6 ))) THEN
            /* Consigned ownership transfer transactions */
      IF (l_transaction_action_id = 3 AND
          l_cost_method <> 1 AND
          l_xfer_cost_method = 1 AND
          l_mmt_primary_quantity < 0) THEN
         l_mta_transaction_id := l_xfer_transaction_id;
                           l_mta_organization_id := l_xfer_organization_id;
      ELSIF (l_transaction_action_id = 3 AND
             l_cost_method = 1 AND
             l_xfer_cost_method = 1 AND
             l_mmt_primary_quantity < 0) THEN
        l_mta_organization_id := l_xfer_organization_id;
 	       ELSIF (l_transaction_action_id = 21 AND
 	              l_cost_method = 1 AND
 	              l_xfer_cost_method = 1 AND
 	              l_fob_point = 1 ) THEN
         l_mta_organization_id := l_xfer_organization_id;
      END IF;
      -- PPV
      l_accounting_line_type := 6;
    /* Internal Sales order Issue to Expense */
    ELSIF(l_transaction_action_id = 1 AND l_transaction_source_type_id = 8) THEN
      L_accounting_line_type := 10; -- Interorg Receivables
    ELSIF (l_transaction_action_id = 17) THEN
      L_accounting_line_type := 2; -- Account
    ELSE  -- the following is neither payback nor PPV
      IF l_exp_flag = 0 THEN
        l_accounting_line_type := 1;
      ELSE
        l_accounting_line_type := 2;
      END IF;
      /* check for common issue to wip,if yes then set the source to be used */
      If l_citw_flag = 1 then
        l_wip_txn_source_type := 13;
      else
        l_wip_txn_source_type := '';
      end if;
    END IF;

    l_cost_element_id := NVL(p_cost_element_id, -99);

/*      Bug 3978501.Change the l_cost_element_id to -99 for expense item or expense  */
/*      sub as MTA will have the Dr entry with cost element id of NULL for expense  */
/*      item receipts   */
/*      Exclude Internal Order Issues to Expense  */
/*      I know that's messed up.. But.  */
/* bugs 4655264 and 4651130. In consistencies between standard and Average costing orgs. THe cost processor stamps a
   cost element ID against the AL of 2 in the case of Average costing orgs and in the case of std costing orgs
   there is no CE stamped against the AL 2.Need to handle them separately. */


    if ( l_exp_flag = 1  AND l_transaction_action_id <> 17 AND l_cost_method = 1) then
      l_cost_element_id := -99;
    End If;
    l_mta_primary_quantity := l_mmt_primary_quantity;

    /* Bug 6461155 */

          if (l_transaction_action_id = 29 and l_transaction_source_type_id = 1)
then

           l_cost_element_id := -99;
           l_mta_primary_quantity := -1 * l_mmt_primary_quantity;
           l_accounting_line_type := 5;

          fnd_file.put_line(fnd_file.log,'PO delivery Adjustment transaction');

          end if;

  END IF;

  if (l_debug = 'Y') then
    FND_FILE.PUT_LINE (FND_FILE.LOG,
                                'DEBIT DATA. Txn: '||to_char(l_mta_transaction_id)
                                ||' Exp_Flag: '||to_char(l_exp_flag)
                                ||' Xfer_Exp_Flag: '
                                ||to_char(l_xfer_exp_flag)
                                ||' Org: '||to_char(l_mta_organization_id)
                                ||' Item: '||to_char(l_inventory_item_id)
                                ||' CE: '||to_char(l_cost_element_id)
                                ||' AL: '||to_char(l_accounting_line_type)
                                ||' Qty: '||to_char(l_mta_primary_quantity)
                                ||' l_cost_method ' || to_char(l_cost_method)
                                ||' l_xfer_cost_method '||to_char(l_xfer_cost_method)
                                ||' Src Flag '||to_char(l_source_flag)
                                ||' Transfer txn '||to_char(l_xfer_transaction_id)
                                ||' Transfer org '||to_char(l_xfer_organization_id)
                                ||' WIP Txn Src Type ' || to_char(l_wip_txn_source_type)
                                );
  END IF;

  SELECT  NVL(MAX(mta.reference_account), -999999)
  INTO    O_dr_code_combination_id
  FROM    mtl_transaction_accounts mta
  WHERE
    mta.transaction_id            = l_mta_transaction_id        AND
    mta.organization_id           = l_mta_organization_id       AND
    mta.inventory_item_id         = l_inventory_item_id         AND
    nvl(mta.cost_element_id, -99) = l_cost_element_id           AND
    mta.accounting_line_type      = l_accounting_line_type    AND
    mta.primary_quantity          = decode(p_variance_flag, 1, mta.primary_quantity,
                                           decode(l_source_flag, 1,
                                           decode(l_transaction_action_id, 3, mta.primary_quantity,
                                           l_mta_primary_quantity), l_mta_primary_quantity)) AND
    (((l_citw_flag = 1) AND
      (mta.transaction_source_type_id = l_wip_txn_source_type)) OR(l_citw_flag <> 1));


   l_stmt_num := 53;

   /* Changes to get the Debit INV sub Ledger ID from MTA  for the dr account fecthed above*/

  If O_dr_code_combination_id <> -999999 then

   SELECT MAX(INV_SUB_LEDGER_ID)
    INTO  O_inv_dr_sub_ledger_id
    FROM  mtl_transaction_accounts mta
   WHERE
    mta.reference_account         = O_dr_code_combination_id    AND
    mta.transaction_id            = l_mta_transaction_id        AND
    mta.organization_id           = l_mta_organization_id       AND
    mta.inventory_item_id         = l_inventory_item_id         AND
    nvl(mta.cost_element_id, -99) = l_cost_element_id           AND
    mta.accounting_line_type      = l_accounting_line_type    AND
    mta.primary_quantity          = decode(p_variance_flag, 1, mta.primary_quantity,
                                           decode(l_source_flag, 1,
                                           decode(l_transaction_action_id, 3, mta.primary_quantity,
                                           l_mta_primary_quantity), l_mta_primary_quantity)) AND
    (((l_citw_flag = 1) AND
      (mta.transaction_source_type_id = l_wip_txn_source_type)) OR(l_citw_flag <> 1));

  End If;

/*  BUG 9412469: Obtain the rate information to pass it to */
/*  pm_insert_pti_pvt since   l_mta_transaction_id   and   */
/*  l_mta_organization_id already contain the logic to     */
/*  select the appropiate transaction to query in MTA      */
/*  including the cases for subinventory transfers and     */
/*  direct interorg between the different combinations     */
/*  it also will centralize this procedure from the DR line*/
/*  This will revert the changes in 7622583 since the logic*/
/*  in there will not derive the txn to be queried in MTA  */
/*  correctly                                              */
  l_stmt_num := 54;

         select mta.currency_conversion_rate, mta.transaction_value
            into l_cc_rate, l_txn_value
         from   mtl_transaction_accounts mta
         where  mta.transaction_id = l_mta_transaction_id
           and  mta.organization_id = l_mta_organization_id
           and  mta.accounting_line_type <> 15    /*Added for Encumbrance project */
           and  rownum<2;
        If l_txn_value is NULL then
         l_cc_rate := 1;
        end If;
         O_cc_rate := l_cc_rate;
        If l_debug = 'Y' then
         fnd_file.put_line(fnd_file.log,' Currency Conversion Rate : ' ||  l_cc_rate);
        end If;

/*  The decode stmt incorporated the fix for bug 917729 and 967071  */
/*  bug 917729, for borrow payback txn, don't need to  */
/*  join the primary quantity  */
/*  Bug#967071. Changed the where clause , if sending and recv orgs have  */
/*  different UOM then primary qty will be different   */


  l_stmt_num := 55;
  /******   Start Cr Account Processing ******/
  IF O_dr_code_combination_id <> -999999 THEN /* Valid Dr A/C */
    IF (l_citw_flag = 1) THEN /* MAIN IF */
      SELECT
        NVL((MAX(mta.reference_account)),-999999)
      INTO O_cr_code_combination_id
      FROM mtl_transaction_accounts mta
      WHERE mta.transaction_id = p_transaction_id
      AND mta.organization_id = l_organization_id
      AND mta.inventory_item_id = l_inventory_item_id
      AND NVL(mta.cost_element_id,-99)= NVL(p_cost_element_id,-99)
      AND mta.accounting_line_type = 1
      AND mta.primary_quantity = decode(l_source_flag,1,l_mmt_primary_quantity,((-1)*l_mmt_primary_quantity))
      AND mta.transaction_source_type_id = 13; --ALWAYS INV

      l_stmt_num := 57;

      /* changes to get the Credit INV sub ledger ID for the credit side  from MTA */

      Select MAX(INV_SUB_LEDGER_ID)
      into   O_inv_cr_sub_ledger_id
      from   mtl_transaction_accounts mta
      where  mta.reference_account = O_cr_code_combination_id
      AND    mta.transaction_id = p_transaction_id
      AND    mta.organization_id = l_organization_id
      AND    mta.inventory_item_id = l_inventory_item_id
      AND    NVL(mta.cost_element_id,-99)= NVL(p_cost_element_id,-99)
      AND    mta.accounting_line_type = 1
      AND    mta.primary_quantity = decode(l_source_flag,1,l_mmt_primary_quantity,((-1)*l_mmt_primary_quantity))
      AND    mta.transaction_source_type_id = 13; --ALWAYS INV

      l_stmt_num := 58;

      /* Check if Org is Blue print.If yes then use clearing Accts */
      BEGIN
      Select NVL(pa_posting_flag,'N'),
             NVL(pa_autoaccounting_flag,'N')
      into l_blue_print_enabled,
           l_autoaccounting_flag
      from pjm_org_parameters
      where organization_id = l_mta_organization_id;
      EXCEPTION
      WHEN NO_DATA_FOUND then
        l_blue_print_enabled := 'N';
        l_autoaccounting_flag := 'N';
      END;
      If l_blue_print_enabled = 'Y' AND l_autoaccounting_flag = 'N' then
        SELECT NVL(MAX(pjm_clearing_account),-999999)
        INTO O_cr_code_combination_id
        FROM pjm_org_parameters
        where organization_id = l_mta_organization_id;

        O_inv_cr_sub_ledger_id := NULL;

        If O_cr_code_combination_id = -999999 then
          raise CST_NO_ACCOUNT_FOUND;
        end If;
      End If;
    ELSIF (l_source_flag = 1) THEN /*Source Txn */
      IF (l_transaction_action_id = 3) THEN /* Dir IO */
        If (NVL(p_cost_element_id,-99) = 2 AND
            NVL(p_resource_id,-99) <> -99 ) then
          l_cost_element_id := 2;
          l_accounting_line_type := 3;
        else
          l_cost_element_id := -99;
          select (decode(sign(l_mmt_primary_quantity),1,10,9))
          into l_accounting_line_type
          from dual;
        End If;
                                l_mta_primary_quantity:=l_mmt_primary_quantity;
      ELSIF ( l_transaction_action_id = 1 AND
              l_transaction_source_type_id = 8 ) THEN
        L_accounting_line_type := 1;
        l_cost_element_id := -99;
        l_mta_primary_quantity := l_mmt_primary_quantity;
      ELSIF (l_transaction_action_id = 17) THEN
        L_accounting_line_type := 9;
        l_cost_element_id := -99;
        l_mta_primary_quantity := l_mmt_primary_quantity;
      ELSE
        IF l_exp_flag = 0 THEN
          l_accounting_line_type := 1;
        ELSE
          l_accounting_line_type := 2;
        END IF;
        l_cost_element_id :=NVL(p_cost_element_id,-99);
        l_mta_primary_quantity:=l_mmt_primary_quantity;
      END IF;
    ELSE /* Neither CITW Nor Source_Flg */
      IF NVL(p_resource_id,-99) <> -99 THEN /* Res Not Null*/
        l_accounting_line_type := 3; --OHA
        l_cost_element_id :=2;       --MOH
        l_mta_primary_quantity := -1 * l_mmt_primary_quantity;
      ELSIF l_transaction_action_id = 3 and p_variance_flag =1 then
        /* handle PPV for direct interorgs receiving side */
        l_accounting_line_type := 9;
        /* the MTA primary Qty is always - against the Rcv */
        if l_mmt_primary_quantity < 0 then
          l_mta_primary_quantity := l_mmt_primary_quantity;
        else
          l_mta_primary_quantity := -1 * l_mmt_primary_quantity;
        end if;
      ELSE
        l_mta_primary_quantity := -1 * l_mmt_primary_quantity;
        SELECT
        decode(l_transaction_action_id, 3, --Direct IO Xfer
        decode(sign(l_mmt_primary_quantity), 1,9, --IO Pyble
        10), --IO Rcvble
        32, 7, --Assy Return
        31, 7, --Assy Complete
        33, 7, --Neg WIP Issue
        34, 7, --Neg WIP Return
        2, decode(l_xfer_exp_flag, 0,1, 2), --Sub Xfer
        4, 2, --Cycle Count
        8, 2, --Phy Inv
        12, --Intransit Receipt
        decode(nvl(l_fob_point,-99), 1,14, 2,9), 21, --Intransit Shipment
        decode(nvl(l_fob_point,-99), 1,10, 2,14), 29, decode(l_transaction_source_type_id, 1,5), --PO Adj
        1, decode(l_transaction_source_type_id, 1, 5, --RTV
        3, 2, --A/C Issue
        5, 7, --WIP/CFM
        6, 2, --Ali Issue
        13,2), --Misc Issue
        27, decode(l_transaction_source_type_id, 1, 5, --PO Receipt
        3, 2, --A/C Receipt
        5, 7, --WIP/CFM
        6, 2, --Ali Receipt
        13,2), --Misc Rcpt
        6,16, /*consigned ownership transfer */
        26,31, /* Logical PO receipt for BP org */
        28,1, /* staging Txfrs */
        17, 9, /* Logical Expense Requition Receipt */ -99)
        INTO l_accounting_line_type
        FROM DUAL;

        IF l_accounting_line_type IN (7,1,14) THEN
          l_cost_element_id := NVL(p_cost_element_id,-99);
        ELSIF l_accounting_line_type = 2 AND l_transaction_action_id =2 THEN
          l_cost_element_id := NVL(p_cost_element_id,-99);
        ELSIF l_accounting_line_type = 9 AND l_transaction_action_id = 17 THEN
          l_cost_element_id := NVL(p_cost_element_id,-99);
        ELSE
          l_cost_element_id := -99;
        END IF;

      END IF; /* Res Not Null */
    END IF; /*MAIN IF */

    IF (l_citw_flag <> 1) THEN
      IF l_debug = 'Y' THEN
        FND_FILE.put_line(fnd_file.log, 'CREDIT DATA: ');
        FND_FILE.put_line(fnd_file.log, 'Cost Element: '||to_char(l_cost_element_id) || ' Accounting Line Type: '||to_char(l_accounting_line_type)||' Primary Quantity: '||to_char(l_mta_primary_quantity));
      END IF;
-- Bug 936641, for borrow payback variance, should NOT
-- store both Cr and Dr with the same accounting information
-- The line 'O_cr_code_combination_id := O_dr_code_combination_id;'
-- was removed.
-- The credit accounts for project transfer txns will be replaced
-- with clearing accounts for blue print orgs
-- Bug 3662806. Enclose Begin and end for non PJM orgs
      l_stmt_num := 60;
      BEGIN
      Select NVL(pa_posting_flag,'N'),
             NVL(pa_autoaccounting_flag,'N')
      into l_blue_print_enabled,
           l_autoaccounting_flag
      from pjm_org_parameters
      where organization_id = l_mta_organization_id;
      EXCEPTION
      WHEN NO_DATA_FOUND then
        l_blue_print_enabled := 'N';
        l_autoaccounting_flag := 'N';
      END;
      if ((l_transaction_action_id = 2) OR (l_transaction_action_id = 1
          AND l_transaction_source_type_id = 5) OR l_transaction_action_id = 28)
          AND l_blue_print_enabled= 'Y'
          AND l_autoaccounting_flag = 'N' then
        SELECT NVL(MAX(pjm_clearing_account),-999999)
        INTO O_cr_code_combination_id
        FROM pjm_org_parameters
        where organization_id = l_mta_organization_id;

        O_inv_cr_sub_ledger_id := NULL;

        If O_cr_code_combination_id = -999999 then
          raise CST_NO_ACCOUNT_FOUND;
        end If;
      else
      /* Non blue print or non project transfer txns
         changed the join condition on the cost element ID to get the correct account */
        SELECT  NVL(MAX(mta.reference_account), -999999)
        INTO    O_cr_code_combination_id
        FROM    mtl_transaction_accounts mta
        WHERE
        mta.transaction_id            =l_mta_transaction_id  AND
        mta.organization_id           =l_mta_organization_id AND
        mta.inventory_item_id         =l_inventory_item_id AND
        nvl(mta.cost_element_id, -99) =decode(l_cost_element_id,-99,nvl(mta.cost_element_id,-99),l_cost_element_id)   AND
        nvl(mta.resource_id, -99) = nvl(p_resource_id,-99)  AND
        mta.accounting_line_type   = l_accounting_line_type AND
        mta.primary_quantity = l_mta_primary_quantity;

       /* Changes to get the INV sub ledger ID for the credit account from MTA */

       SELECT MAX(INV_SUB_LEDGER_ID)
         INTO O_inv_cr_sub_ledger_id
        FROM  mtl_transaction_accounts mta
        WHERE
        mta.reference_account         = O_cr_code_combination_id AND
        mta.transaction_id            =l_mta_transaction_id  AND
        mta.organization_id           =l_mta_organization_id AND
        mta.inventory_item_id         =l_inventory_item_id AND
        nvl(mta.cost_element_id, -99) =decode(l_cost_element_id,-99,nvl(mta.cost_element_id,-99),l_cost_element_id)   AND
        nvl(mta.resource_id, -99) = nvl(p_resource_id,-99)  AND
        mta.accounting_line_type   = l_accounting_line_type AND
        mta.primary_quantity = l_mta_primary_quantity;

      end if;
    END IF; -- l_citw_flag <> 1

    IF O_cr_code_combination_id = -999999 THEN
      O_cr_code_combination_id := O_dr_code_combination_id;
      O_inv_cr_sub_ledger_id   := O_inv_dr_sub_ledger_id;

      IF l_debug = 'Y' THEN
        FND_FILE.put_line(FND_FILE.log, 'Credit Account not found. It will be set the same as Debit account');
      END IF;

    END IF;

  ELSE
    RAISE CST_NO_ACCOUNT_FOUND;
  END IF; /* Valid Dr A/C */

  EXCEPTION
    WHEN CST_NO_ACCOUNT_FOUND THEN
      O_err_num := -1;
      O_err_code := NULL;
      O_err_msg := SUBSTR('No Account Retrieved.'
                                        || '('
                                        ||to_char(l_stmt_num)
                                        ||') '
                                        ||' Txn_id: '
                                        ||to_char(p_transaction_id)
                                        ||' CE: '
                                        ||to_char(p_cost_element_id)
                                        ||' Rsrc: '
                                        ||to_char(p_resource_id)
                                        ||' Src_flag: '
                                        ||to_char(p_source_flag)
                                        ||' Borrow payback variance: '
                                        ||to_char(p_variance_flag),1,200);
    WHEN OTHERS THEN
      IF O_dr_code_combination_id <> -999999 THEN
        O_cr_code_combination_id := O_dr_code_combination_id;
        O_inv_cr_sub_ledger_id   := O_inv_dr_sub_ledger_id;
      ELSE
        O_dr_code_combination_id := -999999;
        O_cr_code_combination_id := -999999;
        O_inv_dr_sub_ledger_id   := NULL;
        O_inv_cr_sub_ledger_id   := NULL;
        O_err_num := SQLCODE;
        O_err_code := NULL;
        O_err_msg := SUBSTR('CSTPPCCB.pm_get_mta_accts('
                                        ||to_char(l_stmt_num)
                                        ||'): '
                                        ||SQLERRM,1,240);
      END IF;
  END;
END pm_get_mta_accts;

 /*----------------------------------------------------------------------------*
 | PRIVATE FUNCTION                                                           |
 |    get_max_group_size                                                      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |                                                                            |
 |    This function will return the maximum number of records that a single   |
 |    worker should process.                                                  |
 |                                                                            |
 | PARAMETERS                                                                 |
 |                                                                            |
 | RETURNS                                                                    |
 |      Records with in a Single Group                                        |
 |                                                                            |
 | CALLED FROM                                                                |
 |    pm_cc_manager                                                           |
 |                                                                            |
 | HISTORY                                                                    |
 |    07-SEP-96  Bhaskar Dasari Created.                                      |
 *----------------------------------------------------------------------------*/

  FUNCTION  get_group_size   RETURN NUMBER IS

  max_group_size_per_worker NUMBER := 3000;
  BEGIN

        return ( max_group_size_per_worker );

  END get_group_size;


 /*----------------------------------------------------------------------------*
 | PRIVATE PROCEDURE                                                          |
 |    pm_ins_pti_pvt                                                          |
 |                                                                            |
 | DESCRIPTION                                                                |
 |                                                                            |
 |    This procedure will call accounting  hook and cost collector hook andt  |
 |    it will manage the insertion of records in PA_TRANSACTIONS_INTERFACE    |
 |                                                                            |
 | PARAMETERS                                                                 |
 |                                                                            |
 |                                                                            |
 | CALLED FROM                                                                |
 |    pm_process_txn_mmt                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |    23-APR-01  Hemant Gosain Created.                                       |
 *----------------------------------------------------------------------------*/

  PROCEDURE  pm_insert_pti_pvt
                  (p_transaction_source                        VARCHAR2,
                      p_batch_name                                VARCHAR2,
                      p_expenditure_ending_date                DATE,
                      p_employee_number                        VARCHAR2,
                      p_organization_name                        VARCHAR2,
                      p_expenditure_item_date                DATE,
                      p_project_number                        VARCHAR2,
                      p_task_number                        VARCHAR2,
                      p_expenditure_type                        VARCHAR2,
                      p_pa_quantity                        NUMBER,
                      p_raw_cost                                NUMBER,
                      p_expenditure_comment                VARCHAR2,
                      p_orig_transaction_reference                VARCHAR2,
                      p_raw_cost_rate                        NUMBER,
                      p_unmatched_negative_txn_flag        VARCHAR2,
                      p_gl_date                                DATE,
                   p_org_id                                NUMBER,
                   p_burdened_cost                        NUMBER,
                   p_burdened_cost_rate                        NUMBER,
                   p_system_linkage                        VARCHAR2,
                   p_transaction_status_code                VARCHAR2,
                   p_denom_currency_code                VARCHAR2,

                   p_transaction_id                     NUMBER,
                   p_transaction_action_id              NUMBER,
                   p_transaction_source_type_id         NUMBER,
                   p_organization_id                    NUMBER,
                   p_inventory_item_id                  NUMBER,
                   p_cost_element_id                    NUMBER,
                   p_resource_id                        NUMBER,
                   p_source_flag                        NUMBER,
                   p_variance_flag                      NUMBER,
                   p_primary_quantity                   NUMBER,
                   p_transfer_organization_id           NUMBER,
                   p_fob_point                          NUMBER,
                   p_wip_entity_id                      NUMBER,
                   p_basis_resource                     NUMBER,

                   p_type_class                         NUMBER,
                   p_project_id                         NUMBER,
                   p_task_id                            NUMBER,
                   p_transaction_date                   DATE,
                   p_cost_group_id                      NUMBER,
                   p_transfer_cost_group_id             NUMBER,
                   p_transaction_source_id              NUMBER,
                   p_to_project_id                        NUMBER,
                   p_to_task_id                         NUMBER,
                   p_source_project_id                  NUMBER,
                   p_source_task_id                     NUMBER,
                   p_transfer_transaction_id            NUMBER,
                   p_primary_cost_method                NUMBER,
                   p_acct_period_id                     NUMBER,
                   p_exp_org_id                         NUMBER,
                   p_distribution_account_id            NUMBER,
                   p_proj_job_ind                       NUMBER,
                   p_first_matl_se_exp_type             VARCHAR2,
                   p_inv_txn_source_literal             VARCHAR2,
                   p_cap_txn_source_literal             VARCHAR2,
                   p_inv_syslink_literal                VARCHAR2,
                   p_bur_syslink_literal                VARCHAR2,
                   p_wip_syslink_literal                VARCHAR2,
                   p_user_def_exp_type                  VARCHAR2,
                   p_flow_schedule                      VARCHAR2,
                   p_si_asset_yes_no                    NUMBER,
                   p_transfer_si_asset_yes_no           NUMBER,

                   O_err_num                  OUT       NOCOPY  NUMBER,
                   O_err_code                 OUT       NOCOPY  VARCHAR2,
                   O_err_msg                  OUT       NOCOPY  VARCHAR2
                  )

  IS

    l_err_num                NUMBER := 0;
    l_err_code               VARCHAR2(240) ;
    l_err_msg                VARCHAR2(240) ;
    l_stmt_num               NUMBER;
    l_hook_used              NUMBER;
    l_cse_hook_used          NUMBER;
    l_cse_err_code           NUMBER := 0;
    l_cse_err_msg            NUMBER := 0;
    l_dr_code_combination_id NUMBER;
    l_cr_code_combination_id NUMBER;
    l_sql_stmt               VARCHAR2(8000);
    l_cse_installed          BOOLEAN;
    l_status                 VARCHAR2(1);
    l_industry               VARCHAR2(1);
    l_schema                 VARCHAR2(30);
    l_nl_trackable           VARCHAR2(1);
    l_asset_creation_code    VARCHAR2(30);

    l_raw_cost_rate          NUMBER := 0;
    l_raw_cost               NUMBER := 0;
    l_burdened_cost_rate     NUMBER := 0;
    l_burdened_cost          NUMBER := 0;
    l_systemlinkage          VARCHAR2(30);

    l_uom_code               VARCHAR2(30) ;
    l_cc_rate                NUMBER;
    l_txn_value              NUMBER;
    l_inv_cr_sub_ledger_id   NUMBER;
    l_inv_dr_sub_ledger_id   NUMBER;

    CST_FAILED_GET_ACCOUNT   EXCEPTION;
    CST_FAILED_HOOK_ACCT     EXCEPTION;
    CST_FAILED_CST_CC_HOOK   EXCEPTION;
    CST_FAILED_CSE_CALL      EXCEPTION;
    CST_NL_NOT_INSTALLED     EXCEPTION;

    l_debug                  VARCHAR2(80);
    l_op_unit         NUMBER;
    l_cross_bg_profile	     VARCHAR2(1);  /* Added for bug 8398299 to pass business group name        */
    l_business_group_name    VARCHAR2(240);/* when the Cross Business Group profile has been activated */

  BEGIN

    l_stmt_num := 1;
    l_hook_used := 0;
    l_cse_hook_used := 0;
    l_cross_bg_profile := pa_utils.IsCrossBGProfile_WNPS; /*Added or bug 8398299, using wrapping function to get profile value*/
    l_business_group_name := NULL;

    l_debug := FND_PROFILE.VALUE('MRP_DEBUG');
    if (l_debug = 'Y') then
        FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Reached#:pm_insert_pti_pvt');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Transaction_id :'||to_char(p_transaction_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: HR:Cross Business Profile = '||l_cross_bg_profile);
    end if;

      l_stmt_num := 10;

      pm_get_mta_accts(
                        p_transaction_id         => p_transaction_id,
                        p_cost_element_id        => p_cost_element_id,
                        p_resource_id            => p_resource_id,
                        p_source_flag            => p_source_flag,
                        p_variance_flag          => p_variance_flag,
                        O_dr_code_combination_id => l_dr_code_combination_id,
                        O_cr_code_combination_id => l_cr_code_combination_id,
                        O_inv_cr_sub_ledger_id   => l_inv_cr_sub_ledger_id,
                        O_inv_dr_sub_ledger_id   => l_inv_dr_sub_ledger_id,
                        O_cc_rate                => l_cc_rate,
                        O_err_num                => l_err_num,
                        O_err_code               => l_err_code,
                        O_err_msg                => l_err_msg);

       IF (l_err_num <> 0) THEN

         RAISE CST_FAILED_GET_ACCOUNT;

       END IF;


       l_stmt_num := 20;

       IF (NVL(l_dr_code_combination_id,-9) < 0) OR
                                (NVL(l_cr_code_combination_id,-9) < 0)
       THEN

         RAISE CST_FAILED_HOOK_ACCT;

       END IF;



   l_stmt_num := 15;

/* changes to support the PJM Blue Print organization stuff */

   If (p_transaction_source = 'PJM_CSTBP_INV_ACCOUNTS')
       OR (p_transaction_source = 'PJM_CSTBP_INV_NO_ACCOUNTS') then

       /* Blue print sources so pass everything as row cost */

         l_raw_cost_rate := p_burdened_cost_rate;
         l_raw_cost := p_burdened_cost;
         l_burdened_cost_rate := NULL;
         l_burdened_cost := NULL;

   Else /* non BP org */

         l_raw_cost_rate := p_raw_cost_rate;
         l_raw_cost := p_raw_cost;
         l_burdened_cost_rate := p_burdened_cost_rate;
         l_burdened_cost := p_burdened_cost;

   End If;


   l_stmt_num := 17;

      /* check if the transaction source is "Inventory with no accounts".If it  is, then do not send any accounts to PA.They will use auto accounting */

     If p_transaction_source = 'PJM_CSTBP_INV_NO_ACCOUNTS' then

       l_dr_code_combination_id := NULL;
       l_cr_code_combination_id := NULL;

       l_inv_cr_sub_ledger_id := NULL;
       l_inv_dr_sub_ledger_id := NULL;

     end if;

  -------------------------------------------------------------------------
    -- Network Logistics Support
    -------------------------------------------------------------------------

/* Added Block - Network Logistics Changes */

    -------------------------------------------------------------------------
    -- Check Installation Status of Network Logistics (CSE)
    -------------------------------------------------------------------------

    l_stmt_num := 30;

     /* Bug 3742735. Pass the org_id of the organization on the txn always.This will enable cross project charging to also work. */

    select to_number(org_information3)
      into l_op_unit
      from hr_organization_information hoi,
           mtl_material_transactions mmt
      where hoi.organization_id = mmt.organization_id
      and mmt.transaction_id = to_number(p_orig_transaction_reference)
      and org_information_context ='Accounting Information';

    l_cse_installed := FND_INSTALLATION.GET_APP_INFO ( 'CSE',
                                                    l_status,
                                                    l_industry,
                                                    l_schema);

/* Check if item is NL trackable  */
       SELECT   nvl(comms_nl_trackable_flag, 'N'), asset_creation_code
       INTO     l_nl_trackable, l_asset_creation_code
       FROM     mtl_system_items
       WHERE    inventory_item_id = p_inventory_item_id
       AND      organization_id =  p_organization_id;

/* Bug 2907681 The code that checks for the item to be NL trackable and the NL module to be installed has been removed as it is not true always.We should not error out if the item is NL trackable but the NL module is not installed */


    IF (l_nl_trackable = 'Y' and l_status = 'I') THEN

      l_stmt_num := 35;
      l_cse_hook_used := 0;

      CSE_COST_COLLECTOR.eib_cost_collector_stub (
            p_transaction_id             =>  p_transaction_id,
            p_organization_id            =>  p_organization_id,
            p_transaction_action_id      =>  p_transaction_action_id,
            p_transaction_source_type_id =>  p_transaction_source_type_id,
            p_type_class                 =>  p_type_class,
            p_project_id                 =>  p_project_id,
            p_task_id                    =>  p_task_id,
            p_transaction_date           =>  p_transaction_date,
            p_primary_quantity           =>  p_primary_quantity,
            p_cost_group_id              =>  p_cost_group_id,
            p_transfer_cost_group_id     =>  p_transfer_cost_group_id,
            p_inventory_item_id          =>  p_inventory_item_id,
            p_transaction_source_id      =>  p_transaction_source_id,
            p_to_project_id              =>  p_to_project_id,
            p_to_task_id                 =>  p_to_task_id,
            p_source_project_id          =>  p_source_project_id,
            p_source_task_id             =>  p_source_task_id,
            p_transfer_transaction_id    =>  p_transfer_transaction_id,
            p_primary_cost_method        =>  p_primary_cost_method,
            p_acct_period_id             =>  p_acct_period_id,
            p_exp_org_id                 =>  p_exp_org_id,
            p_distribution_account_id    =>  p_distribution_account_id,
            p_proj_job_ind               =>  p_proj_job_ind,
            p_first_matl_se_exp_type     =>  p_first_matl_se_exp_type,
            p_inv_txn_source_literal     =>  p_inv_txn_source_literal,
            p_cap_txn_source_literal     =>  p_cap_txn_source_literal,
            p_inv_syslink_literal        =>  p_inv_syslink_literal,
            p_bur_syslink_literal        =>  p_bur_syslink_literal,
            p_wip_syslink_literal        =>  p_wip_syslink_literal,
            p_user_def_exp_type          =>  p_user_def_exp_type,
            p_transfer_organization_id   =>  p_transfer_organization_id,
            p_flow_schedule              =>  p_flow_schedule,
            p_si_asset_yes_no            =>  p_si_asset_yes_no,
            p_transfer_si_asset_yes_no   =>  p_transfer_si_asset_yes_no,
            p_denom_currency_code        =>  p_denom_currency_code,
            p_exp_type                   =>  p_expenditure_type,
            p_dr_code_combination_id     =>  l_dr_code_combination_id,
            p_cr_code_combination_id     =>  l_cr_code_combination_id,
            p_raw_cost                   =>  l_raw_cost,
            p_burden_cost                =>  l_burdened_cost,
            p_cr_sub_ledger_id           =>  l_inv_cr_sub_ledger_id,
            p_dr_sub_ledger_id           =>  l_inv_dr_sub_ledger_id,
            p_cost_element_id            =>  p_cost_element_id,
            O_hook_used                  =>  l_cse_hook_used,
            O_err_num                    =>  l_err_num,
            O_err_code                   =>  l_cse_err_code,
            O_err_msg                    =>  l_cse_err_msg);

      l_stmt_num := 40;

      FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: CSE hook usage flag :'||to_char(l_cse_hook_used));
      IF (l_err_num <> 0) THEN

        RAISE CST_FAILED_CSE_CALL;

      END IF;

    END IF;

/* End: Added Block - Network Logistics Changes */
    l_stmt_num := 45;

    l_hook_used := 0;

    CST_COST_COLLECTOR_HOOK.pm_invtxn_hook(
                                 p_transaction_id                ,
                                 p_organization_id                ,
                                 p_transaction_action_id        ,
                                 p_transaction_source_type_id        ,
                                 p_type_class                        ,
                                 p_project_id                        ,
                                 p_task_id                        ,
                                 p_transaction_date                ,
                                 p_primary_quantity                ,
                                 p_cost_group_id                ,
                                 p_transfer_cost_group_id        ,
                                 p_inventory_item_id                ,
                                 p_transaction_source_id        ,
                                 p_to_project_id                ,
                                 p_to_task_id                        ,
                                 p_source_project_id                ,
                                 p_source_task_id                ,
                                 p_transfer_transaction_id        ,
                                 p_primary_cost_method                ,
                                 p_acct_period_id                ,
                                 p_exp_org_id                        ,
                                 p_distribution_account_id        ,
                                 p_proj_job_ind                        ,
                                 p_first_matl_se_exp_type        ,
                                 p_inv_txn_source_literal        ,
                                 p_cap_txn_source_literal        ,
                                 p_inv_syslink_literal                ,
                                 p_bur_syslink_literal                ,
                                 p_wip_syslink_literal                ,
                                 p_user_def_exp_type            ,
                                 p_transfer_organization_id     ,
                                 p_flow_schedule                ,
                                 p_si_asset_yes_no                ,
                                 p_transfer_si_asset_yes_no        ,
                                 p_denom_currency_code          ,
                                 p_expenditure_type             ,
                                 l_dr_code_combination_id       ,
                                    l_cr_code_combination_id       ,
                                 l_raw_cost                     ,
                                 l_burdened_cost,
                                 p_transaction_source           ,
                                 p_batch_name                   ,
                                 p_expenditure_ending_date      ,
                                 p_employee_number              ,
                                 p_organization_name            ,
                                 p_expenditure_item_date        ,
                                 p_project_number               ,
                                 p_task_number                  ,
                                 p_pa_quantity                  ,
                                 p_expenditure_comment          ,
                                 p_orig_transaction_reference   ,
                                 p_raw_cost_rate                ,
                                 p_unmatched_negative_txn_flag  ,
                                 p_gl_date                      ,
                                 l_op_unit                      ,
                                 p_burdened_cost_rate           ,
                                 p_system_linkage               ,
                                 p_transaction_status_code      ,
                                 l_hook_used                    ,
                                 l_err_num                      ,
                                 l_err_code                     ,
                                 l_err_msg);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: INV hook usage flag :'||to_char(l_hook_used));

    IF (l_err_num <> 0) THEN

      RAISE CST_FAILED_CST_CC_HOOK;

    END IF;




/* Added Block - Network Logistics Changes */

    IF(l_hook_used = 1 OR l_cse_hook_used = 1) THEN
      return;
    END IF;

/* End: Added Block - Network Logistics Changes */

    l_stmt_num := 50;

/* bug 3345746 .For Blue print orgs,the system linkage that should be pased in is INV  for burden as the
   transaction sources do not allow burdening in MFG ( allow_burden_flag = 'N') */

    l_systemlinkage := p_system_linkage;

    If (p_transaction_source = 'PJM_CSTBP_INV_ACCOUNTS') OR (p_transaction_source = 'PJM_CSTBP_INV_NO_ACCOUNTS') then

       If l_systemlinkage = p_bur_syslink_literal then
        l_systemlinkage := p_inv_syslink_literal;
       end If;

    End If;

   l_stmt_num := 51;
/*Bug 8398299:  We will pass the business_group_name from hr_all_organization_units_tl from the business group
                id that we will obtain from cst_organization_definitions for that particular organization_id to
                prevent the error: PA_TOO_MANY_ORGN when they have activated the profile HR:Cross Business Group
*/
    IF (l_cross_bg_profile = 'Y') THEN
    	SELECT 	HAOUT.name
	INTO   	l_business_group_name
        FROM   	hr_all_organization_units_tl HAOUT
        WHERE 	HAOUT.organization_id =
                                        (SELECT COD.business_group_id
                                         FROM	cst_organization_definitions COD
				     	 WHERE  COD.organization_id = p_organization_id)
   	AND 	haout.language = USERENV('LANG');
     END IF;

   l_stmt_num := 52;


    IF (l_hook_used = 0 ) THEN

      if (l_debug = 'Y') then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'DEBUG: Inserting transaction into PTI ');
      end if;


/* The following insert statement into pa_transaction_interface will be changed to insert into pa_transaction_interface_all */


/* The following insert statement into pa_transaction_interface will be changed to insert into pa_transaction_interface_all */

/* Modified the insert to insert the Inventory_item_id and basic UOM code bug 3298023 */

   /*Get the primary UOM code of the item from mtl_system_items */

      select primary_uom_code into l_uom_code
      from mtl_system_items msi
      where msi.inventory_item_id = p_inventory_item_id
      AND msi.organization_id = p_organization_id;

      /*Bug 7622583*/
      /*BUG 9412469, moved this logic to pm_get_mta_accounts
      select mta.currency_conversion_rate, mta.transaction_value
        into l_cc_rate, l_txn_value
        from mtl_transaction_accounts mta
       where mta.transaction_id = to_number(p_orig_transaction_reference)
         and rownum<2;

       if l_txn_value is NULL then
        l_cc_rate := 1;
       end if; */

        If l_debug = 'Y' then
         fnd_file.put_line(fnd_file.log,'UOM code for the INV txn : ' || l_uom_code);
        end If;



      INSERT INTO pa_transaction_interface_all
                  (  transaction_source,
                      batch_name,
                      expenditure_ending_date,
                      employee_number,
                      organization_name,
                      expenditure_item_date,
                      project_number,
                      task_number,
                      expenditure_type,
                      quantity,
                      denom_raw_cost,
                   acct_raw_cost,
                      expenditure_comment,
                      orig_transaction_reference,
                      raw_cost_rate,
                      unmatched_negative_txn_flag,
                      dr_code_combination_id,
                      cr_code_combination_id,
                      cdl_system_reference1,
                      cdl_system_reference2,
                      cdl_system_reference3,
                      gl_date,
                   org_id,
                   denom_burdened_cost,
                   acct_burdened_cost,
                   burdened_cost_rate,
                   system_linkage,
                   transaction_status_code,
                   denom_currency_code,
                   Inventory_item_id,
                   unit_of_measure,
                   cdl_system_reference4,    --Credit INV Sub ledger ID
                   cdl_system_reference5,     --Debit INV Subledger ID
                   person_business_group_name
                  )
      VALUES
                  (
                   p_transaction_source,
                      p_batch_name,
                      p_expenditure_ending_date,
                      p_employee_number,
                      p_organization_name,
                      p_expenditure_item_date,
                      p_project_number,
                      p_task_number,
                   p_expenditure_type,
                      p_pa_quantity,
                      (l_raw_cost/l_cc_rate), /*Bug 7622583*/
                      l_raw_cost,
                      p_expenditure_comment,
                      p_orig_transaction_reference,
                      l_raw_cost_rate,
                      p_unmatched_negative_txn_flag,
                      l_dr_code_combination_id,
                      l_cr_code_combination_id,
                      NULL,
                      NULL,
                      NULL,
                      p_gl_date,
                   l_op_unit,
                   (l_burdened_cost/l_cc_rate), /*Bug 7622583*/
                   l_burdened_cost,
                   l_burdened_cost_rate,
                   l_systemlinkage,
                   p_transaction_status_code,
                   p_denom_currency_code,
                   p_inventory_item_id,
                   l_uom_code,
                   l_inv_cr_sub_ledger_id,
                   l_inv_dr_sub_ledger_id,
                   l_business_group_name
                  );
    END IF; --l_hook_used

  EXCEPTION

    WHEN CST_FAILED_CSE_CALL THEN

      O_err_num := 20005;
      O_err_code  := SUBSTR('CSTPPCCB.pm_insert_pti_pvt('
                            || to_char(l_stmt_num)
                            || '): '
                            || 'FAILED CSE Package Call. '
                            || l_cse_err_code,1,240);
      O_err_msg := substr(l_err_msg,1,240) ;

    WHEN CST_NL_NOT_INSTALLED THEN
      O_err_num := 20004;
      O_err_code  := SUBSTR('CSTPPCCB.pm_process_txn_mmt('
                            || to_char(l_stmt_num)
                            || '): '
                            || 'NL trackable/depreciable item will not be cost collected if Network Logistics is not installed',1,240);
      O_err_msg := substr(l_err_msg,1,240) ;


    WHEN CST_FAILED_GET_ACCOUNT THEN

      O_err_num := 20001;
      O_err_code  := SUBSTR('CSTPPCCB.pm_insert_pti_pvt('
                            || to_char(l_stmt_num)
                            || '): '
                            || 'FAILED TO GET ACCT. '
                            || l_err_msg,1,240);
      fnd_message.set_name('BOM','CST_FAILED_GET_ACCOUNT');
      l_err_msg := fnd_message.get ;
      O_err_msg := substr(l_err_msg,1,240) ;

     WHEN CST_FAILED_HOOK_ACCT THEN

       O_err_num := 20002;

       fnd_message.set_name('BOM','CST_FAILED_HOOK_ACCT');
       l_err_msg := fnd_message.get ;
       O_err_msg := substr(l_err_msg,1,240) ;

       O_err_code := 'CSTPPCCB.pm_insert_pti_pvt('
                            || to_char(l_stmt_num)
                            || '): ';

      WHEN CST_FAILED_CST_CC_HOOK THEN

        O_err_num := 20003;
        O_err_code := l_err_code;
        O_err_msg := SUBSTR('CSTPPCCB.pm_insert_pti_pvt('
                            ||to_char(l_stmt_num)
                            ||'), '
                            ||'CSTCCHKB.pm_invtxn_hook: '
                            ||'error at CSTCCHKB, line: '
                            ||to_char(l_err_num)
                            ||' CSTCCHKB.err_msg:'
                            ||l_err_msg,1,240);


      WHEN OTHERS THEN

         O_err_num := SQLCODE;
         O_err_code := NULL;
         O_err_msg := SUBSTR('CSTPPCCB.pm_insert_pti_pvt('
                            || to_char(l_stmt_num)
                            || '): '
                            ||SQLERRM,1,240);


  END pm_insert_pti_pvt;

/*----------------------------------------------------------------------------*
| PACKAGE CONSTRUCTOR                                                        |
|                                                                            |
| DESCRIPTION                                                                |
|                                                                            |
| HISTORY                                                                    |
|      07-SEP-96   Bhaskar Dasari                                            |
|                                                                            |
*----------------------------------------------------------------------------*/
  --
  -- Constructor Code
  --
BEGIN
        NULL;
END CST_PRJMFG_COST_COLLECTOR ;

/
