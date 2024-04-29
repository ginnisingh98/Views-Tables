--------------------------------------------------------
--  DDL for Package Body GMS_REPORT_SF425
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_REPORT_SF425" AS
--$Header: gmsffrcb.pls 120.1.12010000.6 2009/10/13 21:17:01 rmunjulu noship $



   Procedure Populate_425_History(
                               p_award_id          IN NUMBER,
			                   p_report_end_date   IN DATE
                               ) IS

    CURSOR last_version_csr (p_award_id IN NUMBER) IS
	   select nvl(max(version),0)
       from   gms_425_history
       where  award_id = p_award_id
       and    status_code IN ('F');

	CURSOR last_version_details_csr (p_version_number IN NUMBER, p_award_id IN NUMBER) IS
	   select
	       REPORT_TRN_ID                       REPORT_TRN_ID,
	       nvl(report_type_code,'QUARTERLY')   REPORT_TYPE_CODE,
		   REPORT_END_DATE                     REPORT_END_DATE,
		   nvl(BASIS_OF_ACCNT_CODE,'A')        BASIS_OF_ACCNT_CODE,
	       nvl(CASH_RECEIPTS_AMT,0)            CASH_RECEIPTS_AMT,
           nvl(CASH_DISBURSEMENTS_AMT,0)       CASH_DISBURSEMENTS_AMT,
           nvl(TOTAL_FED_FUNDS_AUTH_AMT,0)     TOTAL_FED_FUNDS_AUTH_AMT,
           nvl(FED_SHARE_OF_EXP_AMT,0)         FED_SHARE_OF_EXP_AMT,
           nvl(FED_SHARE_OF_UNLIQ_OBL_AMT,0)   FED_SHARE_OF_UNLIQ_OBL_AMT,
           nvl(TOTAL_RECPT_SHARE_REQ_AMT,0)    TOTAL_RECPT_SHARE_REQ_AMT,
           nvl(RECPT_SHARE_EXP_AMT,0)          RECPT_SHARE_EXP_AMT,
           nvl(TOTAL_FED_PRG_INC_EARN_AMT,0)   TOTAL_FED_PRG_INC_EARN_AMT,
           nvl(PRG_INC_EXP_DEDUCT_ALT_AMT,0)   PRG_INC_EXP_DEDUCT_ALT_AMT,
		   nvl(PRG_INC_EXP_ADD_ALT_AMT,0)      PRG_INC_EXP_ADD_ALT_AMT
       from   gms_425_history
       where  award_id = p_award_id
       and    status_code IN ('F')
	   and    version = p_version_number;

	CURSOR award_details_csr (p_award_id IN NUMBER) IS
	    select
		     end_date_active , -- Check with SHweta if this is correct
			 start_date_active
		from GMS_AWARDS
		where award_id = p_award_id;

    CURSOR c_sum_amount (
	                       p_award_id           IN NUMBER,
	                       p_report_start_date  IN DATE,
						   p_report_end_date    IN DATE) IS
         Select SUM(nvl(c.amount,0))
          from pa_expenditure_items_all ei,
               pa_cost_distribution_lines_all c,
               gms_award_distributions g
         where c.gl_date  between p_report_start_date and  p_report_end_date
           and c.expenditure_item_id       = ei.expenditure_item_id
           and g.award_id                  = p_award_id
           and g.document_type             = 'EXP'
           and g.adl_line_num              = 1
           and g.adl_status                = 'A'
           and g.expenditure_item_id       = c.expenditure_item_id
           and c.line_type                 = 'R'
           and ei.system_linkage_function <> 'BTC'  -- Put the correct code for system linkage function
           and ei.project_id               in ( select gbv.project_id
                                                from gms_budget_versions gbv
			                        	        where gbv.budget_type_code     = 'AC'
					                              and gbv.budget_status_code   in ('S','W' )
					                              and gbv.award_id             = p_award_id );

    CURSOR c_sum_burden      (
	                          p_award_id           IN NUMBER,
	                          p_report_start_date  IN DATE,
						      p_report_end_date    IN DATE) IS
         Select sum(nvl(bv.burden_cost,0))
           FROM    gms_cdl_burden_detail_v        bv,
	               gms_budget_versions gbv
           WHERE bv.gl_date  between p_report_start_date and  p_report_end_date
             and bv.award_id                 = p_award_id
             and bv.line_type                 = 'R'
             and bv.system_linkage_function <> 'BTC'  -- Put the correct code for system linkage function
             and gbv.budget_type_code     = 'AC'
             and gbv.budget_status_code   in ('S','W' )
             and gbv.award_id             = p_award_id
             and bv.project_id            =  gbv.project_id;

    CURSOR total_outlay_raw ( p_award_id           IN NUMBER,
	                          p_report_start_date  IN DATE,
						      p_report_end_date    IN DATE) IS
	Select
	    nvl(c.amount,0) raw_cost,
        c.expenditure_item_id,
	    c.line_num
	from   pa_expenditure_items ei,
	       pa_cost_distribution_lines_all c,
           gms_award_distributions g
	where g.expenditure_item_id = c.expenditure_item_id
      and g.cdl_line_num        = c.line_num
	  and c.gl_date  between      p_report_start_date  and  p_report_end_date
	  and c.expenditure_item_id = ei.expenditure_item_id
	  and g.award_id            = p_award_id
	  and g.document_type       = 'EXP'
	  and g.adl_status          = 'A'
	  and c.line_type           = 'R'
	  and nvl(ei.system_linkage_function,'XXX') <> 'BTC'
	  and ei.project_id in ( select gbv.project_id
	                           from gms_budget_versions gbv
			                  where gbv.budget_type_code     = 'AC'
				                and gbv.budget_status_code   in ('S','W' )
				                and gbv.award_id             = p_award_id );


    CURSOR total_outlay_burden ( p_award_id             IN NUMBER,
	                             p_expenditure_item_id  IN NUMBER,
						         p_line_num             IN NUMBER) IS
	Select
	  	sum(nvl(bv.burden_cost,0)) burden_cost,
		gcd.report_direct_flag report_direct_flag
	from
        gms_awards a,
		GMS_CDL_BURDEN_DETAIL_V bv,
		pa_ind_cost_codes cd,
        gms_ind_cost_codes gcd,
        gms_allowable_expenditures ae
	where
	    bv.expenditure_item_id           = p_expenditure_item_id
	    and bv.line_num                  = p_line_num
        and a.award_id                   = p_award_id
	    and bv.ind_cost_code             = cd.ind_cost_code
        and ae.allowability_schedule_id  = a.allowable_schedule_id
        and bv.ei_expenditure_type       = ae.expenditure_type
        and nvl(ae.mtdc_exempt_flag,'N') = 'N'
        and cd.ind_cost_code             = gcd.ind_cost_code(+)
	group by
		 bv.expenditure_item_id
		,bv.line_num
		,gcd.report_direct_flag;

    -- Get the Federal Unobligated Commitments
	CURSOR  c_burdened_cost ( p_award_id           IN NUMBER,
	                          p_report_start_date  IN DATE,
						      p_report_end_date    IN DATE) IS
      SELECT sum(burdened_cost)
	  FROM  (SELECT sum(nvl(GB.encumb_period_to_date,0) * decode(balance_type, 'PO', 1, 'AP' , 1, 'ENC' , 1, 0)) burdened_cost
               FROM GMS_BALANCES GB, GMS_BUDGET_VERSIONS GBV
              WHERE gb.award_id = p_award_id
                AND GBV.award_id = GB.award_id
		        AND GBV.budget_version_id = gb.budget_version_id
		        AND GBV.current_flag in ('Y','R')
 		        AND GBV.budget_status_code = 'B'
				AND trunc(gb.start_date) <= trunc(p_report_end_date) -- added to get the cumulative commitments
             GROUP BY GB.award_id
             UNION ALL
             SELECT sum((nvl(gbc.entered_dr,0)- nvl(gbc.entered_cr,0)) * decode(gbc.document_type,'PO',1,'AP',1,'ENC',1,0)) burdened_cost
               FROM gms_bc_packets gbc, GMS_BUDGET_VERSIONS GBV
		      WHERE gbv.budget_version_id = gbc.budget_version_id
                AND gbc.status_code = 'A'
                AND GBV.budget_status_code = 'B'
                AND GBV.current_flag in ('Y', 'R')
                AND gbc.award_id = p_award_id
				AND trunc(gbc.expenditure_item_date) <= trunc(p_report_end_date) -- added to get additional commitments
             GROUP BY GBC.award_id) ;

    l_status_code                 gms_425_history.status_code%type;
	l_creation_date               gms_425_history.creation_date%type;
	l_created_by                  gms_425_history.created_by%type;
	l_last_update_date            gms_425_history.last_update_date%type;
	l_last_updated_by             gms_425_history.last_updated_by%type;
	l_last_update_login           gms_425_history.last_update_login%type;
	l_REPORT_TRN_ID               gms_425_history.REPORT_TRN_ID%type;
	l_BASIS_OF_ACCNT_CODE         gms_425_history.BASIS_OF_ACCNT_CODE%type;
	l_REPORT_TYPE_CODE            gms_425_history.REPORT_TYPE_CODE%type;
	l_CASH_RECEIPTS_AMT           gms_425_history.CASH_RECEIPTS_AMT%type;
	l_CASH_DISBURSEMENTS_AMT      gms_425_history.CASH_DISBURSEMENTS_AMT%type;
	l_TOTAL_FED_FUNDS_AUTH_AMT    gms_425_history.TOTAL_FED_FUNDS_AUTH_AMT%type;
	l_FED_SHARE_OF_EXP_AMT        gms_425_history.FED_SHARE_OF_EXP_AMT%type;
	l_FED_SHARE_OF_UNLIQ_OBL_AMT  gms_425_history.FED_SHARE_OF_UNLIQ_OBL_AMT%type;
	l_TOTAL_RECPT_SHARE_REQ_AMT   gms_425_history.TOTAL_RECPT_SHARE_REQ_AMT%type;
	l_RECPT_SHARE_EXP_AMT         gms_425_history.RECPT_SHARE_EXP_AMT%type;
	l_TOTAL_FED_PRG_INC_EARN_AMT  gms_425_history.TOTAL_FED_PRG_INC_EARN_AMT%type;
	l_PRG_INC_EXP_DEDUCT_ALT_AMT  gms_425_history.PRG_INC_EXP_DEDUCT_ALT_AMT%type;
	l_PRG_INC_EXP_ADD_ALT_AMT     gms_425_history.PRG_INC_EXP_ADD_ALT_AMT%type;
	l_REMARKS                     gms_425_history.REMARKS%type;
	l_NAME                        gms_425_history.NAME%type;
	l_TELEPHONE                   gms_425_history.TELEPHONE%type;
	l_EMAIL                       gms_425_history.EMAIL%type;
	l_REPORT_SUBMIT_DATE          gms_425_history.REPORT_SUBMIT_DATE%type;

	l_EXPENSE_TRN_ID              gms_425_expense.EXPENSE_TRN_ID%type;
	l_INDIRECT_EXP_TYPE_CODE      gms_425_expense.INDIRECT_EXP_TYPE_CODE%type;
	l_INDIRECT_EXP_RATE           gms_425_expense.INDIRECT_EXP_RATE%type;
	l_INDIRECT_EXP_PERIOD_FROM    gms_425_expense.INDIRECT_EXP_PERIOD_FROM%type;
	l_INDIRECT_EXP_PERIOD_TO      gms_425_expense.INDIRECT_EXP_PERIOD_TO%type;
	l_INDIRECT_EXP_BASE_AMT       gms_425_expense.INDIRECT_EXP_BASE_AMT%type;
	l_INDIRECT_EXP_FED_SHARE_AMT  gms_425_expense.INDIRECT_EXP_FED_SHARE_AMT%type;

	last_version_details_rec      last_version_details_csr%ROWTYPE;
	l_last_version                NUMBER;
	l_current_version             NUMBER;
	l_award_end_date              DATE;
	l_award_start_date            DATE;
	l_last_report_trn_id          NUMBER;
	l_period_start_date           DATE;
	l_Sum_Raw_Cost                NUMBER;
	l_Sum_Burden_Cost             NUMBER;
	l_expenditure_item_id         NUMBER;
    l_line_num                    NUMBER;
	l_burden_cost                 NUMBER;
	l_run_date                    DATE;


  Procedure insert_425_history (p_status_code IN gms_425_history.status_code%type) is
  Begin

	-- set the transaction id
    select gms_425_history_report_id_s.nextval
    into   l_report_trn_id
    from dual;

    insert into gms_425_history   (
	 REPORT_TRN_ID,
	 award_id,
	 version,
     status_code,
     creation_date,
     created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 run_date,
	 report_start_date,
	 grant_period_from_date,
	 grant_period_to_date,
     BASIS_OF_ACCNT_CODE,
	 REPORT_TYPE_CODE,
	 REPORT_END_DATE,
	 CASH_RECEIPTS_AMT,
	 CASH_DISBURSEMENTS_AMT,
	 TOTAL_FED_FUNDS_AUTH_AMT,
	 FED_SHARE_OF_EXP_AMT,
	 FED_SHARE_OF_UNLIQ_OBL_AMT,
	 TOTAL_RECPT_SHARE_REQ_AMT,
	 RECPT_SHARE_EXP_AMT,
	 TOTAL_FED_PRG_INC_EARN_AMT,
	 PRG_INC_EXP_DEDUCT_ALT_AMT,
	 PRG_INC_EXP_ADD_ALT_AMT,
	 REMARKS,
	 NAME,
	 TELEPHONE,
	 EMAIL,
	 REPORT_SUBMIT_DATE
    )
    Values
    (
	 l_REPORT_TRN_ID,
	 p_award_id,
	 l_current_version,
     p_status_code,
     l_creation_date,
     l_created_by,
	 l_last_update_date,
	 l_last_updated_by,
	 l_last_update_login,
	 l_run_date,
	 l_period_start_date,
	 l_award_start_date,
	 l_award_end_date,
	 l_BASIS_OF_ACCNT_CODE,
	 l_REPORT_TYPE_CODE,
	 p_REPORT_END_DATE,
	 l_CASH_RECEIPTS_AMT,
	 l_CASH_DISBURSEMENTS_AMT,
	 l_TOTAL_FED_FUNDS_AUTH_AMT,
	 l_FED_SHARE_OF_EXP_AMT,
	 l_FED_SHARE_OF_UNLIQ_OBL_AMT,
	 l_TOTAL_RECPT_SHARE_REQ_AMT,
	 l_RECPT_SHARE_EXP_AMT,
	 l_TOTAL_FED_PRG_INC_EARN_AMT,
	 l_PRG_INC_EXP_DEDUCT_ALT_AMT,
	 l_PRG_INC_EXP_ADD_ALT_AMT,
	 l_REMARKS,
	 l_NAME,
	 l_TELEPHONE,
	 l_EMAIL,
	 l_REPORT_SUBMIT_DATE
    );

    commit; -- added to commit the transaction for bug 8965790
  Exception
      When others then
       raise;
  End insert_425_history;

   -- create as many records as last versions expenses
  Procedure insert_425_expense (p_last_report_trn_id    IN NUMBER) IS

    -- Get last versions details
    CURSOR get_last_version_expenses_csr (p_last_report_trn_id IN NUMBER) IS
       SELECT
	         INDIRECT_EXP_TYPE_CODE,
             INDIRECT_EXP_RATE,
             INDIRECT_EXP_PERIOD_FROM,
	         INDIRECT_EXP_PERIOD_TO,
             INDIRECT_EXP_BASE_AMT,
             INDIRECT_EXP_FED_SHARE_AMT
       FROM
             GMS_425_EXPENSE exp
       WHERE
             exp.report_trn_id = p_last_report_trn_id;
  Begin

    -- loop through the previous versions expenses and insert same values again
    FOR get_last_version_expenses_rec IN get_last_version_expenses_csr (p_last_report_trn_id) LOOP

	   -- set the transaction id
       select gms_425_expenses_id_s.nextval
       into   l_EXPENSE_TRN_ID
       from dual;

       insert into gms_425_expense   (
	    EXPENSE_TRN_ID,
	    REPORT_TRN_ID,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		last_update_login,
		INDIRECT_EXP_TYPE_CODE,
		INDIRECT_EXP_RATE,
		INDIRECT_EXP_PERIOD_FROM,
		INDIRECT_EXP_PERIOD_TO,
		INDIRECT_EXP_BASE_AMT,
		INDIRECT_EXP_FED_SHARE_AMT
       )
       Values
       (
		l_EXPENSE_TRN_ID,
		l_REPORT_TRN_ID,
		l_creation_date,
		l_created_by    ,
		l_last_update_date ,
		l_last_updated_by ,
		l_last_update_login,
		get_last_version_expenses_rec.INDIRECT_EXP_TYPE_CODE,
		get_last_version_expenses_rec.INDIRECT_EXP_RATE,
		get_last_version_expenses_rec.INDIRECT_EXP_PERIOD_FROM,
		get_last_version_expenses_rec.INDIRECT_EXP_PERIOD_TO,
		get_last_version_expenses_rec.INDIRECT_EXP_BASE_AMT,
		get_last_version_expenses_rec.INDIRECT_EXP_FED_SHARE_AMT
       );

       commit ; -- added to commit the transaction fix for bug 8965790
	END LOOP;
   Exception
      When others then
       raise;
   End insert_425_expense;

   Begin

     --1. Basic defaults

	 -- for gms_425_history
     l_creation_date         := trunc(sysdate);
     l_created_by            := fnd_global.user_id;
     l_last_update_date      := trunc(sysdate);
     l_last_updated_by       := fnd_global.user_id;
     l_last_update_login     := fnd_global.login_id;
	 l_run_date              := trunc(sysdate);

     l_REMARKS               := null;
     l_NAME                  := null;
     l_TELEPHONE             := null;
     l_EMAIL                 := null;
     l_REPORT_SUBMIT_DATE    := null;

	 l_REPORT_TYPE_CODE            := 'QUARTERLY';
     l_BASIS_OF_ACCNT_CODE         := 'A'; -- accrual
     l_last_report_trn_id		   := -1;

     l_CASH_RECEIPTS_AMT           := 0;
     l_CASH_DISBURSEMENTS_AMT      := 0;
     l_TOTAL_FED_FUNDS_AUTH_AMT    := 0;
     l_FED_SHARE_OF_EXP_AMT        := 0;
     l_FED_SHARE_OF_UNLIQ_OBL_AMT  := 0;
     l_TOTAL_RECPT_SHARE_REQ_AMT   := 0;
     l_RECPT_SHARE_EXP_AMT         := 0;
     l_TOTAL_FED_PRG_INC_EARN_AMT  := 0;
     l_PRG_INC_EXP_DEDUCT_ALT_AMT  := 0;
     l_PRG_INC_EXP_ADD_ALT_AMT     := 0;

	 -- Get award details
	 OPEN award_details_csr (p_award_id);
	 FETCH award_details_csr INTO l_award_end_date, l_award_start_date;
	 CLOSE award_details_csr;

	 l_period_start_date          := trunc(l_award_start_date);

     --2. Get last version and details and set current version and amounts and details

	 OPEN last_version_csr (p_award_id);
	 FETCH last_version_csr INTO l_last_version;
	 CLOSE last_version_csr;

	 -- override defaults if last version exists
	 IF l_last_version > 0 THEN -- earlier version exist

	    OPEN last_version_details_csr (l_last_version, p_award_id);
	    FETCH last_version_details_csr INTO last_version_details_rec;
	    CLOSE last_version_details_csr;

		l_REPORT_TYPE_CODE            := last_version_details_rec.report_type_code;

        l_BASIS_OF_ACCNT_CODE         := last_version_details_rec.BASIS_OF_ACCNT_CODE;

        l_last_report_trn_id		  := last_version_details_rec.REPORT_TRN_ID;

		l_period_start_date           := trunc(last_version_details_rec.REPORT_END_DATE) + 1;

		-- set previous reports amounts as all of these are cumulative values
        l_CASH_RECEIPTS_AMT           := last_version_details_rec.CASH_RECEIPTS_AMT;
        l_CASH_DISBURSEMENTS_AMT      := last_version_details_rec.CASH_DISBURSEMENTS_AMT;
        l_TOTAL_FED_FUNDS_AUTH_AMT    := last_version_details_rec.TOTAL_FED_FUNDS_AUTH_AMT;
        l_FED_SHARE_OF_EXP_AMT        := last_version_details_rec.FED_SHARE_OF_EXP_AMT;
        l_FED_SHARE_OF_UNLIQ_OBL_AMT  := last_version_details_rec.FED_SHARE_OF_UNLIQ_OBL_AMT;
        l_TOTAL_RECPT_SHARE_REQ_AMT   := last_version_details_rec.TOTAL_RECPT_SHARE_REQ_AMT;
        l_RECPT_SHARE_EXP_AMT         := last_version_details_rec.RECPT_SHARE_EXP_AMT;
        l_TOTAL_FED_PRG_INC_EARN_AMT  := last_version_details_rec.TOTAL_FED_PRG_INC_EARN_AMT;
        l_PRG_INC_EXP_DEDUCT_ALT_AMT  := last_version_details_rec.PRG_INC_EXP_DEDUCT_ALT_AMT;
        l_PRG_INC_EXP_ADD_ALT_AMT     := last_version_details_rec.PRG_INC_EXP_ADD_ALT_AMT;

	 END IF;

	 l_current_version   := l_last_version + 1;

     -- Override Report Type Code If Report End Date is Award End Date then use FINAL as REPORT TYPE CODE
	 IF trunc(p_report_end_date) >= trunc(l_award_end_date) THEN

       l_REPORT_TYPE_CODE := 'FINAL';

	 END IF;

     --3. Add current period value to Cash Disbursements (code from SF272)

	 -- get current period raw cost
     open c_sum_amount (p_award_id, l_period_start_date, p_report_end_date);
     fetch c_sum_amount into l_Sum_Raw_Cost ;
     close c_sum_amount ;

	 -- get current period burden cost
     open c_sum_burden (p_award_id, l_period_start_date, p_report_end_date);
     fetch c_sum_burden into l_Sum_Burden_Cost ;
     close c_sum_burden ;

	 -- Add current period raw cost and current period burden cost to cumulative cash disbursements
     l_CASH_DISBURSEMENTS_AMT  :=  l_CASH_DISBURSEMENTS_AMT + (NVL(l_Sum_Raw_Cost,0) + NVL(l_Sum_Burden_Cost,0)) ;

	 --4. Add current period value to Federal Share of expenditures (code from SF269)

	 -- loop through raw costs for current period
     For Exp_item_rec in total_outlay_raw (p_award_id, l_period_start_date, p_report_end_date) LOOP

        l_expenditure_item_id := Exp_item_rec.expenditure_item_id;

	    l_line_num :=  Exp_item_rec.line_num;

	    -- Add current period raw cost to cumulative fed share of expenditure amount
        l_FED_SHARE_OF_EXP_AMT := l_FED_SHARE_OF_EXP_AMT + exp_item_rec.raw_cost;

		-- loop through burden costs for raw cost
        For Exp_item_rec_1 in total_outlay_burden (p_award_id, l_expenditure_item_id, l_line_num) LOOP

	       -- Add current period burden cost to cumulative fed share of expenditure amount
           l_FED_SHARE_OF_EXP_AMT := l_FED_SHARE_OF_EXP_AMT + exp_item_rec_1.burden_cost;

	    End  loop ;
	 End Loop;

	 --5. Fetch total Federal Share of unliquidated obligations  (code from SF269)

     OPEN   c_burdened_cost (p_award_id, l_period_start_date, p_report_end_date);
	 FETCH  c_burdened_cost INTO l_burden_cost ;
	 CLOSE  c_burdened_cost ;

	 l_FED_SHARE_OF_UNLIQ_OBL_AMT := nvl(l_burden_cost,0); -- Rmunjulu Added nvl to get a zero value instead of null

     --6. Create 2 records, one original and one draft in  425_history.
	     -- Carry forward last versions indirect expenses and create same records for both Original and Draft versions status in 425_expense

     l_status_code       := 'O';

     insert_425_history (l_status_code);

	 -- create expenses based on last versions expenses
	 IF l_last_report_trn_id <> -1 THEN

	    insert_425_expense (l_last_report_trn_id);

	 END IF;

     l_status_code       := 'D';

     insert_425_history(l_status_code);

	 -- create expenses based on last versions expenses
	 IF l_last_report_trn_id <> -1 THEN

        insert_425_expense (l_last_report_trn_id);

	 END IF;

   End Populate_425_History;
End GMS_REPORT_SF425;


/
