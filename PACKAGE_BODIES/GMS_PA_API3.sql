--------------------------------------------------------
--  DDL for Package Body GMS_PA_API3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_PA_API3" AS
/* $Header: gmspax3b.pls 120.8.12010000.3 2009/08/03 04:04:12 prabsing ship $ */

/* added as part of bug 6761516 */
 TYPE t_numb_tab	     is table of number index by binary_integer;
 TYPE t_vch1_tab	     is table of varchar2(1) index by binary_integer;

 g_task_id_tab         t_numb_tab ;
 g_test_tab            t_vch1_tab ;
 /* end added as part of bug 6761516 */

      -- =====================
      -- Start of the comment
      -- API Name 	: grants_enabled
      -- Type		: Public
      -- Pre_reqs	: None
      -- Description	: Determine the grants implementations for a
      --                  operating unit. The value returned here is
      --                  from the cache.
      -- Parameters     : None
      -- Return Value   : 'Y' - Grants is implemented for a MO Org.
      --                  'N'- Grants is not implemented.
      --
      -- End of comments
      -- ===============

      FUNCTION grants_enabled return VARCHAR  is
	l_enabled VARCHAR2(1) ;
      BEGIN
	 l_enabled := 'N' ;

	 IF gms_install.enabled THEN
	    l_enabled := 'Y' ;
	 END IF ;

	 return l_enabled ;

      END grants_enabled ;

      -- =====================
      -- Start of the comment
      -- API Name 	: override_rate_rev_id
      -- Type		: Public
      -- Pre_reqs	: None
      -- Description	: The purpose of this API is to determine
      --                  the schedule based on the award.
      -- Called from    : PA_COST_PLUS.find_rate_sch_rev_id
      -- Return Value   : None
      --
      -- Parameters     :
      -- IN             :
      --                  p_tran_item_id    Expenditure item id
      --                  p_tran_type       Transaction type
      --                  p_task_id         Task ID
      --                  p_schedule_type   Schedule Type
      --                  C  - Costing Schedule
      --                  R  - Revenue Schedule
      --                  I  - Invoice Schedule
      --                  p_exp_item_date   Expenditure item date
      --OUT               x_sch_fixed_date  Schedule fixed date.
      --                  x_rate_sch_rev_id Revision ID
      --                  x_status          Status
      -- Note             Do not add 'commit' or 'rollback' in your code, since Oracle
      --                  Project Accounting controls the transaction for you.
      -- End of comments
      -- ===============

      PROCEDURE override_rate_rev_id(
                           p_tran_item_id          IN         number   DEFAULT NULL,
                           p_tran_type             IN         Varchar2 DEFAULT NULL,
                           p_task_id         	   IN         number   DEFAULT NULL,
                           p_schedule_type         IN         Varchar2 DEFAULT NULL,
                           p_exp_item_date         IN         Date     DEFAULT NULL,
                           x_sch_fixed_date        IN OUT nocopy Date,
                           x_rate_sch_rev_id 	   OUT nocopy number,
                           x_status                OUT nocopy number )  is

         l_sponsored_flag varchar2(1) ;

      BEGIN

	  x_rate_sch_rev_id:= NULL ;
	  x_status         := NULL ;

	  IF p_tran_item_id is NULL THEN
	     return ;
          END IF ;

          gms_pa_api.Override_Rate_Rev_Id(
                           p_tran_item_id,
                           p_tran_type   ,
                           p_task_id     ,
                           p_schedule_type ,
                           p_exp_item_date ,
                           x_sch_fixed_date,
                           x_rate_sch_rev_id ,
                           x_status          )   ;

      END override_rate_rev_id ;

      -- =====================
      -- Start of the comment
      -- API Name 	: commitments_changed
      -- Type		: Public
      -- Pre_reqs	: None
      -- Description	: The purpose of this API is to determine
      --                  the new manual encumbrances/REQ/PO/AP generated
      --                  since the last run of PSI process.
      -- Called from    : PA_CHECK_COMMITMENTS.COMMITMENTS_CHANGED
      -- Return Value   : Y
      --                  N
      --
      -- Parameters     :
      -- IN             :
      --                  p_project_id    Project ID value
      -- End of comments
      -- ===============
      -- Code merged in pa_check_commitments (PAXCMTVB.pls)

     -- =====================
      -- Start of the comment
      -- API Name       : is_award_same
      -- Type           : Public
      -- Pre_reqs       : None
      -- Description    : The purpose of this API is to compare the award entered by the user
      --                  in expenditure
      --                  entry form and the award for the reversal item found is same or not.
      -- Called from    : exp_items_private.check_matching_reversal
      -- Return Value   : Y
      --                  N
      --
      -- Parameters     :
      -- IN             :
      --                  expenditure_item_id  Item id of matching reversal item
      --                  award_number         Award Number entered in expenidture entry form.
      -- End of comments
      -- ===============
        FUNCTION is_award_same (P_expenditure_item_id IN NUMBER,
                                 P_award_number IN VARCHAR2 )
           RETURN VARCHAR2 IS

           l_award_same VARCHAR2(1) ;

         Begin

	   l_award_same := 'N' ;

           select 'Y'
             into  l_award_same
             from gms_award_distributions adl,
                  gms_awards ga
            where adl.expenditure_item_id = p_expenditure_item_id
              and adl.document_type = 'EXP'
              and adl.adl_status = 'A'
              and adl.adl_line_num = 1
              and adl.award_id = ga.award_id
              and ga.award_number = p_award_number;

           RETURN l_award_same ;

        Exception
          when no_data_found then
             return 'N';
        End is_award_same ;

      -- =====================
      -- Start of the comment
      -- API Name       : create_cmt_txns
      -- Type           : Public
      -- Pre_reqs       : None
      -- Description    : The purpose of this API is to create commitment transactions
      --                  using the GMS view and called from the PSI process .
      -- Called from    : PA_TXN_ACCUMS.create_cmt_txns
      -- Return Value   : None
      --
      -- Parameters     :
      -- IN             :
      --                  p_start_project_id         Starting project id in the range.
      --                  p_end_project_id           Last project id in the range.
      --                  p_system_linkage_function  System Linkage function
      -- End of comments
      -- ===============
         PROCEDURE create_cmt_txns ( p_start_project_id     IN NUMBER,
				     p_end_project_id       IN NUMBER,
				     p_system_linkage_function IN VARCHAR2 ) is

	   l_last_updated_by         NUMBER(15) ;
	   l_last_update_date        NUMBER(15) ;
	   l_created_by              NUMBER(15) ;
	   l_last_update_login       NUMBER(15) ;
	   l_request_id              NUMBER(15) ;
	   l_program_application_id  NUMBER(15) ;
	   l_program_id              NUMBER(15) ;
	   l_spon_project            NUMBER(15) ;
	   l_cur_pa_period           varchar2(20); /* Added for commitment change request */
	   l_cur_gl_period           varchar2(15); /* Added for commitment change request */

	   TYPE t_num_tab	     is table of number ;
	   TYPE t_vc30_tab	     is table of varchar2(30) ;
	   TYPE t_vc50_tab	     is table of varchar2(50) ;
	   TYPE t_vc1_tab	     is table of varchar2(1) ;
	   TYPE t_vc255_tab	     is table of varchar2(255) ;
	   TYPE t_vc240_tab	     is table of varchar2(240) ;
	   TYPE t_vc15_tab	     is table of varchar2(15) ;
	   TYPE t_vc20_tab	     is table of varchar2(20) ;
	   TYPE t_vc80_tab	     is table of varchar2(80) ;
	   TYPE t_date_tab           is table of date ;

	   l_project_id              t_num_tab ;
	   l_task_id                 t_num_tab ;
	   l_transaction_source      t_vc30_tab ;
	   l_line_type               t_vc1_tab ;
	   l_cmt_number              t_vc50_tab ;
	   l_cmt_distribution_id     t_num_tab ;
	   l_description             t_vc255_tab ;
           l_expenditure_item_date   t_date_tab ;
	   l_pa_period               t_vc20_tab ;
	   l_gl_period               t_vc15_tab ;
	   l_cmt_line_number         t_num_tab ;
	   l_creation_date           t_date_tab ;
	   l_approved_date           t_date_tab ;
	   l_requestor_name          t_vc240_tab ;
	   l_buyer_name              t_vc240_tab ;
	   l_approved_flag           t_vc1_tab ;
	   l_promised_date           t_date_tab ;
	   l_need_by_date            t_date_tab ;
	   l_header_id               t_num_tab ;
	   l_burdenable_raw_cost     t_num_tab ;
	   l_organization_id         t_num_tab ;
	   l_vendor_id               t_num_tab ;
	   l_vendor_name             t_vc240_tab ;
	   l_expenditure_type        t_vc30_tab ;
	   l_expenditure_category    t_vc30_tab ;
	   l_revenue_category        t_vc30_tab ;
	   l_system_linkage_function t_vc30_tab ;
	   l_unit_of_measure         t_vc30_tab ;
	   l_unit_price              t_num_tab ;
	   l_ind_compiled_set_id     t_num_tab ;
	   l_tot_cmt_raw_cost        t_num_tab ;
	   l_cmt_burdened_cost       t_num_tab ;
	   l_cmt_quantity            t_num_tab ;
	   l_quantity_ordered        t_num_tab ;
	   l_amount_ordered          t_num_tab ;
	   l_orig_quantity_ordered   t_num_tab ;
	   l_orig_amount_ordered     t_num_tab ;
	   l_quantity_cancelled      t_num_tab ;
	   l_amount_cancelled        t_num_tab ;
	   l_quantity_delivered      t_num_tab ;
	   l_amount_delivered        t_num_tab ;
	   l_quantity_invoiced       t_num_tab ;
	   l_amount_invoiced         t_num_tab ;
	   l_qty_out_delivery        t_num_tab ;
	   l_amount_out_delivery     t_num_tab ;
	   l_qty_out_invoiced        t_num_tab ;
	   l_amount_out_invoiced     t_num_tab ;
	   l_qty_overbilled          t_num_tab ;
	   l_amount_overbilled       t_num_tab ;
	   l_orig_txn_ref1           t_vc15_tab ;
	   l_orig_txn_ref2           t_vc15_tab ;
	   l_orig_txn_ref3           t_vc15_tab ;
	   l_updated_by              t_num_tab ;
	   l_update_date             t_date_tab ;
	   --l_created_by              t_num_tab ;
	   l_update_login            t_num_tab ;
	   l_receipt_currency_code   t_vc15_tab ;
	   l_acct_currency_code      t_vc15_tab ;
	   l_receipt_currency_amount t_num_tab ;
	   l_receipt_exchange_rate   t_num_tab ;
           l_acct_raw_cost           t_num_tab ;
	   l_denom_currency_code     t_vc15_tab ;
	   l_denom_raw_cost          t_num_tab ;
	   l_denom_burdened_cost     t_num_tab ;
	   l_acct_burdened_cost      t_num_tab ;
	   l_acct_rate_date          t_date_tab ;
	   l_acct_rate_type          t_vc30_tab ;
	   l_acct_exchange_rate      t_num_tab ;
	   l_cmt_rejection_code      t_vc80_tab ;
	   l_cmt_header_id           t_num_tab ;
         BEGIN

	   l_last_updated_by         := FND_GLOBAL.USER_ID;
	   l_last_update_date        := FND_GLOBAL.USER_ID;
	   l_created_by              := FND_GLOBAL.USER_ID;
	   l_last_update_login       := FND_GLOBAL.LOGIN_ID;
	   l_request_id              := FND_GLOBAL.CONC_REQUEST_ID;
	   l_program_application_id  := FND_GLOBAL.PROG_APPL_ID;
	   l_program_id              := FND_GLOBAL.CONC_PROGRAM_ID;

	   IF p_start_project_id is NULL then
	      return ;
           END IF ;

           -- l_cur_pa_period := pa_accum_utils.Get_current_pa_period;
           -- l_cur_gl_period := pa_accum_utils.Get_current_gl_period;

           -- bug 3746527
           select
                  per.PERIOD_NAME,
                  per.GL_PERIOD_NAME
             into
                  l_cur_pa_period,
                  l_cur_gl_period
             from
                  PA_PROJECTS_ALL prj,
                  PA_PERIODS_ALL per
            where
                  prj.PROJECT_ID = p_start_project_id and
                  nvl(per.ORG_ID, -1) = nvl(prj.ORG_ID, -1) and
                  per.CURRENT_PA_PERIOD_FLAG = 'Y';

           /* End of commitment change request*/
	   -- bug 4094814
	   -- psi will insert for non spon projects.
           -- l_spon_project := gms_cost_plus_extn.is_spon_project(p_start_project_id) ;
	   --
	   -- Non Sponsored Project related changes...
	   --
	   --IF l_spon_project = 1 THEN
           -- bug 4094814 code is changed in psi to allow insert for non spon projects.
	   --END IF ;

	   -- Continue sponsored project from here...
	   ---
           --
	   -- BUG: 3614241
	   -- Performance issue with gms_commitment_txns_v
	   -- FTS and NMV causing performance issue.
	   -- Resolution
	   --  We are making a insert for Manual encumbrance (raw and Burden )
	   --  Commitment insert for the raw cost using the BULK array.
	   --  Indirect cost insert is done using the bulk arary and ind_compiled_set_id
	   --  joins.
	   -- -----

	   l_project_id              := t_num_tab() ;
	   l_task_id                 := t_num_tab() ;
	   l_transaction_source      := t_vc30_tab() ;
	   l_line_type               := t_vc1_tab() ;
	   l_cmt_number              := t_vc50_tab() ;
	   l_cmt_distribution_id     := t_num_tab() ;
	   l_description             := t_vc255_tab() ;
           l_expenditure_item_date   := t_date_tab() ;
	   l_pa_period               := t_vc20_tab() ;
	   l_gl_period               := t_vc15_tab() ;
	   l_cmt_line_number         := t_num_tab() ;
	   l_creation_date           := t_date_tab() ;
	   l_approved_date           := t_date_tab() ;
	   l_requestor_name          := t_vc240_tab() ;
	   l_buyer_name              := t_vc240_tab() ;
	   l_approved_flag           := t_vc1_tab() ;
	   l_promised_date           := t_date_tab() ;
	   l_need_by_date            := t_date_tab() ;
	   l_header_id               := t_num_tab() ;
	   l_organization_id         := t_num_tab() ;
	   l_vendor_id               := t_num_tab() ;
	   l_vendor_name             := t_vc240_tab() ;
	   l_expenditure_type        := t_vc30_tab() ;
	   l_expenditure_category    := t_vc30_tab() ;
	   l_revenue_category        := t_vc30_tab() ;
	   l_system_linkage_function := t_vc30_tab() ;
	   l_unit_of_measure         := t_vc30_tab() ;
	   l_unit_price              := t_num_tab() ;
	   l_ind_compiled_set_id     := t_num_tab() ;
	   l_tot_cmt_raw_cost        := t_num_tab() ;
	   l_cmt_burdened_cost       := t_num_tab() ;
	   l_cmt_quantity            := t_num_tab() ;
	   l_quantity_ordered        := t_num_tab() ;
	   l_amount_ordered          := t_num_tab() ;
	   l_orig_quantity_ordered   := t_num_tab() ;
	   l_orig_amount_ordered     := t_num_tab() ;
	   l_quantity_cancelled      := t_num_tab() ;
	   l_amount_cancelled        := t_num_tab() ;
	   l_quantity_delivered      := t_num_tab() ;
	   l_amount_delivered        := t_num_tab() ;
	   l_quantity_invoiced       := t_num_tab() ;
	   l_amount_invoiced         := t_num_tab() ;
	   l_qty_out_delivery        := t_num_tab() ;
	   l_amount_out_delivery     := t_num_tab() ;
	   l_qty_out_invoiced        := t_num_tab() ;
	   l_amount_out_invoiced     := t_num_tab() ;
	   l_qty_overbilled          := t_num_tab() ;
	   l_amount_overbilled       := t_num_tab() ;
	   l_orig_txn_ref1           := t_vc15_tab() ;
	   l_orig_txn_ref2           := t_vc15_tab() ;
	   l_orig_txn_ref3           := t_vc15_tab() ;
	   l_updated_by              := t_num_tab() ;
	   l_update_date             := t_date_tab() ;
	   --l_created_by              := t_num_tab() ;
	   l_update_login            := t_num_tab() ;
           l_burdenable_raw_cost     := t_num_tab() ;
	   l_receipt_currency_code   := t_vc15_tab() ;
	   l_receipt_currency_amount := t_num_tab() ;
	   l_receipt_exchange_rate   := t_num_tab() ;
	   l_denom_currency_code     := t_vc15_tab() ;
	   l_denom_raw_cost          := t_num_tab() ;
	   l_acct_raw_cost           := t_num_tab() ;
	   l_acct_burdened_cost      := t_num_tab() ;
	   l_denom_burdened_cost     := t_num_tab() ;
	   l_acct_rate_date          := t_date_tab() ;
	   l_acct_rate_type          := t_vc30_tab() ;
	   l_acct_exchange_rate      := t_num_tab() ;
	   l_cmt_rejection_code      := t_vc80_tab() ;
	   l_cmt_header_id           := t_num_tab() ;

       --
       -- 3614241
       -- Insert Raw and burden cost for Manual encumbrances using the gms_enc_psi_v
       --
       -- bug 4068681 PJ.M:B10:P11:QA: GCW: UPDATE PROJECT SUMMARY AMOUNTS PROCESS ERRORS OUT
       -- gms_enc_psi_v view was fixed to use transaction source and project id column.
       -- transaction source was null as part of this bug.
       --

       INSERT INTO pa_commitment_txns
                   ( CMT_LINE_ID,
                     PROJECT_ID,
                     TASK_ID,
                     TRANSACTION_SOURCE,
                     LINE_TYPE,
                     CMT_NUMBER,
                     CMT_DISTRIBUTION_ID,
                     CMT_HEADER_ID,
                     DESCRIPTION,
                     EXPENDITURE_ITEM_DATE,
                     PA_PERIOD,
                     GL_PERIOD,
                     CMT_LINE_NUMBER,
                     CMT_CREATION_DATE,
                     CMT_APPROVED_DATE,
                     CMT_REQUESTOR_NAME,
                     CMT_BUYER_NAME,
                     CMT_APPROVED_FLAG,
                     CMT_PROMISED_DATE,
                     CMT_NEED_BY_DATE,
                     ORGANIZATION_ID,
                     VENDOR_ID,
                     VENDOR_NAME,
                     EXPENDITURE_TYPE,
                     EXPENDITURE_CATEGORY,
                     REVENUE_CATEGORY,
                     SYSTEM_LINKAGE_FUNCTION,
                     UNIT_OF_MEASURE,
                     UNIT_PRICE,
                     CMT_IND_COMPILED_SET_ID,
                     TOT_CMT_RAW_COST,
                     TOT_CMT_BURDENED_COST,
                     TOT_CMT_QUANTITY,
                     QUANTITY_ORDERED,
                     AMOUNT_ORDERED,
                     ORIGINAL_QUANTITY_ORDERED,
                     ORIGINAL_AMOUNT_ORDERED,
                     QUANTITY_CANCELLED,
                     AMOUNT_CANCELLED,
                     QUANTITY_DELIVERED,
                     AMOUNT_DELIVERED,
                     QUANTITY_INVOICED,
                     AMOUNT_INVOICED,
                     QUANTITY_OUTSTANDING_DELIVERY,
                     AMOUNT_OUTSTANDING_DELIVERY,
                     QUANTITY_OUTSTANDING_INVOICE,
                     AMOUNT_OUTSTANDING_INVOICE,
                     QUANTITY_OVERBILLED,
                     AMOUNT_OVERBILLED,
                     ORIGINAL_TXN_REFERENCE1,
                     ORIGINAL_TXN_REFERENCE2,
                     ORIGINAL_TXN_REFERENCE3,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     CREATION_DATE,
                     CREATED_BY,
                     LAST_UPDATE_LOGIN,
                     REQUEST_ID,
                     PROGRAM_APPLICATION_ID,
                     PROGRAM_ID,
                     PROGRAM_UPDATE_DATE,
                     BURDEN_SUM_SOURCE_RUN_ID,
                     BURDEN_SUM_DEST_RUN_ID,
                     BURDEN_SUM_REJECTION_CODE,
                     acct_raw_cost,
                     acct_burdened_cost,
            	     denom_currency_code,
            	     denom_raw_cost,
            	     denom_burdened_cost,
            	     acct_currency_code,
            	     acct_rate_date,
            	     acct_rate_type,
            	     acct_exchange_rate,
            	     receipt_currency_code,
            	     receipt_currency_amount,
            	     receipt_exchange_rate,
                     project_currency_code,
                     project_rate_date,
                     project_rate_type,
                     project_exchange_rate,
                     generation_error_flag,
            	     cmt_rejection_code
                 )
            SELECT   pa_txn_accums.cmt_line_id,
                     project_id,
                     task_id,
                     transaction_source,
                     line_type,
                     cmt_number,
                     cmt_distribution_id,
                     cmt_header_id,
                     description,
                     expenditure_item_date,
                     pa_period,
                     gl_period,
                     cmt_line_number,
                     cmt_creation_date,
                     cmt_approved_date,
                     cmt_requestor_name,
                     cmt_buyer_name,
                     cmt_approved_flag,
                     cmt_promised_date,
                     cmt_need_by_date,
                     organization_id,
                     vendor_id,
                     vendor_name,
                     expenditure_type,
                     expenditure_category,
                     revenue_category,
                     system_linkage_function,
                     unit_of_measure,
                     unit_price,
                     cmt_ind_compiled_set_id,
                     TO_NUMBER(NULL),
                     TO_NUMBER(NULL),
                     tot_cmt_quantity,
                     quantity_ordered,
                     amount_ordered,
                     original_quantity_ordered,
                     original_amount_ordered,
                     quantity_cancelled,
                     amount_cancelled,
                     quantity_delivered,
                     TO_NUMBER(NULL),
                     quantity_invoiced,
                     amount_invoiced,
                     quantity_outstanding_delivery,
                     amount_outstanding_delivery,
                     quantity_outstanding_invoice,
                     amount_outstanding_invoice,
                     quantity_overbilled,
                     amount_overbilled,
                     substr(original_txn_reference1,1,30),  -- bug 8745595
                     substr(original_txn_reference2,1,15),  -- bug 8745595
                         /*adding substr for original_txn_reference2 to make sure that the issue reported for attribute1 column does not occur for attribute6, which
                           is stored  in original_txn_reference2 and presently the size of original_txn_reference2 is 15, but this should be investigated further*/
                     original_txn_reference3,
                     SYSDATE,
                     l_last_updated_by,
                     SYSDATE,
                     l_created_by,
                     l_last_update_login,
                     l_request_id,
                     l_program_application_id,
                     l_program_id,
                     NULL,
                     -9999,
                     NULL,
                     NULL,
                     acct_raw_cost,
                     acct_burdened_cost,
            	     denom_currency_code,
            	     denom_raw_cost,
            	     denom_burdened_cost,
            	     acct_currency_code,
            	     acct_rate_date,
            	     acct_rate_type,
            	     acct_exchange_rate,
            	     receipt_currency_code,
            	     receipt_currency_amount,
            	     receipt_exchange_rate,
             	     NULL,
             	     TO_DATE(NULL),
            	     NULL,
            	     TO_NUMBER(NULL),
                     'N',
            	     NULL
              FROM   gms_enc_psi_v
             WHERE   project_id = p_start_project_id
             --WHERE   project_id BETWEEN p_start_project_id AND p_end_project_id
	     -- bug fixes for 3755094 and 3736097
               AND  NVL(system_linkage_function,'X') =
                            NVL(NVL(p_system_linkage_function,system_linkage_function),'X');

            --
            -- 3614241
            -- Fetch the commitment cost from gms_commitments_override_v into bulk araray elements.
            -- Only Raw cost is fetched here.

	    -- Requisition Insert (Raw Cost)
	    --
            -- bug 4007039 PJ.M:B8:P13:OTH:PERF: INDEX FULL SCAN, NON-MERGABLE VIEW and SHARABLE MEMORY>600K
	    -- gms_commitment_override v was removed and select from the REQ, PO and AP was used directly.
	    --
            SELECT
                     pprd.project_id,
                     pprd.task_id ,
                     'ORACLE_PURCHASING' ,
                      'R' ,
                     pprd.req_number ,
                     pprd.req_distribution_id ,
                     pprd.requisition_header_id ,
                     pprd.item_description ,
                     pprd.expenditure_item_date ,
                     l_cur_pa_period,
                     l_cur_gl_period,
                     pprd.req_line ,
                     pprd.creation_date ,
                     to_date(null) ,
                     pprd.requestor_name ,
                     to_char(null) ,
                     pprd.approved_flag ,
                     to_date(null) ,
                     pprd.need_by_date ,
                     pprd.expenditure_organization_id ,
                     pprd.vendor_id ,
                     pprd.vendor_name ,
                     pprd.expenditure_type ,
                     pprd.expenditure_category ,
                     pprd.revenue_category ,
                     'VI' ,
                     pprd.unit ,
                     pprd.unit_price ,
		     adl.ind_compiled_set_id,
                     pprd.quantity ,
                     to_number(null) ,
                     to_number(null) ,
                     to_number(null) ,
                     to_number(null) ,
                     to_number(null) ,
                     to_number(null) ,
                     to_number(null) ,
                     to_number(null) ,
                     to_number(null) ,
                     to_number(null) ,
                     to_number(null) ,
                     to_number(null) ,
                     to_number(null) ,
                     to_number(null) ,
                     to_number(null) ,
                     NULL ,
                     NULL ,
                     NULL ,
                     pprd.amount ,
                     pprd.amount ,
                     pprd.denom_currency_code ,
                     pprd.denom_amount ,
                     pprd.denom_amount ,
                     pprd.acct_currency_code ,
                     pprd.acct_rate_date ,
                     pprd.acct_rate_type ,
                     pprd.acct_exchange_rate ,
                     to_char(null) ,
                     to_number(null) ,
                     to_number(null),
		     adl.burdenable_raw_cost
       BULK collect into
                     l_project_id,
                     l_task_id,
                     l_transaction_source,
                     l_line_type,
                     l_cmt_number,
                     l_cmt_distribution_id,
                     l_cmt_header_id,
                     l_description,
                     l_expenditure_item_date,
                     l_pa_period,
                     l_gl_period,
                     l_cmt_line_number,
                     l_creation_date,
                     l_approved_date,
                     l_requestor_name,
                     l_buyer_name,
                     l_approved_flag,
                     l_promised_date,
                     l_need_by_date,
                     l_organization_id,
                     l_vendor_id,
                     l_vendor_name,
                     l_expenditure_type,
                     l_expenditure_category,
                     l_revenue_category,
                     l_system_linkage_function,
                     l_unit_of_measure,
                     l_unit_price,
                     l_ind_compiled_set_id,
                     l_cmt_quantity,
                     l_quantity_ordered,
                     l_amount_ordered,
                     l_orig_quantity_ordered,
                     l_orig_amount_ordered,
                     l_quantity_cancelled,
                     l_amount_cancelled,
                     l_quantity_delivered,
                     l_quantity_invoiced,
                     l_amount_invoiced,
                     l_qty_out_delivery,
                     l_amount_out_delivery,
                     l_qty_out_invoiced,
                     l_amount_out_invoiced,
                     l_qty_overbilled,
                     l_amount_overbilled,
                     l_orig_txn_ref1,
                     l_orig_txn_ref2,
                     l_orig_txn_ref3,
                     l_acct_raw_cost,
                     l_acct_burdened_cost,
            	     l_denom_currency_code,
            	     l_denom_raw_cost,
            	     l_denom_burdened_cost,
            	     l_acct_currency_code,
            	     l_acct_rate_date,
            	     l_acct_rate_type,
            	     l_acct_exchange_rate,
            	     l_receipt_currency_code,
            	     l_receipt_currency_amount,
            	     l_receipt_exchange_rate,
            	     l_burdenable_raw_cost
              FROM   PA_PROJ_REQ_DISTRIBUTIONS PPRD,
	             gms_award_distributions   adl
             WHERE   PPRD.project_id         = p_start_project_id
             --
             -- Bug : 4908630
             -- R12.PJ:XB2:DEV:GMS: APPSPERF:GMS: PACKAGE: GMSPAX3B.PLS ( SHARE MEM:11MB)  5 SQL
             --
	       and   adl.distribution_id = pprd.req_distribution_id
	       and   pprd.award_set_id        = adl.award_set_id
	       and   adl.adl_line_num= 1
	     -- bug fixes for 3755094 and 3736097
             --WHERE   project_id BETWEEN p_start_project_id AND p_end_project_id
               AND  'VI' = NVL(NVL(p_system_linkage_function,'VI'),'X');

	   if l_project_id.count <> 0 then

            --
            -- 3614241
            -- Insert Commitment raw Cost using the PL/SQL bulk array elements.
	    --
   	   FORALL indx in 1..l_project_id.count
            INSERT INTO pa_commitment_txns
                   ( cmt_line_id,
                     project_id,
                     task_id,
                     transaction_source,
                     line_type,
                     cmt_number,
                     cmt_distribution_id,
                     cmt_header_id,
                     description,
                     expenditure_item_date,
                     pa_period,
                     gl_period,
                     cmt_line_number,
                     cmt_creation_date,
                     cmt_approved_date,
                     cmt_requestor_name,
                     cmt_buyer_name,
                     cmt_approved_flag,
                     cmt_promised_date,
                     cmt_need_by_date,
                     organization_id,
                     vendor_id,
                     vendor_name,
                     expenditure_type,
                     expenditure_category,
                     revenue_category,
                     system_linkage_function,
                     unit_of_measure,
                     unit_price,
                     cmt_ind_compiled_set_id,
                     tot_cmt_raw_cost,
                     tot_cmt_burdened_cost,
                     tot_cmt_quantity,
                     quantity_ordered,
                     amount_ordered,
                     original_quantity_ordered,
                     original_amount_ordered,
                     quantity_cancelled,
                     amount_cancelled,
                     quantity_delivered,
                     amount_delivered,
                     quantity_invoiced,
                     amount_invoiced,
                     quantity_outstanding_delivery,
                     amount_outstanding_delivery,
                     quantity_outstanding_invoice,
                     amount_outstanding_invoice,
                     quantity_overbilled,
                     amount_overbilled,
                     original_txn_reference1,
                     original_txn_reference2,
                     original_txn_reference3,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date,
                     burden_sum_source_run_id,
                     burden_sum_dest_run_id,
                     burden_sum_rejection_code,
                     acct_raw_cost,
                     acct_burdened_cost,
            	     denom_currency_code,
            	     denom_raw_cost,
            	     denom_burdened_cost,
            	     acct_currency_code,
            	     acct_rate_date,
            	     acct_rate_type,
            	     acct_exchange_rate,
            	     receipt_currency_code,
            	     receipt_currency_amount,
            	     receipt_exchange_rate,
                     project_currency_code,
                     project_rate_date,
                     project_rate_type,
                     project_exchange_rate,
                     generation_error_flag,
            	     cmt_rejection_code
                 )
            values (
                     pa_txn_accums.cmt_line_id,
                     l_project_id(indx),
                     l_task_id(indx),
                     l_transaction_source(indx),
                     l_line_type(indx),
                     l_cmt_number(indx),
                     l_cmt_distribution_id(indx),
                     l_cmt_header_id(indx),
                     l_description(indx),
                     l_expenditure_item_date(indx),
                     l_pa_period(indx),
                     l_gl_period(indx),
                     l_cmt_line_number(indx),
                     l_creation_date(indx),
                     l_approved_date(indx),
                     l_requestor_name(indx),
                     l_buyer_name(indx),
                     l_approved_flag(indx),
                     l_promised_date(indx),
                     l_need_by_date(indx),
                     l_organization_id(indx),
                     l_vendor_id(indx),
                     l_vendor_name(indx),
                     l_expenditure_type(indx),
                     l_expenditure_category(indx),
                     l_revenue_category(indx),
                     l_system_linkage_function(indx),
                     l_unit_of_measure(indx),
                     l_unit_price(indx),
                     to_number(null),
                     to_number(null),
                     to_number(null),
                     l_cmt_quantity(indx),
                     l_quantity_ordered(indx),
                     l_amount_ordered(indx),
                     l_orig_quantity_ordered(indx),
                     l_orig_amount_ordered(indx),
                     l_quantity_cancelled(indx),
                     l_amount_cancelled(indx),
                     l_quantity_delivered(indx),
                     to_number(null),
                     l_quantity_invoiced(indx),
                     l_amount_invoiced(indx),
                     l_qty_out_delivery(indx),
                     l_amount_out_delivery(indx),
                     l_qty_out_invoiced(indx),
                     l_amount_out_invoiced(indx),
                     l_qty_overbilled(indx),
                     l_amount_overbilled(indx),
                     l_orig_txn_ref1(indx),
                     l_orig_txn_ref2(indx),
                     l_orig_txn_ref3(indx),
                     sysdate,
                     l_last_updated_by,
                     sysdate,
                     l_created_by,
                     l_last_update_login,
                     l_request_id,
                     l_program_application_id,
                     l_program_id,
                     null,
                     -9999,
                     null,
                     null,
                     l_acct_raw_cost(indx),
                     l_acct_burdened_cost(indx),
            	     l_denom_currency_code(indx),
            	     l_denom_raw_cost(indx),
            	     l_denom_burdened_cost(indx),
            	     l_acct_currency_code(indx),
            	     l_acct_rate_date(indx),
            	     l_acct_rate_type(indx),
            	     l_acct_exchange_rate(indx),
            	     l_receipt_currency_code(indx),
            	     l_receipt_currency_amount(indx),
            	     l_receipt_exchange_rate(indx),
             	     null,
             	     to_date(null),
            	     null,
            	     to_number(null),
                     'N',
            	     null )  ;

            --
            -- 3614241
            -- Insert Commitment idc Cost using the PL/SQL bulk array elements.
	    --
   	   FORALL indx in 1..l_project_id.count
            INSERT INTO pa_commitment_txns
                   ( cmt_line_id,
                     project_id,
                     task_id,
                     transaction_source,
                     line_type,
                     cmt_number,
                     cmt_distribution_id,
                     cmt_header_id,
                     description,
                     expenditure_item_date,
                     pa_period,
                     gl_period,
                     cmt_line_number,
                     cmt_creation_date,
                     cmt_approved_date,
                     cmt_requestor_name,
                     cmt_buyer_name,
                     cmt_approved_flag,
                     cmt_promised_date,
                     cmt_need_by_date,
                     organization_id,
                     vendor_id,
                     vendor_name,
                     expenditure_type,
                     expenditure_category,
                     revenue_category,
                     system_linkage_function,
                     unit_of_measure,
                     unit_price,
                     cmt_ind_compiled_set_id,
                     tot_cmt_raw_cost,
                     tot_cmt_burdened_cost,
                     tot_cmt_quantity,
                     quantity_ordered,
                     amount_ordered,
                     original_quantity_ordered,
                     original_amount_ordered,
                     quantity_cancelled,
                     amount_cancelled,
                     quantity_delivered,
                     amount_delivered,
                     quantity_invoiced,
                     amount_invoiced,
                     quantity_outstanding_delivery,
                     amount_outstanding_delivery,
                     quantity_outstanding_invoice,
                     amount_outstanding_invoice,
                     quantity_overbilled,
                     amount_overbilled,
                     original_txn_reference1,
                     original_txn_reference2,
                     original_txn_reference3,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date,
                     burden_sum_source_run_id,
                     burden_sum_dest_run_id,
                     burden_sum_rejection_code,
                     acct_raw_cost,
                     acct_burdened_cost,
            	     denom_currency_code,
            	     denom_raw_cost,
            	     denom_burdened_cost,
            	     acct_currency_code,
            	     acct_rate_date,
            	     acct_rate_type,
            	     acct_exchange_rate,
            	     receipt_currency_code,
            	     receipt_currency_amount,
            	     receipt_exchange_rate,
                     project_currency_code,
                     project_rate_date,
                     project_rate_type,
                     project_exchange_rate,
                     generation_error_flag,
            	     cmt_rejection_code
                 )
            select   pa_txn_accums.cmt_line_id,
                     l_project_id(indx),
                     l_task_id(indx),
                     l_transaction_source(indx),
                     l_line_type(indx),
                     l_cmt_number(indx),
                     l_cmt_distribution_id(indx),
                     l_cmt_header_id(indx),
                     l_description(indx),
                     l_expenditure_item_date(indx),
                     l_pa_period(indx),
                     l_gl_period(indx),
                     l_cmt_line_number(indx),
                     l_creation_date(indx),
                     l_approved_date(indx),
                     l_requestor_name(indx),
                     l_buyer_name(indx),
                     l_approved_flag(indx),
                     l_promised_date(indx),
                     l_need_by_date(indx),
                     l_organization_id(indx),
                     l_vendor_id(indx),
                     l_vendor_name(indx),
                     icc.expenditure_type,
                     pet.expenditure_category,
                     l_revenue_category(indx),
                     'BTC',
                     l_unit_of_measure(indx),
                     l_unit_price(indx),
                     l_ind_compiled_set_id(indx),
                     to_number(null),
                     to_number(null),
                     0,
                     0,
                     0,
                     0,
                     0,
                     0,
                     0,
                     0,
                     to_number(null),
                     0,
                     0,
                     0,
                     0,
                     0,
                     0,
                     0,
                     0,
                     l_orig_txn_ref1(indx),
                     l_orig_txn_ref2(indx),
                     l_orig_txn_ref3(indx),
                     sysdate,
                     l_last_updated_by,
                     sysdate,
                     l_created_by,
                     l_last_update_login,
                     l_request_id,
                     l_program_application_id,
                     l_program_id,
                     null,
                     -9999,
                     null,
                     null,
                     0,
                     pa_currency.round_currency_amt(nvl(l_burdenable_raw_cost(indx),0) * cm.compiled_multiplier),
            	     l_denom_currency_code(indx),
            	     0,
            	     pa_currency.round_currency_amt(nvl(l_burdenable_raw_cost(indx),0) * cm.compiled_multiplier /
                       nvl(l_acct_exchange_rate(indx),1)),
            	     l_acct_currency_code(indx),
            	     l_acct_rate_date(indx),
            	     l_acct_rate_type(indx),
            	     l_acct_exchange_rate(indx),
            	     l_receipt_currency_code(indx),
            	     l_receipt_currency_amount(indx),
            	     l_receipt_exchange_rate(indx),
             	     null,
             	     to_date(null),
            	     null,
            	     to_number(null),
                     'N',
            	     null
                FROM pa_ind_rate_sch_revisions irsr,
		     pa_cost_base_exp_types cbet,
		     pa_compiled_multipliers cm,
		     pa_ind_cost_codes icc,
		     pa_ind_rate_schedules_all_bg irs,
		     pa_ind_compiled_sets ics,
		     pa_expenditure_types pet
	       WHERE cbet.cost_base_type = 'INDIRECT COST'
      	         and pa_currency.round_currency_amt(nvl(l_burdenable_raw_cost(indx),0) * cm.compiled_multiplier) <> 0 --added for bug 6271366
--	         and l_acct_raw_cost(indx) <> 0
		 and ics.ind_compiled_set_id = l_ind_compiled_set_id(indx)
		 and cm.ind_compiled_set_id = DECODE( CBET.COST_BASE, NULL, NULL, ics.ind_compiled_set_id )
		 and icc.ind_cost_code = cm.ind_cost_code
		 and cbet.cost_base = cm.cost_base
		 and cbet.expenditure_type = l_expenditure_type(indx)
		 and irsr.cost_plus_structure = cbet.cost_plus_structure
		 and irs.ind_rate_sch_id = irsr.ind_rate_sch_id
		 and ics.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id
		 and ics.organization_id = l_organization_id(indx)
		 and ics.cost_base = cbet.cost_base
		 and icc.expenditure_type = pet.expenditure_type   ;
	   end if ;

         l_project_id.delete ;
         l_task_id.delete ;
         l_transaction_source.delete ;
         l_line_type.delete ;
         l_cmt_number.delete ;
         l_cmt_distribution_id.delete ;
         l_cmt_header_id.delete ;
         l_description.delete ;
         l_expenditure_item_date.delete ;
         l_pa_period.delete ;
         l_gl_period.delete ;
         l_cmt_line_number.delete ;
         l_creation_date.delete ;
         l_approved_date.delete ;
         l_requestor_name.delete ;
         l_buyer_name.delete ;
         l_approved_flag.delete ;
         l_promised_date.delete ;
         l_need_by_date.delete ;
         l_organization_id.delete ;
         l_vendor_id.delete ;
         l_vendor_name.delete ;
         l_expenditure_type.delete ;
         l_expenditure_category.delete ;
         l_revenue_category.delete ;
         l_system_linkage_function.delete ;
         l_unit_of_measure.delete ;
         l_unit_price.delete ;
         l_ind_compiled_set_id.delete ;
         l_cmt_quantity.delete ;
         l_quantity_ordered.delete ;
         l_amount_ordered.delete ;
         l_orig_quantity_ordered.delete ;
         l_orig_amount_ordered.delete ;
         l_quantity_cancelled.delete ;
         l_amount_cancelled.delete ;
         l_quantity_delivered.delete ;
         l_quantity_invoiced.delete ;
         l_amount_invoiced.delete ;
         l_qty_out_delivery.delete ;
         l_amount_out_delivery.delete ;
         l_qty_out_invoiced.delete ;
         l_amount_out_invoiced.delete ;
         l_qty_overbilled.delete ;
         l_amount_overbilled.delete ;
         l_orig_txn_ref1.delete ;
         l_orig_txn_ref2.delete ;
         l_orig_txn_ref3.delete ;
         l_acct_raw_cost.delete ;
         l_acct_burdened_cost.delete ;
         l_denom_currency_code.delete ;
         l_denom_raw_cost.delete ;
         l_denom_burdened_cost.delete ;
         l_acct_currency_code.delete ;
         l_acct_rate_date.delete ;
         l_acct_rate_type.delete ;
         l_acct_exchange_rate.delete ;
         l_receipt_currency_code.delete ;
         l_receipt_currency_amount.delete ;
         l_receipt_exchange_rate.delete ;
         l_burdenable_raw_cost.delete ;

	 --
	 -- Purchase Order Inserts... (Raw)
	    --
            -- bug 4007039 PJ.M:B8:P13:OTH:PERF: INDEX FULL SCAN, NON-MERGABLE VIEW and SHARABLE MEMORY>600K
	    -- gms_commitment_override v was removed and select from the REQ, PO and AP was used directly.
	    --

            SELECT
                pppd.project_id,
		pppd.task_id,
		'ORACLE_PURCHASING',
		'P',
		pppd.po_number,
		pppd.po_distribution_id,
		pppd.po_header_id,
		pppd.item_description,
		pppd.expenditure_item_date,
		l_cur_pa_period, /* Added for commitment change request*/
		l_cur_gl_period, /* Added for commitment change request*/
		pppd.po_line,
		pppd.creation_date,
		pppd.approved_date,
		pppd.requestor_name,
		pppd.buyer_name,
		pppd.approved_flag,
		pppd.promised_date,
		pppd.need_by_date ,
		pppd.expenditure_organization_id,
		pppd.vendor_id,
		pppd.vendor_name,
		pppd.expenditure_type,
		pppd.expenditure_category,
		pppd.revenue_category,
		'VI',
		pppd.unit,
		pppd.unit_price,
		adl.ind_compiled_set_id,
		pppd.quantity_outstanding_invoice,
		pppd.quantity_ordered,
		pppd.amount_ordered,
		pppd.original_quantity_ordered,
		pppd.original_amount_ordered,
		pppd.quantity_cancelled,
		pppd.amount_cancelled,
		pppd.quantity_delivered,
		pppd.quantity_invoiced,
		pppd.amount_invoiced,
		pppd.quantity_outstanding_delivery,
		pppd.amount_outstanding_delivery,
		pppd.quantity_outstanding_invoice,
		pppd.amount_outstanding_invoice,
		pppd.quantity_overbilled,
		pppd.amount_overbilled,
		NULL,
		NULL,
		NULL,
		pppd.amount_outstanding_invoice,
		PPPD.AMOUNT_OUTSTANDING_INVOICE ,
		pppd.denom_currency_code,
		pppd.denom_amt_outstanding_invoice,
		PPPD.denom_amt_outstanding_invoice ,
		pppd.acct_currency_code,
		pppd.acct_rate_date,
		pppd.acct_rate_type,
		pppd.acct_exchange_rate,
		TO_CHAR(NULL),
		TO_NUMBER(NULL),
		TO_NUMBER(NULL) ,
		adl.burdenable_raw_cost
            BULK collect into
                     l_project_id,
                     l_task_id,
                     l_transaction_source,
                     l_line_type,
                     l_cmt_number,
                     l_cmt_distribution_id,
                     l_cmt_header_id,
                     l_description,
                     l_expenditure_item_date,
                     l_pa_period,
                     l_gl_period,
                     l_cmt_line_number,
                     l_creation_date,
                     l_approved_date,
                     l_requestor_name,
                     l_buyer_name,
                     l_approved_flag,
                     l_promised_date,
                     l_need_by_date,
                     l_organization_id,
                     l_vendor_id,
                     l_vendor_name,
                     l_expenditure_type,
                     l_expenditure_category,
                     l_revenue_category,
                     l_system_linkage_function,
                     l_unit_of_measure,
                     l_unit_price,
                     l_ind_compiled_set_id,
                     l_cmt_quantity,
                     l_quantity_ordered,
                     l_amount_ordered,
                     l_orig_quantity_ordered,
                     l_orig_amount_ordered,
                     l_quantity_cancelled,
                     l_amount_cancelled,
                     l_quantity_delivered,
                     l_quantity_invoiced,
                     l_amount_invoiced,
                     l_qty_out_delivery,
                     l_amount_out_delivery,
                     l_qty_out_invoiced,
                     l_amount_out_invoiced,
                     l_qty_overbilled,
                     l_amount_overbilled,
                     l_orig_txn_ref1,
                     l_orig_txn_ref2,
                     l_orig_txn_ref3,
                     l_acct_raw_cost,
                     l_acct_burdened_cost,
                     l_denom_currency_code,
            	     l_denom_raw_cost,
            	     l_denom_burdened_cost,
            	     l_acct_currency_code,
            	     l_acct_rate_date,
            	     l_acct_rate_type,
            	     l_acct_exchange_rate,
            	     l_receipt_currency_code,
            	     l_receipt_currency_amount,
            	     l_receipt_exchange_rate,
            	     l_burdenable_raw_cost
              FROM   PA_PROJ_PO_DISTRIBUTIONS PPPD,
		     GMS_AWARD_DISTRIBUTIONS ADL
             WHERE   PPPD.project_id = p_start_project_id
	       and   pppd.po_distribution_id = adl.po_distribution_id
	       and   pppd.award_set_id       = adl.award_set_id
	       and   adl.adl_line_num        = 1
	     -- bug fixes for 3755094 and 3736097
             --WHERE   project_id BETWEEN p_start_project_id AND p_end_project_id
               AND  'VI' = NVL(NVL(p_system_linkage_function,'VI'),'X');

	   if l_project_id.count <> 0 then

            --
            -- 3614241
            -- Insert Commitment raw Cost using the PL/SQL bulk array elements.
	    --
   	   FORALL indx in 1..l_project_id.count

            INSERT INTO pa_commitment_txns
                   ( cmt_line_id,
                     project_id,
                     task_id,
                     transaction_source,
                     line_type,
                     cmt_number,
                     cmt_distribution_id,
                     cmt_header_id,
                     description,
                     expenditure_item_date,
                     pa_period,
                     gl_period,
                     cmt_line_number,
                     cmt_creation_date,
                     cmt_approved_date,
                     cmt_requestor_name,
                     cmt_buyer_name,
                     cmt_approved_flag,
                     cmt_promised_date,
                     cmt_need_by_date,
                     organization_id,
                     vendor_id,
                     vendor_name,
                     expenditure_type,
                     expenditure_category,
                     revenue_category,
                     system_linkage_function,
                     unit_of_measure,
                     unit_price,
                     cmt_ind_compiled_set_id,
                     tot_cmt_raw_cost,
                     tot_cmt_burdened_cost,
                     tot_cmt_quantity,
                     quantity_ordered,
                     amount_ordered,
                     original_quantity_ordered,
                     original_amount_ordered,
                     quantity_cancelled,
                     amount_cancelled,
                     quantity_delivered,
                     amount_delivered,
                     quantity_invoiced,
                     amount_invoiced,
                     quantity_outstanding_delivery,
                     amount_outstanding_delivery,
                     quantity_outstanding_invoice,
                     amount_outstanding_invoice,
                     quantity_overbilled,
                     amount_overbilled,
                     original_txn_reference1,
                     original_txn_reference2,
                     original_txn_reference3,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date,
                     burden_sum_source_run_id,
                     burden_sum_dest_run_id,
                     burden_sum_rejection_code,
                     acct_raw_cost,
                     acct_burdened_cost,
            	     denom_currency_code,
            	     denom_raw_cost,
            	     denom_burdened_cost,
            	     acct_currency_code,
            	     acct_rate_date,
            	     acct_rate_type,
            	     acct_exchange_rate,
            	     receipt_currency_code,
            	     receipt_currency_amount,
            	     receipt_exchange_rate,
                     project_currency_code,
                     project_rate_date,
                     project_rate_type,
                     project_exchange_rate,
                     generation_error_flag,
            	     cmt_rejection_code
                 )
            values (
                     pa_txn_accums.cmt_line_id,
                     l_project_id(indx),
                     l_task_id(indx),
                     l_transaction_source(indx),
                     l_line_type(indx),
                     l_cmt_number(indx),
                     l_cmt_distribution_id(indx),
                     l_cmt_header_id(indx),
                     l_description(indx),
                     l_expenditure_item_date(indx),
                     l_pa_period(indx),
                     l_gl_period(indx),
                     l_cmt_line_number(indx),
                     l_creation_date(indx),
                     l_approved_date(indx),
                     l_requestor_name(indx),
                     l_buyer_name(indx),
                     l_approved_flag(indx),
                     l_promised_date(indx),
                     l_need_by_date(indx),
                     l_organization_id(indx),
                     l_vendor_id(indx),
                     l_vendor_name(indx),
                     l_expenditure_type(indx),
                     l_expenditure_category(indx),
                     l_revenue_category(indx),
                     l_system_linkage_function(indx),
                     l_unit_of_measure(indx),
                     l_unit_price(indx),
                     to_number(null),
                     to_number(null),
                     to_number(null),
                     l_cmt_quantity(indx),
                     l_quantity_ordered(indx),
                     l_amount_ordered(indx),
                     l_orig_quantity_ordered(indx),
                     l_orig_amount_ordered(indx),
                     l_quantity_cancelled(indx),
                     l_amount_cancelled(indx),
                     l_quantity_delivered(indx),
                     to_number(null),
                     l_quantity_invoiced(indx),
                     l_amount_invoiced(indx),
                     l_qty_out_delivery(indx),
                     l_amount_out_delivery(indx),
                     l_qty_out_invoiced(indx),
                     l_amount_out_invoiced(indx),
                     l_qty_overbilled(indx),
                     l_amount_overbilled(indx),
                     l_orig_txn_ref1(indx),
                     l_orig_txn_ref2(indx),
                     l_orig_txn_ref3(indx),
                     sysdate,
                     l_last_updated_by,
                     sysdate,
                     l_created_by,
                     l_last_update_login,
                     l_request_id,
                     l_program_application_id,
                     l_program_id,
                     null,
                     -9999,
                     null,
                     null,
                     l_acct_raw_cost(indx),
                     l_acct_burdened_cost(indx),
            	     l_denom_currency_code(indx),
            	     l_denom_raw_cost(indx),
            	     l_denom_burdened_cost(indx),
            	     l_acct_currency_code(indx),
            	     l_acct_rate_date(indx),
            	     l_acct_rate_type(indx),
            	     l_acct_exchange_rate(indx),
            	     l_receipt_currency_code(indx),
            	     l_receipt_currency_amount(indx),
            	     l_receipt_exchange_rate(indx),
             	     null,
             	     to_date(null),
            	     null,
            	     to_number(null),
                     'N',
            	     null )  ;

            --
            -- 3614241
            -- Insert Commitment idc Cost using the PL/SQL bulk array elements.
	    --
   	   FORALL indx in 1..l_project_id.count
            INSERT INTO pa_commitment_txns
                   ( cmt_line_id,
                     project_id,
                     task_id,
                     transaction_source,
                     line_type,
                     cmt_number,
                     cmt_distribution_id,
                     cmt_header_id,
                     description,
                     expenditure_item_date,
                     pa_period,
                     gl_period,
                     cmt_line_number,
                     cmt_creation_date,
                     cmt_approved_date,
                     cmt_requestor_name,
                     cmt_buyer_name,
                     cmt_approved_flag,
                     cmt_promised_date,
                     cmt_need_by_date,
                     organization_id,
                     vendor_id,
                     vendor_name,
                     expenditure_type,
                     expenditure_category,
                     revenue_category,
                     system_linkage_function,
                     unit_of_measure,
                     unit_price,
                     cmt_ind_compiled_set_id,
                     tot_cmt_raw_cost,
                     tot_cmt_burdened_cost,
                     tot_cmt_quantity,
                     quantity_ordered,
                     amount_ordered,
                     original_quantity_ordered,
                     original_amount_ordered,
                     quantity_cancelled,
                     amount_cancelled,
                     quantity_delivered,
                     amount_delivered,
                     quantity_invoiced,
                     amount_invoiced,
                     quantity_outstanding_delivery,
                     amount_outstanding_delivery,
                     quantity_outstanding_invoice,
                     amount_outstanding_invoice,
                     quantity_overbilled,
                     amount_overbilled,
                     original_txn_reference1,
                     original_txn_reference2,
                     original_txn_reference3,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date,
                     burden_sum_source_run_id,
                     burden_sum_dest_run_id,
                     burden_sum_rejection_code,
                     acct_raw_cost,
                     acct_burdened_cost,
            	     denom_currency_code,
            	     denom_raw_cost,
            	     denom_burdened_cost,
            	     acct_currency_code,
            	     acct_rate_date,
            	     acct_rate_type,
            	     acct_exchange_rate,
            	     receipt_currency_code,
            	     receipt_currency_amount,
            	     receipt_exchange_rate,
                     project_currency_code,
                     project_rate_date,
                     project_rate_type,
                     project_exchange_rate,
                     generation_error_flag,
            	     cmt_rejection_code
                 )
            select   pa_txn_accums.cmt_line_id,
                     l_project_id(indx),
                     l_task_id(indx),
                     l_transaction_source(indx),
                     l_line_type(indx),
                     l_cmt_number(indx),
                     l_cmt_distribution_id(indx),
                     l_cmt_header_id(indx),
                     l_description(indx),
                     l_expenditure_item_date(indx),
                     l_pa_period(indx),
                     l_gl_period(indx),
                     l_cmt_line_number(indx),
                     l_creation_date(indx),
                     l_approved_date(indx),
                     l_requestor_name(indx),
                     l_buyer_name(indx),
                     l_approved_flag(indx),
                     l_promised_date(indx),
                     l_need_by_date(indx),
                     l_organization_id(indx),
                     l_vendor_id(indx),
                     l_vendor_name(indx),
                     icc.expenditure_type,
                     pet.expenditure_category,
                     l_revenue_category(indx),
                     'BTC',
                     l_unit_of_measure(indx),
                     l_unit_price(indx),
                     l_ind_compiled_set_id(indx),
                     to_number(null),
                     to_number(null),
                     0,
                     0,
                     0,
                     0,
                     0,
                     0,
                     0,
                     0,
                     to_number(null),
                     0,
                     0,
                     0,
                     0,
                     0,
                     0,
                     0,
                     0,
                     l_orig_txn_ref1(indx),
                     l_orig_txn_ref2(indx),
                     l_orig_txn_ref3(indx),
                     sysdate,
                     l_last_updated_by,
                     sysdate,
                     l_created_by,
                     l_last_update_login,
                     l_request_id,
                     l_program_application_id,
                     l_program_id,
                     null,
                     -9999,
                     null,
                     null,
                     0,
                     pa_currency.round_currency_amt(nvl(l_burdenable_raw_cost(indx),0) * cm.compiled_multiplier),
            	     l_denom_currency_code(indx),
            	     0,
            	     pa_currency.round_currency_amt(nvl(l_burdenable_raw_cost(indx),0) * cm.compiled_multiplier /
                       nvl(l_acct_exchange_rate(indx),1)),
            	     l_acct_currency_code(indx),
            	     l_acct_rate_date(indx),
            	     l_acct_rate_type(indx),
            	     l_acct_exchange_rate(indx),
            	     l_receipt_currency_code(indx),
            	     l_receipt_currency_amount(indx),
            	     l_receipt_exchange_rate(indx),
             	     null,
             	     to_date(null),
            	     null,
            	     to_number(null),
                     'N',
            	     null
                FROM pa_ind_rate_sch_revisions irsr,
		     pa_cost_base_exp_types cbet,
		     pa_compiled_multipliers cm,
		     pa_ind_cost_codes icc,
		     pa_ind_rate_schedules_all_bg irs,
		     pa_ind_compiled_sets ics,
		     pa_expenditure_types pet
	       WHERE cbet.cost_base_type = 'INDIRECT COST'
	         and pa_currency.round_currency_amt(nvl(l_burdenable_raw_cost(indx),0) * cm.compiled_multiplier) <> 0 --added for bug 6271366
	         and l_acct_raw_cost(indx) <> 0
		 and ics.ind_compiled_set_id = l_ind_compiled_set_id(indx)
		 and cm.ind_compiled_set_id = DECODE( CBET.COST_BASE, NULL, NULL, ics.ind_compiled_set_id )
		 and icc.ind_cost_code = cm.ind_cost_code
		 and cbet.cost_base = cm.cost_base
		 and cbet.expenditure_type = l_expenditure_type(indx)
		 and irsr.cost_plus_structure = cbet.cost_plus_structure
		 and irs.ind_rate_sch_id = irsr.ind_rate_sch_id
		 and ics.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id
		 and ics.organization_id = l_organization_id(indx)
		 and ics.cost_base = cbet.cost_base
		 and icc.expenditure_type = pet.expenditure_type   ;
	   end if ;
         --
	 -- AP Transactions starts here
	 --
	    --
            -- bug 4007039 PJ.M:B8:P13:OTH:PERF: INDEX FULL SCAN, NON-MERGABLE VIEW and SHARABLE MEMORY>600K
	    -- gms_commitment_override v was removed and select from the REQ, PO and AP was used directly.
	    --
         l_project_id.delete ;
         l_task_id.delete ;
         l_transaction_source.delete ;
         l_line_type.delete ;
         l_cmt_number.delete ;
         l_cmt_distribution_id.delete ;
         l_cmt_header_id.delete ;
         l_description.delete ;
         l_expenditure_item_date.delete ;
         l_pa_period.delete ;
         l_gl_period.delete ;
         l_cmt_line_number.delete ;
         l_creation_date.delete ;
         l_approved_date.delete ;
         l_requestor_name.delete ;
         l_buyer_name.delete ;
         l_approved_flag.delete ;
         l_promised_date.delete ;
         l_need_by_date.delete ;
         l_organization_id.delete ;
         l_vendor_id.delete ;
         l_vendor_name.delete ;
         l_expenditure_type.delete ;
         l_expenditure_category.delete ;
         l_revenue_category.delete ;
         l_system_linkage_function.delete ;
         l_unit_of_measure.delete ;
         l_unit_price.delete ;
         l_ind_compiled_set_id.delete ;
         l_cmt_quantity.delete ;
         l_quantity_ordered.delete ;
         l_amount_ordered.delete ;
         l_orig_quantity_ordered.delete ;
         l_orig_amount_ordered.delete ;
         l_quantity_cancelled.delete ;
         l_amount_cancelled.delete ;
         l_quantity_delivered.delete ;
         l_quantity_invoiced.delete ;
         l_amount_invoiced.delete ;
         l_qty_out_delivery.delete ;
         l_amount_out_delivery.delete ;
         l_qty_out_invoiced.delete ;
         l_amount_out_invoiced.delete ;
         l_qty_overbilled.delete ;
         l_amount_overbilled.delete ;
         l_orig_txn_ref1.delete ;
         l_orig_txn_ref2.delete ;
         l_orig_txn_ref3.delete ;
         l_acct_raw_cost.delete ;
         l_acct_burdened_cost.delete ;
         l_denom_currency_code.delete ;
         l_denom_raw_cost.delete ;
         l_denom_burdened_cost.delete ;
         l_acct_currency_code.delete ;
         l_acct_rate_date.delete ;
         l_acct_rate_type.delete ;
         l_acct_exchange_rate.delete ;
         l_receipt_currency_code.delete ;
         l_receipt_currency_amount.delete ;
         l_receipt_exchange_rate.delete ;
         l_burdenable_raw_cost.delete ;

         SELECT
		ppaid.project_id,
		ppaid.task_id,
                'ORACLE_PAYABLES',
                'I',
		ppaid.invoice_number,
            /* R12 AP Lines uptake:record invoice distribution ID and
               invoice line number instead of line number which is no
               longer unique.*/
		ppaid.invoice_distribution_id,
		ppaid.invoice_id,
		ppaid.description,
		ppaid.expenditure_item_date,
		l_cur_pa_period, /* Added for commitment change request*/
		l_cur_gl_period, /* Added for commitment change request*/
            /* R12 AP Lines uptake:record invoice distribution ID and
               invoice line number instead of line number which is no
               longer unique.*/
		ppaid.invoice_line_number,
		ppaid.invoice_date,
                to_date(NULL),
                to_char(NULL),
                to_char(NULL),
		ppaid.approved_flag,
                to_date(NULL),
                to_date(NULL),
		ppaid.expenditure_organization_id,
                vendor_id,
		ppaid.vendor_name,
		ppaid.expenditure_type,
		ppaid.expenditure_category,
		ppaid.revenue_category,
                'VI',
                to_char(NULL),
                to_number(NULL),
		adl.ind_compiled_set_id,
		ppaid.quantity,
		to_number(null),
                to_number(null),
                to_number(null),
                to_number(null),
                to_number(null),
                to_number(null),
                to_number(null),
                to_number(null),
                to_number(null),
                to_number(null),
                to_number(null),
                to_number(null),
                to_number(null),
                to_number(null),
                to_number(null),
		null,
		null,
		null,
		ppaid.amount,
		ppaid.amount ,
		ppaid.denom_currency_code,
		ppaid.denom_amount,
		ppaid.denom_amount ,
		ppaid.acct_currency_code,
		ppaid.acct_rate_date,
		ppaid.acct_rate_type,
		ppaid.acct_exchange_rate,
		ppaid.receipt_currency_code ,
		ppaid.receipt_currency_amount ,
		ppaid.receipt_exchange_rate ,
/* Commented for Bug 5645290
		adl.burdenable_raw_cost */
/* Added for Bug 5645290 */
                decode(gae.burden_cost_limit,NULL,ppaid.denom_amount,adl.burdenable_raw_cost)
/* Bug 5645290 - End */
	        BULK collect into
                     l_project_id,
                     l_task_id,
                     l_transaction_source,
                     l_line_type,
                     l_cmt_number,
                     l_cmt_distribution_id,
                     l_cmt_header_id,
                     l_description,
                     l_expenditure_item_date,
                     l_pa_period,
                     l_gl_period,
                     l_cmt_line_number,
                     l_creation_date,
                     l_approved_date,
                     l_requestor_name,
                     l_buyer_name,
                     l_approved_flag,
                     l_promised_date,
                     l_need_by_date,
                     l_organization_id,
                     l_vendor_id,
                     l_vendor_name,
                     l_expenditure_type,
                     l_expenditure_category,
                     l_revenue_category,
                     l_system_linkage_function,
                     l_unit_of_measure,
                     l_unit_price,
                     l_ind_compiled_set_id,
                     l_cmt_quantity,
                     l_quantity_ordered,
                     l_amount_ordered,
                     l_orig_quantity_ordered,
                     l_orig_amount_ordered,
                     l_quantity_cancelled,
                     l_amount_cancelled,
                     l_quantity_delivered,
                     l_quantity_invoiced,
                     l_amount_invoiced,
                     l_qty_out_delivery,
                     l_amount_out_delivery,
                     l_qty_out_invoiced,
                     l_amount_out_invoiced,
                     l_qty_overbilled,
                     l_amount_overbilled,
                     l_orig_txn_ref1,
                     l_orig_txn_ref2,
                     l_orig_txn_ref3,
                     l_acct_raw_cost,
                     l_acct_burdened_cost,
           	     l_denom_currency_code,
            	     l_denom_raw_cost,
            	     l_denom_burdened_cost,
            	     l_acct_currency_code,
            	     l_acct_rate_date,
            	     l_acct_rate_type,
            	     l_acct_exchange_rate,
            	     l_receipt_currency_code,
            	     l_receipt_currency_amount,
            	     l_receipt_exchange_rate,
            	     l_burdenable_raw_cost
/* Commented for Bug 5645290
              FROM   PA_PROJ_AP_INV_DISTRIBUTIONS PPAID,
		     GMS_AWARD_DISTRIBUTIONS      ADL
             WHERE   PPAID.project_id                   = p_start_project_id */
/* Added for Bug 5645290 */
              FROM   PA_PROJ_AP_INV_DISTRIBUTIONS PPAID,
		     GMS_AWARD_DISTRIBUTIONS      ADL,
                     gms_allowable_expenditures gae,
	             gms_awards_all ga
             WHERE   PPAID.project_id = p_start_project_id
               and   ga.award_id = adl.award_id
               and   gae.allowability_schedule_id = ga.allowable_schedule_id
               and   gae.expenditure_type = PPAID.expenditure_type
/* Bug 5645290 - End */
             /* R12 AP Lines uptake:record invoice distribution ID and
                invoice line number instead of line number which is no
                longer unique.*/
             --
             -- Bug : 4908630
             -- R12.PJ:XB2:DEV:GMS: APPSPERF:GMS: PACKAGE: GMSPAX3B.PLS ( SHARE MEM:11MB)  5 SQL
             --
               and   adl.invoice_distribution_id  = ppaid.invoice_distribution_id
	       and   ppaid.award_set_id                 = adl.award_set_id
	       and   adl.adl_line_num          = 1
	       and   adl.invoice_id               = ppaid.invoice_id
	       and   adl.distribution_line_number = ppaid.distribution_line_number
               and  'VI' = NVL(NVL(p_system_linkage_function,'VI'),'X')
	       and   NVL(adl.payment_status_flag , 'N') <> 'Y' ;
	     -- bug fixes for 3755094 and 3736097
             --WHERE   project_id BETWEEN p_start_project_id AND p_end_project_id

	   if l_project_id.count <> 0 then

            --
            -- 3614241
            -- Insert Commitment raw Cost using the PL/SQL bulk array elements.
	    --
   	   FORALL indx in 1..l_project_id.count

            INSERT INTO pa_commitment_txns
                   ( cmt_line_id,
                     project_id,
                     task_id,
                     transaction_source,
                     line_type,
                     cmt_number,
                     cmt_distribution_id,
                     cmt_header_id,
                     description,
                     expenditure_item_date,
                     pa_period,
                     gl_period,
                     cmt_line_number,
                     cmt_creation_date,
                     cmt_approved_date,
                     cmt_requestor_name,
                     cmt_buyer_name,
                     cmt_approved_flag,
                     cmt_promised_date,
                     cmt_need_by_date,
                     organization_id,
                     vendor_id,
                     vendor_name,
                     expenditure_type,
                     expenditure_category,
                     revenue_category,
                     system_linkage_function,
                     unit_of_measure,
                     unit_price,
                     cmt_ind_compiled_set_id,
                     tot_cmt_raw_cost,
                     tot_cmt_burdened_cost,
                     tot_cmt_quantity,
                     quantity_ordered,
                     amount_ordered,
                     original_quantity_ordered,
                     original_amount_ordered,
                     quantity_cancelled,
                     amount_cancelled,
                     quantity_delivered,
                     amount_delivered,
                     quantity_invoiced,
                     amount_invoiced,
                     quantity_outstanding_delivery,
                     amount_outstanding_delivery,
                     quantity_outstanding_invoice,
                     amount_outstanding_invoice,
                     quantity_overbilled,
                     amount_overbilled,
                     original_txn_reference1,
                     original_txn_reference2,
                     original_txn_reference3,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date,
                     burden_sum_source_run_id,
                     burden_sum_dest_run_id,
                     burden_sum_rejection_code,
                     acct_raw_cost,
                     acct_burdened_cost,
            	     denom_currency_code,
            	     denom_raw_cost,
            	     denom_burdened_cost,
            	     acct_currency_code,
            	     acct_rate_date,
            	     acct_rate_type,
            	     acct_exchange_rate,
            	     receipt_currency_code,
            	     receipt_currency_amount,
            	     receipt_exchange_rate,
                     project_currency_code,
                     project_rate_date,
                     project_rate_type,
                     project_exchange_rate,
                     generation_error_flag,
            	     cmt_rejection_code
                 )
            values (
                     pa_txn_accums.cmt_line_id,
                     l_project_id(indx),
                     l_task_id(indx),
                     l_transaction_source(indx),
                     l_line_type(indx),
                     l_cmt_number(indx),
                     l_cmt_distribution_id(indx),
                     l_cmt_header_id(indx),
                     l_description(indx),
                     l_expenditure_item_date(indx),
                     l_pa_period(indx),
                     l_gl_period(indx),
                     l_cmt_line_number(indx),
                     l_creation_date(indx),
                     l_approved_date(indx),
                     l_requestor_name(indx),
                     l_buyer_name(indx),
                     l_approved_flag(indx),
                     l_promised_date(indx),
                     l_need_by_date(indx),
                     l_organization_id(indx),
                     l_vendor_id(indx),
                     l_vendor_name(indx),
                     l_expenditure_type(indx),
                     l_expenditure_category(indx),
                     l_revenue_category(indx),
                     l_system_linkage_function(indx),
                     l_unit_of_measure(indx),
                     l_unit_price(indx),
                     to_number(null),
                     to_number(null),
                     to_number(null),
                     l_cmt_quantity(indx),
                     l_quantity_ordered(indx),
                     l_amount_ordered(indx),
                     l_orig_quantity_ordered(indx),
                     l_orig_amount_ordered(indx),
                     l_quantity_cancelled(indx),
                     l_amount_cancelled(indx),
                     l_quantity_delivered(indx),
                     to_number(null),
                     l_quantity_invoiced(indx),
                     l_amount_invoiced(indx),
                     l_qty_out_delivery(indx),
                     l_amount_out_delivery(indx),
                     l_qty_out_invoiced(indx),
                     l_amount_out_invoiced(indx),
                     l_qty_overbilled(indx),
                     l_amount_overbilled(indx),
                     l_orig_txn_ref1(indx),
                     l_orig_txn_ref2(indx),
                     l_orig_txn_ref3(indx),
                     sysdate,
                     l_last_updated_by,
                     sysdate,
                     l_created_by,
                     l_last_update_login,
                     l_request_id,
                     l_program_application_id,
                     l_program_id,
                     null,
                     -9999,
                     null,
                     null,
                     l_acct_raw_cost(indx),
                     l_acct_burdened_cost(indx),
            	     l_denom_currency_code(indx),
            	     l_denom_raw_cost(indx),
            	     l_denom_burdened_cost(indx),
            	     l_acct_currency_code(indx),
            	     l_acct_rate_date(indx),
            	     l_acct_rate_type(indx),
            	     l_acct_exchange_rate(indx),
            	     l_receipt_currency_code(indx),
            	     l_receipt_currency_amount(indx),
            	     l_receipt_exchange_rate(indx),
             	     null,
             	     to_date(null),
            	     null,
            	     to_number(null),
                     'N',
            	     null )  ;

            --
            -- 3614241
            -- Insert Commitment idc Cost using the PL/SQL bulk array elements.
	    --
   	   FORALL indx in 1..l_project_id.count
            INSERT INTO pa_commitment_txns
                   ( cmt_line_id,
                     project_id,
                     task_id,
                     transaction_source,
                     line_type,
                     cmt_number,
                     cmt_distribution_id,
                     cmt_header_id,
                     description,
                     expenditure_item_date,
                     pa_period,
                     gl_period,
                     cmt_line_number,
                     cmt_creation_date,
                     cmt_approved_date,
                     cmt_requestor_name,
                     cmt_buyer_name,
                     cmt_approved_flag,
                     cmt_promised_date,
                     cmt_need_by_date,
                     organization_id,
                     vendor_id,
                     vendor_name,
                     expenditure_type,
                     expenditure_category,
                     revenue_category,
                     system_linkage_function,
                     unit_of_measure,
                     unit_price,
                     cmt_ind_compiled_set_id,
                     tot_cmt_raw_cost,
                     tot_cmt_burdened_cost,
                     tot_cmt_quantity,
                     quantity_ordered,
                     amount_ordered,
                     original_quantity_ordered,
                     original_amount_ordered,
                     quantity_cancelled,
                     amount_cancelled,
                     quantity_delivered,
                     amount_delivered,
                     quantity_invoiced,
                     amount_invoiced,
                     quantity_outstanding_delivery,
                     amount_outstanding_delivery,
                     quantity_outstanding_invoice,
                     amount_outstanding_invoice,
                     quantity_overbilled,
                     amount_overbilled,
                     original_txn_reference1,
                     original_txn_reference2,
                     original_txn_reference3,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date,
                     burden_sum_source_run_id,
                     burden_sum_dest_run_id,
                     burden_sum_rejection_code,
                     acct_raw_cost,
                     acct_burdened_cost,
            	     denom_currency_code,
            	     denom_raw_cost,
            	     denom_burdened_cost,
            	     acct_currency_code,
            	     acct_rate_date,
            	     acct_rate_type,
            	     acct_exchange_rate,
            	     receipt_currency_code,
            	     receipt_currency_amount,
            	     receipt_exchange_rate,
                     project_currency_code,
                     project_rate_date,
                     project_rate_type,
                     project_exchange_rate,
                     generation_error_flag,
            	     cmt_rejection_code
                 )
            select   pa_txn_accums.cmt_line_id,
                     l_project_id(indx),
                     l_task_id(indx),
                     l_transaction_source(indx),
                     l_line_type(indx),
                     l_cmt_number(indx),
                     l_cmt_distribution_id(indx),
                     l_cmt_header_id(indx),
                     l_description(indx),
                     l_expenditure_item_date(indx),
                     l_pa_period(indx),
                     l_gl_period(indx),
                     l_cmt_line_number(indx),
                     l_creation_date(indx),
                     l_approved_date(indx),
                     l_requestor_name(indx),
                     l_buyer_name(indx),
                     l_approved_flag(indx),
                     l_promised_date(indx),
                     l_need_by_date(indx),
                     l_organization_id(indx),
                     l_vendor_id(indx),
                     l_vendor_name(indx),
                     icc.expenditure_type,
                     pet.expenditure_category,
                     l_revenue_category(indx),
                     'BTC',
                     l_unit_of_measure(indx),
                     l_unit_price(indx),
                     l_ind_compiled_set_id(indx),
                     to_number(null),
                     to_number(null),
                     0,
                     0,
                     0,
                     0,
                     0,
                     0,
                     0,
                     0,
                     to_number(null),
                     0,
                     0,
                     0,
                     0,
                     0,
                     0,
                     0,
                     0,
                     l_orig_txn_ref1(indx),
                     l_orig_txn_ref2(indx),
                     l_orig_txn_ref3(indx),
                     sysdate,
                     l_last_updated_by,
                     sysdate,
                     l_created_by,
                     l_last_update_login,
                     l_request_id,
                     l_program_application_id,
                     l_program_id,
                     null,
                     -9999,
                     null,
                     null,
                     0,
                     pa_currency.round_currency_amt(nvl(l_burdenable_raw_cost(indx),0) * cm.compiled_multiplier),
            	     l_denom_currency_code(indx),
            	     0,
            	     pa_currency.round_currency_amt(nvl(l_burdenable_raw_cost(indx),0) * cm.compiled_multiplier /
                       nvl(l_acct_exchange_rate(indx),1)),
            	     l_acct_currency_code(indx),
            	     l_acct_rate_date(indx),
            	     l_acct_rate_type(indx),
            	     l_acct_exchange_rate(indx),
            	     l_receipt_currency_code(indx),
            	     l_receipt_currency_amount(indx),
            	     l_receipt_exchange_rate(indx),
             	     null,
             	     to_date(null),
            	     null,
            	     to_number(null),
                     'N',
            	     null
                FROM pa_ind_rate_sch_revisions irsr,
		     pa_cost_base_exp_types cbet,
		     pa_compiled_multipliers cm,
		     pa_ind_cost_codes icc,
		     pa_ind_rate_schedules_all_bg irs,
		     pa_ind_compiled_sets ics,
		     pa_expenditure_types pet
	       WHERE cbet.cost_base_type = 'INDIRECT COST'
	         and pa_currency.round_currency_amt(nvl(l_burdenable_raw_cost(indx),0) * cm.compiled_multiplier) <> 0 --added for bug 6271366
	         and l_acct_raw_cost(indx) <> 0
		 and ics.ind_compiled_set_id = l_ind_compiled_set_id(indx)
		 and cm.ind_compiled_set_id = DECODE( CBET.COST_BASE, NULL, NULL, ics.ind_compiled_set_id )
		 and icc.ind_cost_code = cm.ind_cost_code
		 and cbet.cost_base = cm.cost_base
		 and cbet.expenditure_type = l_expenditure_type(indx)
		 and irsr.cost_plus_structure = cbet.cost_plus_structure
		 and irs.ind_rate_sch_id = irsr.ind_rate_sch_id
		 and ics.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id
		 and ics.organization_id = l_organization_id(indx)
		 and ics.cost_base = cbet.cost_base
		 and icc.expenditure_type = pet.expenditure_type   ;
	   end if ;

	 END create_cmt_txns ;

      -- =====================
      -- Start of the comment
      -- Bug            : 3599305
      -- API Name       : is_project_type_sponsored
      -- Type           : Public
      -- Pre_reqs       : None
      -- Description    : The purpose of this API is to check if project type is
      --                  marked as sponsored in Grants Accounting.
      -- Called from    :  project type entry and project entry form
      -- Return Value   : Y - Yes
      --                  N - No
      --
      -- Parameters     :
      -- IN             :
      --                  p_project_type          varchar2
      -- End of comments
      -- ===============
      -- bug reference : 3596872
      -- problem       : Please put the SELECT statement in the api :-  GMS_PA_API3.IS_PROJECT_TYPE_SPONSORED  in a cursor.
      --                 If no record is found, the api should return 'N'.
      --                 Otherwise, it is throwing a NO-DATA-FOUND error.
      -- Situation     : When new project type is being created and not saved yet.
      --
         FUNCTION is_project_type_sponsored ( p_project_type     IN VARCHAR2 )
	          return varchar2 is
           l_spon_flag varchar2(1) ;
         begin

	     if p_project_type is NULL then
	        return 'N' ;
             end if ;

	     l_spon_flag := 'N' ;

	     select sponsored_flag
	       into l_spon_flag
               from gms_project_types
              where project_type = p_project_type ;

	     return NVL(l_spon_flag, 'N') ;
         -- bug 3596872
         EXCEPTION
	    when no_data_found then
	         return 'N' ;
	 END is_project_type_sponsored ;

      -- Bug 5726575
      -- =====================
      -- Start of the comment
      -- API Name       : mark_impacted_enc_items
      -- Type           : Public
      -- Pre_reqs       : None
      -- Description    : This procedure is called from
      --                  pa_cost_plus.mark_impacted_exp_items (PAXCCPEB.pls).
      --                  This procedure will mark all the burden impacted lines
      --                  in gms_encumbrance_items_all.
      --
      -- Called from    : pa_cost_plus.mark_impacted_exp_items
      -- Return Value   : None
      --
      -- Parameters     :
      -- IN             :p_ind_compiled_set_id
      --                 p_g_impacted_cost_bases
      --                 p_g_cp_structure
      --                 p_indirect_cost_code
      --                 p_rate_sch_rev_id
      --                 p_g_rate_sch_rev_id
      --                 p_g_org_id
      --                 p_g_org_override
      -- OUT            :errbuf
      --                 retcode
      -- End of comments
      -- ===============
      Procedure mark_impacted_enc_items (p_ind_compiled_set_id in number,
                                         p_g_impacted_cost_bases in varchar2,
                                         p_g_cp_structure in varchar2,
                                         p_indirect_cost_code in varchar2,
                                         p_rate_sch_rev_id in number,
                                         p_g_rate_sch_rev_id in number,
                                         p_g_org_id in number,
                                         p_g_org_override in number,
                                         errbuf OUT NOCOPY VARCHAR2,
                                         retcode OUT NOCOPY     VARCHAR2)
      is
        x_last_updated_by   number(15);
        x_last_update_login number(15);
        x_request_id        number(15);
      begin

        x_last_updated_by   := FND_GLOBAL.USER_ID;
        x_last_update_login := FND_GLOBAL.LOGIN_ID;
        x_request_id        := FND_GLOBAL.CONC_REQUEST_ID;

        UPDATE gms_encumbrance_items_all ITEM
        SET ITEM.enc_distributed_flag =
                 DECODE(ITEM.enc_distributed_flag,
                        'Y', decode(ITEM.ind_compiled_set_id,
                                    p_ind_compiled_set_id, 'N',
                                    ITEM.enc_distributed_flag),
                        ITEM.enc_distributed_flag),
            ITEM.adjustment_type =
                 DECODE(ITEM.enc_distributed_flag,
                        'Y', decode(ITEM.ind_compiled_set_id,
                                    p_ind_compiled_set_id, 'BURDEN_RECOMPILE',
                                    ITEM.adjustment_type),
                        ITEM.adjustment_type),
            ITEM.ind_compiled_set_id = NULL,
            ITEM.last_update_date = SYSDATE,
            ITEM.last_updated_by = x_last_updated_by,
            ITEM.last_update_login = x_last_update_login,
            ITEM.request_id = x_request_id
        WHERE (ITEM.ind_compiled_set_id = p_ind_compiled_set_id
               AND ITEM.enc_distributed_flag = 'Y')
          AND NVL(ITEM.net_zero_adjustment_flag,'N') <> 'Y'
          AND pa_project_stus_utils.Is_Project_Closed(ITEM.project_id) <>'Y'
          AND gms_pa_api2.is_award_closed(ITEM.encumbrance_item_id,ITEM.task_id, 'ENC') = 'N'
          AND exists (select /*+ NO_UNNEST */ null
                      from pa_cost_base_exp_types cbet
                      where cbet.cost_base = p_g_impacted_cost_bases
                        AND cbet.cost_plus_structure = p_g_cp_structure
                        AND cbet.cost_base_type   = p_indirect_cost_code
                        AND cbet.expenditure_type = ITEM.encumbrance_type)
          AND EXISTS (SELECT NULL
                       FROM GMS_ENCUMBRANCES_ALL EXP,
                            PA_IND_COMPILED_SETS ICS
                       WHERE EXP.ENCUMBRANCE_ID = ITEM.ENCUMBRANCE_ID
                         AND ICS.IND_COMPILED_SET_ID = ITEM.IND_COMPILED_SET_ID
                         AND NVL(ITEM.OVERRIDE_TO_ORGANIZATION_ID,  EXP.INCURRED_BY_ORGANIZATION_ID) =ICS.ORGANIZATION_ID
                         AND ICS.STATUS = 'H'
			  AND ICS.IND_RATE_SCH_REVISION_ID = p_rate_sch_rev_id --Bug#5989869
                         AND DECODE(p_rate_sch_rev_id ,p_g_rate_sch_rev_id ,DECODE(ICS.ORGANIZATION_ID,p_g_org_id ,p_g_org_override
                                , PA_COST_PLUS.CHECK_FOR_EXPLICIT_MULTIPLIER(p_rate_sch_rev_id ,ICS.ORGANIZATION_ID))
                                , PA_COST_PLUS.CHECK_FOR_EXPLICIT_MULTIPLIER(p_rate_sch_rev_id ,ICS.ORGANIZATION_ID ))=0
                     )
          AND pa_utils2.Proj_Type_Burden_Disp_Method(ITEM.project_id) IN ('S','s','D','d');
      exception
        when others then
          errbuf := sqlcode;
          retcode := sqlerrm;
      end mark_impacted_enc_items;

      -- Bug 5726575
      -- =====================
      -- Start of the comment
      -- API Name       : mark_prev_rev_enc_items
      -- Type           : Public
      -- Pre_reqs       : None
      -- Description    : This procedure is called from
      --                  pa_cost_plus.mark_prev_rev_exp_items (PAXCCPEB.pls).
      --                  This procedure will mark all the burden impacted lines
      --                  in gms_encumbrance_items_all.
      --
      -- Called from    : pa_cost_plus.mark_prev_rev_exp_items
      -- Return Value   : None
      --
      -- Parameters     :
      -- IN             :p_compiled_set_id
      --                 p_start_date
      --                 p_end_date
      --                 p_mode
      -- OUT            :errbuf
      --                 retcode
      -- End of comments
      -- ===============
      Procedure mark_prev_rev_enc_items (p_compiled_set_id in number,
                                         p_start_date in date,
                                         p_end_date in date,
                                         p_mode in varchar2,
                                         errbuf OUT NOCOPY VARCHAR2,
                                         retcode OUT NOCOPY     VARCHAR2)
      is
        x_last_updated_by   number(15);
        x_last_update_login number(15);
        x_request_id        number(15);
      begin
        x_last_updated_by   := FND_GLOBAL.USER_ID;
        x_last_update_login := FND_GLOBAL.LOGIN_ID;
        x_request_id        := FND_GLOBAL.CONC_REQUEST_ID;

        if p_mode = 'T' then  --Update when task.cost_ind_sch_fixed_date is populated.
	NULL;
	--update commented for the Bug#5989869
          /*UPDATE gms_encumbrance_items_all ei
          SET    enc_distributed_flag = 'N',
                 adjustment_type ='BURDEN_RECOMPILE',
                 last_update_date = SYSDATE,
                 last_updated_by = x_last_updated_by,
                 last_update_login = x_last_update_login,
                 request_id = x_request_id
          WHERE  ind_compiled_set_id = p_compiled_set_id
            AND  EXISTS
                 (SELECT task_id
                  FROM   pa_tasks task
                  WHERE  task.task_id = ei.task_id
                    AND  task.cost_ind_sch_fixed_date BETWEEN p_start_date AND
                             NVL(p_end_date, cost_ind_sch_fixed_date))
            AND  nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
            AND  pa_project_stus_utils.Is_Project_Closed(ei.project_id) <>'Y'
            AND  pa_utils2.Proj_Type_Burden_Disp_Method(ei.project_id) = 'D'
            AND  gms_pa_api2.is_award_closed(ei.encumbrance_item_id,ei.task_id, 'ENC') = 'N';*/
        elsif p_mode = 'N' then --Update based on task.cost_ind_sch_fixed_date IS NULL then go by enc_item_date
	NULL;
	--update commented for the Bug#5989869
          /*UPDATE gms_encumbrance_items_all ei
          SET    enc_distributed_flag =  'N' ,
                 adjustment_type ='BURDEN_RECOMPILE',
                 last_update_date = SYSDATE,
                 last_updated_by = x_last_updated_by,
                 last_update_login = x_last_update_login,
                 request_id = x_request_id
          WHERE  ind_compiled_set_id = p_compiled_set_id
            AND  trunc(encumbrance_item_date) between trunc(p_start_date) and
                         trunc(nvl(p_end_date, encumbrance_item_date))
            AND  EXISTS
                 (SELECT task_id
                  FROM   pa_tasks task
                  WHERE  task.task_id = ei.task_id
                    AND  task.cost_ind_sch_fixed_date IS NULL)
            AND nvl(ei.net_zero_adjustment_flag, 'N') <>'Y'
            AND pa_project_stus_utils.Is_Project_Closed(ei.project_id) <> 'Y'
            AND gms_pa_api2.is_award_closed(ei.encumbrance_item_id,ei.task_id, 'ENC') = 'N'
            AND pa_utils2.Proj_Type_Burden_Disp_Method(ei.project_id) = 'D';*/
        elsif p_mode = 'O' then --Update based on enc_item_date
          UPDATE gms_encumbrance_items_all ei
          SET    enc_distributed_flag =  'N' ,
                 adjustment_type ='BURDEN_RECOMPILE',
                 last_update_date = SYSDATE,
                 last_updated_by = x_last_updated_by,
                 last_update_login = x_last_update_login,
                 request_id = x_request_id
          WHERE  ei.ind_compiled_set_id = p_compiled_set_id
            AND  ei.encumbrance_item_date between p_start_date and nvl(p_end_date, ei.encumbrance_item_date) --Bug#5989869; Removed TRUNC
	    AND  nvl(ei.net_zero_adjustment_flag, 'N') <> 'Y'
            AND  pa_project_stus_utils.Is_Project_Closed(ei.project_id) <> 'Y'
            --AND  pa_utils2.Proj_Type_Burden_Disp_Method(ei.project_id) = 'D' commented for bug#5989869
            AND  gms_pa_api2.is_award_closed(ei.encumbrance_item_id,ei.task_id, 'ENC') = 'N';
        end if;
      exception
        when others then
          errbuf := sqlcode;
          retcode := sqlerrm;
      end mark_prev_rev_enc_items;

      -- Bug 6761516
      -- =====================
      -- Start of the comment
      -- API Name       : mark_enc_items_for_recalc
      -- Type           : Public
      -- Pre_reqs       : None
      -- Description    : This procedure is called from
      --                  GMSAWEAW.fmb and GMSICOVR.fmb.
      --                  This procedure will mark all the associated encumbrance items for recalc
      --                  on insertion, uodation or deletion in Award Management Compliance Screen
      --                  or in Override Schedules Screen.
      --
      -- Called from    : GMSAWEAW.fmb and GMSICOVR.fmb
      -- Return Value   : None
      --
      -- Parameters     :
      -- IN             :p_ind_rate_sch_id
      --                 p_award_id
      --                 p_project_id
      --                 p_task_id
      --                 p_calling_form
      --                 p_event
      --                 p_idc_schedule_fixed_date
      -- OUT            :errbuf
      --                 retcode
      -- End of comments
      -- ===============
    Procedure mark_enc_items_for_recalc (p_ind_rate_sch_id in number,
                                         p_award_id in number,
                                         p_project_id in number,
                                         p_task_id in number,
                                         p_calling_form in varchar2,
                                         p_event in varchar2,
                                         p_idc_schedule_fixed_date in date,
                                         errbuf OUT NOCOPY VARCHAR2,
                                         retcode OUT NOCOPY     VARCHAR2)
      is
        x_last_updated_by   number(15);
        x_last_update_login number(15);
        x_request_id        number(15);
        l_start_date_min    date;
        l_end_date_max      date;
        l_debug             varchar2(1) ;
        l_test              number(1);
        l_award_status gms_awards_all.status%TYPE ;  --BUG 7225876
        l_close_date   gms_awards_all.close_date%TYPE ; -- BUG 7225876
        l_project_closed     varchar2(1); -- BUG 7225876

      begin
        L_DEBUG := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N'); -- to generate debug messages

        IF L_DEBUG = 'Y' THEN
           gms_error_pkg.gms_debug(' ARGUMENTS RECEIVED:: p_ind_rate_sch_id:' || p_ind_rate_sch_id || ',p_award_id:' || p_award_id, 'C');
           gms_error_pkg.gms_debug(',p_project_id:' || p_project_id || ',p_task_id:' || p_task_id || ',p_idc_schedule_fixed_date:' || p_idc_schedule_fixed_date, 'C');
           gms_error_pkg.gms_debug(',p_calling_form:' || p_calling_form || ',p_event:' || p_event, 'C');
        END IF;

        x_last_updated_by   := FND_GLOBAL.USER_ID;
        x_last_update_login := FND_GLOBAL.LOGIN_ID;
        x_request_id        := FND_GLOBAL.CONC_REQUEST_ID;

          begin /* added for bug 7225876 */
                select aw.status, aw.close_date
                  into l_award_status,l_close_date
                  from gms_awards_all aw
                 where aw.award_id = p_award_id;
           exception
              when others then
                  l_award_status := null;
                  l_close_date := null;
           end;

        if p_idc_schedule_fixed_date is null then  -- mark only those enc items for recalc where enc date falls between any of the revisions of associated burden schedule
          IF L_DEBUG = 'Y' THEN
             gms_error_pkg.gms_debug('p_idc_schedule_fixed_date is null', 'C');
          END IF;

          begin
             l_test := 0;
             select 1
             into l_test
             from pa_ind_rate_sch_revisions irsr
             where irsr.ind_rate_sch_id = p_ind_rate_sch_id
               and end_date_active is null;
          exception
             when no_data_found then
                  l_test := 0;
          end;

          if l_test = 0 then
                select min(start_date_active), max(end_date_active)
                into l_start_date_min, l_end_date_max
                from pa_ind_rate_sch_revisions irsr
                where irsr.ind_rate_sch_id = p_ind_rate_sch_id;
          else
                select min(start_date_active)
                into l_start_date_min
                from pa_ind_rate_sch_revisions irsr
                where irsr.ind_rate_sch_id = p_ind_rate_sch_id;
          end if;

          if p_calling_form = 'GMSICOVR' then -- call from override schedule screen
               IF L_DEBUG = 'Y' THEN
                  gms_error_pkg.gms_debug('Call is from OVERRIDE SCHEDULES SCREEN', 'C');
               END IF;

            IF l_award_status <> 'CLOSED' AND l_close_date >= trunc (sysdate ) then /* bug 7225876   */

              l_project_closed := pa_project_stus_utils.Is_Project_Closed(p_project_id);

             UPDATE gms_encumbrance_items_all ITEM
             SET ITEM.enc_distributed_flag = 'N',
                 ITEM.adjustment_type = 'BURDEN_RECALC',
                 ITEM.ind_compiled_set_id = NULL,
                 ITEM.last_update_date = SYSDATE,
                 ITEM.last_updated_by = x_last_updated_by,
                 ITEM.last_update_login = x_last_update_login,
                 ITEM.request_id = x_request_id
             WHERE ITEM.enc_distributed_flag = 'Y'
               AND NVL(ITEM.net_zero_adjustment_flag,'N') <> 'Y'
               AND ITEM.project_id = p_project_id
/*               AND 1 = decode(p_task_id, NULL, 1,
                              decode(ITEM.task_id ,p_task_id, 1, 2))  need to chech the top_task_id instead of task_id */
/* in the following decode, if p_task_id is null, check if any other override for same award, project exists.
                            if p_task id is not null, check if p_task_id = top_task_id for the enc. */
/* calling new function item_task_validate */
/*               AND 1 = decode(p_task_id, NULL ,decode (1, (select 1
                                                             from GMS_OVERRIDE_SCHEDULES GOS,
                                                                  pa_tasks TASK
                                                             where GOS.award_id = p_award_id
                                                               and GOS.project_id = p_project_id
                                                               and nvl(ITEM.task_id,-99) = TASK.task_id
                                                               and nvl(GOS.task_id,-99) = TASK.top_task_id
                                                               and rownum = 1) ,2
                                                                               ,1)
                                              ,decode((select top_task_id
                                                       from pa_tasks
                                                       where task_id = ITEM.task_id), p_task_id ,1
                                                                                                ,2))*/
               AND gms_pa_api3.item_task_validate(p_award_id, p_project_id, p_task_id, ITEM.task_id) = 'Y'
               AND l_project_closed <>'Y' --bug 7225876
              --bug 6967150 AND gms_pa_api2.is_award_closed(ITEM.encumbrance_item_id,ITEM.task_id, 'ENC') = 'N'
               AND EXISTS ( select null
                            from gms_award_distributions adl
                            where adl.expenditure_item_id = ITEM.encumbrance_item_id
                              and adl.document_type = 'ENC'  -- Added these three checks for bug 7225876
                              and adl.adl_status = 'A'
                              and adl.adl_line_num = 1
                              and adl.award_id = p_award_id )
               AND ITEM.encumbrance_item_date between l_start_date_min
                                              and nvl(l_end_date_max,ITEM.encumbrance_item_date)  -- dates corresponding to schedule revisions
              --bug 7225876 AND pa_utils2.Proj_Type_Burden_Disp_Method(ITEM.project_id) IN ('S','s','D','d')
               AND ITEM.ind_compiled_set_id > 0 -- bug 7225876
               AND 1 = decode(p_event, 'INSERT', 1
                                               , (select 1
                                                 from pa_ind_compiled_sets ics,
                                                      pa_ind_rate_sch_revisions irsr
                                                 where ITEM.ind_compiled_set_id = ics.ind_compiled_set_id
                                                   and ics.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id
                                                   and irsr.ind_rate_sch_id = p_ind_rate_sch_id
                                                   and rownum = 1));
            end if;

           elsif p_calling_form = 'GMSAWEAW' then -- call from award management compliance tab

               IF L_DEBUG = 'Y' THEN
                  gms_error_pkg.gms_debug('Call is from AWARD MANAGEMENT SCREEN', 'C');
               END IF;

            IF l_award_status <> 'CLOSED' AND l_close_date >= trunc (sysdate ) then -- bug 7225876

             UPDATE gms_encumbrance_items_all ITEM
             SET ITEM.enc_distributed_flag = 'N',
                 ITEM.adjustment_type = 'BURDEN_RECALC',
                 ITEM.ind_compiled_set_id = NULL,
                 ITEM.last_update_date = SYSDATE,
                 ITEM.last_updated_by = x_last_updated_by,
                 ITEM.last_update_login = x_last_update_login,
                 ITEM.request_id = x_request_id
             WHERE ITEM.enc_distributed_flag = 'Y'
               AND NVL(ITEM.net_zero_adjustment_flag,'N') <> 'Y'
               AND pa_project_stus_utils.Is_Project_Closed(ITEM.project_id) <>'Y'  --  bug 7225876
           --  bug 7225876  AND gms_pa_api2.is_award_closed(ITEM.encumbrance_item_id,ITEM.task_id, 'ENC') = 'N'
               AND EXISTS
                    ( select null
                      from gms_award_distributions adl
                      where adl.expenditure_item_id = ITEM.encumbrance_item_id
                        and adl.award_id = p_award_id
                        and adl.document_type = 'ENC' -- Added these three conditions for bug 7225876
                        and adl.adl_status = 'A'
                        and adl.adl_line_num = 1)
               AND ITEM.encumbrance_item_date between l_start_date_min and nvl(l_end_date_max,ITEM.encumbrance_item_date)
           --   bug 6967150 AND pa_utils2.Proj_Type_Burden_Disp_Method(ITEM.project_id) IN ('S','s','D','d')
               AND ITEM.ind_compiled_set_id > 0 -- bug 7225876
               AND NOT EXISTS
                   ( select 1
                     from GMS_OVERRIDE_SCHEDULES GOS,
                          pa_tasks TASK
                     where GOS.award_id = p_award_id
                       and GOS.project_id = ITEM.project_id
                       and ITEM.task_id = TASK.task_id
                       and nvl(GOS.task_id, TASK.top_task_id) = TASK.top_task_id);
            end if;
           end if;
        else -- p_idc_schedule_fixed_date is not null, mark all associated enc items for recalc
             IF L_DEBUG = 'Y' THEN
                gms_error_pkg.gms_debug('p_idc_schedule_fixed_date is not null', 'C');
             END IF;

           if p_calling_form = 'GMSICOVR' then -- call from override schedule screen

             IF L_DEBUG = 'Y' THEN
                gms_error_pkg.gms_debug('call is from override schedule screen', 'C');
             END IF;

             IF l_award_status <> 'CLOSED' AND l_close_date >= trunc (sysdate ) then -- bug 7225876

              l_project_closed := pa_project_stus_utils.Is_Project_Closed(p_project_id);

             UPDATE gms_encumbrance_items_all ITEM
             SET ITEM.enc_distributed_flag = 'N',
                 ITEM.adjustment_type = 'BURDEN_RECALC',
                 ITEM.ind_compiled_set_id = NULL,
                 ITEM.last_update_date = SYSDATE,
                 ITEM.last_updated_by = x_last_updated_by,
                 ITEM.last_update_login = x_last_update_login,
                 ITEM.request_id = x_request_id
             WHERE ITEM.enc_distributed_flag = 'Y'
               AND NVL(ITEM.net_zero_adjustment_flag,'N') <> 'Y'
               AND ITEM.project_id = p_project_id
/*               AND 1 = decode(p_task_id, NULL, 1,
                              decode(ITEM.task_id ,p_task_id, 1, 2)) need to chech the top_task_id instead of task_id */
/* in the following decode, if p_task_id is null, check if any other override for same award, project exists.
                            if p_task id is not null, check if p_task_id = top_task_id for the enc. */
/* calling new function item_task_validate */
/*               AND 1 = decode(p_task_id, NULL ,decode (1, (select 1
                                                             from GMS_OVERRIDE_SCHEDULES GOS,
                                                                  pa_tasks TASK
                                                             where GOS.award_id = p_award_id
                                                               and GOS.project_id = p_project_id
                                                               and nvl(ITEM.task_id,-99) = TASK.task_id
                                                               and nvl(GOS.task_id,-99) = TASK.top_task_id
                                                               and rownum = 1) ,2
                                                                               ,1)
                                              ,decode((select top_task_id
                                                       from pa_tasks
                                                       where task_id = ITEM.task_id), p_task_id ,1
                                                                                                ,2))*/
               AND gms_pa_api3.item_task_validate(p_award_id, p_project_id, p_task_id, ITEM.task_id) = 'Y'
               AND l_project_closed <>'Y' --bug 7225876
          --bug6967150  AND gms_pa_api2.is_award_closed(ITEM.encumbrance_item_id,ITEM.task_id, 'ENC') = 'N'
               AND EXISTS ( select null
                            from gms_award_distributions adl
                            where adl.expenditure_item_id = ITEM.encumbrance_item_id
                              and adl.document_type = 'ENC' -- Added the three conditions for bug 7225876
                              and adl.adl_status = 'A'
                              and adl.adl_line_num = 1
                              and adl.award_id = p_award_id )
             --bug 7225876  AND pa_utils2.Proj_Type_Burden_Disp_Method(ITEM.project_id) IN ('S','s','D','d')
               AND ITEM.ind_compiled_set_id > 0 -- bug 7225876
               AND 1 = decode(p_event, 'INSERT', 1
                                               , (select 1
                                                  from pa_ind_compiled_sets ics,
                                                       pa_ind_rate_sch_revisions irsr
                                                  where ITEM.ind_compiled_set_id = ics.ind_compiled_set_id
                                                    and ics.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id
                                                    and irsr.ind_rate_sch_id = p_ind_rate_sch_id
                                                    and rownum = 1));
             End if;

           elsif p_calling_form = 'GMSAWEAW' then -- call from award management compliance tab

             IF L_DEBUG = 'Y' THEN
                gms_error_pkg.gms_debug('Call is from award management screen', 'C');
             END IF;

             IF l_award_status <> 'CLOSED' AND l_close_date >= trunc (sysdate ) then

             UPDATE gms_encumbrance_items_all ITEM
             SET ITEM.enc_distributed_flag = 'N',
                 ITEM.adjustment_type = 'BURDEN_RECALC',
                 ITEM.ind_compiled_set_id = NULL,
                 ITEM.last_update_date = SYSDATE,
                 ITEM.last_updated_by = x_last_updated_by,
                 ITEM.last_update_login = x_last_update_login,
                 ITEM.request_id = x_request_id
             WHERE ITEM.enc_distributed_flag = 'Y'
               AND NVL(ITEM.net_zero_adjustment_flag,'N') <> 'Y'
               AND pa_project_stus_utils.Is_Project_Closed(ITEM.project_id) <>'Y' --BUG 7225876
               --BUG 6967150 AND gms_pa_api2.is_award_closed(ITEM.encumbrance_item_id,ITEM.task_id, 'ENC') = 'N'
               AND EXISTS ( select null
                            from gms_award_distributions adl
                            where adl.expenditure_item_id = ITEM.encumbrance_item_id
                              and adl.document_type = 'ENC' -- Added following three condition for bug 7225876
                              and adl.adl_status = 'A'
                              and adl.adl_line_num = 1
                              and adl.award_id = p_award_id )
               AND ITEM.ind_compiled_set_id >0 -- bug 7225876
               AND NOT EXISTS
                   ( select 1
                     from GMS_OVERRIDE_SCHEDULES GOS,
                          pa_tasks TASK
                     where GOS.award_id = p_award_id
                       and GOS.project_id = ITEM.project_id
                       and TASK.task_id = item.task_id
                       and nvl(GOS.task_id, TASK.top_task_id) = TASK.top_task_id);
             END IF;
               --BUG 7225876 AND pa_utils2.Proj_Type_Burden_Disp_Method(ITEM.project_id) IN ('S','s','D','d')

           end if;
        end if;
  exception
      when others then
               IF L_DEBUG = 'Y' THEN
                  gms_error_pkg.gms_debug('IN EXCEPTION BLOCK', 'C');
               END IF;
          errbuf := sqlcode;
          retcode := sqlerrm;
  end mark_enc_items_for_recalc;

      -- Bug 6761516
      -- =====================
      -- Start of the comment
      -- API Name 	: item_task_validate
      -- Type		: Public
      -- Pre_reqs	: None
      -- Description	: This function is called from mark_enc_items_for_recalc
      --                  to perform item validations.
      --                  1. If record being inserted/updated/deleted from overrides schedule
      --                     screen does not have task details, then this function returns 'N'
      --                     if any other override exists for same project, award ,top_task for
      --                     the task of enc. in picture combination, else returns 'Y'
      --                  2. If record being inserted/updated/deleted from overrides schedule
      --                     screen has task details, then just match the top task of the enc.
      --                     in picture with the task on the record.
      -- Parameters     : p_award_id number,
      --                  p_project_id number,
      --                  p_task_id number,
      --                  p_item_task_id number
      -- Return Value   : 'Y' - Encumbrance needs to be marked for recalc.
      --                  'N' - Encumbrance should not be marked for recalc.
      --
      -- End of comments
      -- ===============

function item_task_validate (p_award_id number,
                             p_project_id number,
                             p_task_id number,
                             p_item_task_id number)
 return varchar2 is

 l_test              number ;
 l_max_indx          number ;
 l_return              varchar2(1);

begin

    FOR indx in 1..g_task_id_tab.count loop
      if g_task_id_tab(indx) = p_item_task_id then
         gms_error_pkg.gms_debug('Results already available for task_id:' || g_task_id_tab(indx) || ',value:' || g_test_tab(indx), 'C');
         return g_test_tab(indx);
      end if;
    end loop;

    gms_error_pkg.gms_debug('First Call to task_id:' || p_item_task_id, 'C');
    if p_task_id is NULL then

       begin
         l_test := 0;
         select 1
         into l_test
         from GMS_OVERRIDE_SCHEDULES GOS,
              pa_tasks TASK
         where GOS.award_id = p_award_id
           and GOS.project_id = p_project_id
           and p_item_task_id = TASK.task_id
           and nvl(GOS.task_id,-99) = TASK.top_task_id
           and rownum = 1;
       exception
         when no_data_found then
            l_test := 0;
       end;

       l_max_indx := g_task_id_tab.count;
       g_task_id_tab(l_max_indx+1) := p_item_task_id;
       if l_test = 1 then
           -- as override match is found, these transactions should not be marked for recalc
           -- hence returning 'N'
           l_return := 'N';
       else
           -- as override match is not found, these transactions should be marked for recalc
           -- hence returning 'Y'
           l_return := 'Y';
       end if;
       g_test_tab(l_max_indx+1) := l_return;
       return(l_return);

    else -- p_task id is not null

       begin
         l_test := 0;
         select 1
         into l_test
         from pa_tasks
         where task_id = p_item_task_id
           and top_task_id = p_task_id;
       exception
         when no_data_found then
            l_test := 0;
       end;

       l_max_indx := g_task_id_tab.count;
       g_task_id_tab(l_max_indx+1) := p_item_task_id;
       if l_test = 1 then
          -- as enc task_id matches with p_task_id, these transactions should be marked for recalc
          -- hence returning 'Y'
           l_return := 'Y';
       else
          -- as enc task_id does not match with p_task_id, these transactions should not be marked for recalc
          -- hence returning 'N'
           l_return := 'N';
       end if;
       g_test_tab(l_max_indx+1) := l_return;
       return(l_return);

    end if;

end item_task_validate;
/* Bug 6761516 end */

END gms_pa_api3;

/
