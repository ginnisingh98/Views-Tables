--------------------------------------------------------
--  DDL for Package Body BEN_EVALUATE_PTNL_LF_EVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EVALUATE_PTNL_LF_EVT" as
/* $Header: benptnle.pkb 120.21.12010000.3 2008/08/05 14:51:01 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_evaluate_ptnl_lf_evt.';
g_rec      benutils.g_batch_ler_rec;

-- ----------------------------------------------------------------------------
-- |------------------------< update_ptnl_per_for_ler >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ptnl_per_for_ler
   (p_ptnl_rec       IN OUT NOCOPY BEN_PTNL_LER_FOR_PER%ROWTYPE
   ,p_effective_date IN DATE) is
  --
  l_proc varchar2(72) := g_package||'update_ptnl_per_for_ler';
  --
  l_mnl_dt date;
  l_dtctd_dt   date;
  l_procd_dt   date;
  l_unprocd_dt date;
  l_voidd_dt   date;
  --
begin
  --
  l_procd_dt := trunc(sysdate);
  --
  ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
    (p_validate                 => false
    ,p_ptnl_ler_for_per_id      => p_ptnl_rec.ptnl_ler_for_per_id
    ,p_lf_evt_ocrd_dt           => p_ptnl_rec.lf_evt_ocrd_dt
    ,p_ptnl_ler_for_per_stat_cd => 'PROCD'
    ,p_procd_dt                 => p_effective_date
    ,p_ler_id                   => p_ptnl_rec.ler_id
    ,p_person_id                => p_ptnl_rec.person_id
    ,p_business_group_id        => p_ptnl_rec.business_group_id
    ,p_object_version_number    => p_ptnl_rec.object_version_number
    ,p_effective_date           => p_effective_date
    ,p_program_application_id   => fnd_global.prog_appl_id
    ,p_program_id               => fnd_global.conc_program_id
    ,p_request_id               => fnd_global.conc_request_id
    ,p_program_update_date      => sysdate);
  --
end update_ptnl_per_for_ler;
--
-- ----------------------------------------------------------------------------
-- |------------------< absences_eval_ptnl_per_for_ler >----------------------|
-- ----------------------------------------------------------------------------
--
procedure absences_eval_ptnl_per_for_ler(p_validate in boolean default false
                               ,p_person_id           in number
                               ,p_business_group_id   in number
                               ,p_ler_id              in number default null
                               ,p_mode                in varchar2
                               ,p_effective_date      in date
                               ,p_created_ler_id      out NOCOPY number) is
  --
  l_min_lf_evt_ocrd_dt date := null;
  --
  cursor get_all_potential is
    select ler.ovridg_le_flag,
           pfl.ler_id,
           pfl.ptnl_ler_for_per_id,
           pfl.lf_evt_ocrd_dt,
           pfl.object_version_number,
           ler.ler_eval_rl,
           pfl.creation_date,
           pfl.ptnl_ler_for_per_stat_cd,
           pfl.ntfn_dt,
           pfl.dtctd_dt,
           pfl.voidd_dt,
           ler.name,
           pfl.trgr_table_pk_id, -- it is absence_attendance_id
           ler.lf_evt_oper_cd, -- 9999 lf_evt_oper_cd,
           ler.typ_cd
    from   ben_ptnl_ler_for_per pfl,
           ben_ler_f ler
    where  pfl.ptnl_ler_for_per_stat_cd not in ('VOIDD','PROCD')
    and    pfl.person_id = p_person_id
    and    pfl.ler_id = ler.ler_id
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    pfl.lf_evt_ocrd_dt <= p_effective_date
    --
    -- 9999 Do we need to filter based on effective_date, as all potentials
    -- need to be processed. Also first void all potentials which are not
    -- processed and are corrections.
    --
    and    pfl.ler_id <> ben_manage_life_events.g_ler_id
    and    ler.typ_cd = 'ABS'
    order  by pfl.lf_evt_ocrd_dt asc,
           decode(ler.lf_evt_oper_cd,'DELETE',3,'START',2,1) desc;

  --
  l_potent      get_all_potential%rowtype;
  l_potent_temp get_all_potential%rowtype;
  --
  TYPE l_ppl_rec is TABLE OF get_all_potential%rowtype
       INDEX BY BINARY_INTEGER;
  --
  l_ppl_table            l_ppl_rec;
  l_next_row             binary_integer;
  --
  cursor c_get_min_ptnl is
    select min(ptn.lf_evt_ocrd_dt)
    from   ben_ptnl_ler_for_per ptn,
           ben_ler_f      ler
    where  ptn.person_id = p_person_id
    and    ptn.ler_id    = ler.ler_id
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    ler.typ_cd = 'ABS'
    and    ptn.business_group_id = p_business_group_id
    and    ptn.lf_evt_ocrd_dt <= p_effective_date
    and    ptn.ler_id <> ben_manage_life_events.g_ler_id
    and    ptn.ptnl_ler_for_per_stat_cd not in ('PROCD','VOIDD');
  --
  cursor c_get_ptnl_for_aba is
    select ptn.ptnl_ler_for_per_id
    from ben_ptnl_ler_for_per ptn,
         ben_ler_f      ler
    where ptn.person_id = p_person_id
      and ptn.business_group_id = p_business_group_id
      and ptn.ptnl_ler_for_per_stat_cd not in ('PROCD','VOIDD')
      and p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
      and ler.typ_cd = 'ABS'
      and ptn.ler_id    = ler.ler_id
      and ptn.trgr_table_pk_id = l_potent.trgr_table_pk_id
      and ler.lf_evt_oper_cd = 'DELETE';
  --
  cursor c_get_ptnl_for_del_aba is
    select ptn.*
    from ben_ptnl_ler_for_per ptn
    where ptn.person_id = p_person_id
      and ptn.ptnl_ler_for_per_stat_cd not in ('PROCD','VOIDD')
      and ptn.trgr_table_pk_id = l_potent.trgr_table_pk_id;
  --
  --
  cursor c_winning_ptnl_of_same_type is
    select ler.lf_evt_oper_cd,ptn.*
    from ben_ptnl_ler_for_per ptn,
         ben_ler_f ler
    where ptn.person_id = p_person_id
      and ptn.ptnl_ler_for_per_stat_cd <> 'VOIDD' -- 9999(it should work) not in ('PROCD','VOIDD')
      and ptn.trgr_table_pk_id = l_potent.trgr_table_pk_id
      -- not needed 9999 delete it and ptn.ptnl_ler_for_per_id <> l_potent.ptnl_ler_for_per_id
      and ptn.ler_id = l_potent.ler_id
      and ler.ler_id = ptn.ler_id
      and p_effective_date between ler.effective_start_date and
          ler.effective_end_date
    order by ptn.ptnl_ler_for_per_id desc;
  --
  l_winning_ptnl_rec c_winning_ptnl_of_same_type%rowtype;
  l_next_ptnl_rec    c_winning_ptnl_of_same_type%rowtype;

  cursor c_reopened_abs is
    select 'x'
      from per_absence_attendances
     where absence_attendance_id = l_winning_ptnl_rec.trgr_table_pk_id
       and date_end is null;

  cursor c_get_ptnl_for_win_aba is
    select ptn.*
    from ben_ptnl_ler_for_per ptn
    where ptn.person_id = p_person_id
      and ptn.ptnl_ler_for_per_stat_cd not in ('PROCD','VOIDD')
      and ptn.ler_id = l_winning_ptnl_rec.ler_id
      and ptn.trgr_table_pk_id = l_winning_ptnl_rec.trgr_table_pk_id
      and ptn.ptnl_ler_for_per_id <> l_winning_ptnl_rec.ptnl_ler_for_per_id;
  --
  cursor c_get_procd_pils_for_aba is
    select pil.lf_evt_ocrd_dt
    from   ben_per_in_ler pil
    where  pil.person_id = p_person_id
      and  pil.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
      and  pil.business_group_id = p_business_group_id
      and  pil.trgr_table_pk_id  = l_potent.trgr_table_pk_id
      order  by pil.lf_evt_ocrd_dt asc;
  --
  cursor c_get_procd_pils_for_win is
    select pil.lf_evt_ocrd_dt
    from   ben_per_in_ler pil
    where  pil.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
      and  pil.business_group_id = p_business_group_id
      and  pil.trgr_table_pk_id  = l_winning_ptnl_rec.trgr_table_pk_id
      and  pil.ler_id = l_winning_ptnl_rec.ler_id
      order  by pil.lf_evt_ocrd_dt asc;
  --
  l_procd_lf_evt_ocrd_dt date;
  --
  cursor c_pils_to_backout(p_min_lf_evt_ocrd_dt date, p_ler_id number ) is
    select pil.*
    from   ben_per_in_ler pil,
           ben_ler_f      ler
    where  pil.business_group_id = p_business_group_id
    and    pil.person_id = p_person_id
    and    pil.lf_evt_ocrd_dt >= p_min_lf_evt_ocrd_dt
    and    pil.ler_id <> ben_manage_life_events.g_ler_id -- 9999 what is this?
    and    pil.ler_id = ler.ler_id
    and    (pil.ler_id = p_ler_id or p_ler_id = -1)
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    -- GRADE/STEP
	  -- bug 6147208
    -- and    ler.typ_cd not in ('COMP', 'GSP', 'IREC')-- iRec
    and    ler.typ_cd = 'ABS'
    and    pil.per_in_ler_stat_cd in ('STRTD','PROCD')
    order by pil.lf_evt_ocrd_dt desc,ler.lf_evt_oper_cd asc; -- most recent is the first one to backout.
  --
  l_proc                varchar2(72) := g_package||'absences_eval_ptnl_per_for_ler';
  l_del_ptnl_ler_for_per_id    NUMBER;
  l_bckt_stat_cd            varchar2(72);
  l_curr_per_in_ler_id         NUMBER;
  l_object_version_number      NUMBER;
  l_procd_dt                   date;
  l_strtd_dt                   date;
  l_voidd_dt                   date;
  l_del_ptnl_found             boolean := false;
  l_create_per_in_ler          boolean := true;
  l_dummy                      varchar2(1);

  --
  --Start 6086392
     l_date      date;
     l_bckdt_pil_indx BINARY_INTEGER;
     l_bckdt_pil_count BINARY_INTEGER;
  --End 6086392

   -- bug
   CURSOR c_pil_ovn (cv_per_in_ler_id IN NUMBER)
   IS
      SELECT object_version_number
        FROM ben_per_in_ler
       WHERE per_in_ler_id = cv_per_in_ler_id;

   pil_ovn_rec   c_pil_ovn%ROWTYPE;
	 -- end bug

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Initialise all the variables in the loop.
  --
  loop
    --
    l_potent  :=  l_potent_temp;
    open get_all_potential;
    fetch get_all_potential into l_potent;
    close get_all_potential;
    --
    -- Check if there is a absence delete potential life event exists
    -- for absence attendance id then void all the potentials.
    --
    l_del_ptnl_ler_for_per_id := null;
    open c_get_ptnl_for_aba;
    fetch c_get_ptnl_for_aba into l_del_ptnl_ler_for_per_id;
    close c_get_ptnl_for_aba;
    --
    if l_del_ptnl_ler_for_per_id is not null then
     --
     -- Check any absences are processed which are attached to current absence_id.
     --
     -- Check if there is a Absence Deleted Potential Life Event attached to
     -- this absence_id. If exists then make it processed. If there are
     -- no processed life events attached to this absence_id then void the
     -- absence potential life events attached to this absence_id. If
     -- Absence Start Life Event attached to this absence_id is processed
     -- then backout all the processed absence life events which are in
     -- future with respect to current Absence Start Life Event in descending
     -- order i.e., from row with max lf_evt_ocrd_dt to min lf_evt_ocrd_dt.
     -- Now void all potential life events attached to the deleted absence_id.
     --
     --
     l_del_ptnl_found := true;
     --
     open c_get_procd_pils_for_aba;
     fetch c_get_procd_pils_for_aba into l_min_lf_evt_ocrd_dt;
     close c_get_procd_pils_for_aba;
     --
     if l_min_lf_evt_ocrd_dt is not null then
        --
        -- Back out all the processed life events as this absence is deleted.
        --
        for l_pil_rec in c_pils_to_backout(l_min_lf_evt_ocrd_dt, -1) loop
           --
           l_bckt_stat_cd := 'UNPROCD';
           if l_potent.trgr_table_pk_id = l_pil_rec.trgr_table_pk_id then
              --
              -- Void the potentials which are attched to the deleted absence
              --
              l_bckt_stat_cd := 'VOIDD';
              --
           end if;
           --
           ben_back_out_life_event.back_out_life_events
             (p_per_in_ler_id         => l_pil_rec.per_in_ler_id,
              p_bckt_per_in_ler_id    => null,
              p_bckt_stat_cd          => l_bckt_stat_cd,
              p_business_group_id     => p_business_group_id,
              p_effective_date        => p_effective_date);
           --
  --Start 6086392
             l_bckdt_pil_count := nvl(ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl.count(),0);
             l_bckdt_pil_count := l_bckdt_pil_count +1;
             ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl(l_bckdt_pil_count) := l_pil_rec.per_in_ler_id;
  --End 6086392


        end loop;
        --
     end if;
     --
     -- Now void all the potentials attached to the current absence.
     --
     for l_ppl_rec in c_get_ptnl_for_del_aba loop
         --
         if l_del_ptnl_ler_for_per_id = l_ppl_rec.ptnl_ler_for_per_id then
           --
           ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
            (p_validate                 => false
            ,p_ptnl_ler_for_per_id      => l_ppl_rec.ptnl_ler_for_per_id
            ,p_lf_evt_ocrd_dt           => l_ppl_rec.lf_evt_ocrd_dt
            ,p_ptnl_ler_for_per_stat_cd => 'PROCD'
            ,p_procd_dt                 => p_effective_date
            ,p_ler_id                   => l_ppl_rec.ler_id
            ,p_person_id                => l_ppl_rec.person_id
            ,p_business_group_id        => l_ppl_rec.business_group_id
            ,p_object_version_number    => l_ppl_rec.object_version_number
            ,p_effective_date           => p_effective_date
            ,p_program_application_id   => fnd_global.prog_appl_id
            ,p_program_id               => fnd_global.conc_program_id
            ,p_request_id               => fnd_global.conc_request_id
            ,p_program_update_date      => sysdate);
           --
         else
           --
           ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
             (p_validate                 => false
             ,p_ptnl_ler_for_per_id      => l_ppl_rec.ptnl_ler_for_per_id
             ,p_ptnl_ler_for_per_stat_cd => 'VOIDD'
             ,p_object_version_number    => l_ppl_rec.object_version_number
             ,p_effective_date           => p_effective_date
             ,p_program_application_id   => fnd_global.prog_appl_id
             ,p_program_id               => fnd_global.conc_program_id
             ,p_request_id               => fnd_global.conc_request_id
             ,p_program_update_date      => sysdate
             ,p_voidd_dt                 => p_effective_date);
           --
         end if;
         --
     end loop;
     --
    else
     --
     -- If the delete potential do not exist for the current absence
     -- continue processing it.
     --
     exit;
     --
    end if; -- End of delete potential existence.
    --
  end loop;
  --
  -- For the absence_id attached to this potential find the max(potential_id)
  -- of same life event type (same ler_id) (If in step 1 absence start life event
  -- is picked up then all absence start life events attached to this absence id
  -- will be picked up). If there is a End potential Life Event on same day then
  -- process have to pick up Start potential life event first. This will be
  -- the winning potential life event.
  --
  open c_winning_ptnl_of_same_type;
  fetch c_winning_ptnl_of_same_type into l_winning_ptnl_rec;
  --
  if l_del_ptnl_found and l_winning_ptnl_rec.ptnl_ler_for_per_id is null then
     --
     close c_winning_ptnl_of_same_type;
     --
     -- All the absences are deleted, no winner is found then we need to just
     -- commit the data and move on with next person.
     -- 9999 change the message.
     fnd_message.set_name('BEN','BEN_92536_PERSON_HAS_NO_PPL');
     fnd_message.set_token('PERSON_ID',p_person_id);
     fnd_message.set_token('PROC',l_proc);
     benutils.write(fnd_message.get);
     --
     -- For BENAUTHE
     --
     fnd_message.set_name('BEN','BEN_92536_PERSON_HAS_NO_PPL');
     fnd_message.set_token('PERSON_ID',p_person_id);
     fnd_message.set_token('PROC',l_proc);
     raise ben_manage_life_events.g_life_event_after;
     --
  end if;
  --
  -- Check any more potential exists for the winner type of absence.
  --
  fetch c_winning_ptnl_of_same_type into l_next_ptnl_rec;
  --
  close c_winning_ptnl_of_same_type;
  --
  --
  --
  if (l_winning_ptnl_rec.ptnl_ler_for_per_id <> l_potent.ptnl_ler_for_per_id or
     l_next_ptnl_rec.ptnl_ler_for_per_id is not null)
  then
     --
     -- There are corrections associated with the winner so void all the corrections.
     -- also backout any processed life events in future if there is a processed
     -- life event associated with this absence and ler type.
     --
     -- Find processed absence life event of same type(same ler_id, absence_id)
     -- as winning absence life event (this could be for example absence start
     -- life event). Backout all the processed absence life events which are
     -- in future compared to this processed life event. This processed life event
     -- should be backed out and voided and also potential associated with it
     -- should be voided.
     --
     l_procd_lf_evt_ocrd_dt := null;
     open c_get_procd_pils_for_win;
     fetch c_get_procd_pils_for_win into l_procd_lf_evt_ocrd_dt;
     close c_get_procd_pils_for_win;
     --
     if l_procd_lf_evt_ocrd_dt is not null then
        --
        -- Back out all the processed future life events
        --
        for l_pil_rec in c_pils_to_backout(l_procd_lf_evt_ocrd_dt, -1)
        loop
           --
           l_bckt_stat_cd := 'UNPROCD';
           --
           if (l_winning_ptnl_rec.trgr_table_pk_id = l_pil_rec.trgr_table_pk_id  and
              l_winning_ptnl_rec.ler_id = l_pil_rec.ler_id)
           then
              --
              -- Void the potentials which are attched to the deleted absence
              --
              l_bckt_stat_cd := 'VOIDD';
              --
           end if;
           --
           ben_back_out_life_event.back_out_life_events
             (p_per_in_ler_id         => l_pil_rec.per_in_ler_id,
              p_bckt_per_in_ler_id    => null,
              p_bckt_stat_cd          => l_bckt_stat_cd,
              p_business_group_id     => p_business_group_id,
              p_effective_date        => p_effective_date);
           --

	     --Start 6086392
             l_bckdt_pil_count := nvl(ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl.count(),0);
             l_bckdt_pil_count := l_bckdt_pil_count +1;
             ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl(l_bckdt_pil_count) := l_pil_rec.per_in_ler_id;
	       --End 6086392


        end loop;
        --
     end if;
     --
     -- Now void all the potentials attached to the current absence.
     --
     for l_ppl_rec in c_get_ptnl_for_win_aba loop
         --
         ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
             (p_validate                 => false
             ,p_ptnl_ler_for_per_id      => l_ppl_rec.ptnl_ler_for_per_id
             ,p_ptnl_ler_for_per_stat_cd => 'VOIDD'
             ,p_object_version_number    => l_ppl_rec.object_version_number
             ,p_effective_date           => p_effective_date
             ,p_program_application_id   => fnd_global.prog_appl_id
             ,p_program_id               => fnd_global.conc_program_id
             ,p_request_id               => fnd_global.conc_request_id
             ,p_program_update_date      => sysdate
             ,p_voidd_dt                 => p_effective_date);
         --
     end loop;
  end if;
  --
  -- Now backout all the life events in future compared with
  -- current life event.
  --
  for l_future_pil_rec in c_pils_to_backout(l_winning_ptnl_rec.lf_evt_ocrd_dt + 1, -1) --iRec added +
  loop
     --
     ben_back_out_life_event.back_out_life_events
        (p_per_in_ler_id        => l_future_pil_rec.per_in_ler_id,
        p_bckt_per_in_ler_id    => null,
        p_bckt_stat_cd          => 'UNPROCD',
        p_business_group_id     => p_business_group_id,
        p_effective_date        => p_effective_date);
     --
  --Start 6086392
             l_bckdt_pil_count := nvl(ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl.count(),0);
             l_bckdt_pil_count := l_bckdt_pil_count +1;
             ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl(l_bckdt_pil_count) := l_future_pil_rec.per_in_ler_id;
  --End 6086392

  end loop;
  --
  if l_winning_ptnl_rec.lf_evt_oper_cd ='END' then
     -- in case absence is reopened, don't create a new per in ler
     -- just mark the ptnl as PROCD
     open c_reopened_abs;
     fetch c_reopened_abs into l_dummy;
     l_create_per_in_ler := c_reopened_abs%notfound;
     close c_reopened_abs;
  end if;

  if l_create_per_in_ler then
     --
     -- Create the per in ler for the winner.
     --
     ben_Person_Life_Event_api.create_Person_Life_Event_perf
       (p_validate                => false
       ,p_per_in_ler_id           => l_curr_per_in_ler_id
       ,p_ler_id                  => l_winning_ptnl_rec.ler_id
       ,p_person_id               => l_winning_ptnl_rec.person_id
       ,p_per_in_ler_stat_cd      => 'STRTD'
       ,p_ptnl_ler_for_per_id     => l_winning_ptnl_rec.ptnl_ler_for_per_id
       ,p_lf_evt_ocrd_dt          => l_winning_ptnl_rec.lf_evt_ocrd_dt
       ,p_business_group_id       => l_winning_ptnl_rec.business_group_id
       ,p_ntfn_dt                 => l_winning_ptnl_rec.ntfn_dt
       ,p_trgr_table_pk_id          => l_winning_ptnl_rec.trgr_table_pk_id
       ,p_object_version_number   => l_object_version_number
       ,p_effective_date          => p_effective_date
       ,p_program_application_id  => fnd_global.prog_appl_id
       ,p_program_id              => fnd_global.conc_program_id
       ,p_request_id              => fnd_global.conc_request_id
       ,p_program_update_date     => sysdate
       ,p_procd_dt                => l_procd_dt
       ,p_strtd_dt                => l_strtd_dt
       ,p_voidd_dt                => l_voidd_dt);

  end if;

  g_rec.person_id := p_person_id;
  g_rec.ler_id := l_winning_ptnl_rec.ler_id;
  g_rec.lf_evt_ocrd_dt := l_winning_ptnl_rec.lf_evt_ocrd_dt;
  g_rec.replcd_flag := 'N';
  g_rec.crtd_flag := 'Y';
  g_rec.tmprl_flag := 'N';
  g_rec.dltd_flag := 'N';
  g_rec.open_and_clsd_flag := 'N';
  g_rec.not_crtd_flag := 'N';
  g_rec.clsd_flag := 'N';
  g_rec.stl_actv_flag := 'N';
  g_rec.clpsd_flag := 'N';
  g_rec.clsn_flag := 'N';
  g_rec.no_effect_flag := 'N';
  g_rec.cvrge_rt_prem_flag := 'N';
  g_rec.business_group_id := p_business_group_id;
  g_rec.effective_date := p_effective_date;
  g_rec.per_in_ler_id := l_curr_per_in_ler_id;
  --
  benutils.write(p_rec => g_rec);
  --
  -- update ptnl
  --
  --
  l_procd_dt := trunc(sysdate);
  --
  ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
    (p_validate                 => false
    ,p_ptnl_ler_for_per_id      => l_winning_ptnl_rec.ptnl_ler_for_per_id
    ,p_lf_evt_ocrd_dt           => l_winning_ptnl_rec.lf_evt_ocrd_dt
    ,p_ptnl_ler_for_per_stat_cd => 'PROCD'
    ,p_procd_dt                 => p_effective_date
    ,p_ler_id                   => l_winning_ptnl_rec.ler_id
    ,p_person_id                => l_winning_ptnl_rec.person_id
    ,p_business_group_id        => l_winning_ptnl_rec.business_group_id
    ,p_object_version_number    => l_winning_ptnl_rec.object_version_number
    ,p_effective_date           => p_effective_date
    ,p_program_application_id   => fnd_global.prog_appl_id
    ,p_program_id               => fnd_global.conc_program_id
    ,p_request_id               => fnd_global.conc_request_id
    ,p_program_update_date      => sysdate);

  p_created_ler_id := l_winning_ptnl_rec.ler_id;

  if not l_create_per_in_ler then
     hr_utility.set_location('Leaving:'|| l_proc, 10);
     raise ben_manage_life_events.g_life_event_after;
  end if;


  --Start 6086392
l_bckdt_pil_indx := ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl.first;

if(l_bckdt_pil_indx is not null) then

     loop
      -- bug 5987235

        OPEN c_pil_ovn(ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl(l_bckdt_pil_indx));
        FETCH c_pil_ovn INTO pil_ovn_rec;
        CLOSE c_pil_ovn;

              ben_Person_Life_Event_api.update_person_life_event
                (p_per_in_ler_id         => ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl(l_bckdt_pil_indx)
                ,p_bckt_per_in_ler_id    => l_curr_per_in_ler_id
                -- ,p_object_version_number => l_object_version_number
                ,p_object_version_number => pil_ovn_rec.object_version_number
                ,p_effective_date        => p_effective_date
                ,P_PROCD_DT              => l_date  -- outputs
                ,P_STRTD_DT              => l_date
                ,P_VOIDD_DT              => l_date  );

        exit when l_bckdt_pil_indx = ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl.last;

        l_bckdt_pil_indx := ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl.next(l_bckdt_pil_indx);

    end loop;

end if;

ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl.delete;

  --End 6086392

  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
-- bug 5987235
  Exception
	  when ben_manage_life_events.g_life_event_after then
		  hr_utility.set_location('PTNLE Absence eval Exception g_life_event_after', 121);
			ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl.delete;
			raise ben_manage_life_events.g_life_event_after;
		when others then
		  hr_utility.set_location('PTNLE Absence eval Exception ', 121);
			ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl.delete;
		  fnd_message.raise_error;
-- end bug 5987235
end absences_eval_ptnl_per_for_ler;
--
-- ----------------------------------------------------------------------------
-- |------------------------< cwb_eval_ptnl_per_for_ler >----------------------|
-- ----------------------------------------------------------------------------
--
procedure cwb_eval_ptnl_per_for_ler(p_validate in boolean default false
                               ,p_person_id in number
                               ,p_business_group_id in number
                               ,p_ler_id in number default null
                               ,p_mode in varchar2
                               ,p_effective_date in date
                               ,p_lf_evt_ocrd_dt in date
                               ,p_ptnl_ler_for_per_id in number
                               ,p_created_ler_id out NOCOPY number) is
  --
  cursor c_ptnl(cv_ptnl_ler_for_per_id in number)
  is
    select ptnl.*
    from ben_ptnl_ler_for_per ptnl
    where ptnl.ptnl_ler_for_per_id = cv_ptnl_ler_for_per_id;
  --
  cursor get_per_in_ler(cv_lf_evt_ocrd_dt date)
  is
    select pil.per_in_ler_id,
           pil.per_in_ler_stat_cd,
           pil.lf_evt_ocrd_dt,
           pil.ler_id,
           pil.person_id,
           pil.business_group_id,
           pil.object_version_number,
           pil.procd_dt,
           pil.strtd_dt,
           pil.voidd_dt,
           pil.bckt_dt,
           pil.clsd_dt,
           pil.ntfn_dt
    from   ben_per_in_ler pil,
           ben_ler_f      ler
    where  pil.person_id = p_person_id
    and    pil.per_in_ler_stat_cd in ('STRTD','PROCD')
    and    pil.lf_evt_ocrd_dt >= cv_lf_evt_ocrd_dt
    and    pil.ler_id = ler.ler_id
    and    pil.ler_id = p_ler_id
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    ler.typ_cd = 'COMP'
    union
    select pil.per_in_ler_id,
           pil.per_in_ler_stat_cd,
           pil.lf_evt_ocrd_dt,
           pil.ler_id,
           pil.person_id,
           pil.business_group_id,
           pil.object_version_number,
           pil.procd_dt,
           pil.strtd_dt,
           pil.voidd_dt,
           pil.bckt_dt,
           pil.clsd_dt,
           pil.ntfn_dt
    from   ben_per_in_ler pil,
           ben_ler_f      ler
    where  pil.person_id = p_person_id
    and    pil.per_in_ler_stat_cd in ('STRTD')
    and    pil.lf_evt_ocrd_dt < cv_lf_evt_ocrd_dt
    and    pil.ler_id = ler.ler_id
    and    pil.ler_id = p_ler_id
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    ler.typ_cd = 'COMP'
    order by 3 asc;
  --
  l_pil_rec  get_per_in_ler%rowtype;
  l_ptnl_rec ben_ptnl_ler_for_per%rowtype;
  l_procd_dt                   date;
  l_strtd_dt                   date;
  l_voidd_dt                   date;
  l_object_version_number      NUMBER;
  l_curr_per_in_ler_id         number;
  l_created_ler                varchar2(2) := 'N';
  l_ws_mgr_id                  number;
  l_assignment_id              number(15);
  l_rec                        benutils.g_batch_param_rec;
  --
begin
  --
  hr_utility.set_location('Entering cwb_eval_ptnl_per_for_ler',10);
  hr_utility.set_location('ler_id = ' || p_ler_id,12345);
  hr_utility.set_location('p_lf_evt_ocrd_dt = ' || p_lf_evt_ocrd_dt,12345);
  --
  -- Check whether a per in ler exists for a given ler_id,
  -- life event occured date
  --
  open get_per_in_ler(p_lf_evt_ocrd_dt);
  fetch get_per_in_ler into l_pil_rec;
  close get_per_in_ler;
  --
  if l_pil_rec.lf_evt_ocrd_dt is null then
    --
    -- Case A : Create the per in ler.
    --
    hr_utility.set_location('A',10);
    --
    open c_ptnl(p_ptnl_ler_for_per_id);
    fetch c_ptnl into l_ptnl_rec;
    close c_ptnl;
    --
    l_created_ler := 'Y';
    p_created_ler_id := p_ler_id;
    --
    -- GLOBALCWB : Populate data into ben_cwb_group_hrchy,
    -- ben_cwb_person_tasks, ben_cwb_person_info if the per in ler
    -- created is group per in ler.
    --
    ben_manage_cwb_life_events.g_cache_group_plan_rec.group_per_in_ler_id := null;
    if benutils.g_benefit_action_id is not null then
     --
     benutils.get_batch_parameters
      (p_benefit_action_id => benutils.g_benefit_action_id,
       p_rec               => l_rec);
     --
     ben_manage_cwb_life_events.get_group_plan_info(
                        p_pl_id                => l_rec.pl_id,
                        p_lf_evt_ocrd_dt       => l_rec.lf_evt_ocrd_dt,
                        p_business_group_id    => l_rec.business_group_id);
     --
     hr_utility.set_location(ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id ,1234);
     if l_rec.pl_id = ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id then
        --
        ben_manage_cwb_life_events.get_cwb_manager_and_assignment
                (p_person_id                => p_person_id,
                 p_hrchy_to_use_cd          => ben_manage_cwb_life_events.g_cache_group_plan_rec.hrchy_to_use_cd,
                 p_pos_structure_version_id => ben_manage_cwb_life_events.g_cache_group_plan_rec.pos_structure_version_id,
                 p_effective_date           => ben_manage_cwb_life_events.g_cache_group_plan_rec.group_lf_evt_ocrd_dt,
                 p_manager_id               => l_ws_mgr_id,
                 p_assignment_id            => l_assignment_id ) ;
        --
        hr_utility.set_location('l_ws_mgr_id = ' || l_ws_mgr_id, 1234);
        hr_utility.set_location('l_assignment_id = ' || l_assignment_id, 1234);
     end if;
    end if;
    --
    hr_utility.set_location('group_pl_id = ' || ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id, 1234);
    ben_Person_Life_Event_api.create_Person_Life_Event_perf
    (p_validate                => false
    ,p_per_in_ler_id           => l_curr_per_in_ler_id
    ,p_ler_id                  => p_ler_id
    ,p_person_id               => p_person_id
    ,p_per_in_ler_stat_cd      => 'STRTD'
    ,p_ptnl_ler_for_per_id     => p_ptnl_ler_for_per_id
    ,p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt
    ,p_business_group_id       => p_business_group_id
    ,p_ntfn_dt                 => trunc(sysdate) -- p_ptnl_rec.ntfn_dt
    ,p_group_pl_id             => ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id
    ,p_ws_mgr_id               => l_ws_mgr_id
    ,p_assignment_id           => l_assignment_id
    ,p_object_version_number   => l_object_version_number
    ,p_effective_date          => p_effective_date
    ,p_program_application_id  => fnd_global.prog_appl_id
    ,p_program_id              => fnd_global.conc_program_id
    ,p_request_id              => fnd_global.conc_request_id
    ,p_program_update_date     => sysdate
    ,p_procd_dt                => l_procd_dt
    ,p_strtd_dt                => l_strtd_dt
    ,p_voidd_dt                => l_voidd_dt);
    --
    if l_rec.pl_id = ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id then
        --
        -- Per in ler created is a group per in ler so populate other
        -- plan design tables.
        --
        hr_utility.set_location('Call ben_manage_cwb_life_events.popu_cwb_tables', 1234);
        ben_manage_cwb_life_events.popu_cwb_tables(
            p_group_per_in_ler_id    =>  l_curr_per_in_ler_id,
            p_group_pl_id            =>  ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id,
            p_group_lf_evt_ocrd_dt   =>  ben_manage_cwb_life_events.g_cache_group_plan_rec.group_lf_evt_ocrd_dt,
            p_group_business_group_id => ben_manage_cwb_life_events.g_cache_group_plan_rec.group_business_group_id,
            p_group_ler_id           =>  ben_manage_cwb_life_events.g_cache_group_plan_rec.group_ler_id);
    end if;
    --
    g_rec.person_id      := p_person_id;
    g_rec.ler_id         := p_ler_id;
    g_rec.lf_evt_ocrd_dt := p_lf_evt_ocrd_dt;
    g_rec.replcd_flag    := 'N';
    g_rec.crtd_flag      := 'Y';
    g_rec.tmprl_flag     := 'N';
    g_rec.dltd_flag      := 'N';
    g_rec.open_and_clsd_flag := 'N';
    g_rec.not_crtd_flag  := 'N';
    g_rec.clsd_flag      := 'N';
    g_rec.stl_actv_flag  := 'N';
    g_rec.clpsd_flag     := 'N';
    g_rec.clsn_flag      := 'N';
    g_rec.no_effect_flag := 'N';
    g_rec.cvrge_rt_prem_flag := 'N';
    g_rec.business_group_id := p_business_group_id;
    g_rec.effective_date := p_effective_date;
    g_rec.per_in_ler_id  := l_curr_per_in_ler_id;
    --
    benutils.write(p_rec => g_rec);
    --
    -- update ptnl
    --
    update_ptnl_per_for_ler
      (p_ptnl_rec       => l_ptnl_rec
      ,p_effective_date => p_effective_date);
    --
  elsif p_lf_evt_ocrd_dt > l_pil_rec.lf_evt_ocrd_dt then
    --
    hr_utility.set_location('Case B ',10);
    --
    -- Case B : Potential is after active per in ler. First complete it.
    --
    fnd_message.set_name('BEN','BEN_91797_PTNL_AFTER_ACTIVE');
    fnd_message.set_token('PTNL_LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
    fnd_message.set_token('ACTIVE_LF_EVT_OCRD_DT',
                           l_pil_rec.lf_evt_ocrd_dt);
    benutils.write(p_text => fnd_message.get);
    --
    g_rec.person_id := p_person_id;
    g_rec.ler_id := l_pil_rec.ler_id;
    g_rec.lf_evt_ocrd_dt := p_lf_evt_ocrd_dt;
    g_rec.replcd_flag := 'N';
    g_rec.crtd_flag := 'N';
    g_rec.tmprl_flag := 'N';
    g_rec.dltd_flag := 'N';
    g_rec.open_and_clsd_flag := 'N';
    g_rec.not_crtd_flag := 'N';
    g_rec.clsd_flag := 'N';
    g_rec.stl_actv_flag := 'Y';
    g_rec.clpsd_flag := 'N';
    g_rec.clsn_flag := 'N';
    g_rec.no_effect_flag := 'N';
    g_rec.cvrge_rt_prem_flag := 'N';
    g_rec.business_group_id := p_business_group_id;
    g_rec.effective_date := p_effective_date;
    --
    benutils.write(p_rec => g_rec);
    --
    -- For BENAUTHE retreival purpose.
    fnd_message.set_name('BEN','BEN_91797_PTNL_AFTER_ACTIVE');
    fnd_message.set_token('PTNL_LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
    fnd_message.set_token('ACTIVE_LF_EVT_OCRD_DT',
                           l_pil_rec.lf_evt_ocrd_dt);
    raise ben_manage_life_events.g_life_event_after;
    --
  else
    --
    hr_utility.set_location('Case C ',10);
    --
    -- Case C : Processed or active per in ler is in future for the given
    --          ler so error out. You can't go back and run.
    --
    fnd_message.set_name('BEN','BEN_92864_CWB_PTNL_AFTR_ACTIVE');
    fnd_message.set_token('PTNL_LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
    fnd_message.set_token('ACTIVE_LF_EVT_OCRD_DT',
                           l_pil_rec.lf_evt_ocrd_dt);
    benutils.write(p_text => fnd_message.get);
    --
    g_rec.person_id := p_person_id;
    g_rec.ler_id := l_pil_rec.ler_id;
    g_rec.lf_evt_ocrd_dt := p_lf_evt_ocrd_dt;
    g_rec.replcd_flag := 'N';
    g_rec.crtd_flag := 'N';
    g_rec.tmprl_flag := 'N';
    g_rec.dltd_flag := 'N';
    g_rec.open_and_clsd_flag := 'N';
    g_rec.not_crtd_flag := 'N';
    g_rec.clsd_flag := 'N';
    g_rec.stl_actv_flag := 'Y';
    g_rec.clpsd_flag := 'N';
    g_rec.clsn_flag := 'N';
    g_rec.no_effect_flag := 'N';
    g_rec.cvrge_rt_prem_flag := 'N';
    g_rec.business_group_id := p_business_group_id;
    g_rec.effective_date := p_effective_date;
    --
    benutils.write(p_rec => g_rec);
    --
    -- For BENAUTHE retreival purpose.
    fnd_message.set_name('BEN','BEN_92864_CWB_PTNL_AFTR_ACTIVE');
    fnd_message.set_token('PTNL_LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
    fnd_message.set_token('ACTIVE_LF_EVT_OCRD_DT',
                           l_pil_rec.lf_evt_ocrd_dt);
    raise ben_manage_life_events.g_life_event_after;
    --
    --
  end if;
  --
  hr_utility.set_location('Leaving cwb_eval_ptnl_per_for_ler',10);
  --
end cwb_eval_ptnl_per_for_ler;
--
-- GRADE/STEP : process the grade/step potential life events.
--
-- ----------------------------------------------------------------------------
-- |------------------------< grd_stp_eval_ptnl_per_for_ler >-----------------|
-- ----------------------------------------------------------------------------
--
procedure grd_stp_eval_ptnl_per_for_ler(p_validate in boolean default false
                               ,p_person_id in number
                               ,p_business_group_id in number
                               ,p_ler_id in number default null
                               ,p_mode in varchar2
                               ,p_effective_date in date
                               ,p_created_ler_id out NOCOPY number
                               ,p_lf_evt_oper_cd in varchar2 default null) is    /* GSP Rate Sync*/
  --
  l_proc varchar2(72) := g_package||'grd_stp_eval_ptnl_per_for_ler';
  --
  cursor get_all_potential is
    select ler.ovridg_le_flag,
           pfl.ler_id,
           pfl.ptnl_ler_for_per_id,
           pfl.lf_evt_ocrd_dt,
           pfl.object_version_number,
           ler.ler_eval_rl,
           pfl.creation_date,
           pfl.ptnl_ler_for_per_stat_cd,
           pfl.ntfn_dt,
           pfl.dtctd_dt,
           pfl.voidd_dt,
           ler.name,
           pfl.person_id,
           pfl.business_group_id
    from   ben_ptnl_ler_for_per pfl,
           ben_ler_f ler
    where  pfl.ptnl_ler_for_per_stat_cd not in ('VOIDD','PROCD')
    and    pfl.person_id = p_person_id
    and    pfl.ler_id = ler.ler_id
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    pfl.lf_evt_ocrd_dt <= p_effective_date
    and    pfl.ler_id <> ben_manage_life_events.g_ler_id
    and    ler.typ_cd = 'GSP'
    order  by pfl.lf_evt_ocrd_dt asc;
  --
  -- GSP Rate Sync
  -- Before we process GSP Rate Sync, ensure that one GSP Progression has been processed
  -- for the person in the past
  cursor c_gsp_prog_procd_exists is
  select null
    from ben_per_in_ler pil, ben_ler_f ler
   where pil.person_id = p_person_id
     and pil.ler_id = ler.ler_id
     and p_effective_date between ler.effective_start_date and ler.effective_end_date
     and ler.typ_cd = 'GSP';
  --
  cursor get_gs_proc_strt_le(p_lf_evt_ocrd_dt date) is
    select pil.*
    from   ben_per_in_ler pil,
           ben_ler_f      ler
    where  pil.person_id = p_person_id
    and    (pil.per_in_ler_stat_cd = 'STRTD'
            or
            (pil.per_in_ler_stat_cd = 'PROCD'
             and    pil.lf_evt_ocrd_dt >= p_lf_evt_ocrd_dt)
           )
    and    pil.ler_id <> ben_manage_life_events.g_ler_id
    and    pil.ler_id = ler.ler_id
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    ler.typ_cd = 'GSP'
    order by per_in_ler_stat_cd desc, lf_evt_ocrd_dt desc;
  --
  l_ptnl_rec                ben_ptnl_ler_for_per%rowtype;
  l_potent                  get_all_potential%rowtype;
  l_min_ptnl                get_all_potential%rowtype;
  l_recs_found              boolean := false;
  l_pil_rec                 ben_per_in_ler%rowtype;
  l_curr_per_in_ler_id      number;
  l_procd_dt                date;
  l_strtd_dt                date;
  l_voidd_dt                date;
  l_object_version_number   number;
  l_dummy                   varchar2(1);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Step 1 : Find a potential life event with least lf_evt_ocrd_dt.
  -- Step 2 : Get a started or processed grade/step life event.
  --          If found log a message and skip processing of this person.
  -- Step 3 : If there is a processed grade step life event then log
  --          message : "Process this person manually; as grade step
  --          completed previously". Skip processing this person.
  -- Step 4 : Winner is the potential with least lf_evt_ocrd_dt
  --
  open get_all_potential;
    --
    loop
      --
      fetch get_all_potential into l_potent;
      exit when get_all_potential%notfound;
      --
      if l_min_ptnl.lf_evt_ocrd_dt is null then
         --
         l_min_ptnl := l_potent;
         --
      end if;
      --
      l_recs_found := true;
      --
      if l_potent.ptnl_ler_for_per_stat_cd = 'MNL' then
        --
        -- Need to comeup with new messages???? 99999
        fnd_message.set_name('BEN','BEN_92396_LIFE_EVENT_MANUAL');
        fnd_message.set_token('LE_NAME',l_potent.name);
        fnd_message.set_token('PROC',l_proc);
        benutils.write(p_text => fnd_message.get);
        -- For BENAUTHE retreival purpose.
        fnd_message.set_name('BEN','BEN_92396_LIFE_EVENT_MANUAL');
        fnd_message.set_token('LE_NAME',l_potent.name);
        fnd_message.set_token('PROC',l_proc);
        raise ben_manage_life_events.g_life_event_after;
        --
      end if;
      --
    end loop;
    --
  close get_all_potential;
  --
  -- Step 2
  --
  --
  -- Test for no potentials found error
  --
  if not l_recs_found then
    --
    -- We don't want to add to the error count so lets just process the next
    -- person. The life event could be strtd or procd we don't care.
    --
    fnd_message.set_name('BEN','BEN_92536_PERSON_HAS_NO_PPL');
    fnd_message.set_token('PERSON_ID',p_person_id);
    fnd_message.set_token('PROC',l_proc);
    benutils.write(fnd_message.get);
    --
    -- For BENAUTHE
    --
    fnd_message.set_name('BEN','BEN_92536_PERSON_HAS_NO_PPL');
    fnd_message.set_token('PERSON_ID',p_person_id);
    fnd_message.set_token('PROC',l_proc);
    raise ben_manage_life_events.g_life_event_after;
    --
  end if;
  --
  open get_gs_proc_strt_le(l_min_ptnl.lf_evt_ocrd_dt);
  fetch get_gs_proc_strt_le into l_pil_rec;
  close get_gs_proc_strt_le;
  --
  if l_pil_rec.per_in_ler_stat_cd = 'STRTD' then
    --
    -- Potential is after per in ler so leave ptnl as is
    --
    fnd_message.set_name('BEN','BEN_91797_PTNL_AFTER_ACTIVE');
    fnd_message.set_token('PTNL_LF_EVT_OCRD_DT',l_min_ptnl.lf_evt_ocrd_dt);
    fnd_message.set_token('ACTIVE_LF_EVT_OCRD_DT',
                           l_pil_rec.lf_evt_ocrd_dt);
    benutils.write(p_text => fnd_message.get);
    --
    g_rec.person_id := p_person_id;
    g_rec.ler_id := l_min_ptnl.ler_id;
    g_rec.lf_evt_ocrd_dt := l_min_ptnl.lf_evt_ocrd_dt;
    g_rec.replcd_flag := 'N';
    g_rec.crtd_flag := 'N';
    g_rec.tmprl_flag := 'N';
    g_rec.dltd_flag := 'N';
    g_rec.open_and_clsd_flag := 'N';
    g_rec.not_crtd_flag := 'N';
    g_rec.clsd_flag := 'N';
    g_rec.stl_actv_flag := 'Y';
    g_rec.clpsd_flag := 'N';
    g_rec.clsn_flag := 'N';
    g_rec.no_effect_flag := 'N';
    g_rec.cvrge_rt_prem_flag := 'N';
    g_rec.business_group_id := p_business_group_id;
    g_rec.effective_date := p_effective_date;
    --
    benutils.write(p_rec => g_rec);
    --
    -- For BENAUTHE retreival purpose.
    fnd_message.set_name('BEN','BEN_91797_PTNL_AFTER_ACTIVE');
    fnd_message.set_token('PTNL_LF_EVT_OCRD_DT',l_min_ptnl.lf_evt_ocrd_dt);
    fnd_message.set_token('ACTIVE_LF_EVT_OCRD_DT',
                           l_pil_rec.lf_evt_ocrd_dt);
    raise ben_manage_life_events.g_life_event_after;
    --
  elsif l_pil_rec.per_in_ler_stat_cd = 'PROCD' then
    --
    -- 99999 check the messages above and here.
    --
    -- Potential is after per in ler so leave ptnl as is
    --
    fnd_message.set_name('BEN','BEN_94092_PTNL_BEFORE_PROCD');
    fnd_message.set_token('PTNL_LF_EVT_OCRD_DT',l_min_ptnl.lf_evt_ocrd_dt);
    fnd_message.set_token('ACTIVE_LF_EVT_OCRD_DT',
                           l_pil_rec.lf_evt_ocrd_dt);
    benutils.write(p_text => fnd_message.get);
    --
    g_rec.person_id := p_person_id;
    g_rec.ler_id := l_min_ptnl.ler_id;
    g_rec.lf_evt_ocrd_dt := l_min_ptnl.lf_evt_ocrd_dt;
    g_rec.replcd_flag := 'N';
    g_rec.crtd_flag := 'N';
    g_rec.tmprl_flag := 'N';
    g_rec.dltd_flag := 'N';
    g_rec.open_and_clsd_flag := 'N';
    g_rec.not_crtd_flag := 'N';
    g_rec.clsd_flag := 'N';
    g_rec.stl_actv_flag := 'Y';
    g_rec.clpsd_flag := 'N';
    g_rec.clsn_flag := 'N';
    g_rec.no_effect_flag := 'N';
    g_rec.cvrge_rt_prem_flag := 'N';
    g_rec.business_group_id := p_business_group_id;
    g_rec.effective_date := p_effective_date;
    --
    benutils.write(p_rec => g_rec);
    --
    -- For BENAUTHE retreival purpose.
    fnd_message.set_name('BEN','BEN_94092_PTNL_BEFORE_PROCD');
    fnd_message.set_token('PTNL_LF_EVT_OCRD_DT',l_min_ptnl.lf_evt_ocrd_dt);
    fnd_message.set_token('ACTIVE_LF_EVT_OCRD_DT',l_pil_rec.lf_evt_ocrd_dt);
    raise ben_manage_life_events.g_life_event_after;
    --
  else
    --
    -- GSP Rate Sync
    if p_lf_evt_oper_cd = 'SYNC'
    then
      --
      open c_gsp_prog_procd_exists;
        --
        fetch c_gsp_prog_procd_exists into l_dummy;
        if c_gsp_prog_procd_exists%notfound
        then
          --
          -- GSP Rate Sync is being processed for a person who is never processed for GSP Prog in the past
          close c_gsp_prog_procd_exists;
          hr_utility.set_location('GSP Rate Sync processed withouth GSP Prog', 9);
          --
          fnd_message.set_name('BEN','BEN_94091_NO_GSP_PROG_PROCD');
          benutils.write(fnd_message.get);
          --
          fnd_message.set_name('BEN','BEN_94091_NO_GSP_PROG_PROCD');
          raise ben_manage_life_events.g_life_event_after;
          --
        end if;
        --
      close c_gsp_prog_procd_exists;
      --
    end if;
    -- GSP Rate Sync

    -- insert ptnl
    --
    -- l_created_ler := 'Y';
    p_created_ler_id := l_min_ptnl.ler_id;
    --
    ben_Person_Life_Event_api.create_Person_Life_Event_perf
    (p_validate                => false
    ,p_per_in_ler_id           => l_curr_per_in_ler_id
    ,p_ler_id                  => l_min_ptnl.ler_id
    ,p_person_id               => l_min_ptnl.person_id
    ,p_per_in_ler_stat_cd      => 'STRTD'
    ,p_ptnl_ler_for_per_id     => l_min_ptnl.ptnl_ler_for_per_id
    ,p_lf_evt_ocrd_dt          => l_min_ptnl.lf_evt_ocrd_dt
    ,p_business_group_id       => l_min_ptnl.business_group_id
    ,p_ntfn_dt                 => l_min_ptnl.ntfn_dt
    ,p_object_version_number   => l_object_version_number
    ,p_effective_date          => p_effective_date
    ,p_program_application_id  => fnd_global.prog_appl_id
    ,p_program_id              => fnd_global.conc_program_id
    ,p_request_id              => fnd_global.conc_request_id
    ,p_program_update_date     => sysdate
    ,p_procd_dt                => l_procd_dt
    ,p_strtd_dt                => l_strtd_dt
    ,p_voidd_dt                => l_voidd_dt);
    --
    g_rec.person_id := p_person_id;
    g_rec.ler_id := l_min_ptnl.ler_id;
    g_rec.lf_evt_ocrd_dt := l_min_ptnl.lf_evt_ocrd_dt;
    g_rec.replcd_flag := 'N';
    g_rec.crtd_flag := 'Y';
    g_rec.tmprl_flag := 'N';
    g_rec.dltd_flag := 'N';
    g_rec.open_and_clsd_flag := 'N';
    g_rec.not_crtd_flag := 'N';
    g_rec.clsd_flag := 'N';
    g_rec.stl_actv_flag := 'N';
    g_rec.clpsd_flag := 'N';
    g_rec.clsn_flag := 'N';
    g_rec.no_effect_flag := 'N';
    g_rec.cvrge_rt_prem_flag := 'N';
    g_rec.business_group_id := p_business_group_id;
    g_rec.effective_date := p_effective_date;
    g_rec.per_in_ler_id := l_curr_per_in_ler_id;
    --
    benutils.write(p_rec => g_rec);
    --
    -- update ptnl
    --
    ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
    (p_validate                 => false
    ,p_ptnl_ler_for_per_id      => l_min_ptnl.ptnl_ler_for_per_id
    ,p_lf_evt_ocrd_dt           => l_min_ptnl.lf_evt_ocrd_dt
    ,p_ptnl_ler_for_per_stat_cd => 'PROCD'
    ,p_procd_dt                 => p_effective_date
    ,p_ler_id                   => l_min_ptnl.ler_id
    ,p_person_id                => l_min_ptnl.person_id
    ,p_business_group_id        => l_min_ptnl.business_group_id
    ,p_object_version_number    => l_min_ptnl.object_version_number
    ,p_effective_date           => p_effective_date
    ,p_program_application_id   => fnd_global.prog_appl_id
    ,p_program_id               => fnd_global.conc_program_id
    ,p_request_id               => fnd_global.conc_request_id
    ,p_program_update_date      => sysdate);
    --
  end if;
  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end grd_stp_eval_ptnl_per_for_ler;
--
-- ----------------------------------------------------------------------------
-- |------------------------< eval_ptnl_per_for_ler >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure eval_ptnl_per_for_ler(p_validate in boolean default false
                               ,p_person_id in number
                               ,p_business_group_id in number
                               ,p_ler_id in number default null
                               ,p_mode in varchar2
                               ,p_effective_date in date
                               ,p_created_ler_id out NOCOPY number) is

  --
  l_min_lf_evt_ocrd_dt date := null;
  --
  cursor get_all_potential is
    select ler.ovridg_le_flag,
           pfl.ler_id,
           pfl.ptnl_ler_for_per_id,
           pfl.lf_evt_ocrd_dt,
           pfl.object_version_number,
           ler.ler_eval_rl,
           pfl.creation_date,
           pfl.ptnl_ler_for_per_stat_cd,
           pfl.ntfn_dt,
           pfl.dtctd_dt,
           pfl.voidd_dt,
           ler.name
    from   ben_ptnl_ler_for_per pfl,
           ben_ler_f ler
    where  pfl.ptnl_ler_for_per_stat_cd not in ('VOIDD','PROCD')
    and    pfl.person_id = p_person_id
    and    pfl.ler_id = ler.ler_id
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    pfl.lf_evt_ocrd_dt <= decode(p_mode,
                                        'C',
                                        pfl.lf_evt_ocrd_dt,
                                        p_effective_date)
    and    pfl.ler_id <> ben_manage_life_events.g_ler_id
    --
    -- CWB Changes
    --
    and    ler.typ_cd not in ( 'COMP', 'ABS', 'GSP', 'IREC') -- iRec
    order  by pfl.lf_evt_ocrd_dt asc;
  --
  l_ptnl_rec ben_ptnl_ler_for_per%rowtype;
  --
  l_pil_rec ben_per_in_ler%rowtype;
  --
  -- Bug 3179 :  pil processed or started and a ptnl is created on the
  -- same day. Processed or started pil is not gatting backed out.
  --
  cursor get_all_per_in_ler(p_lf_evt_ocrd_dt date, p_curr_per_in_ler_id number) is
    select pil.*
    from   ben_per_in_ler pil,
           ben_ler_f      ler
    where  pil.person_id = p_person_id
    and    pil.per_in_ler_stat_cd in ('STRTD','PROCD')
    and    pil.lf_evt_ocrd_dt >= p_lf_evt_ocrd_dt
    and    pil.per_in_ler_id <> p_curr_per_in_ler_id
    and    pil.ler_id <> ben_manage_life_events.g_ler_id
    --
    -- CWB Changes
    --
    and    pil.ler_id = ler.ler_id
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    ler.typ_cd not in ( 'COMP', 'ABS', 'GSP', 'IREC') --iRec
    --
    -- CWB Changes End
    --
    order by lf_evt_ocrd_dt desc;
  --
  -- Added as part of Bug : 3078
  -- Get earliest per in ler whether its processed or started
  --
  --
  -- CWB Changes : Cusrsor modified.
  --
  cursor get_current_per_in_ler(cv_lf_evt_ocrd_dt in date) is
    select pil.per_in_ler_id,
           pil.per_in_ler_stat_cd,
           pil.lf_evt_ocrd_dt,
           pil.ler_id,
           pil.person_id,
           pil.business_group_id,
           pil.object_version_number,
           pil.procd_dt,
           pil.strtd_dt,
           pil.voidd_dt,
           pil.bckt_dt,
           pil.clsd_dt,
           pil.ntfn_dt
    from   ben_per_in_ler  pil,
           ben_ler_f      ler
    where  pil.person_id = p_person_id
    and    pil.per_in_ler_stat_cd = 'STRTD'
    and    pil.ler_id <> ben_manage_life_events.g_ler_id
    and    pil.ler_id = ler.ler_id
    and    cv_lf_evt_ocrd_dt
           between ler.effective_start_date
           and     ler.effective_end_date
    and    ler.typ_cd not in ( 'COMP', 'ABS', 'GSP', 'IREC') --iRec
    union
    select pil.per_in_ler_id,
           pil.per_in_ler_stat_cd,
           pil.lf_evt_ocrd_dt,
           pil.ler_id,
           pil.person_id,
           pil.business_group_id,
           pil.object_version_number,
           pil.procd_dt,
           pil.strtd_dt,
           pil.voidd_dt,
           pil.bckt_dt,
           pil.clsd_dt,
           pil.ntfn_dt
    from   ben_per_in_ler pil,
           ben_ler_f      ler
    where  pil.person_id = p_person_id
    and    pil.per_in_ler_stat_cd = 'PROCD'
    and    pil.lf_evt_ocrd_dt >= cv_lf_evt_ocrd_dt
    and    pil.ler_id <> ben_manage_life_events.g_ler_id
    and    pil.ler_id = ler.ler_id
    -- GRADE/STEP
    and    ler.typ_cd not in ( 'COMP', 'ABS', 'GSP', 'IREC')-- iRec
    and    cv_lf_evt_ocrd_dt
           between ler.effective_start_date
           and     ler.effective_end_date
    order  by 3 asc;
  --
  -- CWB Changes End
  --
  --
  -- Bug 3179 : pbodla
  --
  --
  -- CWB Changes : Cursor joined to ben_ler_f
  --
  cursor c_check_deadlock_pil(cv_lf_evt_ocrd_dt in date) is
    select pil.per_in_ler_id,
           pil.per_in_ler_stat_cd,
           pil.lf_evt_ocrd_dt,
           pil.ler_id,
           pil.person_id,
           pil.business_group_id,
           pil.object_version_number,
           pil.procd_dt,
           pil.strtd_dt,
           pil.voidd_dt,
           pil.bckt_dt,
           pil.clsd_dt,
           pil.ntfn_dt
    from   ben_per_in_ler pil,
           ben_ler_f      ler
    where  pil.person_id = p_person_id
    and    pil.per_in_ler_stat_cd in ( 'PROCD', 'STRTD')
    and    pil.ler_id <> ben_manage_life_events.g_ler_id
    and    pil.lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt
    and    pil.ler_id = ler.ler_id
    and    cv_lf_evt_ocrd_dt
           between ler.effective_start_date
           and     ler.effective_end_date
    and    ler.typ_cd not in ( 'COMP', 'ABS', 'GSP', 'IREC');--iRec
  --
  -- CWB Changes End
  --
  --
  l_deadlock_per_in_ler     get_current_per_in_ler%rowtype;
  l_current_per_in_ler      get_current_per_in_ler%rowtype;
  l_curr_per_in_ler_id      number;
  l_ovridg_le_flag          BEN_LER_F.OVRIDG_LE_FLAG%TYPE;
  l_ptnl_ler_for_per_id     BEN_PTNL_LER_FOR_PER.PTNL_LER_FOR_PER_ID%TYPE;
  l_lf_evt_ocrd_dt          BEN_PTNL_LER_FOR_PER.LF_EVT_OCRD_DT%TYPE;
  l_creation_date           BEN_PTNL_LER_FOR_PER.CREATION_DATE%TYPE;
  l_ntfn_dt                 BEN_PTNL_LER_FOR_PER.NTFN_DT%TYPE;
  l_win_ler_id              BEN_LER_F.LER_ID%TYPE;
  l_norm_ler_id             BEN_LER_F.LER_ID%TYPE;
  l_ler_id                  BEN_LER_F.LER_ID%TYPE;
  l_ler_typ_cd              BEN_LER_F.TYP_CD%TYPE;
  l_tmlns_eval_cd           BEN_LER_F.tmlns_eval_cd%type;
  l_tmlns_dys_num           BEN_LER_F.tmlns_dys_num%type;
  l_tmlns_perd_cd           BEN_LER_F.tmlns_perd_cd%type;
  l_tmlns_perd_rl           BEN_LER_F.tmlns_perd_rl%type;
  l_min_tmlns_eval_cd       BEN_LER_F.tmlns_eval_cd%type;
  l_min_tmlns_dys_num       BEN_LER_F.tmlns_dys_num%type;
  l_min_tmlns_perd_cd       BEN_LER_F.tmlns_perd_cd%type;
  l_min_tmlns_perd_rl       BEN_LER_F.tmlns_perd_rl%type;
  l_min_creation_date       BEN_PTNL_LER_FOR_PER.creation_date%type;
  l_object_version_number   BEN_PTNL_LER_FOR_PER.OBJECT_VERSION_NUMBER%TYPE;
  l_proc                    varchar2(72) := g_package||'eval_ptnl_per_for_ler';
  l_created_ler             varchar(2) := 'N';
  l_dummy                   varchar2(1);
  l_num_winners             number := 0;
  l_num_recs                number := 0;
  l_outputs                 ff_exec.outputs_t;
  l_return_ler_id           number;
  l_min_ptnl_ler_for_per_id number;
  l_min_object_version_number number;
  l_rec                       benutils.g_ler;
  l_active_ler_rec            benutils.g_ler;
  l_second_ler_rec            benutils.g_ler;
  l_potent                  get_all_potential%rowtype;
  l_mnl_dt date;
  l_dtctd_dt   date;
  l_procd_dt   date;
  l_unprocd_dt date;
  l_voidd_dt   date;
  l_recs_found boolean := false;

 --Start 6086392
     l_bckdt_pil_indx BINARY_INTEGER;
     l_bckdt_pil_count BINARY_INTEGER;
     l_date      date;
     l_pil_object_version_number BEN_PER_IN_LER.OBJECT_VERSION_NUMBER%TYPE;
  --End 6086392


   -- bug
   CURSOR c_pil_ovn (cv_per_in_ler_id IN NUMBER)
   IS
      SELECT object_version_number
        FROM ben_per_in_ler
       WHERE per_in_ler_id = cv_per_in_ler_id;

   pil_ovn_rec   c_pil_ovn%ROWTYPE;
	 -- end bug


  --
  -- Bug 4872042
  --
  cursor c_winner_ler_typ_cd (cv_ler_id number)
  is
     select typ_cd, name
       from ben_ler_f ler
      where ler_id = cv_ler_id;
  --
  l_typ_cd         VARCHAR2(30);
  l_use_mode       VARCHAR2(30);
  l_ler_name       VARCHAR2(240);
  --
  l_mnl_savepoint_established boolean := false;
  l_mnl_savepoint_preestablish boolean := false;

--
/*
-- ----------------------------------------------------------------------------
-- |------------------------< update_ptnl_per_for_ler >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ptnl_per_for_ler
   (p_ptnl_rec       IN OUT NOCOPY BEN_PTNL_LER_FOR_PER%ROWTYPE
   ,p_effective_date IN DATE) is
  --
  l_proc varchar2(72) := g_package||'update_ptnl_per_for_ler';
  --
  l_mnl_dt date;
  l_dtctd_dt   date;
  l_procd_dt   date;
  l_unprocd_dt date;
  l_voidd_dt   date;
  --
begin
  --
  l_procd_dt := trunc(sysdate);
  --
  ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
    (p_validate                 => false
    ,p_ptnl_ler_for_per_id      => p_ptnl_rec.ptnl_ler_for_per_id
    ,p_lf_evt_ocrd_dt           => p_ptnl_rec.lf_evt_ocrd_dt
    ,p_ptnl_ler_for_per_stat_cd => 'PROCD'
    ,p_procd_dt                 => p_effective_date
    ,p_ler_id                   => p_ptnl_rec.ler_id
    ,p_person_id                => p_ptnl_rec.person_id
    ,p_business_group_id        => p_ptnl_rec.business_group_id
    ,p_object_version_number    => p_ptnl_rec.object_version_number
    ,p_effective_date           => p_effective_date
    ,p_program_application_id   => fnd_global.prog_appl_id
    ,p_program_id               => fnd_global.conc_program_id
    ,p_request_id               => fnd_global.conc_request_id
    ,p_program_update_date      => sysdate);
  --
end update_ptnl_per_for_ler;
*/
-- ------------------------------------------------------------------------
-- |------------------------< insert_per_in_ler >-------------------------|
-- ------------------------------------------------------------------------
procedure insert_per_in_ler
                   (p_ptnl_rec           IN out NOCOPY BEN_PTNL_LER_FOR_PER%ROWTYPE
                   ,p_curr_per_in_ler_id out NOCOPY number
                   ,p_effective_date     IN     DATE) is
  --
  l_per_in_ler_id              NUMBER;
  l_object_version_number      NUMBER;
  l_rslt_object_version_number NUMBER;
  l_proc                       varchar2(72) := g_package||'insert_per_in_ler';
  l_assignment_id              number;
  l_perhasmultptus             boolean;
  l_ler_rec                    ben_ler_f%rowtype;
  l_procd_dt                   date;
  l_strtd_dt                   date;
  l_voidd_dt                   date;
  l_effective_start_date       date;
  l_effective_end_date         date;
  l_effective_date             date;
  --
begin
  ben_Person_Life_Event_api.create_Person_Life_Event_perf
    (p_validate                => false
    ,p_per_in_ler_id           => p_curr_per_in_ler_id
    ,p_ler_id                  => p_ptnl_rec.ler_id
    ,p_person_id               => p_ptnl_rec.person_id
    ,p_per_in_ler_stat_cd      => 'STRTD'
    ,p_ptnl_ler_for_per_id     => p_ptnl_rec.ptnl_ler_for_per_id
    ,p_lf_evt_ocrd_dt          => p_ptnl_rec.lf_evt_ocrd_dt
    ,p_business_group_id       => p_ptnl_rec.business_group_id
    ,p_ntfn_dt                 => p_ptnl_rec.ntfn_dt
    ,p_object_version_number   => l_object_version_number
    ,p_effective_date          => p_effective_date
    ,p_program_application_id  => fnd_global.prog_appl_id
    ,p_program_id              => fnd_global.conc_program_id
    ,p_request_id              => fnd_global.conc_request_id
    ,p_program_update_date     => sysdate
    ,p_procd_dt                => l_procd_dt
    ,p_strtd_dt                => l_strtd_dt
    ,p_voidd_dt                => l_voidd_dt);
  --
  --  If life event is reduction in hours, create benefit
  --  assignment for all personal contacts.
  --
  ben_life_object.get_object(p_ler_id => p_ptnl_rec.ler_id,
                             p_rec    => l_ler_rec);
  --
  if l_ler_rec.typ_cd = 'REDUHRS' then
    --
    -- Create benefits assignment for dependent - COBRA requirement.
    --
    ben_assignment_internal.copy_empasg_to_benasg
      (p_person_id             => p_ptnl_rec.person_id
      ,p_redu_hrs_flag         => 'Y'
      ,p_effective_date        => p_ptnl_rec.lf_evt_ocrd_dt
      ,p_assignment_id         => l_assignment_id
      ,p_object_version_number => l_object_version_number
      ,p_perhasmultptus        => l_perhasmultptus);
    --
  end if;
  --
end insert_per_in_ler;
--
procedure check_for_timeliness
    (p_person_id             in number,
     p_effective_date        in date,
     p_mode                  in varchar2,
     p_business_group_id     in number) is
  --
  l_proc                 varchar2(72) := g_package||'check_for_timeliness';
  l_effective_start_date date;
  l_effective_end_date   date;
  l_outputs              ff_exec.outputs_t;
  --
  l_ass_rec per_all_assignments_f%rowtype;
  l_loc_rec hr_locations_all%rowtype;
  l_jurisdiction_code varchar2(30);
  --
  --bug 1579642 added ptn.mnlo_dt is null in the where clause.
  --not to select the records which are having a date in
  --mnlo_dt column for timeliness information to handle the
  --case where evaluation rule is used along with timeliness.
  cursor c1 is
    select ptn.creation_date,
           ptn.ntfn_dt,
           ler.tmlns_eval_cd,
           ler.tmlns_perd_cd,
           ler.tmlns_dys_num,
           ler.tmlns_perd_rl,
           ler.name,
           ptn.lf_evt_ocrd_dt,
           ptn.ptnl_ler_for_per_id,
           ptn.ler_id,
           ptn.object_version_number
    from   ben_ptnl_ler_for_per ptn,
           ben_ler_f ler
    where  ler.ler_id = ptn.ler_id
    and    ler.business_group_id  = p_business_group_id
    and    ptn.ptnl_ler_for_per_stat_cd not in ('PROCD','VOIDD', 'MNLO')
    and    ptn.mnlo_dt is null  -- to fix the bug 1579642
    and    ptn.lf_evt_ocrd_dt  --p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    ptn.business_group_id  = ler.business_group_id
    and    ptn.person_id = p_person_id
    and    ptn.ler_id <> ben_manage_life_events.g_ler_id
    -- CWB Changes
    and    ler.typ_cd not in ( 'COMP', 'ABS', 'GSP','IREC') --iRec
    and    ptn.lf_evt_ocrd_dt <= decode(ler.typ_cd,        --Bug 5703825
                                        'SCHEDDO',
                                        ptn.lf_evt_ocrd_dt,
					'SCHEDDA',
                                        ptn.lf_evt_ocrd_dt,
                                        p_effective_date);
  --
  l_potent          c1%rowtype;
  l_mnl_dt          date;
  l_dtctd_dt        date;
  l_procd_dt        date;
  l_unprocd_dt      date;
  l_voidd_dt        date;
  l_action_happened boolean := false;
  --
  -- Keep count of potentials which are not in ('PROCD','VOIDD')
  -- Keep count of potentials which are currently voided.
  -- These counts are used to determine whether all potentials
  -- are voided. This condition check is added to display more
  -- appropriate message when benmngle is called on line.
  --
  l_npv_ptnl_cnt        number := 0;
  l_curr_voidd_ptnl_cnt number := 0;
  -- 6129827 Added these 2 variables
  l_mnl_ptnl_cnt        number := 0;
  l_mnl_ler_name        ben_ler_f.name%type;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Rules
  --
  -- 1) if tmlns_eval_cd is null then
  --      do nothing
  -- 2) if tmlns_eval_cd = 'VOID' then
  --      if tmlns_dys_num is null and
  --        tmlns_perd_cd is null then
  --        do nothing
  --      elsif tmlns_dys_num is not null then
  --        if (p_ntfn_dt - lf_evt_ocrd_dt) > tmlns_dys_num then
  --          set event to voided
  --        else
  --          do nothing
  --        end if
  --      end if
  --      if no action has happened and
  --        tmlns_perd_cd is not null then
  --        if tmlns_perd_cd = 'PTCCY' then
  --          if lf_evt_ocrd_dt is before current year then
  --            set event to voided
  --          else
  --            do nothing
  --          end if
  --        elsif tmlns_perd_cd = 'RL' then
  --          if tmlns_perd_rl is not null then
  --            if rule evaluates to Y then
  --              set event to voided
  --            else
  --              do nothing
  --            end if
  --          else
  --            do nothing
  --          end if
  --        end if
  --      end if
  --    elsif tmlns_eval_cd = 'PRCM' then
  --      if tmlns_dys_num is null and
  --        tmlns_perd_cd is null then
  --        do nothing
  --      elsif tmlns_dys_num is not null then
  --        if (p_ntfn_dt - lf_evt_ocrd_dt) > tmlns_dys_num then
  --          leave event as is
  --        else
  --          do nothing
  --        end if
  --      end if
  --      if no action has happened and
  --        tmlns_perd_cd is not null then
  --        if tmlns_perd_cd = 'PTCCY' then
  --          if lf_evt_ocrd_dt is before current year then
  --            leave event as is
  --          else
  --            do nothing
  --          end if
  --        elsif tmlns_perd_cd = 'RL' then
  --          if tmlns_perd_rl is not null then
  --            if rule evaluates to Y then
  --              leave event as is
  --            else
  --              do nothing
  --            end if
  --          else
  --            do nothing
  --          end if
  --        end if
  --      end if
  --    end if
  --
  open c1;
    --
    loop
      --
      fetch c1 into l_potent;
      exit when c1%notfound;
      --
      hr_utility.set_location(' tmlns_eval_cd  '|| l_potent.tmlns_eval_cd , 10);
      hr_utility.set_location(' tmlns_perd_cd  '|| l_potent.tmlns_perd_cd , 10);
      --
      l_npv_ptnl_cnt    := l_npv_ptnl_cnt + 1; --added during iRec
      l_action_happened := false;
      --
      if l_potent.tmlns_eval_cd is null then
        --
        -- No timeliness to consider
        --
         if l_mnl_savepoint_preestablish  then
          l_mnl_savepoint_established := true;
          savepoint ptnl_set_to_manual_savepoint;
        end if;
        null;
        --
      elsif l_potent.tmlns_eval_cd = 'VOID' then
        --
        if l_potent.tmlns_dys_num is not null then
          --
          -- Note use of absolute so that future events work
          --
          if abs((l_potent.ntfn_dt - l_potent.lf_evt_ocrd_dt)) >
              l_potent.tmlns_dys_num then
            --
            -- We need to void the event and raise a message informing the user
            -- that the event has been voided
            --
            l_action_happened := true;
            --
            ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
              (p_validate                 => false
              ,p_ptnl_ler_for_per_id      => l_potent.ptnl_ler_for_per_id
              ,p_ptnl_ler_for_per_stat_cd => 'VOIDD'
              ,p_object_version_number    => l_potent.object_version_number
              ,p_effective_date           => p_effective_date
              ,p_program_application_id   => fnd_global.prog_appl_id
              ,p_program_id               => fnd_global.conc_program_id
              ,p_request_id               => fnd_global.conc_request_id
              ,p_program_update_date      => sysdate
              ,p_voidd_dt                 => p_effective_date);
            --
            l_curr_voidd_ptnl_cnt := l_curr_voidd_ptnl_cnt + 1;-- added during iRec
            fnd_message.set_name('BEN','BEN_92098_LIFE_EVENT_VOIDED');
            fnd_message.set_token('LF_EVT',l_potent.name);
            fnd_message.set_token('LF_EVT_OCRD_DT',l_potent.lf_evt_ocrd_dt);
            benutils.write(p_text => fnd_message.get);
            --
            g_rec.person_id := p_person_id;
            g_rec.ler_id := l_potent.ler_id;
            g_rec.lf_evt_ocrd_dt := l_potent.lf_evt_ocrd_dt;
            g_rec.replcd_flag := 'N';
            g_rec.crtd_flag := 'N';
            g_rec.tmprl_flag := 'N';
            g_rec.dltd_flag := 'N';
            g_rec.open_and_clsd_flag := 'N';
            g_rec.not_crtd_flag := 'Y';
            g_rec.clsd_flag := 'N';
            g_rec.stl_actv_flag := 'N';
            g_rec.clpsd_flag := 'N';
            g_rec.clsn_flag := 'N';
            g_rec.no_effect_flag := 'N';
            g_rec.cvrge_rt_prem_flag := 'N';
            g_rec.business_group_id := p_business_group_id;
            g_rec.effective_date := p_effective_date;
            --
            benutils.write(p_rec => g_rec);
            --
          end if;
          --
        end if;
        --
        if not l_action_happened and
          l_potent.tmlns_perd_cd is not null then
          --
          if l_potent.tmlns_perd_cd = 'PTCCY' then
            --
            -- Note use of absolute so that future events work
            --
            if abs(to_number(to_char(l_potent.ntfn_dt,'YYYY')) -
               to_number(to_char(l_potent.lf_evt_ocrd_dt,'YYYY'))) >= 1 then
              --
              -- We need to void the event and raise a message informing
              -- the user that the event has been voided
              --
              ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
                (p_validate                 => false
                ,p_ptnl_ler_for_per_id      => l_potent.ptnl_ler_for_per_id
                ,p_ptnl_ler_for_per_stat_cd => 'VOIDD'
                ,p_object_version_number    => l_potent.object_version_number
                ,p_effective_date           => p_effective_date
                ,p_program_application_id   => fnd_global.prog_appl_id
                ,p_program_id               => fnd_global.conc_program_id
                ,p_request_id               => fnd_global.conc_request_id
                ,p_program_update_date      => sysdate
                ,p_voidd_dt                 => p_effective_date);
              --
              l_curr_voidd_ptnl_cnt := l_curr_voidd_ptnl_cnt + 1;-- + added during iREC
              fnd_message.set_name('BEN','BEN_92098_LIFE_EVENT_VOIDED');
              fnd_message.set_token('LF_EVT',l_potent.name);
              fnd_message.set_token('LF_EVT_OCRD_DT',l_potent.lf_evt_ocrd_dt);
              benutils.write(p_text => fnd_message.get);
              --
              g_rec.person_id := p_person_id;
              g_rec.ler_id := l_potent.ler_id;
              g_rec.lf_evt_ocrd_dt := l_potent.lf_evt_ocrd_dt;
              g_rec.replcd_flag := 'N';
              g_rec.crtd_flag := 'N';
              g_rec.tmprl_flag := 'N';
              g_rec.dltd_flag := 'N';
              g_rec.open_and_clsd_flag := 'N';
              g_rec.not_crtd_flag := 'Y';
              g_rec.clsd_flag := 'N';
              g_rec.stl_actv_flag := 'N';
              g_rec.clpsd_flag := 'N';
              g_rec.clsn_flag := 'N';
              g_rec.no_effect_flag := 'N';
              g_rec.cvrge_rt_prem_flag := 'N';
              g_rec.business_group_id := p_business_group_id;
              g_rec.effective_date := p_effective_date;
              --
              benutils.write(p_rec => g_rec);
              --
            end if;
            --
          elsif l_potent.tmlns_perd_cd = 'RL' then
            --
            if l_potent.tmlns_perd_rl is not null then
              --
              ben_person_object.get_object(p_person_id => p_person_id,
                                           p_rec       => l_ass_rec);
              --
              if l_ass_rec.assignment_id is null then
                --
                ben_person_object.get_benass_object(p_person_id => p_person_id,
                                                    p_rec       => l_ass_rec);
                --
              end if;
              --
              if l_ass_rec.location_id is not null then
                --
                ben_location_object.get_object
                  (p_location_id => l_ass_rec.location_id,
                   p_rec         => l_loc_rec);
                --
   --             if l_loc_rec.region_2 is not null then
                  --
   --               l_jurisdiction_code :=
   --                 pay_mag_utils.lookup_jurisdiction_code
   --                   (p_state => l_loc_rec.region_2);
                  --
   --             end if;
                --
              end if;
              --
              l_outputs := benutils.formula
                (p_formula_id       => l_potent.tmlns_perd_rl,
                 p_effective_date   => p_effective_date,
                 p_ler_id           => l_potent.ler_id,
                 p_assignment_id    => l_ass_rec.assignment_id,
                 p_organization_id  => l_ass_rec.organization_id,
                 p_business_group_id=> p_business_group_id,
                 p_jurisdiction_code=> l_jurisdiction_code);
              --
              if l_outputs(l_outputs.first).value = 'Y' then
                --
                -- We need to void the event and raise a message informing
                -- the user that the event has been voided
                --
                ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
                  (p_validate                 => false
                  ,p_ptnl_ler_for_per_id      => l_potent.ptnl_ler_for_per_id
                  ,p_ptnl_ler_for_per_stat_cd => 'VOIDD'
                  ,p_object_version_number    => l_potent.object_version_number
                  ,p_effective_date           => p_effective_date
                  ,p_program_application_id   => fnd_global.prog_appl_id
                  ,p_program_id               => fnd_global.conc_program_id
                  ,p_request_id               => fnd_global.conc_request_id
                  ,p_program_update_date      => sysdate
                  ,p_voidd_dt                 => p_effective_date);
                --
                l_curr_voidd_ptnl_cnt := l_curr_voidd_ptnl_cnt + 1;
                fnd_message.set_name('BEN','BEN_92098_LIFE_EVENT_VOIDED');
                fnd_message.set_token('LF_EVT',l_potent.name);
                fnd_message.set_token('LF_EVT_OCRD_DT',l_potent.lf_evt_ocrd_dt);
                benutils.write(p_text => fnd_message.get);
                --
                g_rec.person_id := p_person_id;
                g_rec.ler_id := l_potent.ler_id;
                g_rec.lf_evt_ocrd_dt := l_potent.lf_evt_ocrd_dt;
                g_rec.replcd_flag := 'N';
                g_rec.crtd_flag := 'N';
                g_rec.tmprl_flag := 'N';
                g_rec.dltd_flag := 'N';
                g_rec.open_and_clsd_flag := 'N';
                g_rec.not_crtd_flag := 'Y';
                g_rec.clsd_flag := 'N';
                g_rec.stl_actv_flag := 'N';
                g_rec.clpsd_flag := 'N';
                g_rec.clsn_flag := 'N';
                g_rec.no_effect_flag := 'N';
                g_rec.cvrge_rt_prem_flag := 'N';
                g_rec.business_group_id := p_business_group_id;
                g_rec.effective_date := p_effective_date;
                --
                benutils.write(p_rec => g_rec);
                --
              elsif l_outputs(l_outputs.first).value <> 'N' then
                --
                fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
                fnd_message.set_token('RL',
                                    'tmlns_perd_rl :'||l_potent.tmlns_perd_rl);
                fnd_message.set_token('PROC',l_proc);
                raise ben_manage_life_events.g_record_error;
                --
              end if;
              --
            end if;
            --
          end if;
          --
        end if;
        --
      elsif l_potent.tmlns_eval_cd = 'PRCM' then
        --
        if l_potent.tmlns_dys_num is not null then
          --
          -- Note use of absolute to get value
          --
          if abs((l_potent.ntfn_dt - l_potent.lf_evt_ocrd_dt))
            > l_potent.tmlns_dys_num then
            --
            l_action_happened := true;
            --
            ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
              (p_validate                 => false
              ,p_ptnl_ler_for_per_id      => l_potent.ptnl_ler_for_per_id
              ,p_ptnl_ler_for_per_stat_cd => 'MNL'
              ,p_object_version_number    => l_potent.object_version_number
              ,p_effective_date           => p_effective_date
              ,p_program_application_id   => fnd_global.prog_appl_id
              ,p_program_id               => fnd_global.conc_program_id
              ,p_request_id               => fnd_global.conc_request_id
              ,p_program_update_date      => sysdate
              ,p_mnl_dt                   => p_effective_date);
            --
            l_mnl_ptnl_cnt := l_mnl_ptnl_cnt + 1;
            l_mnl_ler_name := l_potent.name;
            --
          end if;
          --
        end if;
        --
        if not l_action_happened and
          l_potent.tmlns_perd_cd is not null then
          --
          if l_potent.tmlns_perd_cd = 'PTCCY' then
            --
            -- Note use of absolute to get value
            --
            if abs(to_number(to_char(l_potent.ntfn_dt,'YYYY')) -
               to_number(to_char(l_potent.lf_evt_ocrd_dt,'YYYY'))) >= 1 then
              --
              ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
                (p_validate                 => false
                ,p_ptnl_ler_for_per_id      => l_potent.ptnl_ler_for_per_id
                ,p_ptnl_ler_for_per_stat_cd => 'MNL'
                ,p_object_version_number    => l_potent.object_version_number
                ,p_effective_date           => p_effective_date
                ,p_program_application_id   => fnd_global.prog_appl_id
                ,p_program_id               => fnd_global.conc_program_id
                ,p_request_id               => fnd_global.conc_request_id
                ,p_program_update_date      => sysdate
                ,p_mnl_dt                   => p_effective_date);
              --
              l_mnl_ptnl_cnt := l_mnl_ptnl_cnt + 1;
              l_mnl_ler_name := l_potent.name;
              --
            end if;
            --
          elsif l_potent.tmlns_perd_cd = 'RL' then
            --
            if l_potent.tmlns_perd_rl is not null then
              --
              ben_person_object.get_object(p_person_id => p_person_id,
                                           p_rec       => l_ass_rec);
              --
              if l_ass_rec.assignment_id is null then
                --
                ben_person_object.get_benass_object(p_person_id => p_person_id,
                                                    p_rec       => l_ass_rec);
                --
              end if;
              --
              if l_ass_rec.location_id is not null then
                --
                ben_location_object.get_object
                   (p_location_id => l_ass_rec.location_id,
                    p_rec         => l_loc_rec);
                --
       --         if l_loc_rec.region_2 is not null then
                  --
       --           l_jurisdiction_code :=
       --             pay_mag_utils.lookup_jurisdiction_code
       --               (p_state => l_loc_rec.region_2);
                  --
       --         end if;
                --
              end if;
              --
              l_outputs := benutils.formula
                (p_formula_id       => l_potent.tmlns_perd_rl,
                 p_effective_date   => p_effective_date,
                 p_ler_id           => l_potent.ler_id,
                 p_assignment_id    => l_ass_rec.assignment_id,
                 p_organization_id  => l_ass_rec.organization_id,
                 p_business_group_id=> p_business_group_id,
                 p_jurisdiction_code=> l_jurisdiction_code);
              --
              if l_outputs(l_outputs.first).value = 'Y' then
                --
                -- We need to void the event and raise a message informing
                -- the user that the event has been voided
                -- Bug 4217795 set status to manual
                --
                ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
                  (p_validate                 => false
                  ,p_ptnl_ler_for_per_id      => l_potent.ptnl_ler_for_per_id
                  ,p_ptnl_ler_for_per_stat_cd => 'MNL'
                  ,p_object_version_number    => l_potent.object_version_number
                  ,p_effective_date           => p_effective_date
                  ,p_program_application_id   => fnd_global.prog_appl_id
                  ,p_program_id               => fnd_global.conc_program_id
                  ,p_request_id               => fnd_global.conc_request_id
                  ,p_program_update_date      => sysdate
                  ,p_mnl_dt                   => p_effective_date);
                  --
                  l_mnl_ptnl_cnt := l_mnl_ptnl_cnt + 1;
                  l_mnl_ler_name := l_potent.name;
                  --
                --
                /* Bug 4217795
                l_curr_voidd_ptnl_cnt := l_curr_voidd_ptnl_cnt + 1; -- + added during irec
                fnd_message.set_name('BEN','BEN_92098_LIFE_EVENT_VOIDED');
                fnd_message.set_token('LF_EVT',l_potent.name);
                fnd_message.set_token('LF_EVT_OCRD_DT',l_potent.lf_evt_ocrd_dt);
                benutils.write(p_text => fnd_message.get);
                --
                g_rec.person_id := p_person_id;
                g_rec.ler_id := p_ler_id;
                g_rec.lf_evt_ocrd_dt := l_potent.lf_evt_ocrd_dt;
                g_rec.replcd_flag := 'N';
                g_rec.crtd_flag := 'N';
                g_rec.tmprl_flag := 'N';
                g_rec.dltd_flag := 'N';
                g_rec.open_and_clsd_flag := 'N';
                g_rec.not_crtd_flag := 'Y';
                g_rec.clsd_flag := 'N';
                g_rec.stl_actv_flag := 'N';
                g_rec.clpsd_flag := 'N';
                g_rec.clsn_flag := 'N';
                g_rec.no_effect_flag := 'N';
                g_rec.cvrge_rt_prem_flag := 'N';
                g_rec.business_group_id := p_business_group_id;
                g_rec.effective_date := p_effective_date;
                --
                benutils.write(p_rec => g_rec);
                --
                */
              elsif l_outputs(l_outputs.first).value = 'N' then
                --
                null;
                --
              elsif l_outputs(l_outputs.first).value <> 'N' then
                --
                fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
                fnd_message.set_token('RL',
                                  'tmlns_perd_rl :'||l_potent.tmlns_perd_rl);
                fnd_message.set_token('PROC',l_proc);
                raise ben_manage_life_events.g_record_error;
                --
              end if;
              --
            end if;
            --
          end if;
          --
        end if;
        --
      end if;
      --
    end loop;
    --
  close c1;
  --
  hr_utility.set_location(' l_npv_ptnl_cnt  '|| l_npv_ptnl_cnt , 10);
  hr_utility.set_location(' l_curr_voidd_ptnl_cnt  '|| l_curr_voidd_ptnl_cnt , 10);
  hr_utility.set_location(' l_mnl_ptnl_cnt  '|| l_mnl_ptnl_cnt , 10);
  hr_utility.set_location(' l_mnl_ler_name  '|| l_mnl_ler_name , 10);
  --
  -- 6245213 : Set savepoint. This is rolled back, if reqd, in check_and_get_winner.
  if (l_mnl_ptnl_cnt > 0) and not l_mnl_savepoint_established  then
    l_mnl_savepoint_established := true;
    savepoint ptnl_set_to_manual_savepoint;
  end if;
  --
  -- Check if all the potetial's are made VOIDD
  --
  if l_npv_ptnl_cnt <> 0 and
     l_curr_voidd_ptnl_cnt = l_npv_ptnl_cnt then
     --
     fnd_message.set_name('BEN','BEN_92400_ALL_PTNL_VOIDD');
     benutils.write(p_text => fnd_message.get);
     --
     -- Mark a global indicating some of the potentials are
     -- made voidd. This flag is used by benptnle to display
     -- a message back to the user.
     --
     ben_on_line_lf_evt.g_ptnls_voidd_flag := TRUE;
     --
     raise ben_manage_life_events.g_life_event_after;
     --
  elsif l_npv_ptnl_cnt <> 0 and l_curr_voidd_ptnl_cnt <> 0 and
    l_curr_voidd_ptnl_cnt <> l_npv_ptnl_cnt then
     --
     -- Mark a global indicating some of the potentials are
     -- made voidd. This flag is used by benptnle to display
     -- a message back to the user.
     --
     ben_on_line_lf_evt.g_ptnls_voidd_flag := TRUE;
     --
  end if;
  --
  -- 6129827 : If timeliness sets all potentials to Manual/Voided
  -- then exit immediately.
  if (l_npv_ptnl_cnt <> 0) and (l_npv_ptnl_cnt = l_mnl_ptnl_cnt + l_curr_voidd_ptnl_cnt) then
    --
    fnd_message.set_name('BEN','BEN_92396_LIFE_EVENT_MANUAL');
    fnd_message.set_token('LE_NAME',l_mnl_ler_name);
    fnd_message.set_token('PROC',l_proc);
    benutils.write(p_text => fnd_message.get);
    --
    fnd_message.set_name('BEN','BEN_92396_LIFE_EVENT_MANUAL');
    fnd_message.set_token('LE_NAME',l_mnl_ler_name);
    fnd_message.set_token('PROC',l_proc);
    raise ben_manage_life_events.g_life_event_after;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end check_for_timeliness;
--
function rule_evaluates
  (p_ler_id                   in number,
   p_person_id                in number,
   p_business_group_id        in number,
   p_ptnl_ler_for_per_id      in number,
   p_ptnl_ler_for_per_stat_cd in varchar2,
   p_ntfn_dt                  in date,
   p_dtctd_dt                 in date,
   p_voidd_dt                 in date,
   p_object_version_number    in number,
   p_rule_id                  in number,
   p_lf_evt_ocrd_dt           in date,
   p_effective_date           in date) return varchar2 is
  --
  l_proc                     varchar2(72) := g_package||'rule_evaluates';
  l_outputs                  ff_exec.outputs_t;
  l_happened                 varchar2(30) := 'UNSET';
  l_ler_id                   number := p_ler_id;
  l_object_version_number    number;
  l_ptnl_ler_for_per_id      number;
  l_lf_evt_ocrd_dt           date := p_lf_evt_ocrd_dt;
  l_ntfn_dt                  date := p_ntfn_dt;
  l_dtctd_dt                 date := p_dtctd_dt;
  l_voidd_dt                 date := p_voidd_dt;
  l_ptnl_ler_for_per_stat_cd varchar2(30) := p_ptnl_ler_for_per_stat_cd;
  l_ptnl_ler_for_per_stat_cd_use varchar2(30);
  l_procd_dt   date;
  l_unprocd_dt date;
  l_mnl_dt date;
  --
  l_ass_rec per_all_assignments_f%rowtype;
  l_loc_rec hr_locations_all%rowtype;
  l_jurisdiction_code varchar2(30);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- If no rule then return a Y else lets check the rule
  --
  if p_rule_id is null then
    --
    return 'Y';
    --
  else
    --
    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_ass_rec);
    --
    if l_ass_rec.assignment_id is null then
      --
      ben_person_object.get_benass_object(p_person_id => p_person_id,
                                          p_rec       => l_ass_rec);
      --
    end if;
    --
    if l_ass_rec.location_id is not null then
      --
      ben_location_object.get_object(p_location_id => l_ass_rec.location_id,
                                     p_rec         => l_loc_rec);
      --
 --     if l_loc_rec.region_2 is not null then
        --
 --       l_jurisdiction_code :=
 --         pay_mag_utils.lookup_jurisdiction_code
 --         (p_state => l_loc_rec.region_2);
        --
 --     end if;
      --
    end if;
    --
    l_outputs := benutils.formula
      (p_formula_id       => p_rule_id,
       p_effective_date   => p_effective_date,
       p_ler_id           => p_ler_id,
       p_assignment_id    => l_ass_rec.assignment_id,
       p_organization_id  => l_ass_rec.organization_id,
       p_business_group_id=> p_business_group_id,
       --
       -- Bug 1844764
       -- Pass the primary key and lf event occured dt to access
       -- potential data.
       --
       p_param1           => 'BEN_PPL_IV_PTNL_LER_FOR_PER_ID',
       p_param1_value     => to_char(p_ptnl_ler_for_per_id),
       p_param2           => 'BEN_PPL_IV_LF_EVT_OCRD_DT',
       p_param2_value     => to_char(p_lf_evt_ocrd_dt, 'YYYY/MM/DD HH24:MI:SS'),
       p_param3           => 'BEN_PPL_IV_PTNL_LER_FOR_PER_STAT_CD',
       p_param3_value     => p_ptnl_ler_for_per_stat_cd,
       p_param4           => 'BEN_PPL_IV_NTFN_DT',
       p_param4_value     => to_char(p_ntfn_dt, 'YYYY/MM/DD HH24:MI:SS'),
       p_param5           => 'BEN_PPL_IV_DTCTD_DT',
       p_param5_value     => to_char(p_dtctd_dt, 'YYYY/MM/DD HH24:MI:SS'),
       p_jurisdiction_code=> l_jurisdiction_code);
    --
    -- Loop through the returned table and make sure that the returned
    -- values have been found
    --
    for l_count in l_outputs.first..l_outputs.last loop
      --
      begin
        --
        if l_outputs(l_count).name = 'LIFE_EVENT_OCCURRED_DATE' then
          --
          l_lf_evt_ocrd_dt := fnd_date.canonical_to_date
                              (l_outputs(l_count).value);
          --
        elsif l_outputs(l_count).name = 'LIFE_EVENT_HAPPENED' then
          --
          l_happened := l_outputs(l_count).value;
          --
        elsif l_outputs(l_count).name = 'LIFE_EVENT_REASON_ID' then
          --
          l_ler_id := l_outputs(l_count).value;
          --
        elsif l_outputs(l_count).name = 'LIFE_EVENT_NOTIFICATION_DATE' then
          --
          l_ntfn_dt := fnd_date.canonical_to_date
                       (l_outputs(l_count).value);
          --
        elsif l_outputs(l_count).name = 'LIFE_EVENT_DETECTED_DATE' then
          --
          l_dtctd_dt := fnd_date.canonical_to_date
                        (l_outputs(l_count).value);
          --
        elsif l_outputs(l_count).name = 'LIFE_EVENT_VOIDED_DATE' then
          --
          l_voidd_dt := fnd_date.canonical_to_date
                        (l_outputs(l_count).value);
       elsif l_outputs(l_count).name = 'LIFE_EVENT_MANUAL_DATE' then
          --
          l_mnl_dt := fnd_date.canonical_to_date
                        (l_outputs(l_count).value);
          --
        elsif l_outputs(l_count).name = 'LIFE_EVENT_STATUS_CODE' then
          --
          l_ptnl_ler_for_per_stat_cd := l_outputs(l_count).value;
          --
        else
          --
          -- Account for cases where formula returns an unknown
          -- variable name
          --
          fnd_message.set_name('BEN','BEN_92310_FORMULA_RET_PARAM');
          fnd_message.set_token('PROC',l_proc);
          fnd_message.set_token('FORMULA',p_rule_id);
          fnd_message.set_token('PARAMETER',l_outputs(l_count).name);
          fnd_message.raise_error;
          --
        end if;
       if (l_mnl_dt is not null or
           (l_ptnl_ler_for_per_stat_cd is not null and l_ptnl_ler_for_per_stat_cd  = 'MNL')) then
          l_mnl_savepoint_preestablish := true;
        --  savepoint ptnl_set_to_manual_savepoint;
       end if;

        --
        -- Code for type casting errors from formula return variables
        --
      exception
        --
        when others then
          --
          fnd_message.set_name('BEN','BEN_92311_FORMULA_VAL_PARAM');
          fnd_message.set_token('PROC',l_proc);
          fnd_message.set_token('FORMULA',p_rule_id);
          fnd_message.set_token('PARAMETER',l_outputs(l_count).name);
          fnd_message.raise_error;
        --
      end;
      --
    end loop;
    --
    -- hr_utility.set_location('life_event_happened '||l_happened , 15);
    -- hr_utility.set_location('life_event_status_code '||l_ptnl_ler_for_per_stat_cd, 15);
    --
    if l_happened not in ('Y','N') then
      --
      fnd_message.set_name('BEN','BEN_92143_LIFE_EVENT_HAPPENED');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.raise_error;
      --
    end if;
    --
    if l_happened = 'Y' then
      --
      -- hr_utility.set_location('Step 1 ' ,190);
      if p_ler_id <> l_ler_id or
        p_lf_evt_ocrd_dt <> l_lf_evt_ocrd_dt or
        nvl(p_ntfn_dt,hr_api.g_date) <> nvl(l_ntfn_dt,hr_api.g_date) or
        nvl(p_dtctd_dt,hr_api.g_date) <> nvl(l_dtctd_dt,hr_api.g_date) or
        nvl(p_voidd_dt,hr_api.g_date) <> nvl(l_voidd_dt,hr_api.g_date) or
        p_ptnl_ler_for_per_stat_cd <> l_ptnl_ler_for_per_stat_cd then
        --
        -- Sanity check, they may have updated the voidd_dt but forgot to
        -- set the ptnl_ler_for_per_stat_cd so we set it for them
        --
        -- hr_utility.set_location('Step 2 ' ,191);
        if l_voidd_dt is not null and
          l_ptnl_ler_for_per_stat_cd <> 'VOIDD' then
          --
          l_ptnl_ler_for_per_stat_cd := 'VOIDD';
          --
          -- In this case we have to force the rule to think that the rule
          -- did not happen as we want the event to be voided but we also
          -- want to update certain columns.
          --
          l_happened := 'N';
          --hr_utility.set_location(' In the didnot happened case ', 15);
          --
        end if;
        --
        -- We may have had a different life event reason returned in which
        -- case we need to void the old life event and create a new ptnl
        -- life event. In this case carry out the void with the old values
        -- and create the new with the new returned values from the
        -- formula. In this case the event happened.
        --
        -- hr_utility.set_location('Step 3 ' ,193);
        if l_ler_id <> p_ler_id then

          -- Test for valid l_ptnl_ler_for_per_stat_cd
          if l_ptnl_ler_for_per_stat_cd not in ('DTCTD','MNL','UNPROCD') then
            -- hr_utility.set_location('Invalid stat code returned from rule.',10);
            fnd_message.set_name('BEN','BEN_92162_INV_PPL_STCD_TRANS');
            fnd_message.raise_error;
          end if;

          --
          -- First lets create the new ptnl ler for per
          --
          -- If the fast formula rule returned anything other than 'DTCTD',
          -- create the new potential life event with a status of 'UNPROCD'.

          if l_ptnl_ler_for_per_stat_cd = 'DTCTD' then
            l_ptnl_ler_for_per_stat_cd_use := 'DTCTD';
          else
            l_ptnl_ler_for_per_stat_cd_use := 'UNPROCD';
            -- hr_utility.set_location('Step 4 ' ,194);
          end if;
          --hr_utility.set_location(' r_per_stat_cd  '||l_ptnl_ler_for_per_stat_cd, 17);
          if l_ptnl_ler_for_per_stat_cd = 'MNL' then
            l_unprocd_dt := l_mnl_dt;
          else
            l_unprocd_dt := sysdate;
          end if;

          --
          ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per_perf
           (p_validate                 => false,
            p_ptnl_ler_for_per_id      => l_ptnl_ler_for_per_id,
            p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt,
            p_ptnl_ler_for_per_stat_cd => l_ptnl_ler_for_per_stat_cd_use,
            p_ler_id                   => l_ler_id,
            p_person_id                => p_person_id,
            p_ntfn_dt                  => l_ntfn_dt,
            p_unprocd_dt               => l_unprocd_dt,
            p_dtctd_dt                 => l_dtctd_dt,
            p_business_group_id        => p_business_group_id,
            p_object_version_number    => l_object_version_number,
            p_effective_date           => p_effective_date,
            p_program_application_id   => fnd_global.prog_appl_id,
            p_program_id               => fnd_global.conc_program_id,
            p_request_id               => fnd_global.conc_request_id,
            p_program_update_date      => sysdate);
          --
          -- hr_utility.set_location('Step 5 ' ,195);
          if l_ptnl_ler_for_per_stat_cd = 'MNL' then
            ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
             (p_ptnl_ler_for_per_id      => l_ptnl_ler_for_per_id,
              p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt,
              p_ler_id                   => l_ler_id,
              p_ntfn_dt                  => l_ntfn_dt,
              p_dtctd_dt                 => l_dtctd_dt,
              p_voidd_dt                 => l_voidd_dt,
              p_ptnl_ler_for_per_stat_cd => l_ptnl_ler_for_per_stat_cd,
              p_object_version_number    => l_object_version_number,
              p_effective_date           => p_effective_date,
              p_mnl_dt                   => l_mnl_dt,
              p_procd_dt                 => l_procd_dt,
              p_unprocd_dt               => l_unprocd_dt);
          end if;
           --hr_utility.set_location('Step 6 ' ,196);
          l_happened := 'Y';
          --
          -- Make sure that when we update the ptnl ler for per that the
          -- voided date and stat code are set correctly.
          --
          l_ptnl_ler_for_per_stat_cd := 'VOIDD';
          l_voidd_dt := nvl(l_voidd_dt,sysdate);
          l_unprocd_dt := NULL;
          l_dtctd_dt := NULL;
          l_mnl_dt := NULL;
          --
        end if;
        --
        -- The rule has reset some values on the ptnl per for ler.
        -- We need to update the ben_ptnl_ler_for_per record in order
        -- to reflect the evaluated rule.
        --
        l_object_version_number := p_object_version_number;
        --
        ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
          (p_ptnl_ler_for_per_id      => p_ptnl_ler_for_per_id,
           p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt,
           p_ler_id                   => p_ler_id,
           p_ntfn_dt                  => l_ntfn_dt,
           p_dtctd_dt                 => l_dtctd_dt,
           p_voidd_dt                 => l_voidd_dt,
           p_ptnl_ler_for_per_stat_cd => l_ptnl_ler_for_per_stat_cd,
           p_object_version_number    => l_object_version_number,
           p_effective_date           => p_effective_date,
           p_mnl_dt                   => l_mnl_dt,
           p_procd_dt                 => l_procd_dt,
           p_unprocd_dt               => l_unprocd_dt);
         -- hr_utility.set_location('Step 7 ' ,197);
        --
      end if;
      --
      --hr_utility.set_location('Step 8 ' ,198);
    end if;
    --
    -- hr_utility.set_location('l_happened before return '||l_happened , 18 );
    return l_happened;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end rule_evaluates;
--
procedure check_and_get_winner
  (p_lf_evt_ocrd_dt    in date,
   p_person_id         in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_ptnl_rec          out NOCOPY ben_ptnl_ler_for_per%rowtype) is
  --
  l_proc                 varchar2(72) := g_package||'check_and_get_winner';
  l_num_recs             number := 0;
  l_num_winners          number := 0;
  --
  -- Bugs : 3179/3249 : Now consider processed potentials as well to
  -- look for the winner.
  --
  cursor c1 is
    select ler.ovridg_le_flag,
           ppl.ptnl_ler_for_per_id,
           ler.name
    from   ben_ptnl_ler_for_per ppl,
           ben_ler_f ler
    where  ppl.person_id = p_person_id
    and    ppl.ler_id = ler.ler_id
    and    ppl.business_group_id  = p_business_group_id
    and    ppl.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
    and    ler.business_group_id  = ppl.business_group_id
    and    ppl.ptnl_ler_for_per_stat_cd not in ('VOIDD')
    and    ppl.ler_id <> ben_manage_life_events.g_ler_id
    --
    -- CWB Changes
    --
    and    ler.typ_cd not in ( 'COMP', 'ABS', 'GSP', 'IREC') --iRec
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date;
  --
  l_ovridg_le_flag             varchar2(30);
  l_win_ler_name               ben_ler_f.name%TYPE; -- UTF8 varchar2(150);
  l_ler_name                   ben_ler_f.name%TYPE; -- UTF8 varchar2(150);
  l_ptnl_ler_for_per_id        number(15);
  l_win_ptnl_ler_for_per_id    number(15);
  l_search_ptnl_ler_for_per_id number(15);
  l_c1 c1%rowtype;
  --
  -- The following line is deleted from the where clause to
  --
  --   ****and    ppl.ptnl_ler_for_per_id <> l_search_ptnl_ler_for_per_id ****
  --
  -- as the check is made in the loop.
  --
  -- Bugs : 3179/3249 : Now consider processed potentials as well to
  -- back out them and set the potentials to unprocessed.
  -- Then loop around the potentials and void the ones which are not
  -- processed.
  --
  --
  -- CWB Changes : Cursor joined to ben_ler_f
  --
  cursor c_ptnl is
    select ppl.object_version_number,
           ppl.ptnl_ler_for_per_id
    from   ben_ptnl_ler_for_per ppl,
           ben_ler_f      ler
    where  ppl.person_id = p_person_id
    and    ppl.business_group_id  = p_business_group_id
    and    ppl.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
    and    ppl.ler_id <> ben_manage_life_events.g_ler_id
    and    ppl.ler_id = ler.ler_id
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    ler.typ_cd not in ( 'COMP', 'ABS', 'GSP', 'IREC') --iRec
    and    ppl.ptnl_ler_for_per_stat_cd not in ('VOIDD');
  --
  -- CWB Changes End
  --
  cursor c2 is
    select *
    from   ben_ptnl_ler_for_per ptn
    where  ptn.ptnl_ler_for_per_id = l_search_ptnl_ler_for_per_id;
  --
  -- Bug 1146792 (4285) : Modified check_and_get_winner -
  -- Back out the per in ler's before determining
  -- the winner.
  --
  -- CWB Changes : Cursor joined to ben_ler_f
  --
  cursor c_pils_to_backout is
    select pil.*
    from   ben_per_in_ler pil,
           ben_ler_f      ler
    where  pil.business_group_id = p_business_group_id
    and    pil.person_id = p_person_id
    and    (pil.lf_evt_ocrd_dt > p_lf_evt_ocrd_dt -- 5727737/5677090: Need to backout all Future LEs
           or (pil.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
              and pil.ler_id <> ben_manage_life_events.g_ler_id))
    and    pil.ler_id = ler.ler_id
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    ler.typ_cd not in ( 'COMP', 'ABS', 'GSP', 'IREC','SCHEDDU') --iRec
    and    pil.per_in_ler_stat_cd in ('STRTD','PROCD')
    ORDER BY pil.lf_evt_ocrd_dt DESC;
  --
  -- CWB Changes End
  --
  l_per_in_ler_id     number;
  --
  cursor c_ptnl_ovn(v_ptnl_ler_for_per_id number) is
    select ptnl.object_version_number
    from   ben_ptnl_ler_for_per ptnl
    where  ptnl.ptnl_ler_for_per_id = v_ptnl_ler_for_per_id
    and    ptnl.business_group_id   = p_business_group_id;
  --
  l_ptnl_ovn       number;
  --

begin
  --
  hr_utility.set_location('Entering: '|| l_proc, 10);
  --
  -- First back out any ptnls.
  --
  --
  -- Bug 1146792 (4285) : Modified check_and_get_winner -
  -- Back out the per in ler's before determining
  -- the winner.
  --
  -- Any processed or started life events on the same day have
  -- to be backed out prior to processing the winner.
  --
  for l_pil_rec in c_pils_to_backout loop
           --
           ben_back_out_life_event.back_out_life_events
             (p_per_in_ler_id         => l_pil_rec.per_in_ler_id,
              p_bckt_per_in_ler_id    => null,
              p_bckt_stat_cd          => 'UNPROCD',
              p_business_group_id     => p_business_group_id,
              p_effective_date        => p_effective_date);
           --

  --Start 6086392
             l_bckdt_pil_count := nvl(ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl.count(),0);
             l_bckdt_pil_count := l_bckdt_pil_count +1;
             ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl(l_bckdt_pil_count) := l_pil_rec.per_in_ler_id;
  --End 6086392

  end loop;
  --
  -- Lets loop through all the jobs that occured on the p_lf_evt_ocrd_dt and
  -- count the winners and the number of rec with the same date
  --
  open c1;
    --
    loop
      --
      fetch c1 into l_ovridg_le_flag,
                    l_ptnl_ler_for_per_id,
                    l_ler_name;
      exit when c1%notfound;
      --
      l_num_recs := l_num_recs + 1; -- '+1' added during irec
      --
      if l_ovridg_le_flag = 'Y' then
        --
        l_num_winners := l_num_winners + 1;-- '+' added during irec
        l_win_ptnl_ler_for_per_id := l_ptnl_ler_for_per_id;
        l_win_ler_name := l_win_ler_name;
        --
      end if;
      --
    end loop;
    --
  close c1;
  --
  -- Now lets check if we break any rules
  --
  if l_num_winners > 1 then
    --
    -- More than one winner so return an error
    --
    fnd_message.set_name('BEN','BEN_91794_DUP_WINNERS');
    ben_manage_life_events.g_rec.rep_typ_cd := 'ERROR';
    ben_manage_life_events.g_rec.person_id := p_person_id;
    ben_manage_life_events.g_rec.ler_id := null;
    ben_manage_life_events.g_rec.error_message_code := 'BEN_91794_DUP_WINNERS';
    ben_manage_life_events.g_rec.text := fnd_message.get;
    fnd_message.set_name('BEN','BEN_91794_DUP_WINNERS');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('PERSON_ID',p_person_id);
    fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
    raise ben_manage_life_events.g_record_error;
    --
    -- No winners, but more than one potential?
    --
  elsif l_num_winners = 0 and
    l_num_recs > 1 then
    --
    -- Potential life events clash, so error.
    --
    ben_manage_life_events.g_rec.rep_typ_cd := 'ERROR';
    ben_manage_life_events.g_rec.person_id := p_person_id;
    ben_manage_life_events.g_rec.ler_id := null;
    ben_manage_life_events.g_rec.error_message_code := 'BEN_92337_DUPLICATE_PTNL_LE';
    ben_manage_life_events.g_rec.text := fnd_message.get;
    fnd_message.set_name('BEN','BEN_92337_DUPLICATE_PTNL_LE');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('PERSON_ID',p_person_id);
    fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
    raise ben_manage_life_events.g_record_error;
    --
  elsif l_num_winners = 1 then
    --
    l_search_ptnl_ler_for_per_id := l_win_ptnl_ler_for_per_id;
    --
    -- Wining potential found but there are multiple potentials, so
    -- void the other potentials
    --
    if l_num_recs > 1 then
      --
      for l_ptnl in c_ptnl loop
        --
        if  l_ptnl.ptnl_ler_for_per_id <> l_search_ptnl_ler_for_per_id  then
           --
           -- Get the object_version_number as the life event might have
           -- been bolfied resulting in new object version number.
           --
           /*
           open  c_ptnl_ovn(l_ptnl.ptnl_ler_for_per_id);
           fetch c_ptnl_ovn into l_ptnl_ovn;
           close c_ptnl_ovn;
           */
           --
           ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
             (p_validate                 => false
             ,p_ptnl_ler_for_per_id      => l_ptnl.ptnl_ler_for_per_id
             ,p_ptnl_ler_for_per_stat_cd => 'VOIDD'
             ,p_object_version_number    => l_ptnl.object_version_number
             ,p_effective_date           => p_effective_date
             ,p_program_application_id   => fnd_global.prog_appl_id
             ,p_program_id               => fnd_global.conc_program_id
             ,p_request_id               => fnd_global.conc_request_id
             ,p_program_update_date      => sysdate
             ,p_voidd_dt                 => p_effective_date);
        --
        end if;
        --
      end loop;
      --
    end if;
    --
  elsif l_num_recs = 1 then
    --
    l_search_ptnl_ler_for_per_id := l_ptnl_ler_for_per_id;
    l_win_ler_name               := l_ler_name;
    --
  elsif l_num_recs = 0 then
    --
    fnd_message.set_name('BEN','BEN_92144_NO_LIFE_EVENTS');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('PERSON_ID',p_person_id);
    fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
    raise ben_manage_life_events.g_record_error;
    --
  end if;
  --
  open c2;
    --
    fetch c2 into p_ptnl_rec;
    --
    if p_ptnl_rec.ptnl_ler_for_per_stat_cd = 'MNL' then
      --
      close c2;
      --
      -- 6245213 : Rollback all backouts, since the LE is going to MANUAL.
      --
      if (l_mnl_savepoint_established) then
        hr_utility.set_location ('Going to Manual. Rollback all Backouts' ,100);
        rollback to ptnl_set_to_manual_savepoint;
        l_mnl_savepoint_established := false;
        l_mnl_savepoint_preestablish:=false;
      end if;
      ---
      fnd_message.set_name('BEN','BEN_92396_LIFE_EVENT_MANUAL');
      fnd_message.set_token('LE_NAME',l_win_ler_name);
      fnd_message.set_token('PROC',l_proc);
      benutils.write(p_text => fnd_message.get);
      -- For BENAUTHE retreival purpose.
      fnd_message.set_name('BEN','BEN_92396_LIFE_EVENT_MANUAL');
      fnd_message.set_token('LE_NAME',l_win_ler_name);
      fnd_message.set_token('PROC',l_proc);
      raise ben_manage_life_events.g_life_event_after;
      --
    end if;
    --
  close c2;
  --

  hr_utility.set_location('Lea   l_win_ler_name '||l_win_ler_name , 9.9);
  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end check_and_get_winner;
--
function get_earliest_potential(p_person_id         in number,
                                p_business_group_id in number,
                                p_mode              in varchar2,
                                p_effective_date    in date) return date is
  --
  l_proc                 varchar2(72) := g_package||'get_earliest_potential';
  --
  --
  -- CWB Changes : Cursor joined to ben_ler_f
  --
  cursor c1 is
    select min(ptn.lf_evt_ocrd_dt)
    from   ben_ptnl_ler_for_per ptn,
           ben_ler_f      ler
    where  ptn.person_id = p_person_id
    and    ptn.ler_id    = ler.ler_id
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    ler.typ_cd not in ( 'COMP', 'ABS', 'GSP', 'IREC') --iRec
    and    ptn.business_group_id = p_business_group_id
    and    ptn.lf_evt_ocrd_dt <= decode(ler.typ_cd,  --Bug 5703825
                                        'SCHEDDO',
					ptn.lf_evt_ocrd_dt,
					'SCHEDDA',
					ptn.lf_evt_ocrd_dt,
                                        p_effective_date)
    and    ptn.ler_id <> ben_manage_life_events.g_ler_id
    and    ptn.ptnl_ler_for_per_stat_cd not in ('PROCD','VOIDD');
  --
  -- CWB Changes End
  --
  l_min_lf_evt_ocrd_dt date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  open c1;
    --
    fetch c1 into l_min_lf_evt_ocrd_dt;
    --
    -- Remember the min function always returns a row so check if the result
    -- is null rather than c1%notfound.
    --
    if l_min_lf_evt_ocrd_dt is null then
      --
      close c1;
      fnd_message.set_name('BEN','BEN_92144_NO_LIFE_EVENTS');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('PERSON_ID',p_person_id);
      fnd_message.set_token('LF_EVT_OCRD_DT',l_min_lf_evt_ocrd_dt);
      benutils.write(p_text => fnd_message.get);
      -- For BENAUTHE retreival purpose.
      fnd_message.set_name('BEN','BEN_92144_NO_LIFE_EVENTS');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('PERSON_ID',p_person_id);
      fnd_message.set_token('LF_EVT_OCRD_DT',l_min_lf_evt_ocrd_dt);
      raise ben_manage_life_events.g_life_event_after;
      --
    end if;
    --
  close c1;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
  return l_min_lf_evt_ocrd_dt;
  --
end get_earliest_potential;
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --Start 6086392
  ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl.delete;
  --End 6086392

  --
  -- Operation Steps
  -- ===============
  -- 1) Get potential life events and active life event
  -- 2) If a rule is attached evaluate rule
  -- 3) If rule evaluates to N then void life event
  -- 4) If rule evaluates to Y then fine. Apply life event occured date and
  --    new life event reason if required.
  -- 5) Keep account of minimum life event occurred date of valid life events
  -- 6) Check each potential life event for timeliness and void if neccessary
  -- 7) Perform collapsing logic
  -- 8) Check for winners
  --
  open get_all_potential;
    --
    loop
      --
      fetch get_all_potential into l_potent;
      exit when get_all_potential%notfound;
      --
      l_recs_found := true;
      --
      -- Bug 1177226 : Any potential with manual hit then just
      -- stop the process.
      --
      if l_potent.ptnl_ler_for_per_stat_cd = 'MNL' then
        --
        fnd_message.set_name('BEN','BEN_94209_MAN_LER_EXISTIS');
        -- fnd_message.set_token('LE_NAME',l_potent.name);
        -- fnd_message.set_token('PROC',l_proc);
        benutils.write(p_text => fnd_message.get);
        -- For BENAUTHE retreival purpose.
        fnd_message.set_name('BEN','BEN_94209_MAN_LER_EXISTIS');
        -- fnd_message.set_token('LE_NAME',l_potent.name);
        -- fnd_message.set_token('PROC',l_proc);
        raise ben_manage_life_events.g_life_event_after;
        --
      end if;
      --
      -- If there is a rule attached lets evaluate it and handle the returned
      -- values.
      --
      hr_utility.set_location(l_potent.ler_eval_rl,10);
      if rule_evaluates
        (p_ler_id                   => l_potent.ler_id,
         p_person_id                => p_person_id,
         p_business_group_id        => p_business_group_id,
         p_ptnl_ler_for_per_id      => l_potent.ptnl_ler_for_per_id,
         p_ptnl_ler_for_per_stat_cd => l_potent.ptnl_ler_for_per_stat_cd,
         p_ntfn_dt                  => l_potent.ntfn_dt,
         p_dtctd_dt                 => l_potent.dtctd_dt,
         p_voidd_dt                 => l_potent.voidd_dt,
         p_object_version_number    => l_potent.object_version_number,
         p_lf_evt_ocrd_dt           => l_potent.lf_evt_ocrd_dt,
         p_rule_id                  => l_potent.ler_eval_rl,
         p_effective_date           => p_effective_date) <> 'Y' then
        --
        -- The life event didn't happen so void it
        --
        hr_utility.set_location('After call to rule_evaluates ',19);
        ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
          (p_ptnl_ler_for_per_id      => l_potent.ptnl_ler_for_per_id,
           p_object_version_number    => l_potent.object_version_number,
           p_ptnl_ler_for_per_stat_cd => 'VOIDD',
           p_effective_date           => p_effective_date,
           p_voidd_dt                 => p_effective_date);
        --
      end if;
      --
    end loop;
    --
  close get_all_potential;
  --
  -- Test for no potentials found error
  --
  if not l_recs_found then
    --
    -- Person already has a scheduled life event that has been run on this day
    -- We don't want to add to the error count so lets just process the next
    -- person. The life event could be strtd or procd we don't care.
    --
    fnd_message.set_name('BEN','BEN_92536_PERSON_HAS_NO_PPL');
    fnd_message.set_token('PERSON_ID',p_person_id);
    fnd_message.set_token('PROC',l_proc);
    benutils.write(fnd_message.get);
    --
    -- For BENAUTHE
    --
    fnd_message.set_name('BEN','BEN_92536_PERSON_HAS_NO_PPL');
    fnd_message.set_token('PERSON_ID',p_person_id);
    fnd_message.set_token('PROC',l_proc);
    raise ben_manage_life_events.g_life_event_after;
    --
  end if;
  --
  -- Now we have manipulated all potentials, check whether the remaining
  -- potentials fall within the timeliness
  --
  hr_utility.set_location('Before entering check_for_timeliness',90);
  --
  -- 6245213 : If Event goes to manual due to timeliness then
  -- set savepoint l_mnl_savepoint_established in the proc. check_for_timeliness
  -- and rollbck to savepoint in proc.check_and_get_winner
  --
  check_for_timeliness
    (p_person_id             => p_person_id,
     p_effective_date        => p_effective_date,
     p_mode                  => p_mode,
     p_business_group_id     => p_business_group_id);
  --
  hr_utility.set_location('After leaving check_for_timeliness',90);
  --
  -- Check we actually have potential life events and get the minimum life
  -- event occurred of the set of potential life events
  --
  l_min_lf_evt_ocrd_dt := get_earliest_potential
                          (p_person_id         => p_person_id,
                           p_business_group_id => p_business_group_id,
                           p_mode              => p_mode,
                           p_effective_date    => p_effective_date);
  --
  -- Do the collapse, Waaahoooo this is going to be good
  --
  ben_collapse_life_event.main
       (p_person_id          => p_person_id,
        p_business_group_id  => p_business_group_id,
        p_min_lf_evt_ocrd_dt => l_min_lf_evt_ocrd_dt,
        p_mode               => p_mode,
        p_effective_date     => p_effective_date);
  --
  -- We have to reget the min_lf_evt_ocrd_dt as a replace or void may have
  -- occurred and the minimum life event occurred date may be different to
  -- what it was prior to the calll.
  --
  l_min_lf_evt_ocrd_dt := get_earliest_potential
                          (p_person_id         => p_person_id,
                           p_business_group_id => p_business_group_id,
                           p_mode              => p_mode,
                           p_effective_date    => p_effective_date);
  --
  -- Check for potentials that existed on the same day or multiple winners
  -- If there are multiple winners then error
  -- If there are multiple potentials but one winner then delete potentials
  -- If there are multiple potentials but no winners then error
  --
  check_and_get_winner(p_lf_evt_ocrd_dt    => l_min_lf_evt_ocrd_dt,
                       p_person_id         => p_person_id,
                       p_business_group_id => p_business_group_id,
                       p_effective_date    => p_effective_date,
                       p_ptnl_rec          => l_ptnl_rec);
  --
  --
  -- Bug 4872042
  --
  open c_winner_ler_typ_cd (cv_ler_id => l_ptnl_rec.ler_id);
    fetch c_winner_ler_typ_cd into l_typ_cd, l_ler_name;
  close c_winner_ler_typ_cd;
  --
  -- Here we need to check if winner life event type and BENMNGLE mode are different
  -- If different => then commit the COLLAPSING LOGIC and exit the process so that user has
  -- to explicitly process the winner life event in appropriate mode
  --
  -- Similar check also exists in benmngle.pkb
  --
  if /*(p_mode = 'C' and l_typ_cd not like 'SCHEDD%') or --commented against bug 6806014 */
    --Bug 4872042
    (p_mode = 'L' and l_typ_cd in ('SCHEDDU','UNRSTR')) -- remove 'SCHEDDO'
  then
    --
    benutils.write(p_text => 'Winner Life Event : ' || l_ler_name || benutils.id(l_ptnl_rec.ler_id) ||
                             ', Supplied Mode : ' || p_mode);
    --
    if (l_typ_cd like 'SCHEDD%' or l_typ_cd = 'UNRSTR')
    then
       l_use_mode := 'Scheduled mode';
    else
       l_use_mode := 'Life event mode';
    end if;
    --
    if not p_validate
    then
      --
      commit;
      --
      savepoint process_life_event_savepoint;
      --
    end if;
    --
    fnd_message.set_name('BEN','BEN_92145_MODE_LE_DIFFER');
    fnd_message.set_token('MODE',l_use_mode);
    --
    raise ben_manage_life_events.g_record_error;
    --
  end if;
  --
  -- Bug 4872042
  --
  -- Lets do the backing out
  -- for the day of the minimum life event.
  --
  -- Get the current per in ler details so we decide whether to back out
  -- or whatever!
  --
  --
  -- Bug : 3078 (PBODLA)
  -- BENBOLFE currently only backs out closed person life events
  -- when there is a current started life event. BENBOLFE needs to
  -- backout all future life events.
  -- Due to above bug following two lines are commented and a local
  -- cursor is used to get pil's whose status is STRTD, PROCD
  --
  -- ben_person_object.get_object(p_person_id => p_person_id,
  --                              p_rec       => l_pil_rec);
  open get_current_per_in_ler(l_ptnl_rec.lf_evt_ocrd_dt);
    --
    fetch get_current_per_in_ler into l_current_per_in_ler;
    --
  close get_current_per_in_ler;
  --
  hr_utility.set_location('active LED '||l_current_per_in_ler.lf_evt_ocrd_dt,10);
  hr_utility.set_location('ptnl LED '||l_ptnl_rec.lf_evt_ocrd_dt,10);
  -- If no PER_IN_LER exists then we
  -- insert PTNL into PER_IN_LER
  -- update BEN_PTNL_LER_FOR_PER setting to processed
  --
  -- else
  -- We now we have the minimum PTNL PER_IN_LER
  -- and the date of the current PER in LER
  -- we should compare them and if the
  -- ptnl starts before the current
  -- we should delete the current and
  -- insert the ptnl into the PER_IN_LER table
  -- updating the current's old PTNL PER_FOR_LER
  -- record to be unprocessed.
  --
  --
  if l_current_per_in_ler.lf_evt_ocrd_dt is null then
    --
   hr_utility.set_location('A',10);
    -- insert ptnl
    --
    l_created_ler := 'Y';
    p_created_ler_id := l_ptnl_rec.ler_id;
    --
    insert_per_in_ler
      (p_ptnl_rec           => l_ptnl_rec
      ,p_curr_per_in_ler_id => l_curr_per_in_ler_id
      ,p_effective_date     => p_effective_date);
    --
    g_rec.person_id := p_person_id;
    g_rec.ler_id := l_ptnl_rec.ler_id;
    g_rec.lf_evt_ocrd_dt := l_ptnl_rec.lf_evt_ocrd_dt;
    g_rec.replcd_flag := 'N';
    g_rec.crtd_flag := 'Y';
    g_rec.tmprl_flag := 'N';
    g_rec.dltd_flag := 'N';
    g_rec.open_and_clsd_flag := 'N';
    g_rec.not_crtd_flag := 'N';
    g_rec.clsd_flag := 'N';
    g_rec.stl_actv_flag := 'N';
    g_rec.clpsd_flag := 'N';
    g_rec.clsn_flag := 'N';
    g_rec.no_effect_flag := 'N';
    g_rec.cvrge_rt_prem_flag := 'N';
    g_rec.business_group_id := p_business_group_id;
    g_rec.effective_date := p_effective_date;
    g_rec.per_in_ler_id := l_curr_per_in_ler_id;
    --
    benutils.write(p_rec => g_rec);
    --
    -- update ptnl
    --
    update_ptnl_per_for_ler
      (p_ptnl_rec       => l_ptnl_rec
      ,p_effective_date => p_effective_date);
    --
  elsif l_ptnl_rec.lf_evt_ocrd_dt <= l_current_per_in_ler.lf_evt_ocrd_dt then
    --
    -- Bug : 3179 : Check any dead lock situation.
    -- Any pil's which occured on same day.
    --
   hr_utility.set_location('B',10);
    open c_check_deadlock_pil(l_ptnl_rec.lf_evt_ocrd_dt);
      --
      fetch c_check_deadlock_pil into l_deadlock_per_in_ler;
      --
      -- Bug : 3179 : pbodla : See case desicription below.
      -- 1. Created New hire say on 10/14/1999
      -- 2. Processed the new hire on 10/14/1999
      -- 3. Now a marriage reported.
      -- 4. Marriage PIL is created.
      -- 5. When marriage is processed new hire is backed out.
      --    and associated potential is made unprocessed.
      -- 6. Again when new hire potential is processed it causes
      --    marriage to back out as they happened on same day.
      -- 7. It is dead lock situation.
      -- 8. WDS, Phil, Pbodla : Decision is to set the ptnl to
      --    to manual if there is a processed or started potential
      --    on same day.
      --
      if l_deadlock_per_in_ler.per_in_ler_id is not null then
        --
        ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
          (p_validate                 => false
          ,p_ptnl_ler_for_per_id      => l_ptnl_rec.ptnl_ler_for_per_id
          ,p_ptnl_ler_for_per_stat_cd => 'MNL'
          ,p_object_version_number    => l_ptnl_rec.object_version_number
          ,p_effective_date           => p_effective_date
          ,p_program_application_id   => fnd_global.prog_appl_id
          ,p_program_id               => fnd_global.conc_program_id
          ,p_request_id               => fnd_global.conc_request_id
          ,p_program_update_date      => sysdate
          ,p_mnl_dt                   => p_effective_date);
        --
        fnd_message.set_name('BEN','BEN_92396_LIFE_EVENT_MANUAL');
        fnd_message.set_token('LE_NAME',l_potent.name);
        fnd_message.set_token('PROC',l_proc);
        benutils.write(p_text => fnd_message.get);
        -- For BENAUTHE retreival purpose.
        fnd_message.set_name('BEN','BEN_92396_LIFE_EVENT_MANUAL');
        fnd_message.set_token('LE_NAME',l_potent.name);
        fnd_message.set_token('PROC',l_proc);
        g_rec.person_id := p_person_id;
        g_rec.ler_id := l_ptnl_rec.ler_id;
        g_rec.lf_evt_ocrd_dt := l_ptnl_rec.lf_evt_ocrd_dt;
        g_rec.replcd_flag := 'N';
        g_rec.crtd_flag := 'N';
        g_rec.tmprl_flag := 'N';
        g_rec.dltd_flag := 'N';
        g_rec.open_and_clsd_flag := 'N';
        g_rec.not_crtd_flag := 'N';
        g_rec.clsd_flag := 'N';
        g_rec.stl_actv_flag := 'N';
        g_rec.clpsd_flag := 'N';
        g_rec.clsn_flag := 'Y';
        g_rec.no_effect_flag := 'N';
        g_rec.cvrge_rt_prem_flag := 'N';
        g_rec.business_group_id := p_business_group_id;
        g_rec.effective_date := p_effective_date;
        benutils.write(p_rec => g_rec);
        --
        raise ben_manage_life_events.g_life_event_after;
        --
      end if;
      --
    close c_check_deadlock_pil;
    --
    -- insert ptnl into per in ler
    --
    l_created_ler := 'Y';
    p_created_ler_id := l_ptnl_rec.ler_id;
    insert_per_in_ler
      (p_ptnl_rec           => l_ptnl_rec
      ,p_curr_per_in_ler_id => l_curr_per_in_ler_id
      ,p_effective_date     => p_effective_date);
    --
    g_rec.person_id := p_person_id;
    g_rec.ler_id := l_ptnl_rec.ler_id;
    g_rec.lf_evt_ocrd_dt := l_ptnl_rec.lf_evt_ocrd_dt;
    g_rec.replcd_flag := 'Y';
    g_rec.crtd_flag := 'N';
    g_rec.tmprl_flag := 'N';
    g_rec.dltd_flag := 'N';
    g_rec.open_and_clsd_flag := 'N';
    g_rec.not_crtd_flag := 'N';
    g_rec.clsd_flag := 'N';
    g_rec.stl_actv_flag := 'N';
    g_rec.clpsd_flag := 'N';
    g_rec.clsn_flag := 'N';
    g_rec.no_effect_flag := 'N';
    g_rec.cvrge_rt_prem_flag := 'N';
    g_rec.business_group_id := p_business_group_id;
    g_rec.effective_date := p_effective_date;
    g_rec.per_in_ler_id := l_curr_per_in_ler_id;
    --
    benutils.write(p_rec => g_rec);
    --
    -- update ptnl for per_in_ler
    --
    update_ptnl_per_for_ler
      (p_ptnl_rec       => l_ptnl_rec
      ,p_effective_date => p_effective_date);
    --
    -- Fix for April release is to remove all per in lers that occured
    -- after the current potential.
    --
    open get_all_per_in_ler(l_ptnl_rec.lf_evt_ocrd_dt, l_curr_per_in_ler_id);
      --
      loop
        --
        hr_utility.set_location(l_proc||' Loop GAPIL ', 50);
        fetch get_all_per_in_ler into l_pil_rec;
        exit when get_all_per_in_ler%notfound;
        --
        -- First back out all the relevant stuff
        --
        -- Use effective start date of per in ler as this is the only
        -- real safe way of making sure that future stuff will back out
        -- correctly.
        --
        ben_back_out_life_event.back_out_life_events
          (p_per_in_ler_id         => l_pil_rec.per_in_ler_id,
           p_bckt_per_in_ler_id    => l_curr_per_in_ler_id,
           p_business_group_id     => p_business_group_id,
           p_effective_date        => p_effective_date);
        --
      end loop;
      --
    close get_all_per_in_ler;
    --
  else
    --
    -- Potential is after per in ler so leave ptnl as is
    --
    fnd_message.set_name('BEN','BEN_91797_PTNL_AFTER_ACTIVE');
    fnd_message.set_token('PTNL_LF_EVT_OCRD_DT',l_ptnl_rec.lf_evt_ocrd_dt);
    fnd_message.set_token('ACTIVE_LF_EVT_OCRD_DT',
                           l_current_per_in_ler.lf_evt_ocrd_dt);
    benutils.write(p_text => fnd_message.get);
    --
    g_rec.person_id := p_person_id;
    g_rec.ler_id := l_ptnl_rec.ler_id;
    g_rec.lf_evt_ocrd_dt := l_ptnl_rec.lf_evt_ocrd_dt;
    g_rec.replcd_flag := 'N';
    g_rec.crtd_flag := 'N';
    g_rec.tmprl_flag := 'N';
    g_rec.dltd_flag := 'N';
    g_rec.open_and_clsd_flag := 'N';
    g_rec.not_crtd_flag := 'N';
    g_rec.clsd_flag := 'N';
    g_rec.stl_actv_flag := 'Y';
    g_rec.clpsd_flag := 'N';
    g_rec.clsn_flag := 'N';
    g_rec.no_effect_flag := 'N';
    g_rec.cvrge_rt_prem_flag := 'N';
    g_rec.business_group_id := p_business_group_id;
    g_rec.effective_date := p_effective_date;
    --
    benutils.write(p_rec => g_rec);
    --
    -- For BENAUTHE retreival purpose.
    fnd_message.set_name('BEN','BEN_91797_PTNL_AFTER_ACTIVE');
    fnd_message.set_token('PTNL_LF_EVT_OCRD_DT',l_ptnl_rec.lf_evt_ocrd_dt);
    fnd_message.set_token('ACTIVE_LF_EVT_OCRD_DT',
                           l_current_per_in_ler.lf_evt_ocrd_dt);
    raise ben_manage_life_events.g_life_event_after;
    --
  end if;
  --

--Start 6086392

l_bckdt_pil_indx := ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl.first;


if(l_bckdt_pil_indx is not null) then

     loop

        OPEN c_pil_ovn(ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl(l_bckdt_pil_indx));
        FETCH c_pil_ovn INTO pil_ovn_rec;
        CLOSE c_pil_ovn;

              ben_Person_Life_Event_api.update_person_life_event
                (p_per_in_ler_id         => ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl(l_bckdt_pil_indx)
                ,p_bckt_per_in_ler_id    => l_curr_per_in_ler_id
                ,p_object_version_number => pil_ovn_rec.object_version_number
                ,p_effective_date        => p_effective_date
                ,P_PROCD_DT              => l_date  -- outputs
                ,P_STRTD_DT              => l_date
                ,P_VOIDD_DT              => l_date  );

	exit when l_bckdt_pil_indx = ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl.last;

        l_bckdt_pil_indx := ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl.next(l_bckdt_pil_indx);
    end loop;

end if;

ben_evaluate_ptnl_lf_evt.g_bckdt_pil_tbl.delete;


--End 6086392

  hr_utility.set_location('Leaving:'|| l_proc, 90);
  --
end eval_ptnl_per_for_ler;
--
-- iRec
procedure irec_eval_ptnl_per_for_ler(p_validate in boolean default false
                               ,p_person_id in number
                               ,p_business_group_id in number
                               ,p_ler_id in number default null
                               ,p_mode   in varchar2
                               ,p_effective_date in date
                               ,p_lf_evt_ocrd_dt in date
                               ,p_assignment_id  in number
                               ,p_ptnl_ler_for_per_id in number
                               ,p_created_ler_id out NOCOPY number) is
  --
  cursor c_ptnl(cv_ptnl_ler_for_per_id in number)
  is
    select ptnl.*
    from ben_ptnl_ler_for_per ptnl
    where ptnl.ptnl_ler_for_per_id = cv_ptnl_ler_for_per_id;
  --
  cursor get_per_in_ler(cv_assignment_id number,
                        cv_person_id     number,
                        cv_ler_id        number,
                        cv_effective_date date)
  is
    select pil.per_in_ler_id,
           pil.per_in_ler_stat_cd,
           pil.lf_evt_ocrd_dt,
           pil.ler_id,
           pil.person_id,
           pil.business_group_id,
           pil.object_version_number,
           pil.procd_dt,
           pil.strtd_dt,
           pil.voidd_dt,
           pil.bckt_dt,
           pil.clsd_dt,
           pil.ntfn_dt,
           pil.ptnl_ler_for_per_id
    from   ben_per_in_ler pil,
           ben_ler_f      ler
    where  pil.person_id = cv_person_id
    and    pil.per_in_ler_stat_cd in ('STRTD','PROCD')
    and    pil.assignment_id = cv_assignment_id
    and    pil.ler_id = ler.ler_id
    and    pil.ler_id = cv_ler_id
    and    cv_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    ler.typ_cd = 'IREC';
  --
  cursor c_ben_pil_elctbl_chc_popl (p_per_in_ler_id number) is
    select pel.pil_elctbl_chc_popl_id,
           pel.object_version_number
    from   ben_pil_elctbl_chc_popl pel,
           ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id
    and    pil.business_group_id = p_business_group_id
    and    pel.per_in_ler_id = pil.per_in_ler_id
    and    pel.business_group_id = pil.business_group_id;
  --
  l_pil_rec  get_per_in_ler%rowtype;
  l_ptnl_rec ben_ptnl_ler_for_per%rowtype;
  l_procd_dt                   date;
  l_strtd_dt                   date;
  l_voidd_dt                   date;
  l_ntfn_dt                    date;
  l_dtctd_dt                   date;
  l_unprocd_dt                 date;
  l_object_version_number      NUMBER;
  l_pil_object_version_number  NUMBER;
  l_curr_per_in_ler_id         number;
  l_created_ler                varchar2(2) := 'N';
  l_create_pil                 varchar2(2) := 'N';
  --irec2
  l_pel_object_version_number  number;
  l_pel_pk_id                  number;
  l_pil_assignment_id          number;
  --
begin

  -- Step 1.
  --    Check whether per in ler is in processed status for the associated
  --    assignment_id. If yes then raise a error as the offer is already
  --    processed, enrollments may have been already completed and HR
  --    data may have been committed.
  --
  -- Step 2.
  --
  --   If per in ler is started status then back out the event.
  --
  -- Step 3.
  --
  --  Create the pil in started status.
  --
  open get_per_in_ler(p_assignment_id,
                      p_person_id,
                      p_ler_id,
                      p_effective_date);
  fetch get_per_in_ler into l_pil_rec;
  close get_per_in_ler;
  --
  if l_pil_rec.per_in_ler_id is not null and
     l_pil_rec.per_in_ler_stat_cd = 'PROCD'
  then
    --
    -- Offer is already processed, so you can't initiate the offer again.
    -- Error out.
    --
    -- hr_utility.set_location('** ERROR SUP',9909);
    fnd_message.set_name('BEN','BEN_94025_IREC_OFFER_PROCESSED');
    benutils.write(p_text => fnd_message.get);
    --
    g_rec.person_id := p_person_id;
    g_rec.ler_id := l_pil_rec.ler_id;
    g_rec.lf_evt_ocrd_dt := p_lf_evt_ocrd_dt;
    g_rec.replcd_flag := 'N';
    g_rec.crtd_flag := 'N';
    g_rec.tmprl_flag := 'N';
    g_rec.dltd_flag := 'N';
    g_rec.open_and_clsd_flag := 'N';
    g_rec.not_crtd_flag := 'N';
    g_rec.clsd_flag := 'N';
    g_rec.stl_actv_flag := 'Y';
    g_rec.clpsd_flag := 'N';
    g_rec.clsn_flag := 'N';
    g_rec.no_effect_flag := 'N';
    g_rec.cvrge_rt_prem_flag := 'N';
    g_rec.business_group_id := p_business_group_id;
    g_rec.effective_date := p_effective_date;
    --
    benutils.write(p_rec => g_rec);
    --
    -- For BENAUTHE retreival purpose.
    --
    fnd_message.set_name('BEN','BEN_94025_IREC_OFFER_PROCESSED');
    benutils.write(p_text => fnd_message.get);
    raise ben_manage_life_events.g_life_event_after;
    --
  elsif  l_pil_rec.per_in_ler_id is not null and
         l_pil_rec.per_in_ler_stat_cd = 'STRTD' then
    --
    -- Backout the life event.
    -- Update the potential with the new life event occured date.
    --
    --  Start irec2 : dont call back_out_life_events
    --         instead update PIL.PER_IN_LER_STAT_CD to VOID ,
    --                 PEL.PIL_ELCTBL_POPL_STAT_CD to BCKDT

   /* ben_back_out_life_event.back_out_life_events
        (p_per_in_ler_id         => l_pil_rec.per_in_ler_id,
         p_bckt_per_in_ler_id    => null,
         p_bckt_stat_cd          => 'UNPROCD',
         p_business_group_id     => p_business_group_id,
         p_effective_date        => p_effective_date); */

    --  update PIL
    -- 5068367 as per requirement, we would Backout instead of VOID
    ben_Person_Life_Event_api.update_person_life_event
              (p_per_in_ler_id         => l_pil_rec.per_in_ler_id
              ,p_bckt_per_in_ler_id    => null
              ,p_per_in_ler_stat_cd    => 'BCKDT'
              ,p_prvs_stat_cd          => l_pil_rec.per_in_ler_stat_cd
              ,p_object_version_number => l_pil_rec.object_version_number
              ,p_effective_date        => p_effective_date
              ,P_PROCD_DT              => l_procd_dt  -- outputs
              ,P_STRTD_DT              => l_strtd_dt
              ,P_VOIDD_DT              => l_voidd_dt  );

    -- update  PEL
   open c_ben_pil_elctbl_chc_popl(l_pil_rec.per_in_ler_id) ;

      loop

        fetch c_ben_pil_elctbl_chc_popl into l_pel_pk_id,
                                             l_pel_object_version_number;
        exit when c_ben_pil_elctbl_chc_popl%notfound;
        --
        --
        ben_pil_elctbl_chc_popl_api.update_pil_elctbl_chc_popl
          (p_validate                => false,
           p_pil_elctbl_chc_popl_id  => l_pel_pk_id,
           p_pil_elctbl_popl_stat_cd => 'BCKDT',
           p_object_version_number   => l_pel_object_version_number,
           p_effective_date          => p_effective_date);

      end loop;

    close c_ben_pil_elctbl_chc_popl;

    -- update PPL
    --
    -- If lf event occured date is different then update the life event
    -- occured date.
    --
    open c_ptnl(l_pil_rec.ptnl_ler_for_per_id);
    fetch c_ptnl into l_ptnl_rec;
    close c_ptnl;
    --
    -- if l_ptnl_rec.lf_evt_ocrd_dt <> p_lf_evt_ocrd_dt then
    --
    -- update the potential record.
    --
    ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per_perf
       (p_validate                 => false
       ,p_ptnl_ler_for_per_id      => l_ptnl_rec.ptnl_ler_for_per_id
       ,p_ptnl_ler_for_per_stat_cd => 'PROCD'
       ,p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt
       ,p_procd_dt                 => p_lf_evt_ocrd_dt
       ,p_person_id                => l_ptnl_rec.person_id
       ,p_business_group_id        => l_ptnl_rec.business_group_id
       ,p_object_version_number    => l_ptnl_rec.object_version_number
       ,p_effective_date           => p_lf_evt_ocrd_dt
       ,p_program_application_id   => fnd_global.prog_appl_id
       ,p_program_id               => fnd_global.conc_program_id
       ,p_request_id               => fnd_global.conc_request_id
       ,p_program_update_date      => sysdate);
    --
    -- Now create the per in ler.
    --
    l_create_pil := 'Y';
    -- end if;
    --
  else
    --
    -- Create potential.
    --
   ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per_perf
       (p_validate                 => false,
        p_ptnl_ler_for_per_id      => l_ptnl_rec.ptnl_ler_for_per_id,
        p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt,
        p_ptnl_ler_for_per_stat_cd => 'PROCD',
        p_ler_id                   => p_ler_id,
        p_person_id                => p_person_id,
        p_ntfn_dt                  => sysdate, -- l_ntfn_dt
        p_unprocd_dt               => p_lf_evt_ocrd_dt, -- l_unprocd_dt
        p_procd_dt                 => p_lf_evt_ocrd_dt,
        p_dtctd_dt                 => l_dtctd_dt,
        p_business_group_id        => p_business_group_id,
        p_object_version_number    => l_object_version_number,
        p_effective_date           => p_lf_evt_ocrd_dt,
        p_program_application_id   => fnd_global.prog_appl_id,
        p_program_id               => fnd_global.conc_program_id,
        p_request_id               => fnd_global.conc_request_id,
        p_program_update_date      => sysdate);
    --
    l_create_pil := 'Y';
    --
  end if;
  --
  if l_create_pil = 'Y' then
    --
    ben_Person_Life_Event_api.create_Person_Life_Event_perf
    (p_validate                => false
    ,p_per_in_ler_id           => l_curr_per_in_ler_id
    ,p_ler_id                  => p_ler_id
    ,p_person_id               => p_person_id
    ,p_per_in_ler_stat_cd      => 'STRTD'
    ,p_ptnl_ler_for_per_id     => l_ptnl_rec.ptnl_ler_for_per_id
    ,p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt
    ,p_business_group_id       => p_business_group_id
    ,p_ntfn_dt                 => trunc(sysdate) -- p_ptnl_rec.ntfn_dt
    ,p_assignment_id           => p_assignment_id
    ,p_object_version_number   => l_pil_object_version_number
    ,p_effective_date          => p_lf_evt_ocrd_dt
    ,p_program_application_id  => fnd_global.prog_appl_id
    ,p_program_id              => fnd_global.conc_program_id
    ,p_request_id              => fnd_global.conc_request_id
    ,p_program_update_date     => sysdate
    ,p_procd_dt                => l_procd_dt
    ,p_strtd_dt                => l_strtd_dt
    ,p_voidd_dt                => l_voidd_dt);
    --
  end if;
  --
  p_created_ler_id := p_ler_id;
  --
  -- irec2 call create_ben_pil_assignment_api
   ben_pil_assignment_api.create_pil_assignment
   (p_validate                      => false
   ,p_pil_assignment_id             => l_pil_assignment_id
   ,p_per_in_ler_id                 => l_curr_per_in_ler_id
   ,p_applicant_assignment_id       => p_assignment_id
   ,p_offer_assignment_id           => null
   ,p_object_version_number         => l_object_version_number
   ) ;

end irec_eval_ptnl_per_for_ler;
-- end iRec

end ben_evaluate_ptnl_lf_evt;

/
