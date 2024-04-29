--------------------------------------------------------
--  DDL for Package Body PA_ADJUSTMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ADJUSTMENTS" AS
/* $Header: PAXTADJB.pls 120.80.12010000.14 2010/07/21 11:27:39 speddi ship $ */

  RESOURCE_BUSY     EXCEPTION;
  PRAGMA EXCEPTION_INIT( RESOURCE_BUSY, -0054 );

  ExpOrganizationTab      PA_PLSQL_DATATYPES.IdTabTyp;
  ExpOrgTab               PA_PLSQL_DATATYPES.IdTabTyp;
  TaskIdTab               PA_PLSQL_DATATYPES.IdTabTyp;
  ExpItemDateTab          PA_PLSQL_DATATYPES.DateTabTyp;
  ExpTypeTab              PA_PLSQL_DATATYPES.Char30TabTyp ;
  IncurredByPersonIdTab   PA_PLSQL_DATATYPES.IdTabTyp;
  TrxSourceTab            PA_PLSQL_DATATYPES.Char30TabTyp ;
  NlrOrganizationIdTab    PA_PLSQL_DATATYPES.IdTabTyp;
  SysLinkageTab           PA_PLSQL_DATATYPES.Char30TabTyp;
  CrossChargeCodeTab      PA_PLSQL_DATATYPES.Char1TabTyp;
  DenomTpCurrCodeTab      PA_PLSQL_DATATYPES.Char15TabTyp ;
  P_DEBUG_MODE BOOLEAN     := pa_cc_utils.g_debug_mode;

/* R12 Changes Start */
  TYPE METHODS IS RECORD ( ORG_ID NUMBER
                         , METHOD VARCHAR2(25));
  TYPE METHODS_TAB IS TABLE OF METHODS INDEX BY BINARY_INTEGER;
  G_AUTOMATIC_OFFSET_METHOD METHODS_TAB;

  G_VENDOR_ID               NUMBER;
  G_ORG_ID                  NUMBER;
  G_SET_OF_BOOKS_ID         NUMBER;
  G_GL_DATE                 DATE;
  G_COA_ID                  NUMBER;
  G_EMP_ID                  NUMBER;
  G_EMP_CCID                NUMBER;
  G_INVOICE_DISTRIBUTION_ID NUMBER;
  G_EXPENSE_TYPE            NUMBER;
  G_EXP_ITEM_ID             NUMBER;
  G_OLD_CCID                NUMBER;
  G_NEW_CCID                NUMBER;
/* R12 Changes End */

/* R12 Changes Start */
  G_PO_HEADER_ID NUMBER;
  G_PO_NUM VARCHAR2(20);
  G_PO_DATE DATE;
  G_PO_LINE_NUM NUMBER;
  G_PO_DIST_NUM NUMBER;
  G_PO_DIST_ID NUMBER;

  G_INV_TYPE_CODE VARCHAR2(30);
  G_INV_TYPE VARCHAR2(80);
  G_INV_LINE_TYPE_CODE VARCHAR2(30);
  G_INV_LINE_TYPE VARCHAR2(80);
  G_INV_DIST_TYPE_CODE VARCHAR2(30);
  G_INV_DIST_TYPE VARCHAR2(80);
  G_PAYMENT_TYPE_CODE VARCHAR2(30); /* 4914048 */
  G_PAYMENT_TYPE VARCHAR2(80); /* 4914048 */
  G_PO_DIST_TYPE_CODE VARCHAR2(30);
  G_PO_DIST_TYPE VARCHAR2(80);
  G_RCV_TXN_TYPE_CODE VARCHAR2(30);
  G_RCV_TXN_TYPE VARCHAR2(80);

  G_RCV_TXN_ID NUMBER;
  G_RCV_NUM VARCHAR2(30);
  G_RCV_DATE DATE;

  G_INV_ID NUMBER;
  G_INV_NUM VARCHAR2(50);
  G_INV_DATE DATE;
/* R12 Changes End */

/* Bug 5235354 - Start */
  TYPE LEDGER_CNT IS RECORD ( ORG_ID NUMBER
                            , CNT NUMBER);
  TYPE LEDGER_CNT_TAB IS TABLE OF LEDGER_CNT INDEX BY BINARY_INTEGER;
  G_LEDGER_CNT LEDGER_CNT_TAB;
/* Bug 5235354 - End */


/*Bug# 5874347 - Start*/
Function getprojburdenflag(p_project_id in number) return varchar2
IS
X_proj_bcost_flag VARCHAR2(10) DEFAULT 'N';
BEGIN
       SELECT  nvl(burden_cost_flag,'N')
        INTO   X_proj_bcost_flag
        FROM   pa_projects_all proj,
               pa_project_types_all ptype
        WHERE  proj.project_type = ptype.project_type
          AND  nvl(proj.org_id, -99) = nvl(ptype.org_id,-99)
          AND  project_id = p_Project_id ;
return(X_proj_bcost_flag);
Exception
WHEN NO_DATA_FOUND THEN
X_proj_bcost_flag :='N';
return(X_proj_bcost_flag);
END getprojburdenflag;
/*Bug# 5874347 - End */

-- ========================================================================
-- PROCEDURE CheckStatus
-- ========================================================================

  PROCEDURE CheckStatus( status_indicator IN OUT NOCOPY NUMBER )
  IS
  BEGIN

    IF ( status_indicator <> 0 ) THEN
      RAISE SUBROUTINE_ERROR;
    ELSIF ( status_indicator = 0 ) THEN
      status_indicator := NULL;
    END IF;

  END CheckStatus;


--=========================================================================
-- PROCEDURE print_message
--========================================================================
PROCEDURE print_message(p_msg_token1  IN varchar2) IS
			--,p_msg_token2  IN varchar2 ) IS


BEGIN
	If p_msg_token1 is not null --or p_msg_token2 is not null
	   then
		--dbms_output.put_line('LOG: '||p_msg_token1);
		--r_debug.r_msg(p_msg =>'LOG: '||p_msg_token1);
		   pa_cc_utils.log_message('get_denom_curr_code: ' || substr(p_msg_token1,1,250), 0 );
                null;
	End If;

	Return;

END print_message;

FUNCTION is_proj_billable(p_task_id   IN  number) return varchar2 IS

	l_billable  varchar2(1) := 'N';

BEGIN

	SELECT 'Y'
        INTO l_billable
	FROM pa_projects_all pp,
	     pa_tasks t,
	     pa_project_types_all  pt	/** Bug fix 2262118  **/
	WHERE t.task_id = p_task_id
	AND   pp.project_id = t.project_id
	AND   pp.project_type = pt.project_type
    AND   pt.PROJECT_TYPE_CLASS_CODE in ('CAPITAL','CONTRACT')
    -- start 12i MOAC changes
	-- AND   nvl(pp.org_id ,-99) = nvl(pt.org_id ,-99) ;
    AND   pp.org_id = pt.org_id ;

        return l_billable;

EXCEPTION

       WHEN NO_DATA_FOUND then
		return 'N';

       WHEN OTHERS THEN
		return 'N';

END is_proj_billable ;

-- ========================================================================
-- FUNCTION VerifyOrigItem
-- ========================================================================

  FUNCTION VerifyOrigItem ( X_person_id                IN NUMBER
                          , X_org_id                   IN NUMBER
                          , X_item_date                IN DATE
                          , X_task_id                  IN NUMBER
                          , X_exp_type                 IN VARCHAR2
                          , X_system_linkage_function  IN VARCHAR2
                          , X_nl_org_id                IN NUMBER
                          , X_nl_resource              IN VARCHAR2
                          , X_quantity                 IN NUMBER
                          , X_denom_raw_cost           IN NUMBER
		                    , X_trx_source               IN VARCHAR2
			                 , X_denom_currency_code      IN VARCHAR2
			                 , X_acct_raw_cost            IN NUMBER
                          -- SST Change
                          , X_reversed_orig_txn_reference  IN OUT NOCOPY VARCHAR2
                          ) RETURN  NUMBER
  IS
    orig_item_id       NUMBER DEFAULT NULL;
  CURSOR cur_origtxn IS
    SELECT
            min(i.expenditure_item_id),
            -- SST Change: If X_reversed_orig_txn_reference is not NULL
            -- then we already have the reversing item's
            -- orig_transaction_reference, otherwise get the
            -- reversing item's orig_transaction_reference
            decode(X_reversed_orig_txn_reference,NULL,
                   i.orig_transaction_reference,
                   X_reversed_orig_txn_reference) orig_txn_reference
      FROM
            pa_transaction_sources ts
    ,       pa_expenditure_items i
    ,       pa_expenditures e
     WHERE
            i.expenditure_item_date = X_item_date
       AND  i.expenditure_type ||''     = X_exp_type
       AND  i.system_linkage_function ||'' = X_system_linkage_function
       AND  i.task_id               = X_task_id
       AND  ( i.quantity * -1 ) = X_quantity
       AND  i.transaction_source = ts.transaction_source
       AND  (   (     ts.costed_flag = 'Y'
                  AND ( i.denom_raw_cost * -1) = pa_currency.round_trans_currency_amt(X_denom_raw_cost,X_denom_currency_code))
             OR ( ts.costed_flag = 'N' ) )
        AND  (   (     ts.gl_accounted_flag = 'Y'
                  AND ( i.acct_raw_cost * -1) =
                      pa_currency.round_currency_amt(X_acct_raw_cost))
             OR ( ts.gl_accounted_flag = 'N' ) )
       AND  i.expenditure_id = e.expenditure_id
       AND  ( ( e.incurred_by_person_id = X_person_id )
                               OR
            ( ( e.incurred_by_person_id IS NULL ) AND
              ( e.incurred_by_organization_id = X_org_id ) ) )
       AND  nvl( i.organization_id, -1 ) = nvl( X_nl_org_id, -1 )
       AND  nvl( i.non_labor_resource, 'DUMMY' ) =
                             nvl( X_nl_resource, 'DUMMY' )
       AND  i.transaction_source ||'' = X_trx_source
       AND  nvl( i.net_zero_adjustment_flag, 'N' ) = 'N'
		 AND  pa_adjustments.ei_adjusted_in_cache(i.expenditure_item_id) = 'N'
       -- SSt changes: If we have the orig_txn_ref of the reversing item,
       -- then the item we find must have the matching orig_txn_reference.
       -- If we don't have the orig_txn_reference of the reversing item,
       -- then the item we find does not need to satisfy the following
       -- condition
       AND (i.orig_transaction_reference = X_reversed_orig_txn_reference OR
            X_reversed_orig_txn_reference IS NULL)
       GROUP BY decode(X_reversed_orig_txn_reference,NULL,
                   i.orig_transaction_reference,
                   X_reversed_orig_txn_reference);

    BEGIN

    OPEN cur_origtxn;
    FETCH cur_origtxn INTO orig_item_id,X_reversed_orig_txn_reference;
    CLOSE cur_origtxn;

    RETURN ( orig_item_id );

  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
      RETURN ( NULL );

  END VerifyOrigItem;



-- ========================================================================
-- PROCEDURE CommentChange
-- ========================================================================

  PROCEDURE   CommentChange( X_exp_item_id  IN NUMBER
                           , X_new_comment  IN VARCHAR2
                           , X_user         IN NUMBER
                           , X_login        IN NUMBER
                           , X_status       OUT NOCOPY NUMBER )
  IS
    dummy        NUMBER;
    temp_status  NUMBER DEFAULT NULL;

    -- ------------------------------------------------------------------
    -- PROCEDURE CommentChange.DelComment
    -- ------------------------------------------------------------------

    PROCEDURE  DelComment( X_exp_item_id  IN NUMBER
                         , X_status       OUT NOCOPY NUMBER )
    IS
    BEGIN
      DELETE FROM pa_expenditure_comments
            WHERE
                   expenditure_item_id = X_exp_item_id;

      X_status := 0;

    EXCEPTION
      WHEN  OTHERS  THEN
        X_status := SQLCODE;
        RAISE;

    END  DelComment;


    -- ------------------------------------------------------------------
    -- PROCEDURE CommentChange.UpdComment
    -- ------------------------------------------------------------------

    PROCEDURE  UpdComment( X_exp_item_id  IN NUMBER
                         , X_new_comment  IN VARCHAR2
                         , X_user         IN NUMBER
                         , X_login        IN NUMBER
                         , X_status       OUT NOCOPY NUMBER )
    IS
    BEGIN

      UPDATE pa_expenditure_comments
         SET
             expenditure_comment = X_new_comment
      ,      last_update_date    = sysdate
      ,      last_updated_by     = X_user
      ,      last_update_login   = X_login
       WHERE
             expenditure_item_id = X_exp_item_id;

      X_status := 0;

    EXCEPTION
      WHEN  OTHERS  THEN
        X_status := SQLCODE;
        RAISE;

    END  UpdComment;

  BEGIN

    SELECT count(*)
      INTO dummy
      FROM sys.dual
     WHERE EXISTS
             ( SELECT NULL
                 FROM pa_expenditure_comments
                WHERE expenditure_item_id = X_exp_item_id);

    IF( dummy = 0 ) THEN

      pa_transactions.InsItemComment( X_exp_item_id
                                    , X_new_comment
                                    , X_user
                                    , X_login
                                    , temp_status );
      CheckStatus( temp_status );

    ELSIF(    dummy <> 0
          AND X_new_comment IS NOT NULL ) THEN

      UpdComment( X_exp_item_id
                , X_new_comment
                , X_user
                , X_login
                , temp_status );
      CheckStatus( temp_status );

    ELSIF(    dummy <> 0
          AND X_new_comment IS NULL ) THEN

       DelComment( X_exp_item_id
                 , temp_status );

    END IF;

    X_status := 0;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;

  END  CommentChange;



-- ========================================================================
-- PROCEDURE InsAuditRec
-- ========================================================================


  PROCEDURE  InsAuditRec( X_exp_item_id       IN NUMBER
                        , X_adj_activity      IN VARCHAR2
                        , X_module            IN VARCHAR2
                        , X_user              IN NUMBER
                        , X_login             IN NUMBER
                        , X_status            OUT NOCOPY NUMBER
                        , X_who_req_id        IN NUMBER
                        , X_who_prog_id       IN NUMBER
                        , X_who_prog_app_id   IN NUMBER
                        , X_who_prog_upd_date IN DATE
			, X_rejection_code    IN VARCHAR2 )
  IS
  BEGIN
    INSERT INTO pa_expend_item_adj_activities (
          expenditure_item_id
       ,  last_update_date
       ,  last_updated_by
       ,  creation_date
       ,  created_by
       ,  last_update_login
       ,  activity_date
       ,  exception_activity_code
       ,  module_code
       ,  request_id
       ,  program_application_id
       ,  program_id
       ,  program_update_date
       ,  rejection_code)
    VALUES (
          X_exp_item_id              -- expenditure_item_id
       ,  sysdate                    -- last_update_date
       ,  X_user                     -- last_updated_by
       ,  sysdate                    -- creation_date
       ,  X_user                     -- created_by
       ,  X_login                    -- last_update_login
       ,  sysdate                    -- activity_date
       ,  X_adj_activity             -- exception_activity_code
       ,  X_module                   -- module_code
       ,  X_who_req_id               -- request_id
       ,  X_who_prog_app_id          -- program_application_id
       ,  X_who_prog_id              -- program_id
       ,  X_who_prog_upd_date        -- program_update_date
       ,  X_rejection_code );        -- rejection_code

    X_status := 0;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;

  END  InsAuditRec;


-- ========================================================================
-- PROCEDURE  SetNetZero
-- ========================================================================

  PROCEDURE  SetNetZero( X_exp_item_id   IN NUMBER
                       , X_user          IN NUMBER
                       , X_login         IN NUMBER
                       , X_status        OUT NOCOPY NUMBER )
  IS
    BEGIN
      UPDATE pa_expenditure_items_all ei
         SET
              ei.net_zero_adjustment_flag = 'Y'
      ,       ei.last_update_date         = sysdate
      ,       ei.last_updated_by          = X_user
      ,       ei.last_update_login        = X_login
       WHERE
              ei.expenditure_item_id = X_exp_item_id;

      X_status := 0;

    EXCEPTION
      WHEN  OTHERS  THEN
        X_status := SQLCODE;
        RAISE;

  END  SetNetZero;


-- ========================================================================
-- PROCEDURE BackoutItem
-- ========================================================================

  PROCEDURE  BackoutItem( X_exp_item_id      IN NUMBER
                        , X_expenditure_id   IN NUMBER
                        , X_adj_activity     IN VARCHAR2
                        , X_module           IN VARCHAR2
                        , X_user             IN NUMBER
                        , X_login            IN NUMBER
                        , X_status           OUT NOCOPY NUMBER )
  IS
    X_backout_id     NUMBER(15);
    temp_status      NUMBER DEFAULT NULL;
    item_comment     VARCHAR2(240);

  BEGIN

    X_backout_id := pa_utils.GetNextEiId;

    INSERT INTO pa_expenditure_items_all(
         expenditure_item_id
       , task_id
       , expenditure_type
       , system_linkage_function
       , expenditure_item_date
       , expenditure_id
       , override_to_organization_id
       , last_update_date
       , last_updated_by
       , creation_date
       , created_by
       , last_update_login
       , quantity
       , revenue_distributed_flag
       , bill_hold_flag
       , billable_flag
       , bill_rate_multiplier
       , cost_distributed_flag
       , raw_cost
       , raw_cost_rate
       , burden_cost
       , burden_cost_rate
       , cost_ind_compiled_set_id
       , non_labor_resource
       , organization_id
       , adjusted_expenditure_item_id
       , net_zero_adjustment_flag
       , attribute_category
       , attribute1
       , attribute2
       , attribute3
       , attribute4
       , attribute5
       , attribute6
       , attribute7
       , attribute8
       , attribute9
       , attribute10
       , transferred_from_exp_item_id
       , transaction_source
       , orig_transaction_reference
       , source_expenditure_item_id
       , job_id
       , org_id
       , labor_cost_multiplier_name
       , receipt_currency_amount
       , receipt_currency_code
       , receipt_exchange_rate
       , denom_currency_code
       , denom_raw_cost
       , denom_burdened_cost
       , acct_currency_code
       , acct_rate_date
       , acct_rate_type
       , acct_exchange_rate
       , acct_raw_cost
       , acct_burdened_cost
       , acct_exchange_rounding_limit
       , project_currency_code
       , project_rate_date
       , project_rate_type
       , project_exchange_rate
       , cc_cross_charge_code
       , cc_prvdr_organization_id
       , cc_recvr_organization_id
       , cc_rejection_code
       , denom_tp_currency_code
       , denom_transfer_price
       , acct_tp_rate_type
       , acct_tp_rate_date
       , acct_tp_exchange_rate
       , acct_transfer_price
       , projacct_transfer_price
       , cc_markup_base_code
       , tp_base_amount
       , cc_cross_charge_type
       , recvr_org_id
       , cc_bl_distributed_code
       , cc_ic_processed_code
       , tp_ind_compiled_set_id
       , tp_bill_rate
       , tp_bill_markup_percentage
       , tp_schedule_line_percentage
       , tp_rule_percentage
       , cost_job_id
       , tp_job_id
       , prov_proj_bill_job_id
       , assignment_id
       , work_type_id
       , projfunc_currency_code
       , projfunc_cost_rate_date
       , projfunc_cost_rate_type
       , projfunc_cost_exchange_rate
       , project_raw_cost
       , project_burdened_cost
       , project_id
       , project_tp_rate_date
       , project_tp_rate_type
       , project_tp_exchange_rate
       , project_transfer_price
       , tp_amt_type_code
/* inserting cost_burden_distributed_flag for 2661921 */
       , cost_burden_distributed_flag
       , capital_event_id
       , wip_resource_id
       , inventory_item_id
       , unit_of_measure
/* R12 Changes - Start */
       , document_header_id
       , document_distribution_id
       , document_line_number
       , document_payment_id
       , vendor_id
       , document_type
       , document_distribution_type )
/* R12 Changes - End */
    SELECT
          X_backout_id                     -- expenditure_item_id
       ,  ei.task_id                       -- task_id
       ,  ei.expenditure_type              -- expenditure_type
       ,  ei.system_linkage_function       -- system_linkage_function
       ,  ei.expenditure_item_date         -- expenditure_item_date
       ,  nvl( X_expenditure_id,
                ei.expenditure_id )        -- expenditure_id
       ,  ei.override_to_organization_id   -- override exp organization
       ,  sysdate                          -- last_update_date
       ,  X_user                           -- last_updated_by
       ,  sysdate                          -- creation_date
       ,  X_user                           -- created_by
       ,  X_login                          -- last_update_login
       ,  (0 - ei.quantity)                -- quantity
       ,  'N'                              -- revenue_distributed_flag
       ,  ei.bill_hold_flag                -- bill_hold_flag
       ,  ei.billable_flag                 -- billable_flag
       ,  ei.bill_rate_multiplier          -- bill_rate_multiplier
       ,  'N'                              -- cost_distributed_flag
       ,  (0 - ei.raw_cost)                -- raw_cost
       ,  ei.raw_cost_rate                 -- raw_cost_rate
       ,  (0 - ei.burden_cost)             -- raw_cost
       ,  ei.burden_cost_rate              -- raw_cost_rate
       ,  ei.cost_ind_compiled_set_id      -- cost_ind_compiled_set_id
       ,  ei.non_labor_resource            -- non_labor_resource
       ,  ei.organization_id               -- organization_id
       ,  ei.expenditure_item_id           -- adjusted_expenditure_item_id
       ,  'Y'                              -- net_zero_adjustment_flag
       ,  ei.attribute_category            -- attribute_category
       ,  ei.attribute1                    -- attribute1
       ,  ei.attribute2                    -- attribute2
       ,  ei.attribute3                    -- attribute3
       ,  ei.attribute4                    -- attribute4
       ,  ei.attribute5                    -- attribute5
       ,  ei.attribute6                    -- attribute6
       ,  ei.attribute7                    -- attribute7
       ,  ei.attribute8                    -- attribute8
       ,  ei.attribute9                    -- attribute9
       ,  ei.attribute10                   -- attribute10
       ,  ei.transferred_from_exp_item_id  -- tfr from exp item id
       ,  ei.transaction_source            -- transaction_source
       ,  decode(ei.transaction_source,'PTE TIME',NULL,
          decode(ei.transaction_source,'PTE EXPENSE',NULL,
	  decode(ei.transaction_source,'ORACLE TIME AND LABOR',NULL,
	  decode(ei.transaction_source,'Oracle Self Service Time',NULL,
                   ei.orig_transaction_reference)))) -- orig_transaction_reference
       ,  ei.source_expenditure_item_id    -- source_expenditure_item_id
       ,  ei.job_id                        -- job_id
       ,  ei.org_id                        -- org_id
       ,  ei.labor_cost_multiplier_name    -- labor_cost_multiplier_name
       , (0 - ei.receipt_currency_amount)  -- receipt_currency_amount
       ,  ei.receipt_currency_code         -- receipt_currency_code
       ,  ei.receipt_exchange_rate         -- receipt_exchange_rate
       ,  ei.denom_currency_code           -- denom_currency_code
       ,  (0 - ei.denom_raw_cost)          -- denom_raw_cost
       ,  (0 - ei.denom_burdened_cost)     -- denom_burdened_cost
       ,  ei.acct_currency_code            -- acct_currency_code
       ,  ei.acct_rate_date                -- acct_rate_date
       ,  ei.acct_rate_type                -- acct_rate_type
       ,  ei.acct_exchange_rate            -- acct_exchange_rate
       ,  (0 - ei.acct_raw_cost)           -- acct_raw_cost
       ,  (0 - ei.acct_burdened_cost)      -- acct_burdened_cost
       ,  ei.acct_exchange_rounding_limit  -- acct_exchange_rounding_limit
       ,  ei.project_currency_code         -- project_currency_code
       ,  ei.project_rate_date             -- project_rate_date
       ,  ei.project_rate_type             -- project_rate_type
       ,  ei.project_exchange_rate         -- project_exchange_rate
       ,  ei.cc_cross_charge_code          -- cc_cross_charge_code
       ,  ei.cc_prvdr_organization_id      -- cc_prvdr_organization_id
       ,  ei.cc_recvr_organization_id      -- cc_recvr_organization_id
       ,  ei.cc_rejection_code             -- cc_rejection_code
       ,  ei.denom_tp_currency_code        -- denom_tp_currency_code
       ,  (0 - ei.denom_transfer_price)    -- denom_transfer_price
       ,  ei.acct_tp_rate_type             -- acct_tp_rate_type
       ,  ei.acct_tp_rate_date             -- acct_tp_rate_date
       ,  ei.acct_tp_exchange_rate         -- acct_tp_exchange_rate
       ,  (0 - ei.acct_transfer_price)     -- acct_transfer_price
       ,  (0 - ei.projacct_transfer_price) -- projacct_transfer_price
       ,  ei.cc_markup_base_code           -- cc_markup_base_code
       ,  (0 - ei.tp_base_amount)          -- tp_base_amount
       ,  ei.cc_cross_charge_type          -- cc_cross_charge_type
       ,  ei.recvr_org_id                  -- recvr_org_id
       ,  ei.cc_bl_distributed_code        -- cc_bl_distributed_code
       ,  ei.cc_ic_processed_code          -- cc_ic_processed_code
       ,  ei.tp_ind_compiled_set_id        -- tp_ind_compiled_set_id
       ,  ei.tp_bill_rate                  -- tp_bill_rate
       ,  ei.tp_bill_markup_percentage     -- tp_bill_markup_percentage
       ,  ei.tp_schedule_line_percentage   -- tp_schedule_line_percentage
       ,  ei.tp_rule_percentage            -- tp_rule_percentage
       ,  ei.cost_job_id                   -- cost_job_id
       ,  ei.tp_job_id                     -- tp_job_id
       ,  ei.prov_proj_bill_job_id         -- prov_proj_bill_job_id
       ,  ei.assignment_id
       ,  ei.work_type_id
       ,  ei.projfunc_currency_code
       ,  ei.projfunc_cost_rate_date
       ,  ei.projfunc_cost_rate_type
       ,  ei.projfunc_cost_exchange_rate
       ,  (0 - ei.project_raw_cost)         -- project raw cost
       ,  (0 - ei.project_burdened_cost)    -- project burended cost
       ,  ei.project_id
       ,  ei.project_tp_rate_date
       ,  ei.project_tp_rate_type
       ,  ei.project_tp_exchange_rate
       ,  (0 - ei.project_transfer_price)
       ,  ei.tp_amt_type_code
/* inserting cost_burden_distributed_flag for 2661921 */
       ,  decode(ei.cost_ind_compiled_set_id,null,'X','N')
       ,  capital_event_id
       , wip_resource_id
       , inventory_item_id
       , unit_of_measure
/* R12 Changes - Start */
       ,  ei.document_header_id
       ,  ei.document_distribution_id
       ,  ei.document_line_number
       ,  ei.document_payment_id
       ,  ei.vendor_id ei_vendor_id
       ,  ei.document_type
       ,  ei.document_distribution_type
/* R12 Changes - End */
      FROM
            pa_expenditure_items_all ei
     WHERE
            ei.expenditure_item_id = X_exp_item_id;

 /* Fix for Bug 3684711 */
 /* Adding grants integrations to support entry of automatically reversing batches. */
 IF ( pa_gms_api.vert_install  and x_adj_activity = 'PERIOD-END ACCRUAL REVERSAL' ) THEN
    /*
    ** The purpose of the following packet is to create award distribution lines for the
    ** reversal expenditure item.
    */
    gms_awards_dist_pkg.copy_exp_adls( p_exp_item_id     => x_exp_item_id,
				       p_backout_item_id => x_backout_id,
				       p_adj_activity    => x_adj_activity,
				       p_module          => x_module,
				       p_user            => x_user,
				       p_login           => x_login,
				       x_status          => temp_status ) ;

    CheckStatus( status_indicator => temp_status );

 END IF ;

/* Fix for bug 2211472 */
/* Adding the comment of original expenditure_item to the reversed expenditure item
and storing it in  pa_expenditure_comments table */
 BEGIN
 SELECT
              ec.expenditure_comment
        INTO
              item_comment
        FROM
              pa_expenditure_comments ec
       WHERE
              ec.expenditure_item_id = X_exp_item_id;
    EXCEPTION
      WHEN  NO_DATA_FOUND  THEN
      NULL;
 END;


 IF ( item_comment IS NOT NULL ) THEN

        pa_transactions.InsItemComment( X_ei_id    => X_backout_id
                                      , X_ei_comment  =>       item_comment
                                      , X_user        =>        X_user
                                      , X_login       =>        X_login
                                      , X_status      =>        temp_status );

        CheckStatus( status_indicator => temp_status );

      END IF;
/* End of Fix for bug 2211472 */
/*
      Project Summarization changes:
      Store the backout_id in the global variable
     */
    Pa_Adjustments.BackOutId := X_backout_id;

    SetNetZero( X_exp_item_id
              , X_user
              , X_login
              , temp_status );
    CheckStatus( temp_status );

    InsAuditRec( X_backout_id
               , X_adj_activity
               , X_module
               , X_user
               , X_login
               , temp_status
	/* R12 Changes Start */
	       , G_REQUEST_ID
               , G_PROGRAM_ID
	       , G_PROG_APPL_ID
	       , sysdate );
 	/* R12 Changes End */
    CheckStatus( temp_status );

    /* -- MRC Elimination
    IF ( G_update_mrc_data = 'Y' ) THEN

       BackOutMrcItem(X_exp_item_id  =>X_exp_item_id,
                   X_backout_id   => X_backout_id,
                   X_adj_activity => X_adj_activity,
                   X_module       => X_module,
                   X_user         => X_user,
                   X_login        => X_login,
                   X_status       => temp_status);
       CheckStatus(temp_status);
    END IF;
    */

  X_status := 0;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;

  END  BackoutItem;

-- ========================================================================
-- PROCEDURE BackoutMrcItem
-- ========================================================================
/*  MRC Elimination
  PROCEDURE  BackoutMrcItem( X_exp_item_id      IN NUMBER
                        , X_backout_id       IN NUMBER
                        , X_adj_activity     IN VARCHAR2
                        , X_module           IN VARCHAR2
                        , X_user             IN NUMBER
                        , X_login            IN NUMBER
                        , X_status           OUT NOCOPY NUMBER )
  IS
    temp_status      NUMBER DEFAULT NULL;

  BEGIN


     INSERT into pa_mc_exp_items_all(
                     SET_OF_BOOKS_ID,
                     EXPENDITURE_ITEM_ID,
                     RAW_COST,
                     RAW_COST_RATE,
                     BURDEN_COST,
                     BURDEN_COST_RATE,
                     NET_ZERO_ADJUSTMENT_FLAG,
                     TRANSFERRED_FROM_EXP_ITEM_ID,
                     PRC_ASSIGNMENT_ID,
                     CURRENCY_CODE,
                     COST_EXCHANGE_RATE,
                     COST_CONVERSION_DATE,
                     COST_RATE_TYPE,
                     TRANSFER_PRICE,
                     TP_EXCHANGE_RATE,
                     TP_CONVERSION_DATE,
                     TP_RATE_TYPE)

        SELECT       SET_OF_BOOKS_ID,
                     X_backout_id,
                     -1*RAW_COST,
                     RAW_COST_RATE,
                     -1*BURDEN_COST,
                     BURDEN_COST_RATE,
                     'Y', -- net_zero_adjustment_flag
                     NULL,-- Transferred_from_expenditure_item_id
                     PRC_ASSIGNMENT_ID,
                     CURRENCY_CODE,
                     COST_EXCHANGE_RATE,
                     COST_CONVERSION_DATE,
                     COST_RATE_TYPE,
                     -1*TRANSFER_PRICE,
                     TP_EXCHANGE_RATE,
                     TP_CONVERSION_DATE,
                     TP_RATE_TYPE
       FROM pa_mc_exp_items_all
      WHERE expenditure_item_id = X_exp_item_id;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;
END BackoutMrcItem;
*/
-- ========================================================================
--  PROCEDURE  ReverseRelatedItems
-- ========================================================================

  PROCEDURE  ReverseRelatedItems( X_source_exp_item_id  IN NUMBER
                                , X_expenditure_id      IN NUMBER
                                , X_module              IN VARCHAR2
                                , X_user                IN NUMBER
                                , X_login               IN NUMBER
                                , X_status              OUT NOCOPY NUMBER )
  IS

    temp_status   NUMBER DEFAULT NULL;

    CURSOR  GetRelatedItems  IS
      SELECT
              ei.expenditure_item_id
        FROM
              pa_expenditure_items_all ei
       WHERE
              ei.source_expenditure_item_id = X_source_exp_item_id
         AND  nvl(ei.net_zero_adjustment_flag, 'N') <> 'Y';

  BEGIN

    FOR  eachRec  IN GetRelatedItems LOOP

      InsAuditRec( eachRec.expenditure_item_id
                 , 'RELATED ITEM ORIGINATING'
                 , X_module
                 , X_user
                 , X_login
                 , temp_status
	/* R12 Changes Start */
	         , G_REQUEST_ID
                 , G_PROGRAM_ID
	         , G_PROG_APPL_ID
	         , sysdate );
 	/* R12 Changes End */
      CheckStatus( temp_status );


      BackoutItem( eachRec.expenditure_item_id
                 , X_expenditure_id
                 , 'RELATED ITEM BACK-OUT'
                 , X_module
                 , X_user
                 , X_login
                 , temp_status );
      CheckStatus( temp_status );

-- ---------------------------------------------------------------------------
-- Fix for bug 429816. What was happening is :
-- ExpItm   AdjEI   TfrEI   SrcEI   Qty    Raw_Cost
-- -------  ------  ------  ------  -----  --------
--  1                                5      100
--  2                         1      0      20
--  3         1                     -5     -100
--  4         2               1*     0     -20
--
--  The problem is that the reversing related item (4) was showing the Original
--  item(1) as its SourceEI and not the reversing item(3) as its SourceEI
-- ---------------------------------------------------------------------------
-- Fix for bug 604023. What was happening is :
-- ExpItm   AdjEI   TfrEI   SrcEI   Qty    Raw_Cost
-- -------  ------  ------  ------  -----  --------
--  1                                5      100
--  2                        1       0      20
--  (After the 1st transfer)
--  3        1                      -5     -100
--  4        2               3       0     -20
--  5                1               5      100
--  6                        5       0      20 (After Distribute Labor)
--  (After the 2nd transfer)
--  7        3                      -5     -100
--  8        4               NULL*   0     -20
--  9                5               5      100
--  This NULL is populated because the sub-query in the following update checks
--  for 'transferred_from _exp_item_id is null'. As a part of the fix removed the
--  condition 'ei1.transferred_from_exp_item_id is null' from the where clause
--  in the sub-query.
--------------------------------------------------------------------------------


      Update pa_expenditure_items_all ei
         set ei.source_expenditure_item_id =
                    (select ei1.expenditure_item_id
                       from pa_expenditure_items_all ei1
                      where ei1.adjusted_expenditure_item_id =
                                                          X_source_exp_item_id)
       where ei.adjusted_expenditure_item_id = eachRec.expenditure_item_id;

-- End Fix--------------------------------------------------------------------

    END LOOP;

    X_status := 0;

    EXCEPTION
      WHEN  OTHERS  THEN
        X_status := SQLCODE;
        RAISE;

  END  ReverseRelatedItems;

-- ========================================================================
-- PROCEDURE RecalcRelatedItems
-- ========================================================================
-- This procedure has been created for Bug # 720199. This will be called by the
-- RecalcRev procedure to ensure that the related item also has the revenue distributed
-- flag set to 'N' when a relcalc revenue adjustment is done
-- Since, the related item adjustment is always done in the background, the number of
-- items adjusted is shown as 1 even though in the background, 2 items are adjusted
-- the source and the related item.As the user sees only 1 item being adjusted, we
-- display the num adjusted successfully as 1

-- bug # 900114. Removed code which sets raw cost and cost rate to null
-- in this procedure

     PROCEDURE  RecalcRelatedItems( X_expenditure_item_id  IN NUMBER
                                  , X_user                 IN NUMBER
                                  , X_login                IN NUMBER
                                  , X_module               IN VARCHAR2
                                  , X_status               OUT NOCOPY NUMBER )
     IS

     temp_status         NUMBER DEFAULT NULL;

            CURSOR GetRelatedItems IS
         SELECT
                 expenditure_item_id
           FROM
                 pa_expenditure_items_all
          WHERE
                 source_expenditure_item_id = X_expenditure_item_id;
     BEGIN

       FOR eachRec IN GetRelatedItems LOOP

         UPDATE pa_expenditure_items_all
            SET
                 revenue_distributed_flag = 'N'
	 ,       rev_dist_rejection_code = NULL  /*Added for bug 9367103*/
	 ,       last_updated_by = X_user
         ,       last_update_date = sysdate
         ,       last_update_login = X_login
           WHERE
             expenditure_item_id = eachRec.expenditure_item_id;


         pa_adjustments.InsAuditRec( eachRec.expenditure_item_id
                                   , 'REVENUE RECALC'
                                   , X_module
                                   , X_user
                                   , X_login
                                   , temp_status
				/* R12 Changes Start */
	                           , G_REQUEST_ID
          	                   , G_PROGRAM_ID
	                           , G_PROG_APPL_ID
	                           , sysdate );
 				/* R12 Changes End */
         CheckStatus( temp_status );

       END LOOP;

     X_status := 0;

     EXCEPTION
       WHEN  OTHERS  THEN
         X_status := SQLCODE;
         RAISE;

     END  RecalcRelatedItems;


-- ========================================================================
-- PROCEDURE RecalcRev
-- ========================================================================

  PROCEDURE  RecalcRev( ItemsIdTab       IN pa_utils.IdTabTyp
                      , AdjustsIdTab     IN pa_utils.IdTabTyp
                      , X_user           IN NUMBER
                      , X_login          IN NUMBER
                      , X_module         IN VARCHAR2
                      , rows             IN NUMBER
                      , X_status         OUT NOCOPY NUMBER )
  IS
     temp_status       NUMBER DEFAULT NULL;
  BEGIN
    FOR i IN 1..rows LOOP

      UPDATE pa_expenditure_items_all ei
         SET
             ei.revenue_distributed_flag = 'N'
      ,      ei.rev_dist_rejection_code = NULL  /*Added for bug 9367103*/
      ,      ei.last_update_date = sysdate
      ,      ei.last_updated_by = X_user
      ,      ei.last_update_login = X_login
       WHERE
             ei.expenditure_item_id = ItemsIdTab(i);

      InsAuditRec( ItemsIdTab(i)
                 , 'REVENUE RECALC'
                 , X_module
                 , X_user
                 , X_login
                 , temp_status
	/* R12 Changes Start */
	         , G_REQUEST_ID
          	 , G_PROGRAM_ID
	         , G_PROG_APPL_ID
	         , sysdate );
 	/* R12 Changes End */
      CheckStatus( temp_status );

      IF ( AdjustsIdTab(i) IS NOT NULL ) THEN

        UPDATE pa_expenditure_items_all eia
           SET
               eia.revenue_distributed_flag = 'N'
        ,      eia.rev_dist_rejection_code = NULL  /*Added for bug 9367103*/
        ,      eia.last_update_date = sysdate
        ,      eia.last_updated_by = X_user
        ,      eia.last_update_login = X_login
         WHERE
               eia.expenditure_item_id = AdjustsIdTab(i);

        InsAuditRec( AdjustsIdTab(i)
                   , 'REVENUE RECALC'
                   , X_module
                   , X_user
                   , X_login
                   , temp_status
		/* R12 Changes Start */
	           , G_REQUEST_ID
          	   , G_PROGRAM_ID
	           , G_PROG_APPL_ID
	           , sysdate );
 		/* R12 Changes End */
        CheckStatus( temp_status );

      END IF;
-- This part has been added for Bug # 720199. Calls the newly created procedure
-- to set revenue distributed flag to 'N' for related items as well.

      RecalcRelatedItems( ItemsIdTab(i)
                        , X_user
                        , X_login
                        , X_module
                        , temp_status );
      CheckStatus( temp_status );
    END LOOP;

    X_status := 0;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;

  END  RecalcRev;



-- ========================================================================
-- PROCEDURE RecalcCostRev
-- ========================================================================

  PROCEDURE  RecalcCostRev( ItemsIdTab       IN pa_utils.IdTabTyp
                          , AdjustsIdTab     IN pa_utils.IdTabTyp
                          , X_user           IN NUMBER
                          , X_login          IN NUMBER
                          , X_module         IN VARCHAR2
                          , rows             IN NUMBER
                          , X_num_processed  OUT NOCOPY NUMBER
                          , X_status         OUT NOCOPY NUMBER )
  IS
     temp_status         NUMBER DEFAULT NULL;
     item_count          NUMBER := 0;
     trx_source_costed   VARCHAR2(1) DEFAULT 'N';
     trx_source_accounted VARCHAr2(1) DEFAULT 'N';
     trx_source_burden    VARCHAR2(1) DEFAULT 'N';
     system_linkage      VARCHAR2(30);

     PROCEDURE  RecalcRelatedItems( X_expenditure_item_id  IN NUMBER
                                  , X_user                 IN NUMBER
                                  , X_login                IN NUMBER
                                  , X_module               IN VARCHAR2
                                  , X_status               OUT NOCOPY NUMBER )
     IS
       CURSOR GetRelatedItems IS
         SELECT
                 expenditure_item_id
           FROM
                 pa_expenditure_items_all
          WHERE
                 source_expenditure_item_id = X_expenditure_item_id;
     BEGIN

       FOR eachRec IN GetRelatedItems LOOP

         UPDATE pa_expenditure_items_all
            SET
                 cost_distributed_flag = 'N'
         ,       revenue_distributed_flag = 'N'
         ,       rev_dist_rejection_code = NULL  /*Added for bug 9367103*/
         ,       denom_raw_cost = NULL
         ,       raw_cost_rate = NULL
         ,       acct_raw_cost = NULL
         ,       raw_cost      = NULL
     /* Added denom_currency_code for Bug#2291180 */
         ,       denom_currency_code = pa_adjustments.get_denom_curr_code(transaction_source,expenditure_type,denom_currency_code,acct_currency_code,system_linkage_function)
         ,       denom_burdened_cost = NULL
         ,       acct_burdened_cost = NULL
         ,       burden_cost_rate = NULL
         ,       burden_cost        = NULL
	 /* Begin Burdening Changes - PA.L */
	 ,       adjustment_type    = 'RECALC_RAW'
	 /* End Burdening Changes - PA.L */
	 ,       project_raw_cost   = NULL
         ,       project_burdened_cost = NULL
         ,       last_updated_by = X_user
         ,       last_update_date = sysdate
         ,       last_update_login = X_login
           WHERE
                 expenditure_item_id = eachRec.expenditure_item_id;

         item_count := item_count + 1;

         pa_adjustments.InsAuditRec( eachRec.expenditure_item_id
                                   , 'COST AND REV RECALC'
                                   , X_module
                                   , X_user
                                   , X_login
                                   , temp_status
				/* R12 Changes Start */
		 	           , G_REQUEST_ID
          	 		   , G_PROGRAM_ID
	                           , G_PROG_APPL_ID
	                           , sysdate );
			 	/* R12 Changes End */
         CheckStatus( temp_status );

       END LOOP;

     X_status := 0;

     EXCEPTION
       WHEN  OTHERS  THEN
         X_status := SQLCODE;
         RAISE;

     END  RecalcRelatedItems;


  BEGIN
    FOR i IN 1..rows LOOP

      SELECT
              nvl( txs.costed_flag, 'N' )
      ,       nvl(txs.gl_accounted_flag,'N')
      ,       nvl(txs.allow_burden_flag, 'N')
      ,       ei.system_linkage_function INTO
              trx_source_costed
      ,       trx_source_accounted
      ,       trx_source_burden
      ,       system_linkage
        FROM
              pa_expenditure_items_all ei
      ,       pa_transaction_sources txs
       WHERE
              ei.transaction_source = txs.transaction_source(+)
         AND  ei.expenditure_item_id = ItemsIdTab(i);

/* R12 Changes - Added system linkage ER in addition to VI. In R12, users
                 cannot create Expense Reports in Projects. The following change
                 will prohibit the user from recalculating cost for historical
                 Expense Reports created in Projects */
      UPDATE pa_expenditure_items_all ei
         SET
             ei.cost_distributed_flag = 'N'
       /*  Reverted: Added for bug #2027985
             decode( system_linkage, 'VI', ei.cost_distributed_flag,
                                     'ER', ei.cost_distributed_flag,
              decode( trx_source_costed, 'N', 'N', ei.cost_distributed_flag ) )
        End of fix for #2027985 */
      ,      ei.revenue_distributed_flag = 'N'
      ,      ei.rev_dist_rejection_code = NULL  /*Added for bug 9367103*/
      ,      ei.denom_raw_cost =
               decode( system_linkage, 'VI', ei.denom_raw_cost,
                                       'ER', ei.denom_raw_cost,
                  decode( trx_source_costed, 'N', NULL, ei.denom_raw_cost ) )
      ,      ei.raw_cost_rate =
               decode( system_linkage, 'VI', ei.raw_cost_rate,
                                       'ER', ei.raw_cost_rate,
                  decode( trx_source_costed, 'N', NULL, ei.raw_cost_rate ) )
      ,      ei.acct_raw_cost =
               decode( system_linkage, 'VI', ei.acct_raw_cost,
                                       'ER', ei.acct_raw_cost, /* Bug 5191357 */
                 decode( trx_source_accounted, 'N', NULL, ei.acct_raw_cost) )
      ,      ei.raw_cost = NULL
      ,      ei.denom_burdened_cost = decode( trx_source_burden, 'N',
                  decode(system_linkage, 'BTC', ei.denom_burdened_cost,  NULL),decode(getprojburdenflag(ei.project_id),'N',NULL,ei.denom_burdened_cost) ) /*Added for bug:7157616*/
     /* Added denom_currency_code for Bug#2291180 */
      ,      ei.denom_currency_code = pa_adjustments.get_denom_curr_code(ei.transaction_source,ei.expenditure_type, ei.denom_currency_code, ei.acct_currency_code, ei.system_linkage_function)
      ,      ei.acct_burdened_cost =  NULL
      ,      ei.burden_cost_rate = NULL
      ,      ei.burden_cost = NULL
      /* Begin Burdening Changes - PA.L */
      ,      ei.adjustment_type = 'RECALC_RAW'
      /* End Burdening Changes - PA.L */
      ,      ei.project_raw_cost  =  NULL
      ,      ei.project_burdened_cost  =  NULL
      ,      ei.last_update_date = sysdate
      ,      ei.last_updated_by = X_user
      ,      ei.last_update_login = X_login
       WHERE
             ei.expenditure_item_id = ItemsIdTab(i);

      item_count := item_count + 1;

      InsAuditRec( ItemsIdTab(i)
                 , 'COST AND REV RECALC'
                 , X_module
                 , X_user
                 , X_login
                 , temp_status
	/* R12 Changes Start */
	         , G_REQUEST_ID
          	 , G_PROGRAM_ID
	         , G_PROG_APPL_ID
	         , sysdate );
 	/* R12 Changes End */
      CheckStatus( temp_status );

      IF ( AdjustsIdTab(i) IS NOT NULL ) THEN

        UPDATE pa_expenditure_items_all ei
           SET
               ei.cost_distributed_flag = 'N'
       /*  Reverted : Added for bug #2027985
             decode( system_linkage, 'VI', ei.cost_distributed_flag,
                                     'ER', ei.cost_distributed_flag,
              decode( trx_source_costed, 'N', 'N', ei.cost_distributed_flag ) )
        End of fix for #2027985 */
        ,      ei.revenue_distributed_flag = 'N'
	,      ei.rev_dist_rejection_code = NULL  /*Added for bug 9367103*/
        ,      ei.denom_raw_cost =
                 decode( system_linkage, 'VI', ei.denom_raw_cost,
                                         'ER', ei.denom_raw_cost,
                  decode( trx_source_costed, 'N', NULL, ei.denom_raw_cost ) )
        ,      ei.raw_cost_rate =
                 decode( system_linkage, 'VI', ei.raw_cost_rate,
                                         'ER', ei.raw_cost_rate,
                  decode( trx_source_costed, 'N', NULL, ei.raw_cost_rate ) )
        ,      ei.acct_raw_cost =
                 decode( system_linkage, 'VI', ei.acct_raw_cost,
                                         'ER', ei.acct_raw_cost,
                  decode( trx_source_accounted, 'N', NULL, ei.acct_raw_cost ) )
        ,      ei.raw_cost = NULL
        ,     ei.denom_burdened_cost =
             decode( trx_source_burden, 'N', NULL, decode(getprojburdenflag(ei.project_id),'N',NULL,ei.denom_burdened_cost) ) /*Added for bug:7157616*/
     /* Added denom_currency_code for Bug#2291180 */
      ,      ei.denom_currency_code = pa_adjustments.get_denom_curr_code(ei.transaction_source,ei.expenditure_type, ei.denom_currency_code, ei.acct_currency_code, ei.system_linkage_function)
        ,      ei.acct_burdened_cost = NULL
        ,      ei.burden_cost_rate = NULL
        ,      ei.burden_cost = NULL
        ,      ei.project_burdened_cost = NULL
        ,      ei.project_raw_cost = NULL
        ,      ei.last_update_date = sysdate
        ,      ei.last_updated_by = X_user
        ,      ei.last_update_login = X_login
           WHERE
                 ei.expenditure_item_id = AdjustsIdTab(i);

        item_count := item_count + 1;

        InsAuditRec( AdjustsIdTab(i)
                   , 'COST AND REV RECALC'
                   , X_module
                   , X_user
                   , X_login
                   , temp_status
	/* R12 Changes Start */
	         , G_REQUEST_ID
          	 , G_PROGRAM_ID
	         , G_PROG_APPL_ID
	         , sysdate );
 	/* R12 Changes End */
        CheckStatus( temp_status );

      END IF;

      RecalcRelatedItems( ItemsIdTab(i)
                        , X_user
                        , X_login
                        , X_module
                        , temp_status );
      CheckStatus( temp_status );

    END LOOP;

    X_status := 0;
    X_num_processed := item_count;
  EXCEPTION
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;

  END  RecalcCostRev;



-- ========================================================================
-- PROCEDURE RecalcIndCost
-- ========================================================================

  PROCEDURE  RecalcIndCost( ItemsIdTab          IN pa_utils.IdTabTyp
                          , AdjustsIdTab       IN pa_utils.IdTabTyp
                          , X_user           IN NUMBER
                          , X_login          IN NUMBER
                          , X_module         IN VARCHAR2
                          , rows             IN BINARY_INTEGER
                          , X_status         OUT NOCOPY NUMBER )
  IS
     temp_status          NUMBER DEFAULT NULL;
     trx_source_burden    VARCHAR2(1) DEFAULT 'N';
     system_linkage       VARCHAR2(30);

  BEGIN
    FOR i IN 1..rows LOOP

      SELECT
             nvl(txs.allow_burden_flag, 'N'),
             ei.system_linkage_function
      INTO
             trx_source_burden,
             system_linkage
      FROM
              pa_expenditure_items_all ei
      ,       pa_transaction_sources txs
       WHERE
              ei.transaction_source = txs.transaction_source(+)
      AND  ei.expenditure_item_id = ItemsIdTab(i);

	-- Added the Decode function for the acct_burdened_cost,burden_cost_rate,burden_cost
	-- to fix the bug fix : 1490316

       UPDATE pa_expenditure_items_all ei
         SET
             ei.cost_distributed_flag = 'N'
      ,      ei.denom_burdened_cost =
             decode( trx_source_burden, 'N',
                  decode(system_linkage, 'BTC', ei.denom_burdened_cost,  NULL), ei.denom_burdened_cost )
      ,      ei.acct_burdened_cost =
             decode( trx_source_burden, 'N',
                  decode(system_linkage, 'BTC', ei.acct_burdened_cost ,NULL),ei.acct_burdened_cost)
      ,      ei.burden_cost_rate =
             decode( trx_source_burden, 'N',
                  decode(system_linkage, 'BTC',ei.burden_cost_rate ,NULL),ei.burden_cost_rate)
      ,      ei.burden_cost =
             decode( trx_source_burden, 'N',
                  decode(system_linkage, 'BTC',ei.burden_cost,NULL),ei.burden_cost)
      ,      ei.project_burdened_cost =
             decode( trx_source_burden, 'N',
                  decode(system_linkage, 'BTC',ei.project_burdened_cost,NULL),ei.project_burdened_cost)
      /* Begin Burdening Changes - PA.L */
      ,      ei.adjustment_type = decode(ei.adjustment_type, 'RECALC_RAW', ei.adjustment_type
                                    , decode(ei.system_linkage_function, 'BTC', 'RECALC_RAW', 'RECALC_BURDEN'))
      /* End Burdening Changes - PA.L */
      ,      ei.last_update_date = sysdate
      ,      ei.last_updated_by = X_user
      ,      ei.last_update_login = X_login
       WHERE
             ei.expenditure_item_id = ItemsIdTab(i);

      InsAuditRec( ItemsIdTab(i)
                 , 'INDIRECT COST RECALC'
                 , X_module
                 , X_user
                 , X_login
                 , temp_status
	/* R12 Changes Start */
	         , G_REQUEST_ID
          	 , G_PROGRAM_ID
	         , G_PROG_APPL_ID
	         , sysdate );
 	/* R12 Changes End */
      CheckStatus( temp_status );

      IF ( AdjustsIdTab(i) IS NOT NULL ) THEN

        UPDATE pa_expenditure_items_all eia
           SET
               eia.cost_distributed_flag = 'N'
        ,      eia.denom_burdened_cost =
               decode( trx_source_burden, 'N', NULL, eia.denom_burdened_cost )
        ,      eia.acct_burdened_cost =  NULL
        ,      eia.burden_cost_rate = NULL
        ,      eia.burden_cost = NULL
        ,      eia.project_burdened_cost = NULL
        ,      eia.last_update_date = sysdate
        ,      eia.last_updated_by = X_user
        ,      eia.last_update_login = X_login
         WHERE
               eia.expenditure_item_id = AdjustsIdTab(i);

        InsAuditRec( AdjustsIdTab(i)
                   , 'INDIRECT COST RECALC'
                   , X_module
                   , X_user
                   , X_login
                   , temp_status
	/* R12 Changes Start */
	         , G_REQUEST_ID
          	 , G_PROGRAM_ID
	         , G_PROG_APPL_ID
	         , sysdate );
 	/* R12 Changes End */
        CheckStatus( temp_status );

      END IF;
    END LOOP;

    X_status := 0;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;

  END  RecalcIndCost;


-- ========================================================================
-- PROCEDURE RecalcRawCost
-- ========================================================================

  -- This is the exact same procedure as RecalcCostRev, except it
  -- inserts the action 'RAW COST RECALC' into the adjustment activity
  -- table, instead of 'COST AND REV RECALC'.  Used for indirect and
  -- capital (v4.0) projects, where the latter action would not make sense.

  PROCEDURE  RecalcRawCost( ItemsIdTab       IN pa_utils.IdTabTyp
                          , AdjustsIdTab     IN pa_utils.IdTabTyp
                          , X_user           IN NUMBER
                          , X_login          IN NUMBER
                          , X_module         IN VARCHAR2
                          , rows             IN NUMBER
                          , X_num_processed  OUT NOCOPY NUMBER
                          , X_status         OUT NOCOPY NUMBER )
  IS
     temp_status         NUMBER DEFAULT NULL;
     item_count          NUMBER := 0;
     trx_source_costed   VARCHAR2(1) DEFAULT 'N';
     trx_source_accounted VARCHAR2(1) DEFAULT 'N';
     trx_source_burden    VARCHAR2(1) DEFAULT 'N';
     system_linkage      VARCHAR2(30);

     PROCEDURE  RecalcRelatedItems( X_expenditure_item_id  IN NUMBER
                                  , X_user                 IN NUMBER
                                  , X_login                IN NUMBER
                                  , X_module               IN VARCHAR2
                                  , X_status               OUT NOCOPY NUMBER )
     IS
       CURSOR GetRelatedItems IS
         SELECT
                 expenditure_item_id
           FROM
                 pa_expenditure_items_all
          WHERE
                 source_expenditure_item_id = X_expenditure_item_id;
     BEGIN

       FOR eachRec IN GetRelatedItems LOOP

         UPDATE pa_expenditure_items_all
            SET
                 cost_distributed_flag = 'N'
         ,       revenue_distributed_flag = 'N'
         ,       rev_dist_rejection_code = NULL  /*Added for bug 9304451*/
         ,       denom_raw_cost = NULL
         ,       acct_raw_cost = NULL
         ,       raw_cost = NULL
         ,       raw_cost_rate = NULL
     /* Added denom_currency_code for Bug#2291180 */
        ,        denom_currency_code = pa_adjustments.get_denom_curr_code(transaction_source,expenditure_type,denom_currency_code,acct_currency_code,system_linkage_function)
         ,       denom_burdened_cost = NULL
         ,       acct_burdened_cost = NULL
         ,       burden_cost_rate = NULL
         ,       burden_cost        = NULL
	 /* Begin Burdening Changes - PA.L */
	 ,       adjustment_type    = 'RECALC_RAW'
	 /* End Burdening Changes - PA.L */
         ,       project_raw_cost  = NULL
         ,       project_burdened_cost  = NULL
         ,       last_updated_by = X_user
         ,       last_update_date = sysdate
         ,       last_update_login = X_login
           WHERE
                 expenditure_item_id = eachRec.expenditure_item_id;

         item_count := item_count + 1;

         pa_adjustments.InsAuditRec( eachRec.expenditure_item_id
                                   , 'RAW COST RECALC'
                                   , X_module
                                   , X_user
                                   , X_login
                                   , temp_status
				/* R12 Changes Start */
	                           , G_REQUEST_ID
          	                   , G_PROGRAM_ID
	                           , G_PROG_APPL_ID
	                           , sysdate );
 				/* R12 Changes End */
         CheckStatus( temp_status );

       END LOOP;

     X_status := 0;

     EXCEPTION
       WHEN  OTHERS  THEN
         X_status := SQLCODE;
         RAISE;

     END  RecalcRelatedItems;


  BEGIN
    FOR i IN 1..rows LOOP

      SELECT
              nvl( txs.costed_flag, 'N' )
      ,       nvl(txs.gl_accounted_flag,'N')
      ,       nvl(txs.allow_burden_flag, 'N')
      ,       ei.system_linkage_function
        INTO
              trx_source_costed
      ,       trx_source_accounted
      ,       trx_source_burden
      ,       system_linkage
        FROM
              pa_expenditure_items_all ei
      ,       pa_transaction_sources txs
       WHERE
              ei.transaction_source = txs.transaction_source(+)
         AND  ei.expenditure_item_id = ItemsIdTab(i);

/* R12 Changes - Added system linkage ER in addition to VI. In R12, users
                 cannot create Expense Reports in Projects. The following change
                 will prohibit the user from recalculating cost for historical
                 Expense Reports created in Projects */
      UPDATE pa_expenditure_items_all ei
         SET
             ei.cost_distributed_flag = 'N'
       /* Reverted: Added for bug #2027985
             decode( system_linkage, 'VI', ei.cost_distributed_flag,
                                     'ER', ei.cost_distributed_flag,
              decode( trx_source_costed, 'N', 'N', ei.cost_distributed_flag ) )
        End of fix for #2027985 */
      ,      ei.revenue_distributed_flag = 'N'
      ,      ei.rev_dist_rejection_code = NULL  /*Added for bug 9304451*/
      ,      ei.denom_raw_cost =
               decode( system_linkage, 'VI', ei.denom_raw_cost,
                                       'ER', ei.denom_raw_cost,
                  decode( trx_source_costed, 'N', NULL, ei.denom_raw_cost ) )
      ,      ei.raw_cost_rate =
               decode( system_linkage, 'VI', ei.raw_cost_rate,
                                       'ER', ei.raw_cost_rate,
                  decode( trx_source_costed, 'N', NULL, ei.raw_cost_rate ) )
      ,      ei.acct_raw_cost =
               decode( system_linkage, 'VI', ei.acct_raw_cost,
                                       'ER', ei.acct_raw_cost,
                  decode( trx_source_accounted, 'N', NULL, ei.acct_raw_cost ) )
      ,      ei.raw_cost = NULL
      ,       ei.denom_burdened_cost =decode( trx_source_burden, 'N',
                  decode(system_linkage, 'BTC', ei.denom_burdened_cost,  NULL)
                          ,decode(getprojburdenflag(ei.project_id),'N',NULL,ei.denom_burdened_cost))  /*added for bug:7157616*/
     /* Added denom_currency_code for Bug#2291180 */
      ,      ei.denom_currency_code = pa_adjustments.get_denom_curr_code(ei.transaction_source,ei.expenditure_type, ei.denom_currency_code, ei.acct_currency_code, ei.system_linkage_function)
      ,      ei.acct_burdened_cost = NULL
      ,      ei.burden_cost_rate = NULL
      ,      ei.burden_cost = NULL
      /* Begin Burdening Changes - PA.L */
      ,      ei.adjustment_type = 'RECALC_RAW'
      /* End Burdening Changes - PA.L */
      ,      ei.project_raw_cost = null
      ,      ei.project_burdened_cost  =  null
      ,      ei.last_update_date = sysdate
      ,      ei.last_updated_by = X_user
      ,      ei.last_update_login = X_login
       WHERE
             ei.expenditure_item_id = ItemsIdTab(i);

      item_count := item_count + 1;

      InsAuditRec( ItemsIdTab(i)
                 , 'RAW COST RECALC'
                 , X_module
                 , X_user
                 , X_login
                 , temp_status
	/* R12 Changes Start */
	         , G_REQUEST_ID
          	 , G_PROGRAM_ID
	         , G_PROG_APPL_ID
	         , sysdate );
 	/* R12 Changes End */
      CheckStatus( temp_status );

      IF ( AdjustsIdTab(i) IS NOT NULL ) THEN

        UPDATE pa_expenditure_items_all ei
           SET
               ei.cost_distributed_flag ='N'
       /* Reverted: Added for bug #2027985
             decode( system_linkage, 'VI', ei.cost_distributed_flag,
                                     'ER', ei.cost_distributed_flag,
              decode( trx_source_costed, 'N', 'N', ei.cost_distributed_flag ) )
        End of fix for #2027985 */
        ,      ei.revenue_distributed_flag = 'N'
        ,      ei.rev_dist_rejection_code = NULL  /*Added for bug 9304451*/
        ,      ei.denom_raw_cost =
                 decode( system_linkage, 'VI', ei.denom_raw_cost,
                                         'ER', ei.denom_raw_cost,
                  decode( trx_source_costed, 'N', NULL, ei.denom_raw_cost ) )
        ,      ei.raw_cost_rate =
                 decode( system_linkage, 'VI', ei.raw_cost_rate,
                                         'ER', ei.raw_cost_rate,
                  decode( trx_source_costed, 'N', NULL, ei.raw_cost_rate ) )
        ,      ei.acct_raw_cost =
                 decode( system_linkage, 'VI', ei.acct_raw_cost,
                                         'ER', ei.acct_raw_cost,
                  decode( trx_source_accounted, 'N', NULL, ei.acct_raw_cost ) )
        ,      ei.denom_burdened_cost =
             decode( trx_source_burden, 'N', NULL, decode(getprojburdenflag(ei.project_id),'N',NULL,ei.denom_burdened_cost) ) /*added for bug:7157616*/
     /* Added denom_currency_code for Bug#2291180 */
        ,      ei.denom_currency_code = pa_adjustments.get_denom_curr_code(ei.transaction_source,ei.expenditure_type, ei.denom_currency_code, ei.acct_currency_code, ei.system_linkage_function)
        ,      ei.acct_burdened_cost = NULL
        ,      ei.burden_cost_rate = NULL
        ,      ei.burden_cost = NULL
        ,      ei.raw_cost = NULL
        ,      ei.project_burdened_cost  =  null
        ,      ei.project_raw_cost  =  null
        ,      ei.last_update_date = sysdate
        ,      ei.last_updated_by = X_user
        ,      ei.last_update_login = X_login
           WHERE
                 ei.expenditure_item_id = AdjustsIdTab(i);

        item_count := item_count + 1;

        InsAuditRec( AdjustsIdTab(i)
                   , 'RAW COST RECALC'
                   , X_module
                   , X_user
                   , X_login
                   , temp_status
	/* R12 Changes Start */
	         , G_REQUEST_ID
          	 , G_PROGRAM_ID
	         , G_PROG_APPL_ID
	         , sysdate );
 	/* R12 Changes End */
        CheckStatus( temp_status );

      END IF;

      RecalcRelatedItems( ItemsIdTab(i)
                        , X_user
                        , X_login
                        , X_module
                        , temp_status );
      CheckStatus( temp_status );

    END LOOP;

    X_status := 0;
    X_num_processed := item_count;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;

  END  RecalcRawCost;


-- ========================================================================
-- PROCEDURE RecalcCapCost
-- ========================================================================

  -- This is the exact same as RecalcIndCost, except it also sets the
  -- revenue_distributed_flag to 'N'.  Used for expenditure items
  -- belonging to CAPITAL projects (v4.0).

  PROCEDURE  RecalcCapCost( ItemsIdTab          IN pa_utils.IdTabTyp
                          , AdjustsIdTab       IN pa_utils.IdTabTyp
                          , X_user           IN NUMBER
                          , X_login          IN NUMBER
                          , X_module         IN VARCHAR2
                          , rows             IN BINARY_INTEGER
                          , X_status         OUT NOCOPY NUMBER )
  IS
     temp_status       NUMBER DEFAULT NULL;
     trx_source_burden    VARCHAR2(1) DEFAULT 'N';
     system_linkage      VARCHAR2(30);

  BEGIN
    FOR i IN 1..rows LOOP

        SELECT
             nvl(txs.allow_burden_flag, 'N'),
             ei.system_linkage_function
        INTO
             trx_source_burden,
             system_linkage
        FROM
              pa_expenditure_items_all ei
      ,       pa_transaction_sources txs
       WHERE
              ei.transaction_source = txs.transaction_source(+)
       AND  ei.expenditure_item_id = ItemsIdTab(i);

	--- Added the decode function for the following columns acct_burdened_cost,burden_cost_rate,
	--- burden_cost as a bug fix : 1490316, it enables to recalc BTC ei only for the accounting
	--- purpose.

      UPDATE pa_expenditure_items_all ei
         SET
             ei.cost_distributed_flag = 'N'
      ,      ei.revenue_distributed_flag = 'N'
      ,      ei.rev_dist_rejection_code = NULL  /*Added for bug:9367103 */
      ,      ei.denom_burdened_cost =
             decode( trx_source_burden, 'N',
                  decode(system_linkage, 'BTC', ei.denom_burdened_cost,  NULL), ei.denom_burdened_cost )
      ,      ei.acct_burdened_cost =
             decode( trx_source_burden, 'N',
                  decode(system_linkage, 'BTC', ei.acct_burdened_cost,NULL), ei.acct_burdened_cost )
      ,      ei.burden_cost_rate =
             decode( trx_source_burden, 'N',
                  decode(system_linkage, 'BTC', ei.burden_cost_rate , NULL),  ei.burden_cost_rate )
      ,      ei.burden_cost =
             decode( trx_source_burden, 'N',
                  decode(system_linkage, 'BTC',ei.burden_cost , NULL ),ei.burden_cost )
      ,      ei.project_burdened_cost =
             decode( trx_source_burden, 'N',
                  decode(system_linkage, 'BTC',ei.project_burdened_cost , NULL ),ei.project_burdened_cost )
      /* Begin Burdening Changes - PA.L */
      ,      ei.adjustment_type = decode(ei.adjustment_type, 'RECALC_RAW', ei.adjustment_type
                                      , decode(ei.system_linkage_function, 'BTC', 'RECALC_BURDEN'))
      /* End Burdening Changes - PA.L */
      ,      ei.last_update_date = sysdate
      ,      ei.last_updated_by = X_user
      ,      ei.last_update_login = X_login
       WHERE
             ei.expenditure_item_id = ItemsIdTab(i);

      InsAuditRec( ItemsIdTab(i)
                 , 'INDIRECT COST RECALC'
                 , X_module
                 , X_user
                 , X_login
                 , temp_status
	/* R12 Changes Start */
	         , G_REQUEST_ID
          	 , G_PROGRAM_ID
	         , G_PROG_APPL_ID
	         , sysdate );
 	/* R12 Changes End */
      CheckStatus( temp_status );

      IF ( AdjustsIdTab(i) IS NOT NULL ) THEN

        UPDATE pa_expenditure_items_all eia
           SET
               eia.cost_distributed_flag = 'N'
        ,      eia.denom_burdened_cost =
               decode( trx_source_burden, 'N', NULL, eia.denom_burdened_cost )
        ,      eia.acct_burdened_cost =  NULL
        ,      eia.burden_cost_rate = NULL
        ,      eia.burden_cost = NULL
        ,      eia.project_burdened_cost = NULL
        ,      eia.last_update_date = sysdate
        ,      eia.last_updated_by = X_user
        ,      eia.last_update_login = X_login
         WHERE
               eia.expenditure_item_id = AdjustsIdTab(i);

        InsAuditRec( AdjustsIdTab(i)
                   , 'INDIRECT COST RECALC'
                   , X_module
                   , X_user
                   , X_login
                   , temp_status
	/* R12 Changes Start */
	           , G_REQUEST_ID
            	   , G_PROGRAM_ID
	           , G_PROG_APPL_ID
	           , sysdate );
 	/* R12 Changes End */
        CheckStatus( temp_status );

      END IF;
    END LOOP;

    X_status := 0;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;

  END  RecalcCapCost;


--   Fix for Bug # 553129. dhituval on 27-APR
--====================================================================
-- Function GetInvId
--====================================================================

 FUNCTION GetInvId(X_expenditure_item_id NUMBER) return VARCHAR2 is

 v_system_reference2  VARCHAR2(30);
 v_exp_item_id        NUMBER;

 CURSOR c2 is

 select expenditure_item_id
 from pa_expenditure_items_all peia
 where  exists( select null
               from pa_cost_distribution_lines_all cdl
               where cdl.expenditure_item_id = peia.expenditure_item_id)
 start with expenditure_item_id = X_expenditure_item_id
 connect by prior transferred_from_exp_item_id = expenditure_item_id ;

 BEGIN

 for rec in c2 LOOP

 select system_reference2 into v_system_reference2
 from pa_cost_distribution_lines_all
 where expenditure_item_id = rec.expenditure_item_id
 and  line_num_reversed is null
 and  reversed_flag is null
 and  line_type = 'R';

 END LOOP;

 return v_system_reference2;

 end GetInvId;


--=======================================================================
-- Function InvStatus
--=======================================================================
/* R12 changes */
   FUNCTION InvStatus( X_system_reference2  VARCHAR2
                     , X_system_linkage_function VARCHAR2)
   return VARCHAR2 is

-- to check if invoice is cancelled or paid
CURSOR check_inv_cur(p_invoice_id NUMBER) is
SELECT CANCELLED_DATE,
       CANCELLED_BY
FROM   ap_invoices_all
WHERE  invoice_id = p_invoice_id
FOR UPDATE OF INVOICE_ID NOWAIT;
-- to lock the invoice during validation

l_cancelled_date DATE;
l_cancelled_by NUMBER;

   X_error_code  VARCHAR2(30);

   Resource_busy EXCEPTION ;
   PRAGMA EXCEPTION_INIT(Resource_busy,-00054) ;

   BEGIN

	X_error_code := 'N';

        SAVEPOINT AP_PA_REL_LOCK;
        OPEN check_inv_cur(X_system_reference2);
        FETCH check_inv_cur
         INTO l_cancelled_date
             ,l_cancelled_by;
        CLOSE check_inv_cur;

/* check if invoice is cancelled (l_cancelled_date or l_cancelled_by is NOT NULL),
   this check will not be done if the adjustment action is BILLABLE/NON-BILLABLE */
        IF  (l_cancelled_date IS NOT NULL
        OR  l_cancelled_by IS NOT NULL) THEN
          X_Error_code := 'PA_INV_CANCELLED';
        END IF;

/* Release lock if adjustment is not allowed on expenditure item for this invoice */
        IF X_error_code <> 'N' THEN
          ROLLBACK to AP_PA_REL_LOCK;
        END IF;
        RETURN X_error_code;

  EXCEPTION
    when Resource_busy then
      IF x_system_linkage_function = 'VI' THEN
        X_error_code := 'PA_ADJ_INV_OPEN_IN_AP';
      ELSE /* must be ER */
        X_error_code := 'PA_ADJ_ER_OPEN_IN_AP';
      END IF;
      RETURN X_error_code ;
    RAISE ;
    when others then
    RAISE;

 END InvStatus;


-- ========================================================================
-- PROCEDURE Hold
-- ========================================================================

  PROCEDURE  Hold( ItemsIdTab        IN pa_utils.IdTabTyp
                 , AdjustsIdTab     IN pa_utils.IdTabTyp
                 , X_hold         IN VARCHAR2
                 , X_adj_activity IN VARCHAR2
                 , X_user         IN NUMBER
                 , X_login        IN NUMBER
                 , X_module       IN VARCHAR2
                 , rows           IN BINARY_INTEGER
                 , X_status       OUT NOCOPY NUMBER )
  IS
    temp_status      NUMBER DEFAULT NULL;
  BEGIN

    FOR i IN 1..rows LOOP

      UPDATE pa_expenditure_items_all ei
         SET
              ei.bill_hold_flag           = X_hold
      ,       ei.last_updated_by          = X_user
      ,       ei.last_update_date         = sysdate
      ,       ei.last_update_login        = X_login
       WHERE
              ei.expenditure_item_id = ItemsIdTab(i);

      InsAuditRec( ItemsIdTab(i)
                 , X_adj_activity
                 , X_module
                 , X_user
                 , X_login
                 , temp_status
	/* R12 Changes Start */
	         , G_REQUEST_ID
          	 , G_PROGRAM_ID
	         , G_PROG_APPL_ID
	         , sysdate );
 	/* R12 Changes End */
      CheckStatus( temp_status );

      IF ( AdjustsIdTab(i) IS NOT NULL ) THEN

        UPDATE pa_expenditure_items_all eia
           SET
                eia.bill_hold_flag           = X_hold
        ,       eia.last_updated_by          = X_user
        ,       eia.last_update_date         = sysdate
        ,       eia.last_update_login        = X_login
         WHERE
                eia.expenditure_item_id = AdjustsIdTab(i);

        InsAuditRec( AdjustsIdTab(i)
                   , X_adj_activity
                   , X_module
                   , X_user
                   , X_login
                   , temp_status
	/* R12 Changes Start */
  	           , G_REQUEST_ID
          	   , G_PROGRAM_ID
	           , G_PROG_APPL_ID
	           , sysdate );
 	/* R12 Changes End */
        CheckStatus( temp_status );

       END IF;

    END LOOP;

    X_status := 0;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;

  END  Hold;

-- ========================================================================
--  Start of work type  adjustments
-- ========================================================================
/** Logic:
 *  If PA: Transaction Billability derived from Work Type = YES
 *         and  change in work type results in change in the billablity
 *         then update EI with cost_distributed_flag = 'N' so that
 *         costing process will generate reverse and new cdls
 *         IF change in work type NOT results in chagne in billablity
 *         then create new and reverse cdls with transfer status_code = 'G'
 *         and Util summarize_flag  = 'N' and update EI with cost_distributed_flag = 'Y'
 *         so that the cdls are not picked up by summarized programm
 *  If PA: Transaction Billability derived from Work Type = NO
 *         work type and Billabiltiy are two independent process so
 *         then create new and reverse cdls with transfer status_code = 'G'
 *         and Util summarize_flag  = 'N'
 *         To change the billability of the transaction user has to run the
 *         Reclass Billable / Non Billable adjustments seperately
 **/
PROCEDURE  work_type_adjustment
	           ( ItemsIdTab         IN pa_utils.IdTabTyp
             --, AdjustsIdTab      IN pa_utils.IdTabTyp
               , p_billable        IN VARCHAR2
		       , p_work_type_id    IN NUMBER
               , p_adj_activity    IN VARCHAR2
               , p_user            IN NUMBER
               , p_login           IN NUMBER
               , p_module          IN VARCHAR2
               , p_rows            IN BINARY_INTEGER
               , p_TpAmtTypCodeTab        IN pa_utils.Char30TabTyp
               , p_dest_tp_amt_type_code  IN VARCHAR2
               , x_status          OUT NOCOPY NUMBER )
IS
    	l_temp_status      NUMBER DEFAULT NULL;
    	l_err_code         NUMBER ;
    	l_err_stage        VARCHAR2(2000);
    	l_err_stack        VARCHAR2(255) ;

    	l_new_billability  VARCHAR2(10);
    	l_old_billability  VARCHAR2(10);
	    l_old_work_type_id NUMBER ;
        l_profile_option   VARCHAR2(1);
	    l_change_in_billable VARCHAR2(1);
	    l_gl_accounted_flag  VARCHAR2(1);
        l_proj_type_class_code        VARCHAR2(80);
        l_billable_cap_flag           VARCHAR2(15);
	    l_reverse_cdl_status          varchar2(1) :='S' ;

    	FUNCTION cdl_creation
                   ( p_exp_item_id      IN NUMBER
                    , p_billable        IN VARCHAR2
                    , p_work_type_id    IN NUMBER
                    , p_adj_activity    IN VARCHAR2
                    , p_user            IN NUMBER
                    , p_login           IN NUMBER
                    , p_module          IN VARCHAR2
                    , p_mode            IN VARCHAR2
                    , x_status          OUT NOCOPY NUMBER
		            , p_billable_change IN VARCHAR2
                    , p_tp_amt_type_code      IN VARCHAR2
                    , p_dest_tp_amt_type_code IN VARCHAR2) return varchar2 IS

          l_transaction_source      	VARCHAR2(30);
          l_gl_accounted_flag       	VARCHAR2(1);
          l_denom_currency_code     	VARCHAR2(15);
          l_acct_currency_code      	VARCHAR2(15);
          l_acct_rate_date          	DATE;
          l_acct_rate_type          	VARCHAR2(30);
          l_acct_exchange_rate      	NUMBER;
          l_project_currency_code   	VARCHAR2(15);
          l_project_rate_date       	DATE;
          l_project_rate_type       	VARCHAR2(30);
          l_project_exchange_rate   	NUMBER;
          l_system_linkage_function 	VARCHAR2(30);
          l_projfunc_currency_code   	VARCHAR2(15);
          l_projfunc_cost_rate_date     DATE;
          l_projfunc_cost_rate_type     VARCHAR2(30);
          l_projfunc_cost_exchg_rate    NUMBER;
          l_work_type_id                NUMBER;
          l_reverse_cdl_status          varchar2(1) :='S' ;

      	BEGIN

            BEGIN
             IF P_DEBUG_MODE  THEN
                print_message('get_denom_curr_code: ' || 'inside cdl_creation api before SELECT ');
             END IF;
         	SELECT
		        ei.transaction_source,
                tr.gl_accounted_flag,
                ei.denom_currency_code,
                ei.acct_currency_code,
                ei.acct_rate_date,
                ei.acct_rate_type,
                ei.acct_exchange_rate,
                ei.project_currency_code,
                ei.project_rate_date,
                ei.project_rate_type,
                ei.project_exchange_rate,
                tr.system_linkage_function,
                ei.projfunc_currency_code,
                ei.projfunc_cost_rate_date,
                ei.projfunc_cost_rate_type,
                ei.projfunc_cost_exchange_rate,
                ei.work_type_id
         	INTO
		l_transaction_source,
                l_gl_accounted_flag,
                l_denom_currency_code,
                l_acct_currency_code,
                l_acct_rate_date,
                l_acct_rate_type,
                l_acct_exchange_rate,
                l_project_currency_code,
                l_project_rate_date,
                l_project_rate_type,
                l_project_exchange_rate,
                l_system_linkage_function,
                l_projfunc_currency_code,
                l_projfunc_cost_rate_date,
                l_projfunc_cost_rate_type,
                l_projfunc_cost_exchg_rate,
                l_work_type_id
          	FROM  pa_expenditure_items_all ei,
                	pa_transaction_sources tr
          	WHERE tr.transaction_source(+) = ei.transaction_source
            	AND expenditure_item_id   = p_exp_item_id;

		IF P_DEBUG_MODE  THEN
		   print_message('get_denom_curr_code: ' || 'inside cdl_creation api after SELECT ');
		END IF;


        	IF ( l_gl_accounted_flag = 'Y' and l_system_linkage_function <> 'VI' )
                    OR ( p_billable_change = 'N')   then

		        IF P_DEBUG_MODE  THEN
		           print_message('get_denom_curr_code: ' || 'calling pa_costing reversecdl api from work type adjustment api');
		        END IF;
            		Pa_Costing.ReverseCdl
				( X_expenditure_item_id            =>  p_exp_item_id
                                 , X_billable_flag                  =>  p_billable
                                 , X_amount                         =>  NULL
                                 , X_quantity                       =>  NULL
                                 , X_burdened_cost                  =>  NULL
                                 , X_dr_ccid                        =>  NULL
                                 , X_cr_ccid                        =>  NULL
                                 , X_tr_source_accounted            =>  'Y'
                                 , X_line_type                      =>  'R'
                                 , X_user                           =>  p_user
                                 , X_denom_currency_code            =>  l_denom_currency_code
                                 , X_denom_raw_cost                 =>  NULL
                                 , X_denom_burden_cost              =>  NULL
                                 , X_acct_currency_code             =>  l_acct_currency_code
                                 , X_acct_rate_date                 =>  l_acct_rate_date
                                 , X_acct_rate_type                 =>  l_acct_rate_type
                                 , X_acct_exchange_rate             =>  l_acct_exchange_rate
                                 , X_acct_raw_cost                  =>  NULL
                                 , X_acct_burdened_cost             =>  NULL
                                 , X_project_currency_code          =>  l_project_currency_code
                                 , X_project_rate_date              =>  l_project_rate_date
                                 , X_project_rate_type              =>  l_project_rate_type
                                 , X_project_exchange_rate          =>  l_project_exchange_rate
                                 , X_err_code                       =>  l_err_code
                                 , X_err_stage                      =>  l_err_stage
                                 , X_err_stack                      =>  l_err_stack
                                 , P_Projfunc_currency_code         =>  l_projfunc_currency_code
                                 , P_Projfunc_cost_rate_date        =>  l_projfunc_cost_rate_date
                                 , P_Projfunc_cost_rate_type        =>  l_projfunc_cost_rate_type
                                 , P_Projfunc_cost_exchange_rate    =>  l_projfunc_cost_exchg_rate
                                 , P_project_raw_cost               =>  null
                                 , P_project_burdened_cost          =>  null
                                 , P_Work_Type_Id                   =>  p_work_type_id
				 , p_mode                           =>  p_mode
                                 );
			IF P_DEBUG_MODE  THEN
			   print_message('get_denom_curr_code: ' || 'end of reverse cdl api');
			END IF;
			l_reverse_cdl_status := 'S';

		ELSE
			l_reverse_cdl_status := 'E';

                END IF;

              EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        IF P_DEBUG_MODE  THEN
                           print_message('get_denom_curr_code: ' || 'no data found in cdl creation api');
                        END IF;
                        l_reverse_cdl_status := 'E';
                        NULL;

		     WHEN OTHERS then
			l_reverse_cdl_status := 'U';
			RAISE;
			NULL;
              END ;

	      RETURN l_reverse_cdl_status;


      	EXCEPTION
         	WHEN NO_DATA_FOUND THEN
			IF P_DEBUG_MODE  THEN
			   print_message('get_denom_curr_code: ' || 'no data found in cdl creation api');
			END IF;
			RETURN l_reverse_cdl_status;
              		NULL ;
         	WHEN OTHERS THEN
			IF P_DEBUG_MODE  THEN
			   print_message('get_denom_curr_code: ' || 'others in cdl creation ='||sqlcode);
			END IF;
			x_status := sqlcode;
               		RAISE ;

   	END cdl_creation;

BEGIN


	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'inside work type adjustment api before loop');
	END IF;

    FOR i IN 1..p_rows LOOP

	IF P_DEBUG_MODE  THEN
	   print_message ('get_denom_curr_code: ' || 'before select exp_item ='||ItemsIdTab(i));
	END IF;
        /** check the change in work type results in change in billabity **/
         SELECT EI.work_type_id
                ,nvl(tr.gl_accounted_flag,'N')
	            ,pt.PROJECT_TYPE_CLASS_CODE
		        ,nvl(ei.billable_flag ,'N')
         INTO   l_old_work_type_id
                ,l_gl_accounted_flag
                ,l_proj_type_class_code
		        ,l_old_billability
         FROM   pa_expenditure_items_all EI
                ,pa_transaction_sources tr
	            ,pa_project_types_all pt /** Bug fix 2262118  **/
	            ,pa_projects_all pp
		        -- ,pa_tasks t /* Bug 3457922 */
         WHERE tr.transaction_source(+) = ei.transaction_source
         AND   ei.expenditure_item_id = ItemsIdTab(i)
	     -- AND   t.task_id = ei.task_id  /* Bug 3457922 */
	     -- AND   pp.project_id = t.project_id /* Bug 3457922 */
         AND   pp.project_id = ei.project_id   /* Added : Bug 3457922 */
         AND   pp.project_type = pt.project_type
         -- start 12i MOAC changes
	     -- AND   nvl(pp.org_id ,-99) = nvl(pt.org_id ,-99) ;
         AND   pp.org_id = pt.org_id;
         -- end 12i MAOC changes

	/** we are not supposed to change the work type and billable flag
         *  if the destination work type results in  billable for the project_type
         *  is INDIRECT  we should not process . this check is already placed
         *  forms LOV to pick only non billable work types for indirect project
         *  at the item level addjustments , the same is not possible for
         *  massadjust. SO if this api is called from massadjust . we should return
         *  without processing
         **/

	 IF (l_proj_type_class_code = 'INDIRECT') then
		        SELECT nvl(BILLABLE_CAPITALIZABLE_FLAG,'N')
			    INTO  l_billable_cap_flag
        		FROM  pa_work_types_b -- bug 4668802 changed from pa_work_types_v to pa_work_types_b
        		WHERE work_type_id = p_work_type_id
			    AND   trunc(sysdate) between start_date_active and
				                             nvl(end_date_active,sysdate);

		If  l_billable_cap_flag = 'Y' then
		    RETURN;
		End if;

	 END IF;

	IF P_DEBUG_MODE  THEN
	   print_message ('get_denom_curr_code: ' || 'after select l_old_work_type_id ['||l_old_work_type_id||
                       ']l_gl_accounted_flag['||l_gl_accounted_flag||']l_old_billability['||l_old_billability||']' );
	END IF;

        l_profile_option := pa_utils4.IS_WORKTYPE_BILLABLE_ENABLED ;

	If l_profile_option = 'Y' and l_proj_type_class_code  in ('CAPITAL','CONTRACT') then


		l_new_billability := PA_UTILS4.get_trxn_work_billabilty
				(p_work_type_id       => p_work_type_id
                            	,p_tc_extn_bill_flag  => NULL );

		/*** Commented out this portion due to following issue
                 ** Initially set the work type profile to 'N' and transaction is entered with billability = 'Y'
                 ** Now set the work type profile to 'Y', As the old and new worktype results no change in billability
                 ** then EI will never be updated with the billablity change . in order to fix this
                 ** donot derive old billabity based on worktype
        	    l_old_billability := PA_UTILS4.get_trxn_work_billabilty
                                (p_work_type_id       => l_old_work_type_id
                                ,p_tc_extn_bill_flag  => NULL );
		 **/

		IF l_new_billability <> l_old_billability then

			l_change_in_billable := 'Y';
		Else
			l_change_in_billable := 'N';
		End if;

	Else

		l_change_in_billable := 'N';

	End if;

	--l_profile_option := pa_utils4.IS_WORKTYPE_BILLABLE_ENABLED ;

	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'l_old_billability['||l_old_billability||
		      ']l_new_billability['||l_new_billability||
                      ']p_oldTpAMTcode['||p_TpAmtTypCodeTab(i)||']p_newTpAMTcode['||p_dest_tp_amt_type_code||
	              ']l_old_work_type_id['||l_old_work_type_id||']l_new_work_type_id['||p_work_type_id||
		      ']l_profile_option ['||l_profile_option||']l_change_in_billable['||l_change_in_billable||
		      ']l_gl_accounted_flag['||l_gl_accounted_flag||']'  );
	END IF;

	IF l_change_in_billable = 'Y' AND l_gl_accounted_flag = 'Y'  THEN
                /** create reverse and new cdls with transfer status code = 'P'
		 ** and pass new billable flag to create cdl api **/
                IF P_DEBUG_MODE  THEN
                   print_message('get_denom_curr_code: ' || 'calling cdl_creation api');
                END IF;
                l_reverse_cdl_status := cdl_creation
                   ( p_exp_item_id      => ItemsIdTab(i)
                    , p_billable        => l_new_billability
                    , p_work_type_id    => p_work_type_id
                    , p_adj_activity    => p_adj_activity
                    , p_user            => p_user
                    , p_login           => p_login
                    , p_module          => p_module
                    , p_mode            => 'WORK_TYP_ADJ' -- passing 'WORK_TYP_ADJ', bug 3357936
                    , x_status          => x_status
		    , p_billable_change => l_change_in_billable
                    , p_tp_amt_type_code      => p_TpAmtTypCodeTab(i)
                    , p_dest_tp_amt_type_code => p_dest_tp_amt_type_code
                    );
                IF P_DEBUG_MODE  THEN
                   print_message('get_denom_curr_code: ' || 'after  cdl_creating api');
                END IF;

	Elsif l_change_in_billable = 'N' then
		/** create reverse and new cdls with transfer status code = 'G' **/
		IF P_DEBUG_MODE  THEN
		   print_message('get_denom_curr_code: ' || 'calling cdl_creation api');
		END IF;
        	l_reverse_cdl_status := cdl_creation
                   ( p_exp_item_id      => ItemsIdTab(i)
                    , p_billable        => null
                    , p_work_type_id    => p_work_type_id
                    , p_adj_activity    => p_adj_activity
                    , p_user            => p_user
                    , p_login           => p_login
                    , p_module          => p_module
                    , p_mode            => 'WORK_TYP_ADJ' -- Bug 5561542
		    , x_status          => x_status
		    , p_billable_change => l_change_in_billable
                    , p_tp_amt_type_code      => p_TpAmtTypCodeTab(i)
                    , p_dest_tp_amt_type_code => p_dest_tp_amt_type_code
                    );
		IF P_DEBUG_MODE  THEN
		   print_message('get_denom_curr_code: ' || 'after  cdl_creating api');
		END IF;

	END IF; -- end of change_in_billable

      		/**
               	*Project summarization changes Mark ei as cost distributed if cdls are created
                * mark cost distributed flag to 'Y' else mark it as 'N'
                **/
		IF P_DEBUG_MODE  THEN
		   print_message('get_denom_curr_code: ' || 'calling update of EI');
		END IF;
		/**
		Burdening changes (PA.L)
		Work type adjusment API is modified, If the transaction is already
		adjusted by burdening or other adjustment process, this API should
		NOT set the cost distributed flag to 'Y'
		Matrx for updating the cost dist flag
		OrgCostDist  BillablityChange   GlAccted  CdlCreation  UpdCostDist
		------------------------------------------------------------------
  		Y             Y                Y         success       Y
  		N             Y                Y         success       N
  		Y/N           Y                Y         No cdls       N
  		Y/N           Y                N          ---          N
  		Y             N                -         success       Y
  		Y/N           N                -         No cdls       N
		Solution: added decode(nvl(ei.cost_distributed_flag,'N'),'Y','Y','N')
		**/
                UPDATE  pa_expenditure_items_all ei
                SET     ei.work_type_id              = p_work_type_id
                        ,ei.cost_distributed_flag    =
				decode(l_change_in_billable,
				   'Y', decode(l_gl_accounted_flag,
					      'N','N',
					      'Y',decode(l_reverse_cdl_status
							,'S',decode(nvl(ei.cost_distributed_flag,'N'),'Y','Y','N')
							,'N')
                                               ),
				   'N',decode(l_reverse_cdl_status,'S',
                                          decode(nvl(ei.cost_distributed_flag,'N'),'Y','Y','N'),'N'))
                        ,ei.revenue_distributed_flag = 'N'
			,ei.rev_dist_rejection_code = NULL  /*Added for bug:9367103 */
                        ,ei.billable_flag            = decode(l_change_in_billable,'Y',l_new_billability,ei.billable_flag)
                        ,ei.last_updated_by          = p_user
                        ,ei.last_update_date         = sysdate
                        ,ei.last_update_login        = p_login
                        ,ei.tp_amt_type_code         = PA_UTILS4.get_tp_amt_type_code
                                                                (p_work_type_id)
                        ,cc_bl_distributed_code      = DECODE(p_dest_tp_amt_type_code, p_TpAmtTypCodeTab(i),
                                                              cc_bl_distributed_code,
                                                              decode(cc_bl_distributed_code,'X','X','N'))
                        ,cc_ic_processed_code        = DECODE(p_dest_tp_amt_type_code, p_TpAmtTypCodeTab(i),
                                                              cc_ic_processed_code,
                                                              decode(cc_ic_processed_code,'X','X','N'))
                        /* Begin Burdening Changes - PA.L */
                        ,ei.adjustment_type          = NULL
                        /* End Burdening Changes - PA.L */
                WHERE
                        ei.expenditure_item_id = ItemsIdTab(i);

                IF P_DEBUG_MODE  THEN
                   print_message('get_denom_curr_code: ' || 'Num of rows updated ['||sql%rowcount||
                                ']with work type ['||p_work_type_id||']' );
                END IF;

                InsAuditRec( X_exp_item_id    =>       ItemsIdTab(i)
                        , X_adj_activity      =>       p_adj_activity
                        , X_module            =>       p_module
                        , X_user              =>       p_user
                        , X_login             =>       p_login
                        , X_status            =>       l_temp_status
		/* R12 Changes Start */
                        , X_who_req_id        =>       G_REQUEST_ID
                        , X_who_prog_id       =>       G_PROGRAM_ID
                        , X_who_prog_app_id   =>       G_PROG_APPL_ID
                        , X_who_prog_upd_date =>       sysdate);
		/* R12 Changes End */

                CheckStatus( status_indicator => l_temp_status );


     END LOOP;

     X_status := 0;

EXCEPTION
     WHEN  OTHERS  THEN
	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || ' others exection in work type adjustments api');
	END IF;
	X_status := SQLCODE;
	RAISE;

END  work_type_adjustment;
--===========================================================================
-- End of work type adjustments
--===========================================================================


-- ========================================================================
-- PROCEDURE Reclass
-- ========================================================================

  PROCEDURE  Reclass( ItemsIdTab        IN pa_utils.IdTabTyp
                    , AdjustsIdTab      IN pa_utils.IdTabTyp
                    , X_billable        IN VARCHAR2
                    , X_adj_activity    IN VARCHAR2
                    , X_user            IN NUMBER
                    , X_login           IN NUMBER
                    , X_module          IN VARCHAR2
                    , rows              IN BINARY_INTEGER
                    , X_status          OUT NOCOPY NUMBER )
  IS
    temp_status      NUMBER DEFAULT NULL;
    err_code         NUMBER ;
    err_stage        VARCHAR2(2000);
    err_stack        VARCHAR2(255) ;
  BEGIN

    FOR i IN 1..rows LOOP

      UPDATE  pa_expenditure_items_all ei
      SET     ei.billable_flag            = X_billable
      ,       ei.revenue_distributed_flag = 'N'
      ,       ei.rev_dist_rejection_code = NULL  /*Added for bug 9304451*/
      ,       ei.cost_distributed_flag    = 'N'
      /* Begin Burdening Changes - PA.L */
      ,       ei.adjustment_type          = NULL
      /* End Burdening Changes - PA.L */
      ,       ei.last_updated_by          = X_user
      ,       ei.last_update_date         = sysdate
      ,       ei.last_update_login        = X_login
      WHERE
              ei.expenditure_item_id = ItemsIdTab(i);

      DECLARE
          p_transaction_source      VARCHAR2(30);
          p_gl_accounted_flag       VARCHAR2(1);
          p_denom_currency_code     VARCHAR2(15);
	      p_acct_currency_code      VARCHAR2(15);
	      p_acct_rate_date          DATE;
	      p_acct_rate_type          VARCHAR2(30);
	      p_acct_exchange_rate      NUMBER;
	      p_project_currency_code   VARCHAR2(15);
          p_project_rate_date       DATE;
          p_project_rate_type       VARCHAR2(30);
          p_project_exchange_rate   NUMBER;
          p_system_linkage_function VARCHAR2(30);
	      l_projfunc_currency_code   VARCHAR2(15);
          l_projfunc_cost_rate_date       DATE;
          l_projfunc_cost_rate_type       VARCHAR2(30);
          l_projfunc_cost_exchg_rate   NUMBER;
          l_work_type_id               NUMBER;

      BEGIN
         SELECT ei.transaction_source,
                tr.gl_accounted_flag,
                ei.denom_currency_code,
                ei.acct_currency_code,
	            ei.acct_rate_date,
                ei.acct_rate_type,
	            ei.acct_exchange_rate,
                ei.project_currency_code,
                ei.project_rate_date,
	            ei.project_rate_type,
                ei.project_exchange_rate,
                tr.system_linkage_function,
		        ei.projfunc_currency_code,
                ei.projfunc_cost_rate_date,
                ei.projfunc_cost_rate_type,
                ei.projfunc_cost_exchange_rate,
		        ei.work_type_id
         INTO   p_transaction_source,
                p_gl_accounted_flag,
	            p_denom_currency_code,
                p_acct_currency_code,
		        p_acct_rate_date,
                p_acct_rate_type,
		        p_acct_exchange_rate,
	            p_project_currency_code,
                p_project_rate_date,
		        p_project_rate_type,
                p_project_exchange_rate,
                p_system_linkage_function,
          	    l_projfunc_currency_code,
          	    l_projfunc_cost_rate_date,
          	    l_projfunc_cost_rate_type,
          	    l_projfunc_cost_exchg_rate,
		        l_work_type_id
          FROM  pa_expenditure_items_all ei,
                pa_transaction_sources tr
          WHERE tr.transaction_source = ei.transaction_source
            AND expenditure_item_id   = ItemsIdTab(i) ;

-- Added to IF condition below: p_system_linkage_function <> 'VI' to resolve bug # 1764279
-- Added to IF condition below: p_transaction_source <> 'AP EXPENSE' to resolve bug# 2323103
-- Modified IF condition below:
--     ((p_system_linkage_function <> 'VI') or
--      (p_system_linkage_function = 'VI' and p_transaction_source = 'PO RECEIPT '))
--                                                                                   to resolve bug# 2853597
-- Removed AP INVOICE transaction source to resolve the bug#3162892.
 /* Added sys link <> INV for Bug#3693497*/
/* Bug 4610677 - Reversal CDL will not be created for GL Accounted VI and ER transactions */
        IF p_gl_accounted_flag = 'Y' and
           p_system_linkage_function NOT IN ('VI','ER','INV') THEN

            Pa_Costing.ReverseCdl( X_expenditure_item_id            =>	ItemsIdTab(i)
                                 , X_billable_flag                  =>	X_billable
                                 , X_amount                         =>	NULL
                                 , X_quantity                       =>	NULL
                                 , X_burdened_cost                  =>	NULL
                                 , X_dr_ccid                        =>	NULL
                                 , X_cr_ccid                        =>	NULL
                                 , X_tr_source_accounted            =>	'Y'
                                 , X_line_type                      =>	'R'
                                 , X_user                           =>	X_user
                                 , X_denom_currency_code            =>	p_denom_currency_code
                                 , X_denom_raw_cost                 =>	NULL
                                 , X_denom_burden_cost              =>	NULL
                                 , X_acct_currency_code             =>	p_acct_currency_code
                                 , X_acct_rate_date                 =>	p_acct_rate_date
                                 , X_acct_rate_type                 =>	p_acct_rate_type
                                 , X_acct_exchange_rate             =>	p_acct_exchange_rate
                                 , X_acct_raw_cost                  =>	NULL
                                 , X_acct_burdened_cost             =>	NULL
                                 , X_project_currency_code          =>	p_project_currency_code
                                 , X_project_rate_date              =>	p_project_rate_date
                                 , X_project_rate_type              =>	p_project_rate_type
                                 , X_project_exchange_rate          =>	p_project_exchange_rate
                                 , X_err_code                       =>	err_code
                                 , X_err_stage                      =>	err_stage
                                 , X_err_stack                      =>	err_stack
     			                 , P_Projfunc_currency_code         =>  l_projfunc_currency_code
   				                 , P_Projfunc_cost_rate_date        =>  l_projfunc_cost_rate_date
   				                 , P_Projfunc_cost_rate_type        =>  l_projfunc_cost_rate_type
   				                 , P_Projfunc_cost_exchange_rate    =>  l_projfunc_cost_exchg_rate
   				                 , P_project_raw_cost               =>  null
   				                 , P_project_burdened_cost          =>  null
   				                 , P_Work_Type_Id                   =>  l_work_type_id
				                 , p_mode                           =>  'RECLASS'); -- passed reclass BUG 3357936

              /*
                  Project summarization changes
                  Mark ei as cost distributed
               */
               -- start 12i MOAC changes
               -- UPDATE pa_expenditure_items
               UPDATE pa_expenditure_items_all
               -- end 12i MOAC changes
               SET    cost_distributed_flag = 'Y'
               WHERE  expenditure_item_id = ItemsIdTab(i);

          END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              NULL ;
         WHEN OTHERS THEN
               RAISE ;
      END ;

      InsAuditRec( X_exp_item_id       =>	ItemsIdTab(i)
                 , X_adj_activity      =>	X_adj_activity
                 , X_module            =>	X_module
                 , X_user              =>	X_user
                 , X_login             =>	X_login
                 , X_status            =>	temp_status
	/* R12 Changes Start */
                 , X_who_req_id        =>       G_REQUEST_ID
                 , X_who_prog_id       =>       G_PROGRAM_ID
                 , X_who_prog_app_id   =>       G_PROG_APPL_ID
                 , X_who_prog_upd_date =>       sysdate);
	/* R12 Changes End */
      CheckStatus( status_indicator => temp_status );

      IF ( AdjustsIdTab(i) IS NOT NULL ) THEN


        UPDATE pa_expenditure_items_all eia
           SET
               eia.billable_flag            = X_billable
        ,      eia.revenue_distributed_flag = 'N'
	,      eia.rev_dist_rejection_code = NULL  /*Added for bug:9367103 */
        ,      eia.cost_distributed_flag    = 'N'
        ,      eia.last_updated_by          = X_user
        ,      eia.last_update_date         = sysdate
        ,      eia.last_update_login        = X_login
         WHERE
               eia.expenditure_item_id = AdjustsIdTab(i);

        DECLARE

          p_transaction_source      VARCHAR2(30);
          p_gl_accounted_flag       VARCHAR2(1);
          p_denom_currency_code     VARCHAR2(15);
	      p_acct_currency_code      VARCHAR2(15);
	      p_acct_rate_date          DATE;
	      p_acct_rate_type          VARCHAR2(30);
	      p_acct_exchange_rate      NUMBER;
	      p_project_currency_code   VARCHAR2(15);
          p_project_rate_date       DATE;
          p_project_rate_type       VARCHAR2(30);
          p_project_exchange_rate   NUMBER;
          l_projfunc_currency_code   VARCHAR2(15);
          l_projfunc_cost_rate_date       DATE;
          l_projfunc_cost_rate_type       VARCHAR2(30);
          l_projfunc_cost_exchg_rate   NUMBER;
          l_work_type_id               NUMBER;

        BEGIN

           SELECT ei.transaction_source,
                  tr.gl_accounted_flag,
                  ei.denom_currency_code,
                  ei.acct_currency_code,
		          ei.acct_rate_date,
                  ei.acct_rate_type,
		          ei.acct_exchange_rate,
                  ei.project_currency_code,
                  ei.project_rate_date,
		          ei.project_rate_type,
                  ei.project_exchange_rate,
                  ei.projfunc_currency_code,
                  ei.projfunc_cost_rate_date,
                  ei.projfunc_cost_rate_type,
                  ei.projfunc_cost_exchange_rate,
                  ei.work_type_id
           INTO   p_transaction_source,
                  p_gl_accounted_flag,
	              p_denom_currency_code,
                  p_acct_currency_code,
		          p_acct_rate_date,
                  p_acct_rate_type,
		          p_acct_exchange_rate,
	              p_project_currency_code,
                  p_project_rate_date,
		          p_project_rate_type,
                  p_project_exchange_rate,
                  l_projfunc_currency_code,
                  l_projfunc_cost_rate_date,
                  l_projfunc_cost_rate_type,
                  l_projfunc_cost_exchg_rate,
                  l_work_type_id
           FROM   pa_expenditure_items_all ei,
                  pa_transaction_sources tr
           WHERE  tr.transaction_source = ei.transaction_source
             AND  expenditure_item_id = AdjustsIdTab(i) ;

           IF p_gl_accounted_flag = 'Y' THEN

              Pa_Costing.ReverseCdl( X_expenditure_item_id            => AdjustsIdTab(i)
                                   , X_billable_flag                  => X_billable
                                   , X_amount                         => NULL
                                   , X_quantity                       => NULL
                                   , X_burdened_cost                  => NULL
                                   , X_dr_ccid                        => NULL
                                   , X_cr_ccid                        => NULL
                                   , X_tr_source_accounted            => 'Y'
                                   , X_line_type                      => 'R'
                                   , X_user                           => X_user
                                   , X_denom_currency_code            => p_denom_currency_code
                                   , X_denom_raw_cost                 => NULL
                                   , X_denom_burden_cost              => NULL
                                   , X_acct_currency_code             => p_acct_currency_code
                                   , X_acct_rate_date                 => p_acct_rate_date
                                   , X_acct_rate_type                 => p_acct_rate_type
                                   , X_acct_exchange_rate             => p_acct_exchange_rate
                                   , X_acct_raw_cost                  => NULL
                                   , X_acct_burdened_cost             => NULL
                                   , X_project_currency_code          => p_project_currency_code
                                   , X_project_rate_date              => p_project_rate_date
                                   , X_project_rate_type              => p_project_rate_type
                                   , X_project_exchange_rate          => p_project_exchange_rate
                                   , X_err_code                       => err_code
                                   , X_err_stage                      => err_stage
                                   , X_err_stack                      => err_stack
                                   , P_Projfunc_currency_code         => l_projfunc_currency_code
                                   , P_Projfunc_cost_rate_date        => l_projfunc_cost_rate_date
                                   , P_Projfunc_cost_rate_type        => l_projfunc_cost_rate_type
                                   , P_Projfunc_cost_exchange_rate    => l_projfunc_cost_exchg_rate
                                   , P_project_raw_cost               => null
                                   , P_project_burdened_cost          => null
                                   , P_Work_Type_Id                   => l_work_type_id
				                   , p_mode                           => 'RECLASS'); -- passing reclass, bug 3357936
              /*
                  Project summarization changes
                  Mark ei as cost distributed
               */
               -- start 12i MOAC changes
               -- UPDATE pa_expenditure_items
               UPDATE pa_expenditure_items_all
               -- end 12i MOAC changes
               SET    cost_distributed_flag = 'Y'
               WHERE  expenditure_item_id = AdjustsIdTab(i);

            END IF  ;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                NULL ;
           WHEN OTHERS THEN
                 RAISE ;
        END ;

        InsAuditRec( X_exp_item_id       =>	AdjustsIdTab(i)
                   , X_adj_activity      =>	X_adj_activity
                   , X_module            =>	X_module
                   , X_user              =>	X_user
                   , X_login             =>	X_login
                   , X_status            =>	temp_status
	/* R12 Changes Start */
                   , X_who_req_id        =>     G_REQUEST_ID
                   , X_who_prog_id       =>     G_PROGRAM_ID
                   , X_who_prog_app_id   =>     G_PROG_APPL_ID
                   , X_who_prog_upd_date =>     sysdate);
	/* R12 Changes End */

        CheckStatus( status_indicator => temp_status );

      END IF;

    END LOOP;

    X_status := 0;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;

  END  Reclass;


-- ========================================================================
-- PROCEDURE Split
-- ========================================================================

   PROCEDURE Split( X_exp_item_id               IN NUMBER
                  , X_item1_qty                 IN NUMBER
                  , X_item1_raw_cost            IN NUMBER
                  , X_item1_burden_cost         IN NUMBER
                  , X_item1_bill_flag           IN VARCHAR2
                  , X_item1_hold_flag           IN VARCHAR2
                  , X_item2_qty                 IN NUMBER
                  , X_item2_raw_cost            IN NUMBER
                  , X_item2_burden_cost         IN NUMBER
                  , X_item1_receipt_curr_amt    IN NUMBER
                  , X_item2_receipt_curr_amt    IN NUMBER
                  , X_item1_denom_raw_cost      IN NUMBER
                  , X_item2_denom_raw_cost      IN NUMBER
                  , X_item1_denom_burdened_cost IN NUMBER
                  , X_item2_denom_burdened_cost IN NUMBER
                  , X_Item1_acct_raw_cost       IN NUMBER
                  , X_item2_acct_raw_cost       IN NUMBER
                  , X_item1_acct_burdened_cost  IN NUMBER
                  , X_item2_acct_burdened_cost  IN NUMBER
                  , X_item2_bill_flag           IN VARCHAR2
                  , X_item2_hold_flag           IN VARCHAR2
                  , X_user                      IN NUMBER
                  , X_login                     IN NUMBER
                  , X_module                    IN VARCHAR2
                  , X_status                    OUT NOCOPY NUMBER
                  , p_item1_project_raw_cost      IN NUMBER    -- project raw
                  , p_item1_project_burden_cost   IN NUMBER    -- project burden
                  , p_item2_project_raw_cost      IN NUMBER    -- project raw
                  , p_item2_project_burden_cost   IN NUMBER    -- project burden
                 )
  IS

    item_qty                 NUMBER;
    item_raw_cost            NUMBER;
    item_burden_cost         NUMBER ;
    item_receipt_curr_amt    NUMBER;
    item_denom_raw_cost      NUMBER;
    item_denom_burdened_cost NUMBER;
    item_acct_raw_cost       NUMBER;
    item_acct_burdened_cost  NUMBER;
    item_bill_flag           VARCHAR2(1);
    item_hold_flag           VARCHAR2(1);
    new_item_id              NUMBER(15);
    item_comment             VARCHAR2(240);
    temp_status              NUMBER DEFAULT NULL;
    item_project_raw_cost    NUMBER;
    item_project_burdened_cost NUMBER ;

  /* EFC bug2259454 changes */
    l_denom_currency_code    VARCHAR2(30);
    l_exp_type               VARCHAR2(30);
    l_denom_cur_code         VARCHAR2(30);
    l_acct_cur_code          VARCHAR2(30);
    l_sys_link_func          VARCHAR2(3);
    l_denom_raw_cost         NUMBER := NULL;
    l_transaction_source     pa_expenditure_items_all.transaction_source%type;
    l_expenditure_id         pa_expenditure_items_all.expenditure_id%type;
    l_person_id              pa_expenditures_all.incurred_by_person_id%type;
    l_expenditure_item_date  Date;

/* Commented the following code as part of Bug#2291180 -- Start */
/*  Bug#2291180
    function get_denom_curr_code (l_exp_type in varchar2,
                                  l_denom_currency_code in varchar2,
                                  l_acct_currency_code in varchar2,
                                  l_system_linkage_function in varchar2,
                                  l_denom_raw_cost in number) return varchar2 is

         l_cost_rate_flag varchar2(30);
         l_return varchar2(30);

    Begin

	If l_denom_raw_cost is null Then
        	If l_system_linkage_function in ('ST','OT') Then
                	If l_acct_currency_code = l_denom_currency_code Then
                        	l_return := l_denom_currency_code;
               	 	Else
                        	l_return := pa_currency.get_currency_code;
                	End If;
        	Else
                	select cost_rate_flag
                	into l_cost_rate_flag
                	from pa_expenditure_types
                	where expenditure_type = l_exp_type;

                	If l_cost_rate_flag = 'Y' Then
                        	If l_acct_currency_code = l_denom_currency_code Then
                                	l_return := l_denom_currency_code;
                        	Else
                                	l_return := pa_currency.get_currency_code;
                        	End If;
                	Else
                        	l_return := l_denom_currency_code;
                	End If;
        	End If;
    	Else
        	l_return := l_denom_currency_code;
    	End if;

    	return l_return;

    End get_denom_curr_code;
 Bug#2291180 */
    /* End EFC bug2259454 changes */
/* Commented the above code as part of Bug#2291180 -- End */

  BEGIN

	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'Inside split server side api calling insaudit rec api');
	END IF;
    	InsAuditRec( X_exp_item_id       =>	X_exp_item_id
                   , X_adj_activity      =>	'SPLIT ORIGINATING'
                   , X_module            =>	X_module
                   , X_user              =>	X_user
                   , X_login             =>	X_login
                   , X_status            =>	temp_status );

    	CheckStatus( status_indicator => temp_status );
	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'caling back out  api');
	END IF;

        BackoutItem( X_exp_item_id      =>	X_exp_item_id
                   , X_expenditure_id   =>	NULL
                   , X_adj_activity     =>	'SPLIT BACK-OUT'
                   , X_module           =>	X_module
                   , X_user             =>	X_user
                   , X_login            =>	X_login
                   , X_status           =>	temp_status );

        CheckStatus( status_indicator => temp_status );

    /*
        Project Summarization changes
        Call procedure to create CDL for the backout item (if necessary)
     */

	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'calling Pa_Costing.CreateReverseCdl api');
	END IF;

        Pa_Costing.CreateReverseCdl( X_exp_item_id => X_exp_item_id,
                                     X_backout_id  => Pa_Adjustments.BackOutId,
                                     X_user        => X_user,
                                     X_status      => temp_status);

        CheckStatus( status_indicator => temp_status );

        IF P_DEBUG_MODE  THEN
           print_message('get_denom_curr_code: ' || 'calling ReverseRelatedItems api');
        END IF;

    	ReverseRelatedItems( X_source_exp_item_id  => X_exp_item_id
                           , X_expenditure_id      => NULL
                           , X_module              => X_module
                           , X_user                => X_user
                           , X_login               => X_login
                           , X_status              => temp_status );

    	CheckStatus( status_indicator => temp_status );

    	BEGIN

      		SELECT
              		ec.expenditure_comment
        	INTO
              		item_comment
        	FROM
              		pa_expenditure_comments ec
       		WHERE
              		ec.expenditure_item_id = X_exp_item_id;

    	EXCEPTION
      		WHEN  NO_DATA_FOUND  THEN
        		NULL;
   	END;

   	/* Begin EFC bug2259454 changes */
    	select
                transaction_source,
        	expenditure_type,
        	denom_currency_code,
        	acct_currency_code,
        	system_linkage_function,
        	denom_raw_cost,
		expenditure_id ,
		expenditure_item_date
    	into
                l_transaction_source,
        	l_exp_type,
        	l_denom_cur_code,
        	l_acct_cur_code,
        	l_sys_link_func,
        	l_denom_raw_cost,
		l_expenditure_id,
		l_expenditure_item_date
    	from
        	pa_expenditure_items_all
    	where
        	expenditure_item_id = X_exp_item_id;

	/* bug fix: 2798742 */
	select
		Incurred_by_person_id
	into
		l_person_id
	from
		pa_expenditures_all
	where   expenditure_id = l_expenditure_id;
	/* end of bug fix:2798742 */

    	l_denom_currency_code := get_denom_curr_code(l_transaction_source,
                                                     l_exp_type,
                                                     l_denom_cur_code,
                                                     l_acct_cur_code,
                                                     l_sys_link_func,
					             'SPLIT'   /* bug fix: 2798742 */
						     ,l_person_id
						     ,l_expenditure_item_date);

	/* End EFC bug2259454 changes */

    	FOR i IN 1..2 LOOP

      		IF ( i = 1 ) THEN

        		item_qty                 := X_item1_qty ;
        		item_raw_cost            := X_item1_raw_cost;
        		item_burden_cost         := X_item1_burden_cost;
        		item_bill_flag           := X_item1_bill_flag;
        		item_hold_flag           := X_item1_hold_flag;
        		item_receipt_curr_amt    := X_item1_receipt_curr_amt ;
        		item_denom_raw_cost      := X_item1_denom_raw_cost ;
        		item_denom_burdened_cost := X_item1_denom_burdened_cost;
        		item_acct_raw_cost       := X_item1_acct_raw_cost;
        		item_acct_burdened_cost  := X_item1_acct_burdened_cost;
        		item_project_raw_cost    := p_item1_project_raw_cost;
        		item_project_burdened_cost := p_item1_project_burden_cost;

      		ELSE

        		item_qty                 := X_item2_qty ;
        		item_raw_cost            := X_item2_raw_cost;
        		item_burden_cost         := X_item2_burden_cost;
        		item_bill_flag           := X_item2_bill_flag;
        		item_hold_flag           := X_item2_hold_flag;
        		item_receipt_curr_amt    := X_item2_receipt_curr_amt ;
        		item_denom_raw_cost      := X_item2_denom_raw_cost ;
        		item_denom_burdened_cost := X_item2_denom_burdened_cost;
        		item_acct_raw_cost       := X_item2_acct_raw_cost;
        		item_acct_burdened_cost  := X_item2_acct_burdened_cost;
        		item_project_raw_cost    := p_item2_project_raw_cost;
        		item_project_burdened_cost := p_item2_project_burden_cost;

      		END IF;

      		new_item_id := pa_utils.GetNextEiId;

		IF P_DEBUG_MODE  THEN
		   print_message('get_denom_curr_code: ' || 'calling insert into EI');
		END IF;

      		INSERT INTO pa_expenditure_items_all(
       			  expenditure_item_id
       			, task_id
       			, expenditure_type
       			, system_linkage_function
       			, expenditure_item_date
       			, expenditure_id
       			, override_to_organization_id
       			, last_update_date
       			, last_updated_by
       			, creation_date
       			, created_by
       			, last_update_login
       			, quantity
       			, revenue_distributed_flag
       			, bill_hold_flag
       			, billable_flag
       			, bill_rate_multiplier
       			, cost_distributed_flag
       			, raw_cost
       			, raw_cost_rate
       			, burden_cost
       			, burden_cost_rate                    /*1765164*/
       			, non_labor_resource
       			, organization_id
       			, transferred_from_exp_item_id
       			, attribute_category
       			, attribute1
       			, attribute2
       			, attribute3
       			, attribute4
       			, attribute5
       			, attribute6
       			, attribute7
       			, attribute8
       			, attribute9
       			, attribute10
       			, transaction_source
                        ,  orig_transaction_reference    /* Bug 2373450 */
       			, job_id
       			, org_id
       			, labor_cost_multiplier_name
       			, receipt_currency_amount
       			, receipt_currency_code
       			, receipt_exchange_rate
       			, denom_currency_code
      			, denom_raw_cost
       			, denom_burdened_cost
       			, acct_currency_code
       			, acct_rate_date
       			, acct_rate_type
       			, acct_exchange_rate
       			, acct_raw_cost
       			, acct_burdened_cost
       			, acct_exchange_rounding_limit
       			, project_currency_code
       			, project_rate_type
       			, project_rate_date
       			, project_exchange_rate
       			, cost_ind_compiled_set_id /* added for bug 1765164 */
		     /* For split, all the CC attributes are calculated again, following the
   		  	revenue/billing model */
       		     /* , cc_cross_charge_code
       			, cc_prvdr_organization_id
       			, cc_recvr_organization_id
       			, cc_rejection_code
       			, denom_tp_currency_code
       			, denom_transfer_price
       			, acct_tp_rate_type
       			, acct_tp_rate_date
       			, acct_tp_exchange_rate
       			, acct_transfer_price
       			, projacct_transfer_price
       			, cc_markup_base_code
       			, tp_base_amount
       			, cc_cross_charge_type
       			, recvr_org_id
       			, cc_bl_distributed_code
       			, cc_ic_processed_code
       			, tp_ind_compiled_set_id
       			, tp_bill_rate
       			, tp_bill_markup_percentage
       			, tp_schedule_line_percentage
       			, tp_rule_percentage  */
       			, recvr_org_id         /*Bug# 2028917*/
       			, assignment_id
       			, work_type_id
       			, projfunc_currency_code
       			, projfunc_cost_rate_type
       			, projfunc_cost_rate_date
       			, projfunc_cost_exchange_rate
       			, project_raw_cost
       			, project_burdened_cost
       		    /** , project_tp_rate_type
       			, project_tp_rate_date
       			, project_tp_exchange_rate
       			, project_transfer_price **/
       			, project_id
       			, tp_amt_type_code   /** added for bug 3117718 **/
                        , inventory_item_id -- Bug 4320459
                        , unit_of_measure -- Bug 4320459
                 /* R12 Changes - Start */
                        , document_header_id
                        , document_distribution_id
                        , document_line_number
                        , document_payment_id
                        , vendor_id
                        , document_type
                        , document_distribution_type
                 /* R12 Changes - End */
       		)
      		SELECT
      		        new_item_id                     -- expenditure_item_id
      		,       ei.task_id                      -- task_id
      		,       ei.expenditure_type             -- expenditure_type
      		,       ei.system_linkage_function      -- system_linkage_function
      		,       ei.expenditure_item_date        -- expenditure_item_date
      		,       ei.expenditure_id               -- expenditure_id
      		,       ei.override_to_organization_id  -- override_to_organization_id
      		,       sysdate                         -- last_update_date
      		,       X_user                          -- last_updated_by
      		,       sysdate                         -- creation_date
      		,       X_user                          -- created_by
      		,       X_login                         -- last_update_login
      		,       item_qty                        -- quantity
      		,       'N'                             -- revenue_distributed_flag
      		,       item_hold_flag                  -- bill_hold_flag
      		,       item_bill_flag                  -- billable_flag
      		,       ei.bill_rate_multiplier         -- bill_rate_multiplier
      		,       'N'                             -- cost_distributed_flag
      		,       item_raw_cost                   -- raw_cost
      		,       ei.raw_cost_rate                -- raw_cost_rate
      		,       item_burden_cost                -- burden_cost
      		,       ei.burden_cost_rate             -- burden_cost_rate /*1765164*/
      		,       ei.non_labor_resource           -- non_labor_resource
      		,       ei.organization_id              -- organization_id
      		,       ei.expenditure_item_id          -- adjusted_expenditure_item_id
      		,       ei.attribute_category           -- attribute_category
      		,       ei.attribute1                   -- attribute1
      		,       ei.attribute2                   -- attribute2
      		,       ei.attribute3                   -- attribute3
      		,       ei.attribute4                   -- attribute4
      		,       ei.attribute5                   -- attribute5
      		,       ei.attribute6                   -- attribute6
      		,       ei.attribute7                   -- attribute7
      		,       ei.attribute8                   -- attribute8
      		,       ei.attribute9                   -- attribute9
      		,       ei.attribute10                  -- attribute10
      		,       ei.transaction_source           -- transaction_source
                ,       decode(ei.transaction_source,'PTE TIME',NULL,
                        decode(ei.transaction_source,'PTE EXPENSE',NULL,
                        decode(ei.transaction_source,'ORACLE TIME AND LABOR',NULL,
                        decode(ei.transaction_source,'Oracle Self Service Time',NULL,
                              ei.orig_transaction_reference)))) orig_transaction_reference  /* Bug2373450 */
      		,       ei.job_id                       -- job_id
      		,       ei.org_id                       -- org_id
      		,       ei.labor_cost_multiplier_name   -- labor_cost_multiplier_name
      		,       item_receipt_curr_amt           -- receipt currency amount
      		,       ei.receipt_currency_code        -- receipt currency code
      		,       ei.receipt_exchange_rate        -- receipt exchange rate
      	         /***,       ei.denom_currency_code          -- denomination currency code **/
		,       l_denom_currency_code           -- denomiation currency code EFC bug2259454 changes
      		,       item_denom_raw_cost             -- denomination raw cost
      		,       item_denom_burdened_cost        -- denomination burdened cost
      		,       ei.acct_currency_code           -- accounting currency code
      		,       ei.acct_rate_date               -- accounting rate date
      		,       ei.acct_rate_type               -- accounting rate type
      		,       ei.acct_exchange_rate           -- accounting exchange rate
      		,       item_acct_raw_cost              -- accounting raw cost
      		,       item_acct_burdened_cost         -- accounting burdened cost
      		,       ei.acct_exchange_rounding_limit -- accounting exchange rounding limit
      		,       ei.project_currency_code        -- project currency code
      		,       ei.project_rate_type            -- project rate type
      		,       ei.project_rate_date            -- project rate date
      		,       ei.project_exchange_rate        -- accounting exchange rate
      		,       ei.cost_ind_compiled_set_id     -- cost compiled set id added for 1765164
    	/*      ,  	ei.cc_cross_charge_code          -- cc_cross_charge_code
       		,  	ei.cc_prvdr_organization_id      -- cc_prvdr_organization_id
       		,  	ei.cc_recvr_organization_id      -- cc_recvr_organization_id
       		,  	ei.cc_rejection_code             -- cc_rejection_code
       		,  	ei.denom_tp_currency_code        -- denom_tp_currency_code
       		,  	ei.denom_transfer_price          -- denom_transfer_price
       		,  	ei.acct_tp_rate_type             -- acct_tp_rate_type
       		, 	ei.acct_tp_rate_date             -- acct_tp_rate_date
       		,  	ei.acct_tp_exchange_rate         -- acct_tp_exchange_rate
       		,  	ei.acct_transfer_price           -- acct_transfer_price
       		,  	ei.projacct_transfer_price        -- projacct_transfer_price
       		,  	ei.cc_markup_base_code           -- cc_markup_base_code
       		,  	ei.tp_base_amount                -- tp_base_amount
       		,  	ei.cc_cross_charge_type          -- cc_cross_charge_type
       		,  	ei.recvr_org_id                  -- recvr_org_id
       		,  	ei.cc_bl_distributed_code        -- cc_bl_distributed_code
       		,  	ei.cc_ic_processed_code          -- cc_ic_processed_code
       		,  	ei.tp_ind_compiled_set_id        -- tp_ind_compiled_set_id
       		,  	ei.tp_bill_rate                  -- tp_bill_rate
       		,  	ei.tp_bill_markup_percentage     -- tp_bill_markup_percentage
       		,  	ei.tp_schedule_line_percentage   -- tp_schedule_line_percentage
      	 	,  	ei.tp_rule_percentage            -- tp_rule_percentage */
       		,  	ei.recvr_org_id                  -- recvr_org_id       /*Bug# 2028917*/
       		, 	assignment_id
       		, 	work_type_id
       		, 	projfunc_currency_code
       		, 	projfunc_cost_rate_type
       		, 	projfunc_cost_rate_date
       		, 	projfunc_cost_exchange_rate
       		, 	item_project_raw_cost
       		, 	item_project_burdened_cost
      	/* 	, 	project_tp_rate_type
       		, 	project_tp_rate_date
       		, 	project_tp_exchange_rate
       		, 	project_transfer_price **/
       		, 	project_id
 		,       ei.tp_amt_type_code   /** added for bug 3117718 **/
                ,       ei.inventory_item_id -- Bug 4320459
                ,       ei.unit_of_measure   -- Bug 4320459
         /* R12 Changes - Start */
                ,       ei.document_header_id
                ,       ei.document_distribution_id
                ,       ei.document_line_number
                ,       ei.document_payment_id
                ,       ei.vendor_id
                ,       ei.document_type
                ,       ei.document_distribution_type
         /* R12 Changes - End */

      		FROM
              		pa_expenditure_items_all ei
      		WHERE
              		ei.expenditure_item_id = X_exp_item_id;

		IF P_DEBUG_MODE  THEN
		   print_message('get_denom_curr_code: ' || 'Num of rows inserted in split['||sql%rowcount||']' );
		END IF;

      		IF ( item_comment IS NOT NULL ) THEN

        	pa_transactions.InsItemComment(
					X_ei_id       =>	new_item_id
                                      , X_ei_comment  =>	item_comment
                                      , X_user        =>	X_user
                                      , X_login       =>	X_login
                                      , X_status      =>	temp_status );

        	CheckStatus( status_indicator => temp_status );

      	END IF;

      	InsAuditRec(
		   X_exp_item_id       =>	new_item_id
                 , X_adj_activity      =>	'SPLIT DESTINATION'
                 , X_module            =>	X_module
                 , X_user              =>	X_user
                 , X_login             =>	X_login
                 , X_status            =>	temp_status );

      	CheckStatus( status_indicator => temp_status );

    END LOOP;

    IF P_DEBUG_MODE  THEN
       print_message('get_denom_curr_code: ' || 'end of split api');
    END IF;

    X_status := 0;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      IF P_DEBUG_MODE  THEN
         print_message('get_denom_curr_code: ' || 'status ='||X_status);
      END IF;
      RAISE;

  END  Split;


-- ========================================================================
-- PROCEDURE Transfer
-- ========================================================================

  PROCEDURE Transfer ( ItemsIdTab              IN  pa_utils.IdTabTyp
                     , X_dest_prj_id           IN  NUMBER
                     , X_dest_task_id          IN  NUMBER
		             , X_project_currency_code IN  VARCHAR2
		             , X_project_rate_type     IN  VARCHAR2
		             , X_project_rate_date     IN  DATE
		             , X_project_exchange_rate IN  NUMBER
                     , X_user                  IN  NUMBER
                     , X_login                 IN  NUMBER
                     , X_module                IN  VARCHAR2
                     , X_adjust_level          IN  VARCHAR2
                     , rows                    IN  BINARY_INTEGER
                     , X_num_processed         OUT NOCOPY NUMBER
                     , X_num_rejected          OUT NOCOPY NUMBER
                     , X_outcome               OUT NOCOPY VARCHAR2
		             , X_msg_application       OUT NOCOPY VARCHAR2
		             , X_msg_type	       OUT NOCOPY VARCHAR2
		             , X_msg_token1 	       OUT NOCOPY VARCHAR2
		             , X_msg_token2	       OUT NOCOPY VARCHAR2
		             , X_msg_token3	       OUT NOCOPY VARCHAR2
		             , X_msg_count	       OUT NOCOPY Number
                     , p_projfunc_currency_code IN VARCHAR2
                     , p_projfunc_cost_rate_type     IN VARCHAR2
                     , p_projfunc_cost_rate_date     IN DATE
                     , p_projfunc_cost_exchg_rate IN NUMBER
                     , p_assignment_id         IN  NUMBER
                     , p_work_type_id          IN  NUMBER	) IS

    dummy                  NUMBER DEFAULT 0;
    temp_num_processed     NUMBER DEFAULT 0;
    temp_num_rejected      NUMBER DEFAULT 0;
    temp_status            NUMBER DEFAULT NULL;
    temp_outcome           VARCHAR2(30) DEFAULT NULL;
    temp_stage             NUMBER;
    temp_msg_application   VARCHAR2(30)  :='PA';
    temp_msg_type	   VARCHAR2(1)   :='E';
    temp_msg_token1	   VARCHAR2(240) :='';
    temp_msg_token2	   VARCHAR2(240) :='';
    temp_msg_token3	   VARCHAR2(240) :='';
    temp_msg_count	   NUMBER ;

    l_project_rate_date     DATE         := X_project_rate_date;
    l_project_rate_type     VARCHAR2(30) := X_project_rate_type;
    l_project_exchange_rate NUMBER       := X_project_exchange_rate;

    l_projfunc_cost_rate_date     DATE         := p_projfunc_cost_rate_date;
    l_projfunc_cost_rate_type     VARCHAR2(30) := p_projfunc_cost_rate_type;
    l_projfunc_cost_exchg_rate    NUMBER       := p_projfunc_cost_exchg_rate;
    l_denom_currency_code         VARCHAR2(30) := NULL;

    l_assignment_id         NUMBER;
    l_assignment_name       VARCHAR2(80);
    l_work_type_id          NUMBER;
    l_work_type_name        VARCHAR2(80);
    l_tp_amt_type_code      VARCHAR2(80);
    l_error_status          VARCHAR2(80);
    l_error_message_code    VARCHAR2(800);
    l_dest_lcm             VARCHAR2(20) DEFAULT NULL;
    l_acct_rate_date       date;
    l_acct_rate_type       varchar2(100);
    l_acct_exchange_rate   number;
    l_project_currency_code varchar2(100) := x_project_currency_code;
    l_denom_burdened_cost   NUMBER; --Added for bug 6031129


/* changing the cursor select below for the raw_cost and burden_cost
  to make it null always. The costing program would fill in the raw cost
  with the acct_raw_cost for VI and ER when the curr codes are same */

    CURSOR Items ( X_expenditure_item_id IN NUMBER ) IS
      SELECT
          ei.billable_flag
       ,  ei.bill_hold_flag
       ,  NULL raw_cost
       ,  decode(ei.system_linkage_function, 'VI',
                 ei2.raw_cost_rate,
                 decode(ts.costed_flag,
			'Y', ei2.raw_cost_rate,
			NULL)) raw_cost_rate
       ,  NULL burden_cost
          /*,  decode( ei.system_linkage_function, 'VI',
                       ei.override_to_organization_id, NULL ) override_to_org */
           /* Modified For Bug2235662 */
       ,   decode(ei.system_linkage_function,
		  'VI',ei.override_to_organization_id,
		  'ER',decode(ei.transaction_source,
			      null,null,
			      ei.override_to_organization_id),
		  null) override_to_org
       ,   ei.organization_id   nl_resource_org_id
       ,   ei.transaction_source
       ,   ei.vendor_id vendor_id /* R12 Changes - removed reference to cdl.system_reference1 */
       ,   ei.attribute_category
       ,   ei.attribute1
       ,   ei.attribute2
       ,   ei.attribute3
       ,   ei.attribute4
       ,   ei.attribute5
       ,   ei.attribute6
       ,   ei.attribute7
       ,   ei.attribute8
       ,   ei.attribute9
       ,   ei.attribute10
       ,   ec.expenditure_comment
       ,   decode(ei.system_linkage_function, 'VI',
           NVL(ei.override_to_organization_id,e.incurred_by_organization_id), /*Modified for bug 7422380*/
             e.incurred_by_organization_id )   inc_by_org_id
       ,   e.incurred_by_person_id inc_by_person_id
       ,   ei.expenditure_item_date
       ,   decode(ei.transaction_source,'PTE TIME',NULL,
           decode(ei.transaction_source,'PTE EXPENSE',NULL,
           decode(ei.transaction_source,'ORACLE TIME AND LABOR',NULL,
           decode(ei.transaction_source,'Oracle Self Service Time',NULL,
                 ei.orig_transaction_reference)))) orig_transaction_reference
       ,   ei.expenditure_type
       ,   ei.system_linkage_function
       ,   ei.non_labor_resource
       ,   ei.quantity
       ,   e.expenditure_id
       ,   ei.expenditure_item_id transferred_from_exp_item_id
       ,   ei.adjusted_expenditure_item_id expenditure_item_id
       ,   ei.job_id
       ,   ei.org_id
       ,   ei.burden_sum_dest_run_id
       ,   ei.receipt_currency_amount
       ,   ei.receipt_currency_code
       ,   ei.receipt_exchange_rate
       ,   ei.denom_currency_code
       ,  decode(ei.system_linkage_function, 'VI', ei2.denom_raw_cost,
          'ER', ei2.denom_raw_cost,decode( ts.costed_flag, 'Y',
           ei2.denom_raw_cost, NULL)) denom_raw_cost
       ,  decode(ei.system_linkage_function ,'BTC',ei.denom_burdened_cost,
	         decode( ts.allow_burden_flag, 'Y',decode(getprojburdenflag(ei.project_id),'N',NULL,
             ei2.denom_burdened_cost), NULL)) denom_burdened_cost  /*Bug# 5874347*/  /*Bug 8371013: */
       ,   ei.acct_currency_code
       ,   decode(ei.system_linkage_function,'VI',ei2.acct_rate_date,
           'ER',ei2.acct_rate_date, decode(ts.gl_accounted_flag,'Y',
        	ei2.acct_rate_date,decode(ei.acct_rate_type,'User',ei.acct_rate_date,NULL))) acct_rate_date --Bug#3787213
       ,   decode(ei.system_linkage_function,'VI',ei2.acct_rate_type,
        	'ER',ei2.acct_rate_type, decode(ts.gl_accounted_flag,'Y',
		ei2.acct_rate_type,decode(ei.acct_rate_type,'User',ei.acct_rate_type,NULL))) acct_rate_type  --Bug#3787213
       ,   decode(ei.system_linkage_function,'VI',ei2.acct_exchange_rate,
		'ER',ei2.acct_exchange_rate, decode(ts.gl_accounted_flag,'Y',
		ei2.acct_exchange_rate,decode(ei.acct_rate_type,'User',ei.acct_exchange_rate,NULL))) acct_exchange_rate  --Bug#3787213
       ,  decode(ei.system_linkage_function, 'VI', ei2.acct_raw_cost,
		'ER', ei2.acct_raw_cost, decode( ts.gl_accounted_flag, 'Y',
		ei2.acct_raw_cost, NULL)) acct_raw_cost
       ,   ei.acct_exchange_rounding_limit
       ,   decode(ei.system_linkage_function, 'VI','Y', 'ER','Y',
        	nvl(ts.gl_accounted_flag,'N')) gl_accounted_flag
       /* ,  ei.cc_cross_charge_code          -- cc_cross_charge_code
       ,  ei.cc_prvdr_organization_id      -- cc_prvdr_organization_id
       ,  ei.cc_recvr_organization_id      -- cc_recvr_organization_id
       ,  ei.cc_rejection_code             -- cc_rejection_code
       ,  ei.denom_tp_currency_code        -- denom_tp_currency_code
       ,  ei.denom_transfer_price          -- denom_transfer_price
       ,  ei.acct_tp_rate_type             -- acct_tp_rate_type
       ,  ei.acct_tp_rate_date             -- acct_tp_rate_date
       ,  ei.acct_tp_exchange_rate         -- acct_tp_exchange_rate
       ,  ei.acct_transfer_price           -- acct_transfer_price
       ,  ei.projacct_transfer_price        -- projacct_transfer_price
       ,  ei.cc_markup_base_code           -- cc_markup_base_code
       ,  ei.tp_base_amount                -- tp_base_amount
       ,  ei.cc_cross_charge_type          -- cc_cross_charge_type
       ,  ei.recvr_org_id                  -- recvr_org_id
       ,  ei.cc_bl_distributed_code        -- cc_bl_distributed_code
       ,  ei.cc_ic_processed_code          -- cc_ic_processed_code
       ,  ei.tp_ind_compiled_set_id        -- tp_ind_compiled_set_id
       ,  ei.tp_bill_rate                  -- tp_bill_rate
       ,  ei.tp_bill_markup_percentage     -- tp_bill_markup_percentage
       ,  ei.tp_schedule_line_percentage   -- tp_schedule_line_percentage
       ,  ei.tp_rule_percentage            -- tp_rule_percentage
         */
       ,  NULL  project_raw_cost
       ,  NULL  project_burdened_cost
       ,  ei.assignment_id
       ,  ei.work_type_id
       ,  ei.project_rate_type
       ,  ei.project_rate_date
       ,  ei.project_exchange_rate
       ,  e.person_type -- Fix for bug : 3681318
       ,  decode(ei.system_linkage_function,'BTC',ei.acct_burdened_cost,null) acct_burdened_cost /* bug 3669152 */
       ,  ei.project_currency_code        --Start of Bug#3787213. 5 Columns added
       ,  ei.projfunc_currency_code
       ,  ei.projfunc_cost_rate_type
       ,  ei.projfunc_cost_rate_date
       ,  ei.projfunc_cost_exchange_rate  --End of Bug#3787213.
       ,  ei.inventory_item_id -- Bug 4320459
       ,  ei.unit_of_measure   -- Bug 4320459
/* R12 Changes -Start */
       ,  ei.document_header_id
       ,  ei.document_distribution_id
       ,  ei.document_line_number
       ,  ei.document_payment_id
       ,  ei.vendor_id ei_vendor_id
       ,  ei.document_type
       ,  ei.document_distribution_type
/* R12 Changes - End */
     FROM
           pa_expenditures_all e
       ,   pa_expenditure_items_all ei
       ,   pa_expenditure_items_all ei2
       ,   pa_transaction_sources ts
       ,   pa_expenditure_comments ec
/* R12 changes - Removed table pa_cost_distribution_lines */
    WHERE
           e.expenditure_id           = ei.expenditure_id
      AND  ei.expenditure_item_id     = ei2.expenditure_item_id
/* R12 Changes - Removed join conditions for pa_cost_distribution_lines table */
      AND  ei2.transaction_source     = ts.transaction_source (+)
      AND  ei.expenditure_item_id     = X_expenditure_item_id
      AND  ec.expenditure_item_id  (+)= ei.expenditure_item_id ;

/* Commented the following code as part of Bug#2291180 -- Start
  -- EFC bug2259454 changes
  Function get_denom_curr_code2 (l_exp_type in varchar2,
		                 l_denom_currency_code in varchar2,
		                 l_acct_currency_code in varchar2,
		                 l_system_linkage_function in varchar2) return varchar2 is

     l_cost_rate_flag varchar2(30);
     l_return varchar2(30);

  Begin

	If l_system_linkage_function in ('ST','OT') Then
		If l_acct_currency_code = l_denom_currency_code Then
			l_return := l_denom_currency_code;
		Else
			l_return := pa_currency.get_currency_code;
		End If;
	Else
        	select cost_rate_flag
        	into l_cost_rate_flag
        	from pa_expenditure_types
        	where expenditure_type = l_exp_type;

		If l_cost_rate_flag = 'Y' Then
			If l_acct_currency_code = l_denom_currency_code Then
				l_return := l_denom_currency_code;
			Else
				l_return := pa_currency.get_currency_code;
			End If;
		Else
                      	l_return := l_denom_currency_code;
		End If;
	End If;

	return l_return;

  End get_denom_curr_code2;
 Commented the above code as part of Bug#2291180 -- End */

-- Start of Transfer main PL/SQL block

  BEGIN

    IF P_DEBUG_MODE  THEN
       print_message('get_denom_curr_code: ' || 'inside Transfer api');
    END IF;
    l_dest_lcm  := pa_utils2.GetLaborCostMultiplier(X_dest_task_id);
    FOR i IN 1..rows LOOP

      FOR  EiRec  IN Items( ItemsIdTab(i) )  LOOP

	/** derive the destination project currency code based on destination task and destination project **/
	--IF X_project_currency_code is NULL then
	    BEGIN
		SELECT decode(project_currency_code,NULL,projfunc_currency_code,project_currency_code)
		INTO l_project_currency_code
		FROM pa_projects_all
		WHERE project_id = x_dest_prj_id;
	    EXCEPTION
		WHEN NO_DATA_FOUND then
		        Raise;

		WHEN OTHERS  then
			Raise;
	    END;

	--End if;

      /* BEGIN
        --Added this block for bug 5759574
		--Reverted this check for bug 7454045

         SELECT w.name
         INTO l_work_type_name
         FROM pa_work_types_v w
         WHERE w.work_type_id = eirec.work_type_id;

       EXCEPTION
         WHEN others THEN
         NULL;
       END; */

	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'calling get work type assignment api');
	END IF;
	/** derive work type and assignment for the destination task , project **/
 	Pa_Utils4.Get_Work_Assignment (
	    p_person_id  	     => EiRec.inc_by_person_id
	   ,p_project_id 	     => X_dest_prj_id
	   ,p_task_id    	     => X_dest_task_id
	   ,p_ei_date    	     => EiRec.expenditure_item_date
	   ,p_system_linkage 	 => EiRec.system_linkage_function
	   ,x_assignment_id  	 => l_assignment_id
       ,x_assignment_name 	 => l_assignment_name
       ,x_work_type_id    	 => l_work_type_id
       ,x_work_type_name  	 => l_work_type_name
	   ,x_tp_amt_type_code 	 => l_tp_amt_type_code
       ,x_return_status    	 => l_error_status
       ,x_error_message_code => l_error_message_code);

	-- EFC bug2259454 change
	l_denom_currency_code := get_denom_curr_code (EiRec.transaction_source,
                                                  EiRec.expenditure_type,
						                          EiRec.denom_currency_code,
                                                  EiRec.acct_currency_code,
						                          EiRec.system_linkage_function);

	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'after get work assign l_assignment_id['||l_assignment_id||
	              ']l_assignment_name['||l_assignment_name||']l_work_type_id ['||l_work_type_id||
		      ']l_work_type_name['||l_work_type_name||']x_tp_amt_type_code['||l_tp_amt_type_code|| ']' );
	END IF;
	l_acct_rate_date           := EiRec.acct_rate_date;
	l_acct_rate_type           := EiRec.acct_rate_type;
	l_acct_exchange_rate       := EiRec.acct_exchange_rate;
/*Bug#3787213. Added if condition for validating the source and destination currency code for rate type 'User'
If source and destination currencies are same for User rate_type then we are copying the rate_type,
rate_date, and exchange_rate.
*/
	IF EiRec.project_currency_code = l_project_currency_code
	   and EiRec.projfunc_currency_code = p_projfunc_currency_code
	   and l_acct_rate_type = 'User' THEN

		l_project_rate_type        := EiRec.project_rate_type;
		l_project_rate_date        := EiRec.project_rate_date;
		l_project_exchange_rate    := EiRec.project_exchange_rate;
		l_projfunc_cost_rate_type  := EiRec.projfunc_cost_rate_type;
		l_projfunc_cost_rate_date  := EiRec.projfunc_cost_rate_date;
		l_projfunc_cost_exchg_rate := EiRec.projfunc_cost_exchange_rate;

	ELSE

		pa_multi_currency_txn.get_currency_attributes (
		   P_TASK_ID               	=> X_dest_task_id,
		   P_EI_DATE               	=> Eirec.expenditure_item_date,
		   P_CALLING_MODULE        	=> 'TRANSFER',
	--     P_DENOM_CURR_CODE       	=> EiRec.denom_currency_code,
		   P_DENOM_CURR_CODE        => l_denom_currency_code,  -- EFC bug2259454 change
		   P_ACCT_CURR_CODE        	=> EiRec.acct_currency_code,
		   P_ACCOUNTED_FLAG        	=> EiRec.gl_accounted_flag,
		   x_ACCT_RATE_DATE        	=> l_acct_rate_date,
		   x_ACCT_RATE_TYPE        	=> l_acct_rate_type,
		   x_ACCT_EXCH_RATE        	=> l_acct_exchange_rate,
		   P_project_curr_code     	=> l_project_currency_code,
		   x_project_rate_type     	=> l_project_rate_type,
		   x_project_rate_date     	=> l_project_rate_date,
		   x_project_exch_rate     	=> l_project_exchange_rate,
		   P_PROJFUNC_CURR_CODE    	=> p_projfunc_currency_code,
		   x_PROJFUNC_COST_RATE_TYPE => l_projfunc_cost_rate_type,
		   x_PROJFUNC_COST_RATE_DATE => l_projfunc_cost_rate_date,
		   x_PROJFUNC_COST_EXCH_RATE => l_projfunc_cost_exchg_rate,
		   P_SYSTEM_LINKAGE         => EiRec.system_linkage_function,
		   x_status                	=> temp_outcome,
		   x_stage                 	=> temp_stage);
	END IF;

	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'after multi currency p_projfunc_currency_code['||p_projfunc_currency_code||
	              ']l_projfunc_cost_rate_type['||l_projfunc_cost_rate_type||
		      ']l_projfunc_cost_rate_date['||l_projfunc_cost_rate_date||
		      ']l_projfunc_cost_exchg_rate['||l_projfunc_cost_exchg_rate||
		      ']l_project_currency_code['||l_project_currency_code||
		      ']l_project_rate_type ['||l_project_rate_type||']l_project_rate_date ['||l_project_rate_date||
		      ']l_project_exchange_rate['||l_project_exchange_rate||']' );
	END IF;


	IF ( temp_outcome IS NOT NULL ) THEN

		IF ( X_adjust_level = 'I' ) THEN
		 	X_outcome := temp_outcome;
		  	RETURN;
		ELSE
			temp_num_rejected := temp_num_rejected + 1;
	  	    /* R12 Changes Start */
	        InsAuditRec( ItemsIdTab(i)
               	           , 'TRANSFER DESTINATION'
                  	   , X_module
	                   , X_user
          	           , X_login
                  	   , temp_status
	                   , G_REQUEST_ID
          	           , G_PROGRAM_ID
                  	   , G_PROG_APPL_ID
	                   , sysdate
          	           , temp_outcome);
	                CheckStatus(temp_status);
	  	    /* R12 Changes End */
          	temp_outcome := NULL;
		END IF;

	ELSE

      		EiRec.expenditure_item_id := pa_utils.GetNextEiId;
      		pa_transactions_pub.validate_transaction(
                       X_project_id           => X_dest_prj_id
                     , X_task_id 	      => X_dest_task_id
                     , X_ei_date 	      => EiRec.expenditure_item_date
                     , X_expenditure_type     => EiRec.expenditure_type
                     , X_non_labor_resource   => EiRec.non_labor_resource
                     , X_person_id 	      => EiRec.inc_by_person_id
                     , X_quantity 	      => EiRec.quantity
--                   , X_denom_currency_code  => EiRec.denom_currency_code
		             , X_denom_currency_code  => l_denom_currency_code  -- EFC bug2259454 change
		             , X_acct_currency_code   => EiRec.Acct_currency_code
		             , X_denom_raw_cost       => EiRec.denom_raw_cost
		             , X_acct_raw_cost 	      => EiRec.acct_raw_cost
		             , X_acct_rate_type       => l_acct_rate_type        --Bug#3787213. Eirec.acct_rate_type
		             , X_acct_rate_date       => l_acct_rate_date        --Bug#3787213. Eirec.acct_rate_date
		             , X_acct_exchange_rate   => l_acct_exchange_rate    --Bug#3787213. Eirec.acct_exchange_rate
                     , X_transfer_ei 	      => EiRec.transferred_from_exp_item_id
                     , X_incurred_by_org_id   => EiRec.inc_by_org_id
                     , X_nl_resource_org_id   => EiRec.nl_resource_org_id
                     , X_transaction_source   => EiRec.transaction_source
                     , X_calling_module       => X_module
                     , X_vendor_id 	      => EiRec.vendor_id
                     , X_entered_by_user_id   => X_user
                     , X_attribute_category   => EiRec.attribute_category
                     , X_attribute1 	      => EiRec.attribute1
                     , X_attribute2 	      => EiRec.attribute2
                     , X_attribute3 	      => EiRec.attribute3
                     , X_attribute4 	      => EiRec.attribute4
                     , X_attribute5 	      => EiRec.attribute5
                     , X_attribute6 	      => EiRec.attribute6
                     , X_attribute7 	      => EiRec.attribute7
                     , X_attribute8 	      => EiRec.attribute8
                     , X_attribute9 	      => EiRec.attribute9
                     , X_attribute10 	      => EiRec.attribute10
		             , X_attribute11          => ''
		             , X_attribute12 	      => ''
		             , X_attribute13 	      => ''
		             , X_attribute14 	      => ''
		             , X_attribute15 	      => ''
		             , X_msg_application      => temp_msg_application
		             , X_msg_type 	      => temp_msg_type
		             , X_msg_token1 	      => temp_msg_token1
		             , X_msg_token2 	      => temp_msg_token2
		             , X_msg_token3 	      => temp_msg_token3
		             , X_msg_count 	      => temp_msg_count
                     , X_msg_data 	      => temp_outcome
                     , X_billable_flag        => EiRec.billable_flag
            	     , p_projfunc_currency_code => p_projfunc_currency_code
            	     , p_projfunc_cost_rate_type => l_projfunc_cost_rate_type
            	     , p_projfunc_cost_rate_date => l_projfunc_cost_rate_date
            	     , p_projfunc_cost_exchg_rate =>l_projfunc_cost_exchg_rate
            	     , p_assignment_id          => l_assignment_id
            	     , p_work_type_id           => l_work_type_id
		             , p_sys_link_function      => EiRec.system_linkage_function
                     , p_person_type           =>  EiRec.person_type );   -- Fix for bug : 3681318

            /* Start of Bug 2648550 */
		    l_assignment_id := PATC.G_OVERIDE_ASSIGNMENT_ID;
		    l_work_type_id := PATC.G_OVERIDE_WORK_TYPE_ID;
		    l_tp_amt_type_code := PATC.G_OVERIDE_TP_AMT_TYPE_CODE;
            /* End of Bug 2648550 */

		    IF ( temp_outcome IS NOT NULL AND ( temp_msg_type = 'E' ) ) THEN /* Added msg_type check for Bug 4906816 */
			/*Changes for 7371988 Starts here*/

        		IF ( X_adjust_level = 'I' ) THEN
          			X_outcome         := temp_outcome;
			 	    X_msg_application := temp_msg_application;
			 	    X_msg_type        := temp_msg_type;
			 	    X_msg_token1      := temp_msg_token1;
			 	    X_msg_token2      := temp_msg_token2;
			 	    X_msg_token3      := temp_msg_token3;
			 	    X_msg_count       := temp_msg_count;
          			RETURN;
				ELSE
          			temp_num_rejected := temp_num_rejected + 1;
          			temp_outcome      := NULL;
        		END IF;

			ELSE

		/* Added for Bug 4906816 */
				IF ( ( temp_outcome IS NOT NULL ) AND ( temp_msg_type = 'W' ) ) THEN
					IF ( X_adjust_level = 'I' ) THEN
					X_outcome         := temp_outcome;
					X_msg_application := temp_msg_application;
					X_msg_type        := temp_msg_type;
					X_msg_token1      := temp_msg_token1;
					X_msg_token2      := temp_msg_token2;
					X_msg_token3      := temp_msg_token3;
					X_msg_count       := temp_msg_count;
					END IF;
				END IF;

          			--temp_num_rejected := temp_num_rejected + 1;
		  	        /* R12 Changes Start */
		            InsAuditRec( ItemsIdTab(i)
	            	               , 'TRANSFER DESTINATION'
	                  	       , X_module
		                       , X_user
	          	               , X_login
        	          	       , temp_status
	        	               , G_REQUEST_ID
          	        	       , G_PROGRAM_ID
                  	               , G_PROG_APPL_ID
		                       , sysdate
        	  	               , temp_outcome);
	        	    CheckStatus(temp_status);
		  	        /* R12 Changes End */
          			temp_outcome      := NULL;

        		--END IF;

		    --ELSE
/*Changes for 7371988 ends here*/
      			temp_num_processed := temp_num_processed + 1;

                    if ( EiRec.transferred_from_exp_item_id is not null and
                         EiRec.system_linkage_function ='BTC' ) then    /* Bug 8372560 */

                        l_denom_burdened_cost := EiRec.denom_burdened_cost;
                    else

                        select decode(getprojburdenflag(X_dest_prj_id),   -- Bug#Bug6031129
                                          'N',null,EiRec.denom_burdened_cost)
                            into  l_denom_burdened_cost
                            from dual;
                    end if;

			    /* NO IC Changes required. A transfer is considered a new txn
			       For new txns the Cross Charge attributes are populated by
			       IC processes.
			    */
      			pa_transactions.LoadEi(
                                    X_expenditure_item_id     =>	EiRec.expenditure_item_id
                                   ,X_expenditure_id          =>	EiRec.expenditure_id
                                   ,X_expenditure_item_date   =>	EiRec.expenditure_item_date
                                   ,X_project_id              =>	X_dest_prj_id  --NULL
                                   ,X_task_id                 =>	X_dest_task_id
                                   ,X_expenditure_type        =>	EiRec.expenditure_type
                                   ,X_non_labor_resource      =>	EiRec.non_labor_resource
                                   ,X_nl_resource_org_id      =>	EiRec.nl_resource_org_id
                                   ,X_quantity                =>	EiRec.quantity
                                   ,X_raw_cost                =>        EiRec.raw_cost
                                   ,X_raw_cost_rate           =>	EiRec.raw_cost_rate
                                   ,X_override_to_org_id      =>	EiRec.override_to_org
                                   ,X_billable_flag           =>	EiRec.billable_flag
                                   ,X_bill_hold_flag          =>	EiRec.bill_hold_flag
                                   ,X_orig_transaction_ref    =>	EiRec.orig_transaction_reference
                                   ,X_transferred_from_ei     =>	EiRec.transferred_from_exp_item_id
                                   ,X_adj_expend_item_id      =>	to_number( NULL )
                                   ,X_attribute_category      =>	EiRec.attribute_category
                                   ,X_attribute1              =>	EiRec.attribute1
                                   ,X_attribute2              =>	EiRec.attribute2
                                   ,X_attribute3              =>	EiRec.attribute3
                                   ,X_attribute4              =>	EiRec.attribute4
                                   ,X_attribute5              =>	EiRec.attribute5
                                   ,X_attribute6              =>	EiRec.attribute6
                                   ,X_attribute7              =>	EiRec.attribute7
                                   ,X_attribute8              =>	EiRec.attribute8
                                   ,X_attribute9              =>	EiRec.attribute9
                                   ,X_attribute10             =>	EiRec.attribute10
                                   ,X_ei_comment              =>	EiRec.expenditure_comment
                                   ,X_transaction_source      =>	EiRec.transaction_source
                                   ,X_source_exp_item_id      =>	to_number( NULL )
                                   ,i                         =>	temp_num_processed
                                   ,X_job_id                  =>	EiRec.job_id
                                   ,X_org_id                  =>	EiRec.org_id
                                   ,X_labor_cost_multiplier_name =>     l_dest_lcm
                                   ,X_drccid                  =>	NULL
                                   ,X_crccid                  =>	NULL
                                   ,X_cdlsr1                  =>	NULL
                                   ,X_cdlsr2                  =>	NULL
                                   ,X_cdlsr3                  =>	NULL
                                   ,X_gldate                  =>	NULL
                                   ,X_bcost                   =>	NULL  /* Bug#1263399 */
                                   ,X_bcostrate               =>	NULL
                                   ,X_etypeclass              =>	EiRec.system_linkage_function
                                   ,X_burden_sum_dest_run_id  =>	EiRec.burden_sum_dest_run_id
                                   ,X_burden_compile_set_id   =>	NULL
                                   ,X_receipt_currency_amount =>	EiRec.receipt_currency_amount
                                   ,X_receipt_currency_code   =>	EiRec.receipt_currency_code
                                   ,X_receipt_exchange_rate   =>	EiRec.receipt_exchange_rate
                                   -- ,X_denom_currency_code     =>	EiRec.denom_currency_code
				                   ,X_denom_currency_code     =>        l_denom_currency_code -- EFC bug2259454 change
                                   ,X_denom_raw_cost          =>	EiRec.denom_raw_cost
                                   ,X_denom_burdened_cost     =>	l_denom_burdened_cost  -- Bug#6031129
                                   ,X_acct_currency_code      =>	EiRec.acct_currency_code
                                   ,X_acct_rate_date          =>	l_acct_rate_date     --Bug#3787213. Eirec.acct_rate_date
                                   ,X_acct_rate_type          =>	l_acct_rate_type     --Bug#3787213. Eirec.acct_rate_type
                                   ,X_acct_exchange_rate      =>	l_acct_exchange_rate --Bug#3787213. Eirec.acct_exchange_rate
                                   ,X_acct_raw_cost           =>	EiRec.acct_raw_cost
                                   ,X_acct_burdened_cost      =>        EiRec.acct_burdened_cost /* bug 3669152 */
                                   ,X_acct_exchange_rounding_limit  =>	EiRec.acct_exchange_rounding_limit
                                   ,X_project_currency_code   =>	l_project_currency_code
                                   ,X_project_rate_date       =>	l_project_rate_date
                                   ,X_project_rate_type       =>	l_project_rate_type
                                   ,X_project_exchange_rate   =>	l_project_exchange_rate
                   		           , p_assignment_id                =>  l_assignment_id
                   		           , p_work_type_id                 =>  l_work_type_id
                   		           , p_projfunc_currency_code       =>  p_projfunc_currency_code
                   		           , p_projfunc_cost_rate_date      =>  l_projfunc_cost_rate_date
                   		           , p_projfunc_cost_rate_type      =>  l_projfunc_cost_rate_type
                   		           , p_projfunc_cost_exchange_rate  =>  l_projfunc_cost_exchg_rate
                   		           , p_project_raw_cost             =>  EiRec.project_raw_cost
                   		           , p_project_burdened_cost        =>  EiRec.project_burdened_cost
				                   , p_tp_amt_type_code             =>  l_tp_amt_type_code
                                   , p_Inventory_Item_Id      =>       EiRec.inventory_item_id -- Bug 4320459
                                   , p_Unit_Of_Measure        =>       EiRec.unit_of_measure -- Bug 4320459
                 /* R12 Changes - Start */
 		                  , p_document_header_id      =>       EiRec.document_header_id
     		                  , p_document_distribution_id =>      EiRec.document_distribution_id
		                  , p_document_line_number    =>       EiRec.document_line_number
		                  , p_document_payment_id     =>       EiRec.document_payment_id
		                  , p_vendor_id               =>       EiRec.vendor_id
		                  , p_document_type           =>       EiRec.document_type
		                  , p_document_distribution_type =>    EiRec.document_distribution_type
                 /* R12 Changes - End */
                                  ) ;

		END IF; -- End temp_outcome is not null for get_status

	END IF; -- End temp_outcome is not null for get_currency_attributes

    END LOOP;

  END LOOP;

  pa_transactions.InsItems( X_user                =>	X_user
                            , X_login             =>	X_login
                            , X_module            =>	X_module
                            , X_calling_process   =>	'TRANSFER'
                            , Rows                =>	temp_num_processed
                            , X_status            => 	temp_status
                            , X_gl_flag           =>	NULL );

    -- -------------------------------------------------------------------------
    -- OGM_0.0 : OGM needs to create additional details for each expenditure
    -- item created here. VERT_ADJUST_ITEMS does that for vertical applications.
    -- If temp_status is not null it does nothing else process the additional
    -- details and set temp_status in case of system exceptions.
    -- --------------------------------------------------------------------------
    PA_GMS_API.VERT_ADJUST_ITEMS( 'TRANSFER', temp_num_processed, temp_status ) ;

    CheckStatus( status_indicator => temp_status );

    X_num_processed := temp_num_processed;
    X_num_rejected  := temp_num_rejected;
    /* X_outcome       := NULL; Bug 4906816 - Commented to carry forward warnings also */

  EXCEPTION
    WHEN  OTHERS  THEN
      X_outcome := SQLCODE;
      RAISE;

  END  Transfer;


-- ========================================================================
-- PROCEDURE Adjust
-- ========================================================================
-- Added new parameters acct rate attributes for the new rate adjustments

  PROCEDURE  Adjust( X_adj_action           IN VARCHAR2
                   , X_module               IN VARCHAR2
                   , X_user                 IN NUMBER
                   , X_login                IN NUMBER
                   , X_project_id           IN NUMBER
                   , X_adjust_level         IN VARCHAR2
                   , X_expenditure_item_id  IN NUMBER
                   , X_dest_prj_id          IN NUMBER
                   , X_dest_task_id         IN NUMBER
                   , X_project_currency_code IN VARCHAR2
                   , X_project_rate_type     IN VARCHAR2
                   , X_project_rate_date     IN DATE
                   , X_project_exchange_rate IN NUMBER
		           , X_acct_rate_type        IN VARCHAR2
		           , X_acct_rate_date        IN DATE
		           , X_acct_exchange_rate    IN NUMBER
                   , X_task_id              IN NUMBER
                   , X_inc_by_person_id     IN NUMBER
                   , X_inc_by_org_id        IN NUMBER
                   , X_ei_date_low          IN DATE
                   , X_ei_date_high         IN DATE
                   , X_system_linkage       IN VARCHAR2
                   , X_expenditure_type     IN VARCHAR2
                   , X_vendor_id            IN NUMBER
                   , X_nl_resource_org_id   IN NUMBER
                   , X_nl_resource          IN VARCHAR2
                   , X_bill_status          IN VARCHAR2
                   , X_hold_flag            IN VARCHAR2
                   , X_expenditure_comment  IN VARCHAR2
                   , X_inv_num              IN NUMBER
                   , X_inv_line_num         IN NUMBER
                   , X_cc_code              IN VARCHAR2
                   , X_cc_type              IN VARCHAR2
                   , X_bl_dist_code         IN VARCHAR2
                   , X_ic_proc_code         IN VARCHAR2
                   , X_prvdr_orgnzn_id      IN NUMBER
                   , X_recvr_orgnzn_id      IN NUMBER
                   , X_outcome              OUT NOCOPY VARCHAR2
                   , X_num_processed        OUT NOCOPY NUMBER
                   , X_num_rejected         OUT NOCOPY NUMBER
	               , X_msg_application 	  OUT NOCOPY VARCHAR2
		           , X_msg_type		  OUT NOCOPY VARCHAR2
	               , X_msg_token1 	  OUT NOCOPY VARCHAR2
		           , X_msg_token2  	  OUT NOCOPY VARCHAR2
		           , X_msg_token3  	  OUT NOCOPY VARCHAR2
		           , X_msg_count	  OUT NOCOPY Number
                    /* added for proj currency  and additional EI attributes **/
                   , p_assignment_id                IN NUMBER
                   , p_work_type_id                 IN NUMBER
                   , p_projfunc_currency_code       IN varchar2
                   , p_projfunc_cost_rate_date      IN date
                   , p_projfunc_cost_rate_type      IN varchar2
                   , p_projfunc_cost_exchange_rate  IN number
                   , p_project_raw_cost             IN number
                   , p_project_burdened_cost        IN number
                   , p_project_tp_currency_code     IN varchar2
                   , p_project_tp_cost_rate_date    IN date
                   , p_project_tp_cost_rate_type    IN  varchar2
                   , p_project_tp_cost_exchg_rate   IN number
                   , p_project_transfer_price       IN number
                   , p_dest_work_type_id            IN NUMBER
                   , p_tp_amt_type_code             IN varchar2
                   , p_dest_tp_amt_type_code        IN varchar2
                    /** end of proj currency  and additional EI attributes **/
                    ) IS

    ItemsIdTab              pa_utils.IdTabTyp;
    AdjustsIdTab            pa_utils.IdTabTyp;
    DenomCurrCodeTab        pa_utils.Char15TabTyp;
    ProjCurrCodeTab         pa_utils.Char15TabTyp;
    ProjFuncCurrCodeTab     pa_utils.Char15TabTyp;

    TpAmtTypCodeTab         pa_utils.Char30TabTyp;

    dummy               	NUMBER;
    temp_outcome        	VARCHAR2(30) DEFAULT NULL;
    temp_status         	NUMBER DEFAULT NULL;
    temp_num_processed  	NUMBER DEFAULT 0;
    temp_num_rejected   	NUMBER DEFAULT 0;
	temp_msg_application   VARCHAR2(30) :='PA';
	temp_msg_type				VARCHAR2(1) := 'E';
	temp_msg_token1			Varchar2(240) := '';
	temp_msg_token2			Varchar2(240) :='';
	temp_msg_token3			Varchar2(240) :='';
	temp_msg_count			Number ;
    i                   	BINARY_INTEGER := 0;
    adj_ei              	number;
    RelLockStatus number := 0;  /* Bug#3598333 */


    CURSOR  GetPrjExpSummary  IS
      SELECT
              ei.expenditure_item_id
      ,       eia.expenditure_item_id   adj_expenditure_item_id
        FROM
              pa_expenditures_all e
      ,       pa_expenditure_items_all ei
      ,       pa_expenditure_items_all eia
       WHERE
              ei.expenditure_item_id = eia.adjusted_expenditure_item_id (+)
         AND  ei.expenditure_id = e.expenditure_id
         AND  ei.task_id IN

		( SELECT
                          t.task_id
                    FROM
                          pa_tasks t
                   WHERE
                          t.project_id = X_project_id
                     AND  t.task_id = nvl( X_task_id, t.task_id )
		)

         AND  (    X_inc_by_person_id IS NULL
                OR e.incurred_by_person_id = X_inc_by_person_id )
         AND  (    X_inc_by_org_id IS NULL
                OR e.incurred_by_organization_id = X_inc_by_org_id
                OR (    e.incurred_by_organization_id IS NULL
                    AND ei.override_to_organization_id = X_inc_by_org_id ))
         AND  (    X_vendor_id IS NULL
                OR X_vendor_id = ei.vendor_id) /* R12 changes - Removed reference t ocdl.system_reference1 */
         AND  (    X_system_linkage IS NULL
                OR  ei.system_linkage_function = X_system_linkage )
/* commented the following lines for mfg changes and added the one line above
                OR EXISTS
                     ( SELECT  NULL
                         FROM
                               pa_expenditure_types et
                        WHERE
                               et.expenditure_type = ei.expenditure_type
                          AND  ei.system_linkage_function = X_system_linkage ))
*/
         AND  ei.expenditure_type =
                   nvl( X_expenditure_type, ei.expenditure_type )
         AND  (    X_nl_resource_org_id IS NULL
                OR ei.organization_id = X_nl_resource_org_id )
         AND  (    X_nl_resource IS NULL
                OR ei.non_labor_resource = X_nl_resource )
         AND  (    X_hold_flag IS NULL
                OR ei.bill_hold_flag = decode( X_hold_flag, 'B',
                   decode( ei.bill_hold_flag, 'N', 'Z', ei.bill_hold_flag ),
                      ei.bill_hold_flag ) )
         AND  ei.expenditure_item_date BETWEEN
                     nvl( X_ei_date_low, ei.expenditure_item_date )
                 AND nvl( X_ei_date_high, ei.expenditure_item_date )
         AND  ei.adjusted_expenditure_item_id IS NULL
         AND  (        X_bill_status IS NULL
                OR
                   (   X_bill_status = 'U'
                    AND ei.project_id IS NULL
                    AND NOT EXISTS (
                        SELECT NULL
                          FROM
                                pa_proj_invoice_details_view idv
                         WHERE
                                idv.project_id+0 = X_project_id
                           AND  idv.expenditure_item_id =
                                               ei.expenditure_item_id ) )
                OR
                   (    X_bill_status IN ( 'P', 'R', 'B' )
                    AND EXISTS (
                        SELECT
                               NULL
                          FROM
                                pa_draft_invoices i
                        ,       pa_draft_invoice_items ii
                         WHERE
                                i.project_id+0 = X_project_id
                           AND  i.project_id = ii.project_id
                           AND  i.draft_invoice_num = ii.draft_invoice_num
                           AND  nvl(ii.event_task_id, -1) =
                                   nvl(ei.event_task_id, -1)
                           AND  ii.project_id = ei.project_id
                           AND  ii.event_num = ei.event_num
                           AND  nvl( i.released_by_person_id, -1 ) =
                                 decode( X_bill_status, 'P', -1,
                                   'R', i.released_by_person_id,
                                   'B', nvl( i.released_by_person_id, -1), -2)))
               )
            AND (     1 = 2
	       OR ( X_adj_action = 'CHANGE WORK TYPE ATTRIBUTE'  /** proj currency changes **/
                   AND nvl( ei.net_zero_adjustment_flag, 'N' ) <> 'Y'
                   AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                   AND ei.work_type_id <> p_dest_work_type_id
                   AND e.expenditure_status_code = 'APPROVED'
                  )
               OR
                  (    X_adj_action = 'PROJECT OR TASK CHANGE'
                   AND nvl( ei.net_zero_adjustment_flag, 'N' ) <> 'Y'
                   AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                   AND ei.task_id <> X_dest_task_id
                   AND e.expenditure_status_code = 'APPROVED'
                   AND ei.source_expenditure_item_id IS NULL
                  )
               OR
                  (    X_adj_action = 'BILLING HOLD'
                   AND ei.bill_hold_flag in ( 'N', 'O' ) )
               OR
                  (    X_adj_action = 'BILLING HOLD RELEASE'
                   AND ei.bill_hold_flag in ( 'Y', 'O' ) )
               OR
                  (    X_adj_action = 'BILLABLE RECLASS'
                   AND ei.billable_flag <> 'Y'
                   AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                   AND nvl( eia.converted_flag, 'N' ) <> 'Y'
                  )
               OR
                  (    X_adj_action = 'NON-BILLABLE RECLASS'
                   AND ei.billable_flag = 'Y'
                   AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                   AND nvl( eia.converted_flag, 'N' ) <> 'Y'
                  )
               OR
                  (    X_adj_action = 'CAPITALIZABLE RECLASS'
                   AND ei.billable_flag <> 'Y'
                   AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                   AND nvl( eia.converted_flag, 'N' ) <> 'Y'
		   AND exists (select 1
		               From pa_tasks t
		               Where t.task_id = ei.task_id
		               And t.retirement_cost_flag = 'N')

                  )
               OR
                  (    X_adj_action = 'NON-CAPITALIZABLE RECLASS'
                   AND ei.billable_flag = 'Y'
                   AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                   AND nvl( eia.converted_flag, 'N' ) <> 'Y'
                   AND exists (select 1
                               From pa_tasks t
                               Where t.task_id = ei.task_id
                               And t.retirement_cost_flag = 'N')
                  )
               OR
                  (    X_adj_action = 'REVENUE RECALC'
                   AND ei.revenue_distributed_flag||'' IN ( 'Y', 'P' )
                   AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                   AND nvl( eia.converted_flag, 'N' ) <> 'Y'
                  )
               OR
                  (    X_adj_action = 'ONE-TIME BILLING HOLD'
                   AND ei.bill_hold_flag IN ( 'N', 'Y' ) )
               OR
                  (    X_adj_action = 'COST AND REV RECALC'
                   AND (   ei.revenue_distributed_flag||'' IN ( 'Y', 'P' )
                        OR (    ei.cost_distributed_flag||'' = 'Y'
                             OR ei.denom_raw_cost IS NOT NULL ) )
                   AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                   AND nvl( eia.converted_flag, 'N' ) <> 'Y'
                   AND ei.source_expenditure_item_id IS NULL
                   AND nvl( ei.net_zero_adjustment_flag, 'N' ) <> 'Y'
                  )
               OR
                  (    X_adj_action = 'CAPITAL COST RECALC'
                   AND ei.cost_distributed_flag||'' = 'Y' )
               OR
                  (    X_adj_action = 'RAW COST RECALC'
                   AND ei.cost_distributed_flag||'' = 'Y' )
               OR
                  (    X_adj_action = 'INDIRECT COST RECALC'
                   AND ei.cost_distributed_flag||'' = 'Y' ) )
      FOR UPDATE OF ei.expenditure_item_id, eia.expenditure_item_id NOWAIT;


      CURSOR  GetPrjExpItem
      IS
      SELECT
              ei.expenditure_item_id
      ,       eia.expenditure_item_id  adj_expenditure_item_id
        FROM
              pa_expenditures_all e
      ,       pa_expenditure_items_all ei
      ,       pa_expenditure_items_all eia
       WHERE
              ei.expenditure_item_id = eia.adjusted_expenditure_item_id (+)
         AND  ei.expenditure_id = e.expenditure_id
         AND  ei.expenditure_item_id = X_expenditure_item_id
         AND ( 1 = 2
               OR X_adj_action = 'EXP COMMENT CHANGE'
	       OR (X_adj_action = 'CHANGE WORK TYPE ATTRIBUTE'  /** proj currency changes **/
               AND nvl( ei.net_zero_adjustment_flag, 'N' ) <> 'Y'
               AND nvl( ei.converted_flag, 'N' ) <> 'Y'
               AND ei.work_type_id  <> p_dest_work_type_id
               AND e.expenditure_status_code = 'APPROVED'
              )
               OR
              (    X_adj_action = 'PROJECT OR TASK CHANGE'
               AND nvl( ei.net_zero_adjustment_flag, 'N' ) <> 'Y'
               AND nvl( ei.converted_flag, 'N' ) <> 'Y'
               AND ei.task_id <> X_dest_task_id
               AND e.expenditure_status_code = 'APPROVED'
               AND ei.source_expenditure_item_id IS NULL
              )
            OR
               (    X_adj_action = 'BILLING HOLD'
                AND ei.bill_hold_flag in ( 'N', 'O' ) )
            OR
               (    X_adj_action = 'BILLING HOLD RELEASE'
                AND ei.bill_hold_flag in ( 'Y', 'O' ) )
            OR
               (    X_adj_action = 'BILLABLE RECLASS'
                AND ei.billable_flag <> 'Y'
                AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                AND nvl( eia.converted_flag, 'N' ) <> 'Y'
               )
            OR
               (    X_adj_action = 'NON-BILLABLE RECLASS'
                AND ei.billable_flag = 'Y'
                AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                AND nvl( eia.converted_flag, 'N' ) <> 'Y'
               )
            OR
               (    X_adj_action = 'CAPITALIZABLE RECLASS'
                AND ei.billable_flag <> 'Y'
                AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                AND nvl( eia.converted_flag, 'N' ) <> 'Y'
                AND exists (select 1
                            From pa_tasks t
                            Where t.task_id = ei.task_id
                            And t.retirement_cost_flag = 'N')
               )
            OR
               (    X_adj_action = 'NON-CAPITALIZABLE RECLASS'
                AND ei.billable_flag = 'Y'
                AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                AND nvl( eia.converted_flag, 'N' ) <> 'Y'
                AND exists (select 1
                            From pa_tasks t
                            Where t.task_id = ei.task_id
                            And t.retirement_cost_flag = 'N')
               )
            OR
               (    X_adj_action = 'REVENUE RECALC'
                AND ei.revenue_distributed_flag||'' IN ( 'Y', 'P' )
                AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                AND nvl( eia.converted_flag, 'N' ) <> 'Y'
               )
            OR
               (    X_adj_action = 'ONE-TIME BILLING HOLD'
                AND ei.bill_hold_flag IN ( 'N', 'Y' ) )
            OR
               (    X_adj_action = 'COST AND REV RECALC'
                AND (   ei.revenue_distributed_flag||'' IN ( 'Y', 'P' )
                     OR (    ei.cost_distributed_flag||'' = 'Y'
                          OR ei.denom_raw_cost IS NOT NULL ) )
                AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                AND nvl( eia.converted_flag, 'N' ) <> 'Y'
                AND ei.source_expenditure_item_id IS NULL
                AND nvl( ei.net_zero_adjustment_flag, 'N' ) <> 'Y'
               )
            OR
               (    X_adj_action = 'CAPITAL COST RECALC'
                AND ei.cost_distributed_flag||'' = 'Y' )
            OR
               (    X_adj_action = 'RAW COST RECALC'
                AND ei.cost_distributed_flag||'' = 'Y' )
            OR
               (    X_adj_action = 'INDIRECT COST RECALC'
                AND ei.cost_distributed_flag||'' = 'Y' ) )
      FOR UPDATE OF ei.expenditure_item_id, eia.expenditure_item_id NOWAIT;


      CURSOR  GetInvExpSummary
      IS
      SELECT
              ei.expenditure_item_id
      ,       eia.expenditure_item_id   adj_expenditure_item_id
        FROM
              pa_cust_rev_dist_lines r
      ,       pa_expenditure_items_all ei
      ,       pa_expenditure_items_all eia
       WHERE
              ei.expenditure_item_id = eia.adjusted_expenditure_item_id (+)
         AND  ei.adjusted_expenditure_item_id IS NULL
         AND  r.project_id = X_project_id
         AND  r.draft_invoice_num = X_inv_num
         AND  r.draft_invoice_item_line_num =
                 nvl( X_inv_line_num, r.draft_invoice_item_line_num )
         AND  r.expenditure_item_id = ei.expenditure_item_id
         AND  (       1 = 2
	       OR ( X_adj_action = 'CHANGE WORK TYPE ATTRIBUTE'  /** proj currency changes **/
               AND nvl( ei.net_zero_adjustment_flag, 'N' ) <> 'Y'
               AND nvl( ei.converted_flag, 'N' ) <> 'Y'
               AND ei.work_type_id <> p_dest_work_type_id
	       )

               OR
              (    X_adj_action = 'PROJECT OR TASK CHANGE'
               AND nvl( ei.net_zero_adjustment_flag, 'N' ) <> 'Y'
               AND nvl( ei.converted_flag, 'N' ) <> 'Y'
               AND ei.task_id <> X_dest_task_id
               AND ei.source_expenditure_item_id IS NULL
              )
               OR
                 (    X_adj_action = 'BILLING HOLD'
                  AND ei.bill_hold_flag IN ( 'N', 'O' ) )
               OR
                 (    X_adj_action = 'BILLING HOLD RELEASE'
                  AND ei.bill_hold_flag IN ( 'Y', 'O' ) )
               OR
                 (    X_adj_action = 'NON-BILLABLE RECLASS'
                  AND ei.billable_flag = 'Y'
                  AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                  AND nvl( eia.converted_flag, 'N' ) <> 'Y'
                 )
               OR
                 (    X_adj_action = 'REVENUE RECALC'
                  AND ei.revenue_distributed_flag||'' IN ( 'Y', 'P' )
                  AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                  AND nvl( eia.converted_flag, 'N' ) <> 'Y'
                 )
               OR
                 (    X_adj_action = 'ONE-TIME BILLING HOLD'
                  AND ei.bill_hold_flag IN ( 'N', 'Y' ) )
               OR
                 (    X_adj_action = 'COST AND REV RECALC'
                  AND (   ei.revenue_distributed_flag||'' IN ( 'Y', 'P' )
                       OR (    ei.cost_distributed_flag||'' = 'Y'
                            OR ei.denom_raw_cost IS NOT NULL ) )
                  AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                  AND nvl( eia.converted_flag, 'N' ) <> 'Y'
                  AND ei.source_expenditure_item_id IS NULL
                  AND nvl( ei.net_zero_adjustment_flag, 'N' ) <> 'Y'
                 ) )
      FOR UPDATE OF ei.expenditure_item_id, eia.expenditure_item_id NOWAIT;



      CURSOR GetInvExpSummary2
      IS
      SELECT
              ei.expenditure_item_id
      ,       eia.expenditure_item_id  adj_expenditure_item_id
        FROM
              pa_draft_invoice_items ii
      ,       pa_expenditure_items_all ei
      ,       pa_expenditure_items_all eia
       WHERE
              /* Bug # 3457873
	      ei.task_id IN (
                    SELECT task_id
                      FROM pa_tasks
                     WHERE project_id = X_project_id )
	     */
              ei.project_id = X_project_id /* Bug # 3457873 */
         AND  ei.expenditure_item_id = eia.adjusted_expenditure_item_id (+)
         AND  ei.adjusted_expenditure_item_id IS NULL
         AND  ii.project_id = X_project_id
         AND  ii.draft_invoice_num = X_inv_num
         AND  ii.line_num = nvl( X_inv_line_num, ii.line_num )
         AND  ii.project_id = ei.project_id
         AND  nvl( ii.event_task_id, -1 ) = nvl( ei.event_task_id, -1 )
         AND  ii.event_num = ei.event_num
         AND  (       1 = 2
	       OR ( X_adj_action = 'CHANGE WORK TYPE ATTRIBUTE'  /** proj currency changes **/
                  AND nvl( ei.net_zero_adjustment_flag, 'N' ) <> 'Y'
                  AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                  AND ei.work_type_id <> p_dest_work_type_id
                 )
               OR
                 (    X_adj_action = 'BILLING HOLD'
                  AND ei.bill_hold_flag IN ( 'N', 'O' ) )
               OR
                 (    X_adj_action = 'BILLING HOLD RELEASE'
                  AND ei.bill_hold_flag IN ( 'Y', 'O' ) )
               OR
                 (    X_adj_action = 'NON-BILLABLE RECLASS'
                  AND ei.billable_flag = 'Y'
                  AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                  AND nvl( eia.converted_flag, 'N' ) <> 'Y'
                 )
               OR
                 (    X_adj_action = 'REVENUE RECALC'
                  AND ei.revenue_distributed_flag||'' IN ( 'Y', 'P' )
                  AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                  AND nvl( eia.converted_flag, 'N' ) <> 'Y'
                 )
               OR
                 (    X_adj_action = 'ONE-TIME BILLING HOLD'
                  AND ei.bill_hold_flag IN ( 'N', 'Y' ) )
               OR
                 (    X_adj_action = 'COST AND REV RECALC'
                  AND (   ei.revenue_distributed_flag||'' IN ( 'Y', 'P' )
                       OR (    ei.cost_distributed_flag||'' = 'Y'
                            OR ei.denom_raw_cost IS NOT NULL ) )
                  AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                  AND nvl( eia.converted_flag, 'N' ) <> 'Y'
                  AND ei.source_expenditure_item_id IS NULL
                  AND nvl( ei.net_zero_adjustment_flag, 'N' ) <> 'N'
                 )
               OR
                 (    X_adj_action = 'PROJECT OR TASK CHANGE'
                  AND nvl( ei.net_zero_adjustment_flag, 'N' ) <> 'Y'
                  AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                  AND ei.task_id <> X_dest_task_id
                  AND ei.source_expenditure_item_id IS NULL
                 ) )
      FOR UPDATE OF ei.expenditure_item_id, eia.expenditure_item_id NOWAIT;


      CURSOR GetInvExpItem
      IS
      SELECT
              ei.expenditure_item_id
      ,       eia.expenditure_item_id   adj_expenditure_item_id
        FROM
              pa_expenditure_items_all ei
      ,       pa_expenditure_items_all eia
       WHERE
              ei.expenditure_item_id = eia.adjusted_expenditure_item_id (+)
         AND  ei.expenditure_item_id =  X_expenditure_item_id
         AND  (       1 = 2
               OR X_adj_action = 'EXP COMMENT CHANGE'
	       OR ( X_adj_action = 'CHANGE WORK TYPE ATTRIBUTE'  /** proj currency changes **/
                  AND nvl( ei.net_zero_adjustment_flag, 'N' ) <> 'Y'
                  AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                  AND ei.work_type_id <> p_dest_work_type_id
                 )
               OR
                 (    X_adj_action = 'BILLING HOLD'
                  AND ei.bill_hold_flag IN ( 'N', 'O' ) )
               OR
                 (    X_adj_action = 'BILLING HOLD RELEASE'
                  AND ei.bill_hold_flag IN ( 'Y', 'O' ) )
               OR
                 (    X_adj_action = 'NON-BILLABLE RECLASS'
                  AND ei.billable_flag = 'Y'
                  AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                  AND nvl( eia.converted_flag, 'N' ) <> 'Y'
                 )
               OR
                 (    X_adj_action = 'REVENUE RECALC'
                  AND ei.revenue_distributed_flag||'' IN ( 'Y', 'P' )
                  AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                  AND nvl( eia.converted_flag, 'N' ) <> 'Y'
                 )
               OR
                 (    X_adj_action = 'ONE-TIME BILLING HOLD'
                  AND ei.bill_hold_flag IN ( 'N', 'Y' ) )
               OR
                 (    X_adj_action = 'COST AND REV RECALC'
                  AND (   ei.revenue_distributed_flag||'' IN ( 'Y', 'P' )
                       OR (    ei.cost_distributed_flag||'' = 'Y'
                            OR ei.denom_raw_cost IS NOT NULL ) )
                  AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                  AND nvl( eia.converted_flag, 'N' ) <> 'Y'
                  AND ei.source_expenditure_item_id IS NULL
                  AND nvl( ei.net_zero_adjustment_flag, 'N') <> 'Y'
                 )
               OR
                 (    X_adj_action = 'PROJECT OR TASK CHANGE'
                  AND nvl( ei.net_zero_adjustment_flag, 'N' ) <> 'Y'
                  AND nvl( ei.converted_flag, 'N' ) <> 'Y'
                  AND ei.task_id <> X_dest_task_id
                  AND ei.source_expenditure_item_id IS NULL
                 ) )
       FOR UPDATE OF ei.expenditure_item_id, eia.expenditure_item_id NOWAIT;


  BEGIN

	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'Inside the pa_adjustment pkg IN PARAMS x_module ['||X_module||']X_adjust_level ['||X_adjust_level||
       ']X_adj_action['||X_adj_action||']p_work_type_id ['||p_work_type_id||']p_dest_work_type_id['||p_dest_work_type_id||
       ']expenditure_item_id['||x_expenditure_item_id||']p_projfunc_currency_code['||p_projfunc_currency_code||
       ']p_projfunc_cost_rate_date ['||p_projfunc_cost_rate_date||']p_projfunc_cost_rate_type['
	||p_projfunc_cost_rate_type||']p_projfunc_cost_exchange_rate['||p_projfunc_cost_exchange_rate||
        ']p_project_raw_cost['||p_project_raw_cost||']p_project_burdened_cost['||p_project_burdened_cost||
        ']X_project_currency_code['||X_project_currency_code||']X_project_rate_type['||X_project_rate_type||
        ']X_project_rate_date['||X_project_rate_date||']X_project_exchange_rate ['||X_project_exchange_rate||
        ']X_acct_rate_type['||X_acct_rate_type||'] X_acct_rate_date['||X_acct_rate_date||
        ']X_acct_exchange_rate['||X_acct_exchange_rate||']' );
	END IF;

    i := 0;

    -- PAXPRRPE - This is called from GUI EI Adjustment form (PAXTRAPE.fmb).
    -- PAXINADI - This is called from GUI Invoice Reveiew form (PAXINRVW.fmb).
    -- The Name PAXPRRPE/PAXINADI has not been changed because this is being
    -- used by the client as this is what gets passed to transaction
    -- control extension.
    -- Adjust_level will always be at the Item(I) level from V4 onwards,
    -- Summary ('S') adjust level has been kept for compatiblity purposes
    -- for X_modules PAXPRRPE and PAXINADI
    IF ( X_module = 'PAXPRRPE' ) THEN

      IF ( X_adjust_level = 'S' ) THEN

        FOR  EachRec  IN GetPrjExpSummary LOOP
          i := i + 1;
          ItemsIdTab(i)    := EachRec.expenditure_item_id;
          AdjustsIdTab(i)  := EachRec.adj_expenditure_item_id;
        END LOOP;

    ELSIF ( X_adjust_level = 'I' ) THEN

      -- FOR  EachRec  IN GetPrjExpItem LOOP
      --   i := i + 1;
      --   ItemsIdTab(i)    := EachRec.expenditure_item_id;
      --   AdjustsIdTab(i)  := EachRec.adj_expenditure_item_id;
      -- END LOOP;

      i := 1;
      ItemsIdTab(i) := X_expenditure_item_id;
      DenomCurrCodeTab(i)     := NULL ;
      ProjCurrCodeTab(i)      := X_project_currency_code ;
      ProjFuncCurrCodeTab(i)  := p_projfunc_currency_code;
      TpAmtTypCodeTab(i)      := p_tp_amt_type_code;

      IF ( X_adj_action in ('PROJECT OR TASK CHANGE', 'RAW COST RECALC' ,
                            'CAPITAL COST RECALC', 'INDIRECT COST RECALC',
                            'REVENUE RECALC', 'COST AND REV RECALC')
         ) THEN
        AdjustsIdTab(i)  := NULL;
      ELSE
        BEGIN
          -- get the adjusted ei also
          SELECT expenditure_item_id adj
            INTO adj_ei
            FROM pa_expenditure_items_all
           WHERE adjusted_expenditure_item_id = X_expenditure_item_id;

           AdjustsIdTab(i)  := adj_ei;
        EXCEPTION
           WHEN NO_DATA_FOUND then
             AdjustsIdTab(i)  := NULL;
           WHEN others then
             raise;
        END;
      END IF;


    END IF;

    IF ( i = 0 ) THEN
      X_outcome := 'PA_PR_NO_ITEMS_PROC';
      X_num_processed := 0;
      X_num_rejected  := 0;
      RETURN;
    END IF;

  ELSIF ( X_module = 'PAXINADI' ) THEN

    IF ( X_adjust_level = 'S' ) THEN

      FOR  EachRec  IN GetInvExpSummary LOOP
        i := i + 1;
        ItemsIdTab(i)    := EachRec.expenditure_item_id;
        AdjustsIdTab(i)  := EachRec.adj_expenditure_item_id;
      END LOOP;

      FOR EachRec IN GetInvExpSummary2 LOOP
        i := i + 1;
        ItemsIdTab(i)    := EachRec.expenditure_item_id;
        AdjustsIdTab(i)  := EachRec.adj_expenditure_item_id;
      END LOOP;

    ELSIF ( X_adjust_level = 'I' ) THEN

      -- FOR  EachRec  IN GetInvExpItem LOOP
      --   i := i + 1;
      --   ItemsIdTab(i)    := EachRec.expenditure_item_id;
      --   AdjustsIdTab(i)  := EachRec.adj_expenditure_item_id;
      -- END LOOP;

      i := 1;
      ItemsIdTab(i) := X_expenditure_item_id;

/*Bug # 2249022 Added as it is missing */
      DenomCurrCodeTab(i)     := NULL ;
      ProjCurrCodeTab(i)      := X_project_currency_code ;
      ProjFuncCurrCodeTab(i)  := p_projfunc_currency_code;
      TpAmtTypCodeTab(i)      := p_tp_amt_type_code;
/*Bug # 2249022 End */

      IF ( X_adj_action in ('PROJECT OR TASK CHANGE', 'RAW COST RECALC' ,
                            'CAPITAL COST RECALC', 'INDIRECT COST RECALC',
                            'REVENUE RECALC', 'COST AND REV RECALC')
         ) THEN
        AdjustsIdTab(i)  := NULL;
      ELSE
        BEGIN
          -- get the adjusted ei also
          SELECT expenditure_item_id adj
            INTO adj_ei
            FROM pa_expenditure_items_all
           WHERE adjusted_expenditure_item_id = X_expenditure_item_id;

           AdjustsIdTab(i)  := adj_ei;
        EXCEPTION
           WHEN NO_DATA_FOUND then
             AdjustsIdTab(i)  := NULL;
           WHEN others then
             raise;
        END;
      END IF;


    END IF;

    IF ( i = 0 ) THEN
      X_outcome := 'PA_PR_NO_ITEMS_PROC';
      X_num_processed := 0;
      X_num_rejected  := 0;
      RETURN;
    END IF;

END IF;



IF ( X_adj_action = 'BILLABLE RECLASS' ) THEN

Reclass( ItemsIdTab
     , AdjustsIdTab
     , 'Y'
     , X_adj_action
     , X_user
     , X_login
     , X_module
     , i
     , temp_status );
CheckStatus( temp_status );

ELSIF ( X_adj_action = 'NON-BILLABLE RECLASS' ) THEN

Reclass( ItemsIdTab
     , AdjustsIdTab
     , 'N'
     , X_adj_action
     , X_user
     , X_login
     , X_module
     , i
     , temp_status );
CheckStatus( temp_status );

ELSIF ( X_adj_action = 'CAPITALIZABLE RECLASS' ) THEN

Reclass( ItemsIdTab
     , AdjustsIdTab
     , 'Y'
     , X_adj_action
     , X_user
     , X_login
     , X_module
     , i
     , temp_status );
CheckStatus( temp_status );

ELSIF ( X_adj_action = 'NON-CAPITALIZABLE RECLASS' ) THEN

Reclass( ItemsIdTab
     , AdjustsIdTab
     , 'N'
     , X_adj_action
     , X_user
     , X_login
     , X_module
     , i
     , temp_status );
CheckStatus( temp_status );

ELSIF ( X_adj_action = 'BILLING HOLD' ) THEN

Hold( ItemsIdTab
  , AdjustsIdTab
  , 'Y'
  , X_adj_action
  , X_user
  , X_login
  , X_module
  , i
  , temp_status );
CheckStatus( temp_status );

ELSIF ( X_adj_action = 'BILLING HOLD RELEASE' ) THEN

Hold( ItemsIdTab
  , AdjustsIdTab
  , 'N'
  , X_adj_action
  , X_user
  , X_login
  , X_module
  , i
  , temp_status );
CheckStatus( temp_status );

ELSIF ( X_adj_action = 'ONE-TIME BILLING HOLD' ) THEN

Hold( ItemsIdTab
  , AdjustsIdTab
  , 'O'
  , X_adj_action
  , X_user
  , X_login
  , X_module
  , i
  , temp_status );
CheckStatus( temp_status );

ELSIF ( X_adj_action = 'INDIRECT COST RECALC' ) THEN

RecalcIndCost( ItemsIdTab
	   , AdjustsIdTab
	   , X_user
	   , X_login
	   , X_module
	   , i
	   , temp_status );
CheckStatus( temp_status );

ELSIF ( X_adj_action = 'COST AND REV RECALC' ) THEN

RecalcCostRev( ItemsIdTab
	   , AdjustsIdTab
	   , X_user
	   , X_login
	   , X_module
	   , i
	   , temp_num_processed
	   , temp_status );
CheckStatus( temp_status );

ELSIF ( X_adj_action = 'REVENUE RECALC' ) THEN

RecalcRev( ItemsIdTab
       , AdjustsIdTab
       , X_user
       , X_login
       , X_module
       , i
       , temp_status );
CheckStatus( temp_status );

ELSIF ( X_adj_action = 'CAPITAL COST RECALC' ) THEN

RecalcCapCost( ItemsIdTab
	   , AdjustsIdTab
	   , X_user
	   , X_login
	   , X_module
	   , i
	   , temp_status );
CheckStatus( temp_status );

ELSIF ( X_adj_action = 'RAW COST RECALC' ) THEN

RecalcRawCost( ItemsIdTab
	   , AdjustsIdTab
	   , X_user
	   , X_login
	   , X_module
	   , i
	   , temp_num_processed
	   , temp_status );
CheckStatus( temp_status );

-- call to the new rate attribute adjustment procedures
ELSIF ( X_adj_action = 'CHANGE FUNC ATTRIBUTE' ) THEN

  ChangeFuncAttributes(ItemsIdTab
                          , X_adjust_level
                          , X_user
                          , X_login
                          , X_module
                          , X_acct_rate_type
			  , X_acct_rate_date
			  , X_acct_exchange_rate
                          , DenomCurrCodeTab
                          , ProjCurrCodeTab
                          , i
                          , temp_num_processed
                          , temp_num_rejected
                          , temp_status
		 	  , ProjFuncCurrCodeTab) ;
CheckStatus( temp_status );

-- call to the new rate attribute adjustment procedures for project currency
ELSIF ( X_adj_action = 'CHANGE PROJ ATTRIBUTE' ) THEN

 ChangeProjAttributes(ItemsIdTab
                          , X_adjust_level
                          , X_user
                          , X_login
                          , X_module
                          , X_project_rate_type
                          , X_project_rate_date
                          , X_project_exchange_rate
                          , DenomCurrCodeTab
                          , ProjCurrCodeTab
                          , i
                          , temp_num_processed
                          , temp_num_rejected
                          , temp_status         ) ;
CheckStatus( temp_status );

-- call to the new rate attribute adjustment procedures for project functional currency
ELSIF ( X_adj_action = 'CHANGE PROJ FUNC ATTRIBUTE' ) THEN

 ChangeProjFuncAttributes(ItemsIdTab
                          , X_adjust_level
                          , X_user
                          , X_login
                          , X_module
                          , p_projfunc_cost_rate_type
                          , p_projfunc_cost_rate_date
                          , p_projfunc_cost_exchange_rate
                          , DenomCurrCodeTab
                          , ProjFuncCurrCodeTab
                          , i
                          , temp_num_processed
                          , temp_num_rejected
                          , temp_status         ) ;
CheckStatus( temp_status );


-- Call to the 3 new Cross Charge Adjustment routines

ELSIF ( X_adj_action = 'REPROCESS CROSS CHARGE' ) THEN

             ReprocessCrossCharge(ItemsIdTab
                                , X_adjust_level
                                , X_user
                                , X_login
                                , X_module
                                , X_cc_code
                                , X_cc_type
                                , X_bl_dist_code
                                , X_ic_proc_code
                                , X_prvdr_orgnzn_id
                                , X_recvr_orgnzn_id
                                , i
                                , temp_num_processed
                                , temp_status         );

       CheckStatus( temp_status );

ELSIF ( X_adj_action = 'MARK NO CC PROCESS' ) THEN

              MarkNoCCProcess    (ItemsIdTab
                                , X_adjust_level
                                , X_user
                                , X_login
                                , X_module
                                , X_bl_dist_code
                                , X_ic_proc_code
                                , i
                                , temp_num_processed
                                , temp_status         ) ;

        CheckStatus( temp_status );

ELSIF ( X_adj_action = 'CHANGE TP ATTRIBUTE' ) THEN

         ChangeTPAttributes(ItemsIdTab
                          , X_adjust_level
                          , X_user
                          , X_login
                          , X_module
                          , X_acct_rate_type
                          , X_acct_rate_date
                          , X_acct_exchange_rate
    	                  , X_bl_dist_code
                          , X_ic_proc_code
                          , DenomCurrCodeTab
                          , i
                          , temp_num_processed
                          , temp_num_rejected
                          , temp_status
                          , p_PROJECT_TP_COST_RATE_DATE
                          , p_PROJECT_TP_COST_RATE_TYPE
                          , p_PROJECT_TP_COST_EXCHG_RATE ) ;

       CheckStatus( temp_status );


ELSIF ( X_adj_action = 'PROJECT OR TASK CHANGE' ) THEN

/* Bug#3598333 */
FOR j in 1..i LOOP
           If pa_debug.Acquire_user_lock( 'PA_EI_ADJUST_'||to_char( ItemsIdTab(i)))<>0 then
             FND_MESSAGE.SET_NAME('FND','FORM_RECORD_CHANGED');
             APP_EXCEPTION.RAISE_EXCEPTION; /* AcquireLock */
           end if;
END LOOP;
/* Bug#3598333 */

Transfer( ItemsIdTab
      , X_dest_prj_id
      , X_dest_task_id
      , X_project_currency_code
      , X_project_rate_type
      , X_project_rate_date
      , X_project_exchange_rate
      , X_user
      , X_login
      , X_module
      , X_adjust_level
      , i
      , temp_num_processed
      , temp_num_rejected
      , temp_outcome
      , temp_msg_application
      , temp_msg_type
      , temp_msg_token1
      , temp_msg_token2
      , temp_msg_token3
      , temp_msg_count
      , p_projfunc_currency_code
      , p_projfunc_cost_rate_type
      , p_projfunc_cost_rate_date
      , p_projfunc_cost_exchange_rate
      , p_assignment_id
      , p_work_type_id );

/* Bug#3598333 */
/*Changes for 7371988 Starts here -- We will release the lock, hence issuing a commit in PAXEIADJ.pld now, instead of here for messages seeded in Client Extension*/
IF ( temp_msg_type not in ('E','W')) then
        FOR j in 1..i LOOP
           If pa_debug.release_user_lock( 'PA_EI_ADJUST_'||to_char( ItemsIdTab(i)))<>0 then
             FND_MESSAGE.SET_NAME('PA','PA_CAP_CANNOT_RELS_LOCK');
             APP_EXCEPTION.RAISE_EXCEPTION; /* AcquireLock */
           end if;
		   /*Changes for 7371988 end here -- We will release the lock, hence issuing a commit in PAXEIADJ.pld now, instead of here for messages seeded in Client Extension*/
        END LOOP;
/* Bug#3598333 */
END IF;

IF ( temp_outcome IS NOT NULL AND ( temp_msg_type = 'E' ) ) THEN /* Added msg_type check for Bug 4906816 */
/* Bug#3598333 */
FOR j in 1..i LOOP
    RelLockStatus :=  pa_debug.release_user_lock( 'PA_EI_ADJUST_'||to_char( ItemsIdTab(i)));
END LOOP;
/* Bug#3598333 */
RAISE INVALID_ITEM;
END IF;

ELSIF ( X_adj_action = 'EXP COMMENT CHANGE' ) THEN

CommentChange( ItemsIdTab(i)
	   , X_expenditure_comment
	   , X_user
	   , X_login
	   , temp_status );
CheckStatus( temp_status );

/**  start proj currency changes **/
ELSIF ( X_adj_action = 'CHANGE WORK TYPE ATTRIBUTE' ) THEN

 IF P_DEBUG_MODE  THEN
    print_message('get_denom_curr_code: ' || 'calling work_type_adjustment api from adjust pkg');
 END IF;


	work_type_adjustment
                   ( ItemsIdTab        => ItemsIdTab
                    --, AdjustsIdTab   => AdjustsIdTab
                    , p_billable       => NULL
                    , p_work_type_id   =>p_dest_work_type_id
                    , p_adj_activity   =>X_adjust_level
                    , p_user           =>X_user
                    , p_login          =>X_login
                    , p_module         =>X_module
                    , p_rows           => i
                    , p_TpAmtTypCodeTab       => TpAmtTypCodeTab
                    , p_dest_tp_amt_type_code => p_dest_tp_amt_type_code
                    , x_status         => temp_status);
	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'end of work_type_adjustment api from adjust pkg x_status ='||temp_status);
	END IF;

	CheckStatus( temp_status );
	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'after checkstatus api');
	END IF;

/** end proj currency changes **/
END IF;

X_num_processed := temp_num_processed;
X_num_rejected  := temp_num_rejected;
/*X_outcome       := NULL;
 Added for Bug 4906816 */
         X_outcome := temp_outcome;
         X_msg_application := temp_msg_application;
         X_msg_type   := temp_msg_type;
         X_msg_token1 := temp_msg_token1;
         X_msg_token2 := temp_msg_token2;
         X_msg_token3 := temp_msg_token3;
         X_msg_count  := temp_msg_count;

EXCEPTION
   WHEN  INVALID_ITEM  THEN
	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'INVALID_ITEM in adjust api X_outcome ='||temp_outcome);
	END IF;
    X_outcome := temp_outcome;
	 X_msg_application := temp_msg_application;
	 X_msg_type   := temp_msg_type;
	 X_msg_token1 := temp_msg_token1;
	 X_msg_token2 := temp_msg_token2;
	 X_msg_token3 := temp_msg_token3;
	 X_msg_count  := temp_msg_count;
  WHEN RESOURCE_BUSY THEN
     X_outcome := 'PA_ALL_COULD_NOT_LOCK';
	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'RESOURCE_BUSY in adjust api X_outcome ='||X_outcome);
	END IF;
  WHEN  OTHERS  THEN
     X_outcome := SQLCODE;
	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'OTHERS in adjust api X_outcome ='||X_outcome);
	END IF;
     RAISE;

END  Adjust;

-- ========================================================================
-- PROCEDURE MassAdjust
-- ========================================================================

-- This package was created to improve the performance allowing multiple
-- items to be submitted for adjustments together

  /*
   * IC related changes:
   * New parameter added
   */

  PROCEDURE  MassAdjust(
             X_adj_action                IN VARCHAR2
           , X_module                    IN VARCHAR2
           , X_user                      IN NUMBER
           , X_login                     IN NUMBER
           , X_project_id                IN NUMBER
           , X_dest_prj_id               IN NUMBER
           , X_dest_task_id              IN NUMBER
           , X_project_currency_code     IN VARCHAR2
           , X_project_rate_type         IN VARCHAR2
           , X_project_rate_date         IN DATE
           , X_project_exchange_rate     IN NUMBER
           , X_acct_rate_type            IN VARCHAR2
	   , X_acct_rate_date            IN DATE
	   , X_acct_exchange_rate        IN NUMBER
           , X_task_id                   IN NUMBER
           , X_inc_by_person_id          IN NUMBER
           , X_inc_by_org_id             IN NUMBER
           , X_ei_date_low               IN DATE
           , X_ei_date_high              IN DATE
           , X_ex_end_date_low           IN DATE
           , X_ex_end_date_high          IN DATE
           , X_system_linkage            IN VARCHAR2
           , X_expenditure_type          IN VARCHAR2
           , X_expenditure_catg          IN VARCHAR2
           , X_expenditure_group         IN VARCHAR2
           , X_vendor_id                 IN NUMBER
           , X_job_id                    IN NUMBER
           , X_nl_resource_org_id        IN NUMBER
           , X_nl_resource               IN VARCHAR2
           , X_transaction_source        IN VARCHAR2
           , X_cost_distributed_flag     IN VARCHAR2
           , X_revenue_distributed_flag  IN VARCHAR2
           , X_grouped_cip_flag          IN VARCHAR2
           , X_bill_status               IN VARCHAR2
           , X_hold_flag                 IN VARCHAR2
           , X_billable_flag             IN VARCHAR2
           , X_capitalizable_flag        IN VARCHAR2
           , X_net_zero_adjust_flag      IN VARCHAR2
           , X_inv_num                   IN NUMBER
           , X_inv_line_num              IN NUMBER
           , X_cc_code_to_be_determined  IN VARCHAR2
           , X_cc_code_not_crosscharged  IN VARCHAR2
           , X_cc_code_intra_ou          IN VARCHAR2
           , X_cc_code_inter_ou          IN VARCHAR2
           , X_cc_code_intercompany      IN VARCHAR2
           , X_cc_type_no_processing     IN VARCHAR2
           , X_cc_type_b_and_l           IN VARCHAR2
           , X_cc_type_ic_billing        IN VARCHAR2
           , X_cc_prvdr_organization_id  IN NUMBER
           , X_cc_prvdr_ou               IN NUMBER
           , X_cc_recvr_organization_id  IN NUMBER
           , X_cc_recvr_ou               IN NUMBER
           , X_cc_bl_distributed_code    IN VARCHAR2
           , X_cc_ic_processed_code      IN VARCHAR2
           , X_expenditure_item_id       IN NUMBER
           , X_outcome                   OUT NOCOPY VARCHAR2
           , X_num_processed             OUT NOCOPY NUMBER
           , X_num_rejected              OUT NOCOPY NUMBER
           /* added for proj currency  and additional EI attributes **/
           , p_assignment_id                IN NUMBER
           , p_work_type_id                 IN NUMBER
           , p_projfunc_currency_code       IN varchar2
           , p_projfunc_cost_rate_date      IN date
           , p_projfunc_cost_rate_type      IN varchar2
           , p_projfunc_cost_exchange_rate  IN number
           , p_project_raw_cost             IN number
           , p_project_burdened_cost        IN number
           , p_project_tp_currency_code     IN varchar2
           , p_project_tp_cost_rate_date    IN date
           , p_project_tp_cost_rate_type    IN  varchar2
           , p_project_tp_cost_exchg_rate   IN number
           , p_project_transfer_price       IN number
           , p_dest_work_type_id            IN NUMBER
           , p_dest_tp_amt_type_code        IN varchar2
           , p_dest_wt_start_date           IN date
           , p_dest_wt_end_date             IN date
           -- Additional attributes added for FP 'L'
           , p_grouped_rwip_flag            IN varchar2
           , p_capital_event_number         IN number
           , p_start_gl_date                IN date
           , p_end_gl_date                  IN date
           , p_start_pa_date                IN date
           , p_end_pa_date                  IN date
           , p_recvr_start_gl_date          IN date
           , p_recvr_end_gl_date            IN date
           , p_recvr_start_pa_date          IN date
           , p_recvr_end_pa_date            IN date
/* R12 Changes - Start */
           , p_invoice_id                   IN NUMBER
           , p_invoice_line_number          IN NUMBER
           , p_include_related_tax_lines    IN VARCHAR2
	   , p_receipt_number               IN VARCHAR2
	   , p_check_id                     IN NUMBER  /* 4914048 */
           , p_org_id                       IN NUMBER
           , p_dest_award_id                IN NUMBER
           , p_rev_exp_items_req_adjust     IN VARCHAR2
           , p_award_id                     IN NUMBER /* 5194785 */
           , p_expensed_flag                IN VARCHAR2
           , p_wip_resource_id              IN NUMBER
           , p_inventory_item_id            IN NUMBER
/* R12 Changes - End */
            ) IS
    ItemsIdTab               pa_utils.IdTabTyp;
    AdjustsIdTab             pa_utils.IdTabTyp;
    ItemsIdCapTab            pa_utils.IdTabTyp;
    AdjustsIdCapTab          pa_utils.IdTabTyp;
    ItemsIdNCapTab           pa_utils.IdTabTyp;
    AdjustsIdNCapTab         pa_utils.IdTabTyp;
    DenomCurrCodeTab         pa_utils.Char15TabTyp;
    ProjCurrCodeTab          pa_utils.Char15TabTyp;
    ProjFuncCurrCodeTab      pa_utils.Char15TabTyp;
    ProjTpCurrCodeTab        pa_utils.Char15TabTyp;

    TpAmtTypCodeTab          pa_utils.Char30TabTyp;

    dummy                       NUMBER;
    l_project_start_date        DATE;
    l_project_completion_date   DATE;
    l_task_start_date           DATE;
    l_task_completion_date      DATE;
    temp_outcome                VARCHAR2(30) DEFAULT NULL;
    temp_status              NUMBER DEFAULT NULL;
    temp_num_processed       NUMBER DEFAULT 0;
    temp_num_rejected        NUMBER DEFAULT 0;
    num_processed            NUMBER DEFAULT 0;
    num_rejected             NUMBER DEFAULT 0;
    i                        BINARY_INTEGER := 0;
    j                        BINARY_INTEGER := 0;
    k                        BINARY_INTEGER := 0;
    l                        BINARY_INTEGER := 0;
    adj_ei                   number;

/* R12 Changes Start - Changed size to 32000 */
     l_query_string                 VARCHAR2(32000);
/* R12 Changes End */
     v_reserve_rec                  VARCHAR2(2000);
     select_clause                  VARCHAR2(2000);
     reprocess_cc_select            VARCHAR2(2000);
     v_sql_stm1                     VARCHAR2(2000);
     v_sql_stm2	                    VARCHAR2(2000);
     v_sql_stm3	                    VARCHAR2(2000);
     v_sql_stm4                     VARCHAR2(2000);
     v_transfer                     VARCHAR2(2000);
     v_bill_hld                     VARCHAR2(2000);
     v_bill_hold_rel                VARCHAR2(2000);
     v_bill_reclass                 VARCHAR2(2000);
     v_non_bill_reclass             VARCHAR2(2000);
     v_capital_reclass              VARCHAR2(2000);
     v_non_capital_reclass          VARCHAR2(2000);
     v_revenue_recalc               VARCHAR2(2000);
     v_bill_hold_once               VARCHAR2(2000);
     v_cst_rev_recalc               VARCHAR2(2000);
     v_cst_recalc                   VARCHAR2(2000);
     v_ind_cst_recalc               VARCHAR2(2000);
     v_rev_dist_flag                VARCHAR2(2000);
     v_grpd_cip_flag                VARCHAR2(2000);
     v_grpd_rwip_flag               VARCHAR2(2000);
/* R12 Changes Start - Changed size to 32000 */
     where_clause                   VARCHAR2(32000);
/* R12 Changes End */
     from_clause                    VARCHAR2(2000);
     v_condition1                   VARCHAR2(2000);
     v_condition2                   VARCHAR2(2000);
     v_condition3                   VARCHAR2(2000);
     v_condition4                   VARCHAR2(2000);
     /*
      * IC related changes
      * new variable added to append the query criteria
      */
     v_condition5                   VARCHAR2(2000);
     v_system_linkage               VARCHAR2(30);
     v_invoice_id                   NUMBER;
     v_allow_adjustments            VARCHAR2(30):='N';

     v_cursor_adj_id                INTEGER ;
     v_open_cursor                  INTEGER ;

     v_expenditure_item_id          NUMBER(15);
     v_adj_expenditure_item_id      NUMBER(15);
     v_project_type_class_code      VARCHAR2(30);
     v_denom_currency_code          VARCHAR2(15);
     v_project_currency_code        VARCHAR2(15);
     v_denom_tp_currency_code       VARCHAR2(15);
     v_func_attr		    VARCHAR2(2000);
     v_proj_attr		    VARCHAR2(2000);
     v_projfunc_attr		    VARCHAR2(2000);
     l_dummy1                       NUMBER ;
     l_dummy2                       NUMBER ;
     l_dummy3                       NUMBER ;
     l_rate_date_code               VARCHAR2(1) ;
     v_reprocess_cc                 VARCHAR2(2000);
     v_no_cc_process                VARCHAR2(2000);
     v_change_tp_attr               VARCHAR2(2000);
     v_cc_code                      VARCHAR2(1) ;
     v_exp_organization_id          NUMBER ;
     v_exp_org_id                   NUMBER ;
     v_exp_item_date                DATE;
     v_task_id                      NUMBER ;
     v_exp_type                     VARCHAR2(30);
     v_incurred_by_person_id        NUMBER ;
     v_trx_source                   VARCHAR2(30);
     v_nlr_organization_id          NUMBER ;

    /** proj currency and EI attrib related chagnes **/

     l_projfunc_currency_code       varchar2(15);
     l_projfunc_cost_rate_date      date;
     l_projfunc_cost_rate_type      varchar2(30);
     l_projfunc_cost_exchange_rate  number;
     l_project_tp_currency_code     varchar2(15);
     l_assignment_id                number;
     l_work_type_id                 number;
     l_condition6                   varchar2(2000);
     l_work_type_change             varchar2(2000);
     l_tp_amt_type_code             varchar2(30);
     l_transaction_source           varchar2(30);	/* Bug 3951679 : Added */
     l_capital_event_id             number;
/* R12 Changes - Start */
     l_project_id                   number;
     l_old_org_id                   number := -99;
     l_billable_flag                varchar2(1);
     l_document_header_id           number;
     l_document_line_number         number;
     l_document_distribution_id     number;
     l_document_type                varchar2(30);
     l_vendor_id                    number;
     l_gl_accounted                 varchar2(1);
     l_document_payment_id          PA_EXPENDITURE_ITEMS_ALL.DOCUMENT_PAYMENT_ID%TYPE; /* Bug 5006835 */
     l_encoded_error_message        varchar2(2000);
     l_error_message_name           varchar2(30);
     l_application_short_name       varchar2(30);
     l_net_zero_adjustment_flag     PA_EXPENDITURE_ITEMS_ALL.NET_ZERO_ADJUSTMENT_FLAG%TYPE;
     l_converted_flag               PA_EXPENDITURE_ITEMS_ALL.CONVERTED_FLAG%TYPE;
     l_expenditure_status_code      PA_EXPENDITURES_ALL.EXPENDITURE_STATUS_CODE%TYPE;
     l_allow_adjustments_flag       PA_TRANSACTION_SOURCES.ALLOW_ADJUSTMENTS_FLAG%TYPE;
     l_burden_sum_dest_run_id       PA_EXPENDITURE_ITEMS_ALL.BURDEN_SUM_DEST_RUN_ID%TYPE;
     l_document_distribution_type   PA_EXPENDITURE_ITEMS_ALL.DOCUMENT_DISTRIBUTION_TYPE%TYPE;
     l_source_expenditure_item_id   PA_EXPENDITURE_ITEMS_ALL.SOURCE_EXPENDITURE_ITEM_ID%TYPE;
     l_acct_currency_code           PA_EXPENDITURE_ITEMS_ALL.ACCT_CURRENCY_CODE%TYPE;
     l_adjusted_expenditure_item_id PA_EXPENDITURE_ITEMS_ALL.ADJUSTED_EXPENDITURE_ITEM_ID%TYPE;
     l_orig_transaction_reference   PA_EXPENDITURE_ITEMS_ALL.ORIG_TRANSACTION_REFERENCE%TYPE;
     l_project_status_code          PA_PROJECTS_ALL.PROJECT_STATUS_CODE%TYPE;
     l_adjust_allowed               BOOLEAN := TRUE;
     l_award_id                     GMS_AWARDS_ALL.AWARD_ID%TYPE; /* Bug 5436420 */
     l_project_id_cache             PA_PROJECTS_ALL.PROJECT_ID%TYPE := -1; /* Bug 5441891 */
     l_transaction_source_cache     PA_TRANSACTION_SOURCES.TRANSACTION_SOURCE%TYPE := 'NULL'; /* Bug 5441891 */
     l_commit_count                 NUMBER := 0; /* Bug 5501593 */
/* R12 Changes - End */
  BEGIN
/* R12 Changes - Start */

	IF X_module = 'PATXMAS' THEN
	    G_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
	    G_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
	    G_PROG_APPL_ID := FND_GLOBAL.PROG_APPL_ID;
	END IF;

        IF p_org_id IS NOT NULL THEN
            pa_multi_currency.init ;
        END IF;


/* *** Opens a cursor for processing ********************************************************* */

      v_cursor_adj_id := dbms_sql.open_cursor ;

/* ******************************************************************************************* */


/* ** The following section constructs character strings that are used to create a query ***** */

      select_clause := 'SELECT'
                    || ' ei.expenditure_item_id'
                    || ',ei.org_id'
                    || ',ei.project_id'
                    || ',ei.net_zero_adjustment_flag'
                    || ',ei.converted_flag'
                    || ',e.expenditure_status_code'
                    || ',ei.burden_sum_dest_run_id'
                    || ',ei.document_header_id'
                    || ',ei.transaction_source'
                    || ',ei.document_type'
                    || ',ei.document_distribution_type'
                    || ',ei.document_payment_id'
                    || ',ei.source_expenditure_item_id'
                    || ',ei.system_linkage_function'
                    || ',ei.acct_currency_code'
                    || ',ei.denom_currency_code'
                    || ',ei.denom_tp_currency_code'
                    || ',ei.projfunc_currency_code'
                    || ',ei.cc_cross_charge_code'
                    || ',ei.adjusted_expenditure_item_id'
                    || ',ei.orig_transaction_reference'
                    || ',ei.expenditure_item_date'
                    || ',ei.billable_flag'
                    || ',ei.task_id'
                    || ',ei.expenditure_type'
                    || ',ei.vendor_id'
                    || ',nvl(ei.override_to_organization_id, e.incurred_by_organization_id)'
                    || ',e.incurred_by_person_id'
                    || ',ei.document_line_number'
                    || ',ei.document_distribution_id'
                    || ',ei.project_currency_code'
                    || ',ei.tp_amt_type_code'
                    || ',ei.organization_id';

      from_clause := ' FROM'
                  || ' pa_expenditure_items_all ei'
                  || ',pa_expenditures_all e';

      where_clause := ' WHERE ei.expenditure_id = e.expenditure_id';

      if p_org_id is not null then
            where_clause := where_clause || ' AND ei.org_id = :org_id';
      end if;

      if x_project_id is not null then
            where_clause := where_clause || ' AND ei.project_id = :project_id';
            if x_task_id is not null then
                  where_clause := where_clause || ' AND ei.task_id = :task_id';
            end if;
            if p_award_id is not null then
                  where_clause := where_clause
                               || ' AND ei.expenditure_item_id in ('
                               || ' SELECT adl.expenditure_item_id'
                               || '   FROM gms_award_distributions adl'
                               || '  WHERE adl.adl_line_num = 1'
                               || '    AND adl.document_type = ''EXP'''
                               || '    AND adl.adl_status = ''A'''
                               || '    AND adl.project_id = :project_id'
                               || '    AND adl.award_id = :award_id )';
            end if;
      end if;

      if x_expenditure_item_id is not null then
            where_clause := where_clause || ' AND ei.expenditure_item_id = :expenditure_item_id';
      end if;

      if x_inc_by_org_id is not null then
            where_clause := where_clause || ' AND (e.incurred_by_organization_id = :inc_by_org_id' ||
                                            ' OR  (e.incurred_by_organization_id is NULL' ||
                                            ' AND  ei.override_to_organization_id = :inc_by_org_id ))';
      end if ;

      if x_system_linkage is not null then
            where_clause := where_clause || ' AND ei.system_linkage_function = :system_linkage';
      end if;

      if x_expenditure_type is not null then
            where_clause := where_clause || ' AND ei.expenditure_type = :expenditure_type';
      end if;

      if x_ei_date_low is not null then
            where_clause := where_clause || ' AND ei.expenditure_item_date >= trunc(:ei_date_low)';
      end if;

      if x_ei_date_high is not null then
            where_clause := where_clause || ' AND ei.expenditure_item_date <= trunc(:ei_date_high)';
      end if;

      if x_expenditure_catg is not null then
            where_clause := where_clause || ' AND 1 = (SELECT 1'
                                         || '            FROM pa_expenditure_types et'
                                         || '           WHERE et.expenditure_type = ei.expenditure_type'
                                         || '             AND et.expenditure_category = :expenditure_catg)';
      end if;

      if x_ex_end_date_low is not null then
            where_clause := where_clause || ' AND e.expenditure_ending_date >= trunc(pa_utils.getweekending(:ex_end_date_low) - 6)';
      end if;

      if x_ex_end_date_high is not null then
            where_clause := where_clause || ' AND e.expenditure_ending_date <= trunc(pa_utils.getweekending(:ex_end_date_high))';
      end if;

      if x_expenditure_group is not null then
            where_clause := where_clause || ' AND e.expenditure_group = :expenditure_group';
      end if;

      if x_transaction_source is not NULL then
            where_clause := where_clause || ' AND ei.transaction_source = :transaction_source';
      end if;

      if p_work_type_id is not null then
            where_clause := where_clause || ' AND ei.work_type_id = :work_type_id';
      end If;

      if x_cost_distributed_flag is not null then
            where_clause := where_clause || ' AND ei.cost_distributed_flag = :cost_distributed_flag';
      end if;

      if x_billable_flag is not null then
            where_clause := where_clause || ' AND 1 = (SELECT 1'
                                         || '            FROM pa_project_types_all pt'
                                         || '               , pa_projects_all p'
                                         || '           WHERE p.project_type = pt.project_type'
                                         || '             AND p.org_id = pt.org_id'
                                         || '             AND p.project_id = ei.project_id'
                                         || '             AND pt.project_type_class_code <> ''CAPITAL'')'
                                         || ' AND ei.billable_flag = :billable_flag';
      end if;

      if x_hold_flag is not null then
            if x_hold_flag = 'B' then
                  where_clause := where_clause || ' AND ei.bill_hold_flag in ( ''Y'', ''O'')';
            else
                  where_clause := where_clause || ' and ei.bill_hold_flag = :hold_flag';
            end if;
      end if;

      if x_bill_status is not null then
            if x_bill_status = 'Y' then
                  where_clause := where_clause || ' AND (ei.event_num is not null'
                                               || ' OR   EXISTS (SELECT 1'
                                               || '                FROM pa_cust_rev_dist_lines_all r'
                                               || '               WHERE r.expenditure_item_id = ei.expenditure_item_id'
                                               || '                 AND r.draft_invoice_num is not null'
                                               || '              HAVING sum(nvl(r.bill_trans_bill_amount, 0)) <> 0'
                                               || '            GROUP BY r.expenditure_item_id))';
            elsif x_bill_status = 'N' then
                  where_clause := where_clause || ' AND (ei.event_num is not null'
                                               || ' AND  NOT EXISTS (SELECT 1'
                                               || '                    FROM pa_cust_rev_dist_lines_all r'
                                               || '                   WHERE r.expenditure_item_id = ei.expenditure_item_id'
                                               || '                     AND r.draft_invoice_num is not null'
                                               || '                  HAVING sum(nvl(r.bill_trans_bill_amount, 0)) <> 0'
                                               || '                GROUP BY r.expenditure_item_id))';
            end if;
      end if;

      if x_revenue_distributed_flag is not null then
            where_clause := where_clause || ' AND 1 = (SELECT 1'
                                         || '            FROM pa_project_types_all pt'
                                         || '               , pa_projects_all p'
                                         || '           WHERE p.project_type = pt.project_type'
                                         || '             AND p.org_id = pt.org_id'
                                         || '             AND p.project_id = ei.project_id'
                                         || '             AND pt.project_type_class_code <> ''CAPITAL'')'
                                         || ' AND ei.revenue_distributed_flag = :revenue_distributed_flag';
      end if;

      if X_inc_by_person_id is not null then
            where_clause := where_clause || ' AND e.incurred_by_person_id = :incurred_by_person_id';
      end if ;

      if X_job_id  is not null then
            where_clause := where_clause || ' AND ei.job_id  = :job_id';
      end if;

      if p_assignment_id is not null then
            where_clause := where_clause ||' AND ei.assignment_id = :assignment_id';
      end if;

      if X_nl_resource_org_id is not null then
            where_clause := where_clause || ' AND ei.organization_id = :nl_resource_org_id';
      end if;

      if p_wip_resource_id is not null then
            where_clause := where_clause || ' AND ei.wip_resource_id = :wip_resource_id';
      end if;

      if p_inventory_item_id is not null then
            where_clause := where_clause || ' AND ei.inventory_item_id = :inventory_item_id';
      end if;

      if x_vendor_id is not null then
            where_clause := where_clause || ' and e.vendor_id = :vendor_id';
      end if;

      IF p_invoice_id IS NOT NULL THEN
            IF x_transaction_source IS NULL THEN
                  where_clause := where_clause ||
                         ' and ei.transaction_source in ' ||
                         ' (''AP INVOICE'',''INTERPROJECT_AP_INVOICES'',''AP VARIANCE'',''AP NRTAX'',''AP DISCOUNTS''' ||
                         ' ,''AP EXPENSE'',''CSE_IPV_ADJUSTMENT'',''CSE_IPV_ADJUSTMENT_DEPR'',''AP ERV'') ';
            END IF;
		where_clause := where_clause || ' AND ei.document_header_id = :invoice_id ';

            IF p_include_related_tax_lines = 'Y' THEN
                  where_clause := where_clause ||
                               ' and ei.document_distribution_id in' ||
                               ' ( select apdist.invoice_distribution_id' ||
                               '     from ap_invoice_distributions_all apdist' ||
                               '    where apdist.invoice_id = :invoice_id' ||
                               '      and apdist.invoice_line_number = :invoice_line_number' ||
                               '   union all' ||
                               '   select apdist1.invoice_distribution_id' ||
                               '     from ap_invoice_distributions_all apdist1' ||
                               '    where apdist1.charge_Applicable_to_dist_id in' ||
                               '         ( select apdist2.invoice_distribution_id' ||
                               '             from ap_invoice_distributions_all apdist2' ||
                               '            where apdist2.invoice_id = :invoice_id' ||
                               '              and apdist2.invoice_line_number = :invoice_line_number)' ||
                               '      and apdist1.line_type_lookup_code in (''NONREC_TAX'', ''TIPV'', ''TERV'', ''TRV''))'; /* Bug 5403294 */
            ELSIF p_invoice_line_number IS NOT NULL THEN
                  where_clause := where_clause || ' and ei.document_line_number = :invoice_line_number';
            END IF;
	END IF;

      IF p_receipt_number IS NOT NULL THEN
            IF x_transaction_source IS NULL THEN
                  where_clause := where_clause ||
                               ' and ei.transaction_source in ' ||
                               ' (''PO RECEIPT'',''PO RECEIPT NRTAX'',''PO RECEIPT NRTAX PRICE ADJ'',''PO RECEIPT PRICE ADJ''' ||
                               ' ,''CSE_PO_RECEIPT'',''CSE_PO_RECEIPT_DEPR'') ';
            END IF;
		where_clause := where_clause ||
                         ' and ei.document_distribution_id in' ||
                         ' (select rcvtxn.transaction_id' ||
                         ' from rcv_shipment_headers rcvhead' ||
                         ' , rcv_transactions rcvtxn' ||
                         ' where rcvhead.shipment_header_id =' ||
                         ' rcvtxn.shipment_header_id' ||
                         ' and rcvhead.receipt_num = :receipt_number)';
      END IF;

	IF p_check_id IS NOT NULL THEN
            where_clause := where_clause ||
                         ' and ei.document_payment_id in' ||
                         ' (select invoice_payment_id' ||
                         ' from ap_invoice_payments_all' ||
                         ' where check_id = :check_id) ';
      END IF;

      IF p_rev_exp_items_req_adjust = 'Y' THEN
            where_clause := where_clause
                         || ' AND ei.transaction_source IN (''AP VARIANCE'',''AP INVOICE'',''AP NRTAX'',''AP DISCOUNTS'',''AP ERV'''
                         || '                              ,''INTERCOMPANY_AP_INVOICES'',''INTERPROJECT_AP_INVOICES'',''AP EXPENSE'''
                         || '                              ,''PO RECEIPT'',''PO RECEIPT NRTAX'''
                         || '                              ,''PO RECEIPT NRTAX PRICE ADJ'''
                         || '                              ,''PO RECEIPT PRICE ADJ'')'
                         || ' AND EXISTS (select NULL'
                         || '               from pa_cost_distribution_lines cdl1'
                         || '              where cdl1.expenditure_item_id = ei.expenditure_item_id'
                         || '                and cdl1.line_num = 1'
                         || '                and NVL(cdl1.reversed_flag,''N'') <> ''Y'')'
                         || ' AND ei.net_zero_adjustment_flag = ''N'''
                         || ' AND ei.transferred_from_exp_item_id IS NULL'
                         || ' AND pa_adjustments.is_orphaned_src_sys_reversal(ei.document_distribution_id,ei.transaction_source) = ''Y'''; /* 4901129 */
      END IF;

      if  X_cc_code_to_be_determined <> 'N'
      or  X_cc_code_not_crosscharged <> 'XX'
      or  X_cc_code_intra_ou         <> 'XX'
      or  X_cc_code_inter_ou         <> 'XX'
      or  X_cc_code_intercompany     <> 'XX' then
            where_clause := where_clause ||
                          ' AND ei.cc_cross_charge_type IN (:cc_code_not_crosscharged, :cc_code_intra_ou,' ||
                          ' :cc_code_inter_ou, :cc_code_intercompany)';
            if X_cc_code_to_be_determined = 'Y' then
                  where_clause := where_clause || ' OR ei.cc_cross_charge_type IS NULL';
            end if;
      end if;

      if  X_cc_type_no_processing <> 'Z'
      or  X_cc_type_b_and_l       <> 'Z'
      or  X_cc_type_ic_billing    <> 'Z' then
            where_clause := where_clause
                         || ' AND ei.cc_cross_charge_code IN'
                         || ' (:cc_type_no_processing, :cc_type_b_and_l, :cc_type_ic_billing)';
      end if;

      if  X_cc_bl_distributed_code is not null then
            where_clause := where_clause || ' AND ei.cc_bl_distributed_code = :cc_bl_distributed_code';
      end if;

      if  X_cc_ic_processed_code is not null then
            where_clause := where_clause || ' AND ei.cc_ic_processed_code = :cc_ic_processed_code';
      end if;

      if  X_cc_prvdr_organization_id is not null then
            where_clause := where_clause || ' AND ei.cc_prvdr_organization_id = :cc_prvdr_organization_id';
      end if;

      if  X_cc_prvdr_ou is not null then
            where_clause := where_clause || ' AND ei.org_id = :cc_prvdr_ou';
      end if;

      if  p_start_gl_date is not null
      and p_end_gl_date is not null then
            where_clause := where_clause
                         || ' AND pa_expenditures_utils.Get_Latest_GL_Date(ei.expenditure_item_id)'
                         || ' BETWEEN trunc(:start_gl_date) AND trunc(:end_gl_date)';
      elsif p_start_gl_date is not null then
            where_clause := where_clause
                         || ' AND pa_expenditures_utils.Get_Latest_GL_Date(ei.expenditure_item_id) >= trunc(:start_gl_date)';
      elsif p_end_gl_date is not null then
            where_clause := where_clause
                         || ' AND pa_expenditures_utils.Get_Latest_GL_Date(ei.expenditure_item_id) >= trunc(:end_gl_date)';
      end if ;

      if  p_start_pa_date is not null
      and p_end_pa_date is not null then
            where_clause := where_clause
                         || ' AND pa_expenditures_utils.Get_Latest_PA_Date(ei.expenditure_item_id)'
                         || ' BETWEEN trunc(:start_pa_date) AND trunc(:end_pa_date)';
      elsif p_start_pa_date is not null then
            where_clause := where_clause
                         || ' AND pa_expenditures_utils.Get_Latest_PA_Date(ei.expenditure_item_id) >= trunc(:start_pa_date)';
      elsif p_end_pa_date is not null then
            where_clause := where_clause
                         || ' AND pa_expenditures_utils.Get_Latest_PA_Date(ei.expenditure_item_id) >= trunc(:end_pa_date)';
      end if ;

      if  X_cc_recvr_organization_id is not null then
            where_clause := where_clause || ' AND ei.cc_recvr_organization_id = :cc_recvr_organization_id';
      end if;

      if  X_cc_recvr_ou is not null then
            where_clause := where_clause || ' AND ei.recvr_org_id = :cc_recvr_ou';
      end if;

      if  p_recvr_start_gl_date is not null
      and p_recvr_end_gl_date is not null then
            where_clause := where_clause
                         || ' AND pa_expenditures_utils.Get_Latest_GL_Date(ei.expenditure_item_id)'
                         || ' BETWEEN trunc(:recvr_start_gl_date) AND trunc(:recvr_end_gl_date)';
      elsif p_recvr_start_gl_date is not null then
            where_clause := where_clause
                         || ' AND pa_expenditures_utils.Get_Latest_GL_Date(ei.expenditure_item_id) >= trunc(:recvr_start_gl_date)';
      elsif p_recvr_end_gl_date is not null then
            where_clause := where_clause
                         || ' AND pa_expenditures_utils.Get_Latest_GL_Date(ei.expenditure_item_id) >= trunc(:recvr_end_gl_date)';
      end if ;

      if  p_recvr_start_pa_date is not null
      and p_recvr_end_pa_date is not null then
            where_clause := where_clause
                         || ' AND pa_expenditures_utils.Get_Latest_PA_Date(ei.expenditure_item_id)'
                         || ' BETWEEN trunc(:recvr_start_pa_date) AND trunc(:recvr_end_pa_date)';
      elsif p_recvr_start_pa_date is not null then
            where_clause := where_clause
                         || ' AND pa_expenditures_utils.Get_Latest_PA_Date(ei.expenditure_item_id) >= trunc(:recvr_start_pa_date)';
      elsif p_recvr_end_pa_date is not null then
            where_clause := where_clause
                         || ' AND pa_expenditures_utils.Get_Latest_PA_Date(ei.expenditure_item_id) >= trunc(:recvr_end_pa_date)';
      end if ;

      if x_capitalizable_flag is not null then
            where_clause := where_clause || ' AND 1 = (SELECT 1'
                                         || '            FROM pa_project_types_all pt'
                                         || '               , pa_projects_all p'
                                         || '           WHERE p.project_type = pt.project_type'
                                         || '             AND p.org_id = pt.org_id'
                                         || '             AND p.project_id = ei.project_id'
                                         || '             AND pt.project_type_class_code = ''CAPITAL'')'
                                         || ' AND ei.billable_flag = :capitalizable_flag';
      end if;

      if x_grouped_cip_flag is not null then
            where_clause := where_clause || ' AND 1 = (SELECT 1'
                                         || '            FROM pa_project_types_all pt'
                                         || '               , pa_projects_all p'
                                         || '           WHERE p.project_type = pt.project_type'
                                         || '             AND p.org_id = pt.org_id'
                                         || '             AND p.project_id = ei.project_id'
                                         || '             AND pt.project_type_class_code = ''CAPITAL'')'
                                         || ' AND 1 = (SELECT 1'
                                         || '            FROM pa_tasks t'
                                         || '           WHERE t.task_id = ei.task_id'
                                         || '             AND t.retirement_cost_flag = ''N'')'
                                         || ' AND ei.revenue_distributed_flag = :grouped_cip_flag';
      end if;

      if p_grouped_rwip_flag is not null then
            where_clause := where_clause || ' AND 1 = (SELECT 1'
                                         || '            FROM pa_project_types_all pt'
                                         || '               , pa_projects_all p'
                                         || '           WHERE p.project_type = pt.project_type'
                                         || '             AND p.org_id = pt.org_id'
                                         || '             AND p.project_id = ei.project_id'
                                         || '             AND pt.project_type_class_code = ''CAPITAL'')'
                                         || ' AND 1 = (SELECT 1'
                                         || '            FROM pa_tasks t'
                                         || '           WHERE t.task_id = ei.task_id'
                                         || '             AND t.retirement_cost_flag = ''Y'')'
                                         || ' AND ei.revenue_distributed_flag = :grouped_rwip_flag';
      end if;

      if p_expensed_flag = 'Y' then /* Bug 5393328 */
            where_clause := where_clause || ' AND 1 = (SELECT 1'
                                         || '            FROM pa_project_types_all pt'
                                         || '               , pa_projects_all p'
                                         || '           WHERE p.project_type = pt.project_type'
                                         || '             AND p.org_id = pt.org_id'
                                         || '             AND p.project_id = ei.project_id'
                                         || '             AND pt.project_type_class_code = ''CAPITAL'')'
                                         || ' AND 1 = (SELECT 1'
                                         || '            FROM pa_tasks t'
                                         || '           WHERE t.task_id = ei.task_id'
                                         || '             AND t.billable_flag = ''N'''
                                         || '             AND t.retirement_cost_flag = ''N'')';
      end if;

      if p_capital_event_number = -1 then
           where_clause := where_clause || ' AND ei.capital_event_id = -1';
      elsif p_capital_event_number is not null then
           where_clause := where_clause || ' AND EXISTS ('
                                        || '       SELECT null'
                                        || '         FROM pa_capital_events'
                                        || '        WHERE capital_event_number = :capital_event_number'
                                        || '          AND project_id = :project_id';
      end if;

      if x_net_zero_adjust_flag = 'Y' then
            where_clause := where_clause || ' AND NVL(ei.net_zero_adjustment_flag, ''N'') <> ''Y''';
      end if;


      v_reserve_rec  := ' FOR UPDATE OF ei.expenditure_item_id NOWAIT';


      dbms_sql.parse( v_cursor_adj_id
                    , select_clause || from_clause || where_clause -- || v_reserve_rec - Commenting for bug 5501593
                    , dbms_sql.v7);


      if p_org_id is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':org_id', p_org_id);
      end if;

      if x_project_id is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':project_id', x_project_id);
            if x_task_id is not null then
                  dbms_sql.bind_variable(v_cursor_adj_id, ':task_id', x_task_id);
            end if;
            if p_award_id is not null then
                  dbms_sql.bind_variable(v_cursor_adj_id,':award_id', p_award_id);
            end if;
      end if;

      if x_expenditure_item_id is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':expenditure_item_id', x_expenditure_item_id);
      end if;

      if x_inc_by_org_id is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':inc_by_org_id', x_inc_by_org_id);
      end if ;

      if x_system_linkage is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':system_linkage', x_system_linkage);
      end if;

      if x_expenditure_type is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':expenditure_type', x_expenditure_type);
      end if;

      if x_ei_date_low is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':ei_date_low', x_ei_date_low);
      end if;

      if x_ei_date_high is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':ei_date_high', x_ei_date_high);
      end if;

      if x_expenditure_catg is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':expenditure_catg', x_expenditure_catg);
      end if;

      if x_ex_end_date_low is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':ex_end_date_low', x_ex_end_date_low);
      end if;

      if x_ex_end_date_high is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':ex_end_date_high', x_ex_end_date_high);
      end if;

      if x_expenditure_group is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':expenditure_group', x_expenditure_group);
      end if;

      if x_transaction_source is not NULL then
            dbms_sql.bind_variable(v_cursor_adj_id, ':transaction_source', x_transaction_source);
      end if;

      if p_work_type_id is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':work_type_id', p_work_type_id);
      end If;

      if x_cost_distributed_flag is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':cost_distributed_flag', x_cost_distributed_flag);
      end if;

      if x_billable_flag is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':billable_flag', x_billable_flag);
      end if;

      if x_hold_flag is not null then
            if x_hold_flag <> 'B' then
                  dbms_sql.bind_variable(v_cursor_adj_id, ':hold_flag', x_hold_flag);
            end if;
      end if;

      if x_revenue_distributed_flag is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':revenue_distributed_flag', x_revenue_distributed_flag);
      end if;

      if X_inc_by_person_id is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':incurred_by_person_id', X_inc_by_person_id);
      end if ;

      if X_job_id  is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':job_id', X_job_id);
      end if;

      if p_assignment_id is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':assignment_id', p_assignment_id);
      end if;

      if X_nl_resource_org_id is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':nl_resource_org_id', X_nl_resource_org_id);
      end if;

      if p_wip_resource_id is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':wip_resource_id', p_wip_resource_id);
      end if;

      if p_inventory_item_id is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':inventory_item_id', p_inventory_item_id);
      end if;

      if x_vendor_id is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':vendor_id', x_vendor_id);
      end if;

      IF p_invoice_id IS NOT NULL THEN
		dbms_sql.bind_variable(v_cursor_adj_id, ':invoice_id', p_invoice_id);
            IF p_invoice_line_number IS NOT NULL THEN
                  dbms_sql.bind_variable(v_cursor_adj_id, ':invoice_line_number', p_invoice_line_number);
            END IF;
	END IF;

      IF p_receipt_number IS NOT NULL THEN
		dbms_sql.bind_variable(v_cursor_adj_id, ':receipt_number', p_receipt_number);
      END IF;

	IF p_check_id IS NOT NULL THEN
            dbms_sql.bind_variable(v_cursor_adj_id, ':check_id', p_check_id);
      END IF;

      if  X_cc_code_to_be_determined <> 'N'
      or  X_cc_code_not_crosscharged <> 'XX'
      or  X_cc_code_intra_ou         <> 'XX'
      or  X_cc_code_inter_ou         <> 'XX'
      or  X_cc_code_intercompany     <> 'XX' then
            dbms_sql.bind_variable(v_cursor_adj_id, ':cc_code_not_crosscharged', X_cc_code_not_crosscharged);
            dbms_sql.bind_variable(v_cursor_adj_id, ':cc_code_intra_ou', X_cc_code_intra_ou);
            dbms_sql.bind_variable(v_cursor_adj_id, ':cc_code_inter_ou', X_cc_code_inter_ou);
            dbms_sql.bind_variable(v_cursor_adj_id, ':cc_code_intercompany', X_cc_code_intercompany);
      end if;

      if  X_cc_type_no_processing <> 'Z'
      or  X_cc_type_b_and_l       <> 'Z'
      or  X_cc_type_ic_billing    <> 'Z' then
            dbms_sql.bind_variable(v_cursor_adj_id, ':cc_type_no_processing', X_cc_type_no_processing);
            dbms_sql.bind_variable(v_cursor_adj_id, ':cc_type_b_and_l', X_cc_type_b_and_l);
            dbms_sql.bind_variable(v_cursor_adj_id, ':cc_type_ic_billing', X_cc_type_ic_billing);
      end if;

      if  X_cc_bl_distributed_code is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':cc_bl_distributed_code', X_cc_bl_distributed_code);
      end if;

      if  X_cc_ic_processed_code is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':cc_ic_processed_code', X_cc_ic_processed_code);
      end if;

      if  X_cc_prvdr_organization_id is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':cc_prvdr_organization_id', X_cc_prvdr_organization_id);
      end if;

      if  X_cc_prvdr_ou is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':cc_prvdr_ou', X_cc_prvdr_ou);
      end if;

      if p_start_gl_date is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':start_gl_date', p_start_gl_date);
      end if;

      if p_end_gl_date is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':end_gl_date', p_end_gl_date);
      end if ;

      if p_start_pa_date is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':start_pa_date', p_start_pa_date);
      end if;

      if p_end_pa_date is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':end_pa_date', p_end_pa_date);
      end if ;

      if  X_cc_recvr_organization_id is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':cc_recvr_organization_id', X_cc_recvr_organization_id);
      end if;

      if  X_cc_recvr_ou is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':cc_recvr_ou', X_cc_recvr_ou);
      end if;

      if p_recvr_start_gl_date is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':recvr_start_gl_date', p_recvr_start_gl_date);
      end if;

      if p_recvr_end_gl_date is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':recvr_end_gl_date', p_recvr_end_gl_date);
      end if ;

      if p_recvr_start_pa_date is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':recvr_start_pa_date', p_recvr_start_pa_date);
      end if;

      if p_recvr_end_pa_date is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':recvr_end_pa_date', p_recvr_end_pa_date);
      end if ;

      if x_capitalizable_flag is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':capitalizable_flag', x_capitalizable_flag);
      end if;

      if x_grouped_cip_flag is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':grouped_cip_flag', x_grouped_cip_flag);
      end if;

      if p_grouped_rwip_flag is not null then
            dbms_sql.bind_variable(v_cursor_adj_id, ':grouped_rwip_flag', p_grouped_rwip_flag);
      end if;

      if p_capital_event_number is not null then
           if p_capital_event_number <> -1 then
                 dbms_sql.bind_variable(v_cursor_adj_id, ':capital_event_number', p_capital_event_number);
           end if;
      end if;


      dbms_sql.define_column(v_cursor_adj_id, 1,  v_expenditure_item_id);
      dbms_sql.define_column(v_cursor_adj_id, 2,  v_exp_org_id);
      dbms_sql.define_column(v_cursor_adj_id, 3,  l_project_id);
      dbms_sql.define_column(v_cursor_adj_id, 4,  l_net_zero_adjustment_flag, 1);
      dbms_sql.define_column(v_cursor_adj_id, 5,  l_converted_flag, 1);
      dbms_sql.define_column(v_cursor_adj_id, 6,  l_expenditure_status_code, 30);
      dbms_sql.define_column(v_cursor_adj_id, 7,  l_burden_sum_dest_run_id);
      dbms_sql.define_column(v_cursor_adj_id, 8,  l_document_header_id);
      dbms_sql.define_column(v_cursor_adj_id, 9,  l_transaction_source, 30);
      dbms_sql.define_column(v_cursor_adj_id, 10, l_document_type, 30);
      dbms_sql.define_column(v_cursor_adj_id, 11, l_document_distribution_type, 30);
      dbms_sql.define_column(v_cursor_adj_id, 12, l_document_payment_id);
      dbms_sql.define_column(v_cursor_adj_id, 13, l_source_expenditure_item_id);
      dbms_sql.define_column(v_cursor_adj_id, 14, v_system_linkage, 30);
      dbms_sql.define_column(v_cursor_adj_id, 15, l_acct_currency_code, 15);
      dbms_sql.define_column(v_cursor_adj_id, 16, v_denom_currency_code, 15);
      dbms_sql.define_column(v_cursor_adj_id, 17, v_denom_tp_currency_code, 15);
      dbms_sql.define_column(v_cursor_adj_id, 18, l_projfunc_currency_code, 15);
      dbms_sql.define_column(v_cursor_adj_id, 19, v_cc_code, 1);
      dbms_sql.define_column(v_cursor_adj_id, 20, l_adjusted_expenditure_item_id);
      dbms_sql.define_column(v_cursor_adj_id, 21, l_orig_transaction_reference, 30);
      dbms_sql.define_column(v_cursor_adj_id, 22, v_exp_item_date);
      dbms_sql.define_column(v_cursor_adj_id, 23, l_billable_flag, 1);
      dbms_sql.define_column(v_cursor_adj_id, 24, v_task_id);
      dbms_sql.define_column(v_cursor_adj_id, 25, v_exp_type, 30);
      dbms_sql.define_column(v_cursor_adj_id, 26, l_vendor_id);
      dbms_sql.define_column(v_cursor_adj_id, 27, v_exp_organization_id);
      dbms_sql.define_column(v_cursor_adj_id, 28, v_incurred_by_person_id);
      dbms_sql.define_column(v_cursor_adj_id, 29, l_document_line_number);
      dbms_sql.define_column(v_cursor_adj_id, 30, l_document_distribution_id);
      dbms_sql.define_column(v_cursor_adj_id, 31, v_project_currency_code, 15);
      dbms_sql.define_column(v_cursor_adj_id, 32, l_tp_amt_type_code, 30);
      dbms_sql.define_column(v_cursor_adj_id, 33, v_nlr_organization_id);






    IF ( X_module IN ( 'PAXPRRPE','PAXPREPR','PAXBAUPD','PATXMAS') ) THEN
     v_open_cursor := dbms_sql.execute(v_cursor_adj_id);
        LOOP
          /* Fetch the rows into the buffer    ************************* */
	  IF P_DEBUG_MODE  THEN
	     print_message('get_denom_curr_code: ' || 'Fetch the rows into the buffer');
	  END IF;

          If dbms_sql.fetch_rows(v_cursor_adj_id) = 0 then
              --Exit the loop once all the records are fetched

             exit ;
          end if ;

          /*** Retrieve the rows from the buffer into PLSQL variables ****/
      dbms_sql.column_value(v_cursor_adj_id, 1,  v_expenditure_item_id);
      dbms_sql.column_value(v_cursor_adj_id, 2,  v_exp_org_id);
      dbms_sql.column_value(v_cursor_adj_id, 3,  l_project_id);
      dbms_sql.column_value(v_cursor_adj_id, 4,  l_net_zero_adjustment_flag);
      dbms_sql.column_value(v_cursor_adj_id, 5,  l_converted_flag);
      dbms_sql.column_value(v_cursor_adj_id, 6,  l_expenditure_status_code);
      dbms_sql.column_value(v_cursor_adj_id, 7,  l_burden_sum_dest_run_id);
      dbms_sql.column_value(v_cursor_adj_id, 8,  l_document_header_id);
      dbms_sql.column_value(v_cursor_adj_id, 9,  l_transaction_source);
      dbms_sql.column_value(v_cursor_adj_id, 10, l_document_type);
      dbms_sql.column_value(v_cursor_adj_id, 11, l_document_distribution_type);
      dbms_sql.column_value(v_cursor_adj_id, 12, l_document_payment_id);
      dbms_sql.column_value(v_cursor_adj_id, 13, l_source_expenditure_item_id);
      dbms_sql.column_value(v_cursor_adj_id, 14, v_system_linkage);
      dbms_sql.column_value(v_cursor_adj_id, 15, l_acct_currency_code);
      dbms_sql.column_value(v_cursor_adj_id, 16, v_denom_currency_code);
      dbms_sql.column_value(v_cursor_adj_id, 17, v_denom_tp_currency_code);
      dbms_sql.column_value(v_cursor_adj_id, 18, l_projfunc_currency_code);
      dbms_sql.column_value(v_cursor_adj_id, 19, v_cc_code);
      dbms_sql.column_value(v_cursor_adj_id, 20, l_adjusted_expenditure_item_id);
      dbms_sql.column_value(v_cursor_adj_id, 21, l_orig_transaction_reference);
      dbms_sql.column_value(v_cursor_adj_id, 22, v_exp_item_date);
      dbms_sql.column_value(v_cursor_adj_id, 23, l_billable_flag);
      dbms_sql.column_value(v_cursor_adj_id, 24, v_task_id);
      dbms_sql.column_value(v_cursor_adj_id, 25, v_exp_type);
      dbms_sql.column_value(v_cursor_adj_id, 26, l_vendor_id);
      dbms_sql.column_value(v_cursor_adj_id, 27, v_exp_organization_id);
      dbms_sql.column_value(v_cursor_adj_id, 28, v_incurred_by_person_id);
      dbms_sql.column_value(v_cursor_adj_id, 29, l_document_line_number);
      dbms_sql.column_value(v_cursor_adj_id, 30, l_document_distribution_id);
      dbms_sql.column_value(v_cursor_adj_id, 31, v_project_currency_code);
      dbms_sql.column_value(v_cursor_adj_id, 32, l_tp_amt_type_code);
      dbms_sql.column_value(v_cursor_adj_id, 33, v_nlr_organization_id);

/* Bug 5441891 - Start */
      IF l_project_id  <> l_project_id_cache THEN
        SELECT pt.project_type_class_code
             , p.project_status_code
          INTO v_project_type_class_code
             , l_project_status_code
          FROM pa_project_types_all pt
             , pa_projects_all p
         WHERE p.project_type = pt.project_type
           AND p.org_id = pt.org_id
           AND p.project_id = l_project_id;
        l_project_id_cache := l_project_id;
      END IF;

      IF l_transaction_source IS NULL THEN
        l_allow_adjustments_flag := NULL;
        l_gl_accounted := NULL;
      ELSE
        IF l_transaction_source <> l_transaction_source_cache THEN
          SELECT tr.allow_adjustments_flag
               , tr.gl_accounted_flag
            INTO l_allow_adjustments_flag
               , l_gl_accounted
            FROM pa_transaction_sources tr
           WHERE tr.transaction_source = l_transaction_source;
          l_transaction_source_cache := l_transaction_source;
        END IF;
      END IF;
/* Bug 5441891 - End */

/* R12 Changes Start - Set org context if not already set */
      IF p_org_id IS NULL THEN
          IF v_exp_org_id <> l_old_org_id THEN
              PA_MOAC_UTILS.SET_POLICY_CONTEXT('S',v_exp_org_id);
              l_old_org_id := v_exp_org_id;
          END IF;
          pa_multi_currency.init;
      END IF;
/* R12 Changes End */

           v_allow_adjustments := 'N';

/* Bug 5501593 - Checking if the expenditure can be locked for update or not */
           DECLARE
               l_dummy VARCHAR2(1);
               row_locked EXCEPTION;
               PRAGMA EXCEPTION_INIT(row_locked, -54);
           BEGIN
               SELECT NULL
               INTO l_dummy
               FROM pa_expenditure_items_all
               WHERE expenditure_item_id = v_expenditure_item_id
               FOR UPDATE OF expenditure_item_id NOWAIT;
           EXCEPTION
               WHEN row_locked THEN
                   v_allow_adjustments := 'PA_ADJ_EXP_ITEMS_LOCKED';
           END;
/* Bug 5501593 - End */

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'BILLABLE RECLASS'
                             , 'NON-BILLABLE RECLASS'
                             , 'BILLING HOLD'
                             , 'ONE-TIME BILLING HOLD'
                             , 'BILLING HOLD RELEASE'
                             /*, 'COST AND REV RECALC' for bug 8282579 */
                             , 'REVENUE RECALC')
         and v_project_type_class_code = 'CAPITAL' then
             v_allow_adjustments := 'PA_TR_APE_ITEM_IN_CAP_PROJ';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'BILLABLE RECLASS'
                             , 'NON-BILLABLE RECLASS'
                             , 'BILLING HOLD'
                             , 'ONE-TIME BILLING HOLD'
                             , 'BILLING HOLD RELEASE'
                             /*, 'COST AND REV RECALC' for bug 8282579 */
                             , 'REVENUE RECALC')
         and v_project_type_class_code = 'INDIRECT'
         and not pa_gms_api.is_sponsored_project(l_project_id) then
             v_allow_adjustments := 'PA_TR_APE_ITEM_IN_IND_PROJ';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'CAPITALIZABLE RECLASS'
                             , 'NON-CAPITALIZABLE RECLASS')
         and v_project_type_class_code <> 'CAPITAL' then
             v_allow_adjustments := 'PA_TR_APE_ITEM_NOT_IN_CAP_PROJ';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'BILLABLE RECLASS'
                             , 'NON-BILLABLE RECLASS'
                             , 'BILLING HOLD'
                             , 'ONE-TIME BILLING HOLD'
                             , 'BILLING HOLD RELEASE'
                             , 'CAPITALIZABLE RECLASS'
                             , 'NON-CAPITALIZABLE RECLASS'
                             , 'REPROCESS CROSS CHARGE'
                             , 'CHANGE FUNC ATTRIBUTE'
                             , 'CHANGE PROJ FUNC ATTRIBUTE'
                             , 'CHANGE TP ATTRIBUTE'
                             , 'CHANGE WORK TYPE ATTRIBUTE'
                             , 'MARK NO CC PROCESS'
                             , 'RAW COST RECALC'
                             , 'INDIRECT COST RECALC'
                             , 'COST AND REV RECALC'
                             , 'REVENUE RECALC'
                             , 'PROJECT OR TASK CHANGE')
         and l_net_zero_adjustment_flag = 'Y' then
             v_allow_adjustments := 'PA_TR_APE_CANT_ADJ_NET_ZERO';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'BILLABLE RECLASS'
                             , 'NON-BILLABLE RECLASS'
                             , 'CAPITALIZABLE RECLASS'
                             , 'NON-CAPITALIZABLE RECLASS'
                             , 'REPROCESS CROSS CHARGE'
                             , 'CHANGE FUNC ATTRIBUTE'
                             , 'CHANGE PROJ FUNC ATTRIBUTE'
                             , 'CHANGE TP ATTRIBUTE'
                             , 'CHANGE WORK TYPE ATTRIBUTE'
                             , 'MARK NO CC PROCESS'
                             , 'RAW COST RECALC'
                             , 'INDIRECT COST RECALC'
                             , 'COST AND REV RECALC'
                             , 'REVENUE RECALC'
                             , 'PROJECT OR TASK CHANGE')
         and l_converted_flag = 'Y' then
             v_allow_adjustments := 'PA_TR_APE_CANT_ADJ_CONV';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'BILLABLE RECLASS'
                             , 'NON-BILLABLE RECLASS'
                             , 'CAPITALIZABLE RECLASS'
                             , 'NON-CAPITALIZABLE RECLASS'
                             , 'REPROCESS CROSS CHARGE'
                             , 'CHANGE FUNC ATTRIBUTE'
                             , 'CHANGE PROJ FUNC ATTRIBUTE'
                             , 'CHANGE TP ATTRIBUTE'
                             , 'CHANGE WORK TYPE ATTRIBUTE'
                             , 'MARK NO CC PROCESS'
                             , 'RAW COST RECALC'
                             , 'INDIRECT COST RECALC'
                             , 'COST AND REV RECALC'
                             , 'REVENUE RECALC'
                             , 'PROJECT OR TASK CHANGE')
         and l_expenditure_status_code <> 'APPROVED' then
             v_allow_adjustments := 'PA_TR_APE_CANT_ADJ_NON_APPR';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'BILLABLE RECLASS'
                             , 'NON-BILLABLE RECLASS'
                             , 'CAPITALIZABLE RECLASS'
                             , 'NON-CAPITALIZABLE RECLASS'
                             , 'REPROCESS CROSS CHARGE'
                             , 'CHANGE FUNC ATTRIBUTE'
                             , 'RAW COST RECALC'
                             , 'INDIRECT COST RECALC'
                             , 'COST AND REV RECALC'
                             , 'PROJECT OR TASK CHANGE')
         and l_allow_adjustments_flag = 'N' then
             v_allow_adjustments := 'PA_TR_APE_NO_ADJUST';
         end if;

/* Bug 5364389 - Start */
         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'CHANGE WORK TYPE ATTRIBUTE')
         and l_allow_adjustments_flag = 'N'
         and NVL(PA_UTILS4.get_trxn_work_billabilty(p_dest_work_type_id, NULL),l_billable_flag) <> l_billable_flag then
             v_allow_adjustments := 'PA_TR_APE_NO_ADJUST';
         end if;
/* Bug 5364389 - End */

/* Bug 5579712 - Start */
         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'CHANGE WORK TYPE ATTRIBUTE')
         and v_project_type_class_code = 'INDIRECT' then
           declare
             l_billable_capitalizable_flag pa_work_types_b.billable_capitalizable_flag%TYPE;
           begin
             select billable_capitalizable_flag
               into l_billable_capitalizable_flag
               from pa_work_types_b
              where work_type_id = p_dest_work_type_id;
             if l_billable_capitalizable_flag = 'Y' then
               v_allow_adjustments := 'PA_ADJ_WT_IND_PRJ_NOT_ALLOW';
             end if;
           end;
         end if;
/* Bug 5579712 - End */

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'BILLABLE RECLASS'
                             , 'NON-BILLABLE RECLASS'
                             , 'BILLING HOLD'
                             , 'ONE-TIME BILLING HOLD'
                             , 'BILLING HOLD RELEASE'
                             , 'CAPITALIZABLE RECLASS'
                             , 'NON-CAPITALIZABLE RECLASS'
                             , 'REPROCESS CROSS CHARGE'
                             , 'CHANGE FUNC ATTRIBUTE'
                             , 'CHANGE PROJ FUNC ATTRIBUTE'
                             , 'CHANGE TP ATTRIBUTE'
                             , 'CHANGE WORK TYPE ATTRIBUTE'
                             , 'MARK NO CC PROCESS'
                             , 'RAW COST RECALC'
                             , 'INDIRECT COST RECALC'
                             , 'COST AND REV RECALC'
                             , 'REVENUE RECALC'
                             , 'PROJECT OR TASK CHANGE')
         and pa_project_utils.check_prj_stus_action_allowed(l_project_status_code,'ADJUST_TXNS') <> 'Y' then
             v_allow_adjustments := 'PA_TR_APE_PRJ_STS_NO_ADJUST';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'BILLABLE RECLASS'
                             , 'NON-BILLABLE RECLASS'
                             , 'CAPITALIZABLE RECLASS'
                             , 'NON-CAPITALIZABLE RECLASS'
                             , 'REPROCESS CROSS CHARGE'
                             , 'CHANGE FUNC ATTRIBUTE'
                             , 'CHANGE PROJ FUNC ATTRIBUTE'
                             , 'CHANGE TP ATTRIBUTE'
                             , 'CHANGE WORK TYPE ATTRIBUTE'
                             , 'MARK NO CC PROCESS'
                             , 'RAW COST RECALC'
                             , 'COST AND REV RECALC'
                             , 'PROJECT OR TASK CHANGE')
         and l_burden_sum_dest_run_id IS NOT NULL then
             v_allow_adjustments := 'PA_TR_APE_BURDEN_COST_TR';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'BILLABLE RECLASS'
                             , 'NON-BILLABLE RECLASS'
                             , 'BILLING HOLD'
                             , 'ONE-TIME BILLING HOLD'
                             , 'BILLING HOLD RELEASE'
                             , 'CAPITALIZABLE RECLASS'
                             , 'NON-CAPITALIZABLE RECLASS'
                             , 'REPROCESS CROSS CHARGE'
                             , 'CHANGE PROJ FUNC ATTRIBUTE'
                             , 'CHANGE TP ATTRIBUTE'
                             , 'CHANGE WORK TYPE ATTRIBUTE'
                             , 'MARK NO CC PROCESS'
                             , 'RAW COST RECALC'
                             , 'INDIRECT COST RECALC'
                             , 'COST AND REV RECALC'
                             , 'REVENUE RECALC'
                             , 'PROJECT OR TASK CHANGE')
         and l_transaction_source in ( 'AP INVOICE'
                                     , 'INTERPROJECT_AP_INVOICES'
                                     , 'AP VARIANCE'
                                     , 'AP NRTAX'
                                     , 'AP DISCOUNTS'
                                     , 'AP EXPENSE'
                                     , 'PO RECEIPT'
                                     , 'PO RECEIPT NRTAX'
                                     , 'PO RECEIPT NRTAX PRICE ADJ'
                                     , 'PO RECEIPT PRICE ADJ')
         and l_document_header_id is NULL then
             v_allow_adjustments := 'PA_SI_ADJ_NOT_UPGRADED_TO_R12';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'BILLABLE RECLASS'
                             , 'NON-BILLABLE RECLASS'
                             , 'BILLING HOLD'
                             , 'ONE-TIME BILLING HOLD'
                             , 'BILLING HOLD RELEASE'
                             , 'CAPITALIZABLE RECLASS'
                             , 'NON-CAPITALIZABLE RECLASS'
                             , 'REPROCESS CROSS CHARGE'
                             , 'CHANGE PROJ FUNC ATTRIBUTE'
                             , 'CHANGE TP ATTRIBUTE'
                             , 'CHANGE WORK TYPE ATTRIBUTE'
                             , 'MARK NO CC PROCESS'
                             , 'RAW COST RECALC'
                             , 'INDIRECT COST RECALC'
                             , 'COST AND REV RECALC'
                             , 'REVENUE RECALC'
                             , 'PROJECT OR TASK CHANGE')
         and l_transaction_source in ('AP INVOICE','AP EXPENSE','INTERPROJECT_AP_INVOICES','AP VARIANCE','AP NRTAX')
         and l_document_type = 'PREPAYMENT' then
             v_allow_adjustments := 'PA_SI_ADJ_PREPAY_NOT_ALLOW';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'BILLABLE RECLASS'
                             , 'NON-BILLABLE RECLASS'
                             , 'BILLING HOLD'
                             , 'ONE-TIME BILLING HOLD'
                             , 'BILLING HOLD RELEASE'
                             , 'CAPITALIZABLE RECLASS'
                             , 'NON-CAPITALIZABLE RECLASS'
                             , 'REPROCESS CROSS CHARGE'
                             , 'CHANGE PROJ FUNC ATTRIBUTE'
                             , 'CHANGE TP ATTRIBUTE'
                             , 'CHANGE WORK TYPE ATTRIBUTE'
                             , 'MARK NO CC PROCESS'
                             , 'RAW COST RECALC'
                             , 'INDIRECT COST RECALC'
                             , 'COST AND REV RECALC'
                             , 'REVENUE RECALC'
                             , 'PROJECT OR TASK CHANGE')
         and l_transaction_source in ('AP DISCOUNTS')
         and l_document_type = 'PREPAYMENT' then
             v_allow_adjustments := 'PA_SI_ADJ_PREPAY_DIS_NOT_ALLOW';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'BILLABLE RECLASS'
                             , 'NON-BILLABLE RECLASS'
                             , 'BILLING HOLD'
                             , 'ONE-TIME BILLING HOLD'
                             , 'BILLING HOLD RELEASE'
                             , 'CAPITALIZABLE RECLASS'
                             , 'NON-CAPITALIZABLE RECLASS'
                             , 'REPROCESS CROSS CHARGE'
                             , 'CHANGE FUNC ATTRIBUTE'
                             , 'CHANGE PROJ FUNC ATTRIBUTE'
                             , 'CHANGE TP ATTRIBUTE'
                             , 'CHANGE WORK TYPE ATTRIBUTE'
                             , 'MARK NO CC PROCESS'
                             , 'RAW COST RECALC'
                             , 'INDIRECT COST RECALC'
                             , 'COST AND REV RECALC'
                             , 'REVENUE RECALC'
                             , 'PROJECT OR TASK CHANGE')
         and l_transaction_source in ('AP INVOICE','AP EXPENSE','INTERPROJECT_AP_INVOICES','AP VARIANCE','AP NRTAX')
         and ( l_document_distribution_type = 'PREPAY'
          or   IsRelatedToPrepayApp(l_document_distribution_id))
         and l_document_payment_id is NULL then
             v_allow_adjustments := 'PA_SI_ADJ_PREPAY_APP_NOT_ALLOW';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'REPROCESS CROSS CHARGE'
                             , 'CHANGE FUNC ATTRIBUTE'
                             , 'CHANGE PROJ FUNC ATTRIBUTE'
                             , 'CHANGE TP ATTRIBUTE'
                             , 'MARK NO CC PROCESS'
                             , 'RAW COST RECALC'
                             , 'INDIRECT COST RECALC'
                             , 'COST AND REV RECALC'
                             , 'PROJECT OR TASK CHANGE')
         and l_source_expenditure_item_id is not null then
             v_allow_adjustments := 'PA_TR_APE_CANT_ADJ_REL';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'CHANGE FUNC ATTRIBUTE')
         and v_system_linkage in ('VI', 'ER') then
             v_allow_adjustments := 'PA_TR_APE_CANT_ADJ_ER_VI';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'CHANGE FUNC ATTRIBUTE')
         and l_acct_currency_code = v_denom_currency_code then
             v_allow_adjustments := 'PA_TR_APE_ACCT_DENOM_CURR_SAME';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'CHANGE TP ATTRIBUTE')
         and l_acct_currency_code = v_denom_tp_currency_code then
             v_allow_adjustments := 'PA_TR_APE_ACCT_DENOM_CURR_SAME';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'CHANGE PROJ FUNC ATTRIBUTE')
         and l_projfunc_currency_code = v_denom_currency_code then
             v_allow_adjustments := 'PA_TR_APE_PRJ_DENOM_CURR_SAME';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'CHANGE TP ATTRIBUTE')
         and v_cc_code in ( 'N', 'X') then
             v_allow_adjustments := 'PA_TR_APE_CC_CODE_NO_ADJUST';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'CHANGE WORK TYPE ATTRIBUTE'
                             , 'PROJECT OR TASK CHANGE')
         and l_adjusted_expenditure_item_id is not null then
             v_allow_adjustments := 'PA_TR_APE_CANT_ADJ_ADJ';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'MARK NO CC PROCESS')
         and v_cc_code = 'N' then
             v_allow_adjustments := 'PA_TR_APE_MARK_NO_CC_PROC';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'MARK NO CC PROCESS')
         and v_cc_code = 'X' then
             v_allow_adjustments := 'PA_TR_CC_SET_NA';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'RAW COST RECALC')
         and v_project_type_class_code = 'CONTRACT' then
             v_allow_adjustments := 'PA_TR_APE_ITEM_IN_CON_PROJ';
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'PROJECT OR TASK CHANGE')
         and l_transaction_source = 'ORACLE TIME AND LABOR' then
             Pa_Otc_Api.AdjustAllowedToOTCItem(l_orig_transaction_reference,l_adjust_allowed);
             if not l_adjust_allowed then
                 v_allow_adjustments := 'PA_CANT_TRAN_OTC_ITEM';
             end if;
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'PROJECT OR TASK CHANGE') then
             declare
                 l_start_date DATE;
                 l_end_date DATE;
                 cursor proj_start_end_date is
                 select start_date, completion_date
                   from pa_projects_all
                  where project_id = X_dest_prj_id;
             begin
                 open proj_start_end_date;
                 fetch proj_start_end_date into l_start_date, l_end_date;
                 close proj_start_end_date;
                 if not (v_exp_item_date between l_start_date and nvl(l_end_date, v_exp_item_date)) then
                     v_allow_adjustments := 'PA_EX_PROJECT_DATE';
                 end if;
             end;
         end if;

         if  v_allow_adjustments = 'N'
         and x_adj_action in ( 'PROJECT OR TASK CHANGE') then
             declare
                 l_start_date DATE;
                 l_end_date DATE;
                 cursor task_start_end_date is
                 select start_date, completion_date
                   from pa_tasks
                  where task_id = X_dest_task_id;
             begin
                 open task_start_end_date;
                 fetch task_start_end_date into l_start_date, l_end_date;
                 close task_start_end_date;
                 if not (v_exp_item_date between l_start_date and nvl(l_end_date, v_exp_item_date)) then
                     v_allow_adjustments := 'PA_EXP_TASK_EFF';
                 end if;
             end;
         end if;

         if  v_allow_adjustments = 'N'
         and ((v_system_linkage = 'VI'
         and   l_transaction_source in ('AP INVOICE', 'INTERCOMPANY_AP_INVOICES', 'AP ERV', /* Bug 5235354 */
                                     'INTERPROJECT_AP_INVOICES', 'AP VARIANCE' , 'AP NRTAX' , 'AP DISCOUNTS'))
         or  (v_system_linkage = 'ER' and l_transaction_source = 'AP EXPENSE')) then
/* R12 Changes Start */
		IF X_adj_action not in ('BILLABLE RECLASS','NON-BILLABLE RECLASS') THEN
 			v_allow_adjustments := InvStatus(X_system_reference2 => l_document_header_id
                                                        ,X_system_linkage_function => v_system_linkage);
		END IF;
         end if;

/* Bug 5235354 - Start */
         IF  v_allow_adjustments = 'N'
         AND l_transaction_source IN ( 'AP ERV', 'PO RECEIPT', 'PO RECEIPT NRTAX'
                                     , 'PO RECEIPT NRTAX PRICE ADJ', 'PO RECEIPT PRICE ADJ')
         AND ( X_adj_action IN ( 'PROJECT OR TASK CHANGE'
                               , 'BILLABLE RECLASS'
                               , 'NON-BILLABLE RECLASS'
                               , 'CAPITALIZABLE RECLASS'
                               , 'NON-CAPITALIZABLE RECLASS'
                               , 'RAW COST RECALC'
                               , 'COST AND REV RECALC')
          OR ( X_adj_action = 'CHANGE WORK TYPE ATTRIBUTE'
         AND   NVL(PA_UTILS4.get_trxn_work_billabilty(p_dest_work_type_id, NULL),l_billable_flag) <> l_billable_flag)) THEN

             IF  NVL(FND_PROFILE.VALUE('PA_ALLOW_RCV_ERV_ADJ_WHEN_JOURNAL_CONVERT'), 'N') = 'N'
             AND RepCurrOrSecLedgerDiffCurr(v_exp_org_id) THEN

                 IF l_transaction_source = 'AP ERV'
                 AND not PA_Adjustments.IsPeriodEndAccrual(l_document_distribution_id) THEN /* Bug 5381260 */
                     v_allow_adjustments := 'PA_ERV_PROF_SET_TO_NO';
                 END IF;
                 IF l_transaction_source IN ( 'PO RECEIPT', 'PO RECEIPT NRTAX'
                                            , 'PO RECEIPT NRTAX PRICE ADJ', 'PO RECEIPT PRICE ADJ') THEN
                     v_allow_adjustments := 'PA_RCV_PROF_SET_TO_NO';
                 END IF;

             END IF;

         END IF;
/* Bug 5235354 - End */

         IF  v_allow_adjustments = 'N'
         AND l_transaction_source IN ( 'AP INVOICE', 'INTERCOMPANY_AP_INVOICES', 'INTERPROJECT_AP_INVOICES', 'AP ERV' /* Bug 5235354 */
                                     , 'AP VARIANCE', 'AP NRTAX', 'AP DISCOUNTS', 'AP EXPENSE', 'PO RECEIPT'
                                     , 'PO RECEIPT NRTAX', 'PO RECEIPT NRTAX PRICE ADJ', 'PO RECEIPT PRICE ADJ')
         AND ( X_adj_action IN ( 'PROJECT OR TASK CHANGE'
                               , 'BILLABLE RECLASS'
                               , 'NON-BILLABLE RECLASS'
                               , 'CAPITALIZABLE RECLASS'
                               , 'NON-CAPITALIZABLE RECLASS'
                               , 'RAW COST RECALC'
                               , 'COST AND REV RECALC')
          OR ( X_adj_action = 'CHANGE WORK TYPE ATTRIBUTE'
         AND   NVL(PA_UTILS4.get_trxn_work_billabilty(p_dest_work_type_id, NULL),l_billable_flag) <> l_billable_flag)) THEN

             IF pa_adjustments.is_recoverability_affected
                         (p_expenditure_item_id => v_expenditure_item_id
                         ,p_org_id => v_exp_org_id
                         ,p_system_linkage_function => v_system_linkage
                         ,p_transaction_source => l_transaction_source
                         ,p_action => X_adj_action
                         ,p_project_id => NVL(x_dest_prj_id,l_project_id)
                         ,p_task_id => NVL(x_dest_task_id,v_task_id)
                         ,p_expenditure_type => v_exp_type
                         ,p_vendor_id => l_vendor_id
                         ,p_expenditure_organization_id => v_exp_organization_id
                         ,p_expenditure_item_date => v_exp_item_date
                         ,p_emp_id => v_incurred_by_person_id
                         ,p_document_header_id => l_document_header_id
                         ,p_document_line_number => l_document_line_number
                         ,p_document_distribution_id => l_document_distribution_id
                         ,p_document_type => l_document_type
                         ,p_award_id => NVL(p_dest_award_id,PA_GMS_API.VERT_GET_EI_AWARD_ID(v_expenditure_item_id))
                         ,p_billable_flag1 => l_billable_flag
                         ,x_error_message_name => l_error_message_name /* Bug 4997739 */
                         ,x_encoded_error_message => l_encoded_error_message) THEN /* Bug 4997739 */

/* Bug 4997739 - Trap exceptions from workflow or eBTax API */
               IF l_encoded_error_message IS NOT NULL THEN
                 fnd_message.parse_encoded(l_encoded_error_message,l_application_short_name,l_error_message_name);
                 v_allow_adjustments := l_error_message_name;
               ELSE
                 v_allow_adjustments := l_error_message_name;
               END IF;
             END IF;

         END IF;

         IF  v_allow_adjustments = 'N'
         AND v_system_linkage IN ('VI','ER')
         AND l_gl_accounted = 'Y'
         AND ( X_adj_action IN ( 'PROJECT OR TASK CHANGE'
                               , 'BILLABLE RECLASS'
                               , 'NON-BILLABLE RECLASS'
                               , 'CAPITALIZABLE RECLASS'
                               , 'NON-CAPITALIZABLE RECLASS'
                               , 'RAW COST RECALC'
                               , 'COST AND REV RECALC')
          OR ( X_adj_action = 'CHANGE WORK TYPE ATTRIBUTE'
         AND   NVL(PA_UTILS4.get_trxn_work_billabilty(p_dest_work_type_id, NULL),l_billable_flag) <> l_billable_flag)) THEN

             IF NOT pa_adjustments.Allow_Adjust_with_Auto_Offset
                         (p_expenditure_item_id => v_expenditure_item_id
                         ,p_org_id => v_exp_org_id
                         ,p_system_linkage_function => v_system_linkage
                         ,p_transaction_source => l_transaction_source
                         ,p_action => X_adj_action
                         ,p_project_id => NVL(x_dest_prj_id,l_project_id)
                         ,p_task_id => NVL(x_dest_task_id,v_task_id)
                         ,p_expenditure_type => v_exp_type
                         ,p_vendor_id => l_vendor_id
                         ,p_expenditure_organization_id => v_exp_organization_id
                         ,p_expenditure_item_date => v_exp_item_date
                         ,p_emp_id => v_incurred_by_person_id
                         ,p_invoice_distribution_id => l_document_distribution_id
                         ,p_invoice_payment_id => l_document_payment_id /* Bug 5006835 */
                         ,p_award_id => NVL(p_dest_award_id,PA_GMS_API.VERT_GET_EI_AWARD_ID(v_expenditure_item_id))
                         ,p_billable_flag1 => l_billable_flag
                         ,x_encoded_error_message => l_encoded_error_message) THEN /* Bug 4997739 */

/* Bug 4997739 - Trap exceptions from workflow */
               IF l_encoded_error_message IS NOT NULL THEN
                 fnd_message.parse_encoded(l_encoded_error_message,l_application_short_name,l_error_message_name);
                 v_allow_adjustments := l_error_message_name;
               ELSE
                 v_allow_adjustments := 'PA_SI_ADJ_LB_ACC_CHG_NOT_ALLOW';
               END IF;

             END IF;

         END IF;

/* Bug 5436420 - PA_GMS_API.VERT_TRANSFER will verify for award dates and statuses and the
                 expenditure type. Added the adjustment actions Capitalizable, Non-Capitalizable,
                 Recalculate Raw Cost, Recalculate Burden Cost, Billable, Non-Billable, Bill Hold,
                 Once-Time Hold, Release Hold, Recalculate Revenue, Recalculate Cost/Revenue */
         IF  v_allow_adjustments = 'N'
         AND X_adj_action IN ( 'BILLABLE RECLASS'
                             , 'NON-BILLABLE RECLASS'
                             , 'BILLING HOLD'
                             , 'ONE-TIME BILLING HOLD'
                             , 'BILLING HOLD RELEASE'
                             , 'CAPITALIZABLE RECLASS'
                             , 'NON-CAPITALIZABLE RECLASS'
                             , 'RAW COST RECALC'
                             , 'INDIRECT COST RECALC'
                             , 'COST AND REV RECALC'
                             , 'REVENUE RECALC'
                             , 'PROJECT OR TASK CHANGE')
         AND NOT PA_GMS_API.VERT_TRANSFER(v_expenditure_item_id,v_allow_adjustments) THEN

           NULL;

         END IF;

/* Bug 5436420 - 1) For Non-Sponsored projects, adjustment should be disllowed if the source
                    and destination tasks are same.
                 2) For Sponsored Projects, adjustment should allowed if the source task,
                    award are both equal to the destination task,award respectively. */
         if  v_allow_adjustments = 'N'
         and x_Adj_action in ( 'PROJECT OR TASK CHANGE')
         and v_task_id = x_dest_task_id then
             l_award_id := PA_GMS_API.VERT_GET_EI_AWARD_ID(v_expenditure_item_id);
             if  l_award_id is null
             and p_dest_award_id is null then
                 v_allow_adjustments := 'PA_TR_APE_CANT_XFER_TO_SELF';
             elsif l_award_id = p_dest_award_id then
                 v_allow_adjustments := 'GMS_TR_SOURCE_DEST_AWARDS_SAME';
             end if;
         end if;
/* R12 Changes End */

          IF v_allow_adjustments <> 'N' THEN

           	temp_num_rejected := temp_num_rejected + 1;
	     /* R12 Changes Start */
	        InsAuditRec( v_expenditure_item_id
            	           , X_adj_action
                  	   , X_module
	                   , X_user
          	           , X_login
                  	   , temp_status
	                   , G_REQUEST_ID
          	           , G_PROGRAM_ID
                  	   , G_PROG_APPL_ID
	                   , sysdate
          	           , v_allow_adjustments);
	                CheckStatus(temp_status);
            /* R12 changes End */
            j := j + 1 ;

          else

          i := i + 1;

             IF X_adj_action <> 'INDIRECT COST RECALC' then
                ItemsIdTab(i)    := v_expenditure_item_id;
                AdjustsIdTab(i)  := NULL;
                DenomCurrCodeTab(i) := v_denom_currency_code ;
                ProjCurrCodeTab(i)  := v_project_currency_code ;
                SysLinkageTab(i)    := v_system_linkage ;
                CrossChargeCodeTab(i) := v_cc_code ;
                DenomTpCurrCodeTab(i) := v_denom_tp_currency_code ;
		ProjFuncCurrCodeTab(i) := l_projfunc_currency_code;

                TpAmtTypCodeTab(i)     := l_tp_amt_type_code;

                IF X_adj_action = 'REPROCESS CROSS CHARGE' then
                   ExpOrganizationTab(i) := v_exp_organization_id ;
                   ExpOrgTab(i)          := v_exp_org_id ;
                   TaskIdTab(i)          := v_task_id ;
                   ExpItemDateTab(i)     := v_exp_item_date ;
                   ExpTypeTab(i)         := v_exp_type ;
                   IncurredByPersonIdTab(i) := v_incurred_by_person_id ;
                   TrxSourceTab(i)          := l_transaction_source ;
                   NlrOrganizationIdTab(i)  := v_nlr_organization_id ;
                END IF ;

             ELSE
                IF v_project_type_class_code <> 'CAPITAL' then
                    k := k + 1;
                    ItemsIdNCapTab(k)    := v_expenditure_item_id;
                    AdjustsIdNCapTab(k)  := NULL;
                ELSE
                    l := l + 1;
                    ItemsIdCapTab(l)     := v_expenditure_item_id;
                    AdjustsIdCapTab(l)   := NULL;
                END IF;
             END IF;

             IF i >= 500 then

		IF P_DEBUG_MODE  THEN
		   print_message('get_denom_curr_code: ' || 'calling massaction ');
		END IF;
                IF X_adj_action <>  'INDIRECT COST RECALC' then
                   MassAction( ItemsIdTab
                             , AdjustsIdTab
                             , X_adj_action
                             , X_module
                             , X_user
                             , X_login
                             , i
                             , X_dest_prj_id
                             , X_dest_task_id
                	     , X_project_currency_code
                             , X_project_rate_type
                             , X_project_rate_date
                             , X_project_exchange_rate
                             , X_acct_rate_type
			     , X_acct_rate_date
			     , X_acct_exchange_rate
			     , DenomCurrCodeTab
                             , ProjCurrCodeTab
                             , temp_status
                             , num_processed
                             , num_rejected
           		     , ProjFuncCurrCodeTab
           		     , p_projfunc_cost_rate_type
           		     , p_projfunc_cost_rate_date
           		     , p_projfunc_cost_exchange_rate
           		     , p_project_tp_cost_rate_type
           		     , p_project_tp_cost_rate_date
           		     , p_project_tp_cost_exchg_rate
           		     , p_assignment_id
           		     , p_dest_work_type_id
			     , p_projfunc_currency_code
                             , TpAmtTypCodeTab
                             , p_dest_tp_amt_type_code);
                   temp_num_processed := temp_num_processed + num_processed;
                   temp_num_rejected  := temp_num_rejected  + num_rejected ;

                ELSE

                   MassAction( ItemsIdNCapTab
                             , AdjustsIdNCapTab
                             , 'INDIRECT COST RECALC'
                             , X_module
                             , X_user
                             , X_login
                             , k
                             , X_dest_prj_id
                             , X_dest_task_id
                	     , X_project_currency_code
                             , X_project_rate_type
                             , X_project_rate_date
                             , X_project_exchange_rate
                             , X_acct_rate_type
			     , X_acct_rate_date
			     , X_acct_exchange_rate
			     , DenomCurrCodeTab
                             , ProjCurrCodeTab
                             , temp_status
                             , num_processed
                             , num_rejected
                             , ProjFuncCurrCodeTab
                             , p_projfunc_cost_rate_type
                             , p_projfunc_cost_rate_date
                             , p_projfunc_cost_exchange_rate
                             , p_project_tp_cost_rate_type
                             , p_project_tp_cost_rate_date
                             , p_project_tp_cost_exchg_rate
                             , p_assignment_id
                             , p_dest_work_type_id
			     , p_projfunc_currency_code
                             , TpAmtTypCodeTab
                             , p_dest_tp_amt_type_code);
                   temp_num_processed := temp_num_processed + num_processed;
                   temp_num_rejected  := temp_num_rejected  + num_rejected ;

                   MassAction( ItemsIdCapTab
                             , AdjustsIdCapTab
                             , 'CAPITAL COST RECALC'
                             , X_module
                             , X_user
                             , X_login
                             , l
                             , X_dest_prj_id
                             , X_dest_task_id
                	     , X_project_currency_code
                	     , X_project_rate_type
                             , X_project_rate_date
                             , X_project_exchange_rate
                             , X_acct_rate_type
			     , X_acct_rate_date
			     , X_acct_exchange_rate
			     , DenomCurrCodeTab
                             , ProjCurrCodeTab
                             , temp_status
                             , num_processed
                             , num_rejected
                             , ProjFuncCurrCodeTab
                             , p_projfunc_cost_rate_type
                             , p_projfunc_cost_rate_date
                             , p_projfunc_cost_exchange_rate
                             , p_project_tp_cost_rate_type
                             , p_project_tp_cost_rate_date
                             , p_project_tp_cost_exchg_rate
                             , p_assignment_id
                             , p_dest_work_type_id
			     , p_projfunc_currency_code
                             , TpAmtTypCodeTab
                             , p_dest_tp_amt_type_code);
                   temp_num_processed := temp_num_processed + num_processed;
                   temp_num_rejected  := temp_num_rejected  + num_rejected ;
                 END IF;

                 j := j + i;
                 i := 0;
                 k := 0;
                 l := 0;

                 IF ( temp_outcome IS NOT NULL ) THEN
                    RAISE INVALID_ITEM;
                 END IF;
	    IF P_DEBUG_MODE  THEN
	       print_message('get_denom_curr_code: ' || 'after mass action');
	    END IF;

/* Bug 5501593 - Start */
/* Commit after 5000 transactions have been processed */
               l_commit_count := l_commit_count + 500;
               IF l_commit_count >= 5000 THEN
                   commit;
                   l_commit_count := 0;
               END IF;
/* Bug 5501593 - End */

           END IF;
       END IF;
       END LOOP;

-- Added a close cursor since this was causing problems when this
-- procedure was called multiple times. Customer - Oakridge
     IF P_DEBUG_MODE  THEN
        print_message('get_denom_curr_code: ' || 'close the cursor ');
     END IF;
     dbms_sql.close_cursor(v_cursor_adj_id)  ;

       IF i >= 1 then
           IF X_adj_action <>  'INDIRECT COST RECALC' then
 	IF P_DEBUG_MODE  THEN
 	   print_message('get_denom_curr_code: ' || 'i is ['||i||'] denom_currcode[' ||v_denom_currency_code||']' );
 	END IF;
                MassAction( ItemsIdTab
                          , AdjustsIdTab
                          , X_adj_action
                          , X_module
                          , X_user
                          , X_login
                          , i
                          , X_dest_prj_id
                          , X_dest_task_id
                	  , X_project_currency_code
                          , X_project_rate_type
                          , X_project_rate_date
                          , X_project_exchange_rate
                          , X_acct_rate_type
			  , X_acct_rate_date
			  , X_acct_exchange_rate
			  , DenomCurrCodeTab
                          , ProjCurrCodeTab
                          , temp_status
                          , num_processed
                          , num_rejected
                          , ProjFuncCurrCodeTab
                          , p_projfunc_cost_rate_type
                          , p_projfunc_cost_rate_date
                          , p_projfunc_cost_exchange_rate
                          , p_project_tp_cost_rate_type
                          , p_project_tp_cost_rate_date
                          , p_project_tp_cost_exchg_rate
                          , p_assignment_id
                          , p_dest_work_type_id
			  , p_projfunc_currency_code
                          , TpAmtTypCodeTab
                          , p_dest_tp_amt_type_code);
                   temp_num_processed := temp_num_processed + num_processed;
                   temp_num_rejected  := temp_num_rejected  + num_rejected ;
            ELSE
                MassAction( ItemsIdNCapTab
                          , AdjustsIdNCapTab
                          , 'INDIRECT COST RECALC'
                          , X_module
                          , X_user
                          , X_login
                          , k
                          , X_dest_prj_id
                          , X_dest_task_id
                	  , X_project_currency_code
                	  , X_project_rate_type
                	  , X_project_rate_date
                	  , X_project_exchange_rate
                          , X_acct_rate_type
			  , X_acct_rate_date
			  , X_acct_exchange_rate
			  , DenomCurrCodeTab
                          , ProjCurrCodeTab
                          , temp_status
                          , num_processed
                          , num_rejected
                          , ProjFuncCurrCodeTab
                          , p_projfunc_cost_rate_type
                          , p_projfunc_cost_rate_date
                          , p_projfunc_cost_exchange_rate
                          , p_project_tp_cost_rate_type
                          , p_project_tp_cost_rate_date
                          , p_project_tp_cost_exchg_rate
                          , p_assignment_id
                          , p_dest_work_type_id
			  , p_projfunc_currency_code
                          , TpAmtTypCodeTab
                          , p_dest_tp_amt_type_code );
                   temp_num_processed := temp_num_processed + num_processed;
                   temp_num_rejected  := temp_num_rejected  + num_rejected ;

                MassAction( ItemsIdCapTab
                          , AdjustsIdCapTab
                          , 'CAPITAL COST RECALC'
                          , X_module
                          , X_user
                          , X_login
                          , l
                          , X_dest_prj_id
                          , X_dest_task_id
                	  , X_project_currency_code
                	  , X_project_rate_type
               		  , X_project_rate_date
                	  , X_project_exchange_rate
                          , X_acct_rate_type
			  , X_acct_rate_date
			  , X_acct_exchange_rate
			  , DenomCurrCodeTab
                          , ProjCurrCodeTab
                          , temp_status
                          , num_processed
                          , num_rejected
                          , ProjFuncCurrCodeTab
                          , p_projfunc_cost_rate_type
                          , p_projfunc_cost_rate_date
                          , p_projfunc_cost_exchange_rate
                          , p_project_tp_cost_rate_type
                          , p_project_tp_cost_rate_date
                          , p_project_tp_cost_exchg_rate
                          , p_assignment_id
                          , p_dest_work_type_id
			  , p_projfunc_currency_code
                          , TpAmtTypCodeTab
                          , p_dest_tp_amt_type_code);
                   temp_num_processed := temp_num_processed + num_processed;
                   temp_num_rejected  := temp_num_rejected  + num_rejected ;
            END IF;
         END IF;

         j := j + i ;
         i := 0;
         k := 0;
         l := 0;

   IF ( j = 0 ) THEN
        X_outcome := 'PA_PR_NO_ITEMS_PROC';
        X_num_processed := 0;
        X_num_rejected  := 0;
        RETURN;
   END IF;

   END IF;
 IF P_DEBUG_MODE  THEN
    print_message('get_denom_curr_code: ' || 'temp num process is[ '||temp_num_processed||']num reject is[ '||temp_num_rejected
	      ||']End of Mass Adjust api');
 END IF;

X_num_processed := temp_num_processed;
X_num_rejected  := temp_num_rejected;
X_outcome       := NULL;

EXCEPTION
   WHEN  INVALID_ITEM  THEN
     IF P_DEBUG_MODE  THEN
        print_message('get_denom_curr_code: ' || 'execption INVALID_ITEM IN mass adjust');
     END IF;
     X_outcome := temp_outcome;
  WHEN RESOURCE_BUSY THEN
     X_outcome := 'PA_ALL_COULD_NOT_LOCK';
	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'execption RESOURCE_BUSY IN mass adjust PA_ALL_COULD_NOT_LOCK');
	END IF;
     RAISE ;
  WHEN  OTHERS  THEN
     IF P_DEBUG_MODE  THEN
        print_message('get_denom_curr_code: ' || 'execption OTHERS IN mass adjust '||SQLCODE||sqlerrm);
     END IF;
     X_outcome := SQLCODE;
     RAISE;

END  MassAdjust;

-- ========================================================================
-- PROCEDURE MassAction
-- ========================================================================

-- This procedure was created to improve the performance allowing multiple

  PROCEDURE  MassAction(
             ItemsIdTab                  IN pa_utils.IdTabTyp
           , AdjustsIdTab                IN pa_utils.IdTabTyp
           , X_adj_action                IN VARCHAR2
           , X_module                    IN VARCHAR2
           , X_user                      IN NUMBER
           , X_login                     IN NUMBER
           , X_num_rows                  IN NUMBER
           , X_dest_prj_id               IN NUMBER
           , X_dest_task_id              IN NUMBER
	   , X_project_currency_code IN VARCHAR2
           , X_project_rate_type     IN VARCHAR2
           , X_project_rate_date     IN DATE
           , X_project_exchange_rate IN NUMBER
           , X_acct_rate_type        IN VARCHAR2
	   , X_acct_rate_date        IN DATE
	   , X_acct_exchange_rate     IN NUMBER
           , DenomCurrCodeTab          IN pa_utils.Char15TabTyp
           , ProjCurrCodeTab           IN pa_utils.Char15TabTyp
           , X_status                    OUT NOCOPY VARCHAR2
           , X_num_processed             OUT NOCOPY NUMBER
           , X_num_rejected              OUT NOCOPY NUMBER
	   , ProjFuncCurrCodeTab           IN pa_utils.Char15TabTyp
	   , p_projfunc_cost_rate_type     IN VARCHAR2
           , p_projfunc_cost_rate_date     IN date
           , p_projfunc_cost_exchange_rate IN NUMBER
	   , p_project_tp_cost_rate_type   IN VARCHAR2
           , p_project_tp_cost_rate_date   IN DATE
           , p_project_tp_cost_exchg_rate  IN NUMBER
	   , p_assignment_id               IN NUMBER
           , p_work_type_id                IN NUMBER
	   , p_projfunc_currency_code      IN VARCHAR2
           , p_TpAmtTypCodeTab             IN pa_utils.Char30TabTyp
           , p_dest_tp_amt_type_code       IN VARCHAR2     )

  IS
    dummy               NUMBER;
    temp_outcome        VARCHAR2(30) DEFAULT NULL;
    temp_status         NUMBER DEFAULT NULL;
    temp_num_processed  NUMBER DEFAULT 0;
    temp_num_rejected   NUMBER DEFAULT 0;
	 temp_msg_application  VARCHAR2(30);
	 temp_msg_type		   VARCHAR2(1);
	 temp_msg_token1 	   VARCHAR2(240);
	 temp_msg_token2	 	VARCHAR2(240);
	 temp_msg_token3	 	VARCHAR2(240);
	 temp_msg_count	 	Number;
    i                   BINARY_INTEGER := 0;
    j                   BINARY_INTEGER := 0;
    k                   BINARY_INTEGER := 0;
    l                   BINARY_INTEGER := 0;
    adj_ei              number;

    l_projfunc_currency_code    varchar2(15);

  BEGIN

	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'Entering MassAction api adjust action ['||X_adj_action||']proj func cur code ['
	||p_projfunc_currency_code||']work type ['||p_work_type_id||']assignment id ['||p_assignment_id||']' );
	END IF;

    /** commented and passing the IN param to Transfer api
     IF ProjFuncCurrCodeTab.EXISTS(1) then
	    l_projfunc_currency_code := ProjFuncCurrCodeTab(1);
     END IF;
     **/

     l_projfunc_currency_code := p_projfunc_currency_code;


      IF ( X_adj_action = 'BILLABLE RECLASS' ) THEN

         Reclass( ItemsIdTab
                , AdjustsIdTab
                , 'Y'
                , X_adj_action
                , X_user
                , X_login
                , X_module
                , X_num_rows
                , temp_status );

         CheckStatus( temp_status );
         temp_num_processed := X_num_rows ;

      ELSIF ( X_adj_action = 'NON-BILLABLE RECLASS' ) THEN

         Reclass( ItemsIdTab
                , AdjustsIdTab
                , 'N'
                , X_adj_action
                , X_user
                , X_login
                , X_module
                , X_num_rows
                , temp_status );
         CheckStatus( temp_status );
         temp_num_processed := X_num_rows ;

      ELSIF ( X_adj_action = 'CAPITALIZABLE RECLASS' ) THEN

         Reclass( ItemsIdTab
                , AdjustsIdTab
                , 'Y'
                , X_adj_action
                , X_user
                , X_login
                , X_module
                , X_num_rows
                , temp_status );
         CheckStatus( temp_status );
         temp_num_processed := X_num_rows ;

      ELSIF ( X_adj_action = 'NON-CAPITALIZABLE RECLASS' ) THEN

         Reclass( ItemsIdTab
                , AdjustsIdTab
                , 'N'
                , X_adj_action
                , X_user
                , X_login
                , X_module
                , X_num_rows
                , temp_status );
         CheckStatus( temp_status );
         temp_num_processed := X_num_rows ;

      ELSIF ( X_adj_action = 'BILLING HOLD' ) THEN

            Hold( ItemsIdTab
                , AdjustsIdTab
                , 'Y'
                , X_adj_action
                , X_user
                , X_login
                , X_module
                , X_num_rows
                , temp_status );
         CheckStatus( temp_status );
         temp_num_processed := X_num_rows ;

      ELSIF ( X_adj_action = 'BILLING HOLD RELEASE' ) THEN

            Hold( ItemsIdTab
                , AdjustsIdTab
                , 'N'
                , X_adj_action
                , X_user
                , X_login
                , X_module
                , X_num_rows
                , temp_status );
          CheckStatus( temp_status );
         temp_num_processed := X_num_rows ;

     ELSIF ( X_adj_action = 'ONE-TIME BILLING HOLD' ) THEN

            Hold( ItemsIdTab
                , AdjustsIdTab
                , 'O'
                , X_adj_action
                , X_user
                , X_login
                , X_module
                , X_num_rows
                , temp_status );
          CheckStatus( temp_status );
         temp_num_processed := X_num_rows ;

    ELSIF ( X_adj_action = 'INDIRECT COST RECALC' ) THEN

       RecalcIndCost( ItemsIdTab
                , AdjustsIdTab
                , X_user
                , X_login
                , X_module
                , X_num_rows
                , temp_status );
     CheckStatus( temp_status );
     temp_num_processed := X_num_rows ;

    ELSIF ( X_adj_action = 'COST AND REV RECALC' ) THEN
       RecalcCostRev( ItemsIdTab
                , AdjustsIdTab
                , X_user
                , X_login
                , X_module
                , X_num_rows
                , temp_num_processed
                , temp_status );
        CheckStatus( temp_status );

    ELSIF ( X_adj_action = 'REVENUE RECALC' ) THEN

       RecalcRev( ItemsIdTab
                , AdjustsIdTab
                , X_user
                , X_login
                , X_module
                , X_num_rows
                , temp_status );
        CheckStatus( temp_status );
        temp_num_processed := X_num_rows ;

    ELSIF ( X_adj_action = 'CAPITAL COST RECALC' ) THEN

       RecalcCapCost( ItemsIdTab
                , AdjustsIdTab
                , X_user
                , X_login
                , X_module
                , X_num_rows
                , temp_status );
        CheckStatus( temp_status );
        temp_num_processed := X_num_rows ;

    ELSIF ( X_adj_action = 'RAW COST RECALC' ) THEN

        RecalcRawCost( ItemsIdTab
                , AdjustsIdTab
                , X_user
                , X_login
		, X_module
                , X_num_rows
                , temp_num_processed
                , temp_status );
        CheckStatus( temp_status );

    -- call to the new rate attribute adjustment procedures
    ELSIF ( X_adj_action = 'CHANGE FUNC ATTRIBUTE' ) THEN
         ChangeFuncAttributes(ItemsIdTab
                          , 'S'
                          , X_user
                          , X_login
                          , X_module
                          , X_acct_rate_type
			  , X_acct_rate_date
			  , X_acct_exchange_rate
			  , DenomCurrCodeTab
                          , ProjCurrCodeTab
                          , X_num_rows
                          , temp_num_processed
                          , temp_num_rejected
                          , temp_status
			  , ProjFuncCurrCodeTab) ;
          CheckStatus( temp_status );

     -- call to the new rate attribute adjustment procedures
     ELSIF ( X_adj_action = 'CHANGE PROJ ATTRIBUTE' ) THEN

         ChangeProjAttributes(ItemsIdTab
                          , 'S'
                          , X_user
                          , X_login
                          , X_module
                          , X_project_rate_type
                          , X_project_rate_date
                          , X_project_exchange_rate
                          , DenomCurrCodeTab
                          , ProjCurrCodeTab
                          , X_num_rows
                          , temp_num_processed
                          , temp_num_rejected
                          , temp_status         ) ;
          CheckStatus( temp_status );
     -- call to the new project funcational rate attribute adjustment procedures
     ELSIF ( X_adj_action = 'CHANGE PROJ FUNC ATTRIBUTE' ) THEN

         ChangeProjFuncAttributes(ItemsIdTab
                          , 'S'
                          , X_user
                          , X_login
                          , X_module
                          , p_projfunc_cost_rate_type
                          , p_projfunc_cost_rate_date
                          , p_projfunc_cost_exchange_rate
                          , DenomCurrCodeTab
                          , ProjFuncCurrCodeTab
                          , X_num_rows
                          , temp_num_processed
                          , temp_num_rejected
                          , temp_status         ) ;
          CheckStatus( temp_status );

    ELSIF ( X_adj_action = 'REPROCESS CROSS CHARGE' ) THEN
          ReprocessCrossCharge (ItemsIdTab
         			  , 'S'
           			  , X_user
           			  , X_login
           			  , X_module
               			  , Null
			      	  , Null
				  , Null
				  , Null
                                  , Null
                                  , Null
            			  , X_num_rows
           			  , temp_num_processed
           			  , temp_status ) ;
     CheckStatus( temp_status );
    ELSIF ( X_adj_action = 'MARK NO CC PROCESS' ) THEN
           MarkNoCCProcess (ItemsIdTab
          			 , 'S'
           			 , X_user
           			 , X_login
           			 , X_module
 				 , Null
				 , Null
            			 , X_num_rows
           			 , temp_num_processed
           			 , temp_status ) ;
       CheckStatus( temp_status );
    ELSIF ( X_adj_action = 'CHANGE TP ATTRIBUTE' ) THEN
	    ChangeTpAttributes(ItemsIdTab
                          , 'S'
                          , X_user
                          , X_login
                          , X_module
                          , X_acct_rate_type
                          , X_acct_rate_date
                          , X_acct_exchange_rate
	      	          , Null
		          , Null
                          , DenomCurrCodeTab
                          , X_num_rows
                          , temp_num_processed
                          , temp_num_rejected
                          , temp_status
                          , p_PROJECT_TP_COST_RATE_DATE
                          , p_PROJECT_TP_COST_RATE_TYPE
                          , p_PROJECT_TP_COST_EXCHG_RATE) ;
      CheckStatus( temp_status );
    ELSIF ( X_adj_action = 'PROJECT OR TASK CHANGE' ) THEN

        Transfer( ItemsIdTab
                , X_dest_prj_id
                , X_dest_task_id
                , X_project_currency_code
                , X_project_rate_type
                , X_project_rate_date
                , X_project_exchange_rate
                , X_user
                , X_login
                , X_module
                , 'S'
                , X_num_rows
                , temp_num_processed
                , temp_num_rejected
                , temp_outcome
		, temp_msg_application
		, temp_msg_type
		, temp_msg_token1
		, temp_msg_token2
		, temp_msg_token3
		, temp_msg_count
                , l_projfunc_currency_code
                , p_projfunc_cost_rate_type
                , p_projfunc_cost_rate_date
                , p_projfunc_cost_exchange_rate
                , p_assignment_id
                , p_work_type_id);

      		IF ( temp_outcome IS NOT NULL AND ( temp_msg_type = 'E' ) ) THEN /* Added msg_type check for Bug 4906816 */
          		RAISE INVALID_ITEM;
      		END IF;
	/**  start proj currency changes **/
    ELSIF ( X_adj_action = 'CHANGE WORK TYPE ATTRIBUTE' ) THEN

	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'calling work_type_adjustment api');
	END IF;
        	work_type_adjustment
                   ( ItemsIdTab        => ItemsIdTab
                    --, AdjustsIdTab   => AdjustsIdTab
                    , p_billable       => NULL
                    , p_work_type_id   =>p_work_type_id
                    , p_adj_activity   =>X_adj_action
                    , p_user           =>X_user
                    , p_login          =>X_login
                    , p_module         =>X_module
                    , p_rows           =>X_num_rows
                    , p_TpAmtTypCodeTab       => p_TpAmtTypCodeTab
                    , p_dest_tp_amt_type_code => p_dest_tp_amt_type_code
                    , x_status         => temp_status);

	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'end of work type adjustment api');
	END IF;

        	CheckStatus( temp_status );
		temp_num_processed := X_num_rows ;

	/** end proj currency changes **/

    END IF;


X_num_processed := temp_num_processed;
X_num_rejected  := temp_num_rejected;
X_status        := NULL;

EXCEPTION
   WHEN  INVALID_ITEM  THEN
     X_status := temp_outcome;
  WHEN RESOURCE_BUSY THEN
     X_status := 'PA_ALL_COULD_NOT_LOCK';
  WHEN  OTHERS  THEN
     X_status := SQLCODE;
     RAISE;

END  MassAction;


/*----------------------------------------------------------------------------
 -- See Package specs for detail comments for this ei_adjusted_in_cache.
----------------------------------------------------------------------------*/
FUNCTION ei_adjusted_in_cache(X_exp_item_id In Number) RETURN Varchar2
IS
l_exp_item_id Number(15) := NULL;

BEGIN

   l_exp_item_id := pa_adjustments.ExpAdjItemTab(X_exp_item_id);
   RETURN('Y');

EXCEPTION WHEN NO_DATA_FOUND THEN
   RETURN('N');
WHEN OTHERS THEN
   raise;
END ei_adjusted_in_cache;


-- Fix for bug # 913353. in the decode for the project attributes
-- replaced acct_rate_type etc with X_acct_rate_type

  PROCEDURE  ChangeFuncAttributes(ItemsIdTab          IN pa_utils.IdTabTyp
                          , X_adjust_level   IN VARCHAR2
                          , X_user           IN NUMBER
                          , X_login          IN NUMBER
                          , X_module         IN VARCHAR2
                          , X_acct_rate_type IN VARCHAR2
			  , X_acct_rate_date IN DATE
			  , X_acct_exchange_rate IN NUMBER
                          , DenomCurrCodeTab IN pa_utils.Char15TabTyp
			  , ProjCurrCodeTab  IN  pa_utils.Char15TabTyp
                          , rows             IN NUMBER
                          , X_num_processed  OUT NOCOPY NUMBER
                          , X_num_rejected   OUT NOCOPY NUMBER
                          , X_status         OUT NOCOPY NUMBER
                          , ProjfuncCurrCodeTab IN pa_utils.Char15TabTyp  ) IS

     temp_status         NUMBER DEFAULT NULL;
     item_count          NUMBER := 0;
     failed_count        NUMBER := 0 ;
     l_status            VARCHAR2(240)DEFAULT NULL ;
     l_acct_exchange_rate NUMBER := X_acct_exchange_rate;
     l_acct_rate_type  VARCHAR2(30) := X_acct_rate_type ;
     l_acct_rate_date  DATE         := X_acct_rate_date ;
     l_dummy1            NUMBER ;
     l_dummy2            NUMBER ;
     l_dummy3            NUMBER ;

 -- pa_multi_currency.init ;

     PROCEDURE  RecalcRelatedItems( X_expenditure_item_id  IN NUMBER
                                  , X_user                 IN NUMBER
                                  , X_login                IN NUMBER
                                  , X_acct_rate_type       IN VARCHAR2
			          , X_acct_rate_date       IN DATE
			          , X_acct_exchange_rate   IN NUMBER
			          , X_project_currency_code IN VARCHAR2
                                  , X_module               IN VARCHAR2
                                  , X_status               OUT NOCOPY NUMBER
                                  , p_projfunc_currency_code IN VARCHAR2)
     IS
       CURSOR GetRelatedItems IS
         SELECT
                 expenditure_item_id
           FROM
                 pa_expenditure_items_all
          WHERE
                 source_expenditure_item_id = X_expenditure_item_id;
     BEGIN

       FOR eachRec IN GetRelatedItems LOOP

         UPDATE pa_expenditure_items_all
            SET
                 cost_distributed_flag = 'N'
         ,       revenue_distributed_flag = 'N'
	 ,       rev_dist_rejection_code = NULL  /*Added for bug:9367103 */
         ,       acct_rate_type = X_acct_rate_type
         ,       acct_rate_date = X_acct_rate_date
         ,       acct_exchange_rate = X_acct_exchange_rate
         ,       project_rate_type = DECODE(X_project_currency_code,
                 		       pa_multi_currency.G_accounting_currency_code,
  				       X_acct_rate_type,project_rate_type )
         ,       project_rate_date = DECODE(X_project_currency_code,
                 			pa_multi_currency.G_accounting_currency_code,
					X_acct_rate_date, project_rate_date )
         ,       project_exchange_rate = DECODE(X_project_currency_code,
                 			pa_multi_currency.G_accounting_currency_code,
					X_acct_exchange_rate,project_exchange_rate )
         ,       acct_raw_cost = NULL
         ,       acct_burdened_cost = NULL
         ,       project_raw_cost = DECODE(X_project_currency_code,
                 		pa_multi_currency.G_accounting_currency_code, NULL, project_raw_cost )
         ,       project_burdened_cost = DECODE(X_project_currency_code,
                 		pa_multi_currency.G_accounting_currency_code, NULL,project_burdened_cost )
         ,       last_updated_by = X_user
         ,       last_update_date = sysdate
         ,       last_update_login = X_login
         ,       projfunc_cost_rate_type = DECODE(p_projfunc_currency_code,
                                       pa_multi_currency.G_accounting_currency_code,
                                       X_acct_rate_type,projfunc_cost_rate_type )
         ,       projfunc_cost_rate_date = DECODE(p_projfunc_currency_code,
                                        pa_multi_currency.G_accounting_currency_code,
                                        X_acct_rate_date, projfunc_cost_rate_date )
         ,       projfunc_cost_exchange_rate = DECODE(p_projfunc_currency_code,
                                        pa_multi_currency.G_accounting_currency_code,
                                        X_acct_exchange_rate,projfunc_cost_exchange_rate )
         ,       raw_cost = DECODE(p_projfunc_currency_code,
                                pa_multi_currency.G_accounting_currency_code, NULL, raw_cost )
         ,       burden_cost = DECODE(p_projfunc_currency_code,
                                pa_multi_currency.G_accounting_currency_code, NULL,burden_cost )

           WHERE
                 expenditure_item_id = eachRec.expenditure_item_id;

         item_count := item_count + 1;

         pa_adjustments.InsAuditRec( eachRec.expenditure_item_id
                                   , 'CHANGE FUNC ATTRIBUTE'
                                   , X_module
                                   , X_user
                                   , X_login
                                   , temp_status
				/* R12 Changes Start */
	                           , G_REQUEST_ID
          	                   , G_PROGRAM_ID
	                           , G_PROG_APPL_ID
	                           , sysdate );
 				/* R12 Changes End */
         CheckStatus( temp_status );

       END LOOP;

     X_status := 0;

     EXCEPTION
       WHEN  OTHERS  THEN
         X_status := SQLCODE;
         RAISE;

     END  RecalcRelatedItems;


  BEGIN

	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'inside changefunccurrenc attri api');
	END IF;
    FOR i IN 1..rows LOOP

	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'DenomCurrCodeTab(i)['||DenomCurrCodeTab(i)||']ProjCurrCodeTab(i)['||ProjCurrCodeTab(i)||
	']ProjfuncCurrCodeTab(i)['||ProjFuncCurrCodeTab(i) || ']' );
	END IF;
       pa_multi_currency.init ;
   IF X_adjust_level = 'S' THEN

	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'calling pa_multi currency api');
	END IF;
       pa_multi_currency.convert_amount( DenomCurrCodeTab(i)
                                        , pa_multi_currency.G_accounting_currency_code
                                        , l_acct_rate_date
                                        , l_acct_rate_type
                                        , null
                                        , 'Y'
                                        , 'Y'
                                        , l_dummy1
                                        , l_dummy2
                                        , l_dummy3
                                        , l_acct_exchange_rate
                                        , l_status  ) ;

	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'l_acct_rate_date['||l_acct_rate_date||']l_acct_rate_type['||l_acct_rate_type
		    ||']G_accounting_currency_code['||pa_multi_currency.G_accounting_currency_code
		    ||']l_acct_exchange_rate['||l_acct_exchange_rate||']' );
	END IF;
    END IF ;

        IF l_status is not null then
              failed_count := failed_count + 1 ;
	/* R12 Changes Start */
              InsAuditRec( ItemsIdTab(i)
                         , 'CHANGE FUNC ATTRIBUTE'
                         , X_module
                         , X_user
                         , X_login
                         , temp_status
                         , G_REQUEST_ID
                         , G_PROGRAM_ID
                         , G_PROG_APPL_ID
                         , sysdate
                         , l_status);
              CheckStatus(temp_status);
	/* R12 Changes End */

        ELSE

        UPDATE pa_expenditure_items_all ei
         SET
             ei.cost_distributed_flag = 'N'
      ,      ei.revenue_distributed_flag = 'N'
      ,      ei.rev_dist_rejection_code = NULL  /*Added for bug:9367103 */
      ,       acct_rate_type = X_acct_rate_type
      ,       acct_rate_date = X_acct_rate_date
      ,       acct_exchange_rate = l_acct_exchange_rate
      ,       project_rate_type = DECODE(ProjCurrCodeTab(i),
              				pa_multi_currency.G_accounting_currency_code,
					X_acct_rate_type, project_rate_type )
      ,       project_rate_date = DECODE(ProjCurrCodeTab(i),
              				pa_multi_currency.G_accounting_currency_code,
					X_acct_rate_date, project_rate_date )
      ,       project_exchange_rate = DECODE(ProjCurrCodeTab(i),
              				pa_multi_currency.G_accounting_currency_code,
              				X_acct_exchange_rate , project_exchange_rate )
      ,       acct_raw_cost = NULL
      ,       acct_burdened_cost = NULL
      ,       project_raw_cost = DECODE(ProjCurrCodeTab(i),
              			pa_multi_currency.G_accounting_currency_code, NULL, project_raw_cost )
      ,       project_burdened_cost = DECODE(ProjCurrCodeTab(i),
              			pa_multi_currency.G_accounting_currency_code, NULL, project_burdened_cost )
      ,      ei.last_update_date = sysdate
      ,      ei.last_updated_by = X_user
      ,      ei.last_update_login = X_login
         ,       projfunc_cost_rate_type = DECODE(ProjFuncCurrCodeTab(i),
                                       pa_multi_currency.G_accounting_currency_code,
                                       X_acct_rate_type,projfunc_cost_rate_type )
         ,       projfunc_cost_rate_date = DECODE(ProjFuncCurrCodeTab(i),
                                        pa_multi_currency.G_accounting_currency_code,
                                        X_acct_rate_date, projfunc_cost_rate_date )
         ,       projfunc_cost_exchange_rate = DECODE(ProjFuncCurrCodeTab(i),
                                        pa_multi_currency.G_accounting_currency_code,
                                        X_acct_exchange_rate,projfunc_cost_exchange_rate )
         ,       raw_cost = DECODE(ProjFuncCurrCodeTab(i),
                                pa_multi_currency.G_accounting_currency_code, NULL, raw_cost )
         ,       burden_cost = DECODE(ProjFuncCurrCodeTab(i),
                                pa_multi_currency.G_accounting_currency_code, NULL,burden_cost )
       WHERE
             ei.expenditure_item_id = ItemsIdTab(i);

      item_count := item_count + 1;

      InsAuditRec( ItemsIdTab(i)
                 , 'CHANGE FUNC ATTRIBUTE'
                 , X_module
                 , X_user
                 , X_login
                 , temp_status
	/* R12 Changes Start */
	         , G_REQUEST_ID
          	 , G_PROGRAM_ID
	         , G_PROG_APPL_ID
	         , sysdate );
 	/* R12 Changes End */
      CheckStatus( temp_status );

    RecalcRelatedItems( ItemsIdTab(i)
                        , X_user
                        , X_login
                        , X_acct_rate_type
                        , X_acct_rate_date
                        , l_acct_exchange_rate
                        , ProjCurrCodeTab(i)
                        , X_module
                        , temp_status
                        , ProjFuncCurrCodeTab(i));
      CheckStatus( temp_status );

    END IF ;
    END LOOP;

    X_status := 0;
    X_num_processed := item_count;
    X_num_rejected  := failed_count ;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;

  END  ChangeFuncAttributes;

/** This api is newly added to convert / change the project functional currency attributes
 *  this is called from EI enquiry form for EI adjustments
 */
  PROCEDURE  ChangeProjFuncAttributes
                         (ItemsIdTab                 	IN pa_utils.IdTabTyp
                          , p_adjust_level           	IN VARCHAR2
                          , p_user                   	IN NUMBER
                          , p_login                  	IN NUMBER
                          , p_module                 	IN VARCHAR2
                          , p_projfunc_cost_rate_type   IN VARCHAR2
                          , p_projfunc_cost_rate_date   IN DATE
                          , p_projfunc_cost_exchg_rate  IN NUMBER
                          , p_DenomCurrCodeTab          IN pa_utils.Char15TabTyp
                          , p_ProjFuncCurrCodeTab       IN pa_utils.Char15TabTyp
                          , p_rows                      IN NUMBER
                          , X_num_processed             OUT NOCOPY NUMBER
                          , X_num_rejected              OUT NOCOPY NUMBER
                          , X_status                    OUT NOCOPY NUMBER
                         ) IS

     temp_status         NUMBER DEFAULT NULL;
     item_count          NUMBER := 0;
     failed_count        NUMBER := 0 ;
     l_status            VARCHAR2(240)DEFAULT NULL ;
     l_projfunc_cost_exchg_rate NUMBER := p_projfunc_cost_exchg_rate;
     l_projfunc_cost_rate_type  VARCHAR2(30) := p_projfunc_cost_rate_type;
     l_projfunc_cost_rate_date  DATE         := p_projfunc_cost_rate_date;
     l_dummy1            NUMBER ;
     l_dummy2            NUMBER ;
     l_dummy3            NUMBER ;
     PROCEDURE  RecalcRelatedItems( X_expenditure_item_id  IN NUMBER
                                  , X_user                 IN NUMBER
                                  , X_login                IN NUMBER
                                  , X_projfunc_cost_rate_type        IN VARCHAR2
                                  , X_projfunc_cost_rate_date       IN DATE
                                  , X_projfunc_cost_exchg_rate      IN NUMBER
                                  , X_projfunc_currency_code         IN VARCHAR2
                                  , X_module               IN VARCHAR2
                                  , X_status               OUT NOCOPY NUMBER
                                  )
     IS
       CURSOR GetRelatedItems IS
         SELECT
                 expenditure_item_id
           FROM
                 pa_expenditure_items_all
          WHERE
                 source_expenditure_item_id = X_expenditure_item_id;
     BEGIN
       FOR eachRec IN GetRelatedItems LOOP

         UPDATE pa_expenditure_items_all
            SET
                 cost_distributed_flag = 'N'
         ,       revenue_distributed_flag = 'N'
         ,       rev_dist_rejection_code = NULL  /*Added for bug:9367103 */
         ,       projfunc_cost_rate_type = X_projfunc_cost_rate_type
         ,       projfunc_cost_rate_date = X_projfunc_cost_rate_date
         ,       projfunc_cost_exchange_rate =X_projfunc_cost_exchg_rate
         ,       raw_cost = NULL
         ,       burden_cost = NULL
         ,       acct_rate_type = DECODE(X_projfunc_currency_code,
                                         pa_multi_currency.G_accounting_currency_code,
                                         X_projfunc_cost_rate_type, acct_rate_type )
         ,       acct_rate_date = DECODE(X_projfunc_currency_code,
                                         pa_multi_currency.G_accounting_currency_code,
                                         X_projfunc_cost_rate_date , acct_rate_date )
         ,       acct_exchange_rate = DECODE(X_projfunc_currency_code,
                 		             pa_multi_currency.G_accounting_currency_code,
                                             X_projfunc_cost_exchg_rate , acct_exchange_rate )
         ,       acct_raw_cost = DECODE(X_projfunc_currency_code,
                                        pa_multi_currency.G_accounting_currency_code,
                                        NULL, acct_raw_cost )
         ,       acct_burdened_cost = DECODE(X_projfunc_currency_code,
                                        pa_multi_currency.G_accounting_currency_code,
                                        NULL,acct_burdened_cost )
        /** added for project currency changes **/
         ,       project_rate_type = DECODE(x_projfunc_currency_code,project_currency_code,
                                         x_projfunc_cost_rate_type, project_rate_type )
         ,       project_rate_date = DECODE(x_projfunc_currency_code,project_currency_code,
                                         X_projfunc_cost_rate_date , project_rate_date )
         ,       project_exchange_rate = DECODE(x_projfunc_currency_code,project_currency_code,
                                             p_projfunc_cost_exchg_rate , project_exchange_rate )
	 ,       project_raw_cost = DECODE(x_projfunc_currency_code,project_currency_code,
					  NULL ,project_raw_cost)
	 ,       project_burdened_cost = DECODE(x_projfunc_currency_code,project_currency_code,
					 NULL,project_burdened_cost)
        /** end of changes **/
         ,       last_updated_by = X_user
         ,       last_update_date = sysdate
         ,       last_update_login = X_login
           WHERE
                 expenditure_item_id = eachRec.expenditure_item_id;

         item_count := item_count + 1;

         pa_adjustments.InsAuditRec( eachRec.expenditure_item_id
                                   , 'CHANGE PROJ FUNC ATTRIBUTE'
                                   , X_module
                                   , X_user
                                   , X_login
                                   , temp_status
				/* R12 Changes Start */
	                           , G_REQUEST_ID
          	                   , G_PROGRAM_ID
	                           , G_PROG_APPL_ID
	                           , sysdate );
 				/* R12 Changes End */
         CheckStatus( temp_status );

       END LOOP;

     X_status := 0;

     EXCEPTION
       WHEN  OTHERS  THEN
         X_status := SQLCODE;
         RAISE;

     END  RecalcRelatedItems;
  BEGIN
    FOR i IN 1..p_rows LOOP

	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'Inside the ProjFuncCurrCode api p_DenomCurrCodeTab(i)['||p_DenomCurrCodeTab(i)||
	']p_ProjFuncCurrCodeTab(i)['||p_ProjFuncCurrCodeTab(i)||']l_projfunc_cost_rate_date['
        ||l_projfunc_cost_rate_date||']l_projfunc_cost_rate_type['||l_projfunc_cost_rate_type||']' );
	END IF;

      pa_multi_currency.init ;
    IF p_adjust_level = 'S' THEN
	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'calling pa_multi_currency api');
	END IF;
       pa_multi_currency.convert_amount( p_DenomCurrCodeTab(i)
                                        ,p_ProjFuncCurrCodeTab(i)
                                        , l_projfunc_cost_rate_date
                                        , l_projfunc_cost_rate_type
                                        , null
                                        , 'Y'
                                        , 'Y'
                                        , l_dummy1
                                        , l_dummy2
                                        , l_dummy3
                                        , l_projfunc_cost_exchg_rate
                                        , l_status  ) ;

	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'l_projfunc_cost_exchg_rate['||l_projfunc_cost_exchg_rate||']l_projfunc_cost_rate_date['
	||l_projfunc_cost_rate_date||']l_projfunc_cost_rate_type['||l_projfunc_cost_rate_type||']' );
	END IF;
     END IF ;

        IF l_status is not null then
              failed_count := failed_count + 1 ;
	/* R12 Changes Start */
              InsAuditRec( ItemsIdTab(i)
                         , 'CHANGE FUNC ATTRIBUTE'
                         , p_module
                         , p_user
                         , p_login
                         , temp_status
                         , G_REQUEST_ID
                         , G_PROGRAM_ID
                         , G_PROG_APPL_ID
                         , sysdate
                         , l_status);
              CheckStatus(temp_status);
	/* R12 Changes End */

        ELSE
      UPDATE pa_expenditure_items_all ei
         SET
             ei.cost_distributed_flag = 'N'
      ,      ei.revenue_distributed_flag = 'N'
      ,      ei.rev_dist_rejection_code = NULL  /*Added for bug:9367103 */
      ,       projfunc_cost_rate_type = p_projfunc_cost_rate_type
      ,       projfunc_cost_rate_date = p_projfunc_cost_rate_date
      ,       projfunc_cost_exchange_rate = l_projfunc_cost_exchg_rate
      ,       raw_cost = NULL
      ,       burden_cost = NULL
      ,       acct_rate_type = DECODE(p_ProjFuncCurrCodeTab(i),
              				pa_multi_currency.G_accounting_currency_code,
					p_projfunc_cost_rate_type, acct_rate_type )
      ,       acct_rate_date = DECODE(p_ProjFuncCurrCodeTab(i),
              				pa_multi_currency.G_accounting_currency_code,
					p_projfunc_cost_rate_date , acct_rate_date )
      ,       acct_exchange_rate = DECODE(p_ProjFuncCurrCodeTab(i),
              				 pa_multi_currency.G_accounting_currency_code,
              				 l_projfunc_cost_exchg_rate , acct_exchange_rate )
      ,       acct_raw_cost = DECODE(p_ProjFuncCurrCodeTab(i),
              			     	pa_multi_currency.G_accounting_currency_code,
				     	NULL, acct_raw_cost )
      ,       acct_burdened_cost = DECODE(p_ProjFuncCurrCodeTab(i),
              				pa_multi_currency.G_accounting_currency_code,
              				NULL,acct_burdened_cost )
        /** added for project currency changes **/
         ,       project_rate_type = DECODE(p_ProjFuncCurrCodeTab(i), project_currency_code,
                                         p_projfunc_cost_rate_type, project_rate_type )
         ,       project_rate_date = DECODE(p_ProjFuncCurrCodeTab(i), project_currency_code,
                                         p_projfunc_cost_rate_date , project_rate_date )
         ,       project_exchange_rate = DECODE(p_ProjFuncCurrCodeTab(i), project_currency_code,
                                             l_projfunc_cost_exchg_rate , project_exchange_rate )
         ,       project_raw_cost = DECODE(p_ProjFuncCurrCodeTab(i), project_currency_code,
                                          NULL ,project_raw_cost)
         ,       project_burdened_cost = DECODE(p_ProjFuncCurrCodeTab(i), project_currency_code,
                                         NULL,project_burdened_cost)
        /** end of changes **/
      ,      ei.last_update_date = sysdate
      ,      ei.last_updated_by = p_user
      ,      ei.last_update_login = p_login
       WHERE
             ei.expenditure_item_id = ItemsIdTab(i);

	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'Num of rows update for eis ='||sql%rowcount);
	END IF;
      item_count := item_count + 1;
      InsAuditRec( ItemsIdTab(i)
                 , 'CHANGE PROJ FUNC ATTRIBUTE'
                 , p_module
                 , p_user
                 , p_login
                 , temp_status
	/* R12 Changes Start */
	         , G_REQUEST_ID
          	 , G_PROGRAM_ID
	         , G_PROG_APPL_ID
	         , sysdate);
 	/* R12 Changes End */
      CheckStatus( temp_status );

	IF P_DEBUG_MODE  THEN
	   print_message('get_denom_curr_code: ' || 'calling RecalcRelatedItems items ');
	END IF;

    RecalcRelatedItems( ItemsIdTab(i)
                        , p_user
                        , p_login
                        , p_projfunc_cost_rate_type
                        , p_projfunc_cost_rate_date
                        , l_projfunc_cost_exchg_rate
                        , p_ProjFuncCurrCodeTab(i)
                        , p_module
                        , temp_status );
      CheckStatus( temp_status );

    END IF;
    END LOOP;

    X_status := 0;
    X_num_processed := item_count;
    X_num_rejected  := failed_count ;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;

  END  ChangeProjFuncAttributes;

/** This api update the EI table when project curenncy attributes are changed **/

  PROCEDURE  ChangeProjAttributes(ItemsIdTab          IN pa_utils.IdTabTyp
                          , X_adjust_level   IN VARCHAR2
                          , X_user           IN NUMBER
                          , X_login          IN NUMBER
                          , X_module         IN VARCHAR2
                          , X_project_rate_type IN VARCHAR2
			  , X_project_rate_date IN DATE
			  , X_project_exchange_rate IN NUMBER
                          , DenomCurrCodeTab IN pa_utils.Char15TabTyp
                          , ProjCurrCodeTab IN  pa_utils.Char15TabTyp
                          , rows             IN NUMBER
                          , X_num_processed  OUT NOCOPY NUMBER
                          , X_num_rejected   OUT NOCOPY NUMBER
                          , X_status         OUT NOCOPY NUMBER ) IS

     temp_status         NUMBER DEFAULT NULL;
     item_count          NUMBER := 0;
     failed_count        NUMBER := 0 ;
     l_status            VARCHAR2(240)DEFAULT NULL ;
     l_project_exchange_rate NUMBER := X_project_exchange_rate;
     l_project_rate_type  VARCHAR2(30) := X_project_rate_type ;
     l_project_rate_date  DATE         := X_project_rate_date ;
     l_dummy1            NUMBER ;
     l_dummy2            NUMBER ;
     l_dummy3            NUMBER ;

-- pa_multi_currency.init ;

     PROCEDURE  RecalcRelatedItems( X_expenditure_item_id  IN NUMBER
                                  , X_user                 IN NUMBER
                                  , X_login                IN NUMBER
                                  , X_project_rate_type       IN VARCHAR2
			          , X_project_rate_date       IN DATE
			          , X_project_exchange_rate   IN NUMBER
			          , X_project_currency_code IN VARCHAR2
                                  , X_module               IN VARCHAR2
                                  , X_status               OUT NOCOPY NUMBER )
     IS
       CURSOR GetRelatedItems IS
         SELECT
                 expenditure_item_id
           FROM
                 pa_expenditure_items_all
          WHERE
                 source_expenditure_item_id = X_expenditure_item_id;
     BEGIN

       FOR eachRec IN GetRelatedItems LOOP

         UPDATE pa_expenditure_items_all
            SET
                 cost_distributed_flag = 'N'
         ,       revenue_distributed_flag = 'N'
	 ,       rev_dist_rejection_code = NULL  /*Added for bug:9367103 */
         ,       project_rate_type = X_project_rate_type
         ,       project_rate_date = X_project_rate_date
         ,       project_exchange_rate = X_project_exchange_rate
         ,       acct_rate_type = DECODE(X_project_currency_code,
                 			pa_multi_currency.G_accounting_currency_code,
					X_project_rate_type, acct_rate_type )
         ,       acct_rate_date = DECODE(X_project_currency_code,
                 			pa_multi_currency.G_accounting_currency_code,
					X_project_rate_date, acct_rate_date )
         ,       acct_exchange_rate = DECODE(X_project_currency_code,
                 			 pa_multi_currency.G_accounting_currency_code,
                 			 X_project_exchange_rate , acct_exchange_rate )
         ,       project_raw_cost = NULL
         ,       project_burdened_cost = NULL
         ,       acct_raw_cost = DECODE(X_project_currency_code,
                 			pa_multi_currency.G_accounting_currency_code,
					NULL, acct_raw_cost )
         ,       acct_burdened_cost = DECODE(X_project_currency_code,
					pa_multi_currency.G_accounting_currency_code,
					NULL,acct_burdened_cost )
         ,       last_updated_by = X_user
         ,       last_update_date = sysdate
         ,       last_update_login = X_login
           WHERE
                 expenditure_item_id = eachRec.expenditure_item_id;

         item_count := item_count + 1;

         pa_adjustments.InsAuditRec( eachRec.expenditure_item_id
                                   , 'CHANGE PROJ ATTRIBUTE'
                                   , X_module
                                   , X_user
                                   , X_login
                                   , temp_status
				/* R12 Changes Start */
	                           , G_REQUEST_ID
          	                   , G_PROGRAM_ID
	                           , G_PROG_APPL_ID
	                           , sysdate );
 				/* R12 Changes End */
         CheckStatus( temp_status );

       END LOOP;

     X_status := 0;

     EXCEPTION
       WHEN  OTHERS  THEN
         X_status := SQLCODE;
         RAISE;

     END  RecalcRelatedItems;

  BEGIN
    FOR i IN 1..rows LOOP

      pa_multi_currency.init ;
    IF X_adjust_level = 'S' THEN
       pa_multi_currency.convert_amount( DenomCurrCodeTab(i)
                                        ,ProjCurrCodeTab(i)
                                        , l_project_rate_date
                                        , l_project_rate_type
                                        , null
                                        , 'Y'
                                        , 'Y'
                                        , l_dummy1
                                        , l_dummy2
                                        , l_dummy3
                                        , l_project_exchange_rate
                                        , l_status  ) ;
     END IF ;

        IF l_status is not null then
              failed_count := failed_count + 1 ;
	/* R12 Changes Start */
              InsAuditRec( ItemsIdTab(i)
                         , 'CHANGE FUNC ATTRIBUTE'
                         , X_module
                         , X_user
                         , X_login
                         , temp_status
                         , G_REQUEST_ID
                         , G_PROGRAM_ID
                         , G_PROG_APPL_ID
                         , sysdate
                         , l_status);
              CheckStatus(temp_status);
	/* R12 Changes End */
        ELSE

      UPDATE pa_expenditure_items_all ei
         SET
             ei.cost_distributed_flag = 'N'
      ,      ei.revenue_distributed_flag = 'N'
      ,      ei.rev_dist_rejection_code = NULL  /*Added for bug:9367103 */
      ,       project_rate_type = X_project_rate_type
      ,       project_rate_date = X_project_rate_date
      ,       project_exchange_rate = l_project_exchange_rate
      ,       acct_rate_type = DECODE(ProjCurrCodeTab(i),
              				pa_multi_currency.G_accounting_currency_code,
					X_project_rate_type, acct_rate_type )
      ,       acct_rate_date = DECODE(ProjCurrCodeTab(i),
              				pa_multi_currency.G_accounting_currency_code,
					X_project_rate_date , acct_rate_date )
      ,       acct_exchange_rate = DECODE(ProjCurrCodeTab(i),
              				pa_multi_currency.G_accounting_currency_code,
              				X_project_exchange_rate , acct_exchange_rate )
      ,       project_raw_cost = NULL
      ,       project_burdened_cost = NULL
      ,       acct_raw_cost = DECODE(ProjCurrCodeTab(i),
              			pa_multi_currency.G_accounting_currency_code,
				NULL, acct_raw_cost )
      ,       acct_burdened_cost = DECODE(ProjCurrCodeTab(i),
              				pa_multi_currency.G_accounting_currency_code,
              				NULL,acct_burdened_cost )
      ,      ei.last_update_date = sysdate
      ,      ei.last_updated_by = X_user
      ,      ei.last_update_login = X_login
       WHERE
             ei.expenditure_item_id = ItemsIdTab(i);

      item_count := item_count + 1;
      InsAuditRec( ItemsIdTab(i)
                 , 'CHANGE PROJ ATTRIBUTE'
                 , X_module
                 , X_user
                 , X_login
                 , temp_status
	/* R12 Changes Start */
	         , G_REQUEST_ID
          	 , G_PROGRAM_ID
	         , G_PROG_APPL_ID
	         , sysdate );
 	/* R12 Changes End */
      CheckStatus( temp_status );

    RecalcRelatedItems( ItemsIdTab(i)
                        , X_user
                        , X_login
                        , X_project_rate_type
                        , X_project_rate_date
                        , l_project_exchange_rate
                        , ProjCurrCodeTab(i)
                        , X_module
                        , temp_status );
      CheckStatus( temp_status );

    END IF;
    END LOOP;

    X_status := 0;
    X_num_processed := item_count;
    X_num_rejected  := failed_count ;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;

  END  ChangeProjAttributes;

-- New procedure for the Cross Charge Adjustments

  PROCEDURE  ReprocessCrossCharge(ItemsIdTab       IN pa_utils.IdTabTyp
                                , X_adjust_level   IN VARCHAR2
                                , X_user           IN NUMBER
                                , X_login          IN NUMBER
                                , X_module         IN VARCHAR2
                                , X_cc_code        IN VARCHAR2
                                , X_cc_type        IN VARCHAR2
                                , X_bl_dist_code   IN VARCHAR2
                                , X_ic_proc_code   IN VARCHAR2
                                , X_prvdr_orgnzn_id IN NUMBER
                                , X_recvr_orgnzn_id IN NUMBER
                                , rows             IN NUMBER
                                , X_num_processed  OUT NOCOPY NUMBER
                                , X_status         OUT NOCOPY NUMBER ) IS

     temp_status         NUMBER DEFAULT NULL;
     item_count          NUMBER := 0;
     l_project_id                   NUMBER;
     l_task_id                      NUMBER;
     l_expenditure_item_date        DATE;
     l_expenditure_type             VARCHAR2(30);
     l_incurred_by_person_id        NUMBER;
     l_system_linkage_function      VARCHAR2(30);
     l_transaction_source           VARCHAR2(30);
     l_nlr_organization_id          NUMBER;
     l_cc_code_old                  VARCHAR2(1):= NULL;
     l_cc_code                      VARCHAR2(1):= NULL;
     l_bl_dist_code                 VARCHAR2(1):= NULL;
     l_ic_proc_code                 VARCHAR2(1):= NULL;
     l_Status                       VARCHAR2(10);
     l_cc_Type                      VARCHAR2(2):= NULL;
     l_PrvdrOrganizationId          NUMBER := NULL;
     l_RecvrOrganizationId          NUMBER := NULL;
     l_RecvrOrgId                   NUMBER;
     l_Error_Stage                  VARCHAR2(10);
     l_Error_Code                   NUMBER;

    PROCEDURE  RecalcRelatedItems( X_expenditure_item_id  IN NUMBER
                                  , X_user                 IN NUMBER
                                  , X_login                IN NUMBER
                                  , X_module               IN VARCHAR2
                                  , X_status               OUT NOCOPY NUMBER )
     IS
       CURSOR GetRelatedItems IS
         SELECT
                 expenditure_item_id
         FROM
                 pa_expenditure_items_all
         WHERE
                 source_expenditure_item_id = X_expenditure_item_id;
     BEGIN

       FOR eachRec IN GetRelatedItems LOOP

         UPDATE pa_expenditure_items_all
         SET
          cc_cross_charge_code =DECODE(X_adjust_level,'I', X_cc_code, l_cc_code)
      ,   cc_cross_charge_type = DECODE(X_adjust_level,'I',X_cc_type, l_cc_type)
      ,   cc_bl_distributed_code = DECODE(X_adjust_level,'I',X_bl_dist_code,                                              l_bl_dist_code)
      ,   cc_ic_processed_code  =  DECODE(X_adjust_level,'I',X_ic_proc_code,                                              l_ic_proc_code)
      ,   cc_prvdr_organization_id = DECODE(X_adjust_level,'I',X_prvdr_orgnzn_id,                                                l_PrvdrOrganizationId)
      ,   cc_recvr_organization_id = DECODE(X_adjust_level,'I',X_recvr_orgnzn_id,                                                 l_RecvrOrganizationId)
      ,	  denom_tp_currency_code = NULL
      ,	  acct_tp_rate_type  = NULL
      ,	  acct_tp_rate_date   =  NULL
      ,	  acct_tp_exchange_rate =  NULL
      ,   denom_transfer_price = NULL
      ,	  acct_transfer_price = NULL
      ,   projacct_transfer_price = NULL
      ,   cc_markup_base_code= NULL
      ,   tp_base_amount = NULL
      ,   tp_ind_compiled_set_id = NULL
      ,   tp_bill_rate  = NULL
      ,   tp_bill_markup_percentage = NULL
      ,   tp_schedule_line_percentage = NULL
      ,   tp_rule_percentage = NULL
      ,   last_updated_by = X_user
      ,   last_update_date = sysdate
      ,   last_update_login = X_login
      ,   PROJECT_TP_RATE_DATE = null
      ,   PROJECT_TP_RATE_TYPE = null
      ,   PROJECT_TP_EXCHANGE_RATE = null
      ,   PROJECT_TRANSFER_PRICE = null
      ,   PROJFUNC_TP_RATE_DATE  = null
      ,   PROJFUNC_TP_RATE_TYPE  = null
      ,   PROJFUNC_TP_EXCHANGE_RATE = null
      ,   PROJFUNC_TRANSFER_PRICE = null
          WHERE
           expenditure_item_id = eachRec.expenditure_item_id;

         item_count := item_count + 1;

         pa_adjustments.InsAuditRec( eachRec.expenditure_item_id
                                   , 'REPROCESS CROSS CHARGE'
                                   , X_module
                                   , X_user
                                   , X_login
                                   , temp_status
				/* R12 Changes Start */
	                           , G_REQUEST_ID
          	                   , G_PROGRAM_ID
	                           , G_PROG_APPL_ID
	                           , sysdate );
 				/* R12 Changes End */
         CheckStatus( temp_status );

       END LOOP;

     X_status := 0;

     EXCEPTION
       WHEN  OTHERS  THEN
         X_status := SQLCODE;
         RAISE;

     END  RecalcRelatedItems;


BEGIN

    FOR i IN 1..rows LOOP
 IF X_adjust_level = 'S' THEN

-- Decided to fetch the columns needed for passing to the identification
-- API during the MassAdjust select instead of writing a separate
-- select here for performance reasons. We are storing the values fetched
-- in global variables instead of passing as parameters to this procedure
-- as the code was already complete and decided not to add more parameter
-- which would require re testing

 IF P_DEBUG_MODE  THEN
    print_message('get_denom_curr_code: ' || 'before call to CC API, exp item is ['||to_char(ItemsIdTab(i))||']expdateis[ '
	||to_char(ExpItemDateTab(i))||']exp org['||to_char(ExpOrganizationTab(i))||']OU[ '||to_char(ExpOrgTab(i))
	||']exp type[ '||ExpTypeTab(i)||']' );
 END IF;

   pa_cc_ident.pa_cc_identify_txn_adj(ExpOrganizationTab(i),
   				ExpOrgTab(i),
				null,
				TaskIdTab(i),
				ExpItemDateTab(i),
                                ItemsIdTab(i),
				ExpTypeTab(i),
				IncurredByPersonIdTab(i),
				SysLinkageTab(i),
                                NULL, -- proj organization id
                                null, -- PrjOrgId,
                                TrxSourceTab(i),
                                NlrOrganizationIdTab(i),
                                null, -- PrvdrLEId
                                null, -- RecvrLEId
                                l_Status,
                                l_cc_Type,
                                l_cc_Code,
                                l_PrvdrOrganizationId,
                                l_RecvrOrganizationId,
                                l_RecvrOrgId,
                                l_Error_Stage,
                                l_Error_Code,
				X_Calling_Module        => null /* Modified for 3234973 */);

  l_cc_code_old := CrossChargeCodeTab(i) ;

   print_message('Before setting l_cc_code_old['||l_cc_code_old||']l_cc_code['||l_cc_code||']');

  if l_cc_code_old in ( 'N', 'X', 'P') /* Bug 4732956 */
  and l_cc_code = 'I' THEN
           l_ic_proc_code := 'N';
	   l_bl_dist_code := 'X' ;
  elsif l_cc_code_old in ( 'N', 'X', 'P') /* Bug 4732956 */
  and l_cc_code = 'B' THEN
           /* Bug fix: 3065461 setting the bl_dist_code to N instead of X for reprocess CC items
            * when adjustment like No Process cross charge done first and then reporcess cross charge is made
           --l_ic_proc_code := 'N';
           --l_bl_dist_code := 'X' ;
           */
           l_ic_proc_code := 'X';
           l_bl_dist_code := 'N' ;
           /* end of bug fix:3065461 */
  elsif  l_cc_code_old = 'B'
  and l_cc_code = 'I' THEN
           l_ic_proc_code := 'N';
	   l_bl_dist_code := 'N' ;
  elsif l_cc_code_old = 'B'
  and l_cc_code in ( 'N', 'X') THEN
           l_ic_proc_code := 'X';
	   l_bl_dist_code := 'N' ;
  elsif l_cc_code_old = 'I'
  and l_cc_code in ( 'N', 'X') THEN
           l_ic_proc_code := 'N';
	   l_bl_dist_code := 'X' ;
/* Bug 4732956 - Start */
  elsif l_cc_code_old = 'P'
  and l_cc_code in ('N','X') THEN
           l_ic_proc_code := 'X';
           l_bl_dist_code := 'X' ;
/* Bug 4732956 - End */
  elsif l_cc_code_old = 'I'
  and l_cc_code = 'B' THEN
           l_ic_proc_code := 'N';
	   l_bl_dist_code := 'N' ;
  elsif l_cc_code_old = l_cc_code and
        l_cc_code_old = 'B' then
  -- This means that the cc code and/or the cc type has not changed
  -- but the user wants to do a reprocess CC , maybe in order to
  -- recalculate the TP amounts again. Hence, in this case, we
  -- set the appropriate flag to 'N'
           l_ic_proc_code := 'X';
           l_bl_dist_code := 'N' ;
  elsif l_cc_code_old = l_cc_code and
        l_cc_code_old = 'I' then
          l_ic_proc_code := 'N';
           l_bl_dist_code := 'X' ;
/*** Bug 2215272 change the if condition
 *** elsif l_cc_code_old = l_cc_code and **/
  elsif l_cc_code in ('N','X') and
        l_cc_code_old in ('N', 'X') then
           l_ic_proc_code := 'X';
           l_bl_dist_code := 'X' ;
  end if;
 END IF;

  print_message('After setting l_ic_proc_code ['||l_ic_proc_code||']l_bl_dist_code['||l_bl_dist_code||
         ']X_cc_code['||X_cc_code||']X_cc_type['||X_cc_type||']X_bl_dist_code['||X_bl_dist_code||
         ']X_ic_proc_code['||X_ic_proc_code||']X_prvdr_orgnzn_id['||X_prvdr_orgnzn_id||
         ']X_recvr_orgnzn_id['||X_recvr_orgnzn_id||']l_PrvdrOrganizationId['||l_PrvdrOrganizationId||
         ']l_RecvrOrganizationId['||l_RecvrOrganizationId||']');

         UPDATE pa_expenditure_items_all
         SET
          cc_cross_charge_code =DECODE(X_adjust_level,'I', X_cc_code, l_cc_code)
      ,   cc_cross_charge_type = DECODE(X_adjust_level,'I',X_cc_type, l_cc_type)
      ,   cc_bl_distributed_code = DECODE(X_adjust_level,'I',X_bl_dist_code,                                              l_bl_dist_code)
      ,   cc_ic_processed_code  =  DECODE(X_adjust_level,'I',X_ic_proc_code,                                              l_ic_proc_code)
      ,   cc_prvdr_organization_id = DECODE(X_adjust_level,'I',X_prvdr_orgnzn_id,                                                l_PrvdrOrganizationId)
      ,   cc_recvr_organization_id = DECODE(X_adjust_level,'I',X_recvr_orgnzn_id,                                                 l_RecvrOrganizationId)
      ,	  denom_tp_currency_code = NULL
      ,	  acct_tp_rate_type  = NULL
      ,	  acct_tp_rate_date   =  NULL
      ,	  acct_tp_exchange_rate =  NULL
      ,   denom_transfer_price = NULL
      ,	  acct_transfer_price = NULL
      ,   projacct_transfer_price = NULL
      ,   cc_markup_base_code= NULL
      ,   tp_base_amount = NULL
      ,   tp_ind_compiled_set_id = NULL
      ,   tp_bill_rate  = NULL
      ,   tp_bill_markup_percentage = NULL
      ,   tp_schedule_line_percentage = NULL
      ,   tp_rule_percentage = NULL
      ,   last_updated_by = X_user
      ,   last_update_date = sysdate
      ,   last_update_login = X_login
      ,   PROJECT_TP_RATE_DATE = null
      ,   PROJECT_TP_RATE_TYPE = null
      ,   PROJECT_TP_EXCHANGE_RATE = null
      ,   PROJECT_TRANSFER_PRICE = null
      ,   PROJFUNC_TP_RATE_DATE  = null
      ,   PROJFUNC_TP_RATE_TYPE  = null
      ,   PROJFUNC_TP_EXCHANGE_RATE = null
      ,   PROJFUNC_TRANSFER_PRICE = null
          WHERE
          expenditure_item_id = ItemsIdTab(i);
      item_count := item_count + 1;

      InsAuditRec( ItemsIdTab(i)
                 , 'REPROCESS CROSS CHARGE'
                 , X_module
                 , X_user
                 , X_login
                 , temp_status
	/* R12 Changes Start */
	         , G_REQUEST_ID
          	 , G_PROGRAM_ID
	         , G_PROG_APPL_ID
	         , sysdate );
 	/* R12 Changes End */
      CheckStatus( temp_status );


      RecalcRelatedItems( ItemsIdTab(i)
                        , X_user
                        , X_login
                        , X_module
                        , temp_status );
      CheckStatus( temp_status );

    END LOOP;

    X_status := 0;
    X_num_processed := item_count;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;
END ReprocessCrossCharge ;

  PROCEDURE  MarkNoCCProcess    (ItemsIdTab       IN pa_utils.IdTabTyp
                                , X_adjust_level   IN VARCHAR2
                                , X_user           IN NUMBER
                                , X_login          IN NUMBER
                                , X_module         IN VARCHAR2
                                , X_bl_dist_code   IN VARCHAR2
                                , X_ic_proc_code   IN VARCHAR2
                                , rows             IN NUMBER
                                , X_num_processed  OUT NOCOPY NUMBER
                                , X_status         OUT NOCOPY NUMBER ) IS

     temp_status         NUMBER DEFAULT NULL;
     item_count          NUMBER := 0;
     l_cc_code_old                  VARCHAR2(1):= NULL;
     l_bl_dist_code                 VARCHAR2(1):= NULL;
     l_ic_proc_code                 VARCHAR2(1):= NULL;

    PROCEDURE  RecalcRelatedItems( X_expenditure_item_id  IN NUMBER
                                  , X_user                 IN NUMBER
                                  , X_login                IN NUMBER
                                  , X_module               IN VARCHAR2
                                  , X_status               OUT NOCOPY NUMBER )
     IS
       CURSOR GetRelatedItems IS
         SELECT
                 expenditure_item_id
         FROM
                 pa_expenditure_items_all
         WHERE
                 source_expenditure_item_id = X_expenditure_item_id;
     BEGIN
 --print_message('in related ei');
      FOR eachRec IN GetRelatedItems LOOP
 --print_message('in related ei loop');
         UPDATE pa_expenditure_items_all
         SET
          cc_cross_charge_code = 'N'
      ,   cc_bl_distributed_code = DECODE(X_adjust_level,'I',X_bl_dist_code,                                              l_bl_dist_code)
      ,   cc_ic_processed_code  =  DECODE(X_adjust_level,'I',X_ic_proc_code,                                              l_ic_proc_code)
      ,	  denom_tp_currency_code = NULL
      ,	  acct_tp_rate_type  = NULL
      ,	  acct_tp_rate_date   =  NULL
      ,	  acct_tp_exchange_rate =  NULL
      ,   denom_transfer_price = NULL
      ,	  acct_transfer_price = NULL
      ,   projacct_transfer_price = NULL
      ,   cc_markup_base_code= NULL
      ,   tp_base_amount = NULL
      ,   tp_ind_compiled_set_id = NULL
      ,   tp_bill_rate  = NULL
      ,   tp_bill_markup_percentage = NULL
      ,   tp_schedule_line_percentage = NULL
      ,   tp_rule_percentage = NULL
      ,   last_updated_by = X_user
      ,   last_update_date = sysdate
      ,   last_update_login = X_login
      ,   PROJECT_TP_RATE_DATE = null
      ,   PROJECT_TP_RATE_TYPE = null
      ,   PROJECT_TP_EXCHANGE_RATE = null
      ,   PROJECT_TRANSFER_PRICE = null
      ,   PROJFUNC_TP_RATE_DATE  = null
      ,   PROJFUNC_TP_RATE_TYPE  = null
      ,   PROJFUNC_TP_EXCHANGE_RATE = null
      ,   PROJFUNC_TRANSFER_PRICE = null
          WHERE
           expenditure_item_id = eachRec.expenditure_item_id;

         item_count := item_count + 1;

         pa_adjustments.InsAuditRec( eachRec.expenditure_item_id
                                   , 'MARK NO CC PROCESS'
                                   , X_module
                                   , X_user
                                   , X_login
                                   , temp_status
				/* R12 Changes Start */
	                           , G_REQUEST_ID
          	                   , G_PROGRAM_ID
	                           , G_PROG_APPL_ID
	                           , sysdate );
 				/* R12 Changes End */
         CheckStatus( temp_status );

       END LOOP;

     X_status := 0;

     EXCEPTION
       WHEN  OTHERS  THEN
         X_status := SQLCODE;
         RAISE;

     END  RecalcRelatedItems;


BEGIN
    FOR i IN 1..rows LOOP
 IF X_adjust_level = 'S' THEN
   l_cc_code_old := CrossChargeCodeTab(i) ;

  if    l_cc_code_old = 'B'then
           l_ic_proc_code := 'X';
	   l_bl_dist_code := 'N' ;
  elsif l_cc_code_old = 'I'then
           l_ic_proc_code := 'N';
	   l_bl_dist_code := 'X' ;
  end if;
 END IF;


         UPDATE pa_expenditure_items_all
         SET
          cc_cross_charge_code = 'N'
      ,   cc_bl_distributed_code = DECODE(X_adjust_level,'I',X_bl_dist_code,                                              l_bl_dist_code)
      ,   cc_ic_processed_code  =  DECODE(X_adjust_level,'I',X_ic_proc_code,                                              l_ic_proc_code)
      ,	  denom_tp_currency_code = NULL
      ,	  acct_tp_rate_type  = NULL
      ,	  acct_tp_rate_date   =  NULL
      ,	  acct_tp_exchange_rate =  NULL
      ,   denom_transfer_price = NULL
      ,	  acct_transfer_price = NULL
      ,   projacct_transfer_price = NULL
      ,   cc_markup_base_code= NULL
      ,   tp_base_amount = NULL
      ,   tp_ind_compiled_set_id = NULL
      ,   tp_bill_rate  = NULL
      ,   tp_bill_markup_percentage = NULL
      ,   tp_schedule_line_percentage = NULL
      ,   tp_rule_percentage = NULL
      ,   last_updated_by = X_user
      ,   last_update_date = sysdate
      ,   last_update_login = X_login
      ,   PROJECT_TP_RATE_DATE = null
      ,   PROJECT_TP_RATE_TYPE = null
      ,   PROJECT_TP_EXCHANGE_RATE = null
      ,   PROJECT_TRANSFER_PRICE = null
      ,   PROJFUNC_TP_RATE_DATE  = null
      ,   PROJFUNC_TP_RATE_TYPE  = null
      ,   PROJFUNC_TP_EXCHANGE_RATE = null
      ,   PROJFUNC_TRANSFER_PRICE = null

          WHERE
          expenditure_item_id = ItemsIdTab(i);

      item_count := item_count + 1;

      InsAuditRec( ItemsIdTab(i)
                 , 'MARK NO CC PROCESS'
                 , X_module
                 , X_user
                 , X_login
                 , temp_status
	/* R12 Changes Start */
	         , G_REQUEST_ID
          	 , G_PROGRAM_ID
	         , G_PROG_APPL_ID
	         , sysdate );
 	/* R12 Changes End */
      CheckStatus( temp_status );

 IF P_DEBUG_MODE  THEN
    print_message('get_denom_curr_code: ' || 'ei is '||to_char(ItemsIdTab(i)));
 END IF;
      RecalcRelatedItems( ItemsIdTab(i)
                        , X_user
                        , X_login
                        , X_module
                        , temp_status );
      CheckStatus( temp_status );

    END LOOP;

    X_status := 0; X_status := 0;
    X_num_processed := item_count;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;
  END MarkNoCCProcess ;

  PROCEDURE  ChangeTPAttributes(ItemsIdTab          IN pa_utils.IdTabTyp
                          , X_adjust_level          IN VARCHAR2
                          , X_user                  IN NUMBER
                          , X_login                 IN NUMBER
                          , X_module                IN VARCHAR2
                          , X_acct_tp_rate_type     IN VARCHAR2
                          , X_acct_tp_rate_date     IN DATE
                          , X_acct_tp_exchange_rate IN NUMBER
    	                  , X_bl_dist_code          IN VARCHAR2
                          , X_ic_proc_code          IN VARCHAR2
                          , DenomCurrCodeTab        IN pa_utils.Char15TabTyp
                          , rows                    IN NUMBER
                          , X_num_processed         OUT NOCOPY NUMBER
                          , X_num_rejected          OUT NOCOPY NUMBER
                          , X_status                OUT NOCOPY NUMBER
 			  , p_PROJECT_TP_COST_RATE_DATE   IN   DATE
 			  , p_PROJECT_TP_COST_RATE_TYPE   IN   VARCHAR2
 			  , p_PROJECT_TP_COST_EXCHG_RATE  IN   NUMBER
                          )  IS

     temp_status         NUMBER DEFAULT NULL;
     item_count          NUMBER := 0;
     failed_count        NUMBER := 0 ;
     l_status            VARCHAR2(240)DEFAULT NULL ;
     l_acct_exchange_rate NUMBER    := X_acct_tp_exchange_rate;
     l_acct_rate_type  VARCHAR2(30) := X_acct_tp_rate_type ;
     l_acct_rate_date  DATE         := X_acct_tp_rate_date ;
     l_dummy1            NUMBER ;
     l_dummy2            NUMBER ;
     l_dummy3            NUMBER ;
     l_cc_code_old       VARCHAR2(1):= NULL;
     l_bl_dist_code      VARCHAR2(1):= NULL;
     l_ic_proc_code      VARCHAR2(1):= NULL;

     PROCEDURE  RecalcRelatedItems( X_expenditure_item_id  IN NUMBER
                                  , X_user                 IN NUMBER
                                  , X_login                IN NUMBER
                                  , X_acct_tp_rate_type    IN VARCHAR2
                                  , X_acct_tp_rate_date    IN DATE
                                  , X_acct_tp_exchange_rateIN NUMBER
                                  , X_module               IN VARCHAR2
                                  , X_status               OUT NOCOPY NUMBER
                          	  , p_PROJECT_TP_COST_RATE_DATE      IN   DATE  default null
                          	  , p_PROJECT_TP_COST_RATE_TYPE      IN   VARCHAR2 default null
                          	  , p_PROJECT_TP_COST_EXCHG_RATE  IN   NUMBER default null )
     IS
       CURSOR GetRelatedItems IS
         SELECT
                 expenditure_item_id
           FROM
                 pa_expenditure_items_all
          WHERE
                 source_expenditure_item_id = X_expenditure_item_id;
     BEGIN

       FOR eachRec IN GetRelatedItems LOOP

         UPDATE pa_expenditure_items_all

          SET
           cc_bl_distributed_code = DECODE(X_adjust_level,'I',X_bl_dist_code,                                              l_bl_dist_code)
         , cc_ic_processed_code  =  DECODE(X_adjust_level,'I',X_ic_proc_code,                                              l_ic_proc_code)
         , acct_tp_rate_type = X_acct_tp_rate_type
         , acct_tp_rate_date = X_acct_tp_rate_date
         , acct_tp_exchange_rate = l_acct_exchange_rate
        --- , PROJECT_TP_RATE_DATE = p_PROJECT_TP_COST_RATE_DATE
        --- , PROJECT_TP_RATE_TYPE = p_PROJECT_TP_COST_RATE_TYPE
        --- , PROJECT_TP_EXCHANGE_RATE = p_PROJECT_TP_COST_EXCHG_RATE
         , PROJECT_TRANSFER_PRICE = NULL
         , PROJFUNC_TRANSFER_PRICE = NULL
         , denom_transfer_price = NULL
         , acct_transfer_price = NULL
         , last_updated_by = X_user
         , last_update_date = sysdate
         , last_update_login = X_login
           WHERE
                 expenditure_item_id = eachRec.expenditure_item_id;

         item_count := item_count + 1;

         pa_adjustments.InsAuditRec( eachRec.expenditure_item_id
                                   , 'CHANGE TP ATTRIBUTE'
                                   , X_module
                                   , X_user
                                   , X_login
                                   , temp_status
				/* R12 Changes Start */
	                           , G_REQUEST_ID
          	                   , G_PROGRAM_ID
	                           , G_PROG_APPL_ID
	                           , sysdate );
 				/* R12 Changes End */
         CheckStatus( temp_status );

       END LOOP;

     X_status := 0;

     EXCEPTION
       WHEN  OTHERS  THEN
         X_status := SQLCODE;
         RAISE;

     END  RecalcRelatedItems;


  BEGIN
    FOR i IN 1..rows LOOP
       pa_multi_currency.init ;
     IF X_adjust_level = 'S' THEN
        l_cc_code_old := CrossChargeCodeTab(i);

     if l_cc_code_old = 'B' then
           l_ic_proc_code := 'X';
	   l_bl_dist_code := 'N' ;
     elsif l_cc_code_old = 'I' then
           l_ic_proc_code := 'N';
	   l_bl_dist_code := 'X' ;
     end if;
 IF P_DEBUG_MODE  THEN
    print_message('get_denom_curr_code: ' || 'X rate is['||to_char(X_acct_tp_exchange_rate)||']l rate ['||to_char(l_acct_exchange_rate)||']' );
 END IF;

       pa_multi_currency.convert_amount( DenomTpCurrCodeTab(i)
                                 , pa_multi_currency.G_accounting_currency_code
                                 , l_acct_rate_date
                                 , l_acct_rate_type
                                 , null
                                 , 'Y'
                                 , 'Y'
                                 , l_dummy1
                                 , l_dummy2
                                 , l_dummy3
                                 , l_acct_exchange_rate
                                 , l_status  ) ;
 IF P_DEBUG_MODE  THEN
    print_message('get_denom_curr_code: ' || 'X rate after convert amt ['||to_char(l_acct_exchange_rate)||']status ['||l_status||']' );
 END IF;
 END IF ;


  IF l_status is not null then
              failed_count := failed_count + 1 ;
	/* R12 Changes Start */
              InsAuditRec( ItemsIdTab(i)
                         , 'CHANGE FUNC ATTRIBUTE'
                         , X_module
                         , X_user
                         , X_login
                         , temp_status
                         , G_REQUEST_ID
                         , G_PROGRAM_ID
                         , G_PROG_APPL_ID
                         , sysdate
                         , l_status);
              CheckStatus(temp_status);
	/* R12 Changes End */
  ELSE

        UPDATE pa_expenditure_items_all ei
         SET
         cc_bl_distributed_code = DECODE(X_adjust_level, 'I', X_bl_dist_code,                                            l_bl_dist_code)
       , cc_ic_processed_code  =  DECODE(X_adjust_level, 'I',X_ic_proc_code,                                             l_ic_proc_code)
       , acct_tp_rate_type = X_acct_tp_rate_type
       , acct_tp_rate_date = X_acct_tp_rate_date
       , acct_tp_exchange_rate = l_acct_exchange_rate
       , denom_transfer_price = NULL
       , acct_transfer_price = NULL
       , last_updated_by = X_user
       , last_update_date = sysdate
       , last_update_login = X_login
       ---, PROJECT_TP_RATE_DATE = p_PROJECT_TP_COST_RATE_DATE
       ---, PROJECT_TP_RATE_TYPE = p_PROJECT_TP_COST_RATE_TYPE
       ---, PROJECT_TP_EXCHANGE_RATE = p_PROJECT_TP_COST_EXCHG_RATE
       , PROJECT_TRANSFER_PRICE = NULL
       , PROJFUNC_TRANSFER_PRICE = NULL

        WHERE
         ei.expenditure_item_id = ItemsIdTab(i);

      item_count := item_count + 1;

      InsAuditRec( ItemsIdTab(i)
                 , 'CHANGE TP ATTRIBUTE'
                 , X_module
                 , X_user
                 , X_login
                 , temp_status
	/* R12 Changes Start */
	         , G_REQUEST_ID
          	 , G_PROGRAM_ID
	         , G_PROG_APPL_ID
	         , sysdate );
 	/* R12 Changes End */
      CheckStatus( temp_status );

    RecalcRelatedItems( ItemsIdTab(i)
                        , X_user
                        , X_login
                        , X_acct_tp_rate_type
                        , X_acct_tp_rate_date
                        , l_acct_exchange_rate
                        , X_module
                        , temp_status );
      CheckStatus( temp_status );

    END IF ;
    END LOOP;

    X_status := 0;
    X_num_processed := item_count;
    X_num_rejected  := failed_count ;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;

  END  ChangeTPAttributes;


PROCEDURE Allow_Adjustment(
                             p_transaction_source                   IN VARCHAR2,
                             p_orig_transaction_reference           IN VARCHAR2,
                             p_expenditure_type_class               IN VARCHAR2,
                             p_expenditure_type                     IN VARCHAR2,
                             p_expenditure_item_id                  IN NUMBER,
                             p_expenditure_item_date                IN DATE,
                             p_employee_number                      IN VARCHAR2,
                             p_expenditure_org_name                 IN VARCHAR2,
                             p_project_number                       IN VARCHAR2,
                             p_task_number                          IN VARCHAR2,
                             p_non_labor_resource                   IN VARCHAR2,
                             p_non_labor_resource_org_name          IN VARCHAR2,
                             p_quantity                             IN NUMBER,
                             p_raw_cost                             IN NUMBER,
                             p_attribute_category                   IN VARCHAR2,
                             p_attribute1                           IN VARCHAR2,
                             p_attribute2                           IN VARCHAR2,
                             p_attribute3                           IN VARCHAR2,
                             p_attribute4                           IN VARCHAR2,
                             p_attribute5                           IN VARCHAR2,
                             p_attribute6                           IN VARCHAR2,
                             p_attribute7                           IN VARCHAR2,
                             p_attribute8                           IN VARCHAR2,
                             p_attribute9                           IN VARCHAR2,
                             p_attribute10                          IN VARCHAR2,
                             p_org_id                               IN NUMBER,
                             x_allow_adjustment_code                OUT NOCOPY VARCHAR2,
                             x_return_status                        OUT NOCOPY VARCHAR2,
                             x_application_code                     OUT NOCOPY VARCHAR2,
                             x_message_code                         OUT NOCOPY VARCHAR2,
                             x_token_name1                          OUT NOCOPY VARCHAR2,
                             x_token_val1                           OUT NOCOPY VARCHAR2,
                             x_token_name2                          OUT NOCOPY VARCHAR2,
                             x_token_val2                           OUT NOCOPY VARCHAR2,
                             x_token_name3                          OUT NOCOPY VARCHAR2,
                             x_token_val3                           OUT NOCOPY VARCHAR2)

IS

TYPE net_zero_ei_date_rec_type IS RECORD (
     net_zero_adjustment_flag_1     pa_expenditure_items_all.net_zero_adjustment_flag%TYPE DEFAULT NULL,
     expenditure_item_date_1        pa_expenditure_items_all.expenditure_item_date%TYPE DEFAULT NULL,
     net_zero_adjustment_flag_2     pa_expenditure_items_all.net_zero_adjustment_flag%TYPE DEFAULT NULL,
     expenditure_item_date_2        pa_expenditure_items_all.expenditure_item_date%TYPE DEFAULT NULL,
     net_zero_adjustment_flag_3     pa_expenditure_items_all.net_zero_adjustment_flag%TYPE DEFAULT NULL,
     expenditure_item_date_3        pa_expenditure_items_all.expenditure_item_date%TYPE DEFAULT NULL,
     net_zero_adjustment_flag_4     pa_expenditure_items_all.net_zero_adjustment_flag%TYPE DEFAULT NULL,
     expenditure_item_date_4        pa_expenditure_items_all.expenditure_item_date%TYPE DEFAULT NULL,
     net_zero_adjustment_flag_5     pa_expenditure_items_all.net_zero_adjustment_flag%TYPE DEFAULT NULL,
     expenditure_item_date_5        pa_expenditure_items_all.expenditure_item_date%TYPE DEFAULT NULL,
     net_zero_adjustment_flag_6     pa_expenditure_items_all.net_zero_adjustment_flag%TYPE DEFAULT NULL,
     expenditure_item_date_6        pa_expenditure_items_all.expenditure_item_date%TYPE DEFAULT NULL,
     net_zero_adjustment_flag_7     pa_expenditure_items_all.net_zero_adjustment_flag%TYPE DEFAULT NULL,
     expenditure_item_date_7        pa_expenditure_items_all.expenditure_item_date%TYPE DEFAULT NULL);

l_net_zero_ei_date         net_zero_ei_date_rec_type;
l_allow_adjustment_flag    VARCHAR2(1);
l_predefined_flag          VARCHAR2(1);

CURSOR allow_adjustment IS
SELECT allow_adjustments_flag, predefined_flag
FROM   pa_transaction_sources
WHERE  transaction_source = p_transaction_source;

CURSOR sst_adjustment IS
SELECT net_zero_adjustment_flag_1,
       expenditure_item_date_1,
       net_zero_adjustment_flag_2,
       expenditure_item_date_2,
       net_zero_adjustment_flag_3,
       expenditure_item_date_3,
       net_zero_adjustment_flag_4,
       expenditure_item_date_4,
       net_zero_adjustment_flag_5,
       expenditure_item_date_5,
       net_zero_adjustment_flag_6,
       expenditure_item_date_6,
       net_zero_adjustment_flag_7,
       expenditure_item_date_7
FROM   PA_EI_DENORM
WHERE  denorm_id = p_orig_transaction_reference;

l_test NUMBER;

BEGIN

--If the transaction source is NULL then the item was not imported to Projects
--from an external system so RETURN.


IF (p_transaction_source IS NULL) THEN

     x_return_status := 'S';

     RETURN;

END IF; --p_transaction_source is null

--If p_transaction_source is Oracle Self Service Time then check if the item has
--already been adjusted in Self Service Time.

IF (p_transaction_source = 'Oracle Self Service Time') THEN

     OPEN sst_adjustment;

     FETCH sst_adjustment INTO l_net_zero_ei_date;

     --If no records are in the cursor then the item was not found in SST.
     --This indicates data corruption.  No adjustment will be allowed.

     IF (sst_adjustment%ROWCOUNT = 0) THEN

          x_allow_adjustment_code := 'N';

          x_return_status := 'E';

          x_application_code := 'PA';

          x_message_code := 'PA_SST_ITEM_NOT_FOUND';

     ELSIF (l_net_zero_ei_date.expenditure_item_date_1 = p_expenditure_item_date) AND
        (l_net_zero_ei_date.net_zero_adjustment_flag_1 = 'Y') THEN

          x_allow_adjustment_code := 'N';
          x_return_status := 'S';

     ELSIF (l_net_zero_ei_date.expenditure_item_date_2 = p_expenditure_item_date) AND
           (l_net_zero_ei_date.net_zero_adjustment_flag_2 = 'Y') THEN

          x_allow_adjustment_code := 'N';
          x_return_status := 'S';

     ELSIF (l_net_zero_ei_date.expenditure_item_date_3 = p_expenditure_item_date) AND
           (l_net_zero_ei_date.net_zero_adjustment_flag_3 = 'Y') THEN

          x_allow_adjustment_code := 'N';
          x_return_status := 'S';

     ELSIF (l_net_zero_ei_date.expenditure_item_date_4 = p_expenditure_item_date) AND
           (l_net_zero_ei_date.net_zero_adjustment_flag_4 = 'Y') THEN

          x_allow_adjustment_code := 'N';
          x_return_status := 'S';

     ELSIF (l_net_zero_ei_date.expenditure_item_date_5 = p_expenditure_item_date) AND
           (l_net_zero_ei_date.net_zero_adjustment_flag_5 = 'Y') THEN

          x_allow_adjustment_code := 'N';
          x_return_status := 'S';

     ELSIF (l_net_zero_ei_date.expenditure_item_date_6 = p_expenditure_item_date) AND
           (l_net_zero_ei_date.net_zero_adjustment_flag_6 = 'Y') THEN

          x_allow_adjustment_code := 'N';
          x_return_status := 'S';

     ELSIF (l_net_zero_ei_date.expenditure_item_date_7 = p_expenditure_item_date) AND
           (l_net_zero_ei_date.net_zero_adjustment_flag_7 = 'Y') THEN

          x_allow_adjustment_code := 'N';
          x_return_status := 'S';

     --If the net_zero_adjustmentment_flag <> 'Y' then an adjustment should be allowed.

     ELSE x_allow_adjustment_code := 'Y';
          x_return_status := 'S';

     END IF;

     CLOSE sst_adjustment;

--If the transaction source is NOT NULL and is NOT SST then
--open the allow_adjustment cursor.

ELSE OPEN allow_adjustment;

     FETCH allow_adjustment INTO l_allow_adjustment_flag, l_predefined_flag;

     CLOSE allow_adjustment;

     --If the transaction source is seeded then set x_allow_adjustment_code
     --to the allow_adjustment_flag for that transaction source.

     IF (l_predefined_flag = 'Y') THEN

          x_allow_adjustment_code := l_allow_adjustment_flag;
          x_return_status := 'S';

     --If the transaction source is not seeded then call
     --the Allow Adjustment client extension.  By default, the
     --allow_adjustment_extn will return the allow_adjustment_flag
     --for the given transaction source.

     ELSE PA_TRANSACTIONS_PUB.Allow_Adjustment_Extn(
                             p_transaction_source => p_transaction_source,
                             p_allow_adjustment_flag => l_allow_adjustment_flag,
                             p_orig_transaction_reference => p_orig_transaction_reference,
                             p_expenditure_type_class => p_expenditure_type_class,
                             p_expenditure_type => p_expenditure_type,
                             p_expenditure_item_id => p_expenditure_item_id,
                             p_expenditure_item_date => p_expenditure_item_date,
                             p_employee_number => p_employee_number,
                             p_expenditure_org_name => p_expenditure_org_name,
                             p_project_number => p_project_number,
                             p_task_number => p_task_number,
                             p_non_labor_resource => p_non_labor_resource,
                             p_non_labor_resource_org_name => p_non_labor_resource_org_name,
                             p_quantity => p_quantity,
                             p_raw_cost => p_raw_cost,
                             p_attribute_category => p_attribute_category,
                             p_attribute1 => p_attribute1,
                             p_attribute2 => p_attribute2,
                             p_attribute3 => p_attribute3,
                             p_attribute4 => p_attribute4,
                             p_attribute5 => p_attribute5,
                             p_attribute6 => p_attribute6,
                             p_attribute7 => p_attribute7,
                             p_attribute8 => p_attribute8,
                             p_attribute9 => p_attribute9,
                             p_attribute10 => p_attribute10,
                             p_org_id => p_org_id,
                             x_allow_adjustment_code => x_allow_adjustment_code,
                             x_return_status => x_return_status,
                             x_application_code => x_application_code,
                             x_message_code => x_message_code,
                             x_token_name1 => x_token_name1,
                             x_token_val1 => x_token_val1,
                             x_token_name2 => x_token_name2,
                             x_token_val2 => x_token_val2,
                             x_token_name3 => x_token_name3,
                             x_token_val3 => x_token_val3);

     End IF; --l_predefined_flag = 'Y'

END IF; --p_transaction_source = 'Oracle Self Service Time'

EXCEPTION

     WHEN others THEN

          x_return_status := 'U';

          x_message_code := to_char(SQLCODE);

END Allow_Adjustment;

/* This public function get_denom_curr_code() is added for bug#2291180 */
FUNCTION get_denom_curr_code
	(p_transaction_source        IN VARCHAR2
         , p_exp_type                IN VARCHAR2
         , p_denom_currency_code     IN VARCHAR2
         , p_acct_currency_code      IN VARCHAR2
         , p_system_linkage_function IN VARCHAR2
         , p_calling_mode            IN VARCHAR2 default 'ADJUST' /*Bugfix:2798742 */
         , p_person_id               IN NUMBER   default NULL    /*Bugfix:2798742 */
	 , p_ei_date                 IN DATE     default NULL   /*Bugfix:2798742 */
                             ) RETURN VARCHAR2 IS

   l_return_currency_code     pa_expenditure_items_all.denom_currency_code%type;
   l_gl_accounted_flag        pa_transaction_sources.gl_accounted_flag%type;
   l_costed_flag              pa_transaction_sources.costed_flag%type;  /* added bug 3142879 */
   l_cost_rate_flag           pa_expenditure_types.cost_rate_flag%type;
   l_job_id                   pa_expenditure_items_all.job_id%TYPE;
   l_organization_id          pa_expenditures_all.incurred_by_organization_id%TYPE;
   l_cost_rate                pa_bill_rates_all.rate%TYPE;
   l_start_date               Date;
   l_end_date                 Date;
   l_org_labor_sch_rule_id    pa_org_labor_sch_rule.org_labor_sch_rule_id%TYPE;
   l_costing_rule             pa_compensation_rule_sets.compensation_rule_set%TYPE;
   l_rate_sch_id              pa_std_bill_rate_schedules_all.bill_rate_sch_id%TYPE;
   l_acct_rate_type           pa_expenditure_items_all.acct_rate_type%TYPE;
   l_acct_rate_date_code      pa_implementations_all.acct_rate_date_code%TYPE;
   l_acct_exch_rate           pa_org_labor_sch_rule.acct_exchange_rate%TYPE;
   l_ot_project_id            pa_projects_all.project_id%TYPE;
   l_ot_task_id               pa_tasks.task_id%TYPE;
   l_err_stage                number;
   l_err_code                 varchar2(1000);
   OTHERS_EXCEPTION           EXCEPTION;

BEGIN

     /* If Transaction Source is Null, set the flag to 'N' */
      IF p_transaction_source IS NULL THEN
          l_gl_accounted_flag := 'N';
          l_costed_flag       := 'N';/* added bug 3142879 */
      ELSE
            SELECT  gl_accounted_flag, costed_flag
              INTO  l_gl_accounted_flag, l_costed_flag  /* added costed flag bug 3142879 */
              FROM  pa_transaction_sources
             WHERE  transaction_source = p_transaction_source;
       END IF;

      /* Get the cost_rate_flag */
       BEGIN
            SELECT  cost_rate_flag
              INTO  l_cost_rate_flag
              FROM  pa_expenditure_types
             WHERE  expenditure_type = p_exp_type;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
                 l_cost_rate_flag := 'N';

        END;  /* cost_rate_flag */

   /*
      Do not do any processing if the EI is externally accounted
      or
      EI(s) are from the Expense Reports entered in PA.
      For ST/OT/Usages, if acct_currency_code <> denom_currency_code,
      then return functional currency code from the SOB.
      Else if cost_rate_flag is Y and acct_currency_code <> denom_currency_code
      then return functional currency code from the SOB.
   */

   IF (l_gl_accounted_flag = 'Y') OR (l_costed_flag = 'Y') OR /* added costed flag bug 3142879 */
      (p_transaction_source IS NULL and p_system_linkage_function = 'ER') THEN

        l_return_currency_code := p_denom_currency_code;

   ELSIF p_system_linkage_function in ('ST','OT') THEN
       /** Start of Bug fix:2798742 */
         IF p_acct_currency_code = p_denom_currency_code THEN
                  l_return_currency_code := p_denom_currency_code;
         ELSE
            /* bug fix:2822620 get_labor_rate API should be called only for Split, as these EIs are not
             * cost distributed again, where as for Transfer case, New currency code will be
             * derived during cost distribution process
             */
            IF p_calling_mode = 'SPLIT' Then

		  l_return_currency_code := null;
                  --Derive denorm_currency_code based on rate
		     PA_COST_RATE_PUB.get_labor_rate
			( p_person_id              => p_person_id
                          ,p_txn_date              => p_ei_date
                          ,p_calling_module        => 'STAFFED'
                          ,x_job_id                => l_job_id
                          ,x_organization_id       => l_organization_id
                          ,x_cost_rate             => l_cost_rate
                          ,x_start_date_active     => l_start_date
                          ,x_end_date_active       => l_end_date
                          ,x_org_labor_sch_rule_id => l_org_labor_sch_rule_id
                          ,x_costing_rule          => l_costing_rule
                          ,x_rate_sch_id           => l_rate_sch_id
                          ,x_cost_rate_curr_code   => l_return_currency_code
                          ,x_acct_rate_type        => l_acct_rate_type
                          ,x_acct_rate_date_code   => l_acct_rate_date_code
                          ,x_acct_exch_rate        => l_acct_exch_rate
                          ,x_ot_project_id         => l_ot_project_id
                          ,x_ot_task_id            => l_ot_task_id
                          ,x_err_stage             => l_err_stage
                          ,x_err_code              => l_err_code
                         );
	       print_message('l_return_currency_code['||l_return_currency_code||']l_err_stage['||l_err_stage||
		     ']l_err_code['||l_err_code||']');

                /* bug fix 2822620 --If l_return_currency_code IS NOT NULL Then **/
                If l_return_currency_code IS NULL Then

                        Raise OTHERS_EXCEPTION;

                End If;

             ELse  -- calling_mode = 'ADJUST'
                 print_message('Calling mode ADJUST so return account currency code');
                        l_return_currency_code := pa_currency.get_currency_code;
             End If;


         END IF;
       /** End of Bug fix:2798742 */
   ELSIF l_cost_rate_flag = 'Y' THEN

         IF p_acct_currency_code = p_denom_currency_code THEN
                  l_return_currency_code := p_denom_currency_code;
         ELSE
                  l_return_currency_code := pa_currency.get_currency_code;
         END IF;

   ELSE
         l_return_currency_code := p_denom_currency_code;

   END IF;

   RETURN l_return_currency_code;

EXCEPTION
WHEN OTHERS_EXCEPTION THEN
        print_message('inside OTHERS_EXCEPTION l_return_currency_code['||l_return_currency_code||']');
        If l_return_currency_code IS NULL Then
                RAISE;
        ELSE
                return l_return_currency_code;
        END IF;

WHEN OTHERS THEN
        If l_return_currency_code IS NULL Then
                RAISE;
        ELSE
                return l_return_currency_code;
        END IF;
        RAISE;

END get_denom_curr_code;

/* R12 Changes Start */
  PROCEDURE Get_Old_and_New_CCID(
    p_expenditure_item_id         IN         NUMBER
   ,p_project_id                  IN         NUMBER
   ,p_task_id                     IN         NUMBER
   ,p_expenditure_type            IN         VARCHAR2
   ,p_vendor_id                   IN         NUMBER
   ,p_expenditure_organization_id IN         NUMBER
   ,p_expenditure_item_date       IN         DATE
   ,p_billable_flag               IN         VARCHAR2
   ,p_org_id                      IN         NUMBER
   ,p_emp_id                      IN         NUMBER
   ,p_award_id                    IN         NUMBER
   ,p_system_linkage_function     IN         VARCHAR2
   ,p_transaction_source          IN         VARCHAR2
   ,p_invoice_distribution_id     IN         NUMBER
   ,x_old_ccid                    OUT NOCOPY VARCHAR2
   ,x_new_ccid                    OUT NOCOPY VARCHAR2
   ,x_encoded_error_message       OUT NOCOPY VARCHAR2) IS /* Bug 4997739 */

    l_pa_gl_app_id                NUMBER := 8721;
    l_concat_segs                 VARCHAR2(240);
    l_concat_ids		  VARCHAR2(240);
    l_concat_descrs		  VARCHAR2(240);
    l_vendor_id                   NUMBER;
    l_gl_date                     DATE;
    l_sob_id                      NUMBER;
    l_coa_id                      NUMBER;
    l_emp_ccid                    NUMBER;
    l_expense_type                NUMBER;
    l_encoded_error_message       VARCHAR2(2000);

/* this cursor derives the set of books and the chart of account
   associated with Organization in which the transaction was entered */
    CURSOR C_SOB_COA_CUR IS
    SELECT IMP.SET_OF_BOOKS_ID
         , GL.CHART_OF_ACCOUNTS_ID
      FROM GL_LEDGERS_PUBLIC_V GL
         , PA_IMPLEMENTATIONS IMP
     WHERE GL.LEDGER_ID = IMP.SET_OF_BOOKS_ID;

/* this cursor gets the vendor id of the employee for which the ER was entered */
    CURSOR C_VENDOR_ID_CUR(p_emp_id NUMBER) IS
    SELECT VENDOR_ID
      FROM PO_VENDORS_AP_V
     WHERE ACTIVE_FLAG = 'Y'
       AND ENABLED_FLAG = 'Y'
       AND EMPLOYEE_ID = p_emp_id;

/* this cursor gets the CCID of the employee for ehich the ER was entered */
    CURSOR C_EMP_CCID_CUR(p_emp_id NUMBER, p_sob_id NUMBER) IS
    SELECT DEFAULT_CODE_COMB_ID
      FROM PER_ASSIGNMENTS_F
     WHERE PERSON_ID = p_emp_id
       AND SET_OF_BOOKS_ID = p_sob_id
       AND TRUNC(SYSDATE) BETWEEN TRUNC(EFFECTIVE_START_DATE)
       AND NVL(TRUNC(EFFECTIVE_END_DATE), TRUNC(SYSDATE));

/* this cursor get the expense type */
    CURSOR C_EXPENSE_TYPE_CUR(p_invoice_distribution_id NUMBER) IS
    SELECT WEB_PARAMETER_ID
      FROM AP_INVOICE_DISTRIBUTIONS
     WHERE INVOICE_DISTRIBUTION_ID = p_invoice_distribution_id;

/* this cursor gets the old ccid and gl date */
    CURSOR C_OLD_CCID_AND_GL_DATE_CUR(p_expenditure_item_id NUMBER) IS
    SELECT DR_CODE_COMBINATION_ID, GL_DATE
      FROM PA_COST_DISTRIBUTION_LINES
     WHERE EXPENDITURE_ITEM_ID = ( SELECT EXPENDITURE_ITEM_ID
                                     FROM PA_EXPENDITURE_ITEMS
                                    WHERE TRANSFERRED_FROM_EXP_ITEM_ID IS NULL
                               START WITH EXPENDITURE_ITEM_ID = p_expenditure_item_id
                         CONNECT BY PRIOR TRANSFERRED_FROM_EXP_ITEM_ID = EXPENDITURE_ITEM_ID)
       AND TRANSFER_STATUS_CODE = 'V';

  workflow_exception EXCEPTION;
  PRAGMA EXCEPTION_INIT(workflow_exception,-20001);

  BEGIN

/* Check if the organization is cached. If yes then it implies that
   the Chart of Accounts is also cached */
    IF p_org_id <> NVL(G_ORG_ID,-99) THEN

/* If not, get new chart of accounts id */
      OPEN C_SOB_COA_CUR;
      FETCH C_SOB_COA_CUR INTO l_sob_id, l_coa_id;
      CLOSE C_SOB_COA_CUR;

    END IF;

    IF p_system_linkage_function = 'ER' THEN

/* For ERs, check if employee id is cached. If yes, then it implies that
   vendor information is also cached */
      IF  p_vendor_id IS NULL
      AND p_emp_id <> NVL(G_EMP_ID,-99) THEN

/* If not, get employee id */
        OPEN C_VENDOR_ID_CUR(p_emp_id);
        FETCH C_VENDOR_ID_CUR INTO l_vendor_id;
        CLOSE C_VENDOR_ID_CUR;

      END IF;

/* For ERs, check if employee id and set of books id is cached. If yes,
   then it implies that the employee ccid is also cached */
      IF  p_emp_id <> NVL(G_EMP_ID,-99)
      OR  l_sob_id <> NVL(G_SET_OF_BOOKS_ID,-99) THEN

/* If not, get new employee ccid */
        OPEN C_EMP_CCID_CUR(p_emp_id, l_sob_id);
        FETCH C_EMP_CCID_CUR INTO l_emp_ccid;
        CLOSE C_EMP_CCID_CUR;

      END IF;

/* For ERs from Payables, check if invoice distribution id is cached. If yes, it implies
   thet the expense type is also cached */
      IF  p_transaction_source = 'AP EXPENSE'
      AND p_invoice_distribution_id <> NVL(G_INVOICE_DISTRIBUTION_ID,-99) THEN

/* If not, get expense type */
        OPEN C_EXPENSE_TYPE_CUR(p_invoice_distribution_id);
        FETCH C_EXPENSE_TYPE_CUR into l_expense_type;
        CLOSE C_EXPENSE_TYPE_CUR;

      END IF;

    END IF;

/* Update cache */
    G_ORG_ID := NVL(p_org_id, G_ORG_ID);
    G_SET_OF_BOOKS_ID := NVL(l_sob_id,G_SET_OF_BOOKS_ID);
    G_COA_ID := NVL(l_coa_id, G_COA_ID);
    G_VENDOR_ID := NVL(p_vendor_id,NVL(l_vendor_id,G_VENDOR_ID));
    G_EMP_ID := NVL(p_emp_id, G_EMP_ID); /* 4991601 */
    G_EMP_CCID := NVL(l_emp_ccid, G_EMP_CCID);
    G_INVOICE_DISTRIBUTION_ID := NVL(p_invoice_distribution_id,G_INVOICE_DISTRIBUTION_ID);
    G_EXPENSE_TYPE := NVL(l_expense_type, G_EXPENSE_TYPE);

    OPEN C_OLD_CCID_AND_GL_DATE_CUR(p_expenditure_item_id);
    FETCH C_OLD_CCID_AND_GL_DATE_CUR INTO x_old_ccid, l_gl_date;
    CLOSE C_OLD_CCID_AND_GL_DATE_CUR;

    IF p_system_linkage_function = 'VI' THEN

/* For Supplier Costs, we have to pass the accounting data
   as a parameter. We derive the latest open GL period */

      l_gl_date := NVL(pa_utils2.get_prvdr_gl_date(p_reference_date => l_gl_date
                                                  ,p_application_id => l_pa_gl_app_id
                                                  ,p_set_of_books_id => G_SET_OF_BOOKS_ID),l_gl_date);

/* Call Supplier Invoice Account Generator Workflow */
      IF NOT pa_acc_gen_wf_pkg.ap_inv_generate_account
          (p_expenditure_item_id => p_expenditure_item_id
          ,p_project_id => p_project_id
          ,p_task_id => p_task_id
          ,p_expenditure_type => p_expenditure_type
          ,p_vendor_id => G_VENDOR_ID
          ,p_expenditure_organization_id => p_expenditure_organization_id
          ,p_expenditure_item_date => p_expenditure_item_date
          ,p_billable_flag => p_billable_flag
          ,p_chart_of_accounts_id => G_COA_ID
          ,p_attribute_category => NULL
          ,p_attribute1 => NULL
          ,p_attribute2 => NULL
          ,p_attribute3 => NULL
          ,p_attribute4 => NULL
          ,p_attribute5 => NULL
          ,p_attribute6 => NULL
          ,p_attribute7 => NULL
          ,p_attribute8 => NULL
          ,p_attribute9 => NULL
          ,p_attribute10 => NULL
          ,p_attribute11 => NULL
          ,p_attribute12 => NULL
          ,p_attribute13 => NULL
          ,p_attribute14 => NULL
          ,p_attribute15 => NULL
          ,p_dist_attribute_category => NULL
          ,p_dist_attribute1 => NULL
          ,p_dist_attribute2 => NULL
          ,p_dist_attribute3 => NULL
          ,p_dist_attribute4 => NULL
          ,p_dist_attribute5 => NULL
          ,p_dist_attribute6 => NULL
          ,p_dist_attribute7 => NULL
          ,p_dist_attribute8 => NULL
          ,p_dist_attribute9 => NULL
          ,p_dist_attribute10 => NULL
          ,p_dist_attribute11 => NULL
          ,p_dist_attribute12 => NULL
          ,p_dist_attribute13 => NULL
          ,p_dist_attribute14 => NULL
          ,p_dist_attribute15 => NULL
          ,x_return_ccid => x_new_ccid /* Bug 4610677 */
          ,x_concat_segs => l_concat_segs
          ,x_concat_ids => l_concat_ids
          ,x_concat_descrs => l_concat_descrs
          ,x_error_message  => l_encoded_error_message /* Bug 4997739 */
          ,p_award_id => p_award_id
          ,p_accounting_date => l_gl_date) THEN

/* Raise an exception if the workflow returns with an error */
/* 4627975 - Set the encoded message on the message stack before raising exception */
        x_encoded_error_message := l_encoded_error_message; /* Bug 4997739 */

      END IF;
    ELSE

/* Call Expense Report Account Generator Workflow */
      IF NOT pa_acc_gen_wf_pkg.ap_er_generate_account
          (p_expenditure_item_id => p_expenditure_item_id
          ,p_project_id => p_project_id
          ,p_task_id => p_task_id
          ,p_expenditure_type => p_expenditure_type
          ,p_vendor_id => G_VENDOR_ID
          ,p_expenditure_organization_id => p_expenditure_organization_id
          ,p_expenditure_item_date => p_expenditure_item_date
          ,p_billable_flag => p_billable_flag
          ,p_chart_of_accounts_id => G_COA_ID
          ,p_calling_module => 'APXINWKB'
          ,p_employee_id => G_EMP_ID
          ,p_employee_ccid => G_EMP_CCID
          ,p_expense_type => G_EXPENSE_TYPE
          ,p_expense_cc => NULL
          ,p_attribute_category => NULL
          ,p_attribute1 => NULL
          ,p_attribute2 => NULL
          ,p_attribute3 => NULL
          ,p_attribute4 => NULL
          ,p_attribute5 => NULL
          ,p_attribute6 => NULL
          ,p_attribute7 => NULL
          ,p_attribute8 => NULL
          ,p_attribute9 => NULL
          ,p_attribute10 => NULL
          ,p_attribute11 => NULL
          ,p_attribute12 => NULL
          ,p_attribute13 => NULL
          ,p_attribute14 => NULL
          ,p_attribute15 => NULL
          ,p_line_attribute_category => NULL
          ,p_line_attribute1 => NULL
          ,p_line_attribute2 => NULL
          ,p_line_attribute3 => NULL
          ,p_line_attribute4 => NULL
          ,p_line_attribute5 => NULL
          ,p_line_attribute6 => NULL
          ,p_line_attribute7 => NULL
          ,p_line_attribute8 => NULL
          ,p_line_attribute9 => NULL
          ,p_line_attribute10 => NULL
          ,p_line_attribute11 => NULL
          ,p_line_attribute12 => NULL
          ,p_line_attribute13 => NULL
          ,p_line_attribute14 => NULL
          ,p_line_attribute15 => NULL
          ,x_return_ccid => x_new_ccid /* Bug 4610677 */
          ,x_concat_segs => l_concat_segs
          ,x_concat_ids => l_concat_ids
          ,x_concat_descrs => l_concat_descrs
          ,x_error_message  => l_encoded_error_message /* Bug 4997739 */
          ,p_award_id => p_award_id) THEN

/* Raise an exception if the workflow returns with an error */
/* 4627975 - Set the encoded message on the message stack before raising exception */
        x_encoded_error_message := l_encoded_error_message; /* Bug 4997739 */

      END IF;

    END IF;

  END Get_Old_and_New_CCID;

  FUNCTION get_auto_offsets_segments
        (p_auto_offset_option AP_SYSTEM_PARAMETERS.liability_post_lookup_code%TYPE
        ,P_base_ccid  NUMBER
        ,p_coa_id NUMBER) return varchar2 is

    l_base_segments                FND_FLEX_EXT.SEGMENTARRAY ;
    l_overlay_segments             FND_FLEX_EXT.SEGMENTARRAY ;
    l_segments                     FND_FLEX_EXT.SEGMENTARRAY ;
    l_num_of_segments              NUMBER ;
    l_result                       BOOLEAN ;
    l_flex_qualifier_name          VARCHAR2(100);
    l_flex_segment_num             NUMBER;
    l_return_segments              varchar2(200) := null;


  BEGIN

/* Get flexfield qualifier segment number */

    IF (p_auto_offset_option = 'ACCOUNT_SEGMENT_VALUE') THEN

      l_flex_qualifier_name := 'GL_ACCOUNT' ;

    ELSIF (p_auto_offset_option = 'BALANCING_SEGMENT') THEN

      l_flex_qualifier_name := 'GL_BALANCING' ;

    ELSIF (p_auto_offset_option = 'NONE') THEN

      RETURN NULL;

    END IF;

    l_result := FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(101
                                                  ,'GL#'
                                                  ,p_coa_id
                                                  ,l_flex_qualifier_name
                                                  ,l_flex_segment_num);

/* Get the segments of the given account */
    IF (NOT FND_FLEX_EXT.GET_SEGMENTS('SQLGL'
                                     ,'GL#'
                                     , p_coa_id
                                     ,P_base_ccid
                                     ,l_num_of_segments
                                     ,l_base_segments)) THEN

      RETURN -1 ;

    END IF;

/* Get the Balancing Segment or Accounting Segment based on the auto-offset option */
    FOR i IN 1.. l_num_of_segments LOOP

      IF (l_Flex_Qualifier_Name = 'GL_BALANCING') THEN

        IF (i = l_flex_segment_num) THEN

          l_segments(i) := l_base_segments(i);
          l_return_segments := l_segments(i);

        END IF;

      ELSIF (l_Flex_Qualifier_Name = 'GL_ACCOUNT') THEN

        IF (i = l_flex_segment_num) THEN

          l_segments(i) := l_base_segments(i);

        ELSE

          l_segments(i) := l_base_segments(i);
          l_return_segments :=  l_return_segments || l_segments(i) ;

        END IF;

      END IF;

    END LOOP;

    return l_return_segments;

  END get_auto_offsets_segments;

FUNCTION Allow_Adjust_with_Auto_Offset
         (p_expenditure_item_id         IN NUMBER,
          p_org_id                      IN NUMBER,
          p_system_linkage_function     IN VARCHAR2,
          p_transaction_source          IN VARCHAR2,
          P_action                      IN VARCHAR2,
          P_project_id                  IN NUMBER,
          P_task_id                     IN NUMBER,
          p_expenditure_type            IN VARCHAR2,
          p_vendor_id                   IN NUMBER,
          p_expenditure_organization_id IN NUMBER,
          p_expenditure_item_date       IN DATE,
          p_emp_id                      IN NUMBER,
          p_invoice_distribution_id     IN NUMBER,
          p_invoice_payment_id          IN AP_INVOICE_PAYMENTS_ALL.INVOICE_PAYMENT_ID%TYPE, /* Bug 5006835 */
          p_award_id                    IN NUMBER,
          p_billable_flag1              IN VARCHAR2,
          p_billable_flag2              IN VARCHAR2,
          x_encoded_error_message       OUT NOCOPY VARCHAR2) /* Bug 4997739 */
RETURN BOOLEAN IS

  l_automatic_offset_method VARCHAR2(25) := 'UNKNOWN';
  l_billable_flag           VARCHAR2(1);
  l_return                  BOOLEAN := TRUE;
  l_pooled_flag             VARCHAR(1); /* Bug 5006835 */
  l_encoded_error_message   VARCHAR2(2000); /* Bug 4997739 */
  l_historical_flag         PA_EXPENDITURE_ITEMS_ALL.HISTORICAL_FLAG%TYPE := 'N'; /* Bug 5551933 */

  CURSOR c_get_ap_offset_method IS
  SELECT LIABILITY_POST_LOOKUP_CODE
    FROM AP_SYSTEM_PARAMETERS;

/* Bug 5006835 - Start */
/* This cursor is used to determine if the disbursement bank account is pooled
   for a payment in cash basis accounting setup */
  CURSOR c_get_pooled_flag(p_invoice_payment_id AP_INVOICE_PAYMENTS_ALL.INVOICE_PAYMENT_ID%TYPE) IS
  SELECT B.POOLED_FLAG
    FROM CE_BANK_ACCOUNTS B
       , AP_CHECKS_ALL C
       , AP_INVOICE_PAYMENTS_ALL A
   WHERE A.INVOICE_PAYMENT_ID = p_invoice_payment_id
     AND A.CHECK_ID = C.CHECK_ID
     AND C.CE_BANK_ACCT_USE_ID = B.BANK_ACCOUNT_ID;
/* Bug 5006835 - End */

BEGIN

/* Bug 5006835 - Start */
    IF PA_UTILS4.get_ledger_cash_basis_flag = 'Y' THEN

/* Bug 5551933 - Start */
      IF p_transaction_source = 'AP DISCOUNTS' THEN

/* Bug 5559214 - Start */
        SELECT nvl(historical_flag, 'N')
        INTO l_historical_flag
        FROM ap_invoice_distributions_all
        WHERE invoice_distribution_id = p_invoice_distribution_id;
/* Bug 5559214 - End */

      END IF;

      IF  l_historical_flag = 'N'
      AND p_invoice_payment_id IS NOT NULL THEN /* Bug 5455212 */

        OPEN c_get_pooled_flag(p_invoice_payment_id);
        FETCH c_get_pooled_flag INTO l_pooled_flag;
        CLOSE c_get_pooled_flag;

        IF NVL(l_pooled_flag, 'N') = 'N' THEN

          RETURN TRUE;

        END IF;

      END IF;
/* Bug 5551933 - End */

    END IF;
/* Bug 5006835 - End */

/* Account can change only when the project, task, billability or capitalizability changes */
    IF G_AUTOMATIC_OFFSET_METHOD.COUNT = 0 THEN

/* If cache is empty, then populate the PL/SQL table with the offset method and
   corresponding org_id */
      OPEN c_get_ap_offset_method;
      FETCH c_get_ap_offset_method
      INTO l_automatic_offset_method;
      CLOSE c_get_ap_offset_method;

      G_AUTOMATIC_OFFSET_METHOD(1).ORG_ID := p_org_id;
      G_AUTOMATIC_OFFSET_METHOD(1).METHOD := l_automatic_offset_method;

    ELSE

/* else check the cache to see if the automatic offset method is cached for this org */
      FOR i IN G_AUTOMATIC_OFFSET_METHOD.FIRST..G_AUTOMATIC_OFFSET_METHOD.LAST LOOP

        IF G_AUTOMATIC_OFFSET_METHOD(i).ORG_ID = p_org_id THEN

          l_automatic_offset_method := G_AUTOMATIC_OFFSET_METHOD(i).METHOD;
          EXIT;

        END IF;

      END LOOP;

      IF l_automatic_offset_method = 'UNKNOWN' THEN

/* if the offset method is still undetermined, it means that it was not found in the cahce.
   So it has to be derived using the cursor and the cache has to be updated */
        OPEN c_get_ap_offset_method;
        FETCH c_get_ap_offset_method
        INTO l_automatic_offset_method;
        CLOSE c_get_ap_offset_method;

        G_AUTOMATIC_OFFSET_METHOD(G_AUTOMATIC_OFFSET_METHOD.LAST + 1).ORG_ID := p_org_id;
        G_AUTOMATIC_OFFSET_METHOD(G_AUTOMATIC_OFFSET_METHOD.LAST + 1).METHOD := l_automatic_offset_method;

      END IF;

    END IF;

    IF l_automatic_offset_method IS NOT NULL THEN

/* If automatic adjustment is enabled, then check if the transaction can be adjusted or not */

/* we can set the billable/capitalizable flag based on the adjustment action */
      IF p_action IN ('BILLABLE RECLASS','CAPITALIZABLE RECLASS') THEN

        l_billable_flag := 'Y';

      ELSIF p_action IN ('NON-BILLABLE RECLASS','NON-CAPITALIZABLE RECLASS') THEN

        l_billable_flag := 'N';

      ELSE

        l_billable_flag := p_billable_flag1;

      END IF;

/* get the original and new Charge account */
      IF p_expenditure_item_id <> NVL(G_EXP_ITEM_ID,-99) THEN
        get_old_and_new_ccid(p_expenditure_item_id
                            ,p_project_id
                            ,p_task_id
                            ,p_expenditure_type
                            ,p_vendor_id
                            ,p_expenditure_organization_id
                            ,p_expenditure_item_date
                            ,l_billable_flag
                            ,p_org_id
                            ,p_emp_id
                            ,p_award_id
                            ,p_system_linkage_function
                            ,p_transaction_source
                            ,p_invoice_distribution_id
                            ,G_OLD_CCID
                            ,G_NEW_CCID
                            ,l_encoded_error_message); /* Bug 4997739 */
/* Bug 4997739 - Return false if there were any errors in workflow */
        IF l_encoded_error_message IS NOT NULL THEN
          x_encoded_error_message := l_encoded_error_message;
          RETURN FALSE;
        END IF;
        G_EXP_ITEM_ID := p_expenditure_item_id;
      END IF;

/* check if the liability account is affected */
      IF get_auto_offsets_segments(l_automatic_offset_method,G_OLD_CCID,G_COA_ID)
             <> get_auto_offsets_segments(l_automatic_offset_method,G_NEW_CCID,G_COA_ID) THEN

/* if yes, then set the return value to FALSE */
        l_return := FALSE;

      END IF;

      IF  l_return = TRUE
      AND p_action = 'SPLIT' THEN

/* if the adjustment action is split, then the second part of the split transaction
   also has to be verified */
        IF p_expenditure_item_id <> NVL(G_EXP_ITEM_ID,-99) THEN
          get_old_and_new_ccid(p_expenditure_item_id
                              ,p_project_id
                              ,p_task_id
                              ,p_expenditure_type
                              ,p_vendor_id
                              ,p_expenditure_organization_id
                              ,p_expenditure_item_date
                              ,p_billable_flag2
                              ,p_org_id
                              ,p_emp_id
                              ,p_award_id
                              ,p_system_linkage_function
                              ,p_transaction_source
                              ,p_invoice_distribution_id
                              ,G_OLD_CCID
                              ,G_NEW_CCID
                              ,l_encoded_error_message); /* Bug 4997739 */
/* Bug 4997739 - Return false if there were any errors in workflow */
          IF l_encoded_error_message IS NOT NULL THEN
            x_encoded_error_message := l_encoded_error_message;
            RETURN FALSE;
          END IF;
          G_EXP_ITEM_ID := p_expenditure_item_id;
        END IF;

        IF get_auto_offsets_segments(l_automatic_offset_method,G_OLD_CCID,G_COA_ID)
               <> get_auto_offsets_segments(l_automatic_offset_method,G_NEW_CCID,G_COA_ID) THEN

          l_return := FALSE;

        END IF;

      END IF;

    END IF;

  RETURN l_return;

END Allow_Adjust_with_Auto_Offset;
/* R12 changes End */

/* R12 Changes Start */
FUNCTION Get_Displayed_Field
    ( p_lookup_type varchar2
    , p_lookup_code varchar2)
RETURN VARCHAR2 IS

  CURSOR C_Inv_Displayed_Field_Cur IS
  SELECT displayed_field
    FROM ap_lookup_codes
   WHERE lookup_type = p_lookup_type
     AND lookup_code = p_lookup_code;

  CURSOR C_PO_Displayed_Field_Cur IS
  SELECT displayed_field
    FROM po_lookup_codes
   WHERE lookup_type = p_lookup_type
     AND lookup_code = p_lookup_code;

BEGIN

  IF  p_lookup_type = 'INVOICE TYPE' THEN

    IF p_lookup_code <> NVL(G_INV_TYPE_CODE,-99) THEN

      OPEN C_Inv_Displayed_Field_Cur;
      FETCH C_Inv_Displayed_Field_Cur
       INTO G_INV_TYPE;
      CLOSE C_Inv_Displayed_Field_Cur;

      G_INV_TYPE_CODE := p_lookup_code;

    END IF;

    RETURN G_INV_TYPE;

  END IF;

  IF  p_lookup_type = 'INVOICE LINE TYPE' THEN

    IF p_lookup_code <> NVL(G_INV_LINE_TYPE_CODE,-99) THEN

      OPEN C_Inv_Displayed_Field_Cur;
      FETCH C_Inv_Displayed_Field_Cur
       INTO G_INV_LINE_TYPE;
      CLOSE C_Inv_Displayed_Field_Cur;

      G_INV_LINE_TYPE_CODE := p_lookup_code;

    END IF;

    RETURN G_INV_LINE_TYPE;

  END IF;

  IF  p_lookup_type = 'INVOICE DISTRIBUTION TYPE' THEN

    IF p_lookup_code <> NVL(G_INV_DIST_TYPE_CODE,-99) THEN

      OPEN C_Inv_Displayed_Field_Cur;
      FETCH C_Inv_Displayed_Field_Cur
       INTO G_INV_DIST_TYPE;
      CLOSE C_Inv_Displayed_Field_Cur;

      G_INV_DIST_TYPE_CODE := p_lookup_code;

    END IF;

    RETURN G_INV_DIST_TYPE;

  END IF;

/* Bug 4914048 - Start */
  IF  p_lookup_type = 'PAYMENT TYPE' THEN

    IF p_lookup_code <> NVL(G_PAYMENT_TYPE_CODE,-99) THEN

      OPEN C_Inv_Displayed_Field_Cur;
      FETCH C_Inv_Displayed_Field_Cur
       INTO G_PAYMENT_TYPE;
      CLOSE C_Inv_Displayed_Field_Cur;

      G_PAYMENT_TYPE_CODE := p_lookup_code;

    END IF;

    RETURN G_PAYMENT_TYPE;

  END IF;
/* Bug 4914048 - End */

  IF  p_lookup_type = 'PO TYPE' THEN

    IF p_lookup_code <> NVL(G_PO_DIST_TYPE_CODE,-99) THEN

      OPEN C_PO_Displayed_Field_Cur;
      FETCH C_PO_Displayed_Field_Cur
       INTO G_PO_DIST_TYPE;
      CLOSE C_PO_Displayed_Field_Cur;

      G_PO_DIST_TYPE_CODE := p_lookup_code;

    END IF;

    RETURN G_PO_DIST_TYPE;

  END IF;

  IF  p_lookup_type = 'RCV TRANSACTION TYPE' THEN

    IF p_lookup_code <> NVL(G_RCV_TXN_TYPE_CODE,-99) THEN

      OPEN C_PO_Displayed_Field_Cur;
      FETCH C_PO_Displayed_Field_Cur
       INTO G_RCV_TXN_TYPE;
      CLOSE C_PO_Displayed_Field_Cur;

      G_RCV_TXN_TYPE_CODE := p_lookup_code;

    END IF;

    RETURN G_RCV_TXN_TYPE;

  END IF;

  RETURN NULL;

END Get_Displayed_Field;

FUNCTION Get_PO_Info
    ( p_key varchar2
    , p_po_distribution_id number)
RETURN VARCHAR2 IS

  l_po_distribution_type_code varchar2(30);

  CURSOR C_PO_Info_Cur IS
  SELECT po.po_header_id
       , po.segment1
       , po.creation_date
       , po_line.line_num
       , po_dist.distribution_num
       , po_dist.distribution_type
    FROM po_headers po
       , po_lines po_line
       , po_distributions po_dist
   WHERE po.po_header_id = po_line.po_header_id
     AND po_line.po_line_id = po_dist.po_line_id
     AND po_dist.po_distribution_id = p_po_distribution_id;
BEGIN

  IF p_po_distribution_id IS NULL THEN

    RETURN NULL;

  END IF;

  IF  NVL(G_PO_DIST_ID,-99) <> p_po_distribution_id THEN

    OPEN C_PO_Info_Cur;
    FETCH C_PO_Info_Cur
     INTO G_PO_HEADER_ID
        , G_PO_NUM
        , G_PO_DATE
        , G_PO_LINE_NUM
        , G_PO_DIST_NUM
        , l_po_distribution_type_code;
    CLOSE C_PO_Info_Cur;

    G_PO_DIST_TYPE := Get_Displayed_Field('PO TYPE', l_po_distribution_type_code);

    G_PO_DIST_ID := p_po_distribution_id;

  END IF;

  CASE p_key
    WHEN 'PO HEADER ID' THEN RETURN G_PO_HEADER_ID;
    WHEN 'PO NUM'       THEN RETURN G_PO_NUM;
    WHEN 'PO DATE'      THEN RETURN to_char(G_PO_DATE,'DD-MON-YYYY');
    WHEN 'PO LINE NUM'  THEN RETURN G_PO_LINE_NUM;
    WHEN 'PO DIST NUM'  THEN RETURN G_PO_DIST_NUM;
    WHEN 'PO TYPE'      THEN RETURN G_PO_DIST_TYPE;
  END CASE;

EXCEPTION
  WHEN OTHERS THEN
    G_PO_DIST_ID := NULL;
    G_PO_HEADER_ID := NULL;
    G_PO_NUM := NULL;
    G_PO_DATE := NULL;
    G_PO_LINE_NUM := NULL;
    G_PO_DIST_NUM := NULL;
    G_PO_DIST_TYPE := NULL;
    RAISE;

END Get_PO_Info;

FUNCTION Get_Rcv_Info
    ( p_key varchar2
    , p_rcv_transaction_id number)
RETURN VARCHAR2 IS

  l_rcv_transaction_type_code varchar2(30);

  CURSOR C_Rcv_Info_Cur IS
  SELECT rcv.receipt_num
       , rcvtxn.transaction_date
       , rcvtxn.transaction_type
    FROM rcv_shipment_headers rcv
       , rcv_transactions rcvtxn
   WHERE rcv.shipment_header_id = rcvtxn.shipment_header_id
     AND rcvtxn.transaction_id = p_rcv_transaction_id;

BEGIN

  IF p_rcv_transaction_id IS NULL THEN

    RETURN NULL;

  END IF;

  IF NVL(G_RCV_TXN_ID,-1) <> p_rcv_transaction_id THEN

    OPEN C_Rcv_Info_Cur;
    FETCH C_Rcv_Info_Cur
     INTO G_RCV_NUM
        , G_RCV_DATE
        , l_rcv_transaction_type_code;
    CLOSE C_Rcv_Info_Cur;

    G_RCV_TXN_TYPE := Get_Displayed_Field('RCV TRANSACTION TYPE', l_rcv_transaction_type_code);

    G_RCV_TXN_ID := p_rcv_transaction_id;

  END IF;

  CASE p_key
    WHEN 'RECEIPT NUMBER'       THEN RETURN G_RCV_NUM;
    WHEN 'RECEIPT DATE'         THEN RETURN to_char(G_RCV_DATE,'DD-MON-YYYY');
    WHEN 'RCV TRANSACTION TYPE' THEN RETURN G_RCV_TXN_TYPE;
  END CASE;

EXCEPTION
  WHEN OTHERS THEN
    G_RCV_TXN_ID := NULL;
    G_RCV_NUM := NULL;
    G_RCV_DATE := NULL;
    RAISE;

END Get_Rcv_Info;

FUNCTION Get_Inv_Info
    ( p_key varchar2
    , p_invoice_id number)
RETURN VARCHAR2 IS

  l_inv_type_code varchar2(30);

  CURSOR C_Inv_Info_Cur IS
  SELECT ap.invoice_type_lookup_code
       , ap.invoice_num
       , ap.invoice_date
    FROM ap_invoices ap
   WHERE ap.invoice_id = p_invoice_id;

BEGIN

  IF p_invoice_id IS NULL THEN

    RETURN NULL;

  END IF;

  IF NVL(G_INV_ID,-1) <> p_invoice_id THEN

    OPEN C_Inv_Info_Cur;
    FETCH C_Inv_Info_Cur
     INTO l_inv_type_code
        , G_INV_NUM
        , G_INV_DATE;
    CLOSE C_Inv_Info_Cur;

    G_INV_TYPE := Get_Displayed_Field('INVOICE TYPE', l_inv_type_code);

    G_INV_ID := p_invoice_id;

  END IF;

  CASE p_key
    WHEN 'INVOICE TYPE'         THEN RETURN G_INV_TYPE;
    WHEN 'INVOICE NUMBER'       THEN RETURN G_INV_NUM;
    WHEN 'INVOICE DATE'         THEN RETURN to_char(G_INV_DATE,'DD-MON-YYYY');
  END CASE;

EXCEPTION
  WHEN OTHERS THEN
    G_INV_ID := NULL;
    G_INV_NUM := NULL;
    G_INV_DATE := NULL;
    RAISE;

END Get_Inv_Info;

--=======================================================================
-- Function is_recoverability_affected
--=======================================================================
   FUNCTION is_recoverability_affected
         (p_expenditure_item_id         IN NUMBER,
          p_org_id                      IN NUMBER,
          p_system_linkage_function     IN VARCHAR2,
          p_transaction_source          IN VARCHAR2,
          P_action                      IN VARCHAR2,
          P_project_id                  IN NUMBER,
          P_task_id                     IN NUMBER,
          p_expenditure_type            IN VARCHAR2,
          p_vendor_id                   IN NUMBER,
          p_expenditure_organization_id IN NUMBER,
          p_expenditure_item_date       IN DATE,
          p_emp_id                      IN NUMBER,
          p_document_header_id          IN NUMBER,
          p_document_line_number        IN NUMBER,
          p_document_distribution_id    IN NUMBER,
          p_document_type               IN VARCHAR2,
          p_award_id                    IN NUMBER,
          p_billable_flag1              IN VARCHAR2,
          p_billable_flag2              IN VARCHAR2,
          x_error_message_name          OUT NOCOPY VARCHAR2, /* Bug 4997739 */
          x_encoded_error_message       OUT NOCOPY VARCHAR2) /* Bug 4997739 */
   return BOOLEAN is

     l_billable_flag           VARCHAR2(1);
     l_po_line_location_id     NUMBER;
     l_old_ccid                NUMBER;
     l_new_ccid                NUMBER;
     l_return                  BOOLEAN := FALSE;
     l_pa_item_info_tbl ZX_API_PUB.pa_item_info_tbl_type;
     l_return_status VARCHAR2(1);
     l_msg_count NUMBER;
     X_error_code  VARCHAR2(30);
     l_encoded_error_message VARCHAR2(2000);
     l_parent_distribution_id AP_INVOICE_DISTRIBUTIONS_ALL.INVOICE_DISTRIBUTION_ID%TYPE; /* Bug 5386471 */
     l_parent_line_number AP_INVOICE_DISTRIBUTIONS_ALL.INVOICE_LINE_NUMBER%TYPE; /* Bug 5386471 */
     l_ccid_changed BOOLEAN := FALSE; /* Bug 5440305 */

     CURSOR c_po_shipment_id_cur(p_po_distribution_id NUMBER) IS
     SELECT LINE_LOCATION_ID
       FROM PO_DISTRIBUTIONS
      WHERE PO_DISTRIBUTION_ID = p_po_distribution_id;

/* Bug 5386471 - Start */
     CURSOR c_parent_distribution_id_cur(p_invoice_distribution_id AP_INVOICE_DISTRIBUTIONS_ALL.INVOICE_DISTRIBUTION_ID%TYPE) IS
     SELECT NVL(charge_applicable_to_dist_id,NVL(related_id, invoice_distribution_id))
       FROM ap_invoice_distributions_all
      WHERE invoice_distribution_id = p_invoice_distribution_id;

     CURSOR c_parent_line_number_cur(p_parent_distribution_id AP_INVOICE_DISTRIBUTIONS_ALL.INVOICE_DISTRIBUTION_ID%TYPE) IS
     SELECT invoice_line_number
       FROM ap_invoice_distributions_all
      WHERE invoice_distribution_id = p_parent_distribution_id;
/* Bug 5386471 - End */

     etax_exception EXCEPTION;
     PRAGMA EXCEPTION_INIT(etax_exception,-20001);
   BEGIN
/* check if the tax recovery rate can change */
      IF p_action IN ('BILLABLE RECLASS','CAPITALIZABLE RECLASS') THEN

        l_billable_flag := 'Y';

      ELSIF p_action IN ('NON-BILLABLE RECLASS','NON-CAPITALIZABLE RECLASS') THEN

        l_billable_flag := 'N';

      ELSE

        l_billable_flag := p_billable_flag1;

      END IF;

/* get the original and new Charge account */
      IF p_expenditure_item_id <> NVL(G_EXP_ITEM_ID,-99) THEN

        get_old_and_new_ccid(p_expenditure_item_id
                            ,p_project_id
                            ,p_task_id
                            ,p_expenditure_type
                            ,p_vendor_id
                            ,p_expenditure_organization_id
                            ,p_expenditure_item_date
                            ,l_billable_flag
                            ,p_org_id
                            ,p_emp_id
                            ,p_award_id
                            ,p_system_linkage_function
                            ,p_transaction_source
                            ,p_document_distribution_id
                            ,G_OLD_CCID
                            ,G_NEW_CCID
                            ,l_encoded_error_message); /* Bug 4997739 */
/* Bug 4997739 - Return true if there were any errors in workflow */
        IF l_encoded_error_message IS NOT NULL THEN
          x_encoded_error_message := l_encoded_error_message;
          RETURN TRUE;
        END IF;
        G_EXP_ITEM_ID := p_expenditure_item_id;

      END IF;

/* Bug 5440305 - Set flag if the account changes */
      IF G_OLD_CCID <> G_NEW_CCID THEN

          l_ccid_changed := TRUE;

      END IF;

      IF p_transaction_source IN ('AP INVOICE'
                                 ,'INTERCOMPANY_AP_INVOICES'
                                 ,'INTERPROJECT_AP_INVOICES'
                                 ,'AP VARIANCE'
                                 ,'AP NRTAX'
                                 ,'AP DISCOUNTS'
                                 ,'AP EXPENSE'
                                 ,'AP ERV') THEN /* Bug 5235354 */

/* Bug 5386471 - Start */
          OPEN c_parent_distribution_id_cur(p_document_distribution_id);
          FETCH c_parent_distribution_id_cur
           INTO l_parent_distribution_id;
          CLOSE c_parent_distribution_id_cur;

          IF l_parent_distribution_id =  p_document_distribution_id THEN
            l_parent_line_number := p_document_line_number;
          ELSE
            OPEN c_parent_line_number_cur(l_parent_distribution_id);
            FETCH c_parent_line_number_cur
             INTO l_parent_line_number;
            CLOSE c_parent_line_number_cur;
          END IF;
/* Bug 5386471 - End */

          l_pa_item_info_tbl(1).APPLICATION_ID       := 200; --(Oracle payables application Id)
          l_pa_item_info_tbl(1).ENTITY_CODE          := 'AP_INVOICES';
          CASE p_document_type
            WHEN 'STANDARD'       THEN l_pa_item_info_tbl(1).EVENT_CLASS_CODE := 'STANDARD INVOICES';
            WHEN 'PREPAYMENT'     THEN l_pa_item_info_tbl(1).EVENT_CLASS_CODE := 'PREPAYMENT INVOICES';
            WHEN 'EXPENSE REPORT' THEN l_pa_item_info_tbl(1).EVENT_CLASS_CODE := 'EXPENSE REPORTS';
/* Bug 5386471 - Start */
            WHEN 'CREDIT'         THEN l_pa_item_info_tbl(1).EVENT_CLASS_CODE := 'STANDARD INVOICES';
            WHEN 'DEBIT'          THEN l_pa_item_info_tbl(1).EVENT_CLASS_CODE := 'STANDARD INVOICES';
            WHEN 'MIXED'          THEN l_pa_item_info_tbl(1).EVENT_CLASS_CODE := 'STANDARD INVOICES';
/* Bug 5386471 - End */
            ELSE                       l_pa_item_info_tbl(1).EVENT_CLASS_CODE := NULL;
          END CASE;
          l_pa_item_info_tbl(1).TRX_ID               := p_document_header_id;
          l_pa_item_info_tbl(1).TRX_LINE_ID          := l_parent_line_number; /* Bug 5386471 */
          l_pa_item_info_tbl(1).TRX_LEVEL_TYPE       := 'LINE';
          l_pa_item_info_tbl(1).ITEM_EXPENSE_DIST_ID := l_parent_distribution_id; /* Bug 5386471 */
          l_pa_item_info_tbl(1).NEW_ACCOUNT_CCID     := G_NEW_CCID;
          l_pa_item_info_tbl(1).NEW_ACCOUNT_STRING   := NULL;
          l_pa_item_info_tbl(1).NEW_PROJECT_ID       := p_project_id;
          l_pa_item_info_tbl(1).NEW_TASK_ID          := p_task_id;
          l_pa_item_info_tbl(1).RECOVERABILITY_AFFECTED := FALSE;

      ELSIF p_transaction_source IN ('PO RECEIPT'
                                    ,'PO RECEIPT NRTAX'
                                    ,'PO RECEIPT NRTAX PRICE ADJ'
                                    ,'PO RECEIPT PRICE ADJ') THEN

/* Bug 5386471 - Start */
          OPEN c_po_shipment_id_cur(p_document_line_number);
          FETCH c_po_shipment_id_cur
           INTO l_po_line_location_id;
          CLOSE c_po_shipment_id_cur;
/* Bug 5386471 - End */

          l_pa_item_info_tbl(1).APPLICATION_ID       := 201; --(Oracle purchasing application Id)
          l_pa_item_info_tbl(1).ENTITY_CODE          := 'PURCHASE_ORDER';
          l_pa_item_info_tbl(1).EVENT_CLASS_CODE     := 'PO_PA';
          l_pa_item_info_tbl(1).TRX_ID               := p_document_header_id;
          l_pa_item_info_tbl(1).TRX_LINE_ID          := l_po_line_location_id;
          l_pa_item_info_tbl(1).TRX_LEVEL_TYPE       := 'SHIPMENT'; /* Bug 5386471 */
          l_pa_item_info_tbl(1).ITEM_EXPENSE_DIST_ID := p_document_line_number; /* Bug 5386471 */
          l_pa_item_info_tbl(1).NEW_ACCOUNT_CCID     := G_NEW_CCID;
          l_pa_item_info_tbl(1).NEW_ACCOUNT_STRING   := NULL ;
          l_pa_item_info_tbl(1).NEW_PROJECT_ID       := p_project_id;
          l_pa_item_info_tbl(1).NEW_TASK_ID          := p_task_id;
          l_pa_item_info_tbl(1).RECOVERABILITY_AFFECTED := FALSE;

      END IF;

/* Bug 5440305 - eBTax API will be called only if there is a change in the account */
      IF l_ccid_changed THEN

        l_ccid_changed := FALSE; /* Bug 5440305 - Reset the flag */

        ZX_API_PUB.is_recoverability_affected(
                   p_api_version        => 1.0,
                   p_init_msg_list      => FND_API.G_TRUE,
                   p_commit             => NULL,
                   p_validation_level   => NULL,
                   x_return_status      => l_return_status,
                   x_msg_count          => l_msg_count,
                   x_msg_data           => X_error_code,
                   p_pa_item_info_tbl   => l_pa_item_info_tbl);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

          x_error_message_name := 'PA_SI_ADJ_ETAX_EXCEPTION';
          RETURN TRUE;

        END IF;

        IF l_pa_item_info_tbl(1).RECOVERABILITY_AFFECTED THEN

          l_return := TRUE;

        END IF;

      END IF;

      IF  l_return = FALSE
      AND p_action = 'SPLIT' THEN

/* if the adjustment action is split, then the second part of the split transaction
   also has to be verified */
        IF p_expenditure_item_id <> NVL(G_EXP_ITEM_ID,-99) THEN

          get_old_and_new_ccid(p_expenditure_item_id
                              ,p_project_id
                              ,p_task_id
                              ,p_expenditure_type
                              ,p_vendor_id
                              ,p_expenditure_organization_id
                              ,p_expenditure_item_date
                              ,p_billable_flag2
                              ,p_org_id
                              ,p_emp_id
                              ,p_award_id
                              ,p_system_linkage_function
                              ,p_transaction_source
                              ,p_document_distribution_id
                              ,G_OLD_CCID
                              ,G_NEW_CCID
                              ,l_encoded_error_message); /* Bug 4997739 */
/* Bug 4997739 - Return true if there were any errors in workflow */
          IF l_encoded_error_message IS NOT NULL THEN
            x_encoded_error_message := l_encoded_error_message;
            RETURN TRUE;
          END IF;

          G_EXP_ITEM_ID := p_expenditure_item_id;

        END IF;

/* Bug 5440305 - Set flag if the account changes */
        IF G_OLD_CCID <> G_NEW_CCID THEN

          l_ccid_changed := TRUE;

        END IF;

        l_pa_item_info_tbl(1).NEW_ACCOUNT_CCID     := G_NEW_CCID;

/* Bug 5440305 - eBTax API will be called only if there is a change in the account */
        IF l_ccid_changed THEN

          l_ccid_changed := FALSE; /* Bug 5440305 - Reset the flag */
          ZX_API_PUB.is_recoverability_affected(
                   p_api_version        => 1.0,
                   p_init_msg_list      => FND_API.G_TRUE,
                   p_commit             => NULL,
                   p_validation_level   => NULL,
                   x_return_status      => l_return_status,
                   x_msg_count          => l_msg_count,
                   x_msg_data           => X_error_code,
                   p_pa_item_info_tbl   => l_pa_item_info_tbl);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            x_error_message_name := 'PA_SI_ADJ_ETAX_EXCEPTION';
            RETURN TRUE;

          END IF;

          IF l_pa_item_info_tbl(1).RECOVERABILITY_AFFECTED THEN

            l_return := TRUE;

          END IF;

        END IF;

      END IF;

      IF l_return = TRUE THEN

        x_error_message_name := 'PA_SI_ADJ_NRTAX_CHG_NOT_ALLOW';

      END IF;

      RETURN l_return;

 END is_recoverability_affected;
/* R12 Changes End */

/* Bug 4901129 - Start */
FUNCTION is_orphaned_src_sys_reversal( p_document_distribution_id IN PA_EXPENDITURE_ITEMS_ALL.DOCUMENT_DISTRIBUTION_ID%TYPE
                                     , p_transaction_source IN PA_EXPENDITURE_ITEMS_ALL.TRANSACTION_SOURCE%TYPE)
RETURN VARCHAR2 IS
  l_result                   VARCHAR2(1) := 'N';

  CURSOR c_get_count IS
  SELECT DECODE(count(*),0,'N','Y')
    FROM pa_expenditure_items_all ei /* Bug 5561597 */
   WHERE ( ei.document_header_id, ei.document_distribution_id) IN
         ( SELECT apdist2.invoice_id, apdist2.invoice_distribution_id /* Bug 5561597 */
             FROM ap_invoice_distributions_all apdist1, /* Bug 5561597 */
                  ap_invoice_distributions_all apdist2 /* Bug 5561597 */
            WHERE p_document_distribution_id = apdist1.invoice_distribution_id
              AND apdist1.reversal_flag = 'Y'
              AND apdist1.parent_reversal_id = apdist2.invoice_distribution_id
              AND apdist2.old_distribution_id IS NOT NULL
              AND p_transaction_source IN ('AP VARIANCE','AP INVOICE'
                    ,'AP DISCOUNTS','INTERCOMPANY_AP_INVOICES','INTERPROJECT_AP_INVOICES'
                    ,'AP NRTAX','AP EXPENSE','AP ERV') /* Bug 5235354 */
         UNION ALL
           SELECT rcv2.po_header_id, rcv2.transaction_id
             FROM rcv_transactions rcv1
                , rcv_transactions rcv2
            WHERE rcv1.transaction_id = p_document_distribution_id
              AND rcv1.transaction_type in ('RETURN TO RECEIVING','RETURN TO VENDOR','CORRECT')
              AND rcv1.parent_transaction_id = rcv2.transaction_id
              AND p_transaction_source IN ('PO RECEIPT','PO RECEIPT NRTAX',
                                 'PO RECEIPT NRTAX PRICE ADJ','PO RECEIPT PRICE ADJ'))
     AND (   ei.net_zero_adjustment_flag = 'Y'
         OR EXISTS ( SELECT NULL
                       FROM pa_cost_distribution_lines_all cdl2
                      WHERE cdl2.expenditure_item_id = ei.expenditure_item_id
                        AND cdl2.line_num = 1
                        AND cdl2.reversed_flag = 'Y'));
BEGIN
  OPEN c_get_count;
  FETCH c_get_count INTO l_result;
  CLOSE c_get_count;

  RETURN l_result;
END is_orphaned_src_sys_reversal;
/* Bug 4901129 - End */

/* Bug 5235354 - Start */
FUNCTION RepCurrOrSecLedgerDiffCurr(p_org_id PA_EXPENDITURE_ITEMS_ALL.ORG_ID%TYPE)
RETURN BOOLEAN IS

l_count NUMBER := -1;
l_return BOOLEAN := FALSE;

CURSOR c_rep_curr_or_sec_ledger is
SELECT COUNT(*)
FROM gl_ledgers_v gl,
  pa_implementations imp
WHERE imp.set_of_books_id = gl.ledger_id
 AND (EXISTS
  (SELECT NULL
   FROM gl_secondary_ledger_rships_v sl,
     xla_subledger_options_v xso
   WHERE sl.primary_ledger_id = gl.ledger_id
   AND sl.currency_code <> gl.currency_code
   AND sl.relationship_enabled_flag = 'Y'
   AND xso.application_id = 275
   AND xso.enabled_flag = 'Y'
   AND xso.ledger_id = sl.ledger_id)
 OR EXISTS
  (SELECT NULL
   FROM gl_alc_ledger_rships_v alc
   WHERE alc.primary_ledger_id = gl.ledger_id
   AND alc.currency_code <> gl.currency_code
   AND alc.application_id = 275
   AND relationship_enabled_flag = 'Y'));

BEGIN
  IF G_LEDGER_CNT.COUNT = 0 THEN

/* If cache is empty, then populate the PL/SQL table with the query result and
   corresponding org_id */
    OPEN c_rep_curr_or_sec_ledger;
    FETCH c_rep_curr_or_sec_ledger INTO l_count;
    CLOSE c_rep_curr_or_sec_ledger ;

    G_LEDGER_CNT(1).ORG_ID := p_org_id;
    G_LEDGER_CNT(1).CNT := l_count;

  ELSE

/* else check the cache to see if it is cached for this org */
    FOR i IN G_LEDGER_CNT.FIRST..G_LEDGER_CNT.LAST LOOP

      IF G_LEDGER_CNT(i).ORG_ID = p_org_id THEN

        l_count := G_LEDGER_CNT(i).CNT;
        EXIT;

      END IF;

    END LOOP;

    IF l_count = -1  THEN

/* if it is still undetermined, it means that it was not found in the cahce.
   So it has to be derived using the cursor and the cache has to be updated */
      OPEN c_rep_curr_or_sec_ledger;
      FETCH c_rep_curr_or_sec_ledger INTO l_count;
      CLOSE c_rep_curr_or_sec_ledger ;

      G_LEDGER_CNT(G_LEDGER_CNT.LAST + 1).ORG_ID := p_org_id;
      G_LEDGER_CNT(G_LEDGER_CNT.LAST + 1).CNT := l_count;

    END IF;

  END IF;

  IF l_count > 0 THEN
    l_return := TRUE;
  END IF;

  RETURN l_return;

END RepCurrOrSecLedgerDiffCurr;
/* Bug 5235354 - End */

/* Bug 5381260 - Start */
FUNCTION IsPeriodEndAccrual(p_invoice_distribution_id AP_INVOICE_DISTRIBUTIONS_ALL.INVOICE_DISTRIBUTION_ID%TYPE)
RETURN BOOLEAN IS
  l_accrue_on_receipt_flag PO_LINE_LOCATIONS_ALL.ACCRUE_ON_RECEIPT_FLAG%TYPE;
  l_result BOOLEAN := TRUE;

  CURSOR c_get_accrue_on_receipt_flag IS
  SELECT poll.accrue_on_receipt_flag
    FROM po_line_locations_all poll
       , po_distributions_all pod
       , ap_invoice_distributions_all aid
   WHERE poll.line_location_id = pod.line_location_id
     AND pod.po_distribution_id = aid.po_distribution_id
     AND aid.invoice_distribution_id = p_invoice_distribution_id;
BEGIN
  OPEN c_get_accrue_on_receipt_flag;
  FETCH c_get_accrue_on_receipt_flag INTO l_accrue_on_receipt_flag;
  CLOSE c_get_Accrue_on_receipt_flag;

  IF l_accrue_on_receipt_flag = 'Y' THEN
    l_result := FALSE;
  END IF;

  RETURN l_result;
END IsPeriodEndAccrual;
/* Bug 5381260 - End */

/* Bug 5501250 - Start */
FUNCTION IsRelatedToPrepayApp(
  p_invoice_distribution_id AP_INVOICE_DISTRIBUTIONS_ALL.INVOICE_DISTRIBUTION_ID%TYPE
) RETURN BOOLEAN IS
  l_dummy varchar2(1);
BEGIN
  SELECT NULL
    INTO l_dummy
    FROM ap_invoice_distributions_all dist
   WHERE dist.invoice_distribution_id = p_invoice_distribution_id
     AND EXISTS (
           SELECT NULL
             FROM ap_invoice_distributions_all ppdist
            WHERE ppdist.invoice_distribution_id = dist.charge_applicable_to_dist_id
              AND ppdist.line_type_lookup_code = 'PREPAY'
         );
  RETURN TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
END IsRelatedToPrepayApp;
/* Bug 5501250 - End */

END PA_ADJUSTMENTS ;

/
