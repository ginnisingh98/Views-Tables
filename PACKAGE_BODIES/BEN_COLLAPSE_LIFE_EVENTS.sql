--------------------------------------------------------
--  DDL for Package Body BEN_COLLAPSE_LIFE_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COLLAPSE_LIFE_EVENTS" as
/* $Header: benclple.pkb 120.0 2005/05/28 03:49:35 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+
--
Name
	Collapse Life Events
Purpose
        This package is used to collapse life events. It is desigend to be
        caled from formula but can also be called form forms or reports.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        01 Dec 98        G Perry    115.0      Created.
        07 Dec 98        G Perry    115.1      Added in function
                                               get_life_event_occured_date.
        22 Mar 99        TMathers   115.2      Changed -MON- to /MM/
        02 May 99        TMathers   115.3      Undatetracked PTNL_ler_for_per.
        19 dec 01        pbodla     115.4      CWB Changes : Consider only non
                                               comp work bench type potentials.
        07-Jan-02        Rpillay    115.5      Added dbdrv and checkfile command
        14 jul 02        pbodla     115.6      ABSENCES : DO not include absence
                                               life events.
        19-Sep-03       tjesumic    115.7     GSP LE is not considered
        19-Sep-04       pabodla     115.8     iRec - Avoid iRec potentials in
                                              collapse logic.
*/
--------------------------------------------------------------------------------
--
g_package             varchar2(80) := 'ben_collapse_life_events';
g_lf_evt_ocrd_dt      date;
--
function collapse_potential(p_ler_id         in number,
                            p_person_id      in number,
                            p_lf_evt_ocrd_dt in date,
                            p_effective_date in date) return number is
  --
  l_package         varchar2(80) := g_package||'.collapse_potential';
  --
  -- This cursor gets all the potential life events that exist for a
  -- particular person.
  --
  cursor c_get_potentials is
    select ler.typ_cd,
           ler.ler_id,
           ptn.lf_evt_ocrd_dt
    from   ben_ler_f ler,
           ben_ptnl_ler_for_per ptn
    where  ptn.person_id = p_person_id
    and    ptn.ler_id = ler.ler_id
    -- CWB Changes
    -- ABSENCES - avoid collapsing absences life events.
    and    ler.typ_cd not in ('COMP', 'ABS','GSP', 'IREC')
    and    ptnl_ler_for_per_stat_cd in ('UNPROCD','DTCTD')
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    order  by ptn.lf_evt_ocrd_dt asc;
  --
  -- This cursor gets information about the passed in context. It works out
  -- whether the passed in context is a derived factor life event.
  --
  cursor c_life_event is
    select null
    from   ben_ler_f ler
    where  ler.ler_id = p_ler_id
    and    ler.typ_cd in ('DRVDAGE','DRVDCAL','DRVDCMP',
                          'DRVDHRW','DRVDLOS','DRVDTPF')
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date;
  --
  l_potentials      c_get_potentials%rowtype;
  l_dummy           varchar2(1);
  l_return_ler_id   number;
  l_current_derived boolean;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_package,10);
  --
  -- Open cursor to work out if current event is a derived factor life
  -- event.
  --
  open c_life_event;
    --
    fetch c_life_event into l_dummy;
    --
    if c_life_event%found then
      --
      -- Current life event is for a derived factor
      --
      l_current_derived := true;
      --
    else
      --
      -- Current life event is not a derived factor
      --
      l_current_derived := false;
      --
    end if;
    --
  close c_life_event;
  --
  -- Open Cursor to grab all unprocessed and detected life events for
  -- the person we are processing
  --
  open c_get_potentials;
    --
    loop
      --
      fetch c_get_potentials into l_potentials;
      exit when c_get_potentials%notfound;
      --
      -- Now lets assume the tests we want are as follows :
      --
      -- If our current life event is a Derived Factor then
      -- that life event is the collapsed life event unless
      -- there is another life event which is a non derived factor
      --
      -- If our current life event is not a derived factor then
      -- any derived factor life event is our collapsed life event
      -- Remember we are sorting by life event occured date.
      --
      if l_potentials.typ_cd in ('DRVDAGE','DRVDCAL','DRVDCMP',
                                 'DRVDHRW','DRVDLOS','DRVDTPF') and
         not l_current_derived then
        --
        -- This life event is a derived factor and our current life
        -- event is not a derived factor so return this as the collapsed
        -- life event.
        --
        l_return_ler_id := l_potentials.ler_id;
        g_lf_evt_ocrd_dt := l_potentials.lf_evt_ocrd_dt;
        exit;
        --
      elsif l_potentials.typ_cd not in ('DRVDAGE','DRVDCAL','DRVDCMP',
                                        'DRVDHRW','DRVDLOS','DRVDTPF') and
         l_current_derived then
        --
        -- This life event is not a derived factor and our current life event
        -- is a derived factor so the life event becomes the collapsed life
        -- event.
        --
        l_return_ler_id := l_potentials.ler_id;
        g_lf_evt_ocrd_dt := l_potentials.lf_evt_ocrd_dt;
        exit;
        --
      end if;
      --
    end loop;
    --
  close c_get_potentials;
  --
  -- First check whether the l_return_ler_id variable has been set, this
  -- could occur if there were no potential life events that existed
  -- for the person. If so then set the l_return_ler_id to the current
  -- life event.
  --
  if l_return_ler_id is null then
    --
    l_return_ler_id := p_ler_id;
    g_lf_evt_ocrd_dt := p_lf_evt_ocrd_dt;
    --
  end if;
  --
  return l_return_ler_id;
  --
  hr_utility.set_location('Leaving: '||l_package,10);
  --
end collapse_potential;
--
function collapse_life_event(p_effective_date in varchar2,
                             p_assignment_id  in number,
                             p_ler_id         in number) return number is
  --
  l_package        varchar2(80) := g_package||'.collapse_life_event';
  l_effective_date date;
  l_lf_evt_ocrd_dt date;
  l_person_id      number;
  l_ler_id         number;
  --
  cursor c_get_person is
    select paf.person_id
    from   per_assignments_f paf
    where  paf.assignment_id = p_assignment_id
    and    paf.primary_flag = 'Y'
    and    l_effective_date
           between paf.effective_start_date
           and     paf.effective_end_date;
  --
  -- CWB Changes : Cursor joined to ben_ler_f
  --
  cursor c_person_life is
    select ptn.lf_evt_ocrd_dt
    from   ben_ptnl_ler_for_per ptn,
           ben_ler_f ler
    where  ptn.person_id = l_person_id
    and    ptn.ptnl_ler_for_per_stat_cd in ('UNPROCD','DTCTD')
    and    ptn.ler_id = p_ler_id
    and    ler.ler_id = ptn.ler_id
    -- CWB Changes
    -- ABSENCES - avoid collapsing absences life events.
    and    ler.typ_cd not in ('COMP', 'ABS','GSP', 'IREC')
    and    l_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    ptn.rowid = (select min(ptn2.rowid)
                        from   ben_ptnl_ler_for_per ptn2,
                               ben_ler_f      ler2
                        where  ptn2.person_id = ptn.person_id
                        and    ptn2.ler_id = ler2.ler_id
                        and    l_effective_date
                               between ler2.effective_start_date
                               and     ler2.effective_end_date
                        and    ler2.typ_cd not in ('COMP', 'ABS','GSP', 'IREC')
                        and    ptn2.ptnl_ler_for_per_stat_cd in
                               ('UNPROCD','DTCTD')
                        and    ptn2.lf_evt_ocrd_dt =
                               (select min(ptn3.lf_evt_ocrd_dt)
                                from   ben_ptnl_ler_for_per ptn3,
                                       ben_ler_f      ler3
                                where  ptn3.person_id = ptn2.person_id
                                and    ptn3.ler_id = ler3.ler_id
                                and    l_effective_date
                                       between ler3.effective_start_date
                                       and     ler3.effective_end_date
                                and    ler3.typ_cd not in ( 'COMP','GSP', 'IREC', 'ABS')
                                and    ptn3.ptnl_ler_for_per_stat_cd in
                                       ('UNPROCD','DTCTD')
                                ));
  --
  -- CWB Changes End
  --
begin
  --
  hr_utility.set_location('Entering: '||l_package,10);
  --
  -- First lets convert the effective_date into a date as formula only
  -- understands text or numbers but we need it in a date format.
  --
  l_effective_date := to_date(p_effective_date,'DD/MM/YYYY');
  --
  -- Now lets derive the person we are using, since person is not a context.
  -- but there is always a one to one mapping between assignment and person
  --
  open c_get_person;
    --
    fetch c_get_person into l_person_id;
    --
    if c_get_person%notfound then
      --
      -- In this example we error if the person can not be derived
      --
      hr_api.mandatory_arg_error(p_api_name       => l_package,
                                 p_argument       => 'l_person_id',
                                 p_argument_value => l_person_id);
      --
    end if;
    --
  close c_get_person;
  --
  -- Get the life event occured date of the event we are trying to process
  -- we need this if there are no other potential life events that are out
  -- there for the person.
  --
  open c_person_life;
    --
    fetch c_person_life into l_lf_evt_ocrd_dt;
    --
  close c_person_life;
  --
  -- At this point we know the person id and the effective date so
  -- we can work out all the life events that the person currently has
  -- as potential life events and then we can process them accordingly
  --
  l_ler_id := collapse_potential(p_ler_id         => p_ler_id,
                                 p_person_id      => l_person_id,
                                 p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt,
                                 p_effective_date => l_effective_date);
  --
  -- Return the collapsed life event
  --
  return l_ler_id;
  --
  hr_utility.set_location('Leaving: '||l_package,10);
  --
end collapse_life_event;
--
function get_life_event_occured_date return varchar2 is
  --
  l_package        varchar2(80) := g_package||'.get_life_event_occured_date';
  --
begin
  --
  hr_utility.set_location('Entering: '||l_package,10);
  --
  -- We need to return the life event occured date, remember formula can't
  -- handle dates so we must typecast the date as a string.
  --
  return to_char(g_lf_evt_ocrd_dt,'DD/MM/YYYY');
  --
  hr_utility.set_location('Leaving: '||l_package,10);
  --
end get_life_event_occured_date;
--
end ben_collapse_life_events;

/
