--------------------------------------------------------
--  DDL for Package Body BEN_RELATED_PERSON_LER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_RELATED_PERSON_LER_API" as
/* $Header: benrllrb.pkb 120.1.12000000.2 2007/04/13 07:22:11 ssarkar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_related_person_ler_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_related_person_ler >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_related_person_ler
  (p_validate           in boolean  default false,
   p_person_id          in number,
   p_ler_id             in number,
   p_effective_date     in date,
   p_business_group_id  in number,
   p_csd_by_ptnl_ler_for_per_id in number default null,
   p_from_form          in varchar2 default 'Y') is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'create_related_person_ler';
  l_env_rec ben_env_object.g_global_env_rec_type;
  --
  cursor le_exists(p_person_id in number
                ,p_ler_id in number
                ,p_lf_evt_ocrd_dt in date) is
  select 'Y'
  from   ben_ptnl_ler_for_per
  where  person_id                             = p_person_id
  and    ler_id                                = p_ler_id
 /* commenting for bug 5968595
 and    PTNL_LER_FOR_PER_STAT_CD              <> 'VOIDD' /* Bug : 4624390 */
  and    lf_evt_ocrd_dt                        = p_lf_evt_ocrd_dt;
  --
  --
  -- output variables from API call.
  --
  l_ptnl_ler_for_per_id    ben_ptnl_ler_for_per.ptnl_ler_for_per_id%type;
  l_object_version_number  ben_ptnl_ler_for_per.object_version_number%type;
  --
  l_mnl_dt     date;
  l_dtctd_dt   date;
  l_procd_dt   date;
  l_unprocd_dt date;
  l_voidd_dt   date;
  l_con_rec    ben_person_object.g_cache_con_table;
  l_css_rec    ben_life_object.g_cache_css_table;
  l_per_rec    per_all_people_f%rowtype;
  l_ler_rec    ben_ler_f%rowtype;
  l_done_yet   boolean := false;
  l_le_exists  VARCHAR2(1);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Operation
  -- =========
  -- 1) Get the active life events occured date, this is what we use to check
  --    for existing contacts and life event causes life event rows.
  -- 2) Look for changes causes life event rows, then look for persons contacts
  --
  ben_env_object.get(p_rec => l_env_rec);
  --
  ben_life_object.get_object(p_ler_id => p_ler_id,
                             p_rec    => l_css_rec);
  --
  if l_css_rec.exists(1) then
    --
    for l_count2 in l_css_rec.first..l_css_rec.last loop
      --
      -- look for related persons
      --
      if not l_done_yet then
        --
        ben_person_object.get_object(p_person_id => p_person_id,
                                     p_rec       => l_con_rec);
        --
        l_done_yet := true;
        --
      end if;
      --
      if l_con_rec.exists(1) then
        --
        for l_count in l_con_rec.first..l_con_rec.last loop
          --
          hr_utility.set_location(' St Loop CONREC:'||l_proc, 70);
          --
          -- Since l_con_rec has all the contacts for the person, make sure to
          -- select only contacts whose relationships have not been end dated.
          --
          if l_con_rec(l_count).personal_flag = 'Y' and
             nvl(l_con_rec(l_count).date_end, hr_api.g_eot) >= p_effective_date
             then
            --
             open le_exists(l_con_rec(l_count).contact_person_id,
                            l_css_rec(l_count2).rsltg_ler_id,
                            l_env_rec.lf_evt_ocrd_dt);
             fetch le_exists into l_le_exists;
  --
  -- If an already existing life event of this
  -- type exists do nothing.
  --
           if le_exists%notfound then
            close le_exists;
            ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
              (p_validate                 => false,
               p_effective_date           => p_effective_date,
               p_business_group_id        => p_business_group_id,
               p_person_id                => l_con_rec(l_count).contact_person_id,
               p_ler_id                   => l_css_rec(l_count2).rsltg_ler_id,
               p_lf_evt_ocrd_dt           => l_env_rec.lf_evt_ocrd_dt,
               p_ptnl_ler_for_per_stat_cd => 'DTCTD',
               p_ptnl_ler_for_per_src_cd  => 'SYSGND',
               p_ptnl_ler_for_per_id      => l_ptnl_ler_for_per_id,
               p_csd_by_ptnl_ler_for_per_id => p_csd_by_ptnl_ler_for_per_id,
               p_object_version_number    => l_object_version_number,
               p_program_application_id   => fnd_global.prog_appl_id,
               p_program_id               => fnd_global.conc_program_id,
               p_request_id               => fnd_global.conc_request_id,
               p_program_update_date      => sysdate,
               p_ntfn_dt                  => trunc(sysdate),
               p_dtctd_dt                 => p_effective_date);
            --
            hr_utility.set_location(' Done CREPPL:'||l_proc, 70);
            if p_from_form = 'Y' then
              --
              null;
              --
            else
              --
              -- Write log message.
              --
              ben_person_object.get_object
                (p_person_id => l_con_rec(l_count).contact_person_id,
                 p_rec       => l_per_rec);
              --
              hr_utility.set_location(' Done PERGOBJ:'||l_proc, 70);
              ben_life_object.get_object
                (p_ler_id => l_css_rec(l_count2).rsltg_ler_id,
                 p_rec    => l_ler_rec);
              hr_utility.set_location(' Done LIFEGOBJ:'||l_proc, 70);
              --
              fnd_message.set_name('BEN','BEN_92110_RELATED_PERSON_LER');
              fnd_message.set_token('NAME',l_per_rec.full_name);
              fnd_message.set_token('LER',l_ler_rec.name);
              benutils.write(p_text => fnd_message.get);
              --
            end if;
           else
            close le_exists;
           end if;
            --
          end if;
          --
          hr_utility.set_location(' End Loop CONREC:'||l_proc, 70);
        end loop;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end create_related_person_ler;
--
end ben_Related_person_ler_api;

/
