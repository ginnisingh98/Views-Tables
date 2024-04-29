--------------------------------------------------------
--  DDL for Package Body BEN_COMP_OBJECT_LIST1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COMP_OBJECT_LIST1" as
/* $Header: bebmbcl1.pkb 120.2 2006/09/14 11:29:24 bmanyam noship $ */
--
g_package varchar2(50) := 'ben_comp_object_list1.';
--
FUNCTION object_selection_rule(
  p_oipl_id                IN NUMBER
 ,p_pl_id                  IN NUMBER
 ,p_pgm_id                 IN NUMBER
 ,p_pl_typ_id              IN NUMBER
 ,p_opt_id                 IN NUMBER
 ,p_business_group_id      IN NUMBER
 ,p_comp_selection_rule_id IN NUMBER
 ,p_effective_date         IN DATE)
  RETURN BOOLEAN IS
  --
  l_package VARCHAR2(80)      := g_package || '.object_selection_rule';
  l_outputs ff_exec.outputs_t;
  l_return  VARCHAR2(30);
--
BEGIN
  --
  hr_utility.set_location('Entering ' || l_package, 10);
  --
  IF p_comp_selection_rule_id IS NOT NULL THEN
    --
    -- Call formula initialise routine
    --
    hr_utility.set_location('call formula ' || l_package, 20);
    l_outputs  :=
      benutils.formula(p_formula_id=> p_comp_selection_rule_id
       ,p_effective_date    => p_effective_date
       ,p_business_group_id => p_business_group_id
       ,p_assignment_id     => NULL
       ,p_organization_id   => NULL
       ,p_pl_id             => p_pl_id
       ,p_pl_typ_id         => p_pl_typ_id
       ,p_pgm_id            => p_pgm_id
       ,p_opt_id            => p_opt_id
       ,p_jurisdiction_code => NULL);
    --
    -- Formula will return Y or N
    --
    l_return   := l_outputs(l_outputs.FIRST).VALUE;
    --
    IF l_return = 'N' THEN
      --
      hr_utility.set_location('Ret N ' || l_package, 10);
      RETURN FALSE;
    --
    ELSIF l_return = 'Y' THEN
      --
      hr_utility.set_location('Ret Y ' || l_package, 10);
      RETURN TRUE;
    --
    ELSIF l_return <> 'Y' THEN
      --
      -- Defensive coding for Non Y return
      --
      fnd_message.set_name('BEN', 'BEN_91329_FORMULA_RETURN');
      fnd_message.set_token('RL', 'comp_selection_rule_id');
      fnd_message.set_token('PROC', l_package);
      fnd_message.raise_error;
    --
    END IF;
  --
  ELSE
    --
    hr_utility.set_location('Leaving TRUE ' || l_package, 10);
    RETURN TRUE;
  --
  END IF;
  --
END object_selection_rule;
--
PROCEDURE populate_comp_object_list
  (p_comp_obj_cache_id      in     number
  ,p_business_group_id      in     number
  ,p_comp_selection_rule_id in     number
  ,p_effective_date         in     date
  )
IS
  --
  l_pl_id_va               benutils.g_number_table   := benutils.g_number_table();
  l_pgm_id_va              benutils.g_number_table   := benutils.g_number_table();
  l_oipl_id_va             benutils.g_number_table   := benutils.g_number_table();
  l_plip_id_va             benutils.g_number_table   := benutils.g_number_table();
  l_ptip_id_va             benutils.g_number_table   := benutils.g_number_table();
  l_oiplip_id_va           benutils.g_number_table   := benutils.g_number_table();
  l_pl_nip_va              benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_trk_inelig_per_flag_va benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_par_pgm_id_va          benutils.g_number_table   := benutils.g_number_table();
  l_par_ptip_id_va         benutils.g_number_table   := benutils.g_number_table();
  l_par_plip_id_va         benutils.g_number_table   := benutils.g_number_table();
  l_par_pl_id_va           benutils.g_number_table   := benutils.g_number_table();
  l_par_opt_id_va          benutils.g_number_table   := benutils.g_number_table();
  l_flag_bit_val_va        benutils.g_number_table   := benutils.g_number_table();
  l_oiplip_flag_bit_val_va benutils.g_number_table   := benutils.g_number_table();
  --
  l_ele_num        pls_integer;
  --
  CURSOR c_multisesscacherows
    (c_comp_obj_cache_id IN NUMBER
    )
  IS
    SELECT /*+ bebmbcl1.populate_comp_object_list */
      bcocr.pl_id,
      bcocr.pgm_id,
      bcocr.oipl_id,
      bcocr.plip_id,
      bcocr.ptip_id,
      bcocr.oiplip_id,
      bcocr.pl_nip,
      bcocr.trk_inelig_per_flag,
      bcocr.par_pgm_id,
      bcocr.par_ptip_id,
      bcocr.par_plip_id,
      bcocr.par_pl_id,
      bcocr.par_opt_id,
      bcocr.flag_bit_val,
      bcocr.oiplip_flag_bit_val
    FROM     ben_comp_obj_cache_row bcocr
    WHERE    bcocr.comp_obj_cache_id = c_comp_obj_cache_id
    ORDER BY bcocr.comp_obj_cache_row_id;
  --
  l_prev_pgm_id    NUMBER;
  l_pgmrule_pass   BOOLEAN;
  --
BEGIN
  --
  -- Populate the comp object list from the database version
  --
  l_ele_num       := 1;
  l_prev_pgm_id   := hr_api.g_number;
  l_pgmrule_pass  := TRUE;
  --
  open c_multisesscacherows
    (c_comp_obj_cache_id => p_comp_obj_cache_id
    );
  fetch c_multisesscacherows bulk collect into l_pl_id_va,
                                          l_pgm_id_va,
                                          l_oipl_id_va,
                                          l_plip_id_va,
                                          l_ptip_id_va,
                                          l_oiplip_id_va,
                                          l_pl_nip_va,
                                          l_trk_inelig_per_flag_va,
                                          l_par_pgm_id_va,
                                          l_par_ptip_id_va,
                                          l_par_plip_id_va,
                                          l_par_pl_id_va,
                                          l_par_opt_id_va,
                                          l_flag_bit_val_va,
                                          l_oiplip_flag_bit_val_va;
  close c_multisesscacherows;
  --
  if l_pl_id_va.count > 0 then
    --
    for elenum in l_pl_id_va.first..l_pl_id_va.last
    loop
      --
      -- Check if the program rule needs to be fired. Only fire when the
      -- parent pgm id changes
      --
      IF NVL(l_prev_pgm_id, hr_api.g_number) <> NVL(l_par_pgm_id_va(elenum), hr_api.g_number)
      THEN
        --
        l_pgmrule_pass  := object_selection_rule
           (p_pgm_id                 => l_par_pgm_id_va(elenum)
           ,p_pl_typ_id              => NULL
           ,p_pl_id                  => NULL
           ,p_oipl_id                => NULL
           ,p_opt_id                 => NULL
           ,p_business_group_id      => p_business_group_id
           ,p_comp_selection_rule_id => p_comp_selection_rule_id
           ,p_effective_date         => p_effective_date
           );
        --
      END IF;
      --
      IF l_pgmrule_pass THEN
        --
        ben_manage_life_events.g_cache_proc_object(l_ele_num).pl_id                :=
                                                                  l_pl_id_va(elenum);
        ben_manage_life_events.g_cache_proc_object(l_ele_num).pgm_id               :=
                                                                 l_pgm_id_va(elenum);
        ben_manage_life_events.g_cache_proc_object(l_ele_num).oipl_id              :=
                                                                l_oipl_id_va(elenum);
        ben_manage_life_events.g_cache_proc_object(l_ele_num).plip_id              :=
                                                                l_plip_id_va(elenum);
        ben_manage_life_events.g_cache_proc_object(l_ele_num).ptip_id              :=
                                                                l_ptip_id_va(elenum);
        ben_manage_life_events.g_cache_proc_object(l_ele_num).oiplip_id            :=
                                                              l_oiplip_id_va(elenum);
        ben_manage_life_events.g_cache_proc_object(l_ele_num).pl_nip               :=
                                                                 l_pl_nip_va(elenum);
        ben_manage_life_events.g_cache_proc_object(l_ele_num).trk_inelig_per_flag  :=
                                                    l_trk_inelig_per_flag_va(elenum);
        ben_manage_life_events.g_cache_proc_object(l_ele_num).par_pgm_id           :=
                                                             l_par_pgm_id_va(elenum);
        ben_manage_life_events.g_cache_proc_object(l_ele_num).par_ptip_id          :=
                                                            l_par_ptip_id_va(elenum);
        ben_manage_life_events.g_cache_proc_object(l_ele_num).par_plip_id          :=
                                                            l_par_plip_id_va(elenum);
        ben_manage_life_events.g_cache_proc_object(l_ele_num).par_pl_id            :=
                                                              l_par_pl_id_va(elenum);
        ben_manage_life_events.g_cache_proc_object(l_ele_num).par_opt_id           :=
                                                             l_par_opt_id_va(elenum);
        ben_manage_life_events.g_cache_proc_object(l_ele_num).flag_bit_val         :=
                                                           l_flag_bit_val_va(elenum);
        ben_manage_life_events.g_cache_proc_object(l_ele_num).oiplip_flag_bit_val  :=
                                                    l_oiplip_flag_bit_val_va(elenum);
        --
        l_ele_num := l_ele_num + 1;
        --
        -- 5515506: If derived factors exists and the g_derivable_factors is 'NONE',
        -- reset the derivable_factors parameter to 'ASC'
        --
        if (  (l_flag_bit_val_va(elenum) <> 0 OR  l_oiplip_flag_bit_val_va(elenum) <> 0)
            AND (ben_manage_life_events.g_derivable_factors = 'NONE') ) then
            --
            hr_utility.set_location('SET ben_manage_life_events.g_derivable_factors from NONE to ASC', 10);

            ben_manage_life_events.g_derivable_factors := 'ASC';
            fnd_message.set_name('BEN','BEN_93605_RESET_DRVD_FCTR_PARM');
            benutils.write(p_text => fnd_message.get);
            --
        end if;
        --
      END IF;
      --
      l_prev_pgm_id  := l_par_pgm_id_va(elenum);
      --
    end loop;
    --
  end if;
  --
END populate_comp_object_list;
--
PROCEDURE refresh_eff_date_caches
IS
  --

  --
BEGIN
  --
  ben_cobj_cache.clear_down_cache;
  ben_comp_object.clear_down_cache;
  ben_elig_object.clear_down_cache;
  ben_seeddata_object.clear_down_cache;
  ben_manage_life_events.g_cache_person_prtn.delete;
  ben_derive_part_and_rate_cache.clear_down_cache;
  ben_derive_part_and_rate_facts.clear_down_cache;
  ben_derive_part_and_rate_cvg.clear_down_cache;
  ben_derive_part_and_rate_prem.clear_down_cache;
  ben_cel_cache.clear_down_cache;
  ben_org_object.clear_down_cache;
  --
  ben_elp_cache.clear_down_cache;
  ben_cep_cache.clear_down_cache;
  --
  ben_letrg_cache.clear_down_cache;
  --
  ben_rtp_cache.clear_down_cache;
  ben_rt_prfl_cache.clear_down_cache;
  --
END refresh_eff_date_caches;
--
end ben_comp_object_list1;

/
