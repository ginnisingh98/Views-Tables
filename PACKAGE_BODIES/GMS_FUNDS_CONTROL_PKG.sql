--------------------------------------------------------
--  DDL for Package Body GMS_FUNDS_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_FUNDS_CONTROL_PKG" AS
-- $Header: gmsfcfcb.pls 120.45.12010000.4 2009/08/20 11:44:44 sgottimu ship $

  -- Private Global Variables :

    -- Variables initialized in gms_fck:
        g_packet_id              gms_bc_packets.packet_id%type;
        g_mode                   Varchar2(1);
        g_debug                  Varchar2(1); -- To check on, whether to print debug messages in log file or not
        g_error_program_name     Varchar2 (30);
        g_error_procedure_name   Varchar2 (30);
        g_error_stage            Varchar2 (50); -- Bug 5344693 : Increased the size of this variable.

    -- Variables initialized in gms_fck_init:
        g_derived_mode              Varchar2(1);
        g_partial_flag              Varchar2(1);
        g_doc_type                  gms_bc_packets.document_type%type;
	g_non_gms_txn 	            BOOLEAN;
        g_bc_packet_has_P82_records Varchar2(1); -- Used in handle_net_zero_txn/update_fc_sequence
        g_ip_fc_flag	            VARCHAR2(1); -- If FC called for IP or not ..
        g_gl_bc_pkt_sponsored_count NUMBER;      -- Count of sponsored transactions in gl_bc_packets(AP/PO/REQ)
        g_pa_addition_flag_t_count  NUMBER;      -- Count of sponsored AP records with pa_addition_flag = 'T'

  -- Funds Check Return Code for the Packet processed.
	g_return_code		gms_bc_packets.result_code%TYPE;

      -- R12 Funds Management uptake : Defining global variables which are reffered by
      -- copy_gl_pkt_to_gms_pkt and misc_sync_adls procedures
      -- PLSQL type of variables for storing transaction data

      g_set_of_books_id_tab       t_set_of_books_id_type;
      g_je_source_name_tab        t_je_source_name_type;
      g_je_category_name_tab      t_je_category_name_type;
      g_actual_flag_tab           t_actual_flag_type;
      g_project_id_tab            t_project_id_type;
      g_task_id_tab               t_task_id_type;
      g_award_id_tab              t_award_id_type;
      g_result_code_tab           t_result_code_type;
      /* Bug 5614467 : g_entered_dr_tab and g_entered_cr_tab are populated with accounted amounts.
                       g_txn_dr_tab and g_txn_cr_tab are populated with entered amounts. */
      g_entered_dr_tab            t_entered_dr_type;
      g_entered_cr_tab            t_entered_cr_type;
      g_txn_dr_tab                t_entered_dr_type;
      g_txn_cr_tab                t_entered_cr_type;
      g_po_rate_tab               t_po_rate_type; -- Bug 5614467
      g_etype_tab                 t_etype_type;
      g_exp_org_id_tab            t_exp_org_id_type;
      g_exp_item_date_tab         t_exp_item_date_type;
      g_document_type_tab         t_document_type_type;
      g_doc_header_id_tab         t_doc_header_id_type;
      g_doc_dist_id_tab           t_doc_dist_id_type;
      g_vendor_id_tab             t_vendor_id_type;
      g_exp_category_tab          t_exp_category_type;
      g_revenue_category_tab      t_revenue_category_type;
      g_ind_cmp_set_id_tab        t_ind_cmp_set_id_type;
      g_burdenable_raw_cost_tab   t_brc_type; --R12 AP Lines Uptake enhancement : Forward porting bug 4450291
      g_parent_reversal_id_tab    t_parent_reversal_id_type; -- Bug 5369296
      g_doc_dist_line_num_tab     t_doc_dist_line_num_type;
      g_invoice_type_code_tab     t_invoice_type_code_type;
      g_inv_source_tab            t_inv_source_type;
      g_inv_dist_reference_1_tab  t_doc_dist_id_type;
      g_inv_dist_reference_2_tab  t_doc_dist_line_num_type;
      g_source_event_id_tab       t_source_event_id_type;
      g_entered_amount_tab        t_entered_dr_type;
      g_event_type_code_tab       t_event_type_code_type;
      g_main_or_backing_tab       t_main_or_backing_type;
      g_reference6_tab            t_reference6_type;
      g_reference13_tab           t_reference13_type;

      g_ap_inv_dist_id            T_PROJ_BC_AP_DIST := T_PROJ_BC_AP_DIST(); -- variable of nested table type
      g_ap_line_type_lkup         t_invoice_type_code_type;
      g_prepay_std_inv_dist_id    t_doc_dist_id_type;
      g_quantity_variance_tab     t_entered_dr_type;
      g_amount_variance_tab       t_entered_dr_type;
      g_po_distribution_id_tab    t_doc_dist_id_type;
      g_po_header_id_tab          t_doc_dist_id_type;
      g_po_release_id_tab         t_doc_dist_id_type;

      g_ap_prepay_app_dist_id     t_doc_dist_line_num_type;

----------------------------------------------------------------------------------------------------------
-- Variables for error handling .

   g_budget_version_id		NUMBER; -- Bug 2092791 (This is used in setup_start_end_date Logic)
   g_gb_end_date		DATE ;	-- Bug 2092791 (This is used in setup_start_end_date Logic)
   g_exp_date		        DATE ;  -- Bug 2092791 (This is used in setup_start_end_date Logic)

   -- Bug : 2557041 - Added for IP check funds Enhancement
   -- gms_fck_init derives values for the following variables ...

/* -----------------------------------------------------------------------------------------------
   Function  : sponsored_project
   Purpose   : Returns 'Y' if project parameter passed is sponsored, else returns 'N'
-------------------------------------------------------------------------------------------------- */
FUNCTION sponsored_project(p_project_id IN NUMBER)
RETURN VARCHAR2 IS
x_sponsored_flag varchar2(1);
BEGIN
 Select nvl(gpt.sponsored_flag,'N')
 into   x_sponsored_flag
 from   gms_project_types gpt,
        pa_projects_all   pp
 where  pp.project_id    = p_project_id
 and    gpt.project_type = pp.project_type;
 RETURN x_sponsored_flag;
END sponsored_project;

/* -----------------------------------------------------------------------------------------------
   Procedure : lock_budget_versions (Bug 4053891)
   Purpose   : - This procedure will lock the budget version records for the budget versions
                 in the packet being funds checked.
               - Fired only for REQ/PO/AP/FAB/Interface.
               - This was reqd. to enforce incompatibility between sweeper and FC
                 for REQ/PO/AP/FAB/Interface.
-------------------------------------------------------------------------------------------------- */
Procedure Lock_budget_versions(p_packet_id number) is
Cursor c_lock_bvid is
       select budget_version_id
       from  gms_budget_versions
       where budget_version_id in
       (select budget_version_id from  gms_bc_packets_bvid)
       for update;
Begin
for x in  c_lock_bvid loop
    null; -- Dummy code to lock gms_budget_versions
end loop;
End Lock_budget_versions;

/* -----------------------------------------------------------------------------------------------
   Procedure : update_status_on_failed_txns
   Purpose   : Update status code on failed transactions. Used for expenditure items.

-------------------------------------------------------------------------------------------------- */

  Procedure update_status_on_failed_txns(p_packet_id IN Number)
  IS
  BEGIN

   g_error_procedure_name := 'update_status_on_failed_txns';

   UPDATE gms_bc_packets
      SET status_code = 'R'
    WHERE packet_id = p_packet_id
      AND result_code like 'F%';

  END update_status_on_failed_txns;

/* -----------------------------------------------------------------------------------------------
   Procedure : delete_pending_txns
   Purpose   : This procedure will delete pending records in gms_bc_packets associated with a
               request that has been terminated.
               After deleting the records from gms_bc_packets, corresponding request_id entry will
               be deleted from gms_concurrency_control table.
-------------------------------------------------------------------------------------------------- */

Procedure delete_pending_txns
(x_err_code                 OUT NOCOPY      NUMBER,
 x_err_buff                 OUT NOCOPY      VARCHAR2 ) IS

 RESOURCE_BUSY EXCEPTION;
 PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -00054);

 l_request_id    	NUMBER;
 l_phase_code       fnd_concurrent_requests.phase_code%type;

 Cursor c_pending_request_id is
        select request_id
        from   gms_concurrency_control
        where  request_id <> nvl(l_request_id,-1)
        and    process_name = 'GMSFCSYS';
Begin

  g_error_procedure_name := 'delete_pending_txns';
  g_error_stage := ':Start';

  l_request_id  := fnd_global.conc_request_id;

  IF g_debug = 'Y' THEN
     gms_error_pkg.gms_debug (g_error_procedure_name||g_error_stage,'C');
  END IF;

 For c_request_id in c_pending_request_id
 Loop
    -- A. Get the phase code of the concurrent request
    g_error_stage := ':Derive phase';

    Begin
       select phase_code
       into   l_phase_code
       from   fnd_concurrent_requests
       where  request_id =  c_request_id.request_id;
    Exception
       When no_data_found then
            -- requests were purged ..
            l_phase_code := 'C';
     End;

    IF g_debug = 'Y' THEN
     gms_error_pkg.gms_debug (g_error_procedure_name||g_error_stage||' - request_id,phase_code:'||
                                c_request_id.request_id||','||l_phase_code,'C');
    END IF;

     -- Phase Code 'C' indicates that the process has been completed
    If l_phase_code = 'C' then

         -- C. Update gms_bc_packet status to 'T'
         Update gms_bc_packets
         set    status_code = 'T',
                fc_error_message = 'Packet had terminated,status updated to (T) by document_type,request_id:'||l_request_id||g_doc_type
         where  request_id  = c_request_id.request_id
         and    status_code = 'P';

         -- D. Delete concurrency record ..
         Delete
         from  gms_concurrency_control
         where  request_id  = c_request_id.request_id;

   End If; --   If l_phase_code = 'C' then

      l_phase_code := null;
      COMMIT;
 End loop;

  g_error_stage := ':End';

  IF g_debug = 'Y' THEN
     gms_error_pkg.gms_debug (g_error_procedure_name||g_error_stage,'C');
  END IF;

Exception
  -- Handling exception, as any failure to this procedure need not fail the calling process
  -- It's upto the calling process to pass or fail the Main code flow ..
  When Others then
      x_err_code := SQLCODE;
      x_err_buff := SQLERRM;
End delete_pending_txns;

/* ---------------------------------------------------------------------------------------
   PROCEDURE RAW_BURDEN_FAILURE : This procedure will fail
                                  raw transaction if burden failed: F75
                                  burden transaction if raw failed: F63
   !!!! Note: Burden_adjustment entries will be treated as burden of original transaction.

   Parameters: p_packet_id : packet_id of the batch being FC'ed
               p_mode      : Mode in which FC is being carried out (Use g_derived_mode)
               p_level     : Funds Check level from which it is being called
                             'AWD'  : Award,
                             'TTSK' : Top Task,
			     'TSK'  : Task,
                             'RESG' : Resource Group,
			     'RES'  : Resource and
                             'ALL'  : From Check funds etc ..
-------------------------------------------------------------------------------------------*/
PROCEDURE Raw_burden_failure(p_packet_id IN NUMBER, p_mode in VARCHAR2,p_level in VARCHAR2) IS
BEGIN
 g_error_procedure_name := 'RAW_BURDEN_FAILURE';
 -- F75 : Transaction Failed because of Raw
 /*    Update gms_bc_packets bp  Commented for bug 5726575; Moved below the update below next update
       set bp.status_code          = decode(p_mode,'C','F','R'),
           bp.result_code          = decode(substr(bp.result_code,1,1),'P','F75',null,'F75',bp.result_code),
	   bp.fc_error_message     = decode(bp.fc_error_message,NULL,'RAW_BURDEN_FAILURE at stage:'||p_level,bp.fc_error_message)
     where bp.packet_id            = p_packet_id
       and bp.status_code          = 'P'
       and ((p_level = 'RES'  and substr(bp.res_result_code,1,1)     = 'P') or
            (p_level = 'RESG' and substr(bp.res_grp_result_code,1,1) = 'P') or
            (p_level = 'TSK'  and substr(bp.task_result_code,1,1)    = 'P') or
            (p_level = 'TTSK' and substr(bp.top_task_result_code,1,1)= 'P') or
            (p_level = 'AWD'  and substr(bp.award_result_code,1,1)   = 'P') or
            (p_level = 'ALL'  and substr(nvl(bp.result_code,'P'),1,1)         = 'P')
            )
       and bp.parent_bc_packet_id IS NOT NULL
       and exists
           (select 1
            from   gms_bc_packets bp1
            where  bp1.packet_id    = bp.packet_id
            and    bp1.bc_packet_id = bp.parent_bc_packet_id   -- GMS_BC_PACKETS_U1
            and ((p_level = 'RES'  and substr(bp1.res_result_code,1,1)     = 'F') or
                 (p_level = 'RESG' and substr(bp1.res_grp_result_code,1,1) = 'F') or
                 (p_level = 'TSK'  and substr(bp1.task_result_code,1,1)    = 'F') or
                 (p_level = 'TTSK' and substr(bp1.top_task_result_code,1,1)= 'F') or
                 (p_level = 'AWD'  and substr(bp1.award_result_code,1,1)   = 'F') or
                 (p_level = 'ALL'  and substr(nvl(bp1.result_code,'P'),1,1)         = 'F')
                 )
            );*/
        -- Records that has failed will not have status_code update to 'R' at this stage ..
        -- Only way to check in main cursor is result_code 'P' ..

    -- F63 : Transaction Failed because of Burden
     Update gms_bc_packets bp
       set bp.status_code          = decode(p_mode,'C','F','R'),
           bp.result_code          = decode(substr(bp.result_code,1,1),'P','F63',null,'F63',bp.result_code),
	   bp.fc_error_message     = decode(bp.fc_error_message,NULL,'RAW_BURDEN_FAILURE at stage:'||p_level,bp.fc_error_message)
     where bp.packet_id            = p_packet_id
       and bp.status_code          = 'P'
       and ((p_level = 'RES'  and substr(bp.res_result_code,1,1)     = 'P') or
            (p_level = 'RESG' and substr(bp.res_grp_result_code,1,1) = 'P') or
            (p_level = 'TSK'  and substr(bp.task_result_code,1,1)    = 'P') or
            (p_level = 'TTSK' and substr(bp.top_task_result_code,1,1)= 'P') or
            (p_level = 'AWD'  and substr(bp.award_result_code,1,1)   = 'P') or
            (p_level = 'ALL'  and substr(nvl(bp.result_code,'P'),1,1)         = 'P')
            )
       and bp.parent_bc_packet_id IS NULL
       and exists
           (select 1
            from   gms_bc_packets bp1
            where  bp1.packet_id           = bp.packet_id
            and    bp1.parent_bc_packet_id = bp.bc_packet_id   -- GMS_BC_PACKETS_N3
            and ((p_level = 'RES'  and substr(bp1.res_result_code,1,1)     = 'F') or
                 (p_level = 'RESG' and substr(bp1.res_grp_result_code,1,1) = 'F') or
                 (p_level = 'TSK'  and substr(bp1.task_result_code,1,1)    = 'F') or
                 (p_level = 'TTSK' and substr(bp1.top_task_result_code,1,1)= 'F') or
                 (p_level = 'AWD'  and substr(bp1.award_result_code,1,1)   = 'F') or
                 (p_level = 'ALL'  and substr(nvl(bp1.result_code,'P'),1,1)         = 'F')
                 )
            );
        -- Records that has failed will not have status_code update to 'R' at this stage ..
        -- Only way to check in main cursor is result_code 'P' ..
     --Bug 5726575
     Update gms_bc_packets bp
       set bp.status_code          = decode(p_mode,'C','F','R'),
           bp.result_code          = decode(substr(bp.result_code,1,1),'P','F75',null,'F75',bp.result_code),
	   bp.fc_error_message     = decode(bp.fc_error_message,NULL,'RAW_BURDEN_FAILURE at stage:'||p_level,bp.fc_error_message)
     where bp.packet_id            = p_packet_id
       and bp.status_code          = 'P'
       and ((p_level = 'RES'  and substr(bp.res_result_code,1,1)     = 'P') or
            (p_level = 'RESG' and substr(bp.res_grp_result_code,1,1) = 'P') or
            (p_level = 'TSK'  and substr(bp.task_result_code,1,1)    = 'P') or
            (p_level = 'TTSK' and substr(bp.top_task_result_code,1,1)= 'P') or
            (p_level = 'AWD'  and substr(bp.award_result_code,1,1)   = 'P') or
            (p_level = 'ALL'  and substr(bp.result_code,1,1)         = 'P')
            )
       and bp.parent_bc_packet_id IS NOT NULL
       and exists
           (select 1
            from   gms_bc_packets bp1
            where  bp1.packet_id    = bp.packet_id
            and    bp1.bc_packet_id = bp.parent_bc_packet_id   -- GMS_BC_PACKETS_U1
            and    substr(bp1.result_code,1,1) = 'F'
            /*and ((p_level = 'RES'  and substr(bp1.res_result_code,1,1)     = 'F') or
                 (p_level = 'RESG' and substr(bp1.res_grp_result_code,1,1) = 'F') or
                 (p_level = 'TSK'  and substr(bp1.task_result_code,1,1)    = 'F') or
                 (p_level = 'TTSK' and substr(bp1.top_task_result_code,1,1)= 'F') or
                 (p_level = 'AWD'  and substr(bp1.award_result_code,1,1)   = 'F') or
                 (p_level = 'ALL'  and substr(bp1.result_code,1,1)         = 'F')
                 )*/
            );

END Raw_burden_failure;

/* ===========================================================================
   FUNCTION FULL_MODE_FAILURE:
   This function will take of following failures (F65):
   1. Full mode failures
   2. Fail all cdl if one cdl failed for EXP
   3. Fail all burden if one burden failed
   Parameters: p_packet_id : packet_id of the batch being FC'ed
               p_mode      : Mode in which FC is being carried out (use g_mode)
               p_level     : Funds Check level from which it is being called
                             'AWD'  : Award,
                             'TTSK' : Top Task,
                             'TSK'  : Task,
                             'RESG' : Resource Group,
                             'RES'  : Resource and
                             'ALL'  : From Check funds etc ..
  ============================================================================ */
FUNCTION Full_mode_failure(p_packet_id in NUMBER, p_mode in VARCHAR2,p_level in VARCHAR2)
RETURN BOOLEAN IS
 l_dummy number;
Begin
  g_error_procedure_name := 'FULL_MODE_FAILURE';

  If g_partial_flag = 'N' then

  -- If p_mode in ('R','U','C','I') then
    -- Full mode
  Begin
   Select 1
     into l_dummy
     from dual
    where exists
    (select 1 from gms_bc_packets bp1
      where bp1.packet_id = p_packet_id
        and (bp1.status_code in ('R','F') or
             (p_level = 'RES'  and substr(bp1.res_result_code,1,1)     = 'F') or
             (p_level = 'RESG' and substr(bp1.res_grp_result_code,1,1) = 'F') or
             (p_level = 'TSK'  and substr(bp1.task_result_code,1,1)    = 'F') or
             (p_level = 'TTSK' and substr(bp1.top_task_result_code,1,1)= 'F') or
             (p_level = 'AWD'  and substr(bp1.award_result_code,1,1)   = 'F') --or
             --(p_level = 'ALL'  and substr(bp1.result_code,1,1)         = 'F')
             )
     );

     Update gms_bc_packets bp
       set bp.status_code       = decode(p_mode,'C','F','R'),
           bp.result_code       = decode(substr(bp.result_code,1,1),'P','F65',null,'F65',bp.result_code),
	   bp.fc_error_message  = decode(bp.fc_error_message,NULL,'FULL_MODE_FAILURE (R/U/C/I mode) at stage:'||p_level,bp.fc_error_message)
     where packet_id            = p_packet_id
     and   status_code          = 'P';

     RETURN TRUE;
  Exception
     When no_data_found then
          RETURN FALSE;
  End;

 Else  -- (Partial mode)
-- Related invoice failure
 -- If any distribution ITEM/TAX/Variance fails .. all related records should
 -- fail. So, what about related PO?? That is handled below in the partial mode
 -- if..end if. code

 If p_level in ('AWD','ALL') then

     IF g_debug = 'Y' THEN
        gms_error_pkg.gms_debug ('Check for related invoice failure', 'C');
      END IF;

    l_dummy := 0;
    Begin
     select 1
     into   l_dummy
     from   dual
     where  exists (select 1
                    from   gms_bc_packets
                    where  packet_id     = p_packet_id
                    and    document_type = 'AP'
                    and    substr(result_code,1,1) = 'F');
    Exception
      When no_data_found then
           null;
    End;

     IF g_debug = 'Y' THEN
        gms_error_pkg.gms_debug ('Check for related invoice failure, if exists then l_dummy = 1): l_dummy::'||l_dummy, 'C');
      END IF;


    If l_dummy = 1 then
        update gms_bc_packets
        set    result_code = 'F65',
               fc_error_message = decode(fc_error_message,NULL,'FULL_MODE_FAILURE (Related invoice distribution failed) '||p_level,fc_error_message)
        where  packet_id = p_packet_id
        and    substr(result_code,1,1) = 'P'
        and    (document_header_id,document_distribution_id) in
               ( select distinct b.invoice_id,b.invoice_distribution_id
                  from ap_invoice_distributions_all  a,
                       ap_invoice_distributions_all  b
                  where (a.invoice_id,a.invoice_distribution_id) in
                        (select document_header_id,
                                document_distribution_id
                           from gms_bc_packets gbc
                          where gbc.packet_id = p_packet_id
                            and  substr(gbc.result_code,1,1) = 'F'
                            and  gbc.document_type = 'AP'
                            and  gbc.parent_bc_packet_id is null)
                            and  b.invoice_id = a.invoice_id
                   and  COALESCE(b.charge_applicable_to_dist_id,b.related_id,b.invoice_distribution_id) =
                        COALESCE(a.charge_applicable_to_dist_id,a.related_id,a.invoice_distribution_id));

     IF g_debug = 'Y' THEN
        gms_error_pkg.gms_debug (SQL%rowcount||' records updated','C');
      END IF;

    End If;

 End If; --related invoice failure ..

   -- This section will deal with 2 checks:
   -- 1. Fail all burden if one burden failed (EXP/ENC) and also (AP/PO/REQ in partial mode)
   --    This also takes care of burden adjsutment records failing ..
   -- 2. Fail all cdls if one cdl failed for an EXP


     -- 1. Fail all burden if one burden failed (EXP/ENC) and also (AP/PO/REQ in partial mode)
     --    This also takes care of burden adjsutment records failing ..
     -- e.g.:  bc_packet parent_bc_packet exp.type  status
     --            2         1            Overhead   P
     --            3         1            Fringe     F
     -- In this case, we need to fail 2..

   --If p_mode in ('X','E') then

    /* Bug 5250793 : Added code such that if an AP Invoice distribution fails fundscheck then the PO matched to that AP also fails
                     with full mode failure. */
     Update gms_bc_packets bp
     set bp.status_code = decode(p_mode,'C','F','R'),
         bp.result_code = decode(substr(bp.result_code,1,1),'P','F65',null,'F65',bp.result_code),
         bp.fc_error_message = decode(bp.fc_error_message,NULL,'FULL_MODE_FAILURE (X/E/R/U/C mode, INV matched to PO has failed) at stage:'||p_level,bp.fc_error_message)
     where bp.document_type  = 'PO'
     and   bp.packet_id      = p_packet_id
     and   bp.status_code    = 'P'
     and   bp.document_distribution_id in ( select distinct apid.po_distribution_id
						 from  gms_bc_packets bp1,
						       ap_invoice_distributions_all apid
						 where bp1.packet_id = p_packet_id
						 and  bp1.document_type = 'AP'
						 and  bp1.document_distribution_id = apid.invoice_distribution_id
						 and  substr(bp1.result_code,1,1) = 'F'
						 and  apid.po_distribution_id IS NOT NULL ) ;


     Update gms_bc_packets bp
       set bp.status_code          = decode(p_mode,'C','F','R'),
           bp.result_code          = decode(substr(bp.result_code,1,1),'P','F65',null,'F65',bp.result_code),
	   bp.fc_error_message     = decode(bp.fc_error_message,NULL,'FULL_MODE_FAILURE (X/E/R/U/C mode, one of the burden failed) at stage:'||p_level,bp.fc_error_message)
     where bp.packet_id            = p_packet_id
       and bp.status_code          = 'P'
       and bp.document_type        in ('EXP','ENC','AP','PO','REQ')
       and bp.parent_bc_packet_id is NOT NULL
       and exists (select 1
                   from   gms_bc_packets bp1
                   where  bp1.packet_id = bp.packet_id				/* Changed the order for Bug 6043224 */
                   and    bp1.parent_bc_packet_id = bp.parent_bc_packet_id
                   and    bp1.bc_packet_id <> bp.bc_packet_id			/* Uncommented for Bug 6043224 */
                   and    bp1.document_type = bp.document_type			/* Uncommented for Bug 6043224 */
		   and    bp1.parent_bc_packet_id is NOT NULL
                   and    bp1.document_header_id = bp.document_header_id 	/* Added for Bug 6043224 */
                   and    bp1.document_distribution_id = bp.document_distribution_id /* Added for Bug 6043224 */
                   and ((p_level = 'RES'  and substr(bp1.res_result_code,1,1)     = 'F') or
                        (p_level = 'RESG' and substr(bp1.res_grp_result_code,1,1) = 'F') or
                        (p_level = 'TSK'  and substr(bp1.task_result_code,1,1)    = 'F') or
                        (p_level = 'TTSK' and substr(bp1.top_task_result_code,1,1)= 'F') or
                        (p_level = 'AWD'  and substr(bp1.award_result_code,1,1)   = 'F') or
                        (p_level = 'ALL'  and substr(bp1.result_code,1,1)         = 'F')
                       )
                 );

   -- End If;

   -- 2. Fail all cdls if one cdl failed for an EXP

   If p_mode = 'X' then

     Update gms_bc_packets bp
       set bp.status_code          = decode(p_mode,'C','F','R'),
           bp.result_code          = decode(substr(bp.result_code,1,1),'P','F65',null,'F65',bp.result_code),
	   bp.fc_error_message     = decode(bp.fc_error_message,NULL,'FULL_MODE_FAILURE (X mode - one of the CDL failed) at stage:'||p_level,bp.fc_error_message)
     where bp.packet_id            = p_packet_id
       and bp.status_code          = 'P'
       and bp.document_type        = 'EXP'
       and exists (select 1
                   from   gms_bc_packets bp1
                   where  bp1.packet_id = bp.packet_id
                   and    bp1.document_header_id = bp.document_header_id
                   and    bp1.document_distribution_id <> bp.document_distribution_id
                   and    bp1.document_type = bp.document_type
                   and ((p_level = 'RES'  and substr(bp1.res_result_code,1,1)     = 'F') or
                        (p_level = 'RESG' and substr(bp1.res_grp_result_code,1,1) = 'F') or
                        (p_level = 'TSK'  and substr(bp1.task_result_code,1,1)    = 'F') or
                        (p_level = 'TTSK' and substr(bp1.top_task_result_code,1,1)= 'F') or
                        (p_level = 'AWD'  and substr(bp1.award_result_code,1,1)   = 'F') or
                        (p_level = 'ALL'  and substr(bp1.result_code,1,1)         = 'F')
                       )
                 );
   End if; --If p_mode = 'X'

     RETURN TRUE;

 End If; -- partial flag check

     RETURN TRUE; -- This has been put if the mode comes as something unexpected ..

End Full_mode_failure;

/* -------------------------------------------------------------------------------
   This procedure will be used to validate adjusting/adjusted transactions. Procedure has
    a parameter p_mode. This parameter can have 2 values: 'Check_Adjusted' and 'Net_Zero'

   Check_Adjusted Mode : In this mode, we will check for adjusting transactions in the
                         packet whose adjusted transaction has not been funds checked.
                         We will fail such transactions with   'F08'.

   Net_Zero_mode       : In this mode, we will check whether adjsuted and adjusting
                         transactions are present in the same packet. If so, update the
                         transactions result_code with 'P82' and effect_on_funds_code to
                         'I'. This will ensure that 'Funds Available' calculations are
                         not carried out for these transactions.
-------------------------------------------------------------------------------------------*/

Procedure Handle_net_zero_txn(p_packetid IN number, p_mode IN varchar2 ) is

 -- R12 Funds management uptake
 PRAGMA AUTONOMOUS_TRANSACTION;

Cursor c_txn is
    select adjusted_document_header_id,
           nvl(ind_compiled_set_id,-1) ind_compiled_set_id
    from   gms_bc_packets
    where  packet_id = p_packetid
     and   document_type = 'ENC'
    having sum(entered_dr-entered_cr) = 0
    group by  adjusted_document_header_id,
                    nvl(ind_compiled_set_id,-1);
Begin
      g_error_procedure_name := 'Handle_net_zero_txn' ;
      g_error_stage := 'Net Zero - ENC';

      	gms_error_pkg.gms_debug ( 'Handle_net_zero_txn : Start','C');
      	gms_error_pkg.gms_debug ( 'p_mode : '||p_mode,'C');

If p_mode = 'Check_Adjusted' then
   -- Fail adjusting txn. If adjusted has not been funds checked -F08
   update gms_bc_packets gbc
     set    gbc.result_code = 'F08',
	    gbc.award_result_code = 'F08',
	    gbc.top_task_result_code = 'F08',
	    gbc.task_result_code = 'F08',
	    gbc.res_grp_result_code = 'F08',
	    gbc.res_result_code = 'F08',
            gbc.status_code = 'R'
   where  gbc.packet_id = p_packetid
     and  gbc.document_type = 'ENC'
     and  nvl(gbc.result_code,'XX') <> 'P82'
     and  gbc.adjusted_document_header_id is NOT NULL
     and  gbc. adjusted_document_header_id <> gbc.document_header_id
     and  exists
            (select 1
             from   gms_encumbrance_items gei
             where  gei.encumbrance_item_id =   gbc.adjusted_document_header_id
             and    nvl(gei.enc_distributed_flag,'N') = 'N'
             and    nvl(request_id,-1)  <>  gbc.request_id
             ) ;
Elsif p_mode = 'Net_Zero' then
 -- Adjusted and adjusting in same packet
for recs in c_txn
 loop

     update gms_bc_packets gbc
     set    gbc.result_code = 'P82',
 	    gbc.award_result_code = 'P82',
	    gbc.top_task_result_code = 'P82',
	    gbc.task_result_code = 'P82',
	    gbc.res_grp_result_code = 'P82',
	    gbc.res_result_code = 'P82',
            gbc.effect_on_funds_code = 'I'
     where  gbc.packet_id = p_packetid
     and    gbc.adjusted_document_header_id = recs.adjusted_document_header_id
     and    nvl(ind_compiled_set_id,-1) =  recs.ind_compiled_set_id;

    g_bc_packet_has_P82_records := 'Y' ;
end loop;
      	gms_error_pkg.gms_debug ( 'Handle_net_zero_txn : End','C');

End If;

COMMIT;

End Handle_net_zero_txn;

-- This procedure will calculate the ind_compiled_set_id for encumbrances
Procedure Calc_enc_ind_compiled_set_id(p_packet_id IN number) IS

 -- R12 Funds management uptake
 PRAGMA AUTONOMOUS_TRANSACTION;

 TYPE t_project_id_type IS TABLE OF gms_bc_packets.project_id%type;
 TYPE t_award_id_type   IS TABLE OF gms_bc_packets.award_id%type;
 TYPE t_task_id_type    IS TABLE OF gms_bc_packets.task_id%type;
 TYPE t_exp_date_type   IS TABLE OF gms_bc_packets.expenditure_item_date%type;
 TYPE t_exp_type_type   IS TABLE OF gms_bc_packets.expenditure_type%type;
 TYPE t_exp_org_type    IS TABLE OF gms_bc_packets.expenditure_organization_id%type;
 TYPE t_ind_set_type    IS TABLE OF gms_bc_packets.ind_compiled_set_id%type;

 t_project_id t_project_id_type;
 t_award_id   t_award_id_type;
 t_task_id    t_task_id_type;
 t_exp_date   t_exp_date_type;
 t_exp_type   t_exp_type_type;
 t_exp_org    t_exp_org_type;
 t_ind_set    t_ind_set_type;

Begin
      	gms_error_pkg.gms_debug ( 'Calc_enc_ind_compiled_set_id : Start','C');

  -- This part of the code will take care of non-net zero encumbrance items or
  -- the original (adjusted) net zero item

      g_error_procedure_name := 'calc_enc_ind_compiled_set_id' ;
      g_error_stage := 'UPD IND SET: BLK COLL';

 select distinct  gbc.project_id,
                  gbc.award_id,
                  gbc.task_id,
                  gbc.expenditure_item_date,
                  gbc.expenditure_type,
                  gbc.expenditure_organization_id,
                  null
 BULK COLLECT into t_project_id,
                   t_award_id,
                   t_task_id,
                   t_exp_date,
                   t_exp_type,
                   t_exp_org,
                   t_ind_set
  from  gms_bc_packets gbc
  where gbc.packet_id   = p_packet_id
  and   gbc.status_code = 'P'
  and   gbc.ind_compiled_set_id is null
  and   nvl(gbc.burden_adjustment_flag,'N') = 'N' -- 3389292
  and   (gbc.adjusted_document_header_id is NULL OR
         gbc.adjusted_document_header_id = gbc.document_header_id);

      If t_project_id.COUNT > 0 then

      g_error_stage := 'UPD IND SET: COMPUTE';

    	FOR i IN t_project_id.FIRST .. t_project_id.LAST
	LOOP
             t_ind_set(i) := gms_cost_plus_extn.get_award_cmt_compiled_set_id (
                                         t_task_id(i),
                                         t_exp_date(i),
                                         t_exp_type(i),
                                         t_exp_org(i),
                                         'C',
                                         t_award_id(i));
			END LOOP;

      g_error_stage := 'UPD FC SEQ: FOR ALL';
      /* Bug#7034365 :Modified this update to pick up ind_compiled_set_id from gms_award_distributions
 	 so as to ensure that we relieve burden component same as it was reserved for a PO/AP/REQ transaction
      */

         FORALL j IN t_project_id.FIRST .. t_project_id.LAST
           Update /*+ index(gbc GMS_BC_PACKETS_N1) */ gms_bc_packets gbc  /*Added hint for bug 5683910 */
           set   ind_compiled_Set_id         = (nvl((select ind_compiled_set_id  from gms_award_distributions
                                      where document_type = gbc.document_type
                                      and ((document_type = 'AP' and
                                      invoice_id = gbc.document_header_id and
                                      distribution_line_number = gbc.document_distribution_id) OR
                                      (document_type = 'PO' and
                                      po_distribution_id = gbc.document_distribution_id) OR
     	                              (document_type = 'REQ' and
 	                              distribution_id = gbc.document_distribution_id))
 	                              and burdenable_raw_cost<>0
 	                              ),t_ind_set(j))
 	                              )
           where packet_id                   = p_packet_id
           and   project_id                  = t_project_id(j)
           and   award_id                    = t_award_id(j)
           and   task_id                     = t_task_id(j)
           and   expenditure_item_date       = t_exp_date(j)
           and   expenditure_type            = t_exp_type(j)
           and   expenditure_organization_id = t_exp_org(j)
           and   status_code = 'P' --Bug 5726575
           and   ind_compiled_set_id is null --Bug 5726575
           and   nvl(burden_adjustment_flag,'N') = 'N' --Bug 5726575
           and   (adjusted_document_header_id is NULL OR  --Bug 5122879
                  adjusted_document_header_id = document_header_id);

      End If; --If t_project_id.COUNT > 0 then

      	gms_error_pkg.gms_debug ( 'After Bulk processing','C');
  -- =============================================================
  -- This part of the code will take care of the reversing (adjusting) net zero item
  -- =============================================================

  -- Update 1 : For Adjusting (Reversing) transactions whose  original transaction
  --            is in the same packet

  Update gms_bc_packets gbc
  set    gbc.ind_compiled_Set_id = (Select gbc1.ind_compiled_set_id
                                    from   gms_bc_packets gbc1
                                    where  gbc1.packet_id          =  p_packet_id
                                    and    gbc1.document_header_id =  gbc.adjusted_document_header_id
                                    /* bug 6414366 start */
                                    and gbc1.document_distribution_id =
                                            (select max(gbc2.document_distribution_id)
                                             from gms_bc_packets gbc2
                                             where gbc2.packet_id = p_packet_id
                                             and   gbc2.document_header_id = gbc.adjusted_document_header_id))
                                    /* bug 6414366 end */
   where  gbc.packet_id   = p_packet_id
   and    gbc.status_code = 'P'
   --and    gbc.result_code = 'P82'
   and    gbc.ind_compiled_set_id is null
   and    gbc.adjusted_document_header_id is not NULL
  and   nvl(gbc.burden_adjustment_flag,'N') = 'N' -- 3389292
   and    gbc.adjusted_document_header_id <> gbc.document_header_id;

      	gms_error_pkg.gms_debug ( 'After Update 1','C');
-- Bug#6075039 Modified the sub query for performance issue.
  -- Update 2 : For Adjusting (Reversing) transactions whose  original transaction
  --            was funds checked earlier
  Update gms_bc_packets gbc
  set    gbc.ind_compiled_Set_id = (Select nvl(gei.ind_compiled_set_id, adl.ind_compiled_set_id) --Bug 5122879
                                    from   gms_encumbrance_items gei,
                                           gms_award_distributions adl
                                    where adl.expenditure_item_id =gbc.adjusted_document_header_id
                                      and adl.adl_status = 'A'
				      and adl.fc_status = 'A'
				      and nvl(adl.reversed_flag, 'N') = 'N'
				      and adl.line_num_reversed is null
                                      and adl.document_type = 'ENC'
                                      and gei.encumbrance_item_id = adl.expenditure_item_id)
   where  gbc.packet_id   = p_packet_id
   and    gbc.status_code = 'P'
   and    gbc.result_code is NULL
   and    gbc.ind_compiled_set_id is null
   and    gbc.adjusted_document_header_id is not NULL
   and   nvl(gbc.burden_adjustment_flag,'N') = 'N' -- 3389292
   and    gbc.adjusted_document_header_id <> gbc.document_header_id;

   gms_error_pkg.gms_debug ( 'Calc_enc_ind_compiled_set_id : End','C');

   COMMIT;

End Calc_enc_ind_compiled_set_id;

/*--------------------------------------------------------------------------------------------------------
-- This procedure updates table values
-- TABLE          Columns
-- GMS_BC_PACKETS       STATUS_CODE
-- GMS_AWARD_DISTRIBUTIONS    FC_STATUS
--             RESOURCE_LIST_MEMBER_ID
--             BUD_TASK_ID(Budgeted Task)
--             BUD_RES_LIST_MEMBER_ID(Budgeted rlmi)
--             RAW_COST
--             IND_COMPILED_SET_ID
-- GMS_ENCUMBRANCE_ITEMS_ALL     ENC_DISTRIBUTED_FLAG
--
-- DIFFERENT MODE USED FOR UPDATE
-- S - Submit
-- B - Baseline
-- R - Reserve
-- U - Unreserve
-- C - Check Funds
-- E - Encumrance
--
-- DIFFERENT DOCUMENT TYPES FOR UPDATE
-- REQ - Requisitions
-- PO  - Purchase Orders
-- AP  - Payables
-- ENC - Encumbrances
-- -----------------------------------------------------------------*/

   PROCEDURE status_code_update (p_packet_id NUMBER, p_mode VARCHAR2, p_partial VARCHAR2 DEFAULT 'N') IS
      x_err_code   NUMBER;
      x_err_buff   VARCHAR2 (2000);

      x_dummy      NUMBER;          -- Bug 2181546, Added
         CURSOR c_failed_packet IS  -- Bug 2181546, Added
         SELECT 1
           FROM gms_bc_packets
          WHERE packet_id = p_packet_id
            AND SUBSTR (nvl(result_code,'F65'), 1, 1) = 'F' ;

      /* Introduced for Bug# 4159238 (BaseBug#4292763)*/

      TYPE tab_doc_head_id     IS TABLE OF gms_bc_packets.document_header_id%TYPE;
      TYPE tab_doc_type        IS TABLE OF gms_bc_packets.document_type%TYPE;
      TYPE tab_res_code        IS TABLE OF gms_bc_packets.result_code%TYPE;
      TYPE tab_sta_code        IS TABLE OF gms_bc_packets.status_code%TYPE;
      TYPE tab_dr_code         IS TABLE OF gms_bc_packets.entered_dr%TYPE;
      TYPE tab_cr_code         IS TABLE OF gms_bc_packets.entered_cr%TYPE;
      TYPE tab_bud_task_id     IS TABLE OF gms_bc_packets.bud_task_id%TYPE;
      TYPE tab_proj_id         IS TABLE OF gms_bc_packets.project_id%TYPE;
      TYPE tab_res_list_mem_id IS TABLE OF gms_bc_packets.resource_list_member_id%TYPE;
      TYPE tab_doc_dist_id     IS TABLE OF gms_bc_packets.document_distribution_id%TYPE;
      TYPE tab_task_id         IS TABLE OF gms_bc_packets.task_id%TYPE;
      TYPE tab_exp_item_date   IS TABLE OF gms_bc_packets.expenditure_item_date%TYPE;
      TYPE tab_award_id        IS TABLE OF gms_bc_packets.award_id%TYPE;
      TYPE tab_exp_orgnzt_id   IS TABLE OF gms_bc_packets.expenditure_organization_id%TYPE;
      TYPE tab_packet_id       IS TABLE OF gms_bc_packets.packet_id%TYPE;
      TYPE tab_bc_packet_id    IS TABLE OF gms_bc_packets.bc_packet_id%TYPE;
      TYPE tab_exp_type        IS TABLE OF gms_bc_packets.expenditure_type%TYPE;
      TYPE tab_ind_comp_setid  IS TABLE OF gms_bc_packets.ind_compiled_set_id%TYPE;
      TYPE tab_set_of_books_id IS TABLE OF gms_bc_packets.set_of_books_id%TYPE; --Bug 5845974

      tdocument_header_id             tab_doc_head_id;
      tdocument_type                  tab_doc_type;
      tresult_code                    tab_res_code;
      tstatus_code                    tab_sta_code;
      tentered_dr                     tab_dr_code;
      tentered_cr                     tab_cr_code;
      tbud_task_id                    tab_bud_task_id;
      tproject_id                     tab_proj_id;
      tresource_list_member_id        tab_res_list_mem_id;
      tdocument_distribution_id       tab_doc_dist_id;
      ttask_id                        tab_task_id;
      texpenditure_item_date          tab_exp_item_date;
      taward_id                       tab_award_id;
      texpenditure_organization_id    tab_exp_orgnzt_id;
      tpacket_id                      tab_packet_id;
      tbc_packet_id                   tab_bc_packet_id;
      texpenditure_type               tab_exp_type;
      tind_compiled_set_id            tab_ind_comp_setid;
      tset_of_books_id                tab_set_of_books_id; --Bug 5845974

      l_batch_size                    number := 10000;

      /* End of variables introduced for Bug# 4159238 (BaseBug#4292763)*/


      CURSOR update_status IS
	 SELECT document_header_id,                 document_type,                result_code,
                status_code,                        entered_dr,                   entered_cr,
                bud_task_id,                        project_id,                   resource_list_member_id,
                document_distribution_id,           task_id,                      expenditure_item_date,
		expenditure_type , -- Bug 3003584
                award_id,                           expenditure_organization_id,  packet_id,
                bc_packet_id,                       ind_compiled_set_id  -- Added for bug : 2927485
           FROM gms_bc_packets
          WHERE packet_id = p_packet_id
            AND parent_bc_packet_id IS NULL
            AND nvl(burden_adjustment_flag,'N') = 'N'
            AND status_code in ('A','B') --Added to fix bug 2138376 from 'B'*/
	    AND document_type IN ('REQ','PO','AP');

      CURSOR update_status1 IS
	 SELECT document_header_id,                 document_type,                result_code,
                status_code,                        entered_dr,                   entered_cr,
                bud_task_id,                        project_id,                   resource_list_member_id,
                document_distribution_id,           task_id,                      expenditure_item_date,
		expenditure_type , -- Bug 3003584
                award_id,                           expenditure_organization_id,  packet_id,
                bc_packet_id,                       ind_compiled_set_id,  -- Added for bug : 2927485
                set_of_books_id --Bug 5845974
           FROM gms_bc_packets
          WHERE packet_id = p_packet_id
            AND parent_bc_packet_id IS NULL
            AND nvl(burden_adjustment_flag,'N') = 'N'
            AND status_code in ('A','B') --Added to fix bug 2138376 from 'B'*/
	    AND document_type in ('EXP','ENC');
	    --AND document_type = 'ENC';

      CURSOR update_status_enc IS --Bug 5726575
         SELECT gbp.document_header_id,
                gbp.document_type,
                gbp.result_code,
                gbp.document_distribution_id,
                adl.ind_compiled_set_id,
                gbp.packet_id
           FROM gms_bc_packets gbp,
                gms_award_distributions adl
          WHERE gbp.document_header_id = adl.expenditure_item_id
            and gbp.document_distribution_id = adl.adl_line_num
            and gbp.packet_id = p_packet_id
            AND gbp.parent_bc_packet_id IS NULL
            AND nvl(gbp.burden_adjustment_flag,'N') = 'N'
            AND gbp.status_code in ('A','B')
            AND gbp.document_type in ('ENC')
            and adl.document_type = 'ENC'
            and adl.adl_status = 'A'
            and nvl(adl.reversed_flag, 'N') <> 'Y'
            and adl.line_num_reversed is null;

   BEGIN
      g_error_procedure_name := 'status_code_update';
      g_error_stage := 'SCU : START';
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ( 'STATUS_CODE_UPDATE - START ','C');
      END IF;

     If g_partial_flag = 'N' then

        -- -------------------------------- FULL MODE  START ---------------------------------------------+
	--  IF (    ( NVL(p_mode,'R') in ('R') and NVL(p_partial,'N') = 'N')
	--  	   OR ( NVL(p_mode,'R') in ('U','S','B','C'))) 			  	    THEN

        g_error_stage := 'SCU : PARTIAL NO RES';

        --Bug 2181546, Added the cursor and failing packet if atleast one failed record exists in packet
           OPEN c_failed_packet;
           FETCH c_failed_packet INTO x_dummy;

           IF c_failed_packet%FOUND THEN

             -- ---------------------------------------------+
             -- FULL MODE: FAILURE
             -- ---------------------------------------------+
             UPDATE gms_bc_packets
                SET status_code = decode(p_mode,'S','E','C','F','R'),
	            result_code =
                  DECODE (SUBSTR (NVL (result_code, 'F65'), 1, 1), 'P','F65', NVL(result_code,'F65')),  --Bug 2092791 Added NVL Clause
	            fc_error_message     = decode(fc_error_message,NULL,g_error_procedure_name,fc_error_message)
              WHERE packet_id = p_packet_id;

           ELSE

             -- ---------------------------------------------+
             -- FULL MODE: PASS
             -- ---------------------------------------------+
            UPDATE gms_bc_packets
               SET status_code = decode(p_mode,'S','S','B','B','C','C','A')
             WHERE packet_id = p_packet_id;
			IF g_debug = 'Y' THEN
				gms_error_pkg.gms_debug ('STATUS_CODE_UPDATE - SUBMIT UPDATE FOR PASS TRANSACTIONS', 'C');
			END IF;
           END IF;
           CLOSE c_failed_packet;
        -- -------------------------------- PARTIAL MODE  START ---------------------------------------------+
	ELSIF g_partial_flag ='Y' then

	-- ELSIF (     ( NVL(p_mode,'R') in ('R') and NVL(p_partial,'N') = 'Y' )
	--  	      OR ( NVL(p_mode,'R') in ('E'))) THEN

            UPDATE gms_bc_packets
               SET status_code = DECODE (SUBSTR (nvl(result_code,'F65'), 1, 1), 'P', 'A', 'R'),
		   fc_error_message     = decode(fc_error_message,NULL,g_error_procedure_name,fc_error_message)
             WHERE packet_id = p_packet_id;

            IF SQL%NOTFOUND THEN
               IF g_debug = 'Y' THEN
               	gms_error_pkg.gms_debug ('STATUS_CODE_UPDATE - NO RECORDS UPDATED IN PARTIAL MODE', 'C');
               END IF;
            END IF;
            g_error_stage := 'SCU : PARTIAL YES RES';

	 ELSE
            IF g_debug = 'Y' THEN
            	gms_error_pkg.gms_debug ('STATUS_CODE_UPDATE - NO RECORDS UPDATED ', 'C');
            END IF;
	 END IF;

      -- --------------------------------------------------------------------------------------------------+
      -- If g_doc_type <> 'EXP' then

       /* Changes for Bug#4159238  (BaseBug#4292763): Implemented bulk collect logic*/

       IF p_mode IN ('R','U','B','E') THEN


        OPEN update_status;

	LOOP

	 FETCH update_status
         BULK COLLECT INTO
                tdocument_header_id,                tdocument_type,               tresult_code,
                tstatus_code,                       tentered_dr,                  tentered_cr,
                tbud_task_id,                       tproject_id,                  tresource_list_member_id,
                tdocument_distribution_id,          ttask_id,                     texpenditure_item_date,
		texpenditure_type,
                taward_id,                          texpenditure_organization_id, tpacket_id,
                tbc_packet_id,                      tind_compiled_set_id
	 LIMIT  l_batch_size;

	 IF tpacket_id.COUNT > 0 THEN

  	      FORALL I in tpacket_id.FIRST..tpacket_id.LAST
                UPDATE gms_award_distributions
                SET     resource_list_member_id = tresource_list_member_id(i),
                      bud_task_id             = tbud_task_id(i),
                      fc_status               = DECODE(p_mode,'B',fc_status,
                                                DECODE (SUBSTR (tresult_code(i), 1, 1), 'P', 'A', 'R'))
                WHERE  DECODE(tdocument_type(i), 'AP', invoice_id, tdocument_header_id(i) ) = tdocument_header_id(i)
                AND    DECODE(tdocument_type(i), 'REQ', distribution_id,
                                                 'PO',  po_distribution_id,
                                                 'AP', invoice_distribution_id) = tdocument_distribution_id(i)
                /* Bug 5344693 : tdocument_distribution_id(i) stores the invoice_distribution_id for an AP invoice.
		   So for an AP invoice , tdocument_distribution_id(i) should be compared with invoice_distribution_id. */
                AND    adl_status    = 'A'
                AND    document_type = tdocument_type(i)
                AND    project_id    = tproject_id(i)
                AND    task_id       = ttask_id(i)
                AND    award_id      = taward_id(i);

	  /* Used .delete instead of assigning null table to these tables.*/
	  tdocument_header_id.delete;
          tdocument_type.delete;
          tresult_code.delete;
          tstatus_code.delete;
          tentered_dr.delete;
          tentered_cr.delete;
          tbud_task_id.delete;
          tproject_id.delete;
          tresource_list_member_id.delete;
          tdocument_distribution_id.delete;
          ttask_id.delete;
          texpenditure_item_date.delete;
          taward_id.delete;
          texpenditure_organization_id.delete;
          tpacket_id.delete;
          tbc_packet_id.delete;
          texpenditure_type.delete;
	  tind_compiled_set_id.delete;

	 END IF;

	 EXIT WHEN update_status%NOTFOUND;

	END LOOP;
        CLOSE update_status;

      open update_status1;

      LOOP

	FETCH update_status1
	BULK COLLECT INTO
                tdocument_header_id,                tdocument_type,               tresult_code,
                tstatus_code,                       tentered_dr,                  tentered_cr,
                tbud_task_id,                       tproject_id,                  tresource_list_member_id,
                tdocument_distribution_id,          ttask_id,                     texpenditure_item_date,
		texpenditure_type,
                taward_id,                          texpenditure_organization_id, tpacket_id,
                tbc_packet_id,                      tind_compiled_set_id,         tset_of_books_id --Bug 5845974
	 LIMIT  l_batch_size;

       IF tpacket_id.COUNT > 0 THEN

	 FORALL I in tpacket_id.FIRST..tpacket_id.LAST
         UPDATE gms_award_distributions
         SET    cost_distributed_flag =
                DECODE(P_MODE,'B',cost_distributed_flag,DECODE (SUBSTR (tresult_code(i), 1, 1), 'P', 'Y', 'N')),
                fc_status  = DECODE(P_MODE,'B',FC_STATUS,DECODE (SUBSTR (tresult_code(i), 1, 1), 'P', 'A', 'R')),
                raw_cost   = DECODE(P_MODE,'B',RAW_COST,NVL (tentered_dr(i), 0) - NVL (tentered_cr(i), 0)),
                bud_task_id = tbud_task_id(i),
                resource_list_member_id = tresource_list_member_id(i),
                ind_compiled_set_id = DECODE(P_MODE,'B',ind_compiled_set_id, tind_compiled_set_id(i))
         WHERE  expenditure_item_id = tdocument_header_id(i)
         AND    adl_line_num = decode(tdocument_type(i), 'ENC', tdocument_distribution_id(i), adl_line_num)--Bug 5726575
         AND    cdl_line_num = decode(tdocument_type(i), 'ENC', 1, tdocument_distribution_id(i)) /* Bug 6066845 */
         AND    document_type = tdocument_type(i)
         AND    adl_status = 'A';

         /* Commented for bug 5726575
         IF p_mode <> 'B' THEN
              g_error_stage := 'UPDATE_ENC_ITEM';
	       FORALL I in tpacket_id.FIRST..tpacket_id.LAST
               UPDATE gms_encumbrance_items_all
               SET    enc_distributed_flag = DECODE (SUBSTR (tresult_code(i), 1, 1), 'P', 'Y', 'N'),
	              ind_compiled_set_id  = tind_compiled_set_id(i)
               WHERE  encumbrance_item_id  = tdocument_header_id(i)
               AND    tdocument_type(i)    = 'ENC';
         END IF;*/

	 --Bug 5845974
	 IF p_mode <> 'B' THEN
             g_error_stage := 'UPDATE_ADL_WITH_GL_DATE';
             FORALL I in tpacket_id.FIRST..tpacket_id.LAST
               update gms_award_distributions
               set gl_date = pa_utils2.get_prvdr_gl_date(texpenditure_item_date(i), 101, tset_of_books_id(i))
               where document_type = 'ENC'
                 and adl_status = 'A'
                 and expenditure_item_id = tdocument_header_id(i)
                 and adl_line_num = tdocument_distribution_id(i);
	 END IF;

          /* Used .delete instead of assigning null table to these tables. Bug# 4337250*/

	  tdocument_header_id.delete;
          tdocument_type.delete;
          tresult_code.delete;
          tstatus_code.delete;
          tentered_dr.delete;
          tentered_cr.delete;
          tbud_task_id.delete;
          tproject_id.delete;
          tresource_list_member_id.delete;
          tdocument_distribution_id.delete;
          ttask_id.delete;
          texpenditure_item_date.delete;
          taward_id.delete;
          texpenditure_organization_id.delete;
          tpacket_id.delete;
          tbc_packet_id.delete;
          texpenditure_type.delete;
    	  tind_compiled_set_id.delete;

	END IF;

        EXIT WHEN update_status1%NOTFOUND;

        END LOOP;
        close update_status1;

        --Bug 5726575 Start
        open update_status_enc;
        LOOP
          FETCH update_status_enc
          BULK COLLECT INTO tdocument_header_id,
                            tdocument_type,
                            tresult_code,
                            tdocument_distribution_id,
                            tind_compiled_set_id,
                            tpacket_id
          LIMIT  l_batch_size;
         IF tpacket_id.COUNT > 0 THEN
           IF p_mode <> 'B' THEN
             FORALL I in tpacket_id.FIRST..tpacket_id.LAST
               UPDATE gms_encumbrance_items_all
               SET    enc_distributed_flag = DECODE (SUBSTR (tresult_code(i), 1, 1), 'P', 'Y', 'N'),
                      ind_compiled_set_id  = tind_compiled_set_id(i)
               WHERE  encumbrance_item_id  = tdocument_header_id(i);
           END IF;
           tdocument_header_id.delete;
           tdocument_type.delete;
           tresult_code.delete;
           tdocument_distribution_id.delete;
           tpacket_id.delete;
           tind_compiled_set_id.delete;
         END IF;
         EXIT WHEN update_status_enc%NOTFOUND;  /*bug 5840237 */
        END LOOP;
        close update_status_enc;
        --Bug 5726575 End

     --  END IF; --  If g_doc_type <> 'EXP' then

    /* End changes for Bug#4159238 (BaseBug#4292763): Implemented bulk collect logic*/
    END IF;

   EXCEPTION
     WHEN OTHERS THEN
	 IF update_status%ISOPEN THEN
	   CLOSE update_status;
	 END IF;

	 IF update_status1%ISOPEN THEN
	   CLOSE update_status1;
	 END IF;

         -- Bug 5726575 Start
         IF c_failed_packet%ISOPEN THEN
           CLOSE c_failed_packet;
 	 END IF;

         IF update_status_enc%ISOPEN THEN
           CLOSE update_status_enc;
         END IF;
         -- Bug 5726575 End

	 RAISE;    -- Bug 2181546, Added
   END status_code_update;

----------------------------------------------------------------------------------------------------------
-- Procedure to update gms_bc_packets when there is a failure ..
-- This Procedure updates
--                    status_code ,
--					  result_code at Award Level,Task Level,Resource Group Level
--					  fc_error_message
-- 	All the above parameters are optional
--
----------------------------------------------------------------------------------------------------------

   PROCEDURE result_status_code_update (
      p_packet_id                  IN   NUMBER,
      p_status_code                IN   VARCHAR2,
      p_result_code                IN   VARCHAR2,
      p_bc_packet_id               IN   NUMBER DEFAULT NULL,
      p_fc_error_message	   IN	VARCHAR2 DEFAULT NULL ) IS
      x_err_code   NUMBER;
      x_err_buff   VARCHAR2 (2000);
   BEGIN
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('BEGIN result_status_code_update', 'C');
      END IF;
	  g_error_procedure_name  :=  'result_status_code_update' ;

    IF p_bc_packet_id is NULL THEN
       g_error_stage := 'RESULT_CODE:PACK_ID';

       UPDATE gms_bc_packets
       SET    status_code          = decode(status_code,'P',p_status_code,'I',p_status_code,status_code),
              result_code          = decode(substr(result_code,1,1),'F',result_code,p_result_code),
              fc_error_message     = decode(fc_error_message,null,p_fc_error_message,fc_error_message)
       WHERE  packet_id            = p_packet_id;
	ELSE
       g_error_stage := 'RESULT_CODE:BC_PACK_ID';

       UPDATE gms_bc_packets
       SET    status_code          = decode(status_code,'P',p_status_code,'I',p_status_code,status_code),
              result_code          = decode(substr(result_code,1,1),'F',result_code,p_result_code),
              fc_error_message     = decode(fc_error_message,null,p_fc_error_message,fc_error_message)
       WHERE packet_id             = p_packet_id
         AND bc_packet_id          = p_bc_packet_id;

	END IF;

      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('END result_status_code_update', 'C');
      END IF;
      x_err_code := 0;
   END result_status_code_update;

----------------------------------------------------------------------------------------------------------
--  Function to create ADL's for REQ,PO,AP.
--  This Function is used to SYNC up ADL's in case of REQ/PO/AP
--  This function will create ADL's in following scenarios
--                  Auto Create a PO
--		    Copy a PO
--                  Duplicate Distribution lines in REQ/PO
--                  Match a PO with Invoice
----------------------------------------------------------------------------------------------------------

-- R12 Funds management uptake : With R12 this API will get fired before inserting records into gl_bc_packets,
-- hence modified the whole logic of this procedure .
-- Logic is now based on global PLSQL variables populated by copy_gl_pkt_to_gms_pkt procedure

----------------------------------------------------------------------------------------------------------

   FUNCTION misc_synch_adls (p_application_id   IN  NUMBER) RETURN BOOLEAN IS

      x_stage              NUMBER;
      x_award_set_id       NUMBER;
      x_flip_adl_status    varchar2(1); -- Bug 2155774
      l_adl_status         gms_award_distributions.adl_status%TYPE;
      l_adl_document_type  gms_award_distributions.document_type%TYPE;
      l_adl_invoice_id     NUMBER;
      l_adl_dist_id        gms_award_distributions.invoice_distribution_id%TYPE;
      l_award_set_id       gms_award_distributions.award_set_id%TYPE;


      CURSOR c_ap (p_inv_dist_id NUMBER) IS
         SELECT DISTINCT adl.award_set_id,
	                 adl.document_type,		-- Bug 2433889
			 adl.invoice_id,		-- Bug 2433889
			 adl.invoice_distribution_id	-- Bug 2433889
                    FROM ap_invoice_distributions_all ap,
                         gms_award_distributions adl
                   WHERE ap.invoice_distribution_id = p_inv_dist_id
                     AND ap.award_id IS NOT NULL
                     AND ap.award_id = adl.award_set_id
		     AND adl.adl_line_num = 1;


      CURSOR c_exp_adl (p_expenditure_item_id NUMBER,
                        p_cdl_line_num        NUMBER) IS
         SELECT *
           FROM gms_award_distributions
          WHERE document_type = 'EXP'
            AND adl_status = 'A'
            AND expenditure_item_id = NVL (p_expenditure_item_id, -1)
            AND cdl_line_num = NVL (p_cdl_line_num, -1);

      x_rec            c_exp_adl%ROWTYPE;

       	-- Bug 2155774, Cursor to pick all the REQ distributions not having adls
      	CURSOR c_REQ_miss_adls (p_distribution_id NUMBER) IS
      	SELECT adl.award_set_id, adl.adl_status
          FROM gms_award_distributions adl,
               po_req_distributions pd
       	 WHERE pd.distribution_id = p_distribution_id
           AND pd.award_id = adl.award_set_id
      	   AND adl.adl_line_num = 1
           AND not exists (select 1 from gms_award_distributions gad
			    where gad.award_set_id = pd.award_id
			     and  gad.document_type = 'REQ'
      			     and  gad.distribution_id = pd.distribution_id
      			     and  gad.adl_status = 'A');

      	CURSOR c_po_miss_adls (p_po_distribution_id NUMBER) IS
         SELECT pod.award_id award_set_id,
                adl.adl_status  -- Bug 2155774
           FROM po_distributions_all pod,
                gms_award_distributions adl
          WHERE pod.po_distribution_id = p_po_distribution_id
            AND pod.award_id IS NOT NULL
            AND pod.award_id = adl.award_set_id
	    AND adl.adl_line_num = 1   -- Bug 2155774
            AND (adl.document_type = 'REQ'
		 OR NOT EXISTS (SELECT 1
		                  FROM gms_award_distributions gad
				 WHERE gad.award_set_id = pod.award_id
				   AND gad.po_distribution_id = pod.po_distribution_id
				   AND gad.adl_status = 'A'));  -- Bug 2155774, added to pick distribution lines
								-- created by copy of PO and distribution lines


BEGIN

      x_flip_adl_status := 'N';  -- Bug 2155774
      g_error_procedure_name := 'misc_synch_adls';

	-- ---------------------------------
	--  x_stage := 10 - REQUISITION
	--  x_stage := 20 - PO
	--  x_stage := 30 - AP
	-- ---------------------------------

      If p_application_id = 201 THEN

	   g_error_stage := 'Requisitions and Purchase orders';

	    FOR i in 1..g_set_of_books_id_tab.count LOOP

	      -- ========================================================
	      -- For REQ and PO records : Inactivate multiple active adls found at OHSU. This is
	      -- due to data entry combinations.
	      -- ========================================================
	      -- bug : 2308005

		UPDATE gms_award_distributions adl
		   SET adl_status = 'I'
		 WHERE adl.adl_status = 'A'
		   AND (adl.award_set_id,adl.document_type) IN ( SELECT adl2.award_set_id,adl2.document_type
								   FROM gms_award_distributions adl2,
                                                                        po_req_distributions_all pd
                                                                  WHERE g_document_type_tab(i) = 'REQ'
                                                                    AND adl2.document_type     = 'REQ'
                                                                    AND adl2.adl_line_num      = 1
                                                                    AND adl2.distribution_id   = pd.distribution_id
                                                                    AND pd.distribution_id     = g_doc_dist_id_tab(i)
                                                                    AND pd.award_id            <> adl2.award_set_id
                         					  UNION ALL
						                 SELECT adl2.award_set_id,adl2.document_type
                        					   FROM gms_award_distributions adl2,
                                                                        po_distributions_all pd
                                                                  WHERE g_document_type_tab(i)    = 'PO'
                                                                    AND adl2.document_type        = 'PO'
                                                                    AND adl2.adl_line_num         = 1
                                                                    AND adl2.po_distribution_id   = pd.po_distribution_id
                                                                    AND pd.po_distribution_id     = g_doc_dist_id_tab(i)
                                                                    AND pd.award_id               <> adl2.award_set_id);

	   END LOOP;

	   FOR i in 1..g_set_of_books_id_tab.count LOOP

	     -- ---------------------------------------------------------
	     -- STAGE:10 - We need to create missing ADLs for Requistitions
	     -- created using key Duplicate Record(Shift+F6)
	     -- So synch processsing required here.
	     -- ---------------------------------------------------------

	    -- --------------------------------------------------------
	    -- STAGE:20 - Purchasing.
	    -- Standard purchasing and Releases are okay as they are
	    -- Entered.
	    -- REQ - Becomes PO or release will have AWARD SET ID
	    -- copied from REQ. We need to create ADLS for that PO
	    -- So that ADLS are in SYNCH with PO.
	    -- ---------------------------------------------------------

	    -- --------------------------------------------------------------------
	    -- CALL COPY ADLS COMMON PACKAGE to copy the new ADLS
	    -- and also update the distribution line to create a
	    -- link between distribution line and ADLS.
	    -- gms_awards_dist_pkg.copy_adls( p_award_set_id      IN  NUMBER ,
	    --                P_NEW_AWARD_SET_ID  OUT NOCOPY NUMBER,
	    --                p_doc_type          IN  varchar2,
	    --                p_dist_id           IN  NUMBER,
	    --                P_INVOICE_ID        IN  NUMBER DEFAULT NULL,
	    --                p_dist_line_num     IN  NUMBER DEFAULT NULL   )
	    -- --------------------------------------------------------------------

	    g_error_stage := 'MISC_ADL: REQ and PO ';

            l_award_set_id := 0;

	    IF g_document_type_tab(i) = 'REQ' THEN

	       OPEN  c_REQ_miss_adls (g_doc_dist_id_tab(i));
	       FETCH c_REQ_miss_adls INTO l_award_set_id ,l_adl_status;
               CLOSE c_REQ_miss_adls;

	    ELSIF g_document_type_tab(i) = 'PO' THEN

	       OPEN  c_po_miss_adls (g_doc_dist_id_tab(i));
	       FETCH c_po_miss_adls INTO l_award_set_id ,l_adl_status;
               CLOSE c_po_miss_adls;

	    END IF;

	    IF NVL(l_award_set_id ,0) <>0  THEN

	      If l_adl_status = 'I' Then
			update gms_award_distributions
			set adl_status = 'A'
			where award_set_id  = l_award_set_id ;
			x_flip_adl_status := 'Y';
	      End If;

	      gms_awards_dist_pkg.copy_adls(p_award_set_id =>  l_award_set_id,
					    P_NEW_AWARD_SET_ID => x_award_set_id,          --OUT variable
					    p_doc_type => g_document_type_tab(i),
					    p_dist_id => g_doc_dist_id_tab(i),
					    p_called_from => 'MISC_SYNCH_ADLS'
					    );

	      If (x_flip_adl_status = 'Y') Then
			update gms_award_distributions
			set adl_status = 'I'
			where award_set_id  = l_award_set_id ;
			x_flip_adl_status := 'N';
	      End If;

            END IF; --IF NVL(l_award_set_id ,0) <>0  THEN

	   END LOOP;

      ELSIF p_application_id = 200 THEN

	    g_error_stage := 'AP INVOICE';
	    -- =============================================================================
	    -- AP invoice distribution lines having ADls inactive. This occurs due to update
	    -- in when validate item. We are changing the status to 'I' when award change.
	    -- Now if someone clears record then ADLs stays at inactive status.
	    -- =============================================================================
	    -- 2308005 ( CLEARING INVOICE DIST. LINE AFTER CHANGING AWARD MAKES ADL STATUS 'I' ).
	    -- ===================

	    FOR i in 1..g_set_of_books_id_tab.count LOOP

              update gms_award_distributions  adl
                 set adl.adl_status = 'A'
               where adl.document_type = 'AP'
                 and adl.adl_status    = 'I'
                 and adl.award_set_id in ( select adl2.award_set_id
                                             from gms_award_distributions adl2,
                                                  ap_invoice_distributions_all apd
                                            where apd.invoice_id        = g_doc_header_id_tab(i)
                                              AND apd.invoice_distribution_id = g_doc_dist_id_tab(i)
                                              and apd.award_id          is not null
                                              and adl2.award_set_id     = apd.award_id
                                              and adl2.invoice_id       = apd.invoice_id
                                              and adl2.document_type    = 'AP'
                                              and adl2.invoice_distribution_id = apd.invoice_distribution_id
                                              and adl2.adl_status       = 'I'  ) ;

	    END LOOP;

	    FOR i in 1..g_set_of_books_id_tab.count LOOP

		-- ---------------------------------------------------------------
		-- STAGE:30 - AP Invoice.
		-- Standard AP invoice/credit memo/debit memo are okay as they are
		-- Entered.
		-- CASE 1 - PO - Becomes AP will have AWARD SET ID
		--          copied from PO. We need to create ADLS for that AP
		--          So that ADLS are in SYNCH with AP.
		-- CASE 2 - PRORATE
		-- CASE 3 - REVERSAL
		-- CASE 4 - Credit memo matching to AP invoice/ PO
		-- CASE 5 - Debit memo matching to AP invoice/ PO
		-- ---------------------------------------------------------
		-- --------------------------------------------------------------------
		-- CALL COPY ADLS COMMON PACKAGE to copy the new ADLS
		-- and also update the distribution line to create a
		-- link between distribution line and ADLS.
		-- gms_awards_dist_pkg.copy_adls( p_award_set_id      IN  NUMBER ,
		--                P_NEW_AWARD_SET_ID  OUT NOCOPY NUMBER,
		--                p_doc_type          IN  varchar2,
		--                p_dist_id           IN  NUMBER,
		--                P_INVOICE_ID        IN  NUMBER DEFAULT NULL,
		--                p_dist_line_num     IN  NUMBER DEFAULT NULL   )
		-- --------------------------------------------------------------------
		-- Find out NOCOPY do we need to create ADLS
		-- ----------------------------------

		-- Bug 2433889 : Added following If statement to incorporate cursor logic in the
		--		 If statement
		-- R12 Funds Managment Uptake : Unique identifier of invoice distribution is invoice_distribution_id


		OPEN c_ap(g_doc_dist_id_tab(i));
		FETCH c_ap INTO l_award_set_id,
		                l_adl_document_type,
				l_adl_invoice_id,
				l_adl_dist_id;


		IF (C_AP%FOUND AND
		    ( (l_adl_document_type  = 'PO')
		      OR
		      ( /* Bug 5344693 : Removed the document_header_id condition as the document_distribution_id is an unique identifier */
		       g_doc_dist_id_tab(i) <> NVL(l_adl_dist_id,0) AND
		       l_adl_document_type = 'AP'
		     )
		    OR
		     -- Forward port 3598982
		     --
		     ( l_adl_document_type  = 'APD')
		   ))
		 THEN

			 gms_awards_dist_pkg.copy_adls (
			    p_award_set_id => l_award_set_id,
			    P_NEW_AWARD_SET_ID => x_award_set_id,
			    p_doc_type => 'AP',
			    p_dist_id => g_doc_dist_id_tab(i),
			    P_INVOICE_ID => g_doc_header_id_tab(i),
			    p_dist_line_num => g_doc_dist_line_num_tab(i),
			    p_called_from => 'MISC_SYNCH_ADLS');
		END IF;

		CLOSE c_ap;

	     END LOOP;

	     FOR i in 1..g_set_of_books_id_tab.count LOOP

		IF g_inv_source_tab(i) = 'Oracle Project Accounting' AND g_invoice_type_code_tab(i) = 'EXPENSE REPORT' THEN

		     -- ------------------------------------------------------------------------------
		     -- BUG:1361978 - Payable invoice import process for exp report is not bringing
		     -- award.
		     -- ------------------------------------------------------------------------------
		      g_error_stage := 'MISC_ADL: EXP. REP';

			 OPEN c_exp_adl (g_inv_dist_reference_1_tab(i),
				         g_inv_dist_reference_2_tab(i));
			 FETCH c_exp_adl INTO x_rec;
			 IF c_exp_adl%NOTFOUND THEN
			    CLOSE c_exp_adl;
			    RAISE NO_DATA_FOUND;
			 END IF;
			 CLOSE c_exp_adl;

			 x_rec.document_type := 'AP';
			 x_rec.cdl_line_num := NULL;
			 x_rec.expenditure_item_id := NULL;
			 x_rec.invoice_id := g_doc_header_id_tab(i);
			 x_rec.invoice_distribution_id := g_doc_dist_id_tab(i);
			 x_rec.distribution_line_number := g_doc_dist_line_num_tab(i);
			 x_rec.adl_line_num := 1;
			 x_rec.award_set_id := gms_awards_dist_pkg.get_award_set_id;

			 gms_awards_dist_pkg.create_adls (x_rec);

			 UPDATE ap_invoice_distributions_all
			    SET award_id = x_rec.award_set_id
			  WHERE invoice_id = g_doc_header_id_tab(i)
			    AND invoice_distribution_id = g_doc_dist_id_tab(i);

		END IF;

	      END LOOP;

	-- ------------------------------------------------------------------------------
	-- BUG:1361978 - Payable invoice import process for exp report is not bringing
	-- award. End of change.
	-- ------------------------------------------------------------------------------
      End If;   --If p_application_id = 201 THEN

      RETURN TRUE;

EXCEPTION
      WHEN OTHERS THEN
         IF c_ap%ISOPEN THEN
            CLOSE c_ap;
         END IF;
         IF c_exp_adl%ISOPEN THEN
            CLOSE c_exp_adl;
         END IF;
         RAISE;
END misc_synch_adls;

   -- R12 Funds Management Uptake : Obsolete data_transfer_failure procedure as this logic is handled in copy_gl_pkt_to_gms_pkt
   --============================================================================================
   -- Bug 2899151 :  This procedure will fail gl_bc_packets and gms_bc_packets
   -- This procedure will be used when all records in gl_bc_packets (corresponding to sponsored)
   -- and not existing in gms_bc_packets.
   --============================================================================================


-- =====================================================================================================
-- R12 Funds Managment Uptake : New autonomous procedure to update failed result and status codes on
-- gms and gl bc packets if burdenable raw cost calculation failed for atleast one record in packet.
-- This called when calling_mode ='R' (Reserve)/'C' (Checkfunds)/'U' (unreserve) for AP/PO/REQ transactions.
-- This procedure will be fired from main session procedure copy_gl_pkt_to_gms_pkt which in turn is
-- called from GL main budgetory control API.
-- =====================================================================================================

 PROCEDURE UPDATE_BC_PKT_BRC_STATUS  ( p_packet_id   IN NUMBER,
                                       p_result_code IN VARCHAR2,
				       p_partial_flag IN VARCHAR2,
                                       p_mode         IN VARCHAR2 ) IS

 PRAGMA AUTONOMOUS_TRANSACTION;
 l_count NUMBER;

 CURSOR C_count_rejected_rec IS
 SELECT count(*)
   FROM gms_bc_packets
  WHERE packet_id = p_packet_id
    AND status_code in ( 'I' ,'P')
    AND substr(result_code,1,1) = 'F' ;

 BEGIN

  IF g_debug = 'Y' THEN
     gms_error_pkg.gms_debug ('UPDATE_BC_PKT_BRC_STATUS'||':'|| 'Start','C');
  END IF;

  -- Burdenable raw cost calculation procedure returned FALSE due to exception

  IF p_result_code  = 'F' THEN

     IF g_debug = 'Y' THEN
        gms_error_pkg.gms_debug ('UPDATE_BC_PKT_BRC_STATUS'||':'|| 'Updating gms and gl packets to failed status F76/F67','C');
     END IF;

     result_status_code_update ( p_packet_id=> p_packet_id,
                                 p_status_code=> 'T',
                                 p_result_code=> 'F76');

    -- Bug : 2557041 - Added for IP check funds Enhancement
    -- Update gl_bc_packets result_code to F67 if update Burdenable Raw Cost
    -- failed.

    -- R12 funds management Uptake : no update on gl_bc_packets required
    /*UPDATE gl_bc_packets
       SET result_code = DECODE (NVL (SUBSTR (result_code, 1, 1), 'P'),'P', 'F67',result_code)
     WHERE packet_id = P_packet_id;   */

  END IF;

  IF p_partial_flag = 'N' THEN -- Full mode
	  -- Burdenable raw cost calculation failed on atleast one record in packet
	  -- If any transaction has failed burdenable_raw_cost calculation and
	  -- the mode is 'R' or 'U' or 'C' .. fail the packet with F65

	  -- Check for failure
	  OPEN  C_count_rejected_rec;
	  FETCH C_count_rejected_rec INTO l_count;
	  CLOSE C_count_rejected_rec;


	  IF l_count <> 0 THEN

	     IF g_debug = 'Y' THEN
		gms_error_pkg.gms_debug ('UPDATE_BC_PKT_BRC_STATUS'||':'|| 'Updating gms packets to Full mode failure','C');
	     END IF;

	     --  If failure, update result/status code
	     Update gms_bc_packets
		set status_code = decode(p_mode,'C','F','R'),
		    result_code =decode(result_code,null,'F65',
					decode(substr(result_code,1,1),'P','F65',result_code)),
		    fc_error_message = decode(fc_error_message,NULL,
					      'COPY_GL_PKT_TO_GMS_PKT: Post burden calculation Check',fc_error_message)
	      where packet_id = p_packet_id
		AND status_code in ( 'I' ,'P');

	  END If;
  END IF; -- If p_partial_flag = 'N' THEN -- Full mode

  COMMIT;

END UPDATE_BC_PKT_BRC_STATUS;

-- =====================================================================================================
-- R12 Funds Managment Uptake : New autonomous procedure to insert records into gms_bc_packets and also
-- updates failed result and status codes on gms packets in case of any failures during loding.
-- This procedure will be fired from main session procedure copy_gl_pkt_to_gms_pkt which in turn is
-- called from GL main budgetory control API.
-- Input parameters : PLSQL tables storing data associated with gl pkts and AP/PO/REQ tables as the
--                    uncommited data in these transaction tables will not be accessible from
--                    autonomous session.
--                    p_gl_bc_pkt_spon_count -  This parameter stores number of eligible gms records
--                                              in gl_bc_packets
--                    p_return_code          -  'F' - Insertion Failed / Failed status records inserted
--                                              'P' - Insertion passed and no failed status records inserted
-- =====================================================================================================

PROCEDURE Load_gms_pkts(
                 p_packet_id             IN NUMBER,
		 p_partial_flag          IN VARCHAR2,
                 p_set_of_books_id_tab   IN t_set_of_books_id_type,
                 p_je_source_name_tab    IN t_je_source_name_type,
		 p_je_category_name_tab  IN t_je_category_name_type,
		 p_actual_flag_tab       IN t_actual_flag_type,
		 p_project_id_tab        IN t_project_id_type,
		 p_task_id_tab           IN t_task_id_type,
		 p_award_id_tab          IN t_award_id_type,
		 p_result_code_tab       IN t_result_code_type,
		 p_entered_dr_tab        IN t_entered_dr_type,
		 p_entered_cr_tab        IN t_entered_cr_type,
		 p_etype_tab             IN t_etype_type,
		 p_exp_org_id_tab        IN t_exp_org_id_type,
		 p_exp_item_date_tab     IN t_exp_item_date_type,
		 p_document_type_tab     IN t_document_type_type,
                 p_doc_header_id_tab     IN t_doc_header_id_type,
                 p_doc_dist_id_tab       IN t_doc_dist_id_type,
		 p_vendor_id_tab         IN t_vendor_id_type,
		 p_exp_category_tab      IN t_exp_category_type,
		 p_revenue_category_tab  IN t_revenue_category_type,
		 p_ind_cmp_set_id_tab    IN t_ind_cmp_set_id_type,
		 p_burdenable_raw_cost_tab IN t_brc_type, --R12 AP Lines Uptake
		 p_source_event_id_tab     IN t_source_event_id_type,
                 p_return_code           OUT NOCOPY VARCHAR2
               ) IS

	PRAGMA AUTONOMOUS_TRANSACTION;

	l_rec_count                NUMBER;
	l_accrue_at_receipt_flag   VARCHAR2(1);
	l_request_id               NUMBER;
	l_sysdate                  DATE;
        l_user_id                  NUMBER;
        l_login_id                 NUMBER;

   BEGIN

        IF g_debug = 'Y' THEN
          gms_error_pkg.gms_debug ('Load_gms_pkts'||':'|| 'Start','C');
        END IF;


	l_rec_count := p_set_of_books_id_tab.count();

        IF g_debug = 'Y' THEN
          gms_error_pkg.gms_debug ('Load_gms_pkts'||':'|| 'Intializing local variables','C');
        END IF;

	p_return_code    := 'P';
	l_request_id     := fnd_global.conc_request_id;
        l_user_id        := fnd_global.user_id;
        l_login_id       := fnd_global.login_id;

	IF l_request_id = -1 Then
	  l_request_id := NULL;
        end if;

 	SELECT SYSDATE
	  INTO l_sysdate
	  FROM DUAL;

	IF l_rec_count > 0 Then

           IF g_debug = 'Y' THEN
              gms_error_pkg.gms_debug ('Load_gms_pkts'||':'|| 'Starting loop to insert '||l_rec_count||'into gms_bc_packets','C');
           END IF;

   	   FORALL i IN 1 .. l_rec_count
	      INSERT INTO gms_bc_packets
			  (packet_id,
			   set_of_books_id,
			   je_source_name,
			   je_category_name,
			   actual_flag,
			   project_id,
			   task_id,
			   award_id,
			   result_code,
			   status_code,
			   last_update_date,
			   last_updated_by,
			   created_by,
			   creation_date,
			   last_update_login,
			   entered_dr,
			   entered_cr,
			   expenditure_type,
			   burdenable_raw_cost,
			   expenditure_organization_id,
			   expenditure_item_date,
			   document_type,
			   document_header_id,
			   document_distribution_id,
			   transfered_flag,
			   account_type,
			   bc_packet_id,
			   vendor_id,
			   expenditure_category,
			   revenue_category,
			   request_id,
			   ind_compiled_set_id,
                           source_event_id)
	          SELECT   p_packet_id
		          ,p_set_of_books_id_tab(i)
			  ,p_je_source_name_tab(i)
			  ,p_je_category_name_tab(i)
 			  ,p_actual_flag_tab(i)
			  ,p_project_id_tab(i)
			  ,p_task_id_tab(i)
			  ,p_award_id_tab(i)
			  ,p_result_code_tab(i)
 			  ,DECODE (p_award_id_tab(i), NULL, 'R', DECODE(p_document_type_tab(i),'PO','I'
			                                                                      ,'REQ','I'
											      ,'AP','I')) --Check for GMSIP impact as it was always 'P'
			  ,l_sysdate
			  ,l_user_id
			  ,l_user_id
			  ,l_sysdate
			  ,l_login_id
			  ,p_entered_dr_tab(i)
			  ,p_entered_cr_tab(i)
			  ,p_etype_tab(i)
			  ,DECODE(p_document_type_tab(i),'AP',p_burdenable_raw_cost_tab(i),NULL) --R12 AP Lines Uptake
			  ,p_exp_org_id_tab(i)
			  ,p_exp_item_date_tab(i)
			  ,p_document_type_tab(i)
			  ,p_doc_header_id_tab(i)
			  ,p_doc_dist_id_tab(i)
			  ,'N'  -- For GMSIP 'N' should not cause an issue
                          ,NULL
			  ,gms_bc_packets_s.NEXTVAL
			  ,p_vendor_id_tab(i)
			  ,p_exp_category_tab(i)
			  ,p_revenue_category_tab(i)
			  ,l_request_id
			  ,p_ind_cmp_set_id_tab(i)
			  ,p_source_event_id_tab(i)
                   FROM dual;
        END If;


        IF p_partial_flag = 'N'  THEN -- If full mode

           FOR  i IN 1 .. l_rec_count LOOP

		IF SUBSTR(p_result_code_tab(i),1,1) = 'F' THEN

		 UPDATE gms_bc_packets
		    SET result_code = 'F65',
			fc_error_message = decode(fc_error_message,NULL,'Load_gms_pkts:Full mode failure',fc_error_message)
		    WHERE packet_id   = p_packet_id
		      and SUBSTR(result_code,1,1) <> 'F' ;

		 p_return_code := 'F';
		 EXIT;
		END If;
            END LOOP;

         END If;

COMMIT;

EXCEPTION
      WHEN OTHERS THEN
          IF g_debug = 'Y' THEN
	    gms_error_pkg.gms_debug ('Load_gms_pkts - Exception '||' SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM, 'C');
	  END IF;
	  p_return_code := 'F';
END Load_gms_pkts;

-----------------------------------------------------------------------------------
-- R12 Funds management Uptake : New procedure create new record in plsql tabs for
-- backing PO/Release/variance
-----------------------------------------------------------------------------------

PROCEDURE COPY_AP_RECORD (p_copy_from_index    IN NUMBER,
                          p_new_rec_index      IN NUMBER,
			  p_document_type      IN VARCHAR2,
			  p_po_vendor_id       IN NUMBER,
 		          p_po_ind_com_set_id  IN NUMBER,
			  p_entered_dr         IN NUMBER,
			  p_entered_cr         IN NUMBER) IS
BEGIN

       IF g_debug = 'Y' THEN
         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'COPY_AP_RECORD - Start','C');
         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of parameter p_copy_from_index ='||p_copy_from_index,'C');
         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of parameter p_new_rec_index ='||p_new_rec_index,'C');
         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of parameter p_document_type ='||p_document_type,'C');
         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of parameter p_po_vendor_id ='||p_po_vendor_id,'C');
         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of parameter p_po_ind_com_set_id ='||p_po_ind_com_set_id,'C');
         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of parameter p_entered_dr ='||p_entered_dr,'C');
         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of parameter p_entered_cr ='||p_entered_cr,'C');
       END IF;

       g_je_source_name_tab(p_new_rec_index)     := g_je_source_name_tab(p_copy_from_index);
       g_je_category_name_tab(p_new_rec_index)   := g_je_category_name_tab(p_copy_from_index);
       g_actual_flag_tab(p_new_rec_index)        := g_actual_flag_tab(p_copy_from_index);
       g_project_id_tab(p_new_rec_index)         := g_project_id_tab(p_copy_from_index);
       g_task_id_tab(p_new_rec_index)            := g_task_id_tab(p_copy_from_index);
       g_award_id_tab(p_new_rec_index)           := g_award_id_tab(p_copy_from_index);
       g_entered_dr_tab(p_new_rec_index)         := p_entered_dr;
       g_entered_cr_tab(p_new_rec_index)         := p_entered_cr;
       g_etype_tab(p_new_rec_index)              := g_etype_tab(p_copy_from_index);
       g_exp_org_id_tab(p_new_rec_index)         := g_exp_org_id_tab(p_copy_from_index);
       g_exp_item_date_tab(p_new_rec_index)      := g_exp_item_date_tab(p_copy_from_index);
       g_document_type_tab(p_new_rec_index)      := g_document_type_tab(p_copy_from_index);
       g_doc_header_id_tab(p_new_rec_index)      := g_doc_header_id_tab(p_copy_from_index);
       g_doc_dist_id_tab(p_new_rec_index)        := g_doc_dist_id_tab(p_copy_from_index);
       g_prepay_std_inv_dist_id(p_new_rec_index) := g_prepay_std_inv_dist_id(p_copy_from_index);
       g_source_event_id_tab(p_new_rec_index)    := g_source_event_id_tab(p_copy_from_index);
       g_result_code_tab(p_new_rec_index)        := g_result_code_tab(p_copy_from_index);
       g_vendor_id_tab(p_new_rec_index)          := g_vendor_id_tab(p_copy_from_index);
       g_ind_cmp_set_id_tab(p_new_rec_index)     := g_ind_cmp_set_id_tab(p_copy_from_index);
       g_burdenable_raw_cost_tab(p_new_rec_index):= NULL;
       g_quantity_variance_tab(p_new_rec_index)  := NULL;
       g_amount_variance_tab(p_new_rec_index)    := NULL;
       g_po_distribution_id_tab(p_new_rec_index) := g_po_distribution_id_tab(p_copy_from_index);
       g_po_header_id_tab(p_new_rec_index)       := g_po_header_id_tab(p_copy_from_index);
       g_po_release_id_tab(p_new_rec_index)      := g_po_release_id_tab(p_copy_from_index);
       g_set_of_books_id_tab(p_new_rec_index)    := g_set_of_books_id_tab(p_copy_from_index);
       g_exp_category_tab(p_new_rec_index)       := g_exp_category_tab(p_copy_from_index);
       g_revenue_category_tab(p_new_rec_index)   := g_revenue_category_tab(p_copy_from_index);
       g_doc_dist_line_num_tab(p_new_rec_index)  := g_doc_dist_line_num_tab(p_copy_from_index);
       g_invoice_type_code_tab(p_new_rec_index)  := g_invoice_type_code_tab(p_copy_from_index);
       g_inv_source_tab(p_new_rec_index)         := g_inv_source_tab(p_copy_from_index);
       g_inv_dist_reference_1_tab(p_new_rec_index):= g_inv_dist_reference_1_tab(p_copy_from_index);
       g_inv_dist_reference_2_tab(p_new_rec_index):= g_inv_dist_reference_2_tab(p_copy_from_index);

       IF p_document_type = 'PO' THEN

	       g_je_source_name_tab(p_new_rec_index)     := 'Purchasing';
	       g_je_category_name_tab(p_new_rec_index)   := 'Purchases';
               g_document_type_tab(p_new_rec_index)      := 'PO';
               g_doc_header_id_tab(p_new_rec_index)      := NVL(g_po_release_id_tab(p_copy_from_index),g_po_header_id_tab(p_copy_from_index));
               g_doc_dist_id_tab(p_new_rec_index)        := g_po_distribution_id_tab(p_copy_from_index);
	       g_vendor_id_tab(p_new_rec_index)          := p_po_vendor_id;
	       g_ind_cmp_set_id_tab(p_new_rec_index)     := p_po_ind_com_set_id;
	       g_po_distribution_id_tab(p_new_rec_index) := NULL;
	       g_doc_dist_line_num_tab(p_new_rec_index)  := NULL;
	       g_invoice_type_code_tab(p_new_rec_index)  := NULL;
	       g_inv_source_tab(p_new_rec_index)         := NULL;
	       g_inv_dist_reference_1_tab(p_new_rec_index):= NULL;
	       g_inv_dist_reference_2_tab(p_new_rec_index):= NULL;

       END IF;

       IF g_debug = 'Y' THEN
         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'COPY_AP_RECORD - End','C');
       END IF;

EXCEPTION
WHEN OTHERS THEN
  IF g_debug = 'Y' THEN
     gms_error_pkg.gms_debug (g_error_procedure_name||':'||'COPY_AP_RECORD - exception'||SQLERRM,'C');
  END IF;
  RAISE;
END COPY_AP_RECORD;

-----------------------------------------------------------------------------------
-- R12 Funds management Uptake : New procedure to create additional records
-- for associated PO/RELEASE/AMOUNT variance/Quantity Variance while
-- fundschecking AP records.
-----------------------------------------------------------------------------------

PROCEDURE CREATE_BACKING_PO_APVAR_REC (p_copy_from_index    IN NUMBER,
                                       p_new_rec_index      IN OUT NOCOPY NUMBER,
				       p_po_vendor_id       IN NUMBER,
				       p_po_ind_com_set_id  IN NUMBER )  IS

l_new_rec_index             NUMBER; /*modified for bug:	7203553*/
l_entered_dr                NUMBER;
l_entered_cr                NUMBER;

BEGIN

       IF g_debug = 'Y' THEN
         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'CREATE_BACKING_PO_APVAR_REC - Start','C');
       END IF;

       -- Below is the logic of splitting AP line into multiple bc records
       -- 1.IF po_distribution id populated then create PO relieving record
       --   a. IF amount variance exists then
       --           Create new BC record for variance line since both AP line and variance
       --           are eligible for FC
       --   b. IF quantity varaince exists then
       --           Create new BC record for variance line since both main AP line and variance
       --           are eligible for FC .-- Functionality to be verified.

       l_new_rec_index  := p_new_rec_index  ;

       /* Bug 5614467 :
	    If the rate on the PO distribution is not null then
	      Calculate accounted amounts for PO relieving record from its entered amounts and rate
            Else
	      Copy accounted amounts for PO relieving record from those on the invoice */
       If g_po_rate_tab(p_copy_from_index) is NOT NULL then
         IF g_debug = 'Y' THEN
           gms_error_pkg.gms_debug (g_error_procedure_name||':'||'CREATE_BACKING_PO_APVAR_REC - Calculating accounted amounts for PO relieving record from its entered amounts and rate','C');
           gms_error_pkg.gms_debug (g_error_procedure_name||':'||'CREATE_BACKING_PO_APVAR_REC - Rate : '||g_po_rate_tab(p_copy_from_index),'C');
	 END IF;
         l_entered_dr := g_txn_cr_tab(p_copy_from_index) * g_po_rate_tab(p_copy_from_index);
         l_entered_cr := g_txn_dr_tab(p_copy_from_index) * g_po_rate_tab(p_copy_from_index);
       else
         IF g_debug = 'Y' THEN
           gms_error_pkg.gms_debug (g_error_procedure_name||':'||'CREATE_BACKING_PO_APVAR_REC - Copying accounted amounts for PO relieving record from those on the invoice','C');
	 END IF;
	 l_entered_dr := g_entered_cr_tab(p_copy_from_index);
         l_entered_cr := g_entered_dr_tab(p_copy_from_index);
       end if;
       IF g_debug = 'Y' THEN
         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'CREATE_BACKING_PO_APVAR_REC - PO relieving record - l_entered_dr : '||l_entered_dr,'C');
	 gms_error_pkg.gms_debug (g_error_procedure_name||':'||'CREATE_BACKING_PO_APVAR_REC - PO relieving record - l_entered_cr : '||l_entered_cr,'C');
       END IF;

       COPY_AP_RECORD   (p_copy_from_index    => p_copy_from_index,
                          p_new_rec_index     => l_new_rec_index,
			  p_document_type     => 'PO',
			  p_po_vendor_id      => p_po_vendor_id,
 		          p_po_ind_com_set_id => p_po_ind_com_set_id,
			  p_entered_dr        => l_entered_dr,
			  p_entered_cr        => l_entered_cr);

       IF NVL(g_amount_variance_tab(p_copy_from_index),0) <> 0 THEN

               IF g_debug = 'Y' THEN
                 gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Calling CREATE_APVAR_RECORD for amount varaince','C');
               END IF;

               l_new_rec_index := l_new_rec_index + 1;

	       IF g_amount_variance_tab(p_copy_from_index) <0 THEN
		       l_entered_dr := 0;
		       l_entered_cr := ABS(g_amount_variance_tab(p_copy_from_index));
               ELSE
		       l_entered_dr := ABS(g_amount_variance_tab(p_copy_from_index));
		       l_entered_cr := 0;
	       END IF;

	       COPY_AP_RECORD   (p_copy_from_index    => p_copy_from_index,
				  p_new_rec_index     => l_new_rec_index,
				  p_document_type     => 'AP',
				  p_po_vendor_id      => NULL,
				  p_po_ind_com_set_id => NULL,
				  p_entered_dr        => l_entered_dr,
				  p_entered_cr        => l_entered_cr);

	       /* Bug 5369296 : If the AP distribution is a reversing distribution (i.e parent_reversal_id is not  null) ,
	          then the burdenable raw cost on the amount/quantity variance records in gms_bc_packets is stamped as 0.
		  This is because after cancelling an invoice matched to a PO with quantity/amount variance the
		  burdenable raw cost for the reversing distribution is populated on the basis of that populated in
		  gms_award_distributions for the original distribution . The burdenable raw cost populated in
		  gms_award_distributions for the original distribution includes the burdenable raw cost for both the normal
		  distribution  amount and the quantity/amount variance amount. So during invoice cancel we should not
		  create the burden for the amount/quantity variance record in gms_bc_packets i.e the burdenable raw cost on the
		  quantity/amount variance record in gms_bc_packets for the reversing distribution should be zero. */

	       IF g_parent_reversal_id_tab(p_copy_from_index) is NOT NULL then
	               g_burdenable_raw_cost_tab(l_new_rec_index):= 0;
               END IF;

               IF g_debug = 'Y' THEN
                 gms_error_pkg.gms_debug (g_error_procedure_name||':'||'After call to CREATE_APVAR_RECORD for amount varaince','C');
               END IF;

       END IF; --IF NVL(g_tab_ap_amount_variance(p_copy_from_index),0) <> 0 THEN


       IF NVL(g_quantity_variance_tab(p_copy_from_index),0) <> 0 THEN

               IF g_debug = 'Y' THEN
                 gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Calling CREATE_APVAR_RECORD for qty varaince','C');
               END IF;

               l_new_rec_index := l_new_rec_index + 1;

	       IF g_quantity_variance_tab(p_copy_from_index) <0 THEN
		       l_entered_dr := 0;
		       l_entered_cr := ABS(g_quantity_variance_tab(p_copy_from_index));
               ELSE
		       l_entered_dr := ABS(g_quantity_variance_tab(p_copy_from_index));
		       l_entered_cr := 0;
	       END IF;

	       COPY_AP_RECORD   (p_copy_from_index    => p_copy_from_index,
				  p_new_rec_index     => l_new_rec_index,
				  p_document_type     => 'AP',
				  p_po_vendor_id      => NULL,
				  p_po_ind_com_set_id => NULL,
				  p_entered_dr        => l_entered_dr,
				  p_entered_cr        => l_entered_cr);

               -- Bug 5369296
	       IF g_parent_reversal_id_tab(p_copy_from_index) is NOT NULL then
	               g_burdenable_raw_cost_tab(l_new_rec_index):= 0;
               END IF;

               IF g_debug = 'Y' THEN
                 gms_error_pkg.gms_debug (g_error_procedure_name||':'||'After call to CREATE_APVAR_RECORD for qty varaince','C');
               END IF;

       END IF; --IF NVL(g_quantity_variance_tab(p_copy_from_index),0) <> 0 THEN

       p_new_rec_index := l_new_rec_index;

       IF g_debug = 'Y' THEN
         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'CREATE_BACKING_PO_APVAR_REC - End','C');
       END IF;

EXCEPTION
WHEN OTHERS THEN

       IF g_debug = 'Y' THEN
         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'CREATE_BACKING_PO_APVAR_REC - EXception','C');
       END IF;

  RAISE;

END CREATE_BACKING_PO_APVAR_REC;

-- =====================================================================================================
-- R12 Fundscheck Management uptake: AP/PO/REQ will no longer be saving data before firing fundscheck
-- hence existing logic in misc_gms_insert is modified such that code which needs access
-- to AP/PO/REQ tables uncommited gets fired in this main session procedure and insert/update code
-- gets fired in new autonomous procedures.
--
-- This Function fetches required data from PO/AP/REQ and stores in PLSQL tables.Later fires autonomous
-- procedure to insert into gms_bc_packets and update result codes.This is fired from main GL budgetory
-- control API.
-- for EXP and AP -Interface, insert is through gms_pa_costing_pkg
-- for ENC insert into gms_bc_packets takes place through GMS_FC_SYS Package
-- for Budget Submit/Baseline insert into gms_bc_packets takes place through GMS_BUDGET_BALANCE Package
-- =====================================================================================================

PROCEDURE copy_gl_pkt_to_gms_pkt (p_application_id      IN NUMBER,
                                  p_mode                IN  VARCHAR2 DEFAULT 'C',
				  p_partial_flag        IN  VARCHAR2 DEFAULT 'N',
                                  x_return_code         OUT NOCOPY VARCHAR2 ) IS

      -- -----------------------------------------------------------------------------------
      -- If the default award is not distributed and the document is sent for funds check
      -- the packet should fail with the correct failure result code.
      -- ----------------------------------------------------------------------------------
      l_dist_award_id           NUMBER;
      l_award_dist_option       VARCHAR2 (1);
      x_adl_rec                 gms_award_distributions%ROWTYPE;
      l_packet_id               gms_bc_packets.packet_id%TYPE;


      -- IP records are fetched by c_req_po_pkt_rec cursor as IP records will
      -- also be stored in po_bc_distributions

     -- Cursor to fetch REQ and PO data from po_bc_distributions
     -- This cursor fetches all data which has award_set_id populated
     -- Further ADL validations are done at later point in code

     CURSOR c_req_po_pkt_rec  IS
         SELECT pobc.ledger_id,
                'Purchasing'  je_source_name,
   		DECODE(pobc.distribution_type,
			    'REQUISTION','Requisitions',
                            'BLANKET'   ,'Release',
        		    'SCHEDULED' ,'Release',
			    'Purchases') je_category_name,
                'E' actual_flag,
                pobc.pa_project_id,
                pobc.pa_task_id,
                pobc.pa_award_id,
                pobc.accounted_amt, -- Bug 5614467
                pobc.event_type_code,
                pobc.main_or_backing_code,
                pobc.pa_exp_type,
                pobc.pa_exp_org_id,
                TRUNC (pobc.pa_exp_item_date),
                DECODE(pobc.distribution_type,'REQUISITION','REQ','PO'),
                pobc.header_id,
                pobc.distribution_id,
		et.expenditure_category,
		et.revenue_category_code,
		pobc.ae_event_id source_event_id,
                NULL,   -- result_code
		NULL, 	-- vendor_id
		NULL,   -- ind_cmp_set_id
		NULL,    -- burdenable_raw_cost
		pobc.reference6, -- For GMSIP
		pobc.reference13 --Vendor id for GMSIP transactions
           FROM po_bc_distributions pobc ,
                psa_bc_xla_events_gt xlaevt,
		pa_expenditure_types et,
                gms_project_types gpt,
                pa_projects_all pp
          WHERE pobc.ae_event_id = xlaevt.event_id
    	    AND pobc.pa_project_id IS NOT NULL
            AND pobc.pa_project_id = pp.project_id
            AND pp.project_type = gpt.project_type
            AND gpt.sponsored_flag = 'Y'
	    AND pobc.pa_exp_type = et.expenditure_type;


        CURSOR c_awrd_ap_dist IS
         SELECT apd.invoice_distribution_id,
/* Commenting for Bug 5645290
	        apd.line_type_lookup_code */
/* Added for Bug 5645290 */
                decode (apd.prepay_distribution_id ,NULL,line_type_lookup_code,'PREPAY')
/* Bug 5645290 - End */
           FROM psa_bc_xla_events_gt xlaevt,
                ap_invoice_distributions_all apd,
                gms_project_types gpt,
                pa_projects_all pp,
		ap_invoices_all apinv
          WHERE apd.bc_event_id = xlaevt.event_id
	    AND apd.project_id IS NOT NULL
            AND  apinv.invoice_id = apd.invoice_id
            AND apd.project_id = pp.project_id
            AND pp.project_type = gpt.project_type
            AND gpt.sponsored_flag = 'Y'
	    AND NVL (apd.pa_addition_flag, 'X' ) <> 'T'
            --AND  apinv.invoice_type_lookup_code <> 'EXPENSE REPORT' -- need to check if this check is required for Grants in R12
	    -- R12 : Prepayments mathed to PO will not be fundschecked
	    AND  ((apinv.invoice_type_lookup_code = 'PREPAYMENT'
	           AND apd.po_distribution_id IS NULL )
	           OR apinv.invoice_type_lookup_code <> 'PREPAYMENT')
	    --R12 : Application of Prepayment matched to PO will not be fundschecked
	    AND  ((apd.line_type_lookup_code ='PREPAY' AND
	             apd.po_distribution_id IS NULL) OR
                     apd.line_type_lookup_code <> 'PREPAY' );

        -- R12 Funds Management Uptake : This is the main cursor to fetch records from ap extracts
	-- for all eligible invoice distribution id's. This cursor fetches data for Standard Invoices
	-- and prepayments. Note : For prepayments there will be multiple lines for each invoice
	-- distribution as data is fetched from AP_PREPAY_APP_DISTS.
	-- Note : This cursor fetches only the AP dist record ,it doesnt fetch associated
	-- PO/RELEASE that has to be unreserved.

        /* AP's amount calculation logic for all type of invoices
	  (except prepay application) for populating entered amounts

           Its encumbrance_amount column for 'ERV',TERV ,ITEM ,IPV ,MISCELLANEOUS
           FREIGHT , NONREC_TAX,TIPV,TRV,FREIGHT,backing PO

           And ENCUMBRANCE_AMOUNT =NVL(AID.amount,0) - NVL(AID.amount_variance,0) -
           NVL(AID.quantity_variance,0)

           For amount variance extract column = AID_AMOUNT_VARIANCE
           For qty variance extract column = AID_QUANTITY_VARIANCE*/

	CURSOR cur_ap_bc_dist (p_stdinvoice_exists VARCHAR2,
	                       p_prepay_exists     VARCHAR2) IS
	 SELECT 'Payables'                                                                je_source_name,
   		'Purchase Invoices'                                                       je_category_name,
                'E'                                                                       actual_flag,
                apext.aid_project_id                                                      project_id,
                apext.aid_task_id                                                         task_id,
                apext.aid_award_id                                                          award_id,
	        DECODE(SIGN(apext.ENCUMBRANCE_BASE_AMOUNT),-1,0,apext.ENCUMBRANCE_BASE_AMOUNT)      entered_dr, -- Bug 5614467
		DECODE(SIGN(apext.ENCUMBRANCE_BASE_AMOUNT),-1,ABS(apext.ENCUMBRANCE_BASE_AMOUNT),0) entered_cr, -- Bug 5231395 -- Bug 5614467
	        DECODE(SIGN(apext.ENCUMBRANCE_AMOUNT),-1,0,apext.ENCUMBRANCE_AMOUNT)      txn_dr, -- Bug 5614467
		DECODE(SIGN(apext.ENCUMBRANCE_AMOUNT),-1,ABS(apext.ENCUMBRANCE_AMOUNT),0) txn_cr, -- Bug 5614467
                apext.aid_expenditure_type                                                expenditure_type,
                apext.aid_expenditure_org_id                                              org_id,
                NULL                                                                      expenditure_item_date,--populated in later code
                'AP'                                                                      document_type,
                apext.bus_flow_inv_id                                                     invoice_id,
                apext.aid_invoice_dist_id                                                 invoice_distribution_id,
		NULL                                                                      prepay_source_inv_id,
                apext.event_id                                                            source_event_id,
                NULL                                                                      result_code,
		NULL                                                                      vendor_id,
		NULL                                                                      ind_cmp_set_id,
		NULL                                                                      burdenable_raw_cost,
 	        apext.aid_base_quantity_variance                                          ap_quantity_variance, -- Bug 5614467
		apext.aid_base_amount_variance                                            ap_amount_variance, -- Bug 5614467
		/* Bug 5344693 : In the scenario where an Invoice is matched to a PO with variance , the ap_po_distribution_id,
		   ap_po_header_id and ap_po_release_id for the variance distribution should be NULL. */
                DECODE(apext.AID_LINE_TYPE_LOOKUP_CODE,'ITEM',apext.po_distribution_id
                                                      ,'ACCRUAL',apext.po_distribution_id
                                                      ,'NONREC_TAX',apext.po_distribution_id
                                                      ,NULL)                              ap_po_distribution_id,
                DECODE(apext.AID_LINE_TYPE_LOOKUP_CODE,'ITEM',DECODE(apext.po_distribution_id,NULL,NULL,apext.bus_flow_po_doc_id)
                                                      ,'ACCRUAL',DECODE(apext.po_distribution_id,NULL,NULL,apext.bus_flow_po_doc_id)
                                                      ,'NONREC_TAX',DECODE(apext.po_distribution_id,NULL,NULL,apext.bus_flow_po_doc_id)
                                                      , NULL )                            ap_po_header_id,
                DECODE(apext.AID_LINE_TYPE_LOOKUP_CODE,'ITEM',  DECODE(apext.bus_flow_po_dist_type,'RELEASE',apext.bus_flow_po_doc_id,NULL)
                                                      ,'ACCRUAL',DECODE(apext.bus_flow_po_dist_type,'RELEASE',apext.bus_flow_po_doc_id,NULL)
                                                      ,'NONREC_TAX',DECODE(apext.bus_flow_po_dist_type,'RELEASE',apext.bus_flow_po_doc_id,NULL)
                                                      ,NULL)                              ap_po_release_id,
		-- Below columns will be populated later in code
		NULL                                            			  set_of_books_id,
                NULL                                                                      exp_category,
                NULL                                         				  revenue_category,
                NULL                                       				  doc_dist_line_num,
		NULL                                         				  invoice_type_code,
                NULL                                                            	  inv_source,
                NULL                                      				  inv_dist_reference_1,
                NULL                                				          inv_dist_reference_2,
                NULL                                                                      ap_prepay_app_dist_id
          FROM  ap_extract_invoice_dtls_bc_v apext -- Bug 5500126
         WHERE  apext.aid_invoice_dist_id IN (select Column_Value from Table(g_ap_inv_dist_id))
	   AND  apext.event_id in ( SELECT event_id FROM psa_bc_xla_events_gt)
            	-- Bug 5238282 : Prepayment application will be treated as standard invoice line for check funds
		-- as there will be no data in ap_prepay_app_dists table.This table is populated during invoice
		-- validation.
/* Commenting the following condition for Bug 5645290
  	   AND  (p_mode ='C' OR (apext.aid_line_type_lookup_code <> 'PREPAY' AND p_mode <>'C')) */
/* Adding for Bug 5645290*/
           AND  exists (
                  select 1
                  from ap_invoice_distributions_all apd
                  where apd.invoice_distribution_id = apext.aid_invoice_dist_id
                  and ((apd.prepay_distribution_id is NULL AND p_mode <>'C') OR p_mode ='C' ))
/* Bug 5645290 - End */
	   AND  p_stdinvoice_exists = 'Y'
      UNION ALL
        SELECT  'Payables'                                                                je_source_name,
   		'Purchase Invoices'                                                       je_category_name,
                'E'                                                                       actual_flag,
                AID.project_id                                                            project_id,
                AID.task_id                                                               task_id,
                AID.award_id                                                              award_id,
	        DECODE(SIGN(APAD.BASE_AMOUNT),-1,0,APAD.BASE_AMOUNT)                      entered_dr, -- Bug 5614467
		DECODE(SIGN(APAD.BASE_AMOUNT),-1,ABS(APAD.BASE_AMOUNT),0)                 entered_cr, -- Bug 5231395 -- Bug 5614467
	        DECODE(SIGN(APAD.AMOUNT),-1,0,APAD.AMOUNT)                                txn_dr, -- Bug 5614467
		DECODE(SIGN(APAD.AMOUNT),-1,ABS(APAD.AMOUNT),0)                           txn_cr, -- Bug 5614467
                AID.expenditure_type                                                      expenditure_type,
                AID.expenditure_organization_id                                           org_id,
                NULL                                                                      expenditure_item_date, --populated later in code
                'AP'                                                                      document_type,
                AID.invoice_id                                                            invoice_id,
                APAD.Prepay_App_Distribution_ID                                           invoice_distribution_id,
		AID.invoice_distribution_id                                               prepay_source_inv_id,
                APPH.bc_event_id                                                          source_event_id,
                NULL                                                                      result_code,
		NULL                                                                      vendor_id,
		NULL                                                                      ind_cmp_set_id,
		NULL                                                                      burdenable_raw_cost,
 	        NULL                                                                      ap_quantity_variance,
		NULL                                                                      ap_amount_variance,
		AID.po_distribution_id                                                    ap_po_distribution_id,
                NULL                                                                      ap_po_header_id,
                NULL                                                                      ap_po_release_id,
		-- Below columns will be populated later in code
		NULL                                            			  set_of_books_id,
                NULL                                                                      exp_category,
                NULL                                         				  revenue_category,
                NULL                                       				  doc_dist_line_num,
		NULL                                         				  invoice_type_code,
                NULL                                                            	  inv_source,
                NULL                                      				  inv_dist_reference_1,
                NULL                                				          inv_dist_reference_2,
                APAD.prepay_app_dist_id                                                   ap_prepay_app_dist_id
                 -- Last col. will be used in Synch_gms_gl_packets ...
              FROM AP_PREPAY_HISTORY_ALL APPH,
                   AP_PREPAY_APP_DISTS APAD,
                   AP_INVOICE_LINES_ALL AIL,
                   AP_INVOICE_DISTRIBUTIONS_ALL AID
             WHERE AID.bc_event_id = APPH.bc_Event_id
               AND APPH.prepay_history_id = APAD.prepay_history_id
               AND AID.invoice_line_number = AIL.line_number
               AND AID.invoice_id = AIL.invoice_id
               AND AID.line_type_lookup_code IN ( 'PREPAY' ,'NONREC_TAX' ) --Bug 5490378
               and APPH.bc_Event_id IN ( SELECT event_id FROM psa_bc_xla_events_gt)
               and AID.invoice_distribution_id IN (select Column_Value from Table(g_ap_inv_dist_id))
               AND p_prepay_exists = 'Y'
               and aid.invoice_distribution_id = apad.prepay_app_distribution_id
	       and APAD.PREPAY_DIST_LOOKUP_CODE <> 'AWT';

     CURSOR c_req_adl_details (p_req_dist_id NUMBER) IS
       SELECT   adl.award_id,
                DECODE (
                   adl.award_id,
                   l_dist_award_id, 'F21',
                   DECODE (adl.award_id, NULL, 'F62', NULL)), --Bug Fix 1599750(2)-- RESULT CODE for missing ADLS F62
		pov.vendor_id,
    	        adl.ind_compiled_set_id
           FROM gms_award_distributions adl,
		po_requisition_lines_all porl,
                po_req_distributions_all pord,
		po_vendors pov
          WHERE pord.distribution_id = p_req_dist_id
            AND pord.project_id IS NOT NULL
            AND NVL (pord.award_id, l_dist_award_id) = adl.award_set_id
	    AND pord.requisition_line_id = porl.requisition_line_id
	    AND pord.distribution_id = NVL (adl.distribution_id, pord.distribution_id)
            AND pord.project_id = NVL (adl.project_id, pord.project_id)
            AND pord.task_id = NVL (adl.task_id, pord.task_id)
	    AND porl.suggested_vendor_name = pov.vendor_name (+)
            AND NVL (adl.adl_status, 'I') = 'A'
            AND NVL (adl.document_type, 'REQ') IN ('REQ', 'DST');


      CURSOR c_po_adl_details (p_po_dist_id NUMBER) IS
         SELECT adl.award_id,
                DECODE (
                   adl.award_id,
                   l_dist_award_id, 'F21',
                   NULL, 'F62',
		   decode(pll.accrue_on_receipt_flag, 'Y', 'F07',NULL)),
		poh.vendor_id,
	        adl.ind_compiled_set_id,
		pod.rate -- Bug 5614467
           FROM po_distributions_all pod,
		po_headers_all poh,
		po_lines_all   pol, --BUG 3022249
		po_line_locations_all pll, -- BUG 3022249
                gms_award_distributions adl
          WHERE pod.po_distribution_id = p_po_dist_id
            AND pod.project_id IS NOT NULL
	    AND pod.po_header_id = poh.po_header_id
	    and pol.po_header_id = poh.po_header_id
	    and pol.po_line_id   = pod.po_line_id
	    and pll.line_location_id = pod.line_location_id
	    and pll.po_line_id       = pol.po_line_id
            AND NVL (pod.award_id, l_dist_award_id) = adl.award_set_id
            AND pod.po_distribution_id = NVL (adl.po_distribution_id, pod.po_distribution_id)
            AND pod.project_id = NVL (adl.project_id, pod.project_id)
            AND pod.task_id = NVL (adl.task_id, pod.task_id)
            AND NVL (adl.adl_status, 'I') = 'A'	 			  	   -- Bug 2092791
            AND NVL (adl.document_type, 'PO') IN ('PO', 'DST');

      -- Bug 5231395
      -- Cursor to fetch AP data
      CURSOR c_ap_adl_details (p_ap_dist_id  NUMBER) IS
         SELECT apd.set_of_books_id,
                apd.expenditure_item_date,
		et.expenditure_category,
		et.revenue_category_code,
		apd.distribution_line_number,
		api.invoice_type_lookup_code,
                api.source,
		apd.reference_1,        --expenditure_item_id for ER imported to Payables from projects
		apd.reference_2,	--cdl_line_num for ER imported to Payables from projects
	        adl.award_id,
                DECODE (
                   adl.award_id,
                   l_dist_award_id, 'F21',
                   DECODE (adl.award_id, NULL, 'F62', NULL)), --Bug Fix 1599750(2)-- RESULT CODE for missing ADLS F62
		api.vendor_id,
 	        adl.ind_compiled_set_id ,                     --Bug 2456878
		/* Bug 5519731 : The following code is modified such that for a reversing invoice distribution if the parent invoice
		   distribution is interfaced to Grants then calculate the BRC else the burdenable raw cost for the reversing
		   distribution is the negative of the BRC for the parent distribution. */
		( SELECT decode(ap1.pa_addition_flag,'Y',NULL,-1 * nvl(adl1.burdenable_raw_cost,0)) --R12 AP Lines Uptake enhancement : Forward porting bug 4450291
		                                             -- Reversing AP distributions should copy the BRC from reversed Distribution
		    FROM gms_award_distributions adl1,
		         ap_invoice_distributions ap1
                   WHERE adl1.document_type = 'AP'
		     AND adl1.adl_status = 'A' -- Bug 5654186
		     AND adl1.fc_status = 'A'  -- Bug 5654186
		     AND ap1.invoice_id = apd.invoice_id
		     AND ap1.invoice_distribution_id = apd.parent_reversal_id
		     AND apd.reversal_flag = 'Y'
		     AND ap1.reversal_flag ='Y'
		     AND apd.parent_reversal_id IS NOT NULL
		     AND adl1.award_set_id = ap1.award_id
		     AND adl1.adl_line_num =1 ) burdenable_raw_cost ,
                apd.parent_reversal_id  parent_reversal_id  -- Bug 5369296
           FROM ap_invoice_distributions_all apd,
		ap_invoices_all api,
                gms_award_distributions adl,
   	        pa_expenditure_types et
          WHERE apd.invoice_distribution_id = p_ap_dist_id
            AND apd.project_id IS NOT NULL
            AND (NVL (apd.pa_addition_flag, 'X') <> 'T')
            AND NVL (apd.award_id, l_dist_award_id) = adl.award_set_id
            AND apd.invoice_id = NVL (adl.invoice_id, apd.invoice_id)
            AND apd.distribution_line_number =
                                     NVL (adl.distribution_line_number, apd.distribution_line_number)
            AND apd.invoice_distribution_id =
                                       NVL (adl.invoice_distribution_id, apd.invoice_distribution_id)
            AND apd.project_id = NVL (adl.project_id, apd.project_id)
            AND apd.task_id = NVL (adl.task_id, apd.task_id)
      	    AND apd.invoice_id = api.invoice_id
            AND NVL (adl.adl_status, 'I') = 'A'	 			  	   -- Bug 2092791
            AND NVL (adl.document_type, 'AP') IN ('AP', 'DST')
           -- AND NVL (adl.fc_status, 'X') <> 'A' --bug8771286
	    AND apd.expenditure_type = et.expenditure_type;


      -- Local variables
      l_document_type             gl_bc_packets.source_distribution_type%TYPE;
      l_gl_bc_pkt_spon_count      NUMBER;
      L_RETURN_CODE               VARCHAR2(1);
      l_mode                      VARCHAR2(1);
      l_prepay_exists             VARCHAR2(1);
      l_stdinvoice_exists         VARCHAR2(1);
      l_counter                   NUMBER;
      l_debug_start_counter       NUMBER;
      l_po_award_id               po_distributions_all.award_id%TYPE;
      l_po_result_code            gms_bc_packets.result_code%TYPE;
      l_po_vendor_id              po_headers_all.vendor_id%TYPE;
      l_po_ind_com_set_id         gms_award_distributions.ind_compiled_set_id%TYPE;

  -- Procedure to intialize PLSQL type variables
  PROCEDURE Intialize_tabs IS
  BEGIN
	  g_set_of_books_id_tab.delete;
	  g_je_source_name_tab.delete;
	  g_je_category_name_tab.delete;
	  g_actual_flag_tab.delete;
	  g_project_id_tab.delete;
	  g_task_id_tab.delete;
	  g_award_id_tab.delete;
	  g_result_code_tab.delete;
	  g_entered_dr_tab.delete;
	  g_entered_cr_tab.delete;
	  g_txn_dr_tab.delete; -- Bug 5614467
	  g_txn_cr_tab.delete; -- Bug 5614467
	  g_po_rate_tab.delete; -- Bug 5614467
	  g_etype_tab.delete;
	  g_exp_org_id_tab.delete;
	  g_exp_item_date_tab.delete;
	  g_document_type_tab.delete;
	  g_doc_header_id_tab.delete;
	  g_doc_dist_id_tab.delete;
	  g_vendor_id_tab.delete;
	  g_exp_category_tab.delete;
	  g_revenue_category_tab.delete;
	  g_ind_cmp_set_id_tab.delete;
	  g_burdenable_raw_cost_tab.delete; --R12 AP Lines Uptake enhancement : Forward porting bug 4450291
	  g_parent_reversal_id_tab.delete; -- Bug 5369296
	  g_doc_dist_line_num_tab.delete;
          g_invoice_type_code_tab.delete;
          g_inv_source_tab.delete;
          g_inv_dist_reference_1_tab.delete;
          g_inv_dist_reference_2_tab.delete;
	  g_source_event_id_tab.delete;
          g_entered_amount_tab.delete;
          g_event_type_code_tab.delete;
          g_main_or_backing_tab.delete;
	  g_ap_line_type_lkup.delete;
          g_prepay_std_inv_dist_id.delete;
          g_quantity_variance_tab.delete;
          g_amount_variance_tab.delete;
          g_po_distribution_id_tab.delete;
	  g_po_header_id_tab.delete;
	  g_po_release_id_tab.delete;
   END;

PROCEDURE DERIVE_DR_CR IS
BEGIN

   IF g_debug = 'Y' THEN
      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Start of DERIVE_DR_CR ','C');
   END IF;

   FOR l_index IN 1..g_set_of_books_id_tab.Last LOOP

     g_entered_dr_tab(l_index)   := 0;
     g_entered_cr_tab(l_index)   := 0 ;

     IF g_event_type_code_tab(l_index) IN ( 'PO_PA_RESERVED' ,
                                            'PO_PA_CR_MEMO_CANCELLED',
                                            'RELEASE_REOPEN_FINAL_CLOSED',
                                            'RELEASE_CR_MEMO_CANCELLED',
                                            'RELEASE_RESERVED',
                                            'REQ_RESERVED',
                                            'PO_REOPEN_FINAL_MATCH',
                                            -- g_tab_entered_amount and g_tab_accted_amount will be negative for below events
                                            'PO_PA_CANCELLED',
                                            'RELEASE_CANCELLED',
                                            'REQ_CANCELLED'
                                            ) THEN

       IF g_main_or_backing_tab(l_index) = 'M' THEN
          	g_entered_dr_tab(l_index)   := g_entered_amount_tab(l_index);
       ELSE
          	g_entered_cr_tab(l_index)   := g_entered_amount_tab(l_index);
       END IF;

    ELSIF g_event_type_code_tab(l_index) IN ('PO_PA_UNRESERVED' ,
                                             'PO_PA_FINAL_CLOSED',
                                             'PO_PA_REJECTED',
                                             'PO_PA_INV_CANCELLED',
                                             'RELEASE_FINAL_CLOSED',
                                             'RELEASE_INV_CANCELLED',
                                             'RELEASE_REJECTED',
                                             'RELEASE_UNRESERVED',
                                             'REQ_FINAL_CLOSED',
                                             'REQ_REJECTED',
                                             'REQ_RETURNED',
                                             'REQ_UNRESERVED',
                                             'REQ_ADJUSTED') THEN

       IF g_main_or_backing_tab(l_index) = 'M' THEN
          	g_entered_cr_tab(l_index)   := g_entered_amount_tab(l_index);
       ELSE
          	g_entered_dr_tab(l_index)   := g_entered_amount_tab(l_index);
       END IF;

    END IF;

    IF g_debug = 'Y' THEN
      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'value of  g_main_or_backing_tab '||g_main_or_backing_tab(l_index),'C');
      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'value of  g_event_type_code_tab '||g_event_type_code_tab(l_index),'C');
      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'value of  g_entered_cr_tab '||g_entered_cr_tab(l_index),'C');
      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'value of  g_entered_dr_tab '||g_entered_dr_tab(l_index),'C');
    END IF;


  END LOOP;

   IF g_debug = 'Y' THEN
      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'End of DERIVE_DR_CR ','C');
   END IF;

END DERIVE_DR_CR;

-- Main begin
BEGIN

  g_error_procedure_name := 'COPY_GL_PKT_TO_GMS_PKT';
  g_debug                := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N');
  l_mode                 := p_mode;

  -- 'A' mode passed for REQ/PO adjustment scenarios .This should be considered as reserve
  IF l_mode ='A' THEN
     l_mode := 'R';
  END IF;

  IF g_debug = 'Y' THEN
    gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Start','C');
  END IF;

  -- Initializing OUT variables
  x_return_code := 'P';
  l_award_dist_option := 'N';

  SELECT gms_bc_packets_s.nextval
    INTO l_packet_id
    FROM dual;

  IF g_debug = 'Y' THEN
      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Calling Intialize_tabs','C');
  END IF;

  Intialize_tabs;

  -- For AP/PO/REQ/IP records fire misc_synch_adls
  IF p_application_id in (200,201) THEN

               -- Fetch AP/PO/REQ data associted with sponsored Project.No other validations performed
	     IF p_application_id = 200 THEN -- Payables is the Calling application

                IF g_debug = 'Y' THEN
                    gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Inside p_application_id = 200 ','C');
                END IF;

                OPEN  c_awrd_ap_dist;
 	        FETCH c_awrd_ap_dist BULK COLLECT INTO  g_ap_inv_dist_id,g_ap_line_type_lkup;
                CLOSE c_awrd_ap_dist;

                IF g_debug = 'Y' THEN
                    gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Number of AP distribuions fetched ='||g_ap_inv_dist_id.count,'C');
                END IF;

		IF g_ap_inv_dist_id.count <> 0 THEN

		   l_prepay_exists := 'N';
                   l_stdinvoice_exists := 'N';

                   FOR i in 1..g_ap_line_type_lkup.count LOOP
		     -- Prepayment application will be treated as standard invoice line for check funds
		     -- as there will be no data in ap_prepay_app_dists table.This table is populated during invoice
		     -- validation.
		     IF g_ap_line_type_lkup(i) = 'PREPAY' AND p_mode <> 'C' THEN
		        l_prepay_exists := 'Y';
                     ELSE
		        l_stdinvoice_exists := 'Y';
		     END IF;
                     -- Exit the loop if both prepay and standard invoices exists.
		     IF l_prepay_exists= 'Y' AND l_stdinvoice_exists = 'Y' THEN
		        EXIT;
                     END IF;

		   END LOOP;

                   IF g_debug = 'Y' THEN
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'For current run there exists PREPAY distribution ? '||l_prepay_exists,'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'For current run there exists Std Invoice distribution ? '||l_stdinvoice_exists,'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Fetching required data from AP extract into plsql tables','C');
                   End if;

		   OPEN  cur_ap_bc_dist(l_stdinvoice_exists,l_prepay_exists);
		   FETCH cur_ap_bc_dist BULK COLLECT INTO
				  g_je_source_name_tab,
				  g_je_category_name_tab,
				  g_actual_flag_tab,
				  g_project_id_tab,
				  g_task_id_tab,
				  g_award_id_tab,
				  g_entered_dr_tab,
				  g_entered_cr_tab,
				  g_txn_dr_tab, -- Bug 5614467
				  g_txn_cr_tab, -- Bug 5614467
				  g_etype_tab,
				  g_exp_org_id_tab,
				  g_exp_item_date_tab,
				  g_document_type_tab,
				  g_doc_header_id_tab,
				  g_doc_dist_id_tab,
				  g_prepay_std_inv_dist_id,
				  g_source_event_id_tab,
			          g_result_code_tab,
		                  g_vendor_id_tab,
				  g_ind_cmp_set_id_tab,
				  g_burdenable_raw_cost_tab,
				  g_quantity_variance_tab,
				  g_amount_variance_tab,
                                  g_po_distribution_id_tab,
                                  g_po_header_id_tab,
				  g_po_release_id_tab,
               			  g_set_of_books_id_tab,
	                          g_exp_category_tab,
				  g_revenue_category_tab,
				  g_doc_dist_line_num_tab,
				  g_invoice_type_code_tab,
				  g_inv_source_tab,
				  g_inv_dist_reference_1_tab,
				  g_inv_dist_reference_2_tab,
                                  g_ap_prepay_app_dist_id;
                                  -- If you ever use limit, then there will be an issue as g_ap_prepay_app_dist_id
                                  -- is used in Synch_gms_gl_packets
                   CLOSE cur_ap_bc_dist;

                   IF g_debug = 'Y' AND g_doc_dist_id_tab.count <> 0 THEN
		     FOR i in 1..g_doc_dist_id_tab.count LOOP
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Start-Records fetched from AP extract'||-i,'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_je_source_name_tab ='||g_je_source_name_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_je_category_name_tab ='||g_je_category_name_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_actual_flag_tab ='||g_actual_flag_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_project_id_tab ='||g_project_id_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_task_id_tab ='||g_task_id_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_award_id_tab ='||g_award_id_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_entered_dr_tab ='||g_entered_dr_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_entered_cr_tab ='||g_entered_cr_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_etype_tab ='||g_etype_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_exp_org_id_tab ='||g_exp_org_id_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_exp_item_date_tab ='||g_exp_item_date_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_document_type_tab ='||g_document_type_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_doc_header_id_tab ='||g_doc_header_id_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_doc_dist_id_tab ='||g_doc_dist_id_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_prepay_std_inv_dist_id ='||g_prepay_std_inv_dist_id(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_source_event_id_tab ='||g_source_event_id_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_result_code_tab ='||g_result_code_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_vendor_id_tab ='||g_vendor_id_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_ind_cmp_set_id_tab ='||g_ind_cmp_set_id_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_burdenable_raw_cost_tab ='||g_burdenable_raw_cost_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_quantity_variance_tab ='||g_quantity_variance_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_amount_variance_tab ='||g_amount_variance_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_po_distribution_id_tab ='||g_po_distribution_id_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'End-Records fetched from AP extract'||-i,'C');
                     END LOOP;
                   End if;

		END IF;--IF g_ap_inv_dist_id.count <> 0 THEN

	     ELSIF p_application_id = 201 THEN  -- Purchasing is the Calling application

                   IF g_debug = 'Y' THEN
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Inside p_application_id = 201 ','C');
                   END IF;

		   OPEN c_REQ_PO_pkt_rec;
		   FETCH c_REQ_PO_pkt_rec BULK COLLECT INTO
				  g_set_of_books_id_tab,
				  g_je_source_name_tab,
				  g_je_category_name_tab,
				  g_actual_flag_tab,
				  g_project_id_tab,
				  g_task_id_tab,
				  g_award_id_tab,
                                  g_entered_amount_tab,
                                  g_event_type_code_tab,
                                  g_main_or_backing_tab,
				  g_etype_tab,
				  g_exp_org_id_tab,
				  g_exp_item_date_tab,
				  g_document_type_tab,
				  g_doc_header_id_tab,
				  g_doc_dist_id_tab,
				  g_exp_category_tab,
				  g_revenue_category_tab,
				  g_source_event_id_tab,
			          g_result_code_tab,
		                  g_vendor_id_tab,
				  g_ind_cmp_set_id_tab,
				  g_burdenable_raw_cost_tab,
				  g_reference6_tab,
				  g_reference13_tab;
		   CLOSE c_REQ_PO_pkt_rec;

                   IF g_doc_dist_id_tab.count <> 0 THEN
                         IF g_debug = 'Y' THEN
                              gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Calling DERIVE_DR_CR ','C');
                         END IF;
                         DERIVE_DR_CR;
                   END IF;

                   IF g_debug = 'Y' AND g_doc_dist_id_tab.count <> 0 THEN
		     FOR i in 1..g_doc_dist_id_tab.count LOOP
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Start-Records fetched from PO GT table'||-i,'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_set_of_books_id_tab ='||g_set_of_books_id_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_je_source_name_tab ='||g_je_source_name_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_je_category_name_tab ='||g_je_category_name_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_actual_flag_tab ='||g_actual_flag_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_project_id_tab ='||g_project_id_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_task_id_tab ='||g_task_id_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_award_id_tab ='||g_award_id_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_entered_amount_tab ='||g_entered_amount_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_entered_dr_tab ='||g_entered_dr_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_entered_cr_tab ='||g_entered_cr_tab(i),'C');
		      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_event_type_code_tab ='||g_event_type_code_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_main_or_backing_tab ='||g_main_or_backing_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_etype_tab ='||g_etype_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_exp_org_id_tab ='||g_exp_org_id_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_exp_item_date_tab ='||g_exp_item_date_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_document_type_tab ='||g_document_type_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_doc_header_id_tab ='||g_doc_header_id_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_doc_dist_id_tab ='||g_doc_dist_id_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_exp_category_tab ='||g_exp_category_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_revenue_category_tab ='||g_revenue_category_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_source_event_id_tab ='||g_source_event_id_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_result_code_tab ='||g_result_code_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_vendor_id_tab ='||g_vendor_id_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_ind_cmp_set_id_tab ='||g_ind_cmp_set_id_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_burdenable_raw_cost_tab ='||g_burdenable_raw_cost_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_reference6_tab ='||g_reference6_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_reference13_tab ='||g_reference13_tab(i),'C');
                      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'End-Records fetched from PO GT table '||-i,'C');
                     END LOOP;
                   End if;

	      END IF;

             IF g_debug = 'Y' THEN
                gms_error_pkg.gms_debug (g_error_procedure_name||':'||'After fetching data from AP/PO ','C');
             END IF;

   	     -- If no eligible GMS records to process then return with x_return_code as success ('P')
	     IF g_doc_dist_id_tab.count = 0 THEN
                 IF g_debug = 'Y' THEN
                    gms_error_pkg.gms_debug (g_error_procedure_name||':'||'NO records fetched from AP/PO extract,GOTO END_OF_PROCESS ','C');
                 END IF;
                GOTO END_OF_PROCESS;
             END IF;

	     IF g_debug = 'Y' THEN
		 gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Calling misc_synch_adls','C');
	     END IF;

	     IF NOT misc_synch_adls (p_application_id) THEN -- Bug 5344693 : misc_synch_adls is called with correct application_id.
		 x_return_code := 'F';
		 IF g_debug = 'Y' THEN
		    gms_error_pkg.gms_debug (g_error_procedure_name||':'||'misc_synch_adls returned false','C');
		 END IF;
		 -- misc_synch_adls raises if any exceptions so no need to handle exception
		 GOTO END_OF_PROCESS;
	     END IF;

             -- Start of Code to fire GMS specific validations

             IF g_debug = 'Y' THEN
                gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Fetching default award id ','C');
             END IF;

	     SELECT NVL (default_dist_award_id, 0),
		    NVL (award_distribution_option, 'N')
	       INTO l_dist_award_id,
		    l_award_dist_option
	       FROM gms_implementations;

             IF g_debug = 'Y' THEN
                gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Fetching default award id l_award_dist_option = '||l_award_dist_option,'C');
                gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Fetching default award id l_dist_award_id = '||l_dist_award_id,'C');
             END IF;

	     IF l_award_dist_option = 'Y' THEN

		      -- --------------------------------------------------------------------------+
		      -- Insert a dummy record into gms_award_distributions for the default award id
		      -- to remove the outer joints on gms_award_distributions.
		      -- --------------------------------------------------------------------------+
		      x_adl_rec.award_set_id := l_dist_award_id;
		      x_adl_rec.adl_line_num := 1;
		      x_adl_rec.document_type := 'DST';
		      x_adl_rec.award_id := l_dist_award_id;
		      x_adl_rec.adl_status := 'A';
		      x_adl_rec.fc_status := 'N';
		      x_adl_rec.last_update_date := SYSDATE;
		      x_adl_rec.last_updated_by := 0;
		      x_adl_rec.created_by := 0;
		      x_adl_rec.creation_date := SYSDATE ;
		      x_adl_rec.last_update_login := 0;
		      x_adl_rec.request_id := -9999;

		      IF g_debug = 'Y' THEN
			gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Calling gms_awards_dist_pkg.create_adls to create dummy ADL','C');
		      END IF;

		      gms_awards_dist_pkg.create_adls (x_adl_rec);

	     END IF;
	     l_counter := g_doc_dist_id_tab.count;
             --Below loop is to fetch additional information for each distribution
	     FOR i in 1..g_doc_dist_id_tab.count LOOP

		  IF g_document_type_tab(i) ='REQ' THEN

                      IF g_debug = 'Y' THEN
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Fetching REQ data for distribution id '||g_doc_dist_id_tab(i),'C');
                      END IF;

                      OPEN c_req_adl_details(g_doc_dist_id_tab(i));
		      FETCH c_req_adl_details INTO g_award_id_tab(i),
		                                   g_result_code_tab(i),
		                                   g_vendor_id_tab(i),
						   g_ind_cmp_set_id_tab(i);
                      IF c_req_adl_details%NOTFOUND THEN

                       IF g_reference6_tab(i) = 'GMSIP' THEN -- If its an unsaved Iprocurement
                          IF g_debug = 'Y' THEN
                             gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Its an unsaved GMSIP transaction' ,'C');
                          END IF;
                          IF g_award_id_tab(i)=l_dist_award_id THEN
                             g_result_code_tab(i) :='F21';
                          ELSIF g_award_id_tab(i) IS NULL THEN
                             g_result_code_tab(i) :='F62';
                          END IF;
                          g_vendor_id_tab(i) :=g_reference13_tab(i);
                       ELSE
                          IF g_debug = 'Y' THEN
                             gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Raising REQ Data transfer failure F09' ,'C');
                          END IF;
		          g_result_code_tab(i) := 'F09'; -- Data transfer failure
                       END IF; --F g_reference6_tab(i) = 'GMSIP' THEN

                      END IF;
		      CLOSE c_req_adl_details;

                      IF g_debug = 'Y' THEN
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_award_id_tab ='||g_award_id_tab(i),'C');
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_result_code_tab ='||g_result_code_tab(i),'C');
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_vendor_id_tab ='||g_vendor_id_tab(i),'C');
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_ind_cmp_set_id_tab ='||g_ind_cmp_set_id_tab(i),'C');
                      END IF;

                  ELSIF g_document_type_tab(i) ='PO' THEN

                      IF g_debug = 'Y' THEN
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Fetching PO data for distribution id '||g_doc_dist_id_tab(i),'C');
                      END IF;

                      OPEN c_po_adl_details(g_doc_dist_id_tab(i));
		      FETCH c_po_adl_details INTO  g_award_id_tab(i),
		                                   g_result_code_tab(i),
		                                   g_vendor_id_tab(i),
						   g_ind_cmp_set_id_tab(i),
						   g_po_rate_tab(i); -- Bug 5614467
                      IF c_po_adl_details%NOTFOUND THEN
                          IF g_debug = 'Y' THEN
                             gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Raising PO Data transfer failure F09' ,'C');
                         END IF;
		         g_result_code_tab(i) := 'F09'; -- Data transfer failure
                      END IF;
		      CLOSE c_po_adl_details;

                      IF g_debug = 'Y' THEN
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_award_id_tab ='||g_award_id_tab(i),'C');
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_result_code_tab ='||g_result_code_tab(i),'C');
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_vendor_id_tab ='||g_vendor_id_tab(i),'C');
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_ind_cmp_set_id_tab ='||g_ind_cmp_set_id_tab(i),'C');
                      END IF;


                  ELSIF g_document_type_tab(i) ='AP' THEN

                      IF g_debug = 'Y' THEN
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Fetching AP data for distribution id '||g_doc_dist_id_tab(i),'C');
                      END IF;

                      OPEN c_ap_adl_details(g_doc_dist_id_tab(i));
		      FETCH c_ap_adl_details INTO  g_set_of_books_id_tab(i),
		      				   g_exp_item_date_tab(i),
		                                   g_exp_category_tab(i),
						   g_revenue_category_tab(i),
						   g_doc_dist_line_num_tab(i),
						   g_invoice_type_code_tab(i),
						   g_inv_source_tab(i),
						   g_inv_dist_reference_1_tab(i),
						   g_inv_dist_reference_2_tab(i),
						   g_award_id_tab(i),
		                                   g_result_code_tab(i),
		                                   g_vendor_id_tab(i),
						   g_ind_cmp_set_id_tab(i),
						   g_burdenable_raw_cost_tab(i),
						   g_parent_reversal_id_tab(i); -- Bug 5369296
                      IF c_ap_adl_details%NOTFOUND THEN
                          IF g_debug = 'Y' THEN
                             gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Raising AP Data transfer failure F09' ,'C');
                         END IF;
		         g_result_code_tab(i) := 'F09'; -- Data transfer failure
                      END IF;
		      CLOSE c_ap_adl_details;

                      IF g_debug = 'Y' THEN
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_set_of_books_id_tab ='||g_set_of_books_id_tab(i),'C');
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_exp_item_date_tab ='||g_exp_item_date_tab(i),'C');
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_exp_category_tab ='||g_exp_category_tab(i),'C');
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_revenue_category_tab ='||g_revenue_category_tab(i),'C');
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_doc_dist_line_num_tab ='||g_doc_dist_line_num_tab(i),'C');
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_invoice_type_code_tab ='||g_invoice_type_code_tab(i),'C');
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_inv_source_tab ='||g_inv_source_tab(i),'C');
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_inv_dist_reference_1_tab ='||g_inv_dist_reference_1_tab(i),'C');
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_inv_dist_reference_2_tab( ='||g_inv_dist_reference_2_tab(i),'C');
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_award_id_tab ='||g_award_id_tab(i),'C');
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_result_code_tab ='||g_result_code_tab(i),'C');
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_vendor_id_tab ='||g_vendor_id_tab(i),'C');
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_ind_cmp_set_id_tab ='||g_ind_cmp_set_id_tab(i),'C');
                          gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_burdenable_raw_cost_tab ='||g_burdenable_raw_cost_tab(i),'C');
			  gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_parent_reversal_id_tab ='||g_parent_reversal_id_tab(i),'C');
                      END IF;

                      -- Code to check if there exists associated PO/Release and if exists create records
    		      -- to relieve amount variance/quantitiy variance AND PO
		      -- Note: Variance exists only if its PO matched distribution

    	              IF NVL(g_po_distribution_id_tab(i),0) <> 0 THEN


                         OPEN c_po_adl_details(g_po_distribution_id_tab(i));
		         FETCH c_po_adl_details INTO  l_po_award_id,
		                                      l_po_result_code ,
		                                      l_po_vendor_id,
						      l_po_ind_com_set_id,
						      g_po_rate_tab(i); -- Bug 5614467
                         IF c_po_adl_details%NOTFOUND THEN
                             IF g_debug = 'Y' THEN
                                gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Raising PO Data transfer failure F09' ,'C');
                             END IF;
		             g_result_code_tab(i) := 'F09'; -- Data transfer failure
                         ELSE
                             IF g_debug = 'Y' THEN
	                        pa_funds_control_pkg.log_message(p_msg_token1 => 'Calling CREATE_BACKING_PO_APVAR_REC ');
                             End if;

                             -- Creating PO relieving record by copying AP line record and overwriting required column values
                             l_counter := l_counter+1;
			     l_debug_start_counter:= l_counter;

		             CREATE_BACKING_PO_APVAR_REC(p_copy_from_index    => i,
		                                         p_new_rec_index      => l_counter, -- IN OUT VARIABLE
							 p_po_vendor_id       => l_po_vendor_id,
							 p_po_ind_com_set_id  => l_po_ind_com_set_id);

			     IF g_debug = 'Y' THEN
			       FOR i in l_debug_start_counter..g_doc_dist_id_tab.count LOOP
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Start-Records created by CREATE_BACKING_PO_APVAR_REC'||-i,'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_je_source_name_tab ='||g_je_source_name_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_je_category_name_tab ='||g_je_category_name_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_actual_flag_tab ='||g_actual_flag_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_project_id_tab ='||g_project_id_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_task_id_tab ='||g_task_id_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_award_id_tab ='||g_award_id_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_entered_dr_tab ='||g_entered_dr_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_entered_cr_tab ='||g_entered_cr_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_etype_tab ='||g_etype_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_exp_org_id_tab ='||g_exp_org_id_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_exp_item_date_tab ='||g_exp_item_date_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_document_type_tab ='||g_document_type_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_doc_header_id_tab ='||g_doc_header_id_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_doc_dist_id_tab ='||g_doc_dist_id_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_prepay_std_inv_dist_id ='||g_prepay_std_inv_dist_id(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_source_event_id_tab ='||g_source_event_id_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_result_code_tab ='||g_result_code_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_vendor_id_tab ='||g_vendor_id_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_ind_cmp_set_id_tab ='||g_ind_cmp_set_id_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_burdenable_raw_cost_tab ='||g_burdenable_raw_cost_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_quantity_variance_tab ='||g_quantity_variance_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_amount_variance_tab ='||g_amount_variance_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Value of g_po_distribution_id_tab ='||g_po_distribution_id_tab(i),'C');
			         gms_error_pkg.gms_debug (g_error_procedure_name||':'||'End-Records created by CREATE_BACKING_PO_APVAR_REC'||-i,'C');
			     END LOOP;
			   End if;

                          END IF;
		          CLOSE c_po_adl_details;

  	              END IF; --IF g_po_distribution_id_tab(i) IS NOT NULL THEN

                  END IF; --ELSIF g_document_type_tab(i) ='AP' THEN

              END LOOP;

	      IF NVL (l_award_dist_option, 'N') = 'Y' THEN

                  IF g_debug = 'Y' THEN
                     gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Deleting dummy ADL','C');
                  END IF;

		  DELETE gms_award_distributions
		   WHERE award_set_id = NVL (l_dist_award_id, 0)
		     AND document_type = 'DST'
		     AND adl_line_num = 1
	      	     AND adl_status = 'A'
		     AND request_id = -9999;
	     END IF;
   END IF; --IF p_application_id in (200,201) THEN

   IF g_debug = 'Y' THEN
      gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Calling Load_gms_pkts ','C');
   END IF;

   Load_gms_pkts (l_packet_id,
		  p_partial_flag,
		  g_set_of_books_id_tab,
		  g_je_source_name_tab,
		  g_je_category_name_tab,
		  g_actual_flag_tab,
		  g_project_id_tab,
		  g_task_id_tab,
		  g_award_id_tab,
		  g_result_code_tab,
		  g_entered_dr_tab,
		  g_entered_cr_tab,
		  g_etype_tab,
		  g_exp_org_id_tab,
		  g_exp_item_date_tab,
		  g_document_type_tab,
		  g_doc_header_id_tab,
		  g_doc_dist_id_tab,
		  g_vendor_id_tab,
		  g_exp_category_tab,
		  g_revenue_category_tab,
		  g_ind_cmp_set_id_tab,
		  g_burdenable_raw_cost_tab,--R12 AP Lines Uptake enhancement : Forward porting bug 4450291
		  g_source_event_id_tab,
		  l_return_code) ;


   x_return_code := l_return_code;

   -- R12 Funds Management uptake : Calling burdenable raw cost calculation logic for AP/PO/REQ from main session
   -- as access to AP/PO/REQ tables is required

   IF l_mode IN ('R','U','C') AND x_return_code = 'P' THEN

      -- Calling burdenable raw cost calculation
      IF NOT gms_cost_plus_extn.update_bc_pkt_burden_raw_cost (l_packet_id,l_mode,p_partial_flag) THEN
         x_return_code := 'F';
      END IF;

      -- Calling procedure to update failed status because of BRC calculation error
      update_bc_pkt_brc_status  ( l_packet_id,
                                  x_return_code,
				  p_partial_flag,
				  l_mode);
   END IF;

  -- If code reaches this point means that data has been correctly transferred from
  -- gl_bc_packets to gms_bc_packets ..

  <<END_OF_PROCESS>>
  NULL;

EXCEPTION
      WHEN OTHERS THEN
         IF l_award_dist_option = 'Y' THEN
            DELETE      gms_award_distributions
                  WHERE award_set_id = l_dist_award_id
                    AND document_type = 'DST'
                    AND adl_line_num = 1
                    AND adl_status = 'A'
                    AND request_id = -9999;
         END IF;

         IF g_debug = 'Y' THEN
	  	gms_error_pkg.gms_debug ('misc_gms_insert - Exception '||' SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM, 'C');
	 END IF;
         x_return_code := 'F';
END copy_gl_pkt_to_gms_pkt;


----------------------------------------------------------------------------------------------------------
-- This Module creates records for indirect cost for each resource record in a
-- packet.
----------------------------------------------------------------------------------------------------------

   FUNCTION misc_gms_idc (x_packet_id IN NUMBER)
      RETURN BOOLEAN IS
      doc_type   VARCHAR2 (10);
   BEGIN
      g_error_procedure_name := 'misc_gms_idc';
      SELECT document_type
        INTO doc_type
        FROM gms_bc_packets
       WHERE packet_id = x_packet_id
         AND nvl(burden_adjustment_flag,'N') = 'N'
         AND ROWNUM = 1;

-- ------------------------------------------------------------------
-- Indirect Cost should also be created for FAB to get funds checked.
-- ------------------------------------------------------------------
--  Begin Bug 2456878; three insert statements for doc_type 'EXP'/('AP', 'PO', 'REQ', 'FAB') have
--  been combined into one insert statement for perormance reasons. Also, redundant joins to table
--  have been removed

      IF doc_type IN ('AP', 'PO', 'REQ', 'FAB') THEN
         g_error_stage := 'MISC_IDC : AP,PO,REQ';
      ELSIF doc_type = 'EXP' THEN -- Expenditures
         g_error_stage := 'MISC_IDC : EXP';
      ELSIF doc_type = 'ENC' THEN -- Encumbrances
         g_error_stage := 'MISC_IDC : ENC';
      END IF;

      -- get the compile set id for 'AP', 'PO', 'REQ', 'FAB', 'ENC'.
      -- no need to get it for 'EXP'
      -- Fix for bug : 2927485 , Removed 'ENC'
      IF doc_type IN ('AP', 'PO', 'REQ', 'FAB' ) THEN
        -- populating compiled set id where ever it is null
        UPDATE gms_bc_packets gbc
        SET ind_compiled_set_id =  gms_cost_plus_extn.get_award_cmt_compiled_set_id (
                            gbc.task_id,
                            gbc.expenditure_item_date,
                            gbc.expenditure_type, --Bug 3003584
                            gbc.expenditure_organization_id,
                            'C',
                            gbc.award_id)
        WHERE gbc.packet_id = x_packet_id
        AND   gbc.status_code = 'P'
        AND   gbc.ind_compiled_set_id is null
	AND   nvl(gbc.burden_adjustment_flag,'N') = 'N'; -- 3389292

/* ====================================================================================
    Commented out for bug 3810247 : This code will move to stage 701 of gms_fck ..

     ELSIF doc_type = 'ENC' THEN

  	gms_error_pkg.gms_debug ('ENC1: Call calc_enc_ind_compiled_set_id ', 'C');
         -- Fix for bug : 2927485 : calculate ind_compiled_set_id for ENC
          CALC_ENC_IND_COMPILED_SET_ID (x_packet_id);

  	gms_error_pkg.gms_debug ('ENC2: Call Handle_net_zero_txn:Net_Zero ', 'C');
        -- Check if  adjusted and adjusting transactions are present in the same packet
        -- If so, update them with result_code 'P82' and update effect_on_funds_code
        -- to 'I' so that 'funds avilable' calculation ignores them.

            HANDLE_NET_ZERO_TXN(x_packet_id,'Net_Zero');

  	gms_error_pkg.gms_debug ('ENC3: Call Handle_net_zero_txn:Check_Adjusted ', 'C');
        --  Fail adjusting transaction, if original transaction has not been  FC'ed(F08)

            HANDLE_NET_ZERO_TXN(x_packet_id, 'Check_Adjusted');
 ======================================================================================== */

     END IF;


	             INSERT INTO gms_bc_packets
                     (packet_id,
                      project_id,
                      award_id,
                      task_id,
                      expenditure_type,
                      expenditure_item_date,
                      actual_flag,
                      status_code,
                      last_update_date,
                      last_updated_by,
                      created_by,
                      creation_date,
                      last_update_login,
                      set_of_books_id,
                      je_category_name,
                      je_source_name,
                      transfered_flag,
                      document_type,
                      expenditure_organization_id,
                      period_name,
                      period_year,
                      period_num,
                      document_header_id,
                      document_distribution_id,
                      top_task_id,
                      budget_version_id,
                      resource_list_member_id,
                      account_type,
                      entered_dr,
                      entered_cr,
                      tolerance_amount,
                      tolerance_percentage,
                      override_amount,
                      effect_on_funds_code,
                      result_code,
                      amount_type,
                      boundary_code,
                      time_phased_type_code,
                      categorization_code,
                      request_id,
                      gl_bc_packets_rowid,
                      bc_packet_id,
                      parent_bc_packet_id,
		      person_id,
		      job_id,
		      expenditure_category,
		      revenue_category,
		      adjusted_document_header_id,
		      award_set_id,
		      transaction_source,
		      burden_adjustment_flag,
		      burden_adj_bc_packet_id,
                      source_event_id,
                      session_id,
                      serial_id)
            SELECT /*+ index(gbc GMS_BC_PACKETS_N1) */ gbc.packet_id, /* Added the index hint for performance - Bug 5656276 */
                   gbc.project_id,
                   gbc.award_id,
                   gbc.task_id,
                   icc.expenditure_type,
                   TRUNC (gbc.expenditure_item_date),
                   gbc.actual_flag,
                   gbc.status_code,
                   gbc.last_update_date,
                   gbc.last_updated_by,
                   gbc.created_by,
                   gbc.creation_date,
                   gbc.last_update_login,
                   gbc.set_of_books_id,
                   gbc.je_category_name,
                   gbc.je_source_name,
                   gbc.transfered_flag,
                   gbc.document_type,
                   gbc.expenditure_organization_id,
                   gbc.period_name,
                   gbc.period_year,
                   gbc.period_num,
                   gbc.document_header_id,
                   gbc.document_distribution_id,
                   gbc.top_task_id,
                   gbc.budget_version_id,
                   gbc.resource_list_member_id,
                   gbc.account_type,
                   pa_currency.round_currency_amt(
                           decode(sign(gbc.BURDENABLE_RAW_COST * nvl(cm.compiled_multiplier,0)),
                                  1, gbc.burdenable_raw_cost * nvl(cm.compiled_multiplier, 0),
                                  0)), /* Bug 3620801 --entered_dr*/
                   pa_currency.round_currency_amt(
                           decode(sign(gbc.BURDENABLE_RAW_COST * nvl(cm.compiled_multiplier,0)),
                                  -1, abs(gbc.burdenable_raw_cost * nvl(cm.compiled_multiplier, 0)),
                                  0)), /* Bug 3620801 entered_cr*/
                   gbc.tolerance_amount,
                   gbc.tolerance_percentage,
                   gbc.override_amount,
                   gbc.effect_on_funds_code,
                   gbc.result_code,
                   gbc.amount_type,
                   gbc.boundary_code,
                   gbc.time_phased_type_code,
                   gbc.categorization_code,
                   gbc.request_id,
                   gbc.gl_bc_packets_rowid,
                   gms_bc_packets_s.NEXTVAL,
                   decode(gbc.burden_adjustment_flag,'Y',gbc.parent_bc_packet_id,gbc.bc_packet_id),
                    -- In case of burden adjustment flag, use parent_bc_packet_id on raw adjsutment line
		   gbc.person_id,
		   gbc.job_id,
		   et.expenditure_category,
		   et.revenue_category_code,
		   gbc.adjusted_document_header_id,
		   gbc.award_set_id,
		   gbc.transaction_source,
                   gbc.burden_adjustment_flag,
                   gbc.burden_adj_bc_packet_id,
                   gbc.source_event_id,
                   gbc.session_id,
                   gbc.serial_id
              FROM /*pa_ind_rate_sch_revisions irsr, Bug 5656276 */
                   pa_expenditure_types et,
                   pa_ind_cost_codes icc,
		   pa_cost_base_cost_codes cbcc, -- Bug 5656276
                   pa_cost_base_exp_types cbet,
                   /*pa_ind_compiled_sets ics, Bug 5656276 */
                   pa_compiled_multipliers cm,
                   gms_bc_packets gbc
             WHERE /*irsr.cost_plus_structure = cbet.cost_plus_structure Bug 5656276 */
                   et.expenditure_type = icc.expenditure_type -- 2092791 ( RLMI Change)
               AND icc.ind_cost_code = cm.ind_cost_code
               AND cbet.cost_base = cm.cost_base
	       AND cbcc.cost_plus_structure = cbet.cost_plus_structure
               AND cbet.cost_base_type = 'INDIRECT COST'
               /*AND ics.cost_base = cbet.cost_base -- Bug 3003584 Bug 5656276 */
               AND cbet.expenditure_type = gbc.expenditure_type
	       AND cbcc.cost_base = cbet.cost_base /* Bug 5656276 start */
	       AND cm.cost_base_cost_code_id = cbcc.cost_base_cost_code_id
	       AND cm.ind_cost_code = cbcc.ind_cost_code /* Bug 5656276 end */
               /*AND ics.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id
               AND ics.organization_id = gbc.expenditure_organization_id
               AND ics.ind_compiled_set_id = gbc.ind_compiled_set_id  Bug 5656276 */
               AND cm.ind_compiled_set_id = gbc.ind_compiled_set_id /* Bug 5656276 */
               AND cm.compiled_multiplier <> 0
               AND NVL (gbc.burdenable_raw_cost, 0) <> 0
               AND gbc.packet_id = x_packet_id
    	       AND status_code in ('I', 'P');


--  BUG  2456878
--  Three insert statements for doc_type 'EXP'/'ENC'/('AP', 'PO', 'REQ', 'FAB') have
--  been combined into one insert statement as coded above for perormance reasons.

      RETURN TRUE;
   END misc_gms_idc;

--===============================================================================================
/*             This Function updates following setup columns of gms_bc_packets
   	  		   budget_version_id
               amount_type
               boundary_code
               time_phased_type_code
               categorization_code
               resource_list_id
			   effect_on_funds_code
			   Note : Budget Version Id is updated only if it is null , in case of
			   		  Award budget submit/Baseline Process. Budget_version_id is inserted during
					  insertion of records in gms_bc_packets. So if budget_version_id is
					  alreay present this procedure will not update budget_version_id.

					  The earlier logic of calculating budget_version_id in case of
					  mode ('S'/'B') is removed, as budget_version_id logic is already
					  present while inserting records in gms_bc_packets.
*/
--===============================================================================================

   FUNCTION initialize_setup (x_packet_id IN NUMBER,
                              p_mode      IN VARCHAR2)
      RETURN BOOLEAN IS
      x_budget_version_id           gms_bc_packets.budget_version_id%TYPE;
      x_amount_type                 gms_bc_packets.amount_type%TYPE;
      x_boundary_code               gms_bc_packets.boundary_code%TYPE;
      x_time_phased_type_code       gms_bc_packets.time_phased_type_code%TYPE;
      x_categorization_code         gms_bc_packets.categorization_code%TYPE;
      x_project_id                  gms_bc_packets.project_id%TYPE;
      x_award_id                    gms_bc_packets.award_id%TYPE;
      x_dist_award_id               gms_bc_packets.award_id%TYPE;
      x_resource_list_id            gms_bc_packets.resource_list_id%TYPE;
      x_award_distribution_option   VARCHAR2 (10);
      CURSOR cur_init_setup IS
         SELECT DISTINCT project_id,
                         award_id,
                         budget_version_id
                    FROM gms_bc_packets
                   WHERE packet_id = x_packet_id
				     AND status_code in ('P','A')	--Bug 2143160
				   ;
   BEGIN
   	  g_error_procedure_name  :=  'initialize_setup';
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('Initilaze Setup - Start ', 'C');
      END IF;
      g_error_stage := 'INIT_SETUP : START';
      SELECT NVL (default_dist_award_id, 0),
             NVL (award_distribution_option, 'N')
        INTO x_dist_award_id,
             x_award_distribution_option
        FROM gms_implementations;
      OPEN cur_init_setup;
      LOOP
         FETCH cur_init_setup INTO x_project_id, x_award_id, x_budget_version_id;
         EXIT WHEN cur_init_setup%NOTFOUND
                OR x_award_id = NVL (x_dist_award_id, -1111);
		 BEGIN
         SELECT pb.budget_version_id,
                ga.amount_type,
                ga.boundary_code,
                pbm.time_phased_type_code,
                pbm.categorization_code,
                pb.resource_list_id
           INTO x_budget_version_id,
                x_amount_type,
                x_boundary_code,
                x_time_phased_type_code,
                x_categorization_code,
                x_resource_list_id
           FROM gms_budget_versions pb, pa_budget_entry_methods pbm, gms_awards ga
          WHERE ga.award_id = pb.award_id
            AND pb.project_id = x_project_id
            AND pb.award_id = x_award_id
            AND pb.budget_entry_method_code = pbm.budget_entry_method_code
            AND pb.award_id = ga.award_id
            AND pb.budget_version_id =
                      DECODE (x_budget_version_id, NULL, pb.budget_version_id, x_budget_version_id)
            AND pb.current_flag = DECODE (x_budget_version_id, NULL, 'Y', pb.current_flag);
       --   AND pb.budget_status_code = 'B'; -- (This code is commented because in 11I Funds Check is done in
                                               --  Budget Submit mode also )
         UPDATE gms_bc_packets
            SET budget_version_id = x_budget_version_id,
                amount_type = x_amount_type,
                boundary_code = x_boundary_code,
                time_phased_type_code = x_time_phased_type_code,
                categorization_code = x_categorization_code,
                resource_list_id = x_resource_list_id,
                -- Bug 2927485 : Added decode in following statement, we shouldn't
                -- override effect_on_funds_code if it is already populated
		effect_on_funds_code = DECODE(effect_on_funds_code,NULL,DECODE (SIGN (NVL (entered_dr, 0) - NVL (entered_cr, 0)), 1, 'D', 'I'),effect_on_funds_code) --Bug 2069132 ( code Transferred from setup_rlmi )
          WHERE packet_id = x_packet_id
            AND project_id = x_project_id
            AND award_id = x_award_id
 	        AND status_code in ('P','A')	--Bug 2143160
			;
	  EXCEPTION
	  	WHEN NO_DATA_FOUND THEN
         UPDATE gms_bc_packets
            SET result_code = 'F12',
		status_code = decode(p_mode,'S','E','C','F','R')
          WHERE packet_id = x_packet_id
            AND project_id = x_project_id
            AND award_id = x_award_id
 	        AND status_code in ('P','A');	--Bug 2143160
	  END;

      END LOOP;
      CLOSE cur_init_setup;
      g_error_stage := 'INIT_SETUP : END';
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('Initilize_Setup - End ', 'C');
      END IF;
      IF x_award_id = NVL (x_dist_award_id, -1111) THEN
         UPDATE gms_bc_packets
            SET status_code = decode(p_mode,'S','E','C','F','R'),
		result_code = 'F21',
                res_result_code = 'F21',
                res_grp_result_code = 'F21',
                task_result_code = 'F21',
                top_task_result_code = 'F21',
                award_result_code = 'F21'
          WHERE packet_id = x_packet_id;
		 RETURN FALSE;
      END IF;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         IF cur_init_setup%ISOPEN THEN
            CLOSE cur_init_setup;
         END IF;
         RAISE;
   END initialize_setup;

----------------------------------------------------------------------------------------------------------
-- Bug 2092791 : RLMI BULK Update Changes
-- 	   		   	 commented out NOCOPY old setup_rlmi procedure and written new setup_rlmi Procedure
--				 This change is made because of performance issue. The BULK Update feature will update
--				 This Procedure uses BULK UPDATE Feature which will update resource List Member Id
--				 in BULK using PL/SQL Table
-- Purpose :     Generating resource_list_member_id for the packet based on the resource list
--               and expenditure_type

--  --------------------*****-NOTE-******-------------------
--  SETUP_RLMI - Please don't use commit in this API.
--  THIS API IS SHARED WITH VERTICAL APPLICATION INTERFACE.
--  --------------------------------------------------------
----------------------------------------------------------------------------------------------------------

      PROCEDURE setup_rlmi (
      x_packet_id   IN       NUMBER,
      x_mode        IN       VARCHAR2,
      x_err_code    OUT NOCOPY      NUMBER,
      x_err_buff    OUT NOCOPY      VARCHAR2) IS
      TYPE t_doctype IS TABLE OF gms_bc_packets.document_type%TYPE;

      TYPE t_exptype IS TABLE OF gms_bc_packets.expenditure_type%TYPE;

      TYPE t_orgid IS TABLE OF gms_bc_packets.expenditure_organization_id%TYPE;

      TYPE t_personid IS TABLE OF gms_bc_packets.person_id%TYPE;

      TYPE t_jobid IS TABLE OF gms_bc_packets.job_id%TYPE;

      TYPE t_vendorid IS TABLE OF gms_bc_packets.vendor_id%TYPE;

      TYPE t_expcat IS TABLE OF gms_bc_packets.expenditure_category%TYPE;

      TYPE t_revcat IS TABLE OF gms_bc_packets.revenue_category%TYPE;

      TYPE t_catcode IS TABLE OF gms_bc_packets.categorization_code%TYPE;

      TYPE t_reslist IS TABLE OF gms_bc_packets.resource_list_id%TYPE;

      TYPE t_rowid IS TABLE OF VARCHAR2 (50);

      TYPE t_rlmi IS TABLE OF gms_bc_packets.resource_list_member_id%TYPE;

--      TYPE t_upg_err IS TABLE OF gms_award_distributions.upg_error%TYPE;  -- Bug 2178694

      TYPE t_fc_err IS TABLE OF gms_bc_packets.fc_error_message%TYPE;

      t_doc_type                   t_doctype;
      t_exp_type                   t_exptype;
      t_person_id                  t_personid;
      t_job_id                     t_jobid;
      t_vendor_id                  t_vendorid;
      t_org_id                     t_orgid;
      t_exp_cat                    t_expcat;
      t_rev_cat                    t_revcat;
      t_cat_code                   t_catcode;
      t_res_list                   t_reslist;
      t_row_id                     t_rowid;
      t_rlmi_value                 t_rlmi;
      t_fc_error                   t_fc_err;			-- Bug 2178694
      x_prev_list_processed        NUMBER (30);
      x_group_resource_type_id     NUMBER (15);
      x_group_resource_type_name   VARCHAR2 (60);
      x_resource_type_tab          gms_res_map.resource_type_table;
      x_budget_version_id          NUMBER;
      x_res_list_id                NUMBER;
      x_categorization_code        VARCHAR2 (1);
      --   x_err_code                   NUMBER;
      --   x_err_buff                   VARCHAR2 (2000);


      BEGIN

      IF initialize_setup (x_packet_id,x_mode) THEN

      --  ########### =========================================
      --  SETUP_RLMI - Please don't use commit in this API.
      --  THIS API IS SHARED WITH VERTICAL APPLICATION INTERFACE.
      --  ########### =========================================-

         g_error_stage := 'SETUP_RLMI : START';
         IF g_debug = 'Y' THEN
         	gms_error_pkg.gms_debug ('SETUP_RLMI - Start  ', 'C');
         END IF;
         g_error_procedure_name := 'setup_rlmi';

         IF x_mode <> 'U' THEN
            -- 1. Bulk Collect records

		-- --------------------------------------------------------
     		-- Bug 2069132 : Removed nvl for vendor_id,person_id,job_id
		-- --------------------------------------------------------
            SELECT   resource_list_id,
                     categorization_code,
                     document_type,
                     expenditure_type,
                     expenditure_organization_id,
                     expenditure_category,
                     revenue_category,
                     person_id,
                     job_id,
                     vendor_id,
                     ROWID,
                     resource_list_member_id,
                     fc_error_message
                BULK COLLECT INTO t_res_list,
                                  t_cat_code,
                                  t_doc_type,
                                  t_exp_type,
                                  t_org_id,
                                  t_exp_cat,
                                  t_rev_cat,
                                  t_person_id,
                                  t_job_id,
                                  t_vendor_id,
                                  t_row_id,
                                  t_rlmi_value,
                                  t_fc_error		-- Bug 2178694
                FROM gms_bc_packets
               WHERE packet_id = x_packet_id
                 AND status_code NOT IN ('F','R')                 -- Bug 2927485
		 AND resource_list_member_id is NULL
		 AND nvl(burden_adjustment_flag ,'N') = 'N' -- 3389292
            ORDER BY resource_list_id,
                     categorization_code,
                     document_type,
                     expenditure_type,
                     expenditure_organization_id,
                     expenditure_category,
                     person_id,
                     vendor_id,
                     job_id,
                     revenue_category ;

               g_error_stage := 'SETUP_RLMI : BULK COLLECT';
      -- 2. Bulk Processing
            IF t_row_id.COUNT > 0 THEN
               FOR bcpkt_records IN t_row_id.FIRST .. t_row_id.LAST
               LOOP
			   --  If The Value of following Variable is same as that of previous then don't calculate
			   --  resource_list_member_id again use the same resource list member_id
                  IF    t_row_id.PRIOR (bcpkt_records) IS NULL
                     OR (   (t_res_list (t_row_id.PRIOR (bcpkt_records)) <>  t_res_list (bcpkt_records))
                         OR (t_cat_code (t_row_id.PRIOR (bcpkt_records)) <>  t_cat_code (bcpkt_records))
                         OR (t_doc_type (t_row_id.PRIOR (bcpkt_records)) <>  t_doc_type (bcpkt_records))
                         OR (t_exp_type (t_row_id.PRIOR (bcpkt_records)) <>  t_exp_type (bcpkt_records))
                         OR (t_org_id (t_row_id.PRIOR (bcpkt_records))   <>  t_org_id (bcpkt_records))
                         OR (t_exp_cat (t_row_id.PRIOR (bcpkt_records))  <>  t_exp_cat (bcpkt_records))
                         OR (t_rev_cat (t_row_id.PRIOR (bcpkt_records))  <>  t_rev_cat (bcpkt_records))
                         OR (t_person_id (t_row_id.PRIOR (bcpkt_records))<>  t_person_id (bcpkt_records))
                         OR (t_job_id (t_row_id.PRIOR (bcpkt_records))   <>  t_job_id (bcpkt_records))
                         OR (t_vendor_id (t_row_id.PRIOR (bcpkt_records))<>  t_vendor_id (bcpkt_records))) THEN

      --               gms_error_pkg.gms_debug (
      --                        'Setup_rlmi - Debug  '|| t_exp_type (bcpkt_records),
      --                  'C');

                     gms_res_map.map_resources_group (
                        t_doc_type (bcpkt_records),
                        t_exp_type (bcpkt_records),
                        t_org_id (bcpkt_records),
                        t_person_id (bcpkt_records),
                        t_job_id (bcpkt_records),
                        t_vendor_id (bcpkt_records),
                        t_exp_cat (bcpkt_records),
                        t_rev_cat (bcpkt_records),
                        t_cat_code (bcpkt_records),
                        t_res_list (bcpkt_records),
                        NULL,
                        x_prev_list_processed,
                        x_group_resource_type_id,
                        x_group_resource_type_name,
                        x_resource_type_tab,
                        t_rlmi_value (bcpkt_records),
                        t_fc_error (bcpkt_records),
                        x_err_buff);

      --         gms_error_pkg.gms_debug ('Setup_rlmi - Resource List '||to_char(t_res_list(bcpkt_records)), 'C');
      --         gms_error_pkg.gms_debug ('Setup_rlmi - Cat Code '||t_cat_code(bcpkt_records), 'C');
      --         gms_error_pkg.gms_debug ('Setup_rlmi - Doc Type '||t_doc_type(bcpkt_records), 'C');
      --         gms_error_pkg.gms_debug ('Setup_rlmi - Exp Type '||t_exp_type(bcpkt_records), 'C');
      --         gms_error_pkg.gms_debug ('Setup_rlmi - Org Id '||t_org_id(bcpkt_records), 'C');
      --         gms_error_pkg.gms_debug ('Setup_rlmi - Exp Cat '||t_exp_cat(bcpkt_records), 'C');
      --         gms_error_pkg.gms_debug ('Setup_rlmi - Rev Cat '||t_rev_cat(bcpkt_records), 'C');
      --         gms_error_pkg.gms_debug ('Setup_rlmi - Person Id '||t_person_id(bcpkt_records), 'C');
      --         gms_error_pkg.gms_debug ('Setup_rlmi - Job Id '||t_job_id(bcpkt_records), 'C');
      --         gms_error_pkg.gms_debug ('Setup_rlmi - Vendor Id '||t_vendor_id(bcpkt_records), 'C');
      --         gms_error_pkg.gms_debug ('Setup_rlmi - RLMId '||t_rlmi_value(bcpkt_records), 'C');

                  ELSE
                     t_rlmi_value (bcpkt_records) :=
                                     t_rlmi_value (t_row_id.PRIOR (bcpkt_records));
                  END IF;
               END LOOP;
      --4. Bulk Update
               g_error_stage := 'SETUP_RLMI : BULK COLLECT';
               FORALL bcpkt_txns IN t_row_id.FIRST .. t_row_id.LAST
                  UPDATE gms_bc_packets
                     SET status_code = decode(t_rlmi_value (bcpkt_txns),NULL,decode(x_mode,'S','E','C','F','R'),status_code),
					 	 result_code = decode(t_rlmi_value (bcpkt_txns),NULL,'F94',result_code),
					 	 resource_list_member_id = t_rlmi_value (bcpkt_txns),
                         fc_error_message = t_fc_error (bcpkt_txns)		-- Bug 2178694
                   WHERE ROWID = t_row_id (bcpkt_txns);
            END IF;
         END IF;
      END IF;
      END setup_rlmi;


----------------------------------------------------------------------------------------------------------
--Procedure to calulate budgeted task id in packet for a budget version, entry level code and budget entry
--method and update gms_bc_packets for the same set of records having the same combinations.
--A single Update Statment will take care of Updating Budget task id for Following Budget Entry Methods
--      Budget Entry Method
--              P               By Project
--              T               By Top Task
--              L               By Lowest Task
--              M               By Top or Lowest Task
----------------------------------------------------------------------------------------------------------
   PROCEDURE budget_task_id_update (
      x_packetid   IN       NUMBER) IS
   BEGIN
      g_error_procedure_name := 'budget_task_id_update';
      -- if the budget entry level in 'L','T','P' -- update directly.
      g_error_stage := 'BUD_TASK_UPD :L,P,T';
      UPDATE gms_bc_packets bc
         SET (bc.bud_task_id, bc.top_task_id) =
                (SELECT DECODE (bem.entry_level_code, 'P', 0, 'L', bc.task_id, t.top_task_id),
                        DECODE (bem.entry_level_code, 'P', 0, t.top_task_id)
                   FROM pa_budget_entry_methods bem, gms_budget_versions bv,
                                                                            pa_tasks t
                  WHERE bv.budget_version_id = bc.budget_version_id
                    AND bv.budget_entry_method_code = bem.budget_entry_method_code
                    AND bem.entry_level_code IN ('P', 'L', 'T')
                    AND t.task_id = bc.task_id)
       WHERE bc.packet_id = x_packetid
        AND  bc.status_code = 'P'
	AND  bc.bud_task_id IS NULL
	AND  nvl(bc.burden_adjustment_flag,'N') = 'N'  -- 3389292
        AND EXISTS ( SELECT 1
                        FROM pa_budget_entry_methods bem1, gms_budget_versions bv1
                       WHERE bv1.budget_version_id = bc.budget_version_id
                         AND bv1.budget_entry_method_code = bem1.budget_entry_method_code
                         AND bem1.entry_level_code IN ('P', 'L', 'T'));

        IF g_debug = 'Y' THEN
        	gms_error_pkg.gms_debug('BUDGET_TASK_ID_UPDATE - Update for Entry Level code P,L,T Complete ','C');
        END IF;

       -- Added commit for the base bug 3848201
       commit;

      -- if the budget entry level = 'M' and budget at LOWEST TASK
        g_error_stage := 'BUD_TASK_UPD :M';
      UPDATE gms_bc_packets bc
         SET (bc.bud_task_id, bc.top_task_id) =
                (SELECT t.task_id,
                        t.top_task_id
                   FROM pa_budget_entry_methods bem, gms_budget_versions bv,
                                                                            pa_tasks t
                  WHERE bv.budget_version_id = bc.budget_version_id
                    AND bv.budget_entry_method_code = bem.budget_entry_method_code
                    AND bem.entry_level_code = 'M'
                    AND t.task_id = (SELECT task_id
                                       FROM gms_balances
                                      WHERE budget_version_id = bc.budget_version_id
                                        AND project_id = bc.project_id
                                        AND award_id = bc.award_id
                                        AND task_id = bc.task_id
                                        AND balance_type = 'BGT'
                                        AND ROWNUM = 1))
       WHERE bc.packet_id = x_packetid
         AND bud_task_id IS NULL
	     AND status_code = 'P';

       -- Added commit for the base bug 3848201
       commit;

      -- if the budget entry level = 'M' and budget at TOP TASK
      UPDATE gms_bc_packets bc
         SET (bc.bud_task_id, bc.top_task_id) =
                (SELECT t.task_id,
                        t.top_task_id
                   FROM pa_budget_entry_methods bem, gms_budget_versions bv,pa_tasks t
                  WHERE bv.budget_version_id = bc.budget_version_id
                    AND bv.budget_entry_method_code = bem.budget_entry_method_code
                    AND bem.entry_level_code = 'M'
                    AND t.task_id = (SELECT task_id
                                       FROM gms_balances
                                      WHERE task_id = (SELECT top_task_id
                                                         FROM pa_tasks
                                                        WHERE task_id = bc.task_id)
                                        AND budget_version_id = bc.budget_version_id
                                        AND project_id = bc.project_id
                                        AND award_id = bc.award_id
                                        AND balance_type = 'BGT'
                                        AND ROWNUM = 1))
       WHERE bc.packet_id = x_packetid
         AND bud_task_id IS NULL
	     AND status_code = 'P';

       -- Added commit for the base bug 3848201
       commit;

	IF g_debug = 'Y' THEN
        	gms_error_pkg.gms_debug('BUDGET_TASK_ID_UPDATE - Update for Entry Level code M Complete ','C');
        END IF;

-- If Bud Task Id is not updated till this point , then update bud_task_id with
-- task_id of expenditure
      g_error_stage := 'BUD_TASK_UPD :ELSE';
      UPDATE gms_bc_packets bc
         SET (bc.bud_task_id, bc.top_task_id) =
                (SELECT t.task_id,
                        t.top_task_id
                   FROM pa_tasks t
                  WHERE t.task_id = bc.task_id)
       WHERE bc.packet_id = x_packetid
         AND bc.bud_task_id IS NULL
	     AND status_code = 'P'
		 ;

       -- Added commit for the base bug 3848201
       commit;

   END budget_task_id_update;

----------------------------------------------------------------------------------------------------------
-- Procedure to calulate budgeted resource list id in packet for a budget version, entry level code and
-- budget entry method and update gms_bc_packets for the set of records having the same combinations.
----------------------------------------------------------------------------------------------------------

   PROCEDURE bud_res_list_id_update (
      x_packetid   IN       NUMBER) IS
   BEGIN
      g_error_procedure_name := 'bud_res_list_id_update';
      -- At Resource/Resource Group Level
      g_error_stage := 'BUD_RES_UPD :START';

      -- Bug 2605070, Only one stmt is needed to update the parent_resource_id
      UPDATE gms_bc_packets gms
         SET (parent_resource_id) =
                (SELECT pr.parent_member_id
                   FROM pa_resource_list_members pr
                  WHERE pr.resource_list_member_id = gms.resource_list_member_id
                    AND ROWNUM = 1)
       WHERE packet_id = x_packetid
       AND   status_code = 'P'
       AND   parent_resource_id is NULL
       AND   nvl(burden_adjustment_flag,'N') = 'N'; -- 3389292
   END bud_res_list_id_update;

----------------------------------------------------------------------------------------------------------
-- Procedure to update the funds control level code in a packet for a project, award, budget version,
-- budget entry method.
-- update gms_bc_packets for the set of records having the same combinations.
----------------------------------------------------------------------------------------------------------
   PROCEDURE funds_ctrl_level_code (
      x_packet_id   IN       NUMBER) IS
   BEGIN
      g_error_procedure_name := 'funds_ctrl_level_code';
      g_error_stage := 'FUND_CTRL_LEVEL_CODE : A';
-- Award Level
      UPDATE gms_bc_packets gms
         SET a_funds_control_level_code = (SELECT funds_control_level_code
                                             FROM gms_budgetary_controls gbc
                                            WHERE gbc.project_id = gms.project_id
                                              AND gbc.award_id = gms.award_id
                                              AND gbc.task_id IS NULL
                                              AND gbc.parent_member_id IS NULL
                                              AND gbc.resource_list_member_id IS NULL)
       WHERE packet_id = x_packet_id
	     AND status_code = 'P'
	   ;
        IF g_debug = 'Y' THEN
        	gms_error_pkg.gms_debug('FUNDS_CTRL_LEVEL_CODE - Update for Award Result code Complete ','C');
        END IF;
        g_error_stage := 'FUND_CTRL_LEVEL_CODE : TT';
-- Top Task Level
      UPDATE gms_bc_packets gms
         SET tt_funds_control_level_code = (SELECT funds_control_level_code
                                              FROM gms_budgetary_controls gbc
                                             WHERE gbc.project_id = gms.project_id
                                               AND gbc.award_id = gms.award_id
                                               AND gbc.task_id = gms.top_task_id
                                               AND gbc.parent_member_id IS NULL
                                               AND gbc.resource_list_member_id IS NULL)
       WHERE packet_id = x_packet_id
         AND bud_task_id <> 0
	     AND status_code = 'P'
		 ;

       -- Added commit for the base bug 3848201
       commit;

	IF g_debug = 'Y' THEN
        	gms_error_pkg.gms_debug('FUNDS_CTRL_LEVEL_CODE - Update for Top Task Result code Complete ','C');
        END IF;
        g_error_stage := 'FUND_CTRL_LEVEL_CODE : T';

-- Task Level
      UPDATE gms_bc_packets gms
         SET t_funds_control_level_code = (SELECT funds_control_level_code
                                             FROM gms_budgetary_controls gbc
                                            WHERE gbc.project_id = gms.project_id
                                              AND gbc.award_id = gms.award_id
                                              AND gbc.task_id = gms.task_id   -- bug 2579619 : gms.bud_task_id
                                              AND gbc.parent_member_id IS NULL
                                              AND gbc.resource_list_member_id IS NULL)
       WHERE packet_id = x_packet_id
         AND bud_task_id <> 0
	     AND status_code = 'P'
		 ;

       -- Added commit for the base bug 3848201
       commit;

	IF g_debug = 'Y' THEN
        	gms_error_pkg.gms_debug('FUNDS_CTRL_LEVEL_CODE - Update for Task Result code Complete ','C');
        END IF;
      --Task level funds control level code should set up only if budget entry method is by task
      --For project with resource level budget entry method task_id =0
-- Resource Group Level
      g_error_stage := 'FUND_CTRL_LEVEL_CODE : RG';
      UPDATE gms_bc_packets gms
         SET rg_funds_control_level_code = (SELECT funds_control_level_code
                                              FROM gms_budgetary_controls gbc
                                             WHERE gbc.project_id = gms.project_id
                                               AND gbc.award_id = gms.award_id
                                               AND gbc.task_id = gms.bud_task_id
                                               AND gbc.resource_list_member_id =
                                                                             gms.parent_resource_id
                                               AND gbc.parent_member_id = 0)
       WHERE packet_id = x_packet_id
         AND categorization_code <> 'N'
	     AND status_code = 'P'
		 ;

       -- Added commit for the base bug 3848201
       commit;

	IF g_debug = 'Y' THEN
        	gms_error_pkg.gms_debug('FUNDS_CTRL_LEVEL_CODE - Update for resource Group Result code Complete ','C');
        END IF;

-- Resource Level
      g_error_stage := 'FUND_CTRL_LEVEL_CODE : R';
      UPDATE gms_bc_packets gms
         SET r_funds_control_level_code = (SELECT funds_control_level_code
                                             FROM gms_budgetary_controls gbc
                                            WHERE gbc.project_id = gms.project_id
                                              AND gbc.award_id = gms.award_id
                                              AND gbc.task_id = gms.bud_task_id
                                              AND gbc.resource_list_member_id =
                                                                        gms.resource_list_member_id)
       WHERE packet_id = x_packet_id
         AND categorization_code <> 'N'
	     AND status_code = 'P'
		 ;

       -- Added commit for the base bug 3848201
       commit;

       IF g_debug = 'Y' THEN
       	gms_error_pkg.gms_debug('FUNDS_CTRL_LEVEL_CODE - Update for resource Level Result code Complete ','C');
       END IF;

-- If Funds control level code at any level is null
-- The update it to 'None'
      g_error_stage := 'FUND_CTRL_LEVEL_CODE : NONE';
      UPDATE gms_bc_packets gms
         SET r_funds_control_level_code =
                          DECODE (r_funds_control_level_code, NULL, 'N', r_funds_control_level_code),
             rg_funds_control_level_code =
                        DECODE (rg_funds_control_level_code, NULL, 'N', rg_funds_control_level_code),
             t_funds_control_level_code =
                          DECODE (t_funds_control_level_code, NULL, 'N', t_funds_control_level_code),
             tt_funds_control_level_code =
                   DECODE (tt_funds_control_level_code, NULL, 'N', tt_funds_control_level_code),
             a_funds_control_level_code =
                          DECODE (a_funds_control_level_code, NULL, 'N', a_funds_control_level_code)
       WHERE packet_id = x_packet_id
	     AND status_code = 'P'
	   ;

       -- Added commit for the base bug 3848201
       commit;

   END funds_ctrl_level_code;

----------------------------------------------------------------------------------------------------------
--Procedure to calculate start and end date for all amount type and boudary code combinations
----------------------------------------------------------------------------------------------------------
   PROCEDURE setup_start_end_date (
      x_packetid                IN       NUMBER,
      x_bc_packet_id            IN       NUMBER,
      x_project_id              IN       gms_bc_packets.project_id%TYPE,
      x_award_id                IN       gms_bc_packets.award_id%TYPE,
      x_budget_version_id       IN       gms_bc_packets.budget_version_id%TYPE,
      x_time_phased_type_code   IN       pa_budget_entry_methods.time_phased_type_code%TYPE,
      x_expenditure_item_date   IN       DATE,
      x_amount_type             IN       gms_awards.amount_type%TYPE,
      x_boundary_code           IN       gms_awards.boundary_code%TYPE,
      x_set_of_books_id         IN       gms_bc_packets.set_of_books_id%TYPE,

--      x_budgeted_task_id         IN       gms_bc_packets.bud_task_id%TYPE,
--      x_bud_res_list_member_id   IN       NUMBER,
      x_start_date              OUT NOCOPY      DATE,
      x_end_date                OUT NOCOPY      DATE) IS

-- Variables added to get the budgeted task,budgeted resource list member,start and end date for all amount type
-- and boundary code combinations.
      project_start_date     DATE;
      project_end_date       DATE;
      year_start_date        DATE;
      year_end_date          DATE;
      pa_period_start_date   DATE;
      pa_period_end_date     DATE;
      gl_period_start_date   DATE;
      gl_period_end_date     DATE;
      dr_period_start_date   DATE;
      dr_period_end_date     DATE;
      gs_start_date          DATE;
      gs_end_date            DATE;
      gb_end_date            DATE;
      exp_date               DATE;
	  x_err_code			 NUMBER;
	  x_err_buff			 VARCHAR2(500);

      x_error_code          VARCHAR2(1);
      -- BUG 5529930 11I.GMS:QA:PJMRP3B4: FC FAILURE WHEN PROJECT START PRIOR TO BUDGET STAR
      --
      l_gb_start_date        DATE ;
      l_gb_end_date          DATE ;

   BEGIN
      g_error_procedure_name := 'setup_start_end_date';
      --  Find the budget start date and budget end date (X_start_date, x_end_date)
      -- get project start date and end date
      x_err_code := 0; -- initialize error code
      IF (   x_time_phased_type_code = 'N'
          OR x_amount_type = 'PJTD'
          OR x_boundary_code = 'J') THEN
         g_error_stage := 'Project Start and End Date';

         SELECT start_date,
                completion_date
           INTO project_start_date,
                project_end_date
           FROM pa_projects_all
          WHERE project_id = x_project_id;

           -- Added for GMS enhancements : Bug : 5583170
           -- If time pjhase code is date range then
          if x_time_phased_type_code = 'R' then

            SELECT MIN (gb.start_date)
              INTO l_gb_start_date
              FROM gms_balances gb
             WHERE gb.budget_version_id = x_budget_version_id ;

            SELECT MAX (gb.END_date)
              INTO l_gb_end_date
              FROM gms_balances gb
             WHERE gb.budget_version_id = x_budget_version_id  ;

            --
            -- BUG 5529930 11I.GMS:QA:PJMRP3B4: FC FAILURE WHEN PROJECT START PRIOR TO BUDGET STAR
            --
	    IF project_start_date > l_gb_start_date  then
	       project_start_date := l_gb_start_date ;
	    END IF ;

	    IF project_end_date < l_gb_end_date  then
	       project_end_date := l_gb_end_date ;
	    END IF ;
	    --
	    -- End of Fix 5529930.

          end if;
         -- End of GMS enhancement changes.

         IF (project_end_date IS NULL) THEN

		  IF nvl(g_budget_version_id,0) <> x_budget_version_id THEN	-- Bug 2092791

            SELECT MAX (end_date) --Bug Fix 1828613 From
              INTO gb_end_date
              FROM gms_balances
             WHERE budget_version_id = x_budget_version_id;
            SELECT MAX (expenditure_item_date)
              INTO exp_date
              FROM gms_bc_packets
             WHERE budget_version_id = x_budget_version_id;

			 g_budget_version_id := x_budget_version_id;
			 g_gb_end_date		 := gb_end_date;
			 g_exp_date			 := exp_date;

		  ELSE

 		     gb_end_date := g_gb_end_date;	-- Bug 2092791
			 exp_date := g_exp_date;   -- Bug 2092791
		  END IF;	 -- Bug 2092791
            IF x_time_phased_type_code IN ('N', 'G', 'R') THEN
               SELECT TRUNC (gps.end_date)
                 INTO gl_period_end_date
                 FROM gl_period_statuses gps
                WHERE gps.application_id = 101
                  AND gps.set_of_books_id = x_set_of_books_id
                  AND TRUNC (exp_date) BETWEEN gps.start_date AND gps.end_date
                  AND gps.adjustment_period_flag = 'N';
               IF gl_period_end_date > gb_end_date THEN
                  project_end_date := gl_period_end_date;
               ELSE
                  project_end_date := gb_end_date;
               END IF;
            ELSIF x_time_phased_type_code = 'P' THEN
               SELECT TRUNC (end_date)
                 INTO pa_period_end_date
                 FROM pa_periods gpa
                WHERE TRUNC (exp_date) BETWEEN gpa.start_date AND gpa.end_date;
               IF pa_period_end_date > gb_end_date THEN
                  project_end_date := pa_period_end_date;
               ELSE
                  project_end_date := gb_end_date;
               END IF;
            END IF;
         ELSE
            IF x_time_phased_type_code = 'P' THEN
               g_error_stage := 'PJTD_J-P';
               BEGIN
                  SELECT TRUNC (end_date)
                    INTO gs_end_date
                    FROM pa_periods gpa
                   WHERE project_end_date BETWEEN gpa.start_date AND gpa.end_date;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT TRUNC (MAX (end_date))
                       INTO gs_end_date
                       FROM gms_balances
                      WHERE budget_version_id = x_budget_version_id;
               END;
               IF gs_end_date > project_end_date THEN
                  project_end_date := gs_end_date;
               END IF;
            ELSIF x_time_phased_type_code = 'G' THEN
               g_error_stage := 'PJTD_J-G';
               BEGIN
                  SELECT TRUNC (gps.end_date)
                    INTO gs_end_date
                    FROM gl_period_statuses gps
                   WHERE gps.application_id = 101
                     AND gps.set_of_books_id = x_set_of_books_id
                     AND project_end_date BETWEEN gps.start_date AND gps.end_date
                     AND gps.adjustment_period_flag = 'N';
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT TRUNC (MAX (end_date))
                       INTO gs_end_date
                       FROM gms_balances
                      WHERE budget_version_id = x_budget_version_id;
               END;
               IF gs_end_date > project_end_date THEN
                  project_end_date := gs_end_date;
               END IF;
            END IF;
         END IF; --Bug Fix 1828613 From
      END IF;
      -- get Financial year start and end dates
      IF (   x_amount_type = 'YTD'
          OR x_boundary_code = 'Y') THEN
         g_error_stage := 'Year Start and End Date';
         SELECT gps.year_start_date
           INTO year_start_date
           FROM gl_period_statuses gps
          WHERE gps.application_id = 101
            AND gps.set_of_books_id = x_set_of_books_id
            AND TRUNC (x_expenditure_item_date) BETWEEN gps.start_date AND gps.end_date
            AND gps.adjustment_period_flag = 'N';
         year_end_date := ADD_MONTHS (year_start_date, 12) - 1;
      END IF;
      -- get period start and end dates
      IF x_time_phased_type_code = 'G' THEN -- FOR GL period
        BEGIN --Added for bug#5474922
         g_error_stage := 'Time Phase = G';
         SELECT TRUNC (gps.start_date),
                TRUNC (gps.end_date)
           INTO gl_period_start_date,
                gl_period_end_date
           FROM gl_period_statuses gps
          WHERE gps.application_id = 101
            AND gps.set_of_books_id = x_set_of_books_id
            AND TRUNC (x_expenditure_item_date) BETWEEN gps.start_date AND gps.end_date
            AND gps.adjustment_period_flag = 'N';
       EXCEPTION --Added for bug#5474922
         WHEN NO_DATA_FOUND THEN
            gl_period_start_date := NULL;
            gl_period_end_date := NULL;
        END;
      ELSIF x_time_phased_type_code = 'P' THEN -- FOR PA period
         g_error_stage := 'Time Phase = P';
         SELECT TRUNC (start_date),
                TRUNC (end_date)
           INTO pa_period_start_date,
                pa_period_end_date
           FROM pa_periods gpa
          WHERE TRUNC (x_expenditure_item_date) BETWEEN gpa.start_date AND gpa.end_date;
      ELSIF x_time_phased_type_code = 'R' THEN -- FOR DATE RANGE
         g_error_stage := 'Time Phase R';
         /* ====================================================
         || The following code is the new logic for end_date
         || calc for date range and having boundary_code of
         || Period Bug 1622190
         ====================================================*/
         SELECT TRUNC (MAX (start_date)),
                TRUNC (MIN (end_date))
           INTO dr_period_start_date,
                dr_period_end_date
           FROM gms_balances
          WHERE project_id = x_project_id
            AND budget_version_id = x_budget_version_id
            AND award_id = x_award_id
            AND balance_type <> 'BGT'
            AND TRUNC (x_expenditure_item_date) BETWEEN start_date AND end_date;
         IF dr_period_start_date IS NULL THEN
            SELECT TRUNC (MAX (start_date)),
                   TRUNC (MIN (end_date))
              INTO dr_period_start_date,
                   dr_period_end_date
              FROM gms_balances
             WHERE project_id = x_project_id
               AND budget_version_id = x_budget_version_id
               AND award_id = x_award_id
               AND balance_type = 'BGT'
               AND TRUNC (x_expenditure_item_date) BETWEEN start_date AND end_date;
         END IF;
         IF dr_period_start_date IS NULL THEN
            SELECT TRUNC (gps.start_date),
                   TRUNC (gps.end_date)
              INTO dr_period_start_date,
                   dr_period_end_date
              FROM gl_period_statuses gps
             WHERE gps.application_id = 101
               AND gps.set_of_books_id = x_set_of_books_id
               AND TRUNC (x_expenditure_item_date) BETWEEN gps.start_date AND gps.end_date
               AND gps.adjustment_period_flag = 'N';
         END IF; --Bug 1622190
      END IF;
      -- Find the x_start_date and x_end_date
      IF x_time_phased_type_code = 'N' THEN -- for no time phase
         IF (   x_amount_type <> 'PJTD'
             OR x_boundary_code <> 'J') THEN
            gms_error_pkg.gms_message (
               'GMS_INVALID_AMT_TYPE_BND_CODE',
               'TIME_PHASED_CODE',
               x_time_phased_type_code,
               'AMOUNT_TYPE',
               x_amount_type,
               'BOUNDARY_CODE',
               x_boundary_code,
               x_exec_type=> 'C',
               x_err_code=> x_err_code,
               x_err_buff=> x_err_buff);

            Select decode(g_mode,'C','F','R') into x_error_code from dual;

            result_status_code_update (
               p_status_code=>x_error_code,
               p_result_code=> 'F78',
               p_packet_id=> x_packetid,
               p_bc_packet_id=> x_bc_packet_id);

            IF g_debug = 'Y' THEN
            	gms_error_pkg.gms_debug ('For time phase = N it should be project to date project', 'C');
            END IF;
         ELSE
            x_start_date := project_start_date;
            x_end_date := project_end_date;
         END IF;
      ELSIF x_time_phased_type_code IN ('P', 'G', 'R') THEN
         --Project to Date Start and End Date Calculations
           -- start date calc - PJTD
         IF x_amount_type = 'PJTD' THEN
            IF x_time_phased_type_code = 'P' THEN
               g_error_stage := 'PJTD1';
               BEGIN
                  SELECT TRUNC (start_date)
                    INTO gs_start_date
                    FROM pa_periods gpa
                   WHERE project_start_date BETWEEN gpa.start_date AND gpa.end_date;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT TRUNC (MIN (start_date))
                       INTO gs_start_date
                       FROM gms_balances
                      WHERE project_id = x_project_id
                        AND award_id = x_award_id
                        AND budget_version_id = x_budget_version_id
                        AND balance_type = 'BGT';
               END;
            ELSIF x_time_phased_type_code = 'G' THEN
               g_error_stage := 'PJTD2';
               BEGIN
                  SELECT TRUNC (gps.start_date)
                    INTO gs_start_date
                    FROM gl_period_statuses gps
                   WHERE gps.application_id = 101
                     AND gps.set_of_books_id = x_set_of_books_id
                     AND project_start_date BETWEEN gps.start_date AND gps.end_date
                     AND gps.adjustment_period_flag = 'N';
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT TRUNC (MIN (start_date))
                       INTO gs_start_date
                       FROM gms_balances
                      WHERE project_id = x_project_id
                        AND award_id = x_award_id
                        AND budget_version_id = x_budget_version_id
                        AND balance_type = 'BGT';
               END;
            ELSIF x_time_phased_type_code = 'R' THEN
               g_error_stage := 'PJTD3';
               SELECT TRUNC (MIN (start_date))
                 INTO gs_start_date
                 FROM gms_balances
                WHERE project_id = x_project_id
                  AND award_id = x_award_id
                  AND budget_version_id = x_budget_version_id
                  AND balance_type = 'BGT';
            END IF;
            IF gs_start_date < project_start_date THEN
               x_start_date := gs_start_date;
            ELSE
               x_start_date := project_start_date;
            END IF;
            -- end date calc for PJTD - Project
            IF x_boundary_code = 'J' THEN

-- ------------------------------------------------------------------------------------
-- Bug Fix 1828613 the above portion has been commented out NOCOPY replaced by the code below.
-- ------------------------------------------------------------------------------------
               IF x_time_phased_type_code IN ('P', 'G', 'R') THEN
                  x_end_date := project_end_date;
               END IF;
            -- end date calc for PJTD - Year
            ELSIF x_boundary_code = 'Y' THEN
               IF x_time_phased_type_code = 'P' THEN
                  g_error_stage := 'PJTD-Y-P';
                  BEGIN
                     SELECT p.end_date
                       INTO gs_end_date
                       FROM pa_periods p
                      WHERE year_end_date BETWEEN p.start_date AND p.end_date;
                     x_end_date := gs_end_date;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        x_end_date := year_end_date;
                  END;
               ELSIF x_time_phased_type_code = 'G' THEN
                  g_error_stage := 'PJTD-Y-G';
                  x_end_date := year_end_date;
               ELSIF x_time_phased_type_code = 'R' THEN
                  g_error_stage := 'PJTD-Y-R';
                  x_end_date := year_end_date;
               END IF;
            -- end date calc for PJTD - period
            ELSIF x_boundary_code = 'P' THEN
               g_error_stage := 'PJTD-P';
               IF x_time_phased_type_code = 'P' THEN
                  x_end_date := pa_period_end_date;
               ELSIF x_time_phased_type_code = 'G' THEN
                  x_end_date := gl_period_end_date;
               ELSIF x_time_phased_type_code = 'R' THEN
                  x_end_date := dr_period_end_date;
               END IF;
            -- end date calc for PJTD - period
            ELSE
               gms_error_pkg.gms_message (
                  'GMS_INVALID_AMT_TYPE_BND_CODE',
                  'TIME_PHASED_CODE',
                  x_time_phased_type_code,
                  'AMOUNT_TYPE',
                  x_amount_type,
                  'BOUNDARY_CODE',
                  x_boundary_code,
                  x_exec_type=> 'C',
                  x_err_code=> x_err_code,
                  x_err_buff=> x_err_buff);
               IF g_debug = 'Y' THEN
               	gms_error_pkg.gms_debug ('invalid end date for PJTD ', 'C');
               END IF;
            END IF;
         -- Year to Date - start and End date calculation
            -- start date calc - YTD
         ELSIF x_amount_type = 'YTD' THEN
            IF x_time_phased_type_code = 'P' THEN
               g_error_stage := 'YTD1';
               BEGIN
                  SELECT p.start_date
                    INTO gs_start_date
                    FROM pa_periods p
                   WHERE year_start_date BETWEEN p.start_date AND p.end_date;
                  x_start_date := gs_start_date;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     x_start_date := year_start_date;
               END;
            ELSIF x_time_phased_type_code = 'G' THEN
               g_error_stage := 'YTD2';
               x_start_date := year_start_date;
            ELSIF x_time_phased_type_code = 'R' THEN
               g_error_stage := 'YTD3';
               x_start_date := year_start_date;
            END IF;
            -- end date calc for YTD - year
            IF x_boundary_code = 'Y' THEN
               IF x_time_phased_type_code = 'P' THEN
                  g_error_stage := 'YTD-Y-P';
                  BEGIN
                     SELECT p.end_date
                       INTO gs_end_date
                       FROM pa_periods p
                      WHERE year_end_date BETWEEN p.start_date AND p.end_date;
                     x_end_date := gs_end_date;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        x_end_date := year_end_date;
                  END;
               ELSIF x_time_phased_type_code = 'G' THEN
                  g_error_stage := 'YTD-Y-G';
                  x_end_date := year_end_date;
               ELSIF x_time_phased_type_code = 'R' THEN
                  g_error_stage := 'YTD-Y-R';
                  x_end_date := year_end_date;
               END IF;
            -- end date calc for YTD - period
            ELSIF x_boundary_code = 'P' THEN
               g_error_stage := 'YTD-P';
               IF x_time_phased_type_code = 'P' THEN
                  x_end_date := pa_period_end_date;
               ELSIF x_time_phased_type_code = 'G' THEN
                  x_end_date := gl_period_end_date;
               ELSIF x_time_phased_type_code = 'R' THEN
                  x_end_date := dr_period_end_date;
               END IF;
            ELSE
               gms_error_pkg.gms_message (
                  'GMS_INVALID_AMT_TYPE_BND_CODE',
                  'TIME_PHASED_CODE',
                  x_time_phased_type_code,
                  'AMOUNT_TYPE',
                  x_amount_type,
                  'BOUNDARY_CODE',
                  x_boundary_code,
                  x_exec_type=> 'C',
                  x_err_code=> x_err_code,
                  x_err_buff=> x_err_buff);
               IF g_debug = 'Y' THEN
               	gms_error_pkg.gms_debug ('invalid end date for year to date year', 'C');
               END IF;
            END IF;
         --For Period to Date Period
         ELSIF x_amount_type = 'PTD' THEN
            IF x_boundary_code = 'P' THEN
               g_error_stage := 'PTD-P';
               IF x_time_phased_type_code = 'P' THEN
                  x_start_date := pa_period_start_date;
                  x_end_date := pa_period_end_date;
               ELSIF x_time_phased_type_code = 'G' THEN
                  x_start_date := gl_period_start_date;
                  x_end_date := gl_period_end_date;
               ELSIF x_time_phased_type_code = 'R' THEN
                  x_start_date := dr_period_start_date;
                  x_end_date := dr_period_end_date;
               END IF;
            ELSE
               gms_error_pkg.gms_message (
                  'GMS_INVALID_AMT_TYPE_BND_CODE',
                  'TIME_PHASED_CODE',
                  x_time_phased_type_code,
                  'AMOUNT_TYPE',
                  x_amount_type,
                  'BOUNDARY_CODE',
                  x_boundary_code,
                  x_exec_type=> 'C',
                  x_err_code=> x_err_code,
                  x_err_buff=> x_err_buff);
               IF g_debug = 'Y' THEN
               	gms_error_pkg.gms_debug ('invalid end date for period to date', 'C');
               END IF;
            END IF;
         ELSE
            gms_error_pkg.gms_message (
               'GMS_INVALID_AMT_TYPE_BND_CODE',
               'TIME_PHASED_CODE',
               x_time_phased_type_code,
               'AMOUNT_TYPE',
               x_amount_type,
               'BOUNDARY_CODE',
               x_boundary_code,
               x_exec_type=> 'C',
               x_err_code=> x_err_code,
               x_err_buff=> x_err_buff);
            IF g_debug = 'Y' THEN
            	gms_error_pkg.gms_debug ('invalid start date for any combination', 'C');
            END IF;
         END IF;
      ELSE
         gms_error_pkg.gms_message (
            'GMS_INVALID_AMT_TYPE_BND_CODE',
            'TIME_PHASED_CODE',
            x_time_phased_type_code,
            'AMOUNT_TYPE',
            x_amount_type,
            'BOUNDARY_CODE',
            x_boundary_code,
            x_exec_type=> 'C',
            x_err_code=> x_err_code,
            x_err_buff=> x_err_buff);
         IF g_debug = 'Y' THEN
         	gms_error_pkg.gms_debug ('invalid time phased type for any combination', 'C');
         END IF;
      END IF;
--      gms_error_pkg.gms_debug ('start start end date cal-start date'|| x_start_date, 'C');
--      gms_error_pkg.gms_debug ('start start end date cal-end date'|| x_end_date, 'C');
      --('After Date Check Process');
   END setup_start_end_date;

----------------------------------------------------------------------------------------------------------
-- This Procedure calls setup_start_end_date in a Cursor, For each Record in the Packet
-- The x_Start_date and x_end_date returned by the procedure will be assigned to
-- budget_period_start_date and budget_period_end_date
-- Due to performance issues the Procedure setup_start_end_date is called for only Raw Transactions only
-- The same start_date and end_date is used to update the Burden Lines also.
-- Here BULK Update of Oracle 8i is Used for Performance issues
----------------------------------------------------------------------------------------------------------

   PROCEDURE call_start_end_date_update (
      x_packetid   IN       NUMBER ,
      p_mode       IN       VARCHAR2) IS
      TYPE t_packetid IS TABLE OF gms_bc_packets.packet_id%TYPE;
      TYPE t_bcpktid  IS TABLE OF gms_bc_packets.bc_packet_id%TYPE;
      TYPE t_projid	  IS TABLE OF gms_bc_packets.project_id%TYPE;
      TYPE t_awardid  IS TABLE OF gms_bc_packets.award_id%TYPE;
      TYPE t_bvid 	  IS TABLE OF gms_bc_packets.budget_version_id%TYPE;
      TYPE t_tptypecd IS TABLE OF gms_bc_packets.time_phased_type_code%TYPE;
      TYPE t_expdate  IS TABLE OF gms_bc_packets.expenditure_item_date%TYPE;
      TYPE t_amttype  IS TABLE OF gms_bc_packets.amount_type%TYPE;
      TYPE t_boudrcd  IS TABLE OF gms_bc_packets.boundary_code%TYPE;
      TYPE t_sobid	  IS TABLE OF gms_bc_packets.set_of_books_id%TYPE;
      TYPE t_startdt  IS TABLE OF DATE;
      TYPE t_enddt	  IS TABLE OF DATE;
      TYPE t_errcode  IS TABLE OF NUMBER;
      TYPE t_errcbuff IS TABLE OF VARCHAR2(500);
      TYPE t_rowid IS TABLE OF VARCHAR2 (50);
	  t_packet_id     		   t_packetid ;
      t_bc_packet_id  		   t_bcpktid ;
      t_project_id	  		   t_projid ;
      t_award_id	  		   t_awardid ;
      t_budget_version_id	   t_bvid ;
      t_time_phased_type_code  t_tptypecd ;
      t_expenditure_item_date  t_expdate ;
      t_amount_type 		   t_amttype ;
      t_boundary_code		   t_boudrcd ;
      t_set_of_books_id		   t_sobid ;
      t_start_date			   t_startdt ;
      t_end_date			   t_enddt ;

	  x_err_code			   NUMBER;
	  x_err_buff			   VARCHAR2(500);

   BEGIN
      g_error_procedure_name := 'call_start_end_date_update';
      g_error_stage := 'CL_STEND_DATE:BLK COL';
         SELECT project_id,
                award_id,
                budget_version_id,
                time_phased_type_code,
                expenditure_item_date,
                amount_type,
                boundary_code,
                set_of_books_id,
                bc_packet_id,
				budget_period_start_date,
				budget_period_end_date
                BULK COLLECT INTO
					       t_project_id,
						   t_award_id,
						   t_budget_version_id,
						   t_time_phased_type_code,
						   t_expenditure_item_date,
						   t_amount_type,
						   t_boundary_code,
						   t_set_of_books_id,
						   t_bc_packet_id,
						   t_start_date,
						   t_end_date
                FROM gms_bc_packets
               WHERE packet_id = x_packetid
		     AND status_code = 'P'
				 AND parent_bc_packet_id IS NULL ;

	  --  Added following variables for Bug 2092791

	  /*  The Below variables are used in a scenario where project_end_date is NULL
	      instead of recalculating the end_date , calculate it only once for a packet
	  */

	  	  g_budget_version_id := NULL;
	  	  g_gb_end_date	 := NULL;
		  g_exp_date	:= NULL;

           IF t_bc_packet_id.COUNT > 0 THEN
               FOR bcpkt_records IN t_bc_packet_id.FIRST .. t_bc_packet_id.LAST
               LOOP
            setup_start_end_date (
               x_packetid,
               t_bc_packet_id (bcpkt_records ),
               t_project_id  (bcpkt_records ),
               t_award_id  (bcpkt_records ),
               t_budget_version_id  (bcpkt_records ),
               t_time_phased_type_code  (bcpkt_records ),
               t_expenditure_item_date  (bcpkt_records ),
               t_amount_type  (bcpkt_records ),
               t_boundary_code  (bcpkt_records ),
               t_set_of_books_id  (bcpkt_records ),
               t_start_date  (bcpkt_records ),
               t_end_date  (bcpkt_records ));
			 END LOOP;

	       -- Added commit for the base bug 3848201
               commit;

		--	END IF; -- Bug 2683607 : Commented , moved the END IF statement in the end
				-- so that all the FOR ALL statements are included in "IF t_bc_packet_id.COUNT > 0" check
            g_error_stage := 'CL_STEND_DATE:FORALL R';
            FORALL bcpkt_txns IN t_bc_packet_id.FIRST .. t_bc_packet_id.LAST
            UPDATE gms_bc_packets
               SET status_code = DECODE (
                                    t_start_date (bcpkt_txns),
                                    NULL, decode(p_mode,'S','E','C','F','R'),
                                    DECODE (t_end_date (bcpkt_txns), NULL, decode(p_mode,'S','E','C','F','R'), status_code)),
                   result_code = DECODE (
                                    t_start_date (bcpkt_txns),
                                    NULL, DECODE (
                                             t_time_phased_type_code (bcpkt_txns),
                                             'R', 'F95',
                                             'G', 'F79',
                                             'P', 'F73',
                                             'F78'),
                                    DECODE (
                                       t_end_date (bcpkt_txns),
                                       NULL, DECODE (
                                                t_time_phased_type_code (bcpkt_txns),
                                                'R', 'F95',
                                                'G', 'F79',
                                                'P', 'F73',
                                                'F78'),
                                       result_code)),
                   budget_period_start_date = t_start_date (bcpkt_txns),
                   budget_period_end_date = t_end_date (bcpkt_txns)
             WHERE bc_packet_id = t_bc_packet_id (bcpkt_txns);

           -- Added commit for the base bug 3848201
           commit;

-- Bug 2092791
-- This update statement is written to update the burden line with same budget_period_start_date and
-- budget_period_end_date  as that of raw line . This will restrict the call of date calculation
-- program once for each raw/burden transaction
            g_error_stage := 'CL_STEND_DATE:FORALL B';
            FORALL bcpkt_txns IN t_bc_packet_id.FIRST .. t_bc_packet_id.LAST
            UPDATE gms_bc_packets
               SET status_code = DECODE (
                                    t_start_date (bcpkt_txns),
                                    NULL, decode(p_mode,'S','E','C','F','R'),
                                    DECODE (t_end_date (bcpkt_txns), NULL, decode(p_mode,'S','E','C','F','R'), status_code)),
                   result_code = DECODE (
                                    t_start_date (bcpkt_txns),
                                    NULL, DECODE (
                                             t_time_phased_type_code (bcpkt_txns),
                                             'R', 'F95',
                                             'G', 'F79',
                                             'P', 'F73',
                                             'F78'),
                                    DECODE (
                                       t_end_date (bcpkt_txns),
                                       NULL, DECODE (
                                                t_time_phased_type_code (bcpkt_txns),
                                                'R', 'F95',
                                                'G', 'F79',
                                                'P', 'F73',
                                                'F78'),
                                       result_code)),
                   budget_period_start_date = t_start_date (bcpkt_txns),
                   budget_period_end_date = t_end_date (bcpkt_txns)
   		   WHERE parent_bc_packet_id = t_bc_packet_id (bcpkt_txns);
	   END IF; -- Bug 2683607 : Added

       -- Added commit for the base bug 3848201
       commit;

   END call_start_end_date_update;
   -- Bug 2039271

----------------------------------------------------------------------------------------------------------
-- This Procedure locks the gms_concurrency_control table before inserting record into
-- gms_bc_packet_arrival_order, once record is inserted lock is released.
----------------------------------------------------------------------------------------------------------

   PROCEDURE set_concurrency_tab IS
      l_sys_date   DATE;
      x_err_code   NUMBER;
   BEGIN
      g_error_procedure_name := 'set_concurrency_tab';
      g_error_stage := 'SET_CONCURR_TAB: START';
      SELECT SYSDATE
        INTO l_sys_date
        FROM DUAL;
      SELECT     0
            INTO x_err_code
            FROM gms_concurrency_control
           WHERE process_name = 'GMSFCTRL'
      FOR UPDATE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         g_error_stage := 'SET_CONCURR_TAB:NO.D.FND';
         LOCK TABLE gms_concurrency_control IN EXCLUSIVE MODE;
         INSERT INTO gms_concurrency_control
                     (process_name,
                      process_key,
                      request_id,
                      last_update_date,
                      last_updated_by,
                      created_by,
                      creation_date,
                      last_update_login)
              VALUES ('GMSFCTRL',
                      0,
                      0,
                      l_sys_date,
                      -1,
                      -1,
                      l_sys_date,
                      -1);
      WHEN OTHERS THEN
         g_error_stage := 'SET_CONCURR_TAB:OTH';
         RAISE;
   END set_concurrency_tab;


----------------------------------------------------------------------------------------------------------
-- This Procedure inserts record in gms_bc_packet_arrival_order, once record is inserted lock is released.
-- from gms_concurrency_control using COMMIT;

--  gms_bc_packet_arrival_order Table will store the order in which packets
--  have completed there setup and are ready for funds check.
--  This is required becase packets arrived later can pass fundscheck as setup
--  has not been completed for large packets arrived before.
----------------------------------------------------------------------------------------------------------


   PROCEDURE insert_arrival_order_seq (
      x_packetid   IN       NUMBER,
	  x_mode	   IN		VARCHAR2) IS

	  x_err_code   			NUMBER;
	  x_arrival_order_seq           NUMBER;	  -- Bug 2176230

   BEGIN

	  g_error_procedure_name  :=   	'insert_arrival_order_seq';

	COMMIT;

  IF x_mode IN ('R', 'U', 'C', 'E') THEN

   -- ****** ===================================================
   -- Following procedure was defined to resolve missing control
   -- record into concurrency table.
   -- ****** ===================================================
    set_concurrency_tab;
    g_error_stage := 'IN ARRIVAL ORD: R,U,C,E';
    SELECT     0
      INTO x_err_code
      FROM gms_concurrency_control
     WHERE process_name = 'GMSFCTRL'
	   FOR UPDATE;

	 -- Bug 2176230
	 SELECT gms_bc_packet_arrival_order_s.NEXTVAL
	   INTO x_arrival_order_seq
	   FROM DUAL;


	 -- Bug 2176230 : Commit only in case of check funds mode as gms_bc_packet_arrival_order record
	 --               is not going to be committed,to restrict the accounting of these transactions
	 --               in subsequent packets.

	 IF x_mode = 'C' THEN
	   COMMIT;
	 END IF;

	/***********************  GMS Arrival Order Sequence ***************************/
	--*******************************************************************************
	--  Note : The Insert statement below should always be the last statement of the
	--         setup, Before actual funds check happens. Do Not write any code after
	--         this insert statement.
	--*******************************************************************************
    g_error_stage := 'IN ARRIVAL ORD: INSRT';
            INSERT INTO gms_bc_packet_arrival_order
                        (packet_id,
                         arrival_seq,
                         last_update_date,
                         last_updated_by)
                 VALUES (x_packetid,
                         x_arrival_order_seq,	   -- Bug 2176230
                         SYSDATE,
                         fnd_global.user_id);


	 -- Bug 2176230 : Commit only if mode is not check funds mode This is to enable
	 --               the accounting of these transactions in subsequent packets.

	  IF nvl(x_mode,'X') <> 'C' THEN
	    COMMIT;
	  END IF;
   END IF;
   END insert_arrival_order_seq;

----------------------------------------------------------------------------------------------------------
-- This Procedure updated the burdened_cost column of gms_bc_packets .
-- For EXP/PO/AP/REQ/ENC the Burdened cost = Raw Cost + Burdne Cost
-- For Re-Costed Expenditures Burdened COst = Sum ( Raw Cost + Burden Cost ) of all the CDL's of that
-- 	   			 			  		   		  expenditure item id.
----------------------------------------------------------------------------------------------------------

   PROCEDURE update_burdened_cost (
      x_packetid   IN       NUMBER ) IS
   BEGIN
    g_error_procedure_name  :=  'update_burdened_cost';
    g_error_stage := 'UPD_BURDN_COST : START';
   	-- --------------------------------------
    -- UPDATE BURDENED COST ON GMS_BC_PACKETS
    -- BURDENED COST = RAW COST + BURDEN COST.
    -- --------------------------------------
-- Bug 2092791
        UPDATE gms_bc_packets a
             SET burdened_cost =
                    (SELECT SUM ( NVL(entered_dr,0) - NVL(entered_cr,0) )
                       FROM gms_bc_packets b
                      WHERE b.packet_id + 0 = a.packet_id /* Bug 5689194 */
                        AND b.document_type = a.document_type
                        AND b.document_header_id = a.document_header_id
                        AND ((b.document_type='EXP')
                             OR (b.document_type<>'EXP'  AND
                                 b.document_distribution_id = a.document_distribution_id
                                 )
                             )
                    )
           WHERE packet_id = x_packetid
		     AND status_code = 'P'
		   ;
   END update_burdened_cost;

----------------------------------------------------------------------------------------------------------
-- This Function checks for Setup Failure
--
-- In Full Mode    (x_partial = N) If one Transaction failed setup entire Packet is marked at failed
-- In Partila Mode (x_partial = Y) If one Transaction failed setup only that Expenditure is marked with
-- 	  	   				   	       failure.
--								   In Case of partial Mode, care has been taken to modify result_code to
--								   F63/F75/F65 for raw pass burden fail/burden pass raw fail/recosted
--								   Scenarios if any one of the expenditure failed Setup.
----------------------------------------------------------------------------------------------------------

   FUNCTION check_setup_failure (
      x_packetid   IN       NUMBER,
	  x_partial	   IN		VARCHAR2) RETURN BOOLEAN IS

	  x_err_count  NUMBER;
/*

        -- The Update Statement below will mark the Transactions which are having Setup Data Missing
        -- With the result_code as follows
        -- F12  : Funds checking Failed becuase of Invalid Budget Version
        -- F13  : Funds checking Failed becuase of Invalid Resource List Member
        -- F14  : Funds checking Failed becuase of Invalid Budgeted Resource List Member
        -- F15  : Funds checking Failed becuase of Invalid Budgeted Task
        -- F16  : Funds checking Failed becuase of Invalid Amount Type
        -- F17  : Funds checking Failed becuase of Invalid Bondary code
        -- F18  : Funds checking Failed becuase of Invalid Parent Resource Member (Obsoleted : bug 2006221)
        -- F19  : Funds checking Failed becuase of Invalid Top Task
*/

    /* Bug 2006221: 1.  All Decode statements are modified to return proper result_codes
		    2.  Removed decode statement  DECODE(parent_resource_id,NULL,'F18',
			as parent_resource_id can be NULL in case of UNCLASSIFIED Resources
			i.e. for Expenditure Types which are not there in Resource List, so removed
			the check for NULL parent_resource_id
    */

    /* Bug 2605070:     Commented out NOCOPY statement DECODE(bud_resource_list_member_id,NULL,'F14',
			as bud_resource_list_member_id is now obsoleted
    */

  BEGIN

	g_error_procedure_name  :=  'check_setup_failure';
    g_error_stage := 'CHK SETUP FAIL';
	x_err_count  :=0;

  IF x_partial = 'Y' THEN
    g_error_stage := 'CHK SETUP FAIL : Y';
         UPDATE gms_bc_packets gms
            SET gms.status_code = 'T',
                gms.result_code         = DECODE(budget_version_id,NULL,'F12',
						 DECODE(resource_list_member_id,NULL,'F13',
                                                 -- DECODE(bud_resource_list_member_id,NULL,'F14',
						 DECODE(bud_task_id,NULL,'F15',
						 DECODE(amount_type,NULL,'F16',
						 DECODE(boundary_code,NULL,'F17',
						 DECODE(top_task_id,NULL,'F19')))))),
                gms.res_result_code     = DECODE(budget_version_id,NULL,'F12',
						 DECODE(resource_list_member_id,NULL,'F13',
                                                 -- DECODE(bud_resource_list_member_id,NULL,'F14',
						 DECODE(bud_task_id,NULL,'F15',
						 DECODE(amount_type,NULL,'F16',
						 DECODE(boundary_code,NULL,'F17',
						 DECODE(top_task_id,NULL,'F19')))))),
                gms.res_grp_result_code = DECODE(budget_version_id,NULL,'F12',
						 DECODE(resource_list_member_id,NULL,'F13',
                                                 -- DECODE(bud_resource_list_member_id,NULL,'F14',
						 DECODE(bud_task_id,NULL,'F15',
						 DECODE(amount_type,NULL,'F16',
						 DECODE(boundary_code,NULL,'F17',
						 DECODE(top_task_id,NULL,'F19')))))),
                gms.task_result_code    = DECODE(budget_version_id,NULL,'F12',
						 DECODE(resource_list_member_id,NULL,'F13',
                                                 -- DECODE(bud_resource_list_member_id,NULL,'F14',
						 DECODE(bud_task_id,NULL,'F15',
						 DECODE(amount_type,NULL,'F16',
						 DECODE(boundary_code,NULL,'F17',
						 DECODE(top_task_id,NULL,'F19')))))),
                gms.top_task_result_code= DECODE(budget_version_id,NULL,'F12',
						 DECODE(resource_list_member_id,NULL,'F13',
                                                 -- DECODE(bud_resource_list_member_id,NULL,'F14',
						 DECODE(bud_task_id,NULL,'F15',
						 DECODE(amount_type,NULL,'F16',
						 DECODE(boundary_code,NULL,'F17',
						 DECODE(top_task_id,NULL,'F19')))))),
                gms.award_result_code   = DECODE(budget_version_id,NULL,'F12',
						 DECODE(resource_list_member_id,NULL,'F13',
                                                 -- DECODE(bud_resource_list_member_id,NULL,'F14',
						 DECODE(bud_task_id,NULL,'F15',
						 DECODE(amount_type,NULL,'F16',
						 DECODE(boundary_code,NULL,'F17',
						 DECODE(top_task_id,NULL,'F19'))))))
          WHERE gms.packet_id = x_packetid
            AND status_code = 'P'
            AND (  budget_version_id IS NULL
                OR resource_list_member_id IS NULL
                -- OR bud_resource_list_member_id IS NULL
                OR bud_task_id IS NULL
                OR amount_type IS NULL
                OR boundary_code IS NULL
		OR top_task_id IS NULL
--		OR decode(categorization_code,'R',parent_resource_id,1) IS NULL  commented for bug 2006221
				 );

       -- Added commit for the base bug 3848201
       commit;

       -- Call new procedure RAW_BURDEN_FAILURE to handle raw-burden failure ...
       RAW_BURDEN_FAILURE(x_packetid,     -- Packet_id
                          g_derived_mode, -- Mode
                          'ALL'           -- Level
                         );


      -- Call new FUNCTION Full_mode_failure to handle scenario of failing all cdl when one cdl failed ..
      If FULL_MODE_FAILURE(x_packetid,     -- Packet_id
                           g_mode,         -- Mode , use g_mode
                          'ALL'           -- Level
                           ) THEN
         gms_error_pkg.gms_debug (g_error_procedure_name||':full_mode_failure call completed','C');
          -- Note:We're not handling Full mode failures for REQ/PO/AP here ...
      End If;

      -- Net zero txn.s failure
      If g_doc_type in ('EXP','ENC') then
         -- Handle net zero txn.s in the same packet
         -- A. Fail reversing line if original line has failed
         UPDATE gms_bc_packets bp
            SET bp.result_code =  nvl(bp.result_code,'F65'),
                bp.status_code = 'R',
		bp.fc_error_message = decode(bp.fc_error_message,NULL,'CHECK_SETUP_FAILURE - net zero txn. - full mode failure',bp.fc_error_message)
          WHERE bp.packet_id            = x_packetid
            AND bp.effect_on_funds_code = 'I'
            AND bp.result_code          = 'P82'
            AND bp.status_code          = 'P'
            AND bp.document_header_id   <> bp.adjusted_document_header_id
            AND bp.document_type        in ('EXP','ENC')
            AND EXISTS (select 1
                         from  gms_bc_packets bp1
                         where bp1.packet_id          = bp.packet_id
                         and   bp1.document_header_id = bp.adjusted_document_header_id
                         and   SUBSTR (bp1.result_code, 1, 1) = 'F');

       -- Added commit for the base bug 3848201
       commit;

	 -- B. Fail original line if reversing line has failed
         UPDATE gms_bc_packets bp
            SET bp.result_code =  nvl(bp.result_code,'F65'),
                bp.status_code = 'R',
		bp.fc_error_message = decode(bp.fc_error_message,NULL,'CHECK_SETUP_FAILURE - original fail as reversing fail-full mode failure',bp.fc_error_message)
          WHERE bp.packet_id            = x_packetid
            AND bp.effect_on_funds_code = 'I'
            AND bp.result_code          = 'P82'
            AND bp.status_code          = 'P'
            AND bp.document_header_id   = bp.adjusted_document_header_id
            AND bp.document_type        in ('EXP','ENC')
            AND EXISTS (select 1
                         from  gms_bc_packets bp1
                         where bp1.packet_id                   = bp.packet_id
                         and   bp1.adjusted_document_header_id = bp.document_header_id
                         and   SUBSTR (bp1.result_code, 1, 1)  = 'F');

       -- Added commit for the base bug 3848201
       commit;

      End If;


  ELSE    -- full mode
    g_error_stage := 'CHK SETUP FAIL : N';
         BEGIN
            SELECT 1
              INTO x_err_count
              FROM dual
             WHERE EXISTS (SELECT 1
                             FROM gms_bc_packets
                            WHERE packet_id = x_packetid
                              AND (
                                        budget_version_id IS NULL
                                     OR resource_list_member_id IS NULL
                                     -- OR bud_resource_list_member_id IS NULL  -- Bug 2605070
                                     OR bud_task_id IS NULL
                                     OR amount_type IS NULL
                                     OR boundary_code IS NULL
									 OR top_task_id IS NULL
									 OR budget_period_start_date IS NULL
									 OR budget_period_end_date IS NULL
--				     OR decode(categorization_code,'R',parent_resource_id,1) IS NULL   commented for bug 2006221
				  ));

            -- Added commit for the base bug 3848201
            commit;


            UPDATE gms_bc_packets gms
            SET gms.status_code = 'T',
                gms.result_code = DECODE(result_code,NULL,DECODE(budget_version_id,NULL,'F12',
						 DECODE(resource_list_member_id,NULL,'F13',
                                                 -- DECODE(bud_resource_list_member_id,NULL,'F14',
						 DECODE(bud_task_id,NULL,'F15',
						 DECODE(amount_type,NULL,'F16',
						 DECODE(boundary_code,NULL,'F17',
						 DECODE(top_task_id,NULL,'F19','F65')))))),result_code),
                gms.res_result_code     = DECODE(budget_version_id,NULL,'F12',
						 DECODE(resource_list_member_id,NULL,'F13',
                                                 -- DECODE(bud_resource_list_member_id,NULL,'F14',
						 DECODE(bud_task_id,NULL,'F15',
						 DECODE(amount_type,NULL,'F16',
						 DECODE(boundary_code,NULL,'F17',
						 DECODE(top_task_id,NULL,'F19')))))),
                gms.res_grp_result_code = DECODE(budget_version_id,NULL,'F12',
						 DECODE(resource_list_member_id,NULL,'F13',
                                                 -- DECODE(bud_resource_list_member_id,NULL,'F14',
						 DECODE(bud_task_id,NULL,'F15',
						 DECODE(amount_type,NULL,'F16',
						 DECODE(boundary_code,NULL,'F17',
						 DECODE(top_task_id,NULL,'F19')))))),
                gms.task_result_code    = DECODE(budget_version_id,NULL,'F12',
						 DECODE(resource_list_member_id,NULL,'F13',
                                                 -- DECODE(bud_resource_list_member_id,NULL,'F14',
						 DECODE(bud_task_id,NULL,'F15',
						 DECODE(amount_type,NULL,'F16',
						 DECODE(boundary_code,NULL,'F17',
						 DECODE(top_task_id,NULL,'F19')))))),
                gms.top_task_result_code= DECODE(budget_version_id,NULL,'F12',
						 DECODE(resource_list_member_id,NULL,'F13',
                                                 -- DECODE(bud_resource_list_member_id,NULL,'F14',
						 DECODE(bud_task_id,NULL,'F15',
						 DECODE(amount_type,NULL,'F16',
						 DECODE(boundary_code,NULL,'F17',
						 DECODE(top_task_id,NULL,'F19')))))),
                gms.award_result_code   = DECODE(budget_version_id,NULL,'F12',
						 DECODE(resource_list_member_id,NULL,'F13',
                                                 -- DECODE(bud_resource_list_member_id,NULL,'F14',
						 DECODE(bud_task_id,NULL,'F15',
						 DECODE(amount_type,NULL,'F16',
						 DECODE(boundary_code,NULL,'F17',
						 DECODE(top_task_id,NULL,'F19'))))))
         WHERE  gms.packet_id = x_packetid
	 AND    status_code   = 'P';

       -- Added commit for the base bug 3848201
       commit;

	 IF g_debug = 'Y' THEN
         	gms_error_pkg.gms_debug ( 'GMS_SETUP - Setup Failed ', 'C' );
         END IF;

		 RETURN FALSE;
	 EXCEPTION
	     WHEN NO_DATA_FOUND THEN
               -- This is a DUMMY Exception that can happen if all the
               -- records are proper. That's why null statement below.
          NULL;
     END;
  END IF;
  RETURN TRUE;
END check_setup_failure;

----------------------------------------------------------------------------------------------------------
/* 								  Funds Check Sequence Updation

   The sequence in which funds check is performed is decided by funds check Sequence
   (funds_check_seq) . The Records are arranged in the increasing order of there burdened cost.
   The transactions are grouped such that always burden cost follows the raw cost component.
   The order by clause used to assign the sequence is
   burdened_cost, document_header_id, decode(nvl(entered_dr,0),0,1), document_distribution_id, bc_packet_id.
*/
----------------------------------------------------------------------------------------------------------


PROCEDURE update_fc_sequence (
      x_packetid    IN       NUMBER) IS

      TYPE t_fcseq	  IS TABLE OF gms_bc_packets.funds_check_seq%TYPE;
      TYPE t_rowid IS TABLE OF VARCHAR2 (50);
	  t_row_id	   t_rowid;
	  t_fc_seq	   t_fcseq;
      t_count      number; -- fix for bug : 2927485

       Cursor C_result_code is
          select 'ALL' rcode from dual union all
          select 'P82' rcode from dual
         order by 1;


   BEGIN
      g_error_procedure_name := 'update_fc_sequence';
      g_error_stage := 'UPD FC SEQ: BLK COLL';
      t_count      := 0; -- fix for bug : 2927485

         	gms_error_pkg.gms_debug ( 'update_fc_sequence : Start ', 'C' );

    FOR recs in C_result_code
    loop

      IF recs.rcode = 'ALL' then
       -- All records except P82

         SELECT   ROWID,
		 		  funds_check_seq
	 BULK COLLECT INTO
	 	  		  t_row_id,
				  t_fc_seq
             FROM gms_bc_packets
            WHERE packet_id = x_packetid
              AND nvl(result_code,'XX') <> 'P82'
         ORDER BY burdened_cost,
                  document_type,
                  document_header_id,
				  decode(nvl(entered_dr,0),0,1), --  Bug 2092791
				  								 --	 Added to include credit transaction
				  								 --  first in a Re-costing scenario
                  document_distribution_id,
                  bc_packet_id;

      Elsif recs.rcode = 'P82' then
       -- Only P82 records (net zero transactions)

            If g_bc_packet_has_P82_records = 'Y' then

               t_count := t_row_id.COUNT;
               t_row_id.DELETE;
               t_fc_seq.DELETE;

                 SELECT   ROWID,
        		 		  funds_check_seq
        	 BULK COLLECT INTO
	 	          		  t_row_id,
    				      t_fc_seq
                     FROM gms_bc_packets
                    WHERE packet_id = x_packetid
                      AND nvl(result_code,'XX') = 'P82'
                 ORDER BY adjusted_document_header_id,
                                      burdened_cost,
                                     bc_packet_id;

            End if;

      end if;

      If t_row_id.COUNT > 0 then

    	FOR i IN t_row_id.FIRST .. t_row_id.LAST
			LOOP
			  IF t_row_id.PRIOR (i) IS NULL THEN
			  	 t_fc_seq(i) := 1;
			  ELSE
			  	 t_fc_seq(i) := t_fc_seq(t_row_id.PRIOR (i))+  t_count  + 1;
			  END IF;
			END LOOP;
         g_error_stage := 'UPD FC SEQ: FOR ALL';
         FORALL bcpkt_txns IN t_row_id.FIRST .. t_row_id.LAST
         UPDATE gms_bc_packets
            SET funds_check_seq = t_fc_seq(bcpkt_txns)
          WHERE ROWID = t_row_id (bcpkt_txns);
     End if;

    end loop;
         	gms_error_pkg.gms_debug ( 'update_fc_sequence : End ', 'C' );
  END  update_fc_sequence;

   ------------------------------------------------------------------------------------------------------
   --   Wrapper process which calls all the setup procedures and functions
    /***********************************************************************************************/
    /*********************************     FUNDS CHECK SETUP   *************************************/
    /***********************************************************************************************/
    -------------------------------------------------------------------------------------------------
    /* This Function populates setup columns of GMS_BC_PACKETS Table for all the transactions
       This  includes populating
                burdened_cost
                resource_list_member_id
                bud_resource_list_member_id
                bud_task_id
                budget_period_start_date
                budget_period_end_date
                funds_check_seq
        It Also inserts record in gms_bc_packet_arrival_order Table
    */
    -------------------------------------------------------------------------------------------------
   FUNCTION gms_setup (
      x_packetid   IN       NUMBER,
      x_mode       IN       VARCHAR2,
	  x_partial	   IN		VARCHAR2,
	  x_err_code   OUT NOCOPY		NUMBER,
	  x_err_buff   OUT NOCOPY 		VARCHAR2)
      RETURN BOOLEAN IS

   BEGIN
      g_error_procedure_name := 'gms_setup';
      g_error_stage := 'GMS_SETUP : START';
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('GMS_SETUP - Before Burdened Cost Update ', 'C');
      END IF;

	  update_burdened_cost (x_packetid);
	  COMMIT;

--------------------------------------------------------------------------
-- Set up of effect_on_funds_code and generating resource_list_member_id
--------------------------------------------------------------------------
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('GMS_SETUP - Before Setup RLMI ', 'C');
      END IF;
      setup_rlmi (x_packetid, x_mode, x_err_code, x_err_buff);
	  COMMIT;

-- ------------------------------------------------------------------------
-- Update the budgeted task id
-- in gms bc packets for a project, task, award, budget version
-- ------------------------------------------------------------------------
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('GMS_SETUP - Before Budgeted Task Update -> packet_id'|| x_packetid, 'C');
      END IF;
      budget_task_id_update (x_packetid);
	  COMMIT;

      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('GMS_SETUP - After Budgeted Task Update', 'C');
      END IF;

-- --------------------------------------------------------------------------
-- Update the  Budgeted resource list member id(rlmi)
-- in gms bc packets for a project, task, award, budget version
-- --------------------------------------------------------------------------
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('GMS_SETUP - Before Budgeted rlmi Update -> packet_id'|| x_packetid, 'C');
      END IF;
      bud_res_list_id_update (x_packetid);
	  COMMIT;

      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('GMS_SETUP - After Budgeted rlmi Update', 'C');
      END IF;

-- ---------------------------------------------------------------------------
-- Updating the  Funds control level code
-- in gms bc packets for a project, task, award, budget version
-- ---------------------------------------------------------------------------
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('GMS_SETUP - Before Funds ctrl code -> packet_id'|| x_packetid, 'C');
      END IF;
      funds_ctrl_level_code (x_packetid);
	  COMMIT;

	  IF g_debug = 'Y' THEN
	  	gms_error_pkg.gms_debug ('GMS_SETUP - Before start date end date -> packet_id'|| x_packetid, 'C');
	  END IF;

      call_start_end_date_update (x_packetid,x_mode);
	  COMMIT;
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('GMS_SETUP - After startdate end date -> packet_id'|| x_packetid, 'C');
      END IF;

      IF NOT check_setup_failure (x_packetid, x_partial ) THEN
	     COMMIT;
	  	 RETURN FALSE;
	  END IF;
	  COMMIT;

     -- Bug 2176230 : Shifted the code update_fc_sequence above the insert_arrival_order

     IF x_mode IN ('R', 'U', 'C', 'E') THEN
	  update_fc_sequence(x_packetid);
      COMMIT;
     END IF;


      /***********************  GMS Arrival Order Sequence ***************************/

      --*******************************************************************************
      --  Note : The Insert insert_arrival_order procedure call  below should always
      --    	 be the last statement of the setup, Before actual funds check happens.
      --         Do Not write any code after this insert statement.
      --*******************************************************************************

      -- Bug 2176230
	  -- ********************************************************************************
	  -- NOTE :- Don't Put Any Commit after this point till gms_fc_process is complete,
	  --         Reason being for funds checking in C Mode (check funds mode)
	  --         transactions in gms_bc_packets should not be accounted by any other
	  --         subsequent packet.
	  -- ********************************************************************************

	  insert_arrival_order_seq (x_packetid, x_mode);

--    COMMIT;  Bug 2176230

-- Bug 2176230 : Shifted the code update_fc_sequence above the insert_arrival_order
/*
     IF x_mode IN ('R', 'U', 'C', 'E') THEN
	  update_fc_sequence(x_packetid);
      COMMIT;
     END IF;
*/

      g_error_stage := 'GMS_SETUP : END';
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ( 'GMS_SETUP -After Inserting Records in gms_bc_packet_arrival_order ', 'C' );
      END IF;
      RETURN TRUE;
   END gms_setup;

/* ------------------------------------------------------------------------------------------------------
   This Procedure is called  in case of Budget Submit and Re-Baseline prcoess of Award Budget.
   This procedure compares balances from gms_balances table and Records in gms_bc_packets
   for that budget_version_id. If any Record fails, control comes out of the loop  and goes
   to the exception part where all the values of variable are dumped into the o/p file

   Bug 3681963 : Modified the code of procedure budget_fundscheck consider the previous consumed
   balances if range has increased during the execution in loop of res/res grp/task/top task/award level
   cursors. Added the order by clause to ensure that shortest range will always be first. Stored
   the previous balance and used it in the next level if all other parameters are same and range
   has increased.
   Not marked the changes with bug no as lot of code changes were done.
   ------------------------------------------------------------------------------------------------------ */
   PROCEDURE budget_fundscheck (x_packetid NUMBER,x_err_code OUT NOCOPY NUMBER ,x_err_buff OUT NOCOPY VARCHAR2) IS
      CURSOR gms_bc_tot_r IS
         SELECT   SUM (NVL (entered_dr, 0) - NVL (entered_cr, 0)) r_bc_tot,
                  budget_version_id,
                  bud_task_id,
                  resource_list_member_id,  -- Bug 2605070, Replaced bud_resource_list_member_id with this column
                  budget_period_start_date,
                  budget_period_end_date
             FROM gms_bc_packets
            WHERE packet_id = x_packetid
              AND status_code = 'P'
              AND
                  r_funds_control_level_code = 'B'
         GROUP BY budget_version_id,
                  bud_task_id,
                  resource_list_member_id,  -- Bug 2605070, Replaced bud_resource_list_member_id with this column
                  budget_period_start_date,
                  budget_period_end_date
         ORDER BY budget_version_id,
                  bud_task_id,
                  resource_list_member_id,
                  budget_period_start_date,
                  budget_period_end_date;

      CURSOR gms_bc_tot_rg IS
         SELECT   SUM (NVL (entered_dr, 0) - NVL (entered_cr, 0)) rg_bc_tot,
                  budget_version_id,
                  bud_task_id,
                  parent_resource_id,
                  budget_period_start_date,
                  budget_period_end_date
             FROM gms_bc_packets
            WHERE packet_id = x_packetid
              AND status_code = 'P'
              AND rg_funds_control_level_code = 'B'
         GROUP BY budget_version_id,
                  bud_task_id,
                  parent_resource_id,
                  budget_period_start_date,
                  budget_period_end_date
 	 ORDER BY budget_version_id,
                  bud_task_id,
                  parent_resource_id,
                  budget_period_start_date,
                  budget_period_end_date;

      CURSOR gms_bc_tot_t IS
         SELECT   SUM (NVL (entered_dr, 0) - NVL (entered_cr, 0)) t_bc_tot,
                  budget_version_id,
                  bud_task_id,
                  budget_period_start_date,
                  budget_period_end_date
             FROM gms_bc_packets
            WHERE packet_id = x_packetid
              AND status_code = 'P'
              AND t_funds_control_level_code = 'B'
         GROUP BY budget_version_id, bud_task_id, budget_period_start_date, budget_period_end_date
	 ORDER BY budget_version_id, bud_task_id, budget_period_start_date, budget_period_end_date;

      CURSOR gms_bc_tot_tt IS
         SELECT   SUM (NVL (entered_dr, 0) - NVL (entered_cr, 0)) tt_bc_tot,
                  budget_version_id,
                  top_task_id,
                  budget_period_start_date,
                  budget_period_end_date
             FROM gms_bc_packets
            WHERE packet_id = x_packetid
              AND status_code = 'P'
              AND tt_funds_control_level_code = 'B'
         GROUP BY budget_version_id, top_task_id,
                  budget_period_start_date, budget_period_end_date
         ORDER BY budget_version_id, top_task_id,
                  budget_period_start_date, budget_period_end_date;

      CURSOR gms_bc_tot_a IS
         SELECT   SUM (NVL (entered_dr, 0) - NVL (entered_cr, 0)) a_bc_tot,
                  budget_version_id,
                  budget_period_start_date,
                  budget_period_end_date
             FROM gms_bc_packets
            WHERE packet_id = x_packetid
              AND status_code = 'P'
              AND a_funds_control_level_code = 'B'
         GROUP BY budget_version_id, budget_period_start_date, budget_period_end_date
	 ORDER BY budget_version_id, budget_period_start_date, budget_period_end_date;


      x_a_bc_tot                   NUMBER (22, 5);
      x_r_bc_tot                   NUMBER (22, 5);
      x_rg_bc_tot                  NUMBER (22, 5);
      x_t_bc_tot                   NUMBER (22, 5);
      x_tt_bc_tot                  NUMBER (22, 5);
      x_res_list_member_id         gms_bc_packets.resource_list_member_id%TYPE;  -- Bug 2605070
      x_bud_task_id                gms_bc_packets.bud_task_id%TYPE;
      x_budget_version_id          NUMBER (22, 5);
      x_budget_period_start_date   DATE;
      x_budget_period_end_date     DATE;
      temp                         NUMBER;
      x_error_message              VARCHAR2 (2000);
      x_parent_resource_id         NUMBER;
      x_top_task_id                NUMBER;

      l_balance_available	   NUMBER (22,5):=0;
      l_old_start_date		   DATE;
      l_old_end_date		   DATE;
      l_old_res_list_member_id     gms_bc_packets.resource_list_member_id%TYPE;
      l_old_budget_version_id      gms_bc_packets.budget_version_id%TYPE;
      l_old_bud_task_id            gms_bc_packets.bud_task_id%TYPE;
      l_old_top_task_id            gms_bc_packets.top_task_id%TYPE;
      l_old_parent_resource_id     gms_bc_packets.parent_resource_id%TYPE;
      l_previous_tot		   NUMBER (22,5):=0;


   BEGIN
      g_error_procedure_name := 'budget_fundscheck';
      g_error_stage := 'BUD_FC : START';
      -- Resource Level
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('BUDGET_FUNDSCHECK - PROCESS'|| x_packetid, 'C');
      	gms_error_pkg.gms_debug ('BUDGET_FUNDSCHECK - BEFORE RESOURCE LEVEL', 'C');
      END IF;
      g_error_stage := 'BUD_FC : RES';
      OPEN gms_bc_tot_r;
      LOOP
         FETCH gms_bc_tot_r INTO x_r_bc_tot,
                                 x_budget_version_id,
                                 x_bud_task_id,
                                 x_res_list_member_id,
                                 x_budget_period_start_date,
                                 x_budget_period_end_date;

	 EXIT WHEN gms_bc_tot_r%NOTFOUND;

	 IF NOT (   x_budget_version_id = l_old_budget_version_id
	        AND x_budget_period_start_date <= l_old_start_date
	        AND x_budget_period_end_date >= l_old_end_date
	        AND x_res_list_member_id = l_old_res_list_member_id
		AND x_bud_task_id = l_old_bud_task_id)
         THEN
  	       l_previous_tot := 0;
	 END IF;

	 IF NVL(x_r_bc_tot,0) <> 0  THEN

           SELECT NVL(SUM (NVL (budget_period_to_date, 0)),0)
	    INTO l_balance_available
	    FROM gms_balances
	   WHERE budget_version_id = x_budget_version_id
	     AND start_date >= x_budget_period_start_date
	     AND end_date <= x_budget_period_end_date
	     AND resource_list_member_id = x_res_list_member_id
	     AND task_id = x_bud_task_id;

	   IF l_balance_available < (x_r_bc_tot+l_previous_tot) THEN
	      RAISE no_data_found;
	   END IF;

	   l_previous_tot		    := l_previous_tot + x_r_bc_tot;
	   l_old_budget_version_id          := x_budget_version_id;
           l_old_bud_task_id		    := x_bud_task_id;
           l_old_res_list_member_id	    := x_res_list_member_id;
           l_old_start_date                 := x_budget_period_start_date;
           l_old_end_date                   := x_budget_period_end_date;

         END IF;

      END LOOP;
      CLOSE gms_bc_tot_r;
      -- Resource Group Level
      g_error_stage := 'BUD_FC : RESGRP';

      l_previous_tot	:= 0;

      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('BUDGET_FUNDSCHECK - BEFORE RESOURCE GROUP LEVEL', 'C');
      END IF;
      OPEN gms_bc_tot_rg;
      LOOP
         FETCH gms_bc_tot_rg INTO x_rg_bc_tot,
                                  x_budget_version_id,
                                  x_bud_task_id,
                                  x_parent_resource_id,
                                  x_budget_period_start_date,
                                  x_budget_period_end_date;
         EXIT WHEN gms_bc_tot_rg%NOTFOUND;


	 IF NOT (   x_budget_version_id = l_old_budget_version_id
	        AND x_budget_period_start_date <= l_old_start_date
	        AND x_budget_period_end_date >= l_old_end_date
	        AND x_parent_resource_id = l_old_parent_resource_id
		AND x_bud_task_id = l_old_bud_task_id)
         THEN
  	       l_previous_tot := 0;
	 END IF;

	 IF NVL(x_rg_bc_tot,0) <> 0  THEN

           SELECT NVL(SUM (NVL (budget_period_to_date, 0)),0)
	    INTO l_balance_available
	    FROM gms_balances
	   WHERE budget_version_id = x_budget_version_id
             AND start_date >= x_budget_period_start_date
             AND end_date <= x_budget_period_end_date
             AND DECODE (
	         parent_member_id,
	         NULL, resource_list_member_id,
  	         parent_member_id) = x_parent_resource_id
             AND task_id = x_bud_task_id;

	   IF l_balance_available < (x_rg_bc_tot+l_previous_tot) THEN
	      RAISE no_data_found;
	   END IF;

	   l_previous_tot		    := l_previous_tot + x_rg_bc_tot;
	   l_old_budget_version_id          := x_budget_version_id;
           l_old_bud_task_id		    := x_bud_task_id;
           l_old_parent_resource_id	    := x_parent_resource_id;
           l_old_start_date                 := x_budget_period_start_date;
           l_old_end_date                   := x_budget_period_end_date;

         END IF;

      END LOOP;
      CLOSE gms_bc_tot_rg;
      -- Task Level
      g_error_stage := 'BUD_FC : TASK';

      l_previous_tot	:= 0;

      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('BUDGET_FUNDSCHECK - BEFORE TASK LEVEL', 'C');
      END IF;
      OPEN gms_bc_tot_t;
      LOOP
         FETCH gms_bc_tot_t INTO x_t_bc_tot,
                                 x_budget_version_id,
                                 x_bud_task_id,
                                 x_budget_period_start_date,
                                 x_budget_period_end_date;
         EXIT WHEN gms_bc_tot_t%NOTFOUND;

	 IF NOT (   x_budget_version_id = l_old_budget_version_id
	        AND x_budget_period_start_date <= l_old_start_date
	        AND x_budget_period_end_date >= l_old_end_date
		AND x_bud_task_id = l_old_bud_task_id)
         THEN
  	       l_previous_tot := 0;
	 END IF;

	 IF NVL(x_t_bc_tot,0) <> 0  THEN

           SELECT NVL(SUM (NVL (budget_period_to_date, 0)),0)
	    INTO l_balance_available
	    FROM gms_balances
	   WHERE budget_version_id = x_budget_version_id
             AND start_date >= x_budget_period_start_date
             AND end_date <= x_budget_period_end_date
             AND task_id = x_bud_task_id;

	   IF l_balance_available < (x_t_bc_tot+l_previous_tot) THEN
	      RAISE no_data_found;
	   END IF;

	   l_previous_tot		    := l_previous_tot + x_t_bc_tot;
	   l_old_budget_version_id          := x_budget_version_id;
           l_old_bud_task_id		    := x_bud_task_id;
           l_old_start_date                 := x_budget_period_start_date;
           l_old_end_date                   := x_budget_period_end_date;

         END IF;

      END LOOP;
      CLOSE gms_bc_tot_t;
      -- Top Task Level
      g_error_stage := 'BUD_FC : TOP TASK';

      l_previous_tot	:= 0;

      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('BUDGET_FUNDSCHECK - BEFORE TOP TASK LEVEL', 'C');
      END IF;
      OPEN gms_bc_tot_tt;
      LOOP
         FETCH gms_bc_tot_tt INTO x_tt_bc_tot,
                                  x_budget_version_id,
                                  x_top_task_id,
                                  x_budget_period_start_date,
                                  x_budget_period_end_date;
         EXIT WHEN gms_bc_tot_tt%NOTFOUND;

	 IF NOT (   x_budget_version_id = l_old_budget_version_id
	        AND x_budget_period_start_date <= l_old_start_date
	        AND x_budget_period_end_date >= l_old_end_date
		AND x_top_task_id = l_old_top_task_id)
         THEN
  	       l_previous_tot := 0;
	 END IF;

	 IF NVL(x_tt_bc_tot,0) <> 0  THEN

           SELECT NVL(SUM (NVL (budget_period_to_date, 0)),0)
	    INTO l_balance_available
	    FROM gms_balances
           WHERE budget_version_id = x_budget_version_id
	     AND start_date >= x_budget_period_start_date
	     AND end_date <= x_budget_period_end_date
	     AND DECODE (top_task_id, NULL, task_id, top_task_id) = x_top_task_id;

	   IF l_balance_available < (x_tt_bc_tot+l_previous_tot) THEN
	      RAISE no_data_found;
	   END IF;

	   l_previous_tot		    := l_previous_tot + x_tt_bc_tot;
	   l_old_budget_version_id          := x_budget_version_id;
           l_old_top_task_id		    := x_top_task_id;
           l_old_start_date                 := x_budget_period_start_date;
           l_old_end_date                   := x_budget_period_end_date;

         END IF;

      END LOOP;
      CLOSE gms_bc_tot_tt;
      -- Award Level
      g_error_stage := 'BUD_FC : AWARD';

      l_previous_tot	:= 0;

      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('BUDGET_FUNDSCHECK - BEFORE AWARD LEVEL', 'C');
      END IF;
      OPEN gms_bc_tot_a;
      LOOP

	 FETCH gms_bc_tot_a INTO x_a_bc_tot,
                                 x_budget_version_id,
                                 x_budget_period_start_date,
                                 x_budget_period_end_date;
         EXIT WHEN gms_bc_tot_a%NOTFOUND;

	 IF NOT (   x_budget_version_id = l_old_budget_version_id
	        AND x_budget_period_start_date <= l_old_start_date
	        AND x_budget_period_end_date >= l_old_end_date
		)
         THEN
  	       l_previous_tot := 0;
	 END IF;

	 IF NVL(x_a_bc_tot,0) <> 0  THEN

           SELECT NVL(SUM (NVL (budget_period_to_date, 0)),0)
	    INTO l_balance_available
	    FROM gms_balances
	   WHERE budget_version_id = x_budget_version_id
	     AND start_date >= x_budget_period_start_date
	     AND end_date <= x_budget_period_end_date;

	   IF l_balance_available < (x_a_bc_tot+l_previous_tot) THEN
	      RAISE no_data_found;
	   END IF;

	   l_previous_tot		    := l_previous_tot + x_a_bc_tot;
           l_old_start_date                 := x_budget_period_start_date;
           l_old_end_date                   := x_budget_period_end_date;
   	   l_old_budget_version_id          := x_budget_version_id;

         END IF;

      END LOOP;
      CLOSE gms_bc_tot_a;
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('BUDGET_FUNDSCHECK BEFORE P50 UPDATE '|| x_packetid, 'C');
      END IF;
      UPDATE gms_bc_packets
         SET result_code = 'P50',
             award_result_code = 'P50',
             res_result_code = 'P50',
             res_grp_result_code = 'P50',
             task_result_code = 'P50',
             top_task_result_code = 'P50'
       WHERE packet_id = x_packetid
         AND status_code = 'P';
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('BUDGET_FUNDSCHECK - AFTER P50 UPDATE '|| x_packetid, 'C');
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
-- For Resource Level
         IF gms_bc_tot_r%ISOPEN THEN
		    g_error_stage := 'BUD_FC FAIL: RES';
            gms_error_pkg.gms_message (
               x_err_name=> 'GMS_FC_FAIL_AT_BUDG_RES',
               x_token_name1=> 'PACKET_ID',
               x_token_val1=> x_packetid,
               x_token_name2=> 'TASK_ID',
               x_token_val2=> x_bud_task_id,
               x_token_name3=> 'RESOURCE_LIST_MEMBER_ID',
               x_token_val3=> x_res_list_member_id,
               x_token_name4=> 'START_DATE',
               x_token_val4=> x_budget_period_start_date,
               x_token_name5=> 'END_DATE',
               x_token_val5=> x_budget_period_start_date,
               x_exec_type=> 'C',
               x_err_code=> x_err_code,
               x_err_buff=> x_err_buff);
            UPDATE gms_bc_packets
               SET result_code = 'F25',
                   award_result_code = 'F25',
                   res_result_code = 'F25',
                   res_grp_result_code = 'F25',
                   task_result_code = 'F25',
                   top_task_result_code = 'F25'
             WHERE packet_id = x_packetid;
            CLOSE gms_bc_tot_r;
         END IF;

-- For Resource Group Level
         IF gms_bc_tot_rg%ISOPEN THEN
		    g_error_stage := 'BUD_FC FAIL: RES GRP';
            gms_error_pkg.gms_message (
               x_err_name=> 'GMS_FC_FAIL_AT_BUDG_RES_GRP',
               x_token_name1=> 'PACKET_ID',
               x_token_val1=> x_packetid,
               x_token_name2=> 'TASK_ID',
               x_token_val2=> x_bud_task_id,
               x_token_name3=> 'RESOURCE_LIST_MEMBER_ID',
               x_token_val3=> x_parent_resource_id,
               x_token_name4=> 'START_DATE',
               x_token_val4=> x_budget_period_start_date,
               x_token_name5=> 'END_DATE',
               x_token_val5=> x_budget_period_start_date,
               x_exec_type=> 'C',
               x_err_code=> x_err_code,
               x_err_buff=> x_err_buff);
            UPDATE gms_bc_packets
               SET result_code = 'F26',
                   award_result_code = 'F26',
                   res_result_code = 'F26',
                   res_grp_result_code = 'F26',
                   task_result_code = 'F26',
                   top_task_result_code = 'F26'
             WHERE packet_id = x_packetid;
            CLOSE gms_bc_tot_rg;
         END IF;

-- For Task Level
         IF gms_bc_tot_t%ISOPEN THEN
		    g_error_stage := 'BUD_FC FAIL: TASK';
            gms_error_pkg.gms_message (
               x_err_name=> 'GMS_FC_FAIL_AT_BUDG_TASK',
               x_token_name1=> 'PACKET_ID',
               x_token_val1=> x_packetid,
               x_token_name2=> 'TASK_ID',
               x_token_val2=> x_bud_task_id,
               x_token_name4=> 'START_DATE',
               x_token_val4=> x_budget_period_start_date,
               x_token_name5=> 'END_DATE',
               x_token_val5=> x_budget_period_start_date,
               x_exec_type=> 'C',
               x_err_code=> x_err_code,
               x_err_buff=> x_err_buff);
            UPDATE gms_bc_packets
               SET result_code = 'F27',
                   award_result_code = 'F27',
                   res_result_code = 'F27',
                   res_grp_result_code = 'F27',
                   task_result_code = 'F27',
                   top_task_result_code = 'F27'
             WHERE packet_id = x_packetid;
            CLOSE gms_bc_tot_t;
         END IF;

-- For Top Task Level
         IF gms_bc_tot_tt%ISOPEN THEN
		    g_error_stage := 'BUD_FC FAIL: TOPTASK';
            gms_error_pkg.gms_message (
               x_err_name=> 'GMS_FC_FAIL_AT_BUDG_TOP_TASK',
               x_token_name1=> 'PACKET_ID',
               x_token_val1=> x_packetid,
               x_token_name2=> 'TOP_TASK_ID',
               x_token_val2=> x_top_task_id,
               x_token_name4=> 'START_DATE',
               x_token_val4=> x_budget_period_start_date,
               x_token_name5=> 'END_DATE',
               x_token_val5=> x_budget_period_start_date,
               x_exec_type=> 'C',
               x_err_code=> x_err_code,
               x_err_buff=> x_err_buff);
             UPDATE gms_bc_packets
               SET result_code = 'F28',
                   award_result_code = 'F28',
                   res_result_code = 'F28',
                   res_grp_result_code = 'F28',
                   task_result_code = 'F28',
                   top_task_result_code = 'F28'
             WHERE packet_id = x_packetid;
            CLOSE gms_bc_tot_tt;
         END IF;
-- For Award Level

         IF gms_bc_tot_a%ISOPEN THEN
		    g_error_stage := 'BUD_FC FAIL: AWARD';
            gms_error_pkg.gms_message (
               x_err_name=> 'GMS_FC_FAIL_AT_BUDG_AWARD',
               x_token_name1=> 'PACKET_ID',
               x_token_val1=> x_packetid,
               x_token_name4=> 'START_DATE',
               x_token_val4=> x_budget_period_start_date,
               x_token_name5=> 'END_DATE',
               x_token_val5=> x_budget_period_start_date,
               x_exec_type=> 'C',
               x_err_code=> x_err_code,
               x_err_buff=> x_err_buff);
            UPDATE gms_bc_packets
               SET result_code = 'F29',
                   award_result_code = 'F29',
                   res_result_code = 'F29',
                   res_grp_result_code = 'F29',
                   task_result_code = 'F29',
                   top_task_result_code = 'F29'
             WHERE packet_id = x_packetid;
            CLOSE gms_bc_tot_a;
         END IF;
         fnd_file.put_line (fnd_file.output, x_err_buff);
      WHEN OTHERS THEN
         RAISE;
   END budget_fundscheck;

--   ===========================================================================
/*
   This is the main funds checker process, which does the funds checking at
   various level eg. resource, resource group, task , top task and award.
   Funds are not checked in following cases
   		 1.	 If budgetary control setting at that level is 'N'
		 2.	 If entered_dr - entered_cr < 0 ( i.e. for Negative Transaction )
		 3.  If a Transaction fails Funds check at a lower level
		 	 i.e. if a Transaction fails funds check at resource level, This
			 transaction will not be considered for funds checking at higher
			 levels
*/
--   ===========================================================================

   FUNCTION gms_fc_process (
      x_packetid       IN       gms_bc_packets.packet_id%TYPE,
      x_arrival_seq1   IN       gms_bc_packet_arrival_order.packet_id%TYPE,
      x_mode	       IN	Char		-- Bug 2176230
	  )
      RETURN BOOLEAN IS
      x_err_count       NUMBER;
      x_error_message   VARCHAR2 (2000);

	  x_date			DATE;
      x_arrival_seq     gms_bc_packet_arrival_order.packet_id%TYPE;
   BEGIN

   g_error_procedure_name := 'gms_fc_process';
   g_error_stage := 'FC PR : START';
   x_err_count := 0;

      SELECT arrival_seq
        INTO x_arrival_seq
        FROM gms_bc_packet_arrival_order ao
       WHERE ao.packet_id = x_packetid;

-- ==============================================================================
-- *********************  RESOURCE LEVEL SUMMARY UPDATE  ************************
-- ==============================================================================
-- Bug 2092791
-- Following Insert statement inserts records in gms_bc_packets_summary.
-- Records in this table will later be used to summarize amount at
-- resource,task and Award Level for previous and currne packet.
 IF g_debug = 'Y' THEN
 	gms_error_pkg.gms_debug ('RESOURCE LEVEL - SUMMARY INSERT ', 'C');
 END IF;
	  x_date := sysdate;
      g_error_stage := 'FC PR : INSRT SUMM';
	  INSERT INTO gms_bc_packets_bvid
      		       (packet_id,
             	   budget_version_id,
				   creation_date)
				      SELECT DISTINCT x_packetid,
                   	  		 		  budget_version_id,
									  x_date
						FROM gms_bc_packets
					   WHERE packet_id = x_packetid
					   	 AND status_code = 'P' 	  -- This is to ignore Transactions which failed during setup.
					   ;

      -- Bug 4053891   Do not change code flow ..as lock_budget_versions uses gms_bc_packets_bvid
      -- Costing and Funds check is incompatible to Sweeper. 'EXP' has been added to the list for
      -- interface (VI->EXP)

      If g_doc_type in ('REQ','PO','AP','FAB','EXP') then
         LOCK_BUDGET_VERSIONS(x_packetid);
      End If;

           -- Bug 2605070, Replaced bud_resource_list_member_id with resource_list_member_id
	   INSERT INTO gms_bc_packets_summary
            (packet_id,
			 creation_date,
             budget_version_id,
			 top_task_id,
             bud_task_id,
			 parent_resource_id,
             resource_list_member_id,
             budget_period_start_date,
             budget_period_end_date,
             actual_approved,
             actual_pending,
             enc_approved,
             enc_pending)
     SELECT
            x_packetid,
			x_date,
            bcpkt.budget_version_id,
			bcpkt.top_task_id,
            bcpkt.bud_task_id,
			bcpkt.parent_resource_id,
            bcpkt.resource_list_member_id,
            bcpkt.budget_period_start_date,
            bcpkt.budget_period_end_date,
            nvl(sum(decode(bcpkt.status_code || bcpkt.actual_flag, 'AA',nvl(entered_dr,0) - nvl(entered_cr,0),0)),0),
            nvl(sum(decode(bcpkt.status_code || bcpkt.actual_flag, 'PA',nvl(entered_dr,0) - nvl(entered_cr,0),0)),0),
            nvl(sum(decode(bcpkt.status_code || bcpkt.actual_flag, 'AE',nvl(entered_dr,0) - nvl(entered_cr,0),0)),0),
            nvl(sum(decode(bcpkt.status_code || bcpkt.actual_flag, 'PE',nvl(entered_dr,0) - nvl(entered_cr,0),0)),0)
       FROM gms_bc_packets bcpkt,
	   		gms_bc_packet_arrival_order ao,
            gms_bc_packets_bvid a
      WHERE bcpkt.status_code IN ('A', 'P')
        AND bcpkt.budget_version_id = a.budget_version_id
		AND bcpkt.packet_id = ao.packet_id
		AND a.packet_id = x_packetid
		AND ao.arrival_seq <= x_arrival_seq
        AND decode(bcpkt.status_code,
                   'A',1,
                   'P',decode(SIGN(NVL(bcpkt.entered_dr,0)-NVL(bcpkt.entered_cr,0)),
                              -1,decode(bcpkt.packet_id,x_packetid,1,0),
                              1)) = 1
   GROUP BY bcpkt.budget_version_id,
   		 	bcpkt.top_task_id,
            bcpkt.bud_task_id,
			bcpkt.parent_resource_id,
            bcpkt.resource_list_member_id,
            bcpkt.budget_period_start_date,
            bcpkt.budget_period_end_date;

-- ==============================================================================
-- ************************* RESOURCE LEVEL FUNDS CHECK *************************
-- ==============================================================================
--===============================================================================
-- 						RESOURCE LEVEL : POSTED BALANCE UPDATE
--===============================================================================
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('RESOURCE POSTED BALANCE UPDATE', 'C');
      END IF;
      g_error_stage := 'FC PR : RES P BAL';
      UPDATE gms_bc_packets bp
         SET (bp.res_budget_posted, bp.res_actual_posted, bp.res_enc_posted) =
                (SELECT SUM (NVL (budget_period_to_date, 0) * DECODE (balance_type, 'BGT', 1, 0)),
                        SUM (NVL (actual_period_to_date, 0) * DECODE (balance_type, 'EXP', 1, 0)),
                        SUM (NVL (encumb_period_to_date, 0) * DECODE (balance_type, 'REQ', 1, 'PO', 1, 'AP', 1, 'ENC', 1, 0))
                   FROM gms_balances gb
                  WHERE gb.budget_version_id = bp.budget_version_id
                    AND gb.project_id = bp.project_id
                    AND gb.award_id = bp.award_id
                    AND (
			 (bp.bud_task_id = 0) or -- budget at project
			 (bp.bud_task_id > 0 and gb.task_id = bp.bud_task_id and bp.task_id = bp.bud_task_id) or  -- budget at lowest task
			 (bp.bud_task_id > 0 and bp.top_task_id = bp.bud_task_id
			   and DECODE (gb.top_task_id, NULL, gb.task_id, gb.top_task_id) = bp.top_task_id ) -- top task
			) -- 2379815
                    AND gb.resource_list_member_id = bp.resource_list_member_id -- Bug 2605070
                    AND gb.balance_type <> 'REV'
                    AND gb.start_date BETWEEN DECODE (
                                                 bp.time_phased_type_code,
                                                 'N', gb.start_date,
                                                 bp.budget_period_start_date)
                                          AND DECODE (
                                                 bp.time_phased_type_code,
                                                 'N', gb.start_date,
                                                 bp.budget_period_end_date)
                    AND gb.end_date BETWEEN DECODE (
                                               bp.time_phased_type_code,
                                               'N', gb.end_date,
                                               bp.budget_period_start_date)
                                        AND DECODE (
                                               bp.time_phased_type_code,
                                               'N', gb.end_date,
                                               bp.budget_period_end_date))
       WHERE bp.packet_id = x_packetid
         AND bp.effect_on_funds_code = 'D'
         AND bp.status_code = 'P'
         AND bp.categorization_code = 'R'
         AND bp.r_funds_control_level_code <> 'N';
         -- AND bp.budgeted_at_resource_level = 'Y';  -- Bug 2605070
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (
         'RESOURCE LEVEL - APPROVED/PENDING BALANCE FOR PREVIOUS AND CURRENT PACKETS',
         'C');
      END IF;
--===============================================================================
-- 	RESOURCE LEVEL : APPROVED/PENDING BALANCE FOR PREVIOUS AND CURRENT PACKETS
--===============================================================================
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ( 'RESOURCE LEVEL - APPROVED/PENDING BALANCE FOR PREVIOUS AND CURRENT PACKETS','C' );
      END IF;
 -- Bug 2092791
       g_error_stage := 'FC PR : RES A BAL';
		 UPDATE gms_bc_packets bp
		    SET (bp.res_actual_approved, bp.res_actual_pending, bp.res_enc_approved,
			        bp.res_enc_pending) =
         			 (SELECT
						  		  SUM(actual_approved),		--Bug 2490381 : Added SUM
							          SUM(actual_pending),		--Bug 2490381 : Added SUM
								  SUM(enc_approved),		--Bug 2490381 : Added SUM
								  SUM(enc_pending)		--Bug 2490381 : Added SUM
							     FROM gms_bc_packets_summary gmsbcs
								WHERE gmsbcs.packet_id = x_packetid
								  AND gmsbcs.bud_task_id = bp.bud_task_id
								  AND gmsbcs.budget_version_id = bp.budget_version_id
								  AND gmsbcs.resource_list_member_id =
		                                                      bp.resource_list_member_id -- Bug 2605070
								  --Bug 2490381 : Changed "=" to "<=" to consider all the
								  --              records from summary table which fall
								  --		  under budget_period_start_date and budget_period_end_date
								  --		  of current transaction.
								  -- Bug 2897560 : changed the strat date comparision to ">="
								  -- as we need to consider all the recods from summary table which fall
								  -- under budget_period_start_date and budget_period_end_date
								  -- of current transaction.
								  AND gmsbcs.budget_period_start_date >= bp.budget_period_start_date
								  AND gmsbcs.budget_period_end_date <= bp.budget_period_end_date)
		  WHERE bp.packet_id = x_packetid
            AND bp.effect_on_funds_code = 'D'
            AND bp.status_code = 'P'
            AND bp.r_funds_control_level_code <> 'N'
            AND bp.categorization_code = 'R' ;
            -- AND bp.budgeted_at_resource_level = 'Y';  -- Bug 2605070
--===============================================================================
-- 	                RESOURCE LEVEL : AVAILABLE BALANCE UPDATE
--===============================================================================
       g_error_stage := 'FC PR : RES AVA BAL';
         DECLARE
            CURSOR available_bal_at_res IS
               SELECT (nvl(entered_dr,0)-nvl(entered_cr,0)) entered_dr,	--Bug 2092791
                      ROWID,
                      budget_version_id,
                      bud_task_id,
                      resource_list_member_id, -- Bug 2605070
					  effect_on_funds_code,    -- Bug 2927485
                      TRUNC ( budget_period_start_date ) budget_period_start_date,
                      TRUNC ( budget_period_end_date ) budget_period_end_date,
                      actual_flag
                 FROM gms_bc_packets
                WHERE packet_id = x_packetid
                  AND effect_on_funds_code in('D','I')	--Bug 2092791
                  AND status_code = 'P'
                  AND r_funds_control_level_code <> 'N'
                  AND categorization_code = 'R'
                  -- AND budgeted_at_resource_level = 'Y'  -- Bug 2605070
                ORDER BY budget_version_id,
                         bud_task_id,
                         resource_list_member_id,
                         budget_period_start_date,
                         budget_period_end_date,
                         funds_check_seq DESC;
         x_entered_dr                     NUMBER (22, 5);
         x_rowid                          ROWID;
         x_pending_actual                 NUMBER         := -11;
         x_pending_enc                    NUMBER         := -11;
         x_amount                         NUMBER         := -11;
         x_budget_version_id_old          NUMBER         := -11;
         x_bud_task_id_old                NUMBER         := -11;
         x_rlmi_old                       NUMBER         := -11;   -- Bug 2605070
         --x_budget_period_start_date_old   DATE           := TO_DATE ('01-01-1720', 'dd-mm-yyyy'); Bug 2276479
         --x_budget_period_end_date_old     DATE           := TO_DATE ('01-01-1720', 'dd-mm-yyyy'); Bug 2276479
	 x_budget_period_start_date_old   DATE           := NULL;
         x_budget_period_end_date_old     DATE           :=  NULL;

      BEGIN
         FOR res_level IN available_bal_at_res
         LOOP
            IF    res_level.budget_version_id <> x_budget_version_id_old
               OR res_level.bud_task_id <> x_bud_task_id_old
               OR res_level.resource_list_member_id <> x_rlmi_old  -- Bug 2605070
               --OR res_level.budget_period_start_date <> x_budget_period_start_date_old Bug 2276479
               --OR res_level.budget_period_end_date <> x_budget_period_end_date_old THEN Bug 2276479
		OR res_level.budget_period_start_date <> nvl(x_budget_period_start_date_old ,res_level.budget_period_start_date + 1 )
               	OR res_level.budget_period_end_date <> nvl(x_budget_period_end_date_old , res_level.budget_period_end_date + 1 ) THEN

               IF res_level.actual_flag = 'A' THEN
                  x_pending_actual := res_level.entered_dr;
               ELSIF res_level.actual_flag = 'E' THEN
                  x_pending_enc := res_level.entered_dr;
               END IF;
               x_budget_version_id_old := res_level.budget_version_id;
               x_bud_task_id_old := res_level.bud_task_id;
               x_rlmi_old := res_level.resource_list_member_id;  -- Bug 2605070
               x_budget_period_start_date_old := res_level.budget_period_start_date;
               x_budget_period_end_date_old := res_level.budget_period_end_date;
            ELSE
             IF nvl(res_level.entered_dr,0)>= 0 AND res_level.effect_on_funds_code = 'D' THEN	--Bug 2092791 and 2927485 (Update pending balance
               UPDATE gms_bc_packets                                                            --                if funds are decreasing)
                  SET res_actual_pending = NVL (res_actual_pending, 0)
                                           - DECODE (
                                                res_level.actual_flag,
                                                'A', NVL (x_pending_actual, 0),
                                                0),
                      res_enc_pending = NVL (res_enc_pending, 0)
                                        - DECODE (
                                             res_level.actual_flag,
                                             'E', NVL (x_pending_enc, 0),
                                             0)
                WHERE ROWID = res_level.ROWID;
			 END IF;
               IF res_level.actual_flag = 'A' THEN
                  x_pending_actual := x_pending_actual + res_level.entered_dr;
               ELSIF res_level.actual_flag = 'E' THEN
                  x_pending_enc := x_pending_enc + res_level.entered_dr;
               END IF;
            END IF;
         END LOOP;
      END;

-- ================================================================================
-- 	                RESOURCE LEVEL : RESULT CODE UPDATE
-- ================================================================================
--	P68	: Transaction pass Funds Check at Resource level
--	P69	: Transaction pass Funds Check at Resource level in advisory
--	P76	: Transaction does not require funds check at this level
--  P78	: Increase Funds does not require Funds Check
--	F75	: Transaction Failed because of Raw
--	F63	: Transaction Failed because of Burden
--	F92	: Transaction failed funds check at Resource level
-- ================================================================================
-- Added decode(bp.result_code,null,'P78',bp.result_code for bug : 2927485
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('RESULT CODE UPDATE - RESOURCE', 'C');
      END IF;
      g_error_stage := 'FC PR : RES RESULT CODE';
      UPDATE gms_bc_packets bp
         SET bp.res_result_code = DECODE (
                                     bp.effect_on_funds_code,
                                     'I', decode(bp.result_code,null,'P78',bp.result_code) ,
                                     'D', DECODE (
                                             bp.r_funds_control_level_code,
                                             'N', 'P76',
                                             'D', DECODE (
                                                     SIGN (
                                                        NVL (bp.res_budget_posted, 0)
                                                        - NVL (bp.res_actual_posted, 0)
                                                        - NVL (bp.res_enc_posted, 0)
                                                        - NVL (bp.res_actual_approved, 0)
                                                        - NVL (bp.res_actual_pending, 0)
                                                        - NVL (bp.res_enc_approved, 0)
                                                        - NVL (bp.res_enc_pending, 0)),
                                                     -1, 'P69',
                                                     'P68'),
                                             'B', DECODE (
                                                     SIGN (
                                                        NVL (bp.res_budget_posted, 0)
                                                        - NVL (bp.res_actual_posted, 0)
                                                        - NVL (bp.res_enc_posted, 0)
                                                        - NVL (bp.res_actual_approved, 0)
                                                        - NVL (bp.res_actual_pending, 0)
                                                        - NVL (bp.res_enc_approved, 0)
                                                        - NVL (bp.res_enc_pending, 0)),
                                                     -1, 'F92',
                                                     'P68')))
       WHERE bp.packet_id = x_packetid
         AND bp.effect_on_funds_code IN ('D', 'I')
         AND bp.status_code = 'P';


      -- 7. Update all above levels with failure result code
      -- a. Propogate resource level to all other levels
      UPDATE gms_bc_packets bp
         SET bp.res_grp_result_code = res_result_code,
             bp.task_result_code = res_result_code,
             bp.top_task_result_code = res_result_code,
             bp.award_result_code = res_result_code,
             bp.result_code = res_result_code,
             bp.status_code = DECODE(x_mode,'C','F','R')
       WHERE bp.packet_id = x_packetid
         AND bp.effect_on_funds_code IN ('D', 'I')
         AND bp.status_code = 'P'
         AND SUBSTR (bp.res_result_code, 1, 1) = 'F';

       -- Call new procedure RAW_BURDEN_FAILURE to handle raw-burden failure ...
       RAW_BURDEN_FAILURE(x_packetid,     -- Packet_id
                          g_derived_mode, -- Mode
                          'RES'           -- Level
                         );

      -- Call new FUNCTION Full_mode_failure to handle full mode and scenario of failing all cdl when one cdl failed ..
      If FULL_MODE_FAILURE(x_packetid,     -- Packet_id
                        g_mode,         -- Mode , use g_mode
                        'RES'           -- Level
                         ) then
         If g_partial_flag = 'N' then
            -- If full mode, transactions have failed .. exit FC
            GOTO END_OF_FC_PROCESS;
         End if;
      End If;

--===============================================================================
--   	 RESOURCE LEVEL : INSERT NEGATIVE IN SUMMARY FOR FAILED TRANSACTIONS
--===============================================================================
   g_error_stage := 'FC PR : RES INSERT NEG';
   INSERT INTO gms_bc_packets_summary
            (packet_id,
    		 creation_date,
             budget_version_id,
			 top_task_id,
             bud_task_id,
			 parent_resource_id,
             budget_period_start_date,
             budget_period_end_date,
             actual_pending,
             enc_pending)
	Select  x_packetid,
	        x_date,
		    budget_version_id,
       		top_task_id,
			bud_task_id,
		    parent_resource_id,
      		budget_period_start_date,
      		budget_period_end_date,
       		-1 * nvl(sum(decode(status_code || actual_flag,'RA',nvl(entered_dr,0) - nvl(entered_cr,0),0)),0) ,
       		-1 * nvl(sum(decode(status_code || actual_flag,'RE',nvl(entered_dr,0) - nvl(entered_cr,0),0)),0)
	 from   gms_bc_packets
	 where  packet_id = x_packetid
	 and    res_result_code in ('F92','F63','F75','F65')
   group by budget_version_id, top_task_id,bud_task_id, parent_resource_id,budget_period_start_date, budget_period_end_date;

   -- Added commit for the base bug 3848201
   commit;


-- ==============================================================================
-- ********************** RESOURCE GROUP LEVEL FUNDS CHECK **********************
-- ==============================================================================
--===============================================================================
-- 	 			   RESOURCE GROUP LEVEL : POSTED BALANCE UPDATE
--===============================================================================
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('RESOURCE GROUP POSTED BALANCE UPDATE', 'C');
      END IF;
      g_error_stage := 'FC PR : RESG P BAL';
      UPDATE gms_bc_packets bp
         SET (bp.res_grp_budget_posted, bp.res_grp_actual_posted, bp.res_grp_enc_posted) =
                (SELECT SUM (NVL (budget_period_to_date, 0) * DECODE (balance_type, 'BGT', 1, 0)),
                        SUM (NVL (actual_period_to_date, 0) * DECODE (balance_type, 'EXP', 1, 0)),
                        SUM (NVL (encumb_period_to_date, 0) * DECODE (balance_type, 'REQ', 1, 'PO', 1, 'AP', 1, 'ENC', 1, 0))
                   FROM gms_balances gb
                  WHERE gb.budget_version_id = bp.budget_version_id
                    AND gb.project_id = bp.project_id
                    AND gb.award_id = bp.award_id
                    AND (
			 (bp.bud_task_id = 0) or -- budget at project
			 (bp.bud_task_id > 0 and gb.task_id = bp.bud_task_id and bp.task_id = bp.bud_task_id) or  -- budget at lowest task
			 (bp.bud_task_id > 0 and bp.top_task_id = bp.bud_task_id
			   and DECODE (gb.top_task_id, NULL, gb.task_id, gb.top_task_id) = bp.top_task_id ) -- top task
			) -- 2379815
                    --AND gb.resource_list_member_id = bp.bud_resource_list_member_id
                    AND ( (-- gb.balance_type = 'BGT'  and   -- Bug 2605070
 			   gb.resource_list_member_id = bp.parent_resource_id  -- Bug 2605070
  			   )
  			   OR
  			  (-- gb.balance_type <> 'BGT' and  -- Bug 2605070
   			   gb.parent_member_id = bp.parent_resource_id
   			  )
			)
                    AND gb.balance_type <> 'REV'
                    AND gb.start_date BETWEEN DECODE (
                                                 bp.time_phased_type_code,
                                                 'N', gb.start_date,
                                                 bp.budget_period_start_date)
                                          AND DECODE (
                                                 bp.time_phased_type_code,
                                                 'N', gb.start_date,
                                                 bp.budget_period_end_date)
                    AND gb.end_date BETWEEN DECODE (
                                               bp.time_phased_type_code,
                                               'N', gb.end_date,
                                               bp.budget_period_start_date)
                                        AND DECODE (
                                               bp.time_phased_type_code,
                                               'N', gb.end_date,
                                               bp.budget_period_end_date))
       WHERE bp.packet_id = x_packetid
         AND bp.effect_on_funds_code = 'D'
         AND bp.status_code = 'P'
         AND bp.categorization_code = 'R'
         AND bp.rg_funds_control_level_code <> 'N' ;
         -- AND bp.budgeted_at_resource_level = 'N'; -- Bug 2605070

--===================================================================================
-- 	RESOURCE GROUP LEVEL : APPROVED/PENDING BALANCE FOR PREVIOUS AND CURRENT PACKETS
--===================================================================================
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('RESOURCE GROUP LEVEL - APPROVED/PENDING BALANCE FOR CURRENT PACKET', 'C');
      END IF;
--  Bug 2092791
      g_error_stage := 'FC PR : RESG A/P BAL';
		 UPDATE gms_bc_packets bp
		    SET (bp.res_grp_actual_approved, bp.res_grp_actual_pending, bp.res_grp_enc_approved,
			        bp.res_grp_enc_pending) =
         			 (SELECT
					SUM(actual_approved),
					SUM(actual_pending),
					SUM(enc_approved),
					SUM(enc_pending)
				   FROM gms_bc_packets_summary gmsbcs
				  WHERE gmsbcs.packet_id = x_packetid
				    AND gmsbcs.bud_task_id = bp.bud_task_id
				    AND gmsbcs.budget_version_id = bp.budget_version_id
				    AND gmsbcs.parent_resource_id =  bp.parent_resource_id
				    --Bug 2490381 : Changed "=" to "<=" to consider all the
				    --              records from summary table which fall
				    --	 	    under budget_period_start_date and budget_period_end_date
				    --		    of current transaction.
				    -- Bug 2897560 : changed the strat date comparision to ">="
				    -- as we need to consider all the recods from summary table which fall
			            -- under budget_period_start_date and budget_period_end_date
			            -- of current transaction.
	 			    AND gmsbcs.budget_period_start_date >= bp.budget_period_start_date
				    AND gmsbcs.budget_period_end_date <= bp.budget_period_end_date)
		  WHERE bp.packet_id = x_packetid
                    AND bp.effect_on_funds_code = 'D'
                    AND bp.status_code = 'P'
                    AND bp.rg_funds_control_level_code <> 'N'
                    AND bp.categorization_code = 'R';
--           AND bp.budgeted_at_resource_level = 'N';
--  Bug 2092791
--===============================================================================
-- 	            RESOURCE GROUP LEVEL : AVAILABLE BALANCE UPDATE
--===============================================================================
      g_error_stage := 'FC PR : RESG A BAL';
      DECLARE
         CURSOR available_bal_at_res_grp IS
              SELECT (nvl(entered_dr,0)-nvl(entered_cr,0)) entered_dr,		--Bug 2092791
                     ROWID,
                     budget_version_id,
                     bud_task_id,
                     parent_resource_id,
                     effect_on_funds_code,    -- Bug 2927485
                     TRUNC (budget_period_start_date) budget_period_start_date,
                     TRUNC (budget_period_end_date) budget_period_end_date,
                     actual_flag
                FROM gms_bc_packets
               WHERE packet_id = x_packetid
                 AND effect_on_funds_code in ('D','I')  -- Bug 2092791
                 AND status_code = 'P'
                 AND rg_funds_control_level_code <> 'N'
                 AND categorization_code = 'R'
            ORDER BY budget_version_id,
                     bud_task_id,
                     parent_resource_id,
                     budget_period_start_date,
                     budget_period_end_date,
                     funds_check_seq DESC;
         x_entered_dr                     NUMBER (22, 5);
         x_rowid                          ROWID;
         x_pending_actual                 NUMBER         := -11;
         x_pending_enc                    NUMBER         := -11;
         x_amount                         NUMBER         := -11;
         x_budget_version_id_old          NUMBER         := -11;
         x_bud_task_id_old                NUMBER         := -11;
         x_bud_rlmi_old                   NUMBER         := -11;
         x_parent_rlmi_old                NUMBER         := -11;
         --x_budget_period_start_date_old   DATE           := TO_DATE ('01-01-1920', 'dd-mm-yyyy'); Bug 2276479
         --x_budget_period_end_date_old     DATE           := TO_DATE ('01-01-1920', 'dd-mm-yyyy'); Bug 2276479
	 x_budget_period_start_date_old   DATE           := NULL;
         x_budget_period_end_date_old     DATE           :=  NULL;
      BEGIN
         FOR res_grp_level IN available_bal_at_res_grp
         LOOP
            IF    res_grp_level.budget_version_id <> x_budget_version_id_old
               OR res_grp_level.bud_task_id <> x_bud_task_id_old
               OR res_grp_level.parent_resource_id <> x_parent_rlmi_old
               --OR res_grp_level.budget_period_start_date <> x_budget_period_start_date_old Bug 2276479
               --OR res_grp_level.budget_period_end_date <> x_budget_period_end_date_old THEN Bug 2276479
		OR res_grp_level.budget_period_start_date <> nvl(x_budget_period_start_date_old ,res_grp_level.budget_period_start_date + 1 )
               	OR res_grp_level.budget_period_end_date <> nvl(x_budget_period_end_date_old , res_grp_level.budget_period_end_date + 1 ) THEN
               IF res_grp_level.actual_flag = 'A' THEN
                  x_pending_actual := res_grp_level.entered_dr;
               ELSIF res_grp_level.actual_flag = 'E' THEN
                  x_pending_enc := res_grp_level.entered_dr;
               END IF;
               x_budget_version_id_old := res_grp_level.budget_version_id;
               x_bud_task_id_old := res_grp_level.bud_task_id;
               x_parent_rlmi_old := res_grp_level.parent_resource_id;
               x_budget_period_start_date_old := res_grp_level.budget_period_start_date;
               x_budget_period_end_date_old := res_grp_level.budget_period_end_date;
            ELSE
			 IF nvl(res_grp_level.entered_dr,0) >= 0  AND res_grp_level.effect_on_funds_code = 'D' THEN	--Bug 2092791 and 2927485 (Update pending balance
               UPDATE gms_bc_packets                                                                    --                if funds are decreasing)
                  SET res_grp_actual_pending = NVL (res_grp_actual_pending, 0)
                                               - DECODE (
                                                    res_grp_level.actual_flag,
                                                    'A', NVL (x_pending_actual, 0),
                                                    0),
                      res_grp_enc_pending = NVL (res_grp_enc_pending, 0)
                                            - DECODE (
                                                 res_grp_level.actual_flag,
                                                 'E', NVL (x_pending_enc, 0),
                                                 0)
                WHERE ROWID = res_grp_level.ROWID;
			 END IF;
               IF res_grp_level.actual_flag = 'A' THEN
                  x_pending_actual := x_pending_actual + res_grp_level.entered_dr;
               ELSIF res_grp_level.actual_flag = 'E' THEN
                  x_pending_enc := x_pending_enc + res_grp_level.entered_dr;
               END IF;
            END IF;
         END LOOP;
      END;
-- ================================================================================
-- 	                RESOURCE GROUP LEVEL : RESULT CODE UPDATE
-- ================================================================================
--	P72	: Transaction pass Funds Check at Resource Group level
--	P72	: Transaction pass Funds Check at Resource Group level in advisory
--	P76	: Transaction does not require funds check at this level
--  P78	: Increase Funds does not require Funds Check
--	F75	: Transaction Failed because of Raw
--	F63	: Transaction Failed because of Burden
--	F93	: Transaction failed funds check at Resource Group level
-- ================================================================================
      -- Changed for bug : 2927485: Added decode(bp.result_code,null,'P78',bp.result_code)
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('RESULT CODE UPDATE - RESOURCE GROUP', 'C');
      END IF;
      g_error_stage := 'FC PR : RESG RESULT UPD';
      UPDATE gms_bc_packets bp
         SET bp.res_grp_result_code = DECODE (
                                         bp.effect_on_funds_code,
                                         'I',decode(bp.result_code,null,'P78',bp.result_code)  ,
                                         'D', DECODE (
                                                 bp.rg_funds_control_level_code,
                                                 'N', 'P76',
                                                 'D', DECODE (
                                                         SIGN (
                                                            NVL (bp.res_grp_budget_posted, 0)
                                                            - NVL (bp.res_grp_actual_posted, 0)
                                                            - NVL (bp.res_grp_enc_posted, 0)
                                                            - NVL (bp.res_grp_actual_approved, 0)
                                                            - NVL (bp.res_grp_actual_pending, 0)
                                                            - NVL (bp.res_grp_enc_approved, 0)
                                                            - NVL (bp.res_grp_enc_pending, 0)),
                                                         -1, 'P73',
                                                         'P72'),
                                                 'B', DECODE (
                                                         SIGN (
                                                            NVL (bp.res_grp_budget_posted, 0)
                                                            - NVL (bp.res_grp_actual_posted, 0)
                                                            - NVL (bp.res_grp_enc_posted, 0)
                                                            - NVL (bp.res_grp_actual_approved, 0)
                                                            - NVL (bp.res_grp_actual_pending, 0)
                                                            - NVL (bp.res_grp_enc_approved, 0)
                                                            - NVL (bp.res_grp_enc_pending, 0)),
                                                         -1, 'F93',
                                                         'P72')))
       WHERE bp.packet_id = x_packetid
         AND bp.effect_on_funds_code IN ('D', 'I')
         AND bp.status_code = 'P';


      -- 7. Update all above levels with failure result code
      -- b. Propogate resource group level to all other levels
      UPDATE gms_bc_packets bp
         SET bp.task_result_code = res_grp_result_code,
             bp.top_task_result_code = res_grp_result_code,
             bp.award_result_code = res_grp_result_code,
             bp.result_code = res_grp_result_code,
             bp.status_code = DECODE(x_mode,'C','F','R')
       WHERE bp.packet_id = x_packetid
         AND bp.effect_on_funds_code IN ('D', 'I')
         AND bp.status_code = 'P'
         AND SUBSTR (bp.res_grp_result_code, 1, 1) = 'F';

       -- Call new procedure RAW_BURDEN_FAILURE to handle raw-burden failure ...
       RAW_BURDEN_FAILURE(x_packetid,     -- Packet_id
                          g_derived_mode, -- Mode
                          'RESG'          -- Level
                         );

      -- Call new FUNCTION Full_mode_failure to handle full mode and scenario of failing all cdl when one cdl failed ..
      If FULL_MODE_FAILURE(x_packetid,     -- Packet_id
                        g_mode,         -- Mode , use g_mode
                        'RESG'           -- Level
                         ) then
         If g_partial_flag = 'N' then
            -- If full mode, transactions have failed .. exit FC
            GOTO END_OF_FC_PROCESS;
         End if;
      End If;

-- Bug 2092791
--===============================================================================
--  RESOURCE GROUP LEVEL : INSERT NEGATIVE IN SUMMARY FOR FAILED TRANSACTIONS
--===============================================================================
      g_error_stage := 'FC PR : RESG IN NEG';
	   INSERT INTO gms_bc_packets_summary
            (packet_id,
    		 creation_date,
             budget_version_id,
			 top_task_id,
             bud_task_id,
             budget_period_start_date,
             budget_period_end_date,
             actual_pending,
             enc_pending)
	Select  x_packetid,
	        x_date,
		    budget_version_id,
			top_task_id,
       		bud_task_id,
      		budget_period_start_date,
      		budget_period_end_date,
       		-1 * nvl(sum(decode(status_code || actual_flag,'RA',nvl(entered_dr,0) - nvl(entered_cr,0),0)),0) ,
       		-1 * nvl(sum(decode(status_code || actual_flag,'RE',nvl(entered_dr,0) - nvl(entered_cr,0),0)),0)
	 from   gms_bc_packets
	 where  packet_id = x_packetid
	 and    res_grp_result_code in ('F93','F63','F75','F65')
	 and    nvl(substr(res_result_code,1,1),'P') = 'P'
    group by budget_version_id, top_task_id, bud_task_id, budget_period_start_date, budget_period_end_date;

    -- Added commit for the base bug 3848201
    commit;

-- ==============================================================================
-- ************************** TASK LEVEL FUNDS CHECK ****************************
-- ==============================================================================
--===============================================================================
-- 						TASK LEVEL : POSTED BALANCE UPDATE
--===============================================================================
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('TASK :POSTED BALANCE ', 'C');
      END IF;
      g_error_stage := 'FC PR : TASK P BAL';
      UPDATE gms_bc_packets bp
         SET (bp.task_budget_posted, bp.task_actual_posted, bp.task_enc_posted) =
                (SELECT SUM (NVL (budget_period_to_date, 0) * DECODE (balance_type, 'BGT', 1, 0)),
                        SUM (NVL (actual_period_to_date, 0) * DECODE (balance_type, 'EXP', 1, 0)),
                        SUM (NVL (encumb_period_to_date, 0) * DECODE (balance_type, 'REQ', 1, 'PO', 1, 'AP', 1, 'ENC', 1, 0))
                   FROM gms_balances gb
                  WHERE gb.budget_version_id = bp.budget_version_id
                    AND gb.project_id = bp.project_id
                    AND gb.award_id = bp.award_id
                    AND gb.task_id = bp.task_id
                    AND gb.balance_type <> 'REV'
                    AND gb.start_date BETWEEN DECODE (
                                                 bp.time_phased_type_code,
                                                 'N', gb.start_date,
                                                 bp.budget_period_start_date)
                                          AND DECODE (
                                                 bp.time_phased_type_code,
                                                 'N', gb.start_date,
                                                 bp.budget_period_end_date)
                    AND gb.end_date BETWEEN DECODE (
                                               bp.time_phased_type_code,
                                               'N', gb.end_date,
                                               bp.budget_period_start_date)
                                        AND DECODE (
                                               bp.time_phased_type_code,
                                               'N', gb.end_date,
                                               bp.budget_period_end_date))
       WHERE bp.packet_id = x_packetid
         AND bp.effect_on_funds_code = 'D'
         AND bp.status_code = 'P'
         AND bp.t_funds_control_level_code <> 'N'
         AND bp.bud_task_id <> 0;
      -- ** t_funds_control_level_code CAN BE 'N' if 1.Project Level Funding 2. None Control
--===============================================================================
-- 	TASK LEVEL : APPROVED/PENDING BALANCE FOR PREVIOUS AND CURRENT PACKETS
--===============================================================================
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('TASK LEVEL - APPROVED/PENDING BALANCE FOR PREVIOUS PACKETS', 'C');
      END IF;

      g_error_stage := 'FC PR : TASK A/P BAL';
		 UPDATE gms_bc_packets bp
   		    SET (bp.task_actual_approved, bp.task_actual_pending, bp.task_enc_approved,
			        bp.task_enc_pending) =
         			 (SELECT
					 		 SUM (actual_approved),
                             SUM (actual_pending),
                             SUM (enc_approved),
                             SUM (enc_pending)
           			    FROM gms_bc_packets_summary gmsbcs
		 	           WHERE gmsbcs.packet_id = x_packetid
				     AND gmsbcs.budget_version_id = bp.budget_version_id
				     AND gmsbcs.bud_task_id = bp.bud_task_id
					  --Bug 2490381 : Changed "=" to "<=" to consider all the
					  --              records from summary table which fall
					  --		  under budget_period_start_date and budget_period_end_date
					  --		  of current transaction.
					  -- Bug 2897560 : changed the start date comparision to ">="
					  -- as we need to consider all the recods from summary table which fall
					  -- under budget_period_start_date and budget_period_end_date
					  -- of current transaction.
	 			     AND gmsbcs.budget_period_start_date >= bp.budget_period_start_date
				     AND gmsbcs.budget_period_end_date <= bp.budget_period_end_date)
		  WHERE bp.packet_id = x_packetid
		    AND bp.effect_on_funds_code = 'D'
			AND bp.status_code = 'P'
			AND bp.t_funds_control_level_code <> 'N'
			AND bp.bud_task_id <> 0;
--===============================================================================
-- 	                  TASK LEVEL : AVAILABLE BALANCE UPDATE
--===============================================================================
-- 2092791
      g_error_stage := 'FC PR : TASK A BAL';
      DECLARE
         CURSOR available_bal_at_task IS
               SELECT (nvl(entered_dr,0)- nvl(entered_cr,0)) entered_dr,  -- Bug 2092791
                     ROWID,
                     budget_version_id,
                     bud_task_id,
                     effect_on_funds_code,    -- Bug 2927485
                     TRUNC (budget_period_start_date) budget_period_start_date,
                     TRUNC (budget_period_end_date) budget_period_end_date,
                     actual_flag
                FROM gms_bc_packets
               WHERE packet_id = x_packetid
                 AND effect_on_funds_code in ('D','I') 				 -- Bug 2092791
                 AND status_code = 'P'
                 AND t_funds_control_level_code <> 'N'
                 AND bud_task_id <> 0
            ORDER BY budget_version_id,
                     bud_task_id,
                     budget_period_start_date,
                     budget_period_end_date,
                     funds_check_seq DESC;
         x_entered_dr                     NUMBER (22, 5);
         x_rowid                          ROWID;
         x_pending_actual                 NUMBER         := -11;
         x_pending_enc                    NUMBER         := -11;
         x_amount                         NUMBER         := -11;
         x_budget_version_id_old          NUMBER         := -11;
         x_bud_task_id_old                NUMBER         := -11;
         x_bud_rlmi_old                   NUMBER         := -11;
         --x_budget_period_start_date_old   DATE           := TO_DATE ('01-01-1720', 'dd-mm-yyyy'); Bug 2276479
         --x_budget_period_end_date_old     DATE           := TO_DATE ('01-01-1720', 'dd-mm-yyyy'); Bug 2276479
	x_budget_period_start_date_old   DATE           :=  NULL;
	x_budget_period_end_date_old     DATE           :=  NULL;
      BEGIN
         FOR task_level IN available_bal_at_task
         LOOP
            IF    task_level.budget_version_id <> x_budget_version_id_old
               OR task_level.bud_task_id <> x_bud_task_id_old
		OR task_level.budget_period_start_date <> nvl(x_budget_period_start_date_old ,task_level.budget_period_start_date + 1 )
		OR task_level.budget_period_end_date <> nvl(x_budget_period_end_date_old , task_level.budget_period_end_date + 1 ) THEN

               IF task_level.actual_flag = 'A' THEN
                  x_pending_actual := task_level.entered_dr;
               ELSIF task_level.actual_flag = 'E' THEN
                  x_pending_enc := task_level.entered_dr;
               END IF;
               x_budget_version_id_old := task_level.budget_version_id;
               x_bud_task_id_old := task_level.bud_task_id;
               x_budget_period_start_date_old := task_level.budget_period_start_date;
               x_budget_period_end_date_old := task_level.budget_period_end_date;
            ELSE
             IF nvl(task_level.entered_dr,0) >=0  AND task_level.effect_on_funds_code = 'D' THEN	--Bug 2092791 and 2927485 (Update pending balance
               UPDATE gms_bc_packets                                                                --                if funds are decreasing)
                  SET task_actual_pending = NVL (task_actual_pending, 0)
                                            - DECODE (
                                                 task_level.actual_flag,
                                                 'A', NVL (x_pending_actual, 0),
                                                 0),
                      task_enc_pending = NVL (task_enc_pending, 0)
                                         - DECODE (
                                              task_level.actual_flag,
                                              'E', NVL (x_pending_enc, 0),
                                              0)
                WHERE ROWID = task_level.ROWID;
			  END IF;
               IF task_level.actual_flag = 'A' THEN
                  x_pending_actual := x_pending_actual + task_level.entered_dr;
               ELSIF task_level.actual_flag = 'E' THEN
                  x_pending_enc := x_pending_enc + task_level.entered_dr;
               END IF;
            END IF;
         END LOOP;
      END;

-- ================================================================================
-- 	                     TASK LEVEL : RESULT CODE UPDATE
-- ================================================================================
--	P64	: Transaction pass Funds Check at Task level
--	P65	: Transaction pass Funds Check at Task level in advisory
--	P76	: Transaction does not require funds check at this level
--  P78	: Increase Funds does not require Funds Check
--	F63	: Transaction Failed because of Burden
--	F91	: Transaction failed funds check at Task level
-- ================================================================================
      -- 3. Task Result Code Update
 -- Added decode(bp.result_code,null,'P78',bp.result_code for bug : 2927485
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('TASK : RESULT CODE ', 'C');
      END IF;
      g_error_stage := 'FC PR : TASK RESULT CD';
      UPDATE gms_bc_packets bp
         SET bp.task_result_code = DECODE (
                                      bp.effect_on_funds_code,
                                      'I', decode(bp.result_code,null,'P78',bp.result_code) ,
                                      'D', DECODE (
                                              bp.t_funds_control_level_code,
                                              'N', 'P76',
                                              'D', DECODE (
                                                      SIGN (
                                                         NVL (bp.task_budget_posted, 0)
                                                         - NVL (bp.task_actual_posted, 0)
                                                         - NVL (bp.task_enc_posted, 0)
                                                         - NVL (bp.task_actual_approved, 0)
                                                         - NVL (bp.task_actual_pending, 0)
                                                         - NVL (bp.task_enc_approved, 0)
                                                         - NVL (bp.task_enc_pending, 0)),
                                                      -1, 'P65',
                                                      'P64'),
                                              'B', DECODE (
                                                      SIGN (
                                                         NVL (bp.task_budget_posted, 0)
                                                         - NVL (bp.task_actual_posted, 0)
                                                         - NVL (bp.task_enc_posted, 0)
                                                         - NVL (bp.task_actual_approved, 0)
                                                         - NVL (bp.task_actual_pending, 0)
                                                         - NVL (bp.task_enc_approved, 0)
                                                         - NVL (bp.task_enc_pending, 0)),
                                                      -1, 'F91',
                                                      'P64')))
       WHERE bp.packet_id = x_packetid
         AND bp.effect_on_funds_code IN ('D', 'I')
         AND bp.status_code = 'P';



      -- 5. Update all above levels with failure result code
      UPDATE gms_bc_packets bp
         SET bp.result_code = bp.task_result_code,
             bp.top_task_result_code = bp.task_result_code,
             bp.award_result_code = bp.task_result_code,
             bp.status_code = DECODE(x_mode,'C','F','R')
       WHERE bp.packet_id = x_packetid
         AND bp.effect_on_funds_code IN ('D', 'I')
         AND bp.status_code = 'P'
         AND SUBSTR (bp.task_result_code, 1, 1) = 'F';

       -- Call new procedure RAW_BURDEN_FAILURE to handle raw-burden failure ...
       RAW_BURDEN_FAILURE(x_packetid,     -- Packet_id
                          g_derived_mode, -- Mode
                          'TSK'           -- Level
                         );


      -- Call new FUNCTION Full_mode_failure to handle full mode and scenario of failing all cdl when one cdl failed ..
      If FULL_MODE_FAILURE(x_packetid,     -- Packet_id
                        g_mode,         -- Mode , use g_mode
                        'TSK'           -- Level
                         ) then
         If g_partial_flag = 'N' then
            -- If full mode, transactions have failed .. exit FC
            GOTO END_OF_FC_PROCESS;
         End if;
      End If;
-- 	Bug 2092791
--==========================================================================
--     TASK LEVEL : INSERT NEGATIVE IN SUMMARY FOR FAILED TRANSACTIONS
--==========================================================================
       g_error_stage := 'FC PR : TASK IN NEG';
	   INSERT INTO gms_bc_packets_summary
            (packet_id,
    		 creation_date,
             budget_version_id,
			 top_task_id,
             budget_period_start_date,
             budget_period_end_date,
             actual_pending,
             enc_pending)
	Select  x_packetid,
	        x_date,
		    budget_version_id,
			top_task_id,
      		budget_period_start_date,
      		budget_period_end_date,
       		-1 * nvl(sum(decode(status_code || actual_flag,'RA',nvl(entered_dr,0) - nvl(entered_cr,0),0)),0) ,
       		-1 * nvl(sum(decode(status_code || actual_flag,'RE',nvl(entered_dr,0) - nvl(entered_cr,0),0)),0)
	 from   gms_bc_packets
	 where  packet_id = x_packetid
	 and    task_result_code in ('F91','F63','F75','F65')
	 and    substr(res_grp_result_code,1,1) = 'P'
    group by budget_version_id, top_task_id, budget_period_start_date, budget_period_end_date;

    -- Added commit for the base bug 3848201
    commit;

-- ==============================================================================
-- ************************* TOP TASK LEVEL FUNDS CHECK *************************
-- ==============================================================================
--===============================================================================
-- 						TOP TASK LEVEL : POSTED BALANCE UPDATE
--===============================================================================
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('TOP TASK :POSTED BALANCE ', 'C');
      END IF;
      g_error_stage := 'FC PR : TTASK P BAL';
      UPDATE gms_bc_packets bp
         SET (bp.top_task_budget_posted, bp.top_task_actual_posted, bp.top_task_enc_posted) =
                (SELECT SUM (NVL (budget_period_to_date, 0) * DECODE (balance_type, 'BGT', 1, 0)),
                        SUM (NVL (actual_period_to_date, 0) * DECODE (balance_type, 'EXP', 1, 0)),
                        SUM (NVL (encumb_period_to_date, 0) * DECODE (balance_type, 'REQ', 1, 'PO', 1, 'AP', 1, 'ENC', 1, 0))
                   FROM gms_balances gb
                  WHERE gb.budget_version_id = bp.budget_version_id
                    AND gb.project_id = bp.project_id
                    AND gb.award_id = bp.award_id
                    AND gb.balance_type <> 'REV'
                    AND DECODE (gb.top_task_id, NULL, gb.task_id, gb.top_task_id) =
                                                                bp.top_task_id
                    AND gb.start_date BETWEEN DECODE (
                                                 bp.time_phased_type_code,
                                                 'N', gb.start_date,
                                                 bp.budget_period_start_date)
                                          AND DECODE (
                                                 bp.time_phased_type_code,
                                                 'N', gb.start_date,
                                                 bp.budget_period_end_date)
                    AND gb.end_date BETWEEN DECODE (
                                               bp.time_phased_type_code,
                                               'N', gb.end_date,
                                               bp.budget_period_start_date)
                                        AND DECODE (
                                               bp.time_phased_type_code,
                                               'N', gb.end_date,
                                               bp.budget_period_end_date))
       WHERE bp.packet_id = x_packetid
         AND bp.effect_on_funds_code = 'D'
         AND bp.status_code = 'P'
         AND bp.tt_funds_control_level_code <> 'N'
         AND bp.bud_task_id <> 0;
      -- ** t_funds_control_level_code CAN BE 'N' if 1.Project Level Funding 2. None Control
--===============================================================================
-- 	TOP TASK LEVEL : APPROVED/PENDING BALANCE FOR PREVIOUS AND CURRENT PACKETS
--===============================================================================
  IF g_debug = 'Y' THEN
  	gms_error_pkg.gms_debug ('TOP TASK LEVEL - APPROVED/PENDING BALANCE FOR PREVIOUS PACKETS', 'C');
  END IF;
  g_error_stage := 'FC PR : TTASK A/P BAL';
-- Bug 2092791

		 UPDATE gms_bc_packets bp
   		    SET (bp.top_task_actual_approved, bp.top_task_actual_pending, bp.top_task_enc_approved,
			        bp.top_task_enc_pending) =
         			 (SELECT
					 		 SUM (actual_approved),
                             SUM (actual_pending),
                             SUM (enc_approved),
                             SUM (enc_pending)
           			    FROM gms_bc_packets_summary gmsbcs
				       WHERE gmsbcs.packet_id = x_packetid
				         AND gmsbcs.budget_version_id = bp.budget_version_id
					 AND gmsbcs.top_task_id = bp.top_task_id
					  --Bug 2490381 : Changed "=" to "<=" to consider all the
					  --              records from summary table which fall
					  --		  under budget_period_start_date and budget_period_end_date
					  --		  of current transaction.
					  -- Bug 2897560 : changed the start date comparision to ">="
					  -- as we need to consider all the recods from summary table which fall
					  -- under budget_period_start_date and budget_period_end_date
					  -- of current transaction.
					 AND gmsbcs.budget_period_start_date >= bp.budget_period_start_date
					 AND gmsbcs.budget_period_end_date <= bp.budget_period_end_date)
		  WHERE bp.packet_id = x_packetid
		    AND bp.effect_on_funds_code = 'D'
			AND bp.status_code = 'P'
			AND bp.tt_funds_control_level_code <> 'N'
			AND bp.bud_task_id <> 0;
-- Bug 2092791

--===============================================================================
-- 	                TOP TASK LEVEL : AVAILABLE BALANCE UPDATE
--===============================================================================
      g_error_stage := 'FC PR : TTASK A BAL';
      DECLARE
         CURSOR available_bal_at_top_task IS
               SELECT (nvl(entered_dr,0)- nvl(entered_cr,0)) entered_dr,  -- Bug 2092791
                     ROWID,
                     budget_version_id,
                     top_task_id,
                     effect_on_funds_code,    -- Bug 2927485
                     TRUNC (budget_period_start_date) budget_period_start_date,
                     TRUNC (budget_period_end_date) budget_period_end_date,
                     actual_flag
                FROM gms_bc_packets
               WHERE packet_id = x_packetid
                 AND effect_on_funds_code in ('D','I')    -- Bug 2092791
                 AND status_code = 'P'
                 AND tt_funds_control_level_code <> 'N'
                 AND bud_task_id <> 0
            ORDER BY budget_version_id,
                     top_task_id,
                     budget_period_start_date,
                     budget_period_end_date,
                     funds_check_seq DESC;
         x_entered_dr                     NUMBER (22, 5);
         x_rowid                          ROWID;
         x_pending_actual                 NUMBER         := -11;
         x_pending_enc                    NUMBER         := -11;
         x_amount                         NUMBER         := -11;
         x_budget_version_id_old          NUMBER         := -11;
         x_bud_task_id_old                NUMBER         := -11;
         x_top_task_id_old                NUMBER         := -11;
         x_bud_rlmi_old                   NUMBER         := -11;
         --x_budget_period_start_date_old   DATE           := TO_DATE ('01-01-1720', 'dd-mm-yyyy'); Bug 2276479
         --x_budget_period_end_date_old     DATE           := TO_DATE ('01-01-1720', 'dd-mm-yyyy'); Bug 2276479
	x_budget_period_start_date_old   DATE           :=  NULL;
        x_budget_period_end_date_old     DATE           :=  NULL;
      BEGIN
         FOR top_task_level IN available_bal_at_top_task
         LOOP
            IF    top_task_level.budget_version_id <> x_budget_version_id_old
               OR top_task_level.top_task_id <> x_top_task_id_old
               --OR top_task_level.budget_period_start_date <> x_budget_period_start_date_old Bug 2276479
               --OR top_task_level.budget_period_end_date <> x_budget_period_end_date_old THEN Bug 2276479
		OR top_task_level.budget_period_start_date <> nvl(x_budget_period_start_date_old ,top_task_level.budget_period_start_date + 1 )
		OR top_task_level.budget_period_end_date <> nvl(x_budget_period_end_date_old , top_task_level.budget_period_end_date + 1 ) THEN

               IF top_task_level.actual_flag = 'A' THEN
                  x_pending_actual := top_task_level.entered_dr;
               ELSIF top_task_level.actual_flag = 'E' THEN
                  x_pending_enc := top_task_level.entered_dr;
               END IF;
               x_budget_version_id_old := top_task_level.budget_version_id;
               x_top_task_id_old := top_task_level.top_task_id;
               x_budget_period_start_date_old := top_task_level.budget_period_start_date;
               x_budget_period_end_date_old := top_task_level.budget_period_end_date;
            ELSE
             IF nvl(top_task_level.entered_dr,0) >=0  AND top_task_level.effect_on_funds_code = 'D' THEN	--Bug 2092791 and 2927485 (Update pending balance
			   UPDATE gms_bc_packets                                                                        --                if funds are decreasing)
                  SET top_task_actual_pending = NVL (top_task_actual_pending, 0)
                                                - DECODE (
                                                     top_task_level.actual_flag,
                                                     'A', NVL (x_pending_actual, 0),
                                                     0),
                      top_task_enc_pending = NVL (top_task_enc_pending, 0)
                                             - DECODE (
                                                  top_task_level.actual_flag,
                                                  'E', NVL (x_pending_enc, 0),
                                                  0)
                WHERE ROWID = top_task_level.ROWID;
			 END IF;
               IF top_task_level.actual_flag = 'A' THEN
                  x_pending_actual := x_pending_actual + top_task_level.entered_dr;
               ELSIF top_task_level.actual_flag = 'E' THEN
                  x_pending_enc := x_pending_enc + top_task_level.entered_dr;
               END IF;
            END IF;
         END LOOP;
      END;

-- ================================================================================
-- 	                   TOP TASK LEVEL : RESULT CODE UPDATE
-- ================================================================================
--	P79	: Transaction pass Funds Check at Top Task level
--	P80	: Transaction pass Funds Check at Top Task level in advisory
--	P76	: Transaction does not require funds check at this level
--  P78	: Increase Funds does not require Funds Check
--	F63	: Transaction Failed because of Burden
--	F60	: Transaction failed funds check at Top Task level
-- ================================================================================
      -- Top Task Result Code Update
      -- Added decode(bp.result_code,null,'P78',bp.result_code for bug : 2927485
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('TOP TASK : RESULT CODE ', 'C');
      END IF;
      g_error_stage := 'FC PR : TTASK RESULT CODE';
      UPDATE gms_bc_packets bp
         SET bp.top_task_result_code = DECODE (
                                          bp.effect_on_funds_code,
                                          'I', decode(bp.result_code,null,'P78',bp.result_code),
                                          'D', DECODE (
                                                  bp.tt_funds_control_level_code,
                                                  'N', 'P76',
                                                  'D', DECODE (
                                                          SIGN (
                                                             NVL (bp.top_task_budget_posted, 0)
                                                             - NVL (bp.top_task_actual_posted, 0)
                                                             - NVL (bp.top_task_enc_posted, 0)
                                                             - NVL (bp.top_task_actual_approved, 0)
                                                             - NVL (bp.top_task_actual_pending, 0)
                                                             - NVL (bp.top_task_enc_approved, 0)
                                                             - NVL (bp.top_task_enc_pending, 0)),
                                                          -1, 'P80',
                                                          'P79'),
                                                  'B', DECODE (
                                                          SIGN (
                                                             NVL (bp.top_task_budget_posted, 0)
                                                             - NVL (bp.top_task_actual_posted, 0)
                                                             - NVL (bp.top_task_enc_posted, 0)
                                                             - NVL (bp.top_task_actual_approved, 0)
                                                             - NVL (bp.top_task_actual_pending, 0)
                                                             - NVL (bp.top_task_enc_approved, 0)
                                                             - NVL (bp.top_task_enc_pending, 0)),
                                                          -1, 'F60',
                                                          'P79')))
       WHERE bp.packet_id = x_packetid
         AND bp.effect_on_funds_code IN ('D', 'I')
         AND bp.status_code = 'P';


      -- 5. Update all above levels with failure result code
      UPDATE gms_bc_packets bp
         SET bp.result_code = bp.top_task_result_code,
             bp.award_result_code = bp.top_task_result_code,
             bp.status_code = DECODE(x_mode,'C','F','R')
       WHERE bp.packet_id = x_packetid
         AND bp.effect_on_funds_code IN ('D', 'I')
         AND bp.status_code = 'P'
         AND SUBSTR (bp.top_task_result_code, 1, 1) = 'F';

       -- Call new procedure RAW_BURDEN_FAILURE to handle raw-burden failure ...
       RAW_BURDEN_FAILURE(x_packetid,     -- Packet_id
                          g_derived_mode, -- Mode
                          'TTSK'           -- Level
                         );


      -- Call new FUNCTION Full_mode_failure to handle full mode and scenario of failing all cdl when one cdl failed ..
      If FULL_MODE_FAILURE(x_packetid,     -- Packet_id
                        g_mode,         -- Mode , use g_mode
                        'TTSK'           -- Level
                         ) then
         If g_partial_flag = 'N' then
            -- If full mode, transactions have failed .. exit FC
            GOTO END_OF_FC_PROCESS;
         End if;
      End If;

       g_error_stage := 'FC PR : TTASK IN NEG';
	   INSERT INTO gms_bc_packets_summary
            (packet_id,
			 creation_date,
             budget_version_id,
             budget_period_start_date,
             budget_period_end_date,
             actual_pending,
             enc_pending)
	Select  x_packetid,
            x_date,
            budget_version_id,
      		budget_period_start_date,
      		budget_period_end_date,
       		-1 * nvl(sum(decode(status_code || actual_flag, 'RA',nvl(entered_dr,0) - nvl(entered_cr,0),0)),0) ,
       		-1 * nvl(sum(decode(status_code || actual_flag, 'RE',nvl(entered_dr,0) - nvl(entered_cr,0),0)),0)
         from   gms_bc_packets
         where  packet_id = x_packetid
         and    top_task_result_code in ('F60','F63','F65','F75')
		 and    substr(task_result_code,1,1) = 'P'
         group by budget_version_id, budget_period_start_date, budget_period_end_date;

       -- Added commit for the base bug 3848201
       commit;


-- ==============================================================================
-- ************************* AWARD  LEVEL FUNDS CHECK ***************************
-- ==============================================================================
--===============================================================================
-- 		     		   AWARD LEVEL : POSTED BALANCE UPDATE
--===============================================================================
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('AWARD:POSTED BALANCE  ', 'C');
      END IF;
      g_error_stage := 'FC PR : AWARD P B';
      UPDATE gms_bc_packets bp
         SET (bp.award_budget_posted, bp.award_actual_posted, bp.award_enc_posted) =
                (SELECT SUM (NVL (budget_period_to_date, 0) * DECODE (balance_type, 'BGT', 1, 0)),
                        SUM (NVL (actual_period_to_date, 0) * DECODE (balance_type, 'EXP', 1, 0)),
                        SUM (NVL (encumb_period_to_date, 0) * DECODE (balance_type, 'REQ', 1, 'PO', 1, 'AP', 1, 'ENC', 1, 0))
                   FROM gms_balances gb
                  WHERE gb.budget_version_id = bp.budget_version_id
                    AND gb.project_id = bp.project_id
                    AND gb.award_id = bp.award_id
                    AND gb.start_date BETWEEN DECODE (
                                                 bp.time_phased_type_code,
                                                 'N', gb.start_date,
                                                 bp.budget_period_start_date)
                                          AND DECODE (
                                                 bp.time_phased_type_code,
                                                 'N', gb.start_date,
                                                 bp.budget_period_end_date)
                    AND gb.end_date BETWEEN DECODE (
                                               bp.time_phased_type_code,
                                               'N', gb.end_date,
                                               bp.budget_period_start_date)
                                        AND DECODE (
                                               bp.time_phased_type_code,
                                               'N', gb.end_date,
                                               bp.budget_period_end_date))
       WHERE bp.packet_id = x_packetid
         AND bp.effect_on_funds_code = 'D'
         AND bp.status_code = 'P'
         AND bp.a_funds_control_level_code <> 'N';
--===============================================================================
-- 	AWARD LEVEL : APPROVED/PENDING BALANCE FOR PREVIOUS AND CURRENT PACKETS
--===============================================================================
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('AWARD LEVEL - APPROVED/PENDING BALANCE FOR PREVIOUS PACKETS', 'C');
      END IF;
      g_error_stage := 'FC PR : AWARD A/P B';
--  Bug 2092791
	  UPDATE gms_bc_packets bp
	     SET (bp.award_actual_approved, bp.award_actual_pending, bp.award_enc_approved,
		         bp.award_enc_pending) =
         			 (SELECT
						   		   SUM (actual_approved),
						           SUM (actual_pending),
								   SUM (enc_approved),
								   SUM (enc_pending)
					          FROM gms_bc_packets_summary gmsbcs
							 WHERE gmsbcs.packet_id = x_packetid
 							   AND gmsbcs.budget_version_id = bp.budget_version_id
							   --Bug 2490381 : Changed "=" to "<=" to consider all the
 							   --              records from summary table which fall
							   --		   under budget_period_start_date and budget_period_end_date
 							   --		   of current transaction.
					                   -- Bug 2897560 : changed the start date comparision to ">="
					                   -- as we need to consider all the recods from summary table which fall
					                   -- under budget_period_start_date and budget_period_end_date
					                   -- of current transaction.
					                   AND gmsbcs.budget_period_start_date >= bp.budget_period_start_date
							   AND gmsbcs.budget_period_end_date <= bp.budget_period_end_date)
	   WHERE bp.packet_id = x_packetid
		 AND bp.effect_on_funds_code = 'D'
		 AND bp.status_code = 'P'
		 AND bp.a_funds_control_level_code <> 'N';
--  Bug 2092791

--===============================================================================
-- 	                   AWARD LEVEL : AVAILABLE BALANCE UPDATE
--===============================================================================
      g_error_stage := 'FC PR : AWARD A B';
      DECLARE
         CURSOR available_bal_at_awd IS
              SELECT (nvl(entered_dr,0) - nvl(entered_cr,0)) entered_dr,	--Bug 2092791
                     ROWID,
                     budget_version_id,
                     effect_on_funds_code,    -- Bug 2927485
                     TRUNC (budget_period_start_date) budget_period_start_date,
                     TRUNC (budget_period_end_date) budget_period_end_date,
                     actual_flag
                FROM gms_bc_packets
               WHERE packet_id = x_packetid
                 AND effect_on_funds_code in  ('D','I') 	-- 2092791
                 AND status_code = 'P'
                 AND a_funds_control_level_code <> 'N'
            ORDER BY budget_version_id,
                     budget_period_start_date,
                     budget_period_end_date,
                     funds_check_seq DESC;
         x_entered_dr                     NUMBER (22, 5);
         x_rowid                          ROWID;
         x_pending_actual                 NUMBER         := -11;
         x_pending_enc                    NUMBER         := -11;
         x_amount                         NUMBER         := -11;
         x_budget_version_id_old          NUMBER         := -11;
         x_bud_task_id_old                NUMBER         := -11;
         x_bud_rlmi_old                   NUMBER         := -11;
         --x_budget_period_start_date_old   DATE           := TO_DATE ('01-01-1720', 'dd-mm-yyyy'); Bug 2276479
         --x_budget_period_end_date_old     DATE           := TO_DATE ('01-01-1720', 'dd-mm-yyyy'); Bug 2276479
	x_budget_period_start_date_old   DATE           :=  NULL;
	x_budget_period_end_date_old     DATE           :=  NULL;
      BEGIN
         FOR award_level IN available_bal_at_awd
         LOOP
            IF    award_level.budget_version_id <> x_budget_version_id_old
               --OR award_level.budget_period_start_date <> x_budget_period_start_date_old Bug 2276479
               --OR award_level.budget_period_end_date <> x_budget_period_end_date_old THEN Bug 2276479
		OR award_level.budget_period_start_date <> nvl(x_budget_period_start_date_old ,award_level.budget_period_start_date + 1 )
		OR award_level.budget_period_end_date <> nvl(x_budget_period_end_date_old , award_level.budget_period_end_date + 1 ) THEN

               IF award_level.actual_flag = 'A' THEN
                  x_pending_actual := award_level.entered_dr;
               ELSIF award_level.actual_flag = 'E' THEN
                  x_pending_enc := award_level.entered_dr;
               END IF;
               x_budget_version_id_old := award_level.budget_version_id;
               x_budget_period_start_date_old := award_level.budget_period_start_date;
               x_budget_period_end_date_old := award_level.budget_period_end_date;
            ELSE
			  IF nvl(award_level.entered_dr,0) >= 0  AND award_level.effect_on_funds_code = 'D' THEN	--Bug 2092791 and 2927485(Update pending balance
			                                                                                            --                if funds are decreasing)
               UPDATE gms_bc_packets
                  SET award_actual_pending = NVL (award_actual_pending, 0)
                                             - DECODE (
                                                  award_level.actual_flag,
                                                  'A', NVL (x_pending_actual, 0),
                                                  0),
                      award_enc_pending = NVL (award_enc_pending, 0)
                                          - DECODE (
                                               award_level.actual_flag,
                                               'E', NVL (x_pending_enc, 0),
                                               0)
                WHERE ROWID = award_level.ROWID;
			  END IF;
               IF award_level.actual_flag = 'A' THEN
                  x_pending_actual := x_pending_actual + award_level.entered_dr;
               ELSIF award_level.actual_flag = 'E' THEN
                  x_pending_enc := x_pending_enc + award_level.entered_dr;
               END IF;
            END IF;
         END LOOP;
      END;
-- ================================================================================
-- 	                       AWARD LEVEL : RESULT CODE UPDATE
-- ================================================================================
--	P60	: Transaction pass Funds Check at Award level
--	P61	: Transaction pass Funds Check at Award level in advisory
--	P76	: Transaction does not require funds check at this level
--  P78	: Increase Funds does not require Funds Check
--  F53 :
--	F63	: Transaction Failed because of Burden
--	F90	: Transaction failed funds check at Award level
-- ================================================================================
  -- Added decode(bp.result_code,null,'P78',bp.result_code  for bug : 2927485
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('AWARD: Result Code  ', 'C');
      END IF;
      g_error_stage := 'FC PR : AWARD RESULT';
      UPDATE gms_bc_packets bp
         SET bp.award_result_code = DECODE (
                                       bp.effect_on_funds_code,
                                       'I',decode(bp.result_code,null,'P78',bp.result_code ),
                                       'D', DECODE (
                                               bp.a_funds_control_level_code,
                                               'N', 'P76',
                                               'D', DECODE (
                                                       SIGN (
                                                          NVL (bp.award_budget_posted, 0)
                                                          - NVL (bp.award_actual_posted, 0)
                                                          - NVL (bp.award_enc_posted, 0)
                                                          - NVL (bp.award_actual_approved, 0)
                                                          - NVL (bp.award_actual_pending, 0)
                                                          - NVL (bp.award_enc_approved, 0)
                                                          - NVL (bp.award_enc_pending, 0)),
                                                       -1, 'P61',
                                                       'P60'),
                                               'B', DECODE (
                                                       SIGN (
                                                          NVL (bp.award_budget_posted, 0)
                                                          - NVL (bp.award_actual_posted, 0)
                                                          - NVL (bp.award_enc_posted, 0)
                                                          - NVL (bp.award_actual_approved, 0)
                                                          - NVL (bp.award_actual_pending, 0)
                                                          - NVL (bp.award_enc_approved, 0)
                                                          - NVL (bp.award_enc_pending, 0)),
                                                       -1, 'F90',
                                                       'P60')))
       WHERE bp.packet_id = x_packetid
         AND bp.effect_on_funds_code IN ('D', 'I')
         AND bp.status_code = 'P';



      UPDATE gms_bc_packets
         SET result_code = NVL (award_result_code, 'F53'),
             status_code = DECODE (status_code,'P', DECODE (SUBSTR (NVL (award_result_code, 'F53'), 1, 1),'F', DECODE(x_mode,'C','F','R'),status_code),status_code)
       WHERE packet_id = x_packetid
         AND effect_on_funds_code IN ('D', 'I')
         AND status_code = 'P';

       -- Call new procedure RAW_BURDEN_FAILURE to handle raw-burden failure ...
       RAW_BURDEN_FAILURE(x_packetid,     -- Packet_id
                          g_derived_mode, -- Mode
                          'AWD'           -- Level
                         );


      -- Call new FUNCTION Full_mode_failure to handle full mode and scenario of failing all cdl when one cdl failed ..
      If FULL_MODE_FAILURE(x_packetid,     -- Packet_id
                        g_mode,         -- Mode , use g_mode
                        'AWD'           -- Level
                         ) then
         If g_partial_flag = 'N' then
            -- If full mode, transactions have failed .. exit FC
            GOTO END_OF_FC_PROCESS;
         End if;
      End If;

         -- Bug 3426509 : Added following code to update the last advisory result code to result_code column
         -- e.g. if transaction passed funds check in advisory mode at Task and Resource Level , then the
         -- result_code will hold the result_code of Task Level funds check (i.e. 'P65').

         UPDATE gms_bc_packets
            SET result_code = DECODE (top_task_result_code,'P80', 'P80',
                                 DECODE (task_result_code,'P65', 'P65',
                                    DECODE (res_grp_result_code,'P73', 'P73',
                                       DECODE (res_result_code,'P69', 'P69',
                                          result_code))))
          WHERE packet_id = x_packetid
            AND effect_on_funds_code IN ('D', 'I')
            AND status_code = 'P'
            AND SUBSTR (result_code,1,1) <> 'F'
            AND result_code <> 'P61'
            AND (   top_task_result_code = 'P80'
                 OR task_result_code = 'P65'
                 OR res_grp_result_code = 'P73'
                 OR res_result_code = 'P69'
                );

        <<END_OF_FC_PROCESS>>
--================================================================================--
-- Data clean up code from summary tables after Amount calculation
--================================================================================--
      g_error_stage := 'FC PR : DELETE';
		DELETE      gms_bc_packets_summary
		      WHERE packet_id = x_packetid;
		DELETE      gms_bc_packets_bvid
		      WHERE packet_id = x_packetid;

       -- Added commit for the base bug 3848201
       commit;

--  Bug 2092791

--  Bug 2176230
--  Delete Record from gms_bc_packet_arrival_order able to ensure that transactions inserted into
--  gms_bc_packets in check funds mode should not be accounted by any other subsequent packets.

      IF x_mode = 'C' THEN
        DELETE 	    gms_bc_packet_arrival_order
		      WHERE packet_id = x_packetid;
	  END IF;

       COMMIT; -- Bug 4053891 (to release locks ...only set for REQ/PO/AP/FAB/Interface)
              -- lock by lock_budget_versions; If there is a failure then the commit happens
              -- in gms_fck.when_other commit;

      RETURN (TRUE);
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('AFTER FUNDS CHECK', 'C');
      END IF;
   END gms_fc_process;

--------------------------------------------------------------------------------------------------------------------------------------------------
--  This function calls all the procedures and functions for funds checker
--------------------------------------------------------------------------------------------------------------------------------------------------
  -- Funds Check Processor
   FUNCTION gms_fcp (
      x_sobid         IN       gms_bc_packets.set_of_books_id%TYPE,
      x_packetid      IN       gms_bc_packets.packet_id%TYPE,
      x_mode          IN       VARCHAR2,
      x_partial       IN       VARCHAR2,
      x_arrival_seq   IN       gl_bc_packet_arrival_order.arrival_seq%TYPE,
      x_err_code      OUT NOCOPY      NUMBER,
      x_err_buff      OUT NOCOPY      VARCHAR2)
      RETURN BOOLEAN IS
      x_error_code       NUMBER;
      x_error_buff       VARCHAR2(2000);
      x_packetid_ursvd   NUMBER;
      x_stage            VARCHAR2 (100);
   BEGIN
      g_error_procedure_name := 'Gms_fcp';
      x_error_code   :=0;
      x_error_buff   :=null;

      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':x_sobid,x_arrival_seq-'||x_sobid||','||x_arrival_seq, 'C');
      END IF;

      -- If Mode is Unreservation, assign Packet ID to Unreservation Packet ID
      -- and initialize Packet ID to 0. This is done here to prevent the approved
      -- packet from accidentally being updated to status 'Fatal' in case a fatal
      IF x_mode = 'U' THEN
         x_packetid_ursvd := x_packetid;
      ELSE
         x_packetid_ursvd := 0;
      END IF;

-- ------------------------------------------------------------
     -- Setup and Summarization
-- ('********* Calling GMS_SETUP *****************');
-- ------------------------------------------------------------
      gms_error_pkg.gms_debug (g_error_procedure_name||'Calling gms_setup', 'C' );
      g_error_stage := 'gms_setup';
      IF NOT gms_setup (x_packetid, x_mode, x_partial,x_err_code,x_err_buff) THEN
         RETURN (FALSE);
      END IF;

      -- Bug 2176230
	  -- ********************************************************************************
	  -- NOTE :- Don't Put Any Commit after this point till gms_fc_process is complete,
	  --         Reason being for funds checking in C Mode (check funds mode)
	  --         transactions in gms_bc_packets should not be accounted by any other
	  --         subsequent packet.  (Applicable for x_mode = R,U,C,E)
	  -- ********************************************************************************


      g_error_stage := 'gms_fc_process';
      IF x_mode IN ('S', 'B') THEN
         IF g_debug = 'Y' THEN
         	gms_error_pkg.gms_debug ('BEFORE BASELINE', 'C');
         END IF;
         budget_fundscheck (x_packetid,x_err_code,x_err_buff);
         status_code_update (x_packetid, x_mode);
         IF g_debug = 'Y' THEN
         	gms_error_pkg.gms_debug ('AFTER BASELINE', 'C');
         END IF;
      ELSE
         IF NOT gms_fc_process (x_packetid,x_arrival_seq,x_mode) THEN		 -- Bug 2176230
            RETURN (FALSE);
         END IF;
      END IF;
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ( 'GMS_FCP-After Calling gms_fc_process', 'C' );
      	gms_error_pkg.gms_debug ( 'GMS_FCP-END', 'C' );
      END IF;
      RETURN (TRUE);
   END gms_fcp;

--------------------------------------------------------------------------------------------------------------------------------------------------
-- This process generates the status_code and return_code for funds checker
--------------------------------------------------------------------------------------------------------------------------------------------------
-- Get Return Status
  -- Return Code can be of one of the following values :
  --
  --     Code  Meaning   Description
  --     --  -----   --------------------
  --      S    Success   All transactions in packet pass Funds
  --                     Check or Funds Reservation
  --
  --      A    Advisory  All transactions in packet pass Funds
  --                     Check or Funds Reservation; but some
  --                     with Advisory warnings
  --
  --      F    Failure   All transactions in packet fail Funds
  --                     Check or Funds Reservation (partial
  --                     reservation allowed)
  --                     OR
  --                     One or more transactions in packet fail
  --                     Funds Check or Funds Reservation
  --                     (partial reservation not allowed)
  --
  --      P    Partial   Only part of the transactions in packet
  --                     pass Funds Check or Funds Reservation
  --                     (partial reservation allowed only)
  --
  --      T    Fatal     Irrecoverable error detected that
  --                     prevents funds check or reservation
  --                     from proceeding
  --
-- ------------------------------------------------------------------------------------------------
-- To Exit out NOCOPY of gms_fck in case of non_gms application calls.
-- Bug 1966096. Funds check for non-sponsor projects and GL Transactions should happen base
-- on the core functionality. Since their no entry in gms_bc_packets as those transactions
-- gms funds checker should not return false which fail the above transactions.
-- ------------------------------------------------------------------------------------------------

   FUNCTION gms_return_code (
      x_packetid      IN       NUMBER,
      x_mode          IN       CHAR,
      x_partial       IN       CHAR,
      x_return_code   IN OUT NOCOPY   VARCHAR2,
      x_e_code        IN OUT NOCOPY   VARCHAR2,
      x_err_buff      OUT NOCOPY      VARCHAR2)
      RETURN BOOLEAN IS
      x_err_code      NUMBER;
      x_result_code   CHAR;
   BEGIN

   g_error_procedure_name := 'gms_return_code';
      x_err_code := 0;

   IF x_mode IN ('B', 'S') THEN -- I
         g_error_stage := 'submit/baseline';

         BEGIN
            SELECT 0
              INTO x_err_code
              FROM DUAL
             WHERE EXISTS ( SELECT 'X'
                              FROM gms_bc_packets
                             WHERE packet_id = x_packetid
                              AND status_code IN ('S', 'B')); --Bug Fix 1350100 Change status_code from 'A'
                                                               --to 'B' to fix bug 2138376
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               x_err_code := 1;
         END;

         SELECT DECODE (x_err_code, 0, 'S', 'H')
           INTO x_e_code
           FROM DUAL;

      ELSIF x_mode = 'E' THEN
           g_error_stage := 'Encumbrance';

         BEGIN
            SELECT 'F'
              INTO x_result_code
              FROM DUAL
             WHERE EXISTS ( SELECT result_code
                              FROM gms_bc_packets
                             WHERE packet_id = x_packetid
                               AND SUBSTR (result_code, 1, 1) = 'F');
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               x_result_code := 'P';
         END;

         IF x_result_code = 'F' THEN
	    IF g_debug = 'Y' THEN
		gms_error_pkg.gms_debug ( 'Calling status_code_update for encumbrances', 'C' );
	    END IF;

            status_code_update (x_packetid, 'E');
            x_e_code := 'H';

         ELSE -- update gms_bc_packets with approved status
            IF g_debug = 'Y' THEN
            	gms_error_pkg.gms_debug ( 'Calling status_code_update for encumbrances', 'C' );
            END IF;
            status_code_update (x_packetid, 'E');
            x_e_code := 'S';
         END IF;
    END IF; -- I

    g_error_stage := 'Common';

      BEGIN
         SELECT 1
           INTO x_err_code
           FROM DUAL
          WHERE EXISTS ( SELECT 'X'
                           FROM gms_bc_packets
                          WHERE packet_id = x_packetid
                            AND SUBSTR (result_code, 1, 1) = 'F'
                            AND status_code = 'T');
         x_return_code := 'T';
         RETURN TRUE;   			--Bug 2006221

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF x_partial <> 'Y' THEN
               BEGIN
                  SELECT 1
                    INTO x_err_code
                    FROM DUAL
                   WHERE EXISTS ( SELECT 'X'
                                    FROM gms_bc_packets
                                   WHERE packet_id = x_packetid
                                     AND SUBSTR (result_code, 1, 1) = 'F');
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     x_err_code := 0;
               END;

               IF x_err_code = 1 THEN

-- There is no need to check for the document type , IF g_doc_type in ('REQ','PO','AP') THEN
                  x_return_code := 'F'; --21-SEP-2000
               ELSE
                  x_return_code := 'S';
               END IF;
            ELSE
               x_return_code := 'S';
            END IF;
            RETURN TRUE;
      END;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN FALSE;
         RAISE;
   END gms_return_code;


   /* =========================================================================
      -- Bug : 2557041 - Added for IP check funds Enhancement
      -- Modified for PA-GMS C-FC Integration ..

      g_mode : Funds Checker Operation Mode.
                     C  - Check funds
                     R  - Reserve funds.
                     U  - Un-reserve  (only for REQ,PO and AP)
                     B  - Called from budget baseline process  (Processed like check funds)
                     S  - Called from Budget submission     (Processed like check funds)
                     X  - Called for Expenditure Items funds check
                     I  - Called for Supplier Cost funds check during interface AP->PA
                     A  - Adjustments for PO /REQ

      This procedure is called from gms_fck function.

      This procedure initializes following global variables:
      g_ip_fc_flag
		-  'Y' Funds check is called in IP check funds mode
 		-  'N' Funds check is called in NON-IP mode

      g_gl_bc_pkt_sponsored_count  (for AP/PO/REQ)
		-   0  NON-GMS related transactions are being funds checked
   		-  >0  GMS related transactions are being funds checked

      g_pa_addition_flag_t_count (for AP)
                -  Count of AP invoice being funds checked that has pa_addition_flag 'T'

      g_non_gms_txn
                -   TRUE NON-GMS related transactions are being funds checked
                -   FALSE GMS related transactions are being funds checked

     ========================================================================= */

PROCEDURE gms_fck_init(p_partial_flag IN VARCHAR2) IS

-- Note: Award and Expenditure type are the additional filter criterias
--       in misc_gms_insert. Those will not be added here ..helps fail
--       transactions in case of incorrect award number and expenditure type.

-- R12 FundsCheck Management Uptake : Shifted IP/AP/PO/REQ/FAB cursor logic to procedure copy_gl_pkt_to_gms_pkt and
-- merged with the selects which fetches IP/AP/PO/REQ/FAB record for inserting into gms_bc_packets.
-- Added below cursor to derive g_doc_type based on the data inserted into gms_bc_packets by procedure copy_gl_pkt_to_gms_pkt.

   CURSOR C_count_rec IS
   SELECT count(*) gms_txn_count,
          SUM(DECODE(gms.document_type,'REQ',1,0)) req_count,
          SUM(DECODE(gms.document_type,'PO',1,0))  po_count,
          SUM(DECODE(gms.document_type,'AP',1,0))  ap_count,
          SUM(DECODE(gms.document_type,'FAB',1,0)) fab_count
     FROM gms_bc_packets gms
    WHERE gms.packet_id= g_packet_id;

   -- R12 FundsCheck Management Uptake : New variables defined and used in deriving g_doc_type
   l_gms_txn_count  NUMBER;
   l_req_count	    NUMBER;
   l_po_count       NUMBER;
   l_ap_count       NUMBER;
   l_fab_count      NUMBER;

   -- R12 FundsCheck Management Uptake : Deleted obsolete variables

BEGIN
  g_error_procedure_name := 'Gms_fck_init';
  g_error_stage := 'Initalize Global Variables';

  IF g_debug = 'Y' THEN
     gms_error_pkg.gms_debug (g_error_procedure_name||':'||g_error_stage,'C');
  END IF;

  -- ==================================
  -- 1. Initalize global variables ...
  -- ==================================
     g_non_gms_txn 		 := FALSE;
     g_bc_packet_has_P82_records := 'N' ;

  -- ==================================
  -- 2. Derive doc_type ...
  -- ==================================
     g_error_stage := 'Derive doc_type';

     IF g_debug = 'Y' THEN
        gms_error_pkg.gms_debug (g_error_procedure_name||':'||g_error_stage,'C');
     END IF;

    If    g_mode = 'X' then -- p_mode check - I
          g_doc_type := 'EXP';
    Elsif g_mode = 'I' then
          g_doc_type := 'AP';
    Elsif g_mode = 'E' then
          g_doc_type := 'ENC';
    Elsif g_mode in ('S','B') then
          g_doc_type := 'ALL';
    Elsif g_mode in ('R','U','C','A') then

      -- 'A' mode is used fro PO/REQ adjustments ,it should be considered as reserve 'R'
      IF g_mode = 'A' THEN
         g_mode := 'R';
      END IF;

	-- R12 FundsCheck Management Uptake : Deleted existing logic which was deriving g_doc_type and
	-- g_non_gms_txn based on records in GL_bc_packets/AP/PO/REQ tables.
	-- With new architecture the gl_bc_packets/AP/PO/REQ validations will be performed during
	-- insertion of GMS packets in main session and current logic derives document type based on
	-- the data inserted into gms_bc_packets for current packet_id.

        OPEN  c_count_rec;
	FETCH c_count_rec INTO l_gms_txn_count,l_req_count,l_po_count,l_ap_count,l_fab_count;
        CLOSE c_count_rec;

        IF l_gms_txn_count = 0 THEN
	   g_non_gms_txn := TRUE;
	ELSE
	   IF NVL(l_req_count,0) <> 0  AND NVL(l_po_count,0) = 0 then
	       g_doc_type := 'REQ';
   	   ELSIF NVL(l_po_count,0) <> 0 then
	       g_doc_type := 'PO';
	   ELSIF NVL(l_ap_count,0) <> 0 then
	       g_doc_type := 'AP';
	   ELSIF NVL(l_fab_count,0) <> 0 then
	       g_doc_type := 'FAB';
           END IF;
        END IF;

       IF g_debug = 'Y' THEN
           gms_error_pkg.gms_debug (g_error_procedure_name||':'||'Derived value of document type '||g_doc_type,'C');
       END IF;

    End if; -- p_mode check - I

    IF g_debug = 'Y' THEN
       gms_error_pkg.gms_debug (g_error_procedure_name||':Total txns. in gms_bc_packets -'||l_gms_txn_count, 'C');
       gms_error_pkg.gms_debug (g_error_procedure_name||':Total REQ txns in gms_bc_packets -'||l_req_count,'C');
       gms_error_pkg.gms_debug (g_error_procedure_name||':Total PO txns in gms_bc_packets -'||l_po_count,'C');
       gms_error_pkg.gms_debug (g_error_procedure_name||':Total AP txns in gms_bc_packets -'||l_ap_count,'C');
       gms_error_pkg.gms_debug (g_error_procedure_name||':Total FAB txns in gms_bc_packets -'||l_fab_count,'C');
       gms_error_pkg.gms_debug (g_error_procedure_name||':Document type (ALL indicates Submit/Baseline)-'||g_doc_type,'C');
    END IF;

  -- ======================================
  -- 3. Initalize global variables - part B
  -- ======================================
    -- Derive mode ..

    If g_mode in ('X','I') then -- X: Expenditure Items, I: Interface
         g_derived_mode := 'R';
      else
         g_derived_mode := g_mode;
    End If;


    -- Derive partial flag ..

      If g_mode in ('X','E')         then  -- Expenditures/Encumbrances

         g_partial_flag := 'Y';

      Elsif g_mode in ('S','B','I')  then  -- Submit/Baseline/Interface

         g_partial_flag := 'N';

      Elsif g_mode in ('R','U','C') and g_doc_type in ('REQ','PO','AP') then -- AP/PO/REQ

         g_partial_flag := p_partial_flag;

      Elsif g_mode in ('R','U','C') and g_doc_type = 'FAB' then  -- FAB processing

         g_partial_flag := 'N';

      End If;


      IF g_debug = 'Y' THEN
      	  gms_error_pkg.gms_debug ('GMS_FCK-derived values :g_derived_mode,g_partial_flag:'
						||g_derived_mode||','||g_partial_flag,'C');
      END IF;

    -- Initialize currency precision variables ..
    --  pa_currency.set_currency_info;
    -- Moved to gms_fck_init (stage 301), bug 5074028

END gms_fck_init;

----------------------------------------------------------------------------------+
PROCEDURE Si_adjustments ( x_packet_id in NUMBER, x_pkt_row OUT NOCOPY NUMBER )
is

   l_pkt_row                  number ;
   l_stage                    varchar2(10) ;
   /*l_row_id                   VARCHAR2 (200); Commented for bug 6236117 */
   l_inv_encumbrance_type_id  financials_system_parameters.inv_encumbrance_type_id%TYPE;
   /*l_bc_packet_id             NUMBER; Commented for bug 6236117 */

   CURSOR financials_options   IS
   SELECT inv_encumbrance_type_id
     FROM financials_system_parameters;

   CURSOR c_po_doc (p_inv_encumbrance_type_id NUMBER) IS
   SELECT pkt.ROWID              pkt_row_id,
          pod.po_distribution_id po_dist_id,
          pod.po_header_id       po_header_id,
	  pod.project_id         project_id,
	  pod.task_id            task_id,
	  adl.award_id           award_id
     FROM gms_bc_packets               pkt,
          gl_bc_packets                gl,
          ap_invoice_distributions_all ap,
          po_distributions_all         pod,
          gms_award_distributions      adl
      WHERE pkt.packet_id              = x_packet_id
        AND pkt.document_type          = 'AP'
        AND gl.packet_id               = pkt.packet_id
        AND ROWIDTOCHAR (gl.ROWID)     = pkt.gl_bc_packets_rowid
        AND gl.encumbrance_type_id     <> p_inv_encumbrance_type_id
        AND   NVL (pkt.entered_cr, 0) + NVL (pkt.entered_dr, 0) <> 0
        AND pod.po_distribution_id     = ap.po_distribution_id
        AND ap.distribution_line_number= pkt.document_distribution_id
        AND ap.invoice_id              = pkt.document_header_id
	    and pod.award_id               = adl.award_set_id
	    and adl.adl_line_num           = 1
        and nvl(pkt.burden_adjustment_flag,'N') = 'N'
      FOR UPDATE OF pkt.document_type,
                    pkt.document_header_id,
                    pkt.document_distribution_id NOWAIT;

/* Commented for the bug 6236117
CURSOR sum_aprec IS
   SELECT   packet_id,
            document_header_id,
            document_distribution_id,
            award_id,
            expenditure_type,
            document_type,
            SUM (  NVL (entered_dr, 0) - NVL (entered_cr, 0)) raw_cost
      FROM gms_bc_packets
     WHERE packet_id = x_packet_id
       and nvl(burden_adjustment_flag,'N') = 'N'
       AND EXISTS ( SELECT 1
                      FROM gms_bc_packets
                     WHERE packet_id = x_packet_id
                       AND document_type = 'AP')
      GROUP BY packet_id,
               document_header_id,
               document_distribution_id,
               award_id,
               expenditure_type,
               document_type;

   CURSOR min_bc_packet_id (
      x_packet_id                  NUMBER,
      x_doc_type                   VARCHAR2,
      x_document_header_id         NUMBER,
      x_document_distribution_id   NUMBER,
      x_award_id                   NUMBER,
      x_expenditure_type           VARCHAR2
   )
   IS
      SELECT MIN (bc_packet_id)
        FROM gms_bc_packets
       WHERE packet_id = x_packet_id
         AND document_type = x_doc_type
         AND document_header_id = x_document_header_id
         AND document_distribution_id = x_document_distribution_id
         AND award_id = x_award_id
         AND expenditure_type = x_expenditure_type;

Ends commented for bug 6236117 */

BEGIN

  g_error_procedure_name := 'Si_adjustments';

   L_pkt_row := 0 ;
   L_stage    := 'BEGIN' ;

   OPEN financials_options;
   FETCH financials_options INTO l_inv_encumbrance_type_id;
   CLOSE financials_options;

   FOR bc_packets IN c_po_doc (l_inv_encumbrance_type_id)
   LOOP
      UPDATE gms_bc_packets
         SET document_type = 'PO',
             document_header_id = bc_packets.po_header_id,
             document_distribution_id = bc_packets.po_dist_id,
	     project_id         = bc_packets.project_id ,
	     task_id            = bc_packets.task_id ,
	     award_id           = bc_packets.award_id
       WHERE ROWID = bc_packets.pkt_row_id;
   END LOOP;

   Delete from gms_bc_packets
    Where packet_id     = x_packet_id
      And document_type = 'AP'
      And bc_packet_id in
     ( select a.bc_packet_id
        from gms_bc_packets a,
             ap_invoice_distributions_all apd
       where a.packet_id = x_packet_id
         and a.document_type = 'AP'
         and a.document_header_id = apd.invoice_id
         and a.document_distribution_id = apd.distribution_line_number
         and NVL(apd.pa_addition_flag,'X') = 'T') ;

/* Commented for bug 6236117
   FOR bc_packets IN sum_aprec
   LOOP

   -- -----------------------------------------------------------
   -- The 1st distribution line is updated with the total CR and
   -- DB amount.
   -- -----------------------------------------------------------

      OPEN min_bc_packet_id (
         bc_packets.packet_id,
         bc_packets.document_type,
         bc_packets.document_header_id,
         bc_packets.document_distribution_id,
         bc_packets.award_id,
         bc_packets.expenditure_type
      );
      FETCH min_bc_packet_id INTO l_bc_packet_id;
      CLOSE min_bc_packet_id;

      IF bc_packets.raw_cost >= 0
      THEN
         UPDATE gms_bc_packets
            SET entered_dr = bc_packets.raw_cost,
                entered_cr = 0
          WHERE packet_id = x_packet_id
            AND document_type = bc_packets.document_type
            AND bc_packet_id = l_bc_packet_id;


        -- ---------------------------------------------------------------
        -- Since the 1st dist line is updated with the  total other
        -- lines should be updated with 0. This is done for the same AP
        -- Distribution Line. BC packets gets data in multiple lines for
        -- the same distribution line.
        -- ---------------------------------------------------------------
         UPDATE gms_bc_packets
            SET entered_cr = 0,
                entered_dr = 0
          WHERE packet_id = x_packet_id
            AND bc_packet_id > l_bc_packet_id
            AND document_type = bc_packets.document_type
            AND document_header_id = bc_packets.document_header_id
            AND document_distribution_id = bc_packets.document_distribution_id
            AND award_id = bc_packets.award_id
            AND expenditure_type = bc_packets.expenditure_type;

      ELSIF bc_packets.raw_cost < 0
      THEN
         UPDATE gms_bc_packets
            SET entered_cr = bc_packets.raw_cost * -1,
                entered_dr = 0
          WHERE packet_id = x_packet_id
            AND document_type = bc_packets.document_type
            AND bc_packet_id = l_bc_packet_id;

         -- ---------------------------------------------------------------
         -- Since the 1st dist line is updated with the credit total other
         -- lines should be updated with 0. This is done for the same AP
         -- Distribution Line. BC packets gets data in multiple lines for
         -- the same distribution line.
         -- ---------------------------------------------------------------
         UPDATE gms_bc_packets
            SET entered_cr = 0,
                entered_dr = 0
          WHERE packet_id = x_packet_id
            AND bc_packet_id > l_bc_packet_id
            AND document_type = bc_packets.document_type
            AND document_header_id = bc_packets.document_header_id
            AND document_distribution_id = bc_packets.document_distribution_id
            AND award_id = bc_packets.award_id
            AND expenditure_type = bc_packets.expenditure_type;
      END IF;
   END LOOP;

   Ends commenting for bug 6236117 */

   l_stage := 'SELECT' ;

   select 1
     into l_pkt_row
     from dual
    where exists ( select 1 from gms_bc_packets
                   where packet_id = x_packet_id ) ;

   x_pkt_row := l_pkt_row ;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
           IF l_stage = 'SELECT' THEN
	        X_pkt_row := 0 ;
           ELSE
              RAISE ;
           END IF ;
	WHEN OTHERS THEN
            RAISE ;

END SI_ADJUSTMENTS;

-- ------------------------------------ R12 Start ------------------------------------------------+
-- R12 Changes: New procedure
-- --------------------------------------------------------------------------------+
-- This procedure will update the following columns in gms_bc_packets: serial_id,
-- session_id,packet_id,period_name,period_year,period_num,account_type and status.
-- Status will be upated from I to P. Called from gms_fck
-- --------------------------------------------------------------------------------+
PROCEDURE Synch_gms_gl_packets(p_packet_id IN Number)
IS
 l_gms_packet_id gms_bc_packets.packet_id%type;

-- This cursor will fetch only if called for AP/PO/REQ
 CURSOR   get_temp_packet_id Is
 Select   gbc.packet_id
   from   gms_bc_packets gbc
  where  gbc.source_event_id in
             (select glbc.event_id
                from gl_bc_packets glbc
               where glbc.packet_id = p_packet_id)
    and  gbc.status_code ='I'
    and  gbc.document_type in ('AP','PO','REQ')
    and rownum =1;

/* Bug 5285217 : Created the cursor c_gl_bc_pkt. This cursor selects all the records from gl_bc_packets for the current packet_id. */
cursor c_gl_bc_pkt IS
select p_packet_id packet_id,'P' status_code,
			 glbc.session_id session_id,glbc.serial_id serial_id,
			 glbc.je_category_name je_category_name,
			 glbc.je_source_name je_source_name,glbc.period_name period_name,
			 glbc.period_year period_year,glbc.period_num period_num,
			 glbc.account_type account_type,
			 rowidtochar(glbc.rowid) gl_rowid,
                         glbc.event_id event_id,
                         glbc.source_distribution_id_num_1 source_distribution_id_num_1,
                         glet.encumbrance_type_key encumbrance_type_key,
                         glbc.accounted_dr entered_dr , -- Bug 5614467
                         glbc.accounted_cr entered_cr, -- Bug 5614467
			 source_distribution_type
		  from   gl_bc_packets glbc,
		         gl_encumbrance_types glet
		  where  glbc.packet_id           = p_packet_id
		  and    glbc.encumbrance_type_id = glet.encumbrance_type_id;

l_dist_id  pa_bc_packets.document_header_id%type;

BEGIN

  IF g_debug = 'Y' THEN
   	gms_error_pkg.gms_debug ('Synch_gms_gl_packets Strat : packet_id = '|| p_packet_id,'C');
  END IF;

 -- Get the packet_id that was establised earlier ..
 OPEN get_temp_packet_id;
 FETCH get_temp_packet_id INTO l_gms_packet_id;

 IF  get_temp_packet_id%FOUND THEN

         IF g_debug = 'Y' THEN
   	    gms_error_pkg.gms_debug ('Synch_gms_gl_packets Strat : Previously establised packet is = '|| l_gms_packet_id,'C');
         END IF;

	/* Bug 5250793 : Added a join with gl_encumbrance_types so that the gl_bc_packets_rowid on gms_bc_packets is updated
	   correctly for an invoice matched to a PO scenario. Before this change , the same gl_bc_packets_rowid was updated on
	   gms_bc_packets for both the PO reversal and AP reserve records irrespective of the corresponding rowid on gl_bc_packets.*/

	 -- Update gms_bc_packets data
	 /* Bug 5285217 : Changed the code to use "FOR" loop so that gl_bc_packets_rowid on gms_bc_packets is updated correctly
	    for an invoice matched to a PO with Quantity Variance Scenario. Before this change , the same gl_bc_packets_rowid was
	    updated on gms_bc_packets for both the invoice reserve and the quantity variance reserve records irrespective of
	    the corresponding rowid on gl_bc_packets.*/

	     FOR glbcrec in c_gl_bc_pkt LOOP

                 IF g_debug = 'Y' THEN
	     	    gms_error_pkg.gms_debug ('Synch_gms_gl_packets:  glbcrec.source_distribution_type:'|| glbcrec.source_distribution_type,'C');
                 END IF;

                If glbcrec.source_distribution_type = 'AP_PREPAY' then
                   -- This is reqd. as we cannot access ap_prepay_app_dists here .. autonomous ..

                  IF g_debug = 'Y' THEN
	     	     gms_error_pkg.gms_debug ('Synch_gms_gl_packets:  Derive prepay dist id ','C');
                  END IF;

                   For x in g_ap_prepay_app_dist_id.FIRST..g_ap_prepay_app_dist_id.LAST loop

                       IF g_debug = 'Y' THEN
	     	          gms_error_pkg.gms_debug ('Synch_gms_gl_packets: g_ap_prepay_app_dist_id(x)'||g_ap_prepay_app_dist_id(x),'C');
                       END IF;

	               IF g_ap_prepay_app_dist_id(x) = glbcrec.source_distribution_id_num_1 then
                          -- basically, if ap_prepay_app_dists.ap_prepay_dist_id is same as in gl
                          -- assign ap_prepay_app_dists.invoice_distribution_id to l_dist_id

                          l_dist_id := g_doc_dist_id_tab(x);

                          If g_debug = 'Y' THEN
                              gms_error_pkg.gms_debug ('Synch_gms_gl_packets: Found prepay dist,its:'||l_dist_id,'C');
                          End If;

                          EXIT;
                        END IF;

	           End loop;
                End If; --If glbcrec.source_distribution_type = 'AP_PREPAY' then

		 -- Update gms_bc_packets data
		 Update gms_bc_packets gbc
		    set (gbc.packet_id,gbc.status_code,
			 gbc.session_id,gbc.serial_id,
			 gbc.je_category_name,
			 gbc.je_source_name,gbc.period_name,
			 gbc.period_year,gbc.period_num,
			 gbc.account_type,
			 gl_bc_packets_rowid) =
			 (select glbcrec.packet_id,glbcrec.status_code,
			 glbcrec.session_id,glbcrec.serial_id,
			 glbcrec.je_category_name,
			 glbcrec.je_source_name,glbcrec.period_name,
			 glbcrec.period_year,glbcrec.period_num,
			 glbcrec.account_type,
			 glbcrec.gl_rowid from dual
			  )
		  where   gbc.packet_id   = l_gms_packet_id
		  and     gbc.status_code = 'I'
		  and     gbc.source_event_id = glbcrec.event_id
		  and     (( gbc.document_distribution_id = glbcrec.source_distribution_id_num_1
		            AND glbcrec.source_distribution_type <> 'AP_PREPAY') OR
			   (glbcrec.source_distribution_type = 'AP_PREPAY' AND -- Bug 5561741
                             gbc.document_distribution_id = l_dist_id
                              -- Following cannot be used as ap_prepay_app_dists not visible ..autonomous ..
                              -- (SELECT APAD.PREPAY_APP_DISTRIBUTION_ID
			      --                                 FROM ap_prepay_app_dists APAD
			      --				      WHERE APAD.PREPAY_APP_DIST_ID = glbcrec.source_distribution_id_num_1 )
                             ))
		  and     gbc.document_type = decode(glbcrec.encumbrance_type_key,'Commitment','REQ'
									       ,'Obligation','PO'
									       ,'Invoices','AP')
                  /* Bug 5285217 : For an Invoice Matched to a PO with Quantity Variance , there are two records in gl_bc_packets
		     with encumbrance type as 'Invoices' (one for the invoice reserve and the other for the Quantity variance reserve).
		     Also the packet_id,event_id and source_distribution_id_num_1 on both the records are same.
		     So the 'gl_bc_packets_rowid IS NULL' and 'ROWNUM = 1' conditions are used to differentiate between
		     the two records.
                     For the first AP record (either invoice reserve record or the Quantity variance reserve record) in gl_bc_packets,
		     the 'ROWNUM=1' and the (entered_dr-entered_cr) conditions are used to identify the corresponding record
		     in gms_bc_packets. The (entered_dr-entered_cr) check is not suitable for the scenario in which the invoice amount and the quantity
		     variance amount are same. But as the amounts are same for both the invoice reserve and quantity variance reserve
		     records , only 'ROWNUM=1' check will suffice as we need not distinguish between the invoice reserve and the
		     quantity variance record.
		     For the second AP record (one among the invoice reserve record or the Quantity variance reserve record for which the
		     corresponding record is not yet updated in gms_bc_packets) in gl_bc_packets , the 'gl_bc_packets_rowid IS NULL'
		     condition is used to identify the corresponding record in gms_bc_packets.*/
		  and    gbc.gl_bc_packets_rowid IS NULL
		  and    ((nvl(gbc.entered_dr,0) - nvl(gbc.entered_cr,0)) = (nvl(glbcrec.entered_dr,0) - nvl(glbcrec.entered_cr,0)))
		  and    ROWNUM = 1
		  -- If it's PO mathed to an AP then for the PO reversal record in gl_bc_packets source_distribution_id_num_1 is populated as invoice_distribution_id
		  -- whereas for the corresponding record gms_bc_packets will have source_distribution_id_num_1 as po_distribution_id
		  -- Hence for this scenario we will check encumbrance_type_id to get PO record from GL.
		  -- This update is NOT for the PO reversal record in an AP matched to a PO scenario.
		  and    1 >= (select count(distinct glbc1.encumbrance_type_id)  -- This will return more than one count for the PO reversal record in an AP matched to a PO scenario.
					 from  gl_bc_packets glbc1
					where  glbc1.packet_id = p_packet_id
					  and  glbc1.event_id  = gbc.source_event_id
					  and  glbc1.source_distribution_type = 'AP_INV_DIST'
					  and  gbc.document_type ='PO' );

	     END LOOP;

	 IF g_debug = 'Y' THEN
   	    gms_error_pkg.gms_debug ('Synch_gms_gl_packets Strat : Updated bc packets except PO matched to an invoice '|| SQL%ROWCOUNT,'C');
         END IF;

	  -- If it's PO mathed to an AP then for the PO reversal record in gl_bc_packets source_distribution_id_num_1 is populated as invoice_distribution_id
	  -- whereas for the corresponding record gms_bc_packets will have source_distribution_id_num_1 as po_distribution_id
	  -- Hence for this scenario we will check encumbrance_type_id to get PO record from GL.
	  -- This update is for the PO reversal records , which will be only records left with gbc.packet_id   = l_gms_packet_id , in an AP matched to a PO scenario.

	 Update gms_bc_packets gbc
	    set (gbc.packet_id,gbc.status_code,
		 gbc.session_id,gbc.serial_id,
		 gbc.period_name,
		 gbc.period_year,gbc.period_num,
		 gbc.account_type,
		 gl_bc_packets_rowid) =
		 (select p_packet_id,'P',
			 glbc.session_id,glbc.serial_id,
			 glbc.period_name,
			 glbc.period_year,glbc.period_num,
			 glbc.account_type,
			 rowidtochar(glbc.rowid)
		  from   gl_bc_packets glbc
		  where  glbc.packet_id                    = p_packet_id
		  and    glbc.event_id                     = gbc.source_event_id
		  and    glbc.source_distribution_id_num_1 <> gbc.document_distribution_id
		  and    glbc.encumbrance_type_id IN (SELECT glenc.encumbrance_type_id --Seeded encumbrance type for PO
		                                        FROM gl_encumbrance_types glenc
						       WHERE glenc.encumbrance_type_key = 'Obligation')
		  and    rownum = 1)
	  where   gbc.packet_id   = l_gms_packet_id
	  and     gbc.status_code = 'I'
	  and     gbc.document_type ='PO';

         IF g_debug = 'Y' THEN
   	    gms_error_pkg.gms_debug ('Synch_gms_gl_packets Strat : Updated bc packets for PO matched to an invoice '|| SQL%ROWCOUNT,'C');
         END IF;

/* Bug 5645290 - Start */
	Update gms_bc_packets gbc
	    set (gbc.packet_id,gbc.status_code,
		 gbc.session_id,gbc.serial_id,
		 gbc.je_category_name,
		 gbc.je_source_name,gbc.period_name,
		 gbc.period_year,gbc.period_num,
		 gbc.account_type,
		 gl_bc_packets_rowid) =
		 (select gbcparent.packet_id,'P',
			 gbcparent.session_id,gbcparent.serial_id,
			 gbcparent.je_category_name,
			 gbcparent.je_source_name,gbcparent.period_name,
			 gbcparent.period_year,gbcparent.period_num,
			 gbcparent.account_type,
			 gbcparent.gl_bc_packets_rowid
                  from   gms_bc_packets gbcparent
                  where  gbcparent.bc_packet_id = gbc.parent_bc_packet_id)
	  where  gbc.packet_id   = l_gms_packet_id
	  and    gbc.status_code = 'I'
	  and    gbc.gl_bc_packets_rowid IS NULL;

         IF g_debug = 'Y' THEN
   	    gms_error_pkg.gms_debug ('Synch_gms_gl_packets Strat : Updated bc packets for prepayment burden adjustment lines '|| SQL%ROWCOUNT,'C');
         END IF;
/* Bug 5645290 - End */

  END IF;
  CLOSE get_temp_packet_id;

  IF g_debug = 'Y' THEN
     gms_error_pkg.gms_debug ('Synch_gms_gl_packets Strat : End ','C');
  END IF;

End Synch_gms_gl_packets;


/* -----------------------------------------------------------------------------------------
 This is the funds check function which calls all the other functions and procedures.
   Parameters :
      x_sobid    : Set of Books ID   in GL accounts for the packet to funds checked.
      x_packetid : Packet ID of the packet to be funds checked.
      x_mode     : Funds Checker Operation Mode.
                     C  - Check funds
                     R  - Reserve funds.
                     U  - Un-reserve  (only for REQ,PO and AP)
                     B  - Called from budget baseline process  (Processed like check funds)
                     S  - Called from Budget submission     (Processed like check funds)
                     X  - Called for Expenditure Items funds check
                     I  - Called for Supplier Cost funds check during interface AP->PA
      x_partial  : Indicates the packet can be fundschecked/reserverd partially or not
                     Y  - Partial
                     N  - Full mode, default is N
      x_user_id  : User ID for Override   -- Not used
      x_user_resp_id : User Responsibility ID for Override   -- Not used
      x_return_code  : Fudscheck return status
--------------------------------------------------------------------------------------------------*/
   FUNCTION gms_fck (
      x_sobid          IN       NUMBER,
      x_packetid       IN       NUMBER,
      x_mode           IN       VARCHAR2 DEFAULT 'C',
      x_override       IN       VARCHAR2 DEFAULT 'N',
      x_partial        IN       VARCHAR2 DEFAULT 'N',
      x_user_id        IN       NUMBER DEFAULT NULL,
      x_user_resp_id   IN       NUMBER DEFAULT NULL,
      x_execute        IN       VARCHAR2 DEFAULT 'N',
      x_return_code    IN OUT NOCOPY   VARCHAR2,
      x_e_code         OUT NOCOPY      VARCHAR2,
      x_e_stage        OUT NOCOPY      VARCHAR2)
      RETURN BOOLEAN IS

      x_arrival_seq   NUMBER;
      x_err_code      NUMBER;
      x_err_buff      VARCHAR2 (2000);
      x_status        VARCHAR2 (1);
      l_pkt_row       NUMBER ;
      l_dummy         NUMBER;

   BEGIN
      -------------------------------------------------------------------------------+
      -- 1. Initalize variables
      -------------------------------------------------------------------------------+

      g_error_program_name   := 'GMS_FUNDS_CONTROL_PKG';
      g_error_procedure_name := 'Gms_fck';
      g_debug                := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N');
      g_packet_id            := x_packetid;
      g_mode                 := x_mode;

      x_err_code             := 0;
      x_err_buff             := null;

      gms_error_pkg.set_debug_context; -- Added for Bug: 2510024

      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':packet,x_mode,x_partial:'||
			         g_packet_id||','||g_mode||','||x_partial,'C');
      END IF;

       -- ---------------------------------------------------------------------------------------------------------+
       -- 101: R12 Funds Management uptake : This procedure will synch data in gl_bc_packets to gms_bc_packets ..
       -- ---------------------------------------------------------------------------------------------------------+
       SYNCH_GMS_GL_PACKETS(x_packetid);

      -------------------------------------------------------------------------------+
      -- 2. Call gms_fck_init
      -------------------------------------------------------------------------------+
        x_e_stage     := 'Before gms_fck_init call';
        IF g_debug = 'Y' THEN
        	gms_error_pkg.gms_debug (g_error_procedure_name||':'||x_e_stage,'C');
        END IF;

	gms_fck_init(p_partial_flag => x_partial);

        g_error_procedure_name := 'Gms_fck';

      -------------------------------------------------------------------------------+
      -- 3. If funds check called for non-gms transactions exit at this point ..
      -------------------------------------------------------------------------------+
            If g_non_gms_txn then
            x_e_stage := 'All txns. non-gms, exit GMS-FC';

               IF g_debug = 'Y' THEN
        	  gms_error_pkg.gms_debug (g_error_procedure_name||':'||x_e_stage,'C');
               END IF;

               x_return_code := 'S';
               RETURN g_non_gms_txn;
            End If;

      -------------------------------------------------------------------------------+
      -- 301. Initalize currency variables (currency code and precision)
      -------------------------------------------------------------------------------+
           x_e_stage := 'Initalize currency var';

           pa_currency.set_currency_info;

      -------------------------------------------------------------------------------+
      -- 4. Call delete_pending_txns to delete bc pkt txns. left in 'P' status ..
      --    This procedure will delete pending records from gms_bc_packets
      -------------------------------------------------------------------------------+
         x_e_stage := 'delete_pending_txns';
         IF g_debug = 'Y' THEN
            gms_error_pkg.gms_debug (g_error_procedure_name||':'||x_e_stage,'C');
         END IF;

      delete_pending_txns(x_err_code,x_err_buff);

      g_error_procedure_name := 'Gms_fck';
      -------------------------------------------------------------------------------+
      -- 5. Call adl synch for REQ/PO/AP ..
      --    Following procedure create ADLS for NON FAB
      -------------------------------------------------------------------------------+
      -- R12 Funds Management Uptake : Deleted call to misc_synch_adls as its shifted to
      -- main session (copy_gl_pkt_to_gms_pkt) of fundscheck process

      -------------------------------------------------------------------------------+
      -- 6. Following procedure creates gms_bc_packet from gl_bc_packet
      -------------------------------------------------------------------------------+
       -- R12 Funds Management Uptake : Deleted call to misc_gms_insert as its shifted to
       -- main session (copy_gl_pkt_to_gms_pkt) of fundscheck process

      -------------------------------------------------------------------------------+
      -- 7. si adjustment call
      -------------------------------------------------------------------------------+
      -- R12 Funds Management Uptake : R12 open issue
      IF g_doc_type = 'AP' and x_mode = 'R' then
         x_e_stage := 'si_adjustments';
         IF g_debug = 'Y' THEN
                gms_error_pkg.gms_debug (g_error_procedure_name||':'||x_e_stage,'C');
         END IF;

         si_adjustments(x_packetid, l_pkt_row) ;
	 IF l_pkt_row = 0 THEN
            x_return_code := 'S';
	    return TRUE ;
	 END IF ;

      END IF ;

      -------------------------------------------------------------------------------+
      -- 701. Calculate ind_compiled_set_id and handle net_zero for Enc...
      -------------------------------------------------------------------------------+
      -- Encumbrance ind_compiled_set_id derivation and net_zero txn. handling should
      -- happen before the call to calc. burdenable raw cost .. bug 3810247
     /* Bug 5330152 : Added the (x_mode = 'E') check such that the procedures CALC_ENC_IND_COMPILED_SET_ID
        and HANDLE_NET_ZERO_TXN are called only for funds check of Manual Encumbrances. */
     IF (x_mode = 'E') then

      IF g_debug = 'Y' THEN
         g_error_procedure_name := 'Gms_fck';
         x_e_stage := 'ENC:Derive ind';
         gms_error_pkg.gms_debug (g_error_procedure_name||':'||x_e_stage,'C');
      End If;

     CALC_ENC_IND_COMPILED_SET_ID (x_packetid);

      IF g_debug = 'Y' THEN
         g_error_procedure_name := 'Gms_fck';
         x_e_stage := 'ENC:Handle_net_zero_txn:Net_Zero';
         gms_error_pkg.gms_debug (g_error_procedure_name||':'||x_e_stage,'C');
      End If;
        -- Check if  adjusted and adjusting transactions are present in the same packet
        -- If so, update them with result_code 'P82' and update effect_on_funds_code
        -- to 'I' so that 'funds avilable' calculation ignores them.

     HANDLE_NET_ZERO_TXN(x_packetid,'Net_Zero');

      IF g_debug = 'Y' THEN
         g_error_procedure_name := 'Gms_fck';
         x_e_stage := 'ENC:Handle_net_zero_txn:Check_Adjusted';
         gms_error_pkg.gms_debug (g_error_procedure_name||':'||x_e_stage,'C');
      End If;
       --  Fail adjusting transaction, if original transaction has not been  FC'ed(F08)

     HANDLE_NET_ZERO_TXN(x_packetid, 'Check_Adjusted');

    END IF;

      -------------------------------------------------------------------------------+
      -- 8. Burdenable Raw Cost calculation
      -------------------------------------------------------------------------------+
      -- R12 Funds Management Uptake : For x_mode ='R'/'U'/'C', call to calculate burden
      -- update_bc_pkt_burden_raw_cost is shifted to main session procedure
      -- copy_gl_pkt_to_gms_pkt of fundscheck process.

      --IF x_mode IN ('R', 'U', 'C', 'E','X') THEN
      IF x_mode IN ( 'E','X') THEN
         -- Calculate burdenable_cost and update on gms_bc_packets ..............
         -- Calling burden calculation for all except for mode : Submit,Baseline,Interface
         IF g_debug = 'Y' THEN
            x_e_stage := 'Burdenable Raw Cost calculation';
            g_error_procedure_name := 'Gms_fck';
            gms_error_pkg.gms_debug (g_error_procedure_name||':'||x_e_stage,'C');
         END IF;

           -- 8A. CALCULATING BURDENABLE RAW COST
           -- pass g_derived_mode parameter ...
           IF NOT gms_cost_plus_extn.update_bc_pkt_burden_raw_cost (x_packetid,g_derived_mode) THEN
            result_status_code_update (
               p_packet_id=> x_packetid,
               p_status_code=> 'T',
               p_result_code=> 'F76');

	    -- Bug : 2557041 - Added for IP check funds Enhancement
	    -- Update gl_bc_packets result_code to F67 if update Burdenable Raw Cost
	    -- failed.

	    UPDATE gl_bc_packets
	       SET result_code = DECODE (NVL (SUBSTR (result_code, 1, 1), 'P'),'P', 'F67',result_code)
 	     WHERE packet_id = x_packetid;

	    x_e_code := 'U';		  -- Bug : 2557041 - Added , same as done for misc_gms_insert
            g_return_code := 'T';
            x_return_code := 'T';
            RETURN (FALSE);
           END IF;

           -- 8B. CHECK FOR FAILURE ..
           -- If any transaction has failed burdenable_raw_cost calculation and
           -- the mode is 'R' or 'U' or 'C' .. fail the packet with F65
	   -- R12 Funds Management Uptake : burden calculation logic for x_mode ='R'/'U'/'C'
	   -- shifted to main session procedure copy_gl_pkt_to_gms_pkt.

         IF g_debug = 'Y' THEN
         	gms_error_pkg.gms_debug (
            'GMS_FCK-After Calling gms_cost_plus_extn.update_bc_pkt_burden_raw_cost','C');
         END IF;

   END IF;

   -------------------------------------------------------------------------------+
   -- 9. Create indirect cost lines
   -------------------------------------------------------------------------------+
   IF x_mode not in ('S','B') then
         -- Ensure that the burden components are not re-created during budget baseline

         x_e_stage := 'misc_gms_idc';
         IF g_debug = 'Y' THEN
            g_error_procedure_name := 'Gms_fck';
            gms_error_pkg.gms_debug (g_error_procedure_name||':'||x_e_stage,'C');
         END IF;

         IF NOT misc_gms_idc (x_packetid) THEN
            RETURN (FALSE);
         END IF;

	 COMMIT;
   END IF;

   -------------------------------------------------------------------------------+
   -- 10. Main Funds Check Processor - gms_fcp call
   -------------------------------------------------------------------------------+

         x_e_stage := 'gms_fcp';
         IF g_debug = 'Y' THEN
            g_error_procedure_name := 'Gms_fck';
            gms_error_pkg.gms_debug (g_error_procedure_name||':'||x_e_stage,'C');
         END IF;

           -- pass g_derived_mode parameter ...
      IF NOT gms_fcp (x_sobid, x_packetid, g_derived_mode, g_partial_flag, x_arrival_seq,
		      x_err_code, x_err_buff) THEN
         RETURN (FALSE);
      END IF;

     COMMIT;

      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug ('GMS_FCK-After Calling gms_fcp', 'C');
      END IF;

   -------------------------------------------------------------------------------+
   -- 11. Posting for encumbrances ..
   -------------------------------------------------------------------------------+
      IF x_mode = 'E' THEN
         x_e_stage := 'Posting for encumbrances';
            g_error_procedure_name := 'Gms_fck';
         --g_error_procedure_name := 'update_source_burden_raw_cost';
         IF g_debug = 'Y' THEN
            gms_error_pkg.gms_debug (g_error_procedure_name||':'||x_e_stage,'C');
         END IF;

         IF NOT gms_cost_plus_extn.update_source_burden_raw_cost (x_packetid, x_mode, g_partial_flag) THEN
            IF g_debug = 'Y' THEN
         	gms_error_pkg.gms_debug ('GMS_FCK- Posting for encumbrances ..failed','C');
            END IF;
            result_status_code_update (
               p_packet_id=> x_packetid,
               p_status_code=> 'T',
               p_result_code=> 'F64');

         END IF;
      END IF;

   ----------------------------------------------------------------------------------+
   -- 12. Status code update for 'Expenditure Items' and 'Interface Items'
   ----------------------------------------------------------------------------------+

      -- Update bc_packet failed records status_code to 'R'
      IF  x_mode in ('X','I') then

        x_e_stage     := 'Update status on failed bcpkt';
         IF g_debug = 'Y' THEN
            g_error_procedure_name := 'Gms_fck';
            gms_error_pkg.gms_debug (g_error_procedure_name||':'||x_e_stage,'C');
         END IF;

        update_status_on_failed_txns(x_packetid);

      END IF;

   <<gms_return_code_label>>
   ----------------------------------------------------------------------------------+
   -- 13. Determine the return code sent to GL/subit/baseline ..
   ----------------------------------------------------------------------------------+
    x_e_stage     := 'Return Code derivation';

    If x_mode in ('R','U','C','E','S','B') then
        x_e_stage     := 'Determine return code';
         IF g_debug = 'Y' THEN
            g_error_procedure_name := 'Gms_fck';
            gms_error_pkg.gms_debug (g_error_procedure_name||':'||x_e_stage,'C');
         END IF;

      IF NOT gms_return_code (x_packetid, g_derived_mode, g_partial_flag, x_return_code, x_e_code, x_err_buff) THEN
         RETURN FALSE;
      END IF;

      IF g_debug = 'Y' THEN
        g_error_procedure_name := 'Gms_fck';
      	gms_error_pkg.gms_debug (g_error_procedure_name||':'||x_e_stage||':return code'||x_return_code,'C');
      END IF;
    End If;

      <<end_process>>
      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (' ********** End of GMS_FCK **********  ', 'C');
      END IF;
      COMMIT;

      RETURN (TRUE);
-- ********************GMS FUNDS CHECKER LAST LINE *********** END ************************
   EXCEPTION
      WHEN OTHERS THEN
         x_e_code := 'U';
         x_e_stage := SQLCODE||' '||SQLERRM;	-- Bug 2337897 : Added SQLCODE
         g_return_code := 'T';
         x_return_code := 'T';

         gms_error_pkg.gms_message (
            x_err_name=> 'GMS_UNEXPECTED_ERROR',
            x_token_name1=> 'PROGRAM_NAME',
            x_token_val1=> g_error_program_name || '.' || g_error_procedure_name || '.' || g_error_stage,
            x_token_name2=> 'SQLCODE',
            x_token_val2=> SQLCODE,
            x_token_name3=> 'SQLERRM',
            x_token_val3=> SQLERRM,
            x_exec_type=> 'C',
            x_err_code=> x_err_code,
            x_err_buff=> x_err_buff);

         result_status_code_update (
            p_packet_id=> x_packetid,
            p_status_code=> 'T',
            p_result_code=> 'F89',
     		p_fc_error_message=>SUBSTR((g_error_program_name || '.' || g_error_procedure_name || '.' || g_error_stage ||' SQLCODE :'||SQLCODE||' SQLERRM :'||SQLERRM),1,2000)
                                  );

		 -- Bug 2176230 - Delete arrival_order record in case of any failure.

		 IF x_mode = 'C' THEN
                   DELETE gms_bc_packet_arrival_order
		    WHERE packet_id = x_packetid;
   	         END IF;

	 -- Bug 2337897 :  If any Unhandled exception occurs, them mark gl_bc_packets
	 --		   as Funds check failed

         If x_mode in ('R','U','C') and g_doc_type <> 'FAB' then -- not g_derived_mode

  	   UPDATE gl_bc_packets SET
	   result_code = DECODE (NVL (SUBSTR (result_code, 1, 1), 'P'),'P', 'F71',result_code)
	   WHERE packet_id = x_packetid;

         End If;

         COMMIT;
         RETURN(FALSE);
   END gms_fck;

-- ==============================================================================

   PROCEDURE gms_gl_return_code (
      x_packet_id          IN       NUMBER,
      x_mode               IN       VARCHAR2,
      x_gl_return_code     IN OUT NOCOPY   VARCHAR2,
      x_gms_return_code    IN       VARCHAR2,
      x_gms_partial_flag   IN       VARCHAR2,
      x_er_code            IN OUT NOCOPY   VARCHAR2,
      x_er_stage           IN OUT NOCOPY   VARCHAR2) IS

   BEGIN

     -- Code removed as gms_funds_posting_pkg.gms_gl_return_code called for AP/PO/REQ
     -- ENC/EXP does not gms_gl_return_code
     null;

   END gms_gl_return_code;
----------------------------------------------------------------------------------------------------------

-- R12 Funds Management Uptake : This tieback procedure is called from PSA_BC_XLA_PVT.Budgetary_control
-- if SLA accounting fails.This API will mark the gms_bc_packet records to failed status.

PROCEDURE TIEBACK_FAILED_ACCT_STATUS (p_bc_mode IN  VARCHAR2 DEFAULT 'C') IS
BEGIN

   UPDATE gms_bc_packets
     SET  status_code = DECODE(p_bc_mode,'C','F','R'),
          result_code = 'F22'
   WHERE  status_code in ('I','A','S')
     AND  source_event_id IN
            (SELECT  event_id
               FROM  PSA_BC_XLA_EVENTS_GT
	       WHERE upper(result_code) in ('XLA_ERROR','FATAL'));

END TIEBACK_FAILED_ACCT_STATUS;


END gms_funds_control_pkg;

/
