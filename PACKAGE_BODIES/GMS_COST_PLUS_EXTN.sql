--------------------------------------------------------
--  DDL for Package Body GMS_COST_PLUS_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_COST_PLUS_EXTN" as
/* $Header: gmscpexb.pls 120.20 2007/03/17 09:57:33 asubrama ship $  */


-- Global Variable : Used in create_burden_adjustments and function calc_exp_burden
   g_set_of_books_id  pa_implementations_all.set_of_books_id%type;
   g_request_id       gms_bc_packets.request_id%type;

  -- Used in update_bc_pkt_burden_raw_cost
   g_actual_flag     varchar2(1);

  -- Set in update_bc_pkt_burden_raw_cost
  g_error_procedure_name varchar2(30);
  g_error_program_name     Varchar2 (30);
  g_debug                  Varchar2(1);

  -- Stores sqlerrm ..
  g_dummy varchar2(2000);
  --R12 Fundscheck Management uptake:  Defining new global variables
  g_update_status        varchar2(13) ;
  g_update_bvid          varchar2(13) ;
  g_update_brc           varchar2(13) ;



  -- variable used in update_bc_pkt_burden_raw_cost and UPDATE_BC_PACKET
 l_calc_sequence gms_bc_packets.burden_calculation_seq%type;

 -- This cursor and variable will be used to lock the summary table ...
 -- Used in	update_bc_pkt_burden_raw_cost and Maximize_burden
 Cursor c_lock_burden_summary(p_award_id in number,p_exp_type in varchar2) is
        select 1
          from gms_award_exp_type_act_cost
         where award_id         = p_award_id
           and expenditure_type = p_exp_type
         for update;

 l_lock_burden_summary number(1);

--            To retrive the burden schedule id of an  award project from the award id
--            and expenditure item date. The Schedule type is always 'C'


    RESOURCE_BUSY     EXCEPTION;
    PRAGMA EXCEPTION_INIT( RESOURCE_BUSY, -0054 );
    X_ERR_STAGE       VARCHAR2(10) ;

	-- Bug 3465191
	-- Performance Fix.
	--
    TYPE commitRecTyp IS RECORD
	(
      dist_id		   NUMBER,
      header_id		   NUMBER,
      amount		   NUMBER,
      burden           NUMBER,
      award_set_id     NUMBER,
      adl_line_num     NUMBER,
      diff_amount      NUMBER,
      award_id         NUMBER,
      expenditure_type varchar2(30),
	  project_id       NUMBER,
      task_id          NUMBER,
	  expenditure_item_date DATE,
      expenditure_organization_id NUMBER,
	  resource_list_member_id     NUMBER,
      bud_task_id                 NUMBER,
      ind_compiled_set_id         NUMBER
      );

	-- Bug 3465191
	-- Performance Fix.
	--
	TYPE c_adj_rec is REF CURSOR RETURN commitRecTyp;

	CURSOR c_award_exp_total( p_award_id NUMBER, p_exp_type varchar2)  is
			SELECT nvl(act.req_raw_cost,0)			req_raw_cost,
				   nvl(act.po_raw_cost,0)			po_raw_cost,
				   nvl(act.enc_raw_cost,0)			enc_raw_cost,
				   nvl(act.AP_raw_cost,0)			AP_raw_cost,
				   nvl(act.exp_raw_cost,0)			exp_raw_cost,
				   nvl(act.req_burdenable_cost,0)	req_burdenable_cost,
				   nvl(act.po_burdenable_cost,0)	po_burdenable_cost,
				   nvl(act.enc_burdenable_cost,0)	enc_burdenable_cost,
				   nvl(act.ap_burdenable_cost,0)	ap_burdenable_cost,
				   nvl(act.exp_burdenable_cost,0)	exp_burdenable_cost
			  FROM gms_award_exp_type_act_cost act
			 WHERE act.award_id         = P_award_id
			   AND act.expenditure_type = P_EXP_TYPE
			   FOR UPDATE OF REQ_RAW_COST NOWAIT;

  cursor bc_packets( p_packet_id NUMBER, p_award_id	NUMBER, p_expenditure_type varchar2 ) is
     select packet_id,
			bc_packet_id,
            document_header_id,
			document_distribution_id,
            award_id,
			expenditure_type,
			document_type,
            nvl(entered_cr,0)  entered_cr,
			nvl(entered_dr,0)  entered_dr,
		    award_set_id,
		    transaction_source,
			request_id
       from gms_bc_packets
      where packet_id 		= p_packet_id
		and expenditure_type =  p_expenditure_type
		and award_id         =  p_award_id
        and nvl(entered_cr,0) + nvl(entered_dr,0) <> 0
        and Status_code in ('P','I') -- fix for bug : 2927485, To reject transactions that had already failed a setup step
        and burdenable_raw_cost is null -- fix for bug 3810247
        and document_type    <> 'ENC' --Bug 5726575
	  order by decode(document_type,'REQ', 1, 'PO',2, 'ENC', 3, 'AP', 4, 'EXP', 5, 6 ) asc, ( nvl(entered_dr,0) - nvl( entered_cr,0) ) DESC  ;
      -- Above order by is to reduce over burdening ..

           --Bug 5726575
           cursor bc_packets_enc( p_packet_id NUMBER, p_award_id NUMBER, p_expenditure_type varchar2 ) is
              select packet_id,
                     bc_packet_id,
                     document_header_id,
                     document_distribution_id,
                     gbp.award_id,
                     expenditure_type,
                     gbp.document_type,
                     nvl(entered_cr,0)  entered_cr,
                     nvl(entered_dr,0)  entered_dr,
                     gbp.award_set_id,
                     transaction_source,
                     gbp.request_id
                from gms_bc_packets gbp,
                     gms_award_distributions adl
               where gbp.packet_id            =  p_packet_id
                     and gbp.expenditure_type =  p_expenditure_type
                     and gbp.award_id         =  p_award_id
                     and gbp.document_header_id = adl.expenditure_item_id
                     and gbp.document_distribution_id = adl.adl_line_num
                     and adl.document_type = 'ENC'
                     and adl.adl_status = 'A'
                     and nvl(gbp.entered_cr,0) + nvl(gbp.entered_dr,0) <> 0
                     and gbp.document_type    = 'ENC'
                     and gbp.Status_code      = 'P'
            order by decode(adl.line_num_reversed, NULL, decode(adl.reversed_flag, NULL, 3, 2), 1) ASC,
                     (nvl(entered_dr,0) - nvl(entered_cr,0)) ASC;

      -- --------------------------------
      -- Change : status_code   = 'I' ;
      -- --------------------------------

	X_rec_award_EXP_tot			c_award_exp_total%ROWTYPE ;
	X_tot_raw				NUMBER ;
	x_tot_burden				NUMBER ;
	x_cmt_tot_burden			NUMBER ;
	x_award_exp_limit			NUMBER ;

	-- ============================================================
	-- Bug : 1776185 - IDC LIMITS OF $0 NOT BEING RECOGNIZED WHEN
	--     :           BURDENING.
	-- ============================================================
	x_calc_zero_limit			BOOLEAN ;

-- ------------------------------------------------------------------------------------------------+
-- Function burden_allowed:

--  This will check if burden is allowed on the transaction ..
--  RETURN   : Y -- burden cost should be calculated based on set up and limits.
--             N -- Burden cost should be zero.
-- ------------------------------------------------------------------------------------------------+
   FUNCTION burden_allowed(p_transaction_source VARCHAR2) RETURN VARCHAR2
   IS
     l_allow_burden_flag pa_transaction_sources.allow_burden_flag%type;
   BEGIN

    If p_transaction_source is NULL then
       RETURN 'Y';
    End If;

     Select DECODE( NVL(allow_burden_flag,'N'), 'N', 'Y', 'N')
     into   l_allow_burden_flag
	 from   pa_transaction_sources
     where  transaction_source = p_transaction_source;

     RETURN l_allow_burden_flag;
   Exception
      When no_data_found then
        RETURN 'Y';
   END burden_allowed;

  -- BUG 3465191
  -- performance issue with gms_commitment_encumbered_v
  -- the cursors on gms_commitment_encumbered_v were using high shared memory.
  -- open ref cursor open the selects based on the document type and selects
  -- from the base tables directly.
  --
  PROCEDURE open_ref_cursor ( p_doc_adj     IN OUT NOCOPY c_adj_rec,
							  p_doc_type    IN     VARCHAR2,
							  p_award_id    IN     NUMBER,
							  p_exp_type    IN     VARCHAR2,
							  p_dist_id     IN     NUMBER,
							  p_header_id   IN     NUMBER,
							  p_calling_seq IN     VARCHAR2 )  is
     l_choice NUMBER ;
  BEGIN
    g_error_procedure_name := 'open_ref_cursor';
    IF g_debug = 'Y' THEN
       gms_error_pkg.gms_debug (g_error_procedure_name||':Start','C');
   END IF;

    IF p_calling_seq = 'MAXIMIZE_BURDEN' THEN
       l_choice := 1;
    ELSIF p_calling_seq = 'CREATE_ADJPLUS_LOG'  THEN
       l_choice := 2;
    ELSIF p_calling_seq = 'SELF_ADJUSTMENT' THEN
       l_choice := 3;
    ELSE
       l_choice := 0;
    END IF ;

    IF l_choice = 0 THEN
       return ;
    END IF ;

    IF p_doc_type = 'REQ' THEN
	   OPEN P_DOC_ADJ FOR
	   select vw.dist_id,
	   	      vw.header_id,
			  vw.amount,
			  vw.burden,
			  vw.award_set_id,
			  vw.adl_line_num,
			  (vw.amount - NVL(vw.burden,0) ) diff_amount,
			  vw.award_id,
			  vw.expenditure_type,
              vw.project_id,
              vw.task_id,
			  vw.expenditure_item_date,
			  vw.expenditure_organization_id,
              vw.resource_list_member_id,
              vw.bud_task_id,
              vw.ind_compiled_set_id
		from ( select rd.distribution_id                 dist_id,
			          rh.requisition_header_id           header_id,
					  po_intg_document_funds_grp.get_active_encumbrance_func
					  ('REQUISITION',rd.distribution_id) amount,
                       adl.burdenable_raw_cost           burden,
					   adl.award_set_id                  award_set_id,
					   adl.adl_line_num                  adl_line_num,
					   adl.award_id                      award_id,
					   rd.expenditure_type               expenditure_type,
					   rd.project_id,
					   rd.task_id,
					   rd.expenditure_item_date,
					   rd.expenditure_organization_id,
					   adl.resource_list_member_id,
					   adl.bud_task_id,
					   adl.ind_compiled_set_id
				  from po_requisition_headers     RH,
					   po_requisition_lines       RL,
					   po_req_distributions       RD,
					   gms_award_distributions    ADL
				 where rh.type_lookup_code                = 'PURCHASE'
				   and rh.requisition_header_id           = rl.requisition_header_id
				   and nvl(rl.modified_by_agent_flag,'N') = 'N'
				   and rl.source_type_code                = 'VENDOR'
				   and rd.requisition_line_id             = rl.requisition_line_id
				   and nvl(rd.encumbered_flag,'N')        = 'Y'
				   and adl.award_set_id                   = rd.award_id
				   and adl.distribution_id                = rd.distribution_id
				   and adl.adl_status                     = 'A'
				   and adl.document_type                  = 'REQ'
				   and adl.adl_line_num                   = 1
				   and adl.award_id                       = p_award_id
				   and rd.expenditure_type                = p_exp_type
				   --and nvl(rh.authorization_status,'NULL')= 'APPROVED' -- Commented as part of Bug 5037180
			 ) VW
       where ( ( l_choice = 1 and ABS(vw.amount)  > ABS(vw.burden) ) OR
               ( l_choice = 2 and NVL(vw.burden,0) > 0 AND vw.dist_id <> p_dist_id  ) OR
               ( l_choice = 3 and vw.header_id <> p_header_id and vw.burden is not NULL  )
             )
	  order by vw.header_id desc , vw.dist_id desc ;

    ELSIF p_doc_type = 'PO' THEN
	         -- BUG 	: 4908584
			 --         : R12.PJ:XB2:DEV:GMS: APPSPERF:GMS: PACKAGE: GMSBCPEXB.PLS . 1 SQL
			 --         : (Share Memory Size 2,009,186)
		     OPEN P_DOC_ADJ FOR
			      select vw.dist_id,
					     vw.header_id,
						 vw.amount,
						 vw.burden,
						 vw.award_set_id,
						 vw.adl_line_num,
						 (vw.amount - NVL(vw.burden,0) ) diff_amount,
						 vw.award_id,
						 vw.expenditure_type,
              		     vw.project_id,
              			 vw.task_id,
			  			 vw.expenditure_item_date,
			  			 vw.expenditure_organization_id,
              			 vw.resource_list_member_id,
              			 vw.bud_task_id,
              			 vw.ind_compiled_set_id
				    from ( select pod.po_header_id         header_id
							      , pod.po_distribution_id dist_ID
								  , po_intg_document_funds_grp.get_active_encumbrance_func('PO', pod.po_distribution_id)
								    amount
								  , adl.burdenable_raw_cost burden
								  , adl.award_set_id       award_set_id
								  , adl.adl_line_num       adl_line_num
								  , adl.award_id		   award_id
								  , pod.expenditure_type   expenditure_type
					   		      , pod.project_id
					   			  , pod.task_id
					   			  , pod.expenditure_item_date
					  			  , pod.expenditure_organization_id
					   		      , adl.resource_list_member_id
					   			  , adl.bud_task_id
					   			  , adl.ind_compiled_set_id
							 from
								  po_distributions        pod,
								  gms_award_distributions adl
							where nvl(pod.encumbered_flag,'N')= 'Y'
							  and pod.award_id                = adl.award_set_id
							  and adl.adl_line_num            = 1
							  and adl.po_distribution_id      = pod.po_distribution_id
							  --
                              -- 4004559 - PJ.M:B8:P13:OTH:PERF: FULL TABLE SCAN COST ON PO_DISTRIBUTIONS_ALL EXCEEDS 5
							  -- gms_budget_versions criteria was added so that index can be used.
							  -- and full table scan on po_distributions_all is gone.
							  --
							  and pod.project_id in ( select gbv.project_id
							                            from gms_budget_versions gbv
							  			               where gbv.budget_type_code     = 'AC'
										                 and gbv.budget_status_code   in ('S','W' )
														 and gbv.award_id             = p_award_id )
							  and adl.adl_status              = 'A'
							  and adl.fc_status               = 'A'
							  and adl.document_type           = 'PO'
							  and adl.award_id                = p_award_id
							  and pod.expenditure_type        = p_exp_type
							) VW
                      where (vw.amount - NVL(vw.burden,0) ) <> 0
					    AND ( ( l_choice = 1 and ABS(vw.amount)  > ABS(vw.burden) ) OR
                              ( l_choice = 2 and NVL(vw.burden,0) > 0 AND vw.dist_id <> p_dist_id  ) OR
                              ( l_choice = 3 and vw.header_id <> p_header_id and vw.burden is not NULL  )
                            )
    		          order by vw.header_id desc , vw.dist_id desc ;

	   ELSIF p_doc_type = 'AP' THEN
           If l_choice in (2,3) then
			  OPEN P_DOC_ADJ FOR
	               select d.invoice_distribution_id   dist_id    -- AP Lines change
						  ,I.invoice_id                 header_id
						  , pa_cmt_utils.get_apdist_amt(d.invoice_distribution_id,
						                                I.invoice_id,
														nvl(d.base_amount,d.amount),
														'N',
														'GMS', nvl(g.sla_ledger_cash_basis_flag,'N')) amount
		                  --, nvl(d.base_amount,d.amount) amount
		                  , adl.burdenable_raw_cost     burden
						  , adl.award_set_id            award_set_id
						  , adl.adl_line_num            adl_line_num

						  , ( pa_cmt_utils.get_apdist_amt(d.invoice_distribution_id,
						                                I.invoice_id,
														nvl(d.base_amount,d.amount),
														'N',
														'GMS',nvl(g.sla_ledger_cash_basis_flag,'N') ) -  NVL(adl.burdenable_raw_cost,0) ) diff_amount
						  --, (nvl(d.base_amount,d.amount) - NVL(adl.burdenable_raw_cost,0) ) diff_amount
						  , adl.award_id				award_id
						  , d.expenditure_type          expenditure_type
					      , d.project_id
					   	  , d.task_id
					      , d.expenditure_item_date
					  	  , d.expenditure_organization_id
					      , adl.resource_list_member_id
					   	  , adl.bud_task_id
					   	  , adl.ind_compiled_set_id
		             from ap_invoices                  I,
			              ap_invoice_distributions     D,
			              gms_award_distributions      ADL,
					    GL_LEDGERS				   G
		            where i.invoice_id                 = d.invoice_id
					  and pa_cmt_utils.get_apdist_amt(d.invoice_distribution_id,
						                                I.invoice_id,
														nvl(d.base_amount,d.amount),
														'N',
														'GMS',nvl(g.sla_ledger_cash_basis_flag,'N'))  <> 0
		              and decode(d.pa_addition_flag,'Z','Y','G', 'Y','T','Y','E','Y',null,'N', d.pa_addition_flag) <> 'Y'
		              and nvl(d.match_status_flag,'N') = 'A'
		              and d.award_id                   = adl.award_set_id
				    and G.LEDGER_ID = D.SET_OF_BOOKS_ID
		              and adl.invoice_id               = i.invoice_id
		              and adl.invoice_distribution_id  = d.invoice_distribution_id
		              and adl.adl_status               = 'A'
					  and adl.adl_line_num             = 1
		              and adl.document_type            = 'AP'
		              and nvl(adl.fc_status,'N')       = 'A'
					  and d.match_status_flag          = 'A'
					  and adl.award_id                  = p_award_id
					  and d.expenditure_type           = p_exp_type
					  and d.line_type_lookup_code      <> 'PREPAY'
					  and I.invoice_type_lookup_code   <> 'PREPAYMENT'
					  and ( --( l_choice = 1 and ABS(nvl(d.base_amount,d.amount ) ) > ABS(NVL(adl.burdenable_raw_cost,0) )
					        --) OR
                            ( l_choice = 2 and NVL(adl.burdenable_raw_cost,0) > 0
							               and d.invoice_distribution_id <> p_dist_id  ) OR -- AP Lines change
                              ( l_choice = 3 and i.invoice_id <> p_header_id
							                 and adl.burdenable_raw_cost is not NULL  )
                            )
    		          order by I.invoice_id desc , d.invoice_distribution_id desc ; -- AP Lines change
          ElsIf l_choice = 1 then
			  OPEN P_DOC_ADJ FOR
	               select d.invoice_distribution_id    dist_id  -- AP Lines change
						  ,I.invoice_id                 header_id
						  , pa_cmt_utils.get_apdist_amt(d.invoice_distribution_id,
						                                I.invoice_id,
														nvl(d.base_amount,d.amount),
														'N',
														'GMS' ) amount
		                  --, nvl(d.base_amount,d.amount) amount
		                  , adl.burdenable_raw_cost     burden
						  , adl.award_set_id            award_set_id
						  , adl.adl_line_num            adl_line_num
						  , ( pa_cmt_utils.get_apdist_amt(d.invoice_distribution_id,
						                                I.invoice_id,
														nvl(d.base_amount,d.amount),
														'N',
														'GMS',nvl(g.sla_ledger_cash_basis_flag,'N') ) - NVL(adl.burdenable_raw_cost,0) ) diff_amount
						  --, (nvl(d.base_amount,d.amount) - NVL(adl.burdenable_raw_cost,0) ) diff_amount
						  , adl.award_id				award_id
						  , d.expenditure_type          expenditure_type
					      , d.project_id
					   	  , d.task_id
					      , d.expenditure_item_date
					  	  , d.expenditure_organization_id
					      , adl.resource_list_member_id
					   	  , adl.bud_task_id
					   	  , adl.ind_compiled_set_id
		             from ap_invoices                  I,
			              ap_invoice_distributions     D,
			              gms_award_distributions      ADL,
					    gl_ledgers				  g
		            where i.invoice_id                 = d.invoice_id
					  and pa_cmt_utils.get_apdist_amt(d.invoice_distribution_id,
						                                I.invoice_id,
														nvl(d.base_amount,d.amount),
														'N',
														'GMS', nvl(g.sla_ledger_cash_basis_flag,'N'))  <> 0
		              and decode(d.pa_addition_flag,'Z','Y','G', 'Y','T','Y','E','Y',null,'N', d.pa_addition_flag) <> 'Y'
		              and nvl(d.match_status_flag,'N') = 'A'
		              and d.award_id                   = adl.award_set_id
		              and adl.invoice_id               = i.invoice_id
		              and adl.invoice_distribution_id  = d.invoice_distribution_id
		              and adl.adl_status               = 'A'
					  and adl.adl_line_num             = 1
		              and adl.document_type            = 'AP'
		              and nvl(adl.fc_status,'N')       = 'A'
					  and d.match_status_flag          = 'A'
					  and adl.award_id                  = p_award_id
					  and d.expenditure_type           = p_exp_type
					  and d.line_type_lookup_code      <> 'PREPAY'
					  and I.invoice_type_lookup_code   <> 'PREPAYMENT'
                      and nvl(d.base_amount,d.amount) > 0
                      and nvl(d.base_amount,d.amount) <> nvl(adl.burdenable_raw_cost,0)
    		  	       AND G.LEDGER_ID = D.SET_OF_BOOKS_ID
    		          order by (nvl(d.base_amount,d.amount) - nvl(adl.burdenable_raw_cost,0)) desc ;
          End If;

	   ELSIF p_doc_type = 'ENC' THEN
			  OPEN P_DOC_ADJ FOR
		           SELECT  1                                                dist_id
						   , enc.encumbrance_item_id                        header_id
			               , enc.amount                                     amount
			               , adl.burdenable_raw_cost                        burden
			               , adl.award_set_id                               award_set_id
			               , adl.adl_line_num                               adl_line_num
						   , (enc.amount - NVL(adl.burdenable_raw_cost,0) ) diff_amount
						   , adl.award_id                                   award_id
						   , enc.encumbrance_type                           expenditure_type
					   	   , adl.project_id
					   	   , enc.task_id
					   	   , trunc(enc.encumbrance_item_date)  expenditure_item_date
					  	   , nvl(enc.override_to_organization_id,ge.incurred_by_organization_id) expenditure_organization_id
					   	   , adl.resource_list_member_id
					   	   , adl.bud_task_id
					   	   , adl.ind_compiled_set_id
		             from gms_encumbrance_items     enc,
			              gms_award_distributions   adl,
						  gms_encumbrances_all      ge
                    where enc.encumbrance_item_id           = adl.expenditure_item_id
		              and nvl(enc.enc_distributed_flag,'N') = 'Y'
		              and adl.adl_status                    = 'A'
		              and adl.document_type                 = 'ENC'
                              AND nvl(adl.reversed_flag, 'N')       = 'N' --Bug 5726575
                              AND adl.line_num_reversed             is null --Bug 5726575
					  and adl.award_id                      = p_award_id
					  and enc.encumbrance_type              = p_exp_type
					  and ge.encumbrance_id     		    = enc.encumbrance_id
					  and ( (l_choice = 1 and ABS(enc.amount ) > ABS(NVL(adl.burdenable_raw_cost,0)) ) OR
                            (l_choice = 2 and NVL(adl.burdenable_raw_cost,0) > 0
							              and 1 <> p_dist_id  ) OR
                            (l_choice = 3 and enc.encumbrance_item_id <> p_header_id
							                 and adl.burdenable_raw_cost is not NULL  )
					      )
				    order by enc.encumbrance_item_id desc; -- Bug 3697483, changed order by
	   END IF ;

     IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':End','C');
   END IF;
  END open_ref_cursor ;

	-- ----------------------------------------------
	-- DOC: procedure get the totals raw and burden
	-- cost for award and expenditure type.
	-- ----------------------------------------------
	PROCEDURE PROC_GET_AWARD_EXP_TOTAL(	P_packet_id	NUMBER,
										P_award_id	NUMBER,
										P_EXP_TYPE	VARCHAR2
									   ) IS

		x_doc_type		VARCHAR2(3) ;
		x_act_raw		NUMBER ;
		x_burden_cost	NUMBER ;
		l_arrival_seq   NUMBER ;
		l_enc_raw       NUMBER ;
		l_exp_raw       NUMBER ;
		l_po_raw        NUMBER ;
		l_req_raw       NUMBER ;
		l_ap_raw        NUMBER ;

		l_enc_brc       NUMBER ;
		l_exp_brc       NUMBER ;
		l_po_brc        NUMBER ;
		l_req_brc       NUMBER ;
		l_ap_brc        NUMBER ;

		CURSOR get_burden_cost_limit is
 				SELECT gae.burden_cost_limit
   				  FROM gms_allowable_expenditures gae,
        			   gms_awards 				  ga
 		 		 where gae.allowability_schedule_id = ga.allowable_schedule_id
    			   and gae.expenditure_type         = P_EXP_TYPE
    			   and ga.award_id                  = P_award_id;
        --
		-- Start of comment
		-- bug			: 3092603
		-- Desc         : POOR PERFORMANCE FOR APXAPRVL ( INVOICE VALIDATION )
		-- Change desc  : l_arrival_seq code was added and decode was added
		--                to avoid multiple selects for each documents.
		--                Cursor changed was : C_ACT
		-- End of comment.
		--
		CURSOR C_ACT is
			SELECT   SUM( decode(pkt.document_type, 'ENC',(nvl(pkt.entered_dr,0) -nvl(pkt.entered_cr,0)), 0 ) ) enc_raw,
			         SUM( decode(pkt.document_type, 'EXP',(nvl(pkt.entered_dr,0) -nvl(pkt.entered_cr,0)), 0 ) ) exp_raw,
			         SUM( decode(pkt.document_type, 'PO', (nvl(pkt.entered_dr,0) -nvl(pkt.entered_cr,0)), 0 ) ) po_raw,
			         SUM( decode(pkt.document_type, 'REQ',(nvl(pkt.entered_dr,0) -nvl(pkt.entered_cr,0)), 0 ) ) req_raw,
			         SUM( decode(pkt.document_type, 'AP', (nvl(pkt.entered_dr,0) -nvl(pkt.entered_cr,0)), 0 ) ) ap_raw,
					 SUM( decode(pkt.document_type, 'ENC',nvl(pkt.burdenable_raw_cost,0), 0 ) ) enc_brc,
					 SUM( decode(pkt.document_type, 'EXP',nvl(pkt.burdenable_raw_cost,0), 0 ) ) exp_brc,
					 SUM( decode(pkt.document_type, 'PO', nvl(pkt.burdenable_raw_cost,0), 0 ) ) po_brc,
					 SUM( decode(pkt.document_type, 'REQ',nvl(pkt.burdenable_raw_cost,0), 0 ) ) req_brc,
					 SUM( decode(pkt.document_type, 'AP', nvl(pkt.burdenable_raw_cost,0), 0 ) ) ap_brc
	          FROM  GMS_BC_PACKETS 	PKT,
                    gms_budget_versions gbv
              WHERE pkt.award_id				= p_award_id
               and  pkt.expenditure_type		= p_exp_type
               and  pkt.status_code				in ('A', 'P','I' )
               and  burden_calculation_seq > 0
               and  gbv.budget_version_id       = pkt.budget_version_id
               and  gbv.budget_status_code             = 'B'
               and  substr(NVL(pkt.result_code,'P'),1,1) <> 'F'
              and  decode(pkt.status_code,
                           'A',1,
                           'P',decode(SIGN(NVL(entered_dr,0)-NVL(entered_cr,0)),
                                      -1,decode(pkt.packet_id,P_packet_id,1,0),1),
                           'I', decode(SIGN(NVL(entered_dr,0)-NVL(entered_cr,0)),
                                      -1,decode(pkt.packet_id,P_packet_id,1,0),1)
                                       ) = 1;

               -- burden_calculation_seq > 0 used instead of burden_calculation_seq IS NOT NULL
               -- to use the index, value populated for LIMIT scenario
               -- Filter criteria: pick all records that has completed burdenable raw cost calc.
               -- i.e.  burden_calculation_seq > 0 and that has not been posted to balance summary
               -- Look across budget versions ...

               -- Also, as  burden_calculation_seq is zero, current packet will not be considered ..
               -- Do not use parent_bc_packet_id is null as burden log has parent_bc_packet_id value

               -- No need to check with budget version .. Note: budget_version_id is not populated
               -- on records before cost plus, this can lead to the transactions being skipped.


BEGIN
     g_error_procedure_name := 'proc_get_award_exp_total';
     IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':Start','C');
   END IF;

			x_calc_zero_limit := FALSE ;

       		open   get_burden_cost_limit;
       		fetch  get_burden_cost_limit  into x_award_exp_limit;

       		if  get_burden_cost_limit%NOTFOUND then
          		x_award_exp_limit:= 0 ;
			ELSE
					IF x_award_exp_limit = 0 THEN

						x_calc_zero_limit := TRUE ;

					END IF ;
       		end if;

       		close  get_burden_cost_limit;

      		open   c_award_exp_total(p_award_id, p_exp_type);
      		fetch  c_award_exp_total  into x_rec_award_exp_tot  ;

       		IF  c_award_exp_total%NOTFOUND THEN
				x_rec_award_exp_tot.req_raw_cost		:= 0 ;
				x_rec_award_exp_tot.PO_raw_cost			:= 0 ;
				x_rec_award_exp_tot.enc_raw_cost		:= 0 ;
				x_rec_award_exp_tot.ap_raw_cost			:= 0 ;
				x_rec_award_exp_tot.exp_raw_cost		:= 0 ;
				x_rec_award_exp_tot.req_burdenable_cost	:= 0 ;
				x_rec_award_exp_tot.po_burdenable_cost	:= 0 ;
				x_rec_award_exp_tot.enc_burdenable_cost	:= 0 ;
				x_rec_award_exp_tot.AP_burdenable_cost	:= 0 ;
				x_rec_award_exp_tot.exp_burdenable_cost	:= 0 ;
       		END IF;

      		close   c_award_exp_total;
			-- ---------------------------------------------------
			-- Find out NOCOPY the unposted balances from GMS_BC_PACKETS
			-- The gms_award_exp_type_act_cost is updated in
			-- gms_gl_return_code process and burden_posted_flag
			-- is updated to 'Y'. It is possible that there exists
			-- some records for which funds_check has approved and
			-- amounts are not posted.
			-- ---------------------------------------------------
		    -- Start of comment
		    -- bug			: 3092603
		    -- Desc         : POOR PERFORMANCE FOR APXAPRVL ( INVOICE VALIDATION )
		    -- Change desc  : get the maximum arrival order sequence of the
			--                bc packets. This is used to determine the
			--                pending totals of raw and burdenable cost.
		    -- End of comment.
		    --
			SELECT max(arrival_seq)
			  into l_arrival_seq
			  from gms_bc_packet_arrival_order ;

			l_arrival_seq := NVL(l_arrival_seq,0) ;

			-- ----------------------------------------
			-- fetch pending cost from GMS_BC_PACKETS
			-- ----------------------------------------
		    -- Start of comment
		    -- bug			: 3092603
		    -- Desc         : POOR PERFORMANCE FOR APXAPRVL ( INVOICE VALIDATION )
		    -- Change desc  : get the document level breakups of the raw and
			--                burdenable raw cost for all the pending unposted
			--                transactions in bc packets. use cursor c_act.
		    -- End of comment.
		    --
			open c_act ;
			fetch c_act into l_enc_raw,
							 l_exp_raw,
							 l_po_raw,
							 l_req_raw,
							 l_ap_raw,
							 l_enc_brc,
							 l_exp_brc,
							 l_po_brc,
							 l_req_brc,
							 l_ap_brc ;

			close c_act ;

			x_rec_award_exp_tot.req_raw_cost		:=	x_rec_award_exp_tot.req_raw_cost        + nvl(l_req_raw,0) ;
			x_rec_award_exp_tot.req_burdenable_cost	:=	x_rec_award_exp_tot.req_burdenable_cost + nvl(l_req_brc,0) ;

			x_rec_award_exp_tot.po_raw_cost			:=	x_rec_award_exp_tot.po_raw_cost        + nvl(l_po_raw,0) ;
			x_rec_award_exp_tot.po_burdenable_cost	:=	x_rec_award_exp_tot.po_burdenable_cost + nvl(l_po_brc,0) ;

			x_rec_award_exp_tot.AP_raw_cost			:=	x_rec_award_exp_tot.AP_raw_cost        + nvl(l_ap_raw,0) ;
			x_rec_award_exp_tot.AP_burdenable_cost	:=	x_rec_award_exp_tot.AP_burdenable_cost + nvl(l_ap_brc,0) ;

			x_rec_award_exp_tot.ENC_raw_cost		:=	x_rec_award_exp_tot.ENC_raw_cost        + nvl(l_enc_raw,0) ;
			x_rec_award_exp_tot.ENC_burdenable_cost	:=	x_rec_award_exp_tot.ENC_burdenable_cost + nvl(l_enc_brc,0) ;

			x_rec_award_exp_tot.EXP_raw_cost		:=	x_rec_award_exp_tot.EXP_raw_cost        + nvl(l_exp_raw,0) ;
			x_rec_award_exp_tot.EXP_burdenable_cost	:=	x_rec_award_exp_tot.EXP_burdenable_cost + nvl(l_exp_brc,0) ;

		    -- Start of comment
		    -- bug			: 3092603
		    -- Desc         : POOR PERFORMANCE FOR APXAPRVL ( INVOICE VALIDATION )
		    -- End of bug fix.
		    --

			x_tot_raw	:=	x_rec_award_exp_tot.REQ_raw_cost +
						    x_rec_award_exp_tot.PO_raw_cost  +
						    x_rec_award_exp_tot.ENC_raw_cost +
						    x_rec_award_exp_tot.AP_raw_cost  +
						    x_rec_award_exp_tot.EXP_raw_cost  ;

			x_tot_burden :=	x_rec_award_exp_tot.REQ_burdenable_cost +
						    x_rec_award_exp_tot.PO_burdenable_cost  +
						    x_rec_award_exp_tot.ENC_burdenable_cost +
						    x_rec_award_exp_tot.AP_burdenable_cost  +
						    x_rec_award_exp_tot.EXP_burdenable_cost  ;

			x_cmt_tot_burden :=	x_rec_award_exp_tot.REQ_burdenable_cost +
						        x_rec_award_exp_tot.PO_burdenable_cost  +
						        x_rec_award_exp_tot.ENC_burdenable_cost +
						        x_rec_award_exp_tot.AP_burdenable_cost  ;


     IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':x_tot_raw:'||x_tot_raw||';'||'x_tot_burden:'||x_tot_burden||';'||'x_cmt_tot_burden:'||x_cmt_tot_burden,'C');
     END IF;

	EXCEPTION
        WHEN  RESOURCE_BUSY  THEN
        IF g_debug = 'Y' THEN
      	   gms_error_pkg.gms_debug (g_error_procedure_name||':Resource Busy Exception','C');
        END IF;
            -- We couldn't acquire the locks at this time so
            -- We need to abort the processing and have the
            -- stataus Failed .
            -- F40 - Unable to acquire Locks on GMS_AWARD_EXP_TYPE_ACT_COST
            -- ------------------------------------------------------------
			IF get_burden_cost_limit%ISOPEN THEN
				CLOSE get_burden_cost_limit ;
			END IF ;

			IF C_ACT%ISOPEN THEN
				CLOSE c_act ;
			END IF ;

			IF c_award_exp_total%ISOPEN THEN
				close c_award_exp_total ;
			END IF ;

          g_dummy := SQLERRM;
     	  IF g_debug = 'Y' THEN
      	     gms_error_pkg.gms_debug (g_error_procedure_name||':'||g_dummy,'C');
          END IF;

            RAISE ;
		WHEN others then
          IF g_debug = 'Y' THEN
        	   gms_error_pkg.gms_debug (g_error_procedure_name||':When Others Exception','C');
          END IF;

			IF get_burden_cost_limit%ISOPEN THEN
				CLOSE get_burden_cost_limit ;
			END IF ;

			IF C_ACT%ISOPEN THEN
				CLOSE c_act ;
			END IF ;

			IF c_award_exp_total%ISOPEN THEN
				close c_award_exp_total ;
			END IF ;

          g_dummy := SQLERRM;
     	  IF g_debug = 'Y' THEN
      	     gms_error_pkg.gms_debug (g_error_procedure_name||':'||g_dummy,'C');
          END IF;

			RAISE ;
	END PROC_GET_AWARD_EXP_TOTAL ;
    -- ============= END OF  PROC_GET_AWARD_EXP_TOTAL ==========================


-- ------------------------------------------------------------------------------------------------
-- Update expenditure_category and revenue category on gms_bc_packets because of change in RLMI API.
-- Update person_id,job_id,vendor_id columns on gms_bc_packets.
-- This is done before setup_rlmi is called Bug 2143160
-- ------------------------------------------------------------------------------------------------
PROCEDURE update_exp_rev_cat (x_packet_id IN NUMBER) IS
BEGIN
	  --
	  -- To update expenditure_category and revenue category
	  UPDATE gms_bc_packets pkt
		 SET (pkt.expenditure_category,pkt.revenue_category) =
                                       (select pe.expenditure_category,pe.revenue_category_code
					  from pa_expenditure_types pe
					 where pe.expenditure_type = pkt.expenditure_type)
	  WHERE  pkt.packet_id = x_packet_id;
END update_exp_rev_cat;
-- ------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------
-- This procedure updates the gms_bc_packets top_task_id and parent_resource_id for a packet
-- This is mainly used during interface process.
-- Bug 2143160
-- ------------------------------------------------------------------------------------------------
   PROCEDURE update_top_tsk_par_res (x_packet_id IN NUMBER) IS
   BEGIN
      UPDATE gms_bc_packets pkt
         SET pkt.top_task_id = (SELECT top_task_id
                                  FROM pa_tasks
                                 WHERE task_id = pkt.task_id)
       WHERE pkt.packet_id = x_packet_id
         AND pkt.top_task_id IS NULL;

      UPDATE gms_bc_packets pkt
         SET pkt.parent_resource_id = (SELECT parent_member_id
                                         FROM pa_resource_list_members
                                        WHERE resource_list_member_id = pkt.resource_list_member_id)
       WHERE pkt.packet_id = x_packet_id
         AND pkt.parent_resource_id IS NULL;

   END update_top_tsk_par_res;

-- ----------------------------------------------------------------------------------------------------
    -- -------------------------------------------------------------------------
    -- create_burden_adjustments : Function creates burden adjusmtent entry in gms_bc_packets
    -- -------------------------------------------------------------------------
    PROCEDURE create_burden_adjustments(p_rec_log               gms_burden_adjustments_log%ROWTYPE,
					p_project_id            pa_projects_all.project_id%type,
					p_task_id               pa_tasks.task_id%type,
					p_expenditure_item_date gms_bc_packets.expenditure_item_date%type,
                                        p_expenditure_org_id    gms_bc_packets.expenditure_organization_id%type,
					p_rlmi                  gms_bc_packets.resource_list_member_id%type,
					p_bud_task_id           gms_bc_packets.bud_task_id%type,
					p_ind_compiled_set_id   gms_bc_packets.ind_compiled_set_id%type
							          ) IS
       PRAGMA AUTONOMOUS_TRANSACTION; -- R12 Funds Management Uptake : Made this an autonomous procedure.

       x_rec_log	    gms_burden_adjustments_log%ROWTYPE ;
       l_top_task_id        gms_bc_packets.top_task_id%type;
       l_parent_resource_id gms_bc_packets.parent_resource_id%type;
       l_budget_version_id  gms_bc_packets.budget_version_id%type;

       l_stage              varchar2(25);

    BEGIN

     g_error_procedure_name := 'create_burden_adjustments';
     IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':Start','C');
     END IF;

	   x_rec_log	                := p_rec_log ;
   	   x_rec_log.last_update_date	:= SYSDATE ;
	   x_rec_log.last_updated_by	:= nvl(fnd_global.user_id,0) ;
	   x_rec_log.created_by		    := nvl(fnd_global.user_id,0) ;
	   x_rec_log.creation_date		:= SYSDATE ;
	   x_rec_log.last_update_login	:= nvl(fnd_global.user_id,0) ;


       -- Get set_of_books_id ..
       l_stage := 'Derive Set of Books';

       If g_set_of_books_id is null then
          Select set_of_books_id
	      into   g_set_of_books_id
	      from   pa_implementations;
       End If;

       -- Get top_task_id
       l_stage := 'Derive Top Task';

       Select top_task_id
       into   l_top_task_id
	   from   pa_tasks
       where  task_id = p_task_id;

       -- Get parent_member_id
       l_stage := 'Derive Parent Resource';

       Select parent_member_id
       into   l_parent_resource_id
	   from   pa_resource_list_members
       where  resource_list_member_id = p_rlmi;

       -- Get budget_version_id
       l_stage := 'Derive Budget Version';

       Select budget_version_id
       into   l_budget_version_id
       from   gms_budget_versions
       where  award_id           = x_rec_log.award_id
       and    project_id         = p_project_id
       and    budget_status_code ='B'
       and    current_flag       = 'Y';

       -- Create burden adjustment entry ..
       l_stage := 'Create Burden Entry';

       insert into gms_bc_packets(
                   packet_id,
                   project_id,
                   award_id,
                   task_id,
				   budget_version_id,
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
                   document_header_id,
                   document_distribution_id,
                   entered_dr,
                   entered_cr,
                   bc_packet_id,
                   request_id,
                   burden_adj_bc_packet_id, -- burden_adj_bc_packet_id will store the bc_packet_id of txn. being FC'ed
			       parent_bc_packet_id, -- parent_bc_packet_id will store the bc_packet_id of txn. being FC'ed
                   burden_adjustment_flag,
  		 	       burdenable_raw_cost,
				   resource_list_member_id,
				   bud_task_id,
				   ind_compiled_set_id,
				   top_task_id,
				   parent_resource_id,
				   burden_calculation_seq,
                   source_event_id) /* Added for Bug 5645290 */
            values(x_rec_log.packet_id,
                   p_project_id,
  	               x_rec_log.award_id,
                   p_task_id,
				   l_budget_version_id,
  		           x_rec_log.expenditure_type,
  		           p_expenditure_item_date,
  		           decode(x_rec_log.document_type,'EXP','A','E'), -- Actual_flag
  		           decode(x_rec_log.document_type,'EXP','P','I'), -- Bug 	5037180 : Status_code is always 'P'
  		           x_rec_log.last_update_date,
  		           x_rec_log.last_updated_by,
  		           x_rec_log.created_by,
  		           x_rec_log.creation_date,
  		           x_rec_log.last_update_login,
  		           g_set_of_books_id,
  		           decode(x_rec_log.document_type,'REQ','Requisitions',
                                             'PO','Purchases',
                                             'AP','Purchase Invoices',
                                             'ENC','Project Accounting'), --Category
  		           decode(x_rec_log.document_type,'REQ','Purchasing',
                                             'PO','Purchasing',
                                             'AP','Payables',
                                             'ENC','Miscellaneous Transaction'), -- Source:Hard coding 'Misc Tran ..'
  		           'N', --transferred_flag
  		           x_rec_log.document_type,
  		           p_expenditure_org_id,
  		           x_rec_log.document_header_id,
  		           x_rec_log.document_distribution_id,
  		           0, --entered_dr,
  		           0, --entered_cr
  		           gms_bc_packets_s.nextval,
  		           g_request_id,
  		           x_rec_log.bc_packet_id,
  		           x_rec_log.bc_packet_id,
  		           'Y', -- burden_adjustment_flag,
  		           x_rec_log.adj_burdenable_amount,
			       p_rlmi,
				   p_bud_task_id,
				   p_ind_compiled_set_id,
				   l_top_task_id,
				   l_parent_resource_id,
			       x_rec_log.adjustment_id,
                           (select source_event_id
                            from gms_bc_packets
                            where bc_packet_id = x_rec_log.bc_packet_id));  /* Added for Bug 5645290 */


	   -- ---------------------------------------------------------+
	   -- Update the running total of award and expenditure type.
	   -- ---------------------------------------------------------+
	   IF x_rec_log.source_flag = 'N' THEN
	   	   return  ;
	   END IF ;

	   IF p_rec_log.document_type = 'REQ' THEN
		  x_rec_award_exp_tot.req_burdenable_cost	:= x_rec_award_exp_tot.req_burdenable_cost +
												   nvl(p_rec_log.adj_burdenable_amount,0) ;
	   ELSIF p_rec_log.document_type = 'PO' THEN
	   	   x_rec_award_exp_tot.PO_burdenable_cost	:= x_rec_award_exp_tot.PO_burdenable_cost +
												   nvl(p_rec_log.adj_burdenable_amount,0) ;
	   ELSIF p_rec_log.document_type = 'ENC' THEN
		  x_rec_award_exp_tot.ENC_burdenable_cost	:= x_rec_award_exp_tot.ENC_burdenable_cost +
												   nvl(p_rec_log.adj_burdenable_amount,0) ;
	   ELSIF p_rec_log.document_type = 'AP' THEN
		  x_rec_award_exp_tot.AP_burdenable_cost	:= x_rec_award_exp_tot.AP_burdenable_cost +
												   nvl(p_rec_log.adj_burdenable_amount,0) ;
	   ELSIF p_rec_log.document_type = 'EXP' THEN
		  x_rec_award_exp_tot.EXP_burdenable_cost	:= x_rec_award_exp_tot.EXP_burdenable_cost +
												   nvl(p_rec_log.adj_burdenable_amount,0) ;
	   END IF ;

	   x_tot_burden:= x_tot_burden + nvl(p_rec_log.adj_burdenable_amount,0)  ;

     IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':End','C');
     END IF;

    COMMIT; -- R12 Funds Management Uptake : Made this an autonomous procedure.

    EXCEPTION
	   When others then

          g_dummy := SQLERRM;
     	  IF g_debug = 'Y' THEN
      	     gms_error_pkg.gms_debug (g_error_procedure_name||':'||l_stage||';'||g_dummy,'C');
          END IF;

		  RAISE ;
    END create_burden_adjustments;
    -- ======  END create_burden_adjustments ================================================

    -- ----------------------------------------------------
    -- get_prev_unposted_adj : This gets from the log all
    -- the adjustments not applied to the documents.
    -- ----------------------------------------------------
    FUNCTION  get_prev_unposted_adj( p_header_id	NUMBER,
	   							     p_dist_id		NUMBER,
								     p_doc_type		varchar2 )
    return NUMBER IS

       X_prev_adj	NUMBER  ;

	   Cursor get_prev_adj is
		SELECT SUM(burdenable_raw_cost)
		  FROM gms_bc_packets
	     WHERE document_header_id 		= p_header_id
		   AND document_distribution_id = p_dist_id
		   AND document_type			= p_doc_type
		   AND burden_adjustment_flag   = 'Y'
           AND nvl(burden_posted_flag,'N') <> 'X'
	   AND status_code  IN ('P','A','I');

           -- When the burdenable raw cost is posted on the source document, burden_posted_flag wil be updated to 'X'
           -- Also, status_code of 'X' means that the amount has been posted into Award-Exp burden balances ..
    BEGIN
        X_prev_adj	:= 0 ;
	    OPEN  get_prev_adj ;
    	fetch get_prev_adj INTO X_prev_adj ;
    	IF get_prev_adj%NOTFOUND THEN
	   	   X_prev_adj := 0 ;
	    END IF ;
    	return NVL(X_prev_adj,0) ;
    EXCEPTION
    	WHEN OTHERS THEN

          g_dummy := SQLERRM;
     	  IF g_debug = 'Y' THEN
      	     gms_error_pkg.gms_debug (g_error_procedure_name||':'||g_dummy,'C');
          END IF;

    		RAISE ;
    END get_prev_unposted_adj ;
    -- ==============    END OF get_prev_unposted_adj ==========

	-- ---------------------------------------------------------------
	-- The following procedure gets idc_schedule_id for an award
	-- based on override schedules and using pa_cost_plus gets an rate
	-- schedule revision ID.
	-- ---------------------------------------------------------------
	PROCEDURE GET_AWARD_IND_RATE_SCH_REV_ID(x_award_id        IN Number,
						x_task_id        IN Number, -- Bug 2097676: Multiple IDC Build
                                        	x_exp_item_date   IN Date,
                                        	x_rate_sch_rev_id IN OUT NOCOPY Number,
                                        	x_status          IN OUT NOCOPY Number,
                                        	x_stage           IN OUT NOCOPY Number)
	IS
 		l_rate_sch_id     NUMBER(15);
 		l_sch_fixed_date  DATE;

-- Start of code, Bug 2097676: Multiple IDC Build

		l_project_id  NUMBER;
		l_task_id     NUMBER;

		CURSOR	prj_task IS
		SELECT	project_id, top_task_id
		FROM	pa_tasks
		WHERE	task_id = x_task_id;

		CURSOR 	override_schedule_task( l_task_id number) IS
		SELECT 	idc_schedule_id, cost_ind_sch_fixed_date
		FROM 	gms_override_schedules
		WHERE 	award_id = x_award_id
		AND	task_id = l_task_id;

		CURSOR 	override_schedule_project(l_project_id number) IS
		SELECT 	idc_schedule_id, cost_ind_sch_fixed_date
		FROM 	gms_override_schedules
		WHERE 	award_id = x_award_id
		AND	project_id = l_project_id
		AND	task_id is NULL;

-- End of code, Bug 2097676: Multiple IDC Build

	BEGIN

  		-- initialize  variables.
    	x_stage := 250;

-- Start of code, Bug 2097676: Multiple IDC Build

		OPEN   prj_task;
		FETCH  prj_task INTO l_project_id, l_task_id;
		CLOSE  prj_task;

		OPEN   override_schedule_task(l_task_id);
		FETCH  override_schedule_task INTO l_rate_sch_id, l_sch_fixed_date;
		CLOSE  override_schedule_task;

		IF l_rate_sch_id is NULL THEN
			OPEN   override_schedule_project(l_project_id);
			FETCH  override_schedule_project INTO l_rate_sch_id, l_sch_fixed_date;
			CLOSE  override_schedule_project;
		END IF;

		IF l_rate_sch_id is NULL THEN	 -- End of code, Bug 2097676: Multiple IDC Build
   			SELECT 	idc_schedule_id,
				cost_ind_sch_fixed_date
   			INTO  	l_rate_sch_id,
             			l_sch_fixed_date
   			FROM 	gms_awards_all -- bug 3117503. changed to _all.
   			WHERE 	award_id = x_award_id;
		END IF;   --  Bug 2097676: Multiple IDC Build

   		IF l_rate_sch_id is not null THEN
       		  pa_cost_plus.get_revision_by_date  (l_rate_sch_id,
           		                                  l_sch_fixed_date,
               		                              X_EXP_ITEM_DATE,
                   		                          X_RATE_SCH_REV_ID,
                       		                      X_STATUS,
                           		                  X_STAGE );
   		ELSE
     		 x_status := 1;                      -- Award must have a burden schedule
   		END IF;

   		RETURN;

 	 EXCEPTION
    	WHEN NO_DATA_FOUND THEN
       	   x_status := 1;                  -- Award must have a burden schedule
    	WHEN OTHERS THEN
     	    x_status := SQLCODE;             -- System error
	END get_award_ind_rate_sch_rev_id;

	-- ----------------------------------------------------------------------------------
	-- BUG 1522671 - For REQ,PO,AP if there is any idc rate changes when REQ->PO->AP
	-- 		 then the reversing committments should be based on the orginal
	--		 idc rate. This is also applicable if the above committments are reversed.
	--		 For this the orignal idc rate schedule (ind_compiled_set_id)
	--		 is picked from gms_award_distributions for the committements
	-- ----------------------------------------------------------------------------------

	-- ==================================================================================
	-- bug : 1698738 - IDC RATE CHANGES CAUSE DISCREPENCIES IN S.I. INTERFACE TO PROJECTS.
	-- Reorganized award_cmt_compiled_set_id
	-- added l_calc_new
	-- added condition for doc_type = 'EXP'
	-- ===================================================================================
	-- 2305048 ( DATA ERRORS MAKE IT IMPOSSIBLE TO BRING SUPPLIER INVOICES INTO OGA )
	FUNCTION award_cmt_compiled_set_id
        		( 	x_document_header_id          IN NUMBER,
          			x_document_distribution_id    IN NUMBER,
          			x_task_id                     IN NUMBER,
          			x_document_type               IN VARCHAR2,
          			x_expenditure_item_date       IN DATE,
                                p_expenditure_type	      IN VARCHAR2, --Bug 3003584
          			x_organization_id             IN NUMBER,
          			x_schedule_type               IN VARCHAR2,
          			x_award_id                    IN NUMBER) RETURN NUMBER IS

    	l_compiled_set_id          number;
		l_calc_new		   		   BOOLEAN ;

    BEGIN

	l_calc_new	:= FALSE ;

        IF x_document_type = 'REQ' THEN

        	BEGIN
			select adl.ind_compiled_set_id
			  into l_compiled_set_id
			  from gms_award_distributions adl
                               -- R12 Funds Managment Uptake : Obsolete Ap/PO/REQ usage as its not required
			       --po_req_distributions_all por
			 where adl.award_id 		= x_award_id
			   and adl.task_id  		= x_task_id
			   and adl.distribution_id 	= x_document_distribution_id
			   and adl.document_type 	= 'REQ'
			   and adl.adl_status 		= 'A'
			   and adl.fc_status 		= 'A';
                           -- R12 Funds Managment Uptake : Obsolete Ap/PO/REQ usage as its not required
   			   --and adl.award_set_id		= por.award_id
			   --and por.distribution_id	= x_document_distribution_id ;

            	EXCEPTION
               	   when no_data_found then
					l_calc_new := TRUE ;
             	END;
       	ELSIF x_document_type = 'PO' THEN
		BEGIN
			select adl.ind_compiled_set_id
			  into l_compiled_set_id
			  from gms_award_distributions adl
                               -- R12 Funds Managment Uptake : Obsolete Ap/PO/REQ usage as its not required
 			       -- po_distributions_all    pod
			 where adl.award_id 			= x_award_id
			   and adl.task_id  			= x_task_id
			   and adl.po_distribution_id 	= x_document_distribution_id
			   and adl.document_type 		= 'PO'
			   and adl.adl_status 			= 'A'
			   and adl.fc_status 			= 'A'
			   and adl.adl_line_num			= 1 ;
                           -- R12 Funds Managment Uptake : Obsolete Ap/PO/REQ usage as its not required
			   /*and pod.po_distribution_id	= x_document_distribution_id
			   and pod.award_id				= adl.award_set_id ;*/

            	EXCEPTION
            	   when no_data_found then
					l_calc_new := TRUE ;
             	END;
         ELSIF x_document_type = 'AP' THEN
         	BEGIN
			select adl.ind_compiled_set_id
			  into l_compiled_set_id
			  from gms_award_distributions adl
                               -- R12 Funds Managment Uptake : Obsolete Ap/PO/REQ usage as its not required
			       -- ap_invoice_distributions_all apd
			 where adl.award_id 		= x_award_id
			   and adl.task_id  		= x_task_id
			   and adl.invoice_id 		= x_document_header_id
			   and adl.invoice_distribution_id = x_document_distribution_id -- AP Lines change
			   and adl.document_type 	= 'AP'
			   and adl.adl_status 		= 'A'
			   and adl.fc_status 		= 'A'
                           -- R12 Funds Managment Uptake : Obsolete Ap/PO/REQ usage as its not required
			   /*and apd.invoice_id		= x_document_header_id
			   and apd.invoice_distribution_id = x_document_distribution_id -- AP Lines change
			   and apd.award_id			= adl.award_set_id */
			   and adl.adl_line_num		= 1 ;
            	EXCEPTION
            		when no_data_found then
						 l_calc_new := TRUE ;
        	END;
         ELSIF x_document_type = 'EXP' THEN
		BEGIN
			select ind_compiled_set_id
			  into l_compiled_set_id
			  from gms_award_distributions
			 where award_id = x_award_id
			   and task_id  = x_task_id
			   and expenditure_item_id 	= x_document_header_id
			   and cdl_line_num 		= x_document_distribution_id
			   and document_type 		= 'EXP'
			   and adl_status 		= 'A'
			   and fc_status 		= 'A';
		EXCEPTION
            		when no_data_found then
						 l_calc_new := TRUE ;
		END ;
         ELSE
	       l_calc_new := TRUE ;
         END IF;

	 IF l_calc_new THEN
		l_compiled_set_id := get_award_cmt_compiled_set_id
					(   	x_task_id,
						x_expenditure_item_date,
                                                p_expenditure_type, --Bug 3003584
						x_organization_id,
						x_schedule_type,
						x_award_id);
	 END IF ;

    	 return l_compiled_set_id;
    EXCEPTION
    	 when others then
        	raise ;
    END award_cmt_compiled_set_id;

  	FUNCTION get_award_cmt_compiled_set_id
          ( x_task_id               IN NUMBER,
            x_expenditure_item_date IN DATE,
            p_expenditure_type      IN VARCHAR2, --Bug 3003584
            x_organization_id       IN NUMBER,
            x_schedule_type         IN VARCHAR2,
            x_award_id              IN NUMBER)
  	RETURN NUMBER IS
    l_stage number  ;
    l_status number ;
    l_rate_sch_rev_id number;
    l_compiled_set_id number;
    l_cp_structure                pa_cost_plus_structures.cost_plus_structure%TYPE; --Bug 3003584
    l_cost_base                   pa_cost_bases.cost_base%TYPE;  --Bug 3003584

  	BEGIN

    l_stage  := 275;
    l_status := 0;

    -- For award level commitments, use award schedule

    if (x_award_id is not null ) then
       get_award_ind_rate_sch_rev_id(x_award_id,
				     x_task_id,  -- Bug 2097676, Multiple IDC Schedule Build
                                     x_expenditure_item_date,
                                     l_rate_sch_rev_id,
                                     l_status,
                                     l_stage);

        if (l_rate_sch_rev_id is not null ) then
                    --Begin Bug 3003584
             pa_cost_plus.get_cost_plus_structure (
                     rate_sch_rev_id=> l_rate_sch_rev_id,
                     cp_structure=> l_cp_structure,
                     status=> l_status,
                     stage => l_stage
                  );

                  IF (l_status <> 0)
                  THEN
                     RETURN NULL;
                  END IF;

                  pa_cost_plus.get_cost_base (
                     exp_type=> p_expenditure_type,
                     cp_structure=> l_cp_structure,
                     c_base=> l_cost_base,
                     status=> l_status,
                     stage => l_stage);

                  IF (l_status <> 0)
                  THEN
                     RETURN NULL;
                  END IF;

                  --End Bug 3003584
             pa_cost_plus.get_compiled_set_id(l_rate_sch_rev_id,
                                              x_organization_id,
                                              l_cost_base, --Bug 3003584
                                              l_compiled_set_id,
                                              l_status,  l_stage);
        else
            l_compiled_set_id := null;

        end if;
    end if;
    return l_compiled_set_id;

   	EXCEPTION
    when others then
        raise ;
  	END get_award_cmt_compiled_set_id;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

FUNCTION create_adjplus_log(	P_doc_type		IN		varchar2,
				p_adj_amount	        IN		NUMBER,
				p_award_id		IN		NUMBER,
				p_exp_type		IN		varchar2,
				p_packet_id		IN		NUMBER,
				p_bc_packet_id	        IN		NUMBER,
				p_header_id		IN		NUMBER,
				p_dist_id		IN		NUMBER,
				p_only_one		IN 		BOOLEAN,
				p_adjustment_id	        IN OUT NOCOPY 	NUMBER,
				p_line_num		IN OUT NOCOPY 	NUMBER )
return NUMBER is

	x_adjusted_amount	NUMBER ;
	x_dummy				NUMBER ;
	x_dummy1			NUMBER ;
	x_adj_logamt		NUMBER ;
	x_adjustment_id		NUMBER ;
	x_line_num			NUMBER ;
	x_run_total			NUMBER ;
	x_dist_id			NUMBER ;
	x_doc_dist_id		NUMBER ;
	x_hdr_id            NUMBER ;
	x_we_are_done		BOOLEAN	;
	x_doc_type			varchar2(3) ;
	x_rec_log			gms_burden_adjustments_log%ROWTYPE ;
    x_adj_allowed       NUMBER ;
    l_calling_seq       varchar2(30) ;
    C_doc_ADJ           c_adj_rec ;
    adj_rec             commitRecTyp ;

	--
	-- 4004559 - PJ.M:B8:P13:OTH:PERF: FULL TABLE SCAN COST
	-- document type criteria was added to remove the FTS.
	--
	cursor c1 is
	   select sum(burdenable_raw_cost)
	     from gms_bc_packets
        where document_header_id       = x_hdr_id
	      and document_distribution_id = x_doc_dist_id
	      and burden_adjustment_flag   = 'Y'
		  and nvl(burden_posted_flag,'N') <> 'X'
	      and status_code              in ('A','P','I')
		  and document_type in ( 'PO','REQ', 'AP', 'ENC', 'EXP' ) ;

          -- Burden_posted_flag will be update to 'X' when the source document is updated with the
          -- Burdenable_raw_cost amount.This check will ensure that the cursor c1 does not pick these transactions.
          -- Also, only burden adjustment trasnaction, i.e. trasnactions created during burden adjustments needs to be
          -- considerde here .. earlier this select was on the burden log table ..

BEGIN

     g_error_procedure_name := 'create_adjplus_log';
     IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':Start','C');
     END IF;

	x_adjusted_amount := 0;
	x_dummy		      := 0 ;
	x_dummy1	      := 0 ;
	x_adj_logamt      := 0 ;
    l_calling_seq     := 'CREATE_ADJPLUS_LOG' ;
	-- ----------------------------------------------
	-- P_doc_type = Document need to be adjusted.
	-- p_adj_amount = Amount needs to be adjusted.
	-- The pattern of adjustment used is last in
	-- 1st to be adjusted.  LIFO.
	-- ----------------------------------------------
     IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':p_doc_type:'||p_doc_type||';'||'x_dist_id:'||x_dist_id||';'||'p_adj_amount:'||p_adj_amount,'C');
     END IF;


	-- ----------------------------------------------------
	-- BUG: 1362283 - ENC burdenable raw cost not adjusted
	-- when AP resereved and need to be adjusted from ENC.
	-- ENC view always has dist_id = 1 and for AP also 1st
	-- dist_id = 1 so 'and doc.distribution_id <> x_dist_id'
	-- returns false and no data found for adjustment.
	-- this is fixed by adding x_dist_id  := 0 ;for ENC.
	-- ------------------------------------------------------
	x_dist_id  := p_dist_id ;
	IF p_doc_type = 'ENC' THEN
	   x_dist_id  := 0 ;
	ELSE
	   x_dist_id  := p_dist_id ;
	END IF ;

	x_adjusted_amount	:= 0 ;
	x_dummy			:= 0 ;
    x_dummy1                := 0 ;
	x_run_total		:= 0 ;
	x_adjustment_id	 	:= p_adjustment_id ;
	x_line_num		:= nvl(p_line_num,0)	;
	x_doc_type		:= p_doc_type ;
	x_adj_allowed           := 0 ;

    -- ==============================================================================
    -- BUG : 2982977 - GMS: COSTING AND FUNDSCHECK ON USAGES RUNNING FOR OVER TWO DAYS
	-- We don't want to adjust any transactions from the REQ,PO and ENC if the total
	-- burdenable raw cost for that doc is ZERO.
	-- This will avoid the loop of adjustments across the doc and save the processing
	-- time.
	-- Code chages starts here.
	--   New variables added : x_adj_allowed , x_dummy1 , x_doc_dist_id
        -- FOLLOW thru the CHANGE REQUEST FOR THE CODE CHANGES ->Change request : 2982977
	-- ================================================================================


	-- Change request : 2982977
	select
                decode( p_doc_type, 'REQ', x_rec_award_exp_tot.req_burdenable_cost,
			            'PO',  x_rec_award_exp_tot.po_burdenable_cost,
			            'ENC', x_rec_award_exp_tot.enc_burdenable_cost, 1 )
	  into x_adj_allowed
	  from dual ;

     IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':x_adj_allowed:'||x_adj_allowed,'C');
     END IF;

	    -- Change request : 2982977
     IF NVL( x_adj_allowed, 0) <> 0 THEN

		   -- 3465191
		   -- open cursor using the base table
		   --
           l_calling_seq := 'CREATE_ADJPLUS_LOG' ;
           open_ref_cursor( c_doc_adj,
				            x_doc_type,
					        p_award_id,
					        p_exp_type,
					        x_dist_id,
					        NULL, --p_header_id
					        l_calling_seq)  ;
	   LOOP

	      fetch c_doc_adj into adj_rec ;

		  IF c_doc_adj%NOTFOUND THEN
		     close c_doc_adj ;
		     EXIT ;
		  END IF ;

		  x_dummy           := adj_rec.burden ;
		  x_hdr_id          := adj_rec.header_id ;
		  -- Change request : 2982977
		  x_doc_dist_id     := adj_rec.dist_id ;

		-- Change request : 2982977
		open c1 ;
		fetch c1 into x_adj_logamt ;
		close c1 ;

		-- ====================================================
		-- subtract the unposted adjusted amount from the
		-- amount of the doc. the adjusted log amount is -ve
		-- thats why PLUS will be okay.
		-- ===================================================
		-- Change request : 2982977
		x_dummy := x_dummy + NVL(x_adj_logamt,0) ;

		IF p_doc_type = 'REQ' THEN
			IF (x_rec_award_exp_tot.req_burdenable_cost	- x_dummy ) < 0 THEN
				x_dummy := x_rec_award_exp_tot.req_burdenable_cost ;
			END IF ;
		ELSIF p_doc_type = 'PO' THEN
			IF (x_rec_award_exp_tot.PO_burdenable_cost	- x_dummy ) < 0 THEN
				x_dummy := x_rec_award_exp_tot.PO_burdenable_cost ;
			END IF ;
		ELSIF p_doc_type = 'ENC' THEN
			IF (x_rec_award_exp_tot.ENC_burdenable_cost	- x_dummy ) < 0 THEN
				x_dummy := x_rec_award_exp_tot.ENC_burdenable_cost ;
			END IF ;
		END IF ;

		x_run_total	:= x_dummy + x_run_total ;

		IF p_adj_amount <= x_run_total THEN

			-- Never Adjusted as of yet.
	   		x_dummy         := p_adj_amount - ( x_run_total - x_dummy) ;
			x_run_total	    := p_adj_amount ;
			x_we_are_done	:= TRUE ;
		END IF ;

		IF x_adjustment_id  IS NULL THEN
			select gms_adjustments_id_s.NEXTVAL
			  INTO x_adjustment_id
			  FROM dual ;
		END IF ;

		x_line_num			        := x_line_num + 1 ;
		x_rec_log.adjustment_id		:= x_adjustment_id ;
		x_rec_log.line_num		    := x_line_num ;
		x_rec_log.document_header_id:= adj_rec.header_id ;
		x_rec_log.document_type		:= p_doc_type ;
		x_rec_log.amount		    := 0 ;
		x_rec_log.source_flag		:= 'Y' ;
		x_rec_log.award_set_id		:= adj_rec.award_set_id ;
		x_rec_log.adl_line_num		:= adj_rec.adl_line_num ;
		x_rec_log.award_id		    := p_award_id ;
		x_rec_log.expenditure_type	:= p_exp_type ;
		x_rec_log.packet_id		    := p_packet_id ;
		x_rec_log.bc_packet_id		:= p_bc_packet_id ;
		x_rec_log.document_distribution_id	:= adj_rec.dist_id ;
		x_rec_log.adj_burdenable_amount		:= x_dummy * -1 ;

		-- ------------------------------------------------------
		-- Create a adjustment log for this ITEM.
		-- ------------------------------------------------------

			create_burden_adjustments(x_rec_log,
									  adj_rec.project_id,
									  adj_rec.task_id,
									  adj_rec.expenditure_item_date,
									  adj_rec.expenditure_organization_id,
									  adj_rec.resource_list_member_id,
									  adj_rec.bud_task_id,
								      adj_rec.ind_compiled_set_id) ;

		-- Change request : 2982977
		IF p_doc_type = 'REQ' THEN
		   x_dummy1 := x_rec_award_exp_tot.req_burdenable_cost ;
		ELSIF p_doc_type = 'PO' THEN
		   x_dummy1 := x_rec_award_exp_tot.po_burdenable_cost ;
		ELSIF p_doc_type = 'ENC' THEN
		   x_dummy1 := x_rec_award_exp_tot.enc_burdenable_cost ;
		END IF ;


		IF x_we_are_done THEN
		  IF c_doc_adj%ISOPEN THEN
		     CLOSE c_doc_adj ;
		  END IF ;
		  EXIT ;
		END IF ;

		-- Change request : 2982977
		IF x_dummy1 = 0 THEN
		   -- nothing more to adjust for this document
		   -- so exit out of this loop.
		   IF c_doc_adj%ISOPEN THEN
		      CLOSE c_doc_adj ;
		   END IF ;

		   EXIT ;
		END IF ;
	   END LOOP ;
	END IF ;
    IF c_doc_adj%ISOPEN THEN
       CLOSE c_doc_adj ;
    END IF ;

	x_dummy	:=	0 ;

	p_adjustment_id	 	:= x_adjustment_id ;
	p_line_num		:= nvl(x_line_num,0)	;
	IF x_we_are_done OR p_doc_type = 'ENC'  OR p_only_one THEN
		return x_run_total ;
	END IF ;

	IF x_run_total < p_adj_amount THEN

		x_dummy := p_adj_amount - x_run_total ;

		IF x_doc_type = 'REQ' THEN
	  	     x_doc_type := 'PO' ;
		ELSIF 	x_doc_type = 'PO' THEN
	   		x_doc_type := 'ENC' ;
		END IF ;

		x_dummy := create_adjplus_log(	x_doc_type ,
						x_dummy,
						p_award_id,
						p_exp_type,
						p_packet_id,
						p_bc_packet_id,
						p_header_id,
						p_dist_id,
						p_only_one,
						x_adjustment_id	,
						x_line_num )  ;

	END IF ;

	x_run_total :=	x_run_total + x_dummy ;

	p_adjustment_id	 	:= x_adjustment_id ;
	p_line_num		:= nvl(x_line_num,0)	;
	return ( x_run_total );


EXCEPTION
	WHEN others then

          g_dummy := SQLERRM;
     	  IF g_debug = 'Y' THEN
      	     gms_error_pkg.gms_debug (g_error_procedure_name||':'||g_dummy,'C');
          END IF;

		RAISE ;
END create_adjplus_log ;

FUNCTION  SELF_ADJUSTMENT(	p_doc_type	varchar2 ,
							p_record bc_packets%ROWTYPE,
							p_adj_amount     IN  NUMBER,
							p_adjustment_id	IN OUT NOCOPY NUMBER,
							p_line_num 	IN OUT NOCOPY NUMBER) return NUMBER is
	x_adjustment_id	NUMBER ;
	x_line_num		NUMBER ;
	x_run_total		NUMBER ;
	x_dummy			NUMBER ;
	x_diff			NUMBER ;
    X_done          BOOLEAN ;
    X_doc_ADJ       c_adj_rec ;
    C_REC           commitRecTyp ;
    X_rec_log       gms_burden_adjustments_log%ROWTYPE  ;
	x_adj_balance	NUMBER  ;
    l_calling_seq varchar2(30) ;

BEGIN

     g_error_procedure_name := 'self_adjustment';
     IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':Start','C');
     END IF;

	x_adj_balance := 0 ;
    l_calling_seq := 'SELF_ADJUSTMENT' ;
	x_adj_balance	:= p_adj_amount ;
	x_adjustment_id	:= p_adjustment_id ;
	x_line_num		:= p_line_num ;
    l_calling_seq   := 'SELF_ADJUSTMENT' ;

	-- bug 3465191
	-- performance fix.
    open_ref_cursor ( X_doc_ADJ ,
				      p_doc_type,
					  p_record.award_id,
					  p_record.expenditure_type,
					  p_record.document_distribution_id,
					  p_record.document_header_id,
					  l_calling_seq )  ;
	LOOP
       fetch x_doc_adj into c_rec ;
       IF x_doc_adj%notfound THEN
          close x_doc_adj ;
          EXIT ;
       END IF ;

	   --FOR C_REC IN X_DOC_ADJ LOOP
           -- Amount already posted during summarization;
	   x_dummy	:= c_rec.burden; -- + get_prev_unposted_adj( C_REC.header_id,
							     --							 C_REC.dist_id,
						         --								 p_doc_type ) ;

		-- --------------------------------------------------------
		-- BUG:1337438 PO_Burdenable_cost is off
		-- What was happening is that previously computed PO with
		-- 0 burden was adjusted with -Burden which is wrong.
		--
		-- ** July 25, 2001
		-- BUG 1833325 - IDC LIMIT SCENARIO: TWO PROJECTS FUNDING SAME AWARD,
		-- CANCELLED REQUISITION
		-- Req adjustments didn't happen correctly after Req cancellation.
		-- =========================================================================
		--IF p_doc_type in ('PO', 'REQ') and nvl(x_dummy,0) = 0 THEN
		IF p_doc_type in ('PO','REQ')  THEN
			-- -----------------------------------------------
			-- BUG FIXED :UNIT TEST
			-- Following was added because of following error.
			-- PO1	= 30/30 , IDC=100
			-- PO2  = 80/60 , IDC=100
			-- Cancel PO1 -> 0/0
			-- ADJ    PO2 -> 80/100.
			-- After the following changes it worked okay.
			-- -----------------------------------------------
			IF nvl(x_dummy,0) = 0 THEN
				x_diff := 0 ;
			ELSE
	        	x_diff	:= abs(x_dummy) - C_REC.amount ;
			END IF ;
		ELSE
	        x_diff	:= C_REC.amount - abs(x_dummy) ;
		END IF ;
        -- ------------------------------------------------
        -- This is done for AP with MEMO type adjustments.
        -- ------------------------------------------------
		-- BUG FIXED :UNIT TEST
		-- ------------------------------------------------
        IF x_adj_balance < 0 and p_doc_type = 'AP' THEN
            IF x_dummy >= 0 THEN --Change from >  to >= for bug 2311261
                x_diff := x_dummy + x_adj_balance ;
                IF x_diff <= 0 THEN
                    x_diff := x_dummy ;
                ELSE
                    x_diff := x_adj_balance;  -- Added for bug 2311261
                END IF;
            ELSE
                x_diff := 0 ;  -- Added for bug 2311261
            END IF ;
        END IF ;

	    x_dummy := ABS(x_adj_balance) - abs(x_diff) ;

		IF x_dummy <= 0  THEN
		   -- ------------------------------------------------------------------------------
		   -- BUG: 1337294 REQ_burdenable_costvalue is off incase of PO less than REQ amount
		   --x_dummy 	  := ABS(x_adj_balance) ; Changed...
		   -- ------------------------------------------------------------------------------
		   IF p_doc_type = 'AP' THEN
			  x_dummy 	  := ABS(x_adj_balance) ;
		   ELSE
			x_dummy 	  := x_adj_balance ;
		   END IF ;
			x_adj_balance := 0 ;
			x_done := TRUE ;
		ELSE
			x_dummy	:= x_diff ;
            -- ------------------------------------------------
            -- This is done for AP with MEMO type adjustments.
            -- ------------------------------------------------
            IF x_adj_balance < 0 THEN
    			x_adj_balance := (ABS(x_adj_balance) - ABS(x_diff)) * -1  ;
            ELSE
			    x_adj_balance := x_adj_balance - x_diff ;
            END IF ;
		END IF ;

		IF x_dummy <> 0 THEN

			IF x_adjustment_id  IS NULL THEN
				select gms_adjustments_id_s.NEXTVAL
				  INTO x_adjustment_id
				  FROM dual ;
			END IF ;

			x_line_num					:= NVL(x_line_num,0) + 1 ;    -- BRC.1
			x_rec_log.adjustment_id		:= x_adjustment_id ;
			x_rec_log.line_num			:= x_line_num ;
			x_rec_log.document_header_id:= c_rec.header_id ;
			x_rec_log.document_type		:= p_doc_type ;
			x_rec_log.amount			:= 0 ;
			x_rec_log.source_flag		:= 'Y' ;
			x_rec_log.award_set_id		:= c_rec.award_set_id ;
			x_rec_log.adl_line_num		:= c_rec.adl_line_num ;
			x_rec_log.award_id			:= c_rec.award_id ;
			x_rec_log.expenditure_type	:= c_rec.expenditure_type ;
			x_rec_log.packet_id			:= p_record.packet_id ;
			x_rec_log.bc_packet_id		:= p_record.bc_packet_id ;

			x_rec_log.document_distribution_id	:= c_rec.dist_id ;
			x_rec_log.adj_burdenable_amount		:= x_dummy * -1 ;

			-- ------------------------------------------------------
			-- Create a adjustment log for this ITEM.
			-- ------------------------------------------------------
			create_burden_adjustments(x_rec_log,
									  c_rec.project_id,
									  c_rec.task_id,
									  c_rec.expenditure_item_date,
									  c_rec.expenditure_organization_id,
									  c_rec.resource_list_member_id,
									  c_rec.bud_task_id,
								      c_rec.ind_compiled_set_id) ;

		END IF ;
		IF x_done THEN
			EXIT ;
		END IF ;
        --<<NEXTREC>>
        NULL ;
	END LOOP ;

    IF x_doc_adj%ISOPEN THEN
       CLOSE x_doc_adj ;
    END IF ;

	p_adjustment_id	 	:= x_adjustment_id ;
	p_line_num			:= nvl(x_line_num,0)	;

	return x_adj_balance ;

EXCEPTION
	WHEN others THEN

          g_dummy := SQLERRM;
     	  IF g_debug = 'Y' THEN
      	     gms_error_pkg.gms_debug (g_error_procedure_name||':'||g_dummy,'C');
          END IF;

		RAISE ;
END SELF_ADJUSTMENT ;

FUNCTION DERIVE_ADJ_AMOUNT( p_old_burden	IN	NUMBER,
							p_new_burden	IN OUT NOCOPY	NUMBER ) return NUMBER IS
	x_adj_amount	NUMBER ;
	x_diff			NUMBER ;
BEGIN
	x_adj_amount	:= 0 ;
	x_diff			:= 0 ;

	IF p_old_burden < 0 and p_new_burden > 0 THEN

		IF abs(p_old_burden) <> p_new_burden THEN
			x_adj_amount	:= p_new_burden - abs(p_old_burden) ;
			p_new_burden	:= abs(p_old_burden) ;
		ELSIF abs(p_old_burden)	= p_new_burden THEN
			x_adj_amount	:= 0 ;
		END IF ;

	ELSIF (p_old_burden < 0 and p_new_burden < 0 )  OR
	      (p_old_burden > 0 and p_new_burden > 0 ) THEN

			x_adj_amount	:= 0 ;

	ELSIF p_old_burden > 0 and p_new_burden < 0 THEN

		IF abs(p_new_burden) > p_old_burden THEN
			x_adj_amount	:= p_old_burden - abs(p_new_burden) ;
			p_new_burden	:= p_old_burden * -1 ;
		ELSIF abs(p_new_burden) = p_old_burden THEN
			x_adj_amount	:= 0 ;
		ELSIF abs(p_new_burden) < p_old_burden THEN
			x_adj_amount 	:= abs(p_new_burden) - p_old_burden ;
			p_new_burden	:= 0 - p_old_burden ;
		END IF ;

	ELSIF p_old_burden < 0 and p_new_burden = 0 THEN

		p_new_burden	:= abs(p_old_burden) ;
		x_adj_amount	:= p_old_burden ;

	ELSIF p_old_burden = 0 and p_new_burden = 0 THEN

		x_adj_amount	:= 0 ;
		p_new_burden	:= p_old_burden * -1 ;

	ELSIF p_old_burden > 0 and p_new_burden = 0 THEN

		x_adj_amount	:= abs(p_new_burden) - p_old_burden ;
		p_new_burden	:= p_old_burden * -1 ;

	END IF ;

	return x_adj_amount ;

EXCEPTION
	WHEN others then

          g_dummy := SQLERRM;
     	  IF g_debug = 'Y' THEN
      	     gms_error_pkg.gms_debug (g_error_procedure_name||':'||g_dummy,'C');
          END IF;

		RAISE ;
END DERIVE_ADJ_AMOUNT ;

PROCEDURE	UPDATE_BC_PACKET(	p_doc_type	varchar2,
					p_burden	NUMBER,
					p_amount	NUMBER,
					p_record bc_packets%ROWTYPE )
is
  PRAGMA AUTONOMOUS_TRANSACTION; -- R12 Funds Management Uptake : Made this an autonomous procedure.
begin
	IF p_doc_type = 'REQ' THEN
		x_rec_award_exp_tot.req_raw_cost	:= x_rec_award_exp_tot.req_raw_cost +
											   p_amount ;
		x_rec_award_exp_tot.req_burdenable_cost	:= x_rec_award_exp_tot.req_burdenable_cost +
												   p_burden ;
	ELSIF p_doc_type = 'PO' THEN
		x_rec_award_exp_tot.po_raw_cost	:= x_rec_award_exp_tot.po_raw_cost +
											   p_amount ;
		x_rec_award_exp_tot.po_burdenable_cost	:= x_rec_award_exp_tot.po_burdenable_cost +
												   p_burden ;
	ELSIF p_doc_type = 'AP' THEN
		x_rec_award_exp_tot.ap_raw_cost	:= x_rec_award_exp_tot.ap_raw_cost +
											   p_amount ;
		x_rec_award_exp_tot.ap_burdenable_cost	:= x_rec_award_exp_tot.ap_burdenable_cost +
												   p_burden ;
	ELSIF p_doc_type = 'ENC' THEN
		x_rec_award_exp_tot.enc_raw_cost	:= x_rec_award_exp_tot.enc_raw_cost +
											   p_amount ;
		x_rec_award_exp_tot.enc_burdenable_cost	:= x_rec_award_exp_tot.enc_burdenable_cost +
												   p_burden ;
	ELSIF p_doc_type = 'EXP' THEN
		x_rec_award_exp_tot.exp_raw_cost	:= x_rec_award_exp_tot.exp_raw_cost +
											   p_amount ;
		x_rec_award_exp_tot.exp_burdenable_cost	:= x_rec_award_exp_tot.exp_burdenable_cost +
												   p_burden ;
	END IF ;

	x_tot_raw	:= x_tot_raw + p_amount ;
	x_tot_burden:= x_tot_burden + p_burden ;

    select gms_adjustments_id_s.NEXTVAL into l_calc_sequence from dual;

	UPDATE gms_bc_packets
       set burdenable_raw_cost = p_burden,
           burden_calculation_seq = l_calc_sequence
	where packet_id		= p_record.packet_id
	  and bc_packet_id	= p_record.bc_packet_id ;

    COMMIT; --R12 Funds Management Uptake : Made this an autonomous procedure.

EXCEPTION
	when others then

          g_dummy := SQLERRM;
     	  IF g_debug = 'Y' THEN
      	     gms_error_pkg.gms_debug (g_error_procedure_name||':'||g_dummy,'C');
          END IF;

		raise ;
END UPDATE_BC_PACKET ;

FUNCTION COMMON_LOGIC ( p_pkt_amount	NUMBER,
						p_raw_cost		NUMBER,
						P_burden		NUMBER,
						p_adj_amount	IN OUT NOCOPY NUMBER ) return NUMBER is
	x_burden	NUMBER  ;
	x_dummy		NUMBER  ;
BEGIN

     g_error_procedure_name := 'common_logic';
     IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':Start','C');
     END IF;

	    x_burden	 := 0 ;
	    x_dummy	     := 0 ;
		p_adj_amount := 0 ;

     IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':p_pkt_amount:'||p_pkt_amount||';'||'p_raw_cost:'||p_raw_cost,'C');
     END IF;

		IF p_pkt_amount > 0 THEN

				x_dummy := p_pkt_amount ;

				-- ----------------------------------------------------------------
				-- INFORMATION :
				-- The following IF codition - PURPOSE
				-- Let say AP has credit memo of -50,000 for the same award
				-- and expenditures, so AP_RAW_COST = -50,000 and AP_BURDEN = 0
				-- now new standard AP gets in lets say +1000, The total is still
				-- -49,000. Since AP can becomes actuals and we don't want to get
				-- in a situation where Raw cost is -Ve and Burden is +Ve.
				-- Thats why we calculates Zero Burden for this scenario.
				-- This is true for any type of transaction entry. i.e. AP, PO, REQ
				-- ENC and EXP.
				-- -----------------------------------------------------------------
				IF p_raw_cost < 0 THEN
			 		x_dummy := p_raw_cost + p_pkt_amount ;
					IF x_dummy <= 0 THEN
						x_burden := 0 ;
						x_dummy  := 0  ;
					END IF ;
				END IF ;

				if 		(x_tot_burden + x_dummy) <= x_award_exp_limit THEN
						x_burden	:= x_dummy ;
				elsif 	(x_tot_burden + x_dummy) > x_award_exp_limit THEN
						x_burden	:= x_award_exp_limit - x_tot_burden ;
						p_adj_amount:= x_dummy - x_burden ;
				END IF ; -- Limit Check

				-- ---------------------------------------------------------------
				-- Following code is replaced by the previous one.
				-- ---------------------------------------------------------------
				-- if 		(x_tot_burden + p_pkt_amount) <= x_award_exp_limit THEN
				-- 			x_burden	:= p_pkt_amount ;
				-- 	elsif 	(x_tot_burden + p_pkt_amount) > x_award_exp_limit THEN
				-- 			x_burden	:= x_award_exp_limit - x_tot_burden ;
				-- 			p_adj_amount:= p_pkt_amount - x_burden ;
				-- 	END IF ; -- Limit Check
				-- -----------------------------------------------------------------

		ELSIF p_pkt_amount = 0 THEN
				x_burden :=  0 ;

		ELSIF p_pkt_amount < 0 THEN
			 	x_dummy := p_raw_cost + p_pkt_amount ;

				IF x_dummy >= P_burden THEN
					x_burden := 0 ;
				ELSIF  x_dummy <= 0 THEN
					x_burden := 0 - P_burden;
				ELSIF  x_dummy < P_burden THEN
					x_burden	:= x_dummy - P_burden ;
				END IF ;
		END IF ; -- p_pkt_amount > 0
        return x_burden ;
EXCEPTION
	when others then

          g_dummy := SQLERRM;
     	  IF g_debug = 'Y' THEN
      	     gms_error_pkg.gms_debug (g_error_procedure_name||':'||g_dummy,'C');
          END IF;

		raise ;
END COMMON_LOGIC ;

FUNCTION  CALC_REQ_BURDEN(p_record bc_packets%ROWTYPE,p_mode IN VARCHAR2 ) return boolean  -- Bug : 2557041 - Added p_mode parameter
IS
  pkt_amount 		number;
  burden_raw_cost  	number;
  l_award_set_id    NUMBER ;
  l_adl_line_num    NUMBER ;
  x_adjustment_id	NUMBER ;
  x_line_num 		NUMBER ;
  req_adj_amount    NUMBER ;
  bc_pkt_rec 		bc_packets%rowtype;
  req_burden		NUMBER ;
  x_dummy			NUMBER ;
  x_rec_log			gms_burden_adjustments_log%ROWTYPE ;

  CURSOR C_req is
	SELECT  adl.burdenable_raw_cost burden_amount,
			adl.adl_line_num,
			adl.award_set_id
	  FROM  gms_award_distributions adl ,
			po_req_distributions_all req
	  WHERE adl.distribution_id	= p_record.document_distribution_id
	   AND  req.distribution_id	= p_record.document_distribution_id
	   AND  req.award_id		= adl.award_set_id
	   and  adl.adl_status		= 'A'
	   and 	adl.distribution_id	= req.distribution_id ;
BEGIN

     g_error_procedure_name := 'calc_req_burden';
     IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':Start','C');
     END IF;

        x_line_num 		:= 0;
        req_adj_amount  := 0 ;
		bc_pkt_rec		:= 	p_record ;
		bc_pkt_rec.entered_cr	:=	nvl(bc_pkt_rec.entered_cr,0) ;
		bc_pkt_rec.entered_dr	:=	nvl(bc_pkt_rec.entered_dr,0) ;

		if nvl(bc_pkt_rec.entered_cr,0) <>	0 then
			pkt_amount := 0 - bc_pkt_rec.entered_cr;
		elsif nvl(bc_pkt_rec.entered_dr,0) <>	0 then
			pkt_amount := bc_pkt_rec.entered_dr;
		end if;

		-- -----------------------------------------
		-- We don't need and adjustments log so we
		-- calculate it direct.
		-- ------------------------------------------
	        -- ============================================================
	        -- Bug : 1776185 - IDC LIMITS OF $0 NOT BEING RECOGNIZED WHEN
	        --     :           BURDENING.
	        -- ============================================================
		/* -- Update in FUNCTION  update_bc_pkt_burden_raw_cost takes care of this ...
		IF x_calc_zero_limit THEN
			burden_raw_cost := 0 ;
			update_bc_packet('REQ', burden_raw_cost, pkt_amount, p_record ) ;
			return TRUE ;
		END IF ;

		IF nvl(x_award_exp_limit,0) <=  0 THEN
			burden_raw_cost	:= pkt_amount ;
			update_bc_packet('REQ', burden_raw_cost, pkt_amount, p_record ) ;
			return TRUE ;
		END IF ;
        */

		-- --------------------------------------
		-- We have a IDC limit.
		-- X_dummy : is adjustment amount, Req
		-- doesn't have any ADJ amount. So
		-- ignored.
		-- --------------------------------------

		burden_raw_cost	:= common_logic(pkt_amount,
						x_rec_award_exp_tot.req_raw_cost,
						x_rec_award_exp_tot.req_burdenable_cost,
						x_dummy) ;



	       /* =================================================================
		  -- Bug : 2557041 - Added for IP check funds Enhancement

		  As burden adjustment will not be carried out NOCOPY in check funds mode,
	          reutrn after updating the burdenable_raw_cost on gms_bc_packets
		  ================================================================== */

		IF p_mode = 'C' THEN
		   update_bc_packet('REQ', burden_raw_cost, pkt_amount, p_record ) ;
		   RETURN TRUE ;
		END IF;



		-- --------------------------------------------
		-- Get previous calculated burden on the same
		-- line.
		-- --------------------------------------------
		open c_req ;
		fetch c_req into  req_burden,
                          l_award_set_id,
                          l_adl_line_num ;
		close c_req ;

		-- =========================================================================
		-- BUG 1833325 - IDC LIMIT SCENARIO: TWO PROJECTS FUNDING SAME AWARD,
		-- CANCELLED REQUISITION
		-- Related PO Bug :
		-- Req adjustments didn't happen correctly after Req cancellation.
		-- =========================================================================

		--IF req_burden is not NULL  THEN
		--	req_adj_amount	:= derive_adj_amount( nvl(req_burden,0), burden_raw_cost ) ;
		--END IF ;

		IF nvl(req_burden,0) > 0 and pkt_amount < 0 THEN
			   burden_raw_cost := least( abs(pkt_amount), req_burden) * -1 ;
		END IF ;

		IF burden_raw_cost < 0 THEN
		   req_adj_amount := burden_raw_cost ;
		END IF ;

		IF req_adj_amount <> 0 THEN
			x_dummy := 0 ;
			x_dummy	:= self_adjustment( 'REQ',
						p_record,
						req_adj_amount,
						x_adjustment_id,
						x_line_num) ;



			req_adj_amount	:= req_adj_amount - x_dummy ;
		END IF ;

		-- -------------------------------------------------------------------
		-- Update the Running Total.
		-- -------------------------------------------------------------------


		update_bc_packet('REQ', burden_raw_cost, pkt_amount, p_record ) ;

		return TRUE ;

EXCEPTION
	when no_data_found then
		return TRUE ;
    when others then

          g_dummy := SQLERRM;
     	  IF g_debug = 'Y' THEN
      	     gms_error_pkg.gms_debug (g_error_procedure_name||':'||g_dummy,'C');
          END IF;

		Raise ;
END CALC_REQ_BURDEN;

FUNCTION  CALC_PO_BURDEN(p_record	bc_packets%ROWTYPE,p_mode IN VARCHAR2 ) return boolean	-- Bug : 2557041 - Added p_mode parameter
IS

  X_po_dist_id	   	NUMBER ;
  x_line_num		NUMBER ;
  pkt_amount 		number;
  burden_raw_cost  	number;
  x_award_set_id	NUMBER ;
  x_adl_line_num	NUMBER ;
  x_po_burden		NUMBER ;
  x_dummy			NUMBER ;
  po_adj_amount		NUMBER ;
  x_adjustment_id	NUMBER ;

  x_rec_log			gms_burden_adjustments_log%ROWTYPE ;
  bc_pkt_rec 		bc_packets%rowtype;

  cursor po_dist_records is
  	select nvl(adl.burdenable_raw_cost,0) ,
		   adl.award_set_id		award_set_id,
		   adl_line_num			adl_line_num
  	  FROM po_distributions_all pod,
		   gms_award_distributions adl
	 where adl.award_set_id			= pod.award_id
	   AND adl.po_distribution_id	= pod.po_distribution_id
	   and adl.adl_status				= 'A'
	   and pod.po_distribution_id	= X_po_dist_id ;

BEGIN
     g_error_procedure_name := 'calc_po_burden';
     IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':Start','C');
     END IF;

        X_po_dist_id	:= 0 ;
        x_line_num		:= 0 ;
		bc_pkt_rec		:= 	p_record ;
		bc_pkt_rec.entered_cr	:=	nvl(bc_pkt_rec.entered_cr,0) ;
		bc_pkt_rec.entered_dr	:=	nvl(bc_pkt_rec.entered_dr,0) ;

		x_po_dist_id	:= bc_pkt_rec.document_distribution_id ;

		if bc_pkt_rec.entered_cr <>	0 then
			pkt_amount := 0 - bc_pkt_rec.entered_cr;
		elsif bc_pkt_rec.entered_dr <>	0 then
			pkt_amount := bc_pkt_rec.entered_dr;
		end if;


	    -- ============================================================
	    -- Bug : 1776185 - IDC LIMITS OF $0 NOT BEING RECOGNIZED WHEN
	    --     :           BURDENING.
	    -- ============================================================
		/* -- Update in FUNCTION  update_bc_pkt_burden_raw_cost takes care of this ...
		IF x_calc_zero_limit THEN
			burden_raw_cost := 0 ;
			update_bc_packet('PO', burden_raw_cost, pkt_amount, p_record ) ;
			return TRUE ;
		END IF ;

		IF nvl(x_award_exp_limit,0) <=  0 THEN
			-- --------------------------
			-- IDC Limit is not enabled.
			-- -------------------------
			burden_raw_cost	:= pkt_amount ;
			update_bc_packet('PO', burden_raw_cost, pkt_amount, p_record ) ;
			return TRUE ;
		END IF ;
        */

		burden_raw_cost	:= common_logic(	pkt_amount,
							x_rec_award_exp_tot.po_raw_cost,
							x_rec_award_exp_tot.po_burdenable_cost,
							x_dummy) ;

	       /* =================================================================
		  -- Bug : 2557041 -  Added for IP check funds Enhancement

		  As burden adjustment will not be carried out NOCOPY in check funds mode,
	          reutrn after updating the burdenable_raw_cost on gms_bc_packets
		  ================================================================== */

		IF p_mode = 'C' THEN
		   update_bc_packet('PO', burden_raw_cost, pkt_amount, p_record ) ;
		   RETURN TRUE ;
		END IF;


		x_po_dist_id   := nvl(bc_pkt_rec.document_distribution_id,0) ;

		OPEN po_dist_records ;
		FETCH po_dist_records into x_po_burden, x_award_set_id, x_adl_line_num ;
		CLOSE po_dist_records ;
		po_adj_amount := 0 ;

		--IF x_po_burden is not NULL  THEN
	   --		po_adj_amount	:= derive_adj_amount( nvl(x_po_burden,0), burden_raw_cost ) ;
		   --END IF ;

		-- ----------------------------------------
		-- BUG: 1337438 - PO burdenable_cost is OFF
		-- ----------------------------------------
		IF x_po_burden > 0 and pkt_amount < 0 THEN
			   burden_raw_cost := least( abs(pkt_amount), x_po_burden) * -1 ;
		END IF ;

		IF burden_raw_cost < 0 THEN
		   po_adj_amount := burden_raw_cost ;
		END IF ;

		IF po_adj_amount <> 0 THEN
			x_dummy	:= self_adjustment( 'PO',
						    p_record,
						    PO_adj_amount,
						    x_adjustment_id,
						    x_line_num) ;

			--burden_raw_cost	:= burden_raw_cost + x_dummy ;
			-- adjusted amount
			PO_adj_amount	:= PO_adj_amount - x_dummy ;
			IF po_adj_amount <> 0 THEN
					-- ------------------
					-- PO_ADJ_AMOUNT = 0
					-- -------------------
					PO_adj_amount := 0 ;
			END IF ;
        END IF ;

		-- -------------------------------------------------------------------
		-- Update the Running Total.
		-- -------------------------------------------------------------------
		update_bc_packet('PO', burden_raw_cost, pkt_amount, p_record ) ;

		return TRUE ;
EXCEPTION
    when others then

          g_dummy := SQLERRM;
     	  IF g_debug = 'Y' THEN
      	     gms_error_pkg.gms_debug (g_error_procedure_name||':'||g_dummy,'C');
          END IF;

		Raise ;
END  CALC_PO_BURDEN ;

FUNCTION  CALC_ENC_BURDEN(p_record	bc_packets_enc%ROWTYPE) return boolean
IS
  pkt_amount 		number;
  x_award_set_id	NUMBER ;
  x_adl_line_num	NUMBER ;
  x_adjustment_id	NUMBER ;
  x_line_num		NUMBER ;
  x_dummy			NUMBER ;
  x_enc_burden		NUMBER ;
  enc_adj_amount	NUMBER ;
  burden_raw_cost  	number;

  x_rec_log			gms_burden_adjustments_log%ROWTYPE ;
  bc_pkt_rec 		bc_packets%rowtype;

  cursor ENC_record is
  	select nvl(adl.burdenable_raw_cost,0) ,
		   adl.award_set_id		award_set_id,
		   adl_line_num			adl_line_num
  	  FROM gms_encumbrance_items_all enc,
		   gms_award_distributions adl
	 where adl.expenditure_item_id	= ENC.encumbrance_item_id
	   and adl.adl_status				= 'A'
	   and ENC.encumbrance_item_id  = bc_pkt_rec.document_header_id
	   and enc.enc_distributed_flag	= 'Y'  ;

BEGIN
     g_error_procedure_name := 'calc_enc_burden';
     IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':Start','C');
     END IF;

        x_line_num		        := 0;
		bc_pkt_rec				:= 	p_record ;
		bc_pkt_rec.entered_cr	:=	nvl(bc_pkt_rec.entered_cr,0) ;
		bc_pkt_rec.entered_dr	:=	nvl(bc_pkt_rec.entered_dr,0) ;

		if bc_pkt_rec.entered_cr <>	0 then
			pkt_amount := 0 - bc_pkt_rec.entered_cr;
		elsif bc_pkt_rec.entered_dr <>	0 then
			pkt_amount := bc_pkt_rec.entered_dr;
		end if;

		--OPEN enc_record ;
		--FETCH enc_record into x_aenc_burden, x_award_set_id, x_adl_line_num ;
		--CLOSE enc_record ;

	       -- ============================================================
	       -- Bug : 1776185 - IDC LIMITS OF $0 NOT BEING RECOGNIZED WHEN
	       --     :           BURDENING.
	       -- ============================================================
		/* -- Update in FUNCTION  update_bc_pkt_burden_raw_cost takes care of this ...
		IF x_calc_zero_limit THEN
			burden_raw_cost := 0 ;
			update_bc_packet('ENC', burden_raw_cost, pkt_amount, p_record ) ;
			return TRUE ;
		END IF ;
        */
		enc_adj_amount	:= 0 ;

		/* -- Update in FUNCTION  update_bc_pkt_burden_raw_cost takes care of this ...

		IF nvl(x_award_exp_limit,0) <= 0 THEN
			-- --------------------------
			-- IDC Limit is not enabled.
			-- -------------------------
			burden_raw_cost	:= pkt_amount ;
			update_bc_packet('ENC', burden_raw_cost, pkt_amount, p_record ) ;
			return TRUE ;
		END IF ; -- nvl(x_award_exp_limit,0)

        */
		burden_raw_cost	:= common_logic(	pkt_amount,
							x_rec_award_exp_tot.ENC_raw_cost,
							x_rec_award_exp_tot.ENC_burdenable_cost,
							x_dummy) ;

		-- -------------------------------------------------------------------
		-- Update the Running Total.
		-- -------------------------------------------------------------------
		update_bc_packet('ENC', burden_raw_cost, pkt_amount, p_record ) ;

		return TRUE ;
EXCEPTION
	WHEN others THEN

          g_dummy := SQLERRM;
     	  IF g_debug = 'Y' THEN
      	     gms_error_pkg.gms_debug (g_error_procedure_name||':'||g_dummy,'C');
          END IF;

		RAISE ;
END CALC_ENC_BURDEN ;

PROCEDURE NET_ZERO_AP(P_record bc_packets%ROWTYPE)
IS

  x_run_total		NUMBER ;
  x_adj_amount		NUMBER ;
  x_dummy			NUMBER ;
  x_line_num		NUMBER ;
  x_adjustment_id	NUMBER ;
  x_rec_log			gms_burden_adjustments_log%ROWTYPE ;

  cursor AP_ZERO_INVOICE is
  	select nvl(apd.base_amount,apd.amount)	amount , --Bug 2472802
		   nvl(adl.burdenable_raw_cost,0)	burden,
		   apd.invoice_id					header_id,
		   apd.invoice_distribution_id		DIST_ID, -- AP Lines change
		   adl.award_set_id					award_set_id ,
		   adl.adl_line_num					adl_line_num,
		   apd.project_id,
		   apd.task_id,
		   apd.expenditure_item_date,
		   apd.expenditure_organization_id,
		   adl.resource_list_member_id,
	   	   adl.bud_task_id,
		   adl.ind_compiled_set_id
  	  FROM ap_invoice_distributions 	APD,
		   gms_award_distributions 	ADL,
		   gl_ledgers				G
	 where adl.invoice_distribution_id	= APD.invoice_distribution_id
	   and adl.adl_status					= 'A'
	   and adl.award_id					= P_record.award_id
	   and nvl(adl.burdenable_raw_cost,0) <> 0
	   and apd.expenditure_type			= P_record.expenditure_type
	   and ADL.award_set_id				= APD.award_id
	   AND G.LEDGER_ID = APD.SET_OF_BOOKS_ID
	   and pa_cmt_utils.get_apdist_amt( apd.invoice_distribution_id,
		                                apd.invoice_id,
										nvl(apd.base_amount,apd.amount),
										'N',
										'GMS', nvl(g.sla_ledger_cash_basis_flag,'N') ) <> 0
	   and apd.line_type_lookup_code    <> 'PREPAY'
	   and decode(apd.pa_addition_flag,'G', 'Y','Z','Y', 'T','Y', 'E','Y', NULL, 'N', apd.pa_addition_flag ) <> 'Y'
	   -- Bug 2097676: Fixing GSCC Error File.sql.9
	   and apd.invoice_id				= P_record.document_header_id ;

BEGIN
     g_error_procedure_name := 'net_zero_ap';
     IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':Start','C');
     END IF;

    x_run_total		:= 0 ;
    x_adj_amount	:= 0 ;
    x_dummy			:= 0 ;
    x_line_num		:= 0 ;

	for c_rec in AP_ZERO_INVOICE LOOP
        x_dummy := NVL(c_rec.burden,0) ;

           -- Amount already posted during summarization;
	    --x_dummy	:= x_dummy + get_prev_unposted_adj( c_rec.header_id,
        --						 							c_rec.DIST_ID,
	    --					 							'AP' )  ;

		IF x_dummy <> 0 THEN

			x_run_total := x_run_total + x_dummy ;

			IF x_adjustment_id  IS NULL THEN
				select gms_adjustments_id_s.NEXTVAL
				  INTO x_adjustment_id
				  FROM dual ;
			END IF ;

			x_line_num					:= x_line_num + 1 ;
			x_rec_log.adjustment_id		:= x_adjustment_id ;
			x_rec_log.line_num			:= x_line_num ;
			x_rec_log.document_header_id:= c_rec.header_id ;
			x_rec_log.document_type		:= 'AP' ;
			x_rec_log.amount			:= 0 ;
			x_rec_log.source_flag		:= 'Y' ;
			x_rec_log.award_set_id		:= c_rec.award_set_id ;
			x_rec_log.adl_line_num		:= c_rec.adl_line_num ;
			x_rec_log.award_id			:= p_record.award_id ;
			x_rec_log.expenditure_type	:= p_record.expenditure_type ;
			x_rec_log.packet_id			:= p_record.packet_id ;
			x_rec_log.bc_packet_id		:= p_record.bc_packet_id ;

			x_rec_log.document_distribution_id	:= c_rec.dist_id ;
			x_rec_log.adj_burdenable_amount		:= x_dummy * -1 ;

			-- ------------------------------------------------------
			-- Create a adjustment log for this ITEM.
			-- ------------------------------------------------------
			create_burden_adjustments(x_rec_log,
									  c_rec.project_id,
									  c_rec.task_id,
									  c_rec.expenditure_item_date,
									  c_rec.expenditure_organization_id,
									  c_rec.resource_list_member_id,
									  c_rec.bud_task_id,
								      c_rec.ind_compiled_set_id) ;

		END IF ;
	END LOOP ;
EXCEPTION
	When others then

          g_dummy := SQLERRM;
     	  IF g_debug = 'Y' THEN
      	     gms_error_pkg.gms_debug (g_error_procedure_name||':'||g_dummy,'C');
          END IF;

		RAISE ;
END NET_ZERO_AP ;

FUNCTION  CALC_AP_BURDEN(p_record	bc_packets%ROWTYPE,p_mode IN VARCHAR2 ) return boolean	-- Bug : 2557041 - Added p_mode parameter
IS
  pkt_amount 		number;
  x_award_set_id	NUMBER ;
  x_adl_line_num	NUMBER ;
  x_adjustment_id	NUMBER ;
  x_line_num		NUMBER ;
  x_dummy		    NUMBER ;
  burden_raw_cost  	number;
  AP_adj_amount		NUMBER ;
  x_adj_amount		NUMBER ;
  x_rec_log		    gms_burden_adjustments_log%ROWTYPE ;
  bc_pkt_rec 		bc_packets%rowtype;
  AP_adjustment		BOOLEAN ;
  x_AP_TYPE		    VARCHAR2(20) ;
  x_credit		    BOOLEAN ;

  CURSOR C_MEMO is
	select invoice_id
     from ap_invoices  inv
    where inv.invoice_type_lookup_code IN ('CREDIT','DEBIT')
      and inv.invoice_id	= bc_pkt_rec.document_header_id ;
  --
  -- Bug 4737148
  -- burdenable raw cost calculations for apply/unapply prepayment distributions.
  -- Source prepayment ivoice distributions attributes.
  --
  cursor c_prepay is
        select apd1.line_type_lookup_code,
		       apd1.prepay_distribution_id,
			   nvl(adl.burdenable_raw_cost ,0),
		       apd2.invoice_id,
			   adl.award_set_id,
			   adl.award_id,
			   apd2.expenditure_type,
			   apd2.project_id,
			   apd2.task_id,
			   apd2.expenditure_item_date,
			   apd2.expenditure_organization_id,
			   adl.resource_list_member_id,
			   adl.bud_task_id,
			   adl.ind_compiled_set_id
          from ap_invoice_distributions_all apd1,
		       ap_invoice_distributions_all apd2,
		       gms_award_distributions adl
         where apd1.invoice_distribution_id = bc_pkt_rec.document_distribution_id
		   and apd2.invoice_distribution_id = apd1.prepay_distribution_id
		   and apd2.award_id                = adl.award_set_id
		   and adl.invoice_distribution_id = apd2.invoice_distribution_id
		   and adl.document_type           = 'AP'
		   and adl.fc_status               = 'A'
		   and adl.invoice_id              = apd2.invoice_id ;


  l_sum_amount		NUMBER ;
  l_sum_burden		NUMBER ;
  l_sum_count		NUMBER ;
  l_header_id		NUMBER ;
  l_memo		    NUMBER ;

  l_prepay_type     ap_invoice_distributions_all.line_type_lookup_code%TYPE ;
  l_prepay_dist_id      NUMBER ;
  l_prepayment_brc      number ;
  l_prepay_header_id    NUMBER ;
  l_prepay_award_set_id NUMBER ;
  l_prepay_award_id     NUMBER ;
  l_prepay_exp_type     ap_invoice_distributions.expenditure_type%TYPE ;
  l_prepay_project_id   number ;
  l_prepay_task_id      number ;
  l_prepay_ei_date      date ;
  l_prepay_exp_org_id   number ;
  l_prepay_rlmi_id      number ;
  l_prepay_bud_task_id  number ;
  l_prepay_ind_set_id   number ;


  CURSOR C_GET_AWARD_SET_ID IS
    SELECT  adl.award_set_id , adl.adl_line_num
  	  FROM ap_invoice_distributions 	AP,
	       gms_award_distributions 		ADL
	 where adl.invoice_distribution_id	= AP.invoice_distribution_id
	   and adl.adl_status			= 'A'
	   and adl.award_id			= p_record.award_id
	   and ap.expenditure_type		= p_record.expenditure_type
	   and ADL.award_set_id			= AP.award_id
	   and ap.invoice_id			= P_RECORD.document_header_id
         and ap.invoice_distribution_id   = P_RECORD.document_distribution_id ; -- AP Lines change

  cursor AP_ZERO_INVOICE is
  	select sum( pa_cmt_utils.get_apdist_amt(ap.invoice_distribution_id,
				                             ap.invoice_id,
											nvl(ap.base_amount,ap.amount),
											'N',
											'GMS',nvl(g.sla_ledger_cash_basis_flag,'N') ) )				sum_amount ,
		   sum(nvl(adl.burdenable_raw_cost,0))	sum_burden,
		   count(*)				sum_count
  	  FROM ap_invoice_distributions 	AP,
	       gms_award_distributions 	ADL,
		  gl_ledgers				G
	 where adl.invoice_distribution_id	= AP.invoice_distribution_id
	   and adl.adl_status			    = 'A'
	   and adl.award_id			        = bc_pkt_rec.award_id
	   and ap.expenditure_type	        = bc_pkt_rec.expenditure_type
	   and ADL.award_set_id			    = AP.award_id
	   and G.LEDGER_ID = AP.SET_OF_BOOKS_ID
	   and pa_cmt_utils.get_apdist_amt(ap.invoice_distribution_id,
						               ap.invoice_id,
										nvl(ap.base_amount,ap.amount),
										'N',
										'GMS',nvl(g.sla_ledger_cash_basis_flag,'N') ) <> 0
	   and ap.line_type_lookup_code    <> 'PREPAY'
	   and decode(ap.pa_addition_flag,'Z','Y', 'T','Y', 'E','Y', 'G', 'Y',NULL, 'N', ap.pa_addition_flag ) <> 'Y'
	   -- Bug 2097676, Fixing GSCC error File.sql.9
	   and ap.invoice_id				= bc_pkt_rec.document_header_id ;

BEGIN
     g_error_procedure_name := 'calc_ap_burden';
     IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':Start','C');
     END IF;

		bc_pkt_rec		:= 	p_record ;
		bc_pkt_rec.entered_cr	:=	nvl(bc_pkt_rec.entered_cr,0) ;
		bc_pkt_rec.entered_dr	:=	nvl(bc_pkt_rec.entered_dr,0) ;
		-- ------------------------------
		-- Defaulting as a standard AP.
		-- ------------------------------
  		X_AP_TYPE				:=  'STD' ;

		if bc_pkt_rec.entered_cr <>	0 then
			pkt_amount := 0 - bc_pkt_rec.entered_cr;
			x_credit   :=	TRUE ;
		elsif bc_pkt_rec.entered_dr <>	0 then
			pkt_amount := bc_pkt_rec.entered_dr;
		end if;

		-- -----------------------------------------
		-- What are the possible scenarios for AP.
		-- 1.	No IDC Limit Scenarios.
		-- 2. 	IDC	Limit Scenarios.
		-- 		2.1	-	Credit Memo.
		--		2.2	-	Debit Memo.
		--		2.3	-	Cancelled AP
		--		2.4	-	Standard AP.
		-- -----------------------------------------
		-- ----------------------------------------------
		-- CASE 2.3 -	Cancelled AP or AP with ZERO
		--				Raw cost.
		-- ----------------------------------------------
		OPEN AP_ZERO_INVOICE ;
		FETCH AP_ZERO_INVOICE   into l_sum_amount,
									 l_sum_burden,
									 l_sum_count ;
		IF l_sum_amount = 0 THEN
			-- ---------------------
			-- CALL net Zero AP.
			-- ---------------------
			NET_ZERO_AP(P_record) ;
			X_ap_type		:= 'NET-ZERO' ;
			burden_raw_cost	:= 0 ;

			-- -------------------------------------------------------------------------------
			-- BUG : 1321744 IDC Limit scenario fails incase of cancelling DEBIT Memo.
			-- Scenarion - PO - 1000/1000
			--             AP - 2500/2000   , PO - 1000/0
			--             DM - -600/1900   , PO - 1000/100
			-- Cancel DM      - 2000/1900   , PO - 1000/100 WRONG*****
			-- Fixes    - By find the adjustment amounts in cancel of cancellations.
			-- -------------------------------------------------------------------------------
			ap_adj_amount   := ( x_rec_award_exp_tot.ap_raw_cost + pkt_amount ) -
							   ( x_rec_award_exp_tot.ap_burdenable_cost - burden_raw_cost ) ;

			-- ---------------------------------------------------------------------------------
			-- Information : Don't adjust anything if you don't have anything to adjust.
			-- ---------------------------------------------------------------------------------
			OPEN C_MEMO ;
			Fetch c_memo into l_memo ;

			IF C_MEMO%FOUND THEN
					IF ( x_rec_award_exp_tot.req_burdenable_cost + x_rec_award_exp_tot.po_burdenable_cost +
							 x_rec_award_exp_tot.enc_burdenable_cost ) <=0 THEN
							ap_adj_amount := 0 ;
					END IF ;
			END IF ;

			CLOSE C_MEMO ;

		END IF ;

		-- --------------------------------------
		-- We have a IDC limit.
		-- X_dummy : is adjustment amount .
		-- --------------------------------------
        --
        -- Bug 4737148
        -- burdenable raw cost calculations for apply/unapply prepayment distributions.
        -- Source prepayment ivoice distributions attributes.
        --
		open c_prepay ;
		fetch c_prepay into l_prepay_type,
		                    l_prepay_dist_id,
							l_prepayment_brc,
		                    l_prepay_header_id,
							l_prepay_award_set_id,
							l_prepay_award_id,
							l_prepay_exp_type,
							l_prepay_project_id ,
							l_prepay_task_id ,
							l_prepay_ei_date ,
							l_prepay_exp_org_id,
							l_prepay_rlmi_id ,
                            l_prepay_bud_task_id,
							l_prepay_ind_set_id  ;
		close c_prepay ;

		IF X_ap_type <> 'NET-ZERO' THEN

			burden_raw_cost	:= common_logic(	pkt_amount,
								x_rec_award_exp_tot.ap_raw_cost,
							        x_rec_award_exp_tot.ap_burdenable_cost,
								ap_adj_amount) ;
		END IF;

	       /* =================================================================
		  -- Bug : 2557041 -  Added for IP check funds Enhancement

		  As burden adjustment will not be carried out NOCOPY in check funds mode,
	          reutrn after updating the burdenable_raw_cost on gms_bc_packets
		  ================================================================== */

		IF p_mode = 'C' THEN
		   update_bc_packet('AP', burden_raw_cost, pkt_amount, p_record ) ;
   		   RETURN TRUE ;
		END IF;

		OPEN C_GET_AWARD_SET_ID  ;
		fetch C_GET_AWARD_SET_ID into x_award_set_id, x_adl_line_num ;
		CLOSE C_GET_AWARD_SET_ID ;

        --
        -- Bug 4737148
        -- burdenable raw cost calculations for apply/unapply prepayment distributions.
		-- Logic :
		--  Determine the burdenable raw cost stored in source prepayment invoice distributions.
		--  APPLY action will reduce the burdenable raw cost in  source prepayment invoice distributions.
		--  reduced amount is adjusted across another invoice that may be underburden.
		--
/* Bug 5645290 - Checking for l_prepay_dist_id instead of l_prepay_type */
--		IF l_prepay_type = 'PREPAY' and pkt_amount < 0   THEN
		IF l_prepay_dist_id IS NOT NULL and pkt_amount < 0   THEN
		   burden_raw_cost := 0 ;
		   IF abs( pkt_amount) >  l_prepayment_brc then
		      ap_adj_amount    := -1 * l_prepayment_brc ;
           ELSE
		      ap_adj_amount    :=  pkt_amount ;
		   END IF ;

		   IF ap_adj_amount <> 0 THEN

		      IF x_adjustment_id  IS NULL THEN
			     select gms_adjustments_id_s.NEXTVAL
			       INTO x_adjustment_id
			       FROM dual ;
		      END IF ;
		      x_line_num := NVL(x_line_num,0) + 1 ;

		      x_rec_log.adjustment_id		:= x_adjustment_id ;
		      x_rec_log.line_num		    := x_line_num ;
		      x_rec_log.document_header_id  := l_prepay_header_id ;
		      x_rec_log.document_type		:= 'AP' ;
		      x_rec_log.amount		        := 0 ;
		      x_rec_log.source_flag		    := 'Y' ;
		      x_rec_log.award_set_id		:= l_prepay_award_set_id ;
		      x_rec_log.adl_line_num		:= 1 ;
		      x_rec_log.award_id		    := l_prepay_award_id ;
		      x_rec_log.expenditure_type	:= l_prepay_exp_type ;
		      x_rec_log.packet_id		    := p_record.packet_id ;
		      x_rec_log.bc_packet_id		:= p_record.bc_packet_id ;
		      x_rec_log.document_distribution_id:= l_prepay_dist_id ;
		      x_rec_log.adj_burdenable_amount	:= ap_adj_amount ;

		      -- ------------------------------------------------------
		      -- Create a adjustment log for this ITEM.
		      -- ------------------------------------------------------
              --
              -- Bug 4737148
              -- burdenable raw cost calculations for apply/unapply prepayment distributions.
			  -- Create adjusting entries.
			  --
			  create_burden_adjustments(x_rec_log,
									  l_prepay_project_id,
									  l_prepay_task_id,
									  l_prepay_ei_date,
									  l_prepay_exp_org_id,
									  l_prepay_rlmi_id ,
									  l_prepay_bud_task_id,
								      l_prepay_ind_set_id ) ;


		      x_dummy  := self_adjustment ( 'AP', p_record, (-1*ap_adj_amount), x_adjustment_id, x_line_num ) ;
		   END IF ;

		END IF ;

		IF burden_raw_cost < 0 THEN
			X_ap_type := 'MEMO-TYPE' ;
		        ap_adj_amount := burden_raw_cost ;
			x_dummy	  := self_adjustment( 'AP',
										p_record,
										burden_raw_cost,
										x_adjustment_id,
										x_line_num) ;
			burden_raw_cost	:= nvl(x_dummy,0) ;
			-- adjusted amount
			ap_adj_amount	:= ap_adj_amount - ABS(x_dummy) ;

            ap_adj_amount := 0 ;
		END IF ;

		-- --------------------------------------------------
		-- ap_adj_amount will be computed here only for +ve
		-- amounts.
		-- --------------------------------------------------
		IF ap_adj_amount  > 0 AND ( NVL(X_ap_type,'X') <> 'NET-ZERO' OR NVL(L_MEMO,0) > 0 ) THEN

			-- ------------------------------------------------
			-- exp adj_amount is the amount need to be adjusted
			-- We take the amount from ENC and update EXP.
			-- The sequence of adjustment is REQ- PO-ENC.
			-- -------------------------------------------------
			x_dummy	:= 0 ;
			x_dummy := create_adjplus_log(	'REQ' ,
							ap_adj_amount,
							bc_pkt_rec.award_id,
							bc_pkt_rec.expenditure_type,
							bc_pkt_rec.packet_id ,
							bc_pkt_rec.bc_packet_id,
							bc_pkt_rec.document_header_id,
							bc_pkt_rec.document_distribution_id,
							FALSE,
							x_adjustment_id	,
							x_line_num )  ;
                          ap_adj_amount := ap_adj_amount - x_dummy ;--bug 2311261

			  IF NVL(X_ap_type,'X') <> 'NET-ZERO' THEN
			     -- --------------------------------------------------
			     -- BUG 1321744 : IDC Limit scenario fails in case of
			     -- cancelling debit memo.
			     -- --------------------------------------------------
			   	 burden_raw_cost	:=	burden_raw_cost + x_dummy ;
			  END IF ;
		END IF ;

        --
        -- Bug 4737148
        -- burdenable raw cost calculations for apply/unapply prepayment distributions.
		-- Logic :
		--  Determine the burdenable raw cost stored in source prepayment invoice distributions.
		--  UNAPPLY action will increase the burdenable raw cost in  source prepayment invoice distributions.
		--  unapply distributions will get the zero burdenable raw cost.
		--
/* Bug 5645290 - Checking for l_prepay_dist_id instead of l_prepay_type */
--		IF l_prepay_type = 'PREPAY' and pkt_amount > 0   THEN
		IF l_prepay_dist_id IS NOT NULL and pkt_amount > 0   THEN

		   IF burden_raw_cost <> 0 THEN

		      IF x_adjustment_id  IS NULL THEN
			     select gms_adjustments_id_s.NEXTVAL
			       INTO x_adjustment_id
			       FROM dual ;
		      END IF ;
		      x_line_num := NVL(x_line_num,0) + 1 ;

		      x_rec_log.adjustment_id		:= x_adjustment_id ;
		      x_rec_log.line_num		    := x_line_num ;
		      x_rec_log.document_header_id  := l_prepay_header_id ;
		      x_rec_log.document_type		:= 'AP' ;
		      x_rec_log.amount		        := 0 ;
		      x_rec_log.source_flag		    := 'Y' ;
		      x_rec_log.award_set_id		:= l_prepay_award_set_id ;
		      x_rec_log.adl_line_num		:= 1 ;
		      x_rec_log.award_id		    := l_prepay_award_id ;
		      x_rec_log.expenditure_type	:= l_prepay_exp_type ;
		      x_rec_log.packet_id		    := p_record.packet_id ;
		      x_rec_log.bc_packet_id		:= p_record.bc_packet_id ;
		      x_rec_log.document_distribution_id:= l_prepay_dist_id ;
		      x_rec_log.adj_burdenable_amount	:= burden_raw_cost ;
			  burden_raw_cost               := 0 ;

		      -- ------------------------------------------------------
		      -- Create a adjustment log for this ITEM.
		      -- ------------------------------------------------------
              --
              -- Bug 4737148
              -- burdenable raw cost calculations for apply/unapply prepayment distributions.
			  -- Create the adjusting entries.
			  --
			  create_burden_adjustments(x_rec_log,
									  l_prepay_project_id,
									  l_prepay_task_id,
									  l_prepay_ei_date,
									  l_prepay_exp_org_id,
									  l_prepay_rlmi_id ,
									  l_prepay_bud_task_id,
								      l_prepay_ind_set_id ) ;
		   END IF ;
		END IF ;

		-- -------------------------------------------------------------------
		-- Update the Running Total.
		-- -------------------------------------------------------------------
		update_bc_packet('AP', burden_raw_cost, pkt_amount, p_record ) ;

	    return TRUE ;

EXCEPTION
	WHEN others THEN

          g_dummy := SQLERRM;
     	  IF g_debug = 'Y' THEN
      	     gms_error_pkg.gms_debug (g_error_procedure_name||':'||g_dummy,'C');
          END IF;

		RAISE ;
END  CALC_AP_burden;
-- ------------------AP ----------------------------------------------

FUNCTION  CALC_FAB_burden(p_record	bc_packets%ROWTYPE) return boolean
IS
  bc_pkt_rec 		bc_packets%rowtype;
  burden_raw_cost  	number;
  pkt_amount 		number;
  fab_adj_amount	NUMBER ;

BEGIN
     g_error_procedure_name := 'calc_fab_burden';
     IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':Start','C');
     END IF;

		bc_pkt_rec				:= 	p_record ;
		bc_pkt_rec.entered_cr	:=	nvl(bc_pkt_rec.entered_cr,0) ;
		bc_pkt_rec.entered_dr	:=	nvl(bc_pkt_rec.entered_dr,0) ;

        if bc_pkt_rec.entered_cr <>	0 then
           	pkt_amount := 0 - bc_pkt_rec.entered_cr;
        elsif bc_pkt_rec.entered_dr <>	0 then
           	pkt_amount := bc_pkt_rec.entered_dr;
        end if;

		FAB_adj_amount	:= 0 ;

	    -- ============================================================
	    -- Bug : 1776185 - IDC LIMITS OF $0 NOT BEING RECOGNIZED WHEN
	    --     :           BURDENING.
	    -- ============================================================
		/* -- Update in FUNCTION  update_bc_pkt_burden_raw_cost takes care of this ...
		IF x_calc_zero_limit THEN
			burden_raw_cost := 0 ;
			update_bc_packet('FAB', burden_raw_cost, pkt_amount, p_record ) ;
			return TRUE ;
		END IF ;


		IF nvl(x_award_exp_limit,0) <= 0 THEN
			-- --------------------------
			-- IDC Limit is not enabled.
			-- -------------------------
			burden_raw_cost	:= pkt_amount ;
			update_bc_packet('FAB', burden_raw_cost, pkt_amount, p_record ) ;
			return TRUE ;
		END IF ;
        */
		burden_raw_cost	:= common_logic(	pkt_amount,
											0,
											0,
										  	fab_adj_amount	) ;

		-- -------------------------------------------------------------------
		-- Update the Running Total.
		-- -------------------------------------------------------------------
		update_bc_packet('FAB', burden_raw_cost, pkt_amount, p_record ) ;

		return TRUE ;
EXCEPTION
	WHEN others THEN

          g_dummy := SQLERRM;
     	  IF g_debug = 'Y' THEN
      	     gms_error_pkg.gms_debug (g_error_procedure_name||':'||g_dummy,'C');
          END IF;

		RAISE ;
END CALC_FAB_burden ;

FUNCTION  CALC_EXP_burden(p_record	bc_packets%ROWTYPE,p_mode IN VARCHAR2 ) return boolean	-- Bug : 2557041 - Added p_mode parameter
IS
  pkt_amount 		number;
  x_adjustment_id	NUMBER ;
  x_line_num		NUMBER ;
  x_dummy			NUMBER ;
  burden_raw_cost  	number;
  exp_adj_amount	NUMBER ;
  x_rec_log			gms_burden_adjustments_log%ROWTYPE ;
  bc_pkt_rec 		bc_packets%rowtype;
  exp_adjustment	BOOLEAN ;

  -- =================================================================================
  -- ALLOW_BURDEN_FLAG - FLAG indicates that external system will provide burdened
  -- cost.
  -- =================================================================================
  x_allow_burden_flag	pa_transaction_sources.allow_burden_flag%TYPE ;
  x_transaction_source  pa_expenditure_items_all.transaction_source%TYPE ;

BEGIN
     g_error_procedure_name := 'calc_exp_burden';
     IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':Start','C');
     END IF;

		bc_pkt_rec				:= 	p_record ;
		bc_pkt_rec.entered_cr	:=	nvl(bc_pkt_rec.entered_cr,0) ;
		bc_pkt_rec.entered_dr	:=	nvl(bc_pkt_rec.entered_dr,0) ;
		x_allow_burden_flag 	:= 'N' ;
                x_transaction_source    := bc_pkt_rec.transaction_source;

                if bc_pkt_rec.entered_cr <>	0 then
           	        pkt_amount := 0 - bc_pkt_rec.entered_cr;
                elsif bc_pkt_rec.entered_dr <>	0 then
                	pkt_amount := bc_pkt_rec.entered_dr;
                end if;

                x_allow_burden_flag := burden_allowed(x_transaction_source);

		exp_adj_amount	:= 0 ;

                -- Set burdenable raw cost to zero if burden_allowed returns N.

		IF x_allow_burden_flag = 'N' THEN

			burden_raw_cost	:= 0 ;
			update_bc_packet('EXP', burden_raw_cost, pkt_amount, p_record ) ;
			return TRUE ;

		END IF ;


	    -- ============================================================
	    -- Bug : 1776185 - IDC LIMITS OF $0 NOT BEING RECOGNIZED WHEN
	    --     :           BURDENING.
	    -- ============================================================
		/* -- Update in FUNCTION  update_bc_pkt_burden_raw_cost takes care of this ...
		IF x_calc_zero_limit THEN
			burden_raw_cost := 0 ;
			update_bc_packet('EXP', burden_raw_cost, pkt_amount, p_record ) ;
			return TRUE ;
		END IF ;

		IF nvl(x_award_exp_limit,0) <= 0 THEN
			-- --------------------------
			-- IDC Limit is not enabled.
			-- -------------------------
			burden_raw_cost	:= pkt_amount ;
			update_bc_packet('EXP', burden_raw_cost, pkt_amount, p_record ) ;
			return TRUE ;
		END IF ;
        */

		burden_raw_cost	:= common_logic(	pkt_amount,
							x_rec_award_exp_tot.EXP_raw_cost,
							x_rec_award_exp_tot.EXP_burdenable_cost,
						  	exp_adj_amount	) ;

     IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':common logic->burden_raw_cost:'||burden_raw_cost||';'||'exp_adj_amount:'||exp_adj_amount,'C');
     END IF;

	       /* =================================================================
		  -- Bug : 2557041 -  Added for IP check funds Enhancement

		  As burden adjustment will not be carried out NOCOPY in check funds mode,
	          reutrn after updating the burdenable_raw_cost on gms_bc_packets
		  ================================================================== */

		IF p_mode = 'C' THEN
		   update_bc_packet('EXP', burden_raw_cost, pkt_amount, p_record ) ;
   		   RETURN TRUE ;
		END IF;


		-- --------------------------------------------------
		-- exp_adj_amount will be computed here only for +ve
		-- amounts.
		-- --------------------------------------------------
		IF exp_adj_amount <> 0 THEN

           g_request_id            := bc_pkt_rec.request_id;

			-- ------------------------------------------------
			-- exp adj_amount is the amount need to be adjusted
			-- We take the amount from ENC and update EXP.
			-- The sequence of adjustment is REQ- PO-ENC.
			-- -------------------------------------------------
			-- BUG:1349726 : ENC_BURDENABLE_COST is not
			-- released in acse of actuals with IDC scenario.
			-- --bc_pkt_rec.document_distribution_id COMMENTED
			-- because we always adjust from REQ<PO and ENC so
			-- we really don't care value of this here.
			-- In case of ENC bc_pkt_rec.document_distribution_id is
			-- 1 most of the time and ENC is always 1 so adjustment
			-- didn't happened.
			-- -------------------------------------------------

			x_dummy	:= 0 ;
			x_dummy := create_adjplus_log(	'REQ' ,
							exp_adj_amount,
							bc_pkt_rec.award_id,
							bc_pkt_rec.expenditure_type,
							bc_pkt_rec.packet_id,
							bc_pkt_rec.bc_packet_id,
							bc_pkt_rec.document_header_id,
							--bc_pkt_rec.document_distribution_id,
							0,
							FALSE,
							x_adjustment_id	,
							x_line_num )  ;

			burden_raw_cost	:=	burden_raw_cost + x_dummy ;

		END IF ;

		-- -------------------------------------------------------------------
		-- Update the Running Total.
		-- -------------------------------------------------------------------
		update_bc_packet('EXP', burden_raw_cost, pkt_amount, p_record ) ;

		return TRUE ;

EXCEPTION
	WHEN others THEN

          g_dummy := SQLERRM;
     	  IF g_debug = 'Y' THEN
      	     gms_error_pkg.gms_debug (g_error_procedure_name||':'||g_dummy,'C');
          END IF;

		RAISE ;
END  CALC_EXP_burden;
-- ================== End of CALC_EXP_burden == ======================

-- ----------------------------------------------------------------------------- +
-- New procedure, added 11i.GMS.M , Bug 3389292: burden log changes..
-- Following procedure maximizes burden within and outside the packet
-- First, it will check if there are any txns. that needs to be maximized
-- within the packet.
-- Then it will check if there are any AP txns. outside the packet (FC passed)
-- txns. that needs to be maximized.
-- ----------------------------------------------------------------------------- +
PROCEDURE Maximize_burden(p_packet_id in number) is
-- pick award and expenditure type that has
-- * limit (non-zero)
-- * Only check original transaction being FC'ed (parent_bc_packet_id is null)
Cursor c_awd_exp is
       select distinct gbp.award_id,gbp.expenditure_type
       from   gms_bc_packets gbp,
              gms_awards_all ga,
              gms_allowable_expenditures gae
       where  gbp.packet_id = p_packet_id
       and    ga.award_id   = gbp.award_id
       and    gae.allowability_schedule_id = ga.allowable_schedule_id
       and    gae.expenditure_type = gbp.expenditure_type
       and    nvl(gae.burden_cost_limit,0) > 0
       and    gbp.parent_bc_packet_id is null;

-- Get bcpacket records (+ve txn) for an award/expenditure type that has
-- records that are underburdened ...
-- order by diff between raw and burden asc.
-- ascending used as smaller txns. will get processed for FC/bill limits
-- Only check original transaction being FC'ed (parent_bc_packet_id is null)
Cursor c_bcpkts(x_award_id in number, x_expenditure_type in varchar2) is
       select rowid,
              entered_dr ,
              nvl(burdenable_raw_cost,0) burden
       from   gms_bc_packets gbp
       where  gbp.packet_id = p_packet_id
       and    gbp.award_id  = x_award_id
       and    gbp.expenditure_type = x_expenditure_type
       and    nvl(gbp.entered_dr,0) >  0
       and    nvl(entered_cr,0) = 0
       and    nvl(gbp.entered_dr,0) <> nvl(gbp.burdenable_raw_cost,0)
       and    gbp.parent_bc_packet_id is null
       order by decode(gbp.document_type,'EXP',1,'AP',2,'ENC',3,'PO',4,'REQ',5,6) asc,
                nvl(gbp.entered_dr,0) desc;

-- Variable holds burden that can be maximized
x_avail_burden_amt gms_bc_packets.burdenable_raw_cost%type;

-- Variable to hold stage
x_stage number(2);

-- --------------------------------------------------------------+
  x_rec_log   gms_burden_adjustments_log%ROWTYPE ;
  x_doc_adj   c_adj_rec ;
  c_rec       commitRecTyp ;
  x_temp	  NUMBER ;
  x_adjustment_id NUMBER ;

  -- Variable stores burden amount that can be updated on AP txn.
  X_burden_amt_to_update_on_txn NUMBER;

  -- Cursor that checks for Net Zero AP
   cursor AP_ZERO_INVOICE (p_invoice_id in number,
                           p_award_id in number,
                           p_expenditure_type in varchar2) is
  	  select sum( pa_cmt_utils.get_apdist_amt(ap.invoice_distribution_id,
				                                ap.invoice_id,
												nvl(ap.base_amount,ap.amount),
												'N',
												'GMS',nvl(g.sla_ledger_cash_basis_flag,'N') ) )	sum_amount
  	   FROM ap_invoice_distributions 	AP,
		   gms_award_distributions 	ADL,
		   GL_LEDGERS				G
	  where adl.invoice_distribution_id	= AP.invoice_distribution_id
	    and adl.adl_status				= 'A'
	    and adl.award_id				= p_award_id
	    and ap.expenditure_type			= p_expenditure_type
	    and ADL.award_set_id			= AP.award_id
	    and ap.invoice_id				= p_invoice_id
    	    and  G.LEDGER_ID = AP.SET_OF_BOOKS_ID
		and pa_cmt_utils.get_apdist_amt(ap.invoice_distribution_id,
		                                ap.invoice_id,
										nvl(ap.base_amount,ap.amount),
										'N',
										'GMS', nvl(g.sla_ledger_cash_basis_flag,'N') ) <> 0
	    and decode(ap.pa_addition_flag,'Z','Y','G','Y','T','Y','E','Y',NULL,'N',ap.pa_addition_flag) <> 'Y' ;

 -- Cursor to pick expenditure items that has lead to maximizing AP ..
Cursor c_bcpkts_max(p_award_id in number, p_expenditure_type in varchar2) is
       select bc_packet_id,
              abs(nvl(burdenable_raw_cost,0)) burdenable_raw_cost
       from   gms_bc_packets gbp
       where  gbp.packet_id = p_packet_id
       and    gbp.award_id  = p_award_id
       and    gbp.expenditure_type = p_expenditure_type
       and    nvl(gbp.burdenable_raw_cost,0) < 0
       and    gbp.parent_bc_packet_id is null
       order by nvl(gbp.burdenable_raw_cost,0)  desc;

x_bc_packet_id gms_bc_packets.bc_packet_id%type;
x_burdenable_raw_cost gms_bc_packets.burdenable_raw_cost%type;

Begin
    g_error_procedure_name := 'Maximize_burden';
     IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':Start','C');
     END IF;
  -- ------------------------------------------------------------------+
  -- Maximizing common logic
  -- ------------------------------------------------------------------+
  -- initialize variables ..
   x_cmt_tot_burden := 0;
   x_tot_raw        := 0;
   x_tot_burden     := 0;
   x_stage          := 10;

 -- Open cursor
    for x in c_awd_exp  -- Award,Exp Type Loop
    loop
      -- Savepoint
      SAVEPOINT RECONCILE1;
     IF g_debug = 'Y' THEN
     	gms_error_pkg.gms_debug (g_error_procedure_name||':Maximize:award/exp:'||x.award_id||';'||x.expenditure_type,'C');
     END IF;
      -- Cursor and variable defined at package level ..
      Open  c_lock_burden_summary(x.award_id,x.expenditure_type);
      fetch c_lock_burden_summary into l_lock_burden_summary;
      close c_lock_burden_summary;

      -- Get raw and burden total, idc limit
      proc_get_award_exp_total( p_packet_id, x.award_id, x.expenditure_type ) ;
      g_error_procedure_name := 'Maximize_burden';
      -- need to re-initalize g_error_procedure_name

     IF g_debug = 'Y' THEN
     	gms_error_pkg.gms_debug (g_error_procedure_name||':x_award_exp_limit:'||x_award_exp_limit||';'||'x_tot_burden:'||x_tot_burden||';'||'x_tot_raw:'||x_tot_raw,'C');
     END IF;

      -- Check if there is any maximizing scope
      If (x_award_exp_limit <= x_tot_burden) -- burden.cost v/s idc limit
          OR
          (x_tot_raw <= x_tot_burden)  -- burden.cost v/s raw.cost
      then
         IF g_debug = 'Y' THEN
         	gms_error_pkg.gms_debug (g_error_procedure_name||':No maximization reqd. as burden already maximized','C');
         END IF;
          -- No maximizing required

          GOTO END_OF_PROCESS;

      End If;

      -- Get burden available for maximizing
      -- case idc:100, raw:80  and burden:70 , x_avail_burden_amt = 10
      -- case idc:75,  raw:80  and burden:70 , x_avail_burden_amt = 5
      x_avail_burden_amt := least(x_award_exp_limit,x_tot_raw) - x_tot_burden;

     IF g_debug = 'Y' THEN
     	gms_error_pkg.gms_debug (g_error_procedure_name||':x_avail_burden_amt:'||x_avail_burden_amt,'C');
     END IF;

      -- If nothing to apply then no maximizing required.
      If x_avail_burden_amt <= 0 then
          -- No maximizing required
         IF g_debug = 'Y' THEN
         	gms_error_pkg.gms_debug (g_error_procedure_name||':No maximization reqd. as no burden left to maximize','C');
         END IF;

          GOTO END_OF_PROCESS;
      End If;

      x_stage := 20;
  -- ------------------------------------------------------------------+
  -- Maximizing gms_bc_packet records
  -- ------------------------------------------------------------------+
      for y in c_bcpkts(x.award_id,x.expenditure_type)
      loop -- Bcpkt record loop
         If ((y.entered_dr - y.burden) >= x_avail_burden_amt) then

             Update gms_bc_packets
             set    burdenable_raw_cost = nvl(burdenable_raw_cost,0) + x_avail_burden_amt
             where  rowid               = y.rowid;

             x_avail_burden_amt := 0;

          Else
             Update gms_bc_packets
             set    burdenable_raw_cost = y.entered_dr
             where  rowid               = y.rowid;

             x_avail_burden_amt := x_avail_burden_amt - (y.entered_dr - y.burden);

          End If;

          If x_avail_burden_amt = 0 then
             EXIT;
          End If;
      End loop; -- Bcpkt record loop

     IF g_debug = 'Y' THEN
     	gms_error_pkg.gms_debug (g_error_procedure_name||':After max. packet,x_avail_burden_amt:'||x_avail_burden_amt,'C');
     END IF;

      If x_avail_burden_amt = 0 then
          -- No maximizing required
         IF g_debug = 'Y' THEN
         	gms_error_pkg.gms_debug (g_error_procedure_name||':Packet maximized,No further maximization reqd. as x_avail_burden_amt:'||x_avail_burden_amt,'C');
         END IF;

         GOTO END_OF_PROCESS;
      End If;

  -- ------------------------------------------------------------------+
  -- Maximizing records that has already passed FC,outside current pkt.
  -- ------------------------------------------------------------------+
       x_stage := 30;
       SAVEPOINT RECONCILE2;
     -- A.0 open cursor using the base table
     --    Fetch AP records that are underburdened ...
     open_ref_cursor ( x_doc_adj,
					  'AP',
				  	  x.award_id,
					  x.expenditure_type,
					  NULL, -- p_dist_id
					  NULL, -- p_header_id  ,
					  'MAXIMIZE_BURDEN'); -- p_calling_seq
 	 LOOP
	   Fetch x_doc_adj into c_rec ;
 		If x_doc_adj%notfound THEN
           -- A.1 if no AP records exist .. exit out for award/exp type ..
           IF g_debug = 'Y' THEN
              g_error_procedure_name := 'Maximize_Burden';
       	      gms_error_pkg.gms_debug (g_error_procedure_name||':No AP txns. to maximize - Exiting, Burden available to max:'||x_avail_burden_amt,'C');
           END IF;

           Close x_doc_adj ;
           exit ;
		End If;

        g_error_procedure_name := 'Maximize_Burden';
        IF g_debug = 'Y' THEN
     	   gms_error_pkg.gms_debug (g_error_procedure_name||':AP txns:header_id,raw.cost,burden.cost:'||c_rec.header_id||';'||c_rec.amount||';'||c_rec.burden,'C');
        END IF;

       -- A.2 Check if its a NET zero AP .
         Open  AP_ZERO_INVOICE(c_rec.header_id,x.award_id,x.expenditure_type);
	 	 Fetch AP_ZERO_INVOICE into x_temp ;
 	     Close AP_ZERO_INVOICE ;

  		 If x_temp = 0 THEN
           IF g_debug = 'Y' THEN
       	      gms_error_pkg.gms_debug (g_error_procedure_name||':Skipping AP txns:net zero AP','C');
           END IF;

 	       GOTO SKIP_THIS;
		 End If;

        IF g_debug = 'Y' THEN
     	   gms_error_pkg.gms_debug (g_error_procedure_name||':After Net Zero Check','C');
        END IF;

       -- A.3 What is the burden amount that can be updated on this transaction ..
              If (c_rec.amount - c_rec.burden) >= x_avail_burden_amt then
                  X_burden_amt_to_update_on_txn := x_avail_burden_amt;
                  x_avail_burden_amt            := 0;
                  -- All available burden can be updated on this txn.
              Else
                  X_burden_amt_to_update_on_txn := c_rec.amount - c_rec.burden;
                  x_avail_burden_amt            := x_avail_burden_amt - X_burden_amt_to_update_on_txn;
                  -- Only a portion of the available burden can be updated on this txn.
              End If;

        IF g_debug = 'Y' THEN
     	   gms_error_pkg.gms_debug (g_error_procedure_name||':X_burden_amt_to_update_on_txn:'||X_burden_amt_to_update_on_txn,'C');
        END IF;

       -- A.4 Get burden_calculation_seq (adjustment_id) and set values (Common)
 			  select gms_adjustments_id_s.NEXTVAL
			  INTO   x_adjustment_id
			  FROM   dual ;

			  x_rec_log.packet_id		    := p_packet_id ;
			  x_rec_log.award_id			:= x.award_id;
		      x_rec_log.expenditure_type    := x.expenditure_type ;
			  x_rec_log.document_type		:= 'AP';
			  x_rec_log.amount			    := 0 ;
			  x_rec_log.source_flag		    := 'Y' ;
			  x_rec_log.adjustment_id		:= x_adjustment_id ;
			  x_rec_log.document_header_id  := c_rec.header_id ;
			  x_rec_log.document_distribution_id := c_rec.dist_id ;


 		      x_rec_log.last_update_date  := sysdate;
  		      x_rec_log.last_updated_by   := -1;
  		      x_rec_log.created_by        := -1;
  		      x_rec_log.creation_date     := sysdate;
  		      x_rec_log.last_update_login := -1;

              IF g_debug = 'Y' THEN
        	      gms_error_pkg.gms_debug (g_error_procedure_name||':before loop:X_burden_amt_to_update_on_txn:'||X_burden_amt_to_update_on_txn,'C');
              END IF;

       -- A.5 Get bcpkt transaction that caused this burden maximization
       For z in c_bcpkts_max(x.award_id,x.expenditure_type)
       Loop

         -- A.6 Txn. found, check if this txn is responsible for the burden available
            If z.burdenable_raw_cost >= X_burden_amt_to_update_on_txn then
               x_rec_log.adj_burdenable_amount := X_burden_amt_to_update_on_txn;
               X_burden_amt_to_update_on_txn   := 0;
            Else
               x_rec_log.adj_burdenable_amount := z.burdenable_raw_cost;
               X_burden_amt_to_update_on_txn := X_burden_amt_to_update_on_txn - z.burdenable_raw_cost;
            End If;
			x_rec_log.bc_packet_id		:= z.bc_packet_id ;

         -- A.7 Create burden adjustments ..
		     create_burden_adjustments(x_rec_log,
									  c_rec.project_id,
									  c_rec.task_id,
									  c_rec.expenditure_item_date,
									  c_rec.expenditure_organization_id,
									  c_rec.resource_list_member_id,
									  c_rec.bud_task_id,
								      c_rec.ind_compiled_set_id) ;

         If X_burden_amt_to_update_on_txn = 0 then
            exit;
         End if;
       End Loop; -- bcpkt loop

       IF g_debug = 'Y' THEN
   	      gms_error_pkg.gms_debug (g_error_procedure_name||':After loop:X_burden_amt_to_update_on_txn:'||X_burden_amt_to_update_on_txn,'C');
       END IF;

       If X_burden_amt_to_update_on_txn <> 0 then
          -- A.8 There are no records in bcpkts that can account for the available
          --     burden amount that can be maximized on this AP txn...
          --     Create record with dummy bc_packet_id
            x_rec_log.adj_burdenable_amount := X_burden_amt_to_update_on_txn;
            X_burden_amt_to_update_on_txn   := 0;
            x_rec_log.bc_packet_id		    := -1;

         -- A.9 Create burden adjustments ..
		     create_burden_adjustments(x_rec_log,
									  c_rec.project_id,
									  c_rec.task_id,
									  c_rec.expenditure_item_date,
									  c_rec.expenditure_organization_id,
									  c_rec.resource_list_member_id,
									  c_rec.bud_task_id,
								      c_rec.ind_compiled_set_id) ;

        End If;

       IF g_debug = 'Y' THEN
   	      gms_error_pkg.gms_debug (g_error_procedure_name||':After all bckpt:X_burden_amt_to_update_on_txn:'||X_burden_amt_to_update_on_txn,'C');
       END IF;

       IF g_debug = 'Y' THEN
   	      gms_error_pkg.gms_debug (g_error_procedure_name||':After all bckpt:x_avail_burden_amt:'||x_avail_burden_amt,'C');
       END IF;

       -- A.10 No more burden available to maximize, go to next award/exp type ..
       --      else continue with the next AP transaction
     	  If x_avail_burden_amt = 0 then
             exit;
          End If;

    	<<SKIP_THIS>>
          null;
     END LOOP; -- AP txn. loop

     <<END_OF_PROCESS>>
      -- Initialize variables
      x_avail_burden_amt := 0;
      x_cmt_tot_burden := 0;
      x_tot_raw        := 0;
      x_tot_burden     := 0;

      COMMIT;
    end loop;  -- Award,Exp Type Loop

Exception
  When no_data_found then
        g_dummy := SQLERRM;
        IF g_debug = 'Y' THEN
     	   gms_error_pkg.gms_debug (g_error_procedure_name||':'||g_dummy,'C');
        END IF;

       If x_stage < 30 then
          ROLLBACK TO RECONCILE1;
       Elsif x_stage = 30 then
          ROLLBACK TO RECONCILE2;
       End If;
       commit;

  When others then

        g_dummy := SQLERRM;
        IF g_debug = 'Y' THEN
     	   gms_error_pkg.gms_debug (g_error_procedure_name||':'||g_dummy,'C');
        END IF;

       If x_stage < 30 then
          ROLLBACK TO RECONCILE1;
       Elsif x_stage = 30 then
          ROLLBACK TO RECONCILE2;
       End If;
       commit;
End Maximize_burden;

-- ============================================================================
-- R12 Funds Management Uptake : From R12 onwards Payables and  Purchasings
-- code will no longer save the transactions before calling grants, hence
-- existing logic needs to be modified such that the part of code which needs
-- access to AP/PO/REQ tables get fired from main session and the remaining code
-- gets  fired in autonomous mode as its existing currently.
-- Introduced new Autonomous procedure to handle all the updates on gms_bc_packet
-- which were in function  update_bc_pkt_burden_raw_cost

-- --------------------------------------------------------------
-- Function to update the burdenable raw cost,budget version Id and status
-- in GMS_BC_PACKETS.All the records for a packet is updated.
-- Parameters :
-- ==============
-- p_action  : This parameter defines action to be performed on gms_bc_packets
--             Values :
--               'UPDATE-STATUS': Update result_code and status_code on gms_bc_packets
--               'UPDATE-BVID'  : Update budget_version_id on gms_bc_packets
--               'UPDATE-BRC'   : Update burdenable Raw cost on gms_bc_packets
-- p_packet_id  : Packets associated with this packet_id in gms_bc_packets will be updated
-- p_award_id   : Packets associated with this award_id in gms_bc_packets will be updated
-- p_expenditure_type  : Packets associated with this EXP type in gms_bc_packets will be updated
-- p_full_mode_failure : If 'Y' update all the records in packet to failed status
-- p_result_code       : Failed result code

-- --------------------------------------------------------------

PROCEDURE update_bc_pkt_brc_bvid_status (p_action             IN VARCHAR2,
                                         p_mode               IN VARCHAR2 DEFAULT NULL,
                                         p_packet_id          IN NUMBER   DEFAULT NULL,
					 p_award_id           IN NUMBER   DEFAULT NULL,
					 p_expenditure_type   IN VARCHAR2 DEFAULT NULL,
					 p_full_mode_failure  IN VARCHAR2 DEFAULT NULL,
					 x_result_code        IN OUT NOCOPY VARCHAR2
                                          ) IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_count NUMBER;

BEGIN

    IF g_debug = 'Y' THEN
	gms_error_pkg.gms_debug ('UPDATE_BC_PKT_BRC_BVID_STATUS' ||': Start'||l_count,'C');
    END IF;

    IF p_action = g_update_brc THEN

          IF g_debug = 'Y' THEN
	     gms_error_pkg.gms_debug ('UPDATE_BC_PKT_BRC_BVID_STATUS'||': Burdenable Raw cost update :','C');
	  END IF;

	/* --------------------------------------------------------------------
	  -- This update will take care of 3 scenarios:
	  --  A. Non-IDC limit
	  --  B. Zero$ IDC Limit
	  --  C. P82 scenarios
	  --  Logic:
	  --  i.If result code is 'P82' , update burdenable raw cost to zero (net zero)
	  --  ii.   If not, check transaction source of transaction
	  --  iii.   No txn. source, check limit,
	  --  iv.                    if no limit, same as raw_cost,
	  --  v.                     if limit=0, burdenable raw cost=0
	  --  vi.                    if limit, do not update burdeanable raw cost
	  --  vii.   If txn. source, then check burden allowed?
	  --  viii.  No ..burden is zero
	  -- ix.     yes ..  step iv - vi ..
	  -------------------------------------------------------------------- */

/* Bug 5344693 : The following update is modified such that
   if burden_allowed function returns 'Y' (i.e burden is imported from external transaction source and do not calculate in Projects )
   then burdenable raw cost should be 0
   else if burden_allowed returns 'N' (i.e  burden is calculated in projects )
   then calculate the burdenable raw cost. */

	  Update gms_bc_packets gbc
	  Set    gbc.burdenable_raw_cost =
		 (select decode(gbc.result_code,'P82',0,
				decode(gbc.transaction_source,
				       null,decode(gae.burden_cost_limit,
						   null,(gbc.entered_dr-entered_cr),
						   0,0,gbc.burdenable_raw_cost
						   )
				       ,decode(burden_allowed(gbc.transaction_source),
					       'N',0,
					       'Y',decode(gae.burden_cost_limit,
							  null,(gbc.entered_dr-entered_cr),
							  0,0,gbc.burdenable_raw_cost
							 )
					      )
				      )
				)
		  from   gms_allowable_expenditures gae,
			 gms_awards_all ga
		  where  ga.award_id = gbc.award_id
		  and    gae.allowability_schedule_id = ga.allowable_schedule_id
		  and    gae.expenditure_type = gbc.expenditure_type
	         )
	  where  packet_id =  p_packet_id
	  and    status_code in ('P','I')
	  and    burdenable_raw_cost is NULL;

	  l_count := SQL%ROWCOUNT;

          IF g_debug = 'Y' THEN
	     gms_error_pkg.gms_debug ('UPDATE_BC_PKT_BRC_BVID_STATUS'||':Burdenable raw Cost Updated on :'||l_count||' records','C');
	  END IF;

    ELSIF p_action = g_update_status THEN

          IF g_debug = 'Y' THEN
	     gms_error_pkg.gms_debug ('UPDATE_BC_PKT_BRC_BVID_STATUS'||': Result Code update :','C');
	  END IF;

	  update gms_bc_packets
	     set result_code		= x_result_code
	   where packet_id 		= p_packet_id
	     and award_id       	= NVL(p_award_id,award_id)
	     and expenditure_type       = NVL(p_expenditure_type,expenditure_type) ;

	  l_count := SQL%ROWCOUNT;

          IF g_debug = 'Y' THEN
	     gms_error_pkg.gms_debug ('UPDATE_BC_PKT_BRC_BVID_STATUS'||':result code '||x_result_code||' Updated on :'||l_count||' records','C');
	  END IF;


	  If p_full_mode_failure = 'Y'  then -- Encumbrance : PO/AP/REQ
	       Update gms_bc_packets
		  set status_code = 'R',
		      result_code = decode(substr(result_code,1,1),'P','F65',result_code)
		where packet_id = p_packet_id;

	       l_count := SQL%ROWCOUNT;

               IF g_debug = 'Y' THEN
	             gms_error_pkg.gms_debug ('UPDATE_BC_PKT_BRC_BVID_STATUS'||':F65 (full mode failure) Updated on :'||l_count||' records','C');
               END IF;

	  END IF;


    ELSIF p_action = g_update_bvid THEN

           -- Update budget_verison_id on gms_bc_packets. This is required as cursor c_Act
           -- checks for gms_bc_packet trasnactions that has a baselined budget only
           -- during summarization ...

          IF g_debug = 'Y' THEN
	     gms_error_pkg.gms_debug ('UPDATE_BC_PKT_BRC_BVID_STATUS'||': Budget version Id update :','C');
	  END IF;

          Update gms_bc_packets bcp
          set    bcp.budget_version_id = (select gbv.budget_version_id
			  	            from gms_budget_versions gbv
					   where gbv.award_id           = bcp.award_id
					     and gbv.project_id         = bcp.project_id
					     and gbv.budget_status_code ='B'
					     and gbv.current_flag       = 'Y'
                                         )
          where  bcp.packet_id = p_packet_id
          and    bcp.award_id  = p_award_id
          and    bcp.expenditure_type = p_expenditure_type;

          Begin

            Select 1 into l_count
		from dual where exists
                 (select 1 from gms_bc_packets bcp
                  where  bcp.packet_id = p_packet_id
                  and    bcp.award_id  = p_award_id
                  and    bcp.expenditure_type = p_expenditure_type
			      and    bcp.budget_version_id is null);

             IF g_debug = 'Y' THEN
        	gms_error_pkg.gms_debug ('UPDATE_BC_PKT_BRC_BVID_STATUS'||':Budget version id failure: Award,Exp.type:'||p_award_id||';'||p_expenditure_type,'C');
             END IF;

                   x_result_code := 'F';

		   Update gms_bc_packets
	           set    status_code = decode(p_mode,'C','F','R'),
		          result_code = 'F12',
			  fc_error_message = 'Could not derive budget version during burden calculation'
	           where  packet_id = p_packet_id
		   and    award_id  = p_award_id
		   and    expenditure_type = p_expenditure_type
		   and    budget_version_id is null;

           If p_full_mode_failure    = 'Y' then  -- Encumbrance : PO/AP/REQ

             IF g_debug = 'Y' THEN
        	gms_error_pkg.gms_debug ('UPDATE_BC_PKT_BRC_BVID_STATUS'||':Budget version id failure: Full mode failure','C');
             END IF;

              Update gms_bc_packets
		 set status_code = decode(p_mode,'C','F','R'),
		     result_code = decode(substr(result_code,1,1),'P','F65',result_code)
  	       where  packet_id = p_packet_id;

           End If;

          Exception
              When no_Data_found then
                   null;
          End;

    END IF;

 COMMIT;

 EXCEPTION
    when others then
        IF g_debug = 'Y' THEN
           gms_error_pkg.gms_debug ('UPDATE_BC_PKT_BRC_BVID_STATUS'||':When Others Exception','C');
        END IF;

        raise;
END update_bc_pkt_brc_bvid_status;


-- --------------------------------------------------------------
-- Function to calculate and update the burdenable raw cost in GMS_BC_PACKETS
-- All the records for a packet is updated.
-- R12 Funds Managment Uptake : Modified below code to
--  a. shift updates to new autonomous procedure  update_bc_pkt_brc_bvid_status
--  b. Added p_partial_flag parameter to fail records in bc packets based on FULL/PARTIAL MODE.
-- --------------------------------------------------------------

FUNCTION  update_bc_pkt_burden_raw_cost(x_packet_id    IN NUMBER,
                                        p_mode         IN VARCHAR2, -- Bug : 2557041 - Added p_mode parameter
					p_partial_flag IN VARCHAR2 DEFAULT 'N') return boolean

IS

   stat  				boolean;
   X_total 	        	NUMBER ;
   l_expenditure_type  gms_bc_packets.expenditure_type%TYPE ;
   l_award_id          gms_bc_packets.award_id%TYPE ;
   l_header_id		  	NUMBER	;
   X_result_code        VARCHAR2(3) ;

  cursor C_award_exp is
   select distinct bcp.award_id, bcp.expenditure_type
       from gms_bc_packets bcp,
            gms_awards_all ga,
            gms_allowable_expenditures gae
      where bcp.packet_id   = x_packet_id
        and status_code     IN ('P','I')   -- fix for bug : 2927485 ,to reject the transactions that may have already failed a setup step
        and bcp.burdenable_raw_cost is NULL
        and ga.award_id     = bcp.award_id
        and gae.allowability_schedule_id = ga.allowable_schedule_id
        and gae.burden_cost_limit  is not null;

  l_dummy number;
  l_full_mode_failure varchar2(1) := 'N';
  l_result_code   gms_bc_packets.result_code%TYPE;

BEGIN

      -------------------------------------------------------------------------------+
      -- 1. Initalize variables
      -------------------------------------------------------------------------------+

      g_error_program_name   := 'GMS_COST_PLUS_EXTN';
      g_error_procedure_name := 'UPDATE_BC_PKT_BURDEN_RAW_COST';
      g_debug                := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N');
      -- R12 Funds Management Uptake : Intializing global variables
      g_update_status        := 'UPDATE-STATUS';
      g_update_bvid          := 'UPDATE-BVID';
      g_update_brc           := 'UPDATE-BRC';

      gms_error_pkg.set_debug_context;

   IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':Start','C');
   END IF;

   SAVEPOINT SAVE_CALC_PROCESS ;
   X_err_stage := 'STG_13_STR' ;

   -- R12 Funds Management Uptake : Call autonomous procedure to update
   update_bc_pkt_brc_bvid_status (p_action     => g_update_brc,   --'UPDATE-BRC'
                        	  p_packet_id  => x_packet_id,
                                  x_result_code => l_result_code );

  -- Derive g_actual_flag , g_actual_flag and p_mode will determine full mode
  -- If any txn. fails in full mode, exit out and fail all transactions
  If p_mode in ('U','C','E') then
     g_actual_flag := 'E';
  Elsif p_mode in ('R') then
    Begin
     select 'A' into g_actual_flag from dual where exists
                 (select 1 from gms_bc_packets where packet_id = x_packet_id
			      and document_type = 'EXP');
    Exception
      When no_data_found then
        g_actual_flag := 'E';
    End;
  End if;

  -- R12 Funds Management Uptake : For AP/PO/REQ records derive l_full_mode_failure
  -- based on input parameter p_partial_flag

   IF g_actual_flag ='E' AND  p_mode <> 'E' AND p_partial_flag = 'N' THEN
     l_full_mode_failure := 'Y';
   END IF;

   FOR C_INDEX in c_award_exp LOOP

     l_expenditure_type	:=	C_INDEX.expenditure_type ;
     l_award_id			:=	C_INDEX.award_id ;

	 -- ------------------------------------------------------------------------
	 -- We need to calculate the award and exptype balance at this point of time
	 -- based on unposted records and available balance into
	 -- gms_award_exp_type_act_cost table.
	 -- -------------------------------------------------------------------------
	 SAVEPOINT	SAVE_CALC_AWARD_EXP ;
     BEGIN


      X_err_stage := 'STG_142_ST';

      -- R12 Funds Management Uptake : Call autonomous procedure to stamp budget_verson_id on bc_packets.
      -- This code should be fired before locking summary table
       update_bc_pkt_brc_bvid_status  (  p_action             => g_update_bvid,
                                         p_mode               => p_mode,
                                         p_packet_id          => x_packet_id,
	     			         p_award_id           => l_award_id,
				         p_expenditure_type   => l_expenditure_type,
				         p_full_mode_failure  => l_full_mode_failure,
                                         x_result_code        => l_result_code );


       IF SUBSTR(l_result_code,1,1) = 'F' AND l_full_mode_failure = 'Y' THEN -- Exit the loop if full mode and one of them has failed
         EXIT;
       ELSIF SUBSTR(l_result_code,1,1) = 'F' THEN -- Skip this record
         GOTO SKIP_AWD_EXP;
       END IF;

       X_err_stage := 'STG_142_ED';

       -- Cursor and variable defined at package level ..
       Open  c_lock_burden_summary(l_award_id,l_expenditure_type);
       fetch c_lock_burden_summary into l_lock_burden_summary;
       close c_lock_burden_summary;

           X_err_stage := 'STG_14_STR' ;
	       proc_get_award_exp_total( x_packet_id, l_award_id, l_expenditure_type ) ;

               -- R12 Funds Management Uptake : Shifted Budget version Id update code before locking

	       -- Bug : 2557041 - Added p_mode parameter , This parameter is used to
	       --		  restrict creation of burden adjustments in check funds mode

	       FOR C_rec  in  bc_packets( x_packet_id, l_award_id,l_expenditure_type ) LOOP

		      IF c_rec.document_type = 'REQ' THEN
                 X_err_stage := 'STG_15_STR' ;
			     stat	:= calc_req_burden(c_rec,p_mode) ;
                 X_err_stage := 'STG_15_END' ;
		      ELSIF c_rec.document_type = 'PO'  THEN
                 X_err_stage := 'STG_16_STR' ;
			     stat	:= calc_PO_burden(c_rec,p_mode) ;
                 X_err_stage := 'STG_16_END' ;
		      ELSIF c_rec.document_type = 'AP'  THEN
                 X_err_stage := 'STG_17_STR' ;
			     stat	:= calc_AP_burden(c_rec,p_mode) ;
                 X_err_stage := 'STG_17_END' ;
		 /*     ELSIF c_rec.document_type = 'ENC' THEN  Commented for bug 5726575
                 X_err_stage := 'STG_18_STR' ;
			     stat	:= calc_ENC_burden(c_rec) ;
                 X_err_stage := 'STG_18_END' ;*/
		      ELSIF c_rec.document_type = 'EXP' THEN
                 X_err_stage := 'STG_19_STR' ;
			     stat	:= calc_EXP_burden(c_rec,p_mode) ;
                 X_err_stage := 'STG_19_END' ;
		      ELSIF c_rec.document_type = 'FAB' THEN
                 X_err_stage := 'STG_FB_STR' ;
			     stat	:= calc_FAB_burden(c_rec) ;
                 X_err_stage := 'STG_FB_END' ;
		      ELSE
                 X_err_stage := 'STG_20_NUL' ;
			     NULL ;
		      END IF ;

              if (stat = FALSE) then
        	      EXIT ;
     	      end if;

	       END LOOP ;

                        --Bug 5726575
                        FOR C_rec_enc in  bc_packets_enc( x_packet_id, l_award_id,l_expenditure_type ) LOOP
                          X_err_stage := 'STG_18_STR' ;
                          stat        := calc_ENC_burden(c_rec_enc) ;
                          X_err_stage := 'STG_18_END' ;
                          if (stat = FALSE) then
                            EXIT ;
                          end if;
                        END LOOP ;

           if (stat = FALSE) then

             -- R12 Funds Management Uptake : Call autonomous procedure to update.

             l_result_code := 'F49';
	     update_bc_pkt_brc_bvid_status (  p_action             => g_update_status,
                   		              p_packet_id          => x_packet_id,
	  				      p_award_id           => l_award_id,
 				              p_expenditure_type   => l_expenditure_type,
				              p_full_mode_failure  => 'N',
				              x_result_code        => l_result_code );

           end if;

     -- COMMIT; -- R12 Funds Management Uptake
     -- This commit will undo the lock that was applied on summary table.

     EXCEPTION
        WHEN  RESOURCE_BUSY  THEN
         -- We couldn't acquire the locks at this time so
         -- We need to abort the processing and have the
         -- stataus Failed .
         -- F40 - Unable to acquire Locks on GMS_AWARD_EXP_TYPE_ACT_COST
         -- ------------------------------------------------------------

	     ROLLBACK to SAVE_CALC_AWARD_EXP ;

           -- R12 Funds Management Uptake : Call autonomous procedure to update.
           l_result_code := 'F40';
           update_bc_pkt_brc_bvid_status (  p_action             => g_update_status,
                                              p_packet_id          => x_packet_id,
			                      p_award_id           => l_award_id,
                   			      p_expenditure_type   => l_expenditure_type,
				              p_full_mode_failure  => l_full_mode_failure,
				              x_result_code        => l_result_code );

          If l_full_mode_failure ='Y' then
              EXIT;
          End If;

        WHEN  OTHERS  THEN

		   -- -------------------------------------------
		   -- Rollback the changes done till this point.
		   -- -------------------------------------------
	       ROLLBACK to SAVE_CALC_AWARD_EXP ;

           IF    X_err_stage = 'STG_14_STR' THEN
               -- ---------------------------------
               -- Award Exp Type get total failed.
               -- ---------------------------------
               x_result_code := 'F44' ;
           ELSIF X_err_stage = 'STG_15_STR' OR
                 X_err_stage = 'STG_16_STR' OR
                 X_err_stage = 'STG_17_STR' OR
                 X_err_stage = 'STG_18_STR' OR
                 X_err_stage = 'STG_FB_STR' OR
                 X_err_stage = 'STG_19_STR' THEN
                 -- -----------------------------------------------
                 -- F45 : Burden Calculation failed at award and
                 --     : expenditure level.
                 -- -----------------------------------------------
                 x_result_code := 'F45' ;
           ELSIF X_err_stage = 'STG_21_STR' THEN
                 -- -----------------------------------------------
                 -- F46 : BUMP UP calculations failed for IDC Limit
                 --     : Scenarios at award and expenditure level.
                 -- -----------------------------------------------
                 x_result_code := 'F46' ;
           ELSE
                 -- -----------------------------------------------
                 -- F47 : Burden Calculation Failed,
                 --     : Scenarios at award and expenditure level.
                 -- -----------------------------------------------
                 x_result_code := 'F47' ;
           END IF ;

           -- R12 Funds Management Uptake : Call autonomous procedure to update.
           update_bc_pkt_brc_bvid_status (  p_action               => g_update_status,
                                              p_packet_id          => x_packet_id,
			                      p_award_id           => l_award_id,
                   			      p_expenditure_type   => l_expenditure_type,
				              p_full_mode_failure  => l_full_mode_failure,
				              x_result_code        => x_result_code );

           If l_full_mode_failure ='Y' then
               EXIT;
           End If;

     END ;
     -- -----------------------------------------------
     -- END of award and Expenditure Level Calculations
     -- -----------------------------------------------

      -- initialize variables ..
      x_cmt_tot_burden := 0;
      x_tot_raw        := 0;
      x_tot_burden     := 0;

    <<SKIP_AWD_EXP>>
      -- R12 Funds Management Uptake :Delete the below code as it is handled in new logic
      NULL;

   END LOOP;

   -- Call PROC_RECONCILE_DOCUMENT for maximizing burden
   X_err_stage := 'STG_21_STR' ;

   IF NOT ( g_actual_flag ='E' AND  p_mode <> 'E')  THEN -- For AP/PO/REQ records

      IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':Call Maximize_burden','C');
      END IF;

      Maximize_burden(x_packet_id);
     --PROC_RECONCILE_DOCUMENT(x_packet_id);

   End If;

   X_err_stage := 'STG_21_END' ;

   IF g_debug = 'Y' THEN
      	gms_error_pkg.gms_debug (g_error_procedure_name||':End','C');
   END IF;

   return TRUE;

 EXCEPTION
    when others then

		ROLLBACK TO SAVE_CALC_PROCESS ;

        IF x_err_stage = 'STG_10_OTH' THEN
           -- --------------------------------------------
           -- F41 - AP_PO_RATE_DECREASED System Exception
           -- --------------------------------------------
           X_result_code := 'F41' ;
        ELSIF X_ERR_STAGE = 'STG_11_OTH' THEN
           -- --------------------------------------------
           -- F42 - Unable to Consolidate AP
           -- --------------------------------------------
           X_result_code := 'F42' ;
        ELSIF X_err_stage = 'STG_12_OTH' THEN
           -- --------------------------------------------
           -- F43 - Unable to Update PO Document TYPE.
           -- --------------------------------------------
           X_result_code := 'F43' ;
		ELSE
		   X_result_code := 'F48' ;
        END IF ;

           -- R12 Funds Management Uptake : Call autonomous procedure to update.
           update_bc_pkt_brc_bvid_status (  p_action               => g_update_status,
                                              p_packet_id          => x_packet_id,
			                      p_award_id           => NULL,
                   			      p_expenditure_type   => NULL,
				              p_full_mode_failure  => 'N',
				              x_result_code        => x_result_code );


         RETURN FALSE ;

END update_bc_pkt_burden_raw_cost;
-- =============  update_bc_pkt_burden_raw_cost ====================

PROCEDURE PPAY_LOG_POSTING( x_packet_id in number, x_sob_id 	IN NUMBER, p_error_stat IN OUT NOCOPY varchar2) IS
BEGIN
   null; -- All code remove as this will be taken care by Interface FC
END PPAY_LOG_POSTING ;

PROCEDURE CALC_prepayment_burden( X_AP_REC	ap_invoice_distributions_all%ROWTYPE , X_adl_rec	gms_award_distributions%ROWTYPE ) is
BEGIN
   null; -- All code remove as this will be taken care by Interface FC
END CALC_prepayment_burden ;

-- -------------------------------------------------------------------------+
-- FUNCTION  UPDATE_SOURCE_BURDEN_RAW_COST
-- Function updates burdenable raw cost on source document ..
-- -------------------------------------------------------------------------+
FUNCTION  UPDATE_SOURCE_BURDEN_RAW_COST(x_packet_id in number, p_mode varchar2, p_partial_flag varchar2) return boolean
IS
 l_error varchar2(1000);

Cursor c_packet is
       select rowid,document_header_id, document_distribution_id,
              expenditure_type,burdenable_raw_cost,document_type,
              burden_adjustment_flag,ind_compiled_set_id
        from  gms_bc_packets
       where  packet_id   = x_packet_id
         and  status_code  IN ('P','I')
         and  substr(result_code,1,1) = 'P'
         and   ((nvl(burden_adjustment_flag,'N')  = 'N' and parent_bc_packet_id is null)
                -- original raw line
                OR
               (nvl(burden_adjustment_flag,'N')  = 'Y' and nvl(burdenable_raw_cost,0) <> 0)
               -- Burden adjustment line
               )
         and  document_type <> 'EXP'; -- EXP adls are created during tieback..
         --and  parent_bc_packet_id IS NULL;
         -- parent_bc_packet_id is not null on burden adjustment records

 l_stage varchar2(30);
BEGIN
  g_error_program_name   := 'Gms_cost_plus_extn';
  g_error_procedure_name := 'Update_source_burden_raw_cost' ;

  gms_error_pkg.gms_debug (g_error_procedure_name||':Start','C');

 -- Kept this code in a loop operation as burden posted_flag needs to be updated
 -- on records that has been posted to ADL (critical update) ..
 -- If update fails, fail packet, packet failed as if any adjsuting line fails then
 -- corr. line being FC has to fail and vice versa .. so as to avoid confusion ..
 -- fail entire packet ..NOTE: before failing packet we do rollback ..

 SAVEPOINT POST_BURDEN;
 l_stage := 'Retrieve records';
 FOR bc_records in c_packet
 LOOP
   If  bc_records.document_type = 'REQ' then
         update gms_award_distributions
            set burdenable_raw_cost = nvl(burdenable_raw_cost,0) + bc_records.burdenable_raw_cost,
                ind_compiled_set_id = decode(bc_records.burden_adjustment_flag,
											 'Y',ind_compiled_set_id,bc_records.ind_compiled_set_id)
          where distribution_id = bc_records.document_distribution_id
            and adl_status = 'A'
            and document_type = 'REQ';

	Elsif bc_records. document_type = 'PO' then
         update gms_award_distributions
            set burdenable_raw_cost = nvl(burdenable_raw_cost,0) + bc_records.burdenable_raw_cost,
                ind_compiled_set_id = decode(bc_records.burden_adjustment_flag,
											 'Y',ind_compiled_set_id,bc_records.ind_compiled_set_id)
          where po_distribution_id = bc_records.document_distribution_id
            and adl_status = 'A'
            and document_type = 'PO';

	Elsif bc_records.document_type = 'AP' then
         update gms_award_distributions
            set burdenable_raw_cost = nvl(burdenable_raw_cost,0) + bc_records.burdenable_raw_cost,
                ind_compiled_set_id = decode(bc_records.burden_adjustment_flag,
											 'Y',ind_compiled_set_id,bc_records.ind_compiled_set_id)
          where invoice_id = bc_records.document_header_id
            and invoice_distribution_id = bc_records.document_distribution_id  -- AP Lines change
            and adl_status = 'A'
            and document_type = 'AP';

	Elsif bc_records.document_type = 'ENC' then
         update gms_award_distributions
            set burdenable_raw_cost = nvl(burdenable_raw_cost,0) + bc_records.burdenable_raw_cost,
                ind_compiled_set_id = decode(bc_records.burden_adjustment_flag,
											 'Y',ind_compiled_set_id,bc_records.ind_compiled_set_id)
          where expenditure_item_id = bc_records.document_header_id
            and adl_line_num = bc_records.document_distribution_id --Bug 5726575
            and cdl_line_num		= 1
            and adl_status = 'A'
            and document_type = 'ENC';

    End If;

    IF SQL%FOUND THEN
        Update gms_bc_packets
           set burden_posted_flag = 'X'
         where rowid              = bc_records.rowid;
    ELSE
       ROLLBACK TO POST_BURDEN;
       l_stage := 'Failure';
       Update gms_bc_packets
          set status_code = 'R',
              result_code = 'F52'
        where rowid       = bc_records.rowid;

       -- R12 Funds Management Uptake : Update fail status on gms_bc_packets based on Partial/Full mode
       IF p_partial_flag = 'N' THEN
         EXIT;
       END IF;
    END IF ;

 END LOOP;

  gms_error_pkg.gms_debug (g_error_procedure_name||':End','C');

 RETURN TRUE;

EXCEPTION
  When Others then
       l_error:= SUBSTR(SQLERRM,1,1000);

       gms_error_pkg.gms_debug ('***********'||g_error_procedure_name||':FAILURE:'||l_error,'C');

       ROLLBACK TO POST_BURDEN;

       Update gms_bc_packets
       set    status_code      = 'T',
	      result_code      = 'F54',
	      fc_error_message =  l_stage||';'||l_error
       where  packet_id        =  x_packet_id;

       RETURN FALSE;

END UPDATE_SOURCE_BURDEN_RAW_COST;
--------------------------------------------------------------------------
-- Added for Bug: 1331903
-- Start 3098797, 3103159
-- Description : PAXACMPT: EXACT FETCH RETURNS MORE THAN REQUESTED NUMBER OF ROWS
-- Resolution  : Joins with the base tables were added.
--

FUNCTION get_award_compiled_set_id(	x_doc_type in VARCHAR2,
					                x_distribution_id in NUMBER,
					                x_distribution_line_number in NUMBER default NULL )
RETURN number IS

x_ind_compiled_set_id   NUMBER;

BEGIN
	if x_doc_type = 'REQ' then

        -- 3098797, 3103159
        -- Resolution  : Joins with the base tables were added.
        --
		select  adl.ind_compiled_set_id
		into 	x_ind_compiled_set_id
		from 	gms_award_distributions adl,
                po_req_distributions_all req
		where 	req.distribution_id = x_distribution_id
        and     req.award_id        = adl.award_set_id
		and     adl.adl_line_num    = 1 ;

	elsif x_doc_type = 'PO' then

        -- 3098797, 3103159
        -- Resolution  : Joins with the base tables were added.
        --
		select  adl.ind_compiled_set_id
		into 	x_ind_compiled_set_id
		from 	gms_award_distributions adl,
				po_distributions_all    po
		where	po.po_distribution_id = x_distribution_id
		  and   po.award_id           = adl.award_set_id
		  and   adl.adl_line_num      = 1 ;

	elsif x_doc_type = 'AP' then

        -- 3098797, 3103159
        -- Resolution  : Joins with the base tables were added.
        --
		select  adl.ind_compiled_set_id
		into 	x_ind_compiled_set_id
		from 	gms_award_distributions adl,
				ap_invoice_distributions_all apd
		where	apd.distribution_line_number = x_distribution_line_number
        and     apd.invoice_distribution_id    = x_distribution_id  -- AP Lines change
		and     apd.award_id                 = adl.award_set_id
		and     adl.adl_line_num             = 1 ;

	elsif x_doc_type = 'ENC' then
		select  ind_compiled_set_id
		into 	x_ind_compiled_set_id
		from 	gms_award_distributions
		where	expenditure_item_id = x_distribution_id
		and     adl_status = 'A'
		and     fc_status = 'A'
                and      nvl(reversed_flag, 'N') <> 'Y' --Bug 5726575
                and      line_num_reversed is null
		and	    document_type = 'ENC';
	end if;

	return x_ind_compiled_set_id;

exception
	when no_data_found then
	return NULL;
end get_award_compiled_set_id;

---------------------------------------------------------------------------
FUNCTION get_burdenable_raw_cost(	x_doc_type in VARCHAR2,
					x_distribution_id in NUMBER,
					x_distribution_line_number in NUMBER default NULL )
RETURN number IS

x_burdenable_raw_cost   NUMBER;

BEGIN

	if x_doc_type = 'REQ' then

        -- 3098797, 3103159
        -- Resolution  : Joins with the base tables were added.
        --
		select  adl.burdenable_raw_cost
		into 	x_burdenable_raw_cost
		from 	gms_award_distributions adl,
                po_req_distributions_all req
		where 	req.distribution_id = x_distribution_id
        and     req.award_id        = adl.award_set_id
		and     adl.adl_line_num    = 1 ;

	elsif x_doc_type = 'PO' then

        -- 3098797, 3103159
        -- Resolution  : Joins with the base tables were added.
        --
		select  adl.burdenable_raw_cost
		into 	x_burdenable_raw_cost
		from 	gms_award_distributions adl,
				po_distributions_all    po
		where	po.po_distribution_id = x_distribution_id
		  and   po.award_id           = adl.award_set_id
		  and   adl.adl_line_num      = 1 ;

	elsif x_doc_type = 'AP' then

        -- 3098797, 3103159
        -- Resolution  : Joins with the base tables were added.
        --
		select  adl.burdenable_raw_cost
		into 	x_burdenable_raw_cost
		from 	gms_award_distributions adl,
				ap_invoice_distributions_all apd
		where	apd.distribution_line_number = x_distribution_line_number
        and     apd.invoice_distribution_id    = x_distribution_id  -- AP Lines change
		and     apd.award_id                 = adl.award_set_id
		and     adl.adl_line_num             = 1 ;

	elsif x_doc_type = 'ENC' then
		select  burdenable_raw_cost
		into 	x_burdenable_raw_cost
		from 	gms_award_distributions
		where	expenditure_item_id = x_distribution_id
		and     adl_status = 'A'
		and     fc_status = 'A'
                and      nvl(reversed_flag, 'N') <> 'Y' --Bug 5726575
                and      line_num_reversed is null --Bug 5726575
		and	    document_type = 'ENC';

	end if;

	return x_burdenable_raw_cost;

exception
	when no_data_found then
	return NULL;
end;

-- Description : PAXACMPT: EXACT FETCH RETURNS MORE THAN REQUESTED NUMBER OF ROWS
-- Resolution  : Joins with the base tables were added.
-- End 3098797, 3103159
--

---------------------------------------------------------------------------
Function is_spon_project(x_project_id IN NUMBER ) RETURN number IS

	CURSOR c_project IS
	SELECT 'X'
	FROM pa_projects p,
	     gms_project_types gpt
        WHERE p.project_id  	=  x_project_id
	AND   p.project_type	= gpt.project_type
	AND   gpt.sponsored_flag= 'Y'  ;

	x_dummy		varchar2(1) ;
	x_return        number ;

    BEGIN
        open c_project ;
        fetch c_project into x_dummy ;

        IF c_project%FOUND then
            x_return := 0 ;
        ELSE
            x_return := 1 ;
        END IF ;

        return (x_return ) ;

        CLOSE c_project ;
    EXCEPTION
    WHEN OTHERS THEN
        return 1 ;
    END is_spon_project ;
--------------------------------------------------------------------------

END GMS_COST_PLUS_EXTN;

/
