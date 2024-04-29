--------------------------------------------------------
--  DDL for Package Body BEN_TEST_HARNESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_TEST_HARNESS" as
/* $Header: bentsthn.pkb 120.0 2005/05/28 09:31:40 appldev noship $ */
--
g_package varchar2(50) := 'ben_test_harness.';
--
g_alertsev1reas_va      benutils.g_v2_150_table := benutils.g_v2_150_table();
g_alertsev1bftid_va     benutils.g_number_table := benutils.g_number_table();
g_alertsev1prevbftid_va benutils.g_number_table := benutils.g_number_table();
--
g_alertsev2reas_va      benutils.g_v2_150_table := benutils.g_v2_150_table();
g_alertsev2bftid_va     benutils.g_number_table := benutils.g_number_table();
--
g_alertsev1_en      pls_integer := 1;
g_alertsev2_en      pls_integer := 1;
--
PROCEDURE filter_clcode_nondiscreps
  (p_clcode_va         in out nocopy benutils.g_v2_150_table
  ,p_clcodecnt_va      in out nocopy benutils.g_number_table
  ,p_clsumovn_va       in out nocopy benutils.g_number_table
  ,p_clminesd_va       in out nocopy benutils.g_date_table
  ,p_clmineed_va       in out nocopy benutils.g_date_table
  )
IS
  --
  l_tmpclcode_va       benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_tmpclcodecnt_va    benutils.g_number_table := benutils.g_number_table();
  l_tmpclsumovn_va     benutils.g_number_table := benutils.g_number_table();
  l_tmpclminesd_va     benutils.g_date_table   := benutils.g_date_table();
  l_tmpclmineed_va     benutils.g_date_table   := benutils.g_date_table();
  --
  l_tmp_en             pls_integer;
  --
BEGIN
  --
  -- Filter out non discrepancy rollups
  --
  if p_clcode_va.count > 0 then
    --
    l_tmpclcode_va.delete;
    l_tmpclcodecnt_va.delete;
    l_tmpclsumovn_va.delete;
    l_tmpclminesd_va.delete;
    l_tmpclmineed_va.delete;
    l_tmp_en := 1;
    --
    for filtvaen in p_clcode_va.first..p_clcode_va.last
    loop
      --
      if instr(p_clcode_va(filtvaen),'WWBUGS') > 0
      then
        --
        null;
        --
      else
        --
        l_tmpclcode_va.extend(1);
        l_tmpclcodecnt_va.extend(1);
        l_tmpclsumovn_va.extend(1);
        l_tmpclminesd_va.extend(1);
        l_tmpclmineed_va.extend(1);
        --
        l_tmpclcode_va(l_tmp_en)    := p_clcode_va(filtvaen);
        l_tmpclcodecnt_va(l_tmp_en) := p_clcodecnt_va(filtvaen);
        l_tmpclsumovn_va(l_tmp_en)  := p_clsumovn_va(filtvaen);
        l_tmpclminesd_va(l_tmp_en)  := p_clminesd_va(filtvaen);
        l_tmpclmineed_va(l_tmp_en)  := p_clmineed_va(filtvaen);
        l_tmp_en := l_tmp_en+1;
        --
      end if;
      --
    end loop;
    --
    p_clcode_va    := l_tmpclcode_va;
    p_clcodecnt_va := l_tmpclcodecnt_va;
    p_clsumovn_va  := l_tmpclsumovn_va;
    p_clminesd_va  := l_tmpclminesd_va;
    p_clmineed_va  := l_tmpclmineed_va;
    --
  end if;
  --
end filter_clcode_nondiscreps;
--
PROCEDURE filter_discrepperids
  (p_perid_va     in            benutils.g_number_table
  ,p_mmperid_va   in out nocopy benutils.g_number_table
  ,p_mmperlud_va  in out nocopy benutils.g_date_table
  ,p_mmcombnm_va  in out nocopy benutils.g_varchar2_table
  ,p_mmcombnm2_va in out nocopy benutils.g_varchar2_table
  ,p_mmcombid_va  in out nocopy benutils.g_number_table
  ,p_mmcombid2_va in out nocopy benutils.g_number_table
  ,p_mmcnt_va     in out nocopy benutils.g_number_table
  ,p_exclperid_va in out nocopy benutils.g_number_table
  )
IS
  --
  l_newmmperid_va   benutils.g_number_table := benutils.g_number_table();
  l_newmmperlud_va  benutils.g_date_table := benutils.g_date_table();
  l_newmmcombnm_va  benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_newmmcombnm2_va benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_newmmcombid_va  benutils.g_number_table := benutils.g_number_table();
  l_newmmcombid2_va benutils.g_number_table := benutils.g_number_table();
  l_newmmcnt_va     benutils.g_number_table := benutils.g_number_table();
  --
  l_exclperid_va    benutils.g_number_table := benutils.g_number_table();
  --
  l_exclvaen        pls_integer;
  l_mmvaen          pls_integer;
  l_perid_match     boolean;
  --
  l_mmperlud_cnt    pls_integer;
  l_mmcombid_cnt    pls_integer;
  l_mmcombid2_cnt   pls_integer;
  --
BEGIN
  --
  -- Filter out application error person ids
  --
  if p_mmperid_va.count > 0
    and p_perid_va.count > 0
  then
    --
    l_mmvaen   := 1;
    l_exclvaen := 1;
    --
    l_mmperlud_cnt  := p_mmperlud_va.count;
    l_mmcombid2_cnt := p_mmcombid2_va.count;
    --
    for vaen in p_mmperid_va.first..p_mmperid_va.last
    loop
      --
      l_perid_match := FALSE;
      --
      for subvaen in p_perid_va.first..p_perid_va.last
      loop
        --
        if p_perid_va(subvaen) = p_mmperid_va(vaen)
        then
          --
          l_perid_match := TRUE;
          exit;
          --
        end if;
        --
      end loop;
      --
      if not l_perid_match
      then
        --
        l_newmmperid_va.extend(1);
        l_newmmperlud_va.extend(1);
        l_newmmcnt_va.extend(1);
        --
        l_newmmperid_va(l_mmvaen)  := p_mmperid_va(vaen);
        l_newmmcnt_va(l_mmvaen)     := p_mmcnt_va(vaen);
        --
        if l_mmcombid_cnt > 0
        then
          --
          l_newmmcombnm_va.extend(1);
          l_newmmcombid_va.extend(1);
          --
          l_newmmcombnm_va(l_mmvaen)  := p_mmcombnm_va(vaen);
          l_newmmcombid_va(l_mmvaen)  := p_mmcombid_va(vaen);
          --
        end if;
        --
        if l_mmperlud_cnt > 0
        then
          --
          l_newmmperlud_va(l_mmvaen) := p_mmperlud_va(vaen);
          --
        end if;
        --
        if l_mmcombid2_cnt > 0
        then
          --
          l_newmmcombnm2_va.extend(1);
          l_newmmcombid2_va.extend(1);
          l_newmmcombnm2_va(l_mmvaen) := p_mmcombnm2_va(vaen);
          l_newmmcombid2_va(l_mmvaen) := p_mmcombid2_va(vaen);
          --
        end if;
        --
        l_mmvaen := l_mmvaen+1;
        --
      else
        --
        -- Excludes
        --
        l_exclperid_va.extend(1);
        --
        l_exclperid_va(l_exclvaen) := p_mmperid_va(vaen);
        l_exclvaen := l_exclvaen+1;
        --
      end if;
      --
    end loop;
    --
    p_mmperid_va   := l_newmmperid_va;
    p_mmperlud_va  := l_newmmperlud_va;
    p_mmcombnm_va  := l_newmmcombnm_va;
    p_mmcombnm2_va := l_newmmcombnm2_va;
    p_mmcombid_va  := l_newmmcombid_va;
    p_mmcombid2_va := l_newmmcombid2_va;
    p_mmcnt_va     := l_newmmcnt_va;
    --
  end if;
  --
  p_exclperid_va := l_exclperid_va;
  --
end filter_discrepperids;
--
PROCEDURE filter_ledatachgperids
  (p_lud          in            date
  --
  ,p_mmperid_va   in out nocopy benutils.g_number_table
  ,p_mmperlud_va  in out nocopy benutils.g_date_table
  ,p_mmcombnm_va  in out nocopy benutils.g_varchar2_table
  ,p_mmcombnm2_va in out nocopy benutils.g_varchar2_table
  ,p_mmcombid_va  in out nocopy benutils.g_number_table
  ,p_mmcombid2_va in out nocopy benutils.g_number_table
  ,p_mmcnt_va     in out nocopy benutils.g_number_table
  ,p_exclperid_va in out nocopy benutils.g_number_table
  )
IS
  --
  l_newmmperid_va    benutils.g_number_table := benutils.g_number_table();
  l_newmmperlud_va   benutils.g_date_table := benutils.g_date_table();
  l_newmmcombnm_va   benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_newmmcombnm2_va  benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_newmmcombid_va   benutils.g_number_table := benutils.g_number_table();
  l_newmmcombid2_va  benutils.g_number_table := benutils.g_number_table();
  l_newmmcnt_va      benutils.g_number_table := benutils.g_number_table();
  --
  l_exclperid_va     benutils.g_number_table := benutils.g_number_table();
  --
  l_exclvaen         pls_integer;
  l_mmvaen           pls_integer;
  --
  l_mmperlud_cnt     pls_integer;
  l_mmcombid_cnt     pls_integer;
  l_mmcombid2_cnt    pls_integer;
  --
BEGIN
  --
  -- Check for person lud information
  --
  l_mmperlud_cnt := p_mmperlud_va.count;
  --
  if l_mmperlud_cnt > 0
  then
    --
    l_mmvaen   := 1;
    l_exclvaen := 1;
    --
    l_mmcombid_cnt  := p_mmcombid_va.count;
    l_mmcombid2_cnt := p_mmcombid2_va.count;
    --
    for vaen in p_mmperid_va.first..p_mmperid_va.last
    loop
      --
      -- Check for a person data change
      --
      if p_mmperlud_va(vaen) < p_lud
      then
        --
        l_newmmperid_va.extend(1);
        l_newmmperlud_va.extend(1);
        l_newmmcnt_va.extend(1);
        --
        l_newmmperid_va(l_mmvaen)   := p_mmperid_va(vaen);
        l_newmmperlud_va(l_mmvaen)  := p_mmperlud_va(vaen);
        l_newmmcnt_va(l_mmvaen)     := p_mmcnt_va(vaen);
        --
        if l_mmcombid_cnt > 0
        then
          --
          l_newmmcombnm_va.extend(1);
          l_newmmcombid_va.extend(1);
          --
          l_newmmcombnm_va(l_mmvaen)  := p_mmcombnm_va(vaen);
          l_newmmcombid_va(l_mmvaen)  := p_mmcombid_va(vaen);
          --
        end if;
        --
        if l_mmcombid2_cnt > 0
        then
          --
          l_newmmcombnm2_va.extend(1);
          l_newmmcombid2_va.extend(1);
          --
          l_newmmcombnm2_va(l_mmvaen) := p_mmcombnm2_va(vaen);
          l_newmmcombid2_va(l_mmvaen) := p_mmcombid2_va(vaen);
          --
        end if;
        --
        l_mmvaen := l_mmvaen+1;
        --
      else
        --
        -- Excludes
        --
        l_exclperid_va.extend(1);
        --
        l_exclperid_va(l_exclvaen) := p_mmperid_va(vaen);
        l_exclvaen := l_exclvaen+1;
        --
      end if;
      --
    end loop;
    --
    p_mmperid_va   := l_newmmperid_va;
    p_mmperlud_va  := l_newmmperlud_va;
    p_mmcombnm_va  := l_newmmcombnm_va;
    p_mmcombnm2_va := l_newmmcombnm2_va;
    p_mmcombid_va  := l_newmmcombid_va;
    p_mmcombid2_va := l_newmmcombid2_va;
    p_mmcnt_va     := l_newmmcnt_va;
    --
  end if;
  --
  p_exclperid_va := l_exclperid_va;
  --
end filter_ledatachgperids;
--
PROCEDURE get_appl_error_dets
  (p_bft_id       in            number
  --
  ,p_errmesscd_va in out nocopy benutils.g_v2_150_table
  ,p_mxperid_va   in out nocopy benutils.g_number_table
  ,p_errcnt_va    in out nocopy benutils.g_number_table
  ,p_errtot       in out nocopy number
  )
IS
  --
  l_errmesscd_va       benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_mxperid_va         benutils.g_number_table := benutils.g_number_table();
  l_errcnt_va          benutils.g_number_table := benutils.g_number_table();
  --
  l_errtot             pls_integer;
  --
  cursor c_gbenrepercdsum
    (c_bft_id in number
    )
  is
    select ERROR_MESSAGE_CODE,
           max(person_id) mx_perid,
           count(*) cnt
    from ben_reporting
    where benefit_action_id = c_bft_id
    and   ERROR_MESSAGE_CODE is not null
    group by ERROR_MESSAGE_CODE
    order by count(*) desc;
  --
BEGIN
  --
  open c_gbenrepercdsum
    (c_bft_id => p_bft_id
    );
  fetch c_gbenrepercdsum BULK COLLECT INTO l_errmesscd_va,
                                           l_mxperid_va,
                                           l_errcnt_va;
  close c_gbenrepercdsum;
  --
  l_errtot := 0;
  --
  if l_errmesscd_va.count > 0
  then
    --
    for vaen in l_errmesscd_va.first..l_errmesscd_va.last
    loop
      --
      l_errtot := l_errtot+l_errcnt_va(vaen);
      --
    end loop;
    --
  end if;
  --
  p_errmesscd_va := l_errmesscd_va;
  p_mxperid_va   := l_mxperid_va;
  p_errcnt_va    := l_errcnt_va;
  p_errtot       := l_errtot;
  --
end get_appl_error_dets;
--
procedure rollupcode_getrollupdesc
  (p_rollup_code in            varchar2
  --
  ,p_rollup_desc    out nocopy varchar2
  )
is
begin
  --
  if p_rollup_code = 'PIL'
  then
    --
    p_rollup_desc := 'Life Event';
    --
  elsif p_rollup_code = 'PILBCKDT'
  then
    --
    p_rollup_desc := 'Life Event Backed Out';
    --
  elsif p_rollup_code = 'PILSTRTD'
  then
    --
    p_rollup_desc := 'Life Event Started';
    --
  elsif p_rollup_code = 'PILPROCD'
  then
    --
    p_rollup_desc := 'Life Event Processed';
    --
  elsif p_rollup_code = 'PILVOIDD'
  then
    --
    p_rollup_desc := 'Life Event Voided';
    --
  elsif p_rollup_code = 'PEP'
  then
    --
    p_rollup_desc := 'Eligibility Program/PTIP/PLIP/Plan';
    --
  elsif p_rollup_code = 'PEPIE'
  then
    --
    p_rollup_desc := 'Ineligibility Program/PTIP/PLIP/Plan';
    --
  elsif p_rollup_code = 'PEPPGM'
  then
    --
    p_rollup_desc := 'Eligibility Program';
    --
  elsif p_rollup_code = 'PEPPTIP'
  then
    --
    p_rollup_desc := 'Eligibility Plan Type In Program';
    --
  elsif p_rollup_code = 'PEPPLN'
  then
    --
    p_rollup_desc := 'Eligibility Plan';
    --
  elsif p_rollup_code = 'PEPPLNIP'
  then
    --
    p_rollup_desc := 'Eligibility Plan Not In Program';
    --
  elsif p_rollup_code = 'PEPPLIP'
  then
    --
    p_rollup_desc := 'Eligibility Plan In Program';
    --
  elsif p_rollup_code = 'EPO'
  then
    --
    p_rollup_desc := 'Eligibility Option/OIPLIP';
    --
  elsif p_rollup_code = 'EPOIE'
  then
    --
    p_rollup_desc := 'Ineligibility Option/OIPLIP';
    --
  elsif p_rollup_code = 'EGD'
  then
    --
    p_rollup_desc := 'Dependent Eligibility';
    --
  elsif p_rollup_code = 'EPE'
  then
    --
    p_rollup_desc := 'Electability';
    --
  elsif p_rollup_code = 'EPEPLN'
  then
    --
    p_rollup_desc := 'Electability Plan';
    --
  elsif p_rollup_code = 'EPEOIPL'
  then
    --
    p_rollup_desc := 'Electability Option In Plan';
    --
  elsif p_rollup_code = 'EPEAUTOENR'
  then
    --
    p_rollup_desc := 'Electability Automatic Enrollment';
    --
  elsif p_rollup_code = 'EPECURRENR'
  then
    --
    p_rollup_desc := 'Electability Currently Enrolled';
    --
  elsif p_rollup_code = 'PEL'
  then
    --
    p_rollup_desc := 'Electable Program/Plan not in Program';
    --
  elsif p_rollup_code = 'ECC'
  then
    --
    p_rollup_desc := 'Electable Choice Certification';
    --
  elsif p_rollup_code = 'ENB'
  then
    --
    p_rollup_desc := 'Coverage';
    --
  elsif p_rollup_code = 'EPR'
  then
    --
    p_rollup_desc := 'Premium';
    --
  elsif p_rollup_code = 'ECR'
  then
    --
    p_rollup_desc := 'Enrolment Rates';
    --
  elsif p_rollup_code = 'ECRFLXCR'
  then
    --
    p_rollup_desc := 'Enrolment Rates Flex Credits';
    --
  elsif p_rollup_code = 'ECRSTD'
  then
    --
    p_rollup_desc := 'Enrolment Rates Standard';
    --
  elsif p_rollup_code = 'PDP'
  then
    --
    p_rollup_desc := 'Eligible Covered Dependent';
    --
  elsif p_rollup_code = 'PRV'
  then
    --
    p_rollup_desc := 'Participant rate value';
    --
  elsif p_rollup_code = 'PRVFLFX'
  then
    --
    p_rollup_desc := 'Participant rate value flat amount';
    --
  elsif p_rollup_code = 'PRVCVG'
  then
    --
    p_rollup_desc := 'Participant rate value multiple of coverage';
    --
  elsif p_rollup_code = 'PRVNSVU'
  then
    --
    p_rollup_desc := 'Participant rate value no standard values used';
    --
  elsif p_rollup_code = 'PRVCL'
  then
    --
    p_rollup_desc := 'Participant rate multiple of compensation';
    --
  elsif p_rollup_code = 'PRVSAREC'
  then
    --
    p_rollup_desc := 'Participant rate set annual rate equal coverage';
    --
  elsif p_rollup_code = 'PRVAP'
  then
    --
    p_rollup_desc := 'Participant rate multiple of premium';
    --
  elsif p_rollup_code = 'PRVRL'
  then
    --
    p_rollup_desc := 'Participant rate rule';
    --
  elsif p_rollup_code = 'PEN'
  then
    --
    p_rollup_desc := 'Enrolment Result';
    --
  elsif p_rollup_code = 'PENAUTO'
  then
    --
    p_rollup_desc := 'Enrolment Result Automatic';
    --
  elsif p_rollup_code = 'PENEXPL'
  then
    --
    p_rollup_desc := 'Enrolment Result Explicit';
    --
  elsif p_rollup_code = 'PENDFLT'
  then
    --
    p_rollup_desc := 'Enrolment Result Default';
    --
  elsif p_rollup_code = 'PENSSPND'
  then
    --
    p_rollup_desc := 'Enrolment Result Suspended';
    --
  elsif p_rollup_code = 'PENBCKDT'
  then
    --
    p_rollup_desc := 'Enrolment Result Backed Out';
    --
  elsif p_rollup_code = 'PENVOIDD'
  then
    --
    p_rollup_desc := 'Enrolment Result Voided';
    --
  elsif p_rollup_code = 'BPL'
  then
    --
    p_rollup_desc := 'Benefit Provider Ledger';
    --
  elsif p_rollup_code = 'PCM'
  then
    --
    p_rollup_desc := 'Communication';
    --
  elsif p_rollup_code = 'PERACT'
  then
    --
    p_rollup_desc := 'Person Action';
    --
  elsif p_rollup_code = 'PERACTPROC'
  then
    --
    p_rollup_desc := 'Person Action Processed';
    --
  elsif p_rollup_code = 'PERACTERR'
  then
    --
    p_rollup_desc := 'Person Action Errored';
    --
  elsif p_rollup_code = 'PERACTUNPROC'
  then
    --
    p_rollup_desc := 'Person Action Unprocessed';
    --
  elsif p_rollup_code = 'WWBUGS'
  then
    --
    p_rollup_desc := 'Applied Bug';
    --
  elsif p_rollup_code = 'WWBUGSBEN'
  then
    --
    p_rollup_desc := 'Applied BEN Bug';
    --
  elsif p_rollup_code = 'WWBUGSPER'
  then
    --
    p_rollup_desc := 'Applied PER Bug';
    --
  elsif p_rollup_code = 'WWBUGSPAY'
  then
    --
    p_rollup_desc := 'Applied PAY Bug';
    --
  end if;
  --
end;
--
function Var2Value_StripMltBlanks
  (p_var2_value in            varchar2
  ) return varchar2
is
  --
  l_char_cnt       pls_integer;
  l_str_length     pls_integer;
  --
  l_stripv2_value  long;
  l_var2_value     long;
  l_blankseq_count pls_integer;
  --
begin
  --
/*
    --
    -- Temporary
    --
    dbms_output.put_line(' BENTSTHN: length: '||length(p_var2_value)
                        ||' instr: '||instr(p_var2_value,' ')
                        );
    --
*/
  if instr(p_var2_value,' ') > 0
  then
    --
    l_var2_value := replace(replace(p_var2_value,fnd_global.local_chr(10),' '),fnd_global.local_chr(13),' ');
/*
      --
      -- Temporary
      --
      dbms_output.put_line(' BENTSTHN: length l_var2_value: '||length(l_var2_value)
                          );
      --
*/
    --
    l_char_cnt       := 1;
    l_str_length     := length(l_var2_value);
    l_stripv2_value  := null;
    l_blankseq_count := 0;
    --
    loop
      --
      if l_char_cnt >= l_str_length
      then
        --
        exit;
        --
      end if;
      --
      if substr(l_var2_value,l_char_cnt,1) <> ' '
      then
        --
        l_stripv2_value := l_stripv2_value||substr(l_var2_value,l_char_cnt,1);
        --
        l_blankseq_count := 0;
        --
      else
        --
        l_stripv2_value := l_stripv2_value||' ';
        --
        l_blankseq_count := 1;
        --
      end if;
      --
      l_char_cnt := l_char_cnt+1;
      --
    end loop;
/*
      --
      -- Temporary
      --
      dbms_output.put_line(' BENTSTHN: l_stripv2_value: '||substr(l_stripv2_value,200));
      --
*/
    --
  else
    --
    l_stripv2_value := p_var2_value;
    --
  end if;
  --
  return l_stripv2_value;
  --
end Var2Value_StripMltBlanks;
--
procedure Var2Value_Portion
  (p_var2_value      in            varchar2
  ,p_portion_length  in            number
  --
  ,p_v2_val_portions in out nocopy benutils.g_varchar2_table
  )
is
  --
  l_v2_val_portions      benutils.g_varchar2_table := benutils.g_varchar2_table();
  --
  l_v2_value_length      pls_integer;
  l_v2_value_char_count  pls_integer;
  l_string_portion_count pls_integer;
  l_v2charnum            pls_integer;
  --
begin
  --
  if p_var2_value is not null then
    --
    -- Check the length of the message
    --
    l_v2_value_length := length(p_var2_value);
    --
    if l_v2_value_length > p_portion_length then
      --
      -- Truncate the message text into 80 char portions
      --
      l_v2_value_char_count  := 0;
      l_string_portion_count := 0;
      --
      loop
        --
        -- Check if the varchar2 value character count is greater than
        -- the message length.
        --
        if l_v2_value_char_count > l_v2_value_length then
          exit;
        else
          --
          if l_v2_value_char_count > 0
          then
            --
            l_v2charnum := l_v2_value_char_count+1;
            --
          else
            --
            l_v2charnum := l_v2_value_char_count;
            --
          end if;
          --
          l_v2_val_portions.extend(1);
          l_v2_val_portions(l_string_portion_count+1) := substr(p_var2_value, l_v2charnum,p_portion_length);
          --
          l_string_portion_count := l_string_portion_count + 1;
          --
        end if;
        --
        l_v2_value_char_count := l_v2_value_char_count + p_portion_length;
        --
      end loop;
      --
    else
      --
      l_v2_val_portions.extend(1);
      l_v2_val_portions(1) := p_var2_value;
      --
    end if;
    --
  end if;
  --
  p_v2_val_portions := l_v2_val_portions;
  --
end Var2Value_Portion;
--
procedure NewBftAlertCheck
  (p_bft_id            in   number
  ,p_upperact_cnt      in   number
  ,p_ccroraerrreq_cnt  in   number
  ,p_ccrhanderrreq_cnt in   number
  ,p_oraerr_tot        in   number
  )
is
  --
  l_alert_reas varchar2(1000);
  --
begin
  --
  if p_upperact_cnt > 0
  then
    --
    -- Unprocessed person actions
    --
    l_alert_reas := ' UnprocPerAct('||p_upperact_cnt||')';
    --
    -- Check for concurrent request errors
    --
    if p_ccroraerrreq_cnt > 0
    then
      --
      l_alert_reas := l_alert_reas||':ConcReqErr('||p_ccroraerrreq_cnt||')';
      --
    end if;
    --
    if p_ccrhanderrreq_cnt > 0
    then
      --
      l_alert_reas := l_alert_reas||':ConcReqEnvErr('||p_ccrhanderrreq_cnt||')';
      --
    end if;
    --
    if p_oraerr_tot > 0
    then
      --
      l_alert_reas := l_alert_reas||':OraErr('||p_oraerr_tot||')';
      --
    end if;
    --
    g_alertsev1reas_va.extend(1);
    g_alertsev1bftid_va.extend(1);
    g_alertsev1prevbftid_va.extend(1);
    --
    g_alertsev1reas_va(g_alertsev1_en)      := l_alert_reas;
    g_alertsev1bftid_va(g_alertsev1_en)     := p_bft_id;
    g_alertsev1prevbftid_va(g_alertsev1_en) := null;
    g_alertsev1_en := g_alertsev1_en+1;
    --
  elsif p_upperact_cnt = 0
    and p_ccroraerrreq_cnt > 0
  then
    --
    -- Concurrent request errors
    --
    l_alert_reas := ' ConcReqErr('||p_ccroraerrreq_cnt||')';
    --
    if p_oraerr_tot > 0
    then
      --
      l_alert_reas := l_alert_reas||':OraErr('||p_oraerr_tot||')';
      --
    end if;
    --
    g_alertsev1reas_va.extend(1);
    g_alertsev1bftid_va.extend(1);
    g_alertsev1prevbftid_va.extend(1);
    --
    g_alertsev1reas_va(g_alertsev1_en)  := l_alert_reas;
    g_alertsev1bftid_va(g_alertsev1_en) := p_bft_id;
    g_alertsev1prevbftid_va(g_alertsev1_en) := null;
    g_alertsev1_en := g_alertsev1_en+1;
    --
  elsif p_upperact_cnt = 0
    and p_ccrhanderrreq_cnt = 0
    and p_oraerr_tot > 0
  then
    --
    -- Oracle errors no unprocessed person actions
    --
    l_alert_reas := p_oraerr_tot||' OraErr';
    --
    g_alertsev2reas_va.extend(1);
    g_alertsev2bftid_va.extend(1);
    --
    g_alertsev2reas_va(g_alertsev2_en)  := l_alert_reas;
    g_alertsev2bftid_va(g_alertsev2_en) := p_bft_id;
    g_alertsev2_en := g_alertsev2_en+1;
    --
  end if;
  --
end NewBftAlertCheck;
--
procedure PerActCompAlertCheck
  (p_bft_id           in   number
  ,p_prevbft_id       in   number
  ,p_oldprperact_cnt  in   number
  ,p_prperact_cnt     in   number
  ,p_olderrperact_cnt in   number
  ,p_errperact_cnt    in   number
  ,p_oldupperact_cnt  in   number
  ,p_upperact_cnt     in   number
  )
is
  --
  l_alert_reas        varchar2(1000);
  --
  l_prperact_discrep  number;
  l_errperact_discrep number;
  l_upperact_discrep  number;
  --
begin
  --
  -- Check for person action statistic discrepancies
  --
  l_prperact_discrep  := 0;
  l_errperact_discrep := 0;
  l_upperact_discrep  := 0;
  --
  if p_oldprperact_cnt <> p_prperact_cnt
  then
    --
    l_prperact_discrep := p_oldprperact_cnt-p_prperact_cnt;
    --
  elsif p_olderrperact_cnt <> p_errperact_cnt
  then
    --
    l_errperact_discrep := p_olderrperact_cnt-p_errperact_cnt;
    --
  elsif p_oldupperact_cnt <> p_upperact_cnt
  then
    --
    l_upperact_discrep := p_oldupperact_cnt-p_upperact_cnt;
    --
  end if;
  --
  if l_prperact_discrep > 0
  then
    --
    l_alert_reas := ' ProcPerActDisc('||l_prperact_discrep||')';
    --
    g_alertsev1reas_va.extend(1);
    g_alertsev1bftid_va.extend(1);
    g_alertsev1prevbftid_va.extend(1);
    --
    g_alertsev1reas_va(g_alertsev1_en)      := l_alert_reas;
    g_alertsev1bftid_va(g_alertsev1_en)     := p_bft_id;
    g_alertsev1prevbftid_va(g_alertsev1_en) := p_prevbft_id;
    g_alertsev1_en := g_alertsev1_en+1;
    --
  end if;
  --
  if l_errperact_discrep > 0
  then
    --
    -- Processed person actions
    --
    l_alert_reas := ' ErrPerActDisc('||l_errperact_discrep||')';
    --
    g_alertsev1reas_va.extend(1);
    g_alertsev1bftid_va.extend(1);
    g_alertsev1prevbftid_va.extend(1);
    --
    g_alertsev1reas_va(g_alertsev1_en)      := l_alert_reas;
    g_alertsev1bftid_va(g_alertsev1_en)     := p_bft_id;
    g_alertsev1prevbftid_va(g_alertsev1_en) := p_prevbft_id;
    g_alertsev1_en := g_alertsev1_en+1;
    --
  end if;
  --
  if l_upperact_discrep > 0
  then
    --
    l_alert_reas := ' ErrPerActDisc('||l_upperact_discrep||')';
    --
    g_alertsev1reas_va.extend(1);
    g_alertsev1bftid_va.extend(1);
    g_alertsev1prevbftid_va.extend(1);
    --
    g_alertsev1reas_va(g_alertsev1_en)      := l_alert_reas;
    g_alertsev1bftid_va(g_alertsev1_en)     := p_bft_id;
    g_alertsev1prevbftid_va(g_alertsev1_en) := p_prevbft_id;
    g_alertsev1_en := g_alertsev1_en+1;
    --
  end if;
  --
end PerActCompAlertCheck;
--
procedure BuildAlertStrVa
  (p_alertstr_va in out nocopy benutils.g_v2_150_table
  )
is
  --
  l_alertstr_va benutils.g_v2_150_table := benutils.g_v2_150_table();
  --
  l_alert_reas  varchar2(1000);
  --
begin
  --
  if g_alertsev1reas_va.count > 0
  then
    --
    for alertvaen in g_alertsev1reas_va.first..g_alertsev1reas_va.last
    loop
      --
      l_alertstr_va.extend(1);
      --
      if g_alertsev1prevbftid_va(alertvaen) is not null
      then
        --
        l_alertstr_va(alertvaen) := '-- ALERTSEV1:('||g_alertsev1bftid_va(alertvaen)
                                    ||')('||g_alertsev1prevbftid_va(alertvaen)
                                    ||') '||g_alertsev1reas_va(alertvaen);
        --
      else
        --
        l_alertstr_va(alertvaen) := '-- ALERTSEV1:('||g_alertsev1bftid_va(alertvaen)
                                    ||') '||g_alertsev1reas_va(alertvaen);
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if g_alertsev2reas_va.count > 0
  then
    --
    for alertvaen in g_alertsev2reas_va.first..g_alertsev2reas_va.last
    loop
      --
      l_alertstr_va.extend(1);
      l_alertstr_va(alertvaen) := '-- ALERTSEV2:('||g_alertsev2bftid_va(alertvaen)
                                    ||') '||g_alertsev2reas_va(alertvaen);
      --
    end loop;
    --
  end if;
  --
  p_alertstr_va := l_alertstr_va;
  --
end BuildAlertStrVa;
--
PROCEDURE process
  (errbuf                 out nocopy varchar2
  ,retcode                out nocopy number
  ,p_person_id         in     number   default null
  ,p_business_group_id in     number   default null
  ,p_days              in     number   default null
  ,p_baselines         in     number   default null
  ,p_submit_validate   in     varchar2 default 'Y'
  ,p_rollup_rbvs       in     varchar2 default 'Y'
  ,p_refresh_rollups   in     varchar2 default 'N'
  ,p_testcycle_type    in     varchar2 default null
  ,p_mode_cd           in     varchar2 default null
  --
  ,p_ler_id            in     number   default null
  ,p_pgm_id            in     number   default null
  ,p_process_date      in     date     default null
  )
IS
  --
  TYPE cur_type IS REF CURSOR;
  --
  c_bftinst_cur   cur_type;
  --
  type t_v2_4000_va is varray(10000000) of varchar2(4000);
  --
  Type MxBFTInstType is record
    (business_group_id number
    ,person_id         number
    ,ler_id            number
    ,process_date      date
    ,mx_bftid          number
    );
  --
  Type MxPILBGPInstType is record
    (business_group_id number
    ,process_date      date
    ,cnt               number
    );
  --
  Type MxPILLERInstType is record
    (business_group_id number
    ,ler_id            number
    ,process_date      date
    ,cnt               number
    );
  --
  Type MxPILPERInstType is record
    (business_group_id number
    ,person_id         number
    ,process_date      date
    ,cnt               number
    );
  --
  Type BFTInstType is record
    (benefit_action_id number
    ,business_group_id number
    ,person_id         number
    ,ler_id            number
    ,process_date      date
    );
  --
  Type BFTDetType is record
    (max_bftid         number
    ,process_date      date
    ,mode_cd           varchar2(100)
    ,business_group_id number
    ,BENFTS_GRP_ID     number
    ,person_id         number
    ,pgm_id            number
    ,pl_id             number
    ,ler_id            number
    ,opt_id            number
/*
    ,LF_EVT_OCRD_DT    date
*/
    ,max_credt         date
    ,request_id        number
    );
  --
  l_mxbft_inst         MxBFTInstType;
  l_mxpilbgp_inst      MxPILBGPInstType;
  l_mxpiller_inst      MxPILLERInstType;
  l_mxpilper_inst      MxPILPERInstType;
  l_bft_inst           BFTInstType;
  l_bft_dets           BFTDetType;
  --
  l_newbft_id_va       benutils.g_number_table := benutils.g_number_table();
  l_newbftmode_cd_va   benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_newbftbgp_id_va    benutils.g_number_table := benutils.g_number_table();
  l_newbftler_id_va    benutils.g_number_table := benutils.g_number_table();
  l_newbftopt_id_va    benutils.g_number_table := benutils.g_number_table();
  l_newbftper_id_va    benutils.g_number_table := benutils.g_number_table();
  l_newbftpl_id_va     benutils.g_number_table := benutils.g_number_table();
  l_newbftbfg_id_va    benutils.g_number_table := benutils.g_number_table();
  l_newbftpgm_id_va    benutils.g_number_table := benutils.g_number_table();
  l_newbftproc_dt_va   benutils.g_date_table   := benutils.g_date_table();
  l_newbftleodt_dt_va  benutils.g_date_table   := benutils.g_date_table();
  l_newbftmax_credt_va benutils.g_date_table   := benutils.g_date_table();
  l_newbftreqid_va     benutils.g_number_table := benutils.g_number_table();
  --
  l_clcode_va          benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_clcodecnt_va       benutils.g_number_table := benutils.g_number_table();
  l_clsumovn_va        benutils.g_number_table := benutils.g_number_table();
  l_clminesd_va        benutils.g_date_table   := benutils.g_date_table();
  l_clmineed_va        benutils.g_date_table   := benutils.g_date_table();
  l_clidstr_va         t_v2_4000_va            := t_v2_4000_va();
  --
  l_rbv_clcode_va      benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_rbv_clcodecnt_va   benutils.g_number_table := benutils.g_number_table();
  l_rbv_clsumovn_va    benutils.g_number_table := benutils.g_number_table();
  l_rbv_clminesd_va    benutils.g_date_table   := benutils.g_date_table();
  l_rbv_clmineed_va    benutils.g_date_table   := benutils.g_date_table();
  l_rbv_clidstr_va     t_v2_4000_va            := t_v2_4000_va();
  --
  l_mmclccode_va       benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_mmoclcount_va      benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_mmnclcount_va      benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_mtclccode_va       benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_mtoclcount_va      benutils.g_number_table := benutils.g_number_table();
  l_mtnclcount_va      benutils.g_number_table := benutils.g_number_table();
  --
  l_reptext_va         benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_num1_col           benutils.g_number_table := benutils.g_number_table();
  l_num2_col           benutils.g_number_table := benutils.g_number_table();
  l_num3_col           benutils.g_number_table := benutils.g_number_table();
  l_num4_col           benutils.g_number_table := benutils.g_number_table();
  l_num5_col           benutils.g_number_table := benutils.g_number_table();
  l_num6_col           benutils.g_number_table := benutils.g_number_table();
  l_num7_col           benutils.g_number_table := benutils.g_number_table();
  l_num8_col           benutils.g_number_table := benutils.g_number_table();
  l_num9_col           benutils.g_number_table := benutils.g_number_table();
  l_num10_col          benutils.g_number_table := benutils.g_number_table();
  l_num11_col          benutils.g_number_table := benutils.g_number_table();
  l_num12_col          benutils.g_number_table := benutils.g_number_table();
  l_num13_col          benutils.g_number_table := benutils.g_number_table();
  l_num14_col          benutils.g_number_table := benutils.g_number_table();
  l_num15_col          benutils.g_number_table := benutils.g_number_table();
  l_num16_col          benutils.g_number_table := benutils.g_number_table();
  l_num17_col          benutils.g_number_table := benutils.g_number_table();
  l_num18_col          benutils.g_number_table := benutils.g_number_table();
  l_var1_col           benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_var2_col           benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_var3_col           benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_var4_col           benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_var5_col           benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_var6_col           benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_var7_col           benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_var8_col           benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_var9_col           benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_var10_col          benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_var11_col          benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_var12_col          benutils.g_varchar2_table := benutils.g_varchar2_table();
  --
  l_mmperid_va         benutils.g_number_table := benutils.g_number_table();
  l_mmcombid_va        benutils.g_number_table := benutils.g_number_table();
  l_mmcombid2_va       benutils.g_number_table := benutils.g_number_table();
  l_mmcombid3_va       benutils.g_number_table := benutils.g_number_table();
  l_mmcombid4_va       benutils.g_number_table := benutils.g_number_table();
  l_mmcnt_va           benutils.g_number_table := benutils.g_number_table();
  l_mmcombnm_va        benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_mmcombnm2_va       benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_mmcombnm3_va       benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_mmcombnm4_va       benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_adfname_va         benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_adffilver_va       benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_adflud_va          benutils.g_date_table := benutils.g_date_table();
  --
  l_sql_str            long;
  l_sel_str            long;
  l_from_str           long;
  l_grpby_str          long;
  l_ordby_str          long;
  l_where_str          long;
  --
  l_st_date            date;
  l_end_date           date;
  --
  l_PPL_ID             number;
  l_PPL_OVN            number;
  l_benmngle_sqlerrm   varchar2(1000);
  --
  l_sqlstr             long;
  --
  l_vaen               pls_integer;
  --
  l_hist_duration      pls_integer;
  l_show_matches       boolean;
  --
  l_mmrltyp_rbvclcd_va   benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_mmrltyp_rbvclcd_vaen pls_integer;
  --
  l_mmperid_rbvclcd_va   benutils.g_v2_150_table := benutils.g_v2_150_table();
  --
  l_tmpmmclccode_va      benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_bugtype_va           benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_mmerrmesscd_va       benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_mmmxperid_va         benutils.g_number_table := benutils.g_number_table();
  l_mmerrcnt_va          benutils.g_number_table := benutils.g_number_table();
  l_errmesscd_va         benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_mxperid_va           benutils.g_number_table := benutils.g_number_table();
  l_errcnt_va            benutils.g_number_table := benutils.g_number_table();
  l_oraerrtext_va        benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_oraerrtextinst_va    benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_oraerrmxperid_va     benutils.g_number_table := benutils.g_number_table();
  l_oraerrcnt_va         benutils.g_number_table := benutils.g_number_table();
  l_bugpscode_va         benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_bugnum_va            benutils.g_number_table := benutils.g_number_table();
  l_buglud_va            benutils.g_date_table := benutils.g_date_table();
  l_tmpmmerrmesscd_va    benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_tmpmmmxperid_va      benutils.g_number_table := benutils.g_number_table();
  l_tmpmmerrcnt_va       benutils.g_number_table := benutils.g_number_table();
  --
  l_apperrtypdiscr_messcd_va benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_apperrtypdiscr_cnt_va    benutils.g_number_table := benutils.g_number_table();
  l_perid_va1             benutils.g_number_table := benutils.g_number_table();
  l_perid_va2             benutils.g_number_table := benutils.g_number_table();
  l_periddiscrep_perid_va benutils.g_number_table := benutils.g_number_table();
  l_periddiscrep_errcd_va benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_mmperlud_va           benutils.g_date_table := benutils.g_date_table();
  l_mmexclperid_va        benutils.g_number_table := benutils.g_number_table();
  l_newapperr_peridva     benutils.g_number_table := benutils.g_number_table();
  l_mmexclperid_nwva      benutils.g_number_table := benutils.g_number_table();
  l_mmexclperid_leva      benutils.g_number_table := benutils.g_number_table();
  --
  l_text_va               benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_ccrerrcomptxt_va      benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_ccrhanderrcomptxt_va  benutils.g_varchar2_table := benutils.g_varchar2_table();
  --
  l_alertstr_va           benutils.g_v2_150_table := benutils.g_v2_150_table();
  --
  l_mm_elenum          pls_integer;
  l_mt_elenum          pls_integer;
  --
  l_mxbft_lud          date;
  l_thnbft_id          number;
  l_thnbft_ovn         number;
  l_reptext_en         pls_integer;
  --
  l_bgp_name           varchar2(1000);
  l_per_fullname       varchar2(1000);
  l_rollup_desc        varchar2(1000);
  --
  l_days               pls_integer;
  l_pgm_name           varchar2(1000);
  l_ler_name           varchar2(1000);
  l_opt_name           varchar2(1000);
  --
  l_rbvcode_match      boolean;
  --
  l_pln_name           varchar2(1000);
  --
  l_bugvaen            pls_integer;
  l_tmpvaen            pls_integer;
  --
  l_apperr_cnt         pls_integer;
  l_pacterr_cnt        pls_integer;
  l_pactup_cnt         pls_integer;
  l_pactproc_cnt       pls_integer;
  l_oraerr_en          pls_integer;
  l_tmpmmerrmesscd_en  pls_integer;
  l_errfound           boolean;
  l_mmapperr_tot       pls_integer;
  l_apperr_tot         pls_integer;
  l_apperrtyp_discr_en pls_integer;
  l_check_match        boolean;
  l_periddiscrep_en    pls_integer;
  --
  l_baselines          number;
  l_baseline_cnt       number;
  l_discrepancy        boolean;
  --
  l_mmcombid_cnt       pls_integer;
  l_mmcombid2_cnt      pls_integer;
  l_mmperlud_cnt       pls_integer;
  --
  l_reptext            varchar2(150);
  --
  l_rollref_cnt        pls_integer;
  l_env_errors         boolean;
  --
  l_mmapperrfilt_cnt   pls_integer;
  l_mmledatafilt_cnt   pls_integer;
  --
  l_oraerr_text        long;
  l_prevbft_id         number;
  l_v2esecs            varchar2(150);
  l_esecs              number;
  l_ehrs               number;
  l_ehrmins            number;
  l_prperact_cnt       number;
  l_errperact_cnt      number;
  l_upperact_cnt       number;
  l_tphr               number;
  l_bbrthread_cnt      number;
  l_thread_mxdursecs   number;
  l_thread_mndursecs   number;
  l_thread_mxchkcnt    number;
  l_thread_mnchkcnt    number;
  --
  l_ccrreq_cnt         number;
  l_ccrcompreq_cnt     number;
  l_ccrrunreq_cnt      number;
  l_ccrerrreq_cnt      number;
  l_ccrscdtreq_cnt     number;
  l_ccrscddreq_cnt     number;
  l_ccrscdgreq_cnt     number;
  l_ccrscdxreq_cnt     number;
  l_ccrscdireq_cnt     number;
  l_ccrscdqreq_cnt     number;
  --
  l_ccroraerrreq_cnt   number;
  l_ccrhanderrreq_cnt  number;
  l_ccrapperrreq_cnt   number;
  --
  l_alertsev1_en       pls_integer;
  l_alertsev2_en       pls_integer;
  l_alert_reas         varchar2(1000);
  l_oraerr_tot         pls_integer;
  --
  l_oldprperact_cnt    pls_integer;
  l_olderrperact_cnt   pls_integer;
  l_oldupperact_cnt    pls_integer;
  --
  cursor c_bftdets
    (c_bft_id number
    )
  is
    select bft.last_update_date
    from ben_benefit_actions bft
    where bft.benefit_action_id = c_bft_id;
  --
  l_bftdets c_bftdets%rowtype;
  --
  cursor c_maxpildets
    (c_per_id number
    ,c_ler_id number
    )
  is
    select pil.ler_id,
           pil.LF_EVT_OCRD_DT
    from ben_per_in_ler pil
    where pil.per_in_ler_id =
      (select max(pil1.per_in_ler_id)
       from ben_per_in_ler pil1
       where pil1.person_id = pil.person_id
       and pil1.PER_IN_LER_STAT_CD not in ('VOIDD','BCKDT')
      )
    and pil.person_id = c_per_id
    and pil.ler_id = c_ler_id;
  --
  l_maxpildets c_maxpildets%rowtype;
  --
  cursor c_rbvdets
    (c_bft_id in number
    )
  is
    select rbv.rollup_code,
           rbv.rollup_count,
           rbv.rollup_sumovn,
           rbv.rollup_minesd,
           rbv.rollup_mineed,
           rbv.rollup_id_string
    from ben_rollup_rbv_summary rbv,
         ben_batch_actions pba
    where pba.batch_id = c_bft_id
    and   rbv.batch_action_id = pba.batch_action_id
    and   rbv.rollup_count > 0
    order by rbv.rollup_id;
  --
  cursor c_ghistbftdets
    (c_duration      in number
    ,c_mode_cd       in varchar2
    ,c_process_date  in date
    ,c_bgp_id        in number
    ,c_ler_id        in number
    ,c_per_id        in number
    ,c_pgm_id        in number
    ,c_pl_id         in number
    ,c_opt_id        in number
    ,c_bfg_id        in number
    ,c_bft_credt     in date
    )
  is
    select bft.benefit_action_id,
           bft.mode_cd,
           bft.process_date,
           bft.last_update_date,
           bft.business_group_id,
           bft.BENFTS_GRP_ID,
           bft.person_id,
           bft.pgm_id,
           bft.pl_id,
           bft.COMP_SELECTION_RL,
           bft.AUDIT_LOG_FLAG,
           bft.VALIDATE_FLAG,
           bft.LF_EVT_OCRD_DT
    from ben_benefit_actions bft
    where bft.last_update_date > c_bft_credt-c_duration
    and   bft.last_update_date < c_bft_credt
    and   bft.mode_cd                   = c_mode_cd
    and   bft.process_date              = c_process_date
    and   bft.business_group_id         = c_bgp_id
    and   nvl(bft.ler_id,-1)            = nvl(c_ler_id,-1)
    and   nvl(bft.person_id,-1)         = nvl(c_per_id,-1)
    and   nvl(bft.pgm_id,-1)            = nvl(c_pgm_id,-1)
    and   nvl(bft.pl_id,-1)             = nvl(c_pl_id,-1)
    and   nvl(bft.opt_id,-1)            = nvl(c_opt_id,-1)
    and   nvl(bft.BENFTS_GRP_ID,-1)     = nvl(c_bfg_id,-1)
    and   bft.VALIDATE_FLAG = 'B'
    and exists
      (select 1
       from ben_batch_actions pba
       where pba.batch_id = bft.benefit_action_id
      )
    order by bft.benefit_action_id desc;
  --
  cursor c_bgp_dets
    (c_bgp_id number
    )
  is
    select bgp.name
    from per_business_groups bgp
    where bgp.business_group_id = c_bgp_id;
  --
  cursor c_perdets
    (c_per_id number
    )
  is
    select per.full_name
    from per_all_people_f per
    where per.person_id = c_per_id;
  --
  cursor c_pgmdets
    (c_pgm_id number
    )
  is
    select pgm.name
    from ben_pgm_f pgm
    where pgm.pgm_id = c_pgm_id;
  --
  cursor c_plndets
    (c_pl_id number
    )
  is
    select pln.name
    from ben_pl_f pln
    where pln.pl_id = c_pl_id;
  --
  cursor c_lerdets
    (c_ler_id number
    )
  is
    select ler.name
    from ben_ler_f ler
    where ler.ler_id = c_ler_id;
  --
  cursor c_optdets
    (c_opt_id number
    )
  is
    select opt.name
    from ben_opt_f opt
    where opt.opt_id = c_opt_id;
  --
  cursor c_gbenreporaerrinst
    (c_bft_id in number
    )
  is
    select text
    from ben_reporting
    where benefit_action_id = c_bft_id
    and   text like '%ORA-%'
    order by THREAD_ID, REPORTING_ID;
  --
  cursor c_adfiles
    (c_basebft_id number
    ,c_bft_id     number
    )
  is
    select adf.FILENAME,
           adv.VERSION,
           adv.last_update_date
    from ad_files adf,
         AD_FILE_VERSIONS adv
    where adf.file_id = adv.file_id
    and adf.LAST_UPDATE_DATE >
      (select bft.last_update_date
       from ben_benefit_actions bft
       where bft.benefit_action_id = c_basebft_id)
    and adf.LAST_UPDATE_DATE <
      (select bft.last_update_date
       from ben_benefit_actions bft
       where bft.benefit_action_id = c_bft_id)
    and adf.APP_SHORT_NAME = 'BEN'
    and adf.SUBDIR = 'patch/115/sql'
    order by adv.last_update_date desc;
  --
/*
  cursor c_prodbugs
    (c_basebft_id number
    ,c_bft_id     number
    )
  is
    select adb.APPLICATION_SHORT_NAME,
           adb.BUG_NUMBER,
           adb.last_update_date
    from ad_bugs adb
    where adb.LAST_UPDATE_DATE >
      (select bft.last_update_date
       from ben_benefit_actions bft
       where bft.benefit_action_id = c_basebft_id)
    and adb.LAST_UPDATE_DATE <
      (select bft.last_update_date
       from ben_benefit_actions bft
       where bft.benefit_action_id = c_bft_id)
    and adb.APPLICATION_SHORT_NAME = 'BEN'
    order by adb.last_update_date desc;
  --
*/
  cursor c_bfterrcdperids
    (c_bft_id number
    ,c_err_cd varchar2
    )
  is
    select rep.person_id
    from ben_reporting rep
    where rep.benefit_action_id  = c_bft_id
    and   rep.ERROR_MESSAGE_CODE = c_err_cd;
  --
  cursor c_bpidets
    (c_bft_id number
    )
  is
    select bpi.ELPSD_TM
    from BEN_BATCH_PROC_INFO bpi
    where bpi.benefit_action_id = c_bft_id;
  --
  procedure PersonActionStats
    (p_bft_id        number
    --
    ,p_prperact_cnt  in out nocopy number
    ,p_errperact_cnt in out nocopy number
    ,p_upperact_cnt  in out nocopy number
    )
  is
    --
    l_pr_cnt  number;
    l_err_cnt number;
    l_up_cnt  number;
    --
    cursor c_prperact
      (c_bft_id number
      )
    is
      select count(*)
      from ben_person_actions
      where benefit_action_id = c_bft_id
      and   action_status_cd = 'P';
    --
    cursor c_errperact
      (c_bft_id number
      )
    is
      select count(*)
      from ben_person_actions
      where benefit_action_id = c_bft_id
      and   action_status_cd = 'E';
    --
    cursor c_upperact
      (c_bft_id number
      )
    is
      select count(*)
      from ben_person_actions
      where benefit_action_id = c_bft_id
      and   action_status_cd = 'U';
    --
  begin
    --
    l_pr_cnt  := 0;
    l_err_cnt := 0;
    l_up_cnt  := 0;
    --
    open c_prperact
      (c_bft_id => p_bft_id
      );
    fetch c_prperact into l_pr_cnt;
    close c_prperact;
    --
    open c_errperact
      (c_bft_id => p_bft_id
      );
    fetch c_errperact into l_err_cnt;
    close c_errperact;
    --
    open c_upperact
      (c_bft_id => p_bft_id
      );
    fetch c_upperact into l_up_cnt;
    close c_upperact;
    --
    p_prperact_cnt  := l_pr_cnt;
    p_errperact_cnt := l_err_cnt;
    p_upperact_cnt  := l_up_cnt;
    --
  end PersonActionStats;
  --
  procedure BBRThreadStats
    (p_bft_id      in            number
    --
    ,p_thread_cnt  in out nocopy number
    ,p_mxdursecs   in out nocopy number
    ,p_mndursecs   in out nocopy number
    ,p_mxchkcnt    in out nocopy number
    ,p_mnchkcnt    in out nocopy number
    )
  is
    --
    l_lul_va        benutils.g_number_table := benutils.g_number_table();
    l_bftcredt_va   benutils.g_date_table   := benutils.g_date_table();
    l_lud_va        benutils.g_date_table   := benutils.g_date_table();
    l_cnt_va        benutils.g_number_table := benutils.g_number_table();
    l_lultotsecs_va benutils.g_number_table := benutils.g_number_table();
    l_lulavgsecs_va benutils.g_number_table := benutils.g_number_table();
    --
    l_thread_cnt    number;
    l_mx_en         pls_integer;
    l_mn_en         pls_integer;
    l_mxdursecs     pls_integer;
    l_mndursecs     pls_integer;
    l_mxchkcnt      pls_integer;
    l_mnchkcnt      pls_integer;
    --
    cursor c_gthreads
      (c_bft_id in number
      )
    is
      select bbr.last_update_login,
             bft.creation_date,
             max(bbr.last_update_date) max_lud,
             count(*) cnt,
             round((max(bbr.last_update_date)-bft.creation_date)*(24*3600),2) tot_secs,
             round(((max(bbr.last_update_date)-bft.creation_date)*(24*3600))/count(*),2) avg_secs
      from ben_batch_ranges bbr,
           ben_benefit_actions bft
      where bbr.benefit_action_id = c_bft_id
      and   bbr.benefit_action_id = bft.benefit_action_id
      group by bbr.last_update_login,
               bft.creation_date
      order by count(*) desc;
    --
  begin
    --
    open c_gthreads
      (c_bft_id => p_bft_id
      );
    fetch c_gthreads BULK COLLECT INTO l_lul_va,
                                       l_bftcredt_va,
                                       l_lud_va,
                                       l_cnt_va,
                                       l_lultotsecs_va,
                                       l_lulavgsecs_va;
    close c_gthreads;
    --
    l_thread_cnt := l_lul_va.count;
    --
    if l_lultotsecs_va.count > 0
    then
      --
      l_mx_en := l_lultotsecs_va.first;
      l_mn_en := l_lultotsecs_va.last;
      --
      l_mxdursecs  := l_lultotsecs_va(l_mx_en);
      l_mndursecs  := l_lultotsecs_va(l_mn_en);
      l_mxchkcnt   := l_cnt_va(l_mx_en);
      l_mnchkcnt   := l_cnt_va(l_mn_en);
      --
    else
      --
      l_mxdursecs  := 0;
      l_mndursecs  := 0;
      l_mxchkcnt   := 0;
      l_mnchkcnt   := 0;
      --
    end if;
    --
    p_thread_cnt := l_thread_cnt;
    p_mxdursecs  := l_mxdursecs;
    p_mndursecs  := l_mndursecs;
    p_mxchkcnt   := l_mxchkcnt;
    p_mnchkcnt   := l_mnchkcnt;
    --
  end BBRThreadStats;
  --
  procedure CCRequestStats
    (p_bft_id               in            number
    --
    ,p_ccrreq_cnt           in out nocopy number
    ,p_ccrcompreq_cnt       in out nocopy number
    ,p_ccrrunreq_cnt        in out nocopy number
    ,p_ccrerrreq_cnt        in out nocopy number
    ,p_ccrscdtreq_cnt       in out nocopy number
    ,p_ccrscddreq_cnt       in out nocopy number
    ,p_ccrscdgreq_cnt       in out nocopy number
    ,p_ccrscdxreq_cnt       in out nocopy number
    ,p_ccrscdireq_cnt       in out nocopy number
    ,p_ccrscdqreq_cnt       in out nocopy number
    ,p_ccroraerrreq_cnt     in out nocopy number
    ,p_ccrhanderrreq_cnt    in out nocopy number
    ,p_ccrapperrreq_cnt     in out nocopy number
    ,p_ccrerrcomptxt_va     in out nocopy benutils.g_varchar2_table
    ,p_ccrhanderrcomptxt_va in out nocopy benutils.g_varchar2_table
    )
  is
    --
    l_reqid_va          benutils.g_number_table := benutils.g_number_table();
    l_ospid_va          benutils.g_number_table := benutils.g_number_table();
    l_ossid_va          benutils.g_number_table := benutils.g_number_table();
    l_parreqid_va       benutils.g_number_table := benutils.g_number_table();
    l_phcode_va         benutils.g_varchar2_table := benutils.g_varchar2_table();
    l_stcode_va         benutils.g_varchar2_table := benutils.g_varchar2_table();
    l_comptxt_va        benutils.g_varchar2_table := benutils.g_varchar2_table();
    l_reqchkcnt_va      benutils.g_number_table := benutils.g_number_table();
    --
    l_errcomptxt_va     benutils.g_varchar2_table := benutils.g_varchar2_table();
    l_handerrcomptxt_va benutils.g_varchar2_table := benutils.g_varchar2_table();
    --
    l_req_cnt           number;
    l_compreq_cnt       number;
    l_runreq_cnt        number;
    l_errreq_cnt        number;
    l_scdtreq_cnt       number;
    l_scddreq_cnt       number;
    l_scdgreq_cnt       number;
    l_scdxreq_cnt       number;
    l_scdireq_cnt       number;
    l_scdqreq_cnt       number;
    --
    l_oraerrreq_cnt     number;
    l_handerrreq_cnt    number;
    l_apperrreq_cnt     number;
    --
    l_errcomp_en        pls_integer;
    l_handerrcomp_en    pls_integer;
    --
    cursor c_fndreqstats
      (c_bft_id number
      )
    is
      select ccr.request_id,
             ccr.ORACLE_PROCESS_ID,
             ccr.ORACLE_SESSION_ID,
             ccr.PARENT_REQUEST_ID,
             ccr.phase_code,
             ccr.status_code,
             substr(replace(replace(ccr.completion_text,fnd_global.local_chr(10),' ')
                                             ,fnd_global.local_chr(13),' '),1,1000),
             count(*)
      from fnd_concurrent_requests ccr,
           ben_benefit_actions bft,
           ben_batch_ranges bbr
      where ccr.parent_request_id = bft.request_id
      and   bbr.last_update_login = ccr.last_update_login
      and   bft.benefit_action_id = bbr.benefit_action_id
      and   bft.benefit_action_id = c_bft_id
      group by ccr.request_id,
               ccr.ORACLE_PROCESS_ID,
               ccr.ORACLE_SESSION_ID,
               ccr.PARENT_REQUEST_ID,
               ccr.phase_code,
               ccr.status_code,
               substr(replace(replace(ccr.completion_text,fnd_global.local_chr(10),' ')
                                             ,fnd_global.local_chr(13),' '),1,1000);
    --
    cursor c_fndparreqstats
      (c_bft_id number
      )
    is
      select ccr.request_id,
             ccr.ORACLE_PROCESS_ID,
             ccr.ORACLE_SESSION_ID,
             ccr.PARENT_REQUEST_ID,
             ccr.phase_code,
             ccr.status_code,
             substr(replace(replace(ccr.completion_text,fnd_global.local_chr(10),' ')
                                             ,fnd_global.local_chr(13),' '),1,1000),
             count(*)
      from fnd_concurrent_requests ccr,
           ben_benefit_actions bft
      where ccr.request_id = bft.request_id
      and   bft.benefit_action_id = c_bft_id
      group by ccr.request_id,
               ccr.ORACLE_PROCESS_ID,
               ccr.ORACLE_SESSION_ID,
               ccr.PARENT_REQUEST_ID,
               ccr.phase_code,
               ccr.status_code,
               substr(replace(replace(ccr.completion_text,fnd_global.local_chr(10),' ')
                                             ,fnd_global.local_chr(13),' '),1,1000);
    --
  begin
    --
    open c_fndreqstats
      (c_bft_id => p_bft_id
      );
    fetch c_fndreqstats BULK COLLECT INTO l_reqid_va,
                                          l_ospid_va,
                                          l_ossid_va,
                                          l_parreqid_va,
                                          l_phcode_va,
                                          l_stcode_va,
                                          l_comptxt_va,
                                          l_reqchkcnt_va;
    close c_fndreqstats;
    --
    l_compreq_cnt := 0;
    l_runreq_cnt  := 0;
    l_errreq_cnt  := 0;
    l_scdtreq_cnt := 0;
    l_scddreq_cnt := 0;
    l_scdgreq_cnt := 0;
    l_scdxreq_cnt := 0;
    l_scdireq_cnt := 0;
    l_scdqreq_cnt := 0;
    --
    l_oraerrreq_cnt  := 0;
    l_handerrreq_cnt := 0;
    l_apperrreq_cnt  := 0;
    --
    l_errcomp_en     := 1;
    l_handerrcomp_en := 1;
    --
    if l_reqid_va.count > 0
    then
      --
      for reqvaen in l_reqid_va.first..l_reqid_va.last
      loop
        --
        if l_stcode_va(reqvaen) = 'C'
        then
          --
          l_compreq_cnt := l_compreq_cnt+1;
          --
        elsif l_stcode_va(reqvaen) = 'R'
        then
          --
          l_runreq_cnt := l_runreq_cnt+1;
          --
        elsif l_stcode_va(reqvaen) = 'E'
        then
          --
          l_errreq_cnt := l_errreq_cnt+1;
          --
          if instr(l_comptxt_va(reqvaen),'ORA-20001') = 0
          then
            --
            l_errcomptxt_va.extend(1);
            l_errcomptxt_va(l_errcomp_en) := l_comptxt_va(reqvaen);
            l_errcomp_en := l_errcomp_en+1;
            --
            l_oraerrreq_cnt := l_oraerrreq_cnt+1;
            --
          --
          -- Check for logging error
          --
          elsif instr(l_comptxt_va(reqvaen),'_91663_') > 0
          then
            --
            l_handerrcomptxt_va.extend(1);
            l_handerrcomptxt_va(l_handerrcomp_en) := l_comptxt_va(reqvaen);
            l_handerrcomp_en := l_handerrcomp_en+1;
            --
            l_handerrreq_cnt := l_handerrreq_cnt+1;
            --
          else
            --
            l_apperrreq_cnt := l_apperrreq_cnt+1;
            --
          end if;
          --
        elsif l_stcode_va(reqvaen) = 'T'
        then
          --
          l_scdtreq_cnt := l_scdtreq_cnt+1;
          --
        elsif l_stcode_va(reqvaen) = 'G'
        then
          --
          l_scdgreq_cnt := l_scdgreq_cnt+1;
          --
        elsif l_stcode_va(reqvaen) = 'X'
        then
          --
          l_scdxreq_cnt := l_scdxreq_cnt+1;
          --
        elsif l_stcode_va(reqvaen) = 'I'
        then
          --
          l_scdireq_cnt := l_scdireq_cnt+1;
          --
        elsif l_stcode_va(reqvaen) = 'Q'
        then
          --
          l_scdqreq_cnt := l_scdqreq_cnt+1;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    l_req_cnt := l_reqid_va.count;
    --
    open c_fndparreqstats
      (c_bft_id => p_bft_id
      );
    fetch c_fndparreqstats BULK COLLECT INTO l_reqid_va,
                                             l_ospid_va,
                                             l_ossid_va,
                                             l_parreqid_va,
                                             l_phcode_va,
                                             l_stcode_va,
                                             l_comptxt_va,
                                             l_reqchkcnt_va;
    close c_fndparreqstats;
    --
    if l_reqid_va.count > 0
    then
      --
      for reqvaen in l_reqid_va.first..l_reqid_va.last
      loop
        --
        if l_stcode_va(reqvaen) = 'C'
        then
          --
          l_compreq_cnt := l_compreq_cnt+1;
          --
        elsif l_stcode_va(reqvaen) = 'R'
        then
          --
          l_runreq_cnt := l_runreq_cnt+1;
          --
        elsif l_stcode_va(reqvaen) = 'E'
        then
          --
          l_errreq_cnt := l_errreq_cnt+1;
          --
          if instr(l_comptxt_va(reqvaen),'ORA-20001') = 0
          then
            --
            l_errcomptxt_va.extend(1);
            l_errcomptxt_va(l_errcomp_en) := l_comptxt_va(reqvaen);
            l_errcomp_en := l_errcomp_en+1;
            --
            l_oraerrreq_cnt := l_oraerrreq_cnt+1;
            --
          --
          -- Check for logging error
          --
          elsif instr(l_comptxt_va(reqvaen),'_91663_') > 0
          then
            --
            l_handerrcomptxt_va.extend(1);
            l_handerrcomptxt_va(l_handerrcomp_en) := l_comptxt_va(reqvaen);
            l_handerrcomp_en := l_handerrcomp_en+1;
            --
            l_handerrreq_cnt := l_handerrreq_cnt+1;
            --
          else
            --
            l_apperrreq_cnt := l_apperrreq_cnt+1;
            --
          end if;
          --
        elsif l_stcode_va(reqvaen) = 'T'
        then
          --
          l_scdtreq_cnt := l_scdtreq_cnt+1;
          --
        elsif l_stcode_va(reqvaen) = 'G'
        then
          --
          l_scdgreq_cnt := l_scdgreq_cnt+1;
          --
        elsif l_stcode_va(reqvaen) = 'X'
        then
          --
          l_scdxreq_cnt := l_scdxreq_cnt+1;
          --
        elsif l_stcode_va(reqvaen) = 'I'
        then
          --
          l_scdireq_cnt := l_scdireq_cnt+1;
          --
        elsif l_stcode_va(reqvaen) = 'Q'
        then
          --
          l_scdqreq_cnt := l_scdqreq_cnt+1;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    l_req_cnt := l_req_cnt+l_reqid_va.count;
    --
    p_ccrreq_cnt        := l_req_cnt;
    p_ccrcompreq_cnt    := l_compreq_cnt;
    p_ccrrunreq_cnt     := l_runreq_cnt;
    p_ccrerrreq_cnt     := l_errreq_cnt;
    p_ccrscdtreq_cnt    := l_scdtreq_cnt;
    p_ccrscddreq_cnt    := l_scddreq_cnt;
    p_ccrscdgreq_cnt    := l_scdgreq_cnt;
    p_ccrscdxreq_cnt    := l_scdxreq_cnt;
    p_ccrscdireq_cnt    := l_scdireq_cnt;
    p_ccrscdqreq_cnt    := l_scdqreq_cnt;
    --
    p_ccroraerrreq_cnt  := l_oraerrreq_cnt;
    p_ccrhanderrreq_cnt := l_handerrreq_cnt;
    p_ccrapperrreq_cnt  := l_apperrreq_cnt;
    --
    p_ccrerrcomptxt_va := l_errcomptxt_va;
    p_ccrhanderrcomptxt_va := l_handerrcomptxt_va;
    --
  end CCRequestStats;
  --
  procedure OracleErrs
    (p_bft_id            in            number
    --
    ,p_oraerr_tot        in out nocopy number
    ,p_oraerrtext_va     in out nocopy benutils.g_varchar2_table
    ,p_oraerrcnt_va      in out nocopy benutils.g_number_table
    ,p_oraerrmxperid_va  in out nocopy benutils.g_number_table
    ,p_oraerrtextinst_va in out nocopy benutils.g_varchar2_table
    )
  is
    --
    l_text_va     benutils.g_varchar2_table := benutils.g_varchar2_table();
    l_textinst_va benutils.g_varchar2_table := benutils.g_varchar2_table();
    l_mxperid_va  benutils.g_number_table := benutils.g_number_table();
    l_cnt_va      benutils.g_number_table := benutils.g_number_table();
    --
    l_err_en      pls_integer;
    l_err_tot     pls_integer;
    --
    cursor c_gbenreporaerrsum
      (c_bft_id in number
      )
    is
      select text,
             max(person_id) mx_perid,
             count(*) cnt
      from ben_reporting
      where benefit_action_id = c_bft_id
      and   text like '%ORA-%'
      group by text
      order by count(*) desc;
    --
  begin
    --
    -- Get oracle error information
    --
    l_err_en  := 1;
    l_err_tot := 0;
    --
    for row in c_gbenreporaerrsum
      (c_bft_id => p_bft_id
      )
    loop
      --
      l_text_va.extend(1);
      l_mxperid_va.extend(1);
      l_errcnt_va.extend(1);
      l_text_va(l_err_en)    := row.text;
      l_mxperid_va(l_err_en) := row.mx_perid;
      l_errcnt_va(l_err_en)  := row.cnt;
      --
      l_err_tot := l_err_tot+row.cnt;
      l_err_en  := l_err_en+1;
      --
    end loop;
    --
    if l_text_va.count > 0
    then
      --
      open c_gbenreporaerrinst
        (c_bft_id => p_bft_id
        );
      fetch c_gbenreporaerrinst BULK COLLECT INTO l_textinst_va;
      close c_gbenreporaerrinst;
      --
    end if;
    --
    p_oraerr_tot        := l_err_tot;
    p_oraerrtext_va     := l_text_va;
    p_oraerrcnt_va      := l_errcnt_va;
    p_oraerrmxperid_va  := l_mxperid_va;
    p_oraerrtextinst_va := l_textinst_va;
    --
  end OracleErrs;
  --
BEGIN
  --
  -- Defaults
  --
  if p_days is null
  then
    --
    l_days := 1000;
    --
  else
    --
    l_days := p_days;
    --
  end if;
  --
  if p_baselines is null
  then
    --
    l_baselines := 5;
    --
  else
    --
    l_baselines := p_baselines;
    --
  end if;
  --
  -- Sweep up all non rolled up benefit actions
  --
  l_st_date  := sysdate-l_days;
  l_end_date := sysdate;
  --
  l_reptext_va.delete;
  --
  l_reptext_va.extend(1);
  l_reptext_en := 1;
  l_reptext_va(l_reptext_en) := '-- ';
  --
  l_reptext_va.extend(1);
  l_reptext_en := l_reptext_en+1;
  l_reptext_va(l_reptext_en) := '-- Reporting days: '||p_days;
  --
  l_reptext_va.extend(1);
  l_reptext_en := l_reptext_en+1;
  l_reptext_va(l_reptext_en) := '-- Reporting date range: '||l_st_date||' to '||l_end_date;
  --
  if p_rollup_rbvs = 'Y'
  then
    --
    l_hist_duration := 1000;
    l_show_matches  := FALSE;
    --
    -- Rollup non rolled up benefit actions
    --
    l_where_str := ' where bft.validate_flag in ('||''''||'C'||''''
                                              ||','||''''||'B'||''''||') '
                   ||' and bft.last_update_date '
                   ||'   between :st_date and :end_date ';
    --
    if p_person_id is not null
    then
      --
      l_where_str := l_where_str||' and bft.person_id = :per_id ';
      --
    elsif p_business_group_id is not null
    then
      --
      l_where_str := l_where_str||' and bft.business_group_id = :bgp_id ';
      --
    end if;
    --
    l_sel_str   := ' select bft.benefit_action_id, '
                   ||'      bft.business_group_id, '
                   ||'      bft.person_id, '
                   ||'      bft.ler_id, '
                   ||'      bft.process_date ';
    l_from_str  := ' from ben_benefit_actions bft ';
    l_ordby_str := ' order by bft.benefit_action_id desc ';
    --
    l_sql_str := l_sel_str
                 ||' '||l_from_str
                 ||' '||l_where_str
                 ||' '||l_ordby_str;
    --
    if p_person_id is not null
    then
      --
      open c_bftinst_cur FOR l_sql_str using l_st_date,l_end_date,p_person_id;
      --
    elsif p_business_group_id is not null
    then
      --
      open c_bftinst_cur FOR l_sql_str using l_st_date,l_end_date,p_business_group_id;
      --
    else
      --
      open c_bftinst_cur FOR l_sql_str using l_st_date,l_end_date;
      --
    end if;
    --
    l_rollref_cnt := 0;
    --
    loop
      FETCH c_bftinst_cur INTO l_bft_inst;
      EXIT WHEN c_bftinst_cur%NOTFOUND;
/*
        --
        -- Debugging
        --
        l_reptext_va.extend(1);
        l_reptext_en := l_reptext_en+1;
        l_reptext_va(l_reptext_en) := '-- l_bft_inst.benefit_action_id: '||l_bft_inst.benefit_action_id;
        --
        l_reptext_va.extend(1);
        l_reptext_en := l_reptext_en+1;
        l_reptext_va(l_reptext_en) := '-- p_refresh_rollups: '||p_refresh_rollups;

*/
      --
      ben_rollup_rbvs.rollup_benmngle_rbvs
        (p_benefit_action_id => l_bft_inst.benefit_action_id
        ,p_refresh_rollups   => 'Y'
        );
      --
      l_rollref_cnt := l_rollref_cnt+1;
      commit;
      --
    end loop;
    close c_bftinst_cur;
    --
    l_reptext_va.extend(1);
    l_reptext_en := l_reptext_en+1;
    l_reptext_va(l_reptext_en) := '-- Rolled up: '||l_rollref_cnt||' benefit actions ';
    --
  end if;
  --
  -- Report out results
  --
  l_where_str := ' where bft.last_update_date '
                 ||'   between :st_date and :end_date '
                 ||' and pba.batch_id          = bft.benefit_action_id '
                 ||' and pba.batch_type        = '||''''||'BEN_BFT'||'''';
  --
  if p_person_id is not null
  then
    --
    l_where_str := l_where_str||' and bft.person_id = :per_id ';
    --
  elsif p_ler_id is not null
  then
    --
    l_where_str := l_where_str||' and bft.ler_id = :ler_id ';
    --
  elsif p_business_group_id is not null
  then
    --
    l_where_str := l_where_str||' and bft.business_group_id = :bgp_id ';
    --
  end if;
  --
  l_sql_str := 'select max(bft.benefit_action_id) max_bftid, '
               ||'     bft.process_date, '
               ||'     bft.mode_cd, '
               ||'     bft.business_group_id, '
               ||'     bft.BENFTS_GRP_ID, '
               ||'     bft.person_id, '
               ||'     bft.pgm_id, '
               ||'     bft.pl_id, '
               ||'     bft.ler_id, '
               ||'     bft.opt_id, '
               ||'     max(bft.creation_date) max_credt, '
               ||'     max(bft.request_id) '
               ||' from ben_benefit_actions bft, '
               ||'      ben_batch_actions pba '
               ||' '||l_where_str
               ||' group by bft.process_date, '
               ||'          bft.mode_cd, '
               ||'          bft.business_group_id, '
               ||'          bft.BENFTS_GRP_ID, '
               ||'          bft.person_id, '
               ||'          bft.pgm_id, '
               ||'          bft.pl_id, '
               ||'          bft.ler_id, '
               ||'          bft.opt_id '
               ||' order by max(bft.benefit_action_id) desc ';
  --
  if p_person_id is not null
  then
    --
    open c_bftinst_cur FOR l_sql_str using l_st_date,l_end_date,p_person_id;
  --
  elsif p_ler_id is not null
  then
    --
    open c_bftinst_cur FOR l_sql_str using l_st_date,l_end_date,p_ler_id;
    --
  elsif p_business_group_id is not null
  then
    --
    open c_bftinst_cur FOR l_sql_str using l_st_date,l_end_date,p_business_group_id;
    --
  else
    --
    open c_bftinst_cur FOR l_sql_str using l_st_date,l_end_date;
    --
  end if;
  --
  l_reptext_va.extend(1);
  l_reptext_en := l_reptext_en+1;
  l_reptext_va(l_reptext_en) := '-- ';
  --
  l_vaen := 1;
  --
  loop
    FETCH c_bftinst_cur INTO l_bft_dets;
    EXIT WHEN c_bftinst_cur%NOTFOUND;
    --
    l_newbft_id_va.extend(1);
    l_newbftmode_cd_va.extend(1);
    l_newbftbgp_id_va.extend(1);
    l_newbftper_id_va.extend(1);
    l_newbftpgm_id_va.extend(1);
    l_newbftpl_id_va.extend(1);
    l_newbftbfg_id_va.extend(1);
    l_newbftproc_dt_va.extend(1);
    l_newbftler_id_va.extend(1);
    l_newbftopt_id_va.extend(1);
/*
    l_newbftleodt_dt_va.extend(1);
*/
    l_newbftmax_credt_va.extend(1);
    l_newbftreqid_va.extend(1);
    --
    l_newbft_id_va(l_vaen)       := l_bft_dets.max_bftid;
    l_newbftmode_cd_va(l_vaen)   := l_bft_dets.mode_cd;
    l_newbftbgp_id_va(l_vaen)    := l_bft_dets.business_group_id;

    l_newbftper_id_va(l_vaen)    := l_bft_dets.person_id;
    l_newbftpgm_id_va(l_vaen)    := l_bft_dets.pgm_id;
    l_newbftpl_id_va(l_vaen)     := l_bft_dets.pl_id;
    l_newbftbfg_id_va(l_vaen)    := l_bft_dets.BENFTS_GRP_ID;
    l_newbftproc_dt_va(l_vaen)   := l_bft_dets.process_date;
    l_newbftler_id_va(l_vaen)    := l_bft_dets.ler_id;
    l_newbftopt_id_va(l_vaen)    := l_bft_dets.opt_id;
/*
    l_newbftleodt_dt_va(l_vaen)  := l_bft_dets.LF_EVT_OCRD_DT;
*/
    l_newbftmax_credt_va(l_vaen) := l_bft_dets.max_credt;
    l_newbftreqid_va(l_vaen)     := l_bft_dets.request_id;
/*
      --
      -- Debugging parameters
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '-- Debugging parameters ';
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '-- BFTPGMID: '||l_bft_dets.pgm_id;
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '-- BFTPLNID: '||l_bft_dets.pl_id;
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '-- BFTLERID: '||l_bft_dets.ler_id;
      --
*/
    l_vaen := l_vaen+1;
    --
  end loop;
  close c_bftinst_cur;
  --
  -- Display benefit action info
  --
  if l_newbft_id_va.count > 0
  then
    --
    ben_benefit_actions_api.create_perf_benefit_actions
      (p_validate               => false
      ,p_process_date           => trunc(sysdate)
      ,p_mode_cd                => 'Q'
      ,p_derivable_factors_flag => 'N'
      ,p_validate_flag          => 'N'
      ,p_person_id              => null
      ,p_person_type_id         => null
      ,p_pgm_id                 => null
      ,p_business_group_id      => nvl(l_bft_dets.business_group_id,-999999999999999)
      ,p_pl_id                  => null
      ,p_no_programs_flag       => 'N'
      ,p_no_plans_flag          => 'N'
      ,p_comp_selection_rl      => null
      ,p_person_selection_rl    => null
      ,p_ler_id                 => null
      ,p_organization_id        => null
      ,p_benfts_grp_id          => null
      ,p_location_id            => null
      ,p_pstl_zip_rng_id        => null
      ,p_rptg_grp_id            => null
      ,p_pl_typ_id              => null
      ,p_opt_id                 => null
      ,p_eligy_prfl_id          => null
      ,p_vrbl_rt_prfl_id        => null
      ,p_legal_entity_id        => null
      ,p_payroll_id             => null
      ,p_debug_messages_flag    => 'N'
      ,p_audit_log_flag         => 'N'
      ,p_lmt_prpnip_by_org_flag => 'N'
      ,p_request_id             => fnd_global.conc_request_id
      ,p_program_application_id => fnd_global.prog_appl_id
      ,p_program_id             => fnd_global.conc_program_id
      ,p_program_update_date    => sysdate
      ,p_object_version_number  => l_thnbft_ovn
      ,p_lf_evt_ocrd_dt         => null
      ,p_effective_date         => null
      --
      ,p_benefit_action_id      => l_thnbft_id
      );
    --
    commit;
/*
      --
      -- Debugging parameters
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '-- Debugging parameters ';
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '-- BGPID: '||p_business_group_id;
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '-- PERID: '||p_person_id;
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '-- ';
      --
*/
    for vaen in l_newbft_id_va.first..l_newbft_id_va.last
    loop
      --
      l_bgp_name     := null;
      l_per_fullname := null;
      l_pgm_name     := null;
      l_pln_name     := null;
      l_ler_name     := null;
      l_opt_name     := null;
      --
      if l_newbftbgp_id_va(vaen) is not null
      then
        --
        open c_bgp_dets
          (c_bgp_id => l_newbftbgp_id_va(vaen)
          );
        fetch c_bgp_dets into l_bgp_name;
        close c_bgp_dets;
        --
      end if;
      --
      if l_newbftper_id_va(vaen) is not null
      then
        --
        open c_perdets
          (c_per_id => l_newbftper_id_va(vaen)
          );
        fetch c_perdets into l_per_fullname;
        close c_perdets;
        --
      end if;
      --
      if l_newbftpgm_id_va(vaen) is not null
      then
        --
        open c_pgmdets
          (c_pgm_id => l_newbftpgm_id_va(vaen)
          );
        fetch c_pgmdets into l_pgm_name;
        close c_pgmdets;
        --
      end if;
      --
      if l_newbftpl_id_va(vaen) is not null
      then
        --
        open c_plndets
          (c_pl_id => l_newbftpl_id_va(vaen)
          );
        fetch c_plndets into l_pln_name;
        close c_plndets;
        --
      end if;
      --
      if l_newbftler_id_va(vaen) is not null
      then
        --
        open c_lerdets
          (c_ler_id => l_newbftler_id_va(vaen)
          );
        fetch c_lerdets into l_ler_name;
        close c_lerdets;
        --
      end if;
      --
      if l_newbftopt_id_va(vaen) is not null
      then
        --
        open c_optdets
          (c_opt_id => l_newbftopt_id_va(vaen)
          );
        fetch c_optdets into l_opt_name;
        close c_optdets;
        --
      end if;
      --
      -- Check for batch info
      --
      open c_bpidets
        (c_bft_id => l_newbft_id_va(vaen)
        );
      fetch c_bpidets into l_v2esecs;
      close c_bpidets;
      --
      -- Get processed person actions
      --
      PersonActionStats
        (p_bft_id        => l_newbft_id_va(vaen)
        --
        ,p_prperact_cnt  => l_prperact_cnt
        ,p_errperact_cnt => l_errperact_cnt
        ,p_upperact_cnt  => l_upperact_cnt
        );
      --
      BBRThreadStats
        (p_bft_id     => l_newbft_id_va(vaen)
        --
        ,p_thread_cnt => l_bbrthread_cnt
        ,p_mxdursecs  => l_thread_mxdursecs
        ,p_mndursecs  => l_thread_mndursecs
        ,p_mxchkcnt   => l_thread_mxchkcnt
        ,p_mnchkcnt   => l_thread_mnchkcnt
        );
      --
      -- Check for the concurrent manager env
      --
      l_ccrreq_cnt        := 0;
      l_ccrcompreq_cnt    := 0;
      l_ccrrunreq_cnt     := 0;
      l_ccrerrreq_cnt     := 0;
      l_ccrscdtreq_cnt    := 0;
      l_ccrscddreq_cnt    := 0;
      l_ccrscdgreq_cnt    := 0;
      l_ccrscdxreq_cnt    := 0;
      l_ccrscdireq_cnt    := 0;
      l_ccrscdqreq_cnt    := 0;
      l_ccroraerrreq_cnt  := 0;
      l_ccrhanderrreq_cnt := 0;
      l_ccrapperrreq_cnt  := 0;
      l_ccrerrcomptxt_va.delete;
      l_ccrhanderrcomptxt_va.delete;
      --
      if l_newbftreqid_va(vaen) <> -1
      then
        --
        CCRequestStats
          (p_bft_id               => l_newbft_id_va(vaen)
          --
          ,p_ccrreq_cnt           => l_ccrreq_cnt
          ,p_ccrcompreq_cnt       => l_ccrcompreq_cnt
          ,p_ccrrunreq_cnt        => l_ccrrunreq_cnt
          ,p_ccrerrreq_cnt        => l_ccrerrreq_cnt
          ,p_ccrscdtreq_cnt       => l_ccrscdtreq_cnt
          ,p_ccrscddreq_cnt       => l_ccrscddreq_cnt
          ,p_ccrscdgreq_cnt       => l_ccrscdgreq_cnt
          ,p_ccrscdxreq_cnt       => l_ccrscdxreq_cnt
          ,p_ccrscdireq_cnt       => l_ccrscdireq_cnt
          ,p_ccrscdqreq_cnt       => l_ccrscdqreq_cnt
          ,p_ccroraerrreq_cnt     => l_ccroraerrreq_cnt
          ,p_ccrhanderrreq_cnt    => l_ccrhanderrreq_cnt
          ,p_ccrapperrreq_cnt     => l_ccrapperrreq_cnt
          ,p_ccrerrcomptxt_va     => l_ccrerrcomptxt_va
          ,p_ccrhanderrcomptxt_va => l_ccrhanderrcomptxt_va
          );
        --
      end if;
      --
      OracleErrs
        (p_bft_id            => l_newbft_id_va(vaen)
        --
        ,p_oraerr_tot        => l_oraerr_tot
        ,p_oraerrtext_va     => l_oraerrtext_va
        ,p_oraerrcnt_va      => l_oraerrcnt_va
        ,p_oraerrmxperid_va  => l_oraerrmxperid_va
        ,p_oraerrtextinst_va => l_oraerrtextinst_va
        );
      --
      -- Check for new bft alerts
      --
      g_alertsev1_en := 1;
      g_alertsev2_en := 1;
      g_alertsev1reas_va.delete;
      g_alertsev1bftid_va.delete;
      g_alertsev1prevbftid_va.delete;
      g_alertsev2reas_va.delete;
      g_alertsev2bftid_va.delete;
      --
      NewBftAlertCheck
        (p_bft_id            => l_newbft_id_va(vaen)
        ,p_upperact_cnt      => l_upperact_cnt
        ,p_ccroraerrreq_cnt  => l_ccroraerrreq_cnt
        ,p_ccrhanderrreq_cnt => l_ccrhanderrreq_cnt
        ,p_oraerr_tot        => l_oraerr_tot
        );
      --
      -- Calculate performance metrics
      --
      l_v2esecs := replace(replace(l_v2esecs,'seconds',null),',',null);
      l_esecs   := l_v2esecs;
      l_ehrs    := floor(l_esecs/3600);
      l_ehrmins := floor((l_esecs-(l_ehrs*3600))/60);
      --
      if l_prperact_cnt > 0
      then
        --
        l_tphr := round(((60/(l_esecs/l_prperact_cnt))*60),2);
        --
      else
        --
        l_tphr := null;
        --
      end if;
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '==========================================================';
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '-- Benefit Action: '||l_newbft_id_va(vaen)
                                    ||' Time: '||to_char(l_newbftmax_credt_va(vaen),'DD-MON-YYYY-HH24-MI-SS');
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '-- ';
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '-- Duration: '
                                    ||l_ehrs||':'||l_ehrmins
                                    ||' Secs: '||l_esecs
                                    ||' Proc: '||l_prperact_cnt
                                    ||' TP: '||l_tphr;

      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '-- Person Actions: Proc: '||l_prperact_cnt
                                    ||' Err: '||l_errperact_cnt
                                    ||' UP: '||l_upperact_cnt
                                    ||' ORAErr: '||l_oraerr_tot;
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '-- Threads: '||l_bbrthread_cnt
                                    ||' Dur: Mx/Mn '||l_thread_mxdursecs||'/'||l_thread_mndursecs
                                    ||' Chunks: Mx/Mn '||l_thread_mxchkcnt||'/'||l_thread_mnchkcnt;
      --
      if l_newbftreqid_va(vaen) <> -1
      then
        --
        l_reptext_va.extend(1);
        l_reptext_en := l_reptext_en+1;
        l_reptext_va(l_reptext_en) := '-- Concurrent Requests: '||l_ccrreq_cnt
                                      ||' Comp: '||l_ccrcompreq_cnt
                                      ||' Run: '||l_ccrrunreq_cnt
                                      ||' Err: '||l_ccrerrreq_cnt
                                      ||' ORAErr: '||l_ccroraerrreq_cnt
                                      ||' EnvErr: '||l_ccrhanderrreq_cnt
                                      ||' AppErr: '||l_ccrapperrreq_cnt;
        --
      end if;
      --
      BuildAlertStrVa
        (p_alertstr_va => l_alertstr_va
        );
      --
      -- Display alerts
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '-- ';
      --
      if l_alertstr_va.count > 0
      then
        --
        for alertvaen in l_alertstr_va.first..l_alertstr_va.last
        loop
          --
          l_reptext_va.extend(1);
          l_reptext_en := l_reptext_en+1;
          l_reptext_va(l_reptext_en) := l_alertstr_va(alertvaen);
          --
        end loop;
        --
      end if;
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '-- ';
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := rpad('-- Business Group: ',25)||substr(l_bgp_name,1,30)
                                    ||' ('||l_newbftbgp_id_va(vaen)||') ';
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := rpad('-- Mode: ',25)||l_newbftmode_cd_va(vaen);
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := rpad('-- Process Date: ',25)||l_newbftproc_dt_va(vaen);
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := rpad('-- Person: ',25)||substr(l_per_fullname,1,30)
                                    ||' ('||l_newbftper_id_va(vaen)||') ';
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := rpad('-- Life Event Reason: ',25)||substr(l_ler_name,1,30)
                                    ||' ('||l_newbftler_id_va(vaen)||') ';
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := rpad('-- Program: ',25)||substr(l_pgm_name,1,30)
                                    ||' ('||l_newbftpgm_id_va(vaen)||') ';
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := rpad('-- Plan: ',25)||substr(l_pln_name,1,30)
                                    ||' ('||l_newbftpl_id_va(vaen)||') ';
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := rpad('-- Option: ',25)||substr(l_opt_name,1,30)
                                    ||' ('||l_newbftopt_id_va(vaen)||') ';
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '-- ';
      --
      open c_rbvdets
        (c_bft_id => l_newbft_id_va(vaen)
        );
      fetch c_rbvdets BULK COLLECT INTO l_clcode_va,
                                        l_clcodecnt_va,
                                        l_clsumovn_va,
                                        l_clminesd_va,
                                        l_clmineed_va,
                                        l_clidstr_va;
      close c_rbvdets;
      --
      -- Filter out non discrepancy rollups
      --
      filter_clcode_nondiscreps
        (p_clcode_va    => l_clcode_va
        ,p_clcodecnt_va => l_clcodecnt_va
        ,p_clsumovn_va  => l_clsumovn_va
        ,p_clminesd_va  => l_clminesd_va
        ,p_clmineed_va  => l_clmineed_va
        );
      --
      if l_clcode_va.count > 0 then
        --
        l_reptext_va.extend(1);
        l_reptext_en := l_reptext_en+1;
        l_reptext_va(l_reptext_en) := '--- Row counts by functional area: '||l_clcode_va.count;
        --
        l_reptext_va.extend(1);
        l_reptext_en := l_reptext_en+1;
        l_reptext_va(l_reptext_en) := '--- ';
        --
        for elenum in l_clcode_va.first..l_clcode_va.last
        loop
          --
          -- Get rollup type description
          --
          rollupcode_getrollupdesc
            (p_rollup_code => l_clcode_va(elenum)
            --
            ,p_rollup_desc => l_rollup_desc
            );
          --
          l_reptext_va.extend(1);
          l_reptext_en := l_reptext_en+1;
          l_reptext_va(l_reptext_en) := '--- '||rpad(l_clcodecnt_va(elenum),4)||' '
                                        ||l_rollup_desc||' ('||l_clcode_va(elenum)||') ';
          --
        end loop;
        --
      end if;
      --
      -- Get Error and person action details
      --
      get_appl_error_dets
        (p_bft_id       => l_newbft_id_va(vaen)
        --
        ,p_errmesscd_va => l_errmesscd_va
        ,p_mxperid_va   => l_mxperid_va
        ,p_errcnt_va    => l_errcnt_va
        ,p_errtot       => l_apperr_tot
        );
      --
      -- Get person action information
      --
      l_pactup_cnt   := 0;
      l_pactproc_cnt := 0;
      l_pacterr_cnt  := 0;
      --
      if l_clcode_va.count > 0
      then
        --
        for errvaen in l_clcode_va.first..l_clcode_va.last
        loop
          --
          if l_clcode_va(errvaen) = 'PERACTUNPROC'
          then
            --
            l_pactup_cnt := l_clcodecnt_va(errvaen);
            --
          elsif l_clcode_va(errvaen) = 'PERACTPROC'
          then
            --
            l_pactproc_cnt := l_clcodecnt_va(errvaen);
            --
          elsif l_clcode_va(errvaen) = 'PERACTERR'
          then
            --
            l_pacterr_cnt := l_clcodecnt_va(errvaen);
            --
          end if;
          --
        end loop;
        --
      end if;
      --
      -- Display error information
      --
      if l_apperr_tot > 0
      then
        --
        l_reptext_va.extend(1);
        l_reptext_en := l_reptext_en+1;
        l_reptext_va(l_reptext_en) := '---- ';
        --
        l_reptext_va.extend(1);
        l_reptext_en := l_reptext_en+1;
        l_reptext_va(l_reptext_en) := '---- Application Errors: '||l_apperr_tot;
        --
        if l_pacterr_cnt <> l_apperr_cnt
        then
          --
          l_reptext_va.extend(1);
          l_reptext_en := l_reptext_en+1;
          l_reptext_va(l_reptext_en) := '----- Unaccounted errors exist. '||l_apperr_tot
                                        ||' are accounted but '||l_pacterr_cnt||' were raised. ';
          --
        end if;
        --
        if l_errmesscd_va.count > 0
        then
          --
          for errvaen in l_errmesscd_va.first..l_errmesscd_va.last
          loop
            --
            l_reptext_va.extend(1);
            l_reptext_en := l_reptext_en+1;
            l_reptext_va(l_reptext_en) := '----- '||l_errcnt_va(errvaen)
                                          ||' '||l_errmesscd_va(errvaen)
                                          ||' '||l_mxperid_va(errvaen);
            --
          end loop;
          --
        end if;
        --
      end if;
      --
      -- UnHandled oracle errors
      --
      if l_ccrerrcomptxt_va.count > 0
      then
        --
        l_reptext_va.extend(1);
        l_reptext_en := l_reptext_en+1;
        l_reptext_va(l_reptext_en) := '---- ';
        --
        l_reptext_va.extend(1);
        l_reptext_en := l_reptext_en+1;
        l_reptext_va(l_reptext_en) := '---- Concurrent Request Oracle Errors: '||l_ccrerrcomptxt_va.count;
        --
        for ccrerrvaen in l_ccrerrcomptxt_va.first..l_ccrerrcomptxt_va.last
        loop
          --
          l_oraerr_text := Var2Value_StripMltBlanks(l_ccrerrcomptxt_va(ccrerrvaen));
          --
          Var2Value_Portion
            (p_var2_value      => l_oraerr_text
            ,p_portion_length  => 70
            --
            ,p_v2_val_portions => l_text_va
            );
          --
          if l_text_va.count > 0
          then
            --
            for txtvaen in l_text_va.first..l_text_va.last
            loop
              --
              l_reptext_va.extend(1);
              l_reptext_en := l_reptext_en+1;
              l_reptext_va(l_reptext_en) := '----- '||l_text_va(txtvaen);
              --
            end loop;
            --
          else
            --
            l_reptext_va.extend(1);
            l_reptext_en := l_reptext_en+1;
            l_reptext_va(l_reptext_en) := '----- '||l_oraerr_text;
            --
          end if;
          --
        end loop;
        --
      end if;
      --
      -- Handled oracle errors
      --
      if l_ccrhanderrcomptxt_va.count > 0
      then
        --
        l_reptext_va.extend(1);
        l_reptext_en := l_reptext_en+1;
        l_reptext_va(l_reptext_en) := '---- ';
        --
        l_reptext_va.extend(1);
        l_reptext_en := l_reptext_en+1;
        l_reptext_va(l_reptext_en) := '---- Concurrent Request Env Errors: '||l_ccrhanderrcomptxt_va.count;
        --
        for ccrerrvaen in l_ccrhanderrcomptxt_va.first..l_ccrhanderrcomptxt_va.last
        loop
          --
          l_oraerr_text := Var2Value_StripMltBlanks(l_ccrhanderrcomptxt_va(ccrerrvaen));
          --
          Var2Value_Portion
            (p_var2_value      => l_oraerr_text
            ,p_portion_length  => 70
            --
            ,p_v2_val_portions => l_text_va
            );
          --
          if l_text_va.count > 0
          then
            --
            for txtvaen in l_text_va.first..l_text_va.last
            loop
              --
              l_reptext_va.extend(1);
              l_reptext_en := l_reptext_en+1;
              l_reptext_va(l_reptext_en) := '----- '||l_text_va(txtvaen);
              --
            end loop;
            --
          else
            --
            l_reptext_va.extend(1);
            l_reptext_en := l_reptext_en+1;
            l_reptext_va(l_reptext_en) := '----- '||l_oraerr_text;
            --
          end if;
          --
        end loop;
        --
      end if;
      --
      -- Handled oracle errors
      --
      if l_oraerrtext_va.count > 0
      then
        --
        l_reptext_va.extend(1);
        l_reptext_en := l_reptext_en+1;
        l_reptext_va(l_reptext_en) := '---- ';
        --
        l_reptext_va.extend(1);
        l_reptext_en := l_reptext_en+1;
        l_reptext_va(l_reptext_en) := '---- Person Action Oracle Errors: '||l_oraerrtext_va.count;
        --
        for errvaen in l_oraerrtext_va.first..l_oraerrtext_va.last
        loop
          --
          l_oraerr_text := l_oraerrcnt_va(errvaen)||' '||Var2Value_StripMltBlanks(l_oraerrtext_va(errvaen));
          --
          Var2Value_Portion
            (p_var2_value      => l_oraerr_text
            ,p_portion_length  => 70
            --
            ,p_v2_val_portions => l_text_va
            );
          --
          if l_text_va.count > 0
          then
            --
            for txtvaen in l_text_va.first..l_text_va.last
            loop
              --
              l_reptext_va.extend(1);
              l_reptext_en := l_reptext_en+1;
              l_reptext_va(l_reptext_en) := '----- '||l_text_va(txtvaen);
              --
            end loop;
            --
          else
            --
            l_reptext_va.extend(1);
            l_reptext_en := l_reptext_en+1;
            l_reptext_va(l_reptext_en) := '----- '||l_oraerr_text;
            --
          end if;
          --
        end loop;
        --
      end if;
      --
      -- Check for person action issues
      --
      if l_pactup_cnt > 0
        or l_pactproc_cnt = 0
      then
        --
        l_reptext_va.extend(1);
        l_reptext_en := l_reptext_en+1;
        l_reptext_va(l_reptext_en) := '---- ';
        --
        -- Unprocessed person actions
        --
        if l_pactup_cnt > 0
        then
          --
          l_reptext_va.extend(1);
          l_reptext_en := l_reptext_en+1;
          l_reptext_va(l_reptext_en) := '---- Environment Errors: '||l_pactup_cnt;
          --
        elsif l_pactproc_cnt = 0
        then
          --
          l_reptext_va.extend(1);
          l_reptext_en := l_reptext_en+1;
          l_reptext_va(l_reptext_en) := '---- No person actions processed ';
          --
        end if;
        --
      end if;
      --
      -- Get historic benefit actions
      --
      l_baseline_cnt := 0;
      --
      -- Set the latest benefit action
      --
      l_prevbft_id   := l_newbft_id_va(vaen);
      --
/*
          --
          -- Debugging
          --
          l_reptext_va.extend(1);
          l_reptext_en := l_reptext_en+1;
          l_reptext_va(l_reptext_en) := 'c_ghistbftdets: l_hist_duration: '||l_hist_duration;
          --
*/
      for row in c_ghistbftdets
        (c_duration      => l_hist_duration
        ,c_mode_cd       => l_newbftmode_cd_va(vaen)
        ,c_process_date  => l_newbftproc_dt_va(vaen)
        ,c_bgp_id        => l_newbftbgp_id_va(vaen)
        ,c_ler_id        => l_newbftler_id_va(vaen)
        ,c_per_id        => l_newbftper_id_va(vaen)
        ,c_pgm_id        => l_newbftpgm_id_va(vaen)
        ,c_pl_id         => l_newbftpl_id_va(vaen)
        ,c_opt_id        => l_newbftopt_id_va(vaen)
        ,c_bfg_id        => l_newbftbfg_id_va(vaen)
        ,c_bft_credt     => l_newbftmax_credt_va(vaen)
        )
      loop
        --
/*
          --
          -- Debugging
          --
          l_reptext_va.extend(1);
          l_reptext_en := l_reptext_en+1;
          l_reptext_va(l_reptext_en) := '---- l_baseline_cnt: '||l_baseline_cnt
                                        ||' l_baselines: '||l_baselines;
          --
*/
        if l_baseline_cnt > l_baselines
        then
          --
          exit;
          --
        end if;
        --
        -- Get old bft processed person action stats
        --
        PersonActionStats
          (p_bft_id        => row.benefit_action_id
          --
          ,p_prperact_cnt  => l_oldprperact_cnt
          ,p_errperact_cnt => l_olderrperact_cnt
          ,p_upperact_cnt  => l_oldupperact_cnt
          );
        --
        -- Check for new bft alerts
        --
        g_alertsev1_en := 1;
        g_alertsev2_en := 1;
        g_alertsev1reas_va.delete;
        g_alertsev1bftid_va.delete;
        g_alertsev1prevbftid_va.delete;
        g_alertsev2reas_va.delete;
        g_alertsev2bftid_va.delete;
        --
        PerActCompAlertCheck
          (p_bft_id            => l_newbft_id_va(vaen)
          ,p_prevbft_id        => row.benefit_action_id
          ,p_oldprperact_cnt   => l_oldprperact_cnt
          ,p_prperact_cnt      => l_prperact_cnt
          ,p_olderrperact_cnt  => l_olderrperact_cnt
          ,p_errperact_cnt     => l_errperact_cnt
          ,p_oldupperact_cnt   => l_oldupperact_cnt
          ,p_upperact_cnt      => l_upperact_cnt
          );
        --
        BuildAlertStrVa
          (p_alertstr_va => l_alertstr_va
          );
        --
        -- Display alerts
        --
        if l_alertstr_va.count > 0
        then
          --
          l_reptext_va.extend(1);
          l_reptext_en := l_reptext_en+1;
          l_reptext_va(l_reptext_en) := '-- ';
          --
          for alertvaen in l_alertstr_va.first..l_alertstr_va.last
          loop
            --
            l_reptext_va.extend(1);
            l_reptext_en := l_reptext_en+1;
            l_reptext_va(l_reptext_en) := l_alertstr_va(alertvaen);
            --
          end loop;
          --
        end if;
        --
        -- Reset latest RBV information to the previous baseline
        --
        open c_rbvdets
          (c_bft_id => l_prevbft_id
          );
        fetch c_rbvdets BULK COLLECT INTO l_clcode_va,
                                          l_clcodecnt_va,
                                          l_clsumovn_va,
                                          l_clminesd_va,
                                          l_clmineed_va,
                                          l_clidstr_va;
        close c_rbvdets;
/*
          --
          -- Temporary
          --
          dbms_output.put_line('- BENTSTHN: c_rbvdets: l_prevbft_id: '||l_prevbft_id
                              );
          --
          for tmpvaen in l_clcode_va.first..l_clcode_va.last
          loop
            --
            dbms_output.put_line('-- '||l_clcode_va(tmpvaen)
                                );
            --
          end loop;
          --
*/
        --
        -- Filter out non discrepancy rollups
        --
        filter_clcode_nondiscreps
          (p_clcode_va    => l_clcode_va
          ,p_clcodecnt_va => l_clcodecnt_va
          ,p_clsumovn_va  => l_clsumovn_va
          ,p_clminesd_va  => l_clminesd_va
          ,p_clmineed_va  => l_clmineed_va
          );
        --
        -- Get Error and person action details
        --
        get_appl_error_dets
          (p_bft_id       => l_prevbft_id
          --
          ,p_errmesscd_va => l_errmesscd_va
          ,p_mxperid_va   => l_mxperid_va
          ,p_errcnt_va    => l_errcnt_va
          ,p_errtot       => l_apperr_tot
          );
        --
        l_prevbft_id   := row.benefit_action_id;
        --
        open c_rbvdets
          (c_bft_id => row.benefit_action_id
          );
        fetch c_rbvdets BULK COLLECT INTO l_rbv_clcode_va,
                                          l_rbv_clcodecnt_va,
                                          l_rbv_clsumovn_va,
                                          l_rbv_clminesd_va,
                                          l_rbv_clmineed_va,
                                          l_rbv_clidstr_va;
        close c_rbvdets;
/*
          --
          -- Temporary
          --
          dbms_output.put_line('- BENTSTHN: c_rbvdets: rowbft_id: '||row.benefit_action_id
                              );
          --
          for tmpvaen in l_rbv_clcode_va.first..l_rbv_clcode_va.last
          loop
            --
            dbms_output.put_line('-- '||l_rbv_clcode_va(tmpvaen)
                                );
            --
          end loop;
          --
*/
        --
        -- Filter non discrepancy rollup types
        --
        filter_clcode_nondiscreps
          (p_clcode_va    => l_rbv_clcode_va
          ,p_clcodecnt_va => l_rbv_clcodecnt_va
          ,p_clsumovn_va  => l_rbv_clsumovn_va
          ,p_clminesd_va  => l_rbv_clminesd_va
          ,p_clmineed_va  => l_rbv_clmineed_va
          );
        --
        -- Check matches
        --
        l_mm_elenum := 1;
        l_mmclccode_va.delete;
        l_mmoclcount_va.delete;
        l_mmnclcount_va.delete;
        --
        l_mt_elenum := 1;
        l_mtclccode_va.delete;
        l_mtoclcount_va.delete;
        l_mtnclcount_va.delete;
        --
        if l_rbv_clcode_va.count <> l_clcode_va.count
          and l_rbv_clcode_va.count > 0
          and l_clcode_va.count > 0
        then
          --
          l_mmrltyp_rbvclcd_vaen := 1;
          l_mmrltyp_rbvclcd_va.delete;
/*
                  --
                  -- Debugging parameters
                  --
                  l_reptext_va.extend(1);
                  l_reptext_en := l_reptext_en+1;
                  l_reptext_va(l_reptext_en) := '-- Debugging parameters ';
                  --
                  l_reptext_va.extend(1);
                  l_reptext_en := l_reptext_en+1;
                  l_reptext_va(l_reptext_en) := '-- l_rbv_clcode_va.count > l_clcode_va.count: ';
                  --
*/
          --
          for clvaen in l_rbv_clcode_va.first..l_rbv_clcode_va.last
          loop
            --
            l_rbvcode_match := FALSE;
            --
            for subvaen in l_clcode_va.first..l_clcode_va.last
            loop
              --
              if l_rbv_clcode_va(clvaen) = l_clcode_va(subvaen)
              then
                --
                l_rbvcode_match := TRUE;
                exit;
                --
              end if;
              --
            end loop;
            --
            if not l_rbvcode_match
            then
              --
              l_mmrltyp_rbvclcd_va.extend(1);
              l_mmrltyp_rbvclcd_va(l_mmrltyp_rbvclcd_vaen) := l_rbv_clcode_va(clvaen);
              l_mmrltyp_rbvclcd_vaen := l_mmrltyp_rbvclcd_vaen+1;
              --
            end if;
            --
          end loop;
/*
                  --
                  -- Debugging parameters
                  --
                  l_reptext_va.extend(1);
                  l_reptext_en := l_reptext_en+1;
                  l_reptext_va(l_reptext_en) := '-- Debugging parameters ';
                  --
                  l_reptext_va.extend(1);
                  l_reptext_en := l_reptext_en+1;
                  l_reptext_va(l_reptext_en) := '-- l_mmrltyp_rbvclcd_va.count: '||l_mmrltyp_rbvclcd_va.count;
                  --
*/
/*
                 --
                 -- Debugging parameters
                 --
                 l_reptext_va.extend(1);
                 l_reptext_en := l_reptext_en+1;
                 l_reptext_va(l_reptext_en) := '-- Debugging parameters ';
                 --
                 l_reptext_va.extend(1);
                 l_reptext_en := l_reptext_en+1;
                 l_reptext_va(l_reptext_en) := '-- l_clcode_va.count > l_rbv_clcode_va.count ';
                 --
*/
          for clvaen in l_clcode_va.first..l_clcode_va.last
          loop
            --
            l_rbvcode_match := FALSE;
            --
            for subvaen in l_rbv_clcode_va.first..l_rbv_clcode_va.last
            loop
              --
              if l_clcode_va(clvaen) = l_rbv_clcode_va(subvaen)
              then
                --
                l_rbvcode_match := TRUE;
                exit;
                --
              end if;
              --
            end loop;
            --
            if not l_rbvcode_match
            then
              --
              l_mmrltyp_rbvclcd_va.extend(1);
              l_mmrltyp_rbvclcd_va(l_mmrltyp_rbvclcd_vaen) := l_clcode_va(clvaen);
              l_mmrltyp_rbvclcd_vaen := l_mmrltyp_rbvclcd_vaen+1;
              --
            end if;
            --
          end loop;
          --
/*
            --
            -- Temporary debugging
            --
            if l_mmrltyp_rbvclcd_va.count > 0
            then
              --
              for tmpvaen in l_mmrltyp_rbvclcd_va.first..l_mmrltyp_rbvclcd_va.last
              loop
                --
                l_reptext_va.extend(1);
                l_reptext_en := l_reptext_en+1;
                l_reptext_va(l_reptext_en) := '----- l_mmrltyp_rbvclcd_va('||tmpvaen||') '
                                              ||l_mmrltyp_rbvclcd_va(tmpvaen);
                --
              end loop;
              --
            end if;
            --
*/
        elsif l_rbv_clcode_va.count > 0
          and l_clcode_va.count > 0
        then
          --
          for rbv_en in l_rbv_clcode_va.first..l_rbv_clcode_va.last
          loop
            --
            for clcd_en in l_clcode_va.first..l_clcode_va.last
            loop
              --
              if l_rbv_clcode_va(rbv_en) = l_clcode_va(clcd_en)
              then
                --
                if l_rbv_clcodecnt_va(rbv_en) <> l_clcodecnt_va(clcd_en)
                then
                  --
                  l_mmclccode_va.extend(1);
                  l_mmoclcount_va.extend(1);
                  l_mmnclcount_va.extend(1);
                  --
                  l_mmclccode_va(l_mm_elenum)    := l_clcode_va(clcd_en);
                  l_mmoclcount_va(l_mm_elenum)   := l_rbv_clcodecnt_va(rbv_en);
                  l_mmnclcount_va(l_mm_elenum)   := l_clcodecnt_va(clcd_en);
                  l_mm_elenum := l_mm_elenum+1;
                  --
                else
                  --
                  l_mtclccode_va.extend(1);
                  l_mtoclcount_va.extend(1);
                  l_mtnclcount_va.extend(1);
                  --
                  l_mtclccode_va(l_mt_elenum)  := l_clcodecnt_va(clcd_en);
                  l_mtoclcount_va(l_mt_elenum) := l_rbv_clcodecnt_va(rbv_en);
                  l_mtnclcount_va(l_mt_elenum) := l_clcodecnt_va(clcd_en);
                  l_mt_elenum := l_mt_elenum+1;
                  --
                end if;
                --
              end if;
              --
            end loop;
            --
          end loop;
          --
/*
            --
            -- Temporary debugging
            --
            if l_mmclccode_va.count > 0
            then
              --
              for tmpvaen in l_mmclccode_va.first..l_mmclccode_va.last
              loop
                --
                l_reptext_va.extend(1);
                l_reptext_en := l_reptext_en+1;
                l_reptext_va(l_reptext_en) := '----- l_mmclccode_va('||tmpvaen||') '
                                              ||l_mmclccode_va(tmpvaen)
                                              ||' Base: '||l_mmoclcount_va(tmpvaen)
                                              ||' Nw: '||l_mmnclcount_va(tmpvaen);
                --
              end loop;
              --
            end if;
            --
*/
        end if;
        --
        -- Get baseline application error details
        --
        get_appl_error_dets
          (p_bft_id       => row.benefit_action_id
          --
          ,p_errmesscd_va => l_mmerrmesscd_va
          ,p_mxperid_va   => l_mmmxperid_va
          ,p_errcnt_va    => l_mmerrcnt_va
          ,p_errtot       => l_mmapperr_tot
          );
        --
        if l_rbv_clcode_va.count = l_clcode_va.count
          and l_mmclccode_va.count = 0
          and l_mmapperr_tot = l_apperr_tot
          and l_mmerrmesscd_va.count = l_errmesscd_va.count
        then
          --
          l_reptext_va.extend(1);
          l_reptext_en := l_reptext_en+1;
          l_reptext_va(l_reptext_en) := '---- ';
          --
          if l_baseline_cnt = 0
          then
            --
            l_reptext_va.extend(1);
            l_reptext_en := l_reptext_en+1;
            l_reptext_va(l_reptext_en) := '---- No discrepancies with baseline: ('||row.benefit_action_id||') '
                                          ||' Time: '||to_char(row.LAST_UPDATE_DATE,'DD-MON-YYYY-HH24-MI-SS');
            --
          else
            --
            l_reptext_va.extend(1);
            l_reptext_en := l_reptext_en+1;
            l_reptext_va(l_reptext_en) := '---- No discrepancies with previous baseline: ('||row.benefit_action_id||') '
                                          ||' Time: '||to_char(row.LAST_UPDATE_DATE,'DD-MON-YYYY-HH24-MI-SS');
            --
          end if;
          --
        else
          --
          -- Check for bug discrepancies
          --
          l_pactup_cnt := 0;
          --
/*
                 --
                  -- Debugging parameters
                  --
                  l_reptext_va.extend(1);
                  l_reptext_en := l_reptext_en+1;
                  l_reptext_va(l_reptext_en) := '-- Debugging parameters ';
                  --
                  l_reptext_va.extend(1);
                  l_reptext_en := l_reptext_en+1;
                  l_reptext_va(l_reptext_en) := '-- l_mmclccode_va.count: '||l_mmclccode_va.count;
                  --
*/
          --
          -- Check for unprocessed person actions for baseline
          --
          if l_rbv_clcode_va.count > 0
          then
            --
            l_pactup_cnt   := 0;
            l_pactproc_cnt := 0;
            --
            for errvaen in l_rbv_clcode_va.first..l_rbv_clcode_va.last
            loop
              --
              if l_rbv_clcode_va(errvaen) = 'PERACTUNPROC'
              then
                --
                l_pactup_cnt := l_rbv_clcodecnt_va(errvaen);
                --
              elsif l_rbv_clcode_va(errvaen) = 'PERACTPROC'
              then
                --
                l_pactproc_cnt := l_rbv_clcodecnt_va(errvaen);
                --
              end if;
              --
            end loop;
            --
          end if;
          --
        end if;
        --
        -- Check person action issues
        --
        l_env_errors  := false;
        l_discrepancy := false;
        --
        if (l_pactup_cnt > 0
          or l_pactproc_cnt = 0)
          and (l_pactup_cnt <> l_pactproc_cnt)
        then
          --
          l_discrepancy := true;
          --
          l_reptext_va.extend(1);
          l_reptext_en := l_reptext_en+1;
          l_reptext_va(l_reptext_en) := '---- ';
          --
          l_reptext_va.extend(1);
          l_reptext_en := l_reptext_en+1;
          l_reptext_va(l_reptext_en) := '---- Baseline: ('||row.benefit_action_id||') '
                                      ||' Time: '||to_char(row.LAST_UPDATE_DATE,'DD-MON-YYYY-HH24-MI-SS');
          --
          if l_pactup_cnt > 0
          then
            --
            l_env_errors  := true;
            --
            l_reptext_va.extend(1);
            l_reptext_en := l_reptext_en+1;
            l_reptext_va(l_reptext_en) := '----- Baseline Environment Errors: '||l_pactup_cnt;
            --
          elsif l_pactproc_cnt = 0
          then
            --
            l_env_errors  := true;
            --
            l_reptext_va.extend(1);
            l_reptext_en := l_reptext_en+1;
            l_reptext_va(l_reptext_en) := '----- No person actions processed for baseline';
            --
          end if;
          --
        --
        -- Check for application error type or total discrepancies
        --
        elsif l_mmapperr_tot <> l_apperr_tot
          or l_mmerrmesscd_va.count <> l_errmesscd_va.count
        then
          --
          l_discrepancy := true;
          --
          -- Determine application error type discrepancies
          --
          l_apperrtyp_discr_en := 1;
          l_apperrtypdiscr_messcd_va.delete;
          l_apperrtypdiscr_cnt_va.delete;
          --
          if l_mmerrmesscd_va.count > 0
          then
            --
            for errvaen in l_mmerrmesscd_va.first..l_mmerrmesscd_va.last
            loop
              --
              l_check_match := FALSE;
              --
              if l_errmesscd_va.count > 0
              then
                --
                for errsubvaen in l_errmesscd_va.first..l_errmesscd_va.last
                loop
                  --
                  if l_mmerrmesscd_va(errvaen) = l_errmesscd_va(errsubvaen)
                    and l_mmerrcnt_va(errvaen) = l_errcnt_va(errsubvaen)
                  then
                    --
                    l_check_match := TRUE;
                    exit;
                    --
                  end if;
                  --
                end loop;
                --
              end if;
              --
              if not l_check_match
              then
                --
                l_apperrtypdiscr_messcd_va.extend(1);
                l_apperrtypdiscr_cnt_va.extend(1);
                l_apperrtypdiscr_messcd_va(l_apperrtyp_discr_en) := l_mmerrmesscd_va(errvaen);
                l_apperrtypdiscr_cnt_va(l_apperrtyp_discr_en) := l_mmerrcnt_va(errvaen);
                l_apperrtyp_discr_en := l_apperrtyp_discr_en+1;
                --
              end if;
              --
            end loop;
            --
          end if;
          --
          if l_errmesscd_va.count > 0
          then
            --
            for errvaen in l_errmesscd_va.first..l_errmesscd_va.last
            loop
              --
              l_check_match := FALSE;
              --
              if l_mmerrmesscd_va.count > 0
              then
                --
                for errsubvaen in l_mmerrmesscd_va.first..l_mmerrmesscd_va.last
                loop
                  --
                  if l_errmesscd_va(errvaen) = l_mmerrmesscd_va(errsubvaen)
                    and l_errcnt_va(errvaen) = l_mmerrcnt_va(errsubvaen)
                  then
                    --
                    l_check_match := TRUE;
                    exit;
                    --
                  end if;
                  --
                end loop;
                --
              end if;
              --
              if not l_check_match
              then
                --
                l_apperrtypdiscr_messcd_va.extend(1);
                l_apperrtypdiscr_cnt_va.extend(1);
                l_apperrtypdiscr_messcd_va(l_apperrtyp_discr_en) := l_errmesscd_va(errvaen);
                l_apperrtypdiscr_cnt_va(l_apperrtyp_discr_en) := l_errcnt_va(errvaen);
                l_apperrtyp_discr_en := l_apperrtyp_discr_en+1;
                --
              end if;
              --
            end loop;
            --
          end if;
          --
          -- Deduce application error person id discrepancies
          --
          l_newapperr_peridva.delete;
          --
          if l_apperrtypdiscr_messcd_va.count > 0
          then
            --
            l_periddiscrep_en := 1;
            l_periddiscrep_errcd_va.delete;
            l_periddiscrep_perid_va.delete;
            --
            for apperrvaen in l_apperrtypdiscr_messcd_va.first..l_apperrtypdiscr_messcd_va.last
            loop
              --
              open c_bfterrcdperids
                (c_bft_id => row.benefit_action_id
                ,c_err_cd => l_apperrtypdiscr_messcd_va(apperrvaen)
                );
              fetch c_bfterrcdperids BULK COLLECT INTO l_perid_va1;
              close c_bfterrcdperids;
              --
              open c_bfterrcdperids
                (c_bft_id => l_newbft_id_va(vaen)
                ,c_err_cd => l_apperrtypdiscr_messcd_va(apperrvaen)
                );
              fetch c_bfterrcdperids BULK COLLECT INTO l_perid_va2;
              close c_bfterrcdperids;
              --
              l_newapperr_peridva := l_perid_va2;
              --
              if l_perid_va1.count > 0
              then
                --
                for pervaen in l_perid_va1.first..l_perid_va1.last
                loop
                  --
                  l_check_match := FALSE;
                  --
                  if l_perid_va2.count > 0
                  then
                    --
                    for persubvaen in l_perid_va2.first..l_perid_va2.last
                    loop
                      --
                      if l_perid_va1(pervaen) = l_perid_va2(persubvaen)
                      then
                        --
                        l_check_match := TRUE;
                        exit;
                        --
                      end if;
                      --
                    end loop;
                    --
                  end if;
                  --
                  if not l_check_match
                  then
                    --
                    l_periddiscrep_perid_va.extend(1);
                    l_periddiscrep_errcd_va.extend(1);
                    l_periddiscrep_perid_va(l_periddiscrep_en) := l_perid_va1(pervaen);
                    l_periddiscrep_errcd_va(l_periddiscrep_en) := l_apperrtypdiscr_messcd_va(apperrvaen);
                    l_periddiscrep_en := l_periddiscrep_en+1;
                    --
                  end if;
                  --
                end loop;
                --
              end if;
              --
              if l_perid_va2.count > 0
              then
                --
                for pervaen in l_perid_va2.first..l_perid_va2.last
                loop
                  --
                  l_check_match := FALSE;
                  --
                  if l_perid_va1.count > 0
                  then
                    --
                    for persubvaen in l_perid_va1.first..l_perid_va1.last
                    loop
                      --
                      if l_perid_va2(pervaen) = l_perid_va1(persubvaen)
                      then
                        --
                        l_check_match := TRUE;
                        exit;
                        --
                      end if;
                      --
                    end loop;
                    --
                  end if;
                  --
                  if not l_check_match
                  then
                    --
                    l_periddiscrep_perid_va.extend(1);
                    l_periddiscrep_errcd_va.extend(1);
                    l_periddiscrep_perid_va(l_periddiscrep_en) := l_perid_va2(pervaen);
                    l_periddiscrep_errcd_va(l_periddiscrep_en) := l_apperrtypdiscr_messcd_va(apperrvaen);
                    l_periddiscrep_en := l_periddiscrep_en+1;
                    --
                  end if;
                  --
                end loop;
                --
              end if;
              --
            end loop;
            --
          end if;
          --
          l_reptext_va.extend(1);
          l_reptext_en := l_reptext_en+1;
          l_reptext_va(l_reptext_en) := '---- ';
          --
          l_reptext_va.extend(1);
          l_reptext_en := l_reptext_en+1;
          l_reptext_va(l_reptext_en) := '---- Baseline: ('||row.benefit_action_id||') '
                                      ||' Time: '||to_char(row.LAST_UPDATE_DATE,'DD-MON-YYYY-HH24-MI-SS');
          --
          if l_mmerrmesscd_va.count <> l_errmesscd_va.count
          then
            --
            l_reptext_va.extend(1);
            l_reptext_en := l_reptext_en+1;
            l_reptext_va(l_reptext_en) := '----- Baseline Application Error type discrepancy: New: '||l_errmesscd_va.count
                                          ||' Baseline: '||l_mmerrmesscd_va.count;
            --
          elsif l_mmapperr_tot <> l_apperr_tot
          then
            --
            l_reptext_va.extend(1);
            l_reptext_en := l_reptext_en+1;
            l_reptext_va(l_reptext_en) := '----- Baseline Application Error total discrepancy: New: '||l_apperr_tot
                                          ||' Baseline: '||l_mmapperr_tot;
            --
          end if;
          --
          if l_apperrtypdiscr_messcd_va.count > 0
          then
            --
            for errvaen in l_apperrtypdiscr_messcd_va.first..l_apperrtypdiscr_messcd_va.last
            loop
              --
              l_reptext_va.extend(1);
              l_reptext_en := l_reptext_en+1;
              l_reptext_va(l_reptext_en) := '------ '||l_apperrtypdiscr_cnt_va(errvaen)
                                            ||' '||l_apperrtypdiscr_messcd_va(errvaen);
              --
            end loop;
            --
            if l_periddiscrep_errcd_va.count > 0
            then
              --
              l_reptext_va.extend(1);
              l_reptext_en := l_reptext_en+1;
              l_reptext_va(l_reptext_en) := '------- Person id discrepancies ';
              --
              for pervaen in l_periddiscrep_errcd_va.first..l_periddiscrep_errcd_va.last
              loop
                --
                l_reptext_va.extend(1);
                l_reptext_en := l_reptext_en+1;
                l_reptext_va(l_reptext_en) := '------- '||l_periddiscrep_errcd_va(pervaen)
                                              ||' '||l_periddiscrep_perid_va(pervaen);
                --
              end loop;
              --
            end if;
            --
          end if;
          --
        end if;
        --
        -- Check for rollup type discrepancies
        --
        if not l_env_errors
        then
          --
          if l_mmrltyp_rbvclcd_va.count > 0
            and l_clcode_va.count <> l_rbv_clcode_va.count
          then
            --
            l_reptext_va.extend(1);
            l_reptext_en := l_reptext_en+1;
            l_reptext_va(l_reptext_en) := '---- ';
            --
            -- Check for the first discrepancy
            --
            if not l_discrepancy
            then
              --
              l_reptext_va.extend(1);
              l_reptext_en := l_reptext_en+1;
              l_reptext_va(l_reptext_en) := '---- Baseline: ('||row.benefit_action_id||') '
                                          ||' Time: '||to_char(row.LAST_UPDATE_DATE,'DD-MON-YYYY-HH24-MI-SS');
              --
            end if;
            --
            l_discrepancy := true;
            --
            l_reptext_va.extend(1);
            l_reptext_en := l_reptext_en+1;
            l_reptext_va(l_reptext_en) := '----- Rollup type discrepancies '
                                ||' New: '||l_clcode_va.count
                                ||' Baseline: '||l_rbv_clcode_va.count;
            --
            l_mmapperrfilt_cnt := 0;
            l_mmledatafilt_cnt := 0;
            --
            for clvaen in l_mmrltyp_rbvclcd_va.first..l_mmrltyp_rbvclcd_va.last
            loop
/*
                --
                -- Temporary
                --
                dbms_output.put_line('- BENTSTHN: Roll: '||l_mmrltyp_rbvclcd_va(clvaen)
                                    ||' OBFTID: '||row.benefit_action_id
                                    ||' NBFTID: '||l_newbft_id_va(vaen)
                                    );
                --
*/
              --
              ben_rollup_rbvs.get_rollup_code_combkey_va
                (p_rollup_code           => l_mmrltyp_rbvclcd_va(clvaen)
                ,p_old_benefit_action_id => row.benefit_action_id
                ,p_new_benefit_action_id => l_newbft_id_va(vaen)
                --
                ,p_perid_va              => l_mmperid_va
                ,p_perlud_va             => l_mmperlud_va
                ,p_combnm_va             => l_mmcombnm_va
                ,p_combnm2_va            => l_mmcombnm2_va
                ,p_combnm3_va            => l_mmcombnm3_va
                ,p_combnm4_va            => l_mmcombnm4_va
                ,p_combid_va             => l_mmcombid_va
                ,p_combid2_va            => l_mmcombid2_va
                ,p_combid3_va            => l_mmcombid3_va
                ,p_combid4_va            => l_mmcombid4_va
                ,p_cnt_va                => l_mmcnt_va
                );
/*
                  --
                  -- Debugging
                  --
                  l_reptext_va.extend(1);
                  l_reptext_en := l_reptext_en+1;
                  l_reptext_va(l_reptext_en) := '----- Pre filt: '||l_mmrltyp_rbvclcd_va(clvaen)
                                                ||' l_mmperid_va.count: '||l_mmperid_va.count
                                                ||' l_mmcombid2_va.count: '||l_mmcombid2_va.count;
                  --
*/
              --
              -- Filter out new application error person ids
              --
              if l_periddiscrep_perid_va.count > 0
              then
                --
                filter_discrepperids
                  (p_perid_va     => l_newapperr_peridva
                  ,p_mmperid_va   => l_mmperid_va
                  ,p_mmperlud_va  => l_mmperlud_va
                  ,p_mmcombnm_va  => l_mmcombnm_va
                  ,p_mmcombnm2_va => l_mmcombnm2_va
                  ,p_mmcombid_va  => l_mmcombid_va
                  ,p_mmcombid2_va => l_mmcombid2_va
                  ,p_mmcnt_va     => l_mmcnt_va
                  ,p_exclperid_va => l_mmexclperid_nwva
                  );
                --
                -- Filter out discrepancy application error person ids
                --
                filter_discrepperids
                  (p_perid_va     => l_periddiscrep_perid_va
                  ,p_mmperid_va   => l_mmperid_va
                  ,p_mmperlud_va  => l_mmperlud_va
                  ,p_mmcombnm_va  => l_mmcombnm_va
                  ,p_mmcombnm2_va => l_mmcombnm2_va
                  ,p_mmcombid_va  => l_mmcombid_va
                  ,p_mmcombid2_va => l_mmcombid2_va
                  ,p_mmcnt_va     => l_mmcnt_va
                  ,p_exclperid_va => l_mmexclperid_va
                  );
                --
              end if;
              --
              -- Filter out life event data changes
              --
              filter_ledatachgperids
                (p_lud          => row.last_update_date
                ,p_mmperid_va   => l_mmperid_va
                ,p_mmperlud_va  => l_mmperlud_va
                ,p_mmcombnm_va  => l_mmcombnm_va
                ,p_mmcombnm2_va => l_mmcombnm2_va
                ,p_mmcombid_va  => l_mmcombid_va
                ,p_mmcombid2_va => l_mmcombid2_va
                ,p_mmcnt_va     => l_mmcnt_va
                ,p_exclperid_va => l_mmexclperid_leva
                );
/*
                  --
                  -- Debugging
                  --
                  l_reptext_va.extend(1);
                  l_reptext_en := l_reptext_en+1;
                  l_reptext_va(l_reptext_en) := '----- '||l_mmrltyp_rbvclcd_va(clvaen)
                                                ||' l_mmperid_va.count: '||l_mmperid_va.count
                                                ||' l_mmcombid2_va.count: '||l_mmcombid2_va.count;
                  --
*/
              --
              -- Check if all perids were app error perids
              --
              if l_mmperid_va.count > 0
              then
                --
                l_reptext_va.extend(1);
                l_reptext_en := l_reptext_en+1;
                l_reptext_va(l_reptext_en) := '------ '||l_mmrltyp_rbvclcd_va(clvaen);
              --
              -- Check for app error exclusions
              --
              elsif l_mmexclperid_va.count > 0
                or l_mmexclperid_nwva.count > 0
              then
                --
                l_mmapperrfilt_cnt := l_mmapperrfilt_cnt+1;
                --
              --
              -- Check for app error exclusions
              --
              elsif l_mmexclperid_leva.count > 0
              then
                --
                l_mmledatafilt_cnt := l_mmledatafilt_cnt+1;
                --
              end if;
              --
              if l_mmperid_va.count > 0
              then
                --
                l_mmcombid_cnt  := l_mmcombid_va.count;
                l_mmcombid2_cnt := l_mmcombid2_va.count;
                l_mmperlud_cnt  := l_mmperlud_va.count;
                --
                for subvaen in l_mmperid_va.first..l_mmperid_va.last
                loop
                  --
                  -- Only display a maximum of 5 person ids
                  --
                  if subvaen > 5
                  then
                    --
                    exit;
                    --
                  end if;
                  --
                  l_reptext := 'PERID: '||l_mmperid_va(subvaen);
                  --
                  l_reptext := l_reptext||' Cnt: '||l_mmcnt_va(subvaen);
                  --
                  if l_mmperlud_cnt > 0
                  then
                    --
                    l_reptext := l_reptext||' LUD: '
                                 ||to_char(l_mmperlud_va(subvaen),'DD-MON-YYYY HH24-MI-SS');

                    --
                    -- Check for a person data change
                    --
                    if l_mmperlud_va(subvaen) > row.last_update_date
                    then
                      --
                      l_reptext := 'LE Change: '||l_reptext;
                      --
                    end if;
                    --
                  end if;
                  --
                  l_reptext := '-------- '||l_reptext;
                  --
                  l_reptext_va.extend(1);
                  l_reptext_en := l_reptext_en+1;
                  l_reptext_va(l_reptext_en) := substr(l_reptext,1,150);
                  --
                  l_reptext := null;
                  --
                  if l_mmcombid_cnt > 0
                    and l_mmcombid_va(subvaen) is not null
                  then
                    --
                    l_reptext := l_reptext||' '||l_mmcombnm_va(subvaen)||': '||l_mmcombid_va(subvaen);

                    --
                  end if;
                  --
                  if l_mmcombid2_cnt > 0
                    and l_mmcombid2_va(subvaen) is not null
                  then
                    --
                    l_reptext := l_reptext||' '||l_mmcombnm2_va(subvaen)||': '||l_mmcombid2_va(subvaen);


                    --
                  end if;
                  --
                  if l_reptext is not null
                  then
                    --
                    l_reptext := '--------- '||l_reptext;
                    --
                    l_reptext_va.extend(1);
                    l_reptext_en := l_reptext_en+1;
                    l_reptext_va(l_reptext_en) := substr(l_reptext,1,150);
                    --
                  end if;
                  --
                end loop;
                --
              end if;
              --
            end loop;
            --
            -- Check for filtered discrepancy types
            --
            if l_mmapperrfilt_cnt > 0
            then
              --
              l_reptext_va.extend(1);
              l_reptext_en := l_reptext_en+1;
              l_reptext_va(l_reptext_en) := '------ Caused by app error discrepancies: '||l_mmapperrfilt_cnt;
              --
            elsif l_mmledatafilt_cnt > 0
            then
              --
              l_reptext_va.extend(1);
              l_reptext_en := l_reptext_en+1;
              l_reptext_va(l_reptext_en) := '------ Caused by life event data changes: '||l_mmledatafilt_cnt;
              --
            end if;
            --
          --
          -- Check for rollup count discrepancies
          --
          elsif l_mmclccode_va.count > 0
          then
            --
            l_reptext_va.extend(1);
            l_reptext_en := l_reptext_en+1;
            l_reptext_va(l_reptext_en) := '---- ';
            --
            -- Check for the first discrepancy
            --
            if not l_discrepancy
            then
              --
              l_reptext_va.extend(1);
              l_reptext_en := l_reptext_en+1;
              l_reptext_va(l_reptext_en) := '---- Baseline: ('||row.benefit_action_id||') '
                                          ||' Time: '||to_char(row.LAST_UPDATE_DATE,'DD-MON-YYYY-HH24-MI-SS');
              --
            end if;
            --
            l_discrepancy := true;
            --
            l_reptext_va.extend(1);
            l_reptext_en := l_reptext_en+1;
            l_reptext_va(l_reptext_en) := '----- Row count discrepancies: '||l_mmclccode_va.count;
            --
            l_mmapperrfilt_cnt := 0;
            l_mmledatafilt_cnt := 0;
            --
            for elenum in l_mmclccode_va.first..l_mmclccode_va.last
            loop
              --
              -- Don't flag bug count discrepancies
              --
              if instr(l_mmclccode_va(elenum),'WWBUGS') > 0
              then
                --
                null;
                --
              elsif l_mmoclcount_va(elenum) <> l_mmnclcount_va(elenum)
              then
                --
                ben_rollup_rbvs.get_rollup_code_combkey_va
                  (p_rollup_code           => l_mmclccode_va(elenum)
                  ,p_old_benefit_action_id => row.benefit_action_id
                  ,p_new_benefit_action_id => l_newbft_id_va(vaen)
                  --
                  ,p_perid_va              => l_mmperid_va
                  ,p_perlud_va             => l_mmperlud_va
                  ,p_combnm_va             => l_mmcombnm_va
                  ,p_combnm2_va            => l_mmcombnm2_va
                  ,p_combnm3_va            => l_mmcombnm3_va
                  ,p_combnm4_va            => l_mmcombnm4_va
                  ,p_combid_va             => l_mmcombid_va
                  ,p_combid2_va            => l_mmcombid2_va
                  ,p_combid3_va            => l_mmcombid3_va
                  ,p_combid4_va            => l_mmcombid4_va
                  ,p_cnt_va                => l_mmcnt_va
                  );
/*
                  --
                  -- Debugging
                  --
                  l_reptext_va.extend(1);
                  l_reptext_en := l_reptext_en+1;
                  l_reptext_va(l_reptext_en) := '----- '||l_mmclccode_va(elenum)
                                                ||' l_mmperid_va.count: '||l_mmperid_va.count
                                                ||' cbid cnt: '||l_mmcombid_va.count
                                                ||' cbid2 cnt: '||l_mmcombid2_va.count
                                                ||' cbid3 cnt: '||l_mmcombid3_va.count
                                                ||' cbid4 cnt: '||l_mmcombid4_va.count;
*/
/*
                  dbms_output.put_line('----- '||l_mmclccode_va(elenum)
                                      ||' l_mmperid_va.count: '||l_mmperid_va.count
                                      ||' NwBFTID: '||row.benefit_action_id
                                      ||' OldBFTID: '||l_newbft_id_va(vaen)
                                      );
                  --
*/
                --
                -- Filter out new application error person ids
                --
                if l_periddiscrep_perid_va.count > 0
                then
                  --
                  filter_discrepperids
                    (p_perid_va     => l_newapperr_peridva
                    ,p_mmperid_va   => l_mmperid_va
                    ,p_mmperlud_va  => l_mmperlud_va
                    ,p_mmcombnm_va  => l_mmcombnm_va
                    ,p_mmcombnm2_va => l_mmcombnm2_va
                    ,p_mmcombid_va  => l_mmcombid_va
                    ,p_mmcombid2_va => l_mmcombid2_va
                    ,p_mmcnt_va     => l_mmcnt_va
                    ,p_exclperid_va => l_mmexclperid_nwva
                    );
                  --
                  -- Filter out discrepancy application error person ids
                  --
                  filter_discrepperids
                    (p_perid_va     => l_periddiscrep_perid_va
                    ,p_mmperid_va   => l_mmperid_va
                    ,p_mmperlud_va  => l_mmperlud_va
                    ,p_mmcombnm_va  => l_mmcombnm_va
                    ,p_mmcombnm2_va => l_mmcombnm2_va
                    ,p_mmcombid_va  => l_mmcombid_va
                    ,p_mmcombid2_va => l_mmcombid2_va
                    ,p_mmcnt_va     => l_mmcnt_va
                    ,p_exclperid_va => l_mmexclperid_va
                    );
                  --
                end if;
/*
                  --
                  -- Debugging
                  --
                  l_reptext_va.extend(1);
                  l_reptext_en := l_reptext_en+1;
                  l_reptext_va(l_reptext_en) := '----- '||l_mmclccode_va(elenum)
                                                ||' l_mmperid_va.count: '||l_mmperid_va.count
                                                ||' exclperid cnt: '||l_mmexclperid_va.count
                                                ||' perdiscrep cnt: '||l_periddiscrep_perid_va.count;
                  dbms_output.put_line('----- '||l_mmclccode_va(elenum)
                                      ||' l_mmperid_va.count: '||l_mmperid_va.count
                                      ||' NwBFTID: '||row.benefit_action_id
                                      ||' OldBFTID: '||l_newbft_id_va(vaen)
                                      );
                  --
*/
                --
                -- Filter out life event data changes
                --
                filter_ledatachgperids
                  (p_lud          => row.last_update_date
                  ,p_mmperid_va   => l_mmperid_va
                  ,p_mmperlud_va  => l_mmperlud_va
                  ,p_mmcombnm_va  => l_mmcombnm_va
                  ,p_mmcombnm2_va => l_mmcombnm2_va
                  ,p_mmcombid_va  => l_mmcombid_va
                  ,p_mmcombid2_va => l_mmcombid2_va
                  ,p_mmcnt_va     => l_mmcnt_va
                  ,p_exclperid_va => l_mmexclperid_leva
                  );
                --
                -- Check if all perids were app error perids
                --
                if l_mmperid_va.count > 0
                then
                  --
                  l_reptext_va.extend(1);
                  l_reptext_en := l_reptext_en+1;
                  l_reptext_va(l_reptext_en) := '------- '||l_mmclccode_va(elenum)
                                                ||' New: '||l_mmnclcount_va(elenum)
                                                ||' Baseline: '||l_mmoclcount_va(elenum);
                --
                -- Check for app error exclusions
                --
                elsif l_mmexclperid_va.count > 0
                  or l_mmexclperid_nwva.count > 0
                then
                  --
                  l_mmapperrfilt_cnt := l_mmapperrfilt_cnt+1;
                  --
                --
                -- Check for app error exclusions
                --
                elsif l_mmexclperid_leva.count > 0
                then
                  --
                  l_mmledatafilt_cnt := l_mmledatafilt_cnt+1;
                  --
                end if;
                --
/*
                  --
                  -- Debugging
                  --
                  l_reptext_va.extend(1);
                  l_reptext_en := l_reptext_en+1;
                  l_reptext_va(l_reptext_en) := '------- '||l_mmclccode_va(elenum)
                                                ||' PERIDCnt: '||l_mmperid_va.count
                                                ||' CNmCnt: '||l_mmcombnm_va.count
                                                ||' CIdCnt: '||l_mmcombid_va.count
                                                ||' CNm2Cnt: '||l_mmcombnm_va.count
                                                ||' CId2Cnt: '||l_mmcombid_va.count;
                  --
*/
                --
                if l_mmperid_va.count > 0
                then
                  --
                  l_mmcombid_cnt  := l_mmcombid_va.count;
                  l_mmperlud_cnt  := l_mmperlud_va.count;
                  l_mmcombid2_cnt := l_mmcombid2_va.count;
                  --
                  for subvaen in l_mmperid_va.first..l_mmperid_va.last
                  loop
                    --
                    -- Only display a maximum of 5 person ids
                    --
                    if subvaen > 5
                    then
                      --
                      exit;
                      --
                    end if;
                    --
                    l_reptext := 'PERID: '||l_mmperid_va(subvaen);
                    --
                    l_reptext := l_reptext||' Cnt: '||l_mmcnt_va(subvaen);
                    --
                    if l_mmperlud_cnt > 0
                    then
                      --
                      l_reptext := l_reptext||' LUD: '
                                   ||to_char(l_mmperlud_va(subvaen),'DD-MON-YYYY HH24-MI-SS');

                      --
                      -- Check for a person data change
                      --
                      if l_mmperlud_va(subvaen) > row.last_update_date
                      then
                        --
                        l_reptext := 'LE Change: '||l_reptext;
                        --
                      end if;
                      --
                    end if;
                    --
                    l_reptext := '-------- '||l_reptext;
                    --
                    l_reptext_va.extend(1);
                    l_reptext_en := l_reptext_en+1;
                    l_reptext_va(l_reptext_en) := substr(l_reptext,1,150);
                    --
                    l_reptext := null;
                    --
                    if l_mmcombid_cnt > 0
                      and l_mmcombid_va(subvaen) is not null
                    then
                      --
                      l_reptext := l_reptext||' '||l_mmcombnm_va(subvaen)||': '||l_mmcombid_va(subvaen);

                      --
                    end if;
                    --
                    if l_mmcombid2_cnt > 0
                      and l_mmcombid2_va(subvaen) is not null
                    then
                      --
                      l_reptext := l_reptext||' '||l_mmcombnm2_va(subvaen)||': '||l_mmcombid2_va(subvaen);


                      --
                    end if;
                    --
                    if l_reptext is not null
                    then
                      --
                      l_reptext := '--------- '||l_reptext;
                      --
                      l_reptext_va.extend(1);
                      l_reptext_en := l_reptext_en+1;
                      l_reptext_va(l_reptext_en) := substr(l_reptext,1,150);
                      --
                    end if;
                    --
                  end loop;

                end if;
                --
              end if;
              --
            end loop;
            --
            -- Check for filtered discrepancy types
            --
            if l_mmapperrfilt_cnt > 0
            then
              --
              l_reptext_va.extend(1);
              l_reptext_en := l_reptext_en+1;
              l_reptext_va(l_reptext_en) := '------ Caused by app error discrepancies: '||l_mmapperrfilt_cnt;
              --
            end if;
            --
            if l_mmledatafilt_cnt > 0
            then
              --
              l_reptext_va.extend(1);
              l_reptext_en := l_reptext_en+1;
              l_reptext_va(l_reptext_en) := '------ Caused by life event data changes: '||l_mmledatafilt_cnt;
              --
            end if;
            --
          end if;
          --
        end if;
        --
        l_baseline_cnt := l_baseline_cnt+1;
        --
      end loop;
      --
    end loop;
/*
    --
    -- Display patching info
    --
    --   Get bug discrepancies
    --
    open c_prodbugs
      (c_basebft_id => l_newbft_id_va(l_newbft_id_va.last)
      ,c_bft_id     => l_newbft_id_va(l_newbft_id_va.first)
      );
    fetch c_prodbugs BULK COLLECT INTO l_bugpscode_va, l_bugnum_va, l_buglud_va;
    close c_prodbugs;
    --
    if l_bugpscode_va.count > 0
    then
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '----- ';
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '----- Bugs applied: '||l_bugpscode_va.count;
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '----- ';
      --
      for bugvaen in l_bugpscode_va.first..l_bugpscode_va.last
      loop
        --
        l_reptext_va.extend(1);
        l_reptext_en := l_reptext_en+1;
        l_reptext_va(l_reptext_en) := '------ '||l_bugpscode_va(bugvaen)
                                      ||' '||l_bugnum_va(bugvaen)
                                      ||' '||to_char(l_buglud_va(bugvaen),'DD-MON-YYYY-HH24-MI-SS');
        --
      end loop;
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '----';
      --
    end if;
*/
    --
    -- Get BEN file discrepancies
    --
    open c_adfiles
      (c_basebft_id => l_newbft_id_va(l_newbft_id_va.last)
      ,c_bft_id     => l_newbft_id_va(l_newbft_id_va.first)
      );
    fetch c_adfiles BULK COLLECT INTO l_adfname_va, l_adffilver_va,l_adflud_va;
    close c_adfiles;
    --
    if l_adfname_va.count > 0
    then
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '----- Files applied: '||l_adfname_va.count;
      --
      for bugvaen in l_adfname_va.first..l_adfname_va.last
      loop
        --
        -- Only display a maximum of 100 files
        --
        if bugvaen > 200
        then
          --
          exit;
          --
        end if;
        --
        l_reptext_va.extend(1);
        l_reptext_en := l_reptext_en+1;
        l_reptext_va(l_reptext_en) := '------ '||l_adfname_va(bugvaen)
                                      ||' '||l_adffilver_va(bugvaen)
                                      ||' '||to_char(l_adflud_va(bugvaen),'DD-MON-YYYY-HH24-MI-SS');
        --
      end loop;
      --
      l_reptext_va.extend(1);
      l_reptext_en := l_reptext_en+1;
      l_reptext_va(l_reptext_en) := '----';
      --
    end if;
    --
    -- Populate ben_reporting
    --
    if l_reptext_va.count > 0 then
      --
      for repvaen in l_reptext_va.first..l_reptext_va.last
      loop
        --
        if fnd_global.conc_request_id <> -1
        then
          --
          fnd_file.put_line
             (which => fnd_file.log
             ,buff  => l_reptext_va(repvaen)
             );
          --
        end if;
        --
        -- Copy all varray to single column varrays.
        --
        l_num1_col.extend(1);
        --
        select ben_reporting_s.nextval into
        l_num1_col(repvaen)
        from sys.dual;
/*
        l_num1_col(l_count) :=
          g_report_table_object(l_count).reporting_id;
*/
        --
        -- Benefit action
        --
        l_num2_col.extend(1);
        l_num2_col(repvaen) := l_thnbft_id;
        --
        -- Thread
        --
        l_num3_col.extend(1);
        l_num3_col(repvaen) := 1;
        --
        -- Sequence
        --
        l_num4_col.extend(1);
        l_num4_col(repvaen) := repvaen;
        --
        -- Text
        --
        l_var1_col.extend(1);
        l_var1_col(repvaen) := l_reptext_va(repvaen);
        --
        -- OVN
        --
        l_num5_col.extend(1);
        l_num5_col(repvaen) := 1;
        --
        -- OVN
        --
        l_var2_col.extend(1);
        l_var2_col(repvaen) := null;
        l_var3_col.extend(1);
        l_var3_col(repvaen) := null;
        l_var4_col.extend(1);
        l_var4_col(repvaen) := null;
        l_num6_col.extend(1);
        l_num6_col(repvaen) := null;
        l_num7_col.extend(1);
        l_num7_col(repvaen) := null;
        l_num8_col.extend(1);
        l_num8_col(repvaen) := null;
        l_num9_col.extend(1);
        l_num9_col(repvaen) := null;
        l_num10_col.extend(1);
        l_num10_col(repvaen) := null;
        l_num11_col.extend(1);
        l_num11_col(repvaen) := null;
        l_num12_col.extend(1);
        l_num12_col(repvaen) := null;
        l_num13_col.extend(1);
        l_num13_col(repvaen) := null;
        l_num14_col.extend(1);
        l_num14_col(repvaen) := null;
        l_num15_col.extend(1);
        l_num15_col(repvaen) := null;
        l_num16_col.extend(1);
        l_num16_col(repvaen) := null;
        l_num17_col.extend(1);
        l_num17_col(repvaen) := null;
        l_num18_col.extend(1);
        l_num18_col(repvaen) := null;
        --
      end loop;
      --
      forall insvaen in l_num1_col.first..l_num1_col.last
        insert into ben_reporting
          (reporting_id,
           benefit_action_id,
           thread_id,
           sequence,
           text,
           object_version_number,
           rep_typ_cd,
           error_message_code,
           national_identifier,
           related_person_ler_id,
           temporal_ler_id,
           ler_id,
           person_id,
           pgm_id,
           pl_id,
           related_person_id,
           oipl_id,
           pl_typ_id,
           actl_prem_id,
           val,
           mo_num,
           yr_num)
         values
          (l_num1_col(insvaen),
           l_num2_col(insvaen),
           l_num3_col(insvaen),
           l_num4_col(insvaen),
           l_var1_col(insvaen),
           l_num5_col(insvaen),
           l_var2_col(insvaen),
           l_var3_col(insvaen),
           l_var4_col(insvaen),
           l_num6_col(insvaen),
           l_num7_col(insvaen),
           l_num8_col(insvaen),
           l_num9_col(insvaen),
           l_num10_col(insvaen),
           l_num11_col(insvaen),
           l_num12_col(insvaen),
           l_num13_col(insvaen),
           l_num14_col(insvaen),
           l_num15_col(insvaen),
           l_num16_col(insvaen),
           l_num17_col(insvaen),
           l_num18_col(insvaen));
      --
    end if;
    --
  end if;
  --
END process;
--
procedure BFT_DispRepErrInfo
  (p_bft_id      in number
  ,p_reperr_text in boolean
  ,p_disp_rows   in number
  ,p_ext_rslt_id in number
  --
  ,p_dispout_va  in out nocopy benutils.g_varchar2_table
  )
is
  --
  l_dispout_va     benutils.g_varchar2_table := benutils.g_varchar2_table();
  --
  l_errcode        varchar2(2000);
  l_ele_num        pls_integer;
  l_dispout_en     pls_integer;
  l_ersltdet_count number;
  --
  cursor c_gerrcode
    (c_bft_id in number
    )
  is
    select rep.ERROR_MESSAGE_CODE
    from ben_reporting rep
    where rep.benefit_action_id = c_bft_id
    and   rep.ERROR_MESSAGE_CODE is not null;
  --
  cursor c_gbenrepercdsum
    (c_bft_id in number
    )
  is
    select ERROR_MESSAGE_CODE,
           max(person_id) mx_perid,
           count(*) cnt
    from ben_reporting
    where benefit_action_id = c_bft_id
    and   ERROR_MESSAGE_CODE is not null
    group by ERROR_MESSAGE_CODE
    order by count(*) desc;
  --
  cursor c_gbenrepdets
    (c_bft_id in number
    )
  is
    select rep.text,
           rep.thread_id,
           rep.person_id,
           rep.last_update_login
    from ben_reporting rep
    where rep.benefit_action_id = c_bft_id
    order by thread_id, reporting_id;
  --
  cursor c_ersltdetcnt
    (c_ext_rslt_id number
    )
  is
    select count(*)
    from BEN_EXT_RSLT_DTL
    where EXT_RSLT_ID = c_ext_rslt_id;
  --
  cursor c_erslterrsum
    (c_ext_rslt_id number
    )
  is
    select TYP_CD,
           ERR_NUM,
           count(*) cnt
    from BEN_EXT_RSLT_ERR
    where EXT_RSLT_ID = c_ext_rslt_id
    group by TYP_CD,
          ERR_NUM
    order by count(*) desc;
  --
  cursor c_erslterrdet
    (c_ext_rslt_id number
    ,c_typ_cd      varchar2
    )
  is
    select ERR_NUM,
           ERR_TXT,
           count(*) cnt
    from BEN_EXT_RSLT_ERR
    where EXT_RSLT_ID = c_ext_rslt_id
    and   TYP_CD = c_typ_cd
    group by ERR_NUM,
             ERR_TXT
    order by count(*) desc;
  --
begin
  --
  l_dispout_en := 1;
  l_dispout_va.extend(1);
  l_dispout_va(l_dispout_en) := '-- Error code summary: ';
  --
  -- Get error code
  --
  for codesum in c_gbenrepercdsum
    (c_bft_id => p_bft_id
    )
  loop
    --
    l_dispout_va.extend(1);
    l_dispout_en := l_dispout_en+1;
    l_dispout_va(l_dispout_en) := codesum.cnt||' '||codesum.ERROR_MESSAGE_CODE||' '||codesum.mx_perid;
    --
  end loop;
  --
  -- Get reporting info
  --
  if p_reperr_text
  then
    --
    l_dispout_va.extend(1);
    l_dispout_en := l_dispout_en+1;
    l_dispout_va(l_dispout_en) := 'Reporting lines ';
    --
    l_ele_num := 0;
    --
    for row_rep in c_gbenrepdets(p_bft_id)
    loop
      --
      if l_ele_num > p_disp_rows
      then
        --
        exit;
        --
      end if;
      --
      l_dispout_va.extend(1);
      l_dispout_en := l_dispout_en+1;
      l_dispout_va(l_dispout_en) := row_rep.thread_id||' '||substr(row_rep.text,1,250);
      --
      l_ele_num := l_ele_num+1;
      --
    end loop;
    --
  end if;
  --
  -- Check for an extract BFT
  --
  if p_ext_rslt_id is not null
  then
    --
    open c_ersltdetcnt
      (c_ext_rslt_id => p_ext_rslt_id
      );
    fetch c_ersltdetcnt into l_ersltdet_count;
    close c_ersltdetcnt;
    --
    l_dispout_va.extend(1);
    l_dispout_en := l_dispout_en+1;
    l_dispout_va(l_dispout_en) := ' Ex RSLT Det Cnt: '||l_ersltdet_count;
    --
    -- Extract error summary
    --
    for exterr in c_erslterrsum
      (c_ext_rslt_id => p_ext_rslt_id
      )
    loop
      --
      l_dispout_va.extend(1);
      l_dispout_en := l_dispout_en+1;
      l_dispout_va(l_dispout_en) := ' - Err Typ: '||exterr.TYP_CD
                                    ||' Err Num: '||exterr.ERR_NUM
                                    ||' Err Cnt: '||exterr.cnt;
      --
      if exterr.TYP_CD = 'F'
      then
        --
        for fatexterr in c_erslterrdet
          (c_ext_rslt_id => p_ext_rslt_id
          ,c_typ_cd      => exterr.TYP_CD
          )
        loop
          --
          l_dispout_va.extend(1);
          l_dispout_en := l_dispout_en+1;
          l_dispout_va(l_dispout_en) := ' -- Num: '||fatexterr.ERR_NUM
                              ||' '||substr(fatexterr.ERR_TXT,1,60);
          --
        end loop;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  p_dispout_va := l_dispout_va;
  --
end BFT_DispRepErrInfo;
--
end ben_test_harness;

/
