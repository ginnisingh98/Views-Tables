--------------------------------------------------------
--  DDL for Package Body XTR_EXP_SUMM_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_EXP_SUMM_P" as
/* $Header: xtrexpob.pls 120.1 2005/06/29 06:25:54 badiredd ship $ */
----------------------------------------------------------------------------------------------------------------
PROCEDURE CALC_HEDGE_DETAILS(ref_number       IN NUMBER,
                             sel_ccy          IN VARCHAR2,
                             l_base_ccy       IN VARCHAR2,
                             l_company        IN VARCHAR2,
                             incl_options     IN VARCHAR2,
                             incl_indic_exp   IN VARCHAR2,
                             l_portfolio      IN VARCHAR2,
                             perspective      IN VARCHAR2,
                             l_yield_curve    IN VARCHAR2,
                             l_year_basis     IN NUMBER,
                             l_dflt_disc_rate IN NUMBER,
                             l_rounding       IN NUMBER,
                             l_wk_mth         IN VARCHAR2) is
--
 disc_rate      NUMBER := 0;
 disc_value     NUMBER := 0;
 l_num_items    NUMBER := 0;
 l_error        NUMBER := 0;
 l_rate         NUMBER;
 l_date         VARCHAR2(11);
 l_ins_date     DATE;
 l_combination  VARCHAR2(31);
 l_amount       NUMBER;
 l_onc_amount NUMBER;
 l_avg_days     NUMBER := 0;
 l_weight_avg   NUMBER := 0;
 l_deal_ty      NUMBER; l_amount_date  DATE;
 l_fwd_fx_rate NUMBER;
--
 cursor GET_EXPOSURES is
   select decode(l_wk_mth,'W',to_char(next_day(nvl(EXPOSURE_REF_DATE,AMOUNT_DATE),to_char(to_date('09/03/1997','DD/MM/YYYY'),'DY')),'DD-MM-YYYY')
                                           ,to_char(AMOUNT_DATE,'MON-YYYY')),AMOUNT_DATE,
            sum(CASHFLOW_AMOUNT),CURRENCY_COMBINATION,sum(TRANSACTION_RATE),
            decode(DEAL_TYPE,'FX',TRANSACTION_NUMBER,'FXO',TRANSACTION_NUMBER,1),
            decode(DEAL_TYPE,'FX',nvl(EXPOSURE_REF_DATE,AMOUNT_DATE),'FXO',nvl(EXPOSURE_REF_DATE,AMOUNT_DATE),NULL),count(AMOUNT)
   from XTR_DEAL_DATE_AMOUNTS_V
   where STATUS_CODE = 'CURRENT'
   and (AMOUNT_DATE >= trunc(SYSDATE) or EXPOSURE_REF_DATE >=trunc(SYSDATE))
   and COMPANY_CODE = l_company
   and CASHFLOW_AMOUNT <> 0
   and CURRENCY = sel_ccy
   and nvl(PORTFOLIO_CODE,'%') like nvl(upper(l_portfolio),'%')
   and (incl_options = 'Y' or (incl_options = 'N' and AMOUNT_TYPE NOT IN('FXOBUY','FXOSELL')))
   and ((DEAL_SUBTYPE = 'INDIC' and incl_indic_exp = 'Y') or
         DEAL_SUBTYPE <> 'INDIC')
   and nvl(multiple_settlements,'N') <> 'Y'
   group by decode(l_wk_mth,'W',to_char(next_day(nvl(EXPOSURE_REF_DATE,AMOUNT_DATE),to_char(to_date('09/03/1997','DD/MM/YYYY'),'DY')),'DD-MM-YYYY')
                               ,to_char(AMOUNT_DATE,'MON-YYYY')),AMOUNT_DATE,CURRENCY_COMBINATION,
                decode(DEAL_TYPE,'FX',TRANSACTION_NUMBER,'FXO',TRANSACTION_NUMBER,1),
                decode(DEAL_TYPE,'FX',nvl(EXPOSURE_REF_DATE,AMOUNT_DATE),'FXO',nvl(EXPOSURE_REF_DATE,AMOUNT_DATE),NULL);
--
 cursor GET_ACCT_BALS is
  select sum(nvl(OPENING_BALANCE,0)),count(ACCOUNT_NUMBER)
   from XTR_BANK_ACCOUNTS
   where PARTY_CODE = l_company
   and CURRENCY like nvl(sel_ccy,'%')
   and nvl(PORTFOLIO_CODE,'%') like nvl(upper(l_portfolio),'%')
   and nvl(SETOFF_ACCOUNT_YN,'N') <> 'Y';
--
-- Show reverse of call cash on hand where no maturity date exists
-- this is because the cashflow will/would have gone through the account but is
-- not reflected anywhere in the future
-- eg INVEST initial cflow is -ve therefore show as cash on hand (+ve)
--
 cursor GET_ONC_BALS is
  select sum((-1) * d.cashflow_amount) CASH_ON_HAND
   from XTR_DEAL_DATE_AMOUNTS_V d,
        XTR_ROLLOVER_TRANSACTIONS_V r
   where d.STATUS_CODE = 'CURRENT'
   and d.DEAL_TYPE = 'ONC'
   and d.COMPANY_CODE = l_company
   and d.CURRENCY like upper(nvl(sel_ccy,'%'))
   and nvl(d.PORTFOLIO_CODE,'%') like nvl(upper(l_portfolio),'%')
   and nvl(d.multiple_settlements,'N') = 'N'
   and d.CASHFLOW_AMOUNT <> 0
   and r.deal_number = d.deal_number
   and r.transaction_number = d.transaction_number
   and r.MATURITY_DATE is NULL;
--
begin
 delete from XTR_exposure_summary
  where created_on < (trunc(sysdate) - 7);
 commit;
 open GET_EXPOSURES;
 LOOP
  fetch GET_EXPOSURES INTO l_date,l_ins_date,l_amount,l_combination,l_rate,l_deal_ty,l_amount_date,l_num_items;
 EXIT WHEN GET_EXPOSURES%NOTFOUND or l_amount is NULL;
 if l_amount_date is NOT NULL then
  l_avg_days := round(l_amount_date - trunc(sysdate),0);
 else
   if l_wk_mth = 'W' then
    l_avg_days := round(to_date(l_date,'DD-MM-YYYY') - trunc(sysdate) + 15,0);
   else
--    l_avg_days := round(to_date(l_date,'MON-YYYY') - trunc(sysdate) + 15,0);
    l_avg_days := round(l_ins_date - trunc(sysdate) + 15,0);
   end if;
 end if;
  if l_avg_days = 0 then
   l_avg_days := 1;
  end if;
  if l_yield_curve is NOT NULL then
   XTR_fps2_P.EXTRAPOLATE_FROM_YIELD_CURVE(sel_ccy,l_avg_days,l_yield_curve,disc_rate);
  else
   XTR_fps2_P.EXTRAPOLATE_FROM_MARKET_PRICES(sel_ccy,l_avg_days,disc_rate);
  end if;
  if nvl(disc_rate,0) = 0 then
  -- Use Default Discount Rate
  if nvl(l_dflt_disc_rate,0) = 0 then
   disc_value := l_amount;
  else
   disc_rate := l_dflt_disc_rate;
   XTR_fps2_P.DISCOUNT_INTEREST_CALC(nvl(l_year_basis,360),l_amount,disc_rate,l_avg_days,
                                                      nvl(l_rounding,2),disc_value);
   disc_value := l_amount - disc_value;
  end if;
 else
  XTR_fps2_P.DISCOUNT_INTEREST_CALC(nvl(l_year_basis,360),l_amount,disc_rate,l_avg_days,
                                                      nvl(l_rounding,2),disc_value);
  disc_value := l_amount - disc_value;
 end if;
 --
 /*
 -- Calculate FX Forward Rate for Ccy Combinations
 if l_combination is NOT NULL then
   CALC_FX_FWD_RATE(substr(l_combination,1,3),substr(l_combination,5,3),l_company,
                                     nvl(l_year_basis,360),(trunc(sysdate) + l_avg_days),
                                     substr(l_combination,1,3),l_fwd_fx_rate);
 else
  l_fwd_fx_rate := NULL;
 end if;
 */
 --
 begin
 insert into XTR_EXPOSURE_SUMMARY
  (unique_ref_number,currency,period,amount,average_days,weighted_average,currency_combination,
   transaction_rate,created_on,created_by,incl_fx_options,incl_indic_exposures,company,base_currency,
   number_of_items,acct_balance,portfolio_code,hedge_or_trade_view,discount_rate,discounted_back_to,
   discounted_value,yield_curve,forward_fx_rate,selected_ccy,selected_indic,selected_options,
   hedge_trade_whatif,selected_portfolio,month_or_week,period_date)
 values
  (ref_number,sel_ccy,l_date,round(l_amount,2),l_avg_days,l_weight_avg,l_combination,round(l_rate,5),
   trunc(sysdate),fnd_global.user_id,
   incl_options,incl_indic_exp,l_company,l_base_ccy,l_num_items,'N',l_portfolio,perspective,disc_rate,
   trunc(sysdate),disc_value,l_yield_curve,l_fwd_fx_rate,sel_ccy,incl_indic_exp,incl_options,'H',l_portfolio,
   nvl(l_wk_mth,'M'),decode(l_wk_mth,'W',to_date(l_date,'DD-MM-YYYY'),
-- to_date(l_date,'MON-YYYY')));
 l_ins_date));
 exception
 when others then
  l_error := l_error + 1;
 end;
 END LOOP;
 close GET_EXPOSURES;
 --
 l_onc_amount :=0;
 open GET_ONC_BALS;
  fetch GET_ONC_BALS into l_onc_amount;
 close GET_ONC_BALS;
 --
 l_amount := 0;
 l_num_items := 0;
 open GET_ACCT_BALS;
  fetch GET_ACCT_BALS into l_amount,l_num_items;
 close GET_ACCT_BALS;
 --
 -- add On Call Cash Balances to Account Balances
 l_amount := nvl(l_amount,0) + nvl(l_onc_amount,0);
 --
 begin
 insert into XTR_EXPOSURE_SUMMARY
  (unique_ref_number,currency,period,amount,average_days,weighted_average,currency_combination,
   transaction_rate,created_on,created_by,incl_fx_options,incl_indic_exposures,company,base_currency,
   number_of_items,acct_balance,portfolio_code,hedge_or_trade_view,discount_rate,discounted_back_to,
   discounted_value,yield_curve,selected_ccy,selected_indic,selected_options,
   hedge_trade_whatif,selected_portfolio,month_or_week,period_date)
 values
  (ref_number,sel_ccy,decode(l_wk_mth,'W',to_char(next_day(trunc(sysdate),to_char(to_date('09/03/1997','DD/MM/YYYY'),'DY')),'DD-MM-YYYY'),
   to_char(trunc(sysdate),'MON-YYYY')),round(l_amount,2),1,0,null,null,trunc(sysdate),fnd_global.user_id,
   incl_options,incl_indic_exp,l_company,l_base_ccy,l_num_items,'Y',l_portfolio,perspective,
   0,trunc(sysdate),l_amount,l_yield_curve,sel_ccy,incl_indic_exp,incl_options,'H',l_portfolio,
   nvl(l_wk_mth,'M'),trunc(sysdate));
 exception
 when others then
  l_error := l_error + 1;
 end;
 commit;
end CALC_HEDGE_DETAILS;
----------------------------------------------------------------------------------------------------------------
PROCEDURE CALC_TRADING_DETAILS(ref_number     IN NUMBER,
                       l_ccy_a         IN VARCHAR2,
                       l_ccy_b         IN VARCHAR2,
                       l_company      IN VARCHAR2,
                       incl_options   IN VARCHAR2,
                       l_portfolio    IN VARCHAR2,
                       perspective    IN VARCHAR2,
                       l_year_basis   IN NUMBER,
                       l_rounding     IN NUMBER) is
--
 l_ccy            VARCHAR2(15);
 l_num_items    NUMBER := 0;
 l_error        NUMBER := 0;
 l_rate         NUMBER;
 l_date         VARCHAR2(8);
 l_ins_date     DATE;
 l_combination  VARCHAR2(31);
 l_amount       NUMBER;
 l_avg_days     NUMBER := 0;
 l_weight_avg   NUMBER := 0;
 l_deal_ty      NUMBER;
 l_amount_date  DATE;
 l_fwd_fx_rate NUMBER;
 l_hce           NUMBER;
 l_pl            NUMBER;
 l_base        VARCHAR2(15);
--
 cursor GET_CONTRACTS is
  select CURRENCY,to_char(nvl(EXPOSURE_REF_DATE,AMOUNT_DATE),'MON-YYYY'),
            nvl(EXPOSURE_REF_DATE,AMOUNT_DATE),
            sum(CASHFLOW_AMOUNT),
            CURRENCY_COMBINATION,sum(TRANSACTION_RATE),
            TRANSACTION_NUMBER,nvl(EXPOSURE_REF_DATE,AMOUNT_DATE),count(AMOUNT)
   from XTR_DEAL_DATE_AMOUNTS_V
   where STATUS_CODE = 'CURRENT'
    and CURRENCY_COMBINATION like upper(nvl(l_ccy_a,'%'))||'/'||upper(nvl(l_ccy_b,'%'))
    and (AMOUNT_DATE >= trunc(SYSDATE) or EXPOSURE_REF_DATE >=trunc(sysdate))
    and CURRENCY = substr(CURRENCY_COMBINATION,1,3)
    and DEAL_TYPE like 'FX%'
    and AMOUNT_TYPE <> 'EXPIRY'
    and COMPANY_CODE = l_company
    and CASHFLOW_AMOUNT <> 0
    and nvl(PORTFOLIO_CODE,'%') like nvl(upper(l_portfolio),'%')
    and (incl_options = 'Y' or (incl_options = 'N' and AMOUNT_TYPE NOT IN('FXOBUY','FXOSELL')))
   group by CURRENCY,to_char(nvl(EXPOSURE_REF_DATE,AMOUNT_DATE),'MON-YYYY'),
      nvl(EXPOSURE_REF_DATE,AMOUNT_DATE),
      CURRENCY_COMBINATION,
      TRANSACTION_NUMBER,nvl(EXPOSURE_REF_DATE,AMOUNT_DATE);
--
 cursor HCE is
   select HCE_RATE
    from XTR_MASTER_CURRENCIES
    where CURRENCY = l_ccy;
--
begin
 delete from XTR_exposure_summary
  where created_on < (trunc(sysdate) - 7);
 commit;
 open GET_CONTRACTS;
 LOOP
  fetch GET_CONTRACTS INTO l_ccy,l_date,l_ins_date,l_amount,l_combination,l_rate,l_deal_ty,l_amount_date,l_num_items;
 EXIT WHEN GET_CONTRACTS%NOTFOUND or l_amount is NULL;
 if l_amount_date is NOT NULL then
  l_avg_days := round(l_amount_date - trunc(sysdate),0);
 else
--  l_avg_days := round(to_date(l_date,'MON-YYYY') - trunc(sysdate) + 15,0);
  l_avg_days := round(l_ins_date - trunc(sysdate) + 15,0);
 end if;
 if l_avg_days = 0 then
  l_avg_days := 1;
 end if;
 /*
 -- Calculate FX Forward Rate for Ccy Combinations
 if l_combination is NOT NULL then
   CALC_FX_FWD_RATE(substr(l_combination,1,3),substr(l_combination,5,3),l_company,
                                     nvl(l_year_basis,360),(trunc(sysdate) + l_avg_days),
                                     substr(l_combination,1,3),l_fwd_fx_rate);
 else
  l_fwd_fx_rate := NULL;
 end if;
 */
 --
 open HCE;
   fetch HCE INTO l_hce;
 close HCE;
 l_pl := round(l_amount / l_hce,0);
 if l_ccy = substr(l_combination,1,3) then
  l_base := l_ccy;
 else
  l_base := substr(l_combination,5,3);
 end if;
 --
 begin
 insert into XTR_EXPOSURE_SUMMARY
  (unique_ref_number,currency,period,amount,average_days,weighted_average,currency_combination,
   transaction_rate,created_on,created_by,incl_fx_options,company,base_currency,discounted_value,
   number_of_items,acct_balance,portfolio_code,hedge_or_trade_view,discounted_back_to,forward_fx_rate,
   selected_ccy,selected_ccy2,selected_indic,selected_options,hedge_trade_whatif,selected_portfolio,period_date)
 values
  (ref_number,l_ccy,l_date,round(l_amount,2),l_avg_days,l_weight_avg,l_combination,round(l_rate,5),
   trunc(sysdate),fnd_global.user_id,
   incl_options,l_company,l_base,l_pl,l_num_items,'N',l_portfolio,perspective,trunc(sysdate),l_fwd_fx_rate,
   l_ccy_a,l_ccy_b,'N',incl_options,'T',l_portfolio,
 --to_date(l_date,'MON-YYYY'));
           l_ins_date);
 exception
 when others then
  l_error := l_error + 1;
 end;
 END LOOP;
 commit;
end CALC_TRADING_DETAILS;
----------------------------------------------------------------------------------------------------
PROCEDURE CALC_FX_FWD_RATE(l_ccya         IN VARCHAR2,
                           l_ccyb         IN VARCHAR2,
                           l_company_code IN VARCHAR2,
                           l_yr_basis     IN NUMBER,
                           l_end_date     IN DATE,
                           l_base_ccy     IN VARCHAR2,
                           l_answer       IN OUT NOCOPY NUMBER) is
--
  l_days                    NUMBER;
  l_round                   NUMBER;
  l_round1                  NUMBER;
  l_round2                  NUMBER;
  l_round3                  NUMBER;
  l_ccy                     VARCHAR2(15);
  l_ccya_spot               NUMBER;
  l_ccyb_spot               NUMBER;
  tmp_calc_h                NUMBER;
  tmp_calc_k                NUMBER;
  tmp_calc_l                NUMBER;
  tmp_calc_o                NUMBER;
  base_curr_year_basis      NUMBER;
  contra_curr_year_basis    NUMBER;
  usd_curr_year_basis       NUMBER;
  l_base_int_rate           NUMBER;
  l_contra_int_rate         NUMBER;
  l_usd_int_rate            NUMBER;
  l_base_contra_ccya        VARCHAR2(6);
  l_base_contra_ccyb        VARCHAR2(6);
--
 cursor FX_SPOT_RATE is
  select (r.BID_PRICE + r.ASK_PRICE) / 2
   from XTR_MARKET_PRICES r
   where ((r.CURRENCY_A = l_ccy
       and r.CURRENCY_B = 'USD') or
          (r.CURRENCY_A = 'USD'
       and r.CURRENCY_B = l_ccy))
   and r.TERM_TYPE = 'S';
--
 cursor C1 is
  select m1.year_basis,m1.rounding_factor,m2.year_basis,m2.rounding_factor,
         m3.year_basis,m3.rounding_factor,
         round(decode(m1.divide_or_multiply,'*',1 / l_ccya_spot,l_ccya_spot),9),
         decode(m1.divide_or_multiply,'*','BASE','CONTRA'),
         round(decode(m2.divide_or_multiply,'*',1 / l_ccyb_spot,l_ccyb_spot),9),
         decode(m2.divide_or_multiply,'*','BASE','CONTRA')
  from XTR_MASTER_CURRENCIES_V m1,
       XTR_MASTER_CURRENCIES_V m2,
       XTR_MASTER_CURRENCIES_V m3
  where m1.CURRENCY = l_ccya
  and m2.CURRENCY = l_ccyb
  and m3.CURRENCY = 'USD';
--
begin
 -- Fetch Spot rates agst USD for each ccy
 l_ccy := l_ccya;
 l_days := l_end_date - trunc(sysdate);
 if l_ccy = 'USD' then
  l_ccya_spot := 1;
 else
  open FX_SPOT_RATE;
   fetch FX_SPOT_RATE INTO l_ccya_spot;
  if FX_SPOT_RATE%NOTFOUND then
   close FX_SPOT_RATE;
   l_answer := 0;
   goto ERROR_OCCURRED;
  end if;
  close FX_SPOT_RATE;
 end if;
  XTR_fps2_P.EXTRAPOLATE_FROM_MARKET_PRICES(l_ccy,l_days,l_base_int_rate);
 --
 l_ccy := l_ccyb;
 if l_ccy = 'USD' then
  l_ccyb_spot := 1;
 else
  open FX_SPOT_RATE;
   fetch FX_SPOT_RATE INTO l_ccyb_spot;
  if FX_SPOT_RATE%NOTFOUND then
   close FX_SPOT_RATE;
   l_answer := 0;
   goto ERROR_OCCURRED;
  end if;
  close FX_SPOT_RATE;
 end if;
  XTR_fps2_P.EXTRAPOLATE_FROM_MARKET_PRICES(l_ccy,l_days,l_contra_int_rate);
 --
 l_ccy := 'USD';
  XTR_fps2_P.EXTRAPOLATE_FROM_MARKET_PRICES(l_ccy,l_days,l_usd_int_rate);
 --
 open C1;
  fetch C1 INTO base_curr_year_basis,l_round1,contra_curr_year_basis,l_round2,
                usd_curr_year_basis,l_round3,tmp_calc_h,l_base_contra_ccya,tmp_calc_k,l_base_contra_ccyb;
 if C1%NOTFOUND then
  close C1;
  l_answer := 0;
  goto ERROR_OCCURRED;
 end if;
 close C1;
--
 if l_base_int_rate = 0 then
  l_base_int_rate := 0.0001;
 end if;
 if l_contra_int_rate = 0 then
  l_contra_int_rate := 0.0001;
 end if;
 if l_usd_int_rate = 0 then
  l_usd_int_rate := 0.0001;
 end if;
 if l_ccya = 'USD' then
   tmp_calc_l := 1;
 else
  tmp_calc_l := round(((100000 * tmp_calc_h) +
                (100000 * tmp_calc_h * l_base_int_rate /
                (base_curr_year_basis * 100) * l_days)) /
                (100000 + (100000 * l_usd_int_rate /
                (usd_curr_year_basis * 100) * l_days)),9);
 end if;
 if l_ccyb = 'USD' then
  tmp_calc_o := 1;
 else
  tmp_calc_o := round(((100000 * tmp_calc_k) +
                (100000 * tmp_calc_k * l_contra_int_rate /
                (contra_curr_year_basis * 100 ) * l_days)) /
                (100000 + (100000 * l_usd_int_rate /
                (usd_curr_year_basis * 100 ) * l_days)),9);
 end if;
 if l_ccya = l_base_ccy then
  l_answer := round(tmp_calc_o / tmp_calc_l,nvl(l_round,5));
 else
  l_answer := round(tmp_calc_l / tmp_calc_o,nvl(l_round,5));
 end if;
 <<ERROR_OCCURRED>>
 null;
end CALC_FX_FWD_RATE;
-------------------------------------------------------------------------------------------
PROCEDURE CALC_ALL_CCY_EXPOSURES(ref_number           IN NUMBER,
                                 p_sel_ccy            IN VARCHAR2,
                                 l_base_ccy           IN VARCHAR2,
                                 l_company            IN VARCHAR2,
                                 incl_options         IN VARCHAR2,
                                 incl_indic_exp       IN VARCHAR2,
                                 l_portfolio          IN VARCHAR2,
                                 perspective          IN VARCHAR2,
                                 l_yield_curve        IN VARCHAR2,
                                 p_year_basis         IN NUMBER,
                                 l_dflt_disc_rate     IN NUMBER,
                                 p_rounding           IN NUMBER,
                                 p_count_months_from  IN DATE) is
--
 l_ccy          VARCHAR2(15);
 disc_rate      NUMBER := 0;
 disc_value     NUMBER := 0;
 l_num_items    NUMBER := 0;
 l_error        NUMBER := 0;
 l_rate         NUMBER;
 l_date         VARCHAR2(11);
 l_combination  VARCHAR2(31);
 l_amount       NUMBER;
 l_onc_amount NUMBER;
 l_avg_days     NUMBER := 0;
 l_weight_avg   NUMBER := 0;
 l_deal_ty      NUMBER;
 l_amount_date  DATE;
 l_fwd_fx_rate NUMBER;
 l_row_ccy     VARCHAR2(15);
 sel_ccy     VARCHAR2(15);
 l_combin     VARCHAR2(31);
 count_months_from DATE;
--
 cursor GET_FX is
  select CURRENCY,to_char(nvl(EXPOSURE_REF_DATE,AMOUNT_DATE),'DD-MM-YYYY'),sum(CASHFLOW_AMOUNT),
         CURRENCY_COMBINATION,sum(TRANSACTION_RATE),
         decode(DEAL_TYPE,'FX',TRANSACTION_NUMBER,'FXO',TRANSACTION_NUMBER,1),
         decode(DEAL_TYPE,'FX',nvl(EXPOSURE_REF_DATE,AMOUNT_DATE),'FXO',nvl(EXPOSURE_REF_DATE,AMOUNT_DATE),NULL),count(AMOUNT)
   from XTR_DEAL_DATE_AMOUNTS_V
   where STATUS_CODE = 'CURRENT'
   and (AMOUNT_DATE >= trunc(SYSDATE)
        or EXPOSURE_REF_DATE >=trunc(SYSDATE))
   and COMPANY_CODE = l_company
   and CASHFLOW_AMOUNT <> 0
   and CURRENCY = substr(l_combin,1,3)
   and nvl(PORTFOLIO_CODE,'%') like nvl(upper(l_portfolio),'%')
   and CURRENCY_COMBINATION = upper(l_combin)
   and (incl_options = 'Y' or (incl_options = 'N' and AMOUNT_TYPE NOT IN('FXOBUY','FXOSELL')))
   and nvl(multiple_settlements,'N') <> 'Y'
   group by CURRENCY,to_char(nvl(EXPOSURE_REF_DATE,AMOUNT_DATE),'DD-MM-YYYY'),CURRENCY_COMBINATION,
                decode(DEAL_TYPE,'FX',TRANSACTION_NUMBER,'FXO',TRANSACTION_NUMBER,1),
                decode(DEAL_TYPE,'FX',nvl(EXPOSURE_REF_DATE,AMOUNT_DATE),'FXO',nvl(EXPOSURE_REF_DATE,AMOUNT_DATE),NULL);
--
 cursor GET_EXPOSURES is
  select CURRENCY,to_char(AMOUNT_DATE,'DD-MM-YYYY'),sum(CASHFLOW_AMOUNT),
            CURRENCY_COMBINATION,sum(TRANSACTION_RATE),
            decode(DEAL_TYPE,'FX',TRANSACTION_NUMBER,'FXO',TRANSACTION_NUMBER,1),
            decode(DEAL_TYPE,'FX',AMOUNT_DATE,'FXO',AMOUNT_DATE,NULL),count(AMOUNT)
   from XTR_DEAL_DATE_AMOUNTS_V
   where STATUS_CODE = 'CURRENT'
   and AMOUNT_DATE >= trunc(SYSDATE)
   and COMPANY_CODE = l_company
   and ((deal_type='EXP' and perspective='^') or perspective <>'^')
   and CASHFLOW_AMOUNT <> 0
   and CURRENCY like upper(nvl(sel_ccy,'%'))
   and nvl(PORTFOLIO_CODE,'%') like nvl(upper(l_portfolio),'%')
   and CURRENCY_COMBINATION is NULL
   and ((DEAL_SUBTYPE = 'INDIC' and incl_indic_exp = 'Y') or
         DEAL_SUBTYPE <> 'INDIC')
   and nvl(multiple_settlements,'N') <> 'Y'
   group by CURRENCY,to_char(AMOUNT_DATE,'DD-MM-YYYY'),CURRENCY_COMBINATION,
            decode(DEAL_TYPE,'FX',TRANSACTION_NUMBER,'FXO',TRANSACTION_NUMBER,1),
            decode(DEAL_TYPE,'FX',AMOUNT_DATE,'FXO',AMOUNT_DATE,NULL);
--
 cursor GET_ACCT_BALS is
  select currency,sum(nvl(OPENING_BALANCE,0)),count(ACCOUNT_NUMBER)
   from XTR_BANK_ACCOUNTS
   where PARTY_CODE = l_company
   and CURRENCY like upper(nvl(sel_ccy,'%'))
   and nvl(PORTFOLIO_CODE,'%') like nvl(upper(l_portfolio),'%')
   and nvl(SETOFF_ACCOUNT_YN,'N') <> 'Y'
   group by currency;
--
-- Show reverse of call cash on hand where no maturity date exists
-- this is because the cashflow will/would have gone through the account but is
-- not reflected anywhere in the future
-- eg INVEST initial cflow is -ve therefore show as cash on hand (+ve)
--
 cursor GET_ONC_BALS is
  select d.currency,sum((-1) * d.cashflow_amount) CASH_ON_HAND
   from XTR_DEAL_DATE_AMOUNTS_V d,
        XTR_ROLLOVER_TRANSACTIONS_V r
   where d.STATUS_CODE = 'CURRENT'
   and d.DEAL_TYPE = 'ONC'
   and d.COMPANY_CODE = l_company
   and d.CURRENCY like upper(nvl(sel_ccy,'%'))
   and nvl(d.PORTFOLIO_CODE,'%') like nvl(upper(l_portfolio),'%')
   and nvl(d.multiple_settlements,'N') = 'N'
   and d.CASHFLOW_AMOUNT <> 0
   and r.deal_number = d.deal_number
   and r.transaction_number = d.transaction_number
   and r.maturity_date is NULL
   group by d.currency;
--
 cursor SELECTED_CCY is
  select CURRENCY
    from XTR_FX_WHAT_IFS
    where UNIQUE_REF_NUMBER = ref_number
    and REVIEW = 'Y';
--
 cursor DIST_CCY_COMBIN is
  select distinct CURRENCY_FIRST||'/'||CURRENCY_SECOND
   from XTR_BUY_SELL_COMBINATIONS
   where CURRENCY_FIRST IN(select CURRENCY
    from XTR_FX_WHAT_IFS
    where UNIQUE_REF_NUMBER = ref_number)
    or CURRENCY_SECOND IN(select CURRENCY
                           from XTR_FX_WHAT_IFS
                           where UNIQUE_REF_NUMBER = ref_number);
--
 cursor GET_FX_PERIOD is
 select currency,nvl(PERIOD_DESC,nvl(PERIOD_FROM,'0')||decode(nvl(TYPE_PERIOD_FROM_MONTH_YEAR,'M'),nvl(TYPE_PERIOD_TO_MONTH_YEAR,'M'),NULL,decode(nvl(TYPE_PERIOD_FROM_MONTH_YEAR,'M'),'M','Months','Years'))||'-'||
        nvl(PERIOD_TO,'0')||decode(nvl(TYPE_PERIOD_TO_MONTH_YEAR,'M'),'M','Months','Years')) PERIOD_NAME,
        add_months(trunc(count_months_from),decode(nvl(TYPE_PERIOD_FROM_MONTH_YEAR,'M'),'M',1,12)*nvl(PERIOD_FROM,0)) P_FROM,
        decode(PERIOD_TO,NULL,to_date('01/01/2200','DD/MM/YYYY'),add_months(trunc(count_months_from),decode(nvl(TYPE_PERIOD_TO_MONTH_YEAR,'M'),'M',1,12)*PERIOD_TO)) P_TO,
        FX_PERCENT_MAX,FX_PERCENT_MIN,period_desc
 from XTR_INTEREST_RATE_BANDS
 where currency like upper(nvl(p_sel_ccy,'%'))
 and currency not in(select home_currency
                      from XTR_parties_v
                      where party_type='C');
--
 l_fx_ccy 		varchar2(15);
 l_period_name	varchar2(20);
 l_p_from		date;
 l_p_to		date;
 l_max 		number;
 l_min 		number;
 l_period_desc	varchar2(20);
--
 cursor GET_FX_POSTION is
  SELECT nvl(sum(decode(CURRENCY_COMBINATION,NULL,AMOUNT,0)),0) exp_amt,
         nvl(sum(decode(CURRENCY_COMBINATION,NULL,0,
         decode(currency,l_fx_ccy,AMOUNT,-AMOUNT*round(TRANSACTION_RATE,5)))),0) fx_amt
  from XTR_EXPOSURE_SUMMARY
  where UNIQUE_REF_NUMBER = ref_number
  and((currency_combination is null and currency = l_fx_ccy) or
      (currency_combination is not null and
      (substr(currency_combination,1,3) = l_fx_ccy or substr(currency_combination,5,3) = l_fx_ccy)))
  and period_date >= l_p_from
  and period_date < l_p_to
  and hedge_trade_whatif = 'W';
--
 l_exp_amt NUMBER;
 l_fx_amt  NUMBER;
--
cursor get_ccy_exp is
 select YEAR_BASIS, ROUNDING_FACTOR
  from  XTR_MASTER_CURRENCIES_V
  where CURRENCY = l_ccy;
--
cursor get_ccy_fx is
 select YEAR_BASIS, ROUNDING_FACTOR
  from  XTR_MASTER_CURRENCIES_V
  where CURRENCY = l_row_ccy;
--
 l_year_basis NUMBER;
 l_rounding   NUMBER;
--
begin
 delete from XTR_exposure_summary
  where created_on < (trunc(sysdate) - 7);
 delete from XTR_tmp_fx_exposure
  where created_on < (trunc(sysdate) - 7);
--
 commit;
--
if p_count_months_from is NULL then
 count_months_from := trunc(sysdate);
else
 count_months_from := trunc(p_count_months_from);
end if;
--
open SELECTED_CCY;
LOOP
 fetch SELECTED_CCY INTO sel_ccy;
 EXIT WHEN SELECTED_CCY%NOTFOUND;
 --
 open GET_EXPOSURES;
 LOOP
  fetch GET_EXPOSURES INTO l_ccy,l_date,l_amount,l_combination,l_rate,l_deal_ty,l_amount_date,l_num_items;
 EXIT WHEN GET_EXPOSURES%NOTFOUND or l_amount is NULL;
 --
 open get_ccy_exp;
  fetch get_ccy_exp into l_year_basis,l_rounding;
 close get_ccy_exp;
 --
 if l_amount_date is NOT NULL then
  l_avg_days := round(l_amount_date - trunc(count_months_from),0);
 else
  l_avg_days := round(to_date(l_date,'DD-MM-YYYY') - trunc(count_months_from),0);
 end if;
 if l_avg_days = 0 then
  l_avg_days := 1;
 end if;
 if l_yield_curve is NOT NULL then
  XTR_fps2_P.EXTRAPOLATE_FROM_YIELD_CURVE(sel_ccy,l_avg_days,l_yield_curve,disc_rate);
 else
  XTR_fps2_P.EXTRAPOLATE_FROM_MARKET_PRICES(sel_ccy,l_avg_days,disc_rate);
 end if;
 if nvl(disc_rate,0) = 0 then
  -- Use Default Discount Rate
  if nvl(l_dflt_disc_rate,0) = 0 then
   disc_value := l_amount;
  else
   disc_rate := l_dflt_disc_rate;
   XTR_fps2_P.DISCOUNT_INTEREST_CALC(nvl(l_year_basis,360),l_amount,disc_rate,l_avg_days,
                                                       nvl(l_rounding,2),disc_value);
   disc_value := l_amount - disc_value;
  end if;
 else
  XTR_fps2_P.DISCOUNT_INTEREST_CALC(nvl(l_year_basis,360),l_amount,disc_rate,l_avg_days,
                                                      nvl(l_rounding,2),disc_value);
  disc_value := l_amount - disc_value;
 end if;
 --
 /*
 -- Calculate FX Forward Rate for Ccy Combinations
 if l_combination is NOT NULL then
   CALC_FX_FWD_RATE(substr(l_combination,1,3),substr(l_combination,5,3),l_company,
                                     nvl(l_year_basis,360),(trunc(count_months_from) + l_avg_days),
                                     substr(l_combination,1,3),l_fwd_fx_rate);
 else
  l_fwd_fx_rate := NULL;
 end if;
 */
 --
 begin
 if nvl(l_amount,0) <>0 then
 insert into XTR_EXPOSURE_SUMMARY
  (unique_ref_number,currency,period,amount,average_days,weighted_average,currency_combination,
   transaction_rate,created_on,created_by,incl_fx_options,incl_indic_exposures,company,base_currency,
   number_of_items,acct_balance,portfolio_code,hedge_or_trade_view,discount_rate,discounted_back_to,
   discounted_value,yield_curve,forward_fx_rate,selected_ccy,selected_indic,selected_options,
   hedge_trade_whatif,selected_portfolio,period_date)
 values
  (ref_number,l_ccy,l_date,round(l_amount,2),l_avg_days,l_weight_avg,l_combination,round(l_rate,5),
   trunc(sysdate),fnd_global.user_id,
   incl_options,incl_indic_exp,l_company,l_base_ccy,l_num_items,'N',l_portfolio,decode(perspective,'^','W',perspective),disc_rate,
   trunc(sysdate),disc_value,l_yield_curve,l_fwd_fx_rate,nvl(p_sel_ccy,'%'),incl_indic_exp,incl_options,'W',l_portfolio,
   to_date(l_date,'DD-MM-YYYY'));
 end if;
exception
 when others then
  l_error := l_error + 1;
 end;
 END LOOP;
 close GET_EXPOSURES;
 --
if perspective <>'^' then
 l_onc_amount := 0;
 open GET_ONC_BALS;
  fetch GET_ONC_BALS into l_row_ccy,l_onc_amount;
 close GET_ONC_BALS;

 l_amount := 0;
 l_num_items := 0;

 open GET_ACCT_BALS;
  fetch GET_ACCT_BALS into l_row_ccy,l_amount,l_num_items;
 close GET_ACCT_BALS;
 --
 -- Add On Call Cash Balances to Account Balances
 l_amount := nvl(l_amount,0) + nvl(l_onc_amount,0);
 --
 begin
 if nvl(l_amount,0) <>0 then
 insert into XTR_EXPOSURE_SUMMARY
  (unique_ref_number,currency,period,amount,average_days,weighted_average,currency_combination,
   transaction_rate,created_on,created_by,incl_fx_options,incl_indic_exposures,company,base_currency,
   number_of_items,acct_balance,portfolio_code,hedge_or_trade_view,discount_rate,discounted_back_to,
   discounted_value,yield_curve,selected_ccy,selected_indic,selected_options,
   hedge_trade_whatif,selected_portfolio,period_date)
 values
  (ref_number,l_row_ccy,to_char(trunc(sysdate),'DD-MM-YYYY'),round(l_amount,2),1,0,null,null,trunc(sysdate),
   fnd_global.user_id,incl_options,incl_indic_exp,l_company,l_base_ccy,l_num_items,'Y',l_portfolio,perspective,
   0,trunc(sysdate),l_amount,l_yield_curve,nvl(p_sel_ccy,'%'),incl_indic_exp,incl_options,'W',l_portfolio,trunc(sysdate));
 end if;
 exception
 when others then
  l_error := l_error + 1;
 end;
end if;
END LOOP;
close SELECTED_CCY;
--
--
 open DIST_CCY_COMBIN;
 LOOP
  fetch DIST_CCY_COMBIN INTO l_combin;
 --
 EXIT WHEN  DIST_CCY_COMBIN%NOTFOUND;
 open GET_FX;
 LOOP
  fetch GET_FX INTO l_row_ccy,l_date,l_amount,l_combination,l_rate,l_deal_ty,
                    l_amount_date,l_num_items;
 EXIT WHEN GET_FX%NOTFOUND;
 open get_ccy_fx;
 fetch get_ccy_fx into l_year_basis,l_rounding;
 close get_ccy_fx;

 if l_amount_date is NOT NULL then
  l_avg_days := round(l_amount_date - trunc(count_months_from),0);
 else
  l_avg_days := round(to_date(l_date,'DD-MM-YYYY') - trunc(count_months_from),0);
 end if;
 if l_avg_days = 0 then
  l_avg_days := 1;
 end if;
 if l_yield_curve is NOT NULL then
  XTR_fps2_P.EXTRAPOLATE_FROM_YIELD_CURVE(l_row_ccy,l_avg_days,l_yield_curve,disc_rate);
 else
  XTR_fps2_P.EXTRAPOLATE_FROM_MARKET_PRICES(l_row_ccy,l_avg_days,disc_rate);
 end if;
 if nvl(disc_rate,0) = 0 then
  -- Use Default Discount Rate
  if nvl(l_dflt_disc_rate,0) = 0 then
   disc_value := l_amount;
  else
   disc_rate := l_dflt_disc_rate;
   XTR_fps2_P.DISCOUNT_INTEREST_CALC(nvl(l_year_basis,360),l_amount,disc_rate,l_avg_days,
                                                      nvl(l_rounding,2),disc_value);
   disc_value := l_amount - disc_value;
  end if;
 else
  XTR_fps2_P.DISCOUNT_INTEREST_CALC(nvl(l_year_basis,360),l_amount,disc_rate,l_avg_days,
                                                      nvl(l_rounding,2),disc_value);
  disc_value := l_amount - disc_value;
 end if;
 --
 /*
 -- Calculate FX Forward Rate for Ccy Combinations
 if l_combination is NOT NULL then
   CALC_FX_FWD_RATE(substr(l_combination,1,3),substr(l_combination,5,3),l_company,
                                     nvl(l_year_basis,360),(trunc(sysdate) + l_avg_days),
                                     substr(l_combination,1,3),l_fwd_fx_rate);
 else
  l_fwd_fx_rate := NULL;
 end if;
 */
 --
 begin
 if nvl(l_amount,0) <>0 then
 insert into XTR_EXPOSURE_SUMMARY
  (unique_ref_number,currency,period,amount,average_days,weighted_average,currency_combination,
   transaction_rate,created_on,created_by,incl_fx_options,incl_indic_exposures,company,base_currency,
   number_of_items,acct_balance,portfolio_code,hedge_or_trade_view,discount_rate,discounted_back_to,
   discounted_value,yield_curve,forward_fx_rate,selected_ccy,selected_indic,selected_options,
   hedge_trade_whatif,selected_portfolio,period_date)
 values
  (ref_number,l_row_ccy,l_date,round(l_amount,2),l_avg_days,l_weight_avg,l_combination,round(l_rate,5),
   trunc(sysdate),fnd_global.user_id,
   incl_options,incl_indic_exp,l_company,l_base_ccy,l_num_items,'N',l_portfolio,decode(perspective,'^','W',perspective),disc_rate,
   trunc(sysdate),disc_value,l_yield_curve,l_fwd_fx_rate,nvl(p_sel_ccy,'%'),incl_indic_exp,incl_options,'W',l_portfolio,
   to_date(l_date,'DD-MM-YYYY'));
 end if;
 exception
 when others then
  l_error := l_error + 1;
 end;
 END LOOP;
 close GET_FX;
 --
END LOOP;
close DIST_CCY_COMBIN;
------------
-- FX POSITION
 open GET_FX_PERIOD;
 LOOP
  fetch GET_FX_PERIOD into l_fx_ccy,l_period_name,l_p_from,l_p_to,l_max,l_min,l_period_desc;
 EXIT WHEN GET_FX_PERIOD%NOTFOUND;
 --
 l_exp_amt := 0;
 l_fx_amt  := 0;
 --
 open GET_FX_POSTION;
  fetch GET_FX_POSTION into l_exp_amt,l_fx_amt;
 if GET_FX_POSTION%NOTFOUND then
  l_exp_amt := 0;
  l_fx_amt := 0;
 end if;
 close GET_FX_POSTION;
 --
 insert into XTR_TMP_FX_EXPOSURE
  (unique_ref_number,currency,period_name,period_desc,FX_PERCENT_MAX,FX_PERCENT_MIN,
   exp_amount,fx_amount,created_on,created_by,incl_fx_options,incl_indic_exposures,
   company,base_currency,selected_base_currency,selected_ccy,selected_portfolio,yield_curve,
   period_from,period_to,net_exposure,cover_to_forecast,max_amount,min_amount)
 values
  (ref_number,l_fx_ccy,l_period_name,l_period_desc,l_max,l_min,round(l_exp_amt,2),round(l_fx_amt,2),
   trunc(sysdate),fnd_global.user_id,incl_options,incl_indic_exp,l_company,l_base_ccy,l_base_ccy,nvl(p_sel_ccy,'%'),
   l_portfolio,l_yield_curve,l_p_from,l_p_to,nvl(round(l_exp_amt,2),0)+nvl(round(l_fx_amt,2),0),
   decode(nvl(round(l_exp_amt,2),0),0,null,round(nvl(-100*round(l_fx_amt,2),0)/round(l_exp_amt,2),2)),
   (nvl(l_max,0)*nvl(round(-l_exp_amt,2),0))/100-nvl(round(l_fx_amt,2),0),
   (nvl(l_min,0)*nvl(round(-l_exp_amt,2),0))/100-nvl(round(l_fx_amt,2),0));
 END LOOP;
 close GET_FX_PERIOD;
 commit;
end CALC_ALL_CCY_EXPOSURES;
--------------------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GET_SPOT_RATE(p_base_ccy    VARCHAR2,
                       p_contra_ccy  VARCHAR2,
                       p_date        DATE) RETURN NUMBER IS
cursor get_cross is
 SELECT BID_RATE
  FROM XTR_CURRENCY_CROSS_RATES
  WHERE CURRENCY_FIRST=p_base_ccy
  and CURRENCY_SECOND=p_contra_ccy
  and rate_date in(select max(rate_date)
                    from XTR_spot_rates
                    where CURRENCY_FIRST=p_base_ccy
                    and CURRENCY_SECOND=p_contra_ccy
                    and to_char(rate_date,'DD-MM-YYYY')=to_char(p_date,'DD-MM-YYYY'));
--
cursor get_rate(l_ccy varchar2) is
 SELECT USD_BASE_CURR_BID_RATE
  FROM XTR_spot_rates
  WHERE currency = l_ccy
  and rate_date in(select max(rate_date)
                    from XTR_spot_rates
                    where currency=l_ccy
                    and to_char(rate_date,'DD-MM-YYYY')=to_char(p_date,'DD-MM-YYYY'));
 l_base_rate	number;
 l_contra_rate	number;
begin
l_base_rate :=null;
if p_base_ccy <>'USD' and p_contra_ccy <>'USD' then
  open get_cross;
  fetch get_cross into l_base_rate;
  close get_cross;
end if;
if l_base_rate is null then
 l_base_rate :=null;
 l_contra_rate :=null;
 if p_base_ccy ='USD' then
   l_base_rate :=1;
 else
   open get_rate(p_base_ccy);
   fetch get_rate into l_base_rate;
   close get_rate;
 end if;
 if p_contra_ccy ='USD' then
   l_contra_rate :=1;
 else
   open get_rate(p_contra_ccy);
   fetch get_rate into l_contra_rate;
   close get_rate;
 end if;
 if nvl(l_base_rate,0) <>0 then
   return(round(l_contra_rate/l_base_rate,4));
 else
   return(NULL);
 end if;
else
  return(l_base_rate);
end if;
end GET_SPOT_RATE;
-------------------------------------------------------------------------------------------------
FUNCTION GET_HCE_RATE(p_base_ccy    VARCHAR2,
                       p_date        DATE) RETURN NUMBER IS

cursor get_rate is
 select HCE_RATE
  from XTR_spot_rates
  where currency=p_base_ccy
  and rate_date in(select max(rate_date)
                    from XTR_spot_rates
                    where currency = p_base_ccy
                    and to_char(rate_date,'DD-MM-YYYY')=to_char(p_date,'DD-MM-YYYY'));
 --
 l_hce_rate	number;
 --
begin
open get_rate;
 fetch get_rate into l_hce_rate;
close get_rate;
return(l_hce_rate);
end GET_HCE_RATE;
---------------------------------------------------------------------
--PROCEDURE SUMMARY_COST_OF_FUNDS is
PROCEDURE SUMMARY_COST_OF_FUNDS(errbuf	OUT NOCOPY VARCHAR2,
				retcode OUT NOCOPY NUMBER) is
--
 l_run_date date := sysdate;
 l_date     date;
--
/*
cursor get_cof is
 select company_code,deal_type,currency,contra_ccy,currency_combination,
        decode(deal_type,'FX','%',deal_subtype) deal_subtype,
        limit_party,
        product_type,
        portfolio_code,
        sum(nvl(amount_indic,1)*nvl(amount,0)) gross_principal,
        sum(nvl(amount_indic,1)*nvl(amount,0)*nvl(transaction_rate,0)
        /(decode(deal_type,'FX',1,'FXO',1,100))) weighted_amt,
        count(distinct decode(deal_type,'ONC',transaction_number,deal_number)) no_of_deals
 from XTR_MIRROR_DDA_LIMIT_ROW_V
 where (amount_date >= l_date or deal_type = 'ONC' or deal_type = 'CMF')
 and deal_type <>'CA'
 group by company_code,deal_type,currency,contra_ccy,currency_combination,
       decode(deal_type,'FX','%',deal_subtype),limit_party,product_type,portfolio_code;
*/
--
cursor get_cof is
 select a.company_code,a.deal_type,a.currency,a.contra_ccy,a.currency_combination,
        decode(a.deal_type,'FX','%',a.deal_subtype) subtype,
        a.limit_party,
        a.product_type,
        a.portfolio_code,
        round(sum(nvl(a.amount_indic,1)*nvl(a.amount,0)),0) gross_principal,
        round(sum(nvl(a.amount_indic,1)*nvl(a.amount,0)*nvl(a.transaction_rate,0)
        /(decode(a.deal_type,'FX',1,'FXO',1,100))),0) weighted_amt,
        count(distinct a.deal_number) no_of_deals
 from XTR_MIRROR_DDA_LIMIT_ROW_V a,
      XTR_DEALS_V b
 where a.amount_date > l_date
 and a.deal_type not in('CA','ONC','CMF','IG')
 and a.deal_number=b.deal_no
 and (nvl(b.start_date,l_date) <= l_date or a.deal_type='FXO')
 group by a.company_code,a.deal_type,a.currency,a.contra_ccy,a.currency_combination,
       decode(a.deal_type,'FX','%',a.deal_subtype),a.limit_party,a.product_type,a.portfolio_code
union all
 select a.company_code,a.deal_type,a.currency,a.contra_ccy,a.currency_combination,
        a.deal_subtype subtype,
        a.limit_party,
        a.product_type,
        a.portfolio_code,
        round(sum(nvl(a.amount_indic,1)*nvl(a.amount,0)),0) gross_principal,
        round(sum(nvl(a.amount_indic,1)*nvl(a.amount,0)*nvl(a.transaction_rate,0)/100),0) weighted_amt,
        count(distinct decode(a.deal_type,'ONC',a.transaction_number,a.deal_number)) no_of_deals
 from XTR_MIRROR_DDA_LIMIT_ROW_V a,
      XTR_ROLLOVER_TRANSACTIONS_V b
 where a.deal_type in('ONC','CMF','IG')
 and a.deal_number=b.deal_number
 and a.transaction_number=b.transaction_number
 and nvl(b.start_date,l_date) <=l_date
 group by a.company_code,a.deal_type,a.currency,a.contra_ccy,a.currency_combination,
       a.deal_subtype,a.limit_party,a.product_type,a.portfolio_code;
--
 cof get_cof%rowtype;
 l_avg_rate number;
 l_interest number;
--
cursor get_prv_row is
 select as_at_date
  from XTR_cost_of_funds
  where as_at_date < l_date
 order by as_at_date desc;
--
 l_prv_date date;
 l_ins_date date;
--
cursor chk_exits is
 select 1
  from XTR_cost_of_funds
  where as_at_date = l_date;
--
l_dummy number;
--
cursor get_tmm_row is
 select rowid,deal_number
  from XTR_mirror_dda_limit_row_V
  where amount_date > l_date
  and deal_type = 'TMM';
--
l_deal_no number;
l_rowid   varchar2(30);
--
cursor get_tmm_rate is
 select INTEREST_RATE
  from XTR_rollover_transactions_V
  where deal_number=l_deal_no
  and deal_type='TMM'
  and start_date<=l_date
  and maturity_date>l_date
  order by start_date desc;
--
l_transaction_rate number;
--
cursor get_ca_row is
 select COMPANY_CODE,CURRENCY,DEAL_TYPE,AMOUNT_DATE,TRANSACTION_RATE,
          CONTRA_CCY,CURRENCY_COMBINATION,DEAL_SUBTYPE,
          AMOUNT,HCE_AMOUNT,LIMIT_PARTY,PORTFOLIO_CODE,PRODUCT_TYPE,ACCOUNT_NO
  from XTR_mirror_dda_limit_row_V
  where deal_type='CA';

--
bal get_ca_row%ROWTYPE;
--
cursor get_hce_rate(l_ccy varchar2) is
 select nvl(hce_rate,1),year_basis
  from XTR_master_currencies
  where currency = l_ccy;
--
l_hce_rate	number;
l_year_basis number;
--

begin
-- check time
if to_number(to_char(l_run_date,'HH24')) <6 then
 l_date :=trunc(sysdate)-1;
else
 l_date :=trunc(sysdate);
end if;

-- delete COF if already exits
open chk_exits;
 fetch chk_exits into l_dummy;
 if chk_exits%FOUND then
  delete from XTR_cost_of_funds
   where as_at_date = l_date;
 end if;
close chk_exits;

-- get previous run date and copy into COF if has not run this script everyday.

l_prv_date :=null;
open get_prv_row;
 fetch get_prv_row into l_prv_date;
if get_prv_row%FOUND then
 close get_prv_row;
 l_ins_date :=l_prv_date+1;
 WHILE TRUE LOOP
  if l_ins_date<=l_date-1 then
   insert into XTR_COST_OF_FUNDS
               (AS_AT_DATE,COMPANY_CODE,CURRENCY,DEAL_TYPE,AVG_INTEREST_RATE,
                CONTRA_CCY,CURRENCY_COMBINATION,DEAL_SUBTYPE,
                GROSS_PRINCIPAL,HCE_GROSS_PRINCIPAL,INTEREST,HCE_INTEREST,
                NO_OF_DAYS,NO_OF_DEALS,PARTY_CODE, PORTFOLIO_CODE,PRODUCT_TYPE,
                WEIGHTED_AVG_PRINCIPAL,ACCOUNT_NO,CREATED_ON)
      select l_ins_date,COMPANY_CODE,CURRENCY,DEAL_TYPE,AVG_INTEREST_RATE,
                CONTRA_CCY,CURRENCY_COMBINATION,DEAL_SUBTYPE,
                GROSS_PRINCIPAL,HCE_GROSS_PRINCIPAL,INTEREST,HCE_INTEREST,
                NO_OF_DAYS,NO_OF_DEALS,PARTY_CODE, PORTFOLIO_CODE,PRODUCT_TYPE,
                WEIGHTED_AVG_PRINCIPAL,ACCOUNT_NO,trunc(l_run_date)
       from XTR_COST_OF_FUNDS where as_at_date=l_prv_date;
  elsif l_ins_date=l_date then
   insert into XTR_COST_OF_FUNDS
               (AS_AT_DATE,COMPANY_CODE,CURRENCY,DEAL_TYPE,AVG_INTEREST_RATE,
                CONTRA_CCY,CURRENCY_COMBINATION,DEAL_SUBTYPE,
                GROSS_PRINCIPAL,HCE_GROSS_PRINCIPAL,INTEREST,HCE_INTEREST,
                NO_OF_DAYS,NO_OF_DEALS,PARTY_CODE, PORTFOLIO_CODE,PRODUCT_TYPE,
                WEIGHTED_AVG_PRINCIPAL,ACCOUNT_NO,CREATED_ON)
      select l_ins_date,COMPANY_CODE,CURRENCY,DEAL_TYPE,NULL,
                CONTRA_CCY,CURRENCY_COMBINATION,DEAL_SUBTYPE,
                0,0,0,0,
                1,0,PARTY_CODE, PORTFOLIO_CODE,PRODUCT_TYPE,
                0,ACCOUNT_NO,l_run_date
       from XTR_COST_OF_FUNDS where as_at_date=l_prv_date;
  end if;
   l_ins_date :=l_ins_date+1;
   if l_ins_date >=l_date then
     exit;
   end if;
 END LOOP;
else
  close get_prv_row;
end if;

----
-- Only for CA, update amount,rate where as_at_date >=balance_date
open get_ca_row;
 LOOP
  fetch get_ca_row into bal;
 open get_hce_rate(bal.currency);
  fetch get_hce_rate into l_hce_rate,l_year_basis;
 close get_hce_rate;
 exit WHEN get_ca_row%NOTFOUND;

   update XTR_cost_of_funds
     set AVG_INTEREST_RATE = round(bal.transaction_rate,5),
         GROSS_PRINCIPAL = round(bal.amount,0),
         HCE_GROSS_PRINCIPAL = round(bal.amount/l_hce_rate,0),
         WEIGHTED_AVG_PRINCIPAL = round(bal.amount*bal.transaction_rate/100,0),
         INTEREST = round(no_of_days*bal.amount*bal.transaction_rate/(100*l_year_basis),2),
         HCE_INTEREST = round((no_of_days*bal.amount*bal.transaction_rate/(100*l_year_basis))/l_hce_rate,2)
     where as_at_date >= bal.amount_date and as_at_date <>l_date
     and deal_type='CA'
     and deal_subtype=bal.deal_subtype
     and currency=bal.currency
     and company_code=bal.company_code
     and account_no=bal.account_no
     and nvl(portfolio_code,'@#@')=nvl(bal.portfolio_code,'@#@')
     and nvl(product_type,'@#@')=nvl(bal.product_type,'@#@')
     and nvl(party_code,'@#@')=nvl(bal.limit_party,'@#@');

---- for today's

   update XTR_cost_of_funds
     set AVG_INTEREST_RATE = round(bal.transaction_rate,5),
         GROSS_PRINCIPAL = round(bal.amount,0),
         HCE_GROSS_PRINCIPAL = round(bal.amount/l_hce_rate,0),
         WEIGHTED_AVG_PRINCIPAL = round(bal.amount*bal.transaction_rate/100,0),
         INTEREST = round(no_of_days*bal.amount*bal.transaction_rate/(100*l_year_basis),2),
         HCE_INTEREST = round((no_of_days*bal.amount*bal.transaction_rate/(100*l_year_basis))/l_hce_rate,2)
     where as_at_date =l_date
     and deal_type='CA'
     and deal_subtype=bal.deal_subtype
     and currency=bal.currency
     and company_code=bal.company_code
     and account_no=bal.account_no
     and nvl(portfolio_code,'@#@')=nvl(bal.portfolio_code,'@#@')
     and nvl(product_type,'@#@')=nvl(bal.product_type,'@#@')
     and nvl(party_code,'@#@')=nvl(bal.limit_party,'@#@');
   if SQL%NOTFOUND then
    insert into XTR_COST_OF_FUNDS
               (AS_AT_DATE,COMPANY_CODE,CURRENCY,DEAL_TYPE,AVG_INTEREST_RATE,
                CONTRA_CCY,CURRENCY_COMBINATION,DEAL_SUBTYPE,
                GROSS_PRINCIPAL,HCE_GROSS_PRINCIPAL,INTEREST,NO_OF_DAYS,NO_OF_DEALS,PARTY_CODE,
                PORTFOLIO_CODE,PRODUCT_TYPE,WEIGHTED_AVG_PRINCIPAL,ACCOUNT_NO,CREATED_ON)
     values(l_date,bal.COMPANY_CODE,bal.CURRENCY,bal.DEAL_TYPE,round(bal.TRANSACTION_RATE,5),
       bal.CONTRA_CCY,bal.CURRENCY_COMBINATION,bal.DEAL_SUBTYPE,
       round(bal.AMOUNT,0),round(bal.HCE_AMOUNT,0),
       round(bal.AMOUNT*bal.TRANSACTION_RATE/(100*l_year_basis),4),
       1,1,bal.LIMIT_PARTY,bal.PORTFOLIO_CODE,bal.PRODUCT_TYPE,
       round(bal.AMOUNT*bal.TRANSACTION_RATE/(100*l_year_basis),2),bal.ACCOUNT_NO,l_run_date);
   end if;
 END LOOP;
 close get_ca_row;

 --
 -- update transaction_rate for TMM in mirror_dda
 open get_tmm_row;
 LOOP
  fetch get_tmm_row into l_rowid,l_deal_no;
  exit WHEN get_tmm_row%NOTFOUND;
  l_transaction_rate :=null;
  open get_tmm_rate;
  fetch get_tmm_rate into l_transaction_rate;
  close get_tmm_rate;
   if l_transaction_rate is not null then
    update XTR_mirror_dda_limit_row
     set transaction_rate=l_transaction_rate
     where rowid=l_rowid;
   end if;
 END LOOP;
 close get_tmm_row;
 --

 --insert into COF
 open get_cof;
 LOOP
  fetch get_cof into cof;
  exit WHEN get_cof%NOTFOUND;
  open get_hce_rate(cof.currency);
  fetch get_hce_rate into l_hce_rate,l_year_basis;
  close get_hce_rate;

  if cof.deal_type in('ONC','CA','IG','NI','TMM','BOND','DEB','IRS','CMF') then
   if nvl(cof.gross_principal,0) <>0 then
     l_avg_rate :=round(100*cof.weighted_amt/cof.gross_principal,5);
   else
     l_avg_rate :=null;
   end if;
   l_interest :=round(cof.gross_principal*l_avg_rate/(100*l_year_basis),2);
  else
   l_interest := null;
   l_avg_rate := null;
   if cof.deal_type in('FX','FXO') then
    if nvl(cof.gross_principal,0) <>0 then
     l_avg_rate := round(cof.weighted_amt/cof.gross_principal,5);
    else
     l_avg_rate := null;
    end if;
   end if;
  end if;
 --
   update XTR_cost_of_funds
     set AVG_INTEREST_RATE = l_avg_rate,
         GROSS_PRINCIPAL = cof.gross_principal,
         HCE_GROSS_PRINCIPAL = round(cof.GROSS_PRINCIPAL/l_hce_rate,0),
         WEIGHTED_AVG_PRINCIPAL = cof.weighted_amt,
         INTEREST = l_interest,
         HCE_INTEREST =round(l_interest/l_hce_rate,2),
         NO_OF_DAYS =1,
         NO_OF_DEALS=cof.NO_OF_DEALS
     where as_at_date =l_date
     and company_code=cof.company_code
     and deal_type=cof.deal_type
     and deal_subtype=cof.subtype
     and currency=cof.currency
     and nvl(contra_ccy,'@#@')=nvl(cof.contra_ccy,'@#@')
     and nvl(currency_combination,'@#@')=nvl(cof.currency_combination,'@#@')
     and nvl(portfolio_code,'@#@')=nvl(cof.portfolio_code,'@#@')
     and nvl(product_type,'@#@')=nvl(cof.product_type,'@#@')
     and nvl(party_code,'@#@')=nvl(cof.limit_party,'@#@');
   if SQL%NOTFOUND then
    insert into XTR_COST_OF_FUNDS
               (AS_AT_DATE,COMPANY_CODE,CURRENCY,DEAL_TYPE,AVG_INTEREST_RATE,
                CONTRA_CCY,CURRENCY_COMBINATION,DEAL_SUBTYPE,
                GROSS_PRINCIPAL,HCE_GROSS_PRINCIPAL,INTEREST,HCE_INTEREST,
                NO_OF_DAYS,NO_OF_DEALS,PARTY_CODE, PORTFOLIO_CODE,PRODUCT_TYPE,
                WEIGHTED_AVG_PRINCIPAL,ACCOUNT_NO,CREATED_ON)
     values(l_date,cof.COMPANY_CODE,cof.CURRENCY,cof.DEAL_TYPE,
        round(l_avg_rate,5),cof.CONTRA_CCY,cof.CURRENCY_COMBINATION,
        cof.SUBTYPE,round(cof.GROSS_PRINCIPAL,0),round(cof.GROSS_PRINCIPAL/l_hce_rate,0),
        l_interest,round(l_interest/l_hce_rate,2),1,cof.NO_OF_DEALS,cof.LIMIT_PARTY,
        cof.PORTFOLIO_CODE,cof.PRODUCT_TYPE,cof.weighted_amt,'%',l_run_date);
   end if;
 end LOOP;
 close get_cof;
 ----commit;
 end SUMMARY_COST_OF_FUNDS;
---------------------------------------------------------------------
PROCEDURE MAINTAIN_COST_OF_FUNDS(
 L_REF_DATE			IN date,
 L_COMPANY_CODE		IN VARCHAR2,
 L_CURRENCY			IN VARCHAR2,
 L_DEAL_TYPE		IN VARCHAR2,
 L_DEAL_SUBTYPE		IN VARCHAR2,
 L_PRODUCT_TYPE		IN VARCHAR2,
 L_PORTFOLIO_CODE		IN VARCHAR2,
 L_PARTY_CODE		IN VARCHAR2,
 L_CONTRA_CCY		IN VARCHAR2,
 L_CURRENCY_COMBINATION	IN VARCHAR2,
 L_ACCOUNT			IN VARCHAR2,
 L_AMOUNT_DATE	      IN DATE,
 L_TRANSACTION_RATE	IN NUMBER,
 L_AMOUNT			IN NUMBER,
 L_AMOUNT_INDIC		IN NUMBER,
 L_ACTION_INDIC		IN NUMBER) is

---
 cursor GET_DIST_DATE is
  select DISTINCT AS_AT_DATE
   from XTR_COST_OF_FUNDS
   where AS_AT_DATE >= L_REF_DATE
   and (DEAL_TYPE in('ONC','CA') or AS_AT_DATE < L_AMOUNT_DATE)
   ORDER BY AS_AT_DATE ASC;

 l_dist_date		date;

 cursor DET is
  select GROSS_PRINCIPAL,
         GROSS_PRINCIPAL * AVG_INTEREST_RATE / decode(DEAL_TYPE,'FX',1,'FXO',1,100),
         NO_OF_DAYS,ROWID
   from XTR_COST_OF_FUNDS
   where AS_AT_DATE = l_dist_date
   and DEAL_TYPE = L_DEAL_TYPE
   and COMPANY_CODE = L_COMPANY_CODE
   and CURRENCY = L_CURRENCY
   and nvl(CONTRA_CCY,'%')=nvl(L_CONTRA_CCY,'%')
   and nvl(CURRENCY_COMBINATION,'%')=nvl(L_CURRENCY_COMBINATION,'%')
   and DEAL_SUBTYPE = L_DEAL_SUBTYPE
   and nvl(PRODUCT_TYPE,'%') = nvl(L_PRODUCT_TYPE,'%')
   and nvl(PORTFOLIO_CODE,'%') = nvl(L_PORTFOLIO_CODE,'%')
   and nvl(PARTY_CODE,'%') = nvl(L_PARTY_CODE,'%')
   and nvl(ACCOUNT_NO,'%') = nvl(L_ACCOUNT,'%');
--
 cursor get_prv_date is
   select AS_AT_DATE
   from XTR_COST_OF_FUNDS
   where AS_AT_DATE <= L_REF_DATE
   order by as_at_date desc;

--
 cursor get_nxt_date is
   select AS_AT_DATE
   from XTR_COST_OF_FUNDS
   where AS_AT_DATE > L_REF_DATE
   order by as_at_date asc;
l_nxt_date		date;
--
cursor get_hce_rate(l_ccy varchar2) is
 select nvl(hce_rate,1),year_basis
  from XTR_master_currencies
  where currency = l_ccy;
--
l_hce_rate	number;
l_year_basis number;
--
l_prv_date		date;

cursor get_cof_row is
 select rowid row_id,deal_type,currency,gross_principal,avg_interest_rate
  from XTR_cost_of_funds
  where as_at_date = l_prv_date;

 cursor get_no_of_days is
   select decode(AS_AT_DATE,L_REF_DATE,no_of_days,as_at_date - L_REF_DATE)
    from XTR_COST_OF_FUNDS
   where AS_AT_DATE >= L_REF_DATE
   order by AS_AT_DATE;

 cursor get_prv_row is
   select AS_AT_DATE,CURRENCY,DEAL_TYPE,GROSS_PRINCIPAL,AVG_INTEREST_RATE,ROWID
   from XTR_COST_OF_FUNDS
   where AS_AT_DATE = L_REF_DATE
   and (DEAL_TYPE in('ONC','CA') or AS_AT_DATE < L_AMOUNT_DATE)
   and DEAL_TYPE = L_DEAL_TYPE
   and COMPANY_CODE = L_COMPANY_CODE
   and CURRENCY = L_CURRENCY
   and nvl(CONTRA_CCY,'%')=nvl(L_CONTRA_CCY,'%')
   and nvl(CURRENCY_COMBINATION,'%')=nvl(L_CURRENCY_COMBINATION,'%')
   and DEAL_SUBTYPE = L_DEAL_SUBTYPE
   and nvl(PRODUCT_TYPE,'%') = nvl(L_PRODUCT_TYPE,'%')
   and nvl(PORTFOLIO_CODE,'%') = nvl(L_PORTFOLIO_CODE,'%')
   and nvl(PARTY_CODE,'%') = nvl(L_PARTY_CODE,'%')
   and nvl(ACCOUNT_NO,'%') = nvl(L_ACCOUNT,'%')
   order by AS_AT_DATE desc;

 l_dummy		NUMBER;
 l_as_at_date	DATE;
 l_rowid		VARCHAR2(30);
 l_gross		NUMBER;
 l_gross_hce	NUMBER;
 l_rate		NUMBER;
 l_wavg		NUMBER;
 l_interest		NUMBER;
 l_interest_hce	NUMBER;
 l_no_of_days	NUMBER;
 c_no_of_days	NUMBER;
 c_interest		NUMBER;
 c_interest_hce	NUMBER;

 l_days		NUMBER;
 l_dummy_code	NUMBER;
 l_dummy_buf	VARCHAR2(100);

 p_ccy		VARCHAR2(15);
 p_avg_rate		NUMBER;
 p_deal_type	VARCHAR2(7);
--
 cursor HCE is
  select round(l_interest / s.HCE_RATE,2),
         round(l_gross / s.HCE_RATE,0)
   from XTR_MASTER_CURRENCIES s
   where s.CURRENCY = L_CURRENCY;
--

begin
if nvl(L_AMOUNT,0) <>0 and L_REF_DATE <trunc(sysdate) then

  l_prv_date :=null;
  open get_prv_date;
   fetch get_prv_date  into l_prv_date;
  close get_prv_date;

  if l_prv_date <>L_REF_DATE then
   XTR_EXP_SUMM_P.SUMMARY_COST_OF_FUNDS(l_dummy_buf, l_dummy_code);
   l_prv_date :=L_REF_DATE;
  end if;

 if l_prv_date <> L_REF_DATE or l_prv_date is null then
   if l_prv_date is not null then
     l_nxt_date :=null;

     open get_nxt_date;
       fetch get_nxt_date  into l_nxt_date;
     close get_nxt_date;

     l_nxt_date :=nvl(l_nxt_date,trunc(sysdate));

  -- update previous row's no of days and interests;
  --
    l_no_of_days :=L_REF_DATE-l_prv_date;
    c_no_of_days :=l_nxt_date-l_REF_DATE;
 --
    for c in get_cof_row loop
     update XTR_cost_of_funds
      set no_of_days =l_no_of_days
      where rowid=c.row_id;
--
     if c.deal_type in('ONC','CA','IG','NI','TMM','BOND','DEB','IRS','CMF') then

     open get_hce_rate(c.currency);
      fetch get_hce_rate into l_hce_rate,l_year_basis;
      close get_hce_rate;
      l_interest :=round((c.gross_principal*l_no_of_days*c.avg_interest_rate)/(l_year_basis*100),2);
      l_interest_hce := round((c.gross_principal*l_no_of_days*c.avg_interest_rate)/(l_hce_rate*l_year_basis*100),2);

       c_interest :=round((c.gross_principal*c_no_of_days*c.avg_interest_rate)/(l_year_basis*100),2);
       c_interest_hce := round((c.gross_principal*c_no_of_days*c.avg_interest_rate)/(l_hce_rate*l_year_basis*100),2);
     else
      l_interest :=null;
      l_interest_hce :=null;
      c_interest :=null;
      c_interest_hce  :=null;
     end if;

    update XTR_cost_of_funds
     set interest = l_interest,
         hce_interest = l_interest_hce,
         no_of_days =l_no_of_days
     where rowid = c.row_id;

    insert into XTR_COST_OF_FUNDS
     (as_at_date,company_code,currency,deal_type,
      deal_subtype,party_code,portfolio_code,product_type,
      gross_principal,hce_gross_principal,
      weighted_avg_principal,avg_interest_rate,interest,
      hce_interest,no_of_days,no_of_deals,contra_ccy,
      currency_combination,account_no,created_on)
     select L_REF_DATE,company_code,currency,deal_type,
         deal_subtype,party_code,portfolio_code,product_type,
         gross_principal,hce_gross_principal,
         weighted_avg_principal,avg_interest_rate,c_interest,
         c_interest_hce,c_no_of_days,no_of_deals,contra_ccy,
         currency_combination,account_no,L_REF_DATE
      from XTR_cost_of_funds
      where rowid = c.row_id;
  end loop;

  end if;
 end if;

---
  l_no_of_days :=null;

  open get_no_of_days;
  fetch get_no_of_days into l_no_of_days;
  if get_no_of_days%NOTFOUND then
   l_no_of_days := trunc(sysdate) - l_ref_date;
  end if;
  close get_no_of_days;

  l_no_of_days :=nvl(l_no_of_days,0);

  l_as_at_date :=null;
  l_rowid :=null;

   open get_prv_row;
   fetch get_prv_row  into l_as_at_date,p_ccy,p_deal_type,l_gross,p_avg_rate,l_rowid;
   if get_prv_row%NOTFOUND then
     insert into XTR_COST_OF_FUNDS
     (as_at_date,company_code,currency,deal_type,
      deal_subtype,party_code,portfolio_code,product_type,
      gross_principal,hce_gross_principal,
      weighted_avg_principal,avg_interest_rate,interest,
      hce_interest,no_of_days,no_of_deals,contra_ccy,
      currency_combination,account_no,created_on)
     values
     (L_REF_DATE,L_COMPANY_CODE,L_CURRENCY,L_DEAL_TYPE,
      L_DEAL_SUBTYPE,L_PARTY_CODE,L_PORTFOLIO_CODE,
      L_PRODUCT_TYPE,0,0,0,0,0,
      0,l_no_of_days,0,L_CONTRA_CCY,L_CURRENCY_COMBINATION,L_ACCOUNT,
      trunc(sysdate));
   end if;
   close get_prv_row;
---

 open get_hce_rate(L_CURRENCY);
  fetch get_hce_rate into l_hce_rate,l_year_basis;
 close get_hce_rate;

 l_dist_date :=null;
 open GET_DIST_DATE;
 LOOP
 fetch GET_DIST_DATE into l_dist_date;
 exit when GET_DIST_DATE%NOTFOUND;
   l_gross :=null;
   l_rate :=null;
   l_wavg :=null;
   l_days :=null;
   l_rowid :=null;
   open DET;
   fetch DET INTO l_gross,l_wavg,l_days,l_rowid;
   close DET;
   l_gross := round(nvl(l_gross,0) + nvl(L_ACTION_INDIC,1)*nvl(L_AMOUNT,0)*nvl(L_AMOUNT_INDIC,1),0);
   if L_DEAL_TYPE in('FX','FXO') then
     l_wavg := round(nvl(l_wavg,0) + nvl(L_ACTION_INDIC,1)*nvl(L_AMOUNT,0)*nvl(L_AMOUNT_INDIC,1)*nvl(L_TRANSACTION_RATE,0),0);
     if nvl(l_gross,0) <>0 then
      l_rate :=round(l_wavg / l_gross,5);
     else
      l_rate :=null;
     end if;
     l_interest :=null;
   else
     l_wavg := round(nvl(l_wavg,0) + nvl(L_ACTION_INDIC,1)*nvl(L_AMOUNT,0)*nvl(L_AMOUNT_INDIC,1)*nvl(L_TRANSACTION_RATE,0)/100,0);
     if nvl(l_gross,0) <>0 then
      l_rate := round(l_wavg / l_gross*100,5);
     else
      l_rate :=null;
     end if;
     l_interest :=round((nvl(l_days,0)*l_wavg)/l_year_basis,2);
   end if;
   open HCE;
    fetch HCE INTO l_interest_hce,l_gross_hce;
   close HCE;

 -- insert / update record
/*
  if nvl(l_gross,0)=0 then
   delete from XTR_COST_OF_FUNDS
    where rowid=l_rowid;
  else
*/
   update XTR_COST_OF_FUNDS
    set GROSS_PRINCIPAL = round(l_gross,0),
       HCE_GROSS_PRINCIPAL = round(l_gross_hce,0),
       AVG_INTEREST_RATE = round(l_rate,5),
       HCE_INTEREST = round(l_interest_hce,2),
       WEIGHTED_AVG_PRINCIPAL = round(l_wavg,0),
       INTEREST = round(l_interest,2),
       NO_OF_DEALS=nvl(NO_OF_DEALS,0)+L_ACTION_INDIC
     where rowid=l_rowid;
   if SQL%NOTFOUND then
   -- insert new row
    insert into XTR_COST_OF_FUNDS
     (as_at_date,company_code,currency,deal_type,
      deal_subtype,party_code,portfolio_code,product_type,
      gross_principal,hce_gross_principal,
      weighted_avg_principal,avg_interest_rate,interest,
      hce_interest,no_of_days,no_of_deals,contra_ccy,
      currency_combination,account_no,created_on)
     values
     (nvl(l_dist_date,L_REF_DATE),L_COMPANY_CODE,L_CURRENCY,L_DEAL_TYPE,
      L_DEAL_SUBTYPE,L_PARTY_CODE,L_PORTFOLIO_CODE,
      L_PRODUCT_TYPE,round(l_gross,0),round(l_gross_hce,0),round(l_wavg,0),round(l_rate,5),round(l_interest,2),
      round(l_interest_hce,2),nvl(l_days,0),1,L_CONTRA_CCY,L_CURRENCY_COMBINATION,L_ACCOUNT,
      trunc(sysdate));
    end if;
 --- end if;
 end loop;
 close GET_DIST_DATE;
end if;
end MAINTAIN_COST_OF_FUNDS;
----------------------------------------------------------------------------------------
end XTR_EXP_SUMM_P;

/
