--------------------------------------------------------
--  DDL for Package Body BEN_DETERMINE_COMMUNICATIONS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DETERMINE_COMMUNICATIONS1" as
/*$Header: bentmpc1.pkb 120.0 2007/11/23 13:03:24 sallumwa noship $*/
--
/*
History
  Version Date       Author     Comment
  -------+----------+----------+---------------------------------------------------
  115.0   19-Dec-06  mhoyes     Created. Bug5598664.
  115.2   22-Dec-06  mhoyes     Bug5598664 - Added in mod restriction on pep
                                restriction.
  115.3   27-Dec-06  mhoyes     Bug5598664 - Removed  mod restriction on pep.
  115.4   08-Mar-07  mhoyes     Bug5919794 - Removed person or condition.
  ---------------------------------------------------------------------------------
*/
--
g_package    varchar2(80) := 'ben_determine_communications1';
--
procedure get_mssmlg_perids
  (p_per_id           number
  ,p_effdt            date
  ,p_bgp_id           number
  ,p_pet_id           number
  ,p_elig_enrol_cd    varchar2
  ,p_pgm_id           number
  ,p_pl_nip_id        number
  ,p_plan_in_pgm_flag varchar2
  ,p_org_id           number
  ,p_loc_id           number
  --
  ,p_perid_va         out nocopy benutils.g_number_table
  )
is
  --
  l_perid_va    benutils.g_number_table := benutils.g_number_table();
  l_modperid_va benutils.g_number_table := benutils.g_number_table();
  --
  cursor c_per_mssmlgmodallper
    (c_effdt            date
    ,c_bgp_id           number
    ,c_pet_id           number
    ,c_elig_enrol_cd    varchar2
    ,c_pgm_id           number
    ,c_pl_nip_id        number
    ,c_plan_in_pgm_flag varchar2
    ,c_org_id           number
    ,c_loc_id           number
    ,c_work_id          number
    ,c_workers          number
    )
  is
    select /*+ bentmpc1.c_per_mssmlgmodallper 20 */
           person_id
    from per_all_people_f ppf
    where c_effdt between ppf.effective_start_date
                                   and ppf.effective_end_date
    and mod(ppf.person_id,c_workers) = c_work_id
    and ppf.business_group_id  = c_bgp_id
    and ppf.business_group_id = c_bgp_id
    and (c_pet_id is null
         or
           ppf.person_id in (select ppu.person_id
--         exists (select null
                 from   per_person_type_usages_f ppu
                 where
--                        ppf.person_id = ppu.person_id
--                 and
                        ppu.person_type_id = c_pet_id
                 and    c_effdt
                   between ppu.effective_start_date and ppu.effective_end_date
                )
        )
     --
     -- The elig_enrol_cd could be either NULL or ELIG or ENROL
     --
     and (
          (c_elig_enrol_cd = 'ELIG'
           and
           ppf.person_id in (select elig.person_id
--           exists (select 's'
                   from ben_elig_per_f elig,
                        ben_per_in_ler pil
--                   where elig.person_id = ppf.person_id
--                   and
                   where
                       (c_pgm_id is null or
                        elig.pgm_id = c_pgm_id
                       )
                   and ((c_pl_nip_id is null
                         and c_plan_in_pgm_flag = 'Y'
                         and elig.pgm_id is not null
                        )
                        or
                        (c_pl_nip_id is null
                         and c_plan_in_pgm_flag = 'N'
                         and elig.pgm_id is null
                        )
                        or
                        (c_pl_nip_id = elig.pl_id)
                       )
                   and elig.elig_flag = 'Y'
                   and c_effdt
                     between elig.effective_start_date and elig.effective_end_date
                   and pil.per_in_ler_id(+)=elig.per_in_ler_id
                   and pil.business_group_id(+)=elig.business_group_id
                   and (pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
                        or pil.per_in_ler_stat_cd is null
                       )
          )
         )
     or
       (c_elig_enrol_cd = 'ENROL'
        and
           ppf.person_id in (select pen.person_id
--            exists (select 's'
                   from ben_prtt_enrt_rslt_f pen
                   where
--                   pen.person_id = ppf.person_id
--                   and
                       (c_pgm_id is null or
                        pen.pgm_id = c_pgm_id
                       )
                   and ((c_pl_nip_id is null
                         and c_plan_in_pgm_flag = 'Y'
                         and pen.pgm_id is not null
                        )
                       or
                        (c_pl_nip_id is null
                         and c_plan_in_pgm_flag = 'N'
                         and pen.pgm_id is null
                        )
                       or
                        (c_pl_nip_id = pen.pl_id)
                       )
                   and pen.sspndd_flag = 'N'
                   and pen.prtt_enrt_rslt_stat_cd is null
                   and pen.business_group_id = c_bgp_id
                   and nvl(pen.enrt_cvg_thru_dt, hr_api.g_eot) = hr_api.g_eot
                   and c_effdt
                     between pen.effective_start_date and pen.effective_end_date
                   and pen.effective_end_date = hr_api.g_eot
                   )
       )
     or
       (c_elig_enrol_cd is null)
       )
     and ((c_org_id is null and
           c_loc_id is null
          )
         or
           ppf.person_id in (select asg.person_id
--           exists (select 's'
                   FROM per_all_assignments_f asg,
                        per_assignment_status_types ast
                   WHERE
--                       asg.person_id = ppf.person_id
--                   AND
                         asg.primary_flag = 'Y'
                   and (c_org_id is null
                       or asg.organization_id = c_org_id
                       )
                   and (c_loc_id is null
                       or asg.location_id = c_loc_id
                       )
                   AND c_effdt
                     BETWEEN asg.effective_start_date AND asg.effective_end_date
                   AND asg.assignment_status_type_id = ast.assignment_status_type_id
                   and asg.business_group_id = c_bgp_id
                      AND ((assignment_type = 'E'
                        AND (ast.per_system_status = 'ACTIVE_ASSIGN'
                            OR (ast.per_system_status = 'TERM_ASSIGN'
                               AND NOT EXISTS (SELECT assignment_id
                                               FROM per_all_assignments_f asg1,
                                                    per_assignment_status_types ast1
                                               WHERE asg1.assignment_type = 'B'
                                               AND asg1.primary_flag = 'Y'
                                               AND asg1.person_id = ppf.person_id
                                               AND asg1.assignment_status_type_id = ast1.assignment_status_type_id
                                               AND ast1.per_system_status = 'ACTIVE_ASSIGN'
                                               AND c_effdt
                                                 BETWEEN asg1.effective_start_date AND asg1.effective_end_date
                                              )
                               )
                            )
                           )
                         OR
                           (assignment_type = 'B'
                              AND NOT EXISTS (SELECT assignment_id
                                              FROM per_all_assignments_f asg2,
                                                   per_assignment_status_types ast2
                                              WHERE asg2.assignment_type = 'E'
                                              AND asg2.primary_flag = 'Y'
                                              AND asg2.person_id = ppf.person_id
                                              AND asg2.assignment_status_type_id = ast2.assignment_status_type_id
                                              AND ast2.per_system_status = 'ACTIVE_ASSIGN'
                                              AND c_effdt
                                                BETWEEN asg2.effective_start_date AND asg2.effective_end_date
                                             )
                           )
                          )
		  )
	);
  --
  cursor c_per_mssmlgmodoneper
    (c_per_id           number
    ,c_effdt            date
    ,c_bgp_id           number
    ,c_pet_id           number
    ,c_elig_enrol_cd    varchar2
    ,c_pgm_id           number
    ,c_pl_nip_id        number
    ,c_plan_in_pgm_flag varchar2
    ,c_org_id           number
    ,c_loc_id           number
    ,c_work_id          number
    ,c_workers          number
    )
  is
    select /*+ bentmpc1.c_per_mssmlgmodoneper 20 */
           person_id
    from per_all_people_f ppf
    where ppf.person_id = c_per_id
    and c_effdt between ppf.effective_start_date
                                   and ppf.effective_end_date
    and mod(ppf.person_id,c_workers) = c_work_id
    and ppf.business_group_id  = c_bgp_id
    and ppf.business_group_id = c_bgp_id
    and (c_pet_id is null
         or
           ppf.person_id in (select ppu.person_id
--         exists (select null
                 from   per_person_type_usages_f ppu
                 where
--                        ppf.person_id = ppu.person_id
--                 and
                        ppu.person_type_id = c_pet_id
                 and    c_effdt
                   between ppu.effective_start_date and ppu.effective_end_date
                )
        )
     --
     -- The elig_enrol_cd could be either NULL or ELIG or ENROL
     --
     and (
          (c_elig_enrol_cd = 'ELIG'
           and
           ppf.person_id in (select elig.person_id
--           exists (select 's'
                   from ben_elig_per_f elig,
                        ben_per_in_ler pil
--                   where elig.person_id = ppf.person_id
--                   and
                   where
                       (c_pgm_id is null or
                        elig.pgm_id = c_pgm_id
                       )
                   and ((c_pl_nip_id is null
                         and c_plan_in_pgm_flag = 'Y'
                         and elig.pgm_id is not null
                        )
                        or
                        (c_pl_nip_id is null
                         and c_plan_in_pgm_flag = 'N'
                         and elig.pgm_id is null
                        )
                        or
                        (c_pl_nip_id = elig.pl_id)
                       )
                   and elig.elig_flag = 'Y'
                   and c_effdt
                     between elig.effective_start_date and elig.effective_end_date
                   and pil.per_in_ler_id(+)=elig.per_in_ler_id
                   and pil.business_group_id(+)=elig.business_group_id
                   and (pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
                        or pil.per_in_ler_stat_cd is null
                       )
          )
         )
     or
       (c_elig_enrol_cd = 'ENROL'
        and
           ppf.person_id in (select pen.person_id
--            exists (select 's'
                   from ben_prtt_enrt_rslt_f pen
                   where
--                   pen.person_id = ppf.person_id
--                   and
                       (c_pgm_id is null or
                        pen.pgm_id = c_pgm_id
                       )
                   and ((c_pl_nip_id is null
                         and c_plan_in_pgm_flag = 'Y'
                         and pen.pgm_id is not null
                        )
                       or
                        (c_pl_nip_id is null
                         and c_plan_in_pgm_flag = 'N'
                         and pen.pgm_id is null
                        )
                       or
                        (c_pl_nip_id = pen.pl_id)
                       )
                   and pen.sspndd_flag = 'N'
                   and pen.prtt_enrt_rslt_stat_cd is null
                   and pen.business_group_id = c_bgp_id
                   and nvl(pen.enrt_cvg_thru_dt, hr_api.g_eot) = hr_api.g_eot
                   and c_effdt
                     between pen.effective_start_date and pen.effective_end_date
                   and pen.effective_end_date = hr_api.g_eot
                   )
       )
     or
       (c_elig_enrol_cd is null)
       )
     and ((c_org_id is null and
           c_loc_id is null
          )
         or
           ppf.person_id in (select asg.person_id
--           exists (select 's'
                   FROM per_all_assignments_f asg,
                        per_assignment_status_types ast
                   WHERE
--                       asg.person_id = ppf.person_id
--                   AND
                         asg.primary_flag = 'Y'
                   and (c_org_id is null
                       or asg.organization_id = c_org_id
                       )
                   and (c_loc_id is null
                       or asg.location_id = c_loc_id
                       )
                   AND c_effdt
                     BETWEEN asg.effective_start_date AND asg.effective_end_date
                   AND asg.assignment_status_type_id = ast.assignment_status_type_id
                   and asg.business_group_id = c_bgp_id
                      AND ((assignment_type = 'E'
                        AND (ast.per_system_status = 'ACTIVE_ASSIGN'
                            OR (ast.per_system_status = 'TERM_ASSIGN'
                               AND NOT EXISTS (SELECT assignment_id
                                               FROM per_all_assignments_f asg1,
                                                    per_assignment_status_types ast1
                                               WHERE asg1.assignment_type = 'B'
                                               AND asg1.primary_flag = 'Y'
                                               AND asg1.person_id = ppf.person_id
                                               AND asg1.assignment_status_type_id = ast1.assignment_status_type_id
                                               AND ast1.per_system_status = 'ACTIVE_ASSIGN'
                                               AND c_effdt
                                                 BETWEEN asg1.effective_start_date AND asg1.effective_end_date
                                              )
                               )
                            )
                           )
                         OR
                           (assignment_type = 'B'
                              AND NOT EXISTS (SELECT assignment_id
                                              FROM per_all_assignments_f asg2,
                                                   per_assignment_status_types ast2
                                              WHERE asg2.assignment_type = 'E'
                                              AND asg2.primary_flag = 'Y'
                                              AND asg2.person_id = ppf.person_id
                                              AND asg2.assignment_status_type_id = ast2.assignment_status_type_id
                                              AND ast2.per_system_status = 'ACTIVE_ASSIGN'
                                              AND c_effdt
                                                BETWEEN asg2.effective_start_date AND asg2.effective_end_date
                                             )
                           )
                          )
		  )
	);
  --
  l_proc varchar2(80) := g_package || '.get_mssmlg_perids';
  --
  l_perid_en    pls_integer;
  l_mod         pls_integer;
  --
begin
  --
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  l_perid_va.delete;
  l_perid_en := 1;
  l_mod := 20;
  --
  for workid in 1..l_mod
  loop
    --
    l_modperid_va.delete;
    --
    if p_per_id is null
    then
      --
      open c_per_mssmlgmodallper
        (c_effdt            => p_effdt
        ,c_bgp_id           => p_bgp_id
        ,c_pet_id           => p_pet_id
        ,c_elig_enrol_cd    => p_elig_enrol_cd
        ,c_pgm_id           => p_pgm_id
        ,c_pl_nip_id        => p_pl_nip_id
        ,c_plan_in_pgm_flag => p_plan_in_pgm_flag
        ,c_org_id           => p_org_id
        ,c_loc_id           => p_loc_id
        ,c_work_id          => workid-1
        ,c_workers          => l_mod
        );
      fetch c_per_mssmlgmodallper bulk collect into l_modperid_va;
      close c_per_mssmlgmodallper;
      --
    else
      --
      open c_per_mssmlgmodoneper
        (c_per_id           => p_per_id
        ,c_effdt            => p_effdt
        ,c_bgp_id           => p_bgp_id
        ,c_pet_id           => p_pet_id
        ,c_elig_enrol_cd    => p_elig_enrol_cd
        ,c_pgm_id           => p_pgm_id
        ,c_pl_nip_id        => p_pl_nip_id
        ,c_plan_in_pgm_flag => p_plan_in_pgm_flag
        ,c_org_id           => p_org_id
        ,c_loc_id           => p_loc_id
        ,c_work_id          => workid-1
        ,c_workers          => l_mod
        );
      fetch c_per_mssmlgmodoneper bulk collect into l_modperid_va;
      close c_per_mssmlgmodoneper;
      --
    end if;
    --
    if l_modperid_va.count > 0
    then
      --
      for modvaen in l_modperid_va.first..l_modperid_va.last
      loop
        --
        l_perid_va.extend(1);
        l_perid_va(l_perid_en) := l_modperid_va(modvaen);
        l_perid_en := l_perid_en+1;
        --
      end loop;
      --
    end if;
    --
  end loop;
  --
  p_perid_va := l_perid_va;
  --
  hr_utility.set_location('Leaving : ' || l_proc, 10);
  --
end get_mssmlg_perids;
--
end ben_determine_communications1;

/
