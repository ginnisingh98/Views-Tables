--------------------------------------------------------
--  DDL for Package Body BEN_DERIVABLE_FACTOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DERIVABLE_FACTOR" as
/* $Header: bendrvft.pkb 115.8 2004/02/10 07:16:58 vvprabhu noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
        Derivable Factor
Purpose
        This package is used to handle setting of Derivable Factor Participation Flag based on
        data changes that have occurred on child component tables.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        06-Mar-2000      KMahendr   115.0      Created.
        04-Jan-2001      RCHASE     115.1      Bug 1568561.Fix NDS Create calls in
                                               eligy_prfl_handler, missing parens
                                               around or exists conditions
        21-dec-2001      tjesumic   115.2      dynomic sql corrected bug :2160610
        21-dec-2001      tjesumic   115.5      dbdrv fixed
        07-dec-2002      tjesumic   115.6      commit added
        05-May-2003      kmahendr   115.7      Bug#2939392 - dynamic sql is modified to take
                                               bind variables
        04-Oct-2004      vvprabhu   115.8      Bug 3431740 Parameter p_oracle_schema added
                                               to cursor c1 in elig_prfl_handler,
                                               the value is got by the
        				       call to fnd_installation.get_app_info


*/
--------------------------------------------------------------------------------
g_package varchar2(80) := 'ben_derivable_factor.';
--
  procedure eligy_prfl_handler
  (p_event                       in  varchar2,
   p_table_name                  in  varchar2,
   p_col_name                    in  varchar2,
   p_col_id                     in  number)is
  --
  l_proc        varchar2(80) := g_package||'eligy prfl handler';
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
    and owner=upper(p_oracle_schema);
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

  -- Bug 3431740 Parameter p_oracle_schema added to cursor c1, the value is got by the
  -- following call
  l_return := fnd_installation.get_app_info(application_short_name => l_application_short_name,
              		                    status                 => l_status,
                          	            industry               => l_industry,
                                	    oracle_schema          => l_oracle_schema);
  --
  --
  -- Check operation is valid
  --
  if p_event not in ('CREATE','DELETE') then
    --
    fnd_message.set_name('BEN','BEN_92466_EVENT_HANDLER');
    fnd_message.raise_error;
    --
  end if;
  --
  open c1(p_table_name, p_col_name,l_oracle_schema );
  fetch c1 into l_dummy;
  if c1%notfound then
    close c1;
    fnd_message.set_name('BEN','BEN_93388_NO_TAB_COL');
    fnd_message.raise_error;
  end if;
  close c1;
  --
  --
  --
  if p_event = 'CREATE' then
    --
    -- rchase bug 1568561 - added paren pair around ors
    hr_utility.set_location('Create  event ',10);
    --
    l_strg := 'update '||p_table_name||' t  set drvbl_fctr_prtn_elig_flag = :1

               where '||p_col_name|| '= :2 and (
                   exists (select null from ben_elig_age_prte_f eap, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.'||p_col_name||' = :3 and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = eap.eligy_prfl_id)  or
                  exists  (select null from ben_elig_cmbn_age_los_prte_f ecp, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.'||p_col_name||' = :4 and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ecp.eligy_prfl_id) or
                  exists  (select null from ben_elig_comp_lvl_prte_f ecl, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.'||p_col_name||'= :5 and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ecl.eligy_prfl_id) or
                  exists  (select null from ben_elig_hrs_wkd_prte_f ehw, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.'||p_col_name||'= :6 and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ehw.eligy_prfl_id) or
                  exists  (select null from ben_elig_los_prte_f els, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.'||p_col_name||'= :7 and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = els.eligy_prfl_id) or
                  exists  (select null from ben_elig_pct_fl_tm_prte_f epf, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.'||p_col_name||'= :8  and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = epf.eligy_prfl_id))';
     execute immediate l_strg using 'Y',p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id;
--
  elsif p_event = 'DELETE' then
    hr_utility.set_location('update  event ',10);
    l_strg := 'update '||p_table_name||' t  set drvbl_fctr_prtn_elig_flag = :1
               where '||p_col_name|| '= :2  and
               not exists (select null from ben_elig_age_prte_f eap, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.'||p_col_name||' = :3 and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = eap.eligy_prfl_id)  and
               not exists (select null from ben_elig_cmbn_age_los_prte_f ecp, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.'||p_col_name||' = :4 and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ecp.eligy_prfl_id) and
               not exists (select null from ben_elig_comp_lvl_prte_f ecl, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.'||p_col_name||'= :5 and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ecl.eligy_prfl_id) and
               not exists (select null from ben_elig_hrs_wkd_prte_f ehw, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.'||p_col_name||'= :6 and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ehw.eligy_prfl_id) and
               not exists (select null from ben_elig_los_prte_f els, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.'||p_col_name||'= :7 and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = els.eligy_prfl_id) and
               not exists (select null from ben_elig_pct_fl_tm_prte_f epf, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.'||p_col_name||'= :8 and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = epf.eligy_prfl_id)';
     execute immediate l_strg using 'N',p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id,p_col_id;
--
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc,10);
  --
end eligy_prfl_handler;
-----------------------------------------------------------------------
  procedure derivable_factor_handler
  (p_event                       in  varchar2,
   p_eligy_prfl_id               in  number)is
  --
  l_proc        varchar2(80) := g_package||'derivable factor handler';
  --
  cursor c1 is select pgm_id,pl_id,ptip_id,plip_id,oipl_id
      from ben_prtn_elig_f epa, ben_prtn_elig_prfl_f cep
      where cep.eligy_prfl_id = p_eligy_prfl_id and
            cep.prtn_elig_id = epa.prtn_elig_id;

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
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'eligy prfl id',
                             p_argument_value => p_eligy_prfl_id);
  --
  if p_event not in ('CREATE','DELETE') then
    --
    fnd_message.set_name('BEN','BEN_92466_EVENT_HANDLER');
    fnd_message.raise_error;
    --
  end if;


  if p_event = 'CREATE' then

   For i in c1 loop
     If i.pgm_id is not null then
       update ben_pgm_f set drvbl_fctr_prtn_elig_flag = 'Y'
           where pgm_id = i.pgm_id;
     end if;

     If i.pl_id is not null then
       update ben_pl_f set drvbl_fctr_prtn_elig_flag = 'Y'
           where pl_id = i.pl_id;
     end if;

     If i.plip_id is not null then
       update ben_plip_f set drvbl_fctr_prtn_elig_flag = 'Y'
           where plip_id = i.plip_id;
     end if;

     If i.ptip_id is not null then
       update ben_ptip_f set drvbl_fctr_prtn_elig_flag = 'Y'
           where ptip_id = i.ptip_id;
     end if;

     If i.oipl_id is not null then
       update ben_oipl_f set drvbl_fctr_prtn_elig_flag = 'Y'
           where oipl_id = i.oipl_id;
     end if;
   End Loop;
  elsif p_event = 'DELETE' then
    For i in c1 Loop
     If i.pgm_id is not null then

        update ben_pgm_f  set drvbl_fctr_prtn_elig_flag = 'N'
         where pgm_id = i.pgm_id and
               not exists (select null from ben_elig_age_prte_f eap, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.pgm_id = i.pgm_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = eap.eligy_prfl_id)  and
              not exists  (select null from ben_elig_cmbn_age_los_prte_f ecp, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.pgm_id = i.pgm_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ecp.eligy_prfl_id) and
              not exists  (select null from ben_elig_comp_lvl_prte_f ecl, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.pgm_id = i.pgm_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ecl.eligy_prfl_id) and
              not exists  (select null from ben_elig_hrs_wkd_prte_f ehw, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.pgm_id = i.pgm_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ehw.eligy_prfl_id) and
              not exists  (select null from ben_elig_los_prte_f els, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.pgm_id = i.pgm_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = els.eligy_prfl_id) and
              not exists  (select null from ben_elig_pct_fl_tm_prte_f epf, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.pgm_id = i.pgm_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = epf.eligy_prfl_id);
     End If;
     --
     If i.pl_id is not null then

        update ben_pl_f  set drvbl_fctr_prtn_elig_flag = 'N'
         where pl_id = i.pl_id and
               not exists (select null from ben_elig_age_prte_f eap, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.pl_id = i.pl_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = eap.eligy_prfl_id)  and
              not exists  (select null from ben_elig_cmbn_age_los_prte_f ecp, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.pl_id = i.pl_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ecp.eligy_prfl_id) and
              not exists  (select null from ben_elig_comp_lvl_prte_f ecl, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.pl_id = i.pl_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ecl.eligy_prfl_id) and
              not exists  (select null from ben_elig_hrs_wkd_prte_f ehw, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.pl_id = i.pl_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ehw.eligy_prfl_id) and
              not exists  (select null from ben_elig_los_prte_f els, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.pl_id = i.pl_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = els.eligy_prfl_id) and
              not exists  (select null from ben_elig_pct_fl_tm_prte_f epf, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.pl_id = i.pl_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = epf.eligy_prfl_id);
     End If;
     --
     If i.plip_id is not null then

        update ben_plip_f  set drvbl_fctr_prtn_elig_flag = 'N'
         where plip_id = i.plip_id and
               not exists (select null from ben_elig_age_prte_f eap, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.plip_id = i.plip_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = eap.eligy_prfl_id)  and
              not exists  (select null from ben_elig_cmbn_age_los_prte_f ecp, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.plip_id = i.plip_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ecp.eligy_prfl_id) and
              not exists  (select null from ben_elig_comp_lvl_prte_f ecl, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.plip_id = i.plip_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ecl.eligy_prfl_id) and
              not exists  (select null from ben_elig_hrs_wkd_prte_f ehw, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.plip_id = i.plip_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ehw.eligy_prfl_id) and
              not exists  (select null from ben_elig_los_prte_f els, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.plip_id = i.plip_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = els.eligy_prfl_id) and
              not exists  (select null from ben_elig_pct_fl_tm_prte_f epf, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.plip_id = i.plip_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = epf.eligy_prfl_id);
     End If;
--
     If i.ptip_id is not null then

        update ben_ptip_f  set drvbl_fctr_prtn_elig_flag = 'N'
         where ptip_id = i.ptip_id and
               not exists (select null from ben_elig_age_prte_f eap, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.ptip_id = i.ptip_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = eap.eligy_prfl_id)  and
              not exists  (select null from ben_elig_cmbn_age_los_prte_f ecp, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.ptip_id = i.ptip_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ecp.eligy_prfl_id) and
              not exists  (select null from ben_elig_comp_lvl_prte_f ecl, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.ptip_id = i.ptip_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ecl.eligy_prfl_id) and
              not exists  (select null from ben_elig_hrs_wkd_prte_f ehw, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.ptip_id = i.ptip_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ehw.eligy_prfl_id) and
              not exists  (select null from ben_elig_los_prte_f els, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.ptip_id = i.ptip_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = els.eligy_prfl_id) and
              not exists  (select null from ben_elig_pct_fl_tm_prte_f epf, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.ptip_id = i.ptip_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = epf.eligy_prfl_id);
     End If;
     --
    If i.oipl_id is not null then

        update ben_oipl_f set drvbl_fctr_prtn_elig_flag = 'N'
         where oipl_id = i.oipl_id and
               not exists (select null from ben_elig_age_prte_f eap, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.oipl_id = i.oipl_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = eap.eligy_prfl_id)  and
              not exists  (select null from ben_elig_cmbn_age_los_prte_f ecp, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.oipl_id = i.oipl_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ecp.eligy_prfl_id) and
              not exists  (select null from ben_elig_comp_lvl_prte_f ecl, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.oipl_id = i.oipl_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ecl.eligy_prfl_id) and
              not exists  (select null from ben_elig_hrs_wkd_prte_f ehw, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.oipl_id = i.oipl_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = ehw.eligy_prfl_id) and
              not exists  (select null from ben_elig_los_prte_f els, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.oipl_id = i.oipl_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = els.eligy_prfl_id) and
              not exists  (select null from ben_elig_pct_fl_tm_prte_f epf, ben_prtn_elig_f epa,
                           ben_prtn_elig_prfl_f cep
                           where epa.oipl_id = i.oipl_id and epa.prtn_elig_id = cep.prtn_elig_id and
                           cep.eligy_prfl_id = epf.eligy_prfl_id);
    End If;

   End Loop;
end if;

end derivable_factor_handler;
--
end ben_derivable_factor;

/
