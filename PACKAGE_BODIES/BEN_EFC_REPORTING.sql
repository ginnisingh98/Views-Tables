--------------------------------------------------------
--  DDL for Package Body BEN_EFC_REPORTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EFC_REPORTING" as
/* $Header: beefcrep.pkb 120.0 2005/05/28 02:08:31 appldev noship $ */
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
  115.0      13-Aug-01	mhoyes     Created.
  115.1      17-Aug-01	mhoyes     Enhanced for BEN July patch.
  115.2      27-Aug-01	mhoyes     Enhanced for BEN July patch.
  115.3      31-Aug-01	mhoyes     Enhanced for BEN July patch.
  115.4      02-Oct-01	mhoyes     Enhanced for BEN F patchset.
  115.8      04-Jan-02	mhoyes     Enhanced for BEN G patchset.
  -----------------------------------------------------------------------------
*/
g_package  varchar2(33)	:= '  ben_efc_reporting.';  -- Global package name
--
-- Define globals
--
g_start_time    pls_integer;
g_start_gets    pls_integer;
g_start_phygets pls_integer;
g_start_ftss    pls_integer;
g_start_rwprcs  pls_integer;
g_start_pgamem  pls_integer;
--
procedure DisplayEFCInfo
  (p_ent_scode           in     varchar2
  ,p_efc_action_id       in     number default null
  --
  ,p_disp_private        in     boolean default false
  ,p_disp_succeeds       in     boolean default false
  ,p_disp_exclusions     in     boolean default false
  --
  ,p_adjustment_counts   in     ben_efc_adjustments.g_adjustment_counts
  ,p_rcoerr_val_set      in     ben_efc_adjustments.g_rcoerr_values_tbl
  ,p_failed_adj_val_set  in     ben_efc_adjustments.g_failed_adj_values_tbl
  ,p_fatal_error_val_set in     ben_efc_adjustments.g_failed_adj_values_tbl
  ,p_success_val_set     in     ben_efc_adjustments.g_failed_adj_values_tbl
  )
is
  --
  l_proc         varchar2(80)
  := g_package||'DisplayEFCInfo';
  --
  -- PLSQL types
  --
  Type UniqueVals is record
    (unqval     varchar2(1000)
    ,unqval1    varchar2(1000)
    ,esd        date
    ,eed        date
    ,count      number
    ,mncredt    date
    ,mxcredt    date
    ,percentage number
    );
  --
  type UnqVal_set is table of UniqueVals index by binary_integer;
  --
  l_fatal_error_val_set ben_efc_adjustments.g_failed_adj_values_tbl;
  l_tmp_set             ben_efc_adjustments.g_failed_adj_values_tbl;
  l_success_val_set     ben_efc_adjustments.g_failed_adj_values_tbl;
  l_dup_success_val_set ben_efc_adjustments.g_failed_adj_values_tbl;
  l_unq_success_val_set ben_efc_adjustments.g_failed_adj_values_tbl;
  l_dup_excl_val_set    ben_efc_adjustments.g_failed_adj_values_tbl;
  l_unq_excl_val_set    ben_efc_adjustments.g_failed_adj_values_tbl;
  l_unqtype_set         UnqVal_set;
  l_unqval_set          UnqVal_set;
  l_dupval_set          UnqVal_set;
  --
  l_exclude_perc        number;
  l_faterrs_perc        number;
  l_perc                number;
  --
  l_unqele_num          pls_integer;
  --
  l_found               boolean;
  --
  l_succ_count          pls_integer;
  l_succ_perc           pls_integer;
  l_dupsuccval_count    pls_integer;
  l_rco_count           pls_integer;
  l_rco_perc            pls_integer;
  l_fail_count          pls_integer;
  l_fail_perc           pls_integer;
  l_excl_count          pls_integer;
  l_excl_perc           pls_integer;
  l_dupexclval_count    pls_integer;
  l_tabrow_count        pls_integer;
  l_conv_count          pls_integer;
  l_adjust_count        pls_integer;
  --
  l_hv                  pls_integer;
  l_dupele_num          pls_integer;
  l_public_count        pls_integer;
  l_ent_desc            varchar2(100);
  l_disp_str            long;
  --
  l_enddays             pls_integer;
  --
  function get_description
    (p_label in varchar2
    ) return varchar2
  is

  begin
    --
    -- Categories
    --
    if p_label = 'OBSOLETEDATA' then
      --
      return 'Obsolete Data';
      --
    elsif p_label = 'DELETEDINFO' then
      --
      return 'Deleted Data';
      --
    elsif p_label = 'CORRECTEDINFO' then
      --
      return 'Corrected Data';
      --
    elsif p_label = 'VALIDEXCLUSION' then
      --
      return 'Valid Exclusion';
      --
    elsif p_label = 'DATACORRUPT' then
      --
      return 'Corrupted Data';
      --
    elsif p_label = 'MISSINGSETUP' then
      --
      return 'Missing Setup Data';
    --
    -- Exclusion
    --
    elsif p_label = 'OLDDATA12MTHS' then
      --
      return 'Data created more than 12 months ago';
      --
    elsif p_label = 'OLDDATA10MTHS' then
      --
      return 'Data created more than 10 months ago';
      --
    elsif p_label = 'NULLCREDT' then
      --
      return 'No Who trigger creation date';
      --
    elsif p_label = 'INVOVNTRIG' then
      --
      return 'The Who trigger information has been modified but the object version '
             ||' number has not. ';
      --
    elsif p_label = 'NOPILPERSON' then
      --
      return 'NOPILPERSON: The person associated with the life event has been deleted. '
             ||'An EFC adjustment cannot be performed. ';
      --
    elsif p_label = 'NOPILLEODPRVPEN' then
      --
      return 'NOPILLEODPRVPEN: The enrolment result associated with the participant rate '
             ||' value begins after the rate start date for the participant rate value. '
             ||'An EFC adjustment cannot be performed. ';
      --
    elsif p_label = 'NOEPEDETS' then
      --
      return fnd_message.get_string('BEN','BEN_92771_EFC_EPENOEXIST');
      --
/*

      return 'NOEPEDETS: The electable choice which is being used for processing '
             ||' does not exist. An EFC adjustment cannot be performed. ';
*/
      --
    elsif p_label = 'ABRCORR' then
      --
      return fnd_message.get_string('BEN','BEN_92754_CORR_ECRABR');
      --
/*
      return 'Corrected activity base rate';
      --
*/
    elsif p_label = 'VPFCORR' then
      --
      return fnd_message.get_string('BEN','BEN_92755_CORR_VPF');
/*
      return 'Corrected variable rate profile';
*/
      --
    elsif p_label = 'CCMDTCORR' then
      --
      return fnd_message.get_string('BEN','BEN_92760_EFC_CORR_CCM');
/*
      return 'Corrected coverage calculation method';
      --
*/
      --
    elsif p_label = 'CCMDTCORR' then
      --
      return fnd_message.get_string('BEN','BEN_92760_EFC_CORR_CCM');
/*
      return 'Corrected coverage calculation method';
      --
*/
    elsif p_label = 'PRVMODIFIED' then
      --
      return 'Modified participant rate value';
      --
    elsif p_label = 'PRVMODIFIED' then
      --
      return 'End dated participant rate value';
      --
    elsif p_label = 'NODTCOP' then
      --
      return fnd_message.get_string('BEN','BEN_92761_EFC_NO_COP');
      --
/*
      return 'Deleted option in plan';
      --
*/
    elsif p_label = 'NODTPRVABR' then
      --
      return fnd_message.get_string('BEN','BEN_92753_NO_PRVABR_EXISTS');
/*
      return 'The activity base rate attached to the participant rate value has'
             ||' been deleted. ';
*/
      --
    elsif p_label = 'NODTAPR' then
      --
      return fnd_message.get_string('BEN','BEN_92759_EFC_NO_APR');
      --
/*
      return 'Deleted actual premium';
      --
*/
    elsif p_label = 'NODTVPFABR' then
      --
      return 'Detached vapro from activity base rate';
      --
    elsif p_label = 'NOPEN' then
      --
      return fnd_message.get_string('BEN','BEN_92752_NO_PRVPEN_EXISTS');
/*
      return 'Deleted enrolment result';
*/
      --
    elsif p_label = 'CCMFLFX' then
      --
      return 'Flat amount coverage calculation method';
      --
    elsif p_label = 'ABRMCFLFX' then
      --
      return 'Flat amount activity base rate';
      --
    elsif p_label = 'ECRMCFLFX' then
      --
      return 'Flat amount enrolment rate';
      --
    elsif p_label = 'ABREVAEFLGY' then
      --
      return 'Enter value at enrolment activity base rate';
      --
    elsif p_label = 'ECRAOEFLGN' then
      --
      return 'ECRAOEFLGN: Assign on enrolment rate';
      --
    elsif p_label = 'NOPENEPEECR' then
      --
      return 'NOPENEPEECR: No enrolment rate exists for the elecatble choice. '
             ||'This must exist to perform an EFC adjustment. ';
      --
    elsif p_label = 'PRVENDDATED' then
      --
      return 'PRVENDDATED: The participant rate value rate end date has been populated. '
             ||'An EFC adjustment cannot be performed. ';
      --
    elsif p_label = 'ABRMCNULL' then
      --
      return fnd_message.get_string('BEN','BEN_92769_EFC_ABRMC_NULL');
/*
      return 'ABRMCNULL: The rate multiplier code for the activity base rate is null. '
             ||'This must be set to perform an EFC adjustment. ';
*/
      --
    elsif p_label = 'ABRVALNULLEVAEFN' then
      --
      return fnd_message.get_string('BEN','BEN_92770_EFC_ABRVAL_NULL');
/*
      return 'ABRVALNULLEVAEFN: The activity base rate value is null. This must be set '
             ||'when the value is not being entered at enrolment during an EFC adjustment. ';
*/
      --
    elsif p_label = 'CHILDABRVALNULLEVAEFN' then
      --
      return 'CHILDABRVALNULLEVAEFN: The child activity base rate value is null. This must be set '
             ||'when the value is not being entered at enrolment during an EFC adjustment. ';
      --
    elsif p_label = 'SQLPLUSELEPRVCORR' then
      --
      return 'Data modified via SQL*Plus';
      --
    elsif p_label = 'VOIDBACKPIL' then
      --
      return 'Backed out or voided life event';
      --
    elsif p_label = 'BACKVOIDPEN' then
      --
      return 'Backed out or voided enrolment result';
      --
    elsif p_label = 'PRVFLFX' then
      --
      return 'Flat amount participant rate value';
      --
    elsif p_label = 'NOASGPAY' then
      --
      return fnd_message.get_string('BEN','BEN_92751_NO_PRTT_ASG_PAY');
/*
      return 'No payroll is defined for the assignment';
*/
      --
    elsif p_label = 'NOASGPBB' then
      --
      return fnd_message.get_string('BEN','BEN_92757_NO_ASG_PAYBASIS');
/*
      return 'No pay basis is defined for the assignment';
*/
      --
    elsif p_label in ('NOASGPPP','NOSTSALSTCOMP') then
      --
      return fnd_message.get_string('BEN','BEN_92758_NO_ASG_SALARY');
/*
      return 'No pay proposal is defined for the assignment';
*/
      --
    elsif p_label = 'NOPAYPTPNXMTH' then
      --
      return fnd_message.get_string('BEN','BEN_92750_NO_FUT_PAY_PPP');
/*
      return 'No payroll period exists for rate start date plus one month of the payroll';
      --
*/
    elsif p_label = 'NODTPBB' then
      --
      return 'No person benefit balance exists for the benefit balance';
      --
    elsif p_label = 'APRNONMONUOM' then
      --
      return 'Non NCU currency for actual premium';
      --
    elsif p_label = 'ENBPOINTSUOM' then
      --
      return 'Points unit of measure for enrolment coverage';
      --
    elsif p_label = 'VPFPOINTSUOM' then
      --
      return 'Points unit of measure for variable rate profile';
      --
    elsif p_label = 'PGMPOINTSUOM' then
      --
      return 'Points unit of measure for program';
      --
/*
    elsif p_label = 'ENBMODS' then
      --
      return 'Enrolment coverage has been modified since it was created';
      --
*/
    elsif p_label = 'NULLUOM' then
      --
      return fnd_message.get_string('BEN','BEN_92762_EFC_NULL_UOM');
      --
/*
      return 'The UOM to be used for conversion is null.';
      --
*/
    elsif p_label = 'EUROUOM' then
      --
      return 'The UOM to be used for conversion is in Euros.';
      --
    elsif p_label = 'ABRAPREUROUOM' then
      --
      return 'The UOM from the actual premium which is attached to the activity '
             ||' base rate to be used for conversion is in Euros.';
      --
    elsif p_label = 'ABRNONMONUOM' then
      --
      return 'Non monetary unit of measure for the activity base rate.';
      --
    elsif p_label = 'VPFABRNONMONUOM' then
      --
      return 'Non monetary unit of measure for the activity base rate of the variable '
             ||' rate profile.';
      --
    elsif p_label = 'NOPLNCCMCVGMC' then
      --
      return fnd_message.get_string('BEN','BEN_92741_NO_PLN_CCM_ATTACH');
/*
      return 'No coverage calculation method is attached to the plan for coverage activity base rate. ';
*/
      --
    elsif p_label = 'NULLENBIDCVGMC' then
      --
      return 'The coverage is null for an activity base rate. ';
      --
    elsif p_label = 'NULLCOMP' then
      --
      return 'The compensation is null for an activity base rate. ';
      --
    elsif p_label = 'NOPRVABRDTIPV' then
      --
      return fnd_message.get_string('BEN','BEN_92763_EFC_NO_ABR_IPV');
/*
      return 'No input value exists for the element type which is attached to '
             ||' the activity base rate.';
*/
      --
    else
      --
      return nvl(p_label,'ZZZZZZZZZZZZZZZZZZZZ');
      --
    end if;
    --
  end;
  --
begin
  --
  if p_ent_scode = 'PEP' then
    --
    l_ent_desc := 'Eligibility';
    --
  elsif p_ent_scode = 'EPO' then
    --
    l_ent_desc := 'Eligibility option';
    --
  elsif p_ent_scode = 'ENB' then
    --
    l_ent_desc := 'Coverage';
    --
  elsif p_ent_scode = 'EPR' then
    --
    l_ent_desc := 'Enrolment premium';
    --
  elsif p_ent_scode = 'ECR' then
    --
    l_ent_desc := 'Enrolment rate';
    --
  elsif p_ent_scode = 'PRV' then
    --
    l_ent_desc := 'Participant rate value';
    --
  elsif p_ent_scode = 'EEV' then
    --
    l_ent_desc := 'Element entry value';
    --
  elsif p_ent_scode = 'BPL' then
    --
    l_ent_desc := 'Benefit provider ledger';
    --
  end if;
  --
  hr_efc_info.insert_line('-- ');
  hr_efc_info.insert_line('-- '||l_ent_desc||' details ');
  hr_efc_info.insert_line('-- ');
  --
  l_fatal_error_val_set := p_fatal_error_val_set;
  --
  l_rco_count    := p_rcoerr_val_set.count;
  l_fail_count   := p_failed_adj_val_set.count;
  --
  l_tabrow_count := p_adjustment_counts.tabrow_count;
  l_conv_count   := p_adjustment_counts.actconv_count;
  --
  if p_success_val_set.count > 0 then
    --
    l_dupval_set.delete;
    l_dupele_num := 0;
    l_dup_success_val_set.delete;
    l_unq_success_val_set.delete;
    l_unqele_num := 0;
    --
    for ele_num in p_success_val_set.first ..
      p_success_val_set.last
    loop
      --
      -- Note: Assigned to variable to avoid PLSQL error when adding
      --       in hv calculation for hr_api.g_eot-hr_api.g_sot.
      --
      l_enddays := nvl(p_success_val_set(ele_num).eed,hr_api.g_eot)-hr_api.g_sot;
      --
      l_hv := mod(p_success_val_set(ele_num).id,ben_hash_utility.get_hash_key)
              +nvl(p_success_val_set(ele_num).esd,hr_api.g_eot)-hr_api.g_sot
              +l_enddays
              ;
      --
      if l_hv is null then
        --
        l_dup_success_val_set(l_dupele_num) := p_success_val_set(ele_num);
        l_dupele_num := l_dupele_num+1;
        --
      elsif l_dupval_set.exists(l_hv) then
        --
        if (l_dupval_set(l_hv).unqval = p_success_val_set(ele_num).id
          and nvl(l_dupval_set(l_hv).esd,hr_api.g_eot) = nvl(p_success_val_set(ele_num).esd,hr_api.g_eot)
          and nvl(l_dupval_set(l_hv).eed,hr_api.g_eot) = nvl(p_success_val_set(ele_num).eed,hr_api.g_eot)
           )
          or p_success_val_set(ele_num).id is null
        then
          --
          l_dup_success_val_set(l_dupele_num) := p_success_val_set(ele_num);
          l_dupele_num := l_dupele_num+1;
          --
        end if;
        --
      else
        --
        l_dupval_set(l_hv).unqval :=  p_success_val_set(ele_num).id;
        l_dupval_set(l_hv).esd    :=  p_success_val_set(ele_num).esd;
        l_dupval_set(l_hv).eed    :=  p_success_val_set(ele_num).eed;
        l_unq_success_val_set(l_unqele_num) := p_success_val_set(ele_num);
        l_unqele_num := l_unqele_num+1;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  l_dupsuccval_count := l_dup_success_val_set.count;
  l_success_val_set  := l_unq_success_val_set;
  --
  if l_fatal_error_val_set.count > 0 then
    --
    l_dupval_set.delete;
    l_dup_excl_val_set.delete;
    l_unq_excl_val_set.delete;
    l_dupele_num := 0;
    l_unqele_num := 0;
    --
    for ele_num in l_fatal_error_val_set.first ..
      l_fatal_error_val_set.last
    loop
      --
      l_enddays := nvl(l_fatal_error_val_set(ele_num).eed,hr_api.g_eot)-hr_api.g_sot;
      --
      l_hv := mod(l_fatal_error_val_set(ele_num).id,ben_hash_utility.get_hash_key)
              +nvl(l_fatal_error_val_set(ele_num).esd,hr_api.g_eot)-hr_api.g_sot
              +l_enddays
              ;
      --
      if l_hv is null then
        --
        l_dup_excl_val_set(l_dupele_num) := l_fatal_error_val_set(ele_num);
        l_dupele_num := l_dupele_num+1;
        --
      elsif l_dupval_set.exists(l_hv) then
        --
        if (l_dupval_set(l_hv).unqval = l_fatal_error_val_set(ele_num).id
          and nvl(l_dupval_set(l_hv).esd,hr_api.g_eot) = nvl(l_fatal_error_val_set(ele_num).esd,hr_api.g_eot)
          and nvl(l_dupval_set(l_hv).eed,hr_api.g_eot) = nvl(l_fatal_error_val_set(ele_num).eed,hr_api.g_eot)
           )
          or l_fatal_error_val_set(ele_num).id is null
        then
          --
          l_dup_excl_val_set(l_dupele_num) := l_fatal_error_val_set(ele_num);
          l_dupele_num := l_dupele_num+1;
          --
        end if;
        --
      else
        --
        l_dupval_set(l_hv).unqval        := l_fatal_error_val_set(ele_num).id;
        l_dupval_set(l_hv).esd           := l_fatal_error_val_set(ele_num).esd;
        l_dupval_set(l_hv).eed           := l_fatal_error_val_set(ele_num).eed;
        l_unq_excl_val_set(l_unqele_num) := l_fatal_error_val_set(ele_num);
        l_unqele_num := l_unqele_num+1;
        --
      end if;
      --
    end loop;
    --
    -- Exclude private exclusions
    --
    if not p_disp_private then
      --
      l_tmp_set      := l_unq_excl_val_set;
      l_unq_excl_val_set.delete;
      l_public_count := 0;
      --
      for elenum in l_tmp_set.first..l_tmp_set.last
      loop
        --
        if l_tmp_set(elenum).faterr_type not in ('VALIDEXCLUSION'
                                                ,'OBSOLETEDATA'
                                                ,'UNSUPPORTTRANS'
                                                ,'POTENTIALCODEBUG'
                                                ,'FIXEDCODEBUG'
                                                ,'CODECHANGE'
                                                ,'ADJUSTBUG'
                                                )
        then
          --
          l_unq_excl_val_set(l_public_count) := l_tmp_set(elenum);
          l_public_count := l_public_count+1;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  l_dupexclval_count := l_dup_excl_val_set.count;
  l_fatal_error_val_set := l_unq_excl_val_set;
  --
  l_succ_count   := l_success_val_set.count;
  l_excl_count   := l_fatal_error_val_set.count;
  l_adjust_count := l_succ_count+l_rco_count+l_fail_count+l_excl_count;
  --
  if l_tabrow_count > 0 then
    --
    if l_succ_count > 0 then
      --
      l_succ_perc := (l_succ_count/l_adjust_count)*100;
      --
    else
      --
      l_succ_perc := 0;
      --
    end if;
    --
    if l_rco_count > 0 then
      --
      l_rco_perc := (l_rco_count/l_adjust_count)*100;
      --
    else
      --
      l_rco_perc := 0;
      --
    end if;
    --
    if l_fail_count > 0 then
      --
      l_fail_perc := (l_fail_count/l_adjust_count)*100;
      --
    else
      --
      l_fail_perc := 0;
      --
    end if;
    --
    if l_excl_count > 0 then
      --
      l_excl_perc := (l_excl_count/l_adjust_count)*100;
      --
    else
      --
      l_excl_perc := 0;
      --
    end if;
    --
    if p_disp_private then
      --
      hr_efc_info.insert_line('-- Convertable rows: '||l_tabrow_count);
      hr_efc_info.insert_line('-- Converted rows: '||l_conv_count);
      hr_efc_info.insert_line('-- Adjustable rows: '||l_adjust_count);
      hr_efc_info.insert_line('-- ');
      --
    end if;
    --
    hr_efc_info.insert_line('-- Successfully Adjusted rows: '||l_succ_count||' '||l_succ_perc||'% ');
    --
    if p_disp_private then
      --
      hr_efc_info.insert_line('--   Duplicate Succ rows: '||l_dupsuccval_count);
      --
    end if;
    --
    hr_efc_info.insert_line('-- Application errors: '||l_rco_count||' '||l_rco_perc||'% ');
    hr_efc_info.insert_line('-- Non Excluded failure rows: '||l_fail_count||' '||l_fail_perc||'% ');
    hr_efc_info.insert_line('-- Exclusion rows: '||l_excl_count||' '||l_excl_perc||'% ');
    --
    if p_disp_private then
      --
      hr_efc_info.insert_line('--   Duplicate Exclusion rows: '||l_dupexclval_count);
      --
    end if;
    --
    hr_efc_info.insert_line('-- ');
    --
  end if;
  --
  if p_rcoerr_val_set.count > 0 then
    --
    hr_efc_info.insert_line('-- '||p_rcoerr_val_set.count||' Application errors ');
    hr_efc_info.insert_line('-- ');
    --
    for errele_num in p_rcoerr_val_set.first ..
      p_rcoerr_val_set.last
    loop
      --
      hr_efc_info.insert_line(p_rcoerr_val_set(errele_num).id
                          ||' '||p_rcoerr_val_set(errele_num).esd
                          ||' '||p_rcoerr_val_set(errele_num).eed
                          ||' '||p_rcoerr_val_set(errele_num).bgp_id
                          ||' '||p_rcoerr_val_set(errele_num).rco_name
                          ||' '||to_char(p_rcoerr_val_set(errele_num).lud,'DD-MON-YYYY')
                          );
      --
      hr_efc_info.insert_line(' '||substr(p_rcoerr_val_set(errele_num).sql_error,1,240)
                          );
      --
    end loop;
    hr_efc_info.insert_line('-- ');
    --
  end if;
  --
  if p_failed_adj_val_set.count > 0 then
    --
    hr_efc_info.insert_line('-- '||p_failed_adj_val_set.count||' Adjustment failures ');
    hr_efc_info.insert_line('-- ');
    --
    for errele_num in p_failed_adj_val_set.first ..
      p_failed_adj_val_set.last
    loop
      --
      hr_efc_info.insert_line(p_failed_adj_val_set(errele_num).val_type
                          ||' '||p_failed_adj_val_set(errele_num).id
                          ||' '||p_failed_adj_val_set(errele_num).esd
                          ||' '||p_failed_adj_val_set(errele_num).eed
                          ||' '||p_failed_adj_val_set(errele_num).bgp_id
                          ||' '||nvl(to_char(p_failed_adj_val_set(errele_num).old_val1),'N ')
                          ||' '||nvl(to_char(p_failed_adj_val_set(errele_num).new_val1),'N ')
                          ||' '||nvl(to_char(p_failed_adj_val_set(errele_num).old_val2),'N ')
                          ||' '||nvl(to_char(p_failed_adj_val_set(errele_num).new_val2),'N ')
                          ||' '||nvl(to_char(p_failed_adj_val_set(errele_num).credt,'DD-MON-YYYY'),'NCD ')
                          ||' '||nvl(to_char(p_failed_adj_val_set(errele_num).lud,'DD-MON-YYYY'),'NLUD ')
                          ||' '||p_failed_adj_val_set(errele_num).id1
                          ||' '||p_failed_adj_val_set(errele_num).id2
                          ||' '||p_failed_adj_val_set(errele_num).code1
                          );
      --
    end loop;
    hr_efc_info.insert_line('-- ');
    --
  end if;
  --
  if l_fatal_error_val_set.count > 0 then
    --
    -- Get unique fatal errors
    --
    l_unqval_set.delete;
    l_unqele_num := 0;
    --
    for errele_num in l_fatal_error_val_set.first ..
      l_fatal_error_val_set.last
    loop
      --
      -- Populate null fatal error types with MISC
      --
      if l_fatal_error_val_set(errele_num).faterr_type is null then
        --
        l_fatal_error_val_set(errele_num).faterr_type := 'MISC';
        --
      end if;
      --
      -- Check if the error code exists in the unique list
      --
      if l_unqval_set.count > 0 then
        --
        l_found := FALSE;
        --
        for unqrow in l_unqval_set.first..l_unqval_set.last loop
          --
          if l_unqval_set(unqrow).unqval = l_fatal_error_val_set(errele_num).faterr_code
          then
            --
            l_found := TRUE;
            l_unqval_set(unqrow).count  := l_unqval_set(unqrow).count+1;
            --
            -- Check for more recent creation date
            --
            if nvl(l_fatal_error_val_set(errele_num).credt,hr_api.g_sot)
              > nvl(l_unqval_set(unqrow).mxcredt,hr_api.g_sot)
            then
              --
              l_unqval_set(unqrow).mxcredt := l_fatal_error_val_set(errele_num).credt;
              --
            end if;
            --
            -- Check for more oldest creation date
            --
            if nvl(l_fatal_error_val_set(errele_num).credt,hr_api.g_sot)
              < nvl(l_unqval_set(unqrow).mncredt,hr_api.g_sot)
            then
              --
              l_unqval_set(unqrow).mncredt := l_fatal_error_val_set(errele_num).credt;
              --
            end if;
            --
          end if;
          --
        end loop;
        --
        if not l_found then
          --
          l_unqval_set(l_unqele_num).unqval  := l_fatal_error_val_set(errele_num).faterr_code;
          l_unqval_set(l_unqele_num).unqval1 := l_fatal_error_val_set(errele_num).faterr_type;
          l_unqval_set(l_unqele_num).count   := 1;
          l_unqval_set(l_unqele_num).mxcredt := l_fatal_error_val_set(errele_num).credt;
          l_unqval_set(l_unqele_num).mncredt := l_fatal_error_val_set(errele_num).credt;
          l_unqele_num := l_unqele_num+1;
          --
        end if;
        --
      else
        --
        l_unqval_set(l_unqele_num).unqval  := l_fatal_error_val_set(errele_num).faterr_code;
        l_unqval_set(l_unqele_num).unqval1 := l_fatal_error_val_set(errele_num).faterr_type;
        l_unqval_set(l_unqele_num).count   := 1;
        l_unqval_set(l_unqele_num).mxcredt := l_fatal_error_val_set(errele_num).credt;
        l_unqval_set(l_unqele_num).mncredt := l_fatal_error_val_set(errele_num).credt;
        l_unqele_num := l_unqele_num+1;
        --
      end if;
      --
    end loop;
    --
    -- Calculate percentages
    --
    if l_unqval_set.count > 0 then
      --
      for ele_num in l_unqval_set.first..l_unqval_set.last
      loop
        --
        l_unqval_set(ele_num).percentage := round((l_unqval_set(ele_num).count/l_adjust_count)*100,2);
        --
      end loop;
      --
    end if;
    --
    -- Build type statistics
    --
    if l_unqval_set.count > 0 then
      --
      -- Get unique fatal errors
      --
      l_unqtype_set.delete;
      l_unqele_num := 0;
      --
      for errele_num in l_unqval_set.first .. l_unqval_set.last
      loop
        --
        -- Check if the error code exists in the unique list
        --
        if l_unqtype_set.count > 0 then
          --
          l_found := FALSE;
          --
          for unqrow in l_unqtype_set.first..l_unqtype_set.last loop
            --
            if l_unqtype_set(unqrow).unqval = l_unqval_set(errele_num).unqval1
            then
              --
              l_found := TRUE;
              l_unqtype_set(unqrow).count      := l_unqtype_set(unqrow).count+1;
              l_unqtype_set(unqrow).percentage := l_unqtype_set(unqrow).percentage+l_unqval_set(errele_num).percentage;
              --
              -- Check for more recent creation date
              --
              if nvl(l_unqval_set(errele_num).mxcredt,hr_api.g_sot)
                > nvl(l_unqtype_set(unqrow).mxcredt,hr_api.g_sot)
              then
                --
                l_unqtype_set(unqrow).mxcredt := l_unqval_set(errele_num).mxcredt;
                --
              end if;
              --
              -- Check for more recent creation date
              --
              if nvl(l_unqval_set(errele_num).mncredt,hr_api.g_sot)
                < nvl(l_unqtype_set(unqrow).mncredt,hr_api.g_sot)
              then
                --
                l_unqtype_set(unqrow).mncredt := l_unqval_set(errele_num).mncredt;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
          if not l_found then
            --
            l_unqtype_set(l_unqele_num).unqval     := l_unqval_set(errele_num).unqval1;
            l_unqtype_set(l_unqele_num).count      := 1;
            l_unqtype_set(l_unqele_num).mxcredt    := l_unqval_set(errele_num).mxcredt;
            l_unqtype_set(l_unqele_num).mncredt    := l_unqval_set(errele_num).mncredt;
            l_unqtype_set(l_unqele_num).percentage := l_unqval_set(errele_num).percentage;
            l_unqele_num := l_unqele_num+1;
            --
          end if;
          --
        else
          --
          l_unqtype_set(l_unqele_num).unqval     := l_unqval_set(errele_num).unqval1;
          l_unqtype_set(l_unqele_num).count      := 1;
          l_unqtype_set(l_unqele_num).mxcredt    := l_unqval_set(errele_num).mxcredt;
          l_unqtype_set(l_unqele_num).mncredt    := l_unqval_set(errele_num).mncredt;
          l_unqtype_set(l_unqele_num).percentage := l_unqval_set(errele_num).percentage;
          l_unqele_num := l_unqele_num+1;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Display unique fatal error types
    --
    if l_unqtype_set.count > 0 then
      --
      hr_efc_info.insert_line('-- '||l_unqtype_set.count||' Exclusion Type Categories ');
      hr_efc_info.insert_line('-- ');
      --
      for ele_num in l_unqtype_set.first..l_unqtype_set.last
      loop
        --
        l_disp_str := l_unqtype_set(ele_num).count
                      ||' '||l_unqtype_set(ele_num).percentage||'%'
                      ||' '||get_description(l_unqtype_set(ele_num).unqval);
        --
        if p_disp_private then
          --
          l_disp_str := l_disp_str||' Range between: '||l_unqtype_set(ele_num).mncredt
                        ||' and '||l_unqtype_set(ele_num).mxcredt;
          --
        end if;
        --
        hr_efc_info.insert_line(l_disp_str
                               );
        --
      end loop;
      hr_efc_info.insert_line('-- ');
      --
    end if;
    --
    -- Display unique fatal errors
    --
    if l_unqval_set.count > 0 then
      --
      hr_efc_info.insert_line('-- '||l_unqval_set.count||' Exclusion Types ');
      hr_efc_info.insert_line('-- ');
      --
      for ele_num in l_unqval_set.first..l_unqval_set.last
      loop
        --
        l_disp_str := l_unqval_set(ele_num).count
                      ||' '||l_unqval_set(ele_num).percentage||'%'
                      ||' '||get_description(l_unqval_set(ele_num).unqval)
                      ||' ('||get_description(l_unqval_set(ele_num).unqval1)||') ';
        --
        if p_disp_private then
          --
          l_disp_str := l_disp_str||' Range between: '||l_unqval_set(ele_num).mncredt
                        ||' and '||l_unqval_set(ele_num).mxcredt;
          --
        end if;
        --
        hr_efc_info.insert_line(l_disp_str
                               );
        --
      end loop;
      hr_efc_info.insert_line('-- ');
      --
    end if;
    --
    if p_disp_exclusions then
      --
      hr_efc_info.insert_line('-- '||l_fatal_error_val_set.count||' Exclusions ');
      hr_efc_info.insert_line('-- ');
      --
      for errele_num in l_fatal_error_val_set.first ..
        l_fatal_error_val_set.last
      loop
        --
        hr_efc_info.insert_line(l_fatal_error_val_set(errele_num).faterr_code
                            ||' '||l_fatal_error_val_set(errele_num).faterr_type
                            ||' '||l_fatal_error_val_set(errele_num).id
                            ||' '||l_fatal_error_val_set(errele_num).esd
                            ||' '||l_fatal_error_val_set(errele_num).val_type
                            ||' '||l_fatal_error_val_set(errele_num).old_val1
                            ||' '||l_fatal_error_val_set(errele_num).new_val1
                            ||' '||l_fatal_error_val_set(errele_num).ovn
                            ||' '||l_fatal_error_val_set(errele_num).bgp_id
                            ||' '||to_char(l_fatal_error_val_set(errele_num).credt,'DD-MON-YYYY')
                            ||' '||to_char(l_fatal_error_val_set(errele_num).lud,'DD-MON-YYYY')
                            ||' '||l_fatal_error_val_set(errele_num).cre_by
                            ||' '||l_fatal_error_val_set(errele_num).lu_by
                            ||' '||l_fatal_error_val_set(errele_num).id1
                            ||' '||l_fatal_error_val_set(errele_num).id2
                            ||' '||l_fatal_error_val_set(errele_num).code1
                            ||' '||l_fatal_error_val_set(errele_num).code2
                            ||' '||l_fatal_error_val_set(errele_num).code3
                            ||' '||l_fatal_error_val_set(errele_num).code4
                            );
        --
      end loop;
      hr_efc_info.insert_line('-- ');
      --
      if l_dup_excl_val_set.count > 0 then
        --
        hr_efc_info.insert_line('-- '||l_dup_excl_val_set.count||' Duplicate Exclusions ');
        hr_efc_info.insert_line('-- ');
        --
        for errele_num in l_dup_excl_val_set.first ..
          l_dup_excl_val_set.last
        loop
          --
          hr_efc_info.insert_line(l_dup_excl_val_set(errele_num).faterr_code
                              ||' '||l_dup_excl_val_set(errele_num).faterr_type
                              ||' '||l_dup_excl_val_set(errele_num).id
                              ||' '||l_dup_excl_val_set(errele_num).esd
                              ||' '||l_dup_excl_val_set(errele_num).val_type
                              ||' '||l_dup_excl_val_set(errele_num).old_val1
                              ||' '||l_dup_excl_val_set(errele_num).new_val1
                              ||' '||l_dup_excl_val_set(errele_num).ovn
                              ||' '||l_dup_excl_val_set(errele_num).bgp_id
                              ||' '||to_char(l_dup_excl_val_set(errele_num).credt,'DD-MON-YYYY')
                              ||' '||to_char(l_dup_excl_val_set(errele_num).lud,'DD-MON-YYYY')
                              ||' '||l_dup_excl_val_set(errele_num).cre_by
                              ||' '||l_dup_excl_val_set(errele_num).lu_by
                              ||' '||l_dup_excl_val_set(errele_num).id1
                              ||' '||l_dup_excl_val_set(errele_num).id2
                              ||' '||l_dup_excl_val_set(errele_num).code1
                              ||' '||l_dup_excl_val_set(errele_num).code2
                              ||' '||l_dup_excl_val_set(errele_num).code3
                              ||' '||l_dup_excl_val_set(errele_num).code4
                              );
          --
        end loop;
        --
      end if;
      hr_efc_info.insert_line('-- ');
      --
    end if;
    --
  end if;
  --
  if p_success_val_set.count > 0
    and p_disp_succeeds
  then
    --
    hr_efc_info.insert_line('-- '||l_success_val_set.count||' Successes ');
    hr_efc_info.insert_line('-- ');
    --
    for ele_num in l_success_val_set.first ..
      l_success_val_set.last
    loop
      --
      hr_efc_info.insert_line(l_success_val_set(ele_num).id
                          ||' '||l_success_val_set(ele_num).esd
                          ||' '||l_success_val_set(ele_num).eed
                          ||' '||l_success_val_set(ele_num).old_val1
                          ||' '||l_success_val_set(ele_num).new_val1
                          ||' '||l_success_val_set(ele_num).ovn
                          ||' '||l_success_val_set(ele_num).bgp_id
                          ||' '||to_char(l_success_val_set(ele_num).credt,'DD-MON-YYYY')
                          ||' '||to_char(l_success_val_set(ele_num).lud,'DD-MON-YYYY')
                          ||' '||l_success_val_set(ele_num).cre_by
                          ||' '||l_success_val_set(ele_num).lu_by
                          ||' '||l_success_val_set(ele_num).id1
                          ||' '||l_success_val_set(ele_num).id2
                          ||' '||l_success_val_set(ele_num).code1
                          ||' '||l_success_val_set(ele_num).code2
                          ||' '||l_success_val_set(ele_num).code3
                          ||' '||l_success_val_set(ele_num).code4
                          );
      --
    end loop;
    hr_efc_info.insert_line('-- ');
    --
    if l_dup_success_val_set.count > 0 then
      --
      hr_efc_info.insert_line('-- '||l_dup_success_val_set.count||' Duplicate Successes ');
      hr_efc_info.insert_line('-- ');
      --
      for ele_num in l_dup_success_val_set.first..l_dup_success_val_set.last
      loop
        --
        hr_efc_info.insert_line(l_dup_success_val_set(ele_num).id
                            ||' '||l_dup_success_val_set(ele_num).esd
                            ||' '||l_dup_success_val_set(ele_num).eed
                            ||' '||l_dup_success_val_set(ele_num).old_val1
                            ||' '||l_dup_success_val_set(ele_num).new_val1
                            ||' '||l_dup_success_val_set(ele_num).ovn
                            ||' '||l_dup_success_val_set(ele_num).bgp_id
                            ||' '||to_char(l_dup_success_val_set(ele_num).credt,'DD-MON-YYYY')
                            ||' '||to_char(l_dup_success_val_set(ele_num).lud,'DD-MON-YYYY')
                            ||' '||l_dup_success_val_set(ele_num).cre_by
                            ||' '||l_dup_success_val_set(ele_num).lu_by
                            ||' '||l_dup_success_val_set(ele_num).id2
                            ||' '||l_dup_success_val_set(ele_num).code1
                            ||' '||l_dup_success_val_set(ele_num).code2
                            ||' '||l_dup_success_val_set(ele_num).code3
                            ||' '||l_dup_success_val_set(ele_num).code4
                            );
        --
      end loop;
      hr_efc_info.insert_line('-- ');
      --
    end if;
    --
  end if;
  --
end DisplayEFCInfo;
--
end ben_efc_reporting;

/
