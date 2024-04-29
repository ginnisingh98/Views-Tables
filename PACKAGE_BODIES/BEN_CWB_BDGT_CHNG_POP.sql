--------------------------------------------------------
--  DDL for Package Body BEN_CWB_BDGT_CHNG_POP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_BDGT_CHNG_POP" as
/* $Header: bencwbchngpop.pkb 120.0 2005/05/28 13:34 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'ben_cwb_bdgt_chng_pop.';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< CLEAR_BDGT_VALS >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure clear_bdgt_vals
  (p_validate                      in     boolean  default false
  ,p_grp_per_in_ler_id             in     number
  ,p_grp_pl_id                     in     number
  ,p_current_bdgt_pop              in     varchar2
  ,p_lf_evt_ocrd_dt                in     date
  ,p_effective_date                in     date	   default sysdate
  ,p_logon_person_id               in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor for getting Population under a Manager depending upon the Pop code
  --
  cursor csr_get_population
         (c_group_per_in_ler_id  number,
          c_group_pl_id          number,
          c_lf_evt_ocrd_dt       date) is
          Select  max(Hrchy.emp_per_in_ler_id)                      GrpLerId,
                  max(Grp.group_pl_id)                              GrpPlId,
                  max(Grp.group_oipl_id)                            GrpOiplId,
                  max(Grp.object_version_number)                    Ovn
            From  ben_cwb_group_hrchy    Hrchy,
                  ben_cwb_person_groups  Grp,
                  ben_cwb_summary        Summ
           Where  Hrchy.mgr_per_in_ler_id = c_group_per_in_ler_id
             and  Hrchy.lvl_num > 0
             and  Grp.group_per_in_ler_id = Hrchy.emp_per_in_ler_id
             and  Grp.group_pl_id = c_group_pl_id
             and  Grp.lf_evt_ocrd_dt = c_lf_evt_ocrd_dt
             and  Summ.group_per_in_ler_id = Grp.group_per_in_ler_id
             and  Summ.group_pl_id = Grp.group_pl_id
             and  Summ.group_oipl_id = Grp.group_oipl_id
             and  Summ.lf_evt_ocrd_dt = Grp.lf_evt_ocrd_dt
           Group by Summ.group_per_in_ler_id,
                    Summ.group_pl_id,
                    Summ.group_oipl_id
           having sum(Summ.elig_count_all) > 0
           and    (max(dist_bdgt_val) is not null     or max(ws_bdgt_val) is not null or
                   max(dist_bdgt_iss_val) is not null or max(ws_bdgt_iss_val) is not null)
           Order by GrpLerId;
  --
  l_lf_evt_ocrd_date  date;
  l_effective_date    date;
  l_current_bdgt_pop  varchar2(30);
  l_proc              varchar2(72) := g_package||'clear_bdgt_vals';
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint clear_bdgt_vals;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_lf_evt_ocrd_date :=  trunc(p_lf_evt_ocrd_dt);
  l_effective_date   :=  trunc(p_effective_date);
  --
  -- Loop the Cursor and clear the bdgt values for the Population
  --
  for Pop in csr_get_population(p_grp_per_in_ler_id,
                                p_grp_pl_id,
                                p_lf_evt_ocrd_dt) loop
    --
    ben_cwb_person_groups_api.update_group_budget
        (p_group_per_in_ler_id        =>  Pop.GrpLerId
        ,p_group_pl_id                =>  Pop.GrpPlId
        ,p_group_oipl_id              =>  Pop.GrpOiplId
        ,p_lf_evt_ocrd_dt             =>  l_lf_evt_ocrd_date
        ,p_dist_bdgt_val              =>  null
        ,p_ws_bdgt_val                =>  null
        ,p_dist_bdgt_iss_val          =>  null
        ,p_ws_bdgt_iss_val            =>  null
        ,p_ws_bdgt_iss_date           =>  null
        ,p_dist_bdgt_iss_date         =>  null
        ,p_bdgt_pop_cd                =>  null
        ,p_ws_bdgt_val_last_upd_date  =>  l_effective_date
        ,p_ws_bdgt_val_last_upd_by    =>  p_logon_person_id
        ,p_dist_bdgt_val_last_upd_date=>  l_effective_date
        ,p_dist_bdgt_val_last_upd_by  =>  p_logon_person_id
        ,p_object_version_number      =>  Pop.Ovn
        );
  end loop;
  -- End of For Loop (Cursor)
  --
  -- Update the Summary Table (Fixed bug# 3544468)
  ben_cwb_summary_pkg.save_pl_sql_tab;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to clear_bdgt_vals;
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to clear_bdgt_vals;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 90);
    raise;
end clear_bdgt_vals;
-- End of Procedure
--
end ben_cwb_bdgt_chng_pop;
-- End of Package

/
