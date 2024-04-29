--------------------------------------------------------
--  DDL for Package Body BEN_COLLAPSE_LIFE_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COLLAPSE_LIFE_EVENT" as
/* $Header: benclpse.pkb 120.9.12010000.7 2010/02/15 18:09:04 pvelvano ship $ */
--
g_package varchar2(30) := 'ben_collapse_life_event.';
--
type g_events_rec is record
  (ptnl_ler_for_per_id      number(15),
   ler_id                   number(15),
   ptnl_ler_for_per_stat_cd varchar2(30),
   lf_evt_ocrd_dt           date,
   ntfn_dt                  date,
   object_version_number    number(15));
--
type g_events_table is table of g_events_rec index by binary_integer;
--
g_events g_events_table;
g_included_events g_events_table;
all_expressions_parsed exception;
--
g_rec      benutils.g_batch_ler_rec;
--
procedure build_life_event_set(p_person_id         in number,
                               p_business_group_id in number,
                               p_mode              in varchar2,
                               p_effective_date    in date) is
  --
  -- CWB Changes : Cursor joined to ben_ler_f
  --
  cursor c_events is
    select ptn.ptnl_ler_for_per_id,
           ptn.ler_id,
           ptn.ptnl_ler_for_per_stat_cd,
           ptn.lf_evt_ocrd_dt,
           ptn.ntfn_dt,
           ptn.object_version_number
    from   ben_ptnl_ler_for_per ptn,
           ben_ler_f      ler
    where  ptn.business_group_id  = p_business_group_id
    and    ptn.person_id = p_person_id
    and    ptn.ler_id = ler.ler_id
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    -- ABSENCES : Do not consider absence life events
    and    ler.typ_cd not in  ('COMP', 'ABS','GSP', 'IREC')
    and    ptn.ptnl_ler_for_per_stat_cd not in ('VOIDD','MNL')
    and    ptn.lf_evt_ocrd_dt <= decode(ler.typ_cd,  --Bug 5703825
                                        'SCHEDDO',
                                        ptn.lf_evt_ocrd_dt,
					'SCHEDDA',
                                        ptn.lf_evt_ocrd_dt,
                                        p_effective_date)
     order  by ptn.lf_evt_ocrd_dt asc;
  --
  -- CWB Changes End
  --
  l_events c_events%rowtype;
  l_proc   varchar2(80) := g_package||'build_life_event_set';
  l_counter integer;
  -- Added for bug 1975925
  l_ptnl_ler_for_per_id      number(15);
  l_ler_id                   number(15);
  l_ptnl_ler_for_per_stat_cd varchar2(30);
  l_lf_evt_ocrd_dt           date;
  l_ntfn_dt                  date;
  l_object_version_number    number(15);
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  -- Clear g_events table cache
  --
  g_events.delete;
  --
  open c_events;
    --
    l_counter := nvl(g_events.last, 0);
    hr_utility.set_location('Entering after last',11);
    loop
      --
      fetch c_events into l_events;
      exit when c_events%notfound;
      --
      -- Added for bug 1975925
      --
      l_ptnl_ler_for_per_id      := l_events.ptnl_ler_for_per_id;
      l_ler_id                   := l_events.ler_id;
      l_ptnl_ler_for_per_stat_cd := l_events.ptnl_ler_for_per_stat_cd;
      l_lf_evt_ocrd_dt           := l_events.lf_evt_ocrd_dt;
      l_ntfn_dt                  := l_events.ntfn_dt;
      l_object_version_number    := l_events.object_version_number;
      l_counter := l_counter + 1;
      hr_utility.set_location('Entering before assign',11);

      /*
      g_events(l_counter) := l_events;
      */
      g_events(l_counter).ptnl_ler_for_per_id      := l_ptnl_ler_for_per_id;
      g_events(l_counter).ler_id                   := l_ler_id;
      g_events(l_counter).ptnl_ler_for_per_stat_cd := l_ptnl_ler_for_per_stat_cd;
      g_events(l_counter).lf_evt_ocrd_dt           := l_lf_evt_ocrd_dt;
      g_events(l_counter).ntfn_dt                  := l_ntfn_dt;
      g_events(l_counter).object_version_number    := l_object_version_number;
      hr_utility.set_location('Entering after assign',11);
      /*
      Bug 1975925
      if g_events.exists(1) then
        --
        g_events(g_events.count+1) := l_events;
        --
      else
        --
        g_events(1) := l_events;
        --
      end if;
      */
      --
    end loop;
    --
  close c_events;
  --
  hr_utility.set_location('Leaving '||l_proc,10);
  --
end build_life_event_set;
--
function included_in_events(p_ler_id in number) return date is
  --
  l_proc                  varchar2(80) := g_package||'included_in_events';
  l_date                  date;
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  -- If the life event is in the set of included life events then return the
  -- earliest life event occurred date within the set.
  --
  for l_count in g_included_events.first..g_included_events.last loop
    --
    if g_included_events(l_count).ler_id = p_ler_id then
      --
      return g_included_events(l_count).lf_evt_ocrd_dt;
      --
    end if;
    --
  end loop;
  --
  hr_utility.set_location('Leaving '||l_proc,10);
  --
  return null;
  --
end included_in_events;
-- ----------------------------------------------------------------
--  get_first_date
-- ----------------------------------------------------------------
function get_first_date(p_events in ben_clpse_lf_evt_f%rowtype) return date is
  --
  l_proc                  varchar2(80) := g_package||'get_first_date';
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  for l_count in g_included_events.first..g_included_events.last loop
    --
    if g_included_events(l_count).ler_id in
       (p_events.ler1_id,p_events.ler2_id,
        p_events.ler3_id,p_events.ler4_id,
        p_events.ler5_id,p_events.ler6_id,
        p_events.ler7_id,p_events.ler8_id,
        p_events.ler9_id,p_events.ler10_id) then
      --
      hr_utility.set_location('Leaving '||l_proc,10);
      --
      return g_included_events(l_count).lf_evt_ocrd_dt;
      --
      exit;
      --
    end if;
    --
  end loop;
  --
  return null;
  --
end get_first_date;
-- ----------------------------------------------------------------
--  get_last_date
-- ----------------------------------------------------------------
function get_last_date(p_events in ben_clpse_lf_evt_f%rowtype) return date is
  --
  l_proc                  varchar2(80) := g_package||'get_last_date';
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  for l_count in reverse g_included_events.first..g_included_events.last loop
    --
    if g_included_events(l_count).ler_id in
      (p_events.ler1_id,p_events.ler2_id,
       p_events.ler3_id,p_events.ler4_id,
       p_events.ler5_id,p_events.ler6_id,
       p_events.ler7_id,p_events.ler8_id,
       p_events.ler9_id,p_events.ler10_id) then
      --
      hr_utility.set_location('Leaving '||l_proc,10);
      --
      return g_included_events(l_count).lf_evt_ocrd_dt;
      exit;
      --
    end if;
    --
  end loop;
  --
  return null;
  --
end get_last_date;
-- ----------------------------------------------------------------
--  perform_collapse
-- ----------------------------------------------------------------
procedure perform_collapse
  (p_events            in     ben_clpse_lf_evt_f%rowtype,
   p_business_group_id in     number,
   p_person_id         in     number,
   p_effective_date    in     date,
   p_operation         in out nocopy varchar2) is
  --
  l_proc                  varchar2(80) := g_package||'perform_collapse';
  l_outputs               ff_exec.outputs_t;
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_object_version_number number(15);
  l_ptnl_ler_for_per_id   number(15);
  l_per_in_ler_id         number(15);
  l_ass_rec               per_all_assignments_f%rowtype;
  l_mnl_dt                date;
  l_dtctd_dt              date;
  l_procd_dt              date;
  l_unprocd_dt            date;
  l_voidd_dt              date;
  l_lf_evt_ocrd_dt        date;
  l_operation             varchar2(30);
  l_ler_rec               ben_ler_f%rowtype;
  l_c1_lf_evt_ocrd_dt        date;
  l_flag boolean;
  l_not_present boolean;
  --
  cursor c1(p_ptnl_ler_for_per_id number) is
    select pil.per_in_ler_id, pil.lf_evt_ocrd_dt
    from   ben_per_in_ler pil
    where  pil.ptnl_ler_for_per_id = p_ptnl_ler_for_per_id
    and    pil.business_group_id = p_business_group_id
    and    pil.per_in_ler_stat_cd in ('STRTD','PROCD');
  --
  -- 5677090 Added this cursor
    cursor get_all_fut_pils(p_lf_evt_ocrd_dt date, p_curr_per_in_ler_id number) is
    select pil.per_in_ler_id, pil.lf_evt_ocrd_dt, pil.ntfn_dt, ler.name
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.person_id = p_person_id
    and    pil.per_in_ler_stat_cd in ('STRTD','PROCD')
    and    pil.lf_evt_ocrd_dt > p_lf_evt_ocrd_dt
    and    pil.per_in_ler_id <> p_curr_per_in_ler_id
    and    pil.ler_id = ler.ler_id
    and    p_effective_date between ler.effective_start_date and ler.effective_end_date
    and    ler.typ_cd not in ( 'COMP', 'ABS', 'GSP', 'IREC', 'SCHEDDU')
    order by lf_evt_ocrd_dt desc;
    --
    l_pil_rec get_all_fut_pils%ROWTYPE;
  --
  --Start 6086392
    l_bckdt_pil_count BINARY_INTEGER;
  --End 6086392


--Added for Bug 7583015
  cursor c_chk_evt_procd is
  select ptnl_ler_for_per_id from ben_ptnl_ler_for_per
	where person_id=p_person_id
	and business_group_id=p_events.business_group_id
	and ler_id=p_events.eval_ler_id
	and ptnl_ler_for_per_stat_cd in ('PROCD','STRTD')
	and lf_evt_ocrd_dt=l_lf_evt_ocrd_dt;
l_win_ptnl_ler_for_per_id number;

cursor c_get_pil_id is
	select per_in_ler_id from ben_per_in_ler
	where ptnl_ler_for_per_id=l_win_ptnl_ler_for_per_id
	and person_id=p_person_id
	and business_group_id=p_events.business_group_id
	and ler_id=p_events.eval_ler_id;

l_win_per_in_ler_id number;
--End 7583015

/*Bug 9372154*/
cursor c_ler_status(c_ptnl_id number) is
select 'Y' from ben_ptnl_ler_for_per
     where ptnl_ler_for_per_id=c_ptnl_id
     and ptnl_ler_for_per_stat_cd in ('DTCTD','UNPROCD');
l_flag1 varchar2(1);

begin
  --
  l_flag := false;
  l_not_present := true;
  hr_utility.set_location('Entering '||l_proc,10);
  --
  -- First set operation to event collision method
  --
  if p_events.eval_cd = 'RL' then
    --
    -- Call the rule and get the evaluation cd
    --
    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_ass_rec);
    --
    if l_ass_rec.assignment_id is null then
      --
      -- Get benefits assignment
      --
      ben_person_object.get_benass_object(p_person_id => p_person_id,
                                          p_rec       => l_ass_rec);
      --
    end if;
    --
    l_outputs := benutils.formula
      (p_formula_id     => p_events.eval_rl,
       p_effective_date => p_effective_date,
       p_business_group_id => p_business_group_id,
       p_ler_id         => p_events.eval_ler_id,
       p_assignment_id  => l_ass_rec.assignment_id);
    --
    if l_outputs(l_outputs.first).value not in ('V','D') then
      --
      fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
      fnd_message.set_token('RL','p_events.eval_rl');
      fnd_message.set_token('PROC',l_proc);
      raise ben_manage_life_events.g_record_error;
      --
    end if;
    --
    l_operation := l_outputs(l_outputs.first).value;
    --
  else
    --
    l_operation := p_events.eval_cd;
    --
  end if;
  --
  p_operation := l_operation;
  --
  -- Derive the life event occured date for the new potential life event
  --
  if p_events.eval_ler_det_cd = 'RL' then
    --
    -- Call the rule and get the evaluation cd
    --
    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_ass_rec);
    --
    if l_ass_rec.assignment_id is null then
      --
      -- Get benefits assignment
      --
      ben_person_object.get_benass_object(p_person_id => p_person_id,
                                          p_rec       => l_ass_rec);
      --
    end if;
    --
    l_outputs := benutils.formula
      (p_formula_id     => p_events.eval_ler_det_rl,
       p_effective_date => p_effective_date,
       p_business_group_id => p_business_group_id,
       p_ler_id         => p_events.eval_ler_id,
       p_assignment_id  => l_ass_rec.assignment_id);
    --
    begin
      --
      hr_utility.set_location('loutput value1 '|| l_outputs(l_outputs.first).name,10);
      hr_utility.set_location('loutput value2 '|| l_outputs(l_outputs.first).value,10);
      if l_outputs(l_outputs.first).name = 'LIFE_EVENT_OCCURRED_DATE' then
        --
        l_lf_evt_ocrd_dt :=
          fnd_date.canonical_to_date(l_outputs(l_outputs.first).value);
        --
      else
        --
        -- Account for cases where formula returns an unknown
        -- variable name
        --
        fnd_message.set_name('BEN','BEN_92310_FORMULA_RET_PARAM');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('FORMULA',p_events.eval_ler_det_rl);
        fnd_message.set_token('PARAMETER',l_outputs(l_outputs.first).name);
        fnd_message.raise_error;
        --
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
        fnd_message.set_token('FORMULA',p_events.eval_ler_det_rl);
        fnd_message.set_token('PARAMETER',l_outputs(l_outputs.first).name);
        fnd_message.raise_error;
        --
    end;
    --
  elsif p_events.eval_ler_det_cd = 'ELED' then
    -- Earliest life event occured date of those that match
        l_lf_evt_ocrd_dt := get_first_date(p_events  => p_events);

  elsif p_events.eval_ler_det_cd = 'LLED' then
    -- Latest life event occurred date of those that match
        l_lf_evt_ocrd_dt := get_last_date(p_events  => p_events);

  elsif p_events.eval_ler_det_cd = 'ELEDR' then
    --
    -- Earliest life event occured date or the date of the resulting life
    -- event if it was in the set of matched life events.
    --
    l_lf_evt_ocrd_dt :=
                nvl(included_in_events(p_ler_id => p_events.eval_ler_id),
                   get_first_date(p_events  => p_events));
    --
  elsif p_events.eval_ler_det_cd = 'LLEDR' then
    --
    -- Latest life event occured date or the date of the resulting life
    -- event if it was in the set of matched life events.
    --
    l_lf_evt_ocrd_dt :=
                nvl(included_in_events(p_ler_id => p_events.eval_ler_id),
                   get_last_date(p_events  => p_events));
    --
  else
    --
    l_lf_evt_ocrd_dt := p_effective_date;
    --
  end if;
  --
  -- Now we have the evaluation we have to loop through the included table
  -- and either delete or replace the included life events
  --
  for l_count in g_included_events.first..g_included_events.last loop
    --
    -- Only delete or void an event if it matches the set of life events
    --

    if g_included_events(l_count).ler_id in
       (p_events.ler1_id,p_events.ler2_id,
        p_events.ler3_id,p_events.ler4_id,
        p_events.ler5_id,p_events.ler6_id,
        p_events.ler7_id,p_events.ler8_id,
        p_events.ler9_id,p_events.ler10_id) then
      --
      -- Get the life event details
      --
      ben_life_object.get_object(p_ler_id => g_included_events(l_count).ler_id,
                                 p_rec    => l_ler_rec);
      --
      -- If the event is a real per in ler then we need to backout the
      -- active per in ler. We always do a void even if the option is set
      -- to be a delete as otherwise constraints between per_in_ler and
      -- ptnl_per_for_ler fail.
      --
      if g_included_events(l_count).ptnl_ler_for_per_stat_cd = 'PROCD' then
        --
        -- Backout active per in ler
        --
        -- First get correct per in ler id
        --
        open c1(g_included_events(l_count).ptnl_ler_for_per_id);
        fetch c1 into l_per_in_ler_id, l_c1_lf_evt_ocrd_dt;
        close c1;
        --
        hr_utility.set_location('Backout All Future PILs ', 50);
        --
        -- 5677090 Backout LE shud be called in reverse order of occurance.
        -- Before backing out the LEs with same ocrd-dt, we shud backout all future
        -- LEs. Lets make them 'Unprocessed'.
        --  These LEs will not show up in backed-out list in the benauthe (a small bug).
        --
        open get_all_fut_pils(l_c1_lf_evt_ocrd_dt, l_per_in_ler_id);
        loop
        --
            hr_utility.set_location('per_in_ler_id ' || l_pil_rec.per_in_ler_id, 50);
            hr_utility.set_location('lf_evt_ocrd_dt ' || l_pil_rec.lf_evt_ocrd_dt, 50);
            --
            fetch get_all_fut_pils into l_pil_rec;
            exit when get_all_fut_pils%notfound;
            --
	    hr_utility.set_location('Backing Out UNPROCD Future '|| l_pil_rec.per_in_ler_id, 50);
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

            fnd_message.set_name('BEN','BEN_92433_ACTIVE_LER_BCKDT');
            fnd_message.set_token('NAME',l_pil_rec.name);
            fnd_message.set_token('OCCURRED_DATE',l_pil_rec.lf_evt_ocrd_dt);
            fnd_message.set_token('NOTIFICATION_DATE',l_pil_rec.ntfn_dt);
            benutils.write(fnd_message.get);
            --
        end loop;
        close get_all_fut_pils;
        --
	hr_utility.set_location('PROCD eval ler_id '|| p_events.eval_ler_id, 50);
	hr_utility.set_location('PROCD g_included_events '|| g_included_events(l_count).ler_id, 50);
        /* Bug 7583015: Added if else condition.VOIDD if not winning LE, else backout the winning LE to UNPROCD*/
        if(g_included_events(l_count).ler_id <> p_events.eval_ler_id) then
		hr_utility.set_location('Backing Out VOID '|| l_per_in_ler_id, 50);
		ben_back_out_life_event.back_out_life_events
		  (p_per_in_ler_id         => l_per_in_ler_id,
		   p_bckt_per_in_ler_id    => null,
		   p_bckt_stat_cd          => 'VOIDD',
		   p_business_group_id     => p_business_group_id,
		   p_effective_date        => p_effective_date);
		   l_flag := true;
        else
	        hr_utility.set_location('Backing Out UNPROCD '|| l_per_in_ler_id, 50);
		ben_back_out_life_event.back_out_life_events
		  (p_per_in_ler_id         => l_per_in_ler_id,
		   p_bckt_per_in_ler_id    => null,
		   p_bckt_stat_cd          => 'UNPROCD',
		   p_business_group_id     => p_business_group_id,
		   p_effective_date        => p_effective_date);
		   l_flag := true;
		   l_not_present := false;
         end if;
        --
        fnd_message.set_name('BEN','BEN_92433_ACTIVE_LER_BCKDT');
        fnd_message.set_token('NAME',l_ler_rec.name);
        fnd_message.set_token('OCCURRED_DATE',g_included_events(l_count).lf_evt_ocrd_dt);
        fnd_message.set_token('NOTIFICATION_DATE',g_included_events(l_count).ntfn_dt);
        benutils.write(fnd_message.get);
        --
        g_rec.person_id := p_person_id;
        g_rec.ler_id := g_included_events(l_count).ler_id;
        g_rec.lf_evt_ocrd_dt := g_included_events(l_count).lf_evt_ocrd_dt;
        g_rec.replcd_flag := 'N';
        g_rec.crtd_flag := 'N';
        g_rec.tmprl_flag := 'N';
        g_rec.dltd_flag := 'N';
        g_rec.open_and_clsd_flag := 'N';
        g_rec.not_crtd_flag := 'N';
        g_rec.clsd_flag := 'N';
        g_rec.stl_actv_flag := 'N';
        g_rec.clpsd_flag := 'Y';
        g_rec.clsn_flag := 'N';
        g_rec.no_effect_flag := 'N';
        g_rec.cvrge_rt_prem_flag := 'N';
        g_rec.business_group_id := p_business_group_id;
        g_rec.effective_date := p_effective_date;
        --
        benutils.write(p_rec => g_rec);
        --
      elsif l_operation = 'V' then
        --
        -- Update the life event and set its status to voided
        --
	/* Bug 7583015: Added if else condition.VOIDD if not winning LE, else backout the winning LE to UNPROCD*/
	if(g_included_events(l_count).ler_id <> p_events.eval_ler_id) then
		hr_utility.set_location('In V VOIDD ', 50);
		ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per
		 (p_ptnl_ler_for_per_id      => g_included_events(l_count).
						ptnl_ler_for_per_id,
		  p_ptnl_ler_for_per_stat_cd => 'VOIDD',
		  p_voidd_dt                 => p_effective_date,
		  p_effective_date           => p_effective_date,
		  p_object_version_number    => g_included_events(l_count).
						object_version_number);
                 l_flag := true;
		--
		fnd_message.set_name('BEN','BEN_92434_PTNL_LER_VOIDED');
		fnd_message.set_token('NAME',l_ler_rec.name);
		fnd_message.set_token('OCCURRED_DATE',g_included_events(l_count).
						      lf_evt_ocrd_dt);
		fnd_message.set_token('NOTIFICATION_DATE',g_included_events(l_count).
							  ntfn_dt);
		benutils.write(fnd_message.get);
        else
	  if (g_included_events(l_count).ler_id = p_events.eval_ler_id) then
		   hr_utility.set_location('Event not voided '||g_included_events(l_count).ler_id, 50);
		   hr_utility.set_location('p_events.eval_ler_id '||p_events.eval_ler_id, 50);
		   hr_utility.set_location('state '||g_included_events(l_count).ptnl_ler_for_per_stat_cd, 50);
		   l_flag := true;
		   l_not_present := false;

                   /*Bug 9372154: If Winner LE is not processed then update the LE occured with the
		   date determined from the LE occured date determination code */
                   open c_ler_status(g_included_events(l_count).ptnl_ler_for_per_id);
		   fetch c_ler_status into l_flag1;
		   if(c_ler_status%found) then
		           hr_utility.set_location('Winner LE is not processed ', 50);
			   ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per
				 (p_ptnl_ler_for_per_id      => g_included_events(l_count).
								ptnl_ler_for_per_id,
				  p_effective_date           => p_effective_date,
				  p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt,
				  p_object_version_number    => g_included_events(l_count).
								object_version_number);
		   end if;
		   close c_ler_status;
	   end if;
        end if;
        --
      elsif l_operation = 'D' then
        --
        ben_ptnl_ler_for_per_api.delete_ptnl_ler_for_per
         (p_ptnl_ler_for_per_id      => g_included_events(l_count).
                                        ptnl_ler_for_per_id,
          p_effective_date           => p_effective_date,
          p_object_version_number    => g_included_events(l_count).
                                        object_version_number);
        --
        fnd_message.set_name('BEN','BEN_92435_PTNL_LER_DELETED');
        fnd_message.set_token('NAME',l_ler_rec.name);
        fnd_message.set_token('OCCURRED_DATE',g_included_events(l_count).
                                              lf_evt_ocrd_dt);
        fnd_message.set_token('NOTIFICATION_DATE',g_included_events(l_count).
                                                  ntfn_dt);
        benutils.write(fnd_message.get);
        --
      end if;
      --
    end if;
    --
  end loop;
  --
  -- Now lets create the new collapsed life event
  --
  /* Bug 7583015: Added if else condition for creating the potential*/
  if(not l_flag) then
		  ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
		    (p_validate                 => false,
		     p_ptnl_ler_for_per_id      => l_ptnl_ler_for_per_id,
		     p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt,
		     p_ptnl_ler_for_per_stat_cd => 'DTCTD',
		     p_ler_id                   => p_events.eval_ler_id,
		     p_dtctd_dt                 => p_effective_date,
		     p_ntfn_dt                  => trunc(sysdate),
		     p_person_id                => p_person_id,
		     p_business_group_id        => p_events.business_group_id,
		     p_object_version_number    => l_object_version_number,
		     p_effective_date           => p_effective_date,
		     p_program_application_id   => fnd_global.prog_appl_id,
		     p_program_id               => fnd_global.conc_program_id,
		     p_request_id               => fnd_global.conc_request_id,
	             p_program_update_date      => sysdate);
  else
	  if(l_not_present) then
	          open c_chk_evt_procd;
		  fetch c_chk_evt_procd into l_win_ptnl_ler_for_per_id;
		  if(c_chk_evt_procd%found) then
		          close c_chk_evt_procd;
			  open c_get_pil_id;
			  fetch c_get_pil_id into l_win_per_in_ler_id;
			  if(c_get_pil_id%found) then
				  ben_back_out_life_event.back_out_life_events
					  (p_per_in_ler_id         => l_win_per_in_ler_id,
					   p_bckt_per_in_ler_id    => null,
					   p_bckt_stat_cd          => 'UNPROCD',
					   p_business_group_id     => p_business_group_id,
					   p_effective_date        => p_effective_date);
                          end if;
			  close c_get_pil_id;
		  else
		          close c_chk_evt_procd;
			  ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
			    (p_validate                 => false,
			     p_ptnl_ler_for_per_id      => l_ptnl_ler_for_per_id,
			     p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt,
			     p_ptnl_ler_for_per_stat_cd => 'DTCTD',
			     p_ler_id                   => p_events.eval_ler_id,
			     p_dtctd_dt                 => p_effective_date,
			     p_ntfn_dt                  => trunc(sysdate),
			     p_person_id                => p_person_id,
			     p_business_group_id        => p_events.business_group_id,
			     p_object_version_number    => l_object_version_number,
			     p_effective_date           => p_effective_date,
			     p_program_application_id   => fnd_global.prog_appl_id,
			     p_program_id               => fnd_global.conc_program_id,
			     p_request_id               => fnd_global.conc_request_id,
			     p_program_update_date      => sysdate);
                  end if;
	   end if;
 end if;
  --


  hr_utility.set_location('Leaving '||l_proc,10);
  --
end perform_collapse;
--
procedure add_to_included(p_rec in g_events_rec) is
  --
  l_proc        varchar2(80) := g_package||'add_to_include';
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  -- Add record into included list. This is the list from which we will be
  -- voiding or deleteing record from.
  --
  if g_included_events.exists(1) then
    --
    g_included_events(g_included_events.count+1) := p_rec;
    --
  else
    --
    g_included_events(1) := p_rec;
    --
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc,10);
  --
end add_to_included;
--
procedure add_expression(p_value      in     varchar2,
                         p_expression in out nocopy varchar2) is
  --
  l_proc        varchar2(80) := g_package||'add_expression';
  --
begin
  --
  if p_value is not null then
    --
    -- Handle boolean conditions
    --
    if p_value = 'AND' then
      --
      p_expression := p_expression||' and ';
      --
    elsif p_value = 'OR' then
      --
      p_expression := p_expression||' or ';
      --
    else
      --
      p_expression := p_expression||p_value;
      --
    end if;
    --
  else
    --
    -- No more expressions need to be parsed
    --
    raise all_expressions_parsed;
    --
  end if;
  --
end add_expression;
--
function build_boolean_expression(p_events    in ben_clpse_lf_evt_f%rowtype,
                                  p_in_string in varchar2)
  return varchar2 is
  --
  l_proc        varchar2(80) := g_package||'build_boolean_expression';
  l_expression  varchar2(32000);
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  add_expression(p_value      => p_events.ler1_id,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_in_string,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_events.bool1_cd,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_events.ler2_id,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_in_string,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_events.bool2_cd,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_events.ler3_id,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_in_string,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_events.bool3_cd,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_events.ler4_id,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_in_string,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_events.bool4_cd,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_events.ler5_id,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_in_string,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_events.bool5_cd,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_events.ler6_id,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_in_string,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_events.bool6_cd,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_events.ler7_id,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_in_string,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_events.bool7_cd,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_events.ler8_id,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_in_string,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_events.bool8_cd,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_events.ler9_id,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_in_string,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_events.bool9_cd,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_events.ler10_id,
                 p_expression => l_expression);
  --
  add_expression(p_value      => p_in_string,
                 p_expression => l_expression);
  --
  return l_expression;
  --
  hr_utility.set_location('Leaving '||l_proc,10);
  --
exception
  --
  when all_expressions_parsed then
    --
    hr_utility.set_location('Leaving '||l_proc,10);
    return l_expression;
    --
end build_boolean_expression;
--
function parse_expression(p_expression in varchar2) return boolean is
  --
  l_proc        varchar2(80) := g_package||'parse_expression';
  l_dynamic_sql varchar2(32000);
  l_rows        integer;
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  l_dynamic_sql := 'select 1 from sys.dual where '||p_expression;
  --
  execute immediate l_dynamic_sql into l_rows;
  --
  if l_rows = 1 then
    --
    return true;
    --
  end if;
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
exception
  --
  when no_data_found then
    --
    return false;
    --
  when others then
    --
    raise;
    --
end parse_expression;
--
function parse_and_match(p_events             in ben_clpse_lf_evt_f%rowtype,
                         p_min_lf_evt_ocrd_dt in date)
  return boolean is
  --
  l_proc        varchar2(80) := g_package||'parse_and_match';
  l_in_string   varchar2(1000) := ' in (';
  l_first_entry boolean := false;
  l_success     boolean := true;
  l_expression  varchar2(32000);
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  g_included_events.delete;
  --
  -- Steps to build in string
  --
  for l_count in g_events.first..g_events.last loop
    --  according to bill, tolerance should be used to swing around the
    --  min date.  Don't consider ones older than that.
    if p_min_lf_evt_ocrd_dt + nvl(p_events.tlrnc_dys_num,0) >=
      g_events(l_count).lf_evt_ocrd_dt and
      p_min_lf_evt_ocrd_dt - nvl(p_events.tlrnc_dys_num,0) <=
      g_events(l_count).lf_evt_ocrd_dt then
      --
      -- Account for first entry, this doesn't need to have a leading comma
      --
      if not l_first_entry then
        --
        l_first_entry := true;
        l_in_string := l_in_string||g_events(l_count).ler_id;
        --
      else
        --
        -- We need a leading comma to be inserted into the string
        --
        l_in_string := l_in_string||','||g_events(l_count).ler_id;
        --
      end if;
      --
      add_to_included(p_rec => g_events(l_count));
      --
    end if;
    --
  end loop;
  --
  l_in_string := l_in_string||') ';
  --
  -- Only attempt to build the expression if we have some included events
  --
  if l_first_entry then
    --
    l_expression := build_boolean_expression(p_events    => p_events,
                                             p_in_string => l_in_string);
    --
    -- Now we must parse the boolean expression and return whether we have a
    -- match.
    --
    l_success := parse_expression(p_expression => l_expression);
    --
  else
    --
    l_success := false;
    --
  end if;
  --
  hr_utility.set_location(' l_exp '||l_expression,10);
  hr_utility.set_location('Leaving '||l_proc,10);
  --
  return l_success;
  --
end parse_and_match;
--
procedure collapse_event
  (p_person_id          in number,
   p_business_group_id  in number,
   p_mode               in varchar2,
   p_min_lf_evt_ocrd_dt in date,
   p_effective_date     in date) is
  --
  cursor c_events is
    select *
    from   ben_clpse_lf_evt_f clp
    where  clp.business_group_id  = p_business_group_id
    and    p_effective_date
           between clp.effective_start_date
           and     clp.effective_end_date
    order  by seq;
  --
  l_events    c_events%rowtype;
  l_proc      varchar2(80) := g_package||'collapse_event';
  l_match     boolean := false;
  l_operation varchar2(30) := 'NO_MATCH';
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  -- Test if at least one life event was included in the set
  --
  --
  open c_events;
    --
    loop
      --
      fetch c_events into l_events;
      exit when c_events%notfound;
      --
      --
      -- Build potential set of life events structure, this will be used as
      -- part of the parse routine
      --
      build_life_event_set(p_person_id         => p_person_id,
                           p_business_group_id => p_business_group_id,
                           p_mode              => p_mode,
                           p_effective_date    => p_effective_date);
      --
      if g_events.count = 0 then
        --
        -- There are no events to collapse
        --
        exit;
        --
      end if;
      --
      -- Now we have a record lets try and parse it and get a match
      --
      l_match := parse_and_match
                   (p_events             => l_events,
                    p_min_lf_evt_ocrd_dt => p_min_lf_evt_ocrd_dt);
      --
      if l_match then
        --
        perform_collapse(p_events            => l_events,
                         p_business_group_id => p_business_group_id,
                         p_person_id         => p_person_id,
                         p_effective_date    => p_effective_date,
                         p_operation         => l_operation);
        --
      end if;
      --
    end loop;
    --
  close c_events;
  --
  hr_utility.set_location('Leaving '||l_proc,10);
  --
end collapse_event;
--
-- Main routine. This performs the collapse and returns to the calling
-- program.
--
procedure main(p_person_id          in number,
               p_business_group_id  in number,
               p_mode               in varchar2,
               p_min_lf_evt_ocrd_dt in date,
               p_effective_date     in date) is
  --
  l_proc      varchar2(80) := g_package||'main';
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  -- Steps to perform process
  --
  -- 1) Check if we have rows in the collapse life event table
  -- 2) If so populate the potential life events cache with all potential
  --    life events
  -- 3) Retrieve rows and parse dynamic sql to test for solution
  --
  collapse_event(p_person_id          => p_person_id,
                 p_business_group_id  => p_business_group_id,
                 p_mode               => p_mode,
                 p_min_lf_evt_ocrd_dt => p_min_lf_evt_ocrd_dt,
                 p_effective_date     => p_effective_date);
  --
  hr_utility.set_location('Leaving '||l_proc,10);
  --
end main;
--
end ben_collapse_life_event;

/
