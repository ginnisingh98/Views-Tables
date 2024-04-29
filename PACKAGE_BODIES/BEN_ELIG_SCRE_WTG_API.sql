--------------------------------------------------------
--  DDL for Package Body BEN_ELIG_SCRE_WTG_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIG_SCRE_WTG_API" as
/* $Header: beeswapi.pkb 120.2 2005/06/23 00:16:44 abparekh noship $ */
--
-- Package Variables
--
g_package varchar2(50):= 'BEN_ELIG_SCRE_WTG_API';

procedure create_perf_score_weight
(  p_validate                       in boolean    default false
  ,p_elig_scre_wtg_id               out nocopy number
  ,p_effective_date                 in date
  ,p_elig_per_id                    in number   default null
  ,p_elig_per_opt_id                in number   default null
  ,p_elig_rslt_id                   in number   default null
  ,p_per_in_ler_id                  in number   default null
  ,p_eligy_prfl_id                  in number
  ,p_crit_tab_short_name            in varchar2
  ,p_crit_tab_pk_id                 in number
  ,p_computed_score                 in number   default null
  ,p_benefit_action_id              in number   default null
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          out nocopy number
) is

  l_proc varchar2(72) := g_package||'create_perf_score_weight';
  --
  -- Declare cursors and local variables
  --
  l_object_version_number ben_elig_scre_wtg_f.object_version_number%TYPE;
  l_elig_scre_wtg_id      ben_elig_scre_wtg_f.elig_per_opt_id%TYPE;
  l_effective_start_date  ben_elig_scre_wtg_f.effective_start_date%TYPE;
  l_effective_end_date    ben_elig_scre_wtg_f.effective_end_date%TYPE;
  --
  l_created_by            ben_elig_scre_wtg_f.created_by%TYPE;
  l_creation_date         ben_elig_scre_wtg_f.creation_date%TYPE;
  l_last_update_date      ben_elig_scre_wtg_f.last_update_date%TYPE;
  l_last_updated_by       ben_elig_scre_wtg_f.last_updated_by%TYPE;
  --
  Cursor C_Sel1 is select ben_elig_per_opt_f_s.nextval from sys.dual;

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_perf_score_weight;
  --
  -- Derive maximum start and end dates
  --
  l_effective_start_date := p_effective_date;
  l_effective_end_date   := hr_api.g_eot;
  --
  -- Insert the row
  --
  --   Set the object version number for the insert
  --
  l_object_version_number := 1;
  --
  ben_esw_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into l_elig_scre_wtg_id;
  Close C_Sel1;
  --
  -- Insert the row into: ben_elig_per_f
  --
  hr_utility.set_location('Insert: '||l_proc, 5);
  insert into ben_elig_scre_wtg_f
      (elig_scre_wtg_id
      ,elig_per_id
      ,elig_per_opt_id
      ,elig_rslt_id
      ,per_in_ler_id
      ,effective_start_date
      ,effective_end_date
      ,object_version_number
      ,eligy_prfl_id
      ,crit_tab_short_name
      ,crit_tab_pk_id
      ,computed_score
      ,benefit_action_id
      ,created_by
      ,creation_date
      ,last_update_date
      ,last_updated_by
      )
  Values
    (l_elig_scre_wtg_id
    ,p_elig_per_id
    ,p_elig_per_opt_id
    ,p_elig_rslt_id
    ,p_per_in_ler_id
    ,l_effective_start_date
    ,l_effective_end_date
    ,l_object_version_number
    ,p_eligy_prfl_id
    ,p_crit_tab_short_name
    ,p_crit_tab_pk_id
    ,p_computed_score
    ,p_benefit_action_id
    ,l_created_by
    ,l_creation_date
    ,l_last_update_date
    ,l_last_updated_by
    );
  hr_utility.set_location('Dn Insert: '||l_proc, 5);
  --
  ben_esw_shd.g_api_dml := false;   -- Unset the api dml status
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_elig_scre_wtg_id      := l_elig_scre_wtg_id;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_perf_score_weight;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_elig_scre_wtg_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_perf_score_weight;
    --
    p_elig_scre_wtg_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    raise;
    --
end create_perf_score_weight;

procedure update_perf_score_weight
(  p_validate                       in boolean    default false
  ,p_elig_scre_wtg_id               in number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_benefit_action_id              in number   default hr_api.g_number
  ,p_computed_score                 in number   default hr_api.g_number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_score_weight';
  l_object_version_number ben_elig_scre_wtg_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_scre_wtg_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_scre_wtg_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_score_weight;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  ben_esw_upd.upd
    (
     p_elig_scre_wtg_id              => p_elig_scre_wtg_id
    ,p_computed_score                => p_computed_score
    ,p_benefit_action_id             => p_benefit_action_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_score_weight;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;

    ROLLBACK TO update_score_weight;
    raise;
    --
end update_perf_score_weight;

procedure delete_perf_score_weight
(  p_validate                       in boolean    default false
  ,p_elig_scre_wtg_id               in number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_object_version_number          in out nocopy number
) is

  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_score_weight';
  l_object_version_number ben_elig_scre_wtg_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_scre_wtg_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_scre_wtg_f.effective_end_date%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_score_weight;
  --
  l_object_version_number := p_object_version_number;
  --
  ben_esw_del.del
    (
     p_elig_scre_wtg_id              => p_elig_scre_wtg_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number  := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_score_weight;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    -- uncommented for the nocopy
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number  := l_object_version_number;
    --
    ROLLBACK TO delete_score_weight;
    raise;
    --
end delete_perf_score_weight;

procedure load_score_weight
(  p_validate                       in boolean  default false
  ,p_score_tab                      in ben_evaluate_elig_profiles.scoreTab
  ,p_elig_per_id                    in number   default null
  ,p_elig_per_opt_id                in number   default null
  ,p_elig_rslt_id                   in number   default null
  ,p_per_in_ler_id                  in number   default null
  ,p_effective_date                 in date
) is

  cursor c_sc_wg(p_eligy_prfl_id         number,
                 p_elig_per_id           number,
                 p_elig_per_opt_id       number,
                 p_crit_tab_short_name   varchar2,
                 p_crit_tab_pk_id        number,
                 p_effective_date        date) is
  select *
    from ben_elig_scre_wtg_f
   where eligy_prfl_id = p_eligy_prfl_id
     and crit_tab_short_name = p_crit_tab_short_name
     and crit_tab_pk_id = p_crit_tab_pk_id
     and nvl(elig_per_id,-1) = nvl(p_elig_per_id,-1)
     and nvl(elig_per_opt_id,-1) = nvl(p_elig_per_opt_id,-1)
     and nvl(elig_rslt_id,-1) = nvl(p_elig_rslt_id,-1)
     and p_effective_date between effective_start_date
     and effective_end_date;
  --
  l_sc_wg c_sc_wg%rowtype;
  --
  l_object_version_number     number;
  l_effective_start_date      date;
  l_effective_end_date        date;
  l_datetrack_mode            varchar2(100);
  l_correction                boolean;
  l_update                    boolean;
  l_update_override           boolean;
  l_update_change_insert      boolean;
  l_elig_scre_wtg_id          number;
  i                           int;
  l_proc            varchar2(80) := g_package||'.load_score_weight';

begin

  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  -- Bug 4438430
  -- P_ELIG_PER_ID will be null for BEN_ELIG_PER_F records at PLIP level.
  -- In BEN_ELIGIBLE_PERSON_PERF_API we defer creation of BEN_ELIG_PER_F records
  -- at PLIP level until creation at PLN level. So for this case we will store
  -- P_SCORE_TAB into global table BEN_ELIGIBLE_PERSON_PERF_API.G_PEPINSPLIP
  -- In BEN_ELIGIBLE_PERSON_PERF_API.CREATE_PERF_ELIGIBLE_PERSON, we create
  -- BEN_ELIG_SCRE_WRTG_F record after creating corresponding BEN_ELIG_PER_F record
  --
  if p_elig_per_id is null
  then
    --
    BEN_ELIGIBLE_PERSON_PERF_API.g_pepinsplip_score_tab := p_score_tab; /* Bug 4449745 */
    hr_utility.set_location('Defer creation of ESW Record', 9898);
    return;
  end if;
  --
  if p_score_tab.count > 0 then
     hr_utility.set_location('wsr',11);
     for i in 1..p_score_tab.count
     loop
        l_sc_wg := null;
        open c_sc_wg(p_score_tab(i).eligy_prfl_id,
                     p_elig_per_id,
                     p_elig_per_opt_id,
                     p_score_tab(i).crit_tab_short_name,
                     p_score_tab(i).crit_tab_pk_id,
                     p_effective_date);
        fetch c_sc_wg into l_sc_wg;
        close c_sc_wg;
        l_elig_scre_wtg_id := l_sc_wg.elig_scre_wtg_id;
        hr_utility.set_location('elig_scre_wtg_id '||l_elig_scre_wtg_id,5.7);

        if l_elig_scre_wtg_id is null then
           ben_elig_scre_wtg_api.create_perf_score_weight
           (p_validate           => false
           ,p_elig_scre_wtg_id   => l_elig_scre_wtg_id
           ,p_effective_date     => p_effective_date
           ,p_elig_per_id        => p_elig_per_id
           ,p_elig_per_opt_id    => p_elig_per_opt_id
           ,p_per_in_ler_id      => p_per_in_ler_id
           ,p_eligy_prfl_id      => p_score_tab(i).eligy_prfl_id
           ,p_crit_tab_short_name=> p_score_tab(i).crit_tab_short_name
           ,p_crit_tab_pk_id     => p_score_tab(i).crit_tab_pk_id
           ,p_computed_score     => p_score_tab(i).computed_score
           ,p_benefit_action_id  => p_score_tab(i).benefit_action_id
           ,p_effective_start_date  => l_effective_start_date
           ,p_effective_end_date    => l_effective_end_date
           ,p_object_version_number => l_object_version_number);
        else
           dt_api.find_dt_upd_modes
           (p_effective_date       => p_effective_date,
            p_base_table_name      => 'BEN_ELIG_SCRE_WTG_F',
            p_base_key_column      => 'elig_scre_wtg_id',
            p_base_key_value       => l_elig_scre_wtg_id,
            p_correction           => l_correction,
            p_update               => l_update,
            p_update_override      => l_update_override,
            p_update_change_insert => l_update_change_insert);

           if l_update_override then
              l_datetrack_mode := hr_api.g_update_override;
           elsif l_update then
              l_datetrack_mode := hr_api.g_update;
           else
              l_datetrack_mode := hr_api.g_correction;
           end if;

           ben_elig_scre_wtg_api.update_perf_score_weight
           (p_validate           => false
           ,p_elig_scre_wtg_id   => l_elig_scre_wtg_id
           ,p_effective_date     => p_effective_date
           ,p_datetrack_mode     => l_datetrack_mode
           ,p_computed_score     => p_score_tab(i).computed_score
           ,p_benefit_action_id  => p_score_tab(i).benefit_action_id
           ,p_effective_start_date  => l_effective_start_date
           ,p_effective_end_date    => l_effective_end_date
           ,p_object_version_number => l_sc_wg.object_version_number);
        end if;
     end loop;
  end if;
  hr_utility.set_location('Leaving : ' || l_proc, 10);
end load_score_weight;

end BEN_ELIG_SCRE_WTG_API;

/
