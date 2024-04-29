--------------------------------------------------------
--  DDL for Package Body GMS_REPORT_SF269
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_REPORT_SF269" AS
--$Header: gmsgrflb.pls 120.0 2005/05/29 11:46:11 appldev noship $
Procedure Populate_269_History(RETCODE OUT NOCOPY VARCHAR2,
                               ERRBUF  OUT NOCOPY VARCHAR2,
                               x_award_id IN NUMBER,
			       x_report_start_date IN DATE,
			       x_report_end_date   IN DATE
                               ) IS

 l_expenditure_item_id1         pa_cost_distribution_lines_all.expenditure_item_id%type;
 l_line_num1                    pa_cost_distribution_lines_all.line_num%type;

-- Cursor to Get the the total_outlay from raw cost and burdened cost of expenditure item
-- The cursor is split into two for performance reasons
-- BUG 4005793  : FPM Perf. fixes.       |
--
cursor total_outlay_raw IS
	Select nvl(c.amount,0) raw_cost,
               c.expenditure_item_id ,
	       c.line_num
	from   pa_expenditure_items ei,
	       pa_cost_distribution_lines_all c,
               gms_award_distributions g
	where g.expenditure_item_id = c.expenditure_item_id
          and g.cdl_line_num        = c.line_num
	  and c.gl_date  between      X_Report_Start_Date
	                     and      X_Report_End_Date
	  and c.expenditure_item_id = ei.expenditure_item_id
	  and g.award_id            = X_Award_Id
	  and g.document_type       = 'EXP'  -- BUG 4005793  : FPM Perf. fixes.
	  and g.adl_status          = 'A'    -- BUG 4005793  : FPM Perf. fixes.
	  and c.line_type           = 'R'
	  and nvl(ei.system_linkage_function,'XXX') <> 'BTC'
	  --- BUG 4005793  : FPM Perf. fixes.
	  and ei.project_id in ( select gbv.project_id
	                           from gms_budget_versions gbv
			          where gbv.budget_type_code     = 'AC'
				    and gbv.budget_status_code   in ('S','W' )
				    and gbv.award_id             = X_award_id );

--	and c.transfer_status_code    in ('A','V') -- Bug Fix 2701130
	-- and c.reversed_flag is NULL  Bug Fix 2831665.
	-- and c.line_num_reversed is NULL  Bug Fix 2831665.

	--Added the report_direct_flag to fix the bug 924274.
cursor total_outlay_burden IS
	Select
		sum(nvl(bv.burden_cost,0)) burden_cost,
		 gcd.report_direct_flag report_direct_flag
	from    gms_awards a,
		GMS_CDL_BURDEN_DETAIL_V bv,
		pa_ind_cost_codes cd,
                gms_ind_cost_codes gcd,
                gms_allowable_expenditures ae
	where
	     bv.expenditure_item_id          = l_expenditure_item_id1
	    and bv.line_num                  = l_line_num1
            and a.award_id                   = x_award_id
	    and bv.ind_cost_code             = cd.ind_cost_code
            and ae.allowability_schedule_id  = a.allowable_schedule_id
            and bv.ei_expenditure_type       = ae.expenditure_type
            and nvl(ae.mtdc_exempt_flag,'N') = 'N'
            and cd.ind_cost_code             = gcd.ind_cost_code(+)   -- Added outerjoin to fix bug 2651959
	group by
		 bv.expenditure_item_id
		,bv.line_num,
		gcd.report_direct_flag;


 l_award_id                    gms_269_history.award_id%type;
 l_version                     gms_269_history.version%type;
 l_status_code                 gms_269_history.status_code%type;
 l_report_code                 gms_269_history.report_code%type;
 l_creation_date               gms_269_history.creation_date%type;
 l_created_by                  gms_269_history.created_by%type;
 l_last_update_date            gms_269_history.last_update_date%type;
 l_last_updated_by             gms_269_history.last_updated_by%type;
 l_last_update_login           gms_269_history.last_update_login%type;
 l_end_date                    gms_269_history.end_date%type;
 l_document_number             gms_269_history.document_number%type;
 l_accounting_basis            gms_269_history.accounting_basis%type;
 l_funding_start_date          gms_269_history.funding_start_date%type;
 l_funding_end_date            gms_269_history.funding_end_date%type;
 l_report_period_start_date    gms_269_history.report_period_start_date%type;
 l_report_period_end_date      gms_269_history.report_period_end_date%type;
 l_total_outlay                gms_269_history.total_outlay%type;
 l_cum_total_outlay            gms_269_history.cum_total_outlay%type;
 l_refund_rebate               gms_269_history.refund_rebate%type;
 l_cum_refund_rebate           gms_269_history.cum_refund_rebate%type;
 l_program_income              gms_269_history.program_income%type;
 l_cum_program_income          gms_269_history.cum_program_income%type;
 l_contribution                gms_269_history.contribution%type;
 l_cum_contribution            gms_269_history.cum_contribution%type;
 l_other_fed_award             gms_269_history.other_fed_award%type;
 l_cum_other_fed_award         gms_269_history.cum_other_fed_award%type;
 l_prog_income_match           gms_269_history.prog_income_match%type;
 l_cum_prog_income_match       gms_269_history.cum_prog_income_match%type;
 l_other_rec_outlay            gms_269_history.other_rec_outlay%type;
 l_cum_other_rec_outlay        gms_269_history.cum_other_rec_outlay%type;
 l_total_rec_outlay            gms_269_history.total_rec_outlay%type;
 l_cum_total_rec_outlay        gms_269_history.cum_total_rec_outlay%type;
 l_cum_unliquid_obligation     gms_269_history.cum_unliquid_obligation%type;
 l_cum_recipient_obligation    gms_269_history.cum_recipient_obligation%type;
 l_cum_period_federal_fund     gms_269_history.cum_period_federal_fund%type;
 l_cum_program_income_addition gms_269_history.cum_program_income_addition%type;
 l_cum_program_income_unused   gms_269_history.cum_program_income_unused%type;
 l_rate_type                   gms_269_history.rate_type%type;
 l_indirect_cost_rate          gms_269_history.indirect_cost_rate%type;
 l_allowed_cost_base_burden    gms_269_history.allowed_cost_base%type;
 l_allowed_cost_base           gms_269_history.allowed_cost_base%type;
 l_federal_idc_share           gms_269_history.federal_idc_share%type;
 l_remarks                     gms_269_history.remarks%type;

 x_version number;
cursor prev_rec IS
 select nvl(cum_total_outlay,0)       cum_total_outlay,
        nvl(cum_refund_rebate,0)      cum_refund_rebate,
        nvl(cum_program_income,0)     cum_program_income,
        nvl(cum_contribution,0)       cum_contribution,
        nvl(cum_other_fed_award,0)    cum_other_fed_award,
        nvl(cum_prog_income_match,0)  cum_prog_income_match,
        nvl(cum_other_rec_outlay,0)   cum_other_rec_outlay,
        nvl(cum_total_rec_outlay,0)   cum_total_rec_outlay
 from gms_269_history
 where  award_id = X_Award_Id
 and    version  = x_version
 and    status_code = 'F';

 l_prev_269      prev_rec%rowtype;

-- Added for bug 2357578
-- Cursor to fetch Report periods
CURSOR report_period_date_cur IS
SELECT GREATEST(x_report_start_date, start_date_active),
       LEAST(x_report_end_date, end_date_active)
FROM gms_awards
WHERE award_id = x_award_id;

-- Added for bug 2357578
-- Cursor to fetch Funding periods based on award
CURSOR funding_period_date_cur IS
SELECT start_date_active,
       end_date_active
FROM gms_awards
WHERE award_id = x_award_id;

 l_set_of_books_id       number;
 l_expenditure_item_id   NUMBER := NULL;
 l_line_num	         NUMBER := NULL;
 l_transfer_status_code  VARCHAR2(1) := NULL;
 l_raw_cost         	 NUMBER(22,5) := 0;
 l_sum_burden_cost       NUMBER(22,5) := 0;
 l_total_program_outlays NUMBER(22,5) := 0;
 l_err_code              VARCHAR2(1);
 l_err_buff              VARCHAR2(2000);

 Procedure insert_269_hisrory is
  Begin
    insert into gms_269_history   (
	 award_id ,
	 version   ,
         status_code,
         report_status,
	 report_code ,
         creation_date,
         created_by    ,
	 last_update_date ,
	 last_updated_by ,
	 last_update_login,
	 end_date         ,
	 document_number   ,
	 accounting_basis   ,
	 funding_start_date  ,
	 funding_end_date    ,
	 report_period_start_date  ,
	 report_period_end_date   ,
	 total_outlay             ,
	 cum_total_outlay          ,
	 refund_rebate             ,
	 cum_refund_rebate         ,
	 program_income            ,
	 cum_program_income        ,
	 contribution              ,
	 cum_contribution          ,
	 other_fed_award           ,
	 cum_other_fed_award       ,
	 prog_income_match         ,
	 cum_prog_income_match     ,
	 other_rec_outlay          ,
	 cum_other_rec_outlay      ,
	 total_rec_outlay          ,
	 cum_total_rec_outlay      ,
	 cum_unliquid_obligation   ,
	 cum_recipient_obligation  ,
	 cum_period_federal_fund   ,
	 cum_program_income_addition,
	 cum_program_income_unused ,
	 rate_type                 ,
	 indirect_cost_rate        ,
	 allowed_cost_base         ,
	 federal_idc_share         ,
	 remarks
)
Values
(
	 l_award_id ,
	 l_version   ,
         l_status_code,
         l_status_code,
	 l_report_code ,
         l_creation_date,
         l_created_by    ,
	 l_last_update_date ,
	 l_last_updated_by ,
	 l_last_update_login,
	 l_end_date         ,
	 l_document_number   ,
	 l_accounting_basis   ,
	 l_funding_start_date  ,
	 l_funding_end_date    ,
	 l_report_period_start_date  ,
	 l_report_period_end_date   ,
	 l_total_outlay             ,
	 l_cum_total_outlay          ,
	 l_refund_rebate             ,
	 l_cum_refund_rebate         ,
	 l_program_income            ,
	 l_cum_program_income        ,
	 l_contribution              ,
	 l_cum_contribution          ,
	 l_other_fed_award           ,
	 l_cum_other_fed_award       ,
	 l_prog_income_match         ,
	 l_cum_prog_income_match     ,
	 l_other_rec_outlay          ,
	 l_cum_other_rec_outlay      ,
	 l_total_rec_outlay          ,
	 l_cum_total_rec_outlay      ,
	 l_cum_unliquid_obligation   ,
	 l_cum_recipient_obligation  ,
	 l_cum_period_federal_fund   ,
	 l_cum_program_income_addition,
	 l_cum_program_income_unused ,
	 l_rate_type                 ,
	 l_indirect_cost_rate        ,
	 l_allowed_cost_base         ,
	 l_federal_idc_share         ,
	 l_remarks
        );
   Exception
      When others then
       raise;
   End insert_269_hisrory;


Begin
     -- Initialize amount variable
   l_total_outlay  		:= 0;
   l_cum_total_outlay   	:= 0;
   l_refund_rebate      	:= 0;
   l_cum_refund_rebate          := 0;
   l_program_income             := 0;
   l_cum_program_income         := 0;
   l_contribution               := 0;
   l_cum_contribution           := 0;
   l_other_fed_award            := 0;
   l_cum_other_fed_award        := 0;
   l_prog_income_match          := 0;
   l_cum_prog_income_match      := 0;
   l_other_rec_outlay           := 0;
   l_cum_other_rec_outlay       := 0;
   l_total_rec_outlay           := 0;
   l_cum_total_rec_outlay       := 0;
   l_cum_unliquid_obligation    := 0;
   l_cum_recipient_obligation   := 0;
   l_cum_period_federal_fund    := 0;
   l_cum_program_income_addition:= 0;
   l_cum_program_income_unused  := 0;
   l_indirect_cost_rate         := 0;
   l_allowed_cost_base          := 0;
   l_federal_idc_share          := 0;


     --1. Get the last version number

     Begin
       select nvl(max(version),0)
       into   x_version
       from   gms_269_history
       where  award_id = X_Award_Id
       and    status_code = 'O';
     End;

    -- 2. Get document number(Funding Source Award Number) from gms_awards

    Begin
       select funding_source_award_number
       into   l_document_number
       from   GMS_AWARDS
       where  award_id = X_Award_Id;
      EXCEPTION
       WHEN NO_DATA_FOUND THEN
           NULL;
    End;

    --3. Get the cumulative totals from previous report

    Begin
       open prev_rec;
       fetch prev_rec into l_prev_269;
       If prev_rec%notfound then
          l_prev_269.cum_total_outlay      := 0;
          l_prev_269.cum_refund_rebate     := 0;
          l_prev_269.cum_program_income    := 0;
          l_prev_269.cum_contribution      := 0;
          l_prev_269.cum_other_fed_award   := 0;
          l_prev_269.cum_prog_income_match := 0;
          l_prev_269.cum_other_rec_outlay  := 0;
          l_prev_269.cum_total_rec_outlay  := 0;
       End If;
       close prev_rec;
    End;

    --4. Get total outlays for this report

          -- Set current_project_id to NULL to use GMS_CDL_BURDEN_DETAIL_V
          -- for burden costs of all projects

    -- gms_burden_costing.set_current_project_id (NULL);
      -- the above line has been commented out for bug 2442827
    -- Fixed the bug 924274.
  Begin
    For Exp_item_rec in total_outlay_raw LOOP
       l_expenditure_item_id1:= Exp_item_rec.expenditure_item_id;
       l_line_num1 :=  Exp_item_rec.line_num;
       l_total_outlay := l_total_outlay + exp_item_rec.raw_cost;
       l_allowed_cost_base := l_allowed_cost_base + exp_item_rec.raw_cost;
      For Exp_item_rec_1 in total_outlay_burden LOOP
            l_total_outlay := l_total_outlay + exp_item_rec_1.burden_cost;
         If exp_item_rec_1.report_direct_flag ='Y' THEN
             l_allowed_cost_base:= l_allowed_cost_base + exp_item_rec_1.burden_cost;
         Else
              l_federal_idc_share:= l_federal_idc_share + exp_item_rec_1.burden_cost; -- bug 2651959
         End If;
      End  loop ;

    End  loop;
     EXCEPTION
        When no_data_found then
           l_allowed_cost_base := 0;
  End;


    --5. Get the commitments
    DECLARE
        x_period_start_date   DATE ;  -- Bug 2660430
        x_period_end_date     DATE ;  -- Bug 2660430

        CURSOR  c_period_dates IS     -- Bug 2660430, Added
        SELECT  start_date, end_date
          FROM  gl_period_statuses
         WHERE  period_name = (SELECT pa_accum_utils.Get_current_gl_period FROM DUAL)
	   AND  adjustment_period_flag = 'N'
           AND  application_id = 101
           AND  set_of_books_id = l_set_of_books_id ;

	CURSOR  c_burdened_cost IS
        SELECT  sum(burdened_cost)
	  FROM  (SELECT sum(nvl(GB.encumb_period_to_date,0) * decode(balance_type, 'PO', 1, 'AP' , 1, 'ENC' , 1, 0)) burdened_cost
                   FROM GMS_BALANCES GB, GMS_BUDGET_VERSIONS GBV
                  WHERE gb.award_id = x_award_id
                    AND GBV.award_id = GB.award_id
		    AND GBV.budget_version_id = gb.budget_version_id
		    AND GBV.current_flag in ('Y','R')
 		    AND GBV.budget_status_code = 'B'
                  GROUP BY GB.award_id
                 UNION ALL
                 SELECT sum((nvl(gbc.entered_dr,0)- nvl(gbc.entered_cr,0)) * decode(gbc.document_type,'PO',1,'AP',1,'ENC',1,0)) burdened_cost
                   FROM gms_bc_packets gbc, GMS_BUDGET_VERSIONS GBV
		  WHERE gbv.budget_version_id = gbc.budget_version_id
                    AND gbc.status_code = 'A'
                    AND GBV.budget_status_code = 'B'
                    AND GBV.current_flag in ('Y', 'R')
                    AND gbc.award_id = x_award_id
                  GROUP BY GBC.award_id) ;

    Begin
     select set_of_books_id
     into   l_set_of_books_id
     from   pa_implementations;

/*     Select  sum(nvl(acct_burdened_cost,0)) burdened_cost
           --sum(nvl(tot_cmt_burdened_cost,0)) burdened_cost -- 11i changes
     into   l_cum_unliquid_obligation
     from   pa_commitment_txns_v cmt,
            gl_period_statuses    gps
     where  cmt.gl_period = gps.period_name
     and    cmt.original_txn_reference1 = to_char(X_Award_Id)
     and    gps.adjustment_period_flag = 'N'
     and    gps.application_id = 101
     and    gps.set_of_books_id = l_set_of_books_id
     and    gps.start_date >= X_Report_Start_Date
     and    gps.end_date   <= X_Report_End_Date; */

     -- Bug 2660430, Start of code
     OPEN  c_period_dates ;
     FETCH c_period_dates INTO x_period_start_date, x_period_end_date ;
     IF SQL%FOUND THEN
       IF  x_period_start_date >= X_Report_Start_Date
       AND x_period_end_date <= X_Report_End_Date THEN
	   OPEN   c_burdened_cost ;
	   FETCH  c_burdened_cost INTO l_cum_unliquid_obligation ;
	   CLOSE  c_burdened_cost ;
       END IF ;
     END IF ;
     CLOSE  c_period_dates ;
     -- Bug 2660430, End of code

     EXCEPTION
        When no_data_found then
           null;
    End;


    --6. Get the base  amount MTDC

   /* Begin
	Select
		sum(nvl(bv.burden_cost,0)) burden_cost
        into    l_allowed_cost_base_burden
	from	gms_allowable_expenditures ae,
                gms_awards a,
		GMS_CDL_BURDEN_DETAIL_V bv,
        gms_award_distributions g,
		pa_cost_distribution_lines_all c,
		pa_expenditure_items ei
  where g.expenditure_item_id = c.expenditure_item_id
    and g.cdl_line_num        = c.line_num
     and c.transfer_status_code      in ('A','V')
	and c.gl_date  between X_Report_Start_Date and  X_Report_End_Date
	and c.expenditure_item_id       = ei.expenditure_item_id
    and g.award_id               = X_Award_Id
	and c.reversed_flag is NULL
	and c.line_num_reversed is NULL
	and c.line_type = 'R'
	and nvl(ei.system_linkage_function,'XXX') <> 'BTC'
	and bv.expenditure_item_id = g.expenditure_item_id
	and bv.line_num = g.cdl_line_num --change from g.adl_line_num to fix bug 2651959
        and a.award_id    = X_Award_Id
        and ae.allowability_schedule_id = a.allowable_schedule_id
        and ae.expenditure_type  = ei.expenditure_type
        and nvl(ae.mtdc_exempt_flag,'N') = 'N';

     EXCEPTION
        When no_data_found then
           l_allowed_cost_base_burden := 0;
    End; */ -- commented out to fix bug 2651959

    --7. Get the period federal fund
      select sum(nvl(direct_cost,0)) + sum(nvl(indirect_cost,0))
      into   l_cum_period_federal_fund
      from   gms_installments
      where  award_id = X_award_id
      and    (X_report_start_date between start_date_active and end_date_active
              or X_report_End_date between start_date_active and end_date_active );
    --8. Get the funding period from installments
     -- Bug 2357578 : Modified the below code to fetch funding periods
     --               from award instead from Installments.

     -- Commented for bug 2357578
    /*  select min(start_date_active), max(end_date_active)
      into   l_funding_start_date,
             l_funding_end_date
      from   gms_installments
      where  award_id = X_award_id; */

     -- Added for bug 2357578
     OPEN  funding_period_date_cur;
     FETCH funding_period_date_cur INTO
     l_funding_start_date,l_funding_end_date;
     CLOSE funding_period_date_cur;

    --8. Calculate cumulative totals for this report

          l_award_id := X_Award_id;
          l_version  := x_version + 1;
          l_report_code := 'SF269';
          l_creation_date      := trunc(sysdate);
          l_created_by         := fnd_global.user_id;
          l_last_update_date   := trunc(sysdate);
          l_last_updated_by    := fnd_global.user_id;
          l_last_update_login  := fnd_global.login_id;
          l_end_date   := trunc(sysdate);
          l_accounting_basis   := 'A'; -- accruel

          -- Bug 2357578 : Modified the code to fetch report dates based
          -- Award start and end dates.
          --  l_report_period_start_date   := X_report_start_date;
          --  l_report_period_end_date   := X_report_end_date;
          OPEN  report_period_date_cur;
          FETCH report_period_date_cur INTO l_report_period_start_date,
          l_report_period_end_date;
          CLOSE report_period_date_cur;

          l_cum_total_outlay := nvl(l_total_outlay,0) +
                                         nvl(l_prev_269.cum_total_outlay,0);

          l_cum_refund_rebate := nvl(l_refund_rebate,0) +
                                         nvl(l_prev_269.cum_refund_rebate,0);

          l_cum_program_income := nvl(l_program_income,0) +
                                          nvl(l_prev_269.cum_program_income,0);

          l_cum_contribution  := nvl(l_contribution,0) +
                                         nvl(l_prev_269.cum_contribution,0);
          l_cum_other_fed_award  := nvl(l_other_fed_award ,0) +
                                             nvl(l_prev_269.cum_other_fed_award,0 );


          l_cum_prog_income_match  := nvl(l_prog_income_match ,0) +
                                              nvl(l_prev_269.cum_prog_income_match,0 );

          l_cum_other_rec_outlay  := nvl(l_other_rec_outlay ,0) +
                                             nvl(l_prev_269.cum_other_rec_outlay,0 );

          l_total_rec_outlay      := l_contribution +
                                              l_other_fed_award +
                                              l_prog_income_match +
                                              l_other_rec_outlay;

          l_cum_total_rec_outlay   := l_cum_contribution +
                                              l_cum_other_fed_award +
                                              l_cum_prog_income_match +
                                              l_cum_other_rec_outlay;

          l_rate_type               := 'PROVISIONAL';
          If ( l_allowed_cost_base <> 0 ) then
               --l_indirect_cost_rate      := l_allowed_cost_base_burden  / l_allowed_cost_base; bug 2651959
              l_indirect_cost_rate      := l_federal_idc_share  / l_allowed_cost_base;

          End if;
          --l_federal_idc_share := l_allowed_cost_base * l_indirect_cost_rate; bug 2651959

    --9. Create 2 history records, one original and one draft.
          l_status_code := 'O';

          insert_269_hisrory;

          l_status_code := 'D';

          insert_269_hisrory;
End Populate_269_History;
End GMS_REPORT_SF269;


/
