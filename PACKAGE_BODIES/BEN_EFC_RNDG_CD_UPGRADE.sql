--------------------------------------------------------
--  DDL for Package Body BEN_EFC_RNDG_CD_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EFC_RNDG_CD_UPGRADE" as
/* $Header: beefcrcu.pkb 120.0 2005/05/28 02:08:15 appldev noship $ */
--
/*
+==============================================================================+
|			 Copyright (c) 1997 Oracle Corporation		       |
|			    Redwood Shores, California, USA		       |
|				All rights reserved.			       |
+==============================================================================+
--
History
  Version    Date	Author	   Comments
  ---------  ---------	---------- --------------------------------------------
  115.0      12-Jul-01	mhoyes     Created.
  115.1      26-Jul-01	mhoyes     Enhanced for Patchset E+ patch.
  115.2      13-Aug-01	mhoyes     Enhanced for Patchset E+ patch.
  115.3      27-Aug-01	mhoyes     Enhanced for BEN July patch.
  -----------------------------------------------------------------------------
*/
--
-- Globals.
--
g_package varchar2(50) := 'ben_efc_rndg_cd_upgrade.';
--
procedure upgrade_rounding_codes
  (p_business_group_id in     number
  ,p_action_id         in     number
  --
  ,p_modify            in     boolean default false
  )
is
  --
  TYPE cur_type IS REF CURSOR;
  --
  -- PLSQL types
  --
  Type RndgTabDetsType      is record
    (tab_name     varchar2(100)
    ,pkcol_name   varchar2(100)
    ,rndgcol_name varchar2(100)
    ,ent_scode    varchar2(100)
    ,datetracked  varchar2(1)
    );
  --
  Type RndgCodeDetsType      is record
    (id                   number
    ,rndgcol_value        varchar2(100)
    ,effective_start_date date
    ,effective_end_date   date
    );
  --
  type RndgTabDetsSetType  is table of RndgTabDetsType;
  --
  l_proc           varchar2(1000) := 'upgrade_rounding_codes';
  --
  c_rndgcd_tabs    cur_type;
  --
  l_rndgtabnm_set  RndgTabDetsSetType := RndgTabDetsSetType();
  --
  l_rndgcodedets   RndgCodeDetsType;
  --
  l_sel_str        long;
  l_sql_str        long;
  l_ele_num        pls_integer;
  l_count          pls_integer;
  --
  l_backup         boolean;
  l_rndgtab_name   varchar2(100);
  l_currency_code  varchar2(100);
  l_newrndg_code   varchar2(100);
  --
  l_esd            date;
  l_eed            date;
  --
  cursor c_getactdets
    (c_action_id number
    )
  is
    select null
    from ben_round_code_values_efc
    where efc_action_id = c_action_id;
  --
  l_getactdets  c_getactdets%rowtype;
  --
  cursor c_get_apr_currcode
    (c_apr_id    number
    ,c_esd       date
    ,c_action_id number
    )
  is
    select efc.uom
    from ben_actl_prem_f_efc efc
    where efc.efc_action_id = c_action_id
    and   efc.actl_prem_id  = c_apr_id
    and   efc.effective_start_date = c_esd;
  --
  cursor c_get_abr_currcode
    (c_abr_id    number
    ,c_esd       date
    ,c_action_id number
    )
  is
    select nvl(efc.pgm_uom,efc.nip_pl_uom)
    from ben_acty_base_rt_f_efc efc
    where efc.efc_action_id   = c_action_id
    and   efc.acty_base_rt_id = c_abr_id
    and   efc.effective_start_date = c_esd;
  --
  cursor c_get_bpr_currcode
    (c_bpr_id    number
    ,c_esd       date
    ,c_action_id number
    )
  is
    select nvl(efc.pgm_uom,efc.nip_pl_uom)
    from ben_bnft_pool_rlovr_rqmt_f_efc efc
    where efc.efc_action_id   = c_action_id
    and   efc.bnft_pool_rlovr_rqmt_id = c_bpr_id
    and   efc.effective_start_date = c_esd;
  --
  cursor c_get_bpp_currcode
    (c_bpp_id    number
    ,c_esd       date
    ,c_action_id number
    )
  is
    select efc.pgm_uom
    from ben_bnft_prvdr_pool_f_efc efc
    where efc.efc_action_id   = c_action_id
    and   efc.bnft_prvdr_pool_id = c_bpp_id
    and   efc.effective_start_date = c_esd;
  --
  cursor c_get_clf_currcode
    (c_clf_id    number
    ,c_action_id number
    )
  is
    select efc.comp_lvl_uom
    from ben_comp_lvl_fctr_efc efc
    where efc.efc_action_id    = c_action_id
    and   efc.comp_lvl_fctr_id = c_clf_id;
  --
  cursor c_get_ccm_currcode
    (c_ccm_id    number
    ,c_esd       date
    ,c_action_id number
    )
  is
    select nvl(efc.pgm_uom,efc.nip_pl_uom)
    from ben_cvg_amt_calc_mthd_f_efc efc
    where efc.efc_action_id        = c_action_id
    and   efc.cvg_amt_calc_mthd_id = c_ccm_id
    and   efc.effective_start_date = c_esd;
  --
  cursor c_get_prt_currcode
    (c_prt_id    number
    ,c_esd       date
    ,c_action_id number
    )
  is
    select nvl(efc.pgm_uom,efc.nip_pl_uom)
    from  ben_poe_rt_f prt,
          ben_vrbl_rt_prfl_f_efc efc
    where efc.efc_action_id   = c_action_id
    and   prt.poe_rt_id       = c_prt_id
    and   efc.vrbl_rt_prfl_id = prt.vrbl_rt_prfl_id
    and   c_esd
      between prt.effective_start_date and prt.effective_end_date
    and   efc.effective_start_date = c_esd;
  --
  cursor c_get_ppv_currcode
    (c_ppv_id    number
    ,c_esd       date
    ,c_action_id number
    )
  is
    select nvl(efc.pgm_uom,efc.nip_pl_uom)
    from  ben_prtl_mo_rt_prtn_val_f ppv,
          ben_acty_base_rt_f_efc efc
    where efc.efc_action_id   = c_action_id
    and   ppv.acty_base_rt_id = c_ppv_id
    and   efc.acty_base_rt_id = ppv.acty_base_rt_id
    and   c_esd
      between ppv.effective_start_date and ppv.effective_end_date
    and   efc.effective_start_date = c_esd;
  --
  cursor c_get_vpf_currcode
    (c_vpf_id    number
    ,c_esd       date
    ,c_action_id number
    )
  is
    select nvl(efc.pgm_uom,efc.nip_pl_uom)
    from  ben_vrbl_rt_prfl_f_efc efc
    where efc.efc_action_id   = c_action_id
    and   efc.vrbl_rt_prfl_id = c_vpf_id
    and   efc.effective_start_date = c_esd;
  --
begin
  --
  -- Check if rounding code information exists for the EFC action
  --
  l_backup := FALSE;
  --
  if p_action_id is not null then
    --
    open c_getactdets
      (c_action_id => p_action_id
      );
    fetch c_getactdets into l_getactdets;
    if c_getactdets%notfound then
      --
      l_backup := TRUE;
      --
    end if;
    close c_getactdets;
    --
  end if;
  --
  l_ele_num := 1;
  --
  l_rndgtabnm_set.extend(1);
  l_rndgtabnm_set(l_ele_num).tab_name     := 'BEN_ACTL_PREM_F';
  l_rndgtabnm_set(l_ele_num).pkcol_name   := 'ACTL_PREM_ID';
  l_rndgtabnm_set(l_ele_num).rndgcol_name := 'RNDG_CD';
  l_rndgtabnm_set(l_ele_num).ent_scode    := 'APR';
  l_rndgtabnm_set(l_ele_num).datetracked  := 'Y';
  l_ele_num := l_ele_num+1;
  --
  l_rndgtabnm_set.extend(1);
  l_rndgtabnm_set(l_ele_num).tab_name     := 'BEN_ACTY_BASE_RT_F';
  l_rndgtabnm_set(l_ele_num).pkcol_name   := 'ACTY_BASE_RT_ID';
  l_rndgtabnm_set(l_ele_num).rndgcol_name := 'RNDG_CD';
  l_rndgtabnm_set(l_ele_num).ent_scode    := 'ABR';
  l_rndgtabnm_set(l_ele_num).datetracked  := 'Y';
  l_ele_num := l_ele_num+1;
  --
  l_rndgtabnm_set.extend(1);
  l_rndgtabnm_set(l_ele_num).tab_name     := 'BEN_BNFT_POOL_RLOVR_RQMT_F';
  l_rndgtabnm_set(l_ele_num).pkcol_name   := 'BNFT_POOL_RLOVR_RQMT_ID';
  l_rndgtabnm_set(l_ele_num).rndgcol_name := 'VAL_RNDG_CD';
  l_rndgtabnm_set(l_ele_num).ent_scode    := 'BPR';
  l_rndgtabnm_set(l_ele_num).datetracked  := 'Y';
  l_ele_num := l_ele_num+1;
  --
  l_rndgtabnm_set.extend(1);
  l_rndgtabnm_set(l_ele_num).tab_name     := 'BEN_BNFT_PRVDR_POOL_F';
  l_rndgtabnm_set(l_ele_num).pkcol_name   := 'BNFT_PRVDR_POOL_ID';
  l_rndgtabnm_set(l_ele_num).rndgcol_name := 'VAL_RNDG_CD';
  l_rndgtabnm_set(l_ele_num).ent_scode    := 'BPP';
  l_rndgtabnm_set(l_ele_num).datetracked  := 'Y';
  l_ele_num := l_ele_num+1;
  --
  l_rndgtabnm_set.extend(1);
  l_rndgtabnm_set(l_ele_num).tab_name     := 'BEN_COMP_LVL_FCTR';
  l_rndgtabnm_set(l_ele_num).pkcol_name   := 'COMP_LVL_FCTR_ID';
  l_rndgtabnm_set(l_ele_num).rndgcol_name := 'RNDG_CD';
  l_rndgtabnm_set(l_ele_num).ent_scode    := 'CLF';
  l_rndgtabnm_set(l_ele_num).datetracked  := 'N';
  l_ele_num := l_ele_num+1;
  --
  l_rndgtabnm_set.extend(1);
  l_rndgtabnm_set(l_ele_num).tab_name     := 'BEN_CVG_AMT_CALC_MTHD_F';
  l_rndgtabnm_set(l_ele_num).pkcol_name   := 'CVG_AMT_CALC_MTHD_ID';
  l_rndgtabnm_set(l_ele_num).rndgcol_name := 'RNDG_CD';
  l_rndgtabnm_set(l_ele_num).ent_scode    := 'CCM';
  l_rndgtabnm_set(l_ele_num).datetracked  := 'Y';
  l_ele_num := l_ele_num+1;
  --
  l_rndgtabnm_set.extend(1);
  l_rndgtabnm_set(l_ele_num).tab_name     := 'BEN_POE_RT_F';
  l_rndgtabnm_set(l_ele_num).pkcol_name   := 'POE_RT_ID';
  l_rndgtabnm_set(l_ele_num).rndgcol_name := 'RNDG_CD';
  l_rndgtabnm_set(l_ele_num).ent_scode    := 'PRT';
  l_rndgtabnm_set(l_ele_num).datetracked  := 'Y';
  l_ele_num := l_ele_num+1;
  --
  l_rndgtabnm_set.extend(1);
  l_rndgtabnm_set(l_ele_num).tab_name     := 'BEN_PRTL_MO_RT_PRTN_VAL_F';
  l_rndgtabnm_set(l_ele_num).pkcol_name   := 'PRTL_MO_RT_PRTN_VAL_ID';
  l_rndgtabnm_set(l_ele_num).rndgcol_name := 'RNDG_CD';
  l_rndgtabnm_set(l_ele_num).ent_scode    := 'PMRPV';
  l_rndgtabnm_set(l_ele_num).datetracked  := 'Y';
  l_ele_num := l_ele_num+1;
  --
  l_rndgtabnm_set.extend(1);
  l_rndgtabnm_set(l_ele_num).tab_name     := 'BEN_VRBL_RT_PRFL_F';
  l_rndgtabnm_set(l_ele_num).pkcol_name   := 'VRBL_RT_PRFL_ID';
  l_rndgtabnm_set(l_ele_num).rndgcol_name := 'RNDG_CD';
  l_rndgtabnm_set(l_ele_num).ent_scode    := 'VPF';
  l_rndgtabnm_set(l_ele_num).datetracked  := 'Y';
  --
  hr_efc_info.insert_line
    ('-- ');
  hr_efc_info.insert_line
    ('-- Checking upgradeable rounding codes for business group ID '||p_business_group_id
    ||' EFC action ID: '||p_action_id
    );
  hr_efc_info.insert_line
    ('-- ');
  --
  for rndgele_num in l_rndgtabnm_set.first..l_rndgtabnm_set.last
  loop
    --
    l_rndgtab_name := l_rndgtabnm_set(rndgele_num).tab_name;
    --
    l_sql_str := 'select count(*) '
                 ||' from '||l_rndgtab_name
                 ||' where '||l_rndgtabnm_set(rndgele_num).rndgcol_name||' is not null '
                 ||' and business_group_id = '||p_business_group_id;
    --
    open c_rndgcd_tabs FOR l_sql_str;
    FETCH c_rndgcd_tabs INTO l_count;
    CLOSE c_rndgcd_tabs;
    --
    if l_count > 0 then
      --
      if p_modify then
        --
        hr_efc_info.insert_line
          ('--   Mapping '||l_count||' rounding code values to EFC rounding code values in table '
          ||l_rndgtab_name
          );
        --
      elsif not l_backup then
        --
        hr_efc_info.insert_line
          ('--   '||l_count||' Potential rounding code values to be upgraded exist in '
          ||l_rndgtab_name
          );
        --
      else
        --
        hr_efc_info.insert_line
          ('--   '||l_count||' rounding code values being backed up from '
          ||l_rndgtab_name
          );
        --
      end if;
      --
      -- Check for a datetracked table
      --
      l_sel_str := l_rndgtabnm_set(rndgele_num).pkcol_name||', '
                   ||' '||l_rndgtabnm_set(rndgele_num).rndgcol_name;
      --
      if l_rndgtabnm_set(rndgele_num).datetracked = 'Y' then
        --
        l_sel_str := l_sel_str||', effective_start_date, effective_end_date ';
        --
      else
        --
        l_sel_str := l_sel_str||', null, null ';
        --
      end if;
      --
      l_sql_str := 'select '||l_sel_str
                   ||' from '||l_rndgtab_name
                   ||' where '||l_rndgtabnm_set(rndgele_num).rndgcol_name||' is not null '
                   ||' and business_group_id = '||p_business_group_id;
      --
      open c_rndgcd_tabs FOR l_sql_str;
      loop
        FETCH c_rndgcd_tabs INTO l_rndgcodedets;
        EXIT WHEN c_rndgcd_tabs%NOTFOUND;
        --
        if l_backup then
          --
          l_esd := l_rndgcodedets.effective_start_date;
          l_eed := l_rndgcodedets.effective_end_date;
          --
          if l_rndgcodedets.effective_start_date is null then
            --
            l_esd := hr_api.g_sot;
            --
          end if;
          --
          if l_rndgcodedets.effective_end_date is null then
            --
            l_eed := hr_api.g_eot;
            --
          end if;
          --
          insert into ben_round_code_values_efc
            (efc_action_id
            ,table_name
            ,rndcdcol_name
            ,pk_id
            ,effective_start_date
            ,effective_end_date
            ,rndcdcol_value
            )
          values
            (p_action_id
            ,l_rndgtab_name
            ,l_rndgtabnm_set(rndgele_num).rndgcol_name
            ,l_rndgcodedets.id
            ,l_esd
            ,l_eed
            ,l_rndgcodedets.rndgcol_value
            );
          --
        end if;
        --
        -- Check if the rounding code needs to be modified
        --
        if p_modify then
          --
          -- Get the currency code
          --
          if l_rndgtab_name = 'BEN_ACTL_PREM_F'
          then
            --
            open c_get_apr_currcode
              (c_apr_id    => l_rndgcodedets.id
              ,c_esd       => l_rndgcodedets.effective_start_date
              ,c_action_id => p_action_id
              );
            fetch c_get_apr_currcode into l_currency_code;
            if c_get_apr_currcode%notfound then
              --
              l_currency_code := null;
              --
            end if;
            close c_get_apr_currcode;
            --
          elsif l_rndgtab_name = 'BEN_ACTY_BASE_RT_F'
          then
            --
            open c_get_abr_currcode
              (c_abr_id    => l_rndgcodedets.id
              ,c_esd       => l_rndgcodedets.effective_start_date
              ,c_action_id => p_action_id
              );
            fetch c_get_abr_currcode into l_currency_code;
            if c_get_abr_currcode%notfound then
              --
              l_currency_code := null;
              --
            end if;
            close c_get_abr_currcode;
            --
          elsif l_rndgtab_name = 'BEN_BNFT_POOL_RLOVR_RQMT_F'
          then
            --
            open c_get_bpr_currcode
              (c_bpr_id    => l_rndgcodedets.id
              ,c_esd       => l_rndgcodedets.effective_start_date
              ,c_action_id => p_action_id
              );
            fetch c_get_bpr_currcode into l_currency_code;
            if c_get_bpr_currcode%notfound then
              --
              l_currency_code := null;
              --
            end if;
            close c_get_bpr_currcode;
            --
          elsif l_rndgtab_name = 'BEN_BNFT_PRVDR_POOL_F'
          then
            --
            open c_get_bpp_currcode
              (c_bpp_id    => l_rndgcodedets.id
              ,c_esd       => l_rndgcodedets.effective_start_date
              ,c_action_id => p_action_id
              );
            fetch c_get_bpp_currcode into l_currency_code;
            if c_get_bpp_currcode%notfound then
              --
              l_currency_code := null;
              --
            end if;
            close c_get_bpp_currcode;
            --
          elsif l_rndgtab_name = 'BEN_COMP_LVL_FCTR'
          then
            --
            open c_get_clf_currcode
              (c_clf_id    => l_rndgcodedets.id
              ,c_action_id => p_action_id
              );
            fetch c_get_clf_currcode into l_currency_code;
            if c_get_clf_currcode%notfound then
              --
              l_currency_code := null;
              --
            end if;
            close c_get_clf_currcode;
            --
          elsif l_rndgtab_name = 'BEN_CVG_AMT_CALC_MTHD_F'
          then
            --
            open c_get_ccm_currcode
              (c_ccm_id    => l_rndgcodedets.id
              ,c_esd       => l_rndgcodedets.effective_start_date
              ,c_action_id => p_action_id
              );
            fetch c_get_ccm_currcode into l_currency_code;
            if c_get_ccm_currcode%notfound then
              --
              l_currency_code := null;
              --
            end if;
            close c_get_ccm_currcode;
            --
          elsif l_rndgtab_name = 'BEN_POE_RT_F'
          then
            --
            open c_get_prt_currcode
              (c_prt_id    => l_rndgcodedets.id
              ,c_esd       => l_rndgcodedets.effective_start_date
              ,c_action_id => p_action_id
              );
            fetch c_get_prt_currcode into l_currency_code;
            if c_get_prt_currcode%notfound then
              --
              l_currency_code := null;
              --
            end if;
            close c_get_prt_currcode;
            --
          elsif l_rndgtab_name = 'BEN_PRTL_MO_RT_PRTN_VAL_F'
          then
            --
            open c_get_ppv_currcode
              (c_ppv_id    => l_rndgcodedets.id
              ,c_esd       => l_rndgcodedets.effective_start_date
              ,c_action_id => p_action_id
              );
            fetch c_get_ppv_currcode into l_currency_code;
            if c_get_ppv_currcode%notfound then
              --
              l_currency_code := null;
              --
            end if;
            close c_get_ppv_currcode;
            --
          elsif l_rndgtab_name = 'BEN_VRBL_RT_PRFL_F'
          then
            --
            open c_get_vpf_currcode
              (c_vpf_id    => l_rndgcodedets.id
              ,c_esd       => l_rndgcodedets.effective_start_date
              ,c_action_id => p_action_id
              );
            fetch c_get_vpf_currcode into l_currency_code;
            if c_get_vpf_currcode%notfound then
              --
              l_currency_code := null;
              --
            end if;
            close c_get_vpf_currcode;
            --
          end if;
          --
          -- Check if any rounding code mappings have been defined
          --
          if l_currency_code is not null
          then
            --
            l_newrndg_code := ben_efc_stubs.get_cust_mapped_rounding_code
              (p_rndcd_table_name => l_rndgtab_name
              ,p_currency_code    => l_currency_code
              ,p_rndcd_value      => l_rndgcodedets.rndgcol_value
              );
            --
            if l_newrndg_code is not null
              and l_rndgtab_name = 'BEN_ACTL_PREM_F'
            then
              --
              update ben_actl_prem_f
              set rndg_cd = l_newrndg_code
              where actl_prem_id = l_rndgcodedets.id
              and   effective_start_date = l_rndgcodedets.effective_start_date;
            --
            elsif l_newrndg_code is not null
              and l_rndgtab_name = 'BEN_ACTY_BASE_RT_F'
            then
              --
              update ben_acty_base_rt_f
              set rndg_cd = l_newrndg_code
              where acty_base_rt_id = l_rndgcodedets.id
              and   effective_start_date = l_rndgcodedets.effective_start_date;
            --
            elsif l_newrndg_code is not null
              and l_rndgtab_name = 'BEN_BNFT_POOL_RLOVR_RQMT_F'
            then
              --
              update ben_bnft_pool_rlovr_rqmt_f
              set val_rndg_cd = l_newrndg_code
              where bnft_pool_rlovr_rqmt_id = l_rndgcodedets.id
              and   effective_start_date = l_rndgcodedets.effective_start_date;
            --
            elsif l_newrndg_code is not null
              and l_rndgtab_name = 'BEN_BNFT_PRVDR_POOL_F'
            then
              --
              update ben_bnft_prvdr_pool_f
              set val_rndg_cd = l_newrndg_code
              where bnft_prvdr_pool_id = l_rndgcodedets.id
              and   effective_start_date = l_rndgcodedets.effective_start_date;
            --
            elsif l_newrndg_code is not null
              and l_rndgtab_name = 'BEN_COMP_LVL_FCTR'
            then
              --
              update ben_comp_lvl_fctr
              set rndg_cd = l_newrndg_code
              where comp_lvl_fctr_id = l_rndgcodedets.id;
            --
            elsif l_newrndg_code is not null
              and l_rndgtab_name = 'BEN_CVG_AMT_CALC_MTHD_F'
            then
              --
              update ben_cvg_amt_calc_mthd_f
              set rndg_cd = l_newrndg_code
              where cvg_amt_calc_mthd_id = l_rndgcodedets.id
              and   effective_start_date = l_rndgcodedets.effective_start_date;
            --
            elsif l_newrndg_code is not null
              and l_rndgtab_name = 'BEN_POE_RT_F'
            then
              --
              update ben_poe_rt_f
              set rndg_cd = l_newrndg_code
              where poe_rt_id = l_rndgcodedets.id
              and   effective_start_date = l_rndgcodedets.effective_start_date;
            --
            elsif l_newrndg_code is not null
              and l_rndgtab_name = 'BEN_PRTL_MO_RT_PRTN_VAL_F'
            then
              --
              update ben_prtl_mo_rt_prtn_val_f
              set rndg_cd = l_newrndg_code
              where prtl_mo_rt_prtn_val_id = l_rndgcodedets.id
              and   effective_start_date = l_rndgcodedets.effective_start_date;
            --
            elsif l_newrndg_code is not null
              and l_rndgtab_name = 'BEN_VRBL_RT_PRFL_F'
            then
              --
              update ben_vrbl_rt_prfl_f
              set rndg_cd = l_newrndg_code
              where vrbl_rt_prfl_id = l_rndgcodedets.id
              and   effective_start_date = l_rndgcodedets.effective_start_date;
              --
            end if;
            --
            if l_newrndg_code is not null then
              --
              hr_efc_info.insert_line
                ('-- Mapped ID '||l_rndgcodedets.id||' in '||l_rndgtab_name
                ||' for to '||l_newrndg_code||' for currency '||l_currency_code
                );
              --
            end if;
            --
          end if;
          --
        end if;
        --
        commit;
        --
      end loop;
      CLOSE c_rndgcd_tabs;
      --
    end if;
    --
  end loop;
  --
end upgrade_rounding_codes;
--
end ben_efc_rndg_cd_upgrade;

/
