--------------------------------------------------------
--  DDL for Package Body GMS_PA_COSTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_PA_COSTING_PKG" AS
-- $Header: gmspafcb.pls 120.23.12010000.5 2009/01/31 05:21:53 jravisha ship $

-- Declare variables.
-- Bug 5236418 : The collection variables are initialized before they are referenced.
t_project_id	                        tt_project_id := tt_project_id();
t_award_id                              tt_award_id := tt_award_id();
t_task_id                               tt_task_id := tt_task_id();
t_expenditure_type                      tt_expenditure_type := tt_expenditure_type();
t_expenditure_item_date                 tt_expenditure_item_date := tt_expenditure_item_date();
t_actual_flag                           tt_actual_flag;
t_status_code                           tt_status_code;
t_last_update_date                      tt_last_update_date;
t_last_updated_by                       tt_last_updated_by;
t_created_by                            tt_created_by;
t_creation_date                         tt_creation_date;
t_last_update_login                     tt_last_update_login;
t_je_category_name                      tt_je_category_name;
t_je_source_name                        tt_je_source_name;
t_transfered_flag                       tt_transfered_flag;
t_document_type                         tt_document_type;
t_expenditure_organization_id           tt_expenditure_organization_id := tt_expenditure_organization_id();
t_document_header_id                    tt_document_header_id;
t_document_distribution_id              tt_document_distribution_id;
t_entered_dr                            tt_entered_dr;
t_entered_cr                            tt_entered_cr;
t_status_flag                           tt_status_flag;
t_bc_packet_id                          tt_bc_packet_id;
t_request_id                            tt_request_id;
t_ind_compiled_set_id                   tt_ind_compiled_set_id := tt_ind_compiled_set_id();
t_person_id                             tt_person_id;
t_job_id                                tt_job_id;
t_expenditure_category                  tt_expenditure_category := tt_expenditure_category();
t_revenue_category                      tt_revenue_category := tt_revenue_category();
t_adjusted_document_header_id           tt_adjusted_document_header_id;
t_award_set_id                          tt_award_set_id;
t_transaction_source                    tt_transaction_source := tt_transaction_source();
t_system_linkage_function               tt_transaction_source;
t_burdenable_raw_cost                   tt_burdenable_raw_cost := tt_burdenable_raw_cost();
t_acct_raw_cost                         tt_acct_raw_cost := tt_acct_raw_cost();
t_line_type_lookup                      tt_line_type_lookup;
t_invoice_type_lookup                   tt_invoice_type_lookup;

--REL12 : AP lines uptake enhancement : Added below plsql tables
t_invoice_id                            tt_invoice_id := tt_invoice_id();
t_invoice_distribution_id               tt_invoice_distribution_id := tt_invoice_distribution_id();
t_sys_ref4                              tt_sys_ref4 := tt_sys_ref4();
t_bud_task_id                           tt_bud_task_id := tt_bud_task_id();
t_adjusted_expenditure_item_id          tt_document_header_id := tt_document_header_id();
t_txn_interface_id                      tt_txn_interface_id := tt_txn_interface_id();
t_nz_adj_flag                           tt_nz_adj_flag := tt_nz_adj_flag();

l_last_update				date := trunc(sysdate);

-- This variable is used by all the AP interface procedures defined in this package
g_xface_rec				get_xface_cur%ROWTYPE;

g_process               varchar2(10);

-- Declare Local Procedures and Functions here.

-- Set the global debug context if either PA or GMS debug is enabled.
Procedure Set_Debug_Context;

-- Check if there are any CDLs to be processed for the current request_id.
Function More_CDLs_to_Process return varchar2;

-- This procedure fetches the set_of_books_id and packet_id from a sequence.
Procedure INIT;

--
-- Procedure to mark expenditure items as failed fundscheck for costing
--
Procedure Mark_ExpItem_As_Failed;

--
Procedure Delete_Concurrency_Records;


-- Populate GMS_BC_PACKETS with Costed Expenditure Items for fundscheck.
Procedure Populate_BC_Packets;

-- Populate GMS_BC_PACKETS with AP Interface txns
Procedure Populate_BC_Packets(p_bc_pkt  IN  gms_bc_packets%ROWTYPE);

-- Populate GMS Concurrency table. This is to control concurrent running of
-- costing processes.
Procedure Populate_Concurrency_Table(p_system_linkage in VARCHAR2);

-- Procedure execute fundscheck for both Costed Expenditures and Interface SI.
-- Return code is checked to see if any error occured.
Procedure Execute_FundsCheck(p_fck_return_code OUT NOCOPY NUMBER,
                             p_fck_err_code    OUT NOCOPY VARCHAR2,
                             p_fck_err_stage   OUT NOCOPY VARCHAR2);

-- Procedure to handle net zero items and adjusting items coming in
-- for costing and fundscheck.
Procedure Handle_net_zero_txn(p_packetid IN number, p_mode IN varchar2 );

-- Procedure to summarize the amounts for Award + Exp Type and update the
-- summary table.
--Procedure Summarize_Costs;

-- Procedure to update status of packet entries.
Procedure Update_GMS_BC_Packets(p_process IN VARCHAR2, p_request_id IN NUMBER);

-- Procedure to create ADLs for successfully fundschecked expenditure items.
Procedure Create_ADLs(p_process IN VARCHAR2, p_request_id IN NUMBER);

-- Procedure to populate the indirect cost data into gms_bc_packets table.
-- Used for interface process.
Procedure Populate_Indirect_Cost(p_packet_id	IN	NUMBER);

-- Procedure to mark interfacing item as failed. This is used for
-- Interface process.
Procedure Mark_Xface_Item_AS_Failed(p_packet_id IN NUMBER, p_status out nocopy varchar2);

-- Procedure to post the burden costs to adjustment logs.
--Procedure Post_Burden_Records;

-- Procedure to initialize the pl/sql arrays.
Procedure Initialize_Tabs;

-- Procedure to populate arrival order sequence table.
-- In the current code, x_mode is not used.
Procedure Insert_Arrival_Order_Seq (x_packetid  IN  NUMBER,
                                    x_mode      IN  VARCHAR2);

--=============================================================================
-- Procedure FundsCheck_CDLs does the following :
--  1. Check the debug context : set debug context if either Projects or
--     GMS debug options are set to 'Y'.
--  2. Query CDLs based on the request id passed and see if there are any
--     to be processed. If no CDLs are found then return to calling point.
--     Else process them.
--  3. If there are CDLs to be processed populate gms_bc_packets table and
--     call gms_funds_control_pkg.gms_fck in 'X' mode for fundschecking.
--  4. If packet fails fundscheck, mark the expenditures with rejection code
--     and delete the corresponding CDLs.
--
--     Parameters  and meaning.
--     -----------------------
--	   p_request_id    : Request_id of the costing process being run.
--	   p_return_status : Return status: 0 if success and 1 if failure.
--         p_error_code    : Error Code for the failure.
--         p_error_stage   : Stage where the failure occured.
--=============================================================================

Procedure FundsCheck_CDL (p_request_id    IN  NUMBER,
                           p_return_status OUT NOCOPY NUMBER,
                           p_error_code    OUT NOCOPY VARCHAR2,
                           p_error_stage   OUT NOCOPY NUMBER) IS

l_fck_return_code	NUMBER;
l_fck_error_code	varchar2(1) := NULL;
l_fck_error_stage	varchar2(10) := NULL;

begin

  g_packet_id := NULL;
  g_debug_context := NULL;
  g_set_of_books_id := NULL;
  g_request_id := p_request_id;

  g_error_stage := 'FundsCheck_CDL: Start';

  Set_Debug_Context;

  IF g_debug_context = 'Y' THEN
     gms_error_pkg.gms_debug (g_error_stage,'C');
     gms_error_pkg.gms_debug ('Debug profile set to : ' || g_debug_context,'C');
  END IF;

  g_error_stage := 'Checking if there are any CDLs to be processed';

  if More_CDLs_to_Process = 'N' then
         IF g_debug_context = 'Y' THEN
	    gms_error_pkg.gms_debug ('Did not find any CDLs to be processed. Exit','C');
	 END IF;
     p_return_status := 0;
     return;
  end if;

  -- Expenditure items need to be processed. Get packetid and set of books info.
  g_error_stage := 'Execute INIT. Get set of books id and packet id';

  IF g_debug_context = 'Y' THEN
     gms_error_pkg.gms_debug (g_error_stage ,'C');
  END IF;

  INIT;

  IF g_debug_context = 'Y' THEN
     gms_error_pkg.gms_debug ('Set of Books : '|| g_set_of_books_id ||
                              'Packet ID : ' || g_packet_id ,'C');
  END IF;

  g_process := 'Costing';

  -- Perform fundscheck for the items.
  g_error_stage := 'Calling Execute_FundsCheck procedure';

  Execute_FundsCheck(l_fck_return_code,
                     l_fck_error_code,
                     l_fck_error_stage);

  if l_fck_return_code < 0 then

    IF g_debug_context = 'Y' THEN
      gms_error_pkg.gms_debug ('Execute Funds Check returned: ' || l_fck_return_code, 'C');
      gms_error_pkg.gms_debug ('Error Stage : ' || l_fck_error_stage,'C');
    END IF;
  end if;

  -- Mark failure result code in cost_dist_rejection_code for expenditure items that failed
  -- funds check and delete corresponding cdl's.
  Mark_ExpItem_As_Failed;

  -- Initalize pl/sql table ..
  Initialize_Tabs;

  p_return_status := 0;

exception
  when others then

        IF g_debug_context = 'Y' THEN
	   gms_error_pkg.gms_debug ('In when others of FundsCheck_CDL. Stage :' || g_error_stage , 'C');
	END IF;

	p_return_status := -1;
	return;

end FundsCheck_CDL;

---
-------------------------------------------------------------------------------
-- Procedure to set the global variable g_debug_context.
-- Set the variable to 'Y' if either of Grants or Projects debug profile
-- option is set to 'Yes'.
-------------------------------------------------------------------------------
procedure Set_Debug_Context is

begin
  if (NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N') = 'Y' or
      NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N') = 'Y') then
     g_debug_context := 'Y';
     gms_error_pkg.set_debug_context;
  end if;
end Set_Debug_Context;

-------------------------------------------------------------------------------
-- Procedure to fetch the set of books id and fetch packet_id from sequence.
-------------------------------------------------------------------------------

  Procedure INIT is
   l_sob_id	NUMBER;
   l_packet_id	NUMBER;
  Begin
    select gl_bc_packets_s.nextval, set_of_books_id
      into l_packet_id, l_sob_id
      from pa_implementations;

    g_set_of_books_id := l_sob_id;
    g_packet_id := l_packet_id;

    g_error_stage := 'Fetched Set of Books and Packet IDs';

    -- Initialize currency context.
    pa_currency.set_currency_info;

  End INIT;

---
-- Procedure to initialize the pl/sql arrays.

Procedure Initialize_Tabs is
Begin

   t_project_id.delete;
   t_award_id.delete;
   t_task_id.delete;
   t_expenditure_type.delete;
   t_expenditure_item_date.delete;
   t_expenditure_organization_id.delete;
   t_document_header_id.delete;
   t_document_distribution_id.delete;
   t_entered_dr.delete;
   t_entered_cr.delete;
   t_burdenable_raw_cost.delete; --R12 AP lines uptake :Forward port bug 4217161
   t_ind_compiled_set_id.delete;
   t_person_id.delete;
   t_job_id.delete;
   t_expenditure_category.delete;
   t_revenue_category.delete;
   t_adjusted_document_header_id.delete;
   t_award_set_id.delete;
   t_transaction_source.delete;
   t_system_linkage_function.delete;

End Initialize_Tabs;

---
-------------------------------------------------------------------------------
-- Function to check if there are any transactions to be processed.
-- If there are any fetch them into pl/sql arrays and return 'Y' else
-- return 'N'.
-------------------------------------------------------------------------------

Function More_CDLs_to_Process return varchar2 is

cursor get_cdls_cur is
  select cdl.expenditure_item_id,				-- document_header_id
         cdl.line_num,						-- document_distribution_id
         decode(exp.net_zero_adjustment_flag,
                  'Y', nvl(exp.adjusted_expenditure_item_id, cdl.expenditure_item_id),
                  NULL),                                        -- adjusted_document_header_id
         exp.transaction_source,				-- transaction_source
         adl.award_set_id,					-- award_set_id
         adl.award_id,						-- award_id
         cdl.project_id,					-- project_id
         exp.task_id,						-- task_id
         exp.expenditure_type,					-- expenditure_type
         exp.expenditure_item_date,				-- expenditure_item_date
         exp.system_linkage_function,
         cdl.ind_compiled_set_id,                               -- ind_compiled_set_id
         exp.job_id,                                             -- job_id
         nvl(exp.override_to_organization_id, pae.incurred_by_organization_id) expenditure_org, -- Expenditure org
         pae.incurred_by_person_id,                              -- incurred by person_id
         et.expenditure_category,                                -- expenditure catg
         et.revenue_category_code,                               -- revenue catg
         decode(sign(cdl.amount), 1, cdl.amount, 0),             -- entered_dr
         decode(sign(cdl.amount), -1, -1 * cdl.amount, 0),        -- entered_cr
         -- R12 AP Lines Uptake: Reversing CDL lines should have same BRC as that of original line.
         -- This forward port of fix 4217161.
	 (SELECT NVL(adl.burdenable_raw_cost,0) * -1
	    FROM gms_award_distributions adl
	   WHERE adl.cdl_line_num = cdl.line_num_reversed
             AND adl.expenditure_item_id = cdl.expenditure_item_id
             AND adl.document_type       = 'EXP'
             AND adl.adl_status          = 'A'
	     AND cdl.line_num_reversed IS NOT NULL ) burdenable_raw_cost
    from pa_cost_distribution_lines cdl,
         pa_expenditure_items exp,
         gms_award_distributions adl,
         pa_expenditures_all pae,
         pa_expenditure_types et
   where cdl.request_id = g_request_id
     and cdl.line_type = 'R'
     and nvl(cdl.reversed_flag,'N') <> 'Y'
     and cdl.expenditure_item_id = exp.expenditure_item_id
     and exp.cost_distributed_flag = 'S'
     and cdl.expenditure_item_id = adl.expenditure_item_id
     and nvl(adl.cdl_line_num, 1) = 1
     and adl.adl_status = 'A'
     and adl.document_type = 'EXP'
     and exp.expenditure_id = pae.expenditure_id
     and exp.expenditure_type = et.expenditure_type
     and exp.cost_dist_rejection_code is null;


begin

  g_error_stage := 'Opening get_cdls_cur cursor';

  open get_cdls_cur;
  fetch get_cdls_cur bulk collect
   into  t_document_header_id,
         t_document_distribution_id,
         t_adjusted_document_header_id,
         t_transaction_source,
         t_award_set_id,
         t_award_id,
         t_project_id,
         t_task_id,
         t_expenditure_type,
         t_expenditure_item_date,
         t_system_linkage_function,
         t_ind_compiled_set_id,
         t_job_id,
         t_expenditure_organization_id,
         t_person_id,
         t_expenditure_category,
         t_revenue_category,
         t_entered_dr,
         t_entered_cr,
	 t_burdenable_raw_cost;

   close get_cdls_cur;

     g_error_stage := 'Bulk count check.';

   if t_document_header_id.count = 0 then

     IF g_debug_context = 'Y' THEN
        gms_error_pkg.gms_debug ('Did not find any CDLs to be processed','C');
     END IF;

     return 'N';
   else
     IF g_debug_context = 'Y' THEN
        gms_error_pkg.gms_debug ('Found CDLs to be processed','C');
     END IF;

     return 'Y';
   end if;

end More_CDLs_to_Process;

---
/*------------------------------------------------------------------------
 This procedure is called for both Costing and Interface processes.
 Processes are identified by a global variable.
 Do fundscheck where required.
 Procedure returns 0 for success and -1 if procedure encounters any
 exception.
--------------------------------------------------------------------------*/
Procedure Execute_FundsCheck(p_fck_return_code OUT NOCOPY NUMBER,
                             p_fck_err_code    OUT NOCOPY VARCHAR2,
                             p_fck_err_stage   OUT NOCOPY VARCHAR2)  is
  Pragma autonomous_transaction;

l_err_code	           varchar2(1);
l_err_buf	           varchar2(2000);
l_return_code          varchar2(3);

l_system_linkage       varchar2(3);
l_fc_mode	           varchar2(1);
l_partial_mode         varchar2(1);

l_bc_pkt               gms_bc_packets%ROWTYPE;
l_packet_id            number;

l_fc_required          varchar2(1) := 'N';
l_je_source_name       varchar2(30);
l_je_category_name     varchar2(30);
l_doc_type	       varchar2(3);
l_actual_flag	       varchar2(1);
l_status_code          varchar2(1);
l_budget_version_id    number;
l_entry_level_code     varchar2(1);
l_entered_dr           number;
l_entered_cr           number;
l_effect_on_funds_code varchar2(1);

l_new_compiled_set_id  number;
l_invoice_id           number ;
l_po_matched_flag      VARCHAR2(1); -- R12 AP lines uptake
l_comm_fc_req          VARCHAR2(1); -- R12 AP lines uptake
l_top_task_id          number;
l_cmt_releived         VARCHAR2(1) := 'N';

--REL12 : AP lines uptake enhancement : Added below variables
l_old_award_id         gms_awards_all.award_id%TYPE;
l_old_project_id       pa_projects_all.project_id%TYPE;
l_old_task_id          pa_tasks.task_id%TYPE;
l_bud_task_id          gms_bc_packets.bud_task_id%TYPE;
l_adj_ei_populated     VARCHAR2(1);

-- Cash based accounting variables
l_adl_fully_paid        VARCHAR2(1); -- Flag indicating if invoice is flly paid
l_apdist_brc_to_relieve NUMBER;      -- Variable storing the BRC to be relieved for AP
l_apdist_amt_to_relieve NUMBER;      -- Variable storing the Invoice dist amount to be relieved for AP
l_cash_fc_required      VARCHAR2(1); -- Flag indicating if Fundscheck is required during payment interface
l_erv_found             VARCHAR2(1); -- Flag indicates if payment has ERV
l_ap_bc_pkt_id          NUMBER;      -- Variable to store bc_packet_id of the AP RAW record created during FC

CURSOR C_ap_bc_pkt_id (p_packet_id NUMBER) IS
SELECT bc_packet_id
  FROM gms_bc_packets gbc
 WHERE packet_id = p_packet_id
   AND document_type = 'AP'
   AND parent_bc_packet_id IS NULL
   AND entered_dr <> 0 OR entered_cr <> 0 ;

-- R12 AP LINES UPTAKE:Procedure to calculate amount of burden to be releived for partial or full payments for
-- cash basis accounting.

PROCEDURE CALCULATE_PAYTMENT_BRC (p_adl_fully_paid     OUT NOCOPY VARCHAR2 ,
                                  p_erv_found          OUT NOCOPY VARCHAR2 ,
				  p_cash_fc_required   OUT NOCOPY VARCHAR2 ,
				  p_apdist_amt_to_relieve  IN OUT NOCOPY VARCHAR2,
                                  p_apdist_brc_to_relieve  OUT  NOCOPY NUMBER) IS

-- Cursor to check if there exists any exchange rate variance for payment
CURSOR   c_erv_exits IS
SELECT   'Y'
  FROM   DUAL
 WHERE   EXISTS (SELECT 1
                   FROM ap_invoice_payments Pay,
		        ap_invoices_all inv
                  WHERE pay.invoice_payment_id   = g_xface_rec.cdl_system_reference4
		    AND pay.invoice_id           =  inv.invoice_id
		    AND NVL(pay.exchange_rate,0) <> NVL(inv.exchange_rate,0));

-- AP Invoice payment amount to be relieved
CURSOR   C_apdist_amount IS
SELECT   NVL(paydist.invoice_dist_base_amount,paydist.invoice_dist_amount)
  FROM   ap_payment_hist_dists Paydist
 WHERE   paydist.pay_dist_lookup_code = 'CASH'
   AND   Paydist.invoice_distribution_id = g_xface_rec.invoice_distribution_id
   AND   PayDIST.invoice_payment_id = g_xface_rec.cdl_system_reference4;

-- Cursor to fetch burdenable raw cost and payment status on AP invoice distribution corresponding
-- to which payment is being interfaced

 CURSOR C_ap_amt_brc IS
 SELECT nvl(adl.burdenable_raw_cost,0),NVL(adl.payment_status_flag,'N')
   FROM ap_invoice_distributions 	APD,
        gms_award_distributions 	ADL
  where adl.invoice_distribution_id                     = APD.invoice_distribution_id
    and adl.adl_status					= 'A'
    and adl.document_type                               = 'AP'
    and ADL.award_set_id				= APD.award_id
    and apd.invoice_id				        = g_xface_rec.invoice_id
    and apd.invoice_distribution_id		        = g_xface_rec.invoice_distribution_id;

 --BRC already consumed in current run
 CURSOR c_pkt_brc IS
  SELECT sum(NVL(gbc.burdenable_raw_cost,0))
    FROM gms_bc_packets gbc
   WHERE gbc.packet_id = g_packet_id
     AND gbc.request_id = g_request_id
     AND gbc.status_code = 'P'
     AND gbc.document_header_id = g_xface_rec.invoice_id
     AND gbc.document_distribution_id = g_xface_rec.invoice_distribution_id
     AND gbc.document_type = 'AP';

  -- Cursor to fetch amount on invoice distribution
  CURSOR c_ap_amt IS
  SELECT NVL(apdist.base_amount,apdist.amount)
   FROM  ap_invoice_distributions_all apdist
  WHERE  apdist.invoice_distribution_id =  g_xface_rec.invoice_distribution_id
    AND  apdist.invoice_id  = g_xface_rec.invoice_id ;

  -- Bug : 5414183
  -- Cursor to fetch interfaced payment amount for an invoice distribution
  CURSOR c_ap_interfaced_pay_amt IS
  SELECT SUM(NVL(paydist1.invoice_dist_base_amount,paydist1.invoice_dist_amount))
         + SUM(NVL(paydist2.invoice_dist_base_amount,paydist2.invoice_dist_amount))
  FROM   ap_payment_hist_dists Paydist1,
         ap_payment_hist_dists Paydist2
 WHERE   paydist1.pay_dist_lookup_code = 'CASH'
   AND   Paydist1.invoice_distribution_id = g_xface_rec.invoice_distribution_id
   and   Paydist2.invoice_distribution_id = g_xface_rec.invoice_distribution_id
   AND   ( paydist1.pa_addition_flag = 'Y'  OR  --interfaced payments
           PayDIST1.invoice_payment_id IN ( SELECT xface.cdl_system_reference4  -- Payments marked for interface in current run
	                                     FROM pa_transaction_interface_all xface
					    WHERE xface.transaction_source = G_txn_source
					      and xface.cdl_system_reference2  = g_xface_rec.invoice_id
                                              and xface.cdl_system_reference5  = g_xface_rec.invoice_distribution_id
                                              and xface.cdl_system_reference4 is not NULL
					      and xface.TRANSACTION_STATUS_CODE ='P'))
   AND 	paydist2.invoice_distribution_id  = paydist1.invoice_distribution_id
   and  paydist2.payment_history_id       = paydist1.payment_history_id
   and  paydist2.invoice_payment_id       = paydist1.invoice_payment_id
   and  paydist2.pay_dist_lookup_code     = 'DISCOUNT' ;



     -- ====================================================================================
     --
     -- Bug : 5414183
     --     : R12.PJ:XB1:QA:BC:INCORRECT AMOUNTS INTERFACED TO GRANTS IN CASH BASED ACC
     --       For payments, payment amount includes discount amount. So we are interfacing
     --       only payments. But we need to relieve corresponding invoice amount for that
     --       payment.
     --       Invoice dist amount :100
     --                  Payment  : 80
     --                  Disc     : 20
     --          Actual interface : 80
     --          AP Relieve       : 80 + 20 = 100
     -- Functionality :
     --       Discount is applicable when discount method is EXPENSE
     --       Discount is applicable for tax distributions  when discount method is TAX
     --       Discount is not applicable when discount method is 'SYSTEM'
     --       Discount is also based on the discount profile start date
     --       ap payment record includes the discount amount and we do not need to interface
     --       discount record because we are interfacing the payments.
     --       But we need to relieve corresponding inv dist amount paid to relieve the ap commitment amount.
     --       ap amount to relieve := payment amunt + discount amount (when applicable).
     -- ====================================================================================
     CURSOR c_get_disc_amount is
          SELECT  NVL(b.invoice_dist_base_amount , b.invoice_dist_amount) amount
	    from ap_payment_hist_dists b,
	         ap_invoice_distributions_all apd
	   where b.invoice_payment_id      = g_xface_rec.cdl_system_reference4
	     and b.invoice_distribution_id = g_xface_rec.invoice_distribution_id
	     and b.pay_dist_lookup_code    = 'DISCOUNT'
	     and apd.invoice_distribution_id = b.invoice_distribution_id
	     and NVL(apd.historical_flag,'N')       <> 'Y'
	     and apd.expenditure_item_date  >= PA_TRX_IMPORT.G_Profile_Discount_Start_date
	     and apd.line_type_lookup_code  = decode ( PA_TRX_IMPORT.G_discount_Method,
	                                                            'TAX', decode (apd.line_type_lookup_code,
                                                                                                      'TIPV', 'TIPV',
												      'TERV','TERV',
												      'TRV', 'TRV',
												      'NONREC_TAX') ,
	                                                            'SYSTEM', 'NOT APPLICABLE',
								     apd.line_type_lookup_code ) ;


l_ap_outstanding_brc             NUMBER;
l_ap_amt                         NUMBER;
l_ap_interfaced_pay_amt          NUMBER;
l_apdist_pkt_brc                 NUMBER;
l_apdist_brc_to_relieve          NUMBER;
l_disc_amount                    NUMBER := 0;

BEGIN

   -- Fetching applicable discount amount absed on the discount method and profile discount start date.
   --
   -- Bug : 5414183
   --     : R12.PJ:XB1:QA:BC:INCORRECT AMOUNTS INTERFACED TO GRANTS IN CASH BASED ACC
   --
   OPEN  c_get_disc_amount ;
   fetch c_get_disc_amount into l_disc_amount ;
   close c_get_disc_amount ;
   l_disc_amount := NVL(l_disc_amount,0) ;

  --Fetch BRC on ap invoice distribution
  OPEN  C_ap_amt_brc;
  FETCH C_ap_amt_brc INTO l_ap_outstanding_brc,p_adl_fully_paid;
  CLOSE C_ap_amt_brc;

  --Fetch BRC from pa_bc_packets which is consumed during current run
  OPEN  c_pkt_brc;
  FETCH c_pkt_brc INTO l_apdist_pkt_brc;
  CLOSE c_pkt_brc;

  l_ap_outstanding_brc := l_ap_outstanding_brc + l_apdist_pkt_brc;

  -- Calculating AP amount to be relieved.
  -- Only for payment with ERV or for final payment , p_apdist_amt_to_relieve <> g_xface_rec.acct_raw_cost

  -- Intializing the amount
  p_apdist_amt_to_relieve := g_xface_rec.acct_raw_cost + l_disc_amount;

  -- If final payment relieve total outstanding amount
  IF (pa_trx_import.g_finalPaymentId = g_xface_rec.cdl_system_reference4) THEN

      OPEN c_ap_amt;
      FETCH c_ap_amt INTO l_ap_amt ;
      CLOSE c_ap_amt;

      OPEN  c_ap_interfaced_pay_amt;
      FETCH c_ap_interfaced_pay_amt INTO l_ap_interfaced_pay_amt ;
      CLOSE c_ap_interfaced_pay_amt;

      p_apdist_amt_to_relieve := l_ap_amt +l_disc_amount - l_ap_interfaced_pay_amt;

  ELSE
      -- Check if there exists ERV ,IF yes then AP amount to be relieved should be calculated
      -- and based on which BRC has to be dervied .In this case FC is required as AP and EXP amounts will not match.
      OPEN  c_erv_exits;
      FETCH c_erv_exits INTO p_erv_found;
      CLOSE c_erv_exits;

      IF  l_erv_found  = 'Y'  THEN
          OPEN  C_apdist_amount;
          FETCH C_apdist_amount INTO p_apdist_amt_to_relieve;
          CLOSE C_apdist_amount;
          p_apdist_amt_to_relieve := p_apdist_amt_to_relieve + l_disc_amount;
      END IF;

  END IF;

  --  Fundscheck required for below scenarios :
  -- 1. IF AP distriution adl.payment_status_flag = 'Y' then this distribution has been
  --    fully paid and no more adjustments will be allowed on this distribution.i.e.
  --    donot relieve any ap commitment.IN this case EXP should go thru fundscheck.
  -- 2. IF payment has ERV then perform FC as there will be difference in amounts
  -- 3. IF payment is VOIDED/refund then perform FC as +ve amount resrved against AP with
  --    new calculated BRC

  IF (l_adl_fully_paid = 'Y')
     OR (g_xface_rec.acct_raw_cost < 0 )
     OR (l_erv_found = 'Y' )
     OR (pa_trx_import.g_finalPaymentId = g_xface_rec.cdl_system_reference4) THEN

     p_cash_fc_required := 'Y' ;

  END IF;

  -- R12 AP Lines Uptake enhancement : Cash basie accounting Flow
  -- BRC calculation logic :
  --------------------------
  -- 1. IF final payment then relieve leftover BRC.
  -- 2. Calculate BRC for VOIDED payment,refund payments
  -- 3. IF BRC on AP distribution is greater than or equal to payment amount then BRC to
  --    relieve will be equal to that of payment amount
  -- 3. IF BRC on AP distribution is less than payment amount then relieve left over BRC
  -- 5. Update AP distribution ADL with current available BRC and final payment status in tieback
  --
  IF (pa_trx_import.g_finalPaymentId = g_xface_rec.cdl_system_reference4) THEN
      p_apdist_brc_to_relieve := l_ap_outstanding_brc;
  ELSIF p_apdist_amt_to_relieve < 0 THEN
      p_apdist_brc_to_relieve    := NULL;
  ELSIF p_apdist_amt_to_relieve >= l_ap_outstanding_brc THEN
      p_apdist_brc_to_relieve    := l_ap_outstanding_brc;
  ELSIF p_apdist_amt_to_relieve < l_ap_outstanding_brc THEN
      p_apdist_brc_to_relieve    := p_apdist_amt_to_relieve;
  END IF;

END CALCULATE_PAYTMENT_BRC;

PROCEDURE GET_BUD_TASK_DETAILS (p_award_id    NUMBER ,
                                p_project_id  NUMBER,
				p_task_id     NUMBER ) IS

BEGIN

    g_error_stage := 'GET_BUD_TASK_DETAILS: Checking for current baselined budget';
    IF g_debug_context = 'Y' THEN
      gms_error_pkg.gms_debug(g_process||':' || g_error_stage, 'C');
    END IF;

   -- REL12 : AP lines uptake enhancement :
   -- Code introduced to fetch budget_version_id and bud_task_id only if
   -- award/project/task changes.

   IF l_old_award_id   <> p_award_id OR
      l_old_project_id <> p_project_id OR
      l_old_task_id    <> p_task_id   THEN

     begin
       select gbv.budget_version_id, pb.entry_level_code
         into l_budget_version_id, l_entry_level_code
         from gms_budget_versions gbv, pa_budget_entry_methods pb
        where award_id = p_award_id
          and project_id = p_project_id
          and budget_status_code = 'B'
          and current_flag = 'Y'
          and gbv.budget_entry_method_code = pb.budget_entry_method_code;
     exception
      when no_data_found then

           IF g_debug_context = 'Y' THEN
              gms_error_pkg.gms_debug ('No current baselined budget found. Fail the current packet.','C');
              gms_error_pkg.gms_debug ('Award: ' || p_award_id || ' Project: ' || p_project_id, 'C');
           END IF;

          p_fck_return_code := -1;
          p_fck_err_stage := 'F10';
	  return;
     end;

    -- bug 3674107 start
    l_bud_task_id := null;

    select top_task_id
      into l_top_task_id
      from pa_tasks
     where task_id = p_task_id;

    if l_entry_level_code = 'P' then
       l_bud_task_id := 0;
       l_top_task_id := 0;
    elsif l_entry_level_code = 'L' then
       l_bud_task_id := p_task_id;
    elsif l_entry_level_code = 'T' then
       l_bud_task_id := l_top_task_id;
    else -- entry_level_code = 'M'
       begin
         select task_id
           into g_xface_rec.bud_task_id
           from gms_balances
          where budget_version_id = l_budget_version_id
            and task_id = p_task_id
            and balance_type = 'BGT'
	    --Added the following conditions for Bug 4859071
            and project_id = g_xface_rec.project_id
            and award_id = g_xface_rec.award_id
            and rownum =1;
       exception
        when no_data_found then
          begin
            select task_id
              into l_bud_task_id
              from gms_balances
             where budget_version_id = l_budget_version_id
               and task_id = (select top_task_id
                                from pa_tasks
                               where task_id = p_task_id)
               and balance_type = 'BGT'
	       --Added the following conditions for Bug 4859071
               and project_id = g_xface_rec.project_id
               and award_id = g_xface_rec.award_id
               and rownum =1;
          exception
            when no_data_found then
               l_bud_task_id := p_task_id;
          end;
       end;
    end if;

    if l_bud_task_id is null then
       l_bud_task_id := p_task_id;
    end if;
    -- bug 3674107 end.

    l_old_award_id := p_award_id ;
    l_old_project_id := p_project_id;
    l_old_task_id := p_task_id;

   END If;
EXCEPTION
WHEN OTHERS THEN
           IF g_debug_context = 'Y' THEN
              gms_error_pkg.gms_debug ('GET_BUD_TASK_DETAILS : when others exception .\','C');
           END IF;
	   RAISE;
END GET_BUD_TASK_DETAILS;

Begin

  -- If there was any abnormal termination previously, we want to clean up
  -- that data before proceding.
  g_error_stage := 'Calling delete pending transactions';

  gms_funds_control_pkg.delete_pending_txns(l_err_code, l_err_buf);

  if g_process = 'Costing' then

      g_error_stage := 'Calling Populate BC Packets for Costing Fundscheck';

      populate_bc_packets;

     g_error_stage := 'Calling Handle Net Zero Txn for Net Zero';
      -- If adjusting and adjusted items are in the same packet, mark them as passed.

      Handle_Net_Zero_Txn(g_packet_id, 'Net_Zero');

     g_error_stage := 'Calling Handle Net Zero Txn for Check_Adjusted';
      -- If the adjusted item is not already fundschecked or not in the same packet
      -- mark the adjusting item as failed.

      Handle_Net_Zero_Txn(g_packet_id, 'Check_Adjusted');

      select decode(t_system_linkage_function(1), 'ST',  'ST',
                                                  'OT',  'ST',
                                                  'USG', 'USG',
                                                  'PJ',  'USG',
                                                  'ER',  'ER',
                                                  'INV', 'USG',
                                                  'WIP', 'USG',
                                                  'VI',  'VI')
       into l_system_linkage
       from dual;

      -- Call fundscheck in 'X' mode. Internally this is treated same as
      -- 'R' by fundscheck with some flow changes.

      l_fc_mode := 'X';
      l_partial_mode := 'Y';

      g_error_stage := 'Calling populate concurrency table';
      populate_concurrency_table(l_system_linkage);

      commit;

      p_fck_return_code := 0;

      g_error_stage := 'Calling gms_fck';

      -- Call Fundscheck process.
      if NOT gms_funds_control_pkg.gms_fck (x_sobid         =>   g_set_of_books_id,
                                            x_packetid      =>   g_packet_id,
                                            x_mode          =>   l_fc_mode,
                                            x_override      =>   'N',
                                            x_partial       =>   l_partial_mode,
                                            x_user_id       =>   fnd_global.user_id,
                                            x_user_resp_id  =>   fnd_global.resp_id,
                                            x_execute       =>   'Y',
                                            x_return_code   =>   l_return_code,
                                            x_e_code        =>   l_err_code,
                                            x_e_stage       =>   l_err_buf) THEN

          g_error_stage := 'Execute FundsCheck : ' || l_err_buf ;

	  IF g_debug_context = 'Y' THEN
             gms_error_pkg.gms_debug ('Fundscheck errored at: ' || l_err_buf, 'C');
	  END IF;

          -- Set the error codes and related information.
          p_fck_return_code := -1;
          p_fck_err_code := l_err_code;
          p_fck_err_stage := l_err_buf;

      end if;

      commit;

      return;

  end if; -- g_process = 'Costing'

  --- Interface Processing starts.

/*--------------------------------------------------------------------------

  For :  Standard Invoices, Expense Reports and Tax lines

         Check if ind_compiled_set_id changed.
         if ind_compiled_set_id changed then
            create switching entries for AP and EXP
            fundscheck them
         else
            create bucket switching entries for AP and EXP
         end if;
--
  AP Discounts are not fundschecked.
  Prepayment applied distribution line is not fundschecked.

  For : Discounts and Prepayment applied distribution lines
        If amount for either of these is +ve, then do fundscheck
        else create EXP entries.
        For both these entries, no credit is given back to AP.

--------------------------------------------------------------------------*/

  if g_process = 'Interface' then

    g_error_stage := 'In Execute_FundsCheck for Interface items';
    IF g_debug_context = 'Y' THEN
      gms_error_pkg.gms_debug(g_process||':' || g_error_stage, 'C');
    END IF;

   --REL12 : AP lines uptake enhancement : Intializing variables
   l_old_award_id         := 0;
   l_old_project_id       := 0;
   l_old_task_id          := 0;
   l_new_compiled_set_id  := 0;
   l_adj_ei_populated     := 'N';

   -- Intializing cash based accounting related variables
   l_adl_fully_paid           := 'N';
   l_apdist_brc_to_relieve    := NULL;
   l_apdist_amt_to_relieve    := g_xface_rec.acct_raw_cost;
   l_cash_fc_required         := 'N';
   l_erv_found                := 'N';
   l_ap_bc_pkt_id             :=  0;

   -- REL12 : AP lines uptake enhancement :
   -- Compiled_set_id should be queried only for the commitment transaction.
   -- For expenditures, latest compiled set id will always match with the compiled set id
   -- on the adjusted/non adjusted expenditure items. This is controlled by interface process
   -- which rejects interfacing of payables adjustments against uncosted expenditure Items.

   g_error_stage := 'Getting new ind compiled set id';
   IF g_debug_context = 'Y' THEN
      gms_error_pkg.gms_debug(g_process||':' || g_error_stage, 'C');
   END IF;

   l_new_compiled_set_id := gms_cost_plus_extn.get_award_cmt_compiled_set_id(g_xface_rec.task_id,
                                                                              g_xface_rec.expenditure_item_date,
                                                                              g_xface_rec.expenditure_type,
                                                                              g_xface_rec.expenditure_organization_id,
                                                                              'C',
                                                                              g_xface_rec.award_id);

   IF g_debug_context = 'Y' THEN
      gms_error_pkg.gms_debug ('New compiled set id is : ' || l_new_compiled_set_id, 'C');
   END IF;

   IF g_xface_rec.adjusted_expenditure_item_id IS NOT NULL THEN
     l_adj_ei_populated  := 'Y' ;
   END IF;

   --REL12 : AP lines uptake enhancement :
   --Loop for all pa_transaction_interface_all records having same invoice_id,
   --invoice distribution id and Invoice payment id

   FOR i in t_txn_interface_id.FIRST..t_txn_interface_id.LAST LOOP --REL12 :Ap lines Uptake enhancement

    l_system_linkage := 'VI';
    l_fc_mode := 'I';
    l_partial_mode := 'N';
    l_fc_required := 'N';

  -- Create a bc packets record with default values. Update as required.

        l_bc_pkt.packet_id                     :=  g_packet_id;
        l_bc_pkt.project_id                    :=  t_project_id(i);
        l_bc_pkt.award_id                      :=  t_award_id(i);
        l_bc_pkt.task_id                       :=  t_task_id(i);
        l_bc_pkt.expenditure_type              :=  t_expenditure_type(i);
        l_bc_pkt.expenditure_item_date         :=  t_expenditure_item_date(i);
        l_bc_pkt.actual_flag                   :=  'E';
        l_bc_pkt.status_code                   :=  'P';
        l_bc_pkt.set_of_books_id               :=  g_set_of_books_id;
        l_bc_pkt.je_category_name              :=  'Purchase Invoices';
        l_bc_pkt.je_source_name                :=  'Payables';
        l_bc_pkt.transfered_flag               :=  'N';
        l_bc_pkt.document_type                 :=  'AP';
        l_bc_pkt.expenditure_organization_id   :=  t_expenditure_organization_id(i);
        l_bc_pkt.document_header_id            :=  t_invoice_id(i);
        l_bc_pkt.document_distribution_id      :=  t_invoice_distribution_id(i);
        l_bc_pkt.entered_dr                    :=  0;
        l_bc_pkt.entered_cr                    :=  0;
        l_bc_pkt.effect_on_funds_code          :=  'I';
        l_bc_pkt.result_code                   :=  NULL;
        l_bc_pkt.burdenable_raw_cost           :=  t_burdenable_raw_cost(i);
        l_bc_pkt.request_id                    :=  g_request_id;
	-- For transactions latest compiled set id will be same as the one stamped on EI table.
        l_bc_pkt.ind_compiled_set_id           :=  t_ind_compiled_set_id(i);
        l_bc_pkt.vendor_id                     :=  g_xface_rec.vendor_id;
        l_bc_pkt.expenditure_category          :=  t_expenditure_category(i);
        l_bc_pkt.revenue_category              :=  t_revenue_category(i);
        l_bc_pkt.transaction_source            :=  g_txn_source;
	l_bc_pkt.gl_bc_packets_rowid           :=  t_txn_interface_id(i);
        l_bc_pkt.txn_interface_id              :=  t_txn_interface_id(i);


     IF g_debug_context = 'Y' THEN
        gms_error_pkg.gms_debug ('Transaction source : ' || g_txn_source, 'C');
     END IF;

    -- R12 AP lines uptake : Logic for handling transactions where only actuals need to be reserved
    -- and no commitment relieving is required.
    -- Data processed :  AP DISCOUNTS , PREPAYMENT Matched to PO and 11i PREPAYMENT APPLICATIONS

    -- R12 AP lines uptake : Intialize variable holding whether fundscheck is required or NOT
    l_comm_fc_req := 'Y';

    IF (g_txn_source = 'AP DISCOUNTS' ) THEN

       l_comm_fc_req := 'N' ;

    -- PREAPYMENT matched to PO
    ELSIF g_xface_rec.invoice_type_lookup_code = 'PREPAYMENT' THEN

       SELECT DECODE(po_distribution_id,NULL,'N','Y')
         INTO l_po_matched_flag
         FROM ap_invoice_distributions
        WHERE invoice_id = g_xface_rec.invoice_id
          AND invoice_distribution_id =  g_xface_rec.invoice_distribution_id
          AND line_type_lookup_code = 'ITEM';

        IF l_po_matched_flag = 'Y' THEN
           l_comm_fc_req := 'N' ;
        END IF;

    -- 11i PREAPYMENT applications (PREPAY) : which are not fundschecked
    -- In R12 prepayment applications are fundschecked
    ELSIF g_xface_rec.line_type_lookup_code = 'PREPAY' THEN

        IF NVL(g_xface_rec.fc_status,'N')  = 'N' THEN
           l_comm_fc_req := 'N' ;
        END IF;

    END IF;


    -- R12 AP lines uptake : Below commitment costs are NOT fundscheck hence reserve just the actual cost
    -- AP DISCOUNTS : To support R12 and 1ii AP DISCOUNTS
    -- PO matched PREPAYMENT : In R12 prepayments are no longer interfaced to projects .The below code
    --                         is to support 11i historical transactions which are interfaced to projects
    -- PREPAY applications   :
    --                         Accrual based acccounting : In R12 applications of prepayments are no longer
    --                         interfaced to projects.Below code is to support 11i historical transactions.
    --                         Cash based acccounting : In R12 applications of prepayments are interfaced
    --                         from new ap_prepay_apps_dist (cdl_system_refernce4 is not null).as payments .
    --                         11i transactions are interfaced as  invoice dists (cdl_system_refernce4 is null).

    IF ( (g_txn_source = 'AP DISCOUNTS' OR
          g_xface_rec.line_type_lookup_code = 'PREPAYMENT' OR
	  g_xface_rec.line_type_lookup_code = 'PREPAY' ) AND
         l_comm_fc_req = 'N'
        ) THEN

       GET_BUD_TASK_DETAILS (l_bc_pkt.award_id,l_bc_pkt.project_id,l_bc_pkt.task_id);

       l_bc_pkt.bud_task_id                   :=  l_bud_task_id;
       l_bc_pkt.top_task_id                   :=  l_top_task_id;
       l_bc_pkt.budget_version_id             :=  l_budget_version_id;

       if nvl(t_acct_raw_cost(i), 0) > 0 THEN

          l_bc_pkt.entered_dr := pa_currency.round_currency_amt(t_acct_raw_cost(i));
          l_bc_pkt.entered_cr := 0;
          l_bc_pkt.effect_on_funds_code := 'D';
	  --
	  -- REL12 AP Lines Uptake
	  -- Source and reversal transaction is getting interfaced together. So we do not need to
	  -- funds check becoz it is a net zero transaction.
	  --
          IF NVL( t_nz_adj_flag(i) , 'N') = 'Y' then
            l_fc_required := 'N';
	  ELSE
            l_fc_required := 'Y';
            l_bc_pkt.burdenable_raw_cost := NULL; --> this will be calculated
	  END IF ;

       else

	  l_bc_pkt.entered_cr := ABS(pa_currency.round_currency_amt(t_acct_raw_cost(i))) ;
          l_bc_pkt.entered_dr := 0;

	  -- R12 AP lines uptake : For reversing expneditures BRC and ind_compiled_set_id should be
	  -- copied from original expenditure

	  IF t_adjusted_expenditure_item_id(i) IS NOT NULL THEN
             l_bc_pkt.burdenable_raw_cost := -1 * t_burdenable_raw_cost(i) ;
          ELSE
	     l_bc_pkt.burdenable_raw_cost := NULL ;
          END IF;

          l_bc_pkt.effect_on_funds_code := 'I';
          l_fc_required := 'N';
          l_bc_pkt.document_type := 'EXP';
          l_bc_pkt.document_header_id := t_txn_interface_id(i);
          l_bc_pkt.document_distribution_id := 1;
          l_bc_pkt.actual_flag := 'A';

       end if;

          populate_bc_packets(l_bc_pkt);

          -- calculate the burdenable raw cost and update bc_packet entries.

          IF NVL( t_nz_adj_flag(i) , 'N') = 'N' then
		  if not gms_cost_plus_extn.update_bc_pkt_burden_raw_cost(g_packet_id, 'R') then
		     g_error_stage := 'Could not get burdenable raw cost..fail';
		     IF g_debug_context = 'Y' THEN
			gms_error_pkg.gms_debug ('Could not get burdenable raw cost..1', 'C');
		     END IF;
		     p_fck_return_code := -1;
		     p_fck_err_stage := 'F06';
		     commit;
		     return;
		  end if;
	  END IF ;

    END IF;

    -- this is for Std, Exp Report and Tax lines. check if the ind compiled set
    -- id is same if same, creating bucket switching bc packet entries.
    -- else create bc packet entries for fundschecking.

    -- Bug 3681990
    -- Prepayment invoice interfaced to grants without an ADLs.
    -- Prepayments not matching to PO and not discount and not prepayment application
    -- should fall under standard invoice category.
    --

    IF (  g_txn_source<> 'AP DISCOUNTS' AND
          g_xface_rec.line_type_lookup_code <> 'PREPAYMENT' AND
	  g_xface_rec.line_type_lookup_code <> 'PREPAY'  AND
          l_comm_fc_req <> 'N'
        ) THEN

       g_error_stage := 'Processing Std, ER, Tax lines..';
       -- if burden changed, we want to fundscheck the distributions. otherwise
       -- simply do a AP to EXP switch.

        -- R12 AP lines Uptake enhancement :
       --
       -- FC required only if :
       -- a. Burden multiplier has been modified for both cash based and accrual based
       --    accounting
       -- b. Payment mapped to an invoice has exchange rate variance
       -- c. For Cash based accounting if Invoice has been fully paid then no more
       --    adjustments will be performed against AP ,IN this case EXP should go thru
       --    Fundscheck.
       --
       -- If no FC required then switch amounts between AP and EXP buckets i.e.
       -- Put negative amount in AP bucket and put positive amounts in EXP bucket
       -- where ABS(+ve amt) = ABS(-ve amt).
       -- a. For cash based accounting payments are not FC'ed in payables ,only
       --    the corresponding invoice was FC'ed .Hence during payment interface and
       --    when there is no change in burden multipler
       --    relieve amount = payment amount against AP and create EXP's for payment amt.
       -- b. For accrual based accounting, when there is no change in burden multipler
       -- c. if the currenct txn record is a adjusting exp item i.e. adjusted_expenditure_item_id
       --    is not null
       -- d. If the txn records are net zero items i.e. both parent and reversal getting interfaced
       --    in same run.


	-- R12 AP lines uptake: IF its cash based accounting and payments are being interfaced
	-- then call local procedure to populate amount and BRC variables for paymenmts .
	-- IN R12,for cash based accounting historical invoices will be interfaced as
	-- invoice distributions itself and NOT the payments.

  	IF  (NVL(PA_TRX_IMPORT.G_cash_based_accounting,'N') = 'Y' AND
	     g_xface_rec.cdl_system_reference4 IS NOT NULL) THEN

	   CALCULATE_PAYTMENT_BRC (p_adl_fully_paid         => l_adl_fully_paid ,
                                   p_erv_found              => l_erv_found ,
				   p_cash_fc_required       => l_cash_fc_required,
				   p_apdist_amt_to_relieve  => l_apdist_amt_to_relieve,
                                   p_apdist_brc_to_relieve  => l_apdist_brc_to_relieve);
        END IF;

       -- Bug 4017468 : Added nvl function as there was no burden on AP lines.
       if nvl(l_new_compiled_set_id,0) = nvl(g_xface_rec.ind_compiled_set_id,0)
          OR t_adjusted_expenditure_item_id(i) IS NOT NULL
	  OR NVL( t_nz_adj_flag(i) , 'N') = 'Y'
	  OR ( NVL(l_cash_fc_required,'N') = 'N' AND g_xface_rec.cdl_system_reference4 IS NOT NULL) then

         g_error_stage := 'Indirect rate did not change..switch buckets';
         IF g_debug_context = 'Y' THEN
            gms_error_pkg.gms_debug (g_error_stage, 'C');
         END IF;

         IF NVL( t_nz_adj_flag(i) , 'N') = 'Y' then
            l_cmt_releived := 'N';
         END IF ;

         IF l_cmt_releived = 'N' THEN

          l_bc_pkt.ind_compiled_set_id           :=  g_xface_rec.ind_compiled_set_id;
	  l_bc_pkt.project_id                    :=  g_xface_rec.project_id;
          l_bc_pkt.award_id                      :=  g_xface_rec.award_id;
          l_bc_pkt.task_id                       :=  g_xface_rec.task_id;

          GET_BUD_TASK_DETAILS (l_bc_pkt.award_id,l_bc_pkt.project_id,l_bc_pkt.task_id);
          l_bc_pkt.bud_task_id                   :=  l_bud_task_id;
          l_bc_pkt.top_task_id                   :=  l_top_task_id;
          l_bc_pkt.budget_version_id             :=  l_budget_version_id;
	  -- giving credit to AP... Which is okay.
          l_bc_pkt.entered_cr := pa_currency.round_currency_amt(g_xface_rec.acct_raw_cost);
          l_bc_pkt.entered_dr := 0;
  	IF  (NVL(PA_TRX_IMPORT.G_cash_based_accounting,'N') = 'Y' AND
	     g_xface_rec.cdl_system_reference4 IS NOT NULL) THEN
	      l_bc_pkt.entered_cr          := l_apdist_amt_to_relieve;
	      l_bc_pkt.burdenable_raw_cost := -1 * l_apdist_brc_to_relieve;
          ELSE
              l_bc_pkt.burdenable_raw_cost := -1 * g_xface_rec.burdenable_raw_cost;
          END IF;
          l_bc_pkt.effect_on_funds_code := 'I';
	  -- Irrespective of amount sign fundscheck is not required as AP document has been
	  -- Fundschecked in Payables. --??
          l_fc_required := 'N';
          l_bc_pkt.document_type := 'AP';

          populate_bc_packets(l_bc_pkt);
          IF NVL( t_nz_adj_flag(i) , 'N') = 'Y' then
             l_cmt_releived := 'N';
	  ELSE
             l_cmt_releived := 'Y';
	  END IF ;

         END IF;

         l_bc_pkt.project_id                    :=  t_project_id(i);
         l_bc_pkt.award_id                      :=  t_award_id(i);
         l_bc_pkt.task_id                       :=  t_task_id(i);

         GET_BUD_TASK_DETAILS (l_bc_pkt.award_id,l_bc_pkt.project_id,l_bc_pkt.task_id);
         l_bc_pkt.bud_task_id                   :=  l_bud_task_id;
         l_bc_pkt.top_task_id                   :=  l_top_task_id;
         l_bc_pkt.budget_version_id             :=  l_budget_version_id;
	 l_bc_pkt.ind_compiled_set_id           :=  t_ind_compiled_set_id(i);
         l_bc_pkt.entered_dr                    :=  pa_currency.round_currency_amt(t_acct_raw_cost(i));
         l_bc_pkt.entered_cr                    :=  0;

	  -- R12 AP lines uptake : For reversing expneditures BRC and ind_compiled_set_id should be
	  -- copied from original expenditure

  	IF  (NVL(PA_TRX_IMPORT.G_cash_based_accounting,'N') = 'Y' AND
	     g_xface_rec.cdl_system_reference4 IS NOT NULL) THEN
	      l_bc_pkt.burdenable_raw_cost := l_apdist_brc_to_relieve;
          ELSE
	      -- Bug 5389130
	      IF  t_adjusted_expenditure_item_id(i) IS NOT NULL THEN
                 l_bc_pkt.burdenable_raw_cost :=  -1 * t_burdenable_raw_cost(i);
              ELSE
                 l_bc_pkt.burdenable_raw_cost :=  t_burdenable_raw_cost(i);
	      END IF;

          END IF;

         IF  t_adjusted_expenditure_item_id(i) IS NOT NULL THEN
	  IF t_acct_raw_cost(i) >0 THEN
             IF NVL( t_nz_adj_flag(i) , 'N') = 'Y' then
	        l_fc_required := 'N';
	     ELSE
	        l_fc_required := 'Y';
	     END IF ;
             l_bc_pkt.effect_on_funds_code := 'D';
          ELSE
             l_bc_pkt.document_type := 'EXP';
             l_bc_pkt.document_header_id := t_txn_interface_id(i);
             l_bc_pkt.document_distribution_id := 1;
             l_bc_pkt.effect_on_funds_code := 'I';
             l_bc_pkt.actual_flag := 'A';
	     /* Bug 5487306 : When we interface a reversing AP distribution , the original distribution of which is already interfaced
	        to Grants , then the burdenable raw cost for the reversing AP distribution is 0 but the burdenable raw cost for the
		expenditure (reversing the expenditure created for the original AP distribution) will be the negative of the
		burdenable raw cost for the expenditure created for the original AP distribution. So fundscheck is required in this
		scenario. */
             IF nvl(g_xface_rec.acct_raw_cost,0) < 0 AND
                nvl(g_xface_rec.burdenable_raw_cost,0) = 0 AND
                nvl(t_burdenable_raw_cost(i),0) <> 0 then
                l_fc_required := 'Y';
             ELSE
                l_fc_required := 'N';
             END IF;
          END IF;

          populate_bc_packets(l_bc_pkt);

          -- calculate the burdenable raw cost and update bc_packet entries.
          IF NVL( t_nz_adj_flag(i) , 'N') = 'N' then
		  if not gms_cost_plus_extn.update_bc_pkt_burden_raw_cost(g_packet_id, 'R') then
		     g_error_stage := 'Could not get burdenable raw cost..fail';
		     IF g_debug_context = 'Y' THEN
			gms_error_pkg.gms_debug ('Could not get burdenable raw cost..2', 'C');
		     END IF;

		     p_fck_return_code := -1;
		     p_fck_err_stage := 'F06';
		     commit;
		     return;
		  end if;
	  END IF ;

         ELSE
          l_bc_pkt.document_type := 'EXP';
          l_bc_pkt.document_header_id := t_txn_interface_id(i);
          l_bc_pkt.document_distribution_id := 1;
          l_bc_pkt.effect_on_funds_code := 'D';
          l_bc_pkt.actual_flag := 'A';
          l_fc_required := 'N';

          populate_bc_packets(l_bc_pkt);

         END IF;

          -- populate burden for both the raw lines.
          --populate_indirect_cost(g_packet_id); -- shifted outside the loop
	  IF g_debug_context = 'Y' THEN
	     gms_error_pkg.gms_debug ('Populated Invoice switching entries', 'C');
	  END IF;
          g_error_stage := 'Done with invoice switching entries';

       else -- ind compiled set id changed OR FC required for cash based accounting scenarios

        g_error_stage := 'Indirect Rate Changed..processing';
	if g_debug_context = 'Y' THEN
	     gms_error_pkg.gms_debug (g_error_stage, 'C');
	end if;

	-- Start of code for Commitment line record inserting in gms_bc_packets
	IF l_adl_fully_paid <> 'Y' THEN -- Will be YES for fully paid cash based accounting invoice

	  l_bc_pkt.project_id                    :=  g_xface_rec.project_id;
          l_bc_pkt.award_id                      :=  g_xface_rec.award_id;
          l_bc_pkt.task_id                       :=  g_xface_rec.task_id;

          GET_BUD_TASK_DETAILS (l_bc_pkt.award_id,l_bc_pkt.project_id,l_bc_pkt.task_id);
          l_bc_pkt.bud_task_id                   :=  l_bud_task_id;
          l_bc_pkt.top_task_id                   :=  l_top_task_id;
          l_bc_pkt.budget_version_id             :=  l_budget_version_id;

          -- For exchange rate Variance scenario,amount to be relieved for AP is different from acct_raw_cost
	  IF l_erv_found = 'Y' THEN
            IF l_apdist_amt_to_relieve >=0 THEN
               l_bc_pkt.entered_cr := pa_currency.round_currency_amt(l_apdist_amt_to_relieve);
               l_bc_pkt.entered_dr := 0;
	       l_bc_pkt.effect_on_funds_code := 'I';
            ELSE -- IF +ve amount being reserved against AP then calculate BRC.
               l_bc_pkt.entered_dr := pa_currency.round_currency_amt(ABS(l_apdist_amt_to_relieve));
               l_bc_pkt.entered_cr := 0;
	       l_bc_pkt.effect_on_funds_code := 'D';
            END IF;
	  ELSE
            l_bc_pkt.entered_cr := 0;
            l_bc_pkt.entered_dr := 0;
            l_bc_pkt.effect_on_funds_code := 'I';
          END IF;

  	IF  (NVL(PA_TRX_IMPORT.G_cash_based_accounting,'N') = 'Y' AND
	     g_xface_rec.cdl_system_reference4 IS NOT NULL) THEN
	        l_bc_pkt.burdenable_raw_cost := -1 * l_apdist_brc_to_relieve;
          ELSE
              l_bc_pkt.burdenable_raw_cost :=   -1 * g_xface_rec.burdenable_raw_cost;
          END IF;

          l_bc_pkt.actual_flag := 'E';
          l_bc_pkt.document_type := 'AP';

          populate_bc_packets(l_bc_pkt);

          -- calculate the burdenable raw cost if null
          if not gms_cost_plus_extn.update_bc_pkt_burden_raw_cost(g_packet_id, 'R') then
	        g_error_stage := 'Could not get burdenable raw cost..fail';
	        IF g_debug_context = 'Y' THEN
	   	   gms_error_pkg.gms_debug ('Could not get burdenable raw cost..2', 'C');
	        END IF;

	        p_fck_return_code := -1;
	        p_fck_err_stage := 'F06';
	        COMMIT;
	        RETURN;
          end if;

          -- Fetching BC packet Id associated with AP raw record inserted.
	  -- THis is used at later point to flip document_type ='EXP' for actual records
          OPEN  C_ap_bc_pkt_id(g_packet_id);
	  FETCH C_ap_bc_pkt_id INTO l_ap_bc_pkt_id;
	  CLOSE C_ap_bc_pkt_id;

        END IF ;

	-- End of code for Commitment line record insertion in gms_bc_packets

        -- Start of code for actual line record insertion in gms_bc_packets

          l_bc_pkt.project_id                    :=  t_project_id(i);
          l_bc_pkt.award_id                      :=  t_award_id(i);
          l_bc_pkt.task_id                       :=  t_task_id(i);

          GET_BUD_TASK_DETAILS (l_bc_pkt.award_id,l_bc_pkt.project_id,l_bc_pkt.task_id);
          l_bc_pkt.bud_task_id                   :=  l_bud_task_id;
          l_bc_pkt.top_task_id                   :=  l_top_task_id;
          l_bc_pkt.budget_version_id             :=  l_budget_version_id;
          -- populate the reversing entry. rest all entries are same as above.
          l_bc_pkt.ind_compiled_set_id := l_new_compiled_set_id;
          l_bc_pkt.actual_flag := 'A';

          -- For exchange rate Variance scenario,amount to be relieved for AP is different from acct_raw_cost
	  IF l_erv_found = 'Y' THEN
            IF g_xface_rec.acct_raw_cost >=0 THEN
               l_bc_pkt.entered_cr := pa_currency.round_currency_amt(g_xface_rec.acct_raw_cost);
               l_bc_pkt.entered_dr := 0;
	       l_bc_pkt.effect_on_funds_code := 'I';
            ELSE -- IF +ve amount being reserved against AP then calculate BRC.
               l_bc_pkt.entered_dr := pa_currency.round_currency_amt(ABS(g_xface_rec.acct_raw_cost));
               l_bc_pkt.entered_cr := 0;
	       l_bc_pkt.effect_on_funds_code := 'D';
            END IF;
	  ELSE
            l_bc_pkt.entered_cr := 0;
            l_bc_pkt.entered_dr := 0;
            l_bc_pkt.effect_on_funds_code := 'D';
          END IF;

  	IF  (NVL(PA_TRX_IMPORT.G_cash_based_accounting,'N') = 'Y' AND
	     g_xface_rec.cdl_system_reference4 IS NOT NULL) THEN
	        l_bc_pkt.burdenable_raw_cost := l_apdist_brc_to_relieve;
          ELSE
              l_bc_pkt.burdenable_raw_cost :=   t_burdenable_raw_cost(i);
          END IF;

          populate_bc_packets(l_bc_pkt);

          l_fc_required := 'Y';
          -- call FC.
	  IF g_debug_context = 'Y' THEN
	     gms_error_pkg.gms_debug ('Populated Invoice data for fundscheck', 'C');
	  END IF;
	  g_error_stage := 'Populated invoice data for fundscheck';

	  -- calculate the burdenable raw cost and update bc_packet entries.
          if not gms_cost_plus_extn.update_bc_pkt_burden_raw_cost(g_packet_id, 'R') then
	        g_error_stage := 'Could not get burdenable raw cost..fail';
	        IF g_debug_context = 'Y' THEN
	   	   gms_error_pkg.gms_debug ('Could not get burdenable raw cost..2', 'C');
	        END IF;

	        p_fck_return_code := -1;
	        p_fck_err_stage := 'F06';
	        COMMIT;
	        RETURN;
          end if;
         -- End of code for actual line record insertion in gms_bc_packets
       end if;

    end if; -- source and line type check

   END LOOP;

    if l_fc_required = 'N' then

       populate_indirect_cost(g_packet_id);

       g_error_stage := 'Calling setup_rlmi for non-fundschecked txns.';
       IF g_debug_context = 'Y' THEN
         gms_error_pkg.gms_debug(g_process||':' || g_error_stage, 'C');
       END IF;
       gms_funds_control_pkg.setup_rlmi(g_packet_id, 'R', l_err_code, l_err_buf);

       g_error_stage := 'Calling update top task and parent resource for non-FCd txns';
       IF g_debug_context = 'Y' THEN
         gms_error_pkg.gms_debug(g_process||':' || g_error_stage, 'C');
       END IF;
       gms_cost_plus_extn.update_top_tsk_par_res(g_packet_id);

       g_error_stage := 'Populate Arrival Order Sequence Order table';
       IF g_debug_context = 'Y' THEN
         gms_error_pkg.gms_debug(g_process||':' || g_error_stage, 'C');
       END IF;
       Insert_Arrival_Order_Seq(g_packet_id, 'R');

       g_error_stage := 'Update the status and results codes for non-fcd txns';
       IF g_debug_context = 'Y' THEN
         gms_error_pkg.gms_debug(g_process||':' || g_error_stage, 'C');
       END IF;
       update gms_bc_packets gbc
          set gbc.result_code = 'P76',
              gbc.award_result_code = 'P76',
              gbc.top_task_result_code = 'P76',
              gbc.task_result_code = 'P76',
              gbc.res_grp_result_code = 'P76',
              gbc.res_result_code = 'P76'
        where gbc.packet_id = g_packet_id
          and nvl(result_code, 'P76') like 'P%';


       p_fck_return_code := 0;

       commit;

       return;

    else

       populate_concurrency_table(l_system_linkage);

       commit;

      p_fck_return_code := 0;

      if NOT gms_funds_control_pkg.gms_fck (x_sobid         =>   g_set_of_books_id,
                                            x_packetid      =>   g_packet_id,
                                            x_mode          =>   l_fc_mode,
                                            x_override      =>   'N',
                                            x_partial       =>   l_partial_mode,
                                            x_user_id       =>   fnd_global.user_id,
                                            x_user_resp_id  =>   fnd_global.resp_id,
                                            x_execute       =>   'Y',
                                            x_return_code   =>   l_return_code,
                                            x_e_code        =>   l_err_code,
                                            x_e_stage       =>   l_err_buf) THEN

          g_error_stage := 'Execute FundsCheck : ' || p_fck_err_stage ;

           IF g_debug_context = 'Y' THEN
              gms_error_pkg.gms_debug ('Fundscheck returned error..2', 'C');
              gms_error_pkg.gms_debug ('Error : ' || l_err_code || ' Stage : ' || l_err_buf, 'C');
           END IF;
          -- Set the error codes and related information exit.

          p_fck_return_code := -1;
          p_fck_err_code := l_err_code;
          p_fck_err_stage := l_err_buf;

          commit;

          return;

      end if;

       -- if fundscheck succeeds then switch the document.
       -- For lines getting switched to EXP, we populate with
       -- transaction interface id.

       g_error_stage := 'Updating Fundschecked txns with EXP doc type';
       IF g_debug_context = 'Y' THEN
         gms_error_pkg.gms_debug(g_process||':' || g_error_stage, 'C');
       END IF;

       --
       -- Bug : 3603121
       -- PO matched PREPAYMENT should gets funds check during the interface to
       -- grants accounting.
       --
       -- Psuedo-code for update below :
       -- if distribution is never fundschecked in AP then there will be
       --    a single set of records which can be switched to 'EXP'. Those identified are
       --    'AP DISCOUNTS', 'PREPAY' (distribution for applied prepayment)
       --     and PREPAYMENT matched to PO.
       -- else
       --    there will be reversing pairs for AP and EXP. update
       --    them using new ind_compiled_set_id.
       -- end if;

       IF ( (g_txn_source = 'AP DISCOUNTS' OR
             g_xface_rec.line_type_lookup_code = 'PREPAYMENT' OR
	     g_xface_rec.line_type_lookup_code = 'PREPAY' ) AND
             l_comm_fc_req = 'N'
          ) THEN

          update gms_bc_packets
             set document_header_id = txn_interface_id,
                 document_distribution_id = 1,
                 document_type = 'EXP',
                 actual_flag = 'A'
           where packet_id = g_packet_id;

       --else -- for all other fc'd txns
       ELSIF l_adj_ei_populated ='Y' THEN

          update gms_bc_packets
             set document_header_id = txn_interface_id,
                 document_distribution_id = 1,
                 document_type = 'EXP',
                 actual_flag = 'A'
           where packet_id = g_packet_id
	     AND effect_on_funds_code = 'D';

       else -- ind compiled set id donot match

	  -- Update bc records where entered_dr <>0 OR entered_cr <> 0
	  -- This update is for payment with exchange rate variance in cash based accounting ,
          update gms_bc_packets
             set document_header_id = txn_interface_id,
                 document_distribution_id = 1,
                 document_type = 'EXP',
                 actual_flag = 'A'
           where packet_id = g_packet_id
	     AND bc_packet_id NOT IN  (SELECT l_ap_bc_pkt_id
	                                 FROM DUAL
				       UNION ALL
				       SELECT bc_packet_id
	                                 FROM gms_bc_packets
                                        WHERE parent_bc_packet_id = l_ap_bc_pkt_id
					  AND packet_id = g_packet_id )
             AND (entered_dr <> 0 OR entered_cr <>0 ) ;

          -- update switching raw record to correct doc type and raw cost.
          update gms_bc_packets
             set document_header_id = txn_interface_id,
                 document_distribution_id = 1,
                 document_type = 'EXP',
                 entered_dr = decode(sign(g_xface_rec.acct_raw_cost),
                                         1, g_xface_rec.acct_raw_cost, 0),
                 entered_cr = decode(sign(g_xface_rec.acct_raw_cost),
                                        -1, abs(g_xface_rec.acct_raw_cost), 0)
           where packet_id = g_packet_id
             and ind_compiled_set_id = l_new_compiled_set_id
             and parent_bc_packet_id is null
             and document_type = 'AP'
             and nvl(burden_adjustment_flag, 'N') = 'N'
             AND entered_dr = 0
	     AND entered_cr = 0 ;

          --
          -- update switching burden record to correct doc type.
          g_error_stage := 'Updating burden record to EXP';
          IF g_debug_context = 'Y' THEN
            gms_error_pkg.gms_debug(g_process||':' || g_error_stage, 'C');
          END IF;

	  -- bug : 3612707 incorrect actuals in funds check burdenable cost.
	  -- bug : 3607250 burdenable cost -ve
          update gms_bc_packets
             set document_type = 'EXP',
                 document_header_id = txn_interface_id,
                 document_distribution_id = 1
           where packet_id = g_packet_id
             and document_type  = 'AP'
	     and parent_bc_packet_id in ( select a.bc_packet_id
			                    from gms_bc_packets a
			                   where a.ind_compiled_set_id =  l_new_compiled_set_id
				             and a.document_type = 'EXP'
				             and a.packet_id = g_packet_id )

             AND entered_dr = 0
	     AND entered_cr = 0 ;

          --
          -- update the reversing AP line with raw cost
          g_error_stage := 'Updating raw cost on reversing AP line';
          IF g_debug_context = 'Y' THEN
            gms_error_pkg.gms_debug(g_process||':' || g_error_stage, 'C');
          END IF;

          update gms_bc_packets
             set entered_dr = decode(sign(g_xface_rec.acct_raw_cost),
                                     -1, abs(g_xface_rec.acct_raw_cost), 0),
                 entered_cr = decode(sign(g_xface_rec.acct_raw_cost),
                                      1, g_xface_rec.acct_raw_cost, 0)
           where packet_id = g_packet_id
             and ind_compiled_set_id = g_xface_rec.ind_compiled_set_id
             and document_type = 'AP'
             and parent_bc_packet_id is null
             and nvl(burden_adjustment_flag, 'N') = 'N'
             AND entered_dr = 0
	     AND entered_cr = 0 ;

       end if;

    end if; -- l_fc_required = 'Y'

    commit;

    return;

  end if; -- g_process := 'Interface'

End Execute_FundsCheck;

-------------------------------------------------------------------------------
-- Procedure to populate gms_bc_packets table. This procedure is called from
-- Costing fundscheck process.
-------------------------------------------------------------------------------

Procedure Populate_BC_Packets is

l_je_source	    varchar2(30);
l_je_category	varchar2(30);
l_doc_type	    varchar2(3);
l_actual_flag	varchar2(1);
l_status_code   varchar2(1);

begin
    g_error_stage := 'In Populate_BC_Packets for Exp Items';

     l_je_source := 'Projects Accounting';
     l_doc_type := 'EXP';
     l_actual_flag := 'A';
     l_status_code := 'P';

     g_error_stage := 'Populating BC packets with costing data for FC';
     forall i in t_document_header_id.FIRST..t_document_header_id.LAST
     insert into gms_bc_packets(
                 packet_id,
                 project_id,
                 award_id,
                 task_id,
                 expenditure_type,
                 expenditure_item_date,
                 actual_flag,
                 status_code,
                 transfered_flag,
                 last_update_date,
                 last_updated_by,
                 created_by,
                 creation_date,
                 last_update_login,
                 set_of_books_id,
                 je_category_name,
                 je_source_name,
                 document_type,
                 ind_compiled_set_id,
                 expenditure_organization_id,
                 document_header_id,
                 document_distribution_id,
                 entered_dr,
                 entered_cr,
                 bc_packet_id,
                 request_id,
                 person_id,
                 job_id,
                 expenditure_category,
                 revenue_category,
                 adjusted_document_header_id,
                 award_set_id,
                 transaction_source,
		 burdenable_raw_cost   --R12 AP lines uptake :Forward port bug 4217161
		 ) values
                (
                 g_packet_id,
                 t_project_id(i),
                 t_award_id(i),
                 t_task_id(i),
                 t_expenditure_type(i),
                 t_expenditure_item_date(i),
                 l_actual_flag,
                 l_status_code,
                 'N',
                 l_last_update,
                 fnd_global.user_id,
                 fnd_global.user_id,
                 l_last_update,
                 fnd_global.login_id,
                 g_set_of_books_id,
		 decode(t_system_linkage_function(i),
		        'OT', 'Labor Cost',
                        'ST', 'Labor Cost',
                        'ER', 'Purchase Invoices',
                        'VI', 'Purchase Invoices',
                        'USG', 'Usage Cost',
                        'INV', 'Inventory',
                        'PJ',  'Miscellaneous Transaction',
                        'WIP', 'WIP'),
                 l_je_source,
                 l_doc_type,
                 t_ind_compiled_set_id(i),
                 t_expenditure_organization_id(i),
                 t_document_header_id(i),
                 t_document_distribution_id(i),
                 t_entered_dr(i),
                 t_entered_cr(i),
                 gms_bc_packets_s.nextval,
                 g_request_id,
                 t_person_id(i),
                 t_job_id(i),
                 t_expenditure_category(i),
                 t_revenue_category(i),
                 t_adjusted_document_header_id(i),
                 t_award_set_id(i),
                 t_transaction_source(i),
 	         t_burdenable_raw_cost(i) ); --R12 AP lines uptake :Forward port bug 4217161);

     IF g_debug_context = 'Y' THEN
        gms_error_pkg.gms_debug ('Populated gms_bc_packets with costing data for FC', 'C');
     END IF;

end Populate_BC_Packets;

-------------------------------------------------------------------------------
-- Procedure to populate gms_bc_packets table for the given packet.
-- This procedure is called for Supplier interface process.
-------------------------------------------------------------------------------
Procedure Populate_BC_Packets(p_bc_pkt  IN gms_bc_packets%ROWTYPE) is

PRAGMA AUTONOMOUS_TRANSACTION; -- Bug 5474308

begin
    g_error_stage := 'In Populate_BC_Packets for Interface data';

     INSERT into gms_bc_packets ( packet_id,
                                  bc_packet_id,
                                  document_header_id,
                                  document_distribution_id,
                                  Document_type,
                                  project_id,
                                  task_id,
                                  award_id,
                                  expenditure_type,
                                  expenditure_item_date,
                                  expenditure_organization_id,
                                  bud_task_id,
				  top_task_id,
                                  entered_dr,
                                  entered_cr,
                                  budget_version_id,
                                  burdenable_raw_cost,
                                  actual_flag,
                                  status_code,
                                  set_of_books_id,
                                  je_category_name,
                                  je_source_name,
                                  transfered_flag,
                                  status_flag,
                                  result_code,
                                  request_id ,
				  ind_compiled_set_id,
				  effect_on_funds_code,
                                  last_update_date,
                                  last_updated_by,
                                  created_by,
                                  creation_date,
                                  last_update_login,
				  gl_bc_packets_rowid,
                                  vendor_id,
                                  expenditure_category,    --Bug: 5003642
                                  revenue_category) values --Bug: 5003642
                                 (p_bc_pkt.packet_id,
                                  gms_bc_packets_s.nextval,
                                  p_bc_pkt.document_header_id,
                                  p_bc_pkt.document_distribution_id,
                                  p_bc_pkt.Document_type,
                                  p_bc_pkt.project_id,
                                  p_bc_pkt.task_id,
                                  p_bc_pkt.award_id,
                                  p_bc_pkt.expenditure_type,
                                  p_bc_pkt.expenditure_item_date,
                                  p_bc_pkt.expenditure_organization_id,
                                  p_bc_pkt.bud_task_id,
				  p_bc_pkt.top_task_id,
                                  p_bc_pkt.entered_dr,
                                  p_bc_pkt.entered_cr,
                                  p_bc_pkt.budget_version_id,
                                  p_bc_pkt.burdenable_raw_cost,
                                  p_bc_pkt.actual_flag,
                                  p_bc_pkt.status_code,
                                  p_bc_pkt.set_of_books_id,
                                  p_bc_pkt.je_category_name,
                                  p_bc_pkt.je_source_name,
                                  p_bc_pkt.transfered_flag,
                                  p_bc_pkt.status_flag,
                                  p_bc_pkt.result_code,
                                  p_bc_pkt.request_id,
				  p_bc_pkt.ind_compiled_set_id,
				  p_bc_pkt.effect_on_funds_code,
                                  l_last_update,
                                  fnd_global.user_id,
                                  fnd_global.user_id,
                                  l_last_update,
                                  fnd_global.login_id,
				  p_bc_pkt.gl_bc_packets_rowid,
                                  p_bc_pkt.vendor_id,
                                  p_bc_pkt.expenditure_category, --Bug: 5003642
                                  p_bc_pkt.revenue_category);    --Bug: 5003642

      IF g_debug_context = 'Y' THEN
         gms_error_pkg.gms_debug ('Populated BC packets with interface data for FC', 'C');
      END IF;

      COMMIT;

end Populate_BC_Packets;

-------------------------------------------------------------------------------
-- This procedure checks for adjusting and adjusted expenditure items.
-- If they are balanced, then they are marked as successful.
-- If they are not mark them as failed.
-------------------------------------------------------------------------------
Procedure Handle_net_zero_txn(p_packetid IN number, p_mode IN varchar2 ) is

Cursor c_txn is
    select adjusted_document_header_id,
           nvl(ind_compiled_set_id,-1) ind_compiled_set_id
    from   gms_bc_packets
    where  packet_id = p_packetid
    having sum(entered_dr-entered_cr) = 0
    group by  adjusted_document_header_id,
                    nvl(ind_compiled_set_id,-1);
Begin

    g_error_stage := 'In Handle Net Zero Procedure';
    if g_debug_context = 'Y' then
      	gms_error_pkg.gms_debug ( 'Handle_net_zero_txn : Start','C');
      	gms_error_pkg.gms_debug ( 'p_mode : '||p_mode,'C');
    end if;

If p_mode = 'Check_Adjusted' then

   -- Fail adjusting txn. If adjusted has not been funds checked -F08
   IF g_debug_context = 'Y' THEN
      gms_error_pkg.gms_debug ('Fail adjusting txn if adjusted is not FCd', 'C');
   END IF;

   update gms_bc_packets gbc
     set  gbc.result_code = 'F08',
	      gbc.award_result_code = 'F08',
	      gbc.top_task_result_code = 'F08',
	      gbc.task_result_code = 'F08',
	      gbc.res_grp_result_code = 'F08',
	      gbc.res_result_code = 'F08',
          gbc.status_code = 'R'
   where  gbc.packet_id = p_packetid
     and  nvl(gbc.result_code,'XX') <> 'P82'
     and  gbc.adjusted_document_header_id is NOT NULL
     and  gbc. adjusted_document_header_id <> gbc.document_header_id
     and  exists
            (select 1
               from gms_award_distributions adl
              where adl.expenditure_item_id =   gbc.adjusted_document_header_id
                and nvl(adl.fc_status, 'N') = 'N'
                and adl.adl_status = 'A'
                and nvl(adl.request_id,-1)  <>  gbc.request_id
             ) ;

Elsif p_mode = 'Net_Zero' then

 -- Adjusted and adjusting in same packet

    g_error_stage := 'In Handle_Net_Zero...Net_Zero mode';
for recs in c_txn
 loop

     update gms_bc_packets gbc
        set gbc.result_code = 'P82',
 	        gbc.award_result_code = 'P82',
	        gbc.top_task_result_code = 'P82',
	        gbc.task_result_code = 'P82',
	        gbc.res_grp_result_code = 'P82',
	        gbc.res_result_code = 'P82',
            gbc.effect_on_funds_code = 'I'
     where  gbc.packet_id = p_packetid
     and    gbc.adjusted_document_header_id = recs.adjusted_document_header_id /* bug 3604195 */
     and    nvl(gbc.ind_compiled_set_id,-1) =  recs.ind_compiled_set_id;


end loop;

   if g_debug_context = 'Y' then
     gms_error_pkg.gms_debug ( 'Handle_net_zero_txn : End','C');
   end if;

End If;

End Handle_net_zero_txn;

-------------------------------------------------------------------------------
-- Procedure to insert record into concurrency table.
-------------------------------------------------------------------------------
Procedure Populate_Concurrency_Table (p_system_linkage  IN  VARCHAR2)  IS
l_exists	varchar2(1);
Begin

   g_error_stage := 'Populate concurrency table...';
 begin
   select '1'
     into l_exists
     from dual
    where exists (select '1' from gms_concurrency_control
                   where process_name = 'GMSFCSYS'
                     and request_id = g_request_id);
 exception
   when no_data_found then

     insert into gms_concurrency_control
     (PROCESS_NAME,
      PROCESS_KEY ,
      REQUEST_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATED_BY ,
      CREATION_DATE,
      LAST_UPDATE_LOGIN )
     values('GMSFCSYS',
            DECODE(p_system_linkage,
                         'ST',   1,
                         'USG',  2,
                         'ER',   3,
                         'VI',   4),
    	    g_request_id,
            sysdate,
            fnd_global.user_id,
    	    fnd_global.user_id,
    	    sysdate,
    	    fnd_global.login_id
           );

 end;

    g_error_stage := 'Populate concurrency table..end';
    IF g_debug_context = 'Y' THEN
       gms_error_pkg.gms_debug ('Populated concurrency table..end', 'C');
    END IF;
Exception
    When others then
      RAISE;
End Populate_Concurrency_Table;

-------------------------------------------------------------------------------
-- Procedure to mark expenditure items as failed.
-------------------------------------------------------------------------------
Procedure Mark_ExpItem_As_Failed is

  cursor get_failed_exps is
  select distinct document_header_id,
         result_code
    from gms_bc_packets gbc
   where packet_id = g_packet_id
     and substr(nvl(result_code, 'P75'), 1, 1) = 'F'
     and result_code not in ('F75', 'F63')
     and document_type = 'EXP';

  fc_expenditure_item_id	tt_document_header_id;

  TYPE tt_result_code is table of gms_bc_packets.result_code%TYPE;
  fc_result_code		tt_result_code;

Begin
    g_error_stage := 'In Mark_ExpItem_As_Failed';
    IF g_debug_context = 'Y' THEN
      gms_error_pkg.gms_debug (g_error_stage, 'C');
    END IF;

    open get_failed_exps;
    fetch get_failed_exps bulk collect into fc_expenditure_item_id,
                                            fc_result_code;

    close get_failed_exps;

    if fc_expenditure_item_id.count = 0 then
       return;
    end if;

    forall i in fc_expenditure_item_id.FIRST..fc_expenditure_item_id.LAST
      update pa_expenditure_items
         set cost_distributed_flag = decode(cost_distributed_flag,'Y','N',cost_distributed_flag),
	    cost_dist_rejection_code = fc_result_code(i) /*Added for bug 7047986 */
	    							/* decode(fc_result_code(i),  -- Commented for bug 7047986
                                          'F10','F143',
                                          'F90','F10',
                                          'F91','F110',
                                          'F92','F108',
                                          'F93','F109',
                                          'F60','F111',
                                          'F12','F118',
                                          'F89','F142',
                                          'F15','F01',
                                          'F16','F122',
                                          'F17','F122',
                                          'F18','F02',
                                          'F19','F03',
                                          'F21','F04',
                                          'F13','F128',
                                          'F14','F128',
                                          'F94','F128',
                                          'F67','F05',
                                          'F73','F05',
                                          'F78','F05',
                                          'F79','F05',
                                          'F95','F05',
                                          'F40','F06',
                                          'F44','F06',
                                          'F45','F06',
                                          'F46','F06',
                                          'F47','F06',
                                          'F48','F06',
                                          'F49','F06',
                                          'F76','F06',
                                          'F50','F07',
                                          'F51','F07',
                                          'F52','F07',
                                          'F53','F07',
                                          'F54','F07',
                                          fc_result_code(i)) */ -- Mapping GMS to PA code
       where expenditure_item_id = fc_expenditure_item_id(i)
         and request_id = g_request_id;

    forall i in fc_expenditure_item_id.FIRST..fc_expenditure_item_id.LAST
      delete from pa_cost_distribution_lines
       where expenditure_item_id = fc_expenditure_item_id(i)
         and request_id = g_request_id
         and line_num in (select document_distribution_id
                            from gms_bc_packets
                           where document_header_id = fc_expenditure_item_id(i)
                             and packet_id = g_packet_id
                             and parent_bc_packet_id is null
                             and document_type = 'EXP');

      IF g_debug_context = 'Y' THEN
         gms_error_pkg.gms_debug ('Updating reversed flag on CDLs..in mark exp item as failed', 'C');
      END IF;

    forall i in fc_expenditure_item_id.FIRST..fc_expenditure_item_id.LAST
      update pa_cost_distribution_lines
         set reversed_flag = NULL
       where expenditure_item_id = fc_expenditure_item_id(i)
         and nvl(reversed_flag, 'N') = 'Y'
         and request_id = g_request_id;

    -- Initialize pl/sql table ..
    fc_expenditure_item_id.delete;
    fc_result_code.delete;


    IF g_debug_context = 'Y' THEN
      gms_error_pkg.gms_debug ('End Mark_ExpItem_As_Failed', 'C');
    END IF;

END Mark_ExpItem_As_Failed;

-------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
-- This Procedure inserts record in gms_bc_packet_arrival_order, once record is
-- inserted lock is released.
-- from gms_concurrency_control using COMMIT;

--  gms_bc_packet_arrival_order Table will store the order in which packets
--  have completed there setup and are ready for funds check.
--  This is required becase packets arrived later can pass fundscheck as setup
--  has not been completed for large packets arrived before.
----------------------------------------------------------------------------------------------------------


   PROCEDURE insert_arrival_order_seq (x_packetid  IN  NUMBER,
                                       x_mode      IN  VARCHAR2) IS

	  x_err_code   			NUMBER;
	  x_arrival_order_seq           NUMBER;

   BEGIN

     g_error_stage := 'insert_arrival_order_seq';

/* Exception handling as part of bug 7364172, this exception handling is ideally not
   required, because following select statement should always return records. However,
   considering the cst. case, doing the exception handling */
   begin
    SELECT 0
      INTO x_err_code
      FROM gms_concurrency_control
     WHERE process_name = 'GMSFCTRL'
       FOR UPDATE;
   exception
      when no_data_found then
         insert into gms_concurrency_control
            (PROCESS_NAME,
             PROCESS_KEY ,
             REQUEST_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATED_BY ,
             CREATION_DATE,
             LAST_UPDATE_LOGIN )
         values('GMSFCTRL',
                0,
                0,
                sysdate,
                -1,
                -1,
                sysdate,
                -1
                );
   end;  -- end changes for bug 7364172

    SELECT gms_bc_packet_arrival_order_s.NEXTVAL
      INTO x_arrival_order_seq
      FROM DUAL;

    g_error_stage := 'IN ARRIVAL ORD: INSRT';

    INSERT INTO gms_bc_packet_arrival_order
                (packet_id,
                 arrival_seq,
                 last_update_date,
                 last_updated_by)
         VALUES (x_packetid,
                 x_arrival_order_seq,
                 SYSDATE,
                 fnd_global.user_id);

   END insert_arrival_order_seq;

-------------------------------------------------------------------------------
-- This procedure is called from Projects Costing processes. It is called
-- after Projects is done with their TieBack process.
-- Parameters :
--             p_request_id    : Request ID of the calling process
--             p_return_status : 0 if successful, -1 if any exception occurs.
--             p_error_code    : error code sent back if an exception occurs
--             p_error_stage   : Stage where the error/exception occured.
-------------------------------------------------------------------------------
---
Procedure FundsCheck_TieBack (p_request_id    IN  NUMBER,
                              p_return_status OUT NOCOPY NUMBER,
                              p_error_code    OUT NOCOPY VARCHAR2,
                              p_error_stage   OUT NOCOPY NUMBER) is
begin

  g_error_stage := 'FundsCheck_TieBack: ';

  if not gms_cost_plus_extn.update_source_burden_raw_cost(g_packet_id, 'R', 'Y') then
      p_return_status := -1;

      g_error_stage := 'Update Source Burden Raw Cost failed..rollback';
      IF g_debug_context = 'Y' THEN
        gms_error_pkg.gms_debug (g_error_stage, 'C');
      END IF;

      return;
  end if;

  g_error_stage := 'Calling update_gms_bc_packets from FundsCheck_TieBack';
  IF g_debug_context = 'Y' THEN
    gms_error_pkg.gms_debug (g_error_stage, 'C');
  END IF;

  update_gms_bc_packets(g_process, g_request_id);

  g_error_stage := 'Calling Create_ADLs from FundsCheck_TieBack';
  IF g_debug_context = 'Y' THEN
    gms_error_pkg.gms_debug (g_error_stage, 'C');
  END IF;

  -- Note: Do not change the order of create_adls and update_gms_bc_packets ...
  create_adls(g_process, g_request_id);

  g_error_stage := 'Calling Delete_concurrency_records from FundsCheck_TieBack';
  IF g_debug_context = 'Y' THEN
    gms_error_pkg.gms_debug (g_error_stage, 'C');
  END IF;

  delete_concurrency_records;

  p_return_status := 0;
  return;

end FundsCheck_TieBack;

-------------------------------------------------------------------------------
-- Procedure to update the status of transactions in gms_bc_packets.
-- Parameters :
--            p_process : 'Costing' or 'Interface'.
--            p_request_id : Request ID of the calling process.
--
-- Notes:
--    For Costing related transactions, we do the following :
--       Update status_code in gms_bc_packets to Accepted or Rejected.
--
--    For Interface related transactions, we do the following :
--       Txn_Interface_ID is updated on gms_bc_packets.document_header_id
--       after Fundscheck is done. This is done so that we know which
--       transactions are created for 'EXP' document type. Now, we update
--       document_header_id with expenditure_item_id by joining with
--       txn_interface_id.
-------------------------------------------------------------------------------
---
  Procedure Update_GMS_BC_Packets(p_process IN VARCHAR2,
                                  p_request_id IN NUMBER) is
  Begin
    g_error_stage := 'Update_GMS_BC_Packets...start';
    IF g_debug_context = 'Y' THEN
      gms_error_pkg.gms_debug ('Update GMS BC Packets start..', 'C');
    END IF;

    -- If this procedure is called from interface then we need to use
    -- request_id for update ...
    If p_process = 'Interface' then
      update gms_bc_packets
         set status_code = decode(substr(nvl(result_code, 'F65'), 1, 1),
                                'P', 'A',
                                'R')
     where request_id = p_request_id
       and status_code = 'P';
    Else
      -- costing, use g_packet_id for update ..
      update gms_bc_packets
         set status_code = decode(substr(nvl(result_code, 'F65'), 1, 1),
                                'P', 'A',
                                'R')
     where packet_id = g_packet_id
       and status_code = 'P';
    End If;

   IF g_debug_context = 'Y' THEN
     gms_error_pkg.gms_debug ('Update_GMS_BC_Packets...end', 'C');
   END IF;

  End Update_GMS_BC_Packets;

-------------------------------------------------------------------------------
-- Procedure to create ADLs for the transactions that passed fundscheck.
-- Parameters :
--            p_process    : 'Costing' or 'Interface'.
--            p_request_id : Request ID of the calling process.
-------------------------------------------------------------------------------
  Procedure Create_ADLs(p_process IN VARCHAR2,
                        p_request_id IN NUMBER) is

   cursor reversed_cur is
   select cdl.expenditure_item_id, cdl.line_num
     from pa_cost_distribution_lines cdl,
          --pa_expenditure_items_all exp,
	  gms_bc_packets gbc
    where gbc.packet_id = g_packet_id
      and gbc.parent_bc_packet_id is null
      and gbc.status_code = 'A'
      --and exp.expenditure_item_id = gbc.document_header_id
      and cdl.expenditure_item_id = gbc.document_header_id
      and cdl.request_id + 0      = p_request_id
      and mod(gbc.document_distribution_id,2) = 0
      --and exp.cost_distributed_flag = 'Y'
      and cdl.reversed_flag = 'Y';

     Type tab_billable_flag is table of pa_cost_distribution_lines_all.billable_flag%TYPE;
     Type tab_line_num is table of pa_cost_distribution_lines_all.line_num%TYPE;
     Type tab_rlmi is table of gms_bc_packets.resource_list_member_id%TYPE;
     Type tab_bud_task_id is table of gms_bc_packets.bud_task_id%TYPE;
     Type tab_status_code is table of gms_bc_packets.status_code%TYPE;
     Type tab_row_id is table of varchar2(30);

     v_ind_compiled_set_id		tt_ind_compiled_set_id;
     v_billable_flag		        tab_billable_flag;
     v_line_num			        tab_line_num;
     v_expenditure_item_id		tt_document_header_id;
     v_rlmi				tab_rlmi;
     v_bud_task_id			tab_bud_task_id;
     v_raw_cost			        tt_entered_dr;
     v_status_code			tab_status_code;
     v_burdenable_raw_cost              tt_burdenable_raw_cost; -- defined in package spec
     v_rowid			        tab_row_id;
     v_exp_item_id                      tt_document_header_id;
     v_cdl_line_num                     tab_line_num;

  cursor get_xface_exp is
   select gbc.rowid, txn.expenditure_item_id
     from pa_transaction_interface_all txn, gms_bc_packets gbc
    where gbc.request_id = p_request_id
      and txn.txn_interface_id = gbc.document_header_id
      and nvl(txn.transaction_status_code, 'Z') <> 'R'
      and gbc.status_code = 'P'
      and substr(nvl(result_code, 'F'), 1, 1) = 'P'
      and gbc.document_type = 'EXP';

  cursor first_adls is
   select gbc.document_header_id,
          gbc.document_distribution_id,
          cdl.billable_flag,
          gbc.resource_list_member_id,
          gbc.bud_task_id,
          nvl(gbc.entered_dr, 0) - nvl(gbc.entered_cr, 0) raw_cost,
          gbc.status_code,
          gbc.ind_compiled_set_id,
	  gbc.burdenable_raw_cost
     from gms_bc_packets gbc,
          pa_cost_distribution_lines cdl
    where gbc.packet_id = g_packet_id
      and gbc.document_header_id = cdl.expenditure_item_id
      and gbc.document_distribution_id = cdl.line_num
      and gbc.document_distribution_id = 1
      and gbc.parent_bc_packet_id is null
      and gbc.status_code = 'A';

    --Variables used in insert ..
   v_login   number;
   v_userid  number;
   v_date    date;

  Begin
    g_error_stage := 'Create_ADLs...start';
    IF g_debug_context = 'Y' THEN
      gms_error_pkg.gms_debug (g_error_stage, 'C');
    END IF;
    --Variables used in insert ..
    v_login   := fnd_global.login_id;
    v_date    := sysdate;
    v_userid  := fnd_global.user_id;

    if (p_process = 'Costing') then

       open first_adls;
       fetch first_adls bulk collect into v_expenditure_item_id, v_line_num,
                        v_billable_flag, v_rlmi, v_bud_task_id, v_raw_cost,
                        v_status_code, v_ind_compiled_set_id,v_burdenable_raw_cost;
       close first_adls;

       if v_expenditure_item_id.count > 0 then

        forall i in v_expenditure_item_id.FIRST..v_expenditure_item_id.LAST

         update gms_award_distributions
            set ind_compiled_set_id     = v_ind_compiled_set_id(i),
                billable_flag           = v_billable_flag(i),
                cdl_line_num            = v_line_num(i),
                cost_distributed_flag   = 'Y',
                resource_list_member_id = v_rlmi(i),
                bud_task_id             = v_bud_task_id(i),
                raw_cost                = v_raw_cost(i),
                fc_status               = v_status_code(i),
		burdenable_raw_cost    = v_burdenable_raw_cost(i)
          where expenditure_item_id = v_expenditure_item_id(i)
            and adl_status = 'A'
            and fc_status = 'N'
            and nvl(cdl_line_num,1) = 1;

       end if;

       insert into gms_award_distributions(
				AWARD_SET_ID,
				ADL_LINE_NUM,
				DISTRIBUTION_VALUE,
				RAW_COST,
				DOCUMENT_TYPE,
				PROJECT_ID,
				TASK_ID,
				AWARD_ID,
				EXPENDITURE_ITEM_ID,
				CDL_LINE_NUM,
				IND_COMPILED_SET_ID,
				REQUEST_ID,
				LINE_NUM_REVERSED,
				RESOURCE_LIST_MEMBER_ID,
				ADL_STATUS,
				FC_STATUS,
				LINE_TYPE,
				CAPITALIZED_FLAG,
				REVERSED_FLAG,
				REVENUE_DISTRIBUTED_FLAG,
				BILLED_FLAG,
				BILL_HOLD_FLAG,
				BURDENABLE_RAW_COST,
				COST_DISTRIBUTED_FLAG,
				BUD_TASK_ID,
				BILLABLE_FLAG,
				LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                CREATED_BY,
                                CREATION_DATE,
                                LAST_UPDATE_LOGIN)
	     select gbc.award_set_id,
	            gbc.document_distribution_id,
	            100,
	            nvl(gbc.entered_dr, 0) - nvl(gbc.entered_cr, 0),
	            'EXP',
	            gbc.project_id,
	            gbc.task_id,
	            gbc.award_id,
	            gbc.document_header_id,
	            cdl.line_num,
	            gbc.ind_compiled_set_id,
	            cdl.request_id,
	            cdl.line_num_reversed,
	            gbc.resource_list_member_id,
	            'A',                            -- adl_status
	            'A',                            -- fc_status
	            'R',                            -- line_type
	            'N',                            -- capitalized_flag
	            NULL,                           -- reversed_flag
	            'N',                            -- revenue_distributed_flag
	            'N',                            -- billed_flag
	            exp.bill_hold_flag,
	            gbc.burdenable_raw_cost,
	            'Y',                            -- cost_distributed_flag
	            gbc.bud_task_id,
	            cdl.billable_flag,
                    v_date,
		    v_userid,
		    v_userid,
		    v_date,
	            v_login
	       from pa_cost_distribution_lines cdl,
	            pa_expenditure_items_all exp,
	            gms_bc_packets gbc
	      where gbc.packet_id = g_packet_id
	        and exp.expenditure_item_id = cdl.expenditure_item_id
	        and cdl.expenditure_item_id = gbc.document_header_id
	        and cdl.line_num = gbc.document_distribution_id
	        and exp.cost_distributed_flag = 'Y'
	        and gbc.document_distribution_id > 1
	        and gbc.parent_bc_packet_id is null
	        and gbc.status_code = 'A';

	        -- update the reversed flag on adls.
             g_error_stage := 'Created costing ADLs..update reversed flag';
             IF g_debug_context = 'Y' THEN
               gms_error_pkg.gms_debug (g_error_stage, 'C');
             END IF;

             open  reversed_cur;
             fetch reversed_cur bulk collect into v_exp_item_id,v_cdl_line_num;
             close reversed_cur;

             if v_exp_item_id.count > 0 then

                forall i in v_exp_item_id.first..v_exp_item_id.last
                       update gms_award_distributions adl
                          set adl.reversed_flag = 'Y'
                        where expenditure_item_id = v_exp_item_id(i)
                          and cdl_line_num        = v_cdl_line_num(i)
			  and document_type       = 'EXP'; --added for bug 6622800

             end if;

    elsif (p_process = 'Interface') then

      -- update expenditure_item_id from pa_transaction_interface to
      -- gms_bc_packets' document_header_id.
      -- re-sequenced code for bug :3690812

       open get_xface_exp;
       fetch get_xface_exp bulk collect into v_rowid, v_expenditure_item_id;
       close get_xface_exp;

       if v_rowid.count > 0 then

         forall i in v_rowid.first..v_rowid.last
            update gms_bc_packets
               set document_header_id = v_expenditure_item_id(i)
             where rowid = v_rowid(i);

         g_error_stage := 'Creating ADLs for interface..';
         IF g_debug_context = 'Y' THEN
          gms_error_pkg.gms_debug (g_error_stage, 'C');
         END IF;

         forall i in v_rowid.first..v_rowid.last
         insert into gms_award_distributions(
				AWARD_SET_ID,
				ADL_LINE_NUM,
				DISTRIBUTION_VALUE,
				RAW_COST,
				DOCUMENT_TYPE,
				PROJECT_ID,
				TASK_ID,
				AWARD_ID,
				EXPENDITURE_ITEM_ID,
				CDL_LINE_NUM,
				IND_COMPILED_SET_ID,
				REQUEST_ID,
				LINE_NUM_REVERSED,
				RESOURCE_LIST_MEMBER_ID,
				ADL_STATUS,
				FC_STATUS,
				LINE_TYPE,
				CAPITALIZED_FLAG,
				REVERSED_FLAG,
				REVENUE_DISTRIBUTED_FLAG,
				BILLED_FLAG,
				BILL_HOLD_FLAG,
				BURDENABLE_RAW_COST,
				COST_DISTRIBUTED_FLAG,
				BUD_TASK_ID,
				BILLABLE_FLAG,
				LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                CREATED_BY,
                                CREATION_DATE,
                                LAST_UPDATE_LOGIN)
	     select gms_adls_award_set_id_s.NEXTVAL,
	            gbc.document_distribution_id,
	            100,
	            nvl(gbc.entered_dr, 0) - nvl(gbc.entered_cr, 0),
	            'EXP',
	            gbc.project_id,
	            gbc.task_id,
	            gbc.award_id,
	            gbc.document_header_id,
	            cdl.line_num,
	            gbc.ind_compiled_set_id,
	            cdl.request_id,
	            cdl.line_num_reversed,
	            gbc.resource_list_member_id,
	            'A',                            -- adl_status
	            'A',                            -- fc_status
	            'R',                            -- line_type
	            'N',                            -- capitalized_flag
	            NULL,                           -- reversed_flag
	            'N',                            -- revenue_distributed_flag
	            'N',                            -- billed_flag
	            exp.bill_hold_flag,
	            gbc.burdenable_raw_cost,
	            'Y',                            -- cost_distributed_flag
	            gbc.bud_task_id,
	            cdl.billable_flag,
                    v_date,
		    v_userid,
		    v_userid,
		    v_date,
	            v_login
	       from pa_cost_distribution_lines cdl,
	            pa_expenditure_items_all exp,
	            gms_bc_packets gbc
	      where gbc.rowid = v_rowid(i)
	        and exp.expenditure_item_id = cdl.expenditure_item_id
	        and cdl.expenditure_item_id = gbc.document_header_id
	        and cdl.line_num = gbc.document_distribution_id
	        and gbc.document_type = 'EXP'
	        and gbc.parent_bc_packet_id is null
	        and gbc.status_code = 'P'
                and substr(nvl(result_code, 'F'), 1, 1) = 'P';

            v_rowid.delete;
            v_expenditure_item_id.delete;

       end if; /* v_rowid.count > 0 */

    end if; /* process = 'Costing' */

    g_error_stage := 'Create_ADLs...end';
    IF g_debug_context = 'Y' THEN
      gms_error_pkg.gms_debug (g_error_stage, 'C');
    END IF;
  End Create_ADLs;

-------------------------------------------------------------------------------
-- Procedure to delete the concurrency record.
-- This is the last step done for both Fundscheck for Costing and Interface.
-------------------------------------------------------------------------------
  Procedure Delete_Concurrency_Records is
  Begin
    g_error_stage := 'Delete_Concurrency_Records..starts';
    IF g_debug_context = 'Y' THEN
      gms_error_pkg.gms_debug (g_error_stage, 'C');
    END IF;

    delete from gms_concurrency_control
     where process_name = 'GMSFCSYS'
       and request_id = g_request_id;

    g_error_stage := 'Delete_Concurrency_Records..end';
    IF g_debug_context = 'Y' THEN
      gms_error_pkg.gms_debug (g_error_stage, 'C');
    END IF;

  End Delete_Concurrency_Records;

  --
------------------------------------------------------------------------------
-- By the time this procedure is called all GMS validations are done by
-- vert_app_validate if there are any sponsored project related transactions.
-- Here check if transaction_source is one of the supported ones and process
-- them.
--
-- This procedure is called for each distribution line being interfaced
-- from AP. Call is from pa_trx_import.
-- p_status = NULL if successful, else error is populated into p_status.
------------------------------------------------------------------------------

  PROCEDURE Fundscheck_Supplier_Cost(  p_transaction_source    IN VARCHAR2,
                                       p_txn_interface_id      IN NUMBER ,
                                       p_request_id	       IN NUMBER,
                                       p_status                IN OUT NOCOPY Varchar2 ) IS

   l_fck_return_code	varchar2(3) := NULL;
   l_fck_error_code	varchar2(1) := NULL;
   l_fck_error_stage	varchar2(10) := NULL;
   l_fck_required	varchar2(1) := 'N';

   l_status             varchar2(1);
   i                    NUMBER;

    -- Bug 5389130 : Cursor to fetch AP amount for adjustment scenario
    CURSOR C_fetch_ap_amount ( p_sys_ref2 VARCHAR2,
			       p_sys_ref5 VARCHAR2,
	                       p_sys_ref4 VARCHAR2,
			       p_interface_id NUMBER ) IS
	select xface.acct_raw_cost
	  FROM pa_transaction_interface xface
	 WHERE xface.transaction_source = G_txn_source
	   and xface.cdl_system_reference2  = p_sys_ref2
	   and xface.cdl_system_reference5  = p_sys_ref5
	   and (xface.cdl_system_reference4 = p_sys_ref4 OR p_sys_ref4 IS NULL)
	   and xface.SC_XFER_CODE = 'V'
	   and xface.interface_id = p_interface_id
	   and xface.TRANSACTION_STATUS_CODE = 'P';

   -- REL12 : AP Lines uptake Enhancement
   -- Procedure to intialise temporary plsql tables.

   Procedure Initialize_Tabs is
   Begin

    t_txn_interface_id.delete;
    t_transaction_source.delete;
    t_invoice_id.delete;
    t_invoice_distribution_id.delete;
    t_sys_ref4.delete;
    t_project_id.delete;
    t_task_id.delete;
    t_award_id.delete;
    t_ind_compiled_set_id.delete;
    t_burdenable_raw_cost.delete;
    t_bud_task_id.delete;
    t_expenditure_type.delete;
    t_expenditure_item_date.delete;
    t_expenditure_organization_id.delete;
    t_acct_raw_cost.delete;
    t_expenditure_category.delete;
    t_revenue_category.delete;
    t_adjusted_expenditure_item_id.delete;
    t_nz_adj_flag.delete ;

  End Initialize_Tabs;


  Begin

    g_debug_context := NULL;

    g_set_of_books_id := NULL;

    p_status := NULL;

    Set_Debug_Context;

    g_error_stage := 'In FundsCheck_Supplier_Cost..start';
    IF g_debug_context = 'Y' THEN
      gms_error_pkg.gms_debug ('x----  Start of GMS interface process  ----x', 'C');
      gms_error_pkg.gms_debug (g_error_stage, 'C');
    END IF;

    -- Bug 5344693 : Modified the following condition so that records with transaction source as 'AP VARIANCE' are also funds checked.
    if p_transaction_source not in ('AP INVOICE', 'AP DISCOUNTS',
                                     'AP NRTAX', 'AP EXPENSE', 'AP ERV' , 'AP VARIANCE' ) then /* Bug 5284323 */
       g_error_stage := 'Not a supported txn source..return';
       IF g_debug_context = 'Y' THEN
        gms_error_pkg.gms_debug (g_error_stage, 'C');
       END IF;
       return;
    end if;

    g_process := 'Interface';

    g_txn_source := p_transaction_source;

    g_txn_xface_id := p_txn_interface_id;

    g_request_id := p_request_id;

    INIT;

    IF g_debug_context = 'Y' THEN
      gms_error_pkg.gms_debug ('Txn Src: ' || g_txn_source ||', xface id: ' || g_txn_xface_id
                                ||', Request ID: ' || g_request_id, 'C');
    END IF;

    g_error_stage := 'Call execute fundscheck from fundscheck_supplier_cost';
    IF g_debug_context = 'Y' THEN
      gms_error_pkg.gms_debug (g_error_stage, 'C');
    END IF;

    open get_xface_cur;
    fetch get_xface_cur into g_xface_rec;

    if get_xface_cur%NOTFOUND then
       close get_xface_cur;

       g_error_stage := 'No interface records found to process';

       IF g_debug_context = 'Y' THEN
          gms_error_pkg.gms_debug ('No Interface records to process', 'C');
       END IF;

       return;
    else
       close get_xface_cur;
       g_error_stage := 'Interface records found to process';

       IF g_debug_context = 'Y' THEN
          gms_error_pkg.gms_debug ('Interface records to process', 'C');
       END IF;
    end if;

    -- Bug 5236418 : All the collection variables should be cleared before they are used.
    Initialize_Tabs;

   -- REL12 : AP Lines uptake Enhancement
   -- If adjusted_expenditure_item_id is populated then the txn records stores
   -- adjusted/non adjusted expenditures data associated with the original invoice whose reversal is being
   -- interfaced.In this case fetch all interface records having same invoice_id,invoice_distribution id
   -- and invoice payment id.

   -- Note :
   -- Global variable g_xface_rec stores Invoice data which is being interfaced
   -- Plsql tables starting with t_% stores either
   --   -> Stores data of adjusted/non adjusted expenditures associated with original invoice
   --      , if the invoice being interfaced is a reversal distribution.
   --   -> Invoice data , if the invoice being interfaced is a non reversal distribution


    IF  NVL(g_xface_rec.adjusted_expenditure_item_id,0) <> 0 THEN

           OPEN C_fetch_ap_amount (g_xface_rec.invoice_id,
                                   g_xface_rec.invoice_distribution_id,
                                   g_xface_rec.cdl_system_reference4,
				   g_xface_rec.interface_id);
           fetch C_fetch_ap_amount INTO g_xface_rec.acct_raw_cost;
           CLOSE C_fetch_ap_amount;

           OPEN  c_txn_details(g_xface_rec.invoice_id,
	                       g_xface_rec.invoice_distribution_id,
	                       g_xface_rec.cdl_system_reference4,
			       g_xface_rec.interface_id);



           FETCH c_txn_details BULK COLLECT INTO
                 t_txn_interface_id,
                 t_transaction_source,
                 t_invoice_id,
                 t_invoice_distribution_id,
		 t_sys_ref4,
                 t_project_id,
                 t_task_id,
                 t_award_id,
                 t_ind_compiled_set_id,
                 t_burdenable_raw_cost,
                 t_bud_task_id,
                 t_expenditure_type,
                 t_expenditure_item_date,
                 t_expenditure_organization_id,
                 t_acct_raw_cost,
                 t_expenditure_category,
                 t_revenue_category,
                 t_adjusted_expenditure_item_id,
		 t_nz_adj_flag ;
            CLOSE c_txn_details;

	    if t_txn_interface_id.count = 0 then
	       g_error_stage := 'No interface records found to process';
	       IF g_debug_context = 'Y' THEN
		  gms_error_pkg.gms_debug ('No Interface records to process', 'C');
	       END IF;
	       return;
	    end if;
    ELSE

        -- Bug 5236418 : Used BULK COLLECT so that the collection variables need not be extended before assigning value to them.

	 SELECT
	        g_xface_rec.txn_interface_id,
		g_xface_rec.transaction_source,
		g_xface_rec.invoice_id,
		g_xface_rec.invoice_distribution_id,
		g_xface_rec.project_id,
		g_xface_rec.task_id,
		g_xface_rec.award_id,
		g_xface_rec.ind_compiled_set_id,
		g_xface_rec.burdenable_raw_cost,
		g_xface_rec.bud_task_id,
		g_xface_rec.expenditure_type,
		g_xface_rec.expenditure_item_date,
		g_xface_rec.expenditure_organization_id,
		g_xface_rec.acct_raw_cost,
		g_xface_rec.expenditure_category,
		g_xface_rec.revenue_category_code,
		g_xface_rec.adjusted_expenditure_item_id,
		g_xface_rec.net_zero_adjustment_flag
        BULK COLLECT INTO
		 t_txn_interface_id,
		 t_transaction_source,
		 t_invoice_id,
		 t_invoice_distribution_id,
		 t_project_id,
		 t_task_id,
		 t_award_id,
		 t_ind_compiled_set_id,
		 t_burdenable_raw_cost,
		 t_bud_task_id,
		 t_expenditure_type,
		 t_expenditure_item_date,
		 t_expenditure_organization_id,
		 t_acct_raw_cost,
		 t_expenditure_category,
		 t_revenue_category,
		 t_adjusted_expenditure_item_id,
		 t_nz_adj_flag
	FROM DUAL;

    END IF;


    Execute_FundsCheck(l_fck_return_code,
                       l_fck_error_code,
                       l_fck_error_stage);

    Mark_Xface_Item_AS_Failed(g_packet_id, l_status);

    if l_fck_return_code < 0 then
       p_status := substr(l_fck_error_stage, 1, 30);
       IF g_debug_context = 'Y' THEN
          gms_error_pkg.gms_debug ('Error returned by Execute Fundscheck: ' || p_status, 'C');
       END IF;
    elsif (l_status = 'F') then
       p_status := 'GMS_FC_ERROR';
       IF g_debug_context = 'Y' THEN
          gms_error_pkg.gms_debug ('Error returned by Mark_Xface_Item_AS_Failed', 'C');
       END IF;
    end if;

    g_error_stage := ' -- Done with FundsCheck_Supplier_Cost..end -- ';
    IF g_debug_context = 'Y' THEN
      gms_error_pkg.gms_debug (g_error_stage, 'C');
    END IF;

    return;

  Exception
    when others then
       p_status := 'GMS_FC_ERROR';
       g_error_stage := 'Exception in FundsCheck_Supplier_Costs..return error';
       IF g_debug_context = 'Y' THEN
        gms_error_pkg.gms_debug (g_error_stage, 'C');
       END IF;
       return;

  End FundsCheck_Supplier_Cost;

-------------------------------------------------------------------------------
-- Procedure to create the indirect cost entries in gms_bc_packets.
-- This is called from Interface process.
-------------------------------------------------------------------------------

  Procedure Populate_Indirect_Cost(p_packet_id     IN   NUMBER) IS

  BEGIN
       g_error_stage := 'In Populate_Indirect_Cost..start';
       IF g_debug_context = 'Y' THEN
        gms_error_pkg.gms_debug (g_error_stage, 'C');
       END IF;

	Insert into gms_bc_packets
 		( PACKET_ID,
   		PROJECT_ID,
   		AWARD_ID,
   		TASK_ID,
   		EXPENDITURE_TYPE,
   		EXPENDITURE_ITEM_DATE,
   		ACTUAL_FLAG,
   		STATUS_CODE,
   		LAST_UPDATE_DATE,
   		LAST_UPDATED_BY,
   		CREATED_BY,
   		CREATION_DATE,
   		LAST_UPDATE_LOGIN,
   		SET_OF_BOOKS_ID,
   		JE_CATEGORY_NAME,
   		JE_SOURCE_NAME,
   		TRANSFERED_FLAG,
   		DOCUMENT_TYPE,
   		EXPENDITURE_ORGANIZATION_ID,
   		PERIOD_NAME,
   		PERIOD_YEAR,
   		PERIOD_NUM,
   		DOCUMENT_HEADER_ID ,
   		DOCUMENT_DISTRIBUTION_ID,
   		TOP_TASK_ID,
   		BUDGET_VERSION_ID,
		BUD_TASK_ID,
   		RESOURCE_LIST_MEMBER_ID,
   		ACCOUNT_TYPE,
   		ENTERED_DR,
   		ENTERED_CR ,
   		TOLERANCE_AMOUNT,
   		TOLERANCE_PERCENTAGE,
   		OVERRIDE_AMOUNT,
   		EFFECT_ON_FUNDS_CODE ,
   		RESULT_CODE,
   		GL_BC_PACKETS_ROWID,
   		BC_PACKET_ID,
   		PARENT_BC_PACKET_ID,
		VENDOR_ID,
		REQUEST_ID,
		IND_COMPILED_SET_ID,
		AWARD_SET_ID,
		TRANSACTION_SOURCE,
                EXPENDITURE_CATEGORY,  --Bug: 5003642
                REVENUE_CATEGORY)      --Bug: 5003642
 		select
 			gbc.PACKET_ID,
 			gbc.PROJECT_ID,
 			gbc.AWARD_ID,
 			gbc.TASK_ID,
 			icc.EXPENDITURE_TYPE,
 			trunc(gbc.EXPENDITURE_ITEM_DATE),
 			gbc.ACTUAL_FLAG,
 			gbc.STATUS_CODE,
 			gbc.LAST_UPDATE_DATE,
 			gbc.LAST_UPDATED_BY,
 			gbc.CREATED_BY,
 			gbc.CREATION_DATE,
 			gbc.LAST_UPDATE_LOGIN,
 			gbc.SET_OF_BOOKS_ID,
 			gbc.JE_CATEGORY_NAME,
 			gbc.JE_SOURCE_NAME,
 			gbc.TRANSFERED_FLAG,
 			gbc.DOCUMENT_TYPE,
 			gbc.EXPENDITURE_ORGANIZATION_ID,
 			gbc.PERIOD_NAME,
 			gbc.PERIOD_YEAR,
 			gbc.PERIOD_NUM,
 			gbc.DOCUMENT_HEADER_ID ,
 			gbc.DOCUMENT_DISTRIBUTION_ID,
 			gbc.TOP_TASK_ID,
 			gbc.BUDGET_VERSION_ID,
			gbc.BUD_TASK_ID,
 			NULL,
 			gbc.ACCOUNT_TYPE,
			pa_currency.round_currency_amt(decode(sign(gbc.BURDENABLE_RAW_COST * nvl(cm.compiled_multiplier,0)), 1, gbc.burdenable_raw_cost * nvl(cm.compiled_multiplier, 0), 0)),
			pa_currency.round_currency_amt(decode(sign(gbc.BURDENABLE_RAW_COST * nvl(cm.compiled_multiplier,0)), -1, abs(gbc.burdenable_raw_cost * nvl(cm.compiled_multiplier, 0)), 0)), --> bug 3637934
 			gbc.TOLERANCE_AMOUNT,
 			gbc.TOLERANCE_PERCENTAGE,
 			gbc.OVERRIDE_AMOUNT,
 			gbc.EFFECT_ON_FUNDS_CODE ,
 			gbc.RESULT_CODE,
 			gbc.gl_bc_packets_rowid,
 			gms_bc_packets_s.nextval,
 			gbc.BC_PACKET_ID,
			gbc.vendor_id,
			gbc.request_id,
			gbc.ind_compiled_set_id,
			gbc.award_set_id,
			gbc.transaction_source,
                        et.expenditure_category, --Bug: 5003642
                        et.revenue_category_code --Bug: 5003642
 		from	--pa_ind_rate_sch_revisions irsr,  /*6054504*/
        		--pa_cost_bases cb,                /*6054504*/
        		pa_expenditure_types et,
        		pa_ind_cost_codes icc,
        		pa_cost_base_exp_types cbet,
			PA_COST_BASE_COST_CODES CBCC,      /*6054504*/
        		--pa_ind_rate_schedules_all_bg irs,  /*6054504*/
        		--pa_ind_compiled_sets ics,       /*6054504*/
        		pa_compiled_multipliers cm,
        		gms_bc_packets gbc
  		where 	et.expenditure_type          = icc.expenditure_type
    		and 	icc.ind_cost_code            = cm.ind_cost_code
    		and 	cbet.cost_base               = cm.cost_base
    		and 	cbet.cost_base_type          = 'INDIRECT COST'
    		and 	cbet.expenditure_type        = gbc.expenditure_type
    		and 	cm.ind_compiled_set_id       = gbc.ind_compiled_set_id
		and 	cm.compiled_multiplier <> 0
                and     cbcc.cost_plus_structure     = cbet.cost_plus_structure
                and     cbcc.cost_base               = cbet.cost_base
                and     cbcc.cost_base_type          = cbet.cost_base_type
                and     cm.cost_base_cost_code_Id    = cbcc.cost_base_cost_code_Id
                and     cm.ind_cost_code             = cbcc.ind_cost_code
		and     gbc.burdenable_raw_cost <> 0
    		and 	gbc.packet_id = p_packet_id;
--		and     gbc.document_type   = 'AP' ;

       g_error_stage := 'Done populating indirect cost';
       IF g_debug_context = 'Y' THEN
        gms_error_pkg.gms_debug (g_error_stage, 'C');
       END IF;
  END Populate_Indirect_Cost;

-------------------------------------------------------------------------------
-- Tieback after interface process is done. This is called from pa_trx_import
-- after Projects is done with their tieback. This processes data for the
-- current request id.
-- Parameters :
--            p_request_id : Request ID of the calling process.
--            p_status     : 0 if successful, -1 if any exception occurs.
-------------------------------------------------------------------------------

  PROCEDURE Tieback_Interface(p_request_id         IN NUMBER,
                              p_status             IN OUT NOCOPY VARCHAR2
                              ) IS

      cursor pkt_for_summary_update is
      select distinct packet_id
        from gms_bc_packets
       where request_id = p_request_id
         and substr(nvl(result_code, 'P65'), 1, 1) = 'P'
         and status_code = 'P';

      -- Get all rejected transactions from pa_transaction_interface.
      -- Use this to fail gms_bc_packets records.

      cursor get_failed_txns is
      select distinct gbp.packet_id,
             xface.transaction_rejection_code
        from pa_transaction_interface_all xface,
	     gms_bc_packets gbp
       where to_number(gbp.gl_bc_packets_rowid) = xface.txn_interface_id
         and gbp.request_id = p_request_id
	 and gbp.parent_bc_packet_id is null
	 and xface.transaction_status_code = 'R'
         and substr(nvl(gbp.result_code, 'Z'), 1, 1) <> 'F'
         and gbp.status_code = 'P';

      x_packet_id	number;
      x_error_occured   varchar2(1);

      v_all_pkts_failed varchar2(1);

      v_packet_id	tt_bc_packet_id;
      type tt_reject_code is table of
           pa_transaction_interface.transaction_rejection_code%TYPE;
      v_reject_code     tt_reject_code;
      v_status          varchar2(1);

  Begin

     g_error_stage := 'TieBack_Xface: Start';
     IF g_debug_context = 'Y' THEN
       gms_error_pkg.gms_debug (g_error_stage, 'C');
     END IF;

     -- check the transactions which are rejected and fail gms_bc_packets
     -- entries
     open get_failed_txns;
     fetch get_failed_txns bulk collect into v_packet_id,
			                     v_reject_code;

     close get_failed_txns;

     if v_packet_id.count > 0 then

       IF g_debug_context = 'Y' THEN
         gms_error_pkg.gms_debug('Following packets are marked as failed :', 'C');
       END IF;
         IF g_debug_context = 'Y' THEN
           for i in v_packet_id.first..v_packet_id.last loop
              gms_error_pkg.gms_debug('Failed packet : ' || v_packet_id(i), 'C');
           end loop;
         END IF;

	forall i in v_packet_id.FIRST..v_packet_id.LAST
        update gms_bc_packets
	   set result_code = 'F89',
	       status_code = 'T',
               fc_error_message = 'PA_FC_ERROR: ' ||
	                          v_reject_code(i)
         where packet_id = v_packet_id(i);

     end if;
     -- update summary and post adjustment logs.

     v_all_pkts_failed := 'N';

     open pkt_for_summary_update;
     loop
     fetch pkt_for_summary_update into x_packet_id;

        if pkt_for_summary_update%ROWCOUNT = 0 then
	   v_all_pkts_failed := 'Y';
	   close pkt_for_summary_update;
	   exit;
	end if;

        if pkt_for_summary_update%NOTFOUND then
	   close pkt_for_summary_update;
	   exit;
	end if;

        if not
           gms_cost_plus_extn.update_source_burden_raw_cost(x_packet_id, 'R', 'Y') then

           g_error_stage := 'TieBack_Xface: Error returned from update_source_burden_raw_cost';
           IF g_debug_context = 'Y' THEN
             gms_error_pkg.gms_debug (g_error_stage || ' for Packet ID : ' || x_packet_id, 'C');
            END IF;

	   x_error_occured := 'Y';
           Mark_Xface_Item_As_Failed(x_packet_id, v_status);
	   exit;

        end if;

     end loop;

     -- If error occurs, retrurn with failure status. Rollback everything
     if x_error_occured = 'Y' then
        p_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF g_debug_context = 'Y' THEN
          gms_error_pkg.gms_debug('Call to Source Burden Raw Cost failed..return failure', 'C');
        END IF;
	return;
     end if;

     -- Update final payment status for finally paid invoices
     --code change for 7589407 (RDBMS optimizer issue)
        UPDATE gms_award_distributions adl
      SET adl.payment_status_flag='Y'
      WHERE
TO_CHAR(adl.invoice_id)||'|'||TO_CHAR(adl.invoice_distribution_id) IN
       (SELECT
(trx.cdl_system_reference2)||'|'||TO_CHAR(trx.cdl_system_reference5)
        FROM gms_bc_packets pkt,
             pa_transaction_interface_all trx
       WHERE pkt.request_id=p_request_id
         AND pkt.txn_interface_id=trx.txn_interface_id
         AND substr(nvl(pkt.result_code,'P65'), 1, 1)='P'
         AND pkt.status_code='P'
         AND pkt.document_type='AP'
         AND pkt.parent_bc_packet_id IS NULL
         AND trx.cdl_system_reference4=pa_trx_import.g_finalPaymentId) --Final payment
         AND adl.document_type='AP'
         AND adl.adl_status='A';

     -- update the status of gms_bc_packets. update expenditure_item_id
     -- from pa_transaction_interface to gms_bc_packets.

     if v_all_pkts_failed = 'N' then

        g_error_stage := 'TieBack_Xface: Calling Create ADLs';
        IF g_debug_context = 'Y' THEN
          gms_error_pkg.gms_debug (g_error_stage, 'C');
        END IF;

        -- Note:
        -- ADLs should be created before Updating status_code on gms_bc_packets to 'A'.
        -- create_adl package looks at records with status_code 'P'

        create_adls('Interface', p_request_id);

        g_error_stage := 'TieBack_Xface: Calling update_gms_bc_packets';
        IF g_debug_context = 'Y' THEN
          gms_error_pkg.gms_debug (g_error_stage, 'C');
        END IF;

        update_gms_bc_packets('Interface', p_request_id);

     end if;

     p_status := FND_API.G_RET_STS_SUCCESS;

Exception
  when others then
       p_status := 'GMS_FC_ERROR';
       g_error_stage := 'Exception in TieBack_Interface..return error';
       IF g_debug_context = 'Y' THEN
        gms_error_pkg.gms_debug (g_error_stage, 'C');
       END IF;

       return;

End Tieback_Interface;

--=============================================================================
--  Bug       : 5389130
--              R12.PJ:XB7:DEV:BC: TO TRACK GRANTS INTERFACE ISSUES
--  Procedure : Net_zero_adls
--  Purpose   : Adls creation logic for the dummy additional exp created
--              to correct the accounting adjustments.
--              These are new zero transactions.
--
--  Parameters  and meaning.
--  -----------------------
--  p_transaction_source    : Transaction source for supplier cost interface.
--  p_batch                 : Batch name for transaction source.
--  p_status                : return status                  .
--  P_xface_id              : Transaction interface ID.
--=============================================================================
 procedure Net_zero_adls( p_transaction_source IN VARCHAR2,
                          p_batch              IN VARCHAR2,
                          P_xface_id           IN NUMBER,
                          p_status             IN OUT NOCOPY VARCHAR2 ) is
   v_login   number;
   v_userid  number;
   v_date    date;
 begin
    --Variables used in insert ..
    v_login   := fnd_global.login_id;
    v_date    := sysdate;
    v_userid  := fnd_global.user_id;

    g_error_stage := 'TieBack_Xface: Net_zero_adls starts here';
    IF g_debug_context = 'Y' THEN
       gms_error_pkg.gms_debug (g_error_stage, 'C');
    END IF;

    insert into gms_award_distributions(
				AWARD_SET_ID,
				ADL_LINE_NUM,
				DISTRIBUTION_VALUE,
				RAW_COST,
				DOCUMENT_TYPE,
				PROJECT_ID,
				TASK_ID,
				AWARD_ID,
				EXPENDITURE_ITEM_ID,
				CDL_LINE_NUM,
				IND_COMPILED_SET_ID,
				REQUEST_ID,
				LINE_NUM_REVERSED,
				RESOURCE_LIST_MEMBER_ID,
				ADL_STATUS,
				FC_STATUS,
				LINE_TYPE,
				CAPITALIZED_FLAG,
				REVERSED_FLAG,
				REVENUE_DISTRIBUTED_FLAG,
				BILLED_FLAG,
				BILL_HOLD_FLAG,
				BURDENABLE_RAW_COST,
				COST_DISTRIBUTED_FLAG,
				BUD_TASK_ID,
				BILLABLE_FLAG,
				LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                CREATED_BY,
                                CREATION_DATE,
                                LAST_UPDATE_LOGIN)
	     select gms_adls_award_set_id_s.NEXTVAL,
	            1,
	            100,
	            cdl.amount,
	            'EXP',
	            txn.project_id,
	            txn.task_id,
	            adl.award_id,
	            cdl.expenditure_item_id,
	            cdl.line_num,
	            cdl.ind_compiled_set_id,
	            cdl.request_id,
	            cdl.line_num_reversed,
	            adl.resource_list_member_id,
	            'A',                            -- adl_status
	            'A',                            -- fc_status
	            'R',                            -- line_type
	            'N',                            -- capitalized_flag
	            NULL,                           -- reversed_flag
	            'N',                            -- revenue_distributed_flag
	            'N',                            -- billed_flag
	            ei.bill_hold_flag,
	            cdl.amount,
	            'Y',                            -- cost_distributed_flag
	            adl.bud_task_id,
	            cdl.billable_flag,
                v_date,
		        v_userid,
		        v_userid,
		        v_date,
	            v_login
         from pa_transaction_interface_all txn,
              pa_expenditure_items_all     ei,
              pa_cost_distribution_lines_all cdl,
              ap_invoice_distributions_all   apd,
              gms_award_distributions        adl
        where txn.interface_id = p_xface_id
          and nvl(txn.transaction_status_code, 'Z') <> 'R'
          and txn.batch_name   = p_batch
          and txn.adjusted_expenditure_item_id = 0
          and txn.expenditure_item_id          = cdl.expenditure_item_id
          and txn.expenditure_item_id          = ei.expenditure_item_id
          and txn.cdl_system_reference5        = apd.invoice_distribution_id
          and apd.award_id                     = adl.award_set_id
          and adl.adl_line_num                 = 1
          and not exists ( select 1 from gms_award_distributions adl2
                            where adl2.expenditure_item_id = ei.expenditure_item_id
                              and adl2.document_type       = 'EXP'
                              and adl2.adl_status          = 'A'
                              and adl2.adl_line_num        = 1  );

    g_error_stage := 'TieBack_Xface: Net_zero_adls ends here';
    IF g_debug_context = 'Y' THEN
       gms_error_pkg.gms_debug (g_error_stage, 'C');
    END IF;

 end Net_zero_adls ;


-------------------------------------------------------------------------------
-- Procedure marks the current packet's interface data as failed.
-- Updates gms_bc_packets and pa_transaction_interface tables.
-------------------------------------------------------------------------------

  Procedure Mark_Xface_Item_AS_Failed(p_packet_id IN NUMBER,
                                      p_status    OUT NOCOPY VARCHAR2) is

  cursor c1 is -- changed for performance.
  select distinct txn_interface_id
    from gms_bc_packets
   where packet_id = p_packet_id
     and substr(result_code, 1, 1) = 'F';

  v_txn_interface_id    number;
  Begin

    g_error_stage := 'Mark_Xface_Item_As_Failed: Start';
    IF g_debug_context = 'Y' THEN
      gms_error_pkg.gms_debug (g_error_stage, 'C');
    END IF;

    p_status := 'S';

    open c1;
    fetch c1 into v_txn_interface_id;

    if c1%FOUND then
       p_status := 'F';

    update pa_transaction_interface
       set transaction_rejection_code = 'GMS_FC_ERROR',
           transaction_status_code = 'R'
     where txn_interface_id = v_txn_interface_id;

    end if;

    close c1;

    g_error_stage := 'Mark_Xface_Item_As_Failed: End';
    IF g_debug_context = 'Y' THEN
       gms_error_pkg.gms_debug (g_error_stage, 'C');
    END IF;

  End Mark_Xface_Item_AS_Failed;

-------------------------------------------------------------------------------
--  Function : grants_implemented
--  Purpose  : Function checks if grants is implemented for the OU.
--             If so, return 'Y' else return 'N'.
-------------------------------------------------------------------------------
FUNCTION grants_implemented return VARCHAR2 IS
BEGIN

  if gms_pa_api.vert_install then
     return 'Y';
  else
     return 'N';
  end if;

END grants_implemented;

end gms_pa_costing_pkg;

/
