--------------------------------------------------------
--  DDL for Package Body XTR_ACCRUAL_PROCESS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_ACCRUAL_PROCESS_P" as
/* $Header: xtracclb.pls 120.33 2006/12/19 12:23:35 kbabu ship $ */
--------------------------------------------------------------------------------------------
/********************************************************************************************/
/*This procedure calculate NI effective interest. user inputs:                              */
/* p_face_value    : the face value of transaction                                          */
/* p_all_in_rate   : XTR_ROLLOVER_TRANSACTIONS.all_in_rate column                           */
/* p_deal_date     : call from the accrual process - deal.start_date                        */
/*                   call from the resale form - buy start date                             */
/* p_start_date    : call from the accrual process - nvl(ni_reneg_date, batch_end_date)     */
/*                   call from the resale form - sell start date                            */
/* p_maturity_date : deal.maturity_date                                                     */
/* p_adjust        : indicator to know if we need to make day adjustment.                   */
/*                   If p_start_date is a ni_reneg date, then pass 'N', else pass 'Y'       */
/* p_year_calc_type: xtr_deals.year_calc_type                                               */
/* p_calc_basis    : XTR_DEALS.calc_basis, if 'DISCOUNT', pass 'D', if 'YIELD', pass 'Y'    */
/* p_pre_disc_end  : the previous Discount amount.                                          */
/*                   For Reval, it's the value from xtr_revaluation_details.ni_disc_amount  */
/*                   from previous batch.                                                   */
/*                   For Accrual, it's the value from xtr_accrls_amort.accrls_amount_bal    */
/*                   from previous batch                                                    */
/* p_day_count_type: Added for JPY Interest Override Project.  'B'-Both, 'L'-Last, 'F'-1st. */
/* p_resale_both_flag : Added for bug 2448432.  Denotes if procedure is being called as a   */
/*                      result of a resale in which the day count type of the resale = Both.*/
/*                      In such a case, the BUY deal will lose a day's worth of interest    */
/*                      to the SELL deal and the no_of_days from resale start to maturity   */
/*                      will need to be increased by 1 to obtain the correct unamortized    */
/*                      interest amount.                                                    */
/*                      Additional stipulation: 0 <= no_of_days <= l_deal_no_of_days        */
/*                                                                                          */
/* The output will be:                                                                      */
/* p_no_of_days    : the no of days in this accrual period                                  */
/* p_year_basis    : the year basis returns from CALC_DAYS_RUN                              */
/* p_disc_amount   : the current discount amount                                            */
/* p_eff_interest  : the effective interest                                                 */
/********************************************************************************************/


PROCEDURE CALCULATE_EFFECTIVE_INTEREST(
				       p_face_value       IN  NUMBER,
                                       p_all_in_rate      IN  NUMBER,
				       p_deal_date        IN  DATE,
                                       p_start_date       IN  DATE,
                                       p_maturity_date    IN  DATE,
				       p_adjust           IN  VARCHAR2,
                                       p_year_calc_type   IN  VARCHAR2,
				       p_calc_basis       IN  VARCHAR2,
				       p_pre_disc_end     IN  NUMBER,
                                       p_no_of_days       OUT NOCOPY  NUMBER,
				       p_year_basis       OUT NOCOPY  NUMBER,
				       p_disc_amount      OUT NOCOPY  NUMBER,
                                       p_eff_interest     OUT NOCOPY  NUMBER,
                                       p_day_count_type   IN VARCHAR2,
                                       p_resale_both_flag IN VARCHAR2,
                                       p_status_code      IN VARCHAR2) IS

  /*-----------------------------------------------------*/
  /* Get param for Arrears(FOLLOWING) or Forward (PRIOR).*/
  /*-----------------------------------------------------*/
   cursor ADJUST(p_param_name varchar2) is
   select PARAM_VALUE
   from   XTR_PRO_PARAM
   where  PARAM_NAME = p_param_name;

   l_start_disc  NUMBER;
   l_start_date  DATE;
   l_end_disc    NUMBER;
   l_days_adjust VARCHAR2(50);
   l_deal_no_of_days   NUMBER;

Begin

   l_start_date := p_start_date;


   -- AW Japan Project
   l_days_adjust := p_day_count_type;

   /*-----------------*/
   /* Forward (PRIOR) */
   /*-----------------*/
   -- AW Japan Project
   If nvl(l_days_adjust,'FOLLOWING') in ('PRIOR','B') and l_start_date <> p_maturity_date and
      p_adjust = 'Y' then

      If l_days_adjust = 'PRIOR' then
         XTR_CALC_P.calc_days_run(p_deal_date,
                                  p_maturity_date,
                                  p_year_calc_type,
                                  l_deal_no_of_days,
                                  p_year_basis,
                                  null,              -- AW Japan Project
                                  p_day_count_type,  -- AW Japan Project
                                  null);             -- AW Japan Project

      -- AW Japan Project
      elsif l_days_adjust = 'B' then
         XTR_CALC_P.calc_days_run(p_deal_date,
                                  p_maturity_date,
                                  p_year_calc_type,
                                  l_deal_no_of_days,
                                  p_year_basis,
                                  null,
                                  p_day_count_type,
                                  'Y');
      end if;

      l_start_date := l_start_date + 1;
      if l_start_date <> p_maturity_date then
         if l_days_adjust = 'PRIOR' then         -- AW Japan Project
            XTR_CALC_P.calc_days_run(l_start_date,
                                     p_maturity_date,
                                     p_year_calc_type,
                                     p_no_of_days,
                                     p_year_basis,
                                     null,              -- AW Japan Project
                                     p_day_count_type,  -- AW Japan Project
                                     null);             -- AW Japan Project
         else
            -- AW Japan Project
            XTR_CALC_P.calc_days_run(l_start_date,
                                     p_maturity_date,
                                     p_year_calc_type,
                                     p_no_of_days,
                                     p_year_basis,
                                     null,
                                     p_day_count_type,
                                     'Y');
         end if;
         if p_no_of_days > l_deal_no_of_days then
	    p_no_of_days := l_deal_no_of_days;
         end if;
      else
         if l_days_adjust = 'PRIOR' then
            p_no_of_days := 0;
         else                                        -- AW Japan Project
            p_no_of_days := 1;                       -- AW Japan Project
         end if;
      end if;

   /*---------------------*/
   /* Arrears (FOLLOWING) */
   /*---------------------*/
   else

      XTR_CALC_P.calc_days_run(l_start_date,
                               p_maturity_date,
                               p_year_calc_type,
                               p_no_of_days,
                               p_year_basis,
                               null,              -- AW Japan Project
                               p_day_count_type,  -- AW Japan Project
                               null);             -- AW Japan Project

      -- Bug 2448432.
      -- If procedure being called as a result of a resale to obtain the unamortized discount,
      -- p_adjust would be passed in as 'N', bypassing the above "If" condition and behaving as
      -- if the accrual system parameter is being set as 'Arrears'.
      --
      -- If the day count type of the resale deal = 'Both', need to add an additional day to
      -- p_no_of_days because the seller must sacrafice a day of interest from the original
      -- deal to the buyer.  Of course, p_no_of_days cannot exceed the original deal's
      -- total number of days.

      If (nvl(p_resale_both_flag,'N') = 'Y') then

         XTR_CALC_P.calc_days_run(p_deal_date,
                                  p_maturity_date,
                                  p_year_calc_type,
                                  l_deal_no_of_days,
                                  p_year_basis,
                                  null,
                                  p_day_count_type,
                                  'Y');

         p_no_of_days := p_no_of_days + 1;
         p_no_of_days := least(p_no_of_days, l_deal_no_of_days);
      End If;

      -- End Bug 2448432.

   end if;


   /*----------------------------------------------*/
   /* Calculate the accrual amount for this period */
   /*----------------------------------------------*/

   -- bug 4969194
   /* If the status of the deal is closed and clacl basis is 'DISCOUNT' than formaula to be used for
       calculation of effective interest should be done using the 'simple interest' formula
       with rate as in the "BUY" deal */

   if  p_status_code = 'CLOSED' and (p_calc_basis = 'D' or p_calc_basis = 'DISCOUNT') then

          p_disc_amount :=  (nvl(p_face_value,0) * p_all_in_rate * p_no_of_days)/(p_year_basis * 100);

   else


      p_disc_amount := nvl(p_face_value,0) - nvl(p_face_value,0)/(1 + ((p_all_in_rate * p_no_of_days)/(p_year_basis * 100)));

  end if;

   /* AW 2184427  Always calculate using Yield formula.
      if p_calc_basis = 'D' then  -- DISCOUNT
         p_disc_amount := (nvl(p_face_value,0) * p_all_in_rate * p_no_of_days)/(p_year_basis * 100);
      else                        -- YIELD
         p_disc_amount := nvl(p_face_value,0) - nvl(p_face_value,0)/(1 + ((p_all_in_rate * p_no_of_days)/(p_year_basis * 100)));
      end if;
   */

   /*--------------------------------------------------------------*/
   /* Effective interest is the difference between two calculation */
   /*--------------------------------------------------------------*/

   p_eff_interest := nvl(p_pre_disc_end,0) - nvl(p_disc_amount,0);

End;
-----------------------------------------------------------------------------------------------------------------
PROCEDURE CALCULATE_BOND_AMORTISATION (p_company IN VARCHAR2,
				       p_batch_id IN NUMBER,
                                       p_start_date IN DATE,
                                       p_end_date IN DATE,
                                       p_deal_type IN VARCHAR2) is
--
 l_first_accrual_indic 		VARCHAR2(1);
 days_adjust 			NUMBER :=0;
 foreign_dom_ccy 		VARCHAR2(10);
 starting_date 			DATE;
 maturiting_date 		DATE;
 deal_next_coupon 		DATE;
 coupon_mat_date 		DATE;
 l_rev_exp        		VARCHAR2(3);
 l_deduct_coupon 		NUMBER;
 l_amount_to_accrue_amort 	NUMBER;
 trans_days       		NUMBER;
 calc_days        		NUMBER;
 l_round          		NUMBER;
 l_yr_basis       		NUMBER;
 l_rounding       		NUMBER;
 l_calc_basis     		VARCHAR2(10);
 l_ccy            		VARCHAR2(15);
 effective        		DATE;
 l_cross_ref      		NUMBER;
 l_hce_rate       		NUMBER := 1;
 l_interest_adj   		NUMBER := 0;
 l_dummy_num      		NUMBER := 0;
 l_bond_date              	DATE;
 annual_yield             	NUMBER;
 l_cum_tot_price          	NUMBER;
 l_vol_tot_price          	NUMBER;
 l_price                  	NUMBER;
 l_price_rounding         	NUMBER;
 l_yield_rounding         	NUMBER;
 l_bond_start_amt         	NUMBER;
 l_bond_maturity_amt      	NUMBER;
 l_bond_accrual_amort     	NUMBER;
 l_true_adjust            	NUMBER;
 l_exit                       	VARCHAR2(1);
 l_start_interest 		NUMBER;
 l_maturity_interest 		NUMBER;
 l_start_prem 			NUMBER;
 l_maturity_prem 		NUMBER;
 l_start_accrued_price 		NUMBER;
 l_maturity_accrued_price 	NUMBER;

 l_bond_issue			VARCHAR2(10);
 l_days_adjust 			VARCHAR2(50);
 l_deal_nos    			NUMBER;
 l_trans_nos   			NUMBER;
 l_amount_type 			VARCHAR2(7);
 l_accrls_amount_bal 		NUMBER;
 l_year_calc_type 		VARCHAR2(20);
 l_days_EOP			NUMBER;
 l_days_BOP			NUMBER;
 p_start_date_adj		DATE;
 p_end_date_adj			DATE;

 -- Get days adjustment for Accruals (ie ADD a day to end of period).
 cursor ADJUST(p_param_name varchar2) is
  select PARAM_VALUE
   from XTR_PRO_PARAM
   where PARAM_NAME = p_param_name;
--
 cursor RND_FAC is
  select m.ROUNDING_FACTOR
   from XTR_MASTER_CURRENCIES_V m
   where m.CURRENCY = l_ccy ;
 --
 cursor HCE is
  select s.HCE_RATE
   from XTR_MASTER_CURRENCIES s
   where s.CURRENCY = l_ccy;

---

 --
 cursor BONDS is
  select a.deal_no,1 trans_no,a.start_date,a.maturity_date,a.next_coupon_date,a.interest_rate,
         a.maturity_amount,a.coupon_action,a.bond_issue,a.currency,
         decode(nvl(a.frequency,0),0,1,a.frequency) frequency,
         a.coupon_rate,a.start_amount,a.status_code,a.bond_reneg_date,
         a.bond_sale_date,a.deal_subtype,a.product_type,a.portfolio_code,a.cparty_code,
         a.year_calc_type,capital_price,
         a.day_count_type, a.rounding_type,                        -- AW Japan Project
         decode(a.day_count_type,'B','Y','N')   first_trans_flag   -- AW Japan Project
   from XTR_DEALS a
   where a.deal_type = 'BOND'
   and a.company_code = p_company
   and a.deal_subtype IN ('BUY','ISSUE')
   and a.status_code <> 'CANCELLED'
   and a.start_date <= p_end_date
   and (a.maturity_date >= p_start_date
         or a.deal_no not in
             ( select b.deal_no
                from XTR_ACCRLS_AMORT b
                  where b.company_code=p_company
                    and b.deal_type = 'BOND'
                    and b.amount_type <> 'CPMADJ'))
   and a.maturity_date >= a.start_date;

 bond_det BONDS%ROWTYPE;
 --

 cursor BOND_COUPONS is
  select r.deal_number,r.cparty_code,r.interest,r.interest_hce,r.start_date,
            r.maturity_date,r.interest_rate,r.deal_subtype,r.product_type,r.transaction_number,
            r.portfolio_code,r.currency,
            nvl(d.day_count_type,'L')              day_count_type,    -- AW Japan Project
            nvl(d.rounding_type,'R')               rounding_type,     -- AW Japan Project
            decode(nvl(d.day_count_type,'L'),'B',decode(r.transaction_number,2,'Y','N'),
                                             'N')  first_trans_flag   -- AW Japan Project
   from  XTR_ROLLOVER_TRANSACTIONS r,
         XTR_DEALS  d
   where r.deal_type = 'BOND'
   and   r.deal_number = l_deal_nos
   and   r.status_code = 'CURRENT'
   and   r.maturity_date > maturiting_date
   and   d.deal_no     = r.deal_number                                  -- AW Japan Project
   and   d.deal_type   = 'BOND'
   order by r.maturity_date;

 bond_cpn BOND_COUPONS%ROWTYPE;

 cursor chk_first_accrual is
  select 'N'
     from XTR_ACCRLS_AMORT
    where deal_no=l_deal_nos
       and trans_no=l_trans_nos
       and deal_type ='BOND';

 cursor get_year_calc_type is
  select year_calc_type
   from xtr_bond_issues
    where bond_issue_code=l_bond_issue;

--

 cursor get_prv_value is
  select nvl(EFFECTIVE_CALCULATED_VALUE,0) accrls_value
   from XTR_ACCRLS_AMORT
   where deal_no=l_deal_nos
    and trans_no =l_trans_nos
    and deal_type = 'BOND'
    and amount_type=l_amount_type
    and period_to<p_end_date
    order by period_to desc;

 cursor get_prv_bal is
  select nvl(ACCRLS_AMOUNT_BAL,0) accrls_bal
   from XTR_ACCRLS_AMORT
   where deal_no=l_deal_nos
    and trans_no =l_trans_nos
    and deal_type = 'BOND'
    and amount_type=l_amount_type
    and period_to<p_end_date
    order by period_to desc;

 cursor get_coupon_prv_bal is
  select trans_no,nvl(ACCRLS_AMOUNT_BAL,0) accrls_bal
   from XTR_ACCRLS_AMORT
   where deal_no=l_deal_nos
    and amount_type=l_amount_type
    and deal_type='BOND'
    and action_code='POS'
    and period_to < p_end_date
    and (trans_no,period_to)
           in(select trans_no,max(period_to)
              from XTR_ACCRLS_AMORT
              where deal_no=l_deal_nos
              and amount_type=l_amount_type
              and action_code='POS'
              and period_to < p_end_date
              group by trans_no);

l_face_discount		NUMBER;
l_coupon_discount 	NUMBER;
l_this_coupon_disc 	NUMBER;
l_accr_interest		NUMBER;
l_no_of_days            NUMBER;

l_prv_effective_value	NUMBER;
l_action                VARCHAR2(10);

--
begin
 l_first_accrual_indic := NULL;

 --
 l_days_adjust :=null;

 open ADJUST('ACCRUAL_DAYS_ADJUST');
  fetch ADJUST INTO l_days_adjust;
 close ADJUST;

 l_days_adjust :=nvl(l_days_adjust,'FOLLOWING');

 if l_days_adjust ='PRIOR' then
   bond_det.start_date :=bond_det.start_date -1;
 end if;

 ----------------------------------------------------------------------------------------------------------------------
 -- Do Bonds / Fixed Rate Securities using discounted Cflows
 --  Refer bug 929029
 open BONDS;
  LOOP
   fetch BONDS INTO bond_det;
  EXIT when BONDS%NOTFOUND;
   l_deal_nos :=bond_det.deal_no;
   l_trans_nos :=bond_det.trans_no;
   l_ccy :=bond_det.currency;
   l_amount_to_accrue_amort := 0;
   l_bond_accrual_amort := 0;

   if nvl(bond_det.coupon_rate,0)< bond_det.interest_rate then
      l_amount_type :='EFDISC';
   else
      l_amount_type :='EFPREM';
   end if;


   l_first_accrual_indic :='Y';
   open  CHK_FIRST_ACCRUAL;
   fetch CHK_FIRST_ACCRUAL into l_first_accrual_indic;
   close CHK_FIRST_ACCRUAL;


   open  RND_FAC;
   fetch RND_FAC into l_yield_rounding;
   close RND_FAC;

   l_yield_rounding := nvl(l_yield_rounding,2);

   if bond_det.maturity_date is NOT NULL and bond_det.maturity_amount is NOT NULL and
      bond_det.interest_rate is NOT NULL then
     l_bond_accrual_amort := 0;
     l_bond_issue :=bond_det.bond_issue;

     l_face_discount :=0;
     l_coupon_discount :=0;


    if bond_det.year_calc_type is null then
       open  get_year_calc_type;
       fetch get_year_calc_type into  l_year_calc_type;
       close get_year_calc_type;
    else
      l_year_calc_type := bond_det.year_calc_type;
    end if;

    if l_first_accrual_indic ='Y' then
        l_prv_effective_value := xtr_fps2_p.interest_round(bond_det.maturity_amount*bond_det.capital_price/100,
                                                           l_yield_rounding, bond_det.rounding_type);
    else

        l_prv_effective_value :=0;
        open  get_prv_value;
        fetch get_prv_value into l_prv_effective_value;
        close get_prv_value;
    end if;

    if (bond_det.start_date >= p_start_date
       and bond_det.bond_reneg_date is NULL) or
         l_first_accrual_indic ='Y' then
     starting_date := bond_det.start_date;
    else
     if nvl(bond_det.bond_reneg_date,p_start_date) > p_start_date then
      starting_date := bond_det.bond_reneg_date;
     else
      starting_date := p_start_date;
     end if;
    end if;

    if bond_det.status_code <> 'CURRENT' then
     -- If the Bond has Been Sold need to Check if the BOND_SALE_DATE
     -- is in this Period
       if nvl(bond_det.bond_sale_date,bond_det.maturity_date) < p_end_date then
        maturiting_date := nvl(bond_det.bond_sale_date,bond_det.maturity_date);
       else
        maturiting_date := p_end_date;
       end if;
    elsif bond_det.maturity_date > p_end_date then
       maturiting_date := p_end_date;
    else
       maturiting_date := bond_det.maturity_date;
    end if;

      if  bond_det.maturity_date > maturiting_date then
         XTR_CALC_P.CALC_DAYS_RUN(maturiting_date,
                                  bond_det.maturity_date,
                                  l_year_calc_type,
                                  calc_days,
                                  l_yr_basis,
                                  null,                         -- AW Japan Project
                                  bond_det.day_count_type,      -- AW Japan Project
                                  bond_det.first_trans_flag);   -- AW Japan Project
      else
         calc_days :=0;
         l_yr_basis :=365;
      end if;

         xtr_fps2_p.PRESENT_VALUE_COMPOUND(days_in_year      => l_yr_basis/bond_det.frequency,
                                 amount         => bond_det.maturity_amount,
                                 rate           => bond_det.interest_rate/bond_det.frequency,
                                 no_of_days     => calc_days,
                                 round_factor   => l_yield_rounding,
                                 present_value  => l_face_discount);
         l_coupon_discount :=0;
         l_accr_interest :=0;
         open  BOND_COUPONS;
         LOOP
         fetch BOND_COUPONS INTO bond_cpn;
         EXIT when BOND_COUPONS%NOTFOUND;

         if maturiting_date > bond_cpn.start_date and maturiting_date <= bond_cpn.maturity_date then
            XTR_CALC_P.CALC_DAYS_RUN(bond_cpn.start_date,
                                     bond_cpn.maturity_date,
                                     l_year_calc_type,
                                     l_no_of_days,
                                     l_yr_basis,
                                     null,                        -- AW Japan Project
                                     bond_cpn.day_count_type,     -- AW Japan Project
                                     bond_cpn.first_trans_flag);  -- AW Japan Project

            XTR_CALC_P.CALC_DAYS_RUN(bond_cpn.start_date,
                                     maturiting_date,
                                     l_year_calc_type,
                                     calc_days,
                                     l_yr_basis,
                                     null,                        -- AW Japan Project
                                     bond_cpn.day_count_type,     -- AW Japan Project
                                     bond_cpn.first_trans_flag);  -- AW Japan Project

            l_accr_interest := nvl(l_accr_interest,0) + xtr_fps2_p.interest_round(abs((bond_cpn.interest /
                                                        l_no_of_days) * calc_days),l_yield_rounding,
                                                        bond_cpn.rounding_type);

          end if;



          if bond_cpn.maturity_date > maturiting_date then
            XTR_CALC_P.CALC_DAYS_RUN(maturiting_date,
                                     bond_cpn.maturity_date,
                                     l_year_calc_type,
                                     calc_days,
                                     l_yr_basis,
                                     null,                        -- AW Japan Project
                                     bond_cpn.day_count_type,     -- AW Japan Project
                                     bond_cpn.first_trans_flag);  -- AW Japan Project
          else
              calc_days :=0;
              l_yr_basis :=365;
          end if;

            xtr_fps2_p.PRESENT_VALUE_COMPOUND(days_in_year      => l_yr_basis/bond_det.frequency,
                                 amount         => bond_cpn.interest,
                                 rate           => bond_det.interest_rate/bond_det.frequency,
                                 no_of_days     => calc_days,
                                 round_factor   => l_yield_rounding,
                                 present_value  => l_this_coupon_disc);

            l_coupon_discount :=nvl(l_coupon_discount,0)+nvl(l_this_coupon_disc,0);

         END LOOP;
         close BOND_COUPONS;
         l_amount_to_accrue_amort := nvl(l_prv_effective_value,0)-(nvl(l_coupon_discount,0)+nvl(l_face_discount,0)-nvl(l_accr_interest,0));

      if l_amount_to_accrue_amort>=0 then
         l_action :='POS';
      else
         l_action :='REV';
      end if;

      l_accrls_amount_bal :=0;
       open  get_prv_bal;
       fetch get_prv_bal into l_accrls_amount_bal;
       close get_prv_bal;

     if l_accrls_amount_bal <> 0 then
      insert into XTR_ACCRLS_AMORT
                (BATCH_ID,DEAL_NO,TRANS_NO,COMPANY_CODE,DEAL_SUBTYPE,
                 DEAL_TYPE,CURRENCY,PERIOD_FROM,PERIOD_TO,
                 CPARTY_CODE,PRODUCT_TYPE,PORTFOLIO_CODE,
                 INTEREST_RATE,TRANSACTION_AMOUNT,AMOUNT_TYPE,
                 ACCRLS_AMOUNT,YEAR_BASIS,
                 FIRST_ACCRUAL_INDIC,ACTUAL_START_DATE,ACTUAL_MATURITY_DATE,
                 NO_OF_DAYS,ACCRLS_AMOUNT_BAL,EFFECTIVE_CALCULATED_VALUE,ACTION_CODE)
          values(p_batch_id,bond_det.deal_no,1,p_company,bond_det.deal_subtype,
                 'BOND',bond_det.currency,p_start_date,p_end_date,
                 bond_det.cparty_code,bond_det.product_type,
                 bond_det.portfolio_code,bond_det.interest_rate,
                 bond_det.maturity_amount,l_amount_type,
                 abs(l_amount_to_accrue_amort),NULL,
                 l_first_accrual_indic,starting_date,maturiting_date,
                 NULL,l_amount_to_accrue_amort+nvl(l_accrls_amount_bal,0),
                 nvl(l_face_discount,0)+nvl(l_coupon_discount,0)-nvl(l_accr_interest,0),l_action);

       if bond_det.status_code <> 'CURRENT'
        and bond_det.bond_sale_date <=p_end_date then
           insert into XTR_ACCRLS_AMORT
                (BATCH_ID,DEAL_NO,TRANS_NO,COMPANY_CODE,DEAL_SUBTYPE,
                 DEAL_TYPE,CURRENCY,PERIOD_FROM,PERIOD_TO,
                 CPARTY_CODE,PRODUCT_TYPE,PORTFOLIO_CODE,
                 INTEREST_RATE,TRANSACTION_AMOUNT,AMOUNT_TYPE,
                 ACCRLS_AMOUNT,YEAR_BASIS,
                 FIRST_ACCRUAL_INDIC,ACTUAL_START_DATE,ACTUAL_MATURITY_DATE,
                 NO_OF_DAYS,ACCRLS_AMOUNT_BAL,ACTION_CODE)
           values(p_batch_id,bond_det.deal_no,1,p_company,bond_det.deal_subtype,
                 'BOND',bond_det.currency,p_start_date,p_end_date,
                 bond_det.cparty_code,bond_det.product_type,
                 bond_det.portfolio_code,bond_det.interest_rate,
                 bond_det.maturity_amount,l_amount_type,
                 l_amount_to_accrue_amort,NULL,
                 l_first_accrual_indic,starting_date,maturiting_date,
                 NULL,l_amount_to_accrue_amort+nvl(l_accrls_amount_bal,0),
               decode(sign(l_amount_to_accrue_amort+nvl(l_accrls_amount_bal,0)),-1,'POS','REV'));
       end if;
    end if;


   end if;
  END LOOP;
  close BONDS;
end CALCULATE_BOND_AMORTISATION;
------------------------------------------------------------------------------------------------------------
PROCEDURE CALCULATE_ACCRUAL_AMORTISATION(errbuf          OUT NOCOPY  VARCHAR2,
                                         retcode         OUT NOCOPY  NUMBER,
                                         p_company       IN VARCHAR2,
                                         p_batch_id      IN NUMBER,
                                         start_date      IN VARCHAR2,
                                         end_date        IN VARCHAR2,
                                         p_upgrade_batch IN VARCHAR2) AS

--
/* Generalized Steps:
 a) Get Reference Amount
 b) Calculate days in full reference amount period
 c) Calculate days from reference amount start date to Accrual To Date
 d) Calculate Accrual To Date Balance
 e) Calculate Accrual Period Amount
*/

   p_start_date            DATE :=trunc(to_date(start_date,'YYYY/MM/DD HH24:MI:SS'));
   p_end_date              DATE :=trunc(to_date(end_date,'YYYY/MM/DD HH24:MI:SS'));

   deal_yr_basis           NUMBER;
   period_end              DATE;
   period_start            DATE;
   maturing_date           DATE;
   starting_date           DATE;

   l_accrls_amount_bal           NUMBER;            --  for 'l_cumm_int_bal'
   l_action_code                 VARCHAR2(7);
   l_actual_maturity             DATE;
   l_actual_start_date           DATE;
   l_adj_coupon_amt              NUMBER;
   l_adj_amount			 NUMBER := 0;		-- 2422480 added
   l_adj_days			 NUMBER := 0;		-- 2422480 added
--2422480   l_adj_coupon_start            DATE;
   l_amount_to_accrue_amort      NUMBER;
   l_amount_type                 VARCHAR2(7);
   l_back_end_interest           NUMBER;
   l_balance_out                 NUMBER;
   l_batch_id                    XTR_BATCHES.BATCH_ID%TYPE;
   l_batch_start                 VARCHAR2(30);
   l_bond_issue                  VARCHAR2(7);
   l_calc_period_end             DATE;
   l_calc_period_accrl_int       NUMBER;
   l_dda_INT                     NUMBER;
   l_calc_type                   XTR_BOND_ISSUES.CALC_TYPE%TYPE; -- renamed l_flat_zero for COMPOUND COUPON
   l_clean_price                 NUMBER;
   l_ccy                         VARCHAR2(15);
   l_cum_ex                      XTR_DEALS.COUPON_ACTION%TYPE;
   l_coupon_rate                 NUMBER;
   l_coupon_start                DATE;
   l_coupon_end                  DATE;
   l_cross_ref_start_date        DATE;
   l_cumm_resale_face            NUMBER;
   l_day_adjust_flag             VARCHAR2(1)  := 'Y';
   l_day_count_type              VARCHAR2(1);
   l_days_adjust                 VARCHAR2(100);
   l_days_BOP                    NUMBER;
   l_days_EOP                    NUMBER;
   l_deal_start                  DATE;
   l_deal_closed                 VARCHAR2(1);
   l_deal_nos                    NUMBER;
   l_deal_type                   VARCHAR2(7);
   l_dummy                       NUMBER;
   l_elig_resale_start           DATE;
   l_elig_resale_end             DATE;
   l_event_id                    NUMBER;
   l_face_value                  NUMBER;
   l_face_value_bal              NUMBER;
   l_first_accrual_indic         VARCHAR2(1);
   l_forward_adjust              NUMBER;
   l_frequency                   NUMBER;
   l_group_period_accrual_amt	 NUMBER := 0;	-- 2422480 added
   l_group_period_start		 DATE;		-- 2422480 added
   l_group_end_date		 DATE;		-- 2422480 added
   l_hce_rate                    NUMBER  := 1;
   l_maturity_amount             NUMBER;
   l_maturity_face_value         NUMBER;
   l_no_of_days                  NUMBER;
   l_length_of_deal              NUMBER;
   l_period_accrual_amount       NUMBER;
   l_period_resale_amort         NUMBER;
   l_period_start_face_value     NUMBER;
   l_price_rounding              NUMBER;
   l_resale_total_amort          NUMBER;
   l_resale_cumm_amort           NUMBER;
   l_rounding                    NUMBER;
   l_rounding_type               VARCHAR2(1);
   l_start_amount                NUMBER;
   l_status_code                 VARCHAR2(20);
   l_sysdate                     DATE  := trunc(sysdate);
   l_temp                        NUMBER;
   l_to_date_amort_amt           NUMBER;
   l_to_date_amort_amt_bal       NUMBER;
   l_to_date_resale_accrl_int	 NUMBER := 0;		-- 2422480 added
   l_trade_settle                XTR_COMPANY_PARAMETERS.parameter_value_code%TYPE;
   l_trans_nos                   NUMBER;
   l_year_calc_type              VARCHAR2(20);
   l_yr_basis                    NUMBER;


   /*---------------------------------------*/
   /* Determine batch process starting point*/
   /*---------------------------------------*/
   cursor BATCH_START is
   select parameter_value_code
   from   XTR_COMPANY_PARAMETERS
   where  company_code   = p_company
   and    parameter_code = 'ACCNT_BPSTP';


   /*-----------------------------------------------------*/
   /* If batch start from Accruals, generate new Batch_id */
   /*-----------------------------------------------------*/
   cursor GEN_BATCH is
   select XTR_BATCHES_S.NEXTVAL
   from   DUAL;

   /*-----------------------*/
   /* Generate new Event_id */
   /*-----------------------*/
   Cursor EVENT_ID is
   Select XTR_BATCH_EVENTS_S.NEXTVAL
   From   DUAL;

   /*-----------------------------------------------------------------------*/
   /* If batch start from Reval, check reval authorization before Accruals  */
   /*-----------------------------------------------------------------------*/
   cursor CHK_REVAL_AUTH is
   select 1
   from   XTR_BATCH_EVENTS
   where  batch_id = p_batch_id
   and    event_code = 'REVAL'
   and    authorized = 'Y';

   /*---------------------*/
   /* Get rounding factor */
   /*---------------------*/
   cursor RND_FAC is
   select m.ROUNDING_FACTOR
   from   XTR_MASTER_CURRENCIES_V m
   where  m.CURRENCY =l_ccy;

   /*-----------------------------------------------------------------------------*/
   /* Get accrual methods Interest in arrears(Following), Forward interest(Prior).*/
   /*-----------------------------------------------------------------------------*/
   cursor ADJUST(p_param_name varchar2) is
   select PARAM_VALUE
   from   XTR_PRO_PARAM
   where  PARAM_NAME = p_param_name;

   /*------------------------------*/
   /* Get TRADE/SETTLE accounting  */
   /*------------------------------*/
   cursor cur_TRADE_SETTLE is
   select PARAMETER_VALUE_CODE
   from   XTR_COMPANY_PARAMETERS
   where  company_code   = p_company
   and    parameter_code = 'ACCNT_TSDTM';

   /*------------------------------*/
   /* Find IRS First Transaction   */
   /*------------------------------*/
   -- AW Japan Project
   cursor CHK_FIRST_TRAN(l_deal_type VARCHAR2, l_deal_no NUMBER, l_tran_no NUMBER,
                         l_date_from DATE,     l_date_to DATE) is
   select 1
   from   XTR_ROLLOVER_TRANSACTIONS
   where  deal_type            = l_deal_type
   and    deal_number          = l_deal_no
   and    transaction_number  <> l_tran_no
   and    start_date          <= l_date_from
   and    maturity_date       <= l_date_to;

   /*---------------------------------------*/
   /* Select deals for accrual calculations */
   /*---------------------------------------*/
   cursor ACCRUAL_DEALS is select
   -----------------------------------------------
   --  'TMM','RTMM','IRS','ONC','BOND'(Coupon)
   -----------------------------------------------
   a.status_code                                                status_code,
   a.deal_type                                                  deal_type,
   a.deal_number                                                deal_nos,
   a.transaction_number                                         trans_nos,
   a.deal_subtype                                               subtype,
   a.product_type                                               product,
   a.portfolio_code                                             portfolio,
   a.currency                                                   ccy,
   a.cparty_code                                                cparty,
   a.client_code                                                client,
   NULL                                                         action,
   decode(a.deal_type,'BOND','CPMADJ',       'INTADJ')          main_amt_type,
   decode(a.deal_type,'BOND',a.interest,     a.balance_out)     main_amount,
   decode(a.deal_type,'BOND',a.interest_hce, a.balance_out_hce) hce_amount,
   a.interest_rate                                              rate,
   a.start_date                                                 date_from,
   decode(a.maturity_date,NULL, 'PEREND', 'MATURE')             date_type_to,
   a.maturity_date                                              date_to,  -- AW 2113171  For ONC without maturity date
 --nvl(a.maturity_date,p_end_date)                              date_to,  -- old
   a.year_calc_type                                             year_calc_type,
   a.no_of_days                                                 no_of_days,
   NULL                                                         bond_issue,
   a.maturity_date                                              deal_action_date,
   decode(a.deal_type,'ONC',a.interest + nvl(a.interest_refund,0),a.interest)   override_amount, -- AW Japan Project
   nvl(d.rounding_type,'R')                                                     rounding_type,   -- AW Japan Project
   decode(nvl(d.day_count_type,'L'),'F','PRIOR','L','FOLLOWING','B')            day_count_type,  -- AW Japan Project
   decode(nvl(d.day_count_type,'L'),'F',1,0)                                    forward_adjust,  -- AW Japan Project
   decode(nvl(d.day_count_type,'L'),'B',decode(a.deal_type,'TMM', decode(a.transaction_number,1,'Y','N'),
                                                           'ONC', nvl(a.first_transaction_flag,'N'),
                                                           'BOND',decode(a.transaction_number,2,'Y','N'),
                                                           'N'),
                                    'N')                                        first_trans_flag -- AW Japan Project
   from  XTR_ROLLOVER_TRANSACTIONS a,
         XTR_DEALS d
   where a.company_code   = p_company
   and   a.deal_number    = d.deal_no
   and   a.deal_type      = d.deal_type
   and   a.deal_type in ('TMM','RTMM','IRS','ONC','BOND')
   and   nvl(a.maturity_date,a.start_date+1) > a.start_date
   and   nvl(a.interest_rate,0) <> 0
   and ((a.start_date    <= p_end_date and a.deal_type <> 'BOND')
   or   (a.start_date    <= p_end_date and a.deal_type =  'BOND' and
         p_end_date      >= (select b.start_date
                             from   xtr_deals b
                             where  b.deal_no = a.deal_number
                             and    b.deal_type = 'BOND')))
   and ((a.maturity_date >= p_start_date or a.maturity_date is NULL)
   or   (a.deal_number,a.transaction_number) not in (select b.deal_no,b.trans_no
                                                     from   XTR_ACCRLS_AMORT b
                                                     where  b.company_code = p_company
                                                     and    b.deal_type in ('TMM','RTMM','IRS','ONC','BOND')))
   and ((a.deal_type <> 'BOND' and a.status_code <> 'CANCELLED')
   or   (a.deal_type  = 'BOND' and a.status_code not in ('CANCELLED','CLOSED')
                               and a.deal_subtype in ('BUY','ISSUE'))
                               and a.deal_number not in (select deal_no from
                                                         xtr_bond_alloc_details b
                                                        where b.deal_no = d.deal_no
							and b.face_value = d.maturity_amount
    							and b.cross_ref_start_date = d.start_date)) -- bug 5490311
   -----------------------------
   -- BOND (Discount/Premium) --
   -----------------------------
   union all
   select
   a.status_code                                                status_code,
   a.deal_type                                                  deal_type,
   a.deal_no                                                    deal_nos,
   1                                                            trans_nos,
   a.deal_subtype                                               subtype,
   a.product_type                                               product,
   a.portfolio_code                                             portfolio,
   a.currency                                                   ccy,
   a.cparty_code                                                cparty,
   a.client_code                                                client,
   NULL                                                         action,
   decode(sign(a.capital_price-100),-1,'SLDISC','SLPREM')       main_amt_type,
   abs(a.maturity_amount)                                       main_amount,
   a.maturity_hce_amount                                        hce_amount,
   a.interest_rate                                              rate,
   decode(l_trade_settle,'TRADE',a.deal_date,a.start_date)      date_from,
   decode(a.maturity_date,NULL,'PEREND','MATURE')               date_type_to, --Always MATURE cos maturity_date is not null
   a.maturity_date                                              date_to,
   a.year_calc_type                                             year_calc_type,
   a.no_of_days                                                 no_of_days,
   NULL                                                         bond_issue,
   a.bond_sale_date                                             deal_action_date,  -- not use bond_reneg_date !
   abs(a.maturity_amount)                                             override_amount,   -- AW Japan Project, not used
   nvl(a.rounding_type,'R')                                           rounding_type,     -- AW Japan Project
   decode(nvl(a.day_count_type,'L'),'F','PRIOR','L','FOLLOWING','B')  day_count_type,    -- AW Japan Project
   decode(nvl(a.day_count_type,'L'),'F',1,0)                          forward_adjust,    -- AW Japan Project
   decode(nvl(a.day_count_type,'L'),'B','Y','N')                      first_trans_flag   -- AW Japan Project
   from  XTR_DEALS a
   where a.company_code   = p_company
   and   a.deal_type      = 'BOND'
   and   a.deal_subtype in ('BUY','ISSUE')
   and   decode(l_trade_settle,'TRADE',a.deal_date,a.start_date) <= p_end_date
   and ((a.maturity_amount <> 0
   and   a.deal_no not in ( select b.deal_no
                            from   XTR_ACCRLS_AMORT b
                            where  b.company_code = p_company
                            and    b.trans_no     = 1
                            and    b.deal_type    = 'BOND'
                            and    b.action_code  = 'POS'
                            and    b.amount_type in ('SLDISC','SLPREM')))
   or   (a.maturity_date >= p_start_date
   and   a.deal_no      in (select b.deal_no
                            from   XTR_ACCRLS_AMORT b
                            where  b.company_code = p_company
                            and    b.trans_no     = 1
                            and    b.deal_type    = 'BOND'
                            and    b.action_code  = 'POS'
                            and    b.amount_type in ('SLDISC','SLPREM')
                            and    nvl(b.calc_face_value,0) <> 0
                            and    b.batch_id = ( select max(c.batch_id)
                                                  from   XTR_ACCRLS_AMORT c
                                                  where  c.company_code = p_company
                                                  and    c.deal_no      = b.deal_no
                                                  and    c.trans_no     = 1
                                                  and    c.deal_type    = 'BOND'
                                                  and    c.action_code  = 'POS'
                                                  and    c.amount_type in ('SLDISC','SLPREM')))))
   and   a.status_code not in ('CANCELLED', 'CLOSED')
   and a.deal_no not in (select deal_no from
                              xtr_bond_alloc_details b
	             	 where  b.deal_no = a.deal_no
			 and b.face_value = a.maturity_amount
                   	 and b.cross_ref_start_date = a.start_date)	-- bug 5490311
   -------------------------------
   -- NI (Straight Line Method) --
   -------------------------------

   -- Bug 2448432.
   -- Removed references to company trade/settle date accounting method parameter.
   -- Accrual of interest is not to begin until the deal start date always.

   union all
   select
   a.status_code                                                status_code,
   a.deal_type                                                  deal_type,
   a.deal_number                                                deal_nos,
   a.transaction_number                                         trans_nos,
   a.deal_subtype                                               subtype,
   a.product_type                                               product,
   a.portfolio_code                                             portfolio,
   a.currency                                                   ccy,
   a.cparty_code                                                cparty,
   a.client_code                                                client,
   NULL                                                         action,
   'INTADJ'                                                     main_amt_type,
   a.interest                                                   main_amount,
   a.interest_hce                                               hce_amount,
   a.interest_rate                                              rate,
   a.start_date							date_from,
   decode(a.maturity_date,NULL, 'PEREND', 'MATURE')             date_type_to,
   a.maturity_date                                              date_to,
   a.year_calc_type                                             year_calc_type,
   a.no_of_days                                                 no_of_days,
   NULL                                                         bond_issue,
   a.ni_reneg_date                                              deal_action_date,
   a.interest                                                        override_amount,   -- AW Japan Project, not used
   nvl(d.rounding_type,'R')                                          rounding_type,     -- AW Japan Project
   decode(nvl(d.day_count_type,'L'),'F','PRIOR','L','FOLLOWING','B') day_count_type,    -- AW Japan Project
   decode(nvl(d.day_count_type,'L'),'F',1,0)                         forward_adjust,    -- AW Japan Project
   decode(nvl(d.day_count_type,'L'),'B','Y','N')                     first_trans_flag   -- AW Japan Project
   from  XTR_ROLLOVER_TRANSACTIONS a,
         XTR_DEALS  d
   where a.company_code          = p_company
   and   a.deal_number           = d.deal_no
   and   a.deal_type             = d.deal_type
   and   a.deal_type             = 'NI'
   and   a.deal_subtype in ('BUY','SHORT','ISSUE')
   and   a.status_code          <> 'CANCELLED'
   and   nvl(a.interest_rate,0) <> 0
   and   a.start_date		<= p_end_date
   and  (a.maturity_date        >= p_start_date or
        (a.deal_number,a.transaction_number,'INTADJ') not in (select b.deal_no,b.trans_no,b.amount_type
                                                              from   XTR_ACCRLS_AMORT b
                                                              where  b.company_code = p_company
                                                              and    b.deal_type    = 'NI'))
   -----------------------------------------------
   --  'FXO','IRO','BDO','SWPTN'  -- premium
   -----------------------------------------------
   union all
   select
   a.status_code                                                status_code,
   a.deal_type                                                  deal_type,
   a.deal_no                                                    deal_nos,
   1                                                            trans_nos,
   a.deal_subtype                                               subtype,
   a.product_type                                               product,
   a.portfolio_code                                             portfolio,
   nvl(a.premium_currency,a.currency)                           ccy,
   a.cparty_code                                                cparty,
   a.client_code                                                client,
   a.settle_action                                              action,
   'PREMADJ'                                                    main_amt_type,
   a.premium_amount                                             main_amount,
   a.premium_hce_amount                                         hce_amount,
   decode(a.deal_type,'FXO',a.transaction_rate,
                      'BDO',a.capital_price,a.interest_rate)    rate,     -- AW 2113171  No rate displayed for BDO.
   a.premium_date                                               date_from,
   'MATURE'                                                     date_type_to,
   a.expiry_date                                                date_to,
   a.year_calc_type                                             year_calc_type,
   a.no_of_days                                                 no_of_days,
   a.bond_issue                                                 bond_issue,
   a.settle_date                                                deal_action_date,
   a.premium_amount                                             override_amount,  -- AW Japan Project, not used
   'R'                                                          rounding_type,    -- AW Japan Project
   l_days_adjust                                                day_count_type,   -- AW Japan Project
   l_forward_adjust                                             forward_adjust,   -- AW Japan Project
   'N'                                                          first_trans_flag  -- AW Japan Project
   from  XTR_DEALS a
   where a.company_code  = p_company
   and   a.deal_type in ('IRO','BDO','SWPTN','FXO')
   and   a.premium_date <= p_end_date
   and  (a.expiry_date  >= p_start_date
   or    a.deal_no not in ( select b.deal_no
                            from   XTR_ACCRLS_AMORT b
                            where  b.company_code = p_company
                            and    b.deal_type in ('FXO','IRO','BDO','SWPTN')
                            and    b.amount_type  = 'PREMADJ'))    -- AW 1395208
   and   a.status_code <> 'CANCELLED'
   and   nvl(a.premium_amount,0) <> 0

   --------------------------------------------------------
   --  'FRA','BDO','IRO','SWPTN'  -- interest  AW 1395208
   --------------------------------------------------------
   union all
   select
   a.status_code                                                 status_code,
   a.deal_type                                                   deal_type,
   a.deal_no                                                     deal_nos,
   1                                                             trans_nos,
   a.deal_subtype                                                subtype,
   a.product_type                                                product,
   a.portfolio_code                                              portfolio,
   a.currency                                                    ccy,
   a.cparty_code                                                 cparty,
   a.client_code                                                 client,
   a.settle_action                                               action,
   decode(a.deal_type,'BDO',decode(a.deal_subtype,'BCAP','SLDISC','SCAP','SLDISC','SLPREM'),
                      'INTADJ')                                  main_amt_type,
   a.settle_amount                                               main_amount,
   a.settle_hce_amount                                           hce_amount,
   decode(a.deal_type,'BDO',a.exercise_price,a.settle_rate)      rate,
   a.start_date                                                  date_from,
   'MATURE'                                                      date_type_to,
   a.maturity_date                                               date_to,
   a.year_calc_type                                              year_calc_type,   -- if null, ACTUAL/ACTUAL later
   a.no_of_days                                                  no_of_days,
   a.bond_issue                                                  bond_issue,
   a.settle_date                                                 deal_action_date,
   a.settle_amount                                               override_amount,  -- only apply to FRA
   decode(a.deal_type,'FRA',nvl(a.settle_rounding_type,'R'),
                      'R')                                       rounding_type,
   decode(a.deal_type,'FRA',decode(nvl(a.settle_day_count_type,l_days_adjust),'F','PRIOR',
                                                                              'L','FOLLOWING',
                                                                              'B','B',
                                                                              l_days_adjust),
                       l_days_adjust)                            day_count_type,
   decode(decode(a.deal_type,'FRA',nvl(a.settle_day_count_type,l_days_adjust),
                              l_days_adjust),
          'F',1,'PRIOR',1,0)                                     forward_adjust,
   decode(a.deal_type,'FRA','Y','N')                             first_trans_flag
   from  XTR_DEALS a
   where a.company_code   = p_company
   and   a.deal_type in ('FRA','BDO','IRO','SWPTN')
   and   a.maturity_date is not null
   and   a.start_date    < a.maturity_date  -- avoid Bug 3006377 in BDO allowing Start >= Maturity Date
   and   a.start_date    <= p_end_date
   and  (a.maturity_date >= p_start_date
   or    a.deal_no not in ( select b.deal_no
                            from   XTR_ACCRLS_AMORT b
                            where  b.company_code = p_company
                            and    b.deal_type in ('FRA','BDO','IRO','SWPTN')
                            and    b.amount_type in ('INTADJ','SLDISC','SLPREM')))
   and   a.status_code in ('EXERCISED','SETTLED')
   and   nvl(a.settle_amount,0) <> 0
   order by 2,3,4;


---------------------------------------
-- Per Bruce, Tom and Ellen's requests
---------------------------------------
-- select
-- a.status_code                  status_code,
-- a.deal_type                    deal_type,
-- a.deal_no                      deal_nos,
-- 1                              trans_nos,
-- a.deal_subtype                 subtype,
-- a.product_type                 product,
-- a.portfolio_code               portfolio,
-- a.currency                     ccy,
-- a.cparty_code                  cparty,
-- a.client_code                  client,
-- a.settle_action                action,
-- 'SETLADJ'                      main_amt_type,
-- a.settle_amount                main_amount,
-- a.settle_hce_amount            hce_amount,
-- a.interest_rate                rate,
-- a.start_date                   date_from,
-- 'MATURE'                       date_type_to,
-- a.maturity_date                date_to,
-- a.year_calc_type               year_calc_type,
-- a.no_of_days                   no_of_days,
-- a.bond_issue                   bond_issue,
-- a.maturity_date                deal_action_date
-- from  XTR_DEALS a
-- where a.company_code =p_company
-- and   a.deal_type in ('FRA','IRO','BDO','SWPTN')
-- and   a.start_date <= p_end_date
-- and ((a.maturity_date >= p_start_date or
--          a.maturity_date is NULL)
--       or a.deal_no not in
--           ( select b.deal_no
--              from XTR_ACCRLS_AMORT b
--                where b.company_code=p_company
--                  and b.deal_type in('FRA','IRO','BDO','SWPTN')))
-- and   a.maturity_date > a.start_date
-- and   a.status_code <> 'CANCELLED'
-- and   nvl(a.settle_amount,0) <> 0
-- union all

   onc_det ACCRUAL_DEALS%ROWTYPE;

   -----------------------------
   -- Get Bond Discount/Premium
   -----------------------------
   cursor BOND_DISC_PREM is
   select decode(l_trade_settle,'TRADE',cross_ref_deal_date,cross_ref_start_date)  resale_recognition_date,
          front_end_prem_disc,
          face_value,
          cross_ref_no
   from   XTR_BOND_ALLOC_DETAILS
   where  deal_no  = l_deal_nos
   and    decode(l_trade_settle,'TRADE',cross_ref_deal_date,cross_ref_start_date) <= p_end_date
   and   (deal_no,cross_ref_no) not in (select deal_no,trans_no
                                        from   xtr_accrls_amort
                                        where  company_code = p_company);

   discprem_det BOND_DISC_PREM%ROWTYPE;

   -----------------------------
   -- Get Bond Discount/Premium
   -----------------------------
   cursor BOND_COUPON_RESALE is
   select b.back_end_interest,
          b.cross_ref_start_date,
          b.face_value,
          d.coupon_action			-- 2422480  added
   from   XTR_BOND_ALLOC_DETAILS b,
          XTR_DEALS              d
   where  b.deal_no  = l_deal_nos
   and    d.deal_no  = l_deal_nos
   and    b.cross_ref_start_date between l_elig_resale_start and l_elig_resale_end;

   resale_det BOND_COUPON_RESALE%ROWTYPE;


   --------------------------------------
   -- Check if this is the first accrual
   --------------------------------------
   cursor CHK_FIRST_ACCRUAL is
   select 'N'
   from   XTR_ACCRLS_AMORT
   where  deal_no    = l_deal_nos
   and    deal_type  = l_deal_type
   and  ((deal_type  = 'NI'   and amount_type = 'INTADJ') -- To differentiate from new amt type EFFINT for NI.
   or    (deal_type  = 'BOND' and amount_type = l_amount_type and
          l_amount_type in ('SLDISC','SLPREM') and action_code = 'POS')
   or    (deal_type     = 'BOND' and amount_type = l_amount_type and
          l_amount_type = 'CPMADJ' and trans_no = l_trans_nos)           -- AW 2113171  1st accrual indic for coupon.
   or    (deal_type in ('TMM','RTMM','IRS','ONC') and trans_no = l_trans_nos) -- AW 2113171  1st accrual indic
   or    (deal_type in ('BDO','IRO','SWPTN') and amount_type = l_amount_type and            -- AW 1395208
          action_code = 'POS')                                                              -- AW 1395208
   or    (deal_type not in ('NI','BOND','TMM','RTMM','IRS','ONC','BDO','IRO','SWPTN')));    -- AW 1395208
 --

   -----------------------------
   -- Get Deal's Year Calc Type
   -----------------------------
   cursor GET_DEAL_DATA is
   select year_calc_type
   from   xtr_deals
   where  deal_no   = l_deal_nos
   and    deal_type = l_deal_type;

   ------------------------------------
   -- Get issue details for Bond deal
   ------------------------------------
   cursor GET_BOND_DEAL_DATA is
   select bond_issue,
          capital_price,
          coupon_action,
          maturity_amount,
          start_amount,
          start_date
   from   xtr_deals
   where  deal_no   = l_deal_nos
   and    deal_type = l_deal_type;

   ----------------------------------------------
   -- Get Accrued Interest for Discount/Premium
   ----------------------------------------------
   cursor GET_BOND_DDA_INT is
   select amount
   from   XTR_DEAL_DATE_AMOUNTS
   where  deal_number        = l_deal_nos
   and    transaction_number = 1
   and    amount_type        = 'INT'
   and    date_type          = 'COMENCE';

   --------------------------
   -- Get Bond Issue details
   --------------------------
   cursor GET_BOND_ISSUE_DATA is
   select year_calc_type,
          price_rounding,
          nvl(no_of_coupons_per_year,0),
          calc_type,
          commence_date,                 -- COMPOUND COUPON
          maturity_date                  -- COMPOUND COUPON
   from   xtr_bond_issues
   where  bond_issue_code = l_bond_issue;


   --------------------------------
   -- Get previous accrual balance
   --------------------------------
   cursor GET_PRV_BAL is
          -- 2422480. Chg from accrls_amount_bal to fix Testing Issue 2.
          -- 2751078  Issue 2.  Cummulative amount is calculated for SLPREM/SLDISC
   select nvl(decode(l_amount_type,'CPMADJ',EFFINT_ACCRLS_AMOUNT_BAL,ACCRLS_AMOUNT_BAL),0),
          nvl(CALC_FACE_VALUE,0)
   from   XTR_ACCRLS_AMORT
   where  deal_no     = l_deal_nos
   and    trans_no    = l_trans_nos
   and    deal_type   = l_deal_type
   and    amount_type = l_amount_type
   and    action_code in ('POS','REV')			-- 2422480.  Added 'REV'.
   and    batch_id    < nvl(p_batch_id, l_batch_id)	-- To handle inaugural batch. period_to < p_end_date
   order by period_to desc, calc_face_value asc;	-- 2422480.  Added calc_face_value to handle multi-sales on same day.


   ---------------------------------------------------------------------------------------------------------
   -- Check if the deal is closed - if closed, it means 'REV' has been created.  Do not create 'REV' again.
   ---------------------------------------------------------------------------------------------------------
   cursor CHK_CLOSED_DEAL is
   select 'Y'
   from   XTR_ACCRLS_AMORT
   where  deal_no     = l_deal_nos
   and    trans_no    = l_trans_nos
   and    deal_type   = l_deal_type
   and    amount_type = l_amount_type
   and    action_code = 'REV'
   and    batch_id    < nvl(p_batch_id, l_batch_id)  -- To handle inaugural batch. period_to < p_end_date
   order by period_to desc;

   ---------------------------------------------------------------------
   -- Get No of Null Coupon and Odd Coupon Maturity for COMPOUND COUPON
   ---------------------------------------------------------------------
   cursor TOTAL_FULL_COUPONS (p_issue_code VARCHAR2) is
   select count(*)-1,            -- Total FULL Coupon
          min(coupon_date)       -- Odd Coupon Maturity
   from   xtr_bond_coupon_dates
   where  bond_issue_code = p_issue_code;

   -------------------------------------------------------------------------------
   -- Get Previous Coupon Date and No of Previous Full Coupon for COMPOUND COUPON
   -------------------------------------------------------------------------------
   cursor PRV_COUPON_DATES is
   select max(COUPON_DATE),      -- Previous Coupon Date
          greatest(count(*)-1,0) -- Previous Full Coupon
   from   XTR_BOND_COUPON_DATES
   where  BOND_ISSUE_CODE = l_bond_issue
   and    COUPON_DATE    <= p_end_date;

   ------------------------------------------------
   -- Get Next Coupon Date for COMPOUND COUPON
   ------------------------------------------------
   cursor NXT_COUPON_DATES is
   select min(COUPON_DATE)       -- Next Coupon Date
   from   XTR_BOND_COUPON_DATES
   where  BOND_ISSUE_CODE = l_bond_issue
   and    COUPON_DATE     > p_end_date;

   l_dummy_date                  DATE;
   l_bond_rec                    XTR_MM_COVERS.BOND_INFO_REC_TYPE;
   l_comp_coupon                 XTR_MM_COVERS.COMPOUND_CPN_REC_TYPE;
   l_no_quasi_coupon             NUMBER;
   l_bond_commence               DATE;
   l_bond_maturity               DATE;
   l_odd_coupon_start            DATE;
   l_odd_coupon_maturity         DATE;
   l_prev_coupon_date            DATE;
   l_next_coupon_date            DATE;
   l_num_full_cpn_previous       NUMBER;
   l_precision                   NUMBER;
   l_ext_precision               NUMBER;
   l_min_acct_unit               NUMBER;
   l_num_current_coupon          NUMBER;
   l_prv_quasi_coupon            NUMBER;

   ex_reval_auth  exception;

   ----------------------------------------------------
   -- Get sum of accrued to-date balance of the coupon.
   ----------------------------------------------------

   -- Cursor added for 2422480 to fix Testing Issue 2 without too hairy an upgrade script.

   cursor GET_TOTAL_BOND_CPN_ACCRUAL is
   select sum(decode(action_code,'POS',nvl(ACCRLS_AMOUNT,0),nvl(-ACCRLS_AMOUNT,0)))
   from   XTR_ACCRLS_AMORT
   where  deal_no     = l_deal_nos
   and    trans_no    = l_trans_nos
   and    deal_type   = 'BOND'
   and    amount_type = 'CPMADJ'
   and    action_code in ('POS','REV');

   ------------------------------------------------------------------
   -- 2753088,2751078 - Get total resale face value up to given date
   ------------------------------------------------------------------
   cursor TOTAL_RESALE_FACE_VALUE (p_deal_no NUMBER, p_date DATE) is
   select nvl(sum(face_value),0)
   from   XTR_BOND_ALLOC_DETAILS
   where  deal_no               = p_deal_no
   and    cross_ref_start_date <= p_date;

   -----------------------------------------------------------------------------------------
   -- Bug 2751078 - To balance total CPMADJ accruals amount.
   -----------------------------------------------------------------------------------------
   l_sum_prev_accrls  NUMBER;
   l_sum_backend_int  NUMBER;

   --bug 2804548
   v_ChkCpnRateReset_out xtr_mm_covers.ChkCpnRateReset_out_rec;
   v_ChkCpnRateReset_in xtr_mm_covers.ChkCpnRateReset_in_rec;

   -----------------------------------------------------------------------------------------
   -- Bug 2781438 (3450474) - To log reversal amount for TMM, IRS, ONC.
   -----------------------------------------------------------------------------------------
   l_rev_exists   VARCHAR2(1) := 'N';
   l_rev_message  VARCHAR2(20):= '';

BEGIN

   --  Added for Streamline Accounting
   retcode := 0;
   SAVEPOINT sp_accrual;

   Open  BATCH_START;
   Fetch BATCH_START into l_batch_start;
   Close BATCH_START;

   --------------------------------------
   -- Batch process starts from Reval
   --------------------------------------
   If l_batch_start = 'REVAL' then
      Open  CHK_REVAL_AUTH;
      Fetch CHK_REVAL_AUTH into l_temp;
      If CHK_REVAL_AUTH%NOTFOUND then
         Close CHK_REVAL_AUTH;
         Raise ex_reval_auth;
      Else
         Close CHK_REVAL_AUTH;
      End if;
      l_batch_id := p_batch_id;

   --------------------------------------
   -- Batch process starts from ACCRUAL
   --------------------------------------
   Else
      If p_batch_id is null then
         Open  GEN_BATCH;
         Fetch GEN_BATCH into l_batch_id;
         Close GEN_BATCH;

         -- Insert new row to XTR_BATCH when new batch process staring from accrual
         Insert into XTR_BATCHES(batch_id, company_code, period_start, period_end,
                                 gl_group_id, upgrade_batch, created_by, creation_date,
                                 last_updated_by, last_update_date, last_update_login)
                         values (l_batch_id, p_company, p_start_date, p_end_date,
                                 null, nvl(p_upgrade_batch,'N'), fnd_global.user_id, l_sysdate,
                                 fnd_global.user_id, l_sysdate, fnd_global.login_id);
      Else
         l_batch_id := p_batch_id;
      End if;
   End if;

   /*-----------------------------*/
   /* Delete before recalculation */
   /*-----------------------------*/
   if p_batch_id is not null then
      delete from XTR_ACCRLS_AMORT
      where  company_code = p_company
      and    batch_id     = p_batch_id;
   end if;


   /*-----------------------------------------------------*/
   /* Get param for Arrears(FOLLOWING) or Forward (PRIOR).*/
   /*-----------------------------------------------------*/
   -- AW Japan Project
   -- Replaced in loop with ONC_DET.day_count_type and ONC_DET.forward_adjust
   -- Only FXO, IRO, BDO and SWPTN will be using system parameter for Forward/Arrear calculation
   l_days_adjust := null;
   open  ADJUST('ACCRUAL_DAYS_ADJUST');
   fetch ADJUST INTO l_days_adjust;
   close ADJUST;

   l_days_adjust :=nvl(l_days_adjust,'FOLLOWING');
   if l_days_adjust = 'PRIOR' then
      l_forward_adjust := 1;
   else
      l_forward_adjust := 0;
   end if;


   /*--------------------------------*/
   /* Get Trade or Settle accounting */
   /*--------------------------------*/
   open  cur_TRADE_SETTLE;
   fetch cur_TRADE_SETTLE into l_trade_settle;
   close cur_TRADE_SETTLE;

   l_trade_settle := nvl(l_trade_settle,'TRADE');


   /*--------------*/
   /* Main Program */
   /*--------------*/

------------------------------------------------------------------------------------
-- If this is inaugural batch, create a dummy event only.  No details are required.
------------------------------------------------------------------------------------
if nvl(p_upgrade_batch,'N') <> 'I' then

   open  ACCRUAL_DEALS;
   fetch ACCRUAL_DEALS INTO onc_det;
   while ACCRUAL_DEALS%FOUND LOOP


      /*----------------------------*/
      /* Initialise Deal Details    */
      /*----------------------------*/
      l_amount_type   := onc_det.main_amt_type;
      l_ccy           := onc_det.ccy;
      l_deal_nos      := onc_det.deal_nos;
      l_deal_type     := onc_det.deal_type;
      l_status_code   := onc_det.status_code;
      l_trans_nos     := onc_det.trans_nos;

      /*----------------------------*/
      /* Initialise Coupon Details  */
      /*----------------------------*/
      if l_deal_type = 'BOND' and l_amount_type = 'CPMADJ' then
         l_coupon_rate           := onc_det.rate;
         l_coupon_start          := onc_det.date_from;  -- for COMPOUND COUPON - Bond Commencement Date
         l_coupon_end            := onc_det.date_to;
--2422480         l_adj_coupon_start      := onc_det.date_from;

         l_adj_coupon_amt        := 0;
         l_dda_INT               := 0;
         l_calc_period_accrl_int := 0;
         l_cumm_resale_face      := 0;
         l_face_value_bal        := 0;
         l_maturity_amount       := 0;
         l_start_amount          := 0;

      end if;

      /*------------------------------------------------*/
      /* Initialise IRS and RTMM First Transaction Flag */
      /*------------------------------------------------*/
      -- AW Japan Project
      if onc_det.deal_type in ('IRS','RTMM') then
         open CHK_FIRST_TRAN(onc_det.deal_type,onc_det.deal_nos,onc_det.trans_nos,
                             onc_det.date_from,onc_det.date_to);
         fetch CHK_FIRST_TRAN into l_dummy;
         if CHK_FIRST_TRAN%NOTFOUND then
            onc_det.first_trans_flag := 'Y';
         else
            onc_det.first_trans_flag := 'N';
         end if;
         close CHK_FIRST_TRAN;
      end if;

      /*----------------------*/
      /* Get rounding factor  */
      /*----------------------*/
      open  RND_FAC;
      fetch RND_FAC into l_rounding;
      close RND_FAC;
      l_rounding := nvl(l_rounding,2);

      /*----------------------------------------*/
      /* Get Year_Calc_Type  (l_year_calc_type) */
      /*----------------------------------------*/
      l_year_calc_type  := null;
      l_day_adjust_flag := 'Y';

      if onc_det.year_calc_type is NULL and onc_det.deal_type in ('ONC','TMM','RTMM','IRS','NI') then -- Bug1680184 AW
         open  GET_DEAL_DATA;
         fetch GET_DEAL_DATA into l_year_calc_type;
         close GET_DEAL_DATA;

      elsif onc_det.deal_type in ('BDO','BOND') then
         open  GET_BOND_DEAL_DATA;
         fetch GET_BOND_DEAL_DATA into l_bond_issue, l_clean_price, l_cum_ex,
                                       l_maturity_amount, l_start_amount, l_deal_start;
         close GET_BOND_DEAL_DATA;

         open  GET_BOND_ISSUE_DATA;
         fetch GET_BOND_ISSUE_DATA into l_year_calc_type, l_price_rounding, l_frequency, l_calc_type,
                                        l_bond_commence,  l_bond_maturity;  -- COMPOUND COUPON
         close GET_BOND_ISSUE_DATA;

         l_price_rounding := nvl(l_price_rounding,6);

      else
         l_year_calc_type := onc_det.year_calc_type;

      end if;

      l_year_calc_type := nvl(l_year_calc_type,'ACTUAL/ACTUAL');

      /*-----------------------------------------------------------------------*/
      /* Initialise BOND - COMPOUND COUPON: - first transaction flag           */
      /*                                    - odd coupon start date            */
      /*                                    - odd coupon maturity date         */
      /*                                    - no of FULL coupon                */
      /*                                    - previous Coupon Date             */
      /*                                    - previous FULL coupon             */
      /*                                    - next Coupon Date                 */
      /*-----------------------------------------------------------------------*/
      if onc_det.deal_type = 'BOND' and l_amount_type = 'CPMADJ' and l_calc_type = 'COMPOUND COUPON' then

         -----------------------------------------
         -- First transaction flag
         -----------------------------------------
         l_dummy_date := to_date(null);
         select nvl(min(COUPON_DATE),p_end_date)
         into   l_dummy_date
         from   XTR_BOND_COUPON_DATES
         where  BOND_ISSUE_CODE = l_bond_issue
         and    COUPON_DATE     > l_deal_start;
         if p_end_date <= l_dummy_date then
            onc_det.first_trans_flag := 'Y';
         else
            onc_det.first_trans_flag := 'N';
         end if;

         ---------------------------------------------
         -- Total full coupon and odd coupon maturity
         ---------------------------------------------
         l_no_quasi_coupon     := 0;
         open  TOTAL_FULL_COUPONS (l_bond_issue);
         fetch TOTAL_FULL_COUPONS into l_no_quasi_coupon, l_odd_coupon_maturity;
         close TOTAL_FULL_COUPONS;

         ----------------------------------------------------------------------------------
         -- Fetch previous coupon date and previous FULL coupons
         ----------------------------------------------------------------------------------
         open  PRV_COUPON_DATES;
         fetch PRV_COUPON_DATES INTO l_prev_coupon_date, l_num_full_cpn_previous;
         close PRV_COUPON_DATES;
         IF l_prev_coupon_date is null THEN
            l_prev_coupon_date := l_bond_commence;
         END IF;

         ----------------------------------------------------------------------------------
         -- Fetch Next Coupon date
         ----------------------------------------------------------------------------------
         open  NXT_COUPON_DATES;
         fetch NXT_COUPON_DATES INTO l_next_coupon_date;
         close NXT_COUPON_DATES;
         if l_next_coupon_date is null then
            l_next_coupon_date := l_coupon_end;  -- ????????????????????????????????
         end if;

         l_odd_coupon_start := XTR_MM_COVERS.ODD_COUPON_DATE(l_bond_commence,l_bond_maturity, l_frequency,'S');

         FND_CURRENCY.Get_Info ( l_ccy,
                                 l_precision,
                                 l_ext_precision,
                                 l_min_acct_unit);

      end if;

      /*-----------------------------------------------------------------------*/
      /* 4. Determine begining of period accrued balance (l_accrls_amount_bal) */
      /*-----------------------------------------------------------------------*/

      ----------------------------
      -- Find first time accrual
      ----------------------------
      l_accrls_amount_bal   := 0;
      l_maturity_face_value := 0;
      l_first_accrual_indic := 'Y';

      open  CHK_FIRST_ACCRUAL;
      fetch CHK_FIRST_ACCRUAL into l_first_accrual_indic;
      close CHK_FIRST_ACCRUAL;

      --start bug 2804548
      --EXP do not get accrued
      if l_deal_type='BOND' and l_amount_type='CPMADJ' and
      l_trans_nos is not null and l_deal_nos is not null and
      l_first_accrual_indic='Y' then
         v_ChkCpnRateReset_in.deal_type:=l_deal_type;
         v_ChkCpnRateReset_in.transaction_no:=l_trans_nos;
         v_ChkCpnRateReset_in.deal_no:=l_deal_nos;
         xtr_mm_covers.check_coupon_rate_reset(v_ChkCpnRateReset_in,
				 v_ChkCpnRateReset_out);
         --if the coupon or its tax comp has not been reset
         --print out a warning message.
         if not v_ChkCpnRateReset_out.yes then
            FND_MESSAGE.Set_Name ('XTR','XTR_COUPON_RESET_DEAL');
            FND_MESSAGE.Set_Token ('DEAL_NO',l_deal_nos);
            FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
            retcode:=1;
         end if;
      end if;
      --end bug 2804548

      if l_deal_type = 'BOND' and l_amount_type in ('SLDISC','SLPREM') then

         if l_first_accrual_indic = 'Y' then
            --------------------------------
            -- Deal has never been accrued.
            --------------------------------
            l_maturity_face_value     := round(onc_det.main_amount,l_rounding);  -- not an interest amount
            l_period_start_face_value := round(onc_det.main_amount,l_rounding);  -- not an interest amount
            l_to_date_amort_amt       := 0;
            l_to_date_amort_amt_bal   := 0;

         else

            -------------------------------------------------------------------
            -- 2753088,2751078 - SLPREM/SLDISC are generated after total resale
            -------------------------------------------------------------------
            l_dummy      := 0;
            l_dummy_date := p_start_date - 1;  -- to find all Resale Start Date < Batch Start Date
            open  TOTAL_RESALE_FACE_VALUE (l_deal_nos, l_dummy_date);
            fetch TOTAL_RESALE_FACE_VALUE into l_dummy;
            close TOTAL_RESALE_FACE_VALUE;
            if onc_det.main_amount - l_dummy = 0 then
               Goto NEXT_ACCRUAL_DEALS;
            end if;

            ------------------------------------------------------------
            -- Get remaining face value at beginning of the batch period
            ------------------------------------------------------------
            open  GET_PRV_BAL;
            fetch GET_PRV_BAL into l_accrls_amount_bal, l_maturity_face_value;
            close GET_PRV_BAL;
            l_period_start_face_value := l_maturity_face_value;
            l_to_date_amort_amt       := l_accrls_amount_bal;
            l_to_date_amort_amt_bal   := l_accrls_amount_bal;

         end if;

      elsif l_deal_type = 'BOND' and l_amount_type = 'CPMADJ' then

         -- Bug 2422480.
         -- To resolve Testing Issue 2.
         -- Obtain initial purchase interest if processing 1st coupon of deal.

         If (l_coupon_start <= l_deal_start) then
            -------------------------------------------------------------------------------------------
            -- Initial Interest is the Cumulative Interest already accounted for in this first coupon.
            -------------------------------------------------------------------------------------------
            open  GET_BOND_DDA_INT;
            fetch GET_BOND_DDA_INT into l_dda_INT;
            close GET_BOND_DDA_INT;
         End If;

       --if l_first_accrual_indic = 'Y' and l_cum_ex = 'CUM' then
         if l_first_accrual_indic = 'Y' and l_coupon_start <= l_deal_start then
            l_accrls_amount_bal := l_dda_INT;
            l_face_value_bal    := l_maturity_amount;

         else

            open  GET_PRV_BAL;
            fetch GET_PRV_BAL into l_accrls_amount_bal, l_face_value_bal;
            -----------------------------------------------------------------------------------------
            -- If found:
            -- Coupon has been processed before.  Obtain Cumulative Interest already accounted for
            -- based on the latest 'calculation' face value at the end of the last accrual period.
            -----------------------------------------------------------------------------------------
            -- OR
            -----------------------------------------------------------------------------------------
            -- If not found:
            -- New coupon being processed.  Determine how much of the original face value
            -- has been resold prior to start of the current coupon period.
            -----------------------------------------------------------------------------------------
            if GET_PRV_BAL%NOTFOUND then

               ------------------------------------------------------------------------------
               -- 2753088,2751078 - common logic, replace with cursor TOTAL_RESALE_FACE_VALUE
               ------------------------------------------------------------------------------
               if l_calc_type = 'COMPOUND COUPON' then
                  open  TOTAL_RESALE_FACE_VALUE (l_deal_nos, p_end_date);  -- ??????????????
                  fetch TOTAL_RESALE_FACE_VALUE into l_cumm_resale_face;
                  close TOTAL_RESALE_FACE_VALUE;
               else
                  open  TOTAL_RESALE_FACE_VALUE (l_deal_nos, l_coupon_start);
                  fetch TOTAL_RESALE_FACE_VALUE into l_cumm_resale_face;
                  close TOTAL_RESALE_FACE_VALUE;
               end if;

               l_face_value_bal := l_maturity_amount - l_cumm_resale_face;
	     /* for bug 5622679 starts  */
	     else
		  open  TOTAL_RESALE_FACE_VALUE (l_deal_nos, p_start_date-1);
		  fetch TOTAL_RESALE_FACE_VALUE into l_cumm_resale_face;
		  close TOTAL_RESALE_FACE_VALUE;
		  if round(l_maturity_amount - l_cumm_resale_face,l_rounding) = 0 then
		     close GET_PRV_BAL;
		     Goto NEXT_ACCRUAL_DEALS;
		  end if;
             end if;
	     if GET_PRV_BAL%isopen then
		close GET_PRV_BAL;
	     end if;
	     /* for bug 5622679 ends  */
         end if;

         if round(l_face_value_bal,l_rounding) = 0 then     -- not an interest amount
            Goto NEXT_ACCRUAL_DEALS;
         end if;

      else
         open  GET_PRV_BAL;
         fetch GET_PRV_BAL into l_accrls_amount_bal, l_dummy;
         close GET_PRV_BAL;

      end if;


      /*-------------------------------------------------------------------------------------------*/
      /* 1. Calculate accrual / amortisation periods  (period_start, period_end, l_length_of_deal) */
      /*-------------------------------------------------------------------------------------------*/

      -----------------
      -- Period Start
      -----------------
      if l_deal_type = 'BOND' and l_amount_type = 'CPMADJ' then

         -- Bug 2422480 changes start.
         -- Adjust period_start to reflect the actual start date for which the periodic
         -- accrued interest amount is to be calculated for.

         If (nvl(l_first_accrual_indic,'N') = 'Y') then

            -- Coupon being processed for the 1st time.

            If (onc_det.trans_nos = 2) then

               -- This is also the first coupon of the deal.
               -- Periodic interest is to exclude purchase interest.
               -- Therefore, period start should be deal start date.

               period_start := l_deal_start;
            Else
               -- Not the first coupon of the deal.
               -- Periodic interest is to be calculated from the coupon start date.

               period_start := l_coupon_start;
            End If;
         Else
            -- Coupon has been processed before.
            -- period start should be the batch period start date.

            period_start := p_start_date;
         End If;

         -- End 2422480 changes.

      else
         period_start := onc_det.date_from;

      end if;


      ----------------
      -- Period End
      ----------------
      if onc_det.date_type_to = 'PEREND' or onc_det.date_to is null then
         period_end      := p_end_date;

         -- AW 2113171       If DATE_TO is null, keep DATE_TO null for ONC
         if onc_det.deal_type <> 'ONC' then
            onc_det.date_to := p_end_date;
         end if;


      elsif l_amount_type ='PREMADJ' and onc_det.deal_type in ('BDO','IRO','SWPTN','FXO') then
         period_end := nvl(onc_det.deal_action_date,onc_det.date_to);

      elsif l_deal_type = 'BOND' and l_amount_type = 'CPMADJ' then
         period_end        := least(l_coupon_end, p_end_date);
         l_calc_period_end := period_end;


      else
         ---------------------------------------------------
         -- FRA, BDO, IRO, SWPTN : INTADJ, SLPREM, SLDISC     -- AW 1395208
         -- Bond (Discount/Premium) comes in this category
         ---------------------------------------------------
         period_end := onc_det.date_to;


      end if;

      --------------------------------------------------------------------------------
      -- Calculate Length of Deal and Year Basis
      --------------------------------------------------------------------------------

      if onc_det.deal_type = 'BOND' and l_amount_type = 'CPMADJ' then

         if l_calc_type = 'COMPOUND COUPON' then
            -------------------------------------------------------------------------
            -- l_length_of_deal = 'No of Days in Current Coupon' for COMPOUND COUPON
            -------------------------------------------------------------------------
            if p_end_date < l_odd_coupon_maturity then

               XTR_CALC_P.CALC_DAYS_RUN_C(l_odd_coupon_start,
                                          l_odd_coupon_maturity,
                                          l_year_calc_type,
                                          l_frequency,
                                          l_length_of_deal,
                                          l_yr_basis,
                                          null,
                                          onc_det.day_count_type,      -- AW Japan Project
                                          onc_det.first_trans_flag);   -- AW Japan Project
            else
               XTR_CALC_P.CALC_DAYS_RUN_C(l_prev_coupon_date,
                                          l_next_coupon_date,
                                          l_year_calc_type,
                                          l_frequency,
                                          l_length_of_deal,
                                          l_yr_basis,
                                          null,
                                          onc_det.day_count_type,      -- AW Japan Project
                                          onc_det.first_trans_flag);   -- AW Japan Project
            end if;
         else
            -- AW 2113171   -- DO NOT ADJUST FOR Length of deal.
            XTR_CALC_P.CALC_DAYS_RUN_C(l_coupon_start,
                                       l_coupon_end,
                                       l_year_calc_type,
                                       l_frequency,
                                       l_length_of_deal,
                                       l_yr_basis,
                                       null,
                                       onc_det.day_count_type,      -- AW Japan Project
                                       onc_det.first_trans_flag);   -- AW Japan Project
         end if;

      else
         if period_end > period_start then
            if onc_det.deal_type = 'BOND' then

               -- AW 2113171   -- DO NOT ADJUST FOR Length of deal.
               XTR_CALC_P.CALC_DAYS_RUN_C(period_start,
                                          period_end,
                                          l_year_calc_type,
                                          l_frequency,
                                          l_length_of_deal,
                                          l_yr_basis,
                                          null,
                                          onc_det.day_count_type,      -- AW Japan Project
                                          onc_det.first_trans_flag);   -- AW Japan Project
            else
               -- AW Japan Project
               if ((onc_det.day_count_type='PRIOR') or (onc_det.day_count_type='B' and onc_det.first_trans_flag='Y')) and
                    onc_det.deal_type = 'ONC' and onc_det.date_to is null then
               -- if l_days_adjust = 'PRIOR' and onc_det.deal_type = 'ONC' and onc_det.date_to is null then
                  -- AW 2113171   Adjust length of deal for ONC with no maturity date
                  XTR_CALC_P.CALC_DAYS_RUN(period_start - onc_det.forward_adjust,
                                           period_end,
                                           l_year_calc_type,
                                           l_length_of_deal,
                                           l_yr_basis,
                                           onc_det.forward_adjust,
                                           onc_det.day_count_type,      -- AW Japan Project
                                           null);                       -- AW Japan Project
               else
                  -- AW 2113171   -- DO NOT ADJUST FOR Length of deal.
                  XTR_CALC_P.CALC_DAYS_RUN(period_start,
                                           period_end,
                                           l_year_calc_type,
                                           l_length_of_deal,
                                           l_yr_basis,
                                           null,                        -- AW Japan Project
                                           onc_det.day_count_type,      -- AW Japan Project
                                           onc_det.first_trans_flag);   -- AW Japan Project
               end if;
            end if;
         else
               -- AW Japan Project
               if ((onc_det.day_count_type='PRIOR') or (onc_det.day_count_type='B' and onc_det.first_trans_flag='Y')) and
                    onc_det.deal_type = 'ONC' and onc_det.date_to is null then
               -- if onc_det.day_count_type = 'PRIOR' and onc_det.deal_type = 'ONC' and onc_det.date_to is null then
               -- if onc_det.day_count_type in ('PRIOR','B') and
               --    onc_det.deal_type = 'ONC' and onc_det.date_to is null then
               -- if l_days_adjust = 'PRIOR' and onc_det.deal_type = 'ONC' and onc_det.date_to is null then
                  -- AW 2113171  -- To handle ONC with no maturity date and same day batch
                  XTR_CALC_P.CALC_DAYS_RUN(period_start - onc_det.forward_adjust,
                                           period_end,
                                           l_year_calc_type,
                                           l_length_of_deal,
                                           l_yr_basis,
                                           onc_det.forward_adjust,
                                           onc_det.day_count_type,      -- AW Japan Project
                                           null);                       -- AW Japan Project

               else
                  -- AW Japan Project
                  if onc_det.day_count_type = 'B' and onc_det.first_trans_flag = 'Y' and
                     onc_det.deal_type in ('TMM','RTMM','ONC','IRS','BOND','NI') then   -- no accrual for FRA
                     l_length_of_deal := 1;
                  else
                     l_length_of_deal := 0;  -- AW Japan Project  This is for IRO, BDO, FXO, SWPTN
                  end if;
               end if;

         end if;

      end if;

      l_yr_basis := nvl(l_yr_basis,365);


      /*---------------------------------------*/
      /* 1a.  Bond Discount/Premium Adjustment */
      /*---------------------------------------*/

      if onc_det.deal_type = 'BOND' and l_amount_type in ('SLPREM','SLDISC') then
         ----------------------------------------------------------------
         -- Any resale that needs to be recognised in this batch period.
         ----------------------------------------------------------------

         l_resale_total_amort  := 0;
         l_resale_cumm_amort   := 0;
         l_period_resale_amort := 0;

         open  BOND_DISC_PREM;
         fetch BOND_DISC_PREM into discprem_det;
         while BOND_DISC_PREM%FOUND loop

            -----------------------------------------------------------------------------
            -- AW 2113171    -- Consider matured hence do not adjust even for FORWARD
            -----------------------------------------------------------------------------
            -- AW Japan Project
            -- When Both days type is selected, system should include both start date and
            -- resale date to calculate number of days.
            -----------------------------------------------------------------------------
            XTR_CALC_P.CALC_DAYS_RUN_C(period_start,
                                       discprem_det.resale_recognition_date,
                                       l_year_calc_type,
                                       l_frequency,
                                       l_no_of_days,
                                       deal_yr_basis,
                                       null,
                                       onc_det.day_count_type,      -- AW Japan Project
                                       onc_det.first_trans_flag);   -- AW Japan Project

            -----------------------------------------------------------------------------------------------
            -- Calc Total Amort Disc/Prem for the Resale Amount from Deal's Eligible Date to Resale Date.
            -----------------------------------------------------------------------------------------------
            l_resale_total_amort    := round(abs(discprem_det.front_end_prem_disc) *
                                            (l_no_of_days/l_length_of_deal),l_rounding);

            -----------------------------------------------------------------------------------------------
            -- Allocate Amort Disc/Prem for the Resale Amount already accounted for in previous periods.
            -----------------------------------------------------------------------------------------------
            -- In case this will cause a divide by zero error.
            if l_period_start_face_value <> 0 then
                l_resale_cumm_amort := round(discprem_det.face_value/l_period_start_face_value *
                                             l_to_date_amort_amt,l_rounding);
            else
                l_resale_cumm_amort := 0;
            end if;

            -------------------------------------------------------------------------------------
            -- Calculate the Remaining Cummulative Amortization not yet accounted for.
            -------------------------------------------------------------------------------------
            l_to_date_amort_amt_bal := l_to_date_amort_amt_bal - l_resale_cumm_amort;

            -------------------------------------------------------------------------------------
            -- Calculate the Period Disc/Prem Amortization for the Resale Amount.
            -------------------------------------------------------------------------------------
            l_period_resale_amort   := abs(discprem_det.front_end_prem_disc) - l_resale_cumm_amort;

            -------------------------------------------------------------------------------------
            -- Calculate Remaining Face Value to be accounted for.
            -------------------------------------------------------------------------------------
            l_maturity_face_value   := l_maturity_face_value - discprem_det.face_value;

            --------------------------------------
            -- Period Amort for the Resold Amount.
            --------------------------------------
            -- AW 2113171    Do not display if both accrual amount and balance are zero.
            if l_period_resale_amort <> 0 then
         -- if l_period_resale_amort <> 0 and l_resale_total_amort <> 0 then  -- 2737823
               insert into XTR_ACCRLS_AMORT (BATCH_ID,            DEAL_NO,         TRANS_NO,
                                             COMPANY_CODE,        DEAL_SUBTYPE,    DEAL_TYPE,      CURRENCY,
                                             PERIOD_FROM,         PERIOD_TO,
                                             CPARTY_CODE,         PRODUCT_TYPE,    PORTFOLIO_CODE,
                                             INTEREST_RATE,       TRANSACTION_AMOUNT,
                                             AMOUNT_TYPE,         ACTION_CODE,
                                             ACCRLS_AMOUNT,
                                             CALC_FACE_VALUE,
                                             YEAR_BASIS,          FIRST_ACCRUAL_INDIC,
                                             ACTUAL_START_DATE,   ACTUAL_MATURITY_DATE,
                                             NO_OF_DAYS,          ACCRLS_AMOUNT_BAL)
                                     values (l_batch_id,          onc_det.deal_nos,   discprem_det.cross_ref_no,
                                             p_company,           onc_det.subtype,    onc_det.deal_type,onc_det.ccy,
                                             decode(l_first_accrual_indic,'Y',period_start,
                                                    greatest(period_start,p_start_date)),
                                             discprem_det.resale_recognition_date,
                                             onc_det.cparty,      onc_det.product,    onc_det.portfolio,
                                             onc_det.rate,        onc_det.main_amount,
                                             decode(sign(100-l_clean_price),-1,'SLPREM','SLDISC'), 'POS',
                                             l_period_resale_amort,
                                             discprem_det.face_value,
                                             deal_yr_basis,       l_first_accrual_indic,
                                             decode(l_first_accrual_indic,'Y',period_start,
                                                    greatest(period_start,p_start_date)),
                                             discprem_det.resale_recognition_date,
                                             l_no_of_days,        l_resale_total_amort);
            end if;

            -----------------------------------------------------
            -- Reverse Cumulative Amort for the Resold Amount.
            -----------------------------------------------------
            -- AW 2753088,2751078    Do not display if accrual amount is zero.
            if abs(nvl(discprem_det.front_end_prem_disc,0)) <> 0 then
               insert into XTR_ACCRLS_AMORT (BATCH_ID,            DEAL_NO,         TRANS_NO,
                                             COMPANY_CODE,        DEAL_SUBTYPE,    DEAL_TYPE,      CURRENCY,
                                             PERIOD_FROM,         PERIOD_TO,
                                             CPARTY_CODE,         PRODUCT_TYPE,    PORTFOLIO_CODE,
                                             INTEREST_RATE,       TRANSACTION_AMOUNT,
                                             AMOUNT_TYPE,         ACTION_CODE,
                                             ACCRLS_AMOUNT,
                                             CALC_FACE_VALUE,
                                             YEAR_BASIS,          FIRST_ACCRUAL_INDIC,
                                             ACTUAL_START_DATE,   ACTUAL_MATURITY_DATE,
                                             NO_OF_DAYS,          ACCRLS_AMOUNT_BAL)
                                      values(l_batch_id,          onc_det.deal_nos,   discprem_det.cross_ref_no,
                                             p_company,           onc_det.subtype,    onc_det.deal_type,onc_det.ccy,
                                             period_start,        discprem_det.resale_recognition_date,
                                             onc_det.cparty,      onc_det.product,    onc_det.portfolio,
                                             onc_det.rate,        onc_det.main_amount,
                                             decode(sign(100-l_clean_price),-1,'SLPREM','SLDISC'), 'REV',
                                             abs(discprem_det.front_end_prem_disc),
                                             discprem_det.face_value,
                                             deal_yr_basis,       l_first_accrual_indic,
                                             period_start,        discprem_det.resale_recognition_date,
                                             l_no_of_days,        abs(discprem_det.front_end_prem_disc));
            end if;

            -----------------------------------------------------
            -- Reverse Unamort Balance for the Resold Amount.
            -----------------------------------------------------
            -- AW 2753088,2751078    Do not display if accrual amount is zero.
            if abs(nvl(discprem_det.front_end_prem_disc,0)) <> 0 and l_resale_total_amort <> 0 then
               insert into XTR_ACCRLS_AMORT (BATCH_ID,            DEAL_NO,         TRANS_NO,
                                             COMPANY_CODE,        DEAL_SUBTYPE,    DEAL_TYPE,      CURRENCY,
                                             PERIOD_FROM,         PERIOD_TO,
                                             CPARTY_CODE,         PRODUCT_TYPE,    PORTFOLIO_CODE,
                                             INTEREST_RATE,       TRANSACTION_AMOUNT,
                                             AMOUNT_TYPE,         ACTION_CODE,
                                             ACCRLS_AMOUNT,
                                             CALC_FACE_VALUE,
                                             YEAR_BASIS,          FIRST_ACCRUAL_INDIC,
                                             ACTUAL_START_DATE,   ACTUAL_MATURITY_DATE,
                                             NO_OF_DAYS,          ACCRLS_AMOUNT_BAL)
                                      values(l_batch_id,          onc_det.deal_nos,   discprem_det.cross_ref_no,
                                             p_company,           onc_det.subtype,    onc_det.deal_type,onc_det.ccy,
                                             period_start,        discprem_det.resale_recognition_date,
                                             onc_det.cparty,      onc_det.product,    onc_det.portfolio,
                                             onc_det.rate,        onc_det.main_amount,
                                             decode(sign(100-l_clean_price),-1,'SLUAMP','SLUAMD'), 'REV',
                                             abs(discprem_det.front_end_prem_disc) - l_resale_total_amort,
                                             discprem_det.face_value,
                                             deal_yr_basis,       l_first_accrual_indic,
                                             period_start,        discprem_det.resale_recognition_date,
                                             l_no_of_days,        l_resale_total_amort);
            end if;

            fetch BOND_DISC_PREM into discprem_det;
         end loop;
         close BOND_DISC_PREM;
      end if;


      /*--------------------------------------------------------------------------*/
      /* 1b.  Recalc coupon amount at the beginning of the actual coupon period.  */
      /*--------------------------------------------------------------------------*/
      if onc_det.deal_type = 'BOND' and l_amount_type = 'CPMADJ' then

         if l_calc_type in ('FLAT COUPON','FL REGULAR') then --b 2804548
            l_adj_coupon_amt := (l_face_value_bal * (l_coupon_rate/100))/l_frequency;

         elsif l_calc_type = 'COMPOUND COUPON' then

            l_comp_coupon.p_bond_start_date       := l_bond_commence;
            l_comp_coupon.p_odd_coupon_start      := l_odd_coupon_start;
            l_comp_coupon.p_odd_coupon_maturity   := l_odd_coupon_maturity;
            l_comp_coupon.p_full_coupon           := l_no_quasi_coupon;
            l_comp_coupon.p_coupon_rate           := l_coupon_rate;
            l_comp_coupon.p_maturity_amount       := l_face_value_bal;  -- Remaining Face Value
            l_comp_coupon.p_precision             := l_precision;
            l_comp_coupon.p_rounding_type         := onc_det.rounding_type;
            l_comp_coupon.p_year_calc_type        := l_year_calc_type;
            l_comp_coupon.p_frequency             := l_frequency;
            l_comp_coupon.p_day_count_type        := onc_det.day_count_type;
            l_comp_coupon.p_amount_redemption_ind := 'A';

            l_adj_coupon_amt := XTR_MM_COVERS.CALC_COMPOUND_COUPON_AMT(l_comp_coupon);

         else
            l_adj_coupon_amt := l_face_value_bal * (l_coupon_rate/100)*(l_length_of_deal/l_yr_basis);
         end if;

         -- Bug 2422480 additions.
         -- In an attempt to minimize rounding issues, round the coupon amount
         -- based on the interest rounding of the bond issue.

         l_adj_coupon_amt := xtr_fps2_p.interest_round(l_adj_coupon_amt,l_rounding,onc_det.rounding_type);

         -- End 2422480 additions.
      end if;


      /*-----------------------------------------------------------*/
      /* 2. Determine TO DATE  (maturing_date , l_actual_maturity) */
      /*-----------------------------------------------------------*/

      ----------
      -- NI
      ----------
      if onc_det.deal_type ='NI' then
         if nvl(onc_det.deal_action_date,onc_det.date_to)<= p_end_date then

            maturing_date := nvl(onc_det.deal_action_date,onc_det.date_to);

            -- AW 2113171    -- Do not adjust if either maturity or resale within batch end date
            -- if onc_det.deal_action_date is not null then
               l_day_adjust_flag := 'N';
            -- end if;

         else
            maturing_date := p_end_date;
         end if;

      -----------------
      -- Bond Coupons
      -----------------
      elsif onc_det.deal_type = 'BOND' and l_amount_type = 'CPMADJ' then

         -----------------------------------------------------------------------------------------------
         -- Determine Start and End dates of the resale period.  This will differ from the batch start
         -- and batch end periods because resales occurring ona certain date will only affect
         -- interest accrual calculations starting on the day after the resale.
         -----------------------------------------------------------------------------------------------

         -- Changed for 2422480.

         If period_start = l_coupon_start then
            l_elig_resale_start := period_start + 1;
         Else
            l_elig_resale_start := period_start;
         End If;

         l_elig_resale_end := l_calc_period_end;

         -- End 2422480 changes.

/* 2422480
         if period_start = l_coupon_start then
            l_elig_resale_start := period_start;
         else
            l_elig_resale_start := period_start - 1;
         end if;

         if period_end = l_coupon_end then
            l_elig_resale_end := period_end;
         else
            l_elig_resale_end := period_end - 1;
         end if;
*/
      ----------------------------------------
      -- Others (exclude NI and BOND-Coupon)
      ----------------------------------------
      else
         -- AW 2113171    To handle ONC with no maturity date
         -- if onc_det.date_to < p_end_date then  -- old
         if onc_det.date_to <= p_end_date and onc_det.date_to is not null then

            maturing_date := onc_det.date_to;

         else
            maturing_date := p_end_date;

         end if;
      end if;

      l_actual_maturity := maturing_date;

      /*---------------------------------------------------------------------------------------------*/
      /* 3.  Day adjustment - Forward or Arrears (l_actual_start_date, deal_yr_basis, l_no_of_days)  */
      /*---------------------------------------------------------------------------------------------*/

      if not (onc_det.deal_type = 'BOND' and l_amount_type = 'CPMADJ') then

         -- AW Japan Project
         if onc_det.day_count_type='PRIOR' and maturing_date<>nvl(onc_det.date_to,p_end_date) and
            l_day_adjust_flag ='Y' then
         -- if l_days_adjust='PRIOR' and maturing_date<>nvl(onc_det.date_to,p_end_date) and l_day_adjust_flag ='Y' then

            if period_start < maturing_date then
               if onc_det.deal_type = 'BOND' then
                  XTR_CALC_P.CALC_DAYS_RUN_C(period_start - onc_det.forward_adjust,
                                             maturing_date,
                                             l_year_calc_type,
                                             l_frequency,
                                             l_no_of_days,
                                             deal_yr_basis,
                                             onc_det.forward_adjust,
                                             onc_det.day_count_type,  -- AW Japan Project
                                             null);                   -- AW Japan Project
               else
                  -- AW 2113171     To handle ONC with no maturity date
                  XTR_CALC_P.CALC_DAYS_RUN(period_start - onc_det.forward_adjust,
                                           maturing_date,
                                           l_year_calc_type,
                                           l_no_of_days,
                                           deal_yr_basis,
                                           onc_det.forward_adjust,
                                           onc_det.day_count_type,   -- AW Japan Project
                                           null);                    -- AW Japan Project
               end if;
            else
               -- AW 2113171  Similar to One day batch
               if onc_det.day_count_type = 'PRIOR' and period_start = maturing_date then
               -- if l_days_adjust = 'PRIOR' and period_start = maturing_date then
                  XTR_CALC_P.CALC_DAYS_RUN(period_start - onc_det.forward_adjust,
                                           maturing_date,
                                           l_year_calc_type,
                                           l_no_of_days,
                                           deal_yr_basis,
                                           onc_det.forward_adjust,
                                           onc_det.day_count_type,   -- AW Japan Project
                                           null);                    -- AW Japan Project
               else
                  l_no_of_days := 0;
               end if;
            end if;

            if l_no_of_days > l_length_of_deal then
               l_no_of_days := l_length_of_deal;
            end if;

         else
            if period_start < maturing_date then
               if onc_det.deal_type = 'BOND' then

                  if maturing_date <= onc_det.date_to then
                     -- AW 2113171   Do not adjust if matured
                     XTR_CALC_P.CALC_DAYS_RUN_C(period_start,
                                                maturing_date,
                                                l_year_calc_type,
                                                l_frequency,
                                                l_no_of_days,
                                                deal_yr_basis,
                                                null,
                                                onc_det.day_count_type,     -- AW Japan Project
                                                onc_det.first_trans_flag);  -- AW Japan Project
                  else
                     XTR_CALC_P.CALC_DAYS_RUN_C(period_start - onc_det.forward_adjust,
                                                maturing_date,
                                                l_year_calc_type,
                                                l_frequency,
                                                l_no_of_days,
                                                deal_yr_basis,
                                                onc_det.forward_adjust,
                                                onc_det.day_count_type,     -- AW Japan Project
                                                onc_det.first_trans_flag);  -- AW Japan Project

                  end if;
               else
                  if maturing_date <= onc_det.date_to and onc_det.date_to is not null then
                     -- AW 2113171    Do not adjust for matured deal
                     XTR_CALC_P.CALC_DAYS_RUN(period_start,
                                              maturing_date,
                                              l_year_calc_type,
                                              l_no_of_days,
                                              deal_yr_basis,
                                              null,
                                              onc_det.day_count_type,     -- AW Japan Project
                                              onc_det.first_trans_flag);  -- AW Japan Project

                  else
                     -- AW 2113171   To handle ONC with no maturity date
                     XTR_CALC_P.CALC_DAYS_RUN(period_start - onc_det.forward_adjust,
                                              maturing_date,
                                              l_year_calc_type,
                                              l_no_of_days,
                                              deal_yr_basis,
                                              onc_det.forward_adjust,
                                              onc_det.day_count_type,     -- AW Japan Project
                                              onc_det.first_trans_flag);  -- AW Japan Project
                  end if;

                  /* old
                  -- AW 2113171
                  -- Problem - this does not work for FXO
                  XTR_CALC_P.CALC_DAYS_RUN(period_start - l_forward_adjust,
                                           maturing_date,
                                           l_year_calc_type,
                                           l_no_of_days,
                                           deal_yr_basis,
                                           l_forward_adjust);
                  */

               end if;
            else
               -- AW Japan Project
               if onc_det.day_count_type = 'PRIOR' then
               -- if l_days_adjust = 'PRIOR' then
                  -- AW 2113171        Same day batch for all deal types need to adjust
                  XTR_CALC_P.CALC_DAYS_RUN(period_start - onc_det.forward_adjust,
                                           maturing_date,
                                           l_year_calc_type,
                                           l_no_of_days,
                                           deal_yr_basis,
                                           onc_det.forward_adjust,
                                           onc_det.day_count_type,  -- AW Japan Project
                                           null);                   -- AW Japan Project
               elsif onc_det.day_count_type = 'B' then              -- AW Japan Project
                  -- AW Japan Project
                  XTR_CALC_P.CALC_DAYS_RUN(period_start - onc_det.forward_adjust,
                                           maturing_date,
                                           l_year_calc_type,
                                           l_no_of_days,
                                           deal_yr_basis,
                                           onc_det.forward_adjust,
                                           onc_det.day_count_type,
                                           onc_det.first_trans_flag);
               else
                  l_no_of_days :=0;
               end if;
            end if;
         end if;

         deal_yr_basis := nvl(deal_yr_basis,365);

         l_actual_start_date := period_start;

      end if;


      /*------------------------------------------------------------------*/
      /* 5. Calculate accrued-to-date balance  (l_amount_to_accrue_amort) */
      /*------------------------------------------------------------------*/

      ---------------------------
      -- i) ONC, TMM, RTMM, IRS
      ---------------------------
      if onc_det.deal_type in ('ONC','TMM','RTMM','IRS') then


         if onc_det.deal_type = 'ONC' and onc_det.date_to is null then
            ----------------------------------------------------------------
            -- 2781438 (3450474)  separate for ONC without maturity date
            ----------------------------------------------------------------
            -- ONC deal without maturity date: always calculate Accrual Amt.
            ----------------------------------------------------------------
            l_amount_to_accrue_amort := xtr_fps2_p.interest_round(abs(onc_det.main_amount * onc_det.rate /
                                        (deal_yr_basis * 100) * l_no_of_days),l_rounding,onc_det.rounding_type);

         elsif onc_det.date_to > p_end_date then
            ----------------------------------------------------------------
            -- Deal not yet matured -- 2781438 (3450474)  Use overriden amount
            ----------------------------------------------------------------
            if l_length_of_deal > 0 and onc_det.override_amount is not null then
               if l_accrls_amount_bal > onc_det.override_amount then     -- Override amount exceeded
                  l_amount_to_accrue_amort := onc_det.override_amount;
               elsif l_accrls_amount_bal = onc_det.override_amount then  -- Override amount fully accrued
                  Goto NEXT_ACCRUAL_DEALS;
               else                                                      -- May have over-accrued, but not the full amount
                  l_amount_to_accrue_amort := xtr_fps2_p.interest_round(abs(onc_det.override_amount * l_no_of_days/
                                              l_length_of_deal),l_rounding,onc_det.rounding_type);
               end if;

            else
               l_amount_to_accrue_amort := 0;
            end if;

         else
            ----------------------------------------------------------
            -- AW Japan Project
            -- Deal matured
            ----------------------------------------------------------
            if onc_det.override_amount is not null then
               if l_accrls_amount_bal = onc_det.override_amount then   -- Override amount fully accrued
                  Goto NEXT_ACCRUAL_DEALS;
               else
                  l_amount_to_accrue_amort := onc_det.override_amount; -- Final accrual should be Override Amount
               end if;
            else
               l_amount_to_accrue_amort := xtr_fps2_p.interest_round(abs(onc_det.main_amount* l_length_of_deal *
                                           onc_det.rate / (l_yr_basis * 100)),l_rounding,onc_det.rounding_type);
            end if;
         end if;

         --------------------
         -- Reference Amount
         --------------------
         if onc_det.override_amount is null or (onc_det.deal_type = 'ONC' and onc_det.date_to is null) then
            -- AW Japan Project
            if onc_det.deal_type = 'ONC' then
               onc_det.main_amount := xtr_fps2_p.interest_round(abs(onc_det.main_amount*l_no_of_days*onc_det.rate/
                                      (l_yr_basis * 100)),l_rounding,onc_det.rounding_type);
            else
               onc_det.main_amount := xtr_fps2_p.interest_round(abs(onc_det.main_amount*l_length_of_deal*onc_det.rate/
                                      (l_yr_basis * 100)),l_rounding,onc_det.rounding_type);
            end if;
         else
            onc_det.main_amount := onc_det.override_amount;
         end if;

      -----------------------------
      -- ii) BDO, IRO, SWPTN, FXO
      -----------------------------
      elsif l_amount_type = 'PREMADJ' and onc_det.deal_type in('BDO','IRO','SWPTN','FXO') and
         onc_det.status_code in ('EXERCISED','EXPIRED') and
         nvl(onc_det.deal_action_date,onc_det.date_to) < p_end_date then

         l_amount_to_accrue_amort := onc_det.main_amount;

      ----------------------------------
      -- iii) Bond (Discount/Premium)
      ----------------------------------
      elsif onc_det.deal_type = 'BOND' and l_amount_type in ('SLDISC','SLPREM') then
         -------------------------------------------------------------------
         -- Calculate Total Amortize Disc/Prem for the Remaining Face Value.
         -------------------------------------------------------------------
         l_amount_to_accrue_amort := xtr_fps2_p.interest_round(abs(l_maturity_face_value *
                                          ((100-l_clean_price)/100)*(l_no_of_days/l_length_of_deal)),
                                                               l_rounding,onc_det.rounding_type);

         -------------------------------------------------------------------
         -- Calculate Period Amortize Disc/Prem for the Remaining Face Value.
         -------------------------------------------------------------------
         l_period_accrual_amount := nvl(l_amount_to_accrue_amort,0) - nvl(l_to_date_amort_amt_bal,0);

      -----------------------
      -- iv) Bond Coupons
      -----------------------
      elsif onc_det.deal_type = 'BOND' and l_amount_type = 'CPMADJ' then

         if l_elig_resale_start <= l_elig_resale_end then

            open  BOND_COUPON_RESALE;
            fetch BOND_COUPON_RESALE into resale_det;
            while BOND_COUPON_RESALE%FOUND loop

               -- Bug 2422480.
               -- Added logic to group adjustments for resales occuring on the same day into a single
               -- accrual row.  This will fix the issue with inability by subsequent batches to obtain
               -- the correct "accrued to date" balance when multiple resales occurs on the same day

               l_group_period_accrual_amt	:= 0;
               l_group_end_date			:= resale_det.cross_ref_start_date;
               l_group_period_start		:= period_start;

               -- Bug 2422480.  Testing Issue 2.
               -- Initialize coupon accrued to-date total amount.
               -- This is the amount to be displayed and stored in column accrls_amount_bal.

               l_to_date_amort_amt := 0;

               While (BOND_COUPON_RESALE%FOUND and l_group_end_date = resale_det.cross_ref_start_date)
               Loop

                  -- l_cum_ex is the purchase deal's coupon status.

                  if l_cum_ex <> 'CUM' then
                     -----------------------------------------------------------------------------------------
                     -- Current coupon amount unaffected.  But cumulative interest accounted for needs to be
                     -- adjusted by the resale interest allocated to the sale amount from the resale deal.
                     -----------------------------------------------------------------------------------------
                     l_accrls_amount_bal := l_accrls_amount_bal - resale_det.back_end_interest;
                  else
                     -----------------------------------------------------------------------------------------
                     -- Current coupon amount affected by resale.  Need to calc the interest up to this point
                     -- for the current coupon amount and adjust cumulative totals for subsequent processing.
                     -----------------------------------------------------------------------------------------

                     ------------------------------------------------------------------------
                     -- Determine ending date of the calc period and no of days between the
                     -- adjusted coupon start date and the calculation period end date.
                     ------------------------------------------------------------------------
                     l_calc_period_end := resale_det.cross_ref_start_date;

                     -- Bug 2422480 begin additions.
                     -- Do not adjust for extra day in coupon period when deal = 'First' and if calculation
                     -- period end = coupon end.  Otherwise, an extra day of interest will result for the
                     -- remaining face value and interest income will be overstated.

                     If (l_calc_period_end = l_coupon_end) then
                        l_adj_days := 0;
                     Else
                        l_adj_days := onc_det.forward_adjust;
                     End If;

                     -- End 2422480 additions.

                     if l_calc_type = 'COMPOUND COUPON' then

                        -------------------------------------------------------------------------
                        -- l_no_of_days = 'Accrual Date to Prev Coupon Date' for COMPOUND COUPON
                        -------------------------------------------------------------------------
                        if l_prev_coupon_date <= l_calc_period_end then  -- 2737823 prevent ERROR in accrual
                           XTR_CALC_P.CALC_DAYS_RUN_C(l_prev_coupon_date-l_adj_days, -- forward_adjust
                                                      l_calc_period_end,             -- 2737823 p_end_date
                                                      l_year_calc_type,
                                                      l_frequency,
                                                      l_no_of_days,
                                                      l_yr_basis,
                                                      onc_det.forward_adjust,
                                                      onc_det.day_count_type,      -- AW Japan Project
                                                      onc_det.first_trans_flag);   -- AW Japan Project
                        else
                           l_no_of_days := 0;
                        end if;

                        ---------------------------------------------------------------------------
                        -- Calc Total Accrued to date interest based on the pre-sale coupon amount.
                        ---------------------------------------------------------------------------
                        if nvl(l_no_of_days,0) <> 0 and nvl(l_length_of_deal,0) <> 0 then
                           l_num_current_coupon := l_no_of_days/l_length_of_deal;
                        else
                           ---------------------------------------------------------------------------
                           -- If Accrual End Date is on Coupon Date, then l_no_of_days = 0
                           ---------------------------------------------------------------------------
                           l_num_current_coupon := 0;
                        end if;

                        l_bond_rec.p_bond_commence         := l_bond_commence;
                        l_bond_rec.p_odd_coupon_start      := l_odd_coupon_start;
                        l_bond_rec.p_odd_coupon_maturity   := l_odd_coupon_maturity;
                        l_bond_rec.p_calc_date             := l_calc_period_end;   -- p_end_date ?????
                        l_bond_rec.p_yr_calc_type          := l_year_calc_type;
                        l_bond_rec.p_frequency             := l_frequency;
                        l_bond_rec.p_curr_coupon           := l_num_current_coupon;
                        l_bond_rec.p_prv_full_coupon       := l_num_full_cpn_previous;
                        l_bond_rec.p_day_count_type        := onc_det.day_count_type;
                        l_prv_quasi_coupon                 := 0;

                        l_prv_quasi_coupon      := XTR_MM_COVERS.CALC_TOTAL_PREVIOUS_COUPON(l_bond_rec);

                        l_calc_period_accrl_int :=(POWER(1+((l_coupon_rate/100)/l_frequency),l_prv_quasi_coupon)-1)*l_face_value_bal;

                     else


--2422480              XTR_CALC_P.CALC_DAYS_RUN_C(l_adj_coupon_start - onc_det.forward_adjust,
                        XTR_CALC_P.CALC_DAYS_RUN_C(onc_det.date_from - l_adj_days,
                                                   l_calc_period_end,
                                                   l_year_calc_type,
                                                   l_frequency,
                                                   l_no_of_days,
                                                   l_yr_basis,
                                                   onc_det.forward_adjust,
                                                   onc_det.day_count_type,      -- AW Japan Project
                                                   onc_det.first_trans_flag);   -- AW Japan Project

                        ---------------------------------------------------------------------------
                        -- Calc Total Accrued to date interest based on the pre-sale coupon amount.
                        ---------------------------------------------------------------------------
                        l_calc_period_accrl_int := (l_no_of_days/l_length_of_deal)*l_adj_coupon_amt;

                     end if;

                     ---------------------------------------------------------------------------------------
                     -- Determine the calculation period's accrued interest for the pre-sale coupon amount.
                     ---------------------------------------------------------------------------------------
                     l_period_accrual_amount := l_calc_period_accrl_int - l_accrls_amount_bal;

--2422480               ---------------------------------------------------------------------------------------
--2422480               -- Find the greater of l_calc_period_accrl_int and l_accrls_amount_bal
--2422480               ---------------------------------------------------------------------------------------
--2422480               l_accrls_amount_bal := greatest(l_calc_period_accrl_int , l_accrls_amount_bal);

                     -- Bug 2422480 additions begin.

                     -- Need to adjust for any differences between the resale interest and the accrued
                     -- interest calculated by the system.  Differences may occur due to different
                     -- day count and accrual basis defined for the bond issue.  However, do not adjust
                     -- if the resale occurs on the coupon's end date, because such a CUM resale will not
                     -- affect the coupon amount of a coupon maturing on its start date.

                     -- Adjust the accrual to-date amount to be based on the face value after the resale
                     -- by allocating the to-date accrued amount based on the pre-sale face vale.
                     -- The coupon's next periodic accrual amount will need to rely on this amount
                     -- in its calculations.  This adjustment is also necessary only if resale date <> coupon maturity.
                     -- Otherwise, the to-date amount calculated by the system should be used.

                     If (resale_det.cross_ref_start_date = l_coupon_end) then
                        l_accrls_amount_bal := l_calc_period_accrl_int;
                     Else

                        -- Calculate the accrued to date amount as calculated by the accrual process
                        -- for the resold portion of the face value.

                        l_to_date_resale_accrl_int := (resale_det.face_value/l_face_value_bal) * l_calc_period_accrl_int;
                        l_to_date_resale_accrl_int := xtr_fps2_p.interest_round(l_to_date_resale_accrl_int, l_rounding, onc_det.rounding_type);

                        -- Determine necessary adjustment amount between the amount accrued to date
                        -- as calculated by the accrual process vs. the actual resale interest
                        -- received by the buyer for the face value resold.

                        l_adj_amount := resale_det.back_end_interest - l_to_date_resale_accrl_int;

                        -- Apply the adjustment amount to the current period's periodic accrual
                        -- interest amount.  This would result in having the correct balance to be
                        -- reflected in the Interest Income GL account on the day of the resale.

                        l_period_accrual_amount := l_period_accrual_amount + l_adj_amount;

                        -- If deal has not been completely resold, adjust the accrual to-date amount to be based
                        -- on the face value after the resale by allocating the to-date accrued amount based on
                        -- the pre-sale face vale.  The coupon's next periodic accrual amount will need to rely
                        -- on this amount in its calculations.

                        If ((l_face_value_bal - resale_det.face_value) <> 0) then
                           l_accrls_amount_bal := ((l_face_value_bal - resale_det.face_value) / l_face_value_bal) * l_calc_period_accrl_int;
                        Else
                           l_accrls_amount_bal := l_calc_period_accrl_int + l_adj_amount;
                        End If;
                     End If;	-- resale start = coupon end.

                     -- Keep a running total of the periodic accrual amount for the l_calc_period_end_date.
                     -- This is to prevent creation of multiple accrual rows for the same period end date
                     -- when multiple resales occurs on the same day.

                     l_group_period_accrual_amt := l_group_period_accrual_amt + l_period_accrual_amount;

                     -- End Bug 2422480 additions.

                     -- Bug 2422480.
                     -- Added condition to perform adjustments only if the resale start date <> coupon maturity
                     -- and resale = CUM.  Because if the resale occurred on the coupon maturity and the resale = CUM,
                     -- the face value resold will only affect the value of the next coupon.  We do not want to
                     -- understate the accrued to date amount.

                     If (resale_det.coupon_action = 'CUM' and
                         resale_det.cross_ref_start_date <> l_coupon_end) then

                        ---------------------------------------------------------------------------------------
                        -- Adjust 'Calculation' face value of the deal for purpose of recalc the coupon amount.
                        ---------------------------------------------------------------------------------------
                        l_face_value_bal := l_face_value_bal - resale_det.face_value;

                        ----------------------------------------------------------------------------
                        -- Recalc the coupon amount based on the adjusted 'calculation' face value.
                        ----------------------------------------------------------------------------
                        if l_calc_type in ('FLAT COUPON','FL REGULAR') then --b 2804548
                           l_adj_coupon_amt := (l_face_value_bal * (l_coupon_rate/100))/l_frequency;

                        elsif l_calc_type = 'COMPOUND COUPON' then

                           l_comp_coupon.p_bond_start_date       := l_bond_commence;
                           l_comp_coupon.p_odd_coupon_start      := l_odd_coupon_start;
                           l_comp_coupon.p_odd_coupon_maturity   := l_odd_coupon_maturity;
                           l_comp_coupon.p_full_coupon           := l_no_quasi_coupon;
                           l_comp_coupon.p_coupon_rate           := l_coupon_rate;
                           l_comp_coupon.p_maturity_amount       := l_face_value_bal;  -- Remaining Face Value
                           l_comp_coupon.p_precision             := l_precision;
                           l_comp_coupon.p_rounding_type         := onc_det.rounding_type;
                           l_comp_coupon.p_year_calc_type        := l_year_calc_type;
                           l_comp_coupon.p_frequency             := l_frequency;
                           l_comp_coupon.p_day_count_type        := onc_det.day_count_type;
                           l_comp_coupon.p_amount_redemption_ind := 'A';

                           l_adj_coupon_amt := XTR_MM_COVERS.CALC_COMPOUND_COUPON_AMT(l_comp_coupon);

                        else
                           l_adj_coupon_amt := l_face_value_bal * (l_coupon_rate/100)*(l_length_of_deal/l_yr_basis);
                        end if;

                        -- Bug 2422480 addition.

                        l_adj_coupon_amt := xtr_fps2_p.interest_round(l_adj_coupon_amt, l_rounding, onc_det.rounding_type);

                        -- End bug 2422480 addition.
                     End If;

                     ------------------------------------
                     -- Line up the next period start
                     ------------------------------------
                     period_start := l_calc_period_end;
                  End If;	-- l_cum_ex <> 'CUM'.

                  Fetch BOND_COUPON_RESALE into resale_det;
               End Loop;	-- "group" processing of resales occuring on same date.

               -----------------------------------------------------------------------------
               -- Insert one summarized period accrued interest record for each cutoff date.
               -----------------------------------------------------------------------------
               -- AW 2113171    Do not display if both accrual amount and balance are zero.

               -- Bug 2422480.
               -- Changed the period_accrual_amt and period_start to use the "group" variables
               -- in both the conditions and insert statements.

               if xtr_fps2_p.interest_round(l_group_period_accrual_amt,l_rounding,onc_det.rounding_type)<>0 and
                  xtr_fps2_p.interest_round(l_accrls_amount_bal,l_rounding,onc_det.rounding_type)<>0 then
                  if l_group_period_start <= l_calc_period_end then

                     -- Bug 2422480.  Fixes Testing Issue 2.
                     -- Obtain accrued to-date amount for the entire coupon for purposes of displaying
                     -- the sum of it and the current periodic accrual amount as the "Balance" of the
                     -- accrued coupon interest.

                     -- This to-date amount is calculated thusly because it would be impossible to
                     -- properly update any pre-patchset J accrual records to reflect the amount for
                     -- the entire coupon.  Instead, a simple script will be included for bug 2422480
                     -- such that the amounts in the accrls_amount_bal column will be copied to the
                     -- effint_accrls_amount_bal for Bond Coupon records and all future internal
                     -- calculations will utilize the effint_accrls_amount_bal.

                     OPEN  GET_TOTAL_BOND_CPN_ACCRUAL;
                     FETCH GET_TOTAL_BOND_CPN_ACCRUAL into l_to_date_amort_amt;
                     CLOSE GET_TOTAL_BOND_CPN_ACCRUAL;

                     l_group_period_accrual_amt := xtr_fps2_p.interest_round(l_group_period_accrual_amt,l_rounding,onc_det.rounding_type);

                     l_to_date_amort_amt := nvl(l_to_date_amort_amt,0) + l_group_period_accrual_amt + nvl(l_dda_INT,0);

                     insert into XTR_ACCRLS_AMORT (BATCH_ID,            DEAL_NO,         TRANS_NO,
                                                   COMPANY_CODE,        DEAL_SUBTYPE,    DEAL_TYPE,      CURRENCY,
                                                   PERIOD_FROM,         PERIOD_TO,
                                                   CPARTY_CODE,         PRODUCT_TYPE,    PORTFOLIO_CODE,
                                                   INTEREST_RATE,       TRANSACTION_AMOUNT,
                                                   AMOUNT_TYPE,         ACTION_CODE,
                                                   ACCRLS_AMOUNT,
                                                   CALC_FACE_VALUE,
                                                   YEAR_BASIS,          FIRST_ACCRUAL_INDIC,
                                                   ACTUAL_START_DATE,   ACTUAL_MATURITY_DATE,
                                                   NO_OF_DAYS,          ACCRLS_AMOUNT_BAL,
                                                   EFFINT_ACCRLS_AMOUNT_BAL)
                                            values(l_batch_id,          onc_det.deal_nos,   onc_det.trans_nos,
                                                   p_company,           onc_det.subtype,    onc_det.deal_type,  onc_det.ccy,
                                                   l_group_period_start,
                                                   l_calc_period_end,
                                                   onc_det.cparty,      onc_det.product,    onc_det.portfolio,
                                                   onc_det.rate,        l_adj_coupon_amt,
                                                   'CPMADJ', decode(sign(l_group_period_accrual_amt),-1,'REV','POS'),
                                                   abs(l_group_period_accrual_amt),
                                                   l_face_value_bal,
                                                   l_yr_basis,          l_first_accrual_indic,
                                                   l_group_period_start,
                                                   l_calc_period_end,
                                                   l_no_of_days,
                                                   l_to_date_amort_amt,
                                                   xtr_fps2_p.interest_round(l_accrls_amount_bal,
                                                                             l_rounding,onc_det.rounding_type));
                  end if;	-- period_start <= l_calc_period_end.
               end if;		-- both period accrual and accrual to-date <> 0.

            End loop;	-- All eligible resales.

            close BOND_COUPON_RESALE;

         end if;	-- eligible resale start <= eligible resale end.

      --------------------------------
      -- v) NI Deal
      --    Also FRA, BDO, IRO, SWPTN    -- AW 1395208
      --------------------------------
      else
         if l_length_of_deal <> 0 then
            ----------------------------------------------------------------
            -- AW Japan Project - NI always use Overriden Amount for accrual
            ----------------------------------------------------------------
            l_amount_to_accrue_amort := xtr_fps2_p.interest_round(abs((onc_det.main_amount/l_length_of_deal)*l_no_of_days),l_rounding,onc_det.rounding_type);
         else
            l_amount_to_accrue_amort :=NULL;
         end if;

      end if;


      /*-----------------------------------------*/
      /* Period Accrual Amount   (l_action_code) */
      /*-----------------------------------------*/
       if onc_det.deal_type = 'BOND' then
          l_action_code := 'POS';

       else  -- Exclude BOND - CPMADJ
          l_period_accrual_amount := nvl(l_amount_to_accrue_amort,0)-nvl(l_accrls_amount_bal,0);

          if l_period_accrual_amount < 0 then
             l_action_code := 'REV';
             -------------------------------------------------------
             -- 2781438 (3450474) Reset the new accrual balance
             -------------------------------------------------------
             if onc_det.deal_type in ('ONC','TMM','RTMM','IRS') then
                l_accrls_amount_bal := l_amount_to_accrue_amort;
                if l_rev_exists = 'N' then
                   FND_MESSAGE.Set_Name ('XTR','XTR_ACCRUAL_REVERSAL');
                   FND_FILE.Put_Line (FND_FILE.LOG, FND_MESSAGE.Get);
                   l_rev_exists := 'Y';
                end if;
                l_rev_message := '    '||to_char(onc_det.deal_nos)||'/'||to_char(onc_det.trans_nos);
                FND_FILE.Put_Line (FND_FILE.LOG, l_rev_message);
             end if;
             -------------------------------------------------------

          else
             l_action_code := 'POS';
          end if;
       end if;


      /*--------------------*/
      /* 6. Create Accruals */
      /*--------------------*/

      -------------------------
      -- Bond Discount/Premium
      -------------------------
      if onc_det.deal_type = 'BOND' and l_amount_type in ('SLPREM','SLDISC') then

            ---------------------------------
            -- Check if REV has been created
            ---------------------------------
            l_deal_closed := 'N';
            open  chk_closed_deal;
            fetch chk_closed_deal into l_deal_closed;
            close chk_closed_deal;

            if l_deal_closed = 'N' then
               -----------------------------------------------
               -- Period Amort for the remaining Face Value.
               -----------------------------------------------

               -- AW 2113171    Do not display if both accrual amount and balance are zero.
               if l_period_accrual_amount <> 0 and l_amount_to_accrue_amort <> 0 then

                  insert into XTR_ACCRLS_AMORT (BATCH_ID, DEAL_NO,TRANS_NO,COMPANY_CODE,DEAL_SUBTYPE,
                                                DEAL_TYPE,CURRENCY,PERIOD_FROM,PERIOD_TO,
                                                CPARTY_CODE,PRODUCT_TYPE,PORTFOLIO_CODE,
                                                INTEREST_RATE,TRANSACTION_AMOUNT,AMOUNT_TYPE,
                                                ACTION_CODE,ACCRLS_AMOUNT,CALC_FACE_VALUE,YEAR_BASIS,
                                                FIRST_ACCRUAL_INDIC,ACTUAL_START_DATE,ACTUAL_MATURITY_DATE,
                                                NO_OF_DAYS,ACCRLS_AMOUNT_BAL)
                                         values(l_batch_id, onc_det.deal_nos,onc_det.trans_nos,p_company,
                                                onc_det.subtype,
                                                onc_det.deal_type,onc_det.ccy,
                                                decode(l_first_accrual_indic,'Y',period_start,
                                                       greatest(period_start,p_start_date)),
                                                least(onc_det.date_to,p_end_date),
                                                onc_det.cparty,onc_det.product,
                                                onc_det.portfolio,onc_det.rate,
                                                onc_det.main_amount,
                                                decode(sign(100-l_clean_price),-1,'SLPREM','SLDISC'),
                                                'POS',decode(l_maturity_face_value,0,0,abs(l_period_accrual_amount)),
                                                l_maturity_face_value,
                                                deal_yr_basis,l_first_accrual_indic,
                                                decode(l_first_accrual_indic,'Y',period_start,
                                                       greatest(period_start,p_start_date)),
                                                least(onc_det.date_to,p_end_date),
                                                l_no_of_days,l_amount_to_accrue_amort);
               end if;

               ---------------------------------------------------------------------------
               -- Deal Matured.  Reverse Cumulative Amort for the Remaining Face Value.
               ---------------------------------------------------------------------------
               if onc_det.date_to <= p_end_date and l_maturity_face_value <> 0 and
                  nvl(l_amount_to_accrue_amort,0) <> 0 then  -- 2753088,2751078 zero PREM/DISC REV for matured deal.

                  insert into XTR_ACCRLS_AMORT (BATCH_ID, DEAL_NO,TRANS_NO,COMPANY_CODE,DEAL_SUBTYPE,
                                                DEAL_TYPE,CURRENCY,PERIOD_FROM,PERIOD_TO,
                                                CPARTY_CODE,PRODUCT_TYPE,PORTFOLIO_CODE,
                                                INTEREST_RATE,TRANSACTION_AMOUNT,AMOUNT_TYPE,
                                                ACTION_CODE,ACCRLS_AMOUNT,CALC_FACE_VALUE,YEAR_BASIS,
                                                FIRST_ACCRUAL_INDIC,ACTUAL_START_DATE,ACTUAL_MATURITY_DATE,
                                                NO_OF_DAYS,ACCRLS_AMOUNT_BAL)
                                         values(l_batch_id, onc_det.deal_nos,onc_det.trans_nos,p_company,
                                                onc_det.subtype,
                                                onc_det.deal_type,onc_det.ccy,
                                                period_start, onc_det.date_to,
                                                onc_det.cparty,onc_det.product,
                                                onc_det.portfolio,onc_det.rate,
                                                onc_det.main_amount,
                                                decode(sign(100-l_clean_price),-1,'SLPREM','SLDISC'),
                                                'REV', l_amount_to_accrue_amort,
                                                l_maturity_face_value,
                                                deal_yr_basis,l_first_accrual_indic,
                                                period_start, onc_det.date_to,
                                                l_no_of_days,l_amount_to_accrue_amort);


               end if;
            end if; -- l_deal_closed = 'N'

      --------------------------
      -- Bond Coupons
      --------------------------
      elsif onc_det.deal_type = 'BOND' and l_amount_type = 'CPMADJ' then

            ---------------------------------------------------------------------------------------------------------
            -- Calc the accrued interest for the remainder of the batch period, based on the adjusted coupon amount.
            ---------------------------------------------------------------------------------------------------------

            -- Bug 2422480 addition.
            -- Process remainder of the batch period only if entire face value has not been resold.

            If (nvl(l_face_value_bal,0) <> 0) then

               if period_end = l_coupon_end then
                  l_adj_coupon_amt        := onc_det.main_amount;  -- rollover transaction interest
                  l_calc_period_accrl_int := onc_det.main_amount;  -- rollover transaction interest
               else
                  if l_calc_type = 'COMPOUND COUPON' then
                     -------------------------------------------------------------------------
                     -- l_no_of_days = 'Accrual Date to Prev Coupon Date' for COMPOUND COUPON
                     -------------------------------------------------------------------------
                     XTR_CALC_P.CALC_DAYS_RUN_C(l_prev_coupon_date - onc_det.forward_adjust,
                                                period_end,
                                                l_year_calc_type,
                                                l_frequency,
                                                l_no_of_days,
                                                l_yr_basis,
                                                onc_det.forward_adjust,
                                                onc_det.day_count_type,      -- AW Japan Project
                                                onc_det.first_trans_flag);   -- AW Japan Project

                     ---------------------------------------------------------------------------
                     -- Calc Total Accrued to date interest based on the remaining coupon amount.
                     ---------------------------------------------------------------------------
                     if nvl(l_no_of_days,0) <> 0 and nvl(l_length_of_deal,0) <> 0 then
                        l_num_current_coupon := l_no_of_days/l_length_of_deal;
                     else
                        ---------------------------------------------------------------------------
                        -- If Accrual End Date is on Coupon Date, then l_no_of_days = 0
                        ---------------------------------------------------------------------------
                        l_num_current_coupon := 0;
                     end if;

                     l_bond_rec.p_bond_commence         := l_bond_commence;
                     l_bond_rec.p_odd_coupon_start      := l_odd_coupon_start;
                     l_bond_rec.p_odd_coupon_maturity   := l_odd_coupon_maturity;
                     l_bond_rec.p_calc_date             := period_end;
                     l_bond_rec.p_yr_calc_type          := l_year_calc_type;
                     l_bond_rec.p_frequency             := l_frequency;
                     l_bond_rec.p_curr_coupon           := l_num_current_coupon;
                     l_bond_rec.p_prv_full_coupon       := l_num_full_cpn_previous;
                     l_bond_rec.p_day_count_type        := onc_det.day_count_type;
                     l_prv_quasi_coupon                 := 0;

                     l_prv_quasi_coupon      := XTR_MM_COVERS.CALC_TOTAL_PREVIOUS_COUPON(l_bond_rec);

                     l_calc_period_accrl_int :=(POWER(1+((l_coupon_rate/100)/l_frequency),l_prv_quasi_coupon)-1)*l_face_value_bal;

                  else

                     -- Replaced l_adj_coupon_start with onc_det.date_from for 2422480.

                     XTR_CALC_P.CALC_DAYS_RUN_C(onc_det.date_from - onc_det.forward_adjust,
                                                period_end,
                                                l_year_calc_type,
                                                l_frequency,
                                                l_no_of_days,
                                                deal_yr_basis,
                                                onc_det.forward_adjust,
                                                onc_det.day_count_type,      -- AW Japan Project
                                                onc_det.first_trans_flag);   -- AW Japan Project

                     l_calc_period_accrl_int := (l_no_of_days/l_length_of_deal) * l_adj_coupon_amt;

                  end if;

                  -- Bug 2422480 additions.

                  l_calc_period_accrl_int := xtr_fps2_p.interest_round(l_calc_period_accrl_int, l_rounding, onc_det.rounding_type);

                  -- End 2422480 additions.

               end if;

               l_period_accrual_amount := l_calc_period_accrl_int - l_accrls_amount_bal;
               l_period_accrual_amount := xtr_fps2_p.interest_round(l_period_accrual_amount,l_rounding,
                                                                    onc_det.rounding_type);
               ------------------------------------------------------------------------------------
               -- AW Japan Project - in case the overriden amount is less than system amount, need
               --                    to adjust the balance to use the overriden amount on maturity
               ------------------------------------------------------------------------------------
               if period_end = l_coupon_end then
                  l_accrls_amount_bal := onc_det.main_amount;
               else
                  l_accrls_amount_bal := l_calc_period_accrl_int;
               end if;

               -----------------------------------------------------------------------------------------
               -- Bug 2751078 - To balance total CPMADJ accruals amount on maturity.
               -----------------------------------------------------------------------------------------
               if l_bond_maturity = l_coupon_end and l_coupon_end <= period_end then
                  l_sum_prev_accrls := 0;
                  l_sum_backend_int := 0;

                  -----------------------------------------------------------------------------
                  -- (1) = Sum all previous CPMADJ accruals
                  -----------------------------------------------------------------------------
                  select nvl(sum(decode(ACTION_CODE,'REV',-1*ACCRLS_AMOUNT,ACCRLS_AMOUNT)),0)
                  into   l_sum_prev_accrls
                  from   xtr_accrls_amort
                  where  deal_no     = onc_det.deal_nos
                  and    trans_no    = onc_det.trans_nos
                  and    amount_type = 'CPMADJ'
                  and    action_code in ('POS','REV');

                  -----------------------------------------------------------------------------
                  -- (2) = (1) + BUY's INT if first coupon
                  -----------------------------------------------------------------------------
                  if onc_det.trans_nos = 2 and l_cum_ex = 'CUM' then
                     l_sum_prev_accrls := l_sum_prev_accrls + l_dda_INT;
                  end if;

                  -----------------------------------------------------------------------------
                  -- (3) = Sum all back end interest
                  -----------------------------------------------------------------------------
                  select nvl(sum(back_end_interest),0)
                  into   l_sum_backend_int
                  from   XTR_BOND_ALLOC_DETAILS
                  where  deal_no = onc_det.deal_nos
                  and    cross_ref_start_date <= period_end
                  and    cross_ref_start_date >= period_start; -- Bug 4613248 Added the condition

                  -----------------------------------------------------------------------------
                  -- (4) = (2) + current period accruals - (3)
                  -----------------------------------------------------------------------------
                  l_dummy := (l_sum_prev_accrls + l_period_accrual_amount) - l_sum_backend_int;

                  -------------------------------------------------------------------------------
                  -- Adjustment to current period accruals:
                  -- l_period_accrual_amount = difference between Remaining Coupon Amount and (4)
                  -------------------------------------------------------------------------------
                  if onc_det.main_amount <> l_dummy then
                     l_period_accrual_amount := l_period_accrual_amount + (onc_det.main_amount - l_dummy);
                  end if;
                  -----------------------------------------------------------------------------------------

               end if;

               -----------------------------------
               -- Accrued Interest for the coupon.
               -----------------------------------
               -- AW 2113171    Do not display if both accrual amount and balance are zero.
               if xtr_fps2_p.interest_round(l_period_accrual_amount,l_rounding,onc_det.rounding_type) <> 0 and
                  xtr_fps2_p.interest_round(l_accrls_amount_bal,l_rounding,onc_det.rounding_type) <> 0 then

                  -- Bug 2422480.  Fixes Testing Issue 2.
                  -- Calculate the total accrual to-date amount for the coupon to be displayed as 'Balance'.

                  OPEN  GET_TOTAL_BOND_CPN_ACCRUAL;
                  FETCH GET_TOTAL_BOND_CPN_ACCRUAL into l_to_date_amort_amt;
                  CLOSE GET_TOTAL_BOND_CPN_ACCRUAL;

                  l_to_date_amort_amt := nvl(l_to_date_amort_amt,0) + l_period_accrual_amount + nvl(l_dda_INT,0);

                  insert into XTR_ACCRLS_AMORT (BATCH_ID,            DEAL_NO,         TRANS_NO,
                                                COMPANY_CODE,        DEAL_SUBTYPE,    DEAL_TYPE,      CURRENCY,
                                                PERIOD_FROM,         PERIOD_TO,
                                                CPARTY_CODE,         PRODUCT_TYPE,    PORTFOLIO_CODE,
                                                INTEREST_RATE,       TRANSACTION_AMOUNT,
                                                AMOUNT_TYPE,         ACTION_CODE,
                                                ACCRLS_AMOUNT,
                                                CALC_FACE_VALUE,
                                                YEAR_BASIS,          FIRST_ACCRUAL_INDIC,
                                                ACTUAL_START_DATE,   ACTUAL_MATURITY_DATE,
                                                NO_OF_DAYS,          ACCRLS_AMOUNT_BAL,
                                                EFFINT_ACCRLS_AMOUNT_BAL)
                                         values(l_batch_id,          onc_det.deal_nos,   onc_det.trans_nos,
                                                p_company,           onc_det.subtype,    onc_det.deal_type, onc_det.ccy,
                                                period_start,
                                                period_end,
                                                onc_det.cparty,      onc_det.product,    onc_det.portfolio,
                                                onc_det.rate,        onc_det.main_amount, -- l_adj_coupon_amt, AW Japan
                                                'CPMADJ',
                                                decode(sign(l_period_accrual_amount),-1,'REV','POS'),   -- AW Japan Project
                                                abs(xtr_fps2_p.interest_round(abs(l_period_accrual_amount),    -- AW Japan Project
                                                                          l_rounding,onc_det.rounding_type)),
                                                l_face_value_bal,
                                                l_yr_basis,          l_first_accrual_indic,
                                                period_start,
                                                period_end,
                                                l_no_of_days,
                                                l_to_date_amort_amt,
                                                xtr_fps2_p.interest_round(l_accrls_amount_bal,
                                                                          l_rounding,onc_det.rounding_type));
               end if;
            End If;	-- only if remaining face <> 0.
      else

         if NOT (nvl(l_period_accrual_amount,0) = 0 and nvl(l_amount_to_accrue_amort,0) =0 ) then

            ------------
            -- NI
            ------------
            if onc_det.deal_type = 'NI' and
             ((onc_det.status_code = 'CLOSED' and onc_det.deal_action_date <= p_end_date) or
              (onc_det.date_to <= p_end_date)) then -- Bug 1717213 AW

               ---------------------------------
               -- Check if REV has been created
               ---------------------------------
               l_deal_closed :='N';
               open  chk_closed_deal;
               fetch chk_closed_deal into l_deal_closed;
               close chk_closed_deal;

               if nvl(l_deal_closed,'N') ='N' then
                  if nvl(l_period_accrual_amount,0) <> 0 then
                     insert into XTR_ACCRLS_AMORT (BATCH_ID, DEAL_NO,TRANS_NO,COMPANY_CODE,DEAL_SUBTYPE,
                                                   DEAL_TYPE,CURRENCY,PERIOD_FROM,PERIOD_TO,
                                                   CPARTY_CODE,PRODUCT_TYPE,PORTFOLIO_CODE,
                                                   INTEREST_RATE,TRANSACTION_AMOUNT,AMOUNT_TYPE,
                                                   ACTION_CODE,ACCRLS_AMOUNT,YEAR_BASIS,
                                                   FIRST_ACCRUAL_INDIC,ACTUAL_START_DATE,ACTUAL_MATURITY_DATE,
                                                   NO_OF_DAYS,ACCRLS_AMOUNT_BAL)
                                            values(l_batch_id, onc_det.deal_nos,onc_det.trans_nos,p_company,
                                                   onc_det.subtype,
                                                   onc_det.deal_type,onc_det.ccy,p_start_date,l_actual_maturity,
                                                 --onc_det.deal_type,onc_det.ccy,p_start_date,p_end_date,
                                                   onc_det.cparty,onc_det.product,
                                                   onc_det.portfolio,onc_det.rate,
                                                   onc_det.main_amount,onc_det.main_amt_type,
                                                   l_action_code, abs(l_period_accrual_amount),
                                                   deal_yr_basis,l_first_accrual_indic,
                                                   l_actual_start_date,l_actual_maturity,
                                                   l_no_of_days,l_amount_to_accrue_amort);
                  end if;
                  if nvl(l_amount_to_accrue_amort,0) <> 0 then
                     insert into XTR_ACCRLS_AMORT (BATCH_ID,DEAL_NO,TRANS_NO,COMPANY_CODE,DEAL_SUBTYPE,
                                                   DEAL_TYPE,CURRENCY,PERIOD_FROM,PERIOD_TO,
                                                   CPARTY_CODE,PRODUCT_TYPE,PORTFOLIO_CODE,
                                                   INTEREST_RATE,TRANSACTION_AMOUNT,AMOUNT_TYPE,
                                                   ACTION_CODE,ACCRLS_AMOUNT,YEAR_BASIS,
                                                   FIRST_ACCRUAL_INDIC,ACTUAL_START_DATE,ACTUAL_MATURITY_DATE,
                                                   NO_OF_DAYS,ACCRLS_AMOUNT_BAL)
                                            values(l_batch_id,onc_det.deal_nos,onc_det.trans_nos,
                                                   p_company,onc_det.subtype,
                                                   onc_det.deal_type,onc_det.ccy,p_start_date,l_actual_maturity,
                                                 --onc_det.deal_type,onc_det.ccy,p_start_date,p_end_date,
                                                   onc_det.cparty,onc_det.product,
                                                   onc_det.portfolio,onc_det.rate,
                                                   onc_det.main_amount,onc_det.main_amt_type,
                                                   decode(sign(l_amount_to_accrue_amort),-1,'POS','REV'),
                                                   abs(l_amount_to_accrue_amort),
                                                   deal_yr_basis,l_first_accrual_indic,l_actual_start_date,
                                                   l_actual_maturity,
                                                   l_no_of_days,0);
                  end if;
               end if;

            -----------
            -- Others
            -----------
            else

               if nvl(l_period_accrual_amount,0) <> 0  then
                  insert into XTR_ACCRLS_AMORT (BATCH_ID,DEAL_NO,TRANS_NO,COMPANY_CODE,
                                                DEAL_SUBTYPE, DEAL_TYPE,CURRENCY,PERIOD_FROM,PERIOD_TO,
                                                CPARTY_CODE,PRODUCT_TYPE,PORTFOLIO_CODE,
                                                INTEREST_RATE,TRANSACTION_AMOUNT,AMOUNT_TYPE,
                                                ACTION_CODE,ACCRLS_AMOUNT,YEAR_BASIS,
                                                FIRST_ACCRUAL_INDIC,ACTUAL_START_DATE,ACTUAL_MATURITY_DATE,
                                                NO_OF_DAYS,ACCRLS_AMOUNT_BAL)
                                         values(l_batch_id,onc_det.deal_nos,onc_det.trans_nos,
                                                p_company,onc_det.subtype,
                                                onc_det.deal_type,onc_det.ccy,p_start_date,
                                                nvl(l_actual_maturity,p_end_date),                         --Bug 2416970
                                              --decode(onc_det.deal_type,'NI',l_actual_maturity,p_end_date), Bug 2416970
                                              --onc_det.deal_type,onc_det.ccy,p_start_date,p_end_date,
                                                onc_det.cparty,onc_det.product,
                                                onc_det.portfolio,onc_det.rate,
                                                onc_det.main_amount,onc_det.main_amt_type,
                                                l_action_code,abs(l_period_accrual_amount),
                                                deal_yr_basis,l_first_accrual_indic,
                                                l_actual_start_date,l_actual_maturity,
                                                l_no_of_days,l_amount_to_accrue_amort);
               end if;
            end if;
         end if;
      end if;
      --

      <<NEXT_ACCRUAL_DEALS>>

      fetch ACCRUAL_DEALS INTO onc_det;

   END LOOP;

   close ACCRUAL_DEALS;

   /* -------------------------------------------------------*/
   /*   Accruals for Intergroup Transfers and Bank Balances  */
   /* -------------------------------------------------------*/
      XTR_ACCRUAL_PROCESS_P.CALC_INTGROUP_CACCT_ACCLS(p_company,l_batch_id,p_start_date,p_end_date,'%');


   /*-----------------------------------*/
   /* Wait the correct effective mothod */
   /*-----------------------------------*/
   -- XTR_ACCRUAL_PROCESS_P.CALCULATE_BOND_AMORTISATION(p_company,p_start_date,p_end_date,'%');


   /* --------------------------------------------*/
   /* NI accruals using effective interest method */
   /* --------------------------------------------*/
      XTR_ACCRUAL_PROCESS_P.CALCULATE_NI_EFFINT(p_company,l_batch_id,p_batch_id,p_start_date,p_end_date);

end if;


   -------------------------------------------------------------------------------
   -- Insert row to XTR_BATCH_EVENTS table after generating Accrual for the Batch
   -------------------------------------------------------------------------------
   open  EVENT_ID;
   fetch EVENT_ID into l_event_id;
   cLose EVENT_ID;

   insert into XTR_BATCH_EVENTS(batch_event_id, batch_id,event_code, authorized,
                                authorized_by, authorized_on, created_by, creation_date, last_updated_by,
                                last_update_date, last_update_login)
                        values (l_event_id, l_batch_id, 'ACCRUAL', decode(p_upgrade_batch,'I','Y','N'),
                                null, null, fnd_global.user_id,
                                l_sysdate, fnd_global.user_id, l_sysdate, fnd_global.login_id);


   COMMIT;


   EXCEPTION
      when ex_reval_auth then
         ROLLBACK TO SAVEPOINT sp_accrual;
         retcode := -1;
         FND_MESSAGE.Set_Name('XTR', 'XTR_REVAL_AUTH');
         FND_MESSAGE.Set_Token('BATCH', p_batch_id);
         APP_EXCEPTION.Raise_exception;
      when others then
         ROLLBACK TO SAVEPOINT sp_accrual;
         retcode := -1;
         RAISE;


end CALCULATE_ACCRUAL_AMORTISATION;
-----------------------------------------------------------------------------------------------------------------------
PROCEDURE CALC_INTGROUP_CACCT_ACCLS (p_company IN VARCHAR2,
                                     p_batch_id IN NUMBER,
                                     p_start_date IN DATE,
                                     p_end_date IN DATE,
                                     p_deal_type IN VARCHAR2) is
--
  l_days_adjust            VARCHAR2(100);
  l_year                   NUMBER := 365;
  l_subtype                VARCHAR2(7);
  l_amount_to_accrue_amort NUMBER;
  l_period_accrual_amount  NUMBER;
  calc_days                NUMBER;
  l_deal_nos               NUMBER;
  l_trans_nos              NUMBER;
  l_int_rate               NUMBER;
  l_rounding               NUMBER;
  l_ccy                    VARCHAR2(15);
  l_start_interest         NUMBER;
  l_maturity_interest      NUMBER;
  l_hce_rate               NUMBER := 1;
  l_product_type           VARCHAR2(10);
  l_year_calc_type         VARCHAR2(15);
  l_accrls_amount_bal      NUMBER;
  l_first_accrual_indic    VARCHAR2(1);
  l_deal_type              VARCHAR2(7);
  l_actual_end_date        DATE;
  l_forward_adjust         NUMBER;
  l_oldest_date            DATE;
  l_oldest_tran            NUMBER;
  l_first_tran             VARCHAR2(1);
  l_prv_subtype   XTR_ACCRLS_AMORT.DEAL_SUBTYPE%TYPE;

  -----------------------------------------------------------------------------
  -- Get accrual methods Interest in arreas(Following), Forward interest(Prior).
  -----------------------------------------------------------------------------
  cursor ADJUST(p_param_name varchar2) is
  select PARAM_VALUE
  from   XTR_PRO_PARAM
  where  PARAM_NAME = p_param_name;

  ---
  cursor CHK_FIRST_ACCRUAL is
  select 'N'
  from   XTR_ACCRLS_AMORT
  where  deal_no   = l_deal_nos
  and    deal_type = l_deal_type;
  --

  cursor GET_PRV_BAL is
  select nvl(ACCRLS_AMOUNT_BAL,0) accrls_bal, deal_subtype   -- 3866372 to get previous deal subtype
  from   XTR_ACCRLS_AMORT
  where  deal_no     = l_deal_nos
  and    deal_type   = l_deal_type
  and    amount_type = 'INTADJ'
  and    action_code = 'POS'
  and    period_to   < p_end_date
  order by period_to desc;


  cursor RND_FAC is
  select s.ROUNDING_FACTOR,s.YEAR_BASIS,s.HCE_RATE,s.IG_YEAR_BASIS
  from   XTR_MASTER_CURRENCIES_V s
  where  s.CURRENCY = l_ccy;


  ------------------------------------
  -- Accruals for Intergroup Transfers
  ------------------------------------
  cursor IG is
  select i.COMPANY_CODE,
         i.PARTY_CODE cparty,
         i.PORTFOLIO portfolio_code,
         i.PRODUCT_TYPE,
         i.TRANSFER_DATE balance_date,
         i.CURRENCY,
         nvl(i.BALANCE_OUT,0) bal_out,   -- AW 2113171  Use abs(i.BALANCE_OUT) to avoid negative IG balance ???
         nvl(i.ACCRUAL_INTEREST,0)         main_amount,
         nvl(i.INTEREST_RATE,0)            int_rate,
         i.TRANSACTION_NUMBER,
         i.DEAL_NUMBER,
         decode(i.DAY_COUNT_TYPE,'F','PRIOR','L','FOLLOWING','B') day_count_type,  -- AW Japan Project
         nvl(i.ROUNDING_TYPE,'R')                                 rounding_type,   -- AW Japan Project
         decode(nvl(i.DAY_COUNT_TYPE,'L'),'F',1,0)                forward_adjust   -- AW Japan Project
  from   XTR_INTERGROUP_TRANSFERS i
  where  i.COMPANY_CODE = p_company
  and    i.TRANSACTION_NUMBER =
         (select max(k.TRANSACTION_NUMBER)
          from   XTR_INTERGROUP_TRANSFERS k
          where  k.COMPANY_CODE = i.COMPANY_CODE
          and    k.PARTY_CODE = i.PARTY_CODE
          and    k.CURRENCY = i.CURRENCY
          and    k.TRANSFER_DATE =
                  (select max(j.TRANSFER_DATE)
                   from   XTR_INTERGROUP_TRANSFERS j
                   where  j.TRANSFER_DATE <= p_end_date
                   and    j.COMPANY_CODE = i.COMPANY_CODE
                   and    j.PARTY_CODE = i.PARTY_CODE
                   and    j.CURRENCY = i.CURRENCY))
  order by i.CURRENCY;

  ig_det IG%ROWTYPE;


  ------------------------------------
  -- Accruals for Company Bank Charges
  ------------------------------------
  cursor BK_CHARGE is
  select b.COMPANY_CODE,
         b.ACCOUNT_NUMBER,
         b.BALANCE_DATE,
         a.CURRENCY,
         a.BANK_CODE cparty,
         nvl(b.accrual_interest,0) main_amount,
         b.INTEREST_RATE int_rate,
         nvl(b.statement_balance,0)+nvl(b.balance_adjustment,0) bal_out,
         a.portfolio_code,
         nvl(a.year_calc_type,'ACTUAL/ACTUAL') year_calc_type,
         decode(b.DAY_COUNT_TYPE,'F','PRIOR','L','FOLLOWING','B') day_count_type,  -- AW Japan Project
         nvl(b.ROUNDING_TYPE,'R')                                 rounding_type,   -- AW Japan Project
         decode(nvl(b.DAY_COUNT_TYPE,'L'),'F',1,0)                forward_adjust   -- AW Japan Project
  from   XTR_BANK_ACCOUNTS a,
         XTR_BANK_BALANCES b
  where  b.COMPANY_CODE   = p_company
  and    a.ACCOUNT_NUMBER = b.ACCOUNT_NUMBER
  and    a.PARTY_CODE     = b.COMPANY_CODE
--and    nvl(a.SETOFF_ACCOUNT_YN,'N') <> 'Y'
  and    b.BALANCE_DATE = (select max(c.BALANCE_DATE)
                           from   XTR_BANK_BALANCES c
                           where  c.BALANCE_DATE  <= p_end_date
                           and    c.COMPANY_CODE   = b.COMPANY_CODE
                           and    c.ACCOUNT_NUMBER = b.ACCOUNT_NUMBER)
  order by a.CURRENCY,a.ACCOUNT_NUMBER;

  bk_det BK_CHARGE%ROWTYPE;

  --
  cursor CA_DEAL_NUM(v_account_number varchar2,v_currency varchar2) is
  select DEAL_NUMBER,TRANSACTION_NUMBER,PRODUCT_TYPE
  from   XTR_DEAL_DATE_AMOUNTS_V
  where  DEAL_TYPE    = 'CA'
--and    AMOUNT_TYPE  = 'BAL'
  and    ACCOUNT_NO   = v_account_number
  and    CURRENCY     = v_currency
  and    COMPANY_CODE = p_company;

  ------------------------------------
  -- Oldest IG Transaction
  ------------------------------------
  cursor IG_OLDEST (v_deal_no  NUMBER) is
  select TRANSFER_DATE
  from   XTR_INTERGROUP_TRANSFERS
  where  DEAL_NUMBER = v_deal_no
  order by TRANSFER_DATE;

  ------------------------------------
  -- Oldest CA Transaction
  ------------------------------------
  cursor CA_OLDEST (v_acct_no VARCHAR2, v_ccy VARCHAR2, v_comp VARCHAR2) is
  select b.BALANCE_DATE
  from   XTR_BANK_ACCOUNTS a,
         XTR_BANK_BALANCES b
  where  b.COMPANY_CODE   = v_comp
  and    a.PARTY_CODE     = v_comp
  and    a.ACCOUNT_NUMBER = v_acct_no
  and    a.CURRENCY       = v_ccy
  and    a.ACCOUNT_NUMBER = b.ACCOUNT_NUMBER
  order by BALANCE_DATE;

begin

   /* AW Japan Project - select from IG and CA table.
   open  ADJUST('ACCRUAL_DAYS_ADJUST');
   fetch ADJUST INTO l_days_adjust;
   close ADJUST;

   l_days_adjust :=nvl(l_days_adjust,'FOLLOWING');

   if l_days_adjust ='PRIOR' then
      l_forward_adjust := 1;
      --l_actual_end_date := p_end_date + 1;
   else
      l_forward_adjust := 0;
      --l_actual_end_date := p_end_date;
   end if;
   ----------------------------------------------------*/

   l_actual_end_date := p_end_date;

   ----------------------------------------------------------------------
   -- Calculate Accrual/Amortisation adustjments for Intergroup Transfers
   ----------------------------------------------------------------------
   open IG;
   l_ccy       := NULL;
   l_deal_type :='IG';
   l_year_calc_type := null;
   LOOP
      fetch IG INTO ig_det;
      EXIT WHEN IG%NOTFOUND;

      l_deal_nos  := ig_det.deal_number;
      l_trans_nos := ig_det.transaction_number;


      if l_ccy is NOT NULL then
          ------------------------------------------------------------------
         --  IG compound issue - causes the wrong year_calc_type
         ------------------------------------------------------------------
         if l_ccy <> ig_det.currency then
            l_ccy := ig_det.currency;
         end if;
            open  RND_FAC;
            fetch RND_FAC INTO l_rounding,l_year,l_hce_rate,l_year_calc_type;
            if RND_FAC%NOTFOUND then
               l_year     := 365;
               l_rounding := 2;
            end if;
            close RND_FAC;
   --       end if;
      else
         l_ccy := ig_det.currency;
         open  RND_FAC;
         fetch RND_FAC INTO l_rounding,l_year,l_hce_rate,l_year_calc_type;
         if RND_FAC%NOTFOUND then
            l_year     := 365;
            l_rounding := 2;
         end if;
         close RND_FAC;
      end if;

      l_year_calc_type :=nvl(l_year_calc_type,'ACTUAL/ACTUAL');

      l_first_accrual_indic :='Y';

      open  CHK_FIRST_ACCRUAL;
      fetch CHK_FIRST_ACCRUAL into l_first_accrual_indic;
      close CHK_FIRST_ACCRUAL;

      ----------------------------- AW Japan Project  --------------------------------------------
      open  IG_OLDEST(ig_det.deal_number);
      fetch IG_OLDEST into l_oldest_date;
      close IG_OLDEST;
      if l_oldest_date = ig_det.balance_date and ig_det.day_count_type = 'B' then
         l_first_tran := 'Y';
      else
         l_first_tran := 'N';
      end if;
      --------------------------------------------------------------------------------------------

      if ig_det.balance_date = l_actual_end_date then
         -- l_amount_to_accrue_amort:= nvl(ig_det.main_amount,0);

         -- AW 2113171     To handle FORWARD calculation
         if ig_det.day_count_type = 'PRIOR' or l_first_tran = 'Y' then                -- AW Japan Project
            XTR_CALC_P.CALC_DAYS_RUN(ig_det.balance_date - ig_det.forward_adjust,     -- AW Japan Project
                                     l_actual_end_date,
                                     l_year_calc_type,
                                     calc_days,
                                     l_year,
                                     ig_det.forward_adjust,                           -- AW Japan Project
                                     ig_det.day_count_type,                           -- AW Japan Project
                                     l_first_tran);                                   -- AW Japan Project
            l_amount_to_accrue_amort := nvl(ig_det.main_amount,0) +
                                        xtr_fps2_p.interest_round(ig_det.bal_out * (ig_det.int_rate / 100) / l_year * calc_days,l_rounding,ig_det.rounding_type);
         else
            l_amount_to_accrue_amort:= nvl(ig_det.main_amount,0);
         end if;
      else
         -- AW 2113171     To handle FORWARD calculation
         XTR_CALC_P.CALC_DAYS_RUN(ig_det.balance_date - ig_det.forward_adjust,     -- AW Japan Project
                                  l_actual_end_date,
                                  l_year_calc_type,
                                  calc_days,
                                  l_year,
                                  ig_det.forward_adjust,                           -- AW Japan Project
                                  ig_det.day_count_type,                           -- AW Japan Project
                                  l_first_tran);                                   -- AW Japan Project
         l_amount_to_accrue_amort := nvl(ig_det.main_amount,0) +
                                     xtr_fps2_p.interest_round(ig_det.bal_out *
                                    (ig_det.int_rate / 100) / l_year * calc_days,l_rounding,ig_det.rounding_type);
      end if;

      l_accrls_amount_bal :=0;
      open  get_prv_bal;
      fetch get_prv_bal into l_accrls_amount_bal, l_prv_subtype;    -- bug 3866372
      close get_prv_bal;

      l_period_accrual_amount := nvl(l_amount_to_accrue_amort,0)-nvl(l_accrls_amount_bal,0);

      if l_period_accrual_amount < 0 then
           l_subtype := 'FUND';
      elsif  l_period_accrual_amount > 0 then
           l_subtype := 'INVEST';
      else
          l_subtype := nvl(l_prv_subtype,'INVEST');
      end if;


      if l_period_accrual_amount  <> 0 then
          insert into XTR_ACCRLS_AMORT (BATCH_ID,DEAL_NO,TRANS_NO,COMPANY_CODE,DEAL_SUBTYPE,
                                        DEAL_TYPE,CURRENCY,PERIOD_FROM,PERIOD_TO,
                                        CPARTY_CODE,PRODUCT_TYPE,PORTFOLIO_CODE,
                                        INTEREST_RATE,TRANSACTION_AMOUNT,AMOUNT_TYPE,
                                        ACTION_CODE,ACCRLS_AMOUNT,YEAR_BASIS,
                                        FIRST_ACCRUAL_INDIC,ACTUAL_START_DATE,ACTUAL_MATURITY_DATE,
                                        NO_OF_DAYS,ACCRLS_AMOUNT_BAL)
                                 values(p_batch_id,l_deal_nos,l_trans_nos,p_company,l_subtype,
                                        'IG',ig_det.currency,p_start_date,p_end_date,
                                        ig_det.cparty,ig_det.product_type,
                                        ig_det.portfolio_code,ig_det.int_rate,
                                        abs(l_period_accrual_amount),'INTADJ', -- AW 2113171 Display same as accrl amt
                                      --ig_det.main_amount,'INTADJ',
                                        'POS',abs(l_period_accrual_amount),
                                        l_year,l_first_accrual_indic,
                                        ig_det.balance_date,l_actual_end_date,
                                        calc_days,l_amount_to_accrue_amort);
      end if;
   END LOOP;
   close IG;

   ---------------------------------------------------------
   -- Calulate accrual adjustments for Company Bank Accounts
   ---------------------------------------------------------
   open BK_CHARGE;
   l_ccy       := NULL;
   l_deal_type := 'CA';
   LOOP
      fetch BK_CHARGE INTO bk_det;
      EXIT WHEN BK_CHARGE%NOTFOUND;
      if l_ccy is NOT NULL then
         if l_ccy <> bk_det.currency then
            l_ccy := bk_det.currency;
            open  RND_FAC;
            fetch RND_FAC INTO l_rounding,l_year,l_hce_rate,l_year_calc_type;
            if RND_FAC%NOTFOUND then
               l_year     := 365;
               l_rounding := 2;
            end if;
            close RND_FAC;
         end if;
      else
         l_ccy := bk_det.currency;
         open  RND_FAC;
         fetch RND_FAC INTO l_rounding,l_year,l_hce_rate,l_year_calc_type;
         if RND_FAC%NOTFOUND then
            l_year     := 365;
            l_rounding := 2;
         end if;
         close RND_FAC;
      end if;

      l_deal_nos     := null;
      l_trans_nos    := null;
      l_product_type := null;

      open  CA_DEAL_NUM(bk_det.account_number,bk_det.currency);
      fetch CA_DEAL_NUM into l_deal_nos,l_trans_nos,l_product_type;
      close CA_DEAL_NUM;

      l_first_accrual_indic :='Y';
      open  CHK_FIRST_ACCRUAL;
      fetch CHK_FIRST_ACCRUAL into l_first_accrual_indic;
      close CHK_FIRST_ACCRUAL;

      ----------------------------- AW Japan Project  --------------------------------------------
      open  CA_OLDEST(bk_det.account_number, bk_det.currency, bk_det.company_code);
      fetch CA_OLDEST into l_oldest_date;
      close CA_OLDEST;
      if l_oldest_date = bk_det.balance_date and bk_det.day_count_type = 'B' then
         l_first_tran := 'Y';
      else
         l_first_tran := 'N';
      end if;
      --------------------------------------------------------------------------------------------

      if bk_det.balance_date = l_actual_end_date then
         -- l_amount_to_accrue_amort:= nvl(bk_det.main_amount,0);

         -- AW 2113171     To handle FORWARD calculation
         if bk_det.day_count_type = 'PRIOR' or l_first_tran = 'Y' then             -- AW Japan Project
            XTR_CALC_P.CALC_DAYS_RUN(bk_det.balance_date - bk_det.forward_adjust,  -- AW Japan Project
                                     l_actual_end_date,
                                     bk_det.year_calc_type,
                                     calc_days,
                                     l_year,
                                     bk_det.forward_adjust,                        -- AW Japan Project
                                     bk_det.day_count_type,                        -- AW Japan Project
                                     l_first_tran);                                -- AW Japan Project
            l_amount_to_accrue_amort := nvl(bk_det.main_amount,0) +
                                        xtr_fps2_p.interest_round(bk_det.bal_out *
                                       (bk_det.int_rate / 100) / l_year * calc_days,l_rounding,bk_det.rounding_type);
            --AW 2113171  Displays the Ref Amount similar to Arrear method
            --AW 2113171  if bk_det.main_amount = 0 or p_start_date = p_end_date then
            --AW 2113171     bk_det.main_amount := l_amount_to_accrue_amort;
            --AW 2113171  end if;
         else
            l_amount_to_accrue_amort:= nvl(bk_det.main_amount,0);
         end if;
      else
         -- AW 2113171     To handle FORWARD calculation
         XTR_CALC_P.CALC_DAYS_RUN(bk_det.balance_date - bk_det.forward_adjust,  -- AW Japan Project
                                  l_actual_end_date,
                                  bk_det.year_calc_type,
                                  calc_days,
                                  l_year,
                                  bk_det.forward_adjust,                        -- AW Japan Project
                                  bk_det.day_count_type,                        -- AW Japan Project
                                  l_first_tran);                                -- AW Japan Project

         l_amount_to_accrue_amort := nvl(bk_det.main_amount,0) +
                                     xtr_fps2_p.interest_round(bk_det.bal_out *
                                    (bk_det.int_rate / 100) / l_year * calc_days,l_rounding,bk_det.rounding_type);
            --AW 2113171  Displays the Ref Amount similar to Arrear method -- Should this be here too ????
            --AW 2113171  if bk_det.main_amount = 0 or p_start_date = p_end_date then
            --AW 2113171     bk_det.main_amount := l_amount_to_accrue_amort;
            --AW 2113171  end if;
      end if;

      l_accrls_amount_bal :=0;
      open  get_prv_bal;
      fetch get_prv_bal into l_accrls_amount_bal,l_prv_subtype;
      close get_prv_bal;
      l_period_accrual_amount := nvl(l_amount_to_accrue_amort,0)-nvl(l_accrls_amount_bal,0);

-- bug 3866372
      if l_period_accrual_amount < 0 then
           l_subtype := 'FUND';
      elsif l_period_accrual_amount > 0 then
           l_subtype := 'INVEST';
      else
          l_subtype := nvl(l_prv_subtype,'INVEST');
      end if;


      if l_period_accrual_amount  <> 0  and l_deal_nos is not null then
          insert into XTR_ACCRLS_AMORT (BATCH_ID,DEAL_NO,TRANS_NO,COMPANY_CODE,DEAL_SUBTYPE,
                                        DEAL_TYPE,CURRENCY,PERIOD_FROM,PERIOD_TO,
                                        CPARTY_CODE,PRODUCT_TYPE,PORTFOLIO_CODE,
                                        INTEREST_RATE,TRANSACTION_AMOUNT,AMOUNT_TYPE,
                                        ACTION_CODE,ACCRLS_AMOUNT,YEAR_BASIS,
                                        FIRST_ACCRUAL_INDIC,ACTUAL_START_DATE,ACTUAL_MATURITY_DATE,
                                        NO_OF_DAYS,ACCRLS_AMOUNT_BAL)
                                 values(p_batch_id,l_deal_nos,l_trans_nos,p_company,l_subtype,
                                        'CA',bk_det.currency,p_start_date,p_end_date,
                                        bk_det.cparty,l_product_type,
                                        bk_det.portfolio_code,bk_det.int_rate,
                                        abs(l_period_accrual_amount),'INTADJ', -- AW 2113171 Display same as accrl amt
                                      --bk_det.main_amount,'INTADJ',
                                        'POS',abs(l_period_accrual_amount),
                                        l_year,l_first_accrual_indic,
                                        bk_det.balance_date,l_actual_end_date,
                                        calc_days,l_amount_to_accrue_amort);
      end if;
   END LOOP;
   close BK_CHARGE;

end CALC_INTGROUP_CACCT_ACCLS;

-----------------------------------------------------------------------------------------------------------------------
-- Procedure to calculate NI accruals using effective interest method
PROCEDURE CALCULATE_NI_EFFINT(p_company       IN VARCHAR2,
                              p_new_batch_id  IN NUMBER,
                              p_cur_batch_id  IN NUMBER,
                              p_batch_start   IN DATE,
                              p_batch_end     IN DATE) AS


  /*-----------------------------------------------------*/
  /* Get param for Arrears(FOLLOWING) or Forward (PRIOR).*/
  /*-----------------------------------------------------*/
   cursor ADJUST(p_param_name varchar2) is
   select PARAM_VALUE
   from   XTR_PRO_PARAM
   where  PARAM_NAME = p_param_name;

   /*------------------------------*/
   /* Get TRADE/SETTLE accounting  */
   /*------------------------------*/
   cursor cur_TRADE_SETTLE is
   select PARAMETER_VALUE_CODE
   from   XTR_COMPANY_PARAMETERS
   where  company_code   = p_company
   and    parameter_code = 'ACCNT_TSDTM';

  /*---------------------*/
  /* Get Rounding Factor */
  /*---------------------*/
   cursor RND_FAC (p_ccy  VARCHAR2) is
   select m.ROUNDING_FACTOR
   from   XTR_MASTER_CURRENCIES_V m
   where  m.CURRENCY = p_ccy;


   l_trade_settle              XTR_COMPANY_PARAMETERS.parameter_value_code%TYPE;

  /*---------------------------------------------------*/
  /* NI Effective Interest method accruals calculation */
  /*---------------------------------------------------*/

  -- Bug 2448432.
  -- Removed all usage of deal date when company accounting method parameter is set to
  -- trade date.  Interest accrual should comence on deal start date always.

   cursor EFFINT_DEALS is select
   a.status_code                                             status_code,
   a.deal_type                                               deal_type,
   a.deal_number                                             deal_no,
   a.transaction_number                                      trans_no,
   a.deal_subtype                                            subtype,
   a.product_type                                            product,
   a.portfolio_code                                          portfolio,
   a.currency                                                ccy,
   a.cparty_code                                             cparty,
   a.client_code                                             client,
   'EFFINT'                                                  EFFINT_amt_type,
   a.balance_out                                             face_value,
   a.interest                                                interest,
   a.all_in_rate                                             all_in_rate,
   a.initial_fair_value                                      initial_fair_value,
   a.start_date                                              deal_start,
   a.maturity_date                                           deal_maturity,
   a.ni_reneg_date                                           deal_action_date,
   b.year_calc_type                                          year_calc_type,
   decode(b.calc_basis,'DISCOUNT','D','Y')                   calc_basis,
   decode(b.day_count_type,'F','PRIOR','L','FOLLOWING','B')  day_count_type,     -- AW Japan Project
   b.rounding_type                                           rounding_type,      -- AW Japan Project
   a.trans_closeout_no                                       resale_deal_no,      -- Bug 2448432.
   a.interest_rate                                           interest_rate         --bug 4969194
   from  XTR_ROLLOVER_TRANSACTIONS a,
         XTR_DEALS b
   where a.company_code   = p_company
   and   a.deal_type      = 'NI'
   and   a.deal_subtype in ('BUY','SHORT','ISSUE')
   and   b.company_code   = p_company
   and   b.deal_no        = a.deal_number
   and   b.deal_type      = a.deal_type
   and   a.status_code   <> 'CANCELLED'
   and   nvl(a.all_in_rate,0) <> 0
   and   a.start_date  <= p_batch_end
 --and  (a.maturity_date >= p_batch_start
   and  (nvl(a.ni_reneg_date,a.maturity_date) >= p_batch_start
   or   (a.deal_number,a.transaction_number,'EFFINT') not in (select b.deal_no,b.trans_no,b.amount_type
                                                              from   XTR_ACCRLS_AMORT b
                                                              where  b.company_code  = p_company
                                                              and    b.deal_type     = 'NI'));

  /*----------------------------------------------------------*/
  /* Check if this is the first EFFINT accrual for the parcel */
  /*----------------------------------------------------------*/
   cursor CHK_FIRST_ACCRUAL (p_deal_no NUMBER,p_trans_no NUMBER,p_deal_type VARCHAR2,p_amt_type VARCHAR2)is
   select 'N'
   from   XTR_ACCRLS_AMORT
   where  deal_no     = p_deal_no
   and    trans_no    = p_trans_no
   and    deal_type   = p_deal_type
   and    amount_type = p_amt_type;

  /*-----------------------------------------*/
  /* Get the previous EFFINT accrual balance */
  /*-----------------------------------------*/
   cursor GET_PRV_BAL (p_deal_no    NUMBER,   p_trans_no NUMBER,
                       p_deal_type  VARCHAR2, p_amt_type VARCHAR2,
                       p_batch_end  DATE) is
   select nvl(EFFINT_ACCRLS_AMOUNT_BAL,0)
   from   XTR_ACCRLS_AMORT
   where  deal_no     = p_deal_no
   and    trans_no    = p_trans_no
   and    deal_type   = p_deal_type
   and    amount_type = p_amt_type
   and    action_code = 'POS'
   and    batch_id    < nvl(p_cur_batch_id, p_new_batch_id)
   order by period_to desc;

  /*-----------------------------*/
  /* Get sum of all delta amount */
  /*-----------------------------*/
   cursor GET_TOTAL_POS (p_deal_no    NUMBER,   p_trans_no NUMBER,
                         p_deal_type  VARCHAR2, p_amt_type VARCHAR2) is
   select sum(decode(action_code,'POS',ACCRLS_AMOUNT,-ACCRLS_AMOUNT))
   from   XTR_ACCRLS_AMORT
   where  deal_no     = p_deal_no
   and    trans_no    = p_trans_no
   and    deal_type   = p_deal_type
   and    amount_type = p_amt_type
   and    action_code in ('POS','ADJ');		-- Bug 2448432.  Added new action code ADJ.

  /*-----------*/
  /* Variables */
  /*-----------*/
   EFF                         EFFINT_DEALS%ROWTYPE;
   l_action_code               VARCHAR2(7);
   l_accrls_amt_bal            NUMBER;
   l_amount_to_accrue_amort    NUMBER;
   l_actual_start              DATE;
   l_accrl_adjust              VARCHAR2(1);
   l_deal_closed               VARCHAR2(1);
   l_deal_start                DATE;
   l_deal_end                  DATE;
   l_dirname                   VARCHAR2(512);
   l_first_accrual_indic       VARCHAR2(1);
   l_init_discnt_amt           NUMBER;
   l_no_of_days                NUMBER;
   l_period_accrual_amount     NUMBER;
   l_prv_accrl_amt_bal         NUMBER;
   l_rec                       XTR_REVAL_PROCESS_P.XTR_REVL_REC;
   l_REV_amt                   NUMBER;
   l_rounding                  NUMBER;
   l_start_adjust              XTR_PRO_PARAM.PARAM_VALUE%TYPE;
   l_year_basis                NUMBER;
   l_interest_rate             NUMBER;
   l_status_code               VARCHAR2(30);

   -- Additions for bug 2448432.

   l_tot_prev_accrls_amt	NUMBER := 0;
   l_resale_both		VARCHAR2(1) := 'N';
   l_accrl_to_date_amt		NUMBER := 0;

   Function RESALE_BOTH (p_deal_no IN NUMBER) return BOOLEAN is
      l_day_cnt_type		XTR_DEALS.day_count_type%TYPE := 'L';
   Begin
      Select day_count_type
        into l_day_cnt_type
        from xtr_deals
       where deal_no = p_deal_no;

      If (l_day_cnt_type = 'B') then
         Return (true);
      Else
         Return (false);
      End If;

   Exception
      When Others then
         Return (false);
   End;

   -- End 2448432 additions.

   function CUMM_AMT_BAL (p_company      IN  VARCHAR2,  p_new_batch_id     IN NUMBER,  p_amt_type  IN  VARCHAR2,
                          p_deal_no      IN  NUMBER,    p_trans_no         IN NUMBER,
                          p_action_code  IN  VARCHAR2) return NUMBER is

         l_cumm_amt_bal   NUMBER;
   begin
         select sum(ACCRLS_AMOUNT)
         into   l_cumm_amt_bal
         from   xtr_accrls_amort
         where  company_code = p_company
         and    batch_id     < p_new_batch_id
         and    deal_no      = p_deal_no
         and    trans_no     = p_trans_no
         and    amount_type  = p_amt_type
         and    action_code  = p_action_code;

     return nvl(l_cumm_amt_bal,0);

   end;

BEGIN

   xtr_risk_debug_pkg.start_conc_prog;

   /*--------------------------------*/
   /* Get Trade or Settle accounting */
   /*--------------------------------*/
   open  cur_TRADE_SETTLE;
   fetch cur_TRADE_SETTLE into l_trade_settle;
   close cur_TRADE_SETTLE;

   l_trade_settle := nvl(l_trade_settle,'TRADE');

   open  EFFINT_DEALS;
   fetch EFFINT_DEALS INTO EFF;
   while EFFINT_DEALS%FOUND LOOP

      open  RND_FAC (EFF.ccy);
      fetch RND_FAC into l_rounding;
      close RND_FAC;
      l_rounding := nvl(l_rounding,2);

      /*****************************************************************************************/
      /*  Find Initial Fair Value (required for first accrual, i.e previous accrual not found) */
      /*****************************************************************************************/

      l_rec.company_code := p_company;
      l_rec.deal_no      := EFF.deal_no;
      l_rec.deal_type    := EFF.deal_type;
      l_rec.trans_no     := EFF.trans_no;

      l_init_discnt_amt  := EFF.interest;
      l_status_code      := NULL;

      /**********************************************************************/
      /*  Determine Start Date to calculate Accrual Balance for this period */
      /**********************************************************************/

      if nvl(EFF.deal_action_date, EFF.deal_maturity)> p_batch_end then
         ----------------------------------------------------------------------
         -- Deal's maturity or resale date is not reached.  Create POS only. --
         ----------------------------------------------------------------------
         l_actual_start := p_batch_end;

      else
         --------------------------------------------------------------
         -- Deal's maturity or resale date is reached.  Create REV.  --
         --------------------------------------------------------------
         l_actual_start := nvl(EFF.deal_action_date,EFF.deal_maturity);
      end if;


      /**********************************************/
      /* Determine previous period accrued balance  */
      /**********************************************/

      l_first_accrual_indic :='Y';
      open  CHK_FIRST_ACCRUAL (EFF.deal_no, EFF.trans_no, EFF.deal_type, EFF.EFFINT_amt_type);
      fetch CHK_FIRST_ACCRUAL into l_first_accrual_indic;
      close CHK_FIRST_ACCRUAL;

      if l_first_accrual_indic = 'Y' then
         l_prv_accrl_amt_bal := l_init_discnt_amt;
      else
         open  get_prv_bal (EFF.deal_no, EFF.trans_no, EFF.deal_type, EFF.EFFINT_amt_type, p_batch_end);
         fetch get_prv_bal into l_prv_accrl_amt_bal;
         close get_prv_bal;
      end if;

     /**********************************************/
     /*  Calculate current period accrued balance  */
     /**********************************************/

      l_accrl_adjust := 'N';
      if (nvl(EFF.deal_action_date,EFF.deal_maturity) > p_batch_end) or
         (EFF.deal_action_date is not null and EFF.deal_action_date <= p_batch_end) then

         -- Bug 2448432.
         -- Init resale deal = 'Both' flag.

         l_resale_both := 'N';

         -- End 2448432.

         /*---------------------------------------*/
         /*  Adjust date for Forward or Arrears   */
         /*---------------------------------------*/

         if EFF.deal_action_date is not null and EFF.deal_action_date <= p_batch_end then
            l_accrl_adjust := 'N';
            l_interest_rate := EFF.interest_rate;  -- bug 4969194
            l_status_code := EFF.status_code;   -- bug 4969194
            -- Bug 2448432.
            -- Parcel resold within batch period.
            -- Set resale flag to be used in call to CALCULATION_EFFECTIVE_INTEREST proc.

            If (RESALE_BOTH(EFF.resale_deal_no)) then
               l_resale_both := 'Y';
            End If;

            -- End 2448432.

         else
            l_accrl_adjust := 'Y';
            l_interest_rate := EFF.all_in_rate;   -- bug 4969194
         end if;

         XTR_ACCRUAL_PROCESS_P.CALCULATE_EFFECTIVE_INTEREST(
                               EFF.face_value,
                               l_interest_rate,
                               EFF.deal_start,
                               l_actual_start,
                               EFF.deal_maturity,
                               l_accrl_adjust,
                               EFF.year_calc_type,
                               EFF.calc_basis,
                               l_prv_accrl_amt_bal,
                               l_no_of_days,
                               l_year_basis,
                               l_amount_to_accrue_amort,	-- unamortized interest from l_actual_start to maturity.
                               l_period_accrual_amount,		-- accrual amount from EFF.deal_start to l_actual_start.
                               EFF.day_count_type,
                               l_resale_both,                    -- bug 244832
                               l_status_code);	         -- Bug 4969194

      else
         --------------------------------------------------------------------------------
         -- Maturity date is reached and parcel held to maturity - need not calculate. --
         --------------------------------------------------------------------------------

         l_amount_to_accrue_amort := 0;

      end if;

      /* -------------------------------------------------------------------------------------------------*/
      /* This is to adjust the start date to be displayed in Accruals form.  Same logic as Straight line. */
      /* -------------------------------------------------------------------------------------------------*/
      l_deal_start := EFF.deal_start;
      /* AW 2113171  Problem:  EFFINT's display start date is one day earlier than INTADJ.  Confusing to user.
      open  ADJUST('ACCRUAL_DAYS_ADJUST');
      fetch ADJUST INTO l_start_adjust;
      close ADJUST;
      l_start_adjust :=nvl(l_start_adjust,'FOLLOWING');

      if nvl(EFF.deal_action_date,EFF.deal_maturity)<= p_batch_end then
         l_deal_end := nvl(EFF.deal_action_date,EFF.deal_maturity);
      else
         l_deal_end := p_batch_end;
      end if;

      if l_start_adjust ='PRIOR' and l_deal_end <> EFF.deal_maturity and l_accrl_adjust ='Y' then
         l_deal_start := EFF.deal_start - 1;
      else
         l_deal_start := EFF.deal_start;
      end if;
      */
      /* -------------------------------------------------------------------------------------------------*/


      /****************************/
      /* Create accrual records   */
      /****************************/

      -- Bug 2448432.
      -- Obtain actual accrued-to-date effective interest amount from previous batches.
      -- If parcel has matured or resold during batch period, need to back calculate the
      -- last periodic accrual amount to minimize rounding issues which may cause under
      -- or over accrual of the actual interest defined at time of deal creation.

      l_accrl_to_date_amt := 0;

      Open  GET_TOTAL_POS (EFF.deal_no, EFF.trans_no, EFF.deal_type, EFF.EFFINT_amt_type);
      Fetch GET_TOTAL_POS into l_accrl_to_date_amt;
      Close GET_TOTAL_POS;

      -- End 2448432.

      If nvl(EFF.deal_action_date, EFF.deal_maturity) <= p_batch_end then

         -- Bug 2448432.
         -- Last accrual batch for the parcel.  Parcel has either been resold or matured within the batch period.
         -- Adjust the last period's periodic accrual interest to minimize rounding issues.

         -- EFFINT.interest calculated at time of deal entry should already be properly rounded based
         -- on the deal's interest rounding setting and currency.  Likewise for l_accrl_to_date_amt,
         -- the sum of accrual interest (EFFINT/POS) for the parcel as calculated for previous accrual batches,
         -- since each parcel's periodic accrual amount for each batch is also rounded based on the deal's
         -- interest rounding setting and currency.  In the event of a resale, the unamortized interest portion
         -- l_amount_to_accrue_amort (with the identical rounding) would be recorded as the reversal amount
         -- at time of resale.


	 -- bug 4969194 changed the call to interest rounding

         l_period_accrual_amount := EFF.interest - nvl(l_accrl_to_date_amt,0)- xtr_fps2_p.interest_round( nvl(l_amount_to_accrue_amort,0), l_rounding,  EFF.rounding_type);

         l_accrls_amt_bal := nvl(l_accrl_to_date_amt,0) + nvl(l_period_accrual_amount,0);



         -- End 2448432.


         -- AW 2113171   Do not display a row if Accrual Amt and Balance are zero.
         -- AW Japan Project

         -- Bug 2448432.
         -- (1) Removed unecessary interest rounding to the periodic and cumulative accrual interest amounts.
         --     These amounts have already been properly rounded before being stored.
         -- (2) Changed the condition under which a 'POS' EFFINT accrual record is to be created.
         --     A 'POS' record will be created only if the periodic accrual amount is > 0.
         --     In cases where the periodic accrual amount is < 0, a record with the new action code 'ADJ'
         --     will be created using the absolute value of the periodic accrual amount.
         --     A negative value may result due to rounding or certain resale scenerios when a day's worth
         --     of interest is to be backed out from the original purchase deal.  In such cases, if an
         --     adjustment amount is not provided, an overstatement of interest income in the GL accounts
         --     may result.

         if (l_accrls_amt_bal <> 0) and (l_period_accrual_amount <> 0) then

            insert into XTR_ACCRLS_AMORT (BATCH_ID,              DEAL_NO,          TRANS_NO,
                                          COMPANY_CODE,          DEAL_SUBTYPE,     DEAL_TYPE,
                                          CURRENCY,              PERIOD_FROM,      PERIOD_TO,
                                          CPARTY_CODE,           PRODUCT_TYPE,     PORTFOLIO_CODE,
                                          INTEREST_RATE,         TRANSACTION_AMOUNT,
                                          AMOUNT_TYPE,           ACTION_CODE,
                                          ACCRLS_AMOUNT,         YEAR_BASIS,       FIRST_ACCRUAL_INDIC,
                                          ACTUAL_START_DATE,     ACTUAL_MATURITY_DATE,
                                          NO_OF_DAYS,            EFFINT_ACCRLS_AMOUNT_BAL,
                                          ACCRLS_AMOUNT_BAL)
                                   values(p_new_batch_id,        EFF.deal_no,      EFF.trans_no,
                                          p_company,             EFF.subtype,      EFF.deal_type,
                                          EFF.ccy,               p_batch_start,    l_actual_start,
                                        --EFF.ccy,               p_batch_start,    p_batch_end,
                                          EFF.cparty,            EFF.product,      EFF.portfolio,
                                          EFF.all_in_rate,       EFF.interest,
                                          EFF.EFFINT_amt_type,  decode(sign(l_period_accrual_amount),-1,'ADJ','POS'),
                                          abs(nvl(l_period_accrual_amount,0)),
                                          l_year_basis,          l_first_accrual_indic,
                                          l_deal_start,          EFF.deal_maturity,
                                          -- l_actual_start,     EFF.deal_maturity,
                                          nvl(l_no_of_days,0),
                                          abs(l_amount_to_accrue_amort),
                                          l_accrls_amt_bal);
         end if;

         -- By issuing another fetch to GET_TOTAL_POS, we should obtain the total accrual amount to-date
         -- in all the 'POS' and 'ADJ' records created for the parcel to-date, including the one just
         -- created above.

         open  GET_TOTAL_POS(EFF.deal_no, EFF.trans_no, EFF.deal_type, EFF.EFFINT_amt_type);
         fetch GET_TOTAL_POS into l_REV_amt;
         close GET_TOTAL_POS;

         -- The 'REV' record created in the final accrual batch of the parcel should properly contain
         -- the total 'POS' and 'ADJ' amount to-date for the parcel.

        -- Bug 2449432.
        -- Create reversal record only if there is an accrual amount to reverse.
        -- If resold on the 1st day of the purchase.  There will be no accrual (POS) amounts created.

	If (nvl(l_REV_amt,0) <> 0) then
           insert into XTR_ACCRLS_AMORT (BATCH_ID,              DEAL_NO,          TRANS_NO,
                                         COMPANY_CODE,          DEAL_SUBTYPE,     DEAL_TYPE,
                                         CURRENCY,              PERIOD_FROM,      PERIOD_TO,
                                         CPARTY_CODE,           PRODUCT_TYPE,     PORTFOLIO_CODE,
                                         INTEREST_RATE,         TRANSACTION_AMOUNT,
                                         AMOUNT_TYPE,           ACTION_CODE,
                                         ACCRLS_AMOUNT,         YEAR_BASIS,       FIRST_ACCRUAL_INDIC,
                                         ACTUAL_START_DATE,     ACTUAL_MATURITY_DATE,
                                         NO_OF_DAYS,            EFFINT_ACCRLS_AMOUNT_BAL,
                                         ACCRLS_AMOUNT_BAL)
                                  values(p_new_batch_id,        EFF.deal_no,      EFF.trans_no,
                                         p_company,             EFF.subtype,      EFF.deal_type,
                                         EFF.ccy,               p_batch_start,    l_actual_start,
                                       --EFF.ccy,               p_batch_start,    p_batch_end,
                                         EFF.cparty,            EFF.product,      EFF.portfolio,
                                         EFF.all_in_rate,       EFF.interest,
                                         EFF.EFFINT_amt_type,   'REV',
                                         xtr_fps2_p.interest_round(l_REV_amt,l_rounding,EFF.rounding_type),
                                         l_year_basis,          l_first_accrual_indic,
                                         l_deal_start,          EFF.deal_maturity,
                                         --l_actual_start,      EFF.deal_maturity,
                                         nvl(l_no_of_days,0),   0,
                                         0);
                                       --round(l_REV_amt,l_rounding));
                                       --round(l_accrls_amt_bal,l_rounding))
         End If;
      else

         --Add 2448432.

         l_accrls_amt_bal := nvl(l_accrl_to_date_amt,0) + nvl(l_period_accrual_amount,0);

         --End add 2448432.

         -- AW 2113171   Do not display a row if Accrual Amt and Balance are zero.
         -- AW Japan Project

         if xtr_fps2_p.interest_round(l_accrls_amt_bal,l_rounding,EFF.rounding_type) <> 0 and
            xtr_fps2_p.interest_round(abs(l_period_accrual_amount),l_rounding,EFF.rounding_type) <> 0 then

            insert into XTR_ACCRLS_AMORT (BATCH_ID,              DEAL_NO,          TRANS_NO,
                                          COMPANY_CODE,          DEAL_SUBTYPE,     DEAL_TYPE,
                                          CURRENCY,              PERIOD_FROM,      PERIOD_TO,
                                          CPARTY_CODE,           PRODUCT_TYPE,     PORTFOLIO_CODE,
                                          INTEREST_RATE,         TRANSACTION_AMOUNT,
                                          AMOUNT_TYPE,           ACTION_CODE,
                                          ACCRLS_AMOUNT,         YEAR_BASIS,       FIRST_ACCRUAL_INDIC,
                                          ACTUAL_START_DATE,     ACTUAL_MATURITY_DATE,
                                          NO_OF_DAYS,            EFFINT_ACCRLS_AMOUNT_BAL,
                                          ACCRLS_AMOUNT_BAL)
                                   values(p_new_batch_id,        EFF.deal_no,      EFF.trans_no,
                                          p_company,             EFF.subtype,      EFF.deal_type,
                                          EFF.ccy,               p_batch_start,    l_actual_start,
                                        --EFF.ccy,               p_batch_start,    p_batch_end,
                                          EFF.cparty,            EFF.product,      EFF.portfolio,
                                          EFF.all_in_rate,       EFF.interest,
                                          EFF.EFFINT_amt_type,  'POS',
                                          xtr_fps2_p.interest_round(abs(l_period_accrual_amount),
                                                                    l_rounding,EFF.rounding_type),
                                          l_year_basis,          l_first_accrual_indic,
                                          l_deal_start,          EFF.deal_maturity,
                                          --l_actual_start,      EFF.deal_maturity,
                                          nvl(l_no_of_days,0),
                                          xtr_fps2_p.interest_round(abs(l_amount_to_accrue_amort),
                                                                    l_rounding,EFF.rounding_type),
                                          xtr_fps2_p.interest_round( l_accrls_amt_bal,l_rounding,EFF.rounding_type));
         end if;
      end if;

      fetch EFFINT_DEALS INTO EFF;

   END LOOP;
   close EFFINT_DEALS;
   --

   xtr_risk_debug_pkg.stop_conc_debug;

end CALCULATE_NI_EFFINT;

-----------------------------------------------------------------------------------------------------------------------
-- Procedure to Transfer Revaluations to Deal Date Amounts to await Journalling
PROCEDURE TSFR_ACCRUALS_FOR_JNL_PROCESS(
                                      p_company  IN VARCHAR2,
                                      p_end_date IN DATE) is

--
 cursor GETROWS is
  select ROWID,DEAL_NO,TRANS_NO,DEAL_TYPE,DEAL_SUBTYPE,PRODUCT_TYPE,PORTFOLIO_CODE,ACTION_CODE,
         CURRENCY,ACCRLS_AMOUNT,AMOUNT_TYPE ACC_AMOUNT_TYPE
   from XTR_ACCRLS_AMORT
   where COMPANY_CODE  = p_company
   and PERIOD_TO   = p_end_date
   order by currency;
--
 l_amttype   VARCHAR2(7);
 l_date_ty   VARCHAR2(7) :='ACCRUAL';
 l_deal_no   NUMBER;
 l_trans_nos NUMBER;
 l_old_ccy   VARCHAR2(15);
 l_amt_hce   NUMBER;
 l_product   VARCHAR2(10);
 l_portfolio VARCHAR2(7);
 l_type      VARCHAR2(7);
 l_ccy       VARCHAR2(15);
 l_subty     VARCHAR2(7);
 l_acclrs_amount    NUMBER;
 l_action    VARCHAR2(7);
 l_hce_rate  NUMBER;
 l_sysdate   DATE :=trunc(sysdate);
 l_rowid     VARCHAR2(30);
--
 cursor HCE is
  select s.hce_rate
   from XTR_MASTER_CURRENCIES s
   where s.CURRENCY = l_ccy;
--
begin
 l_old_ccy := NULL;
 open GETROWS;
  LOOP
  FETCH GETROWS INTO l_rowid,l_deal_no,l_trans_nos,l_type,l_subty,l_product,l_portfolio,l_action,
                      l_ccy,l_acclrs_amount,l_amttype;
  EXIT WHEN GETROWS%NOTFOUND;
   if l_old_ccy is NULL or l_old_ccy <> l_ccy or l_hce_rate is NULL then
    -- fetch HCE rate
    open HCE;
     fetch HCE INTO l_hce_rate;
    close HCE;
   end if;
   l_old_ccy := l_ccy;
   --
    l_amt_hce := round((l_acclrs_amount / nvl(l_hce_rate,1)),2);
    --
    insert into XTR_DEAL_DATE_AMOUNTS
     (deal_type,amount_type,date_type,deal_number,transaction_date,
      currency,amount,hce_amount,amount_date,action_code,
      cashflow_amount,company_code,transaction_number,
      deal_subtype,authorised,product_type,status_code,
      portfolio_code)
    values
     (l_type,l_amttype,l_date_ty,l_deal_no,l_sysdate,
      l_ccy,l_acclrs_amount,l_amt_hce,p_end_date,l_action,0,
      p_company,l_trans_nos,l_subty,'N',l_product,'CURRENT',
      l_portfolio);
    --
    update XTR_ACCRLS_AMORT
     set TRANSFERED_ON = l_sysdate
     where rowid=l_rowid;
  END LOOP;
  close GETROWS;
/*
  exception
    when others then
      xtr_debug_pkg.debug('Transfer err:l_deal_no='||to_char(l_deal_no));
*/
end TSFR_ACCRUALS_FOR_JNL_PROCESS;
--------------------------------------------------------------------------------------------------------------------------
end XTR_ACCRUAL_PROCESS_P;

/
