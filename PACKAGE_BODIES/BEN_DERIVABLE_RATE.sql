--------------------------------------------------------
--  DDL for Package Body BEN_DERIVABLE_RATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DERIVABLE_RATE" as
/* $Header: bendrvrt.pkb 120.0 2005/05/28 04:13:54 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
        Derivable Factor Rate
Purpose
        This package is used to handle setting of Derivable Factor Applies Rate Flag based on
        data changes that have occurred on child component tables.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        07-Mar-2000      KMahendr   115.0      Created.
        23-Mar-2000      gperry     115.1      Added support for coverages and
                                               premiums.
        11-Apr-2000      mmogel     115.2      Added tokens to messages to make
                                               them more meaningful to the user
        04-Jan-2001      RCHASE     115.3      Bug 1568561. Fix NDS Create calls in
                                               rate_prfl_handler, missing parens
                                               around or exists conditions.
                                               Also, fixed c1 cursor in
                                               derivable_rate_handler to include
                                               premium and coverage calcs when
                                               a derivable factor is attached to
                                               and existing variable rate profile.
       10-Jun-2002       kmahendr   115.4      Bug#2410546 - syntax error in dynamic sql
                                               corrected.
       11-Jun-2002       kmahendr   115.5      Commit statement added.
       05-May-2003       kmahendr   115.6      Bug#2939392 - dynamic sql is modified to take
                                               binary variables.
       04-Feb-2004      vvprabhu   115.7       Bug 3431740 Parameter p_oracle_schema added
                                               to cursor c1 in rate_prfl_handler,
                                               the value is got by the
       				               call to fnd_installation.get_app_info
       15-Feb-2004      vvprabhu   115.8       Initialized l_application_short_name to BEN
       04-Jun-2004      abparekh   115.9       Bug : 3667163 - Corrected number of arguments
                                               in call to execute immediate in RATE_PRFL_HANDLER


*/
--------------------------------------------------------------------------------
g_package varchar2(80) := 'ben_derivable_rate.';
--
procedure rate_prfl_handler
  (p_event                       in  varchar2,
   p_table_name                  in  varchar2,
   p_col_name                    in  varchar2,
   p_col_id                      in  number)is
  --
  l_proc        varchar2(80) := g_package||'rate prfl handler';
  l_strg        varchar2(32000) ;
  l_dummy       varchar2(1);
  l_status			varchar2(1);
  l_industry			varchar2(1);
  l_application_short_name	varchar2(30) := 'BEN';
  l_oracle_schema		varchar2(30);
  l_return                      boolean;

  --
   cursor c1 (p_tab_name varchar2, p_col_name varchar2,p_oracle_schema varchar2) is
    select null
    from   all_tab_columns
    where  table_name = upper(p_tab_name)
    and    column_name = upper(p_col_name)
    and    owner = upper(p_oracle_schema);

  --
begin
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  --
  -- Parameter validation
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'event',
                             p_argument_value => p_event);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'table_name',
                             p_argument_value => p_table_name);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'column name',
                             p_argument_value => p_col_name);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'column_id',
                             p_argument_value => p_col_id);
  --
  -- Bug 3431740 Parameter p_oracle_schema added to cursor c1, the value is got by the
  -- following call
  l_return := fnd_installation.get_app_info(application_short_name => l_application_short_name,
            		                    status                 => l_status,
                        	            industry               => l_industry,
                                      	    oracle_schema          => l_oracle_schema);
  open c1(p_table_name, p_col_name, l_oracle_schema );
  fetch c1 into l_dummy;
  if c1%notfound then
    close c1;
    fnd_message.set_name('BEN','BEN_93388_NO_TAB_COL');
    fnd_message.raise_error;
  end if;
  close c1;

  --
  -- Check operation is valid
  --
  if p_event not in ('CREATE','DELETE') then
    --
    fnd_message.set_name('BEN','BEN_92466_EVENT_HANDLER');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('EVENT',p_event);
    fnd_message.raise_error;
    --
  end if;
  --
  if p_event = 'CREATE' then
    --
    -- rchase bug 1568561 - paren pair addition around ors
    --
    l_strg := 'update '||p_table_name||'  set drvbl_fctr_apls_rts_flag = :1
               where '||p_col_name|| '= :2 and
               drvbl_fctr_apls_rts_flag = :3
                and (
                   exists (select null
                           from   ben_age_rt_f art,
                                  ben_acty_base_rt_f abr,
                                  ben_acty_vrbl_rt_f avr
                           where  abr.'||p_col_name||'= :4
                            and    abr.acty_base_rt_id = avr.acty_base_rt_id
                           and    avr.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id)  or
                   exists (select null
                           from   ben_cmbn_age_los_rt_f cmr,
                                  ben_acty_base_rt_f abr,
                                  ben_acty_vrbl_rt_f avr
                           where  abr.'||p_col_name||'= :5
                           and    abr.acty_base_rt_id = avr.acty_base_rt_id
                           and    avr.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id)  or
                   exists (select null
                           from   ben_comp_lvl_rt_f clr,
                                  ben_acty_base_rt_f abr,
                                  ben_acty_vrbl_rt_f avr
                           where  abr.'||p_col_name||'= :6
                           and    abr.acty_base_rt_id = avr.acty_base_rt_id
                           and    avr.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id)  or
                   exists (select null
                           from   ben_hrs_wkd_in_perd_rt_f hwr,
                                  ben_acty_base_rt_f abr,
                                  ben_acty_vrbl_rt_f avr
                           where  abr.'||p_col_name||'= :7
                            and    abr.acty_base_rt_id = avr.acty_base_rt_id
                           and    avr.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id)  or
                   exists (select null
                           from   ben_los_rt_f lsr,
                                  ben_acty_base_rt_f abr,
                                  ben_acty_vrbl_rt_f avr
                           where  abr.'||p_col_name||'= :8
                           and    abr.acty_base_rt_id = avr.acty_base_rt_id
                           and    avr.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id)  or
                   exists (select null
                           from   ben_pct_fl_tm_rt_f pfr,
                                  ben_acty_base_rt_f abr,
                                  ben_acty_vrbl_rt_f avr
                           where  abr.'||p_col_name||'= :9
                           and    abr.acty_base_rt_id = avr.acty_base_rt_id
                           and    avr.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id))';
     --
     execute immediate l_strg using 'Y',p_col_id,'N',p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id;
     --
     if upper(p_col_name) in ('OIPL_ID','PL_ID') then
       --
       -- Could be a premium rate
       --
       -- rchase bug 1568561 - paren pair addition around ors
       --
       l_strg := 'update '||p_table_name||' set drvbl_fctr_apls_rts_flag = :1
               where '||p_col_name|| '= :2 and
               drvbl_fctr_apls_rts_flag = :3
               and (
                   exists (select null
                           from   ben_age_rt_f art,
                                  ben_actl_prem_f apr,
                                  ben_actl_prem_vrbl_rt_f apv
                           where  apr.'||p_col_name||' = :4
                           and    apr.actl_prem_id = apv.actl_prem_id
                           and    apv.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id)  or
                   exists (select null
                           from   ben_cmbn_age_los_rt_f cmr,
                                  ben_actl_prem_f apr,
                                  ben_actl_prem_vrbl_rt_f apv
                           where  apr.'||p_col_name||'= :5
                           and    apr.actl_prem_id = apv.actl_prem_id
                           and    apv.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id)  or
                   exists (select null
                           from   ben_comp_lvl_rt_f clr,
                                  ben_actl_prem_f apr,
                                  ben_actl_prem_vrbl_rt_f apv
                           where  apr.'||p_col_name||'= :6
                           and    apr.actl_prem_id = apv.actl_prem_id
                           and    apv.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id)  or
                   exists (select null
                           from   ben_hrs_wkd_in_perd_rt_f hwr,
                                  ben_actl_prem_f apr,
                                  ben_actl_prem_vrbl_rt_f apv
                           where  apr.'||p_col_name||'= :7
                           and    apr.actl_prem_id = apv.actl_prem_id
                           and    apv.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id)  or
                   exists (select null
                           from   ben_los_rt_f lsr,
                                  ben_actl_prem_f apr,
                                  ben_actl_prem_vrbl_rt_f apv
                           where  apr.'||p_col_name||'= :8
                           and    apr.actl_prem_id = apv.actl_prem_id
                           and    apv.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id)  or
                   exists (select null
                           from   ben_pct_fl_tm_rt_f pfr,
                                  ben_actl_prem_f apr,
                                  ben_actl_prem_vrbl_rt_f apv
                           where  apr.'||p_col_name||'= :9
                           and    apr.actl_prem_id = apv.actl_prem_id
                           and    apv.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id))';
       --
       execute immediate l_strg using 'Y',p_col_id,'N',p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id;
       --
     end if;
     --
     if upper(p_col_name) in ('OIPL_ID','PL_ID','PLIP_ID') then
       --
       -- Could be a coverage
       --
       l_strg := 'update '||p_table_name||' set drvbl_fctr_apls_rts_flag = :1
               where '||p_col_name|| '= :2 and
               drvbl_fctr_apls_rts_flag = :3
               and (
                   exists (select null
                           from   ben_age_rt_f art,
                                  ben_cvg_amt_calc_mthd_f ccm,
                                  ben_bnft_vrbl_rt_f bvr
                           where  ccm.'||p_col_name||' = :4
                           and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                           and    bvr.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id)  or
                   exists (select null
                           from   ben_cmbn_age_los_rt_f cmr,
                                  ben_cvg_amt_calc_mthd_f ccm,
                                  ben_bnft_vrbl_rt_f bvr
                           where  ccm.'||p_col_name||'= :5
                           and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                           and    bvr.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id)  or
                   exists (select null
                           from   ben_comp_lvl_rt_f clr,
                                  ben_cvg_amt_calc_mthd_f ccm,
                                  ben_bnft_vrbl_rt_f bvr
                           where  ccm.'||p_col_name||'= :6
                           and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                           and    bvr.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id)  or
                   exists (select null
                           from   ben_hrs_wkd_in_perd_rt_f hwr,
                                  ben_cvg_amt_calc_mthd_f ccm,
                                  ben_bnft_vrbl_rt_f bvr
                           where  ccm.'||p_col_name||'= :7
                           and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                           and    bvr.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id)  or
                   exists (select null
                           from   ben_los_rt_f lsr,
                                  ben_cvg_amt_calc_mthd_f ccm,
                                  ben_bnft_vrbl_rt_f bvr
                           where  ccm.'||p_col_name||'= :8
                           and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                           and    bvr.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id)  or
                   exists (select null
                           from   ben_pct_fl_tm_rt_f pfr,
                                  ben_cvg_amt_calc_mthd_f ccm,
                                  ben_bnft_vrbl_rt_f bvr
                           where  ccm.'||p_col_name||'= :9
                           and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                           and    bvr.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id))';
       --
       execute immediate l_strg using 'Y',p_col_id,'N',p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id;
       --
     end if;
     --
  elsif p_event = 'DELETE' then
    --
    l_strg := 'update '||p_table_name||'  set drvbl_fctr_apls_rts_flag = :1
               where '||p_col_name|| '= :2 and
               drvbl_fctr_apls_rts_flag = :3  and
               not exists (select null
                           from   ben_age_rt_f art,
                                  ben_acty_base_rt_f abr,
                                  ben_acty_vrbl_rt_f avr
                           where  abr.'||p_col_name||' = :4
                           and    abr.acty_base_rt_id = avr.acty_base_rt_id
                           and    avr.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id) and
               not exists (select null
                           from   ben_cmbn_age_los_rt_f cmr,
                                  ben_acty_base_rt_f abr,
                                  ben_acty_vrbl_rt_f avr
                           where  abr.'||p_col_name||'= :5
                           and    abr.acty_base_rt_id = avr.acty_base_rt_id
                           and    avr.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id) and
               not exists (select null
                           from   ben_comp_lvl_rt_f clr,
                                  ben_acty_base_rt_f abr,
                                  ben_acty_vrbl_rt_f avr
                           where  abr.'||p_col_name||'= :6
                           and    abr.acty_base_rt_id = avr.acty_base_rt_id
                           and    avr.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id) and
               not exists (select null
                           from   ben_hrs_wkd_in_perd_rt_f hwr,
                                  ben_acty_base_rt_f abr,
                                  ben_acty_vrbl_rt_f avr
                           where  abr.'||p_col_name||'= :7
                           and    abr.acty_base_rt_id = avr.acty_base_rt_id
                           and    avr.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id) and
               not exists (select null
                           from   ben_los_rt_f lsr,
                                  ben_acty_base_rt_f abr,
                                  ben_acty_vrbl_rt_f avr
                           where  abr.'||p_col_name||'= :8
                           and    abr.acty_base_rt_id = avr.acty_base_rt_id
                           and    avr.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id) and
               not exists (select null
                           from   ben_pct_fl_tm_rt_f pfr,
                                  ben_acty_base_rt_f abr,
                                  ben_acty_vrbl_rt_f avr
                           where  abr.'||p_col_name||'= :9
                           and    abr.acty_base_rt_id = avr.acty_base_rt_id
                           and    avr.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id)';
     --
     --
     if upper(p_col_name) in ('OIPL_ID','PL_ID') then
       --
       -- Could be a premium rate
       --
       l_strg := l_strg||' and
               not exists (select null
                           from   ben_age_rt_f art,
                                  ben_actl_prem_f apr,
                                  ben_actl_prem_vrbl_rt_f apv
                           where  apr.'||p_col_name||' = :10
                           and    apr.actl_prem_id = apv.actl_prem_id
                           and    apv.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id) and
               not exists (select null
                           from   ben_cmbn_age_los_rt_f cmr,
                                  ben_actl_prem_f apr,
                                  ben_actl_prem_vrbl_rt_f apv
                           where  apr.'||p_col_name||' = :11
                           and    apr.actl_prem_id = apv.actl_prem_id
                           and    apv.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id) and
               not exists (select null
                           from   ben_comp_lvl_rt_f clr,
                                  ben_actl_prem_f apr,
                                  ben_actl_prem_vrbl_rt_f apv
                           where  apr.'||p_col_name||'= :12
                           and    apr.actl_prem_id = apv.actl_prem_id
                           and    apv.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id) and
               not exists (select null
                           from   ben_hrs_wkd_in_perd_rt_f hwr,
                                  ben_actl_prem_f apr,
                                  ben_actl_prem_vrbl_rt_f apv
                           where  apr.'||p_col_name||'= :13
                           and    apr.actl_prem_id = apv.actl_prem_id
                           and    apv.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id) and
               not exists (select null
                           from   ben_los_rt_f lsr,
                                  ben_actl_prem_f apr,
                                  ben_actl_prem_vrbl_rt_f apv
                           where  apr.'||p_col_name||'= :14
                           and    apr.actl_prem_id = apv.actl_prem_id
                           and    apv.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id) and
               not exists (select null
                           from   ben_pct_fl_tm_rt_f pfr,
                                  ben_actl_prem_f apr,
                                  ben_actl_prem_vrbl_rt_f apv
                           where  apr.'||p_col_name||'= :15
                           and    apr.actl_prem_id = apv.actl_prem_id
                           and    apv.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id)';
       --
     end if;
     --
     if upper(p_col_name) in ('OIPL_ID','PL_ID','PLIP_ID') then
       --
       -- Could be a coverage
       --
       l_strg := l_strg||' and
               not exists (select null
                           from   ben_age_rt_f art,
                                  ben_cvg_amt_calc_mthd_f ccm,
                                  ben_bnft_vrbl_rt_f bvr
                           where  ccm.'||p_col_name||' = :16
                           and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                           and    bvr.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id) and
               not exists (select null
                           from   ben_cmbn_age_los_rt_f cmr,
                                  ben_cvg_amt_calc_mthd_f ccm,
                                  ben_bnft_vrbl_rt_f bvr
                           where  ccm.'||p_col_name||'= :17
                           and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                           and    bvr.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id) and
               not exists (select null
                           from   ben_comp_lvl_rt_f clr,
                                  ben_cvg_amt_calc_mthd_f ccm,
                                  ben_bnft_vrbl_rt_f bvr
                           where  ccm.'||p_col_name||'= :18
                           and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                           and    bvr.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id) and
               not exists (select null
                           from   ben_hrs_wkd_in_perd_rt_f hwr,
                                  ben_cvg_amt_calc_mthd_f ccm,
                                  ben_bnft_vrbl_rt_f bvr
                           where  ccm.'||p_col_name||'= :19
                           and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                           and    bvr.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id) and
               not exists (select null
                           from   ben_los_rt_f lsr,
                                  ben_cvg_amt_calc_mthd_f ccm,
                                  ben_bnft_vrbl_rt_f bvr
                           where  ccm.'||p_col_name||'= :20
                           and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                           and    bvr.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id) and
               not exists (select null
                           from   ben_pct_fl_tm_rt_f pfr,
                                  ben_cvg_amt_calc_mthd_f ccm,
                                  ben_bnft_vrbl_rt_f bvr
                           where  ccm.'||p_col_name||'= :21
                           and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                           and    bvr.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id)';
      --
    end if;
    --
    --Bug : 3667163
    --Wrong number of arguments while calling execute immediate.
    /*
    if upper(p_col_name) =  'PLIP_ID' then -- no check for premium
       execute immediate l_strg using 'N',p_col_id,'Y',p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,
                         p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id;
    else
       hr_utility.set_location('L string'||l_strg,9);
       execute immediate l_strg using 'N',p_col_id,'Y',p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,
                p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,
                p_col_id,p_col_id,p_col_id;
    end if;
    */
    -- Corrected number of arguments in call to execute immediate based on value of p_col_name
    if upper(p_col_name) in ('OIPL_ID','PL_ID') then
       execute immediate l_strg using 'N',p_col_id,'Y',p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,
                p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,
                p_col_id,p_col_id,p_col_id;

    elsif upper(p_col_name) in ('PLIP_ID') then
       execute immediate l_strg using 'N',p_col_id,'Y',p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,
                p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id;
    else
       execute immediate l_strg using 'N',p_col_id,'Y',p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id;
    end if;
    --Bug : 3667163
    --
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc,10);
  --
end rate_prfl_handler;
-----------------------------------------------------------------------
procedure derivable_rate_handler
  (p_event                       in  varchar2,
   p_vrbl_rt_prfl_id             in  number)is
  --
  l_proc        varchar2(80) := g_package||'derivable rate handler';
  --
  cursor c1 is
    select pgm_id,
           pl_id,
           ptip_id,
           plip_id,
           oipl_id
    from   ben_acty_base_rt_f abr,
           ben_acty_vrbl_rt_f avr
    where  avr.vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
    and    avr.acty_base_rt_id = abr.acty_base_rt_id
        -- RCHASE bug 1568561 - added union
    union
    select to_number(null) pgm_id,
           pl_id,
           to_number(null) ptip_id,
           to_number(null) plip_id,
           oipl_id
    from   ben_actl_prem_f apr,
           ben_actl_prem_vrbl_rt_f apv
    where  apr.actl_prem_id = apv.actl_prem_id
      and  apv.vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
    union
    select to_number(null) pgm_id,
           pl_id,
           to_number(null) ptip_id,
           plip_id,
           oipl_id
    from   ben_cvg_amt_calc_mthd_f ccm,
           ben_bnft_vrbl_rt_f bvr
   where   ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
     and   bvr.vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
    ;
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  -- Parameter validation
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'event',
                             p_argument_value => p_event);
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'vrbl_rt prfl id',
                             p_argument_value => p_vrbl_rt_prfl_id);
  --
  if p_event not in ('CREATE','DELETE') then
    --
    fnd_message.set_name('BEN','BEN_92466_EVENT_HANDLER');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('EVENT',p_event);
    fnd_message.raise_error;
    --
  end if;
  --
  if p_event = 'CREATE' then
    --
    For i in c1 loop
      --
      If i.pgm_id is not null then
        --
        update ben_pgm_f
        set    drvbl_fctr_apls_rts_flag = 'Y'
        where  pgm_id = i.pgm_id;
        --
      end if;
      --
      If i.pl_id is not null then
        --
        update ben_pl_f
        set    drvbl_fctr_apls_rts_flag = 'Y'
        where  pl_id = i.pl_id;
        --
      end if;
      --
      If i.plip_id is not null then
        --
        update ben_plip_f
        set    drvbl_fctr_apls_rts_flag = 'Y'
        where  plip_id = i.plip_id;
        --
      end if;
      --
      If i.ptip_id is not null then
        --
        update ben_ptip_f
        set    drvbl_fctr_apls_rts_flag = 'Y'
        where  ptip_id = i.ptip_id;
        --
      end if;
      --
      If i.oipl_id is not null then
        --
        update ben_oipl_f
        set    drvbl_fctr_apls_rts_flag = 'Y'
        where  oipl_id = i.oipl_id;
        --
      end if;
      --
    End Loop;
    --
  elsif p_event = 'DELETE' then
    --
    For i in c1 Loop
      --
      If i.pgm_id is not null then
        --
        update ben_pgm_f
        set    drvbl_fctr_apls_rts_flag = 'N'
        where  pgm_id = i.pgm_id
        and    drvbl_fctr_apls_rts_flag = 'Y'
        and    not exists (select null
                           from   ben_age_rt_f art,
                                  ben_acty_base_rt_f abr,
                                  ben_acty_vrbl_rt_f avr
                           where  abr.pgm_id = i.pgm_id
                           and    abr.acty_base_rt_id = avr.acty_base_rt_id
                           and    avr.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id)
        and    not exists (select null
                           from   ben_cmbn_age_los_rt_f cmr,
                                  ben_acty_base_rt_f abr,
                                  ben_acty_vrbl_rt_f avr
                           where  abr.pgm_id = i.pgm_id
                           and    abr.acty_base_rt_id = avr.acty_base_rt_id
                           and    avr.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id)
        and    not exists (select null
                           from   ben_comp_lvl_rt_f clr,
                                  ben_acty_base_rt_f abr,
                                  ben_acty_vrbl_rt_f avr
                           where  abr.pgm_id = i.pgm_id
                           and    abr.acty_base_rt_id = avr.acty_base_rt_id
                           and    avr.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id)
        and    not exists (select null
                           from   ben_hrs_wkd_in_perd_rt_f hwr,
                                  ben_acty_base_rt_f abr,
                                  ben_acty_vrbl_rt_f avr
                           where  abr.pgm_id = i.pgm_id
                           and    abr.acty_base_rt_id = avr.acty_base_rt_id
                           and    avr.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id)
        and    not exists (select null
                           from   ben_los_rt_f lsr,
                                  ben_acty_base_rt_f abr,
                                  ben_acty_vrbl_rt_f avr
                           where  abr.pgm_id = i.pgm_id
                           and    abr.acty_base_rt_id = avr.acty_base_rt_id
                           and    avr.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id)
        and    not exists (select null
                           from   ben_pct_fl_tm_rt_f pfr,
                                  ben_acty_base_rt_f abr,
                                  ben_acty_vrbl_rt_f avr
                           where  abr.pgm_id = i.pgm_id
                           and    abr.acty_base_rt_id = avr.acty_base_rt_id
                           and    avr.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id);
       --
     End If;
     --
     If i.pl_id is not null then
       --
       update ben_pl_f
       set    drvbl_fctr_apls_rts_flag = 'N'
       where  pl_id = i.pl_id
       and    drvbl_fctr_apls_rts_flag = 'Y'
       and    not exists (select null
                          from   ben_age_rt_f art,
                                 ben_acty_base_rt_f abr,
                                 ben_acty_vrbl_rt_f avr
                          where  abr.pl_id = i.pl_id
                          and    abr.acty_base_rt_id = avr.acty_base_rt_id
                          and    avr.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_cmbn_age_los_rt_f cmr,
                                 ben_acty_base_rt_f abr,
                                 ben_acty_vrbl_rt_f avr
                          where  abr.pl_id = i.pl_id
                          and    abr.acty_base_rt_id = avr.acty_base_rt_id
                          and    avr.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_comp_lvl_rt_f clr,
                                 ben_acty_base_rt_f abr,
                                 ben_acty_vrbl_rt_f avr
                          where  abr.pl_id = i.pl_id
                          and    abr.acty_base_rt_id = avr.acty_base_rt_id
                          and    avr.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_hrs_wkd_in_perd_rt_f hwr,
                                 ben_acty_base_rt_f abr,
                                 ben_acty_vrbl_rt_f avr
                          where  abr.pl_id = i.pl_id
                          and    abr.acty_base_rt_id = avr.acty_base_rt_id
                          and    avr.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_los_rt_f lsr,
                                 ben_acty_base_rt_f abr,
                                 ben_acty_vrbl_rt_f avr
                          where  abr.pl_id = i.pl_id
                          and    abr.acty_base_rt_id = avr.acty_base_rt_id
                          and    avr.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_pct_fl_tm_rt_f pfr,
                                 ben_acty_base_rt_f abr,
                                 ben_acty_vrbl_rt_f avr
                          where  abr.pl_id = i.pl_id
                          and    abr.acty_base_rt_id = avr.acty_base_rt_id
                          and    avr.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_age_rt_f art,
                                 ben_actl_prem_f apr,
                                 ben_actl_prem_vrbl_rt_f apv
                          where  apr.pl_id = i.pl_id
                          and    apr.actl_prem_id = apv.actl_prem_id
                          and    apv.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_cmbn_age_los_rt_f cmr,
                                 ben_actl_prem_f apr,
                                 ben_actl_prem_vrbl_rt_f apv
                          where  apr.pl_id = i.pl_id
                          and    apr.actl_prem_id = apv.actl_prem_id
                          and    apv.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_comp_lvl_rt_f clr,
                                 ben_actl_prem_f apr,
                                 ben_actl_prem_vrbl_rt_f apv
                          where  apr.pl_id = i.pl_id
                          and    apr.actl_prem_id = apv.actl_prem_id
                          and    apv.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_hrs_wkd_in_perd_rt_f hwr,
                                 ben_actl_prem_f apr,
                                 ben_actl_prem_vrbl_rt_f apv
                          where  apr.pl_id = i.pl_id
                          and    apr.actl_prem_id = apv.actl_prem_id
                          and    apv.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_los_rt_f lsr,
                                 ben_actl_prem_f apr,
                                 ben_actl_prem_vrbl_rt_f apv
                          where  apr.pl_id = i.pl_id
                          and    apr.actl_prem_id = apv.actl_prem_id
                          and    apv.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_pct_fl_tm_rt_f pfr,
                                 ben_actl_prem_f apr,
                                 ben_actl_prem_vrbl_rt_f apv
                          where  apr.pl_id = i.pl_id
                          and    apr.actl_prem_id = apv.actl_prem_id
                          and    apv.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_age_rt_f art,
                                 ben_cvg_amt_calc_mthd_f ccm,
                                 ben_bnft_vrbl_rt_f bvr
                          where  ccm.pl_id = i.pl_id
                          and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                          and    bvr.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_cmbn_age_los_rt_f cmr,
                                 ben_cvg_amt_calc_mthd_f ccm,
                                 ben_bnft_vrbl_rt_f bvr
                          where  ccm.pl_id = i.pl_id
                          and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                          and    bvr.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_comp_lvl_rt_f clr,
                                 ben_cvg_amt_calc_mthd_f ccm,
                                 ben_bnft_vrbl_rt_f bvr
                          where  ccm.pl_id = i.pl_id
                          and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                          and    bvr.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_hrs_wkd_in_perd_rt_f hwr,
                                 ben_cvg_amt_calc_mthd_f ccm,
                                 ben_bnft_vrbl_rt_f bvr
                          where  ccm.pl_id = i.pl_id
                          and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                          and    bvr.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_los_rt_f lsr,
                                 ben_cvg_amt_calc_mthd_f ccm,
                                 ben_bnft_vrbl_rt_f bvr
                          where  ccm.pl_id = i.pl_id
                          and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                          and    bvr.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_pct_fl_tm_rt_f pfr,
                                 ben_cvg_amt_calc_mthd_f ccm,
                                 ben_bnft_vrbl_rt_f bvr
                          where  ccm.pl_id = i.pl_id
                          and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                          and    bvr.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id);
       --
     End If;
     --
     If i.plip_id is not null then
       --
       update ben_plip_f
       set    drvbl_fctr_apls_rts_flag = 'N'
       where  plip_id = i.plip_id
       and    drvbl_fctr_apls_rts_flag = 'Y'
       and    not exists (select null
                          from   ben_age_rt_f art,
                                 ben_acty_base_rt_f abr,
                                 ben_acty_vrbl_rt_f avr
                          where  abr.plip_id = i.plip_id
                          and    abr.acty_base_rt_id = avr.acty_base_rt_id
                          and    avr.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_cmbn_age_los_rt_f cmr,
                                 ben_acty_base_rt_f abr,
                                 ben_acty_vrbl_rt_f avr
                          where  abr.plip_id = i.plip_id
                          and    abr.acty_base_rt_id = avr.acty_base_rt_id
                          and    avr.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_comp_lvl_rt_f clr,
                                 ben_acty_base_rt_f abr,
                                 ben_acty_vrbl_rt_f avr
                          where  abr.plip_id = i.plip_id
                          and    abr.acty_base_rt_id = avr.acty_base_rt_id
                          and    avr.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_hrs_wkd_in_perd_rt_f hwr,
                                 ben_acty_base_rt_f abr,
                                 ben_acty_vrbl_rt_f avr
                          where  abr.plip_id = i.plip_id
                          and    abr.acty_base_rt_id = avr.acty_base_rt_id
                          and    avr.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_los_rt_f lsr,
                                 ben_acty_base_rt_f abr,
                                 ben_acty_vrbl_rt_f avr
                          where  abr.plip_id = i.plip_id
                          and    abr.acty_base_rt_id = avr.acty_base_rt_id
                          and    avr.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_pct_fl_tm_rt_f pfr,
                                 ben_acty_base_rt_f abr,
                                 ben_acty_vrbl_rt_f avr
                          where  abr.plip_id = i.plip_id
                          and    abr.acty_base_rt_id = avr.acty_base_rt_id
                          and    avr.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_age_rt_f art,
                                 ben_cvg_amt_calc_mthd_f ccm,
                                 ben_bnft_vrbl_rt_f bvr
                          where  ccm.plip_id = i.plip_id
                          and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                          and    bvr.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_cmbn_age_los_rt_f cmr,
                                 ben_cvg_amt_calc_mthd_f ccm,
                                 ben_bnft_vrbl_rt_f bvr
                          where  ccm.plip_id = i.plip_id
                          and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                          and    bvr.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_comp_lvl_rt_f clr,
                                 ben_cvg_amt_calc_mthd_f ccm,
                                 ben_bnft_vrbl_rt_f bvr
                          where  ccm.plip_id = i.plip_id
                          and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                          and    bvr.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_hrs_wkd_in_perd_rt_f hwr,
                                 ben_cvg_amt_calc_mthd_f ccm,
                                 ben_bnft_vrbl_rt_f bvr
                          where  ccm.plip_id = i.plip_id
                          and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                          and    bvr.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_los_rt_f lsr,
                                 ben_cvg_amt_calc_mthd_f ccm,
                                 ben_bnft_vrbl_rt_f bvr
                          where  ccm.plip_id = i.plip_id
                          and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                          and    bvr.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_pct_fl_tm_rt_f pfr,
                                 ben_cvg_amt_calc_mthd_f ccm,
                                 ben_bnft_vrbl_rt_f bvr
                          where  ccm.plip_id = i.plip_id
                          and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                          and    bvr.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id);
       --
     End If;
     --
     If i.ptip_id is not null then
       --
       update ben_ptip_f
       set    drvbl_fctr_apls_rts_flag = 'N'
       where  ptip_id = i.ptip_id
       and    drvbl_fctr_apls_rts_flag = 'Y'
       and    not exists (select null
                          from   ben_age_rt_f art,
                                 ben_acty_base_rt_f abr,
                                 ben_acty_vrbl_rt_f avr
                          where  abr.ptip_id = i.ptip_id
                          and    abr.acty_base_rt_id = avr.acty_base_rt_id
                          and    avr.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_cmbn_age_los_rt_f cmr,
                                 ben_acty_base_rt_f abr,
                                 ben_acty_vrbl_rt_f avr
                          where  abr.ptip_id = i.ptip_id
                          and    abr.acty_base_rt_id = avr.acty_base_rt_id
                          and    avr.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_comp_lvl_rt_f clr,
                                 ben_acty_base_rt_f abr,
                                 ben_acty_vrbl_rt_f avr
                          where  abr.ptip_id = i.ptip_id
                          and    abr.acty_base_rt_id = avr.acty_base_rt_id
                          and    avr.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_hrs_wkd_in_perd_rt_f hwr,
                                 ben_acty_base_rt_f abr,
                                 ben_acty_vrbl_rt_f avr
                          where  abr.ptip_id = i.ptip_id
                          and    abr.acty_base_rt_id = avr.acty_base_rt_id
                          and    avr.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_los_rt_f lsr,
                                 ben_acty_base_rt_f abr,
                                 ben_acty_vrbl_rt_f avr
                          where  abr.ptip_id = i.ptip_id
                          and    abr.acty_base_rt_id = avr.acty_base_rt_id
                          and    avr.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_pct_fl_tm_rt_f pfr,
                                 ben_acty_base_rt_f abr,
                                 ben_acty_vrbl_rt_f avr
                          where  abr.ptip_id = i.ptip_id
                          and    abr.acty_base_rt_id = avr.acty_base_rt_id
                          and    avr.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id);
      --
    End If;
    --
    If i.oipl_id is not null then
      --
      update ben_oipl_f
      set    drvbl_fctr_apls_rts_flag = 'N'
      where  oipl_id = i.oipl_id
      and    drvbl_fctr_apls_rts_flag = 'Y'
      and    not exists (select null
                         from   ben_age_rt_f art,
                                ben_acty_base_rt_f abr,
                                ben_acty_vrbl_rt_f avr
                         where  abr.oipl_id = i.oipl_id
                         and    abr.acty_base_rt_id = avr.acty_base_rt_id
                         and    avr.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id)
      and    not exists (select null
                         from   ben_cmbn_age_los_rt_f cmr,
                                ben_acty_base_rt_f abr,
                                ben_acty_vrbl_rt_f avr
                         where  abr.oipl_id = i.oipl_id
                         and    abr.acty_base_rt_id = avr.acty_base_rt_id
                         and    avr.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id)
      and    not exists (select null
                         from   ben_comp_lvl_rt_f clr,
                                ben_acty_base_rt_f abr,
                                ben_acty_vrbl_rt_f avr
                         where  abr.oipl_id = i.oipl_id
                         and    abr.acty_base_rt_id = avr.acty_base_rt_id
                         and    avr.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id)
      and    not exists (select null
                         from   ben_hrs_wkd_in_perd_rt_f hwr,
                                ben_acty_base_rt_f abr,
                                ben_acty_vrbl_rt_f avr
                         where  abr.oipl_id = i.oipl_id
                         and    abr.acty_base_rt_id = avr.acty_base_rt_id
                         and    avr.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id)
      and   not exists (select null
                        from   ben_los_rt_f lsr,
                               ben_acty_base_rt_f abr,
                               ben_acty_vrbl_rt_f avr
                        where  abr.oipl_id = i.oipl_id
                        and    abr.acty_base_rt_id = avr.acty_base_rt_id
                        and    avr.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id)
      and   not exists (select null
                        from   ben_pct_fl_tm_rt_f pfr,
                               ben_acty_base_rt_f abr,
                               ben_acty_vrbl_rt_f avr
                        where  abr.oipl_id = i.oipl_id
                        and    abr.acty_base_rt_id = avr.acty_base_rt_id
                        and    avr.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_age_rt_f art,
                                 ben_actl_prem_f apr,
                                 ben_actl_prem_vrbl_rt_f apv
                          where  apr.oipl_id = i.oipl_id
                          and    apr.actl_prem_id = apv.actl_prem_id
                          and    apv.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_cmbn_age_los_rt_f cmr,
                                 ben_actl_prem_f apr,
                                 ben_actl_prem_vrbl_rt_f apv
                          where  apr.oipl_id = i.oipl_id
                          and    apr.actl_prem_id = apv.actl_prem_id
                          and    apv.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_comp_lvl_rt_f clr,
                                 ben_actl_prem_f apr,
                                 ben_actl_prem_vrbl_rt_f apv
                          where  apr.oipl_id = i.oipl_id
                          and    apr.actl_prem_id = apv.actl_prem_id
                          and    apv.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_hrs_wkd_in_perd_rt_f hwr,
                                 ben_actl_prem_f apr,
                                 ben_actl_prem_vrbl_rt_f apv
                          where  apr.oipl_id = i.oipl_id
                          and    apr.actl_prem_id = apv.actl_prem_id
                          and    apv.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_los_rt_f lsr,
                                 ben_actl_prem_f apr,
                                 ben_actl_prem_vrbl_rt_f apv
                          where  apr.oipl_id = i.oipl_id
                          and    apr.actl_prem_id = apv.actl_prem_id
                          and    apv.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_pct_fl_tm_rt_f pfr,
                                 ben_actl_prem_f apr,
                                 ben_actl_prem_vrbl_rt_f apv
                          where  apr.oipl_id = i.oipl_id
                          and    apr.actl_prem_id = apv.actl_prem_id
                          and    apv.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_age_rt_f art,
                                 ben_cvg_amt_calc_mthd_f ccm,
                                 ben_bnft_vrbl_rt_f bvr
                          where  ccm.oipl_id = i.oipl_id
                          and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                          and    bvr.vrbl_rt_prfl_id = art.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_cmbn_age_los_rt_f cmr,
                                 ben_cvg_amt_calc_mthd_f ccm,
                                 ben_bnft_vrbl_rt_f bvr
                          where  ccm.oipl_id = i.oipl_id
                          and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                          and    bvr.vrbl_rt_prfl_id = cmr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_comp_lvl_rt_f clr,
                                 ben_cvg_amt_calc_mthd_f ccm,
                                 ben_bnft_vrbl_rt_f bvr
                          where  ccm.oipl_id = i.oipl_id
                          and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                          and    bvr.vrbl_rt_prfl_id = clr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_hrs_wkd_in_perd_rt_f hwr,
                                 ben_cvg_amt_calc_mthd_f ccm,
                                 ben_bnft_vrbl_rt_f bvr
                          where  ccm.oipl_id = i.oipl_id
                          and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                          and    bvr.vrbl_rt_prfl_id = hwr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_los_rt_f lsr,
                                 ben_cvg_amt_calc_mthd_f ccm,
                                 ben_bnft_vrbl_rt_f bvr
                          where  ccm.oipl_id = i.oipl_id
                          and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                          and    bvr.vrbl_rt_prfl_id = lsr.vrbl_rt_prfl_id)
       and    not exists (select null
                          from   ben_pct_fl_tm_rt_f pfr,
                                 ben_cvg_amt_calc_mthd_f ccm,
                                 ben_bnft_vrbl_rt_f bvr
                          where  ccm.oipl_id = i.oipl_id
                          and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
                          and    bvr.vrbl_rt_prfl_id = pfr.vrbl_rt_prfl_id);
      --
    End If;
    --
  End Loop;
  --
end if;
--
end derivable_rate_handler;
--
end ben_derivable_rate;

/
