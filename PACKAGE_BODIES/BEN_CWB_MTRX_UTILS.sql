--------------------------------------------------------
--  DDL for Package Body BEN_CWB_MTRX_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_MTRX_UTILS" as
/* $Header: bencwbmtrxutils.pkb 120.4.12000000.1 2007/01/19 15:25:17 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'ben_cwb_mtrx_utils.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< UPDATE_RATES >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_rates
  (p_group_per_in_ler_id           in     number
  ,p_pl_id                         in     number
  ,p_oipl_id                       in     number
  ,p_object_version_number         in     number
  ,p_elig_sal                      in     number
  ,p_xchg_rate                     in     number
  ,p_nn_mntry                      in     varchar2
  ,p_rndg_cd                       in     varchar2
  ,p_assignment_id                 in     number
  ,p_alct_by                       in     varchar2
  ,p_trg_val                       in     number
  ) is
  --
  l_val      number;
  l_ovn      number;
  l_proc     varchar2(72) := g_package||'update_rates';
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if (p_alct_by = 'PCT') then
    -- Calculate Amount using Pct of Elig Sal
    l_val := (p_trg_val * p_elig_sal) / 100;
  elsif (p_alct_by = 'AMT' and p_nn_mntry is null) then
    -- Convert Amount into Local Currency Value
    l_val := p_trg_val * p_xchg_rate;
  else
    -- Don't convert the value if units is non-monetary
    l_val := p_trg_val;
  end if;
  -- Bug 5532745
  if p_rndg_cd is not null then
    l_val := benutils.do_rounding
            (p_rounding_cd => p_rndg_cd
            ,p_rounding_rl => null
            ,p_assignment_id => p_assignment_id
            ,p_value         => l_val
            ,p_effective_date => trunc(sysdate));
  end if;
  --
  -- Assign Object Version Number to local variable
  l_ovn := p_object_version_number;
  --
  --
  ben_cwb_person_rates_api.update_person_rate(p_group_per_in_ler_id => p_group_per_in_ler_id
                                             ,p_pl_id => p_pl_id
                                             ,p_oipl_id => p_oipl_id
                                             ,p_rec_val => l_val
                                             ,p_perf_min_max_edit => 'N'
                                             ,p_object_version_number => l_ovn);
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end update_rates;

--
function get_profile_value(p_profile_name  in varchar2
                          ,p_current_value in number) return number is
  l_profile_value  varchar2(255);
begin
  l_profile_value := fnd_profile.value(p_profile_name);
  if l_profile_value is not null then
    return to_number(l_profile_value, '9999999.99999');
  else
    return p_current_value;
  end if;
exception
  when others then
    return p_current_value;
end get_profile_value;

-- End of Procedure
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< POP_TRG_AMTS >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure pop_trg_amts
  (p_validate                      in     boolean
  ,p_acting_mgr_pil_id             in     number
  ,p_mgr_pil_ids                   in     BEN_CWB_ACCESS_STRING_ARRAY
  ,p_lvl_num                       in     number
  ,p_grp_pl_id                     in     number
  ,p_grp_oipl_id                   in     number
  ,p_name_type                     in     varchar2
  ,p_crit_cd1                      in     varchar2
  ,p_crit_cd2                      in     varchar2
  ,p_crit_vals1                    in     BEN_CWB_ACCESS_STRING_ARRAY
  ,p_crit_vals2                    in     BEN_CWB_ACCESS_STRING_ARRAY
  ,p_alct_by                       in     varchar2
  ,p_trg_val                       in     BEN_CWB_ACCESS_STRING_ARRAY
  ) is
  --
  -- Declare cursors and local variables
  l_compratio_range number := 5;
  l_los_range       number := 1;
  --
  -- Cursor for getting Population under a Manager depending upon the Pop code
  --
  cursor csr_get_population
         (c_acting_mgr_pil_id    number,
          c_mgr_pil_id           number,
          c_grp_pl_id            number,
          c_grp_oipl_id          number,
          c_lvl_num              varchar2,
          c_crit_cd1             varchar2,
          c_crit_cd2             varchar2,
          c_name_type            varchar2) is
          Select  Temp.LerId        Emp_ler_id,
                  Temp.PlId         Pl_Id,
                  Temp.OiplId       Oipl_Id,
                  Temp.Ovn          Ovn,
                  Temp.Elig_Sal     Elig_Sal,
                  Temp.pl_xchg_rate Xchg_Rate,
                  Temp.nn_mntry     Nn_Mntry,
                  Temp.rndg_cd      rndg_cd,
                  Temp.assignment_id assignment_id,
                  decode(c_crit_cd1,  'JOB', JobTl.name,  'POS', PosTl.name,  'GRD', GrdTl.name,  'GQ', GrdQrtLkp.meaning,
                         'LOS',  trunc(People.years_employed/l_los_range)*l_los_range, 'ORG', OrgTl.name,
                         'COM', trunc(People.grd_comparatio/l_compratio_range)*l_compratio_range,  'CNTY', terr.territory_short_name,
                         'PFR',  OldPerfLkp.meaning, 'NPFR', NewPerfLkp.meaning, 'JF1', JobDef.segment1, 'JF2', JobDef.segment2,
                         'JF3',  JobDef.segment3,  'JF4', JobDef.segment4, 'JF5', JobDef.segment5, 'EOF1', People.cpi_attribute1,
                         'EOF2', People.cpi_attribute2,   'EOF3', People.cpi_attribute3,   'EOF4', People.cpi_attribute4,
                         'EOF5', People.cpi_attribute5,   'EOF6', People.cpi_attribute6,   'CS1',  People.custom_segment1,
                         'CS2',  People.custom_segment2,  'CS3',  People.custom_segment3,  'CS4',  People.custom_segment4,
                         'CS5',  People.custom_segment5,  'CS6',  People.custom_segment6,  'CS7',  People.custom_segment7,
                         'CS8',  People.custom_segment8,  'CS9',  People.custom_segment9,  'CS10', People.custom_segment10,
                         'CS11', People.custom_segment11, 'CS12', People.custom_segment12, 'CS13', People.custom_segment13,
                         'CS14', People.custom_segment14, 'CS15', People.custom_segment15,
                         'DIRREP', decode(c_name_type, 'FN', DirRep.full_name, 'CN', DirRep.custom_name, DirRep.brief_name),
                         'LOC',  nvl(Loc.description, Loc.location_code)) Crit_Val1,
                  decode(c_crit_cd2,  'JOB', JobTl.name,  'POS', PosTl.name,  'GRD', GrdTl.name,  'GQ', GrdQrtLkp.meaning,
                         'LOS',  trunc(People.years_employed/l_los_range)*l_los_range, 'ORG', OrgTl.name,
                         'COM', trunc(People.grd_comparatio/l_compratio_range)*l_compratio_range,  'CNTY', terr.territory_short_name,
                         'PFR',  OldPerfLkp.meaning, 'NPFR', NewPerfLkp.meaning, 'JF1', JobDef.segment1, 'JF2', JobDef.segment2,
                         'JF3',  JobDef.segment3,  'JF4', JobDef.segment4, 'JF5', JobDef.segment5, 'EOF1', People.cpi_attribute1,
                         'EOF2', People.cpi_attribute2,   'EOF3', People.cpi_attribute3,   'EOF4', People.cpi_attribute4,
                         'EOF5', People.cpi_attribute5,   'EOF6', People.cpi_attribute6,   'CS1',  People.custom_segment1,
                         'CS2',  People.custom_segment2,  'CS3',  People.custom_segment3,  'CS4',  People.custom_segment4,
                         'CS5',  People.custom_segment5,  'CS6',  People.custom_segment6,  'CS7',  People.custom_segment7,
                         'CS8',  People.custom_segment8,  'CS9',  People.custom_segment9,  'CS10', People.custom_segment10,
                         'CS11', People.custom_segment11, 'CS12', People.custom_segment12, 'CS13', People.custom_segment13,
                         'CS14', People.custom_segment14, 'CS15', People.custom_segment15,
                         'DIRREP', decode(c_name_type, 'FN', DirRep.full_name, 'CN', DirRep.custom_name, DirRep.brief_name),
                         'LOC',  nvl(Loc.description, Loc.location_code)) Crit_Val2
            From  ben_cwb_person_info     People
                 ,ben_cwb_person_info     DirRep
                 ,ben_transaction         Txn
                 ,per_jobs                Job
                 ,per_jobs_tl             JobTl
                 ,per_job_definitions     JobDef
                 ,per_grades_tl           GrdTl
                 ,hr_all_positions_f_tl   PosTl
                 ,hr_all_organization_units_tl OrgTl
                 ,hr_locations_all_tl     Loc
                 ,hr_lookups              GrdQrtLkp
                 ,hr_lookups              OldPerfLkp
                 ,hr_lookups              NewPerfLkp
                 ,fnd_territories_tl      terr
                 ,(Select  max(Hrchy.mgr_per_in_ler_id)         MgrLerId
                          ,Rates.group_per_in_ler_id            LerId
                          ,max(Rates.object_version_number)     Ovn
                          ,max(Rates.pl_id)                     PlId
                          ,max(Rates.oipl_id)                   OiplId
                          ,max(Rates.elig_sal_val)              Elig_Sal
                          ,max(GrpPl.perf_revw_strt_dt)         perf_date
                          ,max(GrpPl.emp_interview_typ_cd)      perf_type
                          ,max(xchg.xchg_rate)                  pl_xchg_rate
                          ,max(Pl.rec_nnmntry_uom)              nn_mntry
                          ,max(Pl.rec_rndg_cd)                  rndg_cd
                          ,max(Rates.assignment_id)             assignment_id
                     from  ben_cwb_person_rates   Rates
                          ,ben_cwb_pl_dsgn        Pl
                          ,ben_cwb_pl_dsgn        GrpPl
                          ,ben_cwb_xchg           Xchg
                          ,ben_cwb_group_hrchy    Hrchy
                    where  Hrchy.mgr_per_in_ler_id = c_mgr_pil_id
                      and  ((Hrchy.lvl_num between 1 and c_lvl_num and Hrchy.mgr_per_in_ler_id <> c_acting_mgr_pil_id)
                       or  (Hrchy.lvl_num = 1 and Hrchy.mgr_per_in_ler_id = c_acting_mgr_pil_id))
                      and  Rates.group_per_in_ler_id = Hrchy.emp_per_in_ler_id
                      and  Rates.group_pl_id = c_grp_pl_id
                      and  Rates.group_oipl_id = c_grp_oipl_id
                      and  Rates.elig_flag = 'Y'
                      and  Pl.pl_id = Rates.pl_id
                      and  Pl.oipl_id = Rates.oipl_id
                      and  Pl.lf_evt_ocrd_dt = Rates.lf_evt_ocrd_dt
                      and  Rates.group_pl_id = xchg.group_pl_id
                      and  Rates.lf_evt_ocrd_dt = xchg.lf_evt_ocrd_dt
                      and  Rates.currency = xchg.currency
                      and  Pl.group_pl_id = GrpPl.pl_id
                      and  Pl.lf_evt_ocrd_dt = GrpPl.lf_evt_ocrd_dt
                      and  GrpPl.oipl_id = -1
                   group by Rates.group_per_in_ler_id) Temp
           Where  People.group_per_in_ler_id = Temp.LerId
             and  DirRep.group_per_in_ler_id(+) = Temp.MgrLerId
             and  Job.job_id (+) = People.job_id
             and  JobTl.job_id (+) = People.job_id
             and  JobTl.language (+) = userenv('LANG')
             and  JobDef.job_definition_id (+) = Job.job_definition_id
             and  PosTl.position_id (+) = People.position_id
             and  PosTl.language (+) = userenv('LANG')
             and  GrdTl.grade_id (+) = People.grade_id
             and  GrdTl.language (+) = userenv('LANG')
             and  OrgTl.organization_id (+) = People.organization_id
             and  OrgTl.language (+) = userenv('LANG')
             and  GrdQrtLkp.lookup_code (+) = People.grd_quartile
             and  GrdQrtLkp.lookup_type (+) = 'BEN_CWB_QUAR_IN_GRD'
             and  Loc.location_id (+) = People.location_id
             and  Loc.language (+) = userenv('LANG')
             and  OldPerfLkp.lookup_code (+) = People.performance_rating
             and  OldPerfLkp.lookup_type (+) = 'PERFORMANCE_RATING'
             and  Txn.transaction_id (+) = Temp.assignment_id
             and  Txn.transaction_type (+) = 'CWBPERF' || to_char(Temp.perf_date,'yyyy/mm/dd') || Temp.perf_type
             and  NewPerfLkp.lookup_code (+) = Txn.attribute3
             and  NewPerfLkp.lookup_type (+) = 'PERFORMANCE_RATING'
             and  people.legislation_code = terr.territory_code (+)
             and  terr.language (+) = userenv('LANG');
  --
  l_proc       varchar2(72) := g_package||'pop_trg_amts';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if p_crit_cd1 = 'LOS' or p_crit_cd2 = 'LOS' then
    l_los_range := get_profile_value('BEN_CWB_WIZ_YRS_WKD_RANGE'
                                    ,l_los_range);
  end if;
  if p_crit_cd1 = 'COM' or p_crit_cd2 = 'COM' then
    l_compratio_range := get_profile_value('BEN_CWB_WIZ_COMPRATIO_RANGE'
                                          ,l_compratio_range);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint pop_trg_amts;
  --
  --
  for l_mgr_pil_id in p_mgr_pil_ids.first .. p_mgr_pil_ids.last
  loop
    --
    for pop in csr_get_population(p_acting_mgr_pil_id,
                                  p_mgr_pil_ids(l_mgr_pil_id),
                                  p_grp_pl_id,
                                  p_grp_oipl_id,
                                  p_lvl_num,
                                  p_crit_cd1,
                                  p_crit_cd2,
                                  p_name_type)
    loop
      --
      for l_num in 1 .. p_crit_vals1.count
      loop
        --
        if (p_crit_cd2 is not null) then
          --
          if (nvl(pop.Crit_Val1, 'NV') = p_crit_vals1(l_num) and
              nvl(pop.Crit_Val2, 'NV') = p_crit_vals2(l_num)) then
            --
            update_rates(pop.Emp_ler_id
                        ,pop.Pl_Id
                        ,pop.Oipl_Id
                        ,pop.Ovn
                        ,pop.Elig_Sal
                        ,pop.Xchg_Rate
                        ,pop.Nn_Mntry
                        ,pop.rndg_cd
                        ,pop.assignment_id
                        ,p_alct_by
                        ,p_trg_val(l_num));
            --
          end if;
          --
        else
          --
          if (nvl(pop.Crit_Val1, 'NV') = p_crit_vals1(l_num)) then
            --
            update_rates(pop.Emp_ler_id
                        ,pop.Pl_Id
                        ,pop.Oipl_Id
                        ,pop.Ovn
                        ,pop.Elig_Sal
                        ,pop.Xchg_Rate
                        ,pop.Nn_Mntry
                        ,pop.rndg_cd
                        ,pop.assignment_id
                        ,p_alct_by
                        ,p_trg_val(l_num));
            --
          end if;
          --
        end if;
        -- End of If statement
      end loop;
      -- End of For Loop (First Criterion)
    end loop;
    -- End of For Loop (Cursor)
  end loop;
  -- End of For Loop (Array)
  --
  -- Update the Summary Table
  ben_cwb_summary_pkg.save_pl_sql_tab;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to pop_trg_amts;
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 30);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to pop_trg_amts;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
    raise;
    --
end pop_trg_amts;
-- End of Procedure
--
end ben_cwb_mtrx_utils;
-- End of Package

/
