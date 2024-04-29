--------------------------------------------------------
--  DDL for Package Body GMS_AWARD_DIST_ENG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_AWARD_DIST_ENG" as
-- $Header: gmsawdeb.pls 120.7.12010000.2 2008/08/07 12:52:50 abjacob ship $

    -- =================================================================================
    -- BUG: 3358176 Award Distribution not recognized for sub tasks when funding
    -- pattern is defined at top task level.
    -- top_task_id and pa_tasks join was added.
    -- =================================================================================
    cursor get_funding_pattern   (p_project_id      in number,
                                  p_task_id      in number,
                                  p_exp_item_dt  in date,
                                  p_org_id       in  number) is
                            select fp.funding_sequence,
                                   fp.funding_pattern_id
                             from gms_funding_patterns_all fp,
                                  pa_tasks t
                            where nvl(fp.retroactive_flag, 'N') = 'N'
                              and NVL(fp.status, 'N')           = 'A'
                              -- and org_id                     = nvl(p_org_id, org_id )
                              and ((fp.org_id = p_org_id) or (fp.org_id is null and p_org_id is null)) -- bug 2362489
                              and fp.project_id                 = p_project_id
			      and t.task_id                     = p_task_id
                              and fp.task_id                    = t.top_task_id
                              and p_exp_item_dt between fp.start_date  and nvl(fp.end_date, p_exp_item_dt)
                            union
                            select funding_sequence,
                                   funding_pattern_id
                             from gms_funding_patterns_all gfpa
                            where nvl(retroactive_flag, 'N') = 'N'
                              and NVL(status, 'N')           = 'A'
                              -- and org_id                     = NVL(p_org_id, org_id)
                              and ((org_id = p_org_id) or (org_id is null and p_org_id is null)) -- bug 2362489
                              and project_id                 = p_project_id
                              and task_id is null
                              and p_exp_item_dt between start_date  and nvl(end_date, p_exp_item_dt)
                              and not exists (select '1'
                                                from gms_funding_patterns_all b,
                                                     pa_tasks                 t1
                                                where gfpa.project_id 	= b.project_id
						  and b.status	      	= 'A'
						  and t1.task_id        = p_task_id
                                                  and b.task_id 	= t1.top_task_id)
                             order by 1;

    cursor apply_fp( x_doc_header_id NUMBER,
                     x_doc_type    VARCHAR2 ) is
    select  expenditure_item_date,
            document_header_id,
	    document_distribution_id,
            expenditure_type,
            expenditure_organization_id,
            project_id,
            task_id,
            gl_date,
            quantity,
            amount,
            rowid,
            burdened_cost,
            denom_burdened_cost,
            denom_raw_cost,
            acct_raw_cost,
            acct_burdened_cost,
	    receipt_currency_amount
      from  gms_distributions
     where  NVL(dist_status,'X') <> 'FABA'
       and  document_header_id = x_doc_header_id
       and  document_type = x_doc_type;


 TYPE proj_awd_rec IS RECORD (  document_header_id      number,
				document_distribution_id	NUMBER,
                                project_id          number,
                                task_id             number,
                                award_id            number,
                                dist_value          number,
                                expenditure_type    varchar2(30),
                                expenditure_item_date   date,
                                expenditure_organization_id number,
                                funding_pattern_id  number,
                                gl_date             date,
                                quantity            number,
                                award_amount        number,
                                row_id              rowid,
				burdened_cost       NUMBER,
				denom_burdened_cost NUMBER,
				denom_raw_cost      NUMBER,
				acct_raw_cost       NUMBER,
				acct_burdened_cost  NUMBER,
				receipt_currency_amount NUMBER,
                                funds_check_ok      boolean);

 TYPE fp_table 		is table of proj_awd_rec;
 TYPE t_num_tab 	is table of NUMBER  ;
 TYPE t_date_tab 	is table of DATE ;
 TYPE t_varchar_tab 	is table of varchar2(40) ;

 RESOURCE_BUSY     EXCEPTION;
 PRAGMA EXCEPTION_INIT( RESOURCE_BUSY, -0054 );



 recs           apply_fp%ROWTYPE;
 valid_fp_tab   fp_table ;
 p_SOB_ID       number ;
 X_error        varchar2(200);

 FUNCTION FUNC_BUFF_RECORDS( p_header_id NUMBER,
			     p_line_id	 NUMBER,
			     p_document_type VARCHAR2,
			     p_dist_award_id NUMBER ) return NUMBER IS
   l_count_rec	NUMBER ;
 BEGIN
	IF p_document_type = 'ENC' THEN
		DELETE from gms_distribution_details A
		 WHERE document_type      = p_document_type
		  and  exists ( select 'X' from gms_distributions B
				where A.document_header_id = b.document_distribution_id
				and   B.document_header_id = p_header_id
                        	and b.document_type      = p_document_type ) ;
	ELSE
		DELETE from gms_distribution_details
		 WHERE document_header_id = p_header_id
		   AND document_type      = p_document_type ;
	END IF ;

	DELETE from gms_distributions
	 WHERE document_header_id = p_header_id
	   AND document_type      = p_document_type ;

	IF p_document_type = 'REQ' THEN
	INSERT INTO gms_distributions ( document_header_id,
					document_distribution_id,
					document_type,
					gl_date,
					project_id,
					task_id,
					expenditure_type,
					expenditure_organization_id,
					expenditure_item_date,
					quantity,
					unit_price,
					amount,
					dist_status,
					creation_date
				      )
	 SELECT p_header_id,
		dst.distribution_id,
		p_document_type,
		dst.gl_encumbered_date,
		dst.project_id,
		dst.task_id,
		dst.expenditure_type,
		dst.expenditure_organization_id,
		dst.expenditure_item_date,
		dst.req_line_quantity,
		lne.unit_price,
		-- 3362016 Grants integrations with CWK and PO services.
		--dst.req_line_quantity * lne.unit_price,
		decode( plt.matching_basis, 'AMOUNT', dst.req_line_amount,
						    dst.req_line_quantity * lne.unit_price) ,
		NULL,
		SYSDATE
	   FROM po_requisition_lines_all   lne,
		po_req_distributions_all   dst,
		po_line_types              plt
                -- bug 3576717
	  WHERE lne.requisition_header_id = p_header_id
	    AND lne.requisition_line_id   = p_line_id
	    AND dst.requisition_line_id	  = lne.requisition_line_id
	    AND plt.line_type_id          = lne.line_type_id
	    AND NVL(dst.award_id,0)	  = p_dist_award_id ;

	 l_count_rec := SQL%ROWCOUNT ;
	ELSIF p_document_type = 'PO' THEN

	INSERT INTO gms_distributions ( document_header_id,
					document_distribution_id,
					document_type,
					gl_date,
					project_id,
					task_id,
					expenditure_type,
					expenditure_organization_id,
					expenditure_item_date,
					quantity,
					unit_price,
					amount,
					dist_status,
					creation_date
				      )
	 SELECT dst.po_header_id,
		dst.po_distribution_id,
		p_document_type,
		dst.gl_encumbered_date,
		dst.project_id,
		dst.task_id,
		dst.expenditure_type,
		dst.expenditure_organization_id,
		dst.expenditure_item_date,
		dst.quantity_ordered,
		lne.unit_price,
		-- 3362016 Grants integrations with CWK and PO services.
		-- dst.quantity_ordered * lne.unit_price,
		decode( plt.matching_basis, 'AMOUNT', dst.amount_ordered,
		                                    dst.quantity_ordered * lne.unit_price),
		NULL,
		SYSDATE
	   FROM po_lines_all   lne,
		po_distributions_all   dst,
		po_line_types          plt
                -- bug 3576717
	  WHERE lne.po_header_id = p_header_id
	    AND lne.po_line_id   = p_line_id
	    AND plt.line_type_id = lne.line_type_id
	    AND dst.po_line_id	 = lne.po_line_id
	    AND NVL(dst.award_id,0)	  = p_dist_award_id ;

	 l_count_rec := SQL%ROWCOUNT ;
	ELSIF p_document_type = 'AP' THEN

	INSERT INTO gms_distributions ( document_header_id,
					document_distribution_id,
					document_type,
					gl_date,
					project_id,
					task_id,
					expenditure_type,
					expenditure_organization_id,
					expenditure_item_date,
					quantity,
					unit_price,
					amount,
					dist_status,
					creation_date
				      )
       -- ==========================================
       -- R12 AP Lines Uptake: Insert into gms_distributions
       -- got changed from picking distribution_line_number
       -- to invoice_distribution_id for document type AP.
       -- ==========================================
	 SELECT dst.invoice_id,
		dst.invoice_distribution_id,
		p_document_type,
		dst.accounting_date,
		dst.project_id,
		dst.task_id,
		dst.expenditure_type,
		dst.expenditure_organization_id,
		dst.expenditure_item_date,
		dst.pa_quantity,
		1,
		dst.amount,
		NULL,
		SYSDATE
	   FROM ap_invoice_distributions_all   dst
	  WHERE dst.invoice_id = p_header_id
	    AND NVL(dst.award_id,0)	  = p_dist_award_id ;

	 L_COUNT_REC := SQL%ROWCOUNT ;
	ELSIF p_document_type = 'ENC' THEN

	INSERT INTO gms_distributions ( document_header_id,
					document_distribution_id,
					document_type,
					gl_date,
					project_id,
					task_id,
					expenditure_type,
					expenditure_organization_id,
					expenditure_item_date,
					quantity,
					unit_price,
					amount,
					dist_status,
					creation_date
				      )
	 SELECT hdr.encumbrance_id,
		dst.encumbrance_item_id,
		p_document_type,
		NVL(dst.gl_date,SYSDATE),
		adl.project_id,
		dst.task_id,
		dst.encumbrance_type,
		hdr.incurred_by_organization_id,
		dst.encumbrance_item_date,
		0,
		0,
		dst.amount,
		NULL,
		SYSDATE
	   FROM gms_encumbrances_all hdr,
		gms_encumbrance_items_all dst,
	 	gms_award_distributions   adl
	  WHERE dst.encumbrance_id = p_header_id
	    AND hdr.encumbrance_id = p_header_id
	    AND hdr.encumbrance_id = dst.encumbrance_id
	    AND adl.expenditure_item_id = dst.encumbrance_item_id
            AND nvl(adl.reversed_flag, 'N') = 'N' --Bug 5726575
            AND adl.line_num_reversed is null --Bug 5726575
	    and adl.adl_status          = 'A'
	    AND NVL(adl.award_id,0)	  = p_dist_award_id ;
          ----- Fix for bug : 2017155
	 L_COUNT_REC := SQL%ROWCOUNT ;

     ---- ********************* Fix for bug number : 1939601 start  ****************----------

     	ELSIF p_document_type = 'EXP' THEN

	INSERT INTO gms_distributions ( document_header_id,
					document_distribution_id,
					document_type,
					gl_date,
					project_id,
					task_id,
					expenditure_type,
					expenditure_organization_id,
					expenditure_item_date,
					quantity,
					unit_price,
					amount,
					dist_status,
					creation_date
				      )
	 SELECT hdr.expenditure_id,
		dst.expenditure_item_id,
		p_document_type,
	-- ???????????	NVL(dst.gl_date,SYSDATE),
        SYSDATE,
		adl.project_id,
		dst.task_id,
		dst.expenditure_type,
		hdr.incurred_by_organization_id,
		dst.expenditure_item_date,
		dst.quantity,
		0,
		0,
		NULL,
		SYSDATE
	   FROM pa_expenditures_all hdr,
		pa_expenditure_items_all dst,
	 	gms_award_distributions   adl
	  WHERE dst.expenditure_id = p_header_id
	    AND hdr.expenditure_id = p_header_id
	    AND hdr.expenditure_id = dst.expenditure_id
	    AND adl.expenditure_item_id = dst.expenditure_item_id
	    and adl.adl_status          = 'A'
	    AND NVL(adl.award_id,0)	  = p_dist_award_id ;

     ---- ********************* Fix for bug number : 1939601 end  ****************----------
	 L_COUNT_REC := SQL%ROWCOUNT ;
	END IF ;

	 return L_COUNT_REC ;

 END FUNC_BUFF_RECORDS ;
-- ======================================================
-- Function FUNC_add_to_table begins
-- =======================================================
 FUNCTION FUNC_add_to_table( P_funding_pattern_id NUMBER )
 return NUMBER is
    l_tab_ndx NUMBER ;

    cursor fetch_awards is
            select award_id,
                    distribution_value
             from gms_fp_distributions
            where funding_pattern_id = p_funding_pattern_id
            order by distribution_number  ;

    get_awards_rec     fetch_awards%ROWTYPE;

    x_dist_percent     NUMBER ;
    x_tot_amount       NUMBER ;
    X_diff_amount      NUMBER ;
    x_acc_amount       NUMBER ;

    X_diff_qty         NUMBER ;
    X_acc_qty          NUMBER ;
    X_tot_qty          NUMBER ;
    X_tot_bc            NUMBER ;

    X_tot_denom_bc      NUMBER ;
    x_tot_acct_bc       NUMBER ;
    x_tot_denom_rc      NUMBER ;
    x_tot_acct_rc       NUMBER ;
    x_tot_curr_amount	NUMBER ;

    X_diff_bc           NUMBER ;
    X_diff_denom_bc     NUMBER ;
    x_diff_acct_bc      NUMBER ;
    x_diff_denom_rc     NUMBER ;
    x_diff_acct_rc      NUMBER ;
    x_diff_curr_amount	NUMBER ;

    X_bc                NUMBER ;
    X_denom_bc          NUMBER ;
    x_acct_bc           NUMBER ;
    x_denom_rc          NUMBER ;
    x_acct_rc           NUMBER ;
    x_curr_amount	NUMBER ;

  BEGIN

    x_dist_percent     := 0 ;
    x_tot_amount       := 0;
    X_diff_amount      := 0;
    x_acc_amount       := 0;
    X_diff_qty         := 0;
    X_acc_qty          := 0;
    X_tot_qty          := 0;
    X_tot_bc           := 0 ;
    X_tot_denom_bc     := 0 ;
    x_tot_acct_bc      := 0 ;
    x_tot_denom_rc     := 0 ;
    x_tot_acct_rc      := 0 ;
    x_tot_curr_amount  := 0 ;
    X_diff_bc          := 0 ;
    X_diff_denom_bc    := 0 ;
    x_diff_acct_bc     := 0 ;
    x_diff_denom_rc    := 0 ;
    x_diff_acct_rc     := 0 ;
    x_diff_curr_amount := 0 ;
    X_bc               := 0 ;
    X_denom_bc         := 0 ;
    x_acct_bc          := 0 ;
    x_denom_rc         := 0 ;
    x_acct_rc          := 0 ;
    x_curr_amount      := 0 ;


  	-- Bug 1980810 : Added to set currency related global variables
	--		 Call to pa_currency.round_currency_amt function will use
	--		 global variables and thus improves performance

	 pa_currency.set_currency_info;


        l_tab_ndx := 0 ;
        valid_fp_tab.delete;

        open fetch_awards ;
        x_tot_qty       :=   recs.quantity ;
        x_tot_amount    :=   recs.amount   ;

	x_tot_bc	:=   NVL(recs.burdened_cost,0) ;
	x_tot_denom_bc	:=   NVL(recs.denom_burdened_cost,0) ;
	x_tot_denom_rc	:=   NVL(recs.denom_raw_cost,0) ;

	x_tot_acct_rc	:=   NVL(recs.acct_raw_cost,0) ;
	x_tot_acct_bc	:=   NVL(recs.acct_burdened_cost,0) ;

	x_tot_curr_amount := NVL(recs.receipt_currency_amount,0) ;

        loop
            fetch fetch_awards into get_awards_rec;
            if fetch_awards%NOTFOUND then
               close fetch_awards;
               exit;
            end if;

          l_tab_ndx         := l_tab_ndx + 1;
          x_dist_percent    := get_awards_rec.distribution_value ;

          valid_fp_tab.extend;
          valid_fp_tab(l_tab_ndx).document_header_id := recs.document_header_id;
          valid_fp_tab(l_tab_ndx).document_distribution_id := recs.document_distribution_id;
          valid_fp_tab(l_tab_ndx).project_id     := recs.project_id;
          valid_fp_tab(l_tab_ndx).task_id        := recs.task_id;
          valid_fp_tab(l_tab_ndx).award_id       := get_awards_rec.award_id;
          valid_fp_tab(l_tab_ndx).dist_value     := get_awards_rec.distribution_value;
          valid_fp_tab(l_tab_ndx).expenditure_type := recs.expenditure_type;
          valid_fp_tab(l_tab_ndx).expenditure_item_date := recs.expenditure_item_date;
          --valid_fp_tab(l_tab_ndx).destination_type      := recs.destination_type;
          valid_fp_tab(l_tab_ndx).expenditure_organization_id := recs.expenditure_organization_id;
          valid_fp_tab(l_tab_ndx).funding_pattern_id    := P_funding_pattern_id;
          valid_fp_tab(l_tab_ndx).gl_date               := recs.gl_date;
          --valid_fp_tab(l_tab_ndx).instance_id           := recs.instance_id;
          valid_fp_tab(l_tab_ndx).row_id                := recs.rowid;

	  --
	  -- bug:4451781
	  -- PQE:R12:EXPAND FUNDING PATTERN DECIMAL ENTRY TO THREE
	  --
          IF nvl(recs.quantity, 0) = 0 THEN --Bug 6754773 /* Added NVL for bug 6822240 */
          valid_fp_tab(l_tab_ndx).quantity              := ROUND( ( recs.quantity * x_dist_percent)/100, 3 ) ;

	  -- Bug 1980810 PA Rounding function added

	  valid_fp_tab(l_tab_ndx).award_amount          := pa_currency.round_currency_amt( ( recs.amount   * x_dist_percent)/100);

	  valid_fp_tab(l_tab_ndx).burdened_cost		:= pa_currency.round_currency_amt( (recs.burdened_cost *  x_dist_percent)/100);
	  valid_fp_tab(l_tab_ndx).denom_burdened_cost	:= pa_currency.round_currency_amt( (recs.denom_burdened_cost *  x_dist_percent)/100 );
	  valid_fp_tab(l_tab_ndx).acct_burdened_cost	:= pa_currency.round_currency_amt( (recs.acct_burdened_cost *  x_dist_percent)/100);
	  valid_fp_tab(l_tab_ndx).acct_raw_cost		:= pa_currency.round_currency_amt( (recs.acct_raw_cost *  x_dist_percent)/100);
	  valid_fp_tab(l_tab_ndx).denom_raw_cost	:= pa_currency.round_currency_amt( (recs.denom_raw_cost *  x_dist_percent)/100);
	  valid_fp_tab(l_tab_ndx).receipt_currency_amount := pa_currency.round_currency_amt(  (recs.receipt_currency_amount * x_dist_percent)/100) ;
	     ELSE --Bug 6754773
            valid_fp_tab(l_tab_ndx).quantity := recs.quantity * x_dist_percent/100;
	    /* Starts - Modified following columns derivation for bug#6822240 */
            valid_fp_tab(l_tab_ndx).award_amount :=
             pa_currency.round_currency_amt(recs.amount *  valid_fp_tab(l_tab_ndx).quantity/recs.quantity);
            valid_fp_tab(l_tab_ndx).burdened_cost :=
             pa_currency.round_currency_amt(recs.burdened_cost * valid_fp_tab(l_tab_ndx).quantity/recs.quantity);
            valid_fp_tab(l_tab_ndx).denom_burdened_cost :=
             pa_currency.round_currency_amt( recs.denom_burdened_cost * valid_fp_tab(l_tab_ndx).quantity/recs.quantity);
            valid_fp_tab(l_tab_ndx).acct_burdened_cost :=
             pa_currency.round_currency_amt( recs.acct_burdened_cost * valid_fp_tab(l_tab_ndx).quantity/recs.quantity);
            valid_fp_tab(l_tab_ndx).acct_raw_cost :=
             pa_currency.round_currency_amt( recs.acct_raw_cost * valid_fp_tab(l_tab_ndx).quantity/recs.quantity);
            valid_fp_tab(l_tab_ndx).denom_raw_cost :=
             pa_currency.round_currency_amt( recs.denom_raw_cost * valid_fp_tab(l_tab_ndx).quantity/recs.quantity);
            valid_fp_tab(l_tab_ndx).receipt_currency_amount :=
             pa_currency.round_currency_amt( recs.receipt_currency_amount * valid_fp_tab(l_tab_ndx).quantity/recs.quantity);
     	    /* ENds - Modified following columns derivation for bug#6809323 */
          END if;

          x_acc_qty        :=  x_acc_qty    + valid_fp_tab(l_tab_ndx).quantity     ;
          X_acc_amount     :=  X_acc_amount + valid_fp_tab(l_tab_ndx).award_amount ;

	  x_bc		   :=  NVL(x_bc,0)  + valid_fp_tab(l_tab_ndx).burdened_cost ;
	  x_denom_bc	   :=  NVL(x_denom_bc,0) + valid_fp_tab(l_tab_ndx).denom_burdened_cost  ;
	  x_denom_rc	   :=  NVL(x_denom_rc,0)  + valid_fp_tab(l_tab_ndx).denom_raw_cost ;
	  x_acct_bc	   :=  NVL(x_acct_bc,0)   + valid_fp_tab(l_tab_ndx).acct_burdened_cost ;
	  x_acct_rc	   :=  NVL(x_acct_rc,0)   + valid_fp_tab(l_tab_ndx).acct_raw_cost ;
	  x_curr_amount    :=  NVL(x_curr_amount,0) + valid_fp_tab(l_tab_ndx).receipt_currency_amount ;

       END LOOP ;

       IF l_tab_ndx > 0 THEN

            x_diff_amount                         := X_tot_amount - X_acc_amount ;
            x_diff_qty                            := X_tot_qty    - X_acc_qty ;

	    x_diff_bc				  := X_tot_bc  	  - X_bc ;
	    x_diff_denom_bc			  := X_tot_denom_bc  	  - X_denom_bc ;
	    x_diff_acct_bc			  := X_tot_acct_bc  	  - X_acct_bc ;
	    x_diff_denom_rc			  := X_tot_denom_rc  	  - X_denom_rc ;
	    x_diff_acct_rc			  := X_tot_acct_rc  	  - X_acct_rc ;
	    x_diff_curr_amount			  := x_tot_curr_amount    - X_curr_amount ;

            valid_fp_tab(l_tab_ndx).quantity      := valid_fp_tab(l_tab_ndx).quantity     + X_diff_qty ;
            valid_fp_tab(l_tab_ndx).award_amount  := valid_fp_tab(l_tab_ndx).award_amount + X_diff_amount ;

	    valid_fp_tab(l_tab_ndx).burdened_cost	:= valid_fp_tab(l_tab_ndx).burdened_cost + x_diff_bc ;
	    valid_fp_tab(l_tab_ndx).denom_burdened_cost	:= valid_fp_tab(l_tab_ndx).denom_burdened_cost + x_diff_denom_bc ;
	    valid_fp_tab(l_tab_ndx).acct_burdened_cost	:= valid_fp_tab(l_tab_ndx).acct_burdened_cost + x_diff_acct_bc ;
	    valid_fp_tab(l_tab_ndx).acct_raw_cost	:= valid_fp_tab(l_tab_ndx).acct_raw_cost + x_diff_acct_rc ;
	    valid_fp_tab(l_tab_ndx).denom_raw_cost	:= valid_fp_tab(l_tab_ndx).denom_raw_cost + x_diff_denom_rc ;
	    valid_fp_tab(l_tab_ndx).receipt_currency_amount := valid_fp_tab(l_tab_ndx).receipt_currency_amount + x_diff_curr_amount ;

       END IF ;
        return l_tab_ndx ;
 EXCEPTION
    when others then
        IF fetch_awards%ISOPEN THEN
            CLOSE  fetch_awards ;
        END IF ;

        RAISE ;
 END FUNC_add_to_table;
-- ======================================================
-- Function FUNC_add_to_table Ends
-- =======================================================


-- ======================================================
-- Function valid_transaction
-- =======================================================
 FUNCTION valid_transaction( p_project_id   IN NUMBER,
                             p_task_id      IN NUMBER,
                             p_award_id     IN NUMBER,
                             p_exp_type     IN VARCHAR2,
                             P_EXP_ITEM_DATE IN DATE ) return boolean is

    l_return_stat   varchar2(2000) ;

 begin
 		gms_transactions_pub.validate_transaction(recs.project_id,
							  recs.task_id,
							  P_award_id,
							  recs.expenditure_type,
							  recs.expenditure_item_date,
							  'GMSFABE',
							  l_return_stat);
        --dbms_output.put_line(l_return_stat) ;
		if (l_return_stat is null) then
          return TRUE;
        else
          return FALSE;
        end if;

 END valid_transaction;
-- ======================================================
-- Function valid_transaction End.
-- =======================================================





-- ======================================================
-- Function FUNC_CHECK_FUNDS End.
-- =======================================================

 FUNCTION FUNC_CHECK_FUNDS( p_ndx in number, p_document_type in varchar2) return BOOLEAN is

 x_period_name      varchar2(30);
 x_period_year      varchar2(4);
 x_period_num       number;
 X_packet_id        NUMBER ;
 X_RETURN           BOOLEAN ;
 x_return_code      varchar2(10);
 x_e_code           varchar2(100);
 x_e_mesg           varchar2(240);
 l_budget_version_id NUMBER ;
 x_doc_header_id	NUMBER ;
 x_doc_dist_id		NUMBER ;

 	FUNCTION GET_RESULT_CODE RETURN BOOLEAN IS
	   x_result_code varchar2(1) ;
  	BEGIN
  	-- Debashis. Added exists and removed rownum.
  	        select 1 into x_result_code from dual where exists (
		select substr(NVL(result_code,'X'),1,1)
       		--  into x_result_code
      		  from gms_bc_packets
    		 where packet_id =  X_packet_id
    		   and substr(NVL(result_code,'X'),1,1) = 'F' );
		--   and rownum < 2 ;

      		Return FALSE ;

   	EXCEPTION
   		when no_data_found then
   			return TRUE ;
   		when TOO_MANY_ROWS then
   			return FALSE ;
 	END GET_RESULT_CODE ;

 begin

   l_budget_version_id := 0 ;
    X_RETURN := FALSE ;

	SELECT	GL_BC_PACKETS_S.nextval
      INTO	X_packet_id
      FROM	DUAL ;

    select  glst.period_name,
			glst.period_year,
			glst.period_num
      into  x_period_name,
            x_period_year,
            x_period_num
      from  gl_period_statuses glst
     where  glst.set_of_books_id = P_sob_id
       and  glst.application_id = 101
       and  glst.adjustment_period_flag = 'N'
       and  valid_fp_tab(1).expenditure_item_date  between glst.start_date and glst.end_date;

   for tab_index in 1..p_ndx loop

        select  bv.budget_version_id
          into  l_budget_version_id
          from  gms_budget_versions bv
         where  bv.project_id         = valid_fp_tab(tab_index).project_id
           and  bv.award_id           = valid_fp_tab(tab_index).award_id
           and  bv.budget_status_code = 'B'
           and	bv.current_flag       = 'Y';

         ------ ==============ERROR PROCESSING IF NO BUDGETS ==========
		IF p_document_type = 'ENC' THEN
			x_doc_header_id :=  valid_fp_tab(tab_index).document_distribution_id ;
			x_doc_dist_id   :=  1 ;
		ELSE
			x_doc_header_id :=  valid_fp_tab(tab_index).document_header_id ;
			x_doc_dist_id   :=  valid_fp_tab(tab_index).document_distribution_id ;
		END IF ;


	       insert into gms_bc_packets (  packet_id,
                                  set_of_books_id,
                                  je_source_name,
                                  je_category_name,
                                  actual_flag,
                                  period_name,
                                  period_year,
		                  period_num,
                                  project_id,
                                  task_id,
                                  award_id,
		                  result_code,
		                  funding_pattern_id,
		                  funding_sequence,
		                  fp_status,
                                  status_code,
                                  last_update_date,
                                  last_updated_by,
                                  created_by,
                                  creation_date,
                                  last_update_login,
                                  entered_dr,
                                  entered_cr,
                                  expenditure_type,
                                  expenditure_organization_id,
                                  expenditure_item_date,
                                  document_type,
                                  document_header_id,
                                  document_distribution_id,
		                  transfered_flag,
		                  budget_version_id,
		                  account_type,
		                  bc_packet_id)
                        values  (x_packet_id,
                                 P_sob_id,
                                 'FAB Source Name',
                                 'FAB Category Name',
                                 'E',
                                 x_period_name,
                                 x_period_year,
                                 x_period_num,
                                 valid_fp_tab(tab_index).project_id,
                                 valid_fp_tab(tab_index).task_id,
                                 valid_fp_tab(tab_index).award_id,
                                 NULL, --result code
                                 null,
                                 null,
                                 null,
                                 'P',					--Bug Fix 2273188
                                 sysdate,
                                 FND_GLOBAL.USER_ID,
                                 FND_GLOBAL.USER_ID,
                                 sysdate,
                                 FND_GLOBAL.LOGIN_ID,
                                 valid_fp_tab(tab_index).award_amount,
                                 0,
                                 valid_fp_tab(tab_index).expenditure_type,
                                 valid_fp_tab(tab_index).expenditure_organization_id,
                                 trunc(valid_fp_tab(tab_index).expenditure_item_date),
                                 'FAB',
                                 x_doc_header_id,
                                 x_doc_dist_id,
                                 --tab_index,
                                 'N',
                                 l_budget_version_id, ---bv.budget_version_id,
                                 'E',
                                 gms_bc_packets_s.nextval
                                 );


   END loop;

   -- ==========================================
   -- Set the packet Arrival Order
   -- ==========================================

   -- REL12 :  Deleted the insert into gl_bc_packet_arrival_order as this table
   --          was replaced with gms_bc_packet_arrival_order and no more used in fundscheck code.
   --          Insert into gms_bc_packet_arrival_order is handles by gms_fck.

    -- ========================================
    -- End of packet arrival order.
    -- ========================================
     X_return := GMS_FUNDS_CONTROL_PKG.GMS_FCK( P_sob_id,
                                                X_packet_id,
                                                'C',                     -- For Check Funds Mode..DEFAULT 'R'
                                                'N',                     --x_override DEFAULT 'N'**ignore
                                                'N',                     --x_partial DEFAULT 'N'
                                                fnd_global.user_id,      --x_user_id,
                                                fnd_global.resp_id,
                                                'Y',                     --x_execute***ignore
                                                x_return_code,           --F-failure,S-success
                                                x_e_code,
                                                x_e_mesg);


     if x_return_code = 'F' then
        X_return :=  FALSE ;
      -- Fix for bug : 1782568
      elsif x_return_code IS NULL then
        X_return := FALSE ;
     else
        X_return :=  GET_RESULT_CODE ;
     end if;

     delete from gms_bc_packets
      where packet_id = X_packet_id;

     return X_return ;

 EXCEPTION
    when others then
      -->>>>>>>> MESSAGE HERE..SYSTEM ERROR OCCURED <<<<<<<<<<<------
      X_return := FALSE ;
      RAISE ;
    --  return X_return ;
 END FUNC_CHECK_FUNDS ;
-- ======================================================
-- Function FUNC_CHECK_FUNDS End.
-- =======================================================



-- ======================================================
-- Function populate_dist_details
-- =======================================================

 PROCEDURE populate_dist_details(cntr in number, p_document_type in varchar2) is
	x_doc_header_id      NUMBER ;
	x_doc_dist_id	     NUMBER ;
 begin

   for Tab_index in 1..cntr loop

	IF p_document_type = 'ENC' THEN
		x_doc_header_id :=  valid_fp_tab(tab_index).document_distribution_id ;
		x_doc_dist_id   :=  1 ;
	ELSE
		x_doc_header_id :=  valid_fp_tab(tab_index).document_header_id ;
		x_doc_dist_id   :=  valid_fp_tab(tab_index).document_distribution_id ;
	END IF ;

        insert into gms_distribution_details (
                                                document_header_id,
                                                document_distribution_id,
						document_type,
                                                funding_pattern_id,
                                                distribution_number,
                                                award_id,
                                                project_id,
                                                task_id,
                                                expenditure_type,
                                                expenditure_organization_id,
                                                expenditure_item_date,
                                                gl_date,
                                                quantity_distributed,
                                                amount_distributed,
                                                fc_status,
                                                line_status,
                                                remarks,
						burdened_cost,
						denom_burdened_cost,
						acct_burdened_cost,
						denom_raw_cost,
						acct_raw_cost,
						receipt_currency_amount,
                                                creation_date)
                                                values
                                                (
                                                x_doc_header_id,
                                                x_doc_dist_id,
						p_document_type,
                                                valid_fp_tab(tab_index).funding_pattern_id,
                                                tab_index,
                                                valid_fp_tab(tab_index).award_id,
                                                valid_fp_tab(tab_index).project_id,
                                                valid_fp_tab(tab_index).task_id,
                                                valid_fp_tab(tab_index).expenditure_type,
                                                valid_fp_tab(tab_index).expenditure_organization_id,
                                                valid_fp_tab(tab_index).expenditure_item_date,
                                                valid_fp_tab(tab_index).gl_date,
                                                valid_fp_tab(tab_index).quantity,
                                                valid_fp_tab(tab_index).award_amount,
                                                'A',
                                                'N',
                                                NULL,
						valid_fp_tab(tab_index).burdened_cost,
						valid_fp_tab(tab_index).denom_burdened_cost,
						valid_fp_tab(tab_index).acct_burdened_cost,
						valid_fp_tab(tab_index).denom_raw_cost,
						valid_fp_tab(tab_index).acct_raw_cost,
						valid_fp_tab(tab_index).receipt_currency_amount,
                                                sysdate
                                                );
   end loop;
 END populate_dist_details;
-- ======================================================
-- Function populate_dist_details  ends.
-- =======================================================


-- ======================================================
-- Function  FUNC_FIND_PATTERN
-- =======================================================
FUNCTION FUNC_FIND_PATTERN( p_project_id  IN NUMBER,
                               p_task_id     IN NUMBER,
                               p_exp_type    IN VARCHAR2,
                               p_exp_item_dt IN date,
                               p_org_id      IN number,
			       p_funding_pattern_id IN NUMBER)
return NUMBER IS

    l_pattern_id    NUMBER ;

    cursor fetch_awards1 (x_funding_pattern_id in number) is
            select award_id,
                    distribution_value
             from gms_fp_distributions
            where funding_pattern_id = x_funding_pattern_id
            order by distribution_number ;

 get_awards_rec     fetch_awards1%ROWTYPE;

 l_return       BOOLEAN;
 l_valid_trans  BOOLEAN;
BEGIN

     l_return   := TRUE;


            X_error := 'Opened fetch awards1';
        open fetch_awards1( p_funding_pattern_id );

        loop
            fetch fetch_awards1 into get_awards_rec;
            if fetch_awards1%NOTFOUND then
                close fetch_awards1;
                exit;
            end if;

            l_valid_trans := valid_transaction( p_project_id,
                                                p_task_id   ,
                                                get_awards_rec.award_id,
                                                p_exp_type,
                                                P_EXP_ITEM_DT  ) ;
            if (l_valid_trans) then
                l_pattern_id    := p_funding_pattern_id ;
            else

	      -- ======================================================
              -- l_pattern_id := -1  indicates POETA validation failed.
              -- ======================================================
              l_pattern_id := -1 ;

                close fetch_awards1;
              exit;
            end if;
      end loop; -- get_awards

     return l_pattern_id ;

EXCEPTION
    WHEN OTHERS THEN
            if fetch_awards1%ISOPEN then
                close fetch_awards1;
            END IF ;

            RAISE ;
END FUNC_FIND_PATTERN ;
-- ======================================================
-- Function  FUNC_FIND_PATTERN Ends.
-- =======================================================


-- ======================================================
--  PROCEDURE PROC_DISTRIBUTE_RECORDS *** Main process.
-- =======================================================
PROCEDURE PROC_DISTRIBUTE_RECORDS( p_doc_header_id    in  number,
                                   p_doc_type         in  varchar2,
                                   p_recs_processed   out NOCOPY number,
                                   p_recs_rejected    out NOCOPY number) is




 l_do_funds_check   varchar2(10);
 l_org_id           varchar2(10);
 found_fp           BOOLEAN ;
 l_check_funds      BOOLEAN ;

 l_return_stat      varchar2(10);
 l_tab_index        number ; --- index for the table
 l_pattern_id       number ;
 l_processed        NUMBER ;
 l_rejected         NUMBER ;


    get_funding_pattern_rec	get_funding_pattern%ROWTYPE;
---------------------------- Begin Main ---------------------------------------------------------
 BEGIN
   found_fp           := FALSE;
   l_check_funds      := FALSE ;
   l_tab_index        := 0; --- index for the table
   l_pattern_id       := 0;
   l_processed        := 0 ;
   l_rejected         := 0 ;
   valid_fp_tab       := fp_table();

   l_org_id := PA_MOAC_UTILS.GET_CURRENT_ORG_ID;

   -- FND_PROFILE.GET('ORG_ID', l_org_id);

   FND_PROFILE.GET('GMS_DO_FUNDS_CHECK', l_do_funds_check); --- Define a profile name for funds check YES/NO

   -- =======================================
   -- We don't do funds check for ACTUALS.
   -- =======================================
   IF p_doc_type = 'EXP' THEN
      l_do_funds_check := 'N' ;
   END IF ;

   l_do_funds_check := NVL(l_do_funds_check,'N') ;



 -- Get the Set of Books ID

   select set_of_books_id
     into P_sob_id
     from pa_implementations;

  -- ERR99 ( System Exception was captured for NO_data_found
  -- -------------------------------------------------------


   open apply_fp ( P_doc_header_id, p_doc_type );
   LOOP

       fetch apply_fp into recs;

        IF apply_fp%NOTFOUND then
            close apply_fp;
            exit;
       END IF ;

     -- ================== Pattern Processing =====================
     open get_funding_pattern( recs.project_id,
                               recs.task_id,
                               recs.expenditure_item_date,
                               l_org_id);
     l_pattern_id   := 0 ;
     -- ***** Pattern LOOP ***************
     LOOP

    	fetch get_funding_pattern into get_funding_pattern_rec;

	-- ==========================================================
        -- BUG : 3222459
        -- Transaction import process is erroring in pre_import step.
	-- l_tab_index didn't initialize before funding pattern.
	-- So if funding pattern was not found then l_tab_index had
	-- retained the previous value.
	-- l_tab_index initialization had fixed the issue.
	-- ==========================================================
        l_tab_index := 0 ;
        if get_funding_pattern%NOTFOUND then
              close get_funding_pattern;
              exit;
        end if;

        --  BEGIN OF Pattern Stage 01 =========================================================
        l_pattern_id   := FUNC_FIND_PATTERN (   recs.project_id,
                                                recs.task_id,
                                                recs.expenditure_type,
                                                recs.expenditure_item_date,
                                                l_org_id,
						get_funding_pattern_rec.funding_pattern_id) ;

        l_tab_index := 0 ;

        IF l_pattern_id > 0 THEN
            l_tab_index := FUNC_add_to_table( l_pattern_id )  ;
        END IF ;

        --  END OF Pattern Stage 01 =========================================================

        l_check_funds := TRUE ;

        -- ============= Funds Check Processing ============
        if (upper(l_do_funds_check) = 'Y' and l_tab_index > 0 ) then
            l_check_funds := FUNC_CHECK_FUNDS(l_tab_index, p_doc_type);
        END IF ;
        -- END OF Funds Check Processing ====================

	IF l_check_funds THEN
	   EXIT ;
	END IF ;

     END LOOP ;
     if get_funding_pattern%ISOPEN then
        close get_funding_pattern;
     END IF ;
     -- ***** End of Pattern LOOP ***************

     -- ================== End of Pattern Processing =====================



        -- ==== Create Distributions ========
        IF l_check_funds and l_tab_index > 0 then
            populate_dist_details(l_tab_index, p_doc_type);

            update gms_distributions
               set dist_status = 'FABA'
             where rowid = recs.rowid ;

            l_processed := l_processed + 1 ;
        ELSE
            -- ============== ERROR PROCESSING ============
            --   FUNDS CHECK FAILED
            -- ============================================
            -- ERR02 ( Pattern not found. )
            -- ERR01 ( POETA Failed. )

            IF l_pattern_id <= 0 THEN

               update gms_distributions
                  set dist_status = DECODE(l_pattern_id, -1, 'ERR01', 'ERR02' )
                where rowid                            = recs.rowid
                  and document_header_id               = p_doc_header_id
                  and document_type                    = p_doc_type ;

             ELSIF NOT ( l_check_funds ) THEN

               -- ERR03 ( Check funds failed. )
               update gms_distributions
                  set dist_status = 'ERR03'
                where rowid      = recs.rowid
                  and document_header_id   = p_doc_header_id
                  and document_type = p_doc_type ;
             END IF ;

            l_rejected := l_rejected + 1 ;
            NULL ;
        END IF ;
        -- === End of create Distributions ==============
   END LOOP ;

    if apply_fp%ISOPEN then
      close apply_fp;
    end if;

   p_recs_processed   := l_processed ;
   p_recs_rejected    := l_rejected ;
   delete from gms_distributions
   where creation_date <= ( TRUNC(sysdate) -1  ) ;

   delete from gms_distribution_details
   where creation_date <= ( TRUNC(sysdate) -1  ) ;
   COMMIT ;
 EXCEPTION
     when others then
       --dbms_output.put_line('Error : ' || sqlerrm || X_error);

     if get_funding_pattern%ISOPEN then
        close get_funding_pattern;
     END IF ;

    if apply_fp%ISOPEN then
      close apply_fp;
    end if;

    RAISE ;

   end PROC_DISTRIBUTE_RECORDS ;
-- ==========================================================
--  PROCEDURE PROC_DISTRIBUTE_RECORDS *** Main process ends.
-- ===========================================================

   PROCEDURE PROC_INSERT_TRANS( P_transaction_source	varchar2,
                      		p_batch             	varchar2,
                      		p_user_id           	NUMBER,
                      		p_xface_id          	NUMBER ) IS
	count_new_rec	NUMBER ;
   BEGIN
      	pa_cc_utils.set_curr_function('PROC_INSERT_TRANS');

	UPDATE GMS_DISTRIBUTION_DETAILS
	   SET remarks 			= to_char(PA_TXN_INTERFACE_S.nextval)
	 WHERE document_header_id	= p_xface_id
	   AND document_type		= 'EXP'
	   AND distribution_number	> 1 ;

      	pa_cc_utils.log_message(' Generated new txn_interface_id :'||to_char(SQL%ROWCOUNT));
        --  3466152
        --  import process award distributions doesn't work when batch name is not supplied.
	--  addaed transaction source in the where clause to have better performance.
	--
	--  Bug 3221039 : Modified the following insert to populate award number and not
        --  to populate obsolete columns.

	INSERT into GMS_TRANSACTION_INTERFACE_ALL
	(
		--TASK_NUMBER                                ,
		AWARD_ID                                   ,
		AWARD_NUMBER                               ,
		--EXPENDITURE_TYPE                           ,
		--TRANSACTION_STATUS_CODE                    ,
		--ORIG_TRANSACTION_REFERENCE                 ,
		--ORG_ID                                     ,
		--SYSTEM_LINKAGE                             ,
		--USER_TRANSACTION_SOURCE                    ,
		TRANSACTION_TYPE                           ,
		BURDENABLE_RAW_COST                        ,
		FUNDING_PATTERN_ID                         ,
		CREATED_BY                                 ,
		CREATION_DATE                              ,
		LAST_UPDATED_BY                            ,
		LAST_UPDATE_DATE                           ,
		TXN_INTERFACE_ID
		--BATCH_NAME                                 ,
		--TRANSACTION_SOURCE                         ,
		--EXPENDITURE_ENDING_DATE                    ,
		--EXPENDITURE_ITEM_DATE,
		--PROJECT_NUMBER
	)
	SELECT
		--TXN.TASK_NUMBER                                ,
		GTN.AWARD_ID                                   ,
		GA.AWARD_NUMBER                                ,
		--TXN.EXPENDITURE_TYPE                           ,
		--TXN.TRANSACTION_STATUS_CODE                    ,
		--TXN.ORIG_TRANSACTION_REFERENCE                 ,
		--TXN.ORG_ID                                     ,
		--TXN.SYSTEM_LINKAGE                             ,
		--TXN.USER_TRANSACTION_SOURCE                    ,
		NULL                           			,
		NULL                        ,
		GTN.funding_pattern_id                         ,
		TXN.CREATED_BY                                 ,
		TXN.CREATION_DATE                              ,
		TXN.LAST_UPDATED_BY                            ,
		TXN.LAST_UPDATE_DATE                           ,
		TO_NUMBER(GTN.REMARKS)
		--TXN.BATCH_NAME                                 ,
		--TXN.TRANSACTION_SOURCE                         ,
		--TXN.EXPENDITURE_ENDING_DATE                    ,
		--TXN.EXPENDITURE_ITEM_DATE			,
		--TXN.PROJECT_NUMBER
	  FROM 	PA_TRANSACTION_INTERFACE_ALL TXN,
		GMS_DISTRIBUTION_DETAILS     GTN,
		GMS_AWARDS_ALL               GA   -- Bug 3221039
	 WHERE GTN.document_header_id	= p_xface_id
	   AND GA.award_id              = GTN.award_id  -- Bug 3221039
           AND TXN.transaction_source   = P_transaction_source
	   AND GTN.document_type	= 'EXP'
	   AND GTN.distribution_number	> 1
	   AND GTN.document_distribution_id	= TXN.TXN_INTERFACE_ID ;

	count_new_rec	:= SQL%ROWCOUNT ;
      	pa_cc_utils.log_message(' GMS Transactions inserted :'||to_char(SQL%ROWCOUNT));

        --  3466152
        --  import process award distributions doesn't work when batch name is not supplied.
	--  addaed transaction source in the where clause to have better performance.
	--
	INSERT into PA_TRANSACTION_INTERFACE_ALL
	( 	RECEIPT_CURRENCY_AMOUNT       ,
		RECEIPT_CURRENCY_CODE         ,
		RECEIPT_EXCHANGE_RATE         ,
		DENOM_CURRENCY_CODE           ,
		DENOM_RAW_COST                ,
		DENOM_BURDENED_COST           ,
		ACCT_RATE_DATE                ,
		ACCT_RATE_TYPE                ,
		ACCT_EXCHANGE_RATE            ,
		ACCT_RAW_COST                 ,
		ACCT_BURDENED_COST            ,
		ACCT_EXCHANGE_ROUNDING_LIMIT  ,
		PROJECT_CURRENCY_CODE         ,
		PROJECT_RATE_DATE             ,
		PROJECT_RATE_TYPE             ,
		PROJECT_EXCHANGE_RATE         ,
		ORIG_EXP_TXN_REFERENCE1       ,
		ORIG_EXP_TXN_REFERENCE2       ,
		ORIG_EXP_TXN_REFERENCE3       ,
		ORIG_USER_EXP_TXN_REFERENCE   ,
		VENDOR_NUMBER                 ,
		OVERRIDE_TO_ORGANIZATION_NAME ,
		REVERSED_ORIG_TXN_REFERENCE   ,
		BILLABLE_FLAG                 ,
		PERSON_BUSINESS_GROUP_NAME    ,
		TRANSACTION_SOURCE            ,
		BATCH_NAME                    ,
		EXPENDITURE_ENDING_DATE       ,
		EMPLOYEE_NUMBER               ,
		ORGANIZATION_NAME             ,
		EXPENDITURE_ITEM_DATE         ,
		PROJECT_NUMBER                ,
		TASK_NUMBER                   ,
		EXPENDITURE_TYPE              ,
		NON_LABOR_RESOURCE            ,
		NON_LABOR_RESOURCE_ORG_NAME   ,
		QUANTITY                      ,
		RAW_COST                      ,
		EXPENDITURE_COMMENT           ,
		TRANSACTION_STATUS_CODE       ,
		TRANSACTION_REJECTION_CODE    ,
		EXPENDITURE_ID                ,
		ORIG_TRANSACTION_REFERENCE    ,
		ATTRIBUTE_CATEGORY            ,
		ATTRIBUTE1                    ,
		ATTRIBUTE2                    ,
		ATTRIBUTE3                    ,
		ATTRIBUTE4                    ,
		ATTRIBUTE5                    ,
		ATTRIBUTE6                    ,
		ATTRIBUTE7                    ,
		ATTRIBUTE8                    ,
		ATTRIBUTE9                    ,
		ATTRIBUTE10                   ,
		RAW_COST_RATE                 ,
		INTERFACE_ID                  ,
		UNMATCHED_NEGATIVE_TXN_FLAG   ,
		EXPENDITURE_ITEM_ID           ,
		ORG_ID                        ,
		DR_CODE_COMBINATION_ID        ,
		CR_CODE_COMBINATION_ID        ,
		CDL_SYSTEM_REFERENCE1         ,
		CDL_SYSTEM_REFERENCE2         ,
		CDL_SYSTEM_REFERENCE3         ,
		GL_DATE                       ,
		BURDENED_COST                 ,
		BURDENED_COST_RATE            ,
		SYSTEM_LINKAGE                ,
		TXN_INTERFACE_ID              ,
		USER_TRANSACTION_SOURCE       ,
		CREATED_BY                    ,
		CREATION_DATE                 ,
		LAST_UPDATED_BY               ,
		LAST_UPDATE_DATE              ,
                PROJFUNC_CURRENCY_CODE        ,
                PROJFUNC_COST_RATE_TYPE       ,
                PROJFUNC_COST_RATE_DATE       ,
                PROJFUNC_COST_EXCHANGE_RATE   ,
                PROJECT_RAW_COST              ,
                PROJECT_BURDENED_COST         ,
                ASSIGNMENT_NAME               ,
                WORK_TYPE_NAME                ,
                CDL_SYSTEM_REFERENCE4         ,
                ACCRUAL_FLAG                  ,
                PROJECT_ID                    ,
                TASK_ID                       ,
                PERSON_ID                     ,
                ORGANIZATION_ID               ,
                NON_LABOR_RESOURCE_ORG_ID     ,
                VENDOR_ID                     ,
                OVERRIDE_TO_ORGANIZATION_ID   ,
                ASSIGNMENT_ID                ,
                WORK_TYPE_ID                  ,
                PERSON_BUSINESS_GROUP_ID      ,
                INVENTORY_ITEM_ID             ,
                WIP_RESOURCE_ID               ,
                UNIT_OF_MEASURE               ,
                PO_NUMBER                     , /* CWK Changes */
                PO_HEADER_ID                  ,
                PO_LINE_NUM                   ,
                PO_LINE_ID                    ,
                PERSON_TYPE                   ,
                PO_PRICE_TYPE
	)
	SELECT
		GTN.RECEIPT_CURRENCY_AMOUNT       ,
		TXN.RECEIPT_CURRENCY_CODE         ,
		TXN.RECEIPT_EXCHANGE_RATE         ,
		TXN.DENOM_CURRENCY_CODE           ,
		GTN.DENOM_RAW_COST                ,
		GTN.DENOM_BURDENED_COST           ,
		TXN.ACCT_RATE_DATE                ,
		TXN.ACCT_RATE_TYPE                ,
		TXN.ACCT_EXCHANGE_RATE            ,
		GTN.ACCT_RAW_COST                 ,
		GTN.ACCT_BURDENED_COST            ,
		TXN.ACCT_EXCHANGE_ROUNDING_LIMIT  ,
		TXN.PROJECT_CURRENCY_CODE         ,
		TXN.PROJECT_RATE_DATE             ,
		TXN.PROJECT_RATE_TYPE             ,
		TXN.PROJECT_EXCHANGE_RATE         ,
		TXN.ORIG_EXP_TXN_REFERENCE1       ,
		TXN.ORIG_EXP_TXN_REFERENCE2       ,
		TXN.ORIG_EXP_TXN_REFERENCE3       ,
		TXN.ORIG_USER_EXP_TXN_REFERENCE   ,
		TXN.VENDOR_NUMBER                 ,
		TXN.OVERRIDE_TO_ORGANIZATION_NAME ,
		TXN.REVERSED_ORIG_TXN_REFERENCE   ,
		TXN.BILLABLE_FLAG                 ,
		TXN.PERSON_BUSINESS_GROUP_NAME    ,
		TXN.TRANSACTION_SOURCE            ,
		TXN.BATCH_NAME                    ,
		TXN.EXPENDITURE_ENDING_DATE       ,
		TXN.EMPLOYEE_NUMBER               ,
		TXN.ORGANIZATION_NAME             ,
		TXN.EXPENDITURE_ITEM_DATE         ,
		TXN.PROJECT_NUMBER                ,
		TXN.TASK_NUMBER                   ,
		TXN.EXPENDITURE_TYPE              ,
		TXN.NON_LABOR_RESOURCE            ,
		TXN.NON_LABOR_RESOURCE_ORG_NAME   ,
		GTN.QUANTITY_DISTRIBUTED          ,
		GTN.AMOUNT_DISTRIBUTED            ,
		TXN.EXPENDITURE_COMMENT           ,
		TXN.TRANSACTION_STATUS_CODE       ,
		TXN.TRANSACTION_REJECTION_CODE    ,
		TXN.EXPENDITURE_ID                ,
		TXN.ORIG_TRANSACTION_REFERENCE    ,
		TXN.ATTRIBUTE_CATEGORY            ,
		TXN.ATTRIBUTE1                    ,
		TXN.ATTRIBUTE2                    ,
		TXN.ATTRIBUTE3                    ,
		TXN.ATTRIBUTE4                    ,
		TXN.ATTRIBUTE5                    ,
		TXN.ATTRIBUTE6                    ,
		TXN.ATTRIBUTE7                    ,
		TXN.ATTRIBUTE8                    ,
		TXN.ATTRIBUTE9                    ,
		TXN.ATTRIBUTE10                   ,
		TXN.RAW_COST_RATE                 ,
		TXN.INTERFACE_ID                  ,
		TXN.UNMATCHED_NEGATIVE_TXN_FLAG   ,
		TXN.EXPENDITURE_ITEM_ID           ,
		TXN.ORG_ID                        ,
		TXN.DR_CODE_COMBINATION_ID        ,
		TXN.CR_CODE_COMBINATION_ID        ,
		TXN.CDL_SYSTEM_REFERENCE1         ,
		TXN.CDL_SYSTEM_REFERENCE2         ,
		TXN.CDL_SYSTEM_REFERENCE3         ,
		TXN.GL_DATE                       ,
		GTN.BURDENED_COST                 ,
		TXN.BURDENED_COST_RATE            ,
		TXN.SYSTEM_LINKAGE                ,
		TO_NUMBER(GTN.REMARKS)            ,
		TXN.USER_TRANSACTION_SOURCE       ,
		TXN.CREATED_BY                    ,
		TXN.CREATION_DATE                 ,
		TXN.LAST_UPDATED_BY               ,
		TXN.LAST_UPDATE_DATE              ,
		TXN.PROJFUNC_CURRENCY_CODE        ,
		TXN.PROJFUNC_COST_RATE_TYPE       ,
		TXN.PROJFUNC_COST_RATE_DATE       ,
		TXN.PROJFUNC_COST_EXCHANGE_RATE   ,
		TXN.PROJECT_RAW_COST              ,
		TXN.PROJECT_BURDENED_COST         ,
		TXN.ASSIGNMENT_NAME               ,
		TXN.WORK_TYPE_NAME                ,
		TXN.CDL_SYSTEM_REFERENCE4         ,
		TXN.ACCRUAL_FLAG                  ,
		TXN.PROJECT_ID                    ,
		TXN.TASK_ID                       ,
		TXN.PERSON_ID                     ,
		TXN.ORGANIZATION_ID               ,
		TXN.NON_LABOR_RESOURCE_ORG_ID     ,
		TXN.VENDOR_ID                     ,
		TXN.OVERRIDE_TO_ORGANIZATION_ID   ,
		TXN.ASSIGNMENT_ID                ,
		TXN.WORK_TYPE_ID                  ,
		TXN.PERSON_BUSINESS_GROUP_ID      ,
		TXN.INVENTORY_ITEM_ID             ,
		TXN.WIP_RESOURCE_ID               ,
		TXN.UNIT_OF_MEASURE               ,
		TXN.PO_NUMBER                     ,
		TXN.PO_HEADER_ID                  ,
		TXN.PO_LINE_NUM                   ,
		TXN.PO_LINE_ID                    ,
		TXN.PERSON_TYPE                   ,
		TXN.PO_PRICE_TYPE
	  FROM PA_TRANSACTION_INTERFACE_ALL TXN,
	       GMS_DISTRIBUTION_DETAILS     GTN
	 WHERE GTN.document_header_id	= p_xface_id
	   AND GTN.document_type	= 'EXP'
           AND TXN.transaction_source   = P_transaction_source
	   AND GTN.distribution_number	> 1
	   AND GTN.document_distribution_id   	= TXN.TXN_INTERFACE_ID ;

  	count_new_rec	:= SQL%ROWCOUNT ;
  	pa_cc_utils.log_message(' PA Transactions inserted :'||to_char(SQL%ROWCOUNT));
	DELETE from GMS_DISTRIBUTION_DETAILS
	 where document_header_id   = p_xface_id ;

      	pa_cc_utils.log_message(' No of GMS_DISTRIBUTION_DETAILS records deleted :'||to_char(SQL%ROWCOUNT));
	DELETE from GMS_DISTRIBUTIONS
	 where document_header_id   = p_xface_id ;
      	pa_cc_utils.log_message(' No of GMS_DISTRIBUTIONS records deleted :'||to_char(SQL%ROWCOUNT));
      	pa_cc_utils.reset_curr_function;
   EXCEPTION
	When others then
      		pa_cc_utils.log_message(' ERROR :'||SQLERRM);
      		pa_cc_utils.reset_curr_function;
		RAISE ;
   END PROC_INSERT_TRANS ;

   -- ============
   FUNCTION lockCntrlRec ( trx_source   VARCHAR2
                       	, batch        VARCHAR2
                       	, etypeclasscode VARCHAR2 ) RETURN NUMBER IS
	dummy	NUMBER ;
   BEGIN
      		pa_cc_utils.set_curr_function('Award Distribution lockCntrlRec');

      		pa_cc_utils.log_message('Trying to get lock for record in xface ctrl:'||
                                	' transaction source ='||trx_source||
                                	' batch = '||batch||
                                	' sys link = '||etypeclasscode, 1);
      		SELECT 1
        	  INTO dummy
        	  FROM pa_transaction_xface_control
       		 WHERE transaction_source 	= trx_source
         	   AND  batch_name 		= batch
         	   AND  system_linkage_function = etypeclasscode
         	   AND  status 			= 'PENDING'
      		   FOR UPDATE OF status NOWAIT;

      		pa_cc_utils.log_message('Got lock for record',1);
      		pa_cc_utils.log_message('Updated interface id/status on pa_transaction_xface_control',1);
      		pa_cc_utils.reset_curr_function;

      		RETURN 0;
   EXCEPTION
      		WHEN  RESOURCE_BUSY  THEN
      			pa_cc_utils.log_message('Cannot get lock',1);
      			pa_cc_utils.reset_curr_function;
          		RETURN -1;
   END lockCntrlRec;


   -- ===============================================================
   -- GET_DIST_AWARD_ID returns default distribution award_id
   -- defined in gms implementation setup form.
   -- ===============================================================
   -- Bug 3221039 : Modified the below function to procedure inorder to
   -- fetch even the default award distribution number.

   --FUNCTION GET_DIST_AWARD_ID(p_status out NOCOPY varchar2) return NUMBER is
   --		x_dummy		NUMBER ;

   PROCEDURE GET_DIST_AWARD_ID( p_default_dist_award_id out NOCOPY NUMBER,
                                p_default_dist_award_number out NOCOPY varchar2,
                                p_status out NOCOPY varchar2) IS
   BEGIN
      		pa_cc_utils.set_curr_function('Award Distribution GET_DIST_AWARD_ID');

		SELECT default_dist_award_id,
  	               default_dist_award_number -- Bug 3221039
		  INTO p_default_dist_award_id,
		       p_default_dist_award_number -- Bug 3221039
		  FROM GMS_IMPLEMENTATIONS
		 WHERE AWARD_DISTRIBUTION_OPTION = 'Y' ;

      		pa_cc_utils.log_message('Award Distribution default_dist_award_id='||to_char(p_default_dist_award_id));
      		pa_cc_utils.reset_curr_function;

		--return x_dummy ;
   EXCEPTION
		when no_data_found then
			p_status := 'NO_DATA_FOUND' ;
      			pa_cc_utils.log_message('Award Distribution default_dist_award_id not enabled.****');
      			pa_cc_utils.reset_curr_function;
			--return -1 ;
   END GET_DIST_AWARD_ID ;
   -- ==== End of GET_DIST_AWARD_ID ==================================

   PROCEDURE PRE_IMPORT(   P_transaction_source    IN      VARCHAR2,
                           p_batch                 IN      varchar2,
                           p_user_id               IN      NUMBER,
                           p_xface_id              IN      NUMBER ) IS
	    FIRST_RECORD			BOOLEAN ;

 	    v_doc_header_id			T_NUM_TAB ;
	    v_doc_dist_id			T_NUM_TAB ;
	    V_project_id			T_NUM_TAB ;
	    V_task_id				T_NUM_TAB ;
	    V_exp_org_id			T_NUM_TAB ;
	    V_quantity				T_NUM_TAB ;
	    V_unit_price			T_NUM_TAB ;
	    V_amount				T_NUM_TAB ;
	    V_burdened_cost			T_NUM_TAB ;
	    v_denom_raw_cost			T_NUM_TAB ;
	    v_denom_burdened_cost		T_NUM_TAB ;
	    v_acct_raw_cost			T_NUM_TAB ;
	    v_acct_burdened_cost		T_NUM_TAB ;
	    v_receipt_currency_amount		T_NUM_TAB ;

	    V_exp_type				T_varchar_tab ;
	    V_dist_status			T_varchar_tab ;
	    V_exp_item_date			T_DATE_TAB ;
	    V_creation_date			T_DATE_TAB ;
	    v_gl_date				T_DATE_TAB ;

	    x_default_dist_award_id		NUMBER ;
	    count_rec				NUMBER ;
	    dummy				NUMBER ;
	    x_accepted				NUMBER ;
	    x_rejected				NUMBER ;
	    x_record_found			NUMBER ;

	    x_org_id				NUMBER ;
	    x_override_to_org_id		NUMBER ;
	    x_incurred_by_org_id		NUMBER ;
	    x_dummy				NUMBER ;


	    x_status				VARCHAR2(30) ;
	    x_org_status			VARCHAR2(30) ;
	    X_billable_flag			varchar2(1) ;
  	    l_default_dist_award_number		VARCHAR2(15); -- Bug 3221039
	    l_emp_org_oride            varchar2(1) ;
	    l_emporg_id                NUMBER ;
	    l_empJob_id                NUMBER ;
            l_project_id                        pa_projects_all.project_id%TYPE ;
            l_project_id_last                   pa_projects_all.project_id%TYPE ;
	    l_project_number                    pa_projects_all.segment1%TYPE ;
	    l_project_number_last               pa_projects_all.segment1%TYPE ;
	    l_task_id                           pa_tasks.task_id%TYPE ;
	    l_task_id_last                      pa_tasks.task_id%TYPE ;
	    l_task_number                       pa_tasks.task_number%TYPE ;
	    l_task_number_last                  pa_tasks.task_number%TYPE ;
	    --l_sponsored_flag                    gms_project_types_all.sponsored_flag%TYPE ;
	    l_sponsored_flag                    pa_project_types.sponsored_flag%TYPE ;  --bug 4712763

            cursor c_project_id is
	    select project_id
	      from pa_projects_all
	     where segment1 = l_project_number ;

	     --
	     -- bug : 3628820 perf issue in gmsawdeb.pls
	     -- FTS on pa_projects and pa_tasks table.
	     --
	    cursor c_project_number is
	    select segment1
	      from pa_projects_all
	     where project_id = l_project_id ;
	    --
	    -- bug : 3628820 perf issue in gmsawdeb.pls
	    -- FTS on pa_projects and pa_tasks table.
	    --
	    cursor c_task_id is
	    select task_id
	      from pa_tasks
	     where task_number = l_task_number
	       and project_id  = l_project_id ;

	    --
	    -- bug : 3628820 perf issue in gmsawdeb.pls
	    -- FTS on pa_projects and pa_tasks table.
	    --
	    cursor c_task_number is
	    select task_number
	      from pa_tasks
	     where task_id = l_task_id ;

	     --
	     -- bug : 3628820 perf issue in gmsawdeb.pls
	     -- FTS on pa_projects and pa_tasks table.
	     --
             cursor c_sponsored_flag is
	      select sponsored_flag
		from pa_projects_all p,
		     gms_project_types gpt
               where p.project_id   = l_project_id
		 and p.project_type = gpt.project_type ;

        -- PA.L Changes
        CURSOR c_trans_source is
        SELECT allow_emp_org_override_flag
          from pa_transaction_sources
         where transaction_source = P_TRANSACTION_SOURCE ;
        -- PA.L Changes.

	    CURSOR TrxBatches  IS
		SELECT  xc.transaction_source
		       	, xc.batch_name
			, xc.system_linkage_function
		     	, xc.batch_name ||xc.system_linkage_function|| to_char(P_xface_id) exp_group_name
		   FROM pa_transaction_xface_control xc
		   WHERE xc.transaction_source  = P_transaction_source
		     AND  xc.batch_name         = nvl(P_batch, xc.batch_name)
		     AND  xc.status             = 'PENDING';

   	    CURSOR TrxRecs ( X_transaction_source    VARCHAR2
			     , current_batch         VARCHAR2
			     , curr_etype_class_code VARCHAR2  ) IS
		SELECT  TXN.system_linkage
			,   TXN.expenditure_ending_date expenditure_ending_date
			,   TXN.employee_number
			,   decode( TXN.employee_number, NULL, TXN.organization_name,
				decode(allow_emp_org_override_flag,'Y',TXN.organization_name,NULL)) organization_name
			,   TXN.expenditure_item_date expenditure_item_date
			,   TXN.project_number
			,   TXN.project_id
			,   TXN.task_id
			,   TXN.task_number
			,   TXN.expenditure_type
			,   TXN.non_labor_resource
			,   TXN.non_labor_resource_org_name
			,   TXN.quantity
			,   TXN.raw_cost
			,   TXN.raw_cost_rate
			,   TXN.orig_transaction_reference
			,   TXN.attribute_category
			,   TXN.attribute1
			,   TXN.attribute2
			,   TXN.attribute3
			,   TXN.attribute4
			,   TXN.attribute5
			,   TXN.attribute6
			,   TXN.attribute7
			,   TXN.attribute8
			,   TXN.attribute9
			,   TXN.attribute10
			,   TXN.expenditure_comment
			,   TXN.interface_id
			,   TXN.expenditure_id
			,   TXN.unmatched_negative_txn_flag unmatched_negative_txn_flag
			,   to_number( NULL )  expenditure_item_id
			,   to_number( NULL )  job_id
			,   TXN.org_id             org_id
			,   TXN.dr_code_combination_id
			,   TXN.cr_code_combination_id
			,   TXN.cdl_system_reference1
			,   TXN.cdl_system_reference2
			,   TXN.cdl_system_reference3
			,   TXN.gl_date
			,   TXN.burdened_cost
			,   TXN.burdened_cost_rate
			,   TXN.receipt_currency_amount
			,   TXN.receipt_currency_code
			,   TXN.receipt_exchange_rate
			,   TXN.denom_currency_code
			,   TXN.denom_raw_cost
			,   TXN.denom_burdened_cost
			,   TXN.acct_rate_date
			,   TXN.acct_rate_type
			,   TXN.acct_exchange_rate
			,   TXN.acct_raw_cost
			,   TXN.acct_burdened_cost
			,   TXN.acct_exchange_rounding_limit
			,   TXN.project_currency_code
			,   TXN.project_rate_date
			,   TXN.project_rate_type
			,   TXN.project_exchange_rate
			,   TXN.orig_exp_txn_reference1
			,   TXN.orig_user_exp_txn_reference
			,   TXN.vendor_number
			,   TXN.orig_exp_txn_reference2
			,   TXN.orig_exp_txn_reference3
			,   TXN.override_to_organization_name
			,   TXN.reversed_orig_txn_reference
			,   TXN.billable_flag
			,   TXN.txn_interface_id
			,   TXN.person_business_group_name
			-- Bug 2464841 : Added parameters for 11.5 PA-J certification.
			,   TXN.projfunc_currency_code
			,   TXN.projfunc_cost_rate_type
			,   TXN.projfunc_cost_rate_date
			,   TXN.projfunc_cost_exchange_rate
			,   TXN.project_raw_cost
			,   TXN.project_burdened_cost
			,   TXN.assignment_name
			,   TXN.work_type_name
			,   TXN.accrual_flag
                        ,   TXN.person_id -- PA.L Changes
                        ,   TXN.organization_id
                        ,   TXN.non_labor_resource_org_id
                        ,   TXN.vendor_id
                        ,   TXN.override_to_organization_id
                        ,   TXN.assignment_id
                        ,   TXN.work_type_id
                        ,   TXN.person_business_group_id   -- PA.L Changes end.
                        ,   TXN.po_number  /* cwk */
                        ,   TXN.po_header_id
                        ,   TXN.po_line_num
                        ,   TXN.po_line_id
                        ,   TXN.person_type
                        ,   TXN.po_price_type
                        ,   TXN.wip_resource_id
                        ,   TXN.inventory_item_id
                        ,   TXN.unit_of_measure
		  FROM pa_transaction_interface TXN,
		       pa_transaction_sources	TS,
		       GMS_transaction_interface_all GMS1
		 WHERE TXN.transaction_source 		= X_transaction_source
		   and ts.transaction_source 		= TXN.transaction_source
		   AND TXN.batch_name 			= current_batch
		   AND TXN.transaction_status_code 	= 'P'
		   and gms1.TXN_INTERFACE_ID		= TXN.TXN_INTERFACE_ID
		   and ( (gms1.award_number IS NULL AND NVL(gms1.award_id,0) = x_default_dist_award_id)
		          OR
                         (gms1.award_number		= l_default_dist_award_number))
                         -- Bug 3221039 : To fetch based on Award Number and Award Id
		   AND decode(TXN.system_linkage,'OT','ST',txn.system_linkage) = curr_etype_class_code
	    FOR UPDATE OF TXN.transaction_status_code;

	    TrxRec		TrxRecs%ROWTYPE;

   BEGIN
 	v_doc_header_id		:= T_NUM_TAB();
	v_doc_dist_id	        := T_NUM_TAB();
	V_project_id	        := T_NUM_TAB();
	V_task_id		:= T_NUM_TAB();
	V_exp_org_id		:= T_NUM_TAB();
	V_quantity		:= T_NUM_TAB();
	V_unit_price		:= T_NUM_TAB();
	V_amount		:= T_NUM_TAB();
	V_burdened_cost		:= T_NUM_TAB();
	v_denom_raw_cost	:= T_NUM_TAB();
	v_denom_burdened_cost	:= T_NUM_TAB();
	v_acct_raw_cost		:= T_NUM_TAB();
	v_acct_burdened_cost	:= T_NUM_TAB();
	v_receipt_currency_amount := T_NUM_TAB() ;
	V_exp_type		  := T_varchar_tab() ;
	V_dist_status		  := T_varchar_tab() ;
	V_exp_item_date		  := T_DATE_TAB() ;
        V_creation_date		  := T_DATE_TAB() ;
	v_gl_date               := T_DATE_TAB() ;


	x_record_found		:= 0 ;
	l_project_id_last       := 0 ;
        l_task_id_last          := 0 ;

    	pa_cc_utils.set_curr_function('PRE_IMPORT');
	pa_cc_utils.log_message('Start Grants Accounting Pre Import for award Distributions.'||to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));

	-- Bug 3221039 : Modified the call to procedure from function
	--x_default_dist_award_id := get_dist_award_id(x_status) ;
	get_dist_award_id(x_default_dist_award_id,l_default_dist_award_number,x_status);

	--dbms_output.put_line('x_default_dist_award_id = '||to_char(x_default_dist_award_id)) ;

	-- =====================================================
	-- award distribution is not enabled so we don't need
	-- to continue further.
	-- =====================================================

	IF x_status is not NULL THEN
		pa_cc_utils.log_message('Award Distribution not enabled, pre-import Exit.');
      		pa_cc_utils.reset_curr_function;
		return ;
	END IF ;

	x_record_found		:= 0 ;

        open  c_trans_source ;
        fetch c_trans_source into l_emp_org_oride;
        close c_trans_source ;

	-- ===================================
	-- Fetch batch
	-- ===================================
    	FOR  eachGroup  IN  TrxBatches  LOOP

          	dummy := lockCntrlRec( 	eachGroup.transaction_source , eachGroup.batch_name
                           		, eachGroup.system_linkage_function );
      		IF ( dummy <> 0 ) THEN
			pa_cc_utils.log_message(eachGroup.batch_name||' : All records rejected because of :'||'LOCK_'||eachGroup.batch_name||'_FAILED');

             		UPDATE pa_transaction_interface
                	   SET transaction_rejection_code = 'LOCK_'||eachGroup.batch_name||'_FAILED'
             		       , transaction_status_code = 'PR'
       		 	 WHERE transaction_source 	= eachGroup.transaction_source
         	           AND  batch_name 		= eachGroup.batch_name
			   AND  transaction_status_code = 'P';

			pa_cc_utils.log_message(eachGroup.batch_name||' : Rejected Count :'||to_char(SQL%ROWCOUNT));

     		END IF ;
		-- =======End of LOCK CHECK ********


       		OPEN TrxRecs( eachGroup.transaction_source , eachGroup.batch_name , eachGroup.system_linkage_function  );

		pa_cc_utils.log_message('Fetch Records for :'||eachGroup.transaction_source||','||eachGroup.batch_name||','
					||eachGroup.system_linkage_function ) ;

		FIRST_RECORD	:= TRUE ;

		-- ======================================
		-- Truncate the table of data.
		-- ======================================
		count_rec	:= 0 ;

		-- =====================================
		-- Clear the tab buffer.
		-- =====================================
 	    	v_doc_header_id.DELETE ;
	    	v_doc_dist_id.DELETE ;
	    	v_gl_date.DELETE ;
	    	V_project_id.DELETE ;
	    	V_task_id.DELETE ;
	    	V_exp_org_id.DELETE ;
	    	V_quantity.DELETE ;
	    	V_unit_price.DELETE ;
	    	V_amount.DELETE ;
	    	V_exp_type.DELETE ;
	    	V_dist_status.DELETE ;
	    	V_exp_item_date.DELETE ;
	    	V_creation_date.DELETE ;

		V_burdened_cost.DELETE ;
		v_denom_raw_cost.DELETE ;
		v_denom_burdened_cost.DELETE ;
		v_acct_raw_cost.DELETE ;
		v_acct_burdened_cost.DELETE ;
		v_receipt_currency_amount.DELETE ;
		-- ===========End of BUF clearance **************

        	<<expenditures>>
        	LOOP
          		FETCH  TrxRecs  INTO  TrxRec;

			l_task_id        := TrxRec.task_id ;
			l_project_id     := TrxRec.project_id ;
			l_task_number    := TrxRec.task_number ;
			l_project_number := TrxRec.Project_number ;

          		IF ( TrxRecs%ROWCOUNT = 0 ) THEN
            			pa_cc_utils.log_message('Zero Records Fetched',1);
            			EXIT expenditures ;
          		ELSIF ( TrxRecs%NOTFOUND ) THEN
			    	pa_cc_utils.log_message('Last Record fetched',1);
            			EXIT expenditures ;
          		END IF;
	                --
	                -- bug : 3628820 perf issue in gmsawdeb.pls
	                -- FTS on pa_projects and pa_tasks table.
	                --
			IF l_project_number is NULL and l_project_id is NOT NULL THEN

		           IF l_project_id_last <> l_project_id  THEN
		              pa_cc_utils.log_message('GMS: Pre_import  open c_project_number.');
			      open c_project_number ;
			      fetch c_project_number into l_project_number ;
			      close c_project_number ;

			      l_project_id_last     := l_project_id ;
			      l_project_number_last := l_project_number ;

			      l_sponsored_flag := 'N' ;
			      open c_sponsored_flag ;
		  	      fetch c_sponsored_flag into l_sponsored_flag ;
			      close c_sponsored_flag ;

			      l_project_id_last := l_project_id ;

			   ELSE
			      l_project_number := l_project_number_last ;
			   END IF ;

			   TrxRec.Project_number := l_project_number ;
			END IF ;

	                --
	                -- bug : 3628820 perf issue in gmsawdeb.pls
	                -- FTS on pa_projects and pa_tasks table.
	                --
			IF l_project_number is not NULL and l_project_id is NULL THEN
			   IF l_project_number_last <> l_project_number OR
			      l_project_number_last is NULL THEN

		              pa_cc_utils.log_message('GMS: Pre_import  open c_project_id.');
			      open c_project_id ;
			      fetch c_project_id into l_project_id ;
			      close c_project_id ;

			      l_project_number_last := l_project_number ;
			      l_project_id_last     := l_project_id ;
			      -- bug 5169675
			      -- bug:5131439 TRANSACTION IMORT FAILED WITH PA_EXP_INV_PJTK FOR LEGITIMATE
			      -- TRANSACTIONS
			      -- last tasknumber and taskid not valid when project changed...
			      --
			      l_task_number_last    := NULL  ;
			      l_task_id_last        := NULL  ;
			      -- bug:5131439 end

			      l_sponsored_flag := 'N' ;
			      open c_sponsored_flag ;
		  	      fetch c_sponsored_flag into l_sponsored_flag ;
			      close c_sponsored_flag ;

			   ELSE
			     l_project_id := l_project_id_last ;
			   END IF ;

			   TrxRec.Project_id := l_project_id ;
			END IF ;

	                --
	                -- bug : 3628820 perf issue in gmsawdeb.pls
	                -- FTS on pa_projects and pa_tasks table.
	                --
			IF l_task_number is NULL and l_task_id is NOT NULL THEN
			   IF l_task_id_last <> l_task_id OR
                              l_task_id_last is NULL THEN

		              pa_cc_utils.log_message('GMS: Pre_import  open c_task_number.');
			      open c_task_number ;
			      fetch c_task_number into l_task_number ;
			      close c_task_number ;

			      l_task_number_last := l_task_number ;
			      l_task_id_last     := l_task_id     ;
			   ELSE
			      l_task_number      := l_task_number_last ;
			   END IF ;

			   TrxRec.task_number := l_task_number  ;
			END IF ;

	                --
	                -- bug : 3628820 perf issue in gmsawdeb.pls
	                -- FTS on pa_projects and pa_tasks table.
	                --
			IF l_task_number is not NULL and l_task_id is NULL THEN
			   IF l_task_number_last <> l_task_number OR
			      l_task_number_last is NULL THEN

		              pa_cc_utils.log_message('GMS: Pre_import  open c_task_id.');
			      open c_task_id ;
			      fetch c_task_id into l_task_id ;
			      close c_task_id ;
			      -- 5169675
			      -- bug:5131439 TRANSACTION IMORT FAILED WITH PA_EXP_INV_PJTK FOR LEGITIMATE
			      -- TRANSACTIONS
			      -- Task is Invalid...
			      IF l_task_id is not NULL THEN
			         l_task_id_last     := l_task_id ;
			         l_task_number_last := l_task_number ;
			      END IF ;

			   ELSE
			      l_task_id := l_task_id_last ;
			   END IF ;

			   TrxRec.task_id := l_task_id  ;
			END IF ;
			-- 5169675
                        -- bug:5131439 TRANSACTION IMORT FAILED WITH PA_EXP_INV_PJTK FOR LEGITIMATE
			-- TRANSACTIONS
			--
			x_status := NULL ;

			IF l_task_id is NULL THEN
			   X_status := 'INVALID_TASK' ;
			END IF ;
			-- bug:5131439 end...
			--
	                --
	                -- bug : 3628820 perf issue in gmsawdeb.pls
	                -- FTS on pa_projects and pa_tasks table.
	                --

			-- Following sql will be executed if both project id and project number
			-- are populated in the transaction interface table.
			--
			IF l_project_id_last <> l_project_id THEN
			   l_sponsored_flag := 'N' ;
			   open c_sponsored_flag ;
		  	   fetch c_sponsored_flag into l_sponsored_flag ;
			   close c_sponsored_flag ;

			   l_project_id_last     := l_project_id ;
			   l_project_number_last := l_project_number ;
			END IF ;

			-- 5169675
                        -- bug:5131439 TRANSACTION IMORT FAILED WITH PA_EXP_INV_PJTK FOR LEGITIMATE
			--x_status := NULL ;
			--

		        pa_cc_utils.log_message('GMS: Pre_import  l_project_id :'|| l_project_id);
		        pa_cc_utils.log_message('GMS: Pre_import  l_project_id_last :'|| l_project_id_last);
		        pa_cc_utils.log_message('GMS: Pre_import  l_project_number :'|| l_project_number);
		        pa_cc_utils.log_message('GMS: Pre_import  l_project_id_last :'|| l_project_number_last);

		        pa_cc_utils.log_message('GMS: Pre_import  l_task_id :'|| l_task_id);
		        pa_cc_utils.log_message('GMS: Pre_import  l_task_id_last :'|| l_task_id_last);
		        pa_cc_utils.log_message('GMS: Pre_import  l_task_number :'|| l_task_number);
		        pa_cc_utils.log_message('GMS: Pre_import  l_task_number_last :'|| l_task_number_last);
	                --
	                -- bug : 3628820 perf issue in gmsawdeb.pls
	                -- FTS on pa_projects and pa_tasks table.
	                --
			IF NVL(l_sponsored_flag,'N')  = 'N' THEN
			   X_status := 'GMS_NOT_A_SPONSORED_PROJECT' ;
			   x_org_status := x_status ;
			END IF ;

			IF X_status is NULL THEN
         		   pa_debug.G_err_stage := 'CAlling ValidateOrgId';

         		   pa_cc_utils.log_message(pa_debug.G_err_stage);

         		   PA_TRX_IMPORT.ValidateOrgId(TrxRec.org_id,X_org_status );
			END IF ;
			IF ( X_org_status IS NOT NULL ) THEN
     	  	 		-- Org id is null. Update status.
            			X_status := X_org_status;
         		ELSE
			   -- org id is not null. continue with other validations
         		   pa_debug.G_err_stage := 'CAlling ValidateItem';
         		   pa_cc_utils.log_message(pa_debug.G_err_stage);
	                   l_emporg_id := NULL ;
	                   l_empjob_id := NULL ;

	               IF NVL(l_emp_org_oride, 'N') = 'N' AND
	                  TrxRec.person_id is NOT NULL    THEN

	                  pa_utils.GetEmpOrgJobID( trxRec.person_id,
	                                           trxRec.expenditure_item_date,
					  l_emporg_id ,
					  l_empJob_id ) ;
	               END IF ;

         		   PA_TRX_IMPORT.ValidateItem(  P_transaction_source
                      		,  TrxRec.employee_number
                      		,  TrxRec.organization_name
                      		,  TrxRec.expenditure_ending_date
                      		,  TrxRec.expenditure_item_date
                      		,  TrxRec.expenditure_type
                      		,  TrxRec.project_number
                      		,  TrxRec.task_number
                      		,  TrxRec.non_labor_resource
                      		,  TrxRec.non_labor_resource_org_name
                      		,  TrxRec.quantity
                      		,  TrxRec.denom_raw_cost
                      		,  'PAXTRTRX'   --v_calling_module
                      		,  TrxRec.orig_transaction_reference
                      		,  TrxRec.unmatched_negative_txn_flag
                      		,  P_user_id
                      		,  TrxRec.attribute_category
                      		,  TrxRec.attribute1
                      		,  TrxRec.attribute2
                      		,  TrxRec.attribute3
                      		,  TrxRec.attribute4
                      		,  TrxRec.attribute5
                      		,  TrxRec.attribute6
                      		,  TrxRec.attribute7
                      		,  TrxRec.attribute8
                      		,  TrxRec.attribute9
                      		,  TrxRec.attribute10
                      		,  TrxRec.dr_code_combination_id
                      		,  TrxRec.cr_code_combination_id
                      		,  TrxRec.gl_date
                      		,  TrxRec.denom_burdened_cost
                      		,  TrxRec.system_linkage
                      		,  X_status
                      		,  X_billable_flag
	   	             	,  TrxRec.receipt_currency_amount
	   	             	,  TrxRec.receipt_currency_code
	   	             	,  TrxRec.receipt_exchange_rate
	   	             	,  TrxRec.denom_currency_code
	   	             	,  TrxRec.acct_rate_date
	   	             	,  TrxRec.acct_rate_type
	   	             	,  TrxRec.acct_exchange_rate
	   	             	,  TrxRec.acct_raw_cost
	   	             	,  TrxRec.acct_burdened_cost
	   	             	,  TrxRec.acct_exchange_rounding_limit
	   	             	,  TrxRec.project_currency_code
	   	             	,  TrxRec.project_rate_date
	   	             	,  TrxRec.project_rate_type
	   	             	,  TrxRec.project_exchange_rate
		               	,  TrxRec.raw_cost
		               	,  TrxRec.burdened_cost
                      	        ,  TrxRec.override_to_organization_name
                      	        ,  TrxRec.vendor_number
                      	        ,  TrxRec.org_id
                      	        ,  TrxRec.person_business_group_name
			       -- Bug 2464841 : Added parameters for 11.5 PA-J certification.
			        ,  TrxRec.projfunc_currency_code
			        ,  TrxRec.projfunc_cost_rate_type
			        ,  TrxRec.projfunc_cost_rate_date
			        ,  TrxRec.projfunc_cost_exchange_rate
			        ,  TrxRec.project_raw_cost
			        ,  TrxRec.project_burdened_cost
			        ,  TrxRec.assignment_name
			        ,  TrxRec.work_type_name
			        ,  TrxRec.accrual_flag
   		                ,  TrxRec.project_id
		                ,  TrxRec.Task_id
		                ,  TrxRec.person_id
		                ,  TrxRec.Organization_id
		                ,  TrxRec.non_labor_resource_org_id
		                ,  TrxRec.vendor_id
		                ,  TrxRec.override_to_organization_id
		                ,  TrxRec.person_business_group_id
		                ,  TrxRec.assignment_id
		                ,  TrxRec.work_type_id
		                ,  l_emporg_id
		                ,  l_empjob_id
		                ,  TrxRec.txn_interface_id
                                ,  TrxRec.po_number /* CWK */
                                ,  TrxRec.po_header_id
                                ,  TrxRec.po_line_num
                                ,  TrxRec.po_line_id
                                ,  TrxRec.person_type
                                ,  TrxRec.po_price_type
                             );

				 pa_cc_utils.reset_curr_function;

			END IF ;

           		IF ( X_status IS NOT NULL ) THEN

			     	pa_debug.G_err_stage := 'Updating txn interface table for txn'||
						     ' rejected by validateitem';
			     	pa_cc_utils.log_message(pa_debug.G_err_stage);

             			UPDATE pa_transaction_interface
                		   SET transaction_rejection_code = X_status ,
				       interface_id 		  = P_xface_id ,
				       transaction_status_code 	  = 'PR'
				 WHERE CURRENT OF TrxRecs;

				 pa_cc_utils.reset_curr_function;
			ELSE
			-- =================================================
			-- Identify the record for distribution.
			-- ================================================
				count_rec	:= count_rec + 1 ;
				v_doc_dist_id.extend ;
				v_gl_date.extend ;
				V_project_id.extend ;
				V_task_id.extend ;
				V_exp_org_id.extend ;
				V_quantity.extend ;
				V_amount.extend ;
				V_exp_type.extend ;
				V_dist_status.extend ;
				V_exp_item_date.extend ;
				v_receipt_currency_amount.extend ;

				V_burdened_cost.EXTEND ;
				v_denom_raw_cost.EXTEND ;
				v_denom_burdened_cost.EXTEND ;
				v_acct_raw_cost.EXTEND ;
				v_acct_burdened_cost.EXTEND ;

	    			x_org_id				:= pa_utils.getorgid(TrxRec.organization_name) ;
	    			x_override_to_org_id			:= pa_utils.getorgid(TrxRec.override_to_organization_name) ;
	    			x_incurred_by_org_id			:= NVL(x_override_to_org_id, x_org_id ) ;
				v_doc_dist_id(count_rec)		:= TrxRec.txn_interface_id ;
				v_gl_date(count_rec)                    := TrxRec.gl_date ;
				V_project_id(count_rec)			:= TrxRec.project_id ;
				V_task_id(count_rec)			:= TrxRec.task_id ;
				x_dummy					:= NVL(x_override_to_org_id, x_org_id ) ;

				-- ========================================================================
				-- BUG: 1963556 ( ORA-1400 WHEN RUNNING PAXTRTRX FOR AWARD RELATED LABOR
				--                TRANSACTIONS ).
				-- Expenditure_organization_id is not null column in gms_distributions.
				-- This is required only for funds Check. For expenditures we don't have
				-- Funds check and afford to have it ZERO.
				-- ========================================================================
				V_exp_org_id(count_rec)			:= NVL(x_dummy,0) ;
				V_quantity(count_rec)			:= TrxRec.quantity ;
				-- = =================================================================
				-- = BUG: 3228565
				-- = Transaction import process is erroring out in pre import step.
				-- = gms_distributions.amount column is not null. Null value in
				-- = TrxRec.raw_cost is raising a  ORA exception when inserting into
				-- = gms_distributions table.
				-- = Error is fixed by using NVL(TrxRec.raw_cost,0)
				-- = =================================================================
				V_amount(count_rec)					:= NVL(TrxRec.raw_cost ,0);
				V_exp_type(count_rec)					:= TrxRec.Expenditure_type ;
				V_dist_status(count_rec)				:= NULL ;
				V_exp_item_date(count_rec)				:= TrxRec.Expenditure_item_date ;
				V_burdened_cost(count_rec) 				:= TrxRec.burdened_cost;
				v_denom_raw_cost(count_rec) 				:= TrxRec.denom_raw_cost;
				v_denom_burdened_cost(count_rec) 			:= TrxRec.denom_burdened_cost;
				v_acct_raw_cost(count_rec) 				:= TrxRec.acct_raw_cost ;
				v_receipt_currency_amount(count_rec)			:= TrxRec.receipt_currency_amount ;

				v_acct_burdened_cost(count_rec) 			:= TrxRec.acct_burdened_cost;
				x_record_found						:= x_record_found + 1 ;

            		END IF ;
    		END LOOP expenditures;

		IF TrxRecs%ISOPEN THEN
		   CLOSE TrxRecs ;
		END IF ;

		-- ==================================================
		-- Insert Records into Distribution Table.
		-- PLSQL Bulk operation
		-- =================================================
		FORALL indx in 1..count_rec
			INSERT INTO gms_distributions ( document_header_id,
							document_distribution_id,
							document_type,
							gl_date,
							project_id,
							task_id,
							expenditure_type,
							expenditure_organization_id,
							expenditure_item_date,
							quantity,
							unit_price,
							amount,
							burdened_cost,
							denom_raw_cost,
							denom_burdened_cost,
							acct_raw_cost,
							receipt_currency_amount,
							acct_burdened_cost,
							dist_status,
							creation_date
						      )
				             VALUES   ( P_xface_id,
							v_doc_dist_id(indx),
							'EXP',
							nvl(v_gl_date(indx),SYSDATE),
							v_project_id(indx),
							v_task_id(indx),
							v_exp_type(indx),
							v_exp_org_id(indx),
							v_exp_item_date(indx),
							v_quantity(indx),
							1,
							v_amount(indx),
							v_burdened_cost(indx),
							v_denom_raw_cost(indx),
							v_denom_burdened_cost(indx),
							v_acct_raw_cost(indx),
							v_receipt_currency_amount(indx),
							v_acct_burdened_cost(indx),
							v_dist_status(indx),
							SYSDATE
	          			 	      ) ;
	END LOOP ;

	pa_cc_utils.log_message('Insert record into gms_distributions :'||to_char(count_rec));
	-- =====================================
	-- There is nothing to distribute.
	-- =====================================
	IF x_record_found = 0 THEN
	   pa_cc_utils.reset_curr_function;
	   pa_cc_utils.log_message('Nothing found for distributions -PRE_IMPORT EXIT');
	   return ;
	END IF ;
	-- =================================================
	-- Distribute records using FAB engine.
	-- =================================================
	pa_cc_utils.log_message('Start gms_award_dist_eng.proc_distribute_records '||to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));

	gms_award_dist_eng.proc_distribute_records(p_xface_id,
						   'EXP',
						   x_accepted,
						   x_rejected ) ;
	pa_cc_utils.log_message('End gms_award_dist_eng.proc_distribute_records '||to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
	-- ==================================================
	-- Update 1st distribution into IMPORT tables.
	-- ==================================================
        --  3466152
        --  import process award distributions doesn't work when batch name is not supplied.
	--  removed batch name criteria . Its not needed since txn_interface_id is available.
	--
	-- Bug 3221039 : Modified the below code to distribute based on default Award id/
	-- Award number and to populate both award id and award number .

	update gms_transaction_interface_all  A
	   set (a.award_id,a.award_number) = ( select B.award_id,GA.award_number -- Bug 3221039
			      from gms_distribution_details B,
			           gms_awards_all  GA
			     where a.txn_interface_id = b.document_distribution_id
			       and B.document_header_id = P_xface_id
			       and B.distribution_number= 1
			       and B.document_type	= 'EXP'
			       and GA.award_id = B.award_id)
	 where --A.transaction_source 	= P_transaction_source -- Bug 3221039 : obsolete column
	   --and A.batch_name		= p_batch
              ( (award_number IS NULL AND nvl(award_id,0)= x_default_dist_award_id )
	          OR
                 (award_number		= l_default_dist_award_number)) -- Bug 3221039
	   and A.txn_interface_id in ( select C.document_distribution_id
					 from gms_distribution_details	C
					where C.document_header_id = P_xface_id
					  and C.distribution_number= 1
					  and C.document_type      = 'EXP' );

	pa_cc_utils.log_message('Update award_id in gms_transaction_interface_all count :'||to_char(SQL%ROWCOUNT));

        --  3466152
        --  import process award distributions doesn't work when batch name is not supplied.
	--  removed batch name criteria . Its not needed since txn_interface_id is available.
	--
	update PA_transaction_interface_all  A
	   set ( quantity, raw_cost, burdened_cost, denom_raw_cost, denom_burdened_cost, acct_raw_cost, acct_burdened_cost, receipt_currency_amount ) =
			  ( select B.quantity_distributed,
			 	   B.amount_distributed,
				   B.burdened_cost,
				   B.denom_raw_cost,
				   B.denom_burdened_cost,
				   B.acct_raw_cost,
				   B.acct_burdened_cost,
				   B.receipt_currency_amount
			      from gms_distribution_details B
			     where a.txn_interface_id = b.document_distribution_id
			       and B.document_header_id = P_xface_id
			       and B.distribution_number= 1
			       and B.document_type	= 'EXP' )
	 where A.transaction_source 	= P_transaction_source
	   --and A.batch_name		= p_batch
	   and A.txn_interface_id IN ( 	SELECT C.document_distribution_id
					  from gms_distribution_details C
					 WHERE C.document_header_id = P_xface_id
					   and C.distribution_number= 1
					   and C.document_type      = 'EXP' );

	  pa_cc_utils.log_message('Update ( quantity, raw_cost ) in pa_transaction_interface_all count :'||
				   to_char(SQL%ROWCOUNT));
        --  3466152
        --  import process award distributions doesn't work when batch name is not supplied.
	--  removed batch name criteria . Its not needed since txn_interface_id is available.
	--

        --  3466152
        --  import process award distributions doesn't work when batch name is not supplied.
	--  removed batch name criteria . Its not needed since txn_interface_id is available.
	--
          UPDATE pa_transaction_interface A
             SET transaction_rejection_code = 'AWARD_DISTRIBUTION_FAILED' ,
		 interface_id 		    = P_xface_id ,
		 transaction_status_code    = 'PR'
	   WHERE A.transaction_source     = P_transaction_source
	     --AND A.batch_name             = p_batch
	     AND A.TXN_INTERFACE_ID IN ( SELECT B.document_distribution_id
					   FROM GMS_DISTRIBUTIONS B
					  WHERE B.document_header_id = P_Xface_id
					    and B.document_type      = 'EXP'
					    and NVL(B.dist_status,'X') <> 'FABA' ) ;

	  pa_cc_utils.log_message('Update distribution recject in pa_transaction_interface_all count :'||to_char(SQL%ROWCOUNT));
	-- ===================================================================
	-- Insert distributed records into PA_transaction_interface_all and
	-- gms_transaction_interface_all. Update the count in
	-- pa_transaction_xface_ctrl_all
	-- ==================================================================
	PROC_INSERT_TRANS( P_transaction_source,
                           p_batch             ,
                           p_user_id           ,
                           p_xface_id          ) ;
	pa_cc_utils.log_message('END Grants Accounting Pre Import for award Distributions.'||to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
	pa_cc_utils.reset_curr_function;
   EXCEPTION
	When OTHERS THEN

		IF TrxRecs%Isopen THEN
		   Close TrxRecs ;
		END IF ;

		pa_cc_utils.log_message('ERROR Grants Accounting Pre Import for award Distributions.'||to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
		pa_cc_utils.log_message('PLSQL ERROR Occured :'||SQLERRM);
		pa_cc_utils.reset_curr_function;
		ROLLBACK ;
        	raise_application_error( -20000, SQLERRM ) ;
		RAISE ;
   END PRE_IMPORT ;


END GMS_AWARD_DIST_ENG ;

/
