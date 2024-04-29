--------------------------------------------------------
--  DDL for Package Body XTR_HEDGE_PROCESS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_HEDGE_PROCESS_P" AS
/* $Header: xtrhdgpb.pls 120.8 2005/10/05 20:19:51 eaggarwa ship $ */


/*=====================================================================
   BEGIN: New objects for BUG 3378028 - FAS HEDGE ACCOUNTING PROJECT
======================================================================*/


/*-------------------------------------------------------
 This is a utility procedure to easily switch the debugging
 to the fnd_log file or SQL*PLUS console.
--------------------------------------------------------*/
PROCEDURE LOG_MSG(P_TEXT IN VARCHAR2 DEFAULT NULL, P_VALUE IN VARCHAR2 DEFAULT NULL) IS

l_flag VARCHAR2(1);

BEGIN

   if l_flag = 'D' then
      dbms_output.put_line(p_text||' : '||p_value);
   elsif l_flag = 'C' then
      fnd_file.put_line(1,p_text||' : '||p_value);
   else
      xtr_risk_debug_pkg.dlog(p_text, p_value);
   end if;

END LOG_MSG;

---------------------------------------------------------------------------

PROCEDURE CALC_RECLASS(P_COMPANY IN VARCHAR2,
		       P_BATCH_ID IN NUMBER,
                       P_HEDGE_NO IN NUMBER,
                       P_RECLASS_ID IN NUMBER,
                       P_DATE IN DATE) IS

l_retro_test_id    NUMBER;
l_approach         VARCHAR2(30);
l_round	           NUMBER;
l_gain_loss_ccy    VARCHAR2(15);
l_amount_type      VARCHAR2(30);
l_excl_item        VARCHAR2(30);

l_hedge_amt        NUMBER;
l_ref_amount       NUMBER;

l_orig_hedge_amt   NUMBER;
l_rem_hedge_amt    NUMBER;

l_rec_hdg_amt      NUMBER;
l_cum_rec_hdg_amt  NUMBER;
l_cum_rec_gl_amt   NUMBER;

l_cum_eff_amt      NUMBER;
l_rec_gl_amt       NUMBER;

l_deal_count       NUMBER;
l_deal_total       NUMBER;

l_item_prv_cum     NUMBER;
l_inst_prv_cum	   NUMBER;
l_eff_prv_cum      NUMBER;
l_ineff_prv_cum    NUMBER;
l_excl_prv_cum     NUMBER;

l_hd_eff_prv_cum   NUMBER;
l_hd_ineff_prv_cum NUMBER;
l_hd_excl_prv_cum  NUMBER;

cursor hdg is
select s.hedge_approach, h.hedge_amount, h.exclusion_item_code
from   xtr_hedge_strategies s, xtr_hedge_attributes h
where  s.strategy_code = h.strategy_code
and    h.hedge_attribute_id = p_hedge_no;

cursor ref_amt is
select abs(sum(r.reference_amount)) ref_amt
from   xtr_hedge_relationships r
where  r.hedge_attribute_id = p_hedge_no
and    instrument_item_flag = 'I';

cursor reclass is
select reclass_hedge_amt
from   xtr_reclass_details
where  reclass_details_id = p_reclass_id;

cursor prv_reclass is
select sum(reclass_hedge_amt), sum(reclass_gain_loss_amt)
from   xtr_reclass_details
where  hedge_attribute_id = p_hedge_no
and    reclass_date < p_date;

cursor cum_eff is
select eff_cum_gain_loss_amt
from   xtr_hedge_retro_tests T1
where  hedge_attribute_id = p_hedge_no
and    result_date = (select max(result_date) from xtr_hedge_retro_tests T2
                      where T1.hedge_attribute_id = T2.hedge_attribute_id
		      and result_code is not null);

-- Unit Test Change: Added "and result_code is not null" condition
-- This will give correct result for MANUAL Tests

cursor deal_count is
select count(primary_code) deal_count,
       abs(sum(nvl(reference_amount,0))) deal_total
from   xtr_hedge_relationships
where  hedge_attribute_id = p_hedge_no
and    instrument_item_flag = 'U';

cursor get_deals is
select primary_code deal_no,
       abs(nvl(reference_amount,0)) alloc_ref_amt
from   xtr_hedge_relationships
where  hedge_attribute_id = p_hedge_no
and    instrument_item_flag = 'U';

cursor get_cumu(p_hedge_no in number, p_batch_id in number) is
select item_cum_gain_loss_amt, inst_cum_gain_loss_amt, eff_cum_gain_loss_amt,
       ineff_cum_gain_loss_amt, excluded_cum_gain_loss_amt
from   xtr_hedge_retro_tests
where  hedge_attribute_id = p_hedge_no
and    result_date = (select max(result_date) from xtr_hedge_retro_tests r
                   where  r. hedge_attribute_id = p_hedge_no
                   and    r.batch_id <= p_batch_id);


cursor get_prev_ineff(p_hedge_no in number, p_deal_no in number) is
select eff_cum_gain_loss_amt, ineff_cum_gain_loss_amt, excluded_prd_gain_loss_amt
from   xtr_deal_retro_tests
where  hedge_attribute_id = p_hedge_no
and    deal_number = p_deal_no
and    result_date = (select max(result_date) from xtr_deal_retro_tests r
                   where  r. hedge_attribute_id = p_hedge_no
                   and    r.deal_number = p_deal_no
                   and    r.batch_id <= p_batch_id);

cursor cur_rnd(p_ccy in varchar2) is
select rounding_factor
from   xtr_master_currencies_v
where  currency = p_ccy;

BEGIN

  LOG_MSG('p_reclass_id', p_reclass_id);

  open  hdg;
  fetch hdg into l_approach, l_hedge_amt, l_excl_item;
  close hdg;

  if l_excl_item     = 'NONE' then
     l_amount_type  := 'UNREAL';
  elsif l_excl_item  = 'TIME' then
     l_amount_type  := 'CCYUNRL';
  end if;

  l_gain_loss_ccy := get_gl_ccy(l_amount_type, p_hedge_no, p_company);

  open  cur_rnd(l_gain_loss_ccy);
  fetch cur_rnd into l_round;
  close cur_rnd;

  if l_approach = 'FORECAST' then

    l_orig_hedge_amt := NVL(l_hedge_amt,0);

--  elsif l_approach = 'ASSTLIA' then
  else
    open  ref_amt;
    fetch ref_amt into l_orig_hedge_amt;
    close ref_amt;
  end if;

  LOG_MSG('l_orig_hedge_amt', l_orig_hedge_amt);

  open  reclass;
  fetch reclass into l_rec_hdg_amt;
  close reclass;

  LOG_MSG('l_rec_hdg_amt', l_rec_hdg_amt);

  open  prv_reclass;
  fetch prv_reclass into l_cum_rec_hdg_amt, l_cum_rec_gl_amt;
  close prv_reclass;

  LOG_MSG('l_cum_rec_hdg_amt', l_cum_rec_hdg_amt);
  LOG_MSG('l_cum_rec_gl_amt', l_cum_rec_gl_amt);

  l_rem_hedge_amt := nvl(l_orig_hedge_amt, 0) - nvl(l_cum_rec_hdg_amt, 0);

  LOG_MSG('l_rem_hedge_amt', l_rem_hedge_amt);

  open  cum_eff;
  fetch cum_eff into l_cum_eff_amt;
  close cum_eff;

  LOG_MSG('p_reclass_id'     , p_reclass_id);
  LOG_MSG('l_rec_hdg_amt'    , l_rec_hdg_amt);
  LOG_MSG('l_cum_eff_amt'    , l_cum_eff_amt);
  LOG_MSG('l_cum_rec_gl_amt' , l_cum_rec_gl_amt);
  LOG_MSG('l_orig_hedge_amt' , l_orig_hedge_amt);
  LOG_MSG('l_rem_hedge_amt'  , l_rem_hedge_amt);

  l_rec_gl_amt := round((l_rec_hdg_amt/l_rem_hedge_amt) * ( nvl(l_cum_eff_amt,0) - nvl(l_cum_rec_gl_amt,0)), l_round);

  LOG_MSG('l_rec_gl_amt' ,l_rec_gl_amt);

  LOG_MSG('event', 'updating xtr_reclass_details...');

  update xtr_reclass_details
  set    reclass_gain_loss_amt  = nvl(l_rec_gl_amt,0),
         retro_batch_id         = p_batch_id
  where  reclass_details_id     = p_reclass_id;

  LOG_MSG('event', 'updating xtr_hedge_relationships...');

  update xtr_hedge_relationships
  set    cur_pct_allocation = round(pct_allocation * (l_rem_hedge_amt - l_rec_hdg_amt)/l_orig_hedge_amt,2),
         cur_reference_amt  = round(reference_amount * (l_rem_hedge_amt - l_rec_hdg_amt)/l_orig_hedge_amt, l_round)
  where  hedge_attribute_id = p_hedge_no;

  LOG_MSG('event', 'updating xtr_hedge_retro_tests...');

  update xtr_hedge_retro_tests
  set    reclass_gain_loss_amt = nvl(l_rec_gl_amt,0)
  where  hedge_attribute_id = p_hedge_no
  and    result_date        = p_date;

  if sql%found then
     LOG_MSG('event', 'updated xtr_hedge_retro_tests sucessfully!');
  else
     LOG_MSG('event', 'could not update xtr_hedge_retro_tests. The hedge already matured.');

     open  get_cumu(p_hedge_no, p_batch_id);
     fetch get_cumu into l_item_prv_cum, l_inst_prv_cum, l_eff_prv_cum,
	        l_ineff_prv_cum, l_excl_prv_cum;
     close get_cumu;

     LOG_MSG('l_amount_type = '||l_amount_type);

    select xtr_hedge_retro_tests_s.nextval into l_retro_test_id from dual;

   insert into xtr_hedge_retro_tests
	(HEDGE_RETRO_TEST_ID, COMPANY_CODE, HEDGE_ATTRIBUTE_ID, RESULT_CODE,
	BATCH_ID, RESULT_DATE,CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
	LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,PROGRAM_ID, PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID, REQUEST_ID, COMPLETE_FLAG,GAIN_LOSS_CCY,
	AMOUNT_TYPE, ITEM_PRD_GAIN_LOSS_AMT, INST_PRD_GAIN_LOSS_AMT,
	ITEM_CUM_GAIN_LOSS_AMT, INST_CUM_GAIN_LOSS_AMT, PCT_EFFECTIVE, EFF_PRD_GAIN_LOSS_AMT,
	INEFF_PRD_GAIN_LOSS_AMT, EXCLUDED_PRD_GAIN_LOSS_AMT,
        RECLASS_GAIN_LOSS_AMT,
        EFF_CUM_GAIN_LOSS_AMT, INEFF_CUM_GAIN_LOSS_AMT, EXCLUDED_CUM_GAIN_LOSS_AMT
	)
   values (l_retro_test_id, p_company, p_hedge_no, NULL,
           p_batch_id, p_date, fnd_global.user_id, sysdate, fnd_global.user_id,
           sysdate, fnd_global.login_id, fnd_global.conc_program_id, fnd_global.conc_login_id,
           fnd_global.prog_appl_id, fnd_global.conc_request_id,'Y', l_gain_loss_ccy,
           l_amount_type, 0, 0, l_item_prv_cum, l_inst_prv_cum, NULL, 0,0,0,
           nvl(l_rec_gl_amt,0), l_eff_prv_cum, l_ineff_prv_cum, l_excl_prv_cum
	  );
   end if;

  open  deal_count;
  fetch deal_count into l_deal_count, l_deal_total;
  close deal_count;

  LOG_MSG('l_deal_count', l_deal_count);

  for r in get_deals loop

  LOG_MSG('event', 'updating xtr_deal_retro_tests...');

    update xtr_deal_retro_tests
    set    reclass_gain_loss_amt = nvl(l_rec_gl_amt,0) * round(r.alloc_ref_amt/l_deal_total, l_round)
    where  hedge_attribute_id = p_hedge_no
    and    deal_number = r.deal_no
    and    result_date = p_date;

    if sql%found then

      LOG_MSG('event', 'updated xtr_deal_retro_tests sucessfully!');

    else

      LOG_MSG('event', 'could not update xtr_deal_retro_tests. The hedge already matured.');

      open  get_prev_ineff(p_hedge_no, r.deal_no);
      fetch get_prev_ineff into l_hd_eff_prv_cum, l_hd_ineff_prv_cum, l_hd_excl_prv_cum;
      close get_prev_ineff;

      LOG_MSG('l_amount_type = '||l_amount_type);

      insert into xtr_deal_retro_tests
	(DEAL_RETRO_TEST_ID,
	 HEDGE_RETRO_TEST_ID,
         BATCH_ID,
         HEDGE_ATTRIBUTE_ID,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         PROGRAM_ID,
         PROGRAM_LOGIN_ID,
	 PROGRAM_APPLICATION_ID,
         REQUEST_ID,
         DEAL_NUMBER,
         AMOUNT_TYPE,
         EFF_PRD_GAIN_LOSS_AMT,
         INEFF_PRD_GAIN_LOSS_AMT,
         EXCLUDED_PRD_GAIN_LOSS_AMT,
         RECLASS_GAIN_LOSS_AMT,
         EFF_CUM_GAIN_LOSS_AMT,
         INEFF_CUM_GAIN_LOSS_AMT,
         EXCLUDED_CUM_GAIN_LOSS_AMT,
         RESULT_DATE
        )
      values (
         xtr_deal_retro_tests_s.nextval,
         l_retro_test_id,
         p_batch_id,
         p_hedge_no,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.login_id,
         fnd_global.conc_program_id,
         fnd_global.conc_login_id,
         fnd_global.prog_appl_id,
         fnd_global.conc_request_id,
         r.deal_no,
         l_amount_type,
         0,
         0,
         0,
	 nvl(l_rec_gl_amt,0) * round(r.alloc_ref_amt/l_deal_total, l_round),
         l_hd_eff_prv_cum,
         l_hd_ineff_prv_cum,
         l_hd_excl_prv_cum,
         p_date
	 );

    end if;

  end loop;
END CALC_RECLASS;

---------------------------------------------------------------------------

PROCEDURE AUTHORIZE(p_company IN VARCHAR2, p_batch_id in NUMBER) IS

l_mbst_date          DATE;
l_temp_date 	     DATE;
l_reval_id  	     NUMBER;
l_deal_reval_amt     NUMBER;
l_dummy 	     VARCHAR2(1);

l_dmbtd 	     VARCHAR2(1) := 'N';
l_dmotd 	     VARCHAR2(1) := 'N';

l_drbtd 	     VARCHAR2(1) := 'N';
l_drotd 	     VARCHAR2(1) := 'N';

l_deal_ineff_prd_tot NUMBER := 0;
l_deal_ineff_dnm_tot NUMBER := 0;

l_deal_dnm_ineff     NUMBER := 0;
l_deal_dnm_eff       NUMBER := 0;
l_deal_cum_recl_amt  NUMBER:= 0;

l_amt_type_eu VARCHAR2(30);
l_amt_type_iu VARCHAR2(30);
l_amt_type_ru VARCHAR2(30);
l_amt_type_rr VARCHAR2(30);
l_amt_type_ir VARCHAR2(30);

cursor cur_dnm(p_batch_id in number) is
select deal_number, amount_type, result_date,
nvl(sum(eff_prd_gain_loss_amt),0) eff_prd_gain_loss_amt,
nvl(sum(reclass_gain_loss_amt),0) reclass_gain_loss_amt
from   xtr_deal_retro_tests d
where  d.batch_id 	     = p_batch_id
and    d.hedge_attribute_id in (select hedge_attribute_id
                                from xtr_hedge_attributes ha, xtr_hedge_strategies hs
                                where ha.strategy_code = hs.strategy_code
                                and   hs.hedge_type = 'CASHFLOW')
group by deal_number, amount_type, result_date
order by deal_number, amount_type, result_date;

cursor prv_reclass (p_deal_no in number) is
select nvl(sum(reclass_gain_loss_amt),0)
from   xtr_deal_retro_tests
where  deal_number = p_deal_no
and    result_date <= l_temp_date;

CURSOR reval (p_amount_type in varchar2, p_reval_id in number) is
--select decode(p_amount_type, 'UNREAL', unrealised_pl, curr_gain_loss_amount) reval_amt
select decode(p_amount_type, 'UNREAL', unrealised_pl, curr_gain_loss_amount) reval_amt
from   xtr_revaluation_details
where  revaluation_details_id = p_reval_id;

cursor deal_mbtd (p_deal_no in number, p_date in DATE) is
select 'Y' from xtr_revaluation_details
where  deal_no = p_deal_no
and    realized_flag = 'Y'
and    period_to < p_date;

cursor deal_motd (p_deal_no in number, p_date in DATE) is
select 'Y' from xtr_revaluation_details
where  deal_no = p_deal_no
and    realized_flag = 'Y'
and    period_to = p_date;

cursor deal_rbtd (p_deal_no in number, p_date in DATE) is
select 'Y' from xtr_deal_retro_tests
where  deal_number = p_deal_no
and    nvl(reclass_gain_loss_amt,0) <> 0
and    result_date < p_date;

/* Not proabably needed
cursor deal_rotd (p_deal_no in number, p_date in DATE) is
select 'Y' from xtr_deal_retro_tests
where  deal_no = p_deal_no
and    nvl(reclass_gain_loss_amt,0) <> 0
and    result_date = p_date;
*/

cursor dnm (p_deal_no in number, p_flag in VARCHAR2, p_amount_type in VARCHAR2, p_date_type in VARCHAR2) is
select sum(DECODE(ACTION, 'LOSS',-AMOUNT, AMOUNT)) from xtr_gain_loss_dnm
where journal_date <= l_temp_date
and deal_number = p_deal_no
and reval_eff_flag = p_flag
and amount_type = p_amount_type
and date_type = p_date_type;

cursor reval_dtls(p_deal_no in number) is
 select revaluation_details_id from xtr_revaluation_details
 where  deal_no   = p_deal_no
 and    period_from >= nvl(l_mbst_date, period_from)
-- and    period_to = l_temp_date  -- Unit Test Change
 and    period_to <= l_temp_date
 and    realized_flag = 'N'
 and    batch_id  = p_batch_id
 and    deal_type = 'FX'
 and    deal_subtype = 'FORWARD';


cursor mbstdt(p_deal_no in number, p_end_date in DATE) is
select max(period_from)
from   xtr_revaluation_details
where  batch_id = p_batch_id
and    deal_no  = p_deal_no
and    deal_type = 'FX'
and    deal_subtype = 'FORWARD'
and    period_to <= p_end_date
and    period_from <= p_end_date;

PROCEDURE xtr_ins_dnm (P_DEAL_NO     IN NUMBER,
                       P_DATE        IN DATE,
                       P_DATE_TYPE   IN VARCHAR2,
		       P_AMOUNT_TYPE IN VARCHAR2,
                       P_AMOUNT      IN NUMBER DEFAULT NULL) is

  l_dnm_id       NUMBER;
  l_row_id 	 VARCHAR2(64);
  l_action       VARCHAR2(7);
  l_gl_ccy       VARCHAR2(15);

BEGIN

  select XTR_GAIN_LOSS_DNM_S.nextval into l_dnm_id from dual;

  if p_amount > 0 then
     l_action := 'PROFIT';
  elsif p_amount < 0 then
     l_action := 'LOSS';
  end if;

  l_gl_ccy := get_gl_ccy(p_amount_type, p_deal_no, p_company);

      XTR_GAIN_LOSS_DNM_PKG.INSERT_ROW(
	l_row_id,
   	l_dnm_id ,
	p_batch_id,
	p_company,
	p_deal_no,
	1,
	p_date_type,
	abs(p_amount),
	p_amount_type,
	l_action,
	l_gl_ccy,
        p_date,
        'T',
	sysdate,
	fnd_global.user_id,
	sysdate,
	fnd_global.user_id,
	fnd_global.login_id
	);

Exception
  when others then
     fnd_message.set_name('XTR', 'XTR_154');
     APP_EXCEPTION.Raise_exception;
     LOG_MSG('Error', 'Error occured in XTR_HEDGE_PROCESS_P.xtr_ins_dnm');
     LOG_MSG('Error', SQLERRM);
END xtr_ins_dnm;

Begin

 for dnm_rec in cur_dnm(p_batch_id) loop

  if dnm_rec.amount_type in ('UNREAL','REAL') then
     l_amt_type_eu := 'NRECUNR';
     l_amt_type_iu := 'UNREAL' ;
     l_amt_type_ru := 'RECUNRL';
     l_amt_type_rr := 'RECREAL';
     l_amt_type_ir := 'REAL'   ;
  elsif dnm_rec.amount_type in ('CCYUNRL','CCYREAL') then
     l_amt_type_eu := 'NRECCYU';
     l_amt_type_iu := 'CCYUNRL' ;
     l_amt_type_ru := 'RECCYUN';
     l_amt_type_rr := 'RECCYRE';
     l_amt_type_ir := 'CCYREAL'   ;
end if;

 LOG_MSG('event', 'Authorizing for result date '||dnm_rec.result_date);
 LOG_MSG('dnm_rec.deal_number', dnm_rec.deal_number);
 LOG_MSG('p_batch_id', p_batch_id);

 l_temp_date := dnm_rec.result_date;

 l_deal_reval_amt := 0;

 if l_mbst_date is null then
    open  mbstdt(dnm_rec.deal_number, l_temp_date);
    fetch mbstdt into l_mbst_date;
    close mbstdt;
    LOG_MSG('l_mbst_date: '||l_mbst_date);
 end if;


 for out_rec in reval_dtls(dnm_rec.deal_number) loop
  LOG_MSG('l_reval_id:', out_rec.revaluation_details_id);
  for in_rec in reval(dnm_rec.amount_type, out_rec.revaluation_details_id) loop
     LOG_MSG('in_rec.reval_amt:', in_rec.reval_amt);
     l_deal_reval_amt := nvl(l_deal_reval_amt,0) + in_rec.reval_amt;
  end loop;
 end loop;


/* Unit Test Change
 open  reval_dtls(dnm_rec.deal_number);
 fetch reval_dtls into l_reval_id;
 if reval_dtls%notfound then
     LOG_MSG('status', 'deal already matured');
 else
    open  reval(dnm_rec.amount_type, l_reval_id);
    fetch reval into l_deal_reval_amt;
    close reval;
 end if;
 close reval_dtls;
*/

-- LOG_MSG('l_reval_id', l_reval_id);
 LOG_MSG('l_deal_reval_amt', l_deal_reval_amt);

 l_deal_ineff_prd_tot := nvl(l_deal_reval_amt,0) - nvl(dnm_rec.eff_prd_gain_loss_amt,0);

 LOG_MSG('deal ineff g/l', l_deal_ineff_prd_tot);

 open  dnm(dnm_rec.deal_number, 'T',dnm_rec.amount_type, 'REVAL');
 fetch dnm into l_deal_ineff_dnm_tot;
 close dnm;

 LOG_MSG('l_deal_ineff_dnm_tot', l_deal_ineff_dnm_tot);

 open  deal_mbtd(dnm_rec.deal_number, dnm_rec.result_date);
 fetch deal_mbtd into l_dummy;
 if deal_mbtd%FOUND then
   l_dmbtd := 'Y';
 end if;
 close deal_mbtd;

 LOG_MSG('l_dmbtd', l_dmbtd);

 if l_dmbtd = 'Y' then

   if nvl(dnm_rec.RECLASS_GAIN_LOSS_AMT,0) <> 0 then
      LOG_MSG('event', 'generating RECUNRL row with amount '||dnm_rec.RECLASS_GAIN_LOSS_AMT);
      xtr_ins_dnm(dnm_rec.deal_number, dnm_rec.result_date, 'RECLASS', l_amt_type_ru, dnm_rec.RECLASS_GAIN_LOSS_AMT);
      LOG_MSG('event', 'generating RECREAL row with amount '||dnm_rec.RECLASS_GAIN_LOSS_AMT);
      xtr_ins_dnm(dnm_rec.deal_number, dnm_rec.result_date, 'RECLASS', l_amt_type_rr, dnm_rec.RECLASS_GAIN_LOSS_AMT);
   end if;

 elsif l_dmbtd = 'N' then

   open  deal_motd(dnm_rec.deal_number, dnm_rec.result_date);
   fetch deal_motd into l_dummy;
   if deal_motd%FOUND then
      l_dmotd := 'Y';
   end if;
   close deal_motd;

   LOG_MSG('l_dmotd = '||l_dmotd);

   if l_dmotd = 'Y' then

      open  dnm(dnm_rec.deal_number, 'R', l_amt_type_iu, 'REVAL');
      fetch dnm into l_deal_dnm_ineff;
      close dnm;

      open  dnm(dnm_rec.deal_number, 'T', l_amt_type_eu, 'REVAL');
      fetch dnm into l_deal_dnm_eff;
      close dnm;

      if nvl(l_deal_ineff_prd_tot,0) <> 0 then
        LOG_MSG('event', 'generating UNREAL row');
        LOG_MSG('event', 'generating UNREAL row with amount: '||l_deal_ineff_prd_tot);
        xtr_ins_dnm(dnm_rec.deal_number, dnm_rec.result_date, 'REVAL', l_amt_type_iu, l_deal_ineff_prd_tot);
      end if;

      LOG_MSG('event', 'generating REAL row with amount: ');

      LOG_MSG(l_deal_dnm_ineff - l_deal_dnm_eff);

      xtr_ins_dnm(dnm_rec.deal_number, dnm_rec.result_date, 'REVAL', l_amt_type_ir,
			nvl(l_deal_dnm_ineff,0) - nvl(l_deal_dnm_eff,0));

      /* if the hedge is still active at this time then geenrate NRECUNR row */

      if nvl(dnm_rec.EFF_PRD_GAIN_LOSS_AMT,0) <> 0 then
        LOG_MSG('event', 'generating NRECUNR row');
        xtr_ins_dnm(dnm_rec.deal_number, dnm_rec.result_date, 'REVAL', l_amt_type_eu, dnm_rec.EFF_PRD_GAIN_LOSS_AMT);
      end if;

      if nvl(dnm_rec.RECLASS_GAIN_LOSS_AMT,0) <> 0 then
         l_drotd := 'Y';
         xtr_ins_dnm(dnm_rec.deal_number, dnm_rec.result_date, 'RECLASS', l_amt_type_ru, dnm_rec.RECLASS_GAIN_LOSS_AMT);
      else
         open  deal_rbtd(dnm_rec.deal_number, dnm_rec.result_date);
 	 fetch deal_rbtd into l_dummy;
	 if deal_rbtd%FOUND then
	   l_drbtd := 'Y';
	 end if;
	 close deal_rbtd;
      end if;


      if l_drotd = 'Y' or l_drbtd = 'Y' then

        open  prv_reclass(dnm_rec.deal_number);
        fetch prv_reclass into l_deal_cum_recl_amt;
        close prv_reclass;

        LOG_MSG('event', 'generating RECREAL row with amount: '||l_deal_cum_recl_amt);

        LOG_MSG('event', 'l_deal_cum_recl_amt = '||l_deal_cum_recl_amt);

        xtr_ins_dnm(dnm_rec.deal_number, dnm_rec.result_date, 'REVAL', l_amt_type_rr,
			 l_deal_cum_recl_amt);
      end if;

   else

      if nvl(l_deal_ineff_prd_tot,0) <> 0 then
        LOG_MSG('event', 'generating REVAL/UNREAL row');
        xtr_ins_dnm(dnm_rec.deal_number, dnm_rec.result_date, 'REVAL', l_amt_type_iu, l_deal_ineff_prd_tot);
      end if;

      if nvl(dnm_rec.EFF_PRD_GAIN_LOSS_AMT,0) <> 0 then
        LOG_MSG('event', 'generating REVAL/NRECUNR row');
        xtr_ins_dnm(dnm_rec.deal_number, dnm_rec.result_date, 'REVAL', l_amt_type_eu, dnm_rec.EFF_PRD_GAIN_LOSS_AMT);
      end if;

      if nvl(dnm_rec.RECLASS_GAIN_LOSS_AMT,0) <> 0 then
        LOG_MSG('event', 'generating RECLASS/RECUNRL row');
        xtr_ins_dnm(dnm_rec.deal_number, dnm_rec.result_date, 'RECLASS', l_amt_type_ru, dnm_rec.RECLASS_GAIN_LOSS_AMT);
      end if;

   end if;

 end if;

 l_mbst_date := dnm_rec.result_date;  -- Unit Test Change

 end loop;

 Update XTR_BATCH_EVENTS
 set    AUTHORIZED 	   = 'Y',
	AUTHORIZED_BY 	   = FND_GLOBAL.USER_ID,
	AUTHORIZED_ON 	   = SYSDATE,
        LAST_UPDATED_BY    = FND_GLOBAL.USER_ID,
	LAST_UPDATE_DATE   = SYSDATE,
	LAST_UPDATE_LOGIN  = FND_GLOBAL.LOGIN_ID
 where  BATCH_ID	   = P_BATCH_ID
 and    EVENT_CODE  	   = 'RETROET'
 and    nvl(AUTHORIZED,'N')  <> 'Y';

Exception
   when others then
     fnd_message.set_name('XTR', 'XTR_154');
     APP_EXCEPTION.Raise_exception;
END AUTHORIZE;


/*-----------------------------------------------------------------
     This function returns a ratio representing the deal's
     share of the total hedge instruments amount
------------------------------------------------------------------*/

FUNCTION get_deal_alloc(p_deal_no IN NUMBER,
			p_hedge_no IN NUMBER) return NUMBER is

  l_ref_amt NUMBER;
  l_ref_tot NUMBER;

  /*-------------------------------------------------------
   get deals assigned to this hedge
   --------------------------------------------------------*/

   cursor ref_amt is
   select nvl(reference_amount,0) alloc_ref_amt
   from   xtr_hedge_relationships
   where  hedge_attribute_id = p_hedge_no
   and    primary_code = p_deal_no
   and    instrument_item_flag = 'U';


   cursor ref_tot is
   select sum(nvl(reference_amount,0)) deal_total
   from   xtr_hedge_relationships
   where  hedge_attribute_id = p_hedge_no
   and    instrument_item_flag = 'U';

Begin

   open  ref_amt;
   fetch ref_amt into l_ref_amt;
   close ref_amt;

   open  ref_tot;
   fetch ref_tot into l_ref_tot;
   close ref_tot;

   return round(l_ref_amt/l_ref_tot,2);

END get_deal_alloc;


/*-----------------------------------------------------------------
         This function returns the gain/loss
         currency based on the Amount Type
------------------------------------------------------------------*/
FUNCTION get_gl_ccy(p_amount_type IN VARCHAR2,
		    p_deal_no     IN NUMBER,
		    p_company     IN VARCHAR2) return VARCHAR2 is

  l_gl_ccy  VARCHAR2(15);


   cursor deal_ccy is
   select distinct reval_ccy
   from   xtr_revaluation_details
   where  deal_no = p_deal_no;

   cursor sob_ccy is
   select set_of_books_currency
   from   xtr_parties_v
   where  party_code = p_company
   and party_type = 'C';

Begin


   If p_amount_type in ('UNREAL', 'REAL', 'NRECUNR', 'RECUNRL', 'RECREAL') then
      open  deal_ccy;
      fetch deal_ccy into l_gl_ccy;
      close deal_ccy;
   End If;

   If p_amount_type in ('CCYUNRL', 'CCYREAL', 'NRECCYU', 'RECCYUN', 'RECCYRE') or (l_gl_ccy is NULL) then
      open  sob_ccy;
      fetch sob_ccy into l_gl_ccy;
      close sob_ccy;
   End If;

   return l_gl_ccy;
Exception
   When Others then return NULL;
END get_gl_ccy;


/*-----------------------------------------------------------------
    This function returns 'Y' if the company performs
    retrospective effectiveness testing; otherwise returns 'N'
------------------------------------------------------------------*/
FUNCTION performs_retro(p_company IN VARCHAR2) return VARCHAR2 is

  l_dummy VARCHAR2(30) := 'N';

   cursor param is
   select parameter_value_code
   from   XTR_COMPANY_PARAMETERS
   where  company_code   = p_company
   and    parameter_code = 'ACCNT_BTEST';

Begin

   if p_company is not NULL then
     open  param;
     fetch param into l_dummy;
     close param;
   end if;

   return (l_dummy);

Exception
   When Others then return ('N');
END performs_retro;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
PROCEDURE retro_main_calc(P_COMPANY  IN  VARCHAR2, P_BATCH_ID IN NUMBER) IS

l_temp VARCHAR2(200);

l_retro_test_id NUMBER;

l_deal_no   NUMBER;
l_from_date DATE;
l_to_date   DATE;

l_result       varchar2(30);
l_test_method  varchar2(30);
l_min_tol      number;
l_max_tol      number;
l_pct_eff      number;
l_deal_pct     number;
l_excl_item    VARCHAR2(30);


/*-------------------------------------------------------
 These 2 variables are used to allocate the hedge level
 measurement results to the deals.
--------------------------------------------------------*/
l_deal_count   NUMBER;
l_deal_total   NUMBER;

/*-------------------------------------------------------
 These 2 variables are only used for calulating pct_eff
   and then to determine PASS or FAIL
--------------------------------------------------------*/

l_inst_amt 	  NUMBER := 0;
l_item_amt 	  NUMBER := 0;

l_inst_prd 	  NUMBER := 0;
l_item_prd 	  NUMBER := 0;
l_excl_prd    	  NUMBER := 0;

l_inst_cum 	  NUMBER := 0;
l_item_cum 	  NUMBER := 0;
l_excl_cum    	  NUMBER := 0;

l_inst_prv_cum   NUMBER := 0;
l_item_prv_cum   NUMBER := 0;
l_excl_prv_cum   NUMBER := 0;

l_eff_prv_cum    NUMBER := 0;
l_ineff_prv_cum  NUMBER := 0;

l_eff_cum   	  NUMBER := 0;
l_ineff_cum	  NUMBER := 0;

l_eff_prd   	  NUMBER := 0;
l_ineff_prd	  NUMBER := 0;

l_deal_prd_tot       NUMBER := 0;
l_deal_eff_prd_tot   NUMBER := 0;
l_deal_ineff_prd_tot NUMBER := 0;

l_deal_eff_prv_cum NUMBER;
l_deal_ineff_prv_cum NUMBER;

l_hd_eff_prd         NUMBER := 0;
l_hd_ineff_prd       NUMBER := 0;
l_hd_eff_prv_cum     NUMBER := 0;
l_hd_ineff_prv_cum   NUMBER := 0;

l_cb_end_date DATE;
l_pb_end_date DATE;

l_temp_date 	DATE;
l_reval_id  	NUMBER;
l_reval_amt 	NUMBER;
l_complete_flag VARCHAR2(1);
l_amount_type   VARCHAR2(30);
l_gain_loss_ccy VARCHAR2(15);
l_round         NUMBER;

TYPE eff_table_type is table of NUMBER INDEX BY BINARY_INTEGER;
eff_table eff_table_type;


/*-------------------------------------------------------
                  get eligible hedges
--------------------------------------------------------*/
cursor get_hedges(p_cb_end_date in DATE, p_pb_end_date in DATE) is
select
       deal_no 			hedge_no
       ,revaluation_details_id  rec_id
       ,'10'     		rec_source
       ,period_from 		period_from
       ,period_to   		period_to
       ,unrealised_pl		unrealised_pl
       ,realised_pl		realised_pl
       ,curr_gain_loss_amount   curr_gain_loss_amount
       ,realized_flag		realized_flag
from   xtr_revaluation_details r
where  batch_id is not null
and    company_code = p_company
and    not exists (select 'Y' from xtr_batch_events e
                   where e.batch_id =  r.batch_id and
                   e.event_code = 'RETROET')
and    batch_id in (select batch_id from xtr_batches b where
                    b.period_end <= p_cb_end_date)
and    exists (select 'Y' from XTR_COMPANY_PARAMETERS
               where company_code   = p_company
               and    parameter_code = 'ACCNT_BTEST'
               and    parameter_value_code = 'Y')
and    deal_type = 'HEDGE'
UNION
select DISTINCT
       ha.deal_no		hedge_no
       ,-9999			rec_id
       ,'20'     		rec_source
       ,period_from 		period_from
       ,period_to   		period_to
       ,0			unrealised_pl
       ,0			realised_pl
       ,0			curr_gain_loss_amount
       ,NULL			realized_flag
from   xtr_revaluation_details r, xtr_eligible_hedges_v ha, xtr_hedge_relationships hr
where  batch_id is not null
and    r.company_code = p_company
and    r.deal_no = hr.primary_code
and    r.deal_type = 'FX'
and    r.deal_subtype = 'FORWARD'
and    r.realized_flag = 'N'
and    hr.instrument_item_flag = 'U'
and    ha.deal_no = hr.hedge_attribute_id
and    r.period_to > ha.maturity_date
and    not exists (select 'Y' from xtr_batch_events e
                where e.batch_id =  r.batch_id and
                e.event_code = 'RETROET')
and    batch_id in (select batch_id from xtr_batches b where
                 b.period_end <= p_cb_end_date)
and    exists (select 'Y' from XTR_COMPANY_PARAMETERS
               where company_code   = p_company
               and    parameter_code = 'ACCNT_BTEST'
               and    parameter_value_code = 'Y')
UNION
select
     r.hedge_attribute_id	hedge_no
    ,reclass_details_id 	rec_id
    ,'30'         		rec_source
    ,reclass_date 		period_from
    ,reclass_date 		period_to
    ,NULL         		unrealised_pl
    ,NULL         		realised_pl
    ,NULL         		curr_gain_loss_amount
    ,NULL			realized_flag
from   xtr_reclass_details r, xtr_hedge_attributes h, xtr_hedge_strategies s
where  r.hedge_attribute_id = h.hedge_attribute_id
and    h.strategy_code =  s.strategy_code
and    h.company_code = p_company
and    r.reclass_date <= p_cb_end_date
and    r.reclass_date >  nvl(p_pb_end_date, r.reclass_date - 5)
and    h.hedge_status not in ('DESIGNATE', 'CANCELLED')
and    exists (select 'Y' from XTR_COMPANY_PARAMETERS
               where company_code   = p_company
               and    parameter_code = 'ACCNT_BTEST'
               and    parameter_value_code = 'Y')
and    retro_batch_id is NULL
and    NVL(h.retro_method,'@@') <> 'NOTEST'
and    h.exclusion_item_code is not NULL
and    s.hedge_type = 'CASHFLOW'
order  by hedge_no, period_to, rec_source asc;


/*-------------------------------------------------------
       get effectiveness test results for previous
       retro batch for this hedge
--------------------------------------------------------*/
cursor get_cumu(p_hedge_no in number, p_batch_id in number) is
select item_cum_gain_loss_amt, inst_cum_gain_loss_amt, eff_cum_gain_loss_amt,
       ineff_cum_gain_loss_amt, excluded_cum_gain_loss_amt
from   xtr_hedge_retro_tests
where  hedge_attribute_id = p_hedge_no
and    result_date = (select max(result_date) from xtr_hedge_retro_tests r
                   where  r. hedge_attribute_id = p_hedge_no
                   and    r.batch_id <= p_batch_id);


cursor get_result(p_hedge_no in number, p_batch_id in number) is
select result_code, pct_effective
from   xtr_hedge_retro_tests
where  hedge_attribute_id = p_hedge_no
and    batch_id = p_batch_id;

/*-------------------------------------------------------
       get deal level effectiveness test results for
       this hedge/batch id combination
--------------------------------------------------------*/

cursor get_dist_deals(p_batch_id in number) is
select distinct deal_number
from   xtr_deal_retro_tests
where  batch_id = p_batch_id;

cursor get_deal_retro(p_batch_id in number) is
select deal_number, hedge_attribute_id, hedge_retro_test_id,deal_retro_test_id,
       ineff_cum_gain_loss_amt
from   xtr_deal_retro_tests
where  batch_id = p_batch_id;

/*-------------------------------------------------------
       get deal level cum ineffective amt for previous
       batch
--------------------------------------------------------*/
cursor get_prev_ineff(p_hedge_no in number, p_deal_no in number) is
select eff_cum_gain_loss_amt, ineff_cum_gain_loss_amt
from   xtr_deal_retro_tests
where  hedge_attribute_id = p_hedge_no
and    deal_number = p_deal_no
and    result_date = (select max(result_date) from xtr_deal_retro_tests r
                   where  r. hedge_attribute_id = p_hedge_no
                   and    r.deal_number = p_deal_no
                   and    r.batch_id <= p_batch_id);

/*-------------------------------------------------------
       get sum of deal level effectiveness gain/loss
       amounts for this hedge/batch id combination
--------------------------------------------------------*/
cursor get_tot_eff(p_deal_no in number, p_hedge_retro_test_id in number) is
select sum(eff_prd_gain_loss_amt)
from   xtr_deal_retro_tests
where  deal_number = p_deal_no
and    hedge_retro_test_id = p_hedge_retro_test_id
group  by deal_number, hedge_retro_test_id;


/*-------------------------------------------------------
       get deals assigned to this hedge
--------------------------------------------------------*/
cursor get_deals(p_hedge_no in number) is
select primary_code   deal_no,
       cur_pct_allocation deal_pct,
       abs(nvl(reference_amount,0)) alloc_ref_amt
from   xtr_hedge_relationships
where  hedge_attribute_id = p_hedge_no
and    instrument_item_flag = 'U';

/*-------------------------------------------------------
       get reval gain/loss amounts for this deal
--------------------------------------------------------*/
cursor get_reval is
select unrealised_pl, realised_pl, curr_gain_loss_amount,
       (nvl(unrealised_pl,0)-nvl(curr_gain_loss_amount,0)) excluded_amt,
       revaluation_details_id
from   xtr_revaluation_details
where  deal_no       = l_deal_no
--and    period_from   = l_from_date
--and    period_to     = l_to_date
and    period_from   >= l_from_date
and    period_to     <= l_to_date
and    realized_flag = 'N';


/*-------------------------------------------------------
       get reval gain/loss amount for this deal
--------------------------------------------------------*/
cursor get_deal_gl(p_deal_no in NUMBER) is
select DECODE(l_excl_item, 'NONE', unrealised_pl, 'TIME',curr_gain_loss_amount) deal_pl
from   xtr_revaluation_details
where  deal_no       = p_deal_no
and    period_from   = l_from_date
and    period_to     = l_to_date
and    batch_id      = p_batch_id;


/*-------------------------------------------------------
       get end date for this batch
--------------------------------------------------------*/
cursor cur_date is
select period_end from xtr_batches
where  batch_id = p_batch_id;

/*-------------------------------------------------------
       get end date for immedietly previous batch
--------------------------------------------------------*/
cursor prv_date is
select max(period_end) from xtr_batches b, xtr_batch_events e
where  b.batch_id = e.batch_id
and    b.batch_id < p_batch_id
and    e.event_code = 'RETROET'
and    b.company_code  = p_company;

/*-------------------------------------------------------
       get test related data for this hedge
--------------------------------------------------------*/
cursor hedge(p_hedge_no in number) is
select retro_method, retro_tolerance_min,retro_tolerance_max,exclusion_item_code
from   xtr_hedge_attributes
where  hedge_attribute_id = p_hedge_no;

cursor retro(p_hedge_no in number) is
select pct_effective
from   xtr_hedge_retro_tests
where  batch_id = p_batch_id
and    hedge_attribute_id = p_hedge_no;


/*-------------------------------------------------------
       get deal count and total reference amount
       of the deals assigned to this hedge
--------------------------------------------------------*/
cursor deal_count(p_hedge_no in number) is
select count(primary_code) deal_count,
       abs(sum(nvl(reference_amount,0))) deal_total
from   xtr_hedge_relationships
where  hedge_attribute_id = p_hedge_no
and    instrument_item_flag = 'U';

cursor cur_rnd(p_ccy in varchar2) is
select rounding_factor
from   xtr_master_currencies_v
where  currency = p_ccy;

BEGIN

  open  cur_date;
  fetch cur_date into l_cb_end_date;
  close cur_date;

  open  prv_date;
  fetch prv_date into l_pb_end_date;
  close prv_date;

  LOG_MSG('l_cb_end_date', l_cb_end_date);
  LOG_MSG('l_pb_end_date', l_pb_end_date);

for hdg_rec in get_hedges(l_cb_end_date, l_pb_end_date) Loop

 LOG_MSG('status', 'Entered the main loop');

 Declare

   TYPE alloc_tbl_type is table of NUMBER INDEX BY BINARY_INTEGER;
   alloc_tbl alloc_tbl_type;

   l_alloc_tbl NUMBER;

 Begin

   if hdg_rec.rec_source in (10, 20) then

      l_from_date := hdg_rec.period_from;  /* mini batch start date */
      l_to_date   := hdg_rec.period_to;    /* mini batch end date;
                                             will also be the test/result/siginificant date */

      LOG_MSG('hdg_rec.period_from ', hdg_rec.period_from);
      LOG_MSG('hdg_rec.period_to', hdg_rec.period_to);

      open  hedge (hdg_rec.hedge_no);
      fetch hedge into l_test_method, l_min_tol, l_max_tol, l_excl_item;
      close hedge;

      if l_excl_item = 'NONE' then
          l_item_prd := nvl(hdg_rec.unrealised_pl,0);
      elsif l_excl_item = 'TIME' then
          l_item_prd := nvl(hdg_rec.curr_gain_loss_amount,0);
      end if;

      -- bug 4276958
      l_item_prv_cum := 0;
      l_inst_prv_cum :=0;
      l_eff_prv_cum := 0;
      l_ineff_prv_cum := 0;
      l_excl_prv_cum := 0;
      open  get_cumu(hdg_rec.hedge_no, p_batch_id);
      fetch get_cumu into l_item_prv_cum, l_inst_prv_cum, l_eff_prv_cum,
	        l_ineff_prv_cum, l_excl_prv_cum;
      close get_cumu;

      LOG_MSG('Hedge No'   , hdg_rec.hedge_no);
      LOG_MSG('source'     , hdg_rec.rec_source);
      LOG_MSG('Test Method', l_test_method);
      LOG_MSG('Excl Item'  , l_excl_item);

      LOG_MSG('item unreal amt', l_item_prd);

      l_inst_prd := 0;
      l_excl_prd := 0; -- Added for Bug 4214515

  for deal_rec in get_deals(hdg_rec.hedge_no) Loop

      l_deal_no  := deal_rec.deal_no;

      if hdg_rec.rec_source = 20 then
        l_deal_pct := 0;
      else
        l_deal_pct := deal_rec.deal_pct/100;
      end if;

      LOG_MSG('Deal No' , deal_rec.deal_no);
      LOG_MSG('% Alloc' , deal_rec.deal_pct);

      for reval_rec in get_reval loop

      if l_excl_item     = 'NONE' then
         l_reval_amt    := nvl(reval_rec.unrealised_pl,0);
         l_amount_type  := 'UNREAL';
      elsif l_excl_item  = 'TIME' then
	 l_reval_amt    := nvl(reval_rec.curr_gain_loss_amount,0);
         l_amount_type  := 'CCYUNRL';
      end if;

      eff_table(reval_rec.revaluation_details_id) := l_reval_amt;
      l_alloc_tbl				  := NVL(l_alloc_tbl,0) + l_reval_amt * (l_deal_pct);
      l_inst_prd                                  := nvl(l_inst_prd,0)  + l_reval_amt * (l_deal_pct);

      if l_excl_item = 'TIME' then
         l_excl_prd := nvl(l_excl_prd,0) + reval_rec.excluded_amt* (l_deal_pct);
      end if;

      end loop;

      alloc_tbl(deal_rec.deal_no)                 := l_alloc_tbl;

      LOG_MSG('alloc_tbl('||deal_rec.deal_no||')', alloc_tbl(deal_rec.deal_no));

      l_inst_cum := nvl(l_inst_prd,0) + nvl(l_inst_prv_cum,0);
      l_item_cum := nvl(l_item_prd,0) + nvl(l_item_prv_cum,0);
      l_excl_cum := nvl(l_excl_prd,0) + nvl(l_excl_prv_cum,0);

  end loop;  -- Deals Loop

  l_gain_loss_ccy := get_gl_ccy(l_amount_type, hdg_rec.hedge_no, p_company);
  LOG_MSG('l_gain_loss_ccy', l_gain_loss_ccy);

  open  cur_rnd(l_gain_loss_ccy);
  fetch cur_rnd into l_round;
  close cur_rnd;

  LOG_MSG('l_round', l_round);

  l_item_prd := round(l_item_prd, l_round);
  l_inst_prd := round(l_inst_prd, l_round);
  l_excl_prd := round(l_excl_prd, l_round);
  l_inst_cum := round(l_inst_cum, l_round);
  l_item_cum := round(l_item_cum, l_round);
  l_excl_cum := round(l_excl_cum, l_round);

  LOG_MSG('l_inst_prd', l_inst_prd);
  LOG_MSG('l_item_prd', l_item_prd);
  LOG_MSG('l_excl_prd', l_excl_prd);
  LOG_MSG('l_inst_cum', l_inst_cum);
  LOG_MSG('l_item_cum', l_item_cum);
  LOG_MSG('l_excl_cum', l_excl_cum);

/*************************************************************************
                             Test Result
*************************************************************************/

 if l_test_method = 'SHORTCUT' then

   l_result  := 'PASS';
   l_pct_eff := 100;

 elsif l_test_method = 'MANUAL' then

   l_result  := NULL;
   l_pct_eff := NULL;

 elsif l_test_method in ('PEROFF', 'CUMOFF') then

   if l_test_method = 'PEROFF' then
        l_inst_amt := l_inst_prd;
        l_item_amt := l_item_prd;
   elsif l_test_method = 'CUMOFF' then
        l_inst_amt := l_inst_cum;
        l_item_amt := l_item_cum;
   end if;

   if nvl(l_inst_amt,0) = 0 and nvl(l_item_amt,0) = 0 then
      l_result := 'PASS';
      l_pct_eff := 100;
   elsif (nvl(l_inst_amt,0) = 0 or nvl(l_item_amt,0) = 0) then
      l_result := 'FAIL';
      l_pct_eff := 0;
   elsif (sign(l_inst_amt) = sign(l_item_amt)) then
      l_result := 'FAIL';
      l_pct_eff := ABS(l_inst_amt/l_item_amt)*100;
--    l_pct_eff := 0;
   else
      l_pct_eff := ABS(l_inst_amt/l_item_amt)*100;
      if l_pct_eff < nvl(l_min_tol,0) OR l_pct_eff > nvl(l_max_tol,0) then
        l_result := 'FAIL';
      else
        l_result := 'PASS';
      end if;
   end if;

 end if;

 l_pct_eff := ROUND(l_pct_eff, 6);

 LOG_MSG('Test Result', l_result);
 LOG_MSG('l_pct_eff', l_pct_eff);

 If l_result is not NULL and l_result = 'FAIL' then
   fnd_message.set_name('XTR', 'XTR_DO_PROSPECTIVE_TEST_LOG');
   fnd_message.set_token('P_HEDGE_NO',  hdg_rec.hedge_no);
   fnd_message.set_token('P_TEST_DATE', hdg_rec.period_to);
   fnd_file.put_line(fnd_file.log, fnd_message.get);
 end if;

-- l_gain_loss_ccy := get_gl_ccy(l_amount_type, hdg_rec.hedge_no, p_company);

 LOG_MSG('l_gain_loss_ccy', l_gain_loss_ccy);
 LOG_MSG('l_amount_type', l_amount_type);

/*************************************************************************/

/*************************************************************************
            Determine the cumulative effective based on test result
*************************************************************************/

   if NVL(l_test_method, '@@@') = 'MANUAL' then

       LOG_MSG('event', 'inserting MANUAL test - part of retro calculations');

        /* This implies, not called from the form, but done
           as part of retro calcualtion for the first time */

        select xtr_hedge_retro_tests_s.nextval into l_retro_test_id from dual;

        insert into xtr_hedge_retro_tests
	(HEDGE_RETRO_TEST_ID, COMPANY_CODE, HEDGE_ATTRIBUTE_ID, RESULT_CODE,
	BATCH_ID, RESULT_DATE,CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
	LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,PROGRAM_ID, PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID, REQUEST_ID, COMPLETE_FLAG,GAIN_LOSS_CCY,
	AMOUNT_TYPE, ITEM_PRD_GAIN_LOSS_AMT, INST_PRD_GAIN_LOSS_AMT,
	ITEM_CUM_GAIN_LOSS_AMT, INST_CUM_GAIN_LOSS_AMT, PCT_EFFECTIVE, EFF_PRD_GAIN_LOSS_AMT,
	INEFF_PRD_GAIN_LOSS_AMT, EXCLUDED_PRD_GAIN_LOSS_AMT, RECLASS_GAIN_LOSS_AMT,
	EFF_CUM_GAIN_LOSS_AMT, INEFF_CUM_GAIN_LOSS_AMT, EXCLUDED_CUM_GAIN_LOSS_AMT)
   values (l_retro_test_id, p_company, hdg_rec.hedge_no, NULL,
           p_batch_id, hdg_rec.period_to, fnd_global.user_id, sysdate, fnd_global.user_id,
           sysdate, fnd_global.login_id, fnd_global.conc_program_id, fnd_global.conc_login_id,
           fnd_global.prog_appl_id, fnd_global.conc_request_id,'N',l_gain_loss_ccy,
           l_amount_type, l_item_prd, l_inst_prd, l_item_cum, l_inst_cum, NULL, NULL,
           NULL, l_excl_prd, NULL, NULL, NULL, l_excl_cum);

   elsif NVL(l_test_method, '@@@') <> 'MANUAL' then

   If l_result = 'PASS' then
     if l_test_method = 'SHORTCUT' then
       l_eff_cum := l_inst_cum;
     else
       l_eff_cum := LEAST(ABS(l_inst_cum), ABS(l_item_cum))*SIGN(l_inst_cum);
     end if;
   Elsif l_result = 'FAIL' then
      l_eff_cum := l_eff_prv_cum;
   End If;

   l_eff_prd   := nvl(l_eff_cum,0)  - nvl(l_eff_prv_cum,0);
   l_ineff_prd := nvl(l_inst_prd,0) - nvl(l_eff_prd,0);

   LOG_MSG('Results:');
   LOG_MSG('l_eff_cum'     , l_eff_cum);
   LOG_MSG('l_eff_prv_cum' , l_eff_prv_cum);
   LOG_MSG('l_eff_prd'     , l_eff_prd);
   LOG_MSG('l_ineff_prd'   , l_ineff_prd);

   l_ineff_cum:= nvl(l_ineff_prv_cum,0) + nvl(l_ineff_prd,0);

   select xtr_hedge_retro_tests_s.nextval into l_retro_test_id from dual;

      LOG_MSG('event', 'inserting NON-MANUAL test - part of retro calculations');

      insert into xtr_hedge_retro_tests
	(HEDGE_RETRO_TEST_ID, COMPANY_CODE, HEDGE_ATTRIBUTE_ID, RESULT_CODE,
	BATCH_ID, RESULT_DATE,CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
	LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,PROGRAM_ID, PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID, REQUEST_ID, COMPLETE_FLAG, GAIN_LOSS_CCY,
	AMOUNT_TYPE, ITEM_PRD_GAIN_LOSS_AMT, INST_PRD_GAIN_LOSS_AMT,
	ITEM_CUM_GAIN_LOSS_AMT, INST_CUM_GAIN_LOSS_AMT, PCT_EFFECTIVE, EFF_PRD_GAIN_LOSS_AMT,
	INEFF_PRD_GAIN_LOSS_AMT, EXCLUDED_PRD_GAIN_LOSS_AMT, RECLASS_GAIN_LOSS_AMT,
	EFF_CUM_GAIN_LOSS_AMT, INEFF_CUM_GAIN_LOSS_AMT, EXCLUDED_CUM_GAIN_LOSS_AMT)
      values (l_retro_test_id, p_company, hdg_rec.hedge_no, l_result,
           p_batch_id, hdg_rec.period_to, fnd_global.user_id, sysdate, fnd_global.user_id,
           sysdate, fnd_global.login_id, fnd_global.conc_program_id, fnd_global.conc_login_id,
           fnd_global.prog_appl_id, fnd_global.conc_request_id,'Y',l_gain_loss_ccy,
           l_amount_type, l_item_prd, l_inst_prd, l_item_cum, l_inst_cum, l_pct_eff, l_eff_prd,
           l_ineff_prd, l_excl_prd, NULL, l_eff_cum, l_ineff_cum, l_excl_cum);

   /*-------------------------------------------------------
       if successful, split the amounts among the deals
   --------------------------------------------------------*/

   if sql%found then
     if (l_test_method <> 'MANUAL') then
      LOG_MSG('status', 'INSERT sucessful for xtr_hedge_retro_tests');

      open  deal_count(hdg_rec.hedge_no);
      fetch deal_count into l_deal_count, l_deal_total;
      close deal_count;

      LOG_MSG('deal level amounts:');
      LOG_MSG('l_deal_count'   , l_deal_count);
      LOG_MSG('l_deal_total'   , l_deal_total);
      LOG_MSG('l_eff_prd'      , l_eff_prd);


      for deal_rec in get_deals(hdg_rec.hedge_no) Loop
        LOG_MSG('hdg_rec.hedge_no', hdg_rec.hedge_no);
        LOG_MSG('deal_rec.deal_no', deal_rec.deal_no);
   	LOG_MSG('alloc ref amt'   , deal_rec.alloc_ref_amt);
   	LOG_MSG('alloc ratio'     , round(deal_rec.alloc_ref_amt/l_deal_total, l_round));
   	LOG_MSG('Deal prd g/l'    , l_eff_prd * (deal_rec.alloc_ref_amt/l_deal_total));

        LOG_MSG('deal_rec.deal_no', deal_rec.deal_no);
        LOG_MSG(' alloc_tbl('||deal_rec.deal_no||') ', alloc_tbl(deal_rec.deal_no));

        l_hd_ineff_prd := round(alloc_tbl(deal_rec.deal_no) -
			NVL(l_eff_prd * (deal_rec.alloc_ref_amt/l_deal_total),0), l_round);

        LOG_MSG('Per Hedge-Per Deal: Ineff Amt', l_hd_ineff_prd);

	open  get_prev_ineff(hdg_rec.hedge_no, deal_rec.deal_no);
 	fetch get_prev_ineff into l_hd_eff_prv_cum, l_hd_ineff_prv_cum ;
	close get_prev_ineff;

      insert into xtr_deal_retro_tests
	(DEAL_RETRO_TEST_ID, HEDGE_RETRO_TEST_ID, BATCH_ID, HEDGE_ATTRIBUTE_ID, CREATED_BY, CREATION_DATE,
        LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN, PROGRAM_ID, PROGRAM_LOGIN_ID,
	PROGRAM_APPLICATION_ID, REQUEST_ID, DEAL_NUMBER, AMOUNT_TYPE,
        EFF_PRD_GAIN_LOSS_AMT, INEFF_PRD_GAIN_LOSS_AMT, EXCLUDED_PRD_GAIN_LOSS_AMT,
        RECLASS_GAIN_LOSS_AMT, EFF_CUM_GAIN_LOSS_AMT,  INEFF_CUM_GAIN_LOSS_AMT,
        EXCLUDED_CUM_GAIN_LOSS_AMT, RESULT_DATE)

      values (xtr_deal_retro_tests_s.nextval, l_retro_test_id, p_batch_id, hdg_rec.hedge_no,
              fnd_global.user_id, sysdate, fnd_global.user_id, sysdate, fnd_global.login_id,
              fnd_global.conc_program_id, fnd_global.conc_login_id, fnd_global.prog_appl_id,
              fnd_global.conc_request_id, deal_rec.deal_no, l_amount_type,
              round(l_eff_prd * (deal_rec.alloc_ref_amt/l_deal_total), l_round),
	      l_hd_ineff_prd,
              round(l_excl_prd * (deal_rec.alloc_ref_amt/l_deal_total), l_round), NULL,
              round(l_eff_cum * (deal_rec.alloc_ref_amt/l_deal_total), l_round),
	      nvl(l_hd_ineff_prv_cum,0) + nvl(l_hd_ineff_prd,0),
              round(l_excl_cum * (deal_rec.alloc_ref_amt/l_deal_total), l_round), hdg_rec.period_to
	      );

         if sql%found then
            LOG_MSG('status', 'INSERT successful for xtr_deal_retro_tests');
         else
            LOG_MSG('status', 'INSERT failed for xtr_deal_retro_tests');
         end if;

      end loop;
     end if; -- end if for (l_test_method <> 'MANUAL') condition

    else -- did not insert record into  xtr_hedge_retro_tests

       LOG_MSG('status', 'INSERT failed for xtr_hedge_retro_tests');

    end if;

    end if;  --end if for if l_test_method = 'MANUAL' condition

/*************************************************************************/

   elsif hdg_rec.rec_source = 30 then  -- elseif for hdg_rec = 10,20 condition
    LOG_MSG('hdg_rec.rec_source', hdg_rec.rec_source);
    LOG_MSG('l_test_method', l_test_method);

    if (NVL(l_test_method,'@@@') <> 'MANUAL') then
       LOG_MSG('Calling Reclassification..');
       CALC_RECLASS(p_company, p_batch_id, hdg_rec.hedge_no, hdg_rec.rec_id, hdg_rec.period_to);
       LOG_MSG('status', 'Returned from Reclassification.');
    end if;
   end if; -- end if for hdg_rec = 30 condition

 End;

End Loop;  -- Hedges Loop

/*-----------------------------------------------------------
   If everyting went fine then generate RETROET event
------------------------------------------------------------*/

LOG_MSG('status', 'generating RETROET event..');

ins_retro_event(P_BATCH_ID, 'RETROET');

LOG_MSG('status', 'generated RETROET event..');

Exception
   when others then
   LOG_MSG(SQLERRM);
   fnd_message.set_name('XTR', 'XTR_154');
   APP_EXCEPTION.raise_exception;
END retro_main_calc;


/****************************************************************/
PROCEDURE RETRO_EFF_TEST (ERRBUF     OUT NOCOPY VARCHAR2,
                          RETCODE    OUT NOCOPY VARCHAR2,
                          P_COMPANY  IN  VARCHAR2,
                          P_BATCH_ID IN NUMBER) IS

BEGIN

  	retro_main_calc(P_COMPANY, P_BATCH_ID);

END RETRO_EFF_TEST;
/***************************************************************/




/***************************************************************
   This procedure inserts a new RETROET event
   into XTR_BATCH_EVENTS table
***************************************************************/
PROCEDURE ins_retro_event(p_batch_id  IN NUMBER, p_event in VARCHAR2) is

Cursor CHK_BATCH_RUN is
Select 'Y'
From   XTR_BATCH_EVENTS
Where  batch_id = p_batch_id
and    event_code = p_event;

l_event_id    XTR_BATCH_EVENTS.BATCH_EVENT_ID%TYPE;
l_sysdate     DATE := trunc(sysdate);
l_cur	      VARCHAR2(1);

Begin
 Open CHK_BATCH_RUN;
 Fetch CHK_BATCH_RUN into l_cur;
 If CHK_BATCH_RUN%FOUND then -- the current batch has run
    Close CHK_BATCH_RUN;
    Raise e_batch_been_run;
 Else
    Close CHK_BATCH_RUN;

    select XTR_BATCH_EVENTS_S.NEXTVAL into l_event_id from DUAL;

    Insert into XTR_BATCH_EVENTS(batch_event_id, batch_id, event_code, authorized,
                                   authorized_by, authorized_on, created_by, creation_date,
                                   last_updated_by, last_update_date, last_update_login)
    values(l_event_id, p_batch_id, p_event, 'N', null, null, fnd_global.user_id,
             l_sysdate, fnd_global.user_id, l_sysdate, fnd_global.login_id);
 End If;

EXCEPTION
 When e_batch_been_run then
   FND_MESSAGE.Set_Name('XTR', 'XTR_RETRO_CP_RUNNING');
   APP_EXCEPTION.raise_exception;
End;
/***************************************************************/

/*=====================================================================
   END: New objects for BUG 3378028 - FAS HEDGE ACCOUNTING PROJECT
======================================================================*/



PROCEDURE POPULATE_ITEMS(P_HEDGE_NO IN NUMBER) IS

TYPE HCurTyp IS REF CURSOR;
hcur HCurTyp;

TYPE X_HEDGE_ATTRIBUTE_ID  is table of XTR_HEDGE_ITEMS_TEMP.HEDGE_ATTRIBUTE_ID%type 	Index By BINARY_INTEGER;
TYPE X_TRX_INV_ID          is table of XTR_HEDGE_ITEMS_TEMP.TRX_INV_ID%type 		Index By BINARY_INTEGER;
TYPE X_PAY_SCHEDULE_ID     is table of XTR_HEDGE_ITEMS_TEMP.PAY_SCHEDULE_ID%type 	Index By BINARY_INTEGER;
TYPE X_SOURCE_NAME  	   is table of XTR_HEDGE_ITEMS_TEMP.SOURCE_NAME%type 		Index By BINARY_INTEGER;
TYPE X_TRX_TYPE_NAME       is table of XTR_HEDGE_ITEMS_TEMP.TRX_TYPE_NAME%type 		Index By BINARY_INTEGER;
TYPE X_ORG_NAME            is table of XTR_HEDGE_ITEMS_TEMP.ORG_NAME%type 		Index By BINARY_INTEGER;
TYPE X_VEND_CUST_NAME      is table of XTR_HEDGE_ITEMS_TEMP.VEND_CUST_NAME%type 	Index By BINARY_INTEGER;
TYPE X_TRX_DATE            is table of XTR_HEDGE_ITEMS_TEMP.TRX_DATE%type 		Index By BINARY_INTEGER;
TYPE X_TRX_NUMBER          is table of XTR_HEDGE_ITEMS_TEMP.TRX_NUMBER%type 		Index By BINARY_INTEGER;
TYPE X_CURRENCY_CODE       is table of XTR_HEDGE_ITEMS_TEMP.CURRENCY_CODE%type 		Index By BINARY_INTEGER;
TYPE X_AMOUNT              is table of XTR_HEDGE_ITEMS_TEMP.AMOUNT%type 		Index By BINARY_INTEGER;
TYPE X_DUE_DATE            is table of XTR_HEDGE_ITEMS_TEMP.DUE_DATE%type 		Index By BINARY_INTEGER;
TYPE X_PCT_ALLOCATION      is table of XTR_HEDGE_ITEMS_TEMP.PCT_ALLOCATION%type 	Index By BINARY_INTEGER;
TYPE X_REFERENCE_AMOUNT    is table of XTR_HEDGE_ITEMS_TEMP.REFERENCE_AMOUNT%type 	Index By BINARY_INTEGER;
TYPE X_REQUEST_ID          is table of XTR_HEDGE_ITEMS_TEMP.REQUEST_ID%type 		Index By BINARY_INTEGER;
TYPE X_CREATED_BY          is table of XTR_HEDGE_ITEMS_TEMP.CREATED_BY%type 		Index By BINARY_INTEGER;
TYPE X_CREATION_DATE       is table of XTR_HEDGE_ITEMS_TEMP.CREATION_DATE%type 		Index By BINARY_INTEGER;
TYPE X_LAST_UPDATED_BY     is table of XTR_HEDGE_ITEMS_TEMP.LAST_UPDATED_BY%type 	Index By BINARY_INTEGER;
TYPE X_LAST_UPDATE_DATE    is table of XTR_HEDGE_ITEMS_TEMP.LAST_UPDATE_DATE%type 	Index By BINARY_INTEGER;
TYPE X_LAST_UPDATE_LOGIN   is table of XTR_HEDGE_ITEMS_TEMP.LAST_UPDATE_LOGIN %type 	Index By BINARY_INTEGER;

HEDGE_ATTRIBUTE_ID    	   X_HEDGE_ATTRIBUTE_ID;
TRX_INV_ID 	           X_TRX_INV_ID;
PAY_SCHEDULE_ID   	   X_PAY_SCHEDULE_ID;
SOURCE_NAME 	  	   X_SOURCE_NAME;
TRX_TYPE_NAME	  	   X_TRX_TYPE_NAME;
ORG_NAME 	    	   X_ORG_NAME;
VEND_CUST_NAME   	   X_VEND_CUST_NAME;
TRX_DATE 	   	   X_TRX_DATE;
TRX_NUMBER 	           X_TRX_NUMBER;
CURRENCY_CODE 	 	   X_CURRENCY_CODE;
AMOUNT 		       	   X_AMOUNT;
DUE_DATE 	           X_DUE_DATE;
PCT_ALLOCATION 	           X_PCT_ALLOCATION;
REFERENCE_AMOUNT           X_REFERENCE_AMOUNT;
REQUEST_ID                 X_REQUEST_ID;
CREATED_BY                 X_CREATED_BY;
CREATION_DATE		   X_CREATION_DATE;
LAST_UPDATED_BY            X_LAST_UPDATED_BY;
LAST_UPDATE_DATE           X_LAST_UPDATE_DATE;
LAST_UPDATE_LOGIN          X_LAST_UPDATE_LOGIN;

idx        NUMBER := 1;
cnt        NUMBER := 1;
l_data_source VARCHAR2(10);

l_query    VARCHAR2(32000);

-- AR Related Variables and cursors Begin

cursor cur_rel(HEDGE_NO IN NUMBER) is
SELECT PRIMARY_CODE TRX_INV_ID, SECONDARY_CODE PAY_SCHEDULE_ID, HEDGE_ATTRIBUTE_ID,
       PCT_ALLOCATION, REFERENCE_AMOUNT HEDGE_AMOUNT
FROM   XTR_HEDGE_RELATIONSHIPS
WHERE  HEDGE_ATTRIBUTE_ID = HEDGE_NO
AND INSTRUMENT_ITEM_FLAG = 'I';

cursor trx(p_trx_id in number) is
select trx_number, trx_date, batch_source_id, cust_trx_type_id,
       org_id, invoice_currency_code
from ra_customer_trx_all
where customer_trx_id = p_trx_id;

l_ar_trxtype_id      NUMBER(15);
l_customer_id     NUMBER(15);
l_ar_org_id          NUMBER(15);
l_batch_source_id NUMBER(15);

cursor  ar_pmts(p_trx_id in number, p_paysch_id in number) is
select due_date,customer_id
from ar_payment_schedules_all
where customer_trx_id = p_trx_id
and payment_schedule_id = p_paysch_id;

cursor ar_trxtype is
select name
from ra_cust_trx_types_all
where cust_trx_type_id = l_ar_trxtype_id
and  org_id =  l_ar_org_id;

cursor batch is
select name
from ra_batch_sources_all
where batch_source_id = l_batch_source_id
and  org_id =  l_ar_org_id;


/* BUG 3497802 Repalcing RA_CUSTOMERS with HZ_PARTIES

cursor customer(p_customer_id in number) is
select customer_name
from   ra_customers
where  customer_id = p_customer_id;

*/

cursor customer(p_customer_id in number) is
select substrb(PARTY.PARTY_NAME,1,50)
from   hz_parties party, hz_cust_accounts cust_acct
where  cust_acct.party_id = party.party_id
and    cust_acct.cust_account_id = p_customer_id;

cursor ar_org is
select name
from hr_operating_units
where organization_id = l_ar_org_id;

-- AR Related Variables and cursors End

-- AP Related Variables and cursors Begin

l_ap_invtype VARCHAR2(25);
l_vendor_id  NUMBER(15);
l_ap_org_id  NUMBER(15);
l_ap_source  AP_INVOICES_ALL.source%type;

cursor invoice(p_invoice_id in number) is
select invoice_num, invoice_date, source, invoice_type_lookup_code,
       vendor_id, org_id, payment_currency_code
from ap_invoices_all
where invoice_id = p_invoice_id;

cursor  ap_pmts(p_invoice_id in number, p_payment_num in number) is
select due_date
from ap_payment_schedules_all
where invoice_id = p_invoice_id
and payment_num = p_payment_num;

cursor ap_trxtype is
select displayed_field
from ap_lookup_codes k
where lookup_type = 'INVOICE TYPE'
and  lookup_code =  l_ap_invtype;

cursor ap_source is
select displayed_field
from   ap_lookup_codes k
where  lookup_type = 'SOURCE'
and    lookup_code =  l_ap_source;

cursor vendor(p_vendor_id in number) is
select vendor_name
from   po_vendors
where  vendor_id = p_vendor_id;

cursor ap_org is
select name
from   hr_operating_units
where  organization_id = l_ap_org_id;

-- AP Related Variables and cursors End

l_status XTR_HEDGE_ATTRIBUTES.HEDGE_STATUS%TYPE;

cursor hedge(hedge_no in number) is
select hedge_status
from   xtr_hedge_attributes
where  hedge_attribute_id =  hedge_no;

l_count NUMBER := 0;

Cursor cur_dtls(p_hedge_no in number) is
select count(*) from xtr_hedge_relationships
where  hedge_attribute_id = p_hedge_no
and    instrument_item_flag = 'I';

l_iu_flag VARCHAR2(1) := 'I';

BEGIN

open  hedge(P_HEDGE_NO);
fetch hedge into l_status;
close hedge;

open  cur_dtls(P_HEDGE_NO);
fetch cur_dtls into l_count;
close cur_dtls;

If (l_status = 'CURRENT' and l_count = 0) then
   l_data_source := 'EXT';
   If Get_Source_Code(P_HEDGE_NO) = 'AP' then
      l_query := 'SELECT INVOICE_ID TRX_INV_ID, PAYMENT_NUM PAY_SCHEDULE_ID, SOURCE_NAME, TRX_TYPE_NAME, ORG_NAME,
                  VENDOR_NAME VEND_CUST_NAME, TRX_DATE, TRX_NUMBER, CURRENCY_CODE, AMOUNT, DUE_DATE FROM
                  XTR_AP_ORIG_TRX_V '||get_where_clause(p_hedge_no);
   Elsif Get_Source_Code(P_HEDGE_NO) = 'AR' then
      l_query := 'SELECT CUSTOMER_TRX_ID TRX_INV_ID, PAYMENT_SCHEDULE_ID PAY_SCHEDULE_ID, SOURCE_NAME, TRX_TYPE_NAME,
                  ORG_NAME, CUSTOMER_NAME VEND_CUST_NAME, TRX_DATE, TRX_NUMBER, CURRENCY_CODE, AMOUNT, DUE_DATE FROM
                  XTR_AR_ORIG_TRX_V '||get_where_clause(p_hedge_no);
   End If;

   OPEN hcur FOR l_query;
   LOOP
      FETCH hcur INTO TRX_INV_ID(idx),PAY_SCHEDULE_ID(idx),SOURCE_NAME(idx),
                      TRX_TYPE_NAME(idx),ORG_NAME(idx),VEND_CUST_NAME(idx),
                      TRX_DATE(idx),TRX_NUMBER(idx),CURRENCY_CODE(idx),
                      AMOUNT(idx),DUE_DATE(idx);
                      HEDGE_ATTRIBUTE_ID(idx) := P_HEDGE_NO;
                      PCT_ALLOCATION(idx) := NULL;
                      REFERENCE_AMOUNT(idx) := NULL;
      EXIT WHEN hcur%NOTFOUND;
      REQUEST_ID(idx)        := FND_GLOBAL.CONC_REQUEST_ID;
      CREATED_BY(idx)        := FND_GLOBAL.USER_ID;
      CREATION_DATE(idx)     := SYSDATE;
      LAST_UPDATED_BY(idx)   := FND_GLOBAL.USER_ID;
      LAST_UPDATE_DATE(idx)  := SYSDATE;
      LAST_UPDATE_LOGIN(idx) := FND_GLOBAL.LOGIN_ID;
      idx := idx+1;
   END LOOP;
   CLOSE hcur;
Elsif (l_status in ('FULFILLED','FAILED') or (l_status = 'CURRENT' and l_count <> 0)) then
   l_data_source := 'XTR';
   l_query := 'SELECT PRIMARY_CODE TRX_INV_ID, SECONDARY_CODE PAY_SCHEDULE_ID, HEDGE_ATTRIBUTE_ID, AMOUNT,
               PCT_ALLOCATION, REFERENCE_AMOUNT FROM XTR_HEDGE_RELATIONSHIPS WHERE
               INSTRUMENT_ITEM_FLAG = :iu_flag AND HEDGE_ATTRIBUTE_ID = :HEDGE_NO';

   OPEN hcur FOR l_query using l_iu_flag, p_hedge_no;
   LOOP
      FETCH hcur INTO TRX_INV_ID(cnt),PAY_SCHEDULE_ID(cnt),HEDGE_ATTRIBUTE_ID(cnt),AMOUNT(cnt),
                      PCT_ALLOCATION(cnt),REFERENCE_AMOUNT(cnt);

      EXIT WHEN hcur%NOTFOUND;
      If Get_Source_Code(P_HEDGE_NO) = 'AP' then
         Open  invoice(TRX_INV_ID(cnt));
         Fetch invoice into TRX_NUMBER(cnt), TRX_DATE(cnt), l_ap_source,
                            l_ap_invtype, l_vendor_id, l_ap_org_id, CURRENCY_CODE(cnt);
         if invoice%notfound then
            TRX_NUMBER(cnt)    := NULL;
            TRX_DATE(cnt)      := NULL;
            l_ap_source        := NULL;
            l_ap_invtype       := NULL;
            l_vendor_id        := NULL;
            l_ap_org_id        := NULL;
            CURRENCY_CODE(cnt) := NULL;
         end if;
         Close invoice;

         Open  ap_pmts(TRX_INV_ID(cnt),PAY_SCHEDULE_ID(cnt));
         Fetch ap_pmts into DUE_DATE(cnt);
         if ap_pmts%notfound then
            DUE_DATE(cnt) := NULL;
         end if;
         Close ap_pmts;

         open  ap_trxtype;
         fetch ap_trxtype into TRX_TYPE_NAME(cnt);
         if ap_trxtype%notfound then
            TRX_TYPE_NAME(cnt) := NULL;
         end if;
         close ap_trxtype;

         open  ap_source;
         fetch ap_source into SOURCE_NAME(cnt);
         if ap_source%NOTFOUND then
            select decode(l_ap_source,'Manual Invoice Entry',
                          fnd_message.get_string('XTR','XTR_AP_SOURCE_MANUAL'),
                          fnd_message.get_string('XTR','XTR_AP_SOURCE_OTHER'))
            INTO SOURCE_NAME(cnt) from dual;
         end if;
         close ap_source;

         open  vendor(l_vendor_id);
         fetch vendor into VEND_CUST_NAME(cnt);
         if vendor%notfound then
            VEND_CUST_NAME(cnt) := NULL;
         end if;
         close vendor;

         open  ap_org;
         fetch ap_org into ORG_NAME(cnt);
         if ap_org%notfound then
            ORG_NAME(cnt) := NULL;
         end if;
         close ap_org;

      Elsif Get_Source_Code(P_HEDGE_NO) = 'AR' then

         Open  trx(TRX_INV_ID(cnt));
         Fetch trx into TRX_NUMBER(cnt), TRX_DATE(cnt), l_batch_source_id,
                   l_ar_trxtype_id, l_ar_org_id, CURRENCY_CODE(cnt);
         if trx%notfound then
            TRX_NUMBER(cnt)	:= NULL;
            TRX_DATE(cnt)	:= NULL;
            l_batch_source_id	:= NULL;
            l_ar_trxtype_id	:= NULL;
            l_ar_org_id		:= NULL;
            CURRENCY_CODE(cnt)	:= NULL;
         end if;
         Close trx;

         Open  ar_pmts(TRX_INV_ID(cnt),PAY_SCHEDULE_ID(cnt));
         Fetch ar_pmts into DUE_DATE(cnt),l_customer_id;
         if ar_pmts%notfound then
            DUE_DATE(cnt) := NULL;
            l_customer_id := NULL;
         end if;
         Close ar_pmts;

         open  ar_trxtype;
         fetch ar_trxtype into TRX_TYPE_NAME(cnt);
         if ar_trxtype%notfound then
            TRX_TYPE_NAME(cnt) := NULL;
         end if;
         close ar_trxtype;

         open  batch;
         fetch batch into SOURCE_NAME(cnt);
         if batch%notfound then
            SOURCE_NAME(cnt) := NULL;
         end if;
         close batch;

         open  customer(l_customer_id);
         fetch customer into VEND_CUST_NAME(cnt);
         if customer%notfound then
            VEND_CUST_NAME(cnt) := NULL;
         end if;
         close customer;

        open  ar_org;
        fetch ar_org into ORG_NAME(cnt);
        if ar_org%notfound then
           ORG_NAME(cnt) := NULL;
        end if;
        close ar_org;

      End If;
      REQUEST_ID(cnt) 	     := FND_GLOBAL.CONC_REQUEST_ID;
      CREATED_BY(cnt)        := FND_GLOBAL.USER_ID;
      CREATION_DATE(cnt)     := SYSDATE;
      LAST_UPDATED_BY(cnt)   := FND_GLOBAL.USER_ID;
      LAST_UPDATE_DATE(cnt)  := SYSDATE;
      LAST_UPDATE_LOGIN(cnt) := FND_GLOBAL.LOGIN_ID;
      cnt := cnt+1;
   END LOOP;
   CLOSE hcur;
End If;

  IF (l_data_source = 'EXT' AND idx > 1) OR (l_data_source = 'XTR' AND cnt > 1) then
      FORALL J in TRX_INV_ID.FIRST..TRX_INV_ID.LAST
      insert into XTR_HEDGE_ITEMS_TEMP(HEDGE_ATTRIBUTE_ID,
         TRX_INV_ID,PAY_SCHEDULE_ID,SOURCE_NAME,
         TRX_TYPE_NAME, ORG_NAME,VEND_CUST_NAME,TRX_DATE,
         TRX_NUMBER,CURRENCY_CODE, AMOUNT,PCT_ALLOCATION, REFERENCE_AMOUNT,
         DUE_DATE,REQUEST_ID,CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
         LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
         )
      values (HEDGE_ATTRIBUTE_ID(j),
             TRX_INV_ID(j),PAY_SCHEDULE_ID(j),SOURCE_NAME(j),
             TRX_TYPE_NAME(j), ORG_NAME(j),VEND_CUST_NAME(j),TRX_DATE(j),
             TRX_NUMBER(j),CURRENCY_CODE(j), AMOUNT(j),PCT_ALLOCATION(j),REFERENCE_AMOUNT(j),
             DUE_DATE(j),REQUEST_ID(j),CREATED_BY(j), CREATION_DATE(j), LAST_UPDATED_BY(j),
             LAST_UPDATE_DATE(j), LAST_UPDATE_LOGIN(j)
             );
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
END POPULATE_ITEMS;

PROCEDURE CALC_PCT_ALLOC (ERRBUF     OUT NOCOPY VARCHAR2,
                          RETCODE    OUT NOCOPY VARCHAR2,
                          P_HEDGE_NO IN  NUMBER
                          ) AS
TYPE HCurTyp IS REF CURSOR;

hcur HCurTyp;

TYPE X_HEDGE_RELATIONSHIP_ID is table of xtr_hedge_relationships.HEDGE_RELATIONSHIP_ID%type Index By BINARY_INTEGER;
TYPE X_HEDGE_ATTRIBUTE_ID    is table of xtr_hedge_relationships.HEDGE_ATTRIBUTE_ID%type    Index By BINARY_INTEGER;
TYPE X_SOURCE_TYPE_ID	     is table of xtr_hedge_relationships.SOURCE_TYPE_ID%type 	    Index By BINARY_INTEGER;
TYPE X_PRIMARY_CODE	     is table of xtr_hedge_relationships.PRIMARY_CODE%type 	    Index By BINARY_INTEGER;
TYPE X_SECONDARY_CODE	     is table of xtr_hedge_relationships.SECONDARY_CODE%type 	    Index By BINARY_INTEGER;
TYPE X_INSTRUMENT_ITEM_FLAG  is table of xtr_hedge_relationships.INSTRUMENT_ITEM_FLAG%type  Index By BINARY_INTEGER;
TYPE X_PCT_ALLOCATION	     is table of xtr_hedge_relationships.PCT_ALLOCATION%type 	    Index By BINARY_INTEGER;
TYPE X_REFERENCE_AMOUNT	     is table of xtr_hedge_relationships.REFERENCE_AMOUNT%type 	    Index By BINARY_INTEGER;
TYPE X_AMOUNT	             is table of xtr_hedge_relationships.AMOUNT%type 	            Index By BINARY_INTEGER;
TYPE X_CREATED_BY	     is table of xtr_hedge_relationships.CREATED_BY%type 	    Index By BINARY_INTEGER;
TYPE X_CREATION_DATE	     is table of xtr_hedge_relationships.CREATION_DATE%type 	    Index By BINARY_INTEGER;
TYPE X_LAST_UPDATED_BY	     is table of xtr_hedge_relationships.LAST_UPDATED_BY%type 	    Index By BINARY_INTEGER;
TYPE X_LAST_UPDATE_DATE	     is table of xtr_hedge_relationships.LAST_UPDATE_DATE%type 	    Index By BINARY_INTEGER;
TYPE X_LAST_UPDATE_LOGIN     is table of xtr_hedge_relationships.LAST_UPDATE_LOGIN%type     Index By BINARY_INTEGER;

HEDGE_RELATIONSHIP_ID	X_HEDGE_RELATIONSHIP_ID;
HEDGE_ATTRIBUTE_ID	X_HEDGE_ATTRIBUTE_ID;
SOURCE_TYPE_ID		X_SOURCE_TYPE_ID;
PRIMARY_CODE		X_PRIMARY_CODE;
SECONDARY_CODE		X_SECONDARY_CODE;
INSTRUMENT_ITEM_FLAG	X_INSTRUMENT_ITEM_FLAG;
PCT_ALLOCATION			X_PCT_ALLOCATION;
REFERENCE_AMOUNT		X_REFERENCE_AMOUNT;
AMOUNT		        X_AMOUNT;
CREATED_BY			X_CREATED_BY;
CREATION_DATE		X_CREATION_DATE;
LAST_UPDATED_BY		X_LAST_UPDATED_BY;
LAST_UPDATE_DATE	X_LAST_UPDATE_DATE;
LAST_UPDATE_LOGIN	X_LAST_UPDATE_LOGIN;

cursor pct(p_prim_code in VARCHAR2, p_sec_code in VARCHAR2) is
   select nvl(sum(pct_allocation),0) from
   xtr_hedge_relationships hr, xtr_hedge_attributes ha
   where hr.hedge_attribute_id = ha.hedge_attribute_id
   and   ((ha.hedge_status in ('DESIGNATE','CURRENT','FULFILLED'))
          OR (hedge_status in ('FAILED','DEDESIGNATED') and ha.start_date <= ha.discontinue_date)
          )
   and primary_code   = p_prim_code
   and secondary_code = p_sec_code;

l_pct NUMBER := 0;

cursor source(hedge_no in NUMBER) is
select st.source_type_id, instrument_item_flag
from   xtr_hedge_criteria hc,
       xtr_source_types st
where  hedge_attribute_id =  hedge_no
and    hc.from_value 	  =  st.source_code
and    criteria_type 	  =  'BASIC'
and    criteria_code 	  =  'ITEM_SOURCE';

l_source_id XTR_SOURCE_TYPES.SOURCE_TYPE_ID%TYPE;
l_iu_flag      XTR_SOURCE_TYPES.INSTRUMENT_ITEM_FLAG%TYPE;

idx        NUMBER := 1;
l_query    VARCHAR2(32000);
l_select   VARCHAR2(350);

BEGIN

open  source(P_HEDGE_NO);
fetch source into l_source_id, l_iu_flag;
close source;

If xtr_hedge_process_p.get_source_code(P_HEDGE_NO) = 'AP' then
   l_query := ' SELECT INVOICE_ID, PAYMENT_NUM, AMOUNT FROM XTR_AP_ORIG_TRX_V '||get_where_clause(P_HEDGE_NO);
Elsif xtr_hedge_process_p.get_source_code(P_HEDGE_NO) = 'AR' then
   l_query := ' SELECT CUSTOMER_TRX_ID, PAYMENT_SCHEDULE_ID, AMOUNT FROM XTR_AR_ORIG_TRX_V '||get_where_clause(P_HEDGE_NO);
End If;

OPEN hcur FOR l_query;
LOOP
   FETCH hcur INTO PRIMARY_CODE(idx),SECONDARY_CODE(idx),AMOUNT(idx);
   EXIT WHEN hcur%NOTFOUND;
   idx := idx+1;
END LOOP;
CLOSE hcur;

If idx > 1 then
   FOR k in PRIMARY_CODE.FIRST..PRIMARY_CODE.LAST LOOP
      l_pct := 0;
      open  pct(PRIMARY_CODE(k), SECONDARY_CODE(k));
      fetch pct into l_pct;
      close pct;

      PCT_ALLOCATION(k)       := 100-nvl(l_pct,0);
      REFERENCE_AMOUNT(k)     := AMOUNT(k) * (PCT_ALLOCATION(k)/100);
      select xtr_hedge_relationships_s.nextval into HEDGE_RELATIONSHIP_ID(k) from dual;

      HEDGE_ATTRIBUTE_ID(k)    := p_hedge_no;
      SOURCE_TYPE_ID(k)        := l_source_id;
      INSTRUMENT_ITEM_FLAG(k)  := l_iu_flag;
      CREATED_BY(k)            := fnd_global.user_id;
      CREATION_DATE(k)         := sysdate;
      LAST_UPDATED_BY(k)       := fnd_global.user_id;
      LAST_UPDATE_DATE(k)      := sysdate;
      LAST_UPDATE_LOGIN(k)     := fnd_global.login_id;
   END LOOP;

   FORALL J in PRIMARY_CODE.FIRST..PRIMARY_CODE.LAST
      insert into xtr_hedge_relationships
             (HEDGE_RELATIONSHIP_ID,HEDGE_ATTRIBUTE_ID,SOURCE_TYPE_ID,PRIMARY_CODE,
              SECONDARY_CODE,INSTRUMENT_ITEM_FLAG,PCT_ALLOCATION,REFERENCE_AMOUNT,AMOUNT,
              CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
      values (HEDGE_RELATIONSHIP_ID(j),HEDGE_ATTRIBUTE_ID(j),SOURCE_TYPE_ID(j),PRIMARY_CODE(j),
              SECONDARY_CODE(j),INSTRUMENT_ITEM_FLAG(j),PCT_ALLOCATION(j),REFERENCE_AMOUNT(j),
              AMOUNT(j),CREATED_BY(j),CREATION_DATE(j),LAST_UPDATED_BY(j),LAST_UPDATE_DATE(j),
              LAST_UPDATE_LOGIN(j));
End If;
EXCEPTION
   WHEN OTHERS THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
END   CALC_PCT_ALLOC;


/*CHECK_ADV_CRIT_SET_CONSISTENCY is a common procedure to insure the
  data is consistent.  The count of each advanced item and condition_count
  must all be equal
*/
PROCEDURE CHECK_ADV_CRIT_SET_CONSISTENCY(p_crit_set IN CRITERIA_SET_REC_TYPE) IS
BEGIN
       if p_crit_set.condition_count <> p_crit_set.item.count or
          p_crit_set.condition_count <> p_crit_set.condition.count or
          p_crit_set.condition_count <> p_crit_set.value.count or
          p_crit_set.condition_count is null then
          raise e_invalid_criteria_set;
       end if;
END CHECK_ADV_CRIT_SET_CONSISTENCY;



/* Local procedure to generate dynamic portion of where clause
   Warning: This procedure returns only additional AND clauses.
   You must add a 'WHERE' clause before using the results from
   this procedure.
   AR where clause is returned in the second parameter.
   AP where clause is returned in the third parameter.
   Do not confuse the order of these two.
   The dynamic portion is common code for ACTUAL and FORECAST hedge
   queries, so it was extracted to keep only one source of code.
*/
PROCEDURE GENERATE_DYN_WHERE_CLAUSE(p_crit_set IN CRITERIA_SET_REC_TYPE,
                                    v_ar_where OUT NOCOPY VARCHAR2,
                                    v_ap_where OUT NOCOPY VARCHAR2) IS

   v_ap_invtype_eq  Varchar2(5000);
   v_ap_invtype_neq Varchar2(5000);
   v_ap_source_eq   Varchar2(5000);
   v_ap_source_neq  Varchar2(5000);
   v_ap_supplier_eq   Varchar2(5000);
   v_ap_supplier_neq  Varchar2(5000);
   v_ar_customer_eq   Varchar2(5000);
   v_ar_customer_neq  Varchar2(5000);
   v_ar_source_eq   Varchar2(5000);
   v_ar_source_neq  Varchar2(5000);
   v_ar_trxtype_eq   Varchar2(5000);
   v_ar_trxtype_neq  Varchar2(5000);
   v_opunit_eq   Varchar2(5000);
   v_opunit_neq  Varchar2(5000);

Cursor ar_source(p_source in VARCHAR2, p_company in VARCHAR2) is
       select '(BATCH_SOURCE_ID = '|| batch_source_id || ' AND ORG_ID = '||org_id||') OR '  source
from   ra_batch_sources_all bs,
       hr_operating_units ho,
       xtr_parties_v xp
where  bs.org_id = ho.organization_id
       and  ho.set_of_books_id = (SELECT glle.ledger_id FROM gl_ledger_le_v glle
             WHERE  glle.legal_entity_id = xp.legal_entity_id
          AND glle.ledger_category_code = 'PRIMARY')   -- bug 4654775
       and xp.party_code = nvl(p_company,xp.party_code) --BUG 3002000 #7
       and bs.name = p_source;

Cursor ar_trxtype(p_trxtype in VARCHAR2, p_company in VARCHAR2) is
       select '(CUST_TRX_TYPE_ID = '|| cust_trx_type_id || ' AND ORG_ID = '||org_id||') OR '  trxtype
       from   ra_cust_trx_types_all tt,
              hr_operating_units ho,
              xtr_parties_v xp
       where  tt.org_id = ho.organization_id
          and     ho.set_of_books_id = (SELECT glle.ledger_id FROM gl_ledger_le_v glle
             WHERE  glle.legal_entity_id = xp.legal_entity_id
          AND glle.ledger_category_code = 'PRIMARY')   -- bug 4654775
              and xp.party_code = nvl(p_company,xp.party_code) -- BUG 3002000 #7
              and tt.name = p_trxtype
       union all
       select '(CUST_TRX_TYPE_ID = -99999) OR '  trxtype
       from   DUAL
       where  substr(fnd_message.get_string('XTR','XTR_AR_TRX_TYPE_CASH'),1,20) = p_trxtype;

/* BUG 3497802 Repalcing RA_CUSTOMERS with HZ_PARTIES

cursor ar_customer(p_customer in VARCHAR2) is
SELECT CUSTOMER_ID ||','  customer
FROM   RA_CUSTOMERS
WHERE  CUSTOMER_NAME = p_customer;

*/

cursor ar_customer(p_customer in VARCHAR2) is
SELECT cust_acct.cust_account_id||','  customer
FROM   hz_parties party, hz_cust_accounts cust_acct
WHERE  substrb(PARTY.PARTY_NAME,1,50) = p_customer
and    cust_acct.party_id = party.party_id;

l_ar_customer_eq    VARCHAR2(5000);
l_ar_customer_neq   VARCHAR2(5000);

l_ar_source_eq      VARCHAR2(5000);
l_ar_trxtype_eq     Varchar2(5000);

l_ar_source_neq     VARCHAR2(5000);
l_ar_trxtype_neq    Varchar2(5000);


BEGIN

       CHECK_ADV_CRIT_SET_CONSISTENCY(p_crit_set);

       For i in 0..p_crit_set.condition_count-1 Loop
              If    p_crit_set.item(i) = 'AP_INVTYPE' and p_crit_set.condition(i) = '='  then
                  if v_ap_invtype_eq is null then
                     v_ap_invtype_eq := 'IN ('''||replace(p_crit_set.value(i),'''','''''')||'''';
                  else
                     v_ap_invtype_eq := v_ap_invtype_eq||','''||replace(p_crit_set.value(i),'''','''''')||'''';
                  end if;
               Elsif p_crit_set.item(i) = 'AP_INVTYPE' and p_crit_set.condition(i) = '<>' then
                  if v_ap_invtype_neq is null then
                     v_ap_invtype_neq := 'NOT IN ('''||replace(p_crit_set.value(i),'''','''''')||'''';
                  else
                     v_ap_invtype_neq := v_ap_invtype_neq||','''||replace(p_crit_set.value(i),'''','''''')||'''';
                  end if;
               Elsif p_crit_set.item(i) = 'AP_SOURCE' and p_crit_set.condition(i) = '=' then
                  if v_ap_source_eq is null then
                     v_ap_source_eq := 'IN ('''||replace(p_crit_set.value(i),'''','''''')||'''';
                  else
                     v_ap_source_eq := v_ap_source_eq||','''||replace(p_crit_set.value(i),'''','''''')||'''';
                  end if;
               Elsif p_crit_set.item(i) = 'AP_SOURCE' and p_crit_set.condition(i) = '<>' then
                  if v_ap_source_neq is null then
                     v_ap_source_neq := 'NOT IN ('''||replace(p_crit_set.value(i),'''','''''')||'''';
                  else
                     v_ap_source_neq := v_ap_source_neq||','''||replace(p_crit_set.value(i),'''','''''')||'''';
                  end if;
               Elsif p_crit_set.item(i) = 'AP_SUPPLIER' and p_crit_set.condition(i) = '=' then
                  if v_ap_supplier_eq is null then
                     v_ap_supplier_eq := 'IN ('''||replace(p_crit_set.value(i),'''','''''')||'''';
                  else
                     v_ap_supplier_eq := v_ap_supplier_eq||','''||replace(p_crit_set.value(i),'''','''''')||'''';
                  end if;
               Elsif p_crit_set.item(i) = 'AP_SUPPLIER' and p_crit_set.condition(i) = '<>' then

                  if v_ap_supplier_neq is null then
                     v_ap_supplier_neq := 'NOT IN ('''||replace(p_crit_set.value(i),'''','''''')||'''';
                  else
                     v_ap_supplier_neq := v_ap_supplier_neq||','''||replace(p_crit_set.value(i),'''','''''')||'''';
                  end if;
               Elsif p_crit_set.item(i) = 'AR_CUSTOMER' and p_crit_set.condition(i) = '=' then
                  Begin
   	                 l_ar_customer_eq := NULL;
                     for r in ar_customer(p_crit_set.value(i)) Loop
                        l_ar_customer_eq := l_ar_customer_eq||r.customer;
                     end loop;
                     v_ar_customer_eq := v_ar_customer_eq||l_ar_customer_eq;
                  End;

               Elsif p_crit_set.item(i) = 'AR_CUSTOMER' and p_crit_set.condition(i) = '<>' then
                  Begin
  	                 l_ar_customer_neq := NULL;
                     for r in ar_customer(p_crit_set.value(i)) Loop
                        l_ar_customer_neq := l_ar_customer_neq||r.customer;
                     end loop;
                     v_ar_customer_neq := v_ar_customer_neq||l_ar_customer_neq;
                  End;

               Elsif p_crit_set.item(i) = 'AR_SOURCE' and p_crit_set.condition(i) = '=' then
                  Begin
   	                 l_ar_source_eq := NULL;
                     for r in ar_source(p_crit_set.value(i), p_crit_set.company_code) Loop
                        l_ar_source_eq := l_ar_source_eq||r.source;
                     end loop;
                     v_ar_source_eq := v_ar_source_eq||l_ar_source_eq;
                  End;
               Elsif p_crit_set.item(i) = 'AR_SOURCE' and p_crit_set.condition(i) = '<>' then
                  Begin
   	                 l_ar_source_neq := NULL;
                     for r in ar_source(p_crit_set.value(i), p_crit_set.company_code) Loop
                        l_ar_source_neq := l_ar_source_neq||r.source;
                     end loop;
                     v_ar_source_neq := v_ar_source_neq||l_ar_source_neq;
                End;
              Elsif p_crit_set.item(i) = 'AR_TRXTYPE' and p_crit_set.condition(i) = '=' then
	             Begin
                    l_ar_trxtype_eq := NULL;
		            for r in ar_trxtype(p_crit_set.value(i), p_crit_set.company_code) Loop
	                   l_ar_trxtype_eq := l_ar_trxtype_eq||r.trxtype;
                    end loop;
                    v_ar_trxtype_eq := v_ar_trxtype_eq||l_ar_trxtype_eq;
		         End;
              Elsif p_crit_set.item(i) = 'AR_TRXTYPE' and p_crit_set.condition(i) = '<>' then
	             Begin
                    l_ar_trxtype_neq := NULL;
		            for r in ar_trxtype(p_crit_set.value(i), p_crit_set.company_code) Loop
	                   l_ar_trxtype_neq := l_ar_trxtype_neq||r.trxtype;
                    end loop;
                    v_ar_trxtype_neq := v_ar_trxtype_neq||l_ar_trxtype_neq;
		         End;
              Elsif p_crit_set.item(i) = 'COMN_OPUNIT' and p_crit_set.condition(i) = '=' then
                 if v_opunit_eq is null then
                    v_opunit_eq := 'IN ('||p_crit_set.value(i);
                 else
                    v_opunit_eq := v_opunit_eq ||','||p_crit_set.value(i);
                 end if;
              Elsif p_crit_set.item(i) = 'COMN_OPUNIT' and p_crit_set.condition(i) = '<>' then
                 if v_opunit_neq is null then
                    v_opunit_neq := 'NOT IN ('||p_crit_set.value(i);
                 else
                    v_opunit_neq := v_opunit_neq ||','||p_crit_set.value(i);
                 end if;
              End If;
        End Loop;

If v_ap_invtype_eq is not null then
   v_ap_invtype_eq:= ' and trx_type_id '||v_ap_invtype_eq||')';
End If;
If v_ap_invtype_neq is not null then
   v_ap_invtype_neq:= ' and trx_type_id '||v_ap_invtype_neq||')';
End if;
If v_ap_source_eq is not null then
   v_ap_source_eq:= ' and source '||v_ap_source_eq||')';
End If;
If v_ap_source_neq is not null then
   v_ap_source_neq:= ' and source '||v_ap_source_neq||')';
End If;

If v_ap_supplier_eq is not null then
   v_ap_supplier_eq := ' AND VENDOR_ID '||v_ap_supplier_eq||')';
End If;

If v_ap_supplier_neq is not null then
   v_ap_supplier_neq := ' AND VENDOR_ID '||v_ap_supplier_neq||')';
End If;

If v_ar_customer_eq is not null then
   v_ar_customer_eq := ' AND CUSTOMER_ID IN ('||substr(v_ar_customer_eq,1,length(v_ar_customer_eq)-1)||') ';
End If;

If v_ar_customer_neq is not null then
   v_ar_customer_neq := ' AND CUSTOMER_ID NOT IN ('||substr(v_ar_customer_neq,1,length(v_ar_customer_neq)-1)||') ';
End If;

If v_ar_source_eq is not null then
   v_ar_source_eq := ' AND ('||substr(v_ar_source_eq,1,length(v_ar_source_eq)-4)||')';
End IF;

If v_ar_source_neq is not null then
   v_ar_source_neq := ' AND NOT ('||substr(v_ar_source_neq,1,length(v_ar_source_neq)-4)||')';
End IF;

If v_ar_trxtype_eq is not null then
   v_ar_trxtype_eq := ' AND ('||substr(v_ar_trxtype_eq,1,length(v_ar_trxtype_eq)-4)||')';
End If;

If v_ar_trxtype_neq is not null then
   v_ar_trxtype_neq := ' AND  NOT ('||substr(v_ar_trxtype_neq,1,length(v_ar_trxtype_neq)-4)||')';
End If;

If v_opunit_eq is not null then
   v_opunit_eq := ' and org_id '||v_opunit_eq||')';
End If;
If v_opunit_neq is not null then
   v_opunit_neq := ' and org_id '||v_opunit_neq||')';
End If;

       If p_crit_set.source = 'AP' or p_crit_set.source = 'BOTH' then
          v_ap_where := v_ap_invtype_eq||v_ap_invtype_neq||v_ap_source_eq||v_ap_source_neq||
                          v_ap_supplier_eq||v_ap_supplier_neq||v_opunit_eq||v_opunit_neq;
       End if;
       If p_crit_set.source = 'AR' or p_crit_set.source = 'BOTH' then
          v_ar_where := v_ar_customer_eq||v_ar_customer_neq||v_ar_source_eq||v_ar_source_neq||
                          v_ar_trxtype_eq||v_ar_trxtype_neq||v_opunit_eq||v_opunit_neq;
       End If;

END GENERATE_DYN_WHERE_CLAUSE;




/* GET_WHERE_CLAUSE is unique only to the FORECAST hedge project.  This procedure
   requires an associated hedge number to generate the assocaited query */
FUNCTION GET_WHERE_CLAUSE(P_HEDGE_NO IN NUMBER) RETURN VARCHAR2 IS
   v_where VARCHAR2(32000) := ' WHERE 1=1 ';
   v_ar_where    VARCHAR2(32000);
   v_ap_where    VARCHAR2(32000);
   p_crit_set    CRITERIA_SET_REC_TYPE;


cursor hedge_dtls(hedge_no in NUMBER) is
select company_code, hedge_currency
from xtr_hedge_attributes
where hedge_attribute_id = hedge_no;

l_company  XTR_PARTY_INFO.PARTY_CODE%TYPE;
l_currency XTR_MASTER_CURRENCIES.CURRENCY%TYPE;

cursor source(hedge_no in NUMBER) is
select from_value
from xtr_hedge_criteria
where hedge_attribute_id = hedge_no
and criteria_type = 'BASIC'
and criteria_code = 'ITEM_SOURCE';

l_source XTR_HEDGE_CRITERIA.FROM_VALUE%TYPE;

cursor basic_crit(hedge_no in NUMBER) is
--select from_value, to_value
select fnd_date.canonical_to_date(from_value), fnd_date.canonical_to_date(to_value)
from xtr_hedge_criteria
where hedge_attribute_id = hedge_no
and criteria_type = 'BASIC'
and criteria_code = 'TRX_DATES';

--l_from_value XTR_HEDGE_CRITERIA.FROM_VALUE%TYPE;
--l_to_value   XTR_HEDGE_CRITERIA.TO_VALUE%TYPE;

l_from_value DATE;
l_to_value   DATE;

cursor adv_crit(hedge_no in NUMBER) is
select criteria_code,operator,from_value
from xtr_hedge_criteria
where criteria_type = 'ADVANCED'
and hedge_attribute_id = hedge_no;

Begin
     open  hedge_dtls(P_HEDGE_NO);
     fetch hedge_dtls into l_company, l_currency;
     close hedge_dtls;
     open  source(P_HEDGE_NO);
     fetch source into l_source;
     close source;
     open  basic_crit(P_HEDGE_NO);
     fetch basic_crit into l_from_value, l_to_value;
     close basic_crit;
      v_where := v_where||' And Company_Code  = '''||replace(l_company,'''','''''') ||'''';
      v_where := v_where||' And Currency_Code = '''||replace(l_currency,'''','''''')||'''';
      v_where := v_where||' AND (trx_date >= '''
            ||l_from_value
            ||''' AND trx_date <= '''
            ||l_to_value
            ||''')';

     p_crit_set.company_code := l_company;
     p_crit_set.currency     := l_currency;
     p_crit_set.source       := l_source;

     p_crit_set.condition_count := 0;
     for rec in adv_crit(p_hedge_no) loop
        p_crit_set.item(p_crit_set.condition_count) := rec.criteria_code;
        p_crit_set.condition(p_crit_set.condition_count) := rec.operator;
        p_crit_set.value(p_crit_set.condition_count) := rec.from_value;

        p_crit_set.condition_count := p_crit_set.condition_count+1;

     end loop;

     GENERATE_DYN_WHERE_CLAUSE(p_crit_set,v_ar_where,v_ap_where);


       If l_source = 'AP' then
          v_where := v_where||v_ap_where;
       Elsif l_source = 'AR' then
          v_where := v_where||v_ar_where;
       end if;

   RETURN (v_where);

END GET_WHERE_CLAUSE;

FUNCTION GET_SOURCE_CODE(P_HEDGE_NO IN NUMBER) RETURN VARCHAR2 IS

cursor source(hedge_no in NUMBER) is
select st.source_code
from   xtr_hedge_criteria hc,
       xtr_source_types st
where  hedge_attribute_id =  hedge_no
and    hc.from_value 	  =  st.source_code
and    criteria_type 	  =  'BASIC'
and    criteria_code 	  =  'ITEM_SOURCE';

l_source_code XTR_SOURCE_TYPES.SOURCE_CODE%TYPE;

BEGIN
   open  source(P_HEDGE_NO);
   fetch source into l_source_code;
   close source;

   RETURN(l_source_code);

END GET_SOURCE_CODE;

FUNCTION GET_REQUEST_STATUS(P_REQUEST_ID IN NUMBER) RETURN VARCHAR2 IS

   call_status  boolean;
   rphase       varchar2(30);
   rstatus      varchar2(30);
   dphase       varchar2(30);
   dstatus      varchar2(30);
   message      varchar2(240);
   l_request_id NUMBER(15);

BEGIN
   l_request_id := P_REQUEST_ID;
   call_status := FND_CONCURRENT.GET_REQUEST_STATUS(l_request_id, '', '',
                                     rphase,rstatus,dphase,dstatus, message);
   return(dphase);

END GET_REQUEST_STATUS;




/* MINIMUM_DEFAULT is a procedure to ensure that loaded criteria sets have
   at least the bare bones minimum data
*/
PROCEDURE MINIMUM_DEFAULT(p_crit_set IN OUT NOCOPY CRITERIA_SET_REC_TYPE) IS
BEGIN

  if (p_crit_set.currency is null) then
    SELECT PARAM_VALUE
    INTO   p_crit_set.currency
    FROM   xtr_pro_param
    WHERE  param_name = 'SYSTEM_FUNCTIONAL_CCY';
    p_crit_set.currency := nvl(p_crit_set.currency,'USD');
  end if;

  p_crit_set.source   := nvl(p_crit_set.source  ,'AR');
  p_crit_set.factor   := nvl(p_crit_set.factor  ,'1');
  p_crit_set.ar_unpld := nvl(p_crit_set.ar_unpld,'N');
  p_crit_set.ap_unpld := nvl(p_crit_set.ap_unpld,'N');
  if (p_crit_set.source <> 'AR') then
    p_crit_set.discount := nvl(p_crit_set.discount,'NONE');
  end if;
  p_crit_set.condition_count := nvl(p_crit_set.condition_count, 0);
END MINIMUM_DEFAULT;


/* Generate_common_date_clause reduces errors by consolidating the shared piece
   of code that is common to building the date where clause
*/
PROCEDURE GENERATE_COMMON_DATE_CLAUSE(p_crit_set CRITERIA_SET_REC_TYPE,
                                      v_due_date_ar_and IN OUT NOCOPY VARCHAR2,
                                      v_due_date_ap_and IN OUT NOCOPY VARCHAR2) IS
  v_date_comparer VARCHAR2(80);
BEGIN
  If p_crit_set.discount='MAX' then
    v_date_comparer := 'Max_Discounted_Date';
  elsif p_crit_set.discount='MIN' then
    v_date_comparer := 'Min_Discounted_Date';
  else
    v_date_comparer := 'Min_Due_Date';
  end if;

	-- v_due_date_ar_and is for AR
	If p_crit_set.DUE_DATE_FROM IS NOT NULL AND p_crit_set.DUE_DATE_TO IS NOT NULL then
		 v_due_date_ar_and := ' AND (min_due_date is null OR min_due_date >= to_date('''
					||p_crit_set.DUE_DATE_FROM
					||''',''RRRR/MM/DD'') AND min_due_date <= to_date('''
					||p_crit_set.DUE_DATE_TO
					||''',''RRRR/MM/DD''))';
	Elsif p_crit_set.DUE_DATE_FROM IS NOT NULL AND p_crit_set.DUE_DATE_TO IS NULL then
		 v_due_date_ar_and := ' AND (min_due_date is null OR min_due_date >= to_date('''
					||p_crit_set.DUE_DATE_FROM
					||''',''RRRR/MM/DD''))';
	Elsif p_crit_set.DUE_DATE_FROM IS NULL AND p_crit_set.DUE_DATE_TO IS NOT NULL then
		 v_due_date_ar_and := ' AND (min_due_date is null OR min_due_date <= to_date('''
					||p_crit_set.DUE_DATE_TO
					||''',''RRRR/MM/DD''))';
	Else
		 v_due_date_ar_and := ' AND (1=1) ';
	End If;

	-- v_due_date_ap_and is for AP
	If p_crit_set.DUE_DATE_FROM IS NOT NULL AND p_crit_set.DUE_DATE_TO IS NOT NULL then
		 v_due_date_ap_and := ' AND ('||v_date_comparer||' is null OR '||v_date_comparer||' >= to_date('''
					||p_crit_set.DUE_DATE_FROM
					||''',''RRRR/MM/DD'') AND '||v_date_comparer||' <= to_date('''
					||p_crit_set.DUE_DATE_TO
					||''',''RRRR/MM/DD''))';
	Elsif p_crit_set.DUE_DATE_FROM IS NOT NULL AND p_crit_set.DUE_DATE_TO IS NULL then
		 v_due_date_ap_and := ' AND ('||v_date_comparer||' is null OR '||v_date_comparer||' >= to_date('''
					||p_crit_set.DUE_DATE_FROM
					||''',''RRRR/MM/DD''))';
	Elsif p_crit_set.DUE_DATE_FROM IS NULL AND p_crit_set.DUE_DATE_TO IS NOT NULL then
		 v_due_date_ap_and := ' AND ('||v_date_comparer||' is null OR '||v_date_comparer||' <= to_date('''
					||p_crit_set.DUE_DATE_TO
					||''',''RRRR/MM/DD''))';
	Else
		 v_due_date_ap_and := ' AND (1=1) ';
	End If;

END GENERATE_COMMON_DATE_CLAUSE;



/* Generate_query_from_details is the procedure called from the find positions form
   This generates a query from the details provided in the criteria_set_rec_type
   p_crit_set.criteria_set value is ignored in this procedure and has no meaning.
   This code was essentially extracted from the FIND_ARAP forms procedure
*/
PROCEDURE GENERATE_QUERY_FROM_DETAILS(p_crit_set CRITERIA_SET_REC_TYPE, p_query OUT NOCOPY VARCHAR2,
                                      p_where OUT NOCOPY VARCHAR2,
                                      p_where1 OUT NOCOPY VARCHAR2,
                                      p_where2 OUT NOCOPY VARCHAR2) IS
     v_select Varchar2(5000) := 'Select company_code company, sob_currency_code sob_curreny, k.meaning source, sum(amount) amount from ';
     v_select1 Varchar2(10000) :=
     'Select company_code, sob_currency_code sob_currency, k.meaning source, sum( '
      ||' decode( '
      ||' nvl('
      ||''''
      ||p_crit_set.Discount
      ||''''
      ||', ''NONE''), '
      ||' ''NONE'', Amount, '
      ||' ''MAX'', Max_Discounted_Amount, '
      ||' ''MIN'', Min_Discounted_Amount '
      ||')'
      ||') amount from ';
     v_tablename1 Varchar2(200) := ' xtr_ar_open_trx_v, fnd_lookups k '; --If modified, do not forget
     v_tablename2 Varchar2(200) := ' xtr_ap_open_trx_v, fnd_lookups k '; --to modify code in body as well
     v_where Varchar2(5000)  := ' Where k.lookup_type = ''XTR_HEDGE_SOURCES'' ';
     v_ar_where Varchar2(5000);
     v_ap_where Varchar2(5000);
     v_and Varchar2(15000)    := ' And k.lookup_code = ';
     v_and1 Varchar2(15000);
     v_and2 Varchar2(15000);
     v_due_date_ar_and Varchar2(2000);
     v_due_date_ap_and Varchar2(2000);
     v_group Varchar2(15000) :=  ' Group by company_code,sob_currency_code,k.meaning ';
     v_order Varchar2(15000) :=  ' Order by 1,2,3,4 ';
     v_query Varchar2(32000);
     v_both  Char(1) := 'N';
     v_and1_flag Char(1) := 'N';
     v_org_flag Char(1);

  v_company             VARCHAR2(7);
  v_source              VARCHAR2(80);
  v_amount              NUMBER;
  v_date_comparer       VARCHAR2(80):='min_due_date';

  source_cursor      INTEGER;
  destination_cursor INTEGER;
  ignore             INTEGER;
  native constant    INTEGER := 1;

   dec_pos NUMBER;
   l_ar_tot NUMBER;
   l_ap_tot NUMBER;
   l_tot1   NUMBER;

BEGIN
       if (p_crit_set.ar_unpld = 'N') then
          v_tablename1:=' xtr_ar_open_apld_trx_v, fnd_lookups k ';
       end if;
       if (p_crit_set.ap_unpld = 'N') then
          v_tablename2:=' xtr_ap_open_apld_trx_v, fnd_lookups k ';
       end if;
       If p_crit_set.Source = 'AR' then
          v_select := v_select||v_tablename1;
          v_and    := v_and||'''AR''';
       Elsif p_crit_set.Source = 'AP' then
          v_select := v_select1||v_tablename2;
          v_and    := v_and||'''AP''';
       Else
          v_both   := 'Y';
          v_and1   := v_and||'''AR''';
          v_and2   := v_and||'''AP''';
       End if;

      GENERATE_COMMON_DATE_CLAUSE(p_crit_set,v_due_date_ar_and,v_due_date_ap_and);

      if nvl(p_crit_set.ar_unpld,'N') = 'N' then
         v_due_date_ar_and := v_due_date_ar_and || ' AND APPLIED_TRX=''Y'' ';
      end if;
      if nvl(p_crit_set.ap_unpld,'N') = 'N' then
         v_due_date_ap_and := v_due_date_ap_and || ' AND APPLIED_TRX=''Y'' ';
      end if;


       If v_both = 'N'  then
          v_and := v_and||' And Currency_Code = '''||replace(p_crit_set.currency,'''','''''')||'''';
          If p_crit_set.Company_Code is not null then
             v_and := v_and||' And Company_Code = '''||replace(p_crit_set.company_code,'''','''''')||'''';
          End if;
          if p_crit_set.sob_currency is not null then
             v_and := v_and||' And sob_currency_code = '''||replace(p_crit_set.sob_currency,'''','''''')||'''';
          end if;
--        v_and := v_and||v_due_date_and;

       Else
             v_and1 := v_and1||' and Currency_Code = '''||replace(p_crit_set.currency,'''','''''')||'''';
             v_and2 := v_and2||' and Currency_Code = '''||replace(p_crit_set.currency,'''','''''')||'''';

             If p_crit_set.Company_Code is not null then
                v_and1 := v_and1||' And Company_Code = '''||replace(p_crit_set.company_code,'''','''''')||'''';
                v_and2 := v_and2||' And Company_Code = '''||replace(p_crit_set.company_Code,'''','''''')||'''';
             End if;
             if p_crit_set.sob_currency is not null then
                v_and1 := v_and1||' And Sob_currency_code = '''||replace(p_crit_set.sob_currency,'''','''''')||'''';
                v_and2 := v_and2||' And Sob_currency_code = '''||replace(p_crit_set.sob_currency,'''','''''')||'''';
             end if;

--           v_and1 := v_and1||v_due_date_and;
--           v_and2 := v_and2||v_due_date_and;
       End if;



       GENERATE_DYN_WHERE_CLAUSE(p_crit_set,v_ar_where,v_ap_where);


       if p_crit_set.source = 'AR' then
          v_and := v_and||v_due_date_ar_and||v_ar_where;
       elsif p_crit_set.source = 'AP' then
          v_and := v_and||v_due_date_ap_and||v_ap_where;
       else
          v_and1 := v_and1||v_due_date_ar_and||v_ar_where;
          v_and2 := v_and2||v_due_date_ap_and||v_ap_where;
       end if;

       If v_both = 'N' then
          p_query  := v_Select||v_where||v_and||v_group||v_order;
          p_where := substr(v_and, instr(v_and, ' Currency_Code'));
       Else
          p_query := v_Select||v_tablename1||v_where||v_and1||v_group||' union '||
                     v_Select1||v_tablename2||v_where||v_and2||v_group||v_order;
          p_where1 := substr(v_and1, instr(v_and1, ' Currency_Code'));
          p_where2 := substr(v_and2, instr(v_and2, ' Currency_Code'));
       End if;


END GENERATE_QUERY_FROM_DETAILS;




/* GET_HOAPR_REPORT_PARAMETERS is the procedure called from the
   position - outstanding receivables / payables report.
   It takes a criteria set and returns a where clause for the AR table
   and the AP table and the respective tables to pull the information from.
   p_crit_set.criteria_set value is ignored in this procedure and has no meaning.
   This code was essentially extracted from the FIND_ARAP forms procedure
*/
PROCEDURE GET_HOAPR_REPORT_PARAMETERS(p_criteria_set_name VARCHAR2,
                                      p_criteria_set_owner VARCHAR2,
                                      p_source          IN OUT NOCOPY xtr_hedge_criteria.from_value%TYPE,
                                      p_currency        IN OUT NOCOPY xtr_hedge_criteria.from_value%TYPE,
                                      p_company_code    IN OUT NOCOPY xtr_hedge_criteria.from_value%TYPE,
                                      p_sob_currency    IN OUT NOCOPY xtr_hedge_criteria.from_value%TYPE,
                                      p_discount        IN OUT NOCOPY xtr_hedge_criteria.from_value%TYPE,
                                      p_factor          IN OUT NOCOPY xtr_hedge_criteria.from_value%TYPE,
                                      p_due_date_from   IN OUT NOCOPY xtr_hedge_criteria.from_value%TYPE,
                                      p_due_date_to     IN OUT NOCOPY xtr_hedge_criteria.to_value%TYPE,
                                      p_ar_unpld        IN OUT NOCOPY xtr_hedge_criteria.from_value%TYPE,
                                      p_ap_unpld        IN OUT NOCOPY xtr_hedge_criteria.from_value%TYPE,
                                      p_ar_from  OUT NOCOPY VARCHAR2,
                                      p_ap_from  OUT NOCOPY VARCHAR2,
                                      p_ar_where OUT NOCOPY VARCHAR2,
                                      p_ap_where OUT NOCOPY VARCHAR2) IS

p_crit_set          CRITERIA_SET_REC_TYPE;
v_date_comparer     VARCHAR2(80);
v_due_date_ar_and   VARCHAR2(250);
v_due_date_ap_and   VARCHAR2(250);
v_dyn_ar_where      VARCHAR2(15000);
v_dyn_ap_where      VARCHAR2(15000);
n_dummy             NUMBER;


BEGIN

  if (p_criteria_set_name is not null) then
    select count(*)
    into   n_dummy
    from   xtr_hedge_criteria
    where  criteria_set = p_criteria_set_name
    and    criteria_set_owner = p_criteria_set_owner;

    if (n_dummy > 0) then
      p_crit_set.criteria_set_owner := p_criteria_set_owner;
    end if;

    p_crit_set.criteria_set := p_criteria_set_name;
    load_criteria_set(p_crit_set);
  end if;
  p_crit_set.source          := nvl(p_source       ,p_crit_set.source);
  p_crit_set.currency        := nvl(p_currency     ,p_crit_set.currency);
  p_crit_set.company_code    := nvl(p_company_code ,p_crit_set.company_code);
  p_crit_set.sob_currency    := nvl(p_sob_currency ,p_crit_set.sob_currency);
  p_crit_set.discount        := nvl(p_discount     ,p_crit_set.discount);
  p_crit_set.factor          := nvl(p_factor       ,p_crit_set.factor);
  p_crit_set.due_date_from   := nvl(p_due_date_from,p_crit_set.due_date_from);
  p_crit_set.due_date_to     := nvl(p_due_date_to  ,p_crit_set.due_date_to  );
  p_crit_set.ar_unpld        := nvl(p_ar_unpld     ,p_crit_set.ar_unpld);
  p_crit_set.ap_unpld        := nvl(p_ar_unpld     ,p_crit_set.ap_unpld);

  MINIMUM_DEFAULT(p_crit_set);

  p_source        := p_crit_set.source;
  p_currency      := p_crit_set.currency;
  p_company_code  := p_crit_set.company_code;
  p_sob_currency  := p_crit_set.sob_currency;
  p_discount      := p_crit_set.discount;
  p_factor        := p_crit_set.factor;
  p_due_date_from := p_crit_set.due_date_from;
  p_due_date_to   := p_crit_set.due_date_to;
  p_ar_unpld      := p_crit_set.ar_unpld;
  p_ap_unpld      := p_crit_set.ap_unpld;


  if (p_crit_set.ar_unpld='Y') then
    p_ar_from := 'XTR_AR_OPEN_TRX_V';
  else
    p_ar_from := 'XTR_AR_OPEN_APLD_TRX_V';
  end if;

  if (p_crit_set.ap_unpld='Y') then
    p_ap_from := 'XTR_AP_OPEN_TRX_V';
  else
    p_ap_from := 'XTR_AP_OPEN_APLD_TRX_V';
  end if;

  if (p_crit_set.source not in ('AR','BOTH')) then
    p_ar_from := 'XTR_AR_OPEN_APLD_TRX_V';
    p_ar_where := ' AND 1=2 ';
  end if;

  if (p_crit_set.source not in ('AP','BOTH')) then
    p_ap_from := 'XTR_AP_OPEN_APLD_TRX_V';
    p_ap_where := ' AND 1=2 ';
  end if;

  GENERATE_COMMON_DATE_CLAUSE(p_crit_set,v_due_date_ar_and,v_due_date_ap_and);

	p_ar_where := p_ar_where||' and Currency_Code = '''||replace(p_crit_set.currency,'''','''''')||'''';
	p_ap_where := p_ap_where||' and Currency_Code = '''||replace(p_crit_set.currency,'''','''''')||'''';

	If p_crit_set.Company_Code is not null then
		p_ar_where := p_ar_where||' And Company_Code = '''||replace(p_crit_set.company_code,'''','''''')||'''';
		p_ap_where := p_ap_where||' And Company_Code = '''||replace(p_crit_set.company_Code,'''','''''')||'''';
	End if;
	if p_crit_set.sob_currency is not null then
		p_ar_where := p_ar_where||' And Sob_currency_code = '''||replace(p_crit_set.sob_currency,'''','''''')||'''';
		p_ap_where := p_ap_where||' And Sob_currency_code = '''||replace(p_crit_set.sob_currency,'''','''''')||'''';
	end if;


  GENERATE_DYN_WHERE_CLAUSE(p_crit_set,v_dyn_ar_where,v_dyn_ap_where);

  p_ar_where := p_ar_where||v_due_date_ar_and||v_dyn_ar_where;
  p_ap_where := p_ap_where||v_due_date_ap_and||v_dyn_ap_where;

END GET_HOAPR_REPORT_PARAMETERS;


/* SAVE_CRITERIA_SET takes in a criteria_set_rec_type and saves the information
   into the table.
   1) if no set name is specified, raise an exception
   2) if name matches already used name, load, retain, and use creator id and created date
         delete all rows that belong to the matching set
   3) For every non null criteria add a row into xtr_hedge_criteria
      Note: date is saved relative to system date.
*/
PROCEDURE SAVE_CRITERIA_SET(p_crit_set CRITERIA_SET_REC_TYPE) IS

v_user_id     NUMBER := FND_GLOBAL.user_id;
v_date        DATE   := sysdate;
v_log_in_id   NUMBER := FND_GLOBAL.login_id;
v_create_id   NUMBER;
v_create_date DATE;

cursor get_old_set_info(p_criteria_set varchar2,p_criteria_set_owner number) is
select created_by,creation_date
from   xtr_hedge_criteria
where  criteria_set = p_criteria_set
and    (criteria_set_owner = p_criteria_set_owner
        or (criteria_set_owner is null
            and p_criteria_set_owner is null
           )
       );


  PROCEDURE ADD_CRITERIA(p_type in VARCHAR2,
                         p_code in VARCHAR2,
                         p_operator in VARCHAR2,
                         p_from in VARCHAR2,
                         p_to in VARCHAR2 default NULL) IS
  BEGIN
    if (p_from is not null) then
      insert into xtr_hedge_criteria(hedge_criteria_id,
                                     criteria_type,
                                     criteria_code,
                                     operator,
                                     from_value,
                                     to_value,
                                     created_by,
                                     creation_date,
                                     last_updated_by,
                                     last_update_date,
                                     last_update_login,
                                     criteria_set,
                                     criteria_set_owner)
      values(xtr_hedge_criteria_s.nextval,
             p_type,
             p_code,
             p_operator,
             p_from,
             p_to,
             v_create_id,
             v_create_date,
             v_user_id,
             v_date,
             v_log_in_id,
             p_crit_set.criteria_set,
             p_crit_set.criteria_set_owner);
    end if;
  END;

BEGIN
  if (p_crit_set.criteria_set is null) then
    raise e_invalid_criteria_set;
  end if;

  open get_old_set_info(p_crit_set.criteria_set,p_crit_set.criteria_set_owner);
  fetch get_old_set_info into v_create_id,v_create_date;
  if (get_old_set_info%FOUND) then

    DELETE_CRITERIA_SET(p_crit_set);

  else

    v_create_id := v_user_id;
    v_create_date := v_date;

  end if;
  close get_old_set_info;

  CHECK_ADV_CRIT_SET_CONSISTENCY(p_crit_set);

  ADD_CRITERIA('BASIC','ITEM_SOURCE','=',p_crit_set.source);
  ADD_CRITERIA('BASIC','CURRENCY','=',p_crit_set.currency);
  ADD_CRITERIA('BASIC','COMPANY_CODE','=',p_crit_set.company_code);
  ADD_CRITERIA('BASIC','SOB_CURRENCY','=',p_crit_set.sob_currency);
  ADD_CRITERIA('BASIC','DISCOUNT','=',p_crit_set.discount);
  ADD_CRITERIA('BASIC','FACTOR','=',p_crit_set.factor);

  ADD_CRITERIA('BASIC','TRX_DATES','BETWEEN',to_date(p_crit_set.due_date_from,'RRRR/MM/DD')-trunc(sysdate),to_date(p_crit_set.due_date_to,'RRRR/MM/DD')-trunc(sysdate));
  ADD_CRITERIA('BASIC','AR_UNPLD','=',p_crit_set.ar_unpld);
  ADD_CRITERIA('BASIC','AP_UNPLD','=',p_crit_set.ap_unpld);

  for i in 0..p_crit_set.condition_count - 1 loop
    ADD_CRITERIA('ADVANCED',p_crit_set.item(i),p_crit_set.condition(i),p_crit_set.value(i));
  end loop;

END SAVE_CRITERIA_SET;

/* LOAD_CRITERIA_SET works in the opposite manner as SAVE_CRITERIA_SET
   This time, the procedure is given a set name and owner and uses that
   information to load all the details from xtr_hedge_criteria
*/
PROCEDURE LOAD_CRITERIA_SET(p_crit_set IN OUT NOCOPY CRITERIA_SET_REC_TYPE) IS

v_dummy xtr_hedge_criteria.to_value%type;
i Number;

cursor get_advanced_criteria is
select criteria_code,operator,from_value
from   xtr_hedge_criteria
where  criteria_type='ADVANCED'
and    criteria_set = p_crit_set.criteria_set
and    (criteria_set_owner = p_crit_set.criteria_set_owner
        or (criteria_set_owner is null
            and p_crit_set.criteria_set_owner is null
           )
       );

cursor get_basic_criteria(p_criteria_code VARCHAR2) is
select from_value,to_value
from   xtr_hedge_criteria
where  criteria_type = 'BASIC'
and    criteria_code = p_criteria_code
and    criteria_set = p_crit_set.criteria_set
and    (criteria_set_owner = p_crit_set.criteria_set_owner
        or (criteria_set_owner is null
            and p_crit_set.criteria_set_owner is null
           )
       );

  PROCEDURE LOAD_BASIC_CRITERIA(p_code in VARCHAR2,
                                p_from out NOCOPY VARCHAR2,
                                p_to out NOCOPY VARCHAR2) IS
  BEGIN
    open get_basic_criteria(p_code);
    fetch get_basic_criteria into p_from,p_to;
    close get_basic_criteria;
  END;

BEGIN
  if (p_crit_set.criteria_set is null) then
    raise e_invalid_criteria_set;
  end if;

  LOAD_BASIC_CRITERIA('ITEM_SOURCE',p_crit_set.source,v_dummy);
  LOAD_BASIC_CRITERIA('CURRENCY',p_crit_set.currency,v_dummy);
  LOAD_BASIC_CRITERIA('COMPANY_CODE',p_crit_set.company_code,v_dummy);
  LOAD_BASIC_CRITERIA('SOB_CURRENCY',p_crit_set.sob_currency,v_dummy);
  LOAD_BASIC_CRITERIA('DISCOUNT',p_crit_set.discount,v_dummy);
  LOAD_BASIC_CRITERIA('FACTOR',p_crit_set.factor,v_dummy);
  LOAD_BASIC_CRITERIA('TRX_DATES',p_crit_set.due_date_from,p_crit_set.due_date_to);
  p_crit_set.due_date_from := to_char(p_crit_set.due_date_from + trunc(sysdate),'RRRR/MM/DD');
  p_crit_set.due_date_to := to_char(p_crit_set.due_date_to + trunc(sysdate),'RRRR/MM/DD');
  LOAD_BASIC_CRITERIA('AR_UNPLD',p_crit_set.ar_unpld,v_dummy);
  LOAD_BASIC_CRITERIA('AP_UNPLD',p_crit_set.ap_unpld,v_dummy);
  i:=0;
  for r in get_advanced_criteria loop
    p_crit_set.item(i):=r.criteria_code;
    p_crit_set.condition(i):=r.operator;
    p_crit_set.value(i):=r.from_value;
    i := i+1;
  end loop;
  p_crit_set.condition_count := i;

  MINIMUM_DEFAULT(p_crit_set);

END LOAD_CRITERIA_SET;




/* DELETE_CRITERIA_SET removes all rows from xtr_hedge_criteria
   that match the set name and owner
*/
PROCEDURE DELETE_CRITERIA_SET(p_crit_set CRITERIA_SET_REC_TYPE) IS
BEGIN
  DELETE xtr_hedge_criteria
  WHERE  criteria_set = p_crit_set.criteria_set
  AND    (
          criteria_set_owner = p_crit_set.criteria_set_owner
          or
          (
           criteria_set_owner is null
           and
           p_crit_set.criteria_set_owner is null
          )
         );

END DELETE_CRITERIA_SET;

END   XTR_HEDGE_PROCESS_P;


/
