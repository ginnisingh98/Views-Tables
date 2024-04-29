--------------------------------------------------------
--  DDL for Package Body PAY_CONTINUOUS_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CONTINUOUS_CALC" AS
/* $Header: pycontc.pkb 120.19.12010000.2 2009/11/16 07:47:58 priupadh ship $ */

/* Global definitions */
--
  g_package varchar2(80) := 'PAY_CONTINUOUS_CALC';
  TYPE event_cache IS RECORD
  (
    business_group_id           number_tbl,
    legislation_code            varchar_2_tbl,
    table_name                  varchar_60_tbl,
    column_name                 varchar_60_tbl,
    change_type                 varchar_60_tbl,
    event_update_id             number_tbl,
    event_type                  varchar_60_tbl,
    event_check                 boolean_tbl,
    sz                          INTEGER
  );
--
 g_event_cache event_cache;
--

  /* Name      : event_update
     Purpose   : Based on parameters passed in this procedure checks whether
                 the specified column has been updated, if so it records
                 any events associated with that update.
     Arguments :
     Notes     :
  */
  procedure event_update(
                         p_business_group_id in number,
                         p_legislation_code  in varchar2,
                         p_table_name        in varchar2,
                         p_column_name       in varchar2,
                         p_old_value         in varchar2,
                         p_new_value         in varchar2,
                         p_effective_date    in date,
                         p_calc_date         in date default null,
                         p_event_type        in varchar2 default 'U'
                        )
  is
--
    cursor get_events (p_bg_id in number,
                       p_leg_code in varchar2,
                       p_tab_name in varchar2,
                       p_col_name in varchar2,
                       p_evnt_typ in varchar2
                      )
    is
    select peu.change_type,
           peu.event_update_id,
           peu.event_type
      from pay_event_updates peu,
           pay_dated_tables  pt
     where ((p_bg_id = peu.business_group_id
            and peu.legislation_code is null)
        or (p_leg_code = peu.legislation_code
            and peu.business_group_id is null)
        or (peu.business_group_id is null
            and peu.legislation_code is null))
       and pt.dated_table_id = peu.dated_table_id
       and pt.table_name = p_tab_name
       and peu.event_type = p_evnt_typ
       and nvl(peu.column_name, 'NULL') = nvl(p_col_name, 'NULL');
--
  cnt number;
  processed boolean;
  l_calc_date date;
  l_event_type pay_event_updates.event_type%type;
  begin
--
    if (p_calc_date is null) then
      l_calc_date := p_effective_date;
    else
      l_calc_date := p_calc_date;
    end if;
--
    -- Setup the event_type
    if (pay_dyn_triggers.g_dyt_mode = pay_dyn_triggers.g_dbms_dyt) then
      l_event_type := p_event_type;
    else
      l_event_type := pay_dyn_triggers.g_dyt_mode;
    end if;
--
    hr_utility.set_location('pay_continuous_calc.event_update', 10);
    /* Search the cache does this event exist in the cache */
    processed := false;
    for cnt in 1..g_event_cache.sz loop
       if (    g_event_cache.business_group_id(cnt) = p_business_group_id
           and g_event_cache.legislation_code(cnt)  = p_legislation_code
           and g_event_cache.table_name(cnt)        = p_table_name
           and nvl(g_event_cache.column_name(cnt), 'NULL')
                                                    = nvl(p_column_name, 'NULL')
           and g_event_cache.event_type(cnt)        = l_event_type) then
--
         processed := true;
         /* Ok we got the cached value */
         if (g_event_cache.event_check(cnt) = true) then
--
            hr_utility.trace('+Discovered our event in cache.');
            hr_utility.trace('+Event: '||l_event_type||' on '||p_table_name||'.'||p_column_name);
--
            /* If its an update then check the values otherwise just add it to the list */
            if (   g_event_cache.event_type(cnt) = 'U'
                or g_event_cache.event_type(cnt) = 'CORRECTION'
                or g_event_cache.event_type(cnt) = 'UPDATE'
                or g_event_cache.event_type(cnt) = 'UPDATE_OVERRIDE'
                or g_event_cache.event_type(cnt) = 'UPDATE_CHANGE_INSERT') then
              hr_utility.trace('Comparing...'||p_old_value||' with '||p_new_value);
              if (nvl(p_old_value, 'peu<null>') <> nvl(p_new_value, 'peu<null>')) then
                 /* OK record the event in the event list */
                 hr_utility.trace('>Event passes test => add to list for recording in to ppe.');
                 g_event_list.sz := g_event_list.sz + 1;
                 g_event_list.change_type(g_event_list.sz) :=
                                             g_event_cache.change_type(cnt);
                 g_event_list.effective_date(g_event_list.sz) := p_effective_date;
                 g_event_list.calc_date(g_event_list.sz) := l_calc_date;
                 g_event_list.event_update_id(g_event_list.sz) :=
                                             g_event_cache.event_update_id(cnt);
                 g_event_list.description(g_event_list.sz)
                                    := nvl(p_old_value, '<null>')
                                               ||' -> '||  nvl(p_new_value, '<null>');
              end if;
            else
               hr_utility.trace('>Event auto passes => add to list for recording in to ppe.');
               g_event_list.sz := g_event_list.sz + 1;
               g_event_list.change_type(g_event_list.sz) :=
                                           g_event_cache.change_type(cnt);
               g_event_list.effective_date(g_event_list.sz) := p_effective_date;
               g_event_list.calc_date(g_event_list.sz) := l_calc_date;
               g_event_list.event_update_id(g_event_list.sz) :=
                                           g_event_cache.event_update_id(cnt);
               g_event_list.description(g_event_list.sz) := null;
            end if;
         end if;
--
       end if;
    end loop;
--
    hr_utility.set_location('pay_continuous_calc.event_update', 30);
    /* The event doesn't exist in the cache, go get it */
    if (processed = false) then
       declare
          found boolean;
       begin
--
         hr_utility.set_location('pay_continuous_calc.event_update', 40);
         found := false;
    --hr_utility.trace('> p_business_group_id: '||p_business_group_id);
    --hr_utility.trace('> p_legislation_code:  '||p_legislation_code);
    --hr_utility.trace('> p_table_name:        '||p_table_name);
    --hr_utility.trace('> p_column_name:       '||p_column_name);
    --hr_utility.trace('> l_event_type:        '||l_event_type);

         for evnt in get_events (p_business_group_id, p_legislation_code,
                                 p_table_name, p_column_name, l_event_type) loop
--
--
            hr_utility.trace('+Our event is not in cache, go get it...');
            hr_utility.trace('+Event: '||l_event_type||' on '||p_table_name||'.'||p_column_name);
--
            found := true;
            g_event_cache.sz := g_event_cache.sz + 1;
            g_event_cache.business_group_id(g_event_cache.sz) := p_business_group_id;
            g_event_cache.legislation_code(g_event_cache.sz)  := p_legislation_code;
            g_event_cache.table_name(g_event_cache.sz)          := p_table_name;
            g_event_cache.column_name(g_event_cache.sz)          := p_column_name;
            g_event_cache.event_check(g_event_cache.sz)       := true;
            g_event_cache.change_type(g_event_cache.sz)        := evnt.change_type;
            g_event_cache.event_update_id(g_event_cache.sz)   := evnt.event_update_id;
            g_event_cache.event_type(g_event_cache.sz)        := evnt.event_type;
--
--
            /* If its an update then check the values otherwise just add it to the list */
            if (   g_event_cache.event_type(g_event_cache.sz) = 'U'
                or g_event_cache.event_type(g_event_cache.sz) = 'CORRECTION'
                or g_event_cache.event_type(g_event_cache.sz) = 'UPDATE'
                or g_event_cache.event_type(g_event_cache.sz) = 'UPDATE_OVERRIDE'
                or g_event_cache.event_type(g_event_cache.sz) = 'UPDATE_CHANGE_INSERT') then
              hr_utility.trace('Comparing...'||p_old_value||' with '||p_new_value);
              --
              if (nvl(p_old_value, 'peu<null>') <> nvl(p_new_value, 'peu<null>')) then
                 /* OK record the event in the event list */
                 hr_utility.trace('>Event passes test => add to list for recording in to ppe.');
                 g_event_list.sz := g_event_list.sz + 1;
                 g_event_list.change_type(g_event_list.sz) :=
                                             g_event_cache.change_type(g_event_cache.sz);
                 g_event_list.effective_date(g_event_list.sz) := p_effective_date;
                 g_event_list.calc_date(g_event_list.sz) := l_calc_date;
                 g_event_list.event_update_id(g_event_list.sz) :=
                                             g_event_cache.event_update_id(g_event_cache.sz);
                 g_event_list.description(g_event_list.sz)
                                    := nvl(p_old_value, '<null>')
                                               ||' -> '||  nvl(p_new_value, '<null>');
              hr_utility.trace('5...');
              end if;
            else
                 hr_utility.trace('>Event auto passes => add to list for recording in to ppe.');
               g_event_list.sz := g_event_list.sz + 1;
               g_event_list.change_type(g_event_list.sz) :=
                                           g_event_cache.change_type(g_event_cache.sz);
               g_event_list.effective_date(g_event_list.sz) := p_effective_date;
               g_event_list.calc_date(g_event_list.sz) := l_calc_date;
               g_event_list.event_update_id(g_event_list.sz) :=
                                           g_event_cache.event_update_id(g_event_cache.sz);
               g_event_list.description(g_event_list.sz) := null;
            end if;
--
         end loop;
--
         /* No this isn't a valid event hence don't call the API */
         if (found = false) then
--
            hr_utility.trace('Not valid event, add to a cache of non-recorded events');
--

            g_event_cache.sz := g_event_cache.sz + 1;
            g_event_cache.business_group_id(g_event_cache.sz) := p_business_group_id;
            g_event_cache.legislation_code(g_event_cache.sz)  := p_legislation_code;
            g_event_cache.table_name(g_event_cache.sz)          := p_table_name;
            g_event_cache.column_name(g_event_cache.sz)          := p_column_name;
            g_event_cache.event_check(g_event_cache.sz)       := false;
            g_event_cache.change_type(g_event_cache.sz)        := null;
            g_event_cache.event_update_id(g_event_cache.sz)   := null;
            g_event_cache.event_type(g_event_cache.sz)        := l_event_type;
         end if;
--
       end;
    end if;
    hr_utility.set_location('pay_continuous_calc.event_update', 900);
--
  end event_update;

---------------------------------------------------------------------------------------
-- Here are the procedures that have been built for the core triggers
---------------------------------------------------------------------------------------

--
--------------------------------------------
-- PAY_ELEMENT_ENTRIES_F
--------------------------------------------
/* Used generator to build this procedure, but removed some of that table values.
*/
/* PAY_ELEMENT_ENTRIES */
/* name : PAY_ELEMENT_ENTRIES_F_aru
   purpose : This is procedure that records any changes for updates
             on element_entries.
*/
procedure PAY_ELEMENT_ENTRIES_F_aru(
  p_business_group_id in number,
  p_legislation_code in varchar2,
  p_effective_date in date,
  p_old_ASSIGNMENT_ID in NUMBER,
  p_new_ASSIGNMENT_ID in NUMBER,
  p_old_ATTRIBUTE1 in VARCHAR2,
  p_new_ATTRIBUTE1 in VARCHAR2,
  p_old_ATTRIBUTE10 in VARCHAR2,
  p_new_ATTRIBUTE10 in VARCHAR2,
  p_old_ATTRIBUTE11 in VARCHAR2,
  p_new_ATTRIBUTE11 in VARCHAR2,
  p_old_ATTRIBUTE12 in VARCHAR2,
  p_new_ATTRIBUTE12 in VARCHAR2,
  p_old_ATTRIBUTE13 in VARCHAR2,
  p_new_ATTRIBUTE13 in VARCHAR2,
  p_old_ATTRIBUTE14 in VARCHAR2,
  p_new_ATTRIBUTE14 in VARCHAR2,
  p_old_ATTRIBUTE15 in VARCHAR2,
  p_new_ATTRIBUTE15 in VARCHAR2,
  p_old_ATTRIBUTE16 in VARCHAR2,
  p_new_ATTRIBUTE16 in VARCHAR2,
  p_old_ATTRIBUTE17 in VARCHAR2,
  p_new_ATTRIBUTE17 in VARCHAR2,
  p_old_ATTRIBUTE18 in VARCHAR2,
  p_new_ATTRIBUTE18 in VARCHAR2,
  p_old_ATTRIBUTE19 in VARCHAR2,
  p_new_ATTRIBUTE19 in VARCHAR2,
  p_old_ATTRIBUTE2 in VARCHAR2,
  p_new_ATTRIBUTE2 in VARCHAR2,
  p_old_ATTRIBUTE20 in VARCHAR2,
  p_new_ATTRIBUTE20 in VARCHAR2,
  p_old_ATTRIBUTE3 in VARCHAR2,
  p_new_ATTRIBUTE3 in VARCHAR2,
  p_old_ATTRIBUTE4 in VARCHAR2,
  p_new_ATTRIBUTE4 in VARCHAR2,
  p_old_ATTRIBUTE5 in VARCHAR2,
  p_new_ATTRIBUTE5 in VARCHAR2,
  p_old_ATTRIBUTE6 in VARCHAR2,
  p_new_ATTRIBUTE6 in VARCHAR2,
  p_old_ATTRIBUTE7 in VARCHAR2,
  p_new_ATTRIBUTE7 in VARCHAR2,
  p_old_ATTRIBUTE8 in VARCHAR2,
  p_new_ATTRIBUTE8 in VARCHAR2,
  p_old_ATTRIBUTE9 in VARCHAR2,
  p_new_ATTRIBUTE9 in VARCHAR2,
  p_old_ATTRIBUTE_CATEGORY in VARCHAR2,
  p_new_ATTRIBUTE_CATEGORY in VARCHAR2,
  p_old_COST_ALLOCATION_KEYFLEX in NUMBER,
  p_new_COST_ALLOCATION_KEYFLEX in NUMBER,
  p_old_DATE_EARNED in DATE,
  p_new_DATE_EARNED in DATE,
  p_old_EFFECTIVE_END_DATE in DATE,
  p_new_EFFECTIVE_END_DATE in DATE,
  p_old_EFFECTIVE_START_DATE in DATE,
  p_new_EFFECTIVE_START_DATE in DATE,
  p_old_ENTRY_INFORMATION1 in VARCHAR2,
  p_new_ENTRY_INFORMATION1 in VARCHAR2,
  p_old_ENTRY_INFORMATION10 in VARCHAR2,
  p_new_ENTRY_INFORMATION10 in VARCHAR2,
  p_old_ENTRY_INFORMATION11 in VARCHAR2,
  p_new_ENTRY_INFORMATION11 in VARCHAR2,
  p_old_ENTRY_INFORMATION12 in VARCHAR2,
  p_new_ENTRY_INFORMATION12 in VARCHAR2,
  p_old_ENTRY_INFORMATION13 in VARCHAR2,
  p_new_ENTRY_INFORMATION13 in VARCHAR2,
  p_old_ENTRY_INFORMATION14 in VARCHAR2,
  p_new_ENTRY_INFORMATION14 in VARCHAR2,
  p_old_ENTRY_INFORMATION15 in VARCHAR2,
  p_new_ENTRY_INFORMATION15 in VARCHAR2,
  p_old_ENTRY_INFORMATION16 in VARCHAR2,
  p_new_ENTRY_INFORMATION16 in VARCHAR2,
  p_old_ENTRY_INFORMATION17 in VARCHAR2,
  p_new_ENTRY_INFORMATION17 in VARCHAR2,
  p_old_ENTRY_INFORMATION18 in VARCHAR2,
  p_new_ENTRY_INFORMATION18 in VARCHAR2,
  p_old_ENTRY_INFORMATION19 in VARCHAR2,
  p_new_ENTRY_INFORMATION19 in VARCHAR2,
  p_old_ENTRY_INFORMATION2 in VARCHAR2,
  p_new_ENTRY_INFORMATION2 in VARCHAR2,
  p_old_ENTRY_INFORMATION20 in VARCHAR2,
  p_new_ENTRY_INFORMATION20 in VARCHAR2,
  p_old_ENTRY_INFORMATION21 in VARCHAR2,
  p_new_ENTRY_INFORMATION21 in VARCHAR2,
  p_old_ENTRY_INFORMATION22 in VARCHAR2,
  p_new_ENTRY_INFORMATION22 in VARCHAR2,
  p_old_ENTRY_INFORMATION23 in VARCHAR2,
  p_new_ENTRY_INFORMATION23 in VARCHAR2,
  p_old_ENTRY_INFORMATION24 in VARCHAR2,
  p_new_ENTRY_INFORMATION24 in VARCHAR2,
  p_old_ENTRY_INFORMATION25 in VARCHAR2,
  p_new_ENTRY_INFORMATION25 in VARCHAR2,
  p_old_ENTRY_INFORMATION26 in VARCHAR2,
  p_new_ENTRY_INFORMATION26 in VARCHAR2,
  p_old_ENTRY_INFORMATION27 in VARCHAR2,
  p_new_ENTRY_INFORMATION27 in VARCHAR2,
  p_old_ENTRY_INFORMATION28 in VARCHAR2,
  p_new_ENTRY_INFORMATION28 in VARCHAR2,
  p_old_ENTRY_INFORMATION29 in VARCHAR2,
  p_new_ENTRY_INFORMATION29 in VARCHAR2,
  p_old_ENTRY_INFORMATION3 in VARCHAR2,
  p_new_ENTRY_INFORMATION3 in VARCHAR2,
  p_old_ENTRY_INFORMATION30 in VARCHAR2,
  p_new_ENTRY_INFORMATION30 in VARCHAR2,
  p_old_ENTRY_INFORMATION4 in VARCHAR2,
  p_new_ENTRY_INFORMATION4 in VARCHAR2,
  p_old_ENTRY_INFORMATION5 in VARCHAR2,
  p_new_ENTRY_INFORMATION5 in VARCHAR2,
  p_old_ENTRY_INFORMATION6 in VARCHAR2,
  p_new_ENTRY_INFORMATION6 in VARCHAR2,
  p_old_ENTRY_INFORMATION7 in VARCHAR2,
  p_new_ENTRY_INFORMATION7 in VARCHAR2,
  p_old_ENTRY_INFORMATION8 in VARCHAR2,
  p_new_ENTRY_INFORMATION8 in VARCHAR2,
  p_old_ENTRY_INFORMATION9 in VARCHAR2,
  p_new_ENTRY_INFORMATION9 in VARCHAR2,
  p_old_ENTRY_INFORMATION_CATEGO in VARCHAR2,
  p_new_ENTRY_INFORMATION_CATEGO in VARCHAR2,
  p_old_ORIGINAL_ENTRY_ID in NUMBER,
  p_new_ORIGINAL_ENTRY_ID in NUMBER,
  p_old_PERSONAL_PAYMENT_METHOD_ in NUMBER,
  p_new_PERSONAL_PAYMENT_METHOD_ in NUMBER,
  p_old_REASON in VARCHAR2,
  p_new_REASON in VARCHAR2,
  p_old_SUBPRIORITY in NUMBER,
  p_new_SUBPRIORITY in NUMBER,
  p_old_UPDATING_ACTION_ID in NUMBER,
  p_new_UPDATING_ACTION_ID in NUMBER,
  p_old_ELEMENT_ENTRY_ID in number
  )
  is
  --
  l_proc varchar2(240) := g_package||'.pay_element_entries_f_aru';
BEGIN
--
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates haven't changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE1',
                                     p_old_ATTRIBUTE1,
                                     p_new_ATTRIBUTE1,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE10',
                                     p_old_ATTRIBUTE10,
                                     p_new_ATTRIBUTE10,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE11',
                                     p_old_ATTRIBUTE11,
                                     p_new_ATTRIBUTE11,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE12',
                                     p_old_ATTRIBUTE12,
                                     p_new_ATTRIBUTE12,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE13',
                                     p_old_ATTRIBUTE13,
                                     p_new_ATTRIBUTE13,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE14',
                                     p_old_ATTRIBUTE14,
                                     p_new_ATTRIBUTE14,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE15',
                                     p_old_ATTRIBUTE15,
                                     p_new_ATTRIBUTE15,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE16',
                                     p_old_ATTRIBUTE16,
                                     p_new_ATTRIBUTE16,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE17',
                                     p_old_ATTRIBUTE17,
                                     p_new_ATTRIBUTE17,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE18',
                                     p_old_ATTRIBUTE18,
                                     p_new_ATTRIBUTE18,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE19',
                                     p_old_ATTRIBUTE19,
                                     p_new_ATTRIBUTE19,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE2',
                                     p_old_ATTRIBUTE2,
                                     p_new_ATTRIBUTE2,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE20',
                                     p_old_ATTRIBUTE20,
                                     p_new_ATTRIBUTE20,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE3',
                                     p_old_ATTRIBUTE3,
                                     p_new_ATTRIBUTE3,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE4',
                                     p_old_ATTRIBUTE4,
                                     p_new_ATTRIBUTE4,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE5',
                                     p_old_ATTRIBUTE5,
                                     p_new_ATTRIBUTE5,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE6',
                                     p_old_ATTRIBUTE6,
                                     p_new_ATTRIBUTE6,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE7',
                                     p_old_ATTRIBUTE7,
                                     p_new_ATTRIBUTE7,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE8',
                                     p_old_ATTRIBUTE8,
                                     p_new_ATTRIBUTE8,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE9',
                                     p_old_ATTRIBUTE9,
                                     p_new_ATTRIBUTE9,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ATTRIBUTE_CATEGORY',
                                     p_old_ATTRIBUTE_CATEGORY,
                                     p_new_ATTRIBUTE_CATEGORY,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'COST_ALLOCATION_KEYFLEX_ID',
                                     p_old_COST_ALLOCATION_KEYFLEX,
                                     p_new_COST_ALLOCATION_KEYFLEX,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'DATE_EARNED',
                                     p_old_DATE_EARNED,
                                     p_new_DATE_EARNED,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION1',
                                     p_old_ENTRY_INFORMATION1,
                                     p_new_ENTRY_INFORMATION1,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION10',
                                     p_old_ENTRY_INFORMATION10,
                                     p_new_ENTRY_INFORMATION10,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION11',
                                     p_old_ENTRY_INFORMATION11,
                                     p_new_ENTRY_INFORMATION11,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION12',
                                     p_old_ENTRY_INFORMATION12,
                                     p_new_ENTRY_INFORMATION12,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION13',
                                     p_old_ENTRY_INFORMATION13,
                                     p_new_ENTRY_INFORMATION13,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION14',
                                     p_old_ENTRY_INFORMATION14,
                                     p_new_ENTRY_INFORMATION14,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION15',
                                     p_old_ENTRY_INFORMATION15,
                                     p_new_ENTRY_INFORMATION15,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION16',
                                     p_old_ENTRY_INFORMATION16,
                                     p_new_ENTRY_INFORMATION16,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION17',
                                     p_old_ENTRY_INFORMATION17,
                                     p_new_ENTRY_INFORMATION17,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION18',
                                     p_old_ENTRY_INFORMATION18,
                                     p_new_ENTRY_INFORMATION18,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION19',
                                     p_old_ENTRY_INFORMATION19,
                                     p_new_ENTRY_INFORMATION19,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION2',
                                     p_old_ENTRY_INFORMATION2,
                                     p_new_ENTRY_INFORMATION2,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION20',
                                     p_old_ENTRY_INFORMATION20,
                                     p_new_ENTRY_INFORMATION20,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION21',
                                       p_old_ENTRY_INFORMATION21,
                                     p_new_ENTRY_INFORMATION21,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION22',
                                     p_old_ENTRY_INFORMATION22,
                                     p_new_ENTRY_INFORMATION22,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION23',
                                     p_old_ENTRY_INFORMATION23,
                                     p_new_ENTRY_INFORMATION23,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION24',
                                     p_old_ENTRY_INFORMATION24,
                                     p_new_ENTRY_INFORMATION24,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION25',
                                     p_old_ENTRY_INFORMATION25,
                                     p_new_ENTRY_INFORMATION25,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION26',
                                     p_old_ENTRY_INFORMATION26,
                                     p_new_ENTRY_INFORMATION26,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION27',
                                     p_old_ENTRY_INFORMATION27,
                                     p_new_ENTRY_INFORMATION27,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION28',
                                     p_old_ENTRY_INFORMATION28,
                                     p_new_ENTRY_INFORMATION28,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION29',
                                     p_old_ENTRY_INFORMATION29,
                                     p_new_ENTRY_INFORMATION29,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION3',
                                     p_old_ENTRY_INFORMATION3,
                                     p_new_ENTRY_INFORMATION3,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION30',
                                     p_old_ENTRY_INFORMATION30,
                                     p_new_ENTRY_INFORMATION30,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION4',
                                     p_old_ENTRY_INFORMATION4,
                                     p_new_ENTRY_INFORMATION4,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION5',
                                     p_old_ENTRY_INFORMATION5,
                                     p_new_ENTRY_INFORMATION5,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION6',
                                     p_old_ENTRY_INFORMATION6,
                                     p_new_ENTRY_INFORMATION6,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION7',
                                     p_old_ENTRY_INFORMATION7,
                                     p_new_ENTRY_INFORMATION7,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION8',
                                     p_old_ENTRY_INFORMATION8,
                                     p_new_ENTRY_INFORMATION8,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION9',
                                     p_old_ENTRY_INFORMATION9,
                                     p_new_ENTRY_INFORMATION9,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ENTRY_INFORMATION_CATEGORY',
                                     p_old_ENTRY_INFORMATION_CATEGO,
                                     p_new_ENTRY_INFORMATION_CATEGO,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'ORIGINAL_ENTRY_ID',
                                     p_old_ORIGINAL_ENTRY_ID,
                                     p_new_ORIGINAL_ENTRY_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'PERSONAL_PAYMENT_METHOD_ID',
                                     p_old_PERSONAL_PAYMENT_METHOD_,
                                     p_new_PERSONAL_PAYMENT_METHOD_,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'REASON',
                                     p_old_REASON,
                                     p_new_REASON,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'SUBPRIORITY',
                                     p_old_SUBPRIORITY,
                                     p_new_SUBPRIORITY,
                                     p_effective_date
                                    );
  else
    /* OK it must be a date track change */
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                    );
  end if;
--
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                p_assignment_id         => p_old_ASSIGNMENT_ID,
                p_effective_date        => g_event_list.effective_date(cnt),
                p_change_type           => g_event_list.change_type(cnt),
                p_status                => 'U',
                p_description           => g_event_list.description(cnt),
                p_process_event_id      => l_process_event_id,
                p_object_version_number => l_object_version_number,
                p_event_update_id       => g_event_list.event_update_id(cnt),
                p_surrogate_key         => p_old_ELEMENT_ENTRY_ID,
                p_calculation_date      => g_event_list.calc_date(cnt),
                p_business_group_id     => p_business_group_id
                );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
  hr_utility.set_location(l_proc, 900);
--
end PAY_ELEMENT_ENTRIES_F_aru;
--

/* name : element_entries_ari
   purpose : This is procedure that records any inserts
             on element_entries.
*/

  procedure element_entries_ari(
                                p_business_group_id in number,
                                p_legislation_code in varchar2,
                                p_assignment_id in number,
                                p_effective_start_date in date,
                                p_updating_action_id in number,
                                p_new_element_entry_id in number
                               )
  is
    l_process_api boolean;
    l_process_event_id number;
    l_object_version_number number;
    l_proc varchar2(240) := g_package||'.element_entries_ari';
  begin
--
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'I'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                p_assignment_id         => p_assignment_id,
                p_effective_date        => g_event_list.effective_date(cnt),
                p_change_type           => g_event_list.change_type(cnt),
                p_status                => 'U',
                p_description           => g_event_list.description(cnt),
                p_process_event_id      => l_process_event_id,
                p_object_version_number => l_object_version_number,
                p_event_update_id       => g_event_list.event_update_id(cnt),
                p_surrogate_key         => p_new_ELEMENT_ENTRY_ID,
                p_calculation_date      => g_event_list.calc_date(cnt),
                p_business_group_id     => p_business_group_id
                );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
  hr_utility.set_location(l_proc, 900);
  end element_entries_ari;
--

/* name : element_entries_ard
   purpose : This is procedure that records any deletes
             on element_entries.
*/
  procedure element_entries_ard(
                                p_business_group_id in number,
                                p_legislation_code in varchar2,
                                p_assignment_id in number,
                                p_old_ELEMENT_ENTRY_ID in number,
                                p_old_effective_start_date in date,
                                p_new_effective_start_date in date,
                                p_old_effective_end_date in date,
                                p_new_effective_end_date in date,
                                p_old_ELEMENT_TYPE_ID in number default null
                               )
  is
    l_process_event_id number;
    l_object_version_number number;
    l_effective_date date;
    l_mode pay_event_updates.event_type%type;
    l_column_name pay_event_updates.column_name%type;
    l_old_value      date;
    l_new_value      date;
    l_noted_value    pay_process_events.noted_value%type;
    l_proc varchar2(240) := g_package||'.element_entries_ard';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
    l_noted_value := null;
--
    if (   pay_dyn_triggers.g_dyt_mode = pay_dyn_triggers.g_dbms_dyt
        or pay_dyn_triggers.g_dyt_mode = 'ZAP') then
--
      if (   pay_dyn_triggers.g_dyt_mode = pay_dyn_triggers.g_dbms_dyt) then
        l_mode := 'D';
      else
        l_mode := pay_dyn_triggers.g_dyt_mode;
      end if;
      l_effective_date := p_old_effective_start_date;
      l_column_name := null;
      l_old_value   := null;
      l_new_value   := null;
      l_noted_value := p_old_ELEMENT_TYPE_ID;
--
    else
      l_mode := pay_dyn_triggers.g_dyt_mode;
      if (pay_dyn_triggers.g_dyt_mode = 'DELETE') then
--
         l_effective_date := p_new_effective_end_date;
         l_column_name := 'EFFECTIVE_END_DATE';
         l_old_value   := p_old_effective_end_date;
         l_new_value   := p_new_effective_end_date;
--
      elsif (pay_dyn_triggers.g_dyt_mode = 'FUTURE_CHANGE'
            or pay_dyn_triggers.g_dyt_mode = 'DELETE_NEXT_CHANGE') then
--
         l_effective_date := p_old_effective_start_date;
         l_column_name := 'EFFECTIVE_END_DATE';
         l_old_value   := p_old_effective_end_date;
         l_new_value   := p_new_effective_end_date;
--
      end if;
    end if;
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_ENTRIES_F',
                                     l_column_name,
                                     l_old_value,
                                     l_new_value,
                                     l_effective_date,
                                     l_effective_date,
                                     l_mode
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                p_assignment_id         => p_assignment_id,
                p_effective_date        => g_event_list.effective_date(cnt),
                p_change_type           => g_event_list.change_type(cnt),
                p_status                => 'U',
                p_description           => g_event_list.description(cnt),
                p_process_event_id      => l_process_event_id,
                p_object_version_number => l_object_version_number,
                p_event_update_id       => g_event_list.event_update_id(cnt),
                p_surrogate_key         => p_old_ELEMENT_ENTRY_ID,
                p_calculation_date      => g_event_list.calc_date(cnt),
                p_business_group_id     => p_business_group_id,
                p_noted_value           => l_noted_value
                );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
  hr_utility.set_location(l_proc, 900);
  end element_entries_ard;

--------------------------------------------
-- PAY_ELEMENT_ENTRY_VALUES_F
--------------------------------------------
/* PAY_ELEMENT_ENTRY_VALUES_F */
/* name : PAY_ELEMENT_ENTRY_VALUES_F_aru
   purpose : This is procedure that records any changes for updates
             on element_entry_values.
*/
procedure PAY_ELEMENT_ENTRY_VALUES_F_aru(
  p_business_group_id in number,
  p_legislation_code in varchar2,
  p_effective_date in date,
  p_old_ELEMENT_ENTRY_ID in NUMBER,
  p_new_ELEMENT_ENTRY_ID in NUMBER,
  p_old_SCREEN_ENTRY_VALUE in VARCHAR2,
  p_new_SCREEN_ENTRY_VALUE in VARCHAR2,
  p_old_ELEMENT_ENTRY_VALUE_ID in NUMBER
)
is
--
 cursor get_asg is
 select ee.assignment_id
   from pay_element_entries_f ee
  where ee.element_entry_id = p_old_ELEMENT_ENTRY_ID
    and p_effective_date between ee.effective_start_date
                             and ee.effective_end_date;
--
begin
  hr_utility.set_location('pay_cc_dyt_code_pkg.PAY_ELEMENT_ENTRY_VALUES_F_aru', 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
  pay_continuous_calc.event_update(p_business_group_id,
                                   p_legislation_code,
                                   'PAY_ELEMENT_ENTRY_VALUES_F',
                                   'SCREEN_ENTRY_VALUE',
                                   p_old_SCREEN_ENTRY_VALUE,
                                   p_new_SCREEN_ENTRY_VALUE,
                                   p_effective_date,
                                   p_effective_date
                                  );
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for asgrec in get_asg loop
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                p_assignment_id         => asgrec.assignment_id,
                p_effective_date        => g_event_list.effective_date(cnt),
                p_change_type           => g_event_list.change_type(cnt),
                p_status                => 'U',
                p_description           => g_event_list.description(cnt),
                p_process_event_id      => l_process_event_id,
                p_object_version_number => l_object_version_number,
                p_event_update_id       => g_event_list.event_update_id(cnt),
                p_business_group_id     => p_business_group_id,
                p_calculation_date      => g_event_list.calc_date(cnt),
                p_surrogate_key         => p_old_ELEMENT_ENTRY_VALUE_ID
                );
         end loop;
       end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
   hr_utility.set_location('pay_cc_dyt_code_pkg.PAY_ELEMENT_ENTRY_VALUES_F_aru', 50);
--
end PAY_ELEMENT_ENTRY_VALUES_F_aru;
--

--------------------------------------------
-- PER_CONTRACTS_F
--------------------------------------------
procedure PER_CONTRACTS_F_aru(
    p_business_group_id in number,
    p_legislation_code in varchar2,
    p_effective_date in date ,
    p_old_ATTRIBUTE1 in VARCHAR2,
    p_new_ATTRIBUTE1 in VARCHAR2 ,
    p_old_ATTRIBUTE10 in VARCHAR2,
    p_new_ATTRIBUTE10 in VARCHAR2 ,
    p_old_ATTRIBUTE11 in VARCHAR2,
    p_new_ATTRIBUTE11 in VARCHAR2 ,
    p_old_ATTRIBUTE12 in VARCHAR2,
    p_new_ATTRIBUTE12 in VARCHAR2 ,
    p_old_ATTRIBUTE13 in VARCHAR2,
    p_new_ATTRIBUTE13 in VARCHAR2 ,
    p_old_ATTRIBUTE14 in VARCHAR2,
    p_new_ATTRIBUTE14 in VARCHAR2 ,
    p_old_ATTRIBUTE15 in VARCHAR2,
    p_new_ATTRIBUTE15 in VARCHAR2 ,
    p_old_ATTRIBUTE16 in VARCHAR2,
    p_new_ATTRIBUTE16 in VARCHAR2 ,
    p_old_ATTRIBUTE17 in VARCHAR2,
    p_new_ATTRIBUTE17 in VARCHAR2 ,
    p_old_ATTRIBUTE18 in VARCHAR2,
    p_new_ATTRIBUTE18 in VARCHAR2 ,
    p_old_ATTRIBUTE19 in VARCHAR2,
    p_new_ATTRIBUTE19 in VARCHAR2 ,
    p_old_ATTRIBUTE2 in VARCHAR2,
    p_new_ATTRIBUTE2 in VARCHAR2 ,
    p_old_ATTRIBUTE20 in VARCHAR2,
    p_new_ATTRIBUTE20 in VARCHAR2 ,
    p_old_ATTRIBUTE3 in VARCHAR2,
    p_new_ATTRIBUTE3 in VARCHAR2 ,
    p_old_ATTRIBUTE4 in VARCHAR2,
    p_new_ATTRIBUTE4 in VARCHAR2 ,
    p_old_ATTRIBUTE5 in VARCHAR2,
    p_new_ATTRIBUTE5 in VARCHAR2 ,
    p_old_ATTRIBUTE6 in VARCHAR2,
    p_new_ATTRIBUTE6 in VARCHAR2 ,
    p_old_ATTRIBUTE7 in VARCHAR2,
    p_new_ATTRIBUTE7 in VARCHAR2 ,
    p_old_ATTRIBUTE8 in VARCHAR2,
    p_new_ATTRIBUTE8 in VARCHAR2 ,
    p_old_ATTRIBUTE9 in VARCHAR2,
    p_new_ATTRIBUTE9 in VARCHAR2 ,
    p_old_ATTRIBUTE_CATEGORY in VARCHAR2,
    p_new_ATTRIBUTE_CATEGORY in VARCHAR2 ,
    p_old_BUSINESS_GROUP_ID in NUMBER,
    p_new_BUSINESS_GROUP_ID in NUMBER ,
    p_old_CONTRACTUAL_JOB_TITLE in VARCHAR2,
    p_new_CONTRACTUAL_JOB_TITLE in VARCHAR2 ,
    p_old_CONTRACT_ID in NUMBER,
    p_new_CONTRACT_ID in NUMBER ,
    p_old_CTR_INFORMATION1 in VARCHAR2,
    p_new_CTR_INFORMATION1 in VARCHAR2 ,
    p_old_CTR_INFORMATION10 in VARCHAR2,
    p_new_CTR_INFORMATION10 in VARCHAR2 ,
    p_old_CTR_INFORMATION11 in VARCHAR2,
    p_new_CTR_INFORMATION11 in VARCHAR2 ,
    p_old_CTR_INFORMATION12 in VARCHAR2,
    p_new_CTR_INFORMATION12 in VARCHAR2 ,
    p_old_CTR_INFORMATION13 in VARCHAR2,
    p_new_CTR_INFORMATION13 in VARCHAR2 ,
    p_old_CTR_INFORMATION14 in VARCHAR2,
    p_new_CTR_INFORMATION14 in VARCHAR2 ,
    p_old_CTR_INFORMATION15 in VARCHAR2,
    p_new_CTR_INFORMATION15 in VARCHAR2 ,
    p_old_CTR_INFORMATION16 in VARCHAR2,
    p_new_CTR_INFORMATION16 in VARCHAR2 ,
    p_old_CTR_INFORMATION17 in VARCHAR2,
    p_new_CTR_INFORMATION17 in VARCHAR2 ,
    p_old_CTR_INFORMATION18 in VARCHAR2,
    p_new_CTR_INFORMATION18 in VARCHAR2 ,
    p_old_CTR_INFORMATION19 in VARCHAR2,
    p_new_CTR_INFORMATION19 in VARCHAR2 ,
    p_old_CTR_INFORMATION2 in VARCHAR2,
    p_new_CTR_INFORMATION2 in VARCHAR2 ,
    p_old_CTR_INFORMATION20 in VARCHAR2,
    p_new_CTR_INFORMATION20 in VARCHAR2 ,
    p_old_CTR_INFORMATION3 in VARCHAR2,
    p_new_CTR_INFORMATION3 in VARCHAR2 ,
    p_old_CTR_INFORMATION4 in VARCHAR2,
    p_new_CTR_INFORMATION4 in VARCHAR2 ,
    p_old_CTR_INFORMATION5 in VARCHAR2,
    p_new_CTR_INFORMATION5 in VARCHAR2 ,
    p_old_CTR_INFORMATION6 in VARCHAR2,
    p_new_CTR_INFORMATION6 in VARCHAR2 ,
    p_old_CTR_INFORMATION7 in VARCHAR2,
    p_new_CTR_INFORMATION7 in VARCHAR2 ,
    p_old_CTR_INFORMATION8 in VARCHAR2,
    p_new_CTR_INFORMATION8 in VARCHAR2 ,
    p_old_CTR_INFORMATION9 in VARCHAR2,
    p_new_CTR_INFORMATION9 in VARCHAR2 ,
    p_old_CTR_INFORMATION_CATEGORY in VARCHAR2,
    p_new_CTR_INFORMATION_CATEGORY in VARCHAR2 ,
    p_old_DESCRIPTION in VARCHAR2,
    p_new_DESCRIPTION in VARCHAR2 ,
    p_old_DOC_STATUS in VARCHAR2,
    p_new_DOC_STATUS in VARCHAR2 ,
    p_old_DOC_STATUS_CHANGE_DATE in DATE,
    p_new_DOC_STATUS_CHANGE_DATE in DATE ,
    p_old_DURATION in NUMBER,
    p_new_DURATION in NUMBER ,
    p_old_DURATION_UNITS in VARCHAR2,
    p_new_DURATION_UNITS in VARCHAR2 ,
    p_old_END_REASON in VARCHAR2,
    p_new_END_REASON in VARCHAR2 ,
    p_old_EXTENSION_PERIOD in NUMBER,
    p_new_EXTENSION_PERIOD in NUMBER ,
    p_old_EXTENSION_PERIOD_UNITS in VARCHAR2,
    p_new_EXTENSION_PERIOD_UNITS in VARCHAR2 ,
    p_old_EXTENSION_REASON in VARCHAR2,
    p_new_EXTENSION_REASON in VARCHAR2 ,
    p_old_NUMBER_OF_EXTENSIONS in NUMBER,
    p_new_NUMBER_OF_EXTENSIONS in NUMBER ,
    p_old_PARTIES in VARCHAR2,
    p_new_PARTIES in VARCHAR2 ,
    p_old_PERSON_ID in NUMBER,
    p_new_PERSON_ID in NUMBER ,
    p_old_REFERENCE in VARCHAR2,
    p_new_REFERENCE in VARCHAR2 ,
    p_old_START_REASON in VARCHAR2,
    p_new_START_REASON in VARCHAR2 ,
    p_old_STATUS in VARCHAR2,
    p_new_STATUS in VARCHAR2 ,
    p_old_STATUS_REASON in VARCHAR2,
    p_new_STATUS_REASON in VARCHAR2 ,
    p_old_TYPE in VARCHAR2,
    p_new_TYPE in VARCHAR2 ,
    p_old_EFFECTIVE_END_DATE in DATE,
    p_new_EFFECTIVE_END_DATE in DATE ,
    p_old_EFFECTIVE_START_DATE in DATE,
    p_new_EFFECTIVE_START_DATE in DATE

)
is
--
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_assignments_f
   where person_id = p_person_id;
--
begin
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE1',
                                     p_old_ATTRIBUTE1,
                                     p_new_ATTRIBUTE1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE10',
                                     p_old_ATTRIBUTE10,
                                     p_new_ATTRIBUTE10,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE11',
                                     p_old_ATTRIBUTE11,
                                     p_new_ATTRIBUTE11,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE12',
                                     p_old_ATTRIBUTE12,
                                     p_new_ATTRIBUTE12,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE13',
                                     p_old_ATTRIBUTE13,
                                     p_new_ATTRIBUTE13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE14',
                                     p_old_ATTRIBUTE14,
                                     p_new_ATTRIBUTE14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE15',
                                     p_old_ATTRIBUTE15,
                                     p_new_ATTRIBUTE15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE16',
                                     p_old_ATTRIBUTE16,
                                     p_new_ATTRIBUTE16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE17',
                                     p_old_ATTRIBUTE17,
                                     p_new_ATTRIBUTE17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE18',
                                     p_old_ATTRIBUTE18,
                                     p_new_ATTRIBUTE18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE19',
                                     p_old_ATTRIBUTE19,
                                     p_new_ATTRIBUTE19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE2',
                                     p_old_ATTRIBUTE2,
                                     p_new_ATTRIBUTE2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE20',
                                     p_old_ATTRIBUTE20,
                                     p_new_ATTRIBUTE20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE3',
                                     p_old_ATTRIBUTE3,
                                     p_new_ATTRIBUTE3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE4',
                                     p_old_ATTRIBUTE4,
                                     p_new_ATTRIBUTE4,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE5',
                                     p_old_ATTRIBUTE5,
                                     p_new_ATTRIBUTE5,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE6',
                                     p_old_ATTRIBUTE6,
                                     p_new_ATTRIBUTE6,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE7',
                                     p_old_ATTRIBUTE7,
                                     p_new_ATTRIBUTE7,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE8',
                                     p_old_ATTRIBUTE8,
                                     p_new_ATTRIBUTE8,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE9',
                                     p_old_ATTRIBUTE9,
                                     p_new_ATTRIBUTE9,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'ATTRIBUTE_CATEGORY',
                                     p_old_ATTRIBUTE_CATEGORY,
                                     p_new_ATTRIBUTE_CATEGORY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'BUSINESS_GROUP_ID',
                                     p_old_BUSINESS_GROUP_ID,
                                     p_new_BUSINESS_GROUP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CONTRACTUAL_JOB_TITLE',
                                     p_old_CONTRACTUAL_JOB_TITLE,
                                     p_new_CONTRACTUAL_JOB_TITLE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CONTRACT_ID',
                                     p_old_CONTRACT_ID,
                                     p_new_CONTRACT_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION1',
                                     p_old_CTR_INFORMATION1,
                                     p_new_CTR_INFORMATION1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION10',
                                     p_old_CTR_INFORMATION10,
                                     p_new_CTR_INFORMATION10,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION11',
                                     p_old_CTR_INFORMATION11,
                                     p_new_CTR_INFORMATION11,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION12',
                                     p_old_CTR_INFORMATION12,
                                     p_new_CTR_INFORMATION12,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION13',
                                     p_old_CTR_INFORMATION13,
                                     p_new_CTR_INFORMATION13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION14',
                                     p_old_CTR_INFORMATION14,
                                     p_new_CTR_INFORMATION14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION15',
                                     p_old_CTR_INFORMATION15,
                                     p_new_CTR_INFORMATION15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION16',
                                     p_old_CTR_INFORMATION16,
                                     p_new_CTR_INFORMATION16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION17',
                                     p_old_CTR_INFORMATION17,
                                     p_new_CTR_INFORMATION17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION18',
                                     p_old_CTR_INFORMATION18,
                                     p_new_CTR_INFORMATION18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION19',
                                     p_old_CTR_INFORMATION19,
                                     p_new_CTR_INFORMATION19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION2',
                                     p_old_CTR_INFORMATION2,
                                     p_new_CTR_INFORMATION2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION20',
                                     p_old_CTR_INFORMATION20,
                                     p_new_CTR_INFORMATION20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION3',
                                     p_old_CTR_INFORMATION3,
                                     p_new_CTR_INFORMATION3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION4',
                                     p_old_CTR_INFORMATION4,
                                     p_new_CTR_INFORMATION4,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION5',
                                     p_old_CTR_INFORMATION5,
                                     p_new_CTR_INFORMATION5,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION6',
                                     p_old_CTR_INFORMATION6,
                                     p_new_CTR_INFORMATION6,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION7',
                                     p_old_CTR_INFORMATION7,
                                     p_new_CTR_INFORMATION7,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION8',
                                     p_old_CTR_INFORMATION8,
                                     p_new_CTR_INFORMATION8,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION9',
                                     p_old_CTR_INFORMATION9,
                                     p_new_CTR_INFORMATION9,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'CTR_INFORMATION_CATEGORY',
                                     p_old_CTR_INFORMATION_CATEGORY,
                                     p_new_CTR_INFORMATION_CATEGORY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'DESCRIPTION',
                                     p_old_DESCRIPTION,
                                     p_new_DESCRIPTION,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'DOC_STATUS',
                                     p_old_DOC_STATUS,
                                     p_new_DOC_STATUS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'DOC_STATUS_CHANGE_DATE',
                                     p_old_DOC_STATUS_CHANGE_DATE,
                                     p_new_DOC_STATUS_CHANGE_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'DURATION',
                                     p_old_DURATION,
                                     p_new_DURATION,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'DURATION_UNITS',
                                     p_old_DURATION_UNITS,
                                     p_new_DURATION_UNITS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'END_REASON',
                                     p_old_END_REASON,
                                     p_new_END_REASON,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'EXTENSION_PERIOD',
                                     p_old_EXTENSION_PERIOD,
                                     p_new_EXTENSION_PERIOD,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'EXTENSION_PERIOD_UNITS',
                                     p_old_EXTENSION_PERIOD_UNITS,
                                     p_new_EXTENSION_PERIOD_UNITS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'EXTENSION_REASON',
                                     p_old_EXTENSION_REASON,
                                     p_new_EXTENSION_REASON,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'NUMBER_OF_EXTENSIONS',
                                     p_old_NUMBER_OF_EXTENSIONS,
                                     p_new_NUMBER_OF_EXTENSIONS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'PARTIES',
                                     p_old_PARTIES,
                                     p_new_PARTIES,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'PERSON_ID',
                                     p_old_PERSON_ID,
                                     p_new_PERSON_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'REFERENCE',
                                     p_old_REFERENCE,
                                     p_new_REFERENCE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'START_REASON',
                                     p_old_START_REASON,
                                     p_new_START_REASON,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'STATUS',
                                     p_old_STATUS,
                                     p_new_STATUS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'STATUS_REASON',
                                     p_old_STATUS_REASON,
                                     p_new_STATUS_REASON,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'TYPE',
                                     p_old_TYPE,
                                     p_new_TYPE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'TYPE',
                                     p_old_TYPE,
                                     p_new_TYPE,
                                     p_effective_date
                                  );
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTRACTS_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                  );

  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for asgrec in asgcur (p_old_PERSON_ID) loop
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                p_assignment_id         => asgrec.assignment_id,
                p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
                p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
                p_status                => 'U',
                p_description           => pay_continuous_calc.g_event_list.description(cnt),
                p_process_event_id      => l_process_event_id,
                p_object_version_number => l_object_version_number,
                p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
                p_business_group_id     => p_business_group_id,
                p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
                p_surrogate_key         => p_new_contract_id
           );
         end loop;
       end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
end PER_CONTRACTS_F_aru;


--
/* Used generator to build this procedure, but removed some of that table values.
*/
/* PER_ALL_ASSIGNMENTS */
/* name : PER_ALL_ASSIGNMENTS_F_aru
   purpose : This is procedure that records any updates
             on assignments.
*/
procedure PER_ALL_ASSIGNMENTS_F_aru(
p_business_group_id in number,
p_legislation_code in varchar2,
p_effective_date in date,
p_old_APPLICATION_ID in NUMBER,
p_new_APPLICATION_ID in NUMBER,
p_old_ASSIGNMENT_ID in NUMBER,
p_new_ASSIGNMENT_ID in NUMBER,
p_old_ASSIGNMENT_NUMBER in VARCHAR2,
p_new_ASSIGNMENT_NUMBER in VARCHAR2,
p_old_ASSIGNMENT_SEQUENCE in NUMBER,
p_new_ASSIGNMENT_SEQUENCE in NUMBER,
p_old_ASSIGNMENT_STATUS_TYPE_I in NUMBER,
p_new_ASSIGNMENT_STATUS_TYPE_I in NUMBER,
p_old_ASSIGNMENT_TYPE in VARCHAR2,
p_new_ASSIGNMENT_TYPE in VARCHAR2,
p_old_ASS_ATTRIBUTE1 in VARCHAR2,
p_new_ASS_ATTRIBUTE1 in VARCHAR2,
p_old_ASS_ATTRIBUTE10 in VARCHAR2,
p_new_ASS_ATTRIBUTE10 in VARCHAR2,
p_old_ASS_ATTRIBUTE11 in VARCHAR2,
p_new_ASS_ATTRIBUTE11 in VARCHAR2,
p_old_ASS_ATTRIBUTE12 in VARCHAR2,
p_new_ASS_ATTRIBUTE12 in VARCHAR2,
p_old_ASS_ATTRIBUTE13 in VARCHAR2,
p_new_ASS_ATTRIBUTE13 in VARCHAR2,
p_old_ASS_ATTRIBUTE14 in VARCHAR2,
p_new_ASS_ATTRIBUTE14 in VARCHAR2,
p_old_ASS_ATTRIBUTE15 in VARCHAR2,
p_new_ASS_ATTRIBUTE15 in VARCHAR2,
p_old_ASS_ATTRIBUTE16 in VARCHAR2,
p_new_ASS_ATTRIBUTE16 in VARCHAR2,
p_old_ASS_ATTRIBUTE17 in VARCHAR2,
p_new_ASS_ATTRIBUTE17 in VARCHAR2,
p_old_ASS_ATTRIBUTE18 in VARCHAR2,
p_new_ASS_ATTRIBUTE18 in VARCHAR2,
p_old_ASS_ATTRIBUTE19 in VARCHAR2,
p_new_ASS_ATTRIBUTE19 in VARCHAR2,
p_old_ASS_ATTRIBUTE2 in VARCHAR2,
p_new_ASS_ATTRIBUTE2 in VARCHAR2,
p_old_ASS_ATTRIBUTE20 in VARCHAR2,
p_new_ASS_ATTRIBUTE20 in VARCHAR2,
p_old_ASS_ATTRIBUTE21 in VARCHAR2,
p_new_ASS_ATTRIBUTE21 in VARCHAR2,
p_old_ASS_ATTRIBUTE22 in VARCHAR2,
p_new_ASS_ATTRIBUTE22 in VARCHAR2,
p_old_ASS_ATTRIBUTE23 in VARCHAR2,
p_new_ASS_ATTRIBUTE23 in VARCHAR2,
p_old_ASS_ATTRIBUTE24 in VARCHAR2,
p_new_ASS_ATTRIBUTE24 in VARCHAR2,
p_old_ASS_ATTRIBUTE25 in VARCHAR2,
p_new_ASS_ATTRIBUTE25 in VARCHAR2,
p_old_ASS_ATTRIBUTE26 in VARCHAR2,
p_new_ASS_ATTRIBUTE26 in VARCHAR2,
p_old_ASS_ATTRIBUTE27 in VARCHAR2,
p_new_ASS_ATTRIBUTE27 in VARCHAR2,
p_old_ASS_ATTRIBUTE28 in VARCHAR2,
p_new_ASS_ATTRIBUTE28 in VARCHAR2,
p_old_ASS_ATTRIBUTE29 in VARCHAR2,
p_new_ASS_ATTRIBUTE29 in VARCHAR2,
p_old_ASS_ATTRIBUTE3 in VARCHAR2,
p_new_ASS_ATTRIBUTE3 in VARCHAR2,
p_old_ASS_ATTRIBUTE30 in VARCHAR2,
p_new_ASS_ATTRIBUTE30 in VARCHAR2,
p_old_ASS_ATTRIBUTE4 in VARCHAR2,
p_new_ASS_ATTRIBUTE4 in VARCHAR2,
p_old_ASS_ATTRIBUTE5 in VARCHAR2,
p_new_ASS_ATTRIBUTE5 in VARCHAR2,
p_old_ASS_ATTRIBUTE6 in VARCHAR2,
p_new_ASS_ATTRIBUTE6 in VARCHAR2,
p_old_ASS_ATTRIBUTE7 in VARCHAR2,
p_new_ASS_ATTRIBUTE7 in VARCHAR2,
p_old_ASS_ATTRIBUTE8 in VARCHAR2,
p_new_ASS_ATTRIBUTE8 in VARCHAR2,
p_old_ASS_ATTRIBUTE9 in VARCHAR2,
p_new_ASS_ATTRIBUTE9 in VARCHAR2,
p_old_ASS_ATTRIBUTE_CATEGORY in VARCHAR2,
p_new_ASS_ATTRIBUTE_CATEGORY in VARCHAR2,
p_old_BARGAINING_UNIT_CODE in VARCHAR2,
p_new_BARGAINING_UNIT_CODE in VARCHAR2,
p_old_BUSINESS_GROUP_ID in NUMBER,
p_new_BUSINESS_GROUP_ID in NUMBER,
p_old_CAGR_GRADE_DEF_ID in NUMBER,
p_new_CAGR_GRADE_DEF_ID in NUMBER,
p_old_CAGR_ID_FLEX_NUM in NUMBER,
p_new_CAGR_ID_FLEX_NUM in NUMBER,
p_old_CHANGE_REASON in VARCHAR2,
p_new_CHANGE_REASON in VARCHAR2,
p_old_COLLECTIVE_AGREEMENT_ID in NUMBER,
p_new_COLLECTIVE_AGREEMENT_ID in NUMBER,
p_old_COMMENT_ID in NUMBER,
p_new_COMMENT_ID in NUMBER,
p_old_CONTRACT_ID in NUMBER,
p_new_CONTRACT_ID in NUMBER,
p_old_DATE_PROBATION_END in DATE,
p_new_DATE_PROBATION_END in DATE,
p_old_DEFAULT_CODE_COMB_ID in NUMBER,
p_new_DEFAULT_CODE_COMB_ID in NUMBER,
p_old_EFFECTIVE_END_DATE in DATE,
p_new_EFFECTIVE_END_DATE in DATE,
p_old_EFFECTIVE_START_DATE in DATE,
p_new_EFFECTIVE_START_DATE in DATE,
p_old_EMPLOYMENT_CATEGORY in VARCHAR2,
p_new_EMPLOYMENT_CATEGORY in VARCHAR2,
p_old_ESTABLISHMENT_ID in NUMBER,
p_new_ESTABLISHMENT_ID in NUMBER,
p_old_FREQUENCY in VARCHAR2,
p_new_FREQUENCY in VARCHAR2,
p_old_GRADE_ID in NUMBER,
p_new_GRADE_ID in NUMBER,
p_old_HOURLY_SALARIED_CODE in VARCHAR2,
p_new_HOURLY_SALARIED_CODE in VARCHAR2,
p_old_INTERNAL_ADDRESS_LINE in VARCHAR2,
p_new_INTERNAL_ADDRESS_LINE in VARCHAR2,
p_old_JOB_ID in NUMBER,
p_new_JOB_ID in NUMBER,
p_old_LABOUR_UNION_MEMBER_FLAG in VARCHAR2,
p_new_LABOUR_UNION_MEMBER_FLAG in VARCHAR2,
p_old_LOCATION_ID in NUMBER,
p_new_LOCATION_ID in NUMBER,
p_old_MANAGER_FLAG in VARCHAR2,
p_new_MANAGER_FLAG in VARCHAR2,
p_old_NORMAL_HOURS in NUMBER,
p_new_NORMAL_HOURS in NUMBER,
p_old_OBJECT_VERSION_NUMBER in NUMBER,
p_new_OBJECT_VERSION_NUMBER in NUMBER,
p_old_ORGANIZATION_ID in NUMBER,
p_new_ORGANIZATION_ID in NUMBER,
p_old_PAYROLL_ID in NUMBER,
p_new_PAYROLL_ID in NUMBER,
p_old_PAY_BASIS_ID in NUMBER,
p_new_PAY_BASIS_ID in NUMBER,
p_old_PEOPLE_GROUP_ID in NUMBER,
p_new_PEOPLE_GROUP_ID in NUMBER,
p_old_PERF_REVIEW_PERIOD in NUMBER,
p_new_PERF_REVIEW_PERIOD in NUMBER,
p_old_PERF_REVIEW_PERIOD_FREQU in VARCHAR2,
p_new_PERF_REVIEW_PERIOD_FREQU in VARCHAR2,
p_old_PERIOD_OF_SERVICE_ID in NUMBER,
p_new_PERIOD_OF_SERVICE_ID in NUMBER,
p_old_PERSON_ID in NUMBER,
p_new_PERSON_ID in NUMBER,
p_old_PERSON_REFERRED_BY_ID in NUMBER,
p_new_PERSON_REFERRED_BY_ID in NUMBER,
p_old_POSITION_ID in NUMBER,
p_new_POSITION_ID in NUMBER,
p_old_PRIMARY_FLAG in VARCHAR2,
p_new_PRIMARY_FLAG in VARCHAR2,
p_old_PROBATION_PERIOD in NUMBER,
p_new_PROBATION_PERIOD in NUMBER,
p_old_PROBATION_UNIT in VARCHAR2,
p_new_PROBATION_UNIT in VARCHAR2,
p_old_PROGRAM_APPLICATION_ID in NUMBER,
p_new_PROGRAM_APPLICATION_ID in NUMBER,
p_old_PROGRAM_ID in NUMBER,
p_new_PROGRAM_ID in NUMBER,
p_old_PROGRAM_UPDATE_DATE in DATE,
p_new_PROGRAM_UPDATE_DATE in DATE,
p_old_RECRUITER_ID in NUMBER,
p_new_RECRUITER_ID in NUMBER,
p_old_RECRUITMENT_ACTIVITY_ID in NUMBER,
p_new_RECRUITMENT_ACTIVITY_ID in NUMBER,
p_old_REQUEST_ID in NUMBER,
p_new_REQUEST_ID in NUMBER,
p_old_SAL_REVIEW_PERIOD in NUMBER,
p_new_SAL_REVIEW_PERIOD in NUMBER,
p_old_SAL_REVIEW_PERIOD_FREQUE in VARCHAR2,
p_new_SAL_REVIEW_PERIOD_FREQUE in VARCHAR2,
p_old_SET_OF_BOOKS_ID in NUMBER,
p_new_SET_OF_BOOKS_ID in NUMBER,
p_old_SOFT_CODING_KEYFLEX_ID in NUMBER,
p_new_SOFT_CODING_KEYFLEX_ID in NUMBER,
p_old_SOURCE_ORGANIZATION_ID in NUMBER,
p_new_SOURCE_ORGANIZATION_ID in NUMBER,
p_old_SOURCE_TYPE in VARCHAR2,
p_new_SOURCE_TYPE in VARCHAR2,
p_old_SPECIAL_CEILING_STEP_ID in NUMBER,
p_new_SPECIAL_CEILING_STEP_ID in NUMBER,
p_old_SUPERVISOR_ID in NUMBER,
p_new_SUPERVISOR_ID in NUMBER,
p_old_TIME_NORMAL_FINISH in VARCHAR2,
p_new_TIME_NORMAL_FINISH in VARCHAR2,
p_old_TIME_NORMAL_START in VARCHAR2,
p_new_TIME_NORMAL_START in VARCHAR2,
p_old_TITLE in VARCHAR2,
p_new_TITLE in VARCHAR2,
p_old_VACANCY_ID in NUMBER,
p_new_VACANCY_ID in NUMBER,
p_old_PROJECTED_ASSIGNMENT_END in DATE default null,
p_new_PROJECTED_ASSIGNMENT_END in DATE default null
)
is
--
begin
  hr_utility.set_location('pay_continuous_calc.PER_ALL_ASSIGNMENTS_F_aru', 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates haven't changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'APPLICATION_ID',
                                     p_old_APPLICATION_ID,
                                     p_new_APPLICATION_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASSIGNMENT_ID',
                                     p_old_ASSIGNMENT_ID,
                                     p_new_ASSIGNMENT_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASSIGNMENT_NUMBER',
                                     p_old_ASSIGNMENT_NUMBER,
                                     p_new_ASSIGNMENT_NUMBER,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASSIGNMENT_SEQUENCE',
                                     p_old_ASSIGNMENT_SEQUENCE,
                                     p_new_ASSIGNMENT_SEQUENCE,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASSIGNMENT_STATUS_TYPE_ID',
                                     p_old_ASSIGNMENT_STATUS_TYPE_I,
                                     p_new_ASSIGNMENT_STATUS_TYPE_I,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASSIGNMENT_TYPE',
                                     p_old_ASSIGNMENT_TYPE,
                                     p_new_ASSIGNMENT_TYPE,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE1',
                                     p_old_ASS_ATTRIBUTE1,
                                     p_new_ASS_ATTRIBUTE1,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE10',
                                     p_old_ASS_ATTRIBUTE10,
                                     p_new_ASS_ATTRIBUTE10,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE11',
                                     p_old_ASS_ATTRIBUTE11,
                                     p_new_ASS_ATTRIBUTE11,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE12',
                                     p_old_ASS_ATTRIBUTE12,
                                     p_new_ASS_ATTRIBUTE12,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE13',
                                     p_old_ASS_ATTRIBUTE13,
                                     p_new_ASS_ATTRIBUTE13,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE14',
                                     p_old_ASS_ATTRIBUTE14,
                                     p_new_ASS_ATTRIBUTE14,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE15',
                                     p_old_ASS_ATTRIBUTE15,
                                     p_new_ASS_ATTRIBUTE15,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE16',
                                     p_old_ASS_ATTRIBUTE16,
                                     p_new_ASS_ATTRIBUTE16,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE17',
                                     p_old_ASS_ATTRIBUTE17,
                                     p_new_ASS_ATTRIBUTE17,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE18',
                                     p_old_ASS_ATTRIBUTE18,
                                     p_new_ASS_ATTRIBUTE18,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE19',
                                     p_old_ASS_ATTRIBUTE19,
                                     p_new_ASS_ATTRIBUTE19,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE2',
                                     p_old_ASS_ATTRIBUTE2,
                                     p_new_ASS_ATTRIBUTE2,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE20',
                                     p_old_ASS_ATTRIBUTE20,
                                     p_new_ASS_ATTRIBUTE20,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE21',
                                     p_old_ASS_ATTRIBUTE21,
                                     p_new_ASS_ATTRIBUTE21,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE22',
                                     p_old_ASS_ATTRIBUTE22,
                                     p_new_ASS_ATTRIBUTE22,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE23',
                                     p_old_ASS_ATTRIBUTE23,
                                     p_new_ASS_ATTRIBUTE23,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE24',
                                     p_old_ASS_ATTRIBUTE24,
                                     p_new_ASS_ATTRIBUTE24,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE25',
                                     p_old_ASS_ATTRIBUTE25,
                                     p_new_ASS_ATTRIBUTE25,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE26',
                                     p_old_ASS_ATTRIBUTE26,
                                     p_new_ASS_ATTRIBUTE26,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE27',
                                     p_old_ASS_ATTRIBUTE27,
                                     p_new_ASS_ATTRIBUTE27,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE28',
                                     p_old_ASS_ATTRIBUTE28,
                                     p_new_ASS_ATTRIBUTE28,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE29',
                                     p_old_ASS_ATTRIBUTE29,
                                     p_new_ASS_ATTRIBUTE29,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE3',
                                     p_old_ASS_ATTRIBUTE3,
                                     p_new_ASS_ATTRIBUTE3,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE30',
                                     p_old_ASS_ATTRIBUTE30,
                                     p_new_ASS_ATTRIBUTE30,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE4',
                                     p_old_ASS_ATTRIBUTE4,
                                     p_new_ASS_ATTRIBUTE4,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE5',
                                     p_old_ASS_ATTRIBUTE5,
                                     p_new_ASS_ATTRIBUTE5,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE6',
                                     p_old_ASS_ATTRIBUTE6,
                                     p_new_ASS_ATTRIBUTE6,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE7',
                                     p_old_ASS_ATTRIBUTE7,
                                     p_new_ASS_ATTRIBUTE7,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE8',
                                     p_old_ASS_ATTRIBUTE8,
                                     p_new_ASS_ATTRIBUTE8,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE9',
                                     p_old_ASS_ATTRIBUTE9,
                                     p_new_ASS_ATTRIBUTE9,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ASS_ATTRIBUTE_CATEGORY',
                                     p_old_ASS_ATTRIBUTE_CATEGORY,
                                     p_new_ASS_ATTRIBUTE_CATEGORY,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'BARGAINING_UNIT_CODE',
                                     p_old_BARGAINING_UNIT_CODE,
                                     p_new_BARGAINING_UNIT_CODE,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'BUSINESS_GROUP_ID',
                                     p_old_BUSINESS_GROUP_ID,
                                     p_new_BUSINESS_GROUP_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'CAGR_GRADE_DEF_ID',
                                     p_old_CAGR_GRADE_DEF_ID,
                                     p_new_CAGR_GRADE_DEF_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'CAGR_ID_FLEX_NUM',
                                     p_old_CAGR_ID_FLEX_NUM,
                                     p_new_CAGR_ID_FLEX_NUM,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'CHANGE_REASON',
                                     p_old_CHANGE_REASON,
                                     p_new_CHANGE_REASON,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'COLLECTIVE_AGREEMENT_ID',
                                     p_old_COLLECTIVE_AGREEMENT_ID,
                                     p_new_COLLECTIVE_AGREEMENT_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'COMMENT_ID',
                                     p_old_COMMENT_ID,
                                     p_new_COMMENT_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'CONTRACT_ID',
                                     p_old_CONTRACT_ID,
                                     p_new_CONTRACT_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'DATE_PROBATION_END',
                                     p_old_DATE_PROBATION_END,
                                     p_new_DATE_PROBATION_END,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'DEFAULT_CODE_COMB_ID',
                                     p_old_DEFAULT_CODE_COMB_ID,
                                     p_new_DEFAULT_CODE_COMB_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'EMPLOYMENT_CATEGORY',
                                     p_old_EMPLOYMENT_CATEGORY,
                                     p_new_EMPLOYMENT_CATEGORY,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ESTABLISHMENT_ID',
                                     p_old_ESTABLISHMENT_ID,
                                     p_new_ESTABLISHMENT_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'FREQUENCY',
                                     p_old_FREQUENCY,
                                     p_new_FREQUENCY,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'GRADE_ID',
                                     p_old_GRADE_ID,
                                     p_new_GRADE_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'HOURLY_SALARIED_CODE',
                                     p_old_HOURLY_SALARIED_CODE,
                                     p_new_HOURLY_SALARIED_CODE,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'INTERNAL_ADDRESS_LINE',
                                     p_old_INTERNAL_ADDRESS_LINE,
                                     p_new_INTERNAL_ADDRESS_LINE,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'JOB_ID',
                                     p_old_JOB_ID,
                                     p_new_JOB_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'LABOUR_UNION_MEMBER_FLAG',
                                     p_old_LABOUR_UNION_MEMBER_FLAG,
                                     p_new_LABOUR_UNION_MEMBER_FLAG,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'LOCATION_ID',
                                     p_old_LOCATION_ID,
                                     p_new_LOCATION_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'MANAGER_FLAG',
                                     p_old_MANAGER_FLAG,
                                     p_new_MANAGER_FLAG,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'NORMAL_HOURS',
                                     p_old_NORMAL_HOURS,
                                     p_new_NORMAL_HOURS,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'ORGANIZATION_ID',
                                     p_old_ORGANIZATION_ID,
                                     p_new_ORGANIZATION_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'PAYROLL_ID',
                                     p_old_PAYROLL_ID,
                                     p_new_PAYROLL_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'PAY_BASIS_ID',
                                     p_old_PAY_BASIS_ID,
                                     p_new_PAY_BASIS_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'PEOPLE_GROUP_ID',
                                     p_old_PEOPLE_GROUP_ID,
                                     p_new_PEOPLE_GROUP_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'PERF_REVIEW_PERIOD',
                                     p_old_PERF_REVIEW_PERIOD,
                                     p_new_PERF_REVIEW_PERIOD,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'PERF_REVIEW_PERIOD_FREQUENCY',
                                     p_old_PERF_REVIEW_PERIOD_FREQU,
                                     p_new_PERF_REVIEW_PERIOD_FREQU,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'PERIOD_OF_SERVICE_ID',
                                     p_old_PERIOD_OF_SERVICE_ID,
                                     p_new_PERIOD_OF_SERVICE_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'PERSON_ID',
                                     p_old_PERSON_ID,
                                     p_new_PERSON_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'PERSON_REFERRED_BY_ID',
                                     p_old_PERSON_REFERRED_BY_ID,
                                     p_new_PERSON_REFERRED_BY_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'POSITION_ID',
                                     p_old_POSITION_ID,
                                     p_new_POSITION_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'PRIMARY_FLAG',
                                     p_old_PRIMARY_FLAG,
                                     p_new_PRIMARY_FLAG,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'PROBATION_PERIOD',
                                     p_old_PROBATION_PERIOD,
                                     p_new_PROBATION_PERIOD,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'PROBATION_UNIT',
                                     p_old_PROBATION_UNIT,
                                     p_new_PROBATION_UNIT,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'PROGRAM_APPLICATION_ID',
                                     p_old_PROGRAM_APPLICATION_ID,
                                     p_new_PROGRAM_APPLICATION_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'PROGRAM_ID',
                                     p_old_PROGRAM_ID,
                                     p_new_PROGRAM_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'PROGRAM_UPDATE_DATE',
                                     p_old_PROGRAM_UPDATE_DATE,
                                     p_new_PROGRAM_UPDATE_DATE,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'RECRUITER_ID',
                                     p_old_RECRUITER_ID,
                                     p_new_RECRUITER_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'RECRUITMENT_ACTIVITY_ID',
                                     p_old_RECRUITMENT_ACTIVITY_ID,
                                     p_new_RECRUITMENT_ACTIVITY_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'REQUEST_ID',
                                     p_old_REQUEST_ID,
                                     p_new_REQUEST_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'SAL_REVIEW_PERIOD',
                                     p_old_SAL_REVIEW_PERIOD,
                                     p_new_SAL_REVIEW_PERIOD,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'SAL_REVIEW_PERIOD_FREQUENCY',
                                     p_old_SAL_REVIEW_PERIOD_FREQUE,
                                     p_new_SAL_REVIEW_PERIOD_FREQUE,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'SET_OF_BOOKS_ID',
                                     p_old_SET_OF_BOOKS_ID,
                                     p_new_SET_OF_BOOKS_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'SOFT_CODING_KEYFLEX_ID',
                                     p_old_SOFT_CODING_KEYFLEX_ID,
                                     p_new_SOFT_CODING_KEYFLEX_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'SOURCE_ORGANIZATION_ID',
                                     p_old_SOURCE_ORGANIZATION_ID,
                                     p_new_SOURCE_ORGANIZATION_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'SOURCE_TYPE',
                                     p_old_SOURCE_TYPE,
                                     p_new_SOURCE_TYPE,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'SPECIAL_CEILING_STEP_ID',
                                     p_old_SPECIAL_CEILING_STEP_ID,
                                     p_new_SPECIAL_CEILING_STEP_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'SUPERVISOR_ID',
                                     p_old_SUPERVISOR_ID,
                                     p_new_SUPERVISOR_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'TIME_NORMAL_FINISH',
                                     p_old_TIME_NORMAL_FINISH,
                                     p_new_TIME_NORMAL_FINISH,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'TIME_NORMAL_START',
                                     p_old_TIME_NORMAL_START,
                                     p_new_TIME_NORMAL_START,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'TITLE',
                                     p_old_TITLE,
                                     p_new_TITLE,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'VACANCY_ID',
                                     p_old_VACANCY_ID,
                                     p_new_VACANCY_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'PROJECTED_ASSIGNMENT_END',
                                     p_old_PROJECTED_ASSIGNMENT_END,
                                     p_new_PROJECTED_ASSIGNMENT_END,
                                     p_effective_date
                                    );
  else
    /* OK it must be a date track change */
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                    );
  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => p_old_ASSIGNMENT_ID,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_surrogate_key         => p_old_ASSIGNMENT_ID,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_business_group_id     => p_business_group_id
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
  hr_utility.set_location('pay_continuous_calc.PER_ALL_ASSIGNMENTS_F_aru', 50);
--
end PER_ALL_ASSIGNMENTS_F_aru;
--
/* PER_ALL_ASSIGNMENTS_F_ari */
/* name : PER_ALL_ASSIGNMENTS_F_ari
   purpose : This is procedure that records any insert
             on assignments.
*/
  procedure PER_ALL_ASSIGNMENTS_F_ari(
                                         p_business_group_id in number,
                                         p_legislation_code in varchar2,
                                         p_assignment_id in number,
                                         p_effective_start_date in date
                                        )
  is
  l_process_event_id number;
  l_object_version_number number;
    l_proc varchar2(240) := g_package||'.per_all_assignments_f_ari';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'I'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
             p_assignment_id         => p_assignment_id,
             p_effective_date        => g_event_list.effective_date(cnt),
             p_change_type           => g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => g_event_list.event_update_id(cnt),
             p_surrogate_key         => p_assignment_id,
             p_calculation_date      => g_event_list.calc_date(cnt),
             p_business_group_id     => p_business_group_id
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
  hr_utility.set_location(l_proc, 900);
  end per_all_assignments_f_ari;
--
/* name : per_all_assignments_f_ard
   purpose : This is procedure that records any deletes
             on assignments.
*/
  procedure per_all_assignments_f_ard(
                                         p_business_group_id in number,
                                         p_legislation_code in varchar2,
                                         p_assignment_id in number,
                                         p_effective_start_date in date
                                        )
  is
  l_process_event_id number;
  l_object_version_number number;
    l_proc varchar2(240) := g_package||'.per_all_assignments_f_ard';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_ASSIGNMENTS_F',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'D'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => p_assignment_id,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_surrogate_key         => p_assignment_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_business_group_id     => p_business_group_id
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
    hr_utility.set_location(l_proc, 900);
  END per_all_assignments_f_ard;


/* PAY_PERSONAL_PAYMENT_METHODS_F */
/* name : PER_ALL_payment_methods_ari
   purpose : This is procedure that records any insert
             on personal_payment_methods.
*/
  procedure personal_payment_methods_ari(
                                         p_business_group_id in number,
                                         p_legislation_code in varchar2,
                                         p_assignment_id in number,
                                         p_effective_start_date in date,
                                         p_payment_method_id in number
                                        )
  is
    l_process_event_id number;
    l_object_version_number number;
    l_proc varchar2(240) := g_package||'.personal_payment_methods_ari';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'I'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => p_assignment_id,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_surrogate_key         => p_payment_method_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_business_group_id     => p_business_group_id
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
    hr_utility.set_location(l_proc, 900);
  end personal_payment_methods_ari;
--
/* name : personal_payment_methods_ard
   purpose : This is procedure that records any deletes
             on personal_payment_methods.
*/
  procedure personal_payment_methods_ard(
                                         p_business_group_id in number,
                                         p_legislation_code in varchar2,
                                         p_assignment_id in number,
                                         p_effective_start_date in date,
                                         p_payment_method_id in number
                                        )
  is
    l_process_event_id number;
    l_object_version_number number;
    l_proc varchar2(240) := g_package||'.personal_payment_methods_ard';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'D'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => p_assignment_id,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_surrogate_key         => p_payment_method_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_business_group_id     => p_business_group_id
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
    hr_utility.set_location(l_proc, 900);
  END personal_payment_methods_ard;
--
/* name : PERSONAL_PAYMENT_METHODS_F_aru
   purpose : This is procedure that records any updates
             on personal_payment_methods.
*/
procedure PERSONAL_PAYMENT_METHODS_F_aru(
p_business_group_id in number,
p_legislation_code in varchar2,
p_effective_date in date,
p_old_AMOUNT in NUMBER,
p_new_AMOUNT in NUMBER,
p_old_ASSIGNMENT_ID in NUMBER,
p_new_ASSIGNMENT_ID in NUMBER,
p_old_ATTRIBUTE1 in VARCHAR2,
p_new_ATTRIBUTE1 in VARCHAR2,
p_old_ATTRIBUTE10 in VARCHAR2,
p_new_ATTRIBUTE10 in VARCHAR2,
p_old_ATTRIBUTE11 in VARCHAR2,
p_new_ATTRIBUTE11 in VARCHAR2,
p_old_ATTRIBUTE12 in VARCHAR2,
p_new_ATTRIBUTE12 in VARCHAR2,
p_old_ATTRIBUTE13 in VARCHAR2,
p_new_ATTRIBUTE13 in VARCHAR2,
p_old_ATTRIBUTE14 in VARCHAR2,
p_new_ATTRIBUTE14 in VARCHAR2,
p_old_ATTRIBUTE15 in VARCHAR2,
p_new_ATTRIBUTE15 in VARCHAR2,
p_old_ATTRIBUTE16 in VARCHAR2,
p_new_ATTRIBUTE16 in VARCHAR2,
p_old_ATTRIBUTE17 in VARCHAR2,
p_new_ATTRIBUTE17 in VARCHAR2,
p_old_ATTRIBUTE18 in VARCHAR2,
p_new_ATTRIBUTE18 in VARCHAR2,
p_old_ATTRIBUTE19 in VARCHAR2,
p_new_ATTRIBUTE19 in VARCHAR2,
p_old_ATTRIBUTE2 in VARCHAR2,
p_new_ATTRIBUTE2 in VARCHAR2,
p_old_ATTRIBUTE20 in VARCHAR2,
p_new_ATTRIBUTE20 in VARCHAR2,
p_old_ATTRIBUTE3 in VARCHAR2,
p_new_ATTRIBUTE3 in VARCHAR2,
p_old_ATTRIBUTE4 in VARCHAR2,
p_new_ATTRIBUTE4 in VARCHAR2,
p_old_ATTRIBUTE5 in VARCHAR2,
p_new_ATTRIBUTE5 in VARCHAR2,
p_old_ATTRIBUTE6 in VARCHAR2,
p_new_ATTRIBUTE6 in VARCHAR2,
p_old_ATTRIBUTE7 in VARCHAR2,
p_new_ATTRIBUTE7 in VARCHAR2,
p_old_ATTRIBUTE8 in VARCHAR2,
p_new_ATTRIBUTE8 in VARCHAR2,
p_old_ATTRIBUTE9 in VARCHAR2,
p_new_ATTRIBUTE9 in VARCHAR2,
p_old_ATTRIBUTE_CATEGORY in VARCHAR2,
p_new_ATTRIBUTE_CATEGORY in VARCHAR2,
p_old_COMMENT_ID in NUMBER,
p_new_COMMENT_ID in NUMBER,
p_old_EFFECTIVE_END_DATE in DATE,
p_new_EFFECTIVE_END_DATE in DATE,
p_old_EFFECTIVE_START_DATE in DATE,
p_new_EFFECTIVE_START_DATE in DATE,
p_old_EXTERNAL_ACCOUNT_ID in NUMBER,
p_new_EXTERNAL_ACCOUNT_ID in NUMBER,
p_old_ORG_PAYMENT_METHOD_ID in NUMBER,
p_new_ORG_PAYMENT_METHOD_ID in NUMBER,
p_old_PAYEE_ID in NUMBER,
p_new_PAYEE_ID in NUMBER,
p_old_PAYEE_TYPE in VARCHAR2,
p_new_PAYEE_TYPE in VARCHAR2,
p_old_PERCENTAGE in NUMBER,
p_new_PERCENTAGE in NUMBER,
p_old_PERSONAL_PAYMENT_METHOD_ in NUMBER,
p_new_PERSONAL_PAYMENT_METHOD_ in NUMBER,
p_old_PRIORITY in NUMBER,
p_new_PRIORITY in NUMBER
)
is
--
begin
--
  hr_utility.set_location('pay_continuous_calc.PERSONAL_PAYMENT_METHODS_F_aru', 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates haven't changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'AMOUNT',
                                     p_old_AMOUNT,
                                     p_new_AMOUNT,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ASSIGNMENT_ID',
                                     p_old_ASSIGNMENT_ID,
                                     p_new_ASSIGNMENT_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE1',
                                     p_old_ATTRIBUTE1,
                                     p_new_ATTRIBUTE1,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE10',
                                     p_old_ATTRIBUTE10,
                                     p_new_ATTRIBUTE10,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE11',
                                     p_old_ATTRIBUTE11,
                                     p_new_ATTRIBUTE11,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE12',
                                     p_old_ATTRIBUTE12,
                                     p_new_ATTRIBUTE12,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE13',
                                     p_old_ATTRIBUTE13,
                                     p_new_ATTRIBUTE13,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE14',
                                     p_old_ATTRIBUTE14,
                                     p_new_ATTRIBUTE14,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE15',
                                     p_old_ATTRIBUTE15,
                                     p_new_ATTRIBUTE15,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE16',
                                     p_old_ATTRIBUTE16,
                                     p_new_ATTRIBUTE16,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE17',
                                     p_old_ATTRIBUTE17,
                                     p_new_ATTRIBUTE17,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE18',
                                     p_old_ATTRIBUTE18,
                                     p_new_ATTRIBUTE18,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE19',
                                     p_old_ATTRIBUTE19,
                                     p_new_ATTRIBUTE19,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE2',
                                     p_old_ATTRIBUTE2,
                                     p_new_ATTRIBUTE2,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE20',
                                     p_old_ATTRIBUTE20,
                                     p_new_ATTRIBUTE20,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE3',
                                     p_old_ATTRIBUTE3,
                                     p_new_ATTRIBUTE3,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE4',
                                     p_old_ATTRIBUTE4,
                                     p_new_ATTRIBUTE4,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE5',
                                     p_old_ATTRIBUTE5,
                                     p_new_ATTRIBUTE5,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE6',
                                     p_old_ATTRIBUTE6,
                                     p_new_ATTRIBUTE6,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE7',
                                     p_old_ATTRIBUTE7,
                                     p_new_ATTRIBUTE7,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE8',
                                     p_old_ATTRIBUTE8,
                                     p_new_ATTRIBUTE8,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE9',
                                     p_old_ATTRIBUTE9,
                                     p_new_ATTRIBUTE9,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ATTRIBUTE_CATEGORY',
                                     p_old_ATTRIBUTE_CATEGORY,
                                     p_new_ATTRIBUTE_CATEGORY,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'COMMENT_ID',
                                     p_old_COMMENT_ID,
                                     p_new_COMMENT_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'EXTERNAL_ACCOUNT_ID',
                                     p_old_EXTERNAL_ACCOUNT_ID,
                                     p_new_EXTERNAL_ACCOUNT_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'ORG_PAYMENT_METHOD_ID',
                                     p_old_ORG_PAYMENT_METHOD_ID,
                                     p_new_ORG_PAYMENT_METHOD_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'PAYEE_ID',
                                     p_old_PAYEE_ID,
                                     p_new_PAYEE_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'PAYEE_TYPE',
                                     p_old_PAYEE_TYPE,
                                     p_new_PAYEE_TYPE,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'PERCENTAGE',
                                     p_old_PERCENTAGE,
                                     p_new_PERCENTAGE,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'PERSONAL_PAYMENT_METHOD_ID',
                                     p_old_PERSONAL_PAYMENT_METHOD_,
                                     p_new_PERSONAL_PAYMENT_METHOD_,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'PRIORITY',
                                     p_old_PRIORITY,
                                     p_new_PRIORITY,
                                     p_effective_date
                                    );
  else
    /* OK it must be a date track change */
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_PERSONAL_PAYMENT_METHODS_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                    );
  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => p_old_ASSIGNMENT_ID,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_surrogate_key         => p_old_PERSONAL_PAYMENT_METHOD_,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_business_group_id     => p_business_group_id
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
  hr_utility.set_location('pay_continuous_calc.PERSONAL_PAYMENT_METHODS_F_aru', 50);
--
end PERSONAL_PAYMENT_METHODS_F_aru;
--
/* PAY_LINK_INPUT_VALUES */
/* name : PAY_LINK_INPUT_VALUES_F_aru
   purpose : This is procedure that records any updates
             on link_input_values.
*/
procedure PAY_LINK_INPUT_VALUES_F_aru(
p_business_group_id in number,
p_legislation_code in varchar2,
p_effective_date in date,
p_old_COSTED_FLAG in VARCHAR2,
p_new_COSTED_FLAG in VARCHAR2 ,
p_old_DEFAULT_VALUE in VARCHAR2,
p_new_DEFAULT_VALUE in VARCHAR2 ,
p_old_ELEMENT_LINK_ID in NUMBER,
p_new_ELEMENT_LINK_ID in NUMBER ,
p_old_INPUT_VALUE_ID in NUMBER,
p_new_INPUT_VALUE_ID in NUMBER ,
p_old_LINK_INPUT_VALUE_ID in NUMBER,
p_new_LINK_INPUT_VALUE_ID in NUMBER ,
p_old_MAX_VALUE in VARCHAR2,
p_new_MAX_VALUE in VARCHAR2 ,
p_old_MIN_VALUE in VARCHAR2,
p_new_MIN_VALUE in VARCHAR2 ,
p_old_WARNING_OR_ERROR in VARCHAR2,
p_new_WARNING_OR_ERROR in VARCHAR2 ,
p_old_EFFECTIVE_END_DATE in DATE,
p_new_EFFECTIVE_END_DATE in DATE ,
p_old_EFFECTIVE_START_DATE in DATE,
p_new_EFFECTIVE_START_DATE in DATE
)
is
--
begin
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_LINK_INPUT_VALUES_F',
                                     'COSTED_FLAG',
                                     p_old_COSTED_FLAG,
                                     p_new_COSTED_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_LINK_INPUT_VALUES_F',
                                     'DEFAULT_VALUE',
                                     p_old_DEFAULT_VALUE,
                                     p_new_DEFAULT_VALUE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_LINK_INPUT_VALUES_F',
                                     'ELEMENT_LINK_ID',
                                     p_old_ELEMENT_LINK_ID,
                                     p_new_ELEMENT_LINK_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_LINK_INPUT_VALUES_F',
                                     'INPUT_VALUE_ID',
                                     p_old_INPUT_VALUE_ID,
                                     p_new_INPUT_VALUE_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_LINK_INPUT_VALUES_F',
                                     'LINK_INPUT_VALUE_ID',
                                     p_old_LINK_INPUT_VALUE_ID,
                                     p_new_LINK_INPUT_VALUE_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_LINK_INPUT_VALUES_F',
                                     'MAX_VALUE',
                                     p_old_MAX_VALUE,
                                     p_new_MAX_VALUE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_LINK_INPUT_VALUES_F',
                                     'MIN_VALUE',
                                     p_old_MIN_VALUE,
                                     p_new_MIN_VALUE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_LINK_INPUT_VALUES_F',
                                     'WARNING_OR_ERROR',
                                     p_old_WARNING_OR_ERROR,
                                     p_new_WARNING_OR_ERROR,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_LINK_INPUT_VALUES_F',
                                     'WARNING_OR_ERROR',
                                     p_old_WARNING_OR_ERROR,
                                     p_new_WARNING_OR_ERROR,
                                     p_effective_date
                                  );
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_LINK_INPUT_VALUES_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_LINK_INPUT_VALUES_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                  );

  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => null,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_business_group_id     => p_business_group_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_surrogate_key         => p_new_LINK_INPUT_VALUE_ID
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
end PAY_LINK_INPUT_VALUES_F_aru;
--
/* Used generator to build this procedure, but removed some of that table values.
*/
/* PAY_ELEMENT_LINKS */
/* name : PAY_ELEMENT_LINKS_F_aru
   purpose : This is procedure that records any updates
             on element_links.
*/
procedure PAY_ELEMENT_LINKS_F_aru(
p_business_group_id in number,
p_legislation_code in varchar2,
p_effective_date in date,
p_old_ATTRIBUTE1 in VARCHAR2,
p_new_ATTRIBUTE1 in VARCHAR2,
p_old_ATTRIBUTE10 in VARCHAR2,
p_new_ATTRIBUTE10 in VARCHAR2,
p_old_ATTRIBUTE11 in VARCHAR2,
p_new_ATTRIBUTE11 in VARCHAR2,
p_old_ATTRIBUTE12 in VARCHAR2,
p_new_ATTRIBUTE12 in VARCHAR2,
p_old_ATTRIBUTE13 in VARCHAR2,
p_new_ATTRIBUTE13 in VARCHAR2,
p_old_ATTRIBUTE14 in VARCHAR2,
p_new_ATTRIBUTE14 in VARCHAR2,
p_old_ATTRIBUTE15 in VARCHAR2,
p_new_ATTRIBUTE15 in VARCHAR2,
p_old_ATTRIBUTE16 in VARCHAR2,
p_new_ATTRIBUTE16 in VARCHAR2,
p_old_ATTRIBUTE17 in VARCHAR2,
p_new_ATTRIBUTE17 in VARCHAR2,
p_old_ATTRIBUTE18 in VARCHAR2,
p_new_ATTRIBUTE18 in VARCHAR2,
p_old_ATTRIBUTE19 in VARCHAR2,
p_new_ATTRIBUTE19 in VARCHAR2,
p_old_ATTRIBUTE2 in VARCHAR2,
p_new_ATTRIBUTE2 in VARCHAR2,
p_old_ATTRIBUTE20 in VARCHAR2,
p_new_ATTRIBUTE20 in VARCHAR2,
p_old_ATTRIBUTE3 in VARCHAR2,
p_new_ATTRIBUTE3 in VARCHAR2,
p_old_ATTRIBUTE4 in VARCHAR2,
p_new_ATTRIBUTE4 in VARCHAR2,
p_old_ATTRIBUTE5 in VARCHAR2,
p_new_ATTRIBUTE5 in VARCHAR2,
p_old_ATTRIBUTE6 in VARCHAR2,
p_new_ATTRIBUTE6 in VARCHAR2,
p_old_ATTRIBUTE7 in VARCHAR2,
p_new_ATTRIBUTE7 in VARCHAR2,
p_old_ATTRIBUTE8 in VARCHAR2,
p_new_ATTRIBUTE8 in VARCHAR2,
p_old_ATTRIBUTE9 in VARCHAR2,
p_new_ATTRIBUTE9 in VARCHAR2,
p_old_ATTRIBUTE_CATEGORY in VARCHAR2,
p_new_ATTRIBUTE_CATEGORY in VARCHAR2,
p_old_BALANCING_KEYFLEX_ID in NUMBER,
p_new_BALANCING_KEYFLEX_ID in NUMBER,
p_old_COSTABLE_TYPE in VARCHAR2,
p_new_COSTABLE_TYPE in VARCHAR2,
p_old_COST_ALLOCATION_KEYFLEX in NUMBER,
p_new_COST_ALLOCATION_KEYFLEX in NUMBER,
p_old_ELEMENT_LINK_ID in NUMBER,
p_new_ELEMENT_LINK_ID in NUMBER,
p_old_ELEMENT_SET_ID in NUMBER,
p_new_ELEMENT_SET_ID in NUMBER,
p_old_ELEMENT_TYPE_ID in NUMBER,
p_new_ELEMENT_TYPE_ID in NUMBER,
p_old_EFFECTIVE_END_DATE in DATE,
p_new_EFFECTIVE_END_DATE in DATE,
p_old_EFFECTIVE_START_DATE in DATE,
p_new_EFFECTIVE_START_DATE in DATE
)
is
--
begin
  hr_utility.set_location('pay_continuous_calc.PAY_ELEMENT_LINKS_F_aru', 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE1',
                                     p_old_ATTRIBUTE1,
                                     p_new_ATTRIBUTE1,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE10',
                                     p_old_ATTRIBUTE10,
                                     p_new_ATTRIBUTE10,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE11',
                                     p_old_ATTRIBUTE11,
                                     p_new_ATTRIBUTE11,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE12',
                                     p_old_ATTRIBUTE12,
                                     p_new_ATTRIBUTE12,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE13',
                                     p_old_ATTRIBUTE13,
                                     p_new_ATTRIBUTE13,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE14',
                                     p_old_ATTRIBUTE14,
                                     p_new_ATTRIBUTE14,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE15',
                                     p_old_ATTRIBUTE15,
                                     p_new_ATTRIBUTE15,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE16',
                                     p_old_ATTRIBUTE16,
                                     p_new_ATTRIBUTE16,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE17',
                                     p_old_ATTRIBUTE17,
                                     p_new_ATTRIBUTE17,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE18',
                                     p_old_ATTRIBUTE18,
                                     p_new_ATTRIBUTE18,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE19',
                                     p_old_ATTRIBUTE19,
                                     p_new_ATTRIBUTE19,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE2',
                                     p_old_ATTRIBUTE2,
                                     p_new_ATTRIBUTE2,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE20',
                                     p_old_ATTRIBUTE20,
                                     p_new_ATTRIBUTE20,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE3',
                                     p_old_ATTRIBUTE3,
                                     p_new_ATTRIBUTE3,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE4',
                                     p_old_ATTRIBUTE4,
                                     p_new_ATTRIBUTE4,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE5',
                                     p_old_ATTRIBUTE5,
                                     p_new_ATTRIBUTE5,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE6',
                                     p_old_ATTRIBUTE6,
                                     p_new_ATTRIBUTE6,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE7',
                                     p_old_ATTRIBUTE7,
                                     p_new_ATTRIBUTE7,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE8',
                                     p_old_ATTRIBUTE8,
                                     p_new_ATTRIBUTE8,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE9',
                                     p_old_ATTRIBUTE9,
                                     p_new_ATTRIBUTE9,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ATTRIBUTE_CATEGORY',
                                     p_old_ATTRIBUTE_CATEGORY,
                                     p_new_ATTRIBUTE_CATEGORY,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'BALANCING_KEYFLEX_ID',
                                     p_old_BALANCING_KEYFLEX_ID,
                                     p_new_BALANCING_KEYFLEX_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'COSTABLE_TYPE',
                                     p_old_COSTABLE_TYPE,
                                     p_new_COSTABLE_TYPE,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'COST_ALLOCATION_KEYFLEX_ID',
                                     p_old_COST_ALLOCATION_KEYFLEX,
                                     p_new_COST_ALLOCATION_KEYFLEX,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'ELEMENT_SET_ID',
                                     p_old_ELEMENT_SET_ID,
                                     p_new_ELEMENT_SET_ID,
                                     p_effective_date
                                    );
--
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_LINKS_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                  );

  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => null,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_business_group_id     => p_business_group_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_surrogate_key         => p_new_ELEMENT_LINK_ID
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
  hr_utility.set_location('pay_continuous_calc.PAY_ELEMENT_LINKS_F_aru', 50);
--
end PAY_ELEMENT_LINKS_F_aru;
--
/* PAY_INPUT_VALUES */
/* name : PAY_INPUT_VALUES_F_aru
   purpose : This is procedure that records any updates
             on input_values.
*/
procedure PAY_INPUT_VALUES_F_aru(
p_business_group_id in number,
p_legislation_code in varchar2,
p_effective_date in date ,
p_old_DEFAULT_VALUE in VARCHAR2,
p_new_DEFAULT_VALUE in VARCHAR2 ,
p_old_DISPLAY_SEQUENCE in NUMBER,
p_new_DISPLAY_SEQUENCE in NUMBER ,
p_old_ELEMENT_TYPE_ID in NUMBER,
p_new_ELEMENT_TYPE_ID in NUMBER ,
p_old_FORMULA_ID in NUMBER,
p_new_FORMULA_ID in NUMBER ,
p_old_GENERATE_DB_ITEMS_FLAG in VARCHAR2,
p_new_GENERATE_DB_ITEMS_FLAG in VARCHAR2 ,
p_old_HOT_DEFAULT_FLAG in VARCHAR2,
p_new_HOT_DEFAULT_FLAG in VARCHAR2 ,
p_old_INPUT_VALUE_ID in NUMBER,
p_new_INPUT_VALUE_ID in NUMBER ,
p_old_LEGISLATION_SUBGROUP in VARCHAR2,
p_new_LEGISLATION_SUBGROUP in VARCHAR2 ,
p_old_LOOKUP_TYPE in VARCHAR2,
p_new_LOOKUP_TYPE in VARCHAR2 ,
p_old_MANDATORY_FLAG in VARCHAR2,
p_new_MANDATORY_FLAG in VARCHAR2 ,
p_old_MAX_VALUE in VARCHAR2,
p_new_MAX_VALUE in VARCHAR2 ,
p_old_MIN_VALUE in VARCHAR2,
p_new_MIN_VALUE in VARCHAR2 ,
p_old_UOM in VARCHAR2,
p_new_UOM in VARCHAR2 ,
p_old_WARNING_OR_ERROR in VARCHAR2,
p_new_WARNING_OR_ERROR in VARCHAR2 ,
p_old_EFFECTIVE_END_DATE in DATE,
p_new_EFFECTIVE_END_DATE in DATE ,
p_old_EFFECTIVE_START_DATE in DATE,
p_new_EFFECTIVE_START_DATE in DATE
)
is
--
begin
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_INPUT_VALUES_F',
                                     'DEFAULT_VALUE',
                                     p_old_DEFAULT_VALUE,
                                     p_new_DEFAULT_VALUE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_INPUT_VALUES_F',
                                     'DISPLAY_SEQUENCE',
                                     p_old_DISPLAY_SEQUENCE,
                                     p_new_DISPLAY_SEQUENCE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_INPUT_VALUES_F',
                                     'ELEMENT_TYPE_ID',
                                     p_old_ELEMENT_TYPE_ID,
                                     p_new_ELEMENT_TYPE_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_INPUT_VALUES_F',
                                     'FORMULA_ID',
                                     p_old_FORMULA_ID,
                                     p_new_FORMULA_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_INPUT_VALUES_F',
                                     'GENERATE_DB_ITEMS_FLAG',
                                     p_old_GENERATE_DB_ITEMS_FLAG,
                                     p_new_GENERATE_DB_ITEMS_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_INPUT_VALUES_F',
                                     'HOT_DEFAULT_FLAG',
                                     p_old_HOT_DEFAULT_FLAG,
                                     p_new_HOT_DEFAULT_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_INPUT_VALUES_F',
                                     'INPUT_VALUE_ID',
                                     p_old_INPUT_VALUE_ID,
                                     p_new_INPUT_VALUE_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_INPUT_VALUES_F',
                                     'LEGISLATION_SUBGROUP',
                                     p_old_LEGISLATION_SUBGROUP,
                                     p_new_LEGISLATION_SUBGROUP,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_INPUT_VALUES_F',
                                     'LOOKUP_TYPE',
                                     p_old_LOOKUP_TYPE,
                                     p_new_LOOKUP_TYPE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_INPUT_VALUES_F',
                                     'MANDATORY_FLAG',
                                     p_old_MANDATORY_FLAG,
                                     p_new_MANDATORY_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_INPUT_VALUES_F',
                                     'MAX_VALUE',
                                     p_old_MAX_VALUE,
                                     p_new_MAX_VALUE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_INPUT_VALUES_F',
                                     'MIN_VALUE',
                                     p_old_MIN_VALUE,
                                     p_new_MIN_VALUE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_INPUT_VALUES_F',
                                     'UOM',
                                     p_old_UOM,
                                     p_new_UOM,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_INPUT_VALUES_F',
                                     'WARNING_OR_ERROR',
                                     p_old_WARNING_OR_ERROR,
                                     p_new_WARNING_OR_ERROR,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_INPUT_VALUES_F',
                                     'WARNING_OR_ERROR',
                                     p_old_WARNING_OR_ERROR,
                                     p_new_WARNING_OR_ERROR,
                                     p_effective_date
                                  );
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_INPUT_VALUES_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_INPUT_VALUES_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                  );

  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => null,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_business_group_id     => p_business_group_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_surrogate_key         => p_new_INPUT_VALUE_ID
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
end PAY_INPUT_VALUES_F_aru;
--
/* Used generator to build this procedure, but removed some of that table values.
*/
/* PAY_ALL_PAYROLLS */
/* name : PAY_ALL_PAYROLLS_F_aru
   purpose : This is procedure that records any updates
             on payrolls.
*/
procedure PAY_ALL_PAYROLLS_F_aru(
p_business_group_id in number,
p_legislation_code in varchar2,
p_effective_date in date,
p_old_ATTRIBUTE1 in VARCHAR2,
p_new_ATTRIBUTE1 in VARCHAR2,
p_old_ATTRIBUTE10 in VARCHAR2,
p_new_ATTRIBUTE10 in VARCHAR2,
p_old_ATTRIBUTE11 in VARCHAR2,
p_new_ATTRIBUTE11 in VARCHAR2,
p_old_ATTRIBUTE12 in VARCHAR2,
p_new_ATTRIBUTE12 in VARCHAR2,
p_old_ATTRIBUTE13 in VARCHAR2,
p_new_ATTRIBUTE13 in VARCHAR2,
p_old_ATTRIBUTE14 in VARCHAR2,
p_new_ATTRIBUTE14 in VARCHAR2,
p_old_ATTRIBUTE15 in VARCHAR2,
p_new_ATTRIBUTE15 in VARCHAR2,
p_old_ATTRIBUTE16 in VARCHAR2,
p_new_ATTRIBUTE16 in VARCHAR2,
p_old_ATTRIBUTE17 in VARCHAR2,
p_new_ATTRIBUTE17 in VARCHAR2,
p_old_ATTRIBUTE18 in VARCHAR2,
p_new_ATTRIBUTE18 in VARCHAR2,
p_old_ATTRIBUTE19 in VARCHAR2,
p_new_ATTRIBUTE19 in VARCHAR2,
p_old_ATTRIBUTE2 in VARCHAR2,
p_new_ATTRIBUTE2 in VARCHAR2,
p_old_ATTRIBUTE20 in VARCHAR2,
p_new_ATTRIBUTE20 in VARCHAR2,
p_old_ATTRIBUTE3 in VARCHAR2,
p_new_ATTRIBUTE3 in VARCHAR2,
p_old_ATTRIBUTE4 in VARCHAR2,
p_new_ATTRIBUTE4 in VARCHAR2,
p_old_ATTRIBUTE5 in VARCHAR2,
p_new_ATTRIBUTE5 in VARCHAR2,
p_old_ATTRIBUTE6 in VARCHAR2,
p_new_ATTRIBUTE6 in VARCHAR2,
p_old_ATTRIBUTE7 in VARCHAR2,
p_new_ATTRIBUTE7 in VARCHAR2,
p_old_ATTRIBUTE8 in VARCHAR2,
p_new_ATTRIBUTE8 in VARCHAR2,
p_old_ATTRIBUTE9 in VARCHAR2,
p_new_ATTRIBUTE9 in VARCHAR2,
p_old_ATTRIBUTE_CATEGORY in VARCHAR2,
p_new_ATTRIBUTE_CATEGORY in VARCHAR2,
p_old_COST_ALLOCATION_KEYFLEX_ in NUMBER,
p_new_COST_ALLOCATION_KEYFLEX_ in NUMBER,
p_old_DEFAULT_PAYMENT_METHOD_I in NUMBER,
p_new_DEFAULT_PAYMENT_METHOD_I in NUMBER,
p_old_PAYROLL_ID in NUMBER,
p_new_PAYROLL_ID in NUMBER,
p_old_PRL_INFORMATION1 in VARCHAR2,
p_new_PRL_INFORMATION1 in VARCHAR2,
p_old_PRL_INFORMATION10 in VARCHAR2,
p_new_PRL_INFORMATION10 in VARCHAR2,
p_old_PRL_INFORMATION11 in VARCHAR2,
p_new_PRL_INFORMATION11 in VARCHAR2,
p_old_PRL_INFORMATION12 in VARCHAR2,
p_new_PRL_INFORMATION12 in VARCHAR2,
p_old_PRL_INFORMATION13 in VARCHAR2,
p_new_PRL_INFORMATION13 in VARCHAR2,
p_old_PRL_INFORMATION14 in VARCHAR2,
p_new_PRL_INFORMATION14 in VARCHAR2,
p_old_PRL_INFORMATION15 in VARCHAR2,
p_new_PRL_INFORMATION15 in VARCHAR2,
p_old_PRL_INFORMATION16 in VARCHAR2,
p_new_PRL_INFORMATION16 in VARCHAR2,
p_old_PRL_INFORMATION17 in VARCHAR2,
p_new_PRL_INFORMATION17 in VARCHAR2,
p_old_PRL_INFORMATION18 in VARCHAR2,
p_new_PRL_INFORMATION18 in VARCHAR2,
p_old_PRL_INFORMATION19 in VARCHAR2,
p_new_PRL_INFORMATION19 in VARCHAR2,
p_old_PRL_INFORMATION2 in VARCHAR2,
p_new_PRL_INFORMATION2 in VARCHAR2,
p_old_PRL_INFORMATION20 in VARCHAR2,
p_new_PRL_INFORMATION20 in VARCHAR2,
p_old_PRL_INFORMATION21 in VARCHAR2,
p_new_PRL_INFORMATION21 in VARCHAR2,
p_old_PRL_INFORMATION22 in VARCHAR2,
p_new_PRL_INFORMATION22 in VARCHAR2,
p_old_PRL_INFORMATION23 in VARCHAR2,
p_new_PRL_INFORMATION23 in VARCHAR2,
p_old_PRL_INFORMATION24 in VARCHAR2,
p_new_PRL_INFORMATION24 in VARCHAR2,
p_old_PRL_INFORMATION25 in VARCHAR2,
p_new_PRL_INFORMATION25 in VARCHAR2,
p_old_PRL_INFORMATION26 in VARCHAR2,
p_new_PRL_INFORMATION26 in VARCHAR2,
p_old_PRL_INFORMATION27 in VARCHAR2,
p_new_PRL_INFORMATION27 in VARCHAR2,
p_old_PRL_INFORMATION28 in VARCHAR2,
p_new_PRL_INFORMATION28 in VARCHAR2,
p_old_PRL_INFORMATION29 in VARCHAR2,
p_new_PRL_INFORMATION29 in VARCHAR2,
p_old_PRL_INFORMATION3 in VARCHAR2,
p_new_PRL_INFORMATION3 in VARCHAR2,
p_old_PRL_INFORMATION30 in VARCHAR2,
p_new_PRL_INFORMATION30 in VARCHAR2,
p_old_PRL_INFORMATION4 in VARCHAR2,
p_new_PRL_INFORMATION4 in VARCHAR2,
p_old_PRL_INFORMATION5 in VARCHAR2,
p_new_PRL_INFORMATION5 in VARCHAR2,
p_old_PRL_INFORMATION6 in VARCHAR2,
p_new_PRL_INFORMATION6 in VARCHAR2,
p_old_PRL_INFORMATION7 in VARCHAR2,
p_new_PRL_INFORMATION7 in VARCHAR2,
p_old_PRL_INFORMATION8 in VARCHAR2,
p_new_PRL_INFORMATION8 in VARCHAR2,
p_old_PRL_INFORMATION9 in VARCHAR2,
p_new_PRL_INFORMATION9 in VARCHAR2,
p_old_PRL_INFORMATION_CATEGORY in VARCHAR2,
p_new_PRL_INFORMATION_CATEGORY in VARCHAR2,
p_old_SOFT_CODING_KEYFLEX_ID in NUMBER,
p_new_SOFT_CODING_KEYFLEX_ID in NUMBER,
p_old_SUSPENSE_ACCOUNT_KEYFLEX in NUMBER,
p_new_SUSPENSE_ACCOUNT_KEYFLEX in NUMBER,
p_old_EFFECTIVE_END_DATE in DATE,
p_new_EFFECTIVE_END_DATE in DATE,
p_old_EFFECTIVE_START_DATE in DATE,
p_new_EFFECTIVE_START_DATE in DATE
)
is
--
 cursor get_asg (p_payroll_id in number) is
 select distinct asg.assignment_id
   from per_assignments_f asg
  where asg.payroll_id = p_payroll_id
    and p_effective_date < asg.effective_end_date;
--
begin
  hr_utility.set_location('pay_continuous_calc.PAY_ALL_PAYROLLS_F_aru', 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE1',
                                     p_old_ATTRIBUTE1,
                                     p_new_ATTRIBUTE1,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE10',
                                     p_old_ATTRIBUTE10,
                                     p_new_ATTRIBUTE10,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE11',
                                     p_old_ATTRIBUTE11,
                                     p_new_ATTRIBUTE11,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE12',
                                     p_old_ATTRIBUTE12,
                                     p_new_ATTRIBUTE12,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE13',
                                     p_old_ATTRIBUTE13,
                                     p_new_ATTRIBUTE13,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE14',
                                     p_old_ATTRIBUTE14,
                                     p_new_ATTRIBUTE14,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE15',
                                     p_old_ATTRIBUTE15,
                                     p_new_ATTRIBUTE15,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE16',
                                     p_old_ATTRIBUTE16,
                                     p_new_ATTRIBUTE16,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE17',
                                     p_old_ATTRIBUTE17,
                                     p_new_ATTRIBUTE17,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE18',
                                     p_old_ATTRIBUTE18,
                                     p_new_ATTRIBUTE18,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE19',
                                     p_old_ATTRIBUTE19,
                                     p_new_ATTRIBUTE19,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE2',
                                     p_old_ATTRIBUTE2,
                                     p_new_ATTRIBUTE2,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE20',
                                     p_old_ATTRIBUTE20,
                                     p_new_ATTRIBUTE20,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE3',
                                     p_old_ATTRIBUTE3,
                                     p_new_ATTRIBUTE3,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE4',
                                     p_old_ATTRIBUTE4,
                                     p_new_ATTRIBUTE4,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE5',
                                     p_old_ATTRIBUTE5,
                                     p_new_ATTRIBUTE5,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE6',
                                     p_old_ATTRIBUTE6,
                                     p_new_ATTRIBUTE6,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE7',
                                     p_old_ATTRIBUTE7,
                                     p_new_ATTRIBUTE7,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE8',
                                     p_old_ATTRIBUTE8,
                                     p_new_ATTRIBUTE8,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE9',
                                     p_old_ATTRIBUTE9,
                                     p_new_ATTRIBUTE9,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'ATTRIBUTE_CATEGORY',
                                     p_old_ATTRIBUTE_CATEGORY,
                                     p_new_ATTRIBUTE_CATEGORY,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'COST_ALLOCATION_KEYFLEX_ID',
                                     p_old_COST_ALLOCATION_KEYFLEX_,
                                     p_new_COST_ALLOCATION_KEYFLEX_,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'DEFAULT_PAYMENT_METHOD_ID',
                                     p_old_DEFAULT_PAYMENT_METHOD_I,
                                     p_new_DEFAULT_PAYMENT_METHOD_I,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION1',
                                     p_old_PRL_INFORMATION1,
                                     p_new_PRL_INFORMATION1,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION10',
                                     p_old_PRL_INFORMATION10,
                                     p_new_PRL_INFORMATION10,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION11',
                                     p_old_PRL_INFORMATION11,
                                     p_new_PRL_INFORMATION11,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION12',
                                     p_old_PRL_INFORMATION12,
                                     p_new_PRL_INFORMATION12,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION13',
                                     p_old_PRL_INFORMATION13,
                                     p_new_PRL_INFORMATION13,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION14',
                                     p_old_PRL_INFORMATION14,
                                     p_new_PRL_INFORMATION14,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION15',
                                     p_old_PRL_INFORMATION15,
                                     p_new_PRL_INFORMATION15,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION16',
                                     p_old_PRL_INFORMATION16,
                                     p_new_PRL_INFORMATION16,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION17',
                                     p_old_PRL_INFORMATION17,
                                     p_new_PRL_INFORMATION17,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION18',
                                     p_old_PRL_INFORMATION18,
                                     p_new_PRL_INFORMATION18,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION19',
                                     p_old_PRL_INFORMATION19,
                                     p_new_PRL_INFORMATION19,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION2',
                                     p_old_PRL_INFORMATION2,
                                     p_new_PRL_INFORMATION2,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION20',
                                     p_old_PRL_INFORMATION20,
                                     p_new_PRL_INFORMATION20,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION21',
                                     p_old_PRL_INFORMATION21,
                                     p_new_PRL_INFORMATION21,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION22',
                                     p_old_PRL_INFORMATION22,
                                     p_new_PRL_INFORMATION22,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION23',
                                     p_old_PRL_INFORMATION23,
                                     p_new_PRL_INFORMATION23,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION24',
                                     p_old_PRL_INFORMATION24,
                                     p_new_PRL_INFORMATION24,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION25',
                                     p_old_PRL_INFORMATION25,
                                     p_new_PRL_INFORMATION25,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION26',
                                     p_old_PRL_INFORMATION26,
                                     p_new_PRL_INFORMATION26,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION27',
                                     p_old_PRL_INFORMATION27,
                                     p_new_PRL_INFORMATION27,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION28',
                                     p_old_PRL_INFORMATION28,
                                     p_new_PRL_INFORMATION28,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION29',
                                     p_old_PRL_INFORMATION29,
                                     p_new_PRL_INFORMATION29,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION3',
                                     p_old_PRL_INFORMATION3,
                                     p_new_PRL_INFORMATION3,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION30',
                                     p_old_PRL_INFORMATION30,
                                     p_new_PRL_INFORMATION30,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION4',
                                     p_old_PRL_INFORMATION4,
                                     p_new_PRL_INFORMATION4,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION5',
                                     p_old_PRL_INFORMATION5,
                                     p_new_PRL_INFORMATION5,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION6',
                                     p_old_PRL_INFORMATION6,
                                     p_new_PRL_INFORMATION6,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION7',
                                     p_old_PRL_INFORMATION7,
                                     p_new_PRL_INFORMATION7,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION8',
                                     p_old_PRL_INFORMATION8,
                                     p_new_PRL_INFORMATION8,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION9',
                                     p_old_PRL_INFORMATION9,
                                     p_new_PRL_INFORMATION9,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'PRL_INFORMATION_CATEGORY',
                                     p_old_PRL_INFORMATION_CATEGORY,
                                     p_new_PRL_INFORMATION_CATEGORY,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'SOFT_CODING_KEYFLEX_ID',
                                     p_old_SOFT_CODING_KEYFLEX_ID,
                                     p_new_SOFT_CODING_KEYFLEX_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'SUSPENSE_ACCOUNT_KEYFLEX',
                                     p_old_SUSPENSE_ACCOUNT_KEYFLEX,
                                     p_new_SUSPENSE_ACCOUNT_KEYFLEX,
                                     p_effective_date
                                    );
--
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ALL_PAYROLLS_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                  );

  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => null,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_business_group_id     => p_business_group_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_surrogate_key         => p_new_PAYROLL_ID
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
  hr_utility.set_location('pay_continuous_calc.PAY_ALL_PAYROLLS_F_aru', 50);
--
end PAY_ALL_PAYROLLS_F_aru;
--
/* Used generator to build this procedure, but removed some of that table values.
*/
/* PAY_ELEMENT_TYEPS_F */
/* name : PAY_ELEMENT_TYPES_F_aru
   purpose : This is procedure that records any updates
             on element_types.
*/
procedure PAY_ELEMENT_TYPES_F_aru(
p_business_group_id in number,
p_legislation_code in varchar2,
p_effective_date in date,
p_old_ATTRIBUTE1 in VARCHAR2,
p_new_ATTRIBUTE1 in VARCHAR2,
p_old_ATTRIBUTE10 in VARCHAR2,
p_new_ATTRIBUTE10 in VARCHAR2,
p_old_ATTRIBUTE11 in VARCHAR2,
p_new_ATTRIBUTE11 in VARCHAR2,
p_old_ATTRIBUTE12 in VARCHAR2,
p_new_ATTRIBUTE12 in VARCHAR2,
p_old_ATTRIBUTE13 in VARCHAR2,
p_new_ATTRIBUTE13 in VARCHAR2,
p_old_ATTRIBUTE14 in VARCHAR2,
p_new_ATTRIBUTE14 in VARCHAR2,
p_old_ATTRIBUTE15 in VARCHAR2,
p_new_ATTRIBUTE15 in VARCHAR2,
p_old_ATTRIBUTE16 in VARCHAR2,
p_new_ATTRIBUTE16 in VARCHAR2,
p_old_ATTRIBUTE17 in VARCHAR2,
p_new_ATTRIBUTE17 in VARCHAR2,
p_old_ATTRIBUTE18 in VARCHAR2,
p_new_ATTRIBUTE18 in VARCHAR2,
p_old_ATTRIBUTE19 in VARCHAR2,
p_new_ATTRIBUTE19 in VARCHAR2,
p_old_ATTRIBUTE2 in VARCHAR2,
p_new_ATTRIBUTE2 in VARCHAR2,
p_old_ATTRIBUTE20 in VARCHAR2,
p_new_ATTRIBUTE20 in VARCHAR2,
p_old_ATTRIBUTE3 in VARCHAR2,
p_new_ATTRIBUTE3 in VARCHAR2,
p_old_ATTRIBUTE4 in VARCHAR2,
p_new_ATTRIBUTE4 in VARCHAR2,
p_old_ATTRIBUTE5 in VARCHAR2,
p_new_ATTRIBUTE5 in VARCHAR2,
p_old_ATTRIBUTE6 in VARCHAR2,
p_new_ATTRIBUTE6 in VARCHAR2,
p_old_ATTRIBUTE7 in VARCHAR2,
p_new_ATTRIBUTE7 in VARCHAR2,
p_old_ATTRIBUTE8 in VARCHAR2,
p_new_ATTRIBUTE8 in VARCHAR2,
p_old_ATTRIBUTE9 in VARCHAR2,
p_new_ATTRIBUTE9 in VARCHAR2,
p_old_ATTRIBUTE_CATEGORY in VARCHAR2,
p_new_ATTRIBUTE_CATEGORY in VARCHAR2,
p_old_ELEMENT_INFORMATION1 in VARCHAR2,
p_new_ELEMENT_INFORMATION1 in VARCHAR2,
p_old_ELEMENT_INFORMATION10 in VARCHAR2,
p_new_ELEMENT_INFORMATION10 in VARCHAR2,
p_old_ELEMENT_INFORMATION11 in VARCHAR2,
p_new_ELEMENT_INFORMATION11 in VARCHAR2,
p_old_ELEMENT_INFORMATION12 in VARCHAR2,
p_new_ELEMENT_INFORMATION12 in VARCHAR2,
p_old_ELEMENT_INFORMATION13 in VARCHAR2,
p_new_ELEMENT_INFORMATION13 in VARCHAR2,
p_old_ELEMENT_INFORMATION14 in VARCHAR2,
p_new_ELEMENT_INFORMATION14 in VARCHAR2,
p_old_ELEMENT_INFORMATION15 in VARCHAR2,
p_new_ELEMENT_INFORMATION15 in VARCHAR2,
p_old_ELEMENT_INFORMATION16 in VARCHAR2,
p_new_ELEMENT_INFORMATION16 in VARCHAR2,
p_old_ELEMENT_INFORMATION17 in VARCHAR2,
p_new_ELEMENT_INFORMATION17 in VARCHAR2,
p_old_ELEMENT_INFORMATION18 in VARCHAR2,
p_new_ELEMENT_INFORMATION18 in VARCHAR2,
p_old_ELEMENT_INFORMATION19 in VARCHAR2,
p_new_ELEMENT_INFORMATION19 in VARCHAR2,
p_old_ELEMENT_INFORMATION2 in VARCHAR2,
p_new_ELEMENT_INFORMATION2 in VARCHAR2,
p_old_ELEMENT_INFORMATION20 in VARCHAR2,
p_new_ELEMENT_INFORMATION20 in VARCHAR2,
p_old_ELEMENT_INFORMATION3 in VARCHAR2,
p_new_ELEMENT_INFORMATION3 in VARCHAR2,
p_old_ELEMENT_INFORMATION4 in VARCHAR2,
p_new_ELEMENT_INFORMATION4 in VARCHAR2,
p_old_ELEMENT_INFORMATION5 in VARCHAR2,
p_new_ELEMENT_INFORMATION5 in VARCHAR2,
p_old_ELEMENT_INFORMATION6 in VARCHAR2,
p_new_ELEMENT_INFORMATION6 in VARCHAR2,
p_old_ELEMENT_INFORMATION7 in VARCHAR2,
p_new_ELEMENT_INFORMATION7 in VARCHAR2,
p_old_ELEMENT_INFORMATION8 in VARCHAR2,
p_new_ELEMENT_INFORMATION8 in VARCHAR2,
p_old_ELEMENT_INFORMATION9 in VARCHAR2,
p_new_ELEMENT_INFORMATION9 in VARCHAR2,
p_old_ELEMENT_INFORMATION_CATE in VARCHAR2,
p_new_ELEMENT_INFORMATION_CATE in VARCHAR2,
p_old_ELEMENT_TYPE_ID in NUMBER,
p_new_ELEMENT_TYPE_ID in NUMBER,
p_old_GROSSUP_FLAG in VARCHAR2,
p_new_GROSSUP_FLAG in VARCHAR2,
p_old_ITERATIVE_FLAG in VARCHAR2,
p_new_ITERATIVE_FLAG in VARCHAR2,
p_old_ITERATIVE_FORMULA_ID in NUMBER,
p_new_ITERATIVE_FORMULA_ID in NUMBER,
p_old_ITERATIVE_PRIORITY in NUMBER,
p_new_ITERATIVE_PRIORITY in NUMBER,
p_old_POST_TERMINATION_RULE in VARCHAR2,
p_new_POST_TERMINATION_RULE in VARCHAR2,
p_old_PROCESSING_PRIORITY in NUMBER,
p_new_PROCESSING_PRIORITY in NUMBER,
p_old_PROCESS_MODE in VARCHAR2,
p_new_PROCESS_MODE in VARCHAR2,
p_old_EFFECTIVE_END_DATE in DATE,
p_new_EFFECTIVE_END_DATE in DATE,
p_old_EFFECTIVE_START_DATE in DATE,
p_new_EFFECTIVE_START_DATE in DATE
)
is
--
begin
  hr_utility.set_location('pay_continuous_calc.PAY_ELEMENT_TYPES_F_aru', 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE1',
                                     p_old_ATTRIBUTE1,
                                     p_new_ATTRIBUTE1,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE10',
                                     p_old_ATTRIBUTE10,
                                     p_new_ATTRIBUTE10,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE11',
                                     p_old_ATTRIBUTE11,
                                     p_new_ATTRIBUTE11,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE12',
                                     p_old_ATTRIBUTE12,
                                     p_new_ATTRIBUTE12,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE13',
                                     p_old_ATTRIBUTE13,
                                     p_new_ATTRIBUTE13,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE14',
                                     p_old_ATTRIBUTE14,
                                     p_new_ATTRIBUTE14,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE15',
                                     p_old_ATTRIBUTE15,
                                     p_new_ATTRIBUTE15,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE16',
                                     p_old_ATTRIBUTE16,
                                     p_new_ATTRIBUTE16,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE17',
                                     p_old_ATTRIBUTE17,
                                     p_new_ATTRIBUTE17,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE18',
                                     p_old_ATTRIBUTE18,
                                     p_new_ATTRIBUTE18,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE19',
                                     p_old_ATTRIBUTE19,
                                     p_new_ATTRIBUTE19,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE2',
                                     p_old_ATTRIBUTE2,
                                     p_new_ATTRIBUTE2,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE20',
                                     p_old_ATTRIBUTE20,
                                     p_new_ATTRIBUTE20,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE3',
                                     p_old_ATTRIBUTE3,
                                     p_new_ATTRIBUTE3,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE4',
                                     p_old_ATTRIBUTE4,
                                     p_new_ATTRIBUTE4,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE5',
                                     p_old_ATTRIBUTE5,
                                     p_new_ATTRIBUTE5,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE6',
                                     p_old_ATTRIBUTE6,
                                     p_new_ATTRIBUTE6,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE7',
                                     p_old_ATTRIBUTE7,
                                     p_new_ATTRIBUTE7,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE8',
                                     p_old_ATTRIBUTE8,
                                     p_new_ATTRIBUTE8,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE9',
                                     p_old_ATTRIBUTE9,
                                     p_new_ATTRIBUTE9,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ATTRIBUTE_CATEGORY',
                                     p_old_ATTRIBUTE_CATEGORY,
                                     p_new_ATTRIBUTE_CATEGORY,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION1',
                                     p_old_ELEMENT_INFORMATION1,
                                     p_new_ELEMENT_INFORMATION1,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION10',
                                     p_old_ELEMENT_INFORMATION10,
                                     p_new_ELEMENT_INFORMATION10,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION11',
                                     p_old_ELEMENT_INFORMATION11,
                                     p_new_ELEMENT_INFORMATION11,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION12',
                                     p_old_ELEMENT_INFORMATION12,
                                     p_new_ELEMENT_INFORMATION12,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION13',
                                     p_old_ELEMENT_INFORMATION13,
                                     p_new_ELEMENT_INFORMATION13,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION14',
                                     p_old_ELEMENT_INFORMATION14,
                                     p_new_ELEMENT_INFORMATION14,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION15',
                                     p_old_ELEMENT_INFORMATION15,
                                     p_new_ELEMENT_INFORMATION15,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION16',
                                     p_old_ELEMENT_INFORMATION16,
                                     p_new_ELEMENT_INFORMATION16,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION17',
                                     p_old_ELEMENT_INFORMATION17,
                                     p_new_ELEMENT_INFORMATION17,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION18',
                                     p_old_ELEMENT_INFORMATION18,
                                     p_new_ELEMENT_INFORMATION18,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION19',
                                     p_old_ELEMENT_INFORMATION19,
                                     p_new_ELEMENT_INFORMATION19,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION2',
                                     p_old_ELEMENT_INFORMATION2,
                                     p_new_ELEMENT_INFORMATION2,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION20',
                                     p_old_ELEMENT_INFORMATION20,
                                     p_new_ELEMENT_INFORMATION20,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION3',
                                     p_old_ELEMENT_INFORMATION3,
                                     p_new_ELEMENT_INFORMATION3,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION4',
                                     p_old_ELEMENT_INFORMATION4,
                                     p_new_ELEMENT_INFORMATION4,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION5',
                                     p_old_ELEMENT_INFORMATION5,
                                     p_new_ELEMENT_INFORMATION5,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION6',
                                     p_old_ELEMENT_INFORMATION6,
                                     p_new_ELEMENT_INFORMATION6,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION7',
                                     p_old_ELEMENT_INFORMATION7,
                                     p_new_ELEMENT_INFORMATION7,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION8',
                                     p_old_ELEMENT_INFORMATION8,
                                     p_new_ELEMENT_INFORMATION8,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION9',
                                     p_old_ELEMENT_INFORMATION9,
                                     p_new_ELEMENT_INFORMATION9,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ELEMENT_INFORMATION_CATEGORY',
                                     p_old_ELEMENT_INFORMATION_CATE,
                                     p_new_ELEMENT_INFORMATION_CATE,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'GROSSUP_FLAG',
                                     p_old_GROSSUP_FLAG,
                                     p_new_GROSSUP_FLAG,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ITERATIVE_FLAG',
                                     p_old_ITERATIVE_FLAG,
                                     p_new_ITERATIVE_FLAG,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ITERATIVE_FORMULA_ID',
                                     p_old_ITERATIVE_FORMULA_ID,
                                     p_new_ITERATIVE_FORMULA_ID,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'ITERATIVE_PRIORITY',
                                     p_old_ITERATIVE_PRIORITY,
                                     p_new_ITERATIVE_PRIORITY,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'POST_TERMINATION_RULE',
                                     p_old_POST_TERMINATION_RULE,
                                     p_new_POST_TERMINATION_RULE,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'PROCESSING_PRIORITY',
                                     p_old_PROCESSING_PRIORITY,
                                     p_new_PROCESSING_PRIORITY,
                                     p_effective_date
                                    );
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'PROCESS_MODE',
                                     p_old_PROCESS_MODE,
                                     p_new_PROCESS_MODE,
                                     p_effective_date
                                    );
--
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_ELEMENT_TYPES_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                  );

  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => null,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_business_group_id     => p_business_group_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_surrogate_key         => p_new_ELEMENT_TYPE_ID
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
  hr_utility.set_location('pay_continuous_calc.PAY_ELEMENT_TYPES_F_aru', 50);
--
end PAY_ELEMENT_TYPES_F_aru;
--
/* PAY_GRADE_RULES_F */
/* name : PAY_GRADE_RULES_F_aru
   purpose : This is procedure that records any updates
             on grade_rules.
*/
procedure PAY_GRADE_RULES_F_aru(
p_business_group_id in number,
p_legislation_code in varchar2,
p_effective_date in date ,
p_old_GRADE_OR_SPINAL_POINT_ID in NUMBER,
p_new_GRADE_OR_SPINAL_POINT_ID in NUMBER ,
p_old_GRADE_RULE_ID in NUMBER,
p_new_GRADE_RULE_ID in NUMBER ,
p_old_MAXIMUM in VARCHAR2,
p_new_MAXIMUM in VARCHAR2 ,
p_old_MID_VALUE in VARCHAR2,
p_new_MID_VALUE in VARCHAR2 ,
p_old_MINIMUM in VARCHAR2,
p_new_MINIMUM in VARCHAR2 ,
p_old_PROGRAM_APPLICATION_ID in NUMBER,
p_new_PROGRAM_APPLICATION_ID in NUMBER ,
p_old_PROGRAM_ID in NUMBER,
p_new_PROGRAM_ID in NUMBER ,
p_old_PROGRAM_UPDATE_DATE in DATE,
p_new_PROGRAM_UPDATE_DATE in DATE ,
p_old_RATE_ID in NUMBER,
p_new_RATE_ID in NUMBER ,
p_old_RATE_TYPE in VARCHAR2,
p_new_RATE_TYPE in VARCHAR2 ,
p_old_REQUEST_ID in NUMBER,
p_new_REQUEST_ID in NUMBER ,
p_old_SEQUENCE in NUMBER,
p_new_SEQUENCE in NUMBER ,
p_old_VALUE in VARCHAR2,
p_new_VALUE in VARCHAR2 ,
p_old_EFFECTIVE_END_DATE in DATE,
p_new_EFFECTIVE_END_DATE in DATE ,
p_old_EFFECTIVE_START_DATE in DATE,
p_new_EFFECTIVE_START_DATE in DATE
)
is
--
begin
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_GRADE_RULES_F',
                                     'GRADE_OR_SPINAL_POINT_ID',
                                     p_old_GRADE_OR_SPINAL_POINT_ID,
                                     p_new_GRADE_OR_SPINAL_POINT_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_GRADE_RULES_F',
                                     'GRADE_RULE_ID',
                                     p_old_GRADE_RULE_ID,
                                     p_new_GRADE_RULE_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_GRADE_RULES_F',
                                     'MAXIMUM',
                                     p_old_MAXIMUM,
                                     p_new_MAXIMUM,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_GRADE_RULES_F',
                                     'MID_VALUE',
                                     p_old_MID_VALUE,
                                     p_new_MID_VALUE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_GRADE_RULES_F',
                                     'MINIMUM',
                                     p_old_MINIMUM,
                                     p_new_MINIMUM,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_GRADE_RULES_F',
                                     'PROGRAM_APPLICATION_ID',
                                     p_old_PROGRAM_APPLICATION_ID,
                                     p_new_PROGRAM_APPLICATION_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_GRADE_RULES_F',
                                     'PROGRAM_ID',
                                     p_old_PROGRAM_ID,
                                     p_new_PROGRAM_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_GRADE_RULES_F',
                                     'PROGRAM_UPDATE_DATE',
                                     p_old_PROGRAM_UPDATE_DATE,
                                     p_new_PROGRAM_UPDATE_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_GRADE_RULES_F',
                                     'RATE_ID',
                                     p_old_RATE_ID,
                                     p_new_RATE_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_GRADE_RULES_F',
                                     'RATE_TYPE',
                                     p_old_RATE_TYPE,
                                     p_new_RATE_TYPE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_GRADE_RULES_F',
                                     'REQUEST_ID',
                                     p_old_REQUEST_ID,
                                     p_new_REQUEST_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_GRADE_RULES_F',
                                     'SEQUENCE',
                                     p_old_SEQUENCE,
                                     p_new_SEQUENCE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_GRADE_RULES_F',
                                     'VALUE',
                                     p_old_VALUE,
                                     p_new_VALUE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_GRADE_RULES_F',
                                     'VALUE',
                                     p_old_VALUE,
                                     p_new_VALUE,
                                     p_effective_date
                                  );
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_GRADE_RULES_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_GRADE_RULES_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                  );

  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => null,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_business_group_id     => p_business_group_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_surrogate_key         => p_new_GRADE_RULE_ID
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
end PAY_GRADE_RULES_F_aru;
--


/* PER_ADDRESSES */
/* name : PER_ADDRESSES_ari
   purpose : This is procedure that records any insert
             on addresses table.
*/
  Procedure PER_ADDRESSES_ari(
                              p_business_group_id in number,
                              p_legislation_code in varchar2,
                              p_person_id in number,
                              p_effective_start_date in date,
                              p_new_address_id in number
                              )
is
--
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_assignments_f
   where person_id = p_person_id;
--
  l_process_event_id number;
  l_proc varchar2(240) := g_package||'.per_addresses_ari';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'I'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
      for asgrec in asgcur (p_person_id) loop
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                  p_assignment_id         => asgrec.assignment_id,
                                  p_effective_date        => g_event_list.effective_date(cnt),
                                  p_change_type           => g_event_list.change_type(cnt),
                                  p_status                => 'U',
                                  p_description           => g_event_list.description(cnt),
                                  p_process_event_id      => l_process_event_id,
                                  p_object_version_number => l_object_version_number,
                                  p_event_update_id       => g_event_list.event_update_id(cnt),
                                  p_business_group_id     => p_business_group_id,
                                  p_calculation_date      => g_event_list.calc_date(cnt),
                                  p_surrogate_key         => p_new_address_id
                                           );
       end loop;
      end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
  hr_utility.set_location(l_proc, 900);

end PER_ADDRESSES_ari;

--

/* name : PER_ADDRESSES_aru
   purpose : This is procedure that records any updates
             on addresses.
*/
procedure PER_ADDRESSES_aru(
p_business_group_id in number,
p_legislation_code in varchar2,
p_effective_date in date ,
p_old_ADDRESS_ID in NUMBER,
p_new_ADDRESS_ID in NUMBER ,
p_old_ADDRESS_LINE1 in VARCHAR2,
p_new_ADDRESS_LINE1 in VARCHAR2 ,
p_old_ADDRESS_LINE2 in VARCHAR2,
p_new_ADDRESS_LINE2 in VARCHAR2 ,
p_old_ADDRESS_LINE3 in VARCHAR2,
p_new_ADDRESS_LINE3 in VARCHAR2 ,
p_old_ADDRESS_TYPE in VARCHAR2,
p_new_ADDRESS_TYPE in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE1 in VARCHAR2,
p_new_ADDR_ATTRIBUTE1 in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE10 in VARCHAR2,
p_new_ADDR_ATTRIBUTE10 in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE11 in VARCHAR2,
p_new_ADDR_ATTRIBUTE11 in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE12 in VARCHAR2,
p_new_ADDR_ATTRIBUTE12 in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE13 in VARCHAR2,
p_new_ADDR_ATTRIBUTE13 in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE14 in VARCHAR2,
p_new_ADDR_ATTRIBUTE14 in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE15 in VARCHAR2,
p_new_ADDR_ATTRIBUTE15 in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE16 in VARCHAR2,
p_new_ADDR_ATTRIBUTE16 in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE17 in VARCHAR2,
p_new_ADDR_ATTRIBUTE17 in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE18 in VARCHAR2,
p_new_ADDR_ATTRIBUTE18 in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE19 in VARCHAR2,
p_new_ADDR_ATTRIBUTE19 in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE2 in VARCHAR2,
p_new_ADDR_ATTRIBUTE2 in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE20 in VARCHAR2,
p_new_ADDR_ATTRIBUTE20 in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE3 in VARCHAR2,
p_new_ADDR_ATTRIBUTE3 in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE4 in VARCHAR2,
p_new_ADDR_ATTRIBUTE4 in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE5 in VARCHAR2,
p_new_ADDR_ATTRIBUTE5 in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE6 in VARCHAR2,
p_new_ADDR_ATTRIBUTE6 in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE7 in VARCHAR2,
p_new_ADDR_ATTRIBUTE7 in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE8 in VARCHAR2,
p_new_ADDR_ATTRIBUTE8 in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE9 in VARCHAR2,
p_new_ADDR_ATTRIBUTE9 in VARCHAR2 ,
p_old_ADDR_ATTRIBUTE_CATEGORY in VARCHAR2,
p_new_ADDR_ATTRIBUTE_CATEGORY in VARCHAR2 ,
p_old_ADD_INFORMATION13 in VARCHAR2,
p_new_ADD_INFORMATION13 in VARCHAR2 ,
p_old_ADD_INFORMATION14 in VARCHAR2,
p_new_ADD_INFORMATION14 in VARCHAR2 ,
p_old_ADD_INFORMATION15 in VARCHAR2,
p_new_ADD_INFORMATION15 in VARCHAR2 ,
p_old_ADD_INFORMATION16 in VARCHAR2,
p_new_ADD_INFORMATION16 in VARCHAR2 ,
p_old_ADD_INFORMATION17 in VARCHAR2,
p_new_ADD_INFORMATION17 in VARCHAR2 ,
p_old_ADD_INFORMATION18 in VARCHAR2,
p_new_ADD_INFORMATION18 in VARCHAR2 ,
p_old_ADD_INFORMATION19 in VARCHAR2,
p_new_ADD_INFORMATION19 in VARCHAR2 ,
p_old_ADD_INFORMATION20 in VARCHAR2,
p_new_ADD_INFORMATION20 in VARCHAR2 ,
p_old_BUSINESS_GROUP_ID in NUMBER,
p_new_BUSINESS_GROUP_ID in NUMBER ,
p_old_COUNTRY in VARCHAR2,
p_new_COUNTRY in VARCHAR2 ,
p_old_DATE_FROM in DATE,
p_new_DATE_FROM in DATE ,
p_old_DATE_TO in DATE,
p_new_DATE_TO in DATE ,
p_old_PERSON_ID in NUMBER,
p_new_PERSON_ID in NUMBER ,
p_old_POSTAL_CODE in VARCHAR2,
p_new_POSTAL_CODE in VARCHAR2 ,
p_old_PRIMARY_FLAG in VARCHAR2,
p_new_PRIMARY_FLAG in VARCHAR2 ,
p_old_PROGRAM_APPLICATION_ID in NUMBER,
p_new_PROGRAM_APPLICATION_ID in NUMBER ,
p_old_PROGRAM_ID in NUMBER,
p_new_PROGRAM_ID in NUMBER ,
p_old_PROGRAM_UPDATE_DATE in DATE,
p_new_PROGRAM_UPDATE_DATE in DATE ,
p_old_REGION_1 in VARCHAR2,
p_new_REGION_1 in VARCHAR2 ,
p_old_REGION_2 in VARCHAR2,
p_new_REGION_2 in VARCHAR2 ,
p_old_REGION_3 in VARCHAR2,
p_new_REGION_3 in VARCHAR2 ,
p_old_REQUEST_ID in NUMBER,
p_new_REQUEST_ID in NUMBER ,
p_old_STYLE in VARCHAR2,
p_new_STYLE in VARCHAR2 ,
p_old_TELEPHONE_NUMBER_1 in VARCHAR2,
p_new_TELEPHONE_NUMBER_1 in VARCHAR2 ,
p_old_TELEPHONE_NUMBER_2 in VARCHAR2,
p_new_TELEPHONE_NUMBER_2 in VARCHAR2 ,
p_old_TELEPHONE_NUMBER_3 in VARCHAR2,
p_new_TELEPHONE_NUMBER_3 in VARCHAR2 ,
p_old_TOWN_OR_CITY in VARCHAR2,
p_new_TOWN_OR_CITY in VARCHAR2
)
is
--
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_assignments_f
   where person_id = p_person_id;
--
begin
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDRESS_ID',
                                     p_old_ADDRESS_ID,
                                     p_new_ADDRESS_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDRESS_LINE1',
                                     p_old_ADDRESS_LINE1,
                                     p_new_ADDRESS_LINE1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDRESS_LINE2',
                                     p_old_ADDRESS_LINE2,
                                     p_new_ADDRESS_LINE2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDRESS_LINE3',
                                     p_old_ADDRESS_LINE3,
                                     p_new_ADDRESS_LINE3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDRESS_TYPE',
                                     p_old_ADDRESS_TYPE,
                                     p_new_ADDRESS_TYPE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE1',
                                     p_old_ADDR_ATTRIBUTE1,
                                     p_new_ADDR_ATTRIBUTE1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE10',
                                     p_old_ADDR_ATTRIBUTE10,
                                     p_new_ADDR_ATTRIBUTE10,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE11',
                                     p_old_ADDR_ATTRIBUTE11,
                                     p_new_ADDR_ATTRIBUTE11,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE12',
                                     p_old_ADDR_ATTRIBUTE12,
                                     p_new_ADDR_ATTRIBUTE12,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE13',
                                     p_old_ADDR_ATTRIBUTE13,
                                     p_new_ADDR_ATTRIBUTE13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE14',
                                     p_old_ADDR_ATTRIBUTE14,
                                     p_new_ADDR_ATTRIBUTE14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE15',
                                     p_old_ADDR_ATTRIBUTE15,
                                     p_new_ADDR_ATTRIBUTE15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE16',
                                     p_old_ADDR_ATTRIBUTE16,
                                     p_new_ADDR_ATTRIBUTE16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE17',
                                     p_old_ADDR_ATTRIBUTE17,
                                     p_new_ADDR_ATTRIBUTE17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE18',
                                     p_old_ADDR_ATTRIBUTE18,
                                     p_new_ADDR_ATTRIBUTE18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE19',
                                     p_old_ADDR_ATTRIBUTE19,
                                     p_new_ADDR_ATTRIBUTE19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE2',
                                     p_old_ADDR_ATTRIBUTE2,
                                     p_new_ADDR_ATTRIBUTE2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE20',
                                     p_old_ADDR_ATTRIBUTE20,
                                     p_new_ADDR_ATTRIBUTE20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE3',
                                     p_old_ADDR_ATTRIBUTE3,
                                     p_new_ADDR_ATTRIBUTE3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE4',
                                     p_old_ADDR_ATTRIBUTE4,
                                     p_new_ADDR_ATTRIBUTE4,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE5',
                                     p_old_ADDR_ATTRIBUTE5,
                                     p_new_ADDR_ATTRIBUTE5,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE6',
                                     p_old_ADDR_ATTRIBUTE6,
                                     p_new_ADDR_ATTRIBUTE6,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE7',
                                     p_old_ADDR_ATTRIBUTE7,
                                     p_new_ADDR_ATTRIBUTE7,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE8',
                                     p_old_ADDR_ATTRIBUTE8,
                                     p_new_ADDR_ATTRIBUTE8,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE9',
                                     p_old_ADDR_ATTRIBUTE9,
                                     p_new_ADDR_ATTRIBUTE9,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADDR_ATTRIBUTE_CATEGORY',
                                     p_old_ADDR_ATTRIBUTE_CATEGORY,
                                     p_new_ADDR_ATTRIBUTE_CATEGORY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADD_INFORMATION13',
                                     p_old_ADD_INFORMATION13,
                                     p_new_ADD_INFORMATION13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADD_INFORMATION14',
                                     p_old_ADD_INFORMATION14,
                                     p_new_ADD_INFORMATION14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADD_INFORMATION15',
                                     p_old_ADD_INFORMATION15,
                                     p_new_ADD_INFORMATION15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADD_INFORMATION16',
                                     p_old_ADD_INFORMATION16,
                                     p_new_ADD_INFORMATION16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADD_INFORMATION17',
                                     p_old_ADD_INFORMATION17,
                                     p_new_ADD_INFORMATION17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADD_INFORMATION18',
                                     p_old_ADD_INFORMATION18,
                                     p_new_ADD_INFORMATION18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADD_INFORMATION19',
                                     p_old_ADD_INFORMATION19,
                                     p_new_ADD_INFORMATION19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'ADD_INFORMATION20',
                                     p_old_ADD_INFORMATION20,
                                     p_new_ADD_INFORMATION20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'BUSINESS_GROUP_ID',
                                     p_old_BUSINESS_GROUP_ID,
                                     p_new_BUSINESS_GROUP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'COUNTRY',
                                     p_old_COUNTRY,
                                     p_new_COUNTRY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'DATE_FROM',
                                     p_old_DATE_FROM,
                                     p_new_DATE_FROM,
                                     p_new_date_from,
                                     least(p_old_date_from,
                                           p_new_date_from)
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'DATE_TO',
                                     p_old_DATE_TO,
                                     p_new_DATE_TO,
                                     nvl(p_new_date_to,p_effective_date),
                                     least(p_old_date_to,
                                           p_new_date_to)
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'PERSON_ID',
                                     p_old_PERSON_ID,
                                     p_new_PERSON_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'POSTAL_CODE',
                                     p_old_POSTAL_CODE,
                                     p_new_POSTAL_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'PRIMARY_FLAG',
                                     p_old_PRIMARY_FLAG,
                                     p_new_PRIMARY_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'PROGRAM_APPLICATION_ID',
                                     p_old_PROGRAM_APPLICATION_ID,
                                     p_new_PROGRAM_APPLICATION_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'PROGRAM_ID',
                                     p_old_PROGRAM_ID,
                                     p_new_PROGRAM_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'PROGRAM_UPDATE_DATE',
                                     p_old_PROGRAM_UPDATE_DATE,
                                     p_new_PROGRAM_UPDATE_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'REGION_1',
                                     p_old_REGION_1,
                                     p_new_REGION_1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'REGION_2',
                                     p_old_REGION_2,
                                     p_new_REGION_2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'REGION_3',
                                     p_old_REGION_3,
                                     p_new_REGION_3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'REQUEST_ID',
                                     p_old_REQUEST_ID,
                                     p_new_REQUEST_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'STYLE',
                                     p_old_STYLE,
                                     p_new_STYLE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'TELEPHONE_NUMBER_1',
                                     p_old_TELEPHONE_NUMBER_1,
                                     p_new_TELEPHONE_NUMBER_1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'TELEPHONE_NUMBER_2',
                                     p_old_TELEPHONE_NUMBER_2,
                                     p_new_TELEPHONE_NUMBER_2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'TELEPHONE_NUMBER_3',
                                     p_old_TELEPHONE_NUMBER_3,
                                     p_new_TELEPHONE_NUMBER_3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ADDRESSES',
                                     'TOWN_OR_CITY',
                                     p_old_TOWN_OR_CITY,
                                     p_new_TOWN_OR_CITY,
                                     p_effective_date
                                  );
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
      for asgrec in asgcur (p_old_PERSON_ID) loop
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => asgrec.assignment_id,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_business_group_id     => p_business_group_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_surrogate_key         => p_old_address_id
                                           );
       end loop;
      end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
end PER_ADDRESSES_aru;
--

/* PER_ALL_PEOPLE_F */
/* name : PER_ALL_PEOPLE_F_ard
   purpose : This is procedure that records any Delete on people.
*/
--
 procedure PER_ALL_PEOPLE_F_ard(
                                         p_business_group_id in number,
                                         p_legislation_code in varchar2,
                                         p_old_person_id in number,
                                         p_old_effective_start_date in date,
                                         p_new_effective_start_date in date,
                                         p_old_effective_end_date in date,
                                         p_new_effective_end_date in date
                                        )
is
    l_process_event_id number;
    l_object_version_number number;
    l_effective_date date;
    l_proc varchar2(240) := g_package||'.PER_ALL_PEOPLE_F_ard';
--
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_assignments_f
   where person_id = p_person_id;
--
begin
hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;

    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     null,
                                     null,
                                     null,
                                     p_old_effective_start_date,
                                     p_old_effective_start_date,
                                     'D'	--l_mode
                                    );

   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
    hr_utility.trace('> With in Create Process Event:        ');
     for asgrec in asgcur (p_old_PERSON_ID) loop
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => asgrec.assignment_id,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_surrogate_key         => p_old_person_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_business_group_id     => p_business_group_id
                                           );


         end loop;
       end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
    hr_utility.set_location(l_proc, 900);
END PER_ALL_PEOPLE_F_ard;

/* PER_SPINAL_POINT_PLACEMENTS_F */
/* name : PER_SPINAL_POINT_PLCMTS_F_ard
   purpose : This is procedure that records any Delete on Spinal Point Placements.
*/
--
 procedure PER_SPIN_PNT_PLACEMENTS_F_ard(
                                         p_business_group_id in number,
                                         p_legislation_code in varchar2,
                                         p_old_placement_id in number,
                                         p_old_effective_start_date in date,
                                         p_new_effective_start_date in date,
                                         p_old_effective_end_date in date,
                                         p_new_effective_end_date in date,
					 p_old_assignment_id in number
                                        )
is
    l_process_event_id number;
    l_object_version_number number;
    l_proc varchar2(240) := g_package||'.PER_SPIN_PNT_PLACEMENTS_F_ard';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--


    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_SPINAL_POINT_PLACEMENTS_F',
                                     null,
                                     null,
                                     null,
                                     p_old_effective_start_date,
                                     p_old_effective_start_date,
                                     'D'
                                    );

   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
    hr_utility.trace('> With in Create Process Event:        ');
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => p_old_assignment_id,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_surrogate_key         => p_old_placement_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_business_group_id     => p_business_group_id
                                           );


         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
    hr_utility.set_location(l_proc, 900);
END PER_SPIN_PNT_PLACEMENTS_F_ard;


/* name : PER_SPINAL_POINT_PLCMTS_F_ari   -- Added for bug 6265962
   purpose : This is procedure that records any Insert on Spinal Point Placements.
*/
--
 procedure PER_SPIN_PNT_PLACEMENTS_F_ari(
                                         p_business_group_id in number,
                                         p_legislation_code in varchar2,
                                         p_placement_id in number,
					 p_assignment_id in number,
                                         p_effective_start_date in date
                                        )
is
    l_process_event_id number;
    l_object_version_number number;
    l_proc varchar2(240) := g_package||'.PER_SPIN_PNT_PLACEMENTS_F_ari';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--

    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_SPINAL_POINT_PLACEMENTS_F',
                                     null,
                                     null,
                                     null,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'I'
                                    );

   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
    hr_utility.trace('> With in Create Process Event:        ');
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => p_assignment_id,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_surrogate_key         => p_placement_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_business_group_id     => p_business_group_id
                                           );


         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
    hr_utility.set_location(l_proc, 900);
END PER_SPIN_PNT_PLACEMENTS_F_ari;
--

/* PAY_GRADE_RULES_F */
/* name : PAY_GRADE_RULES_F_ard
   purpose : This is procedure that records any Delete on Grade Rules.
*/
--

 procedure PAY_GRADE_RULES_F_ard(
                                         p_business_group_id in number,
                                         p_legislation_code in varchar2,
                                         p_old_grade_rule_id in number,
                                         p_old_effective_start_date in date,
                                         p_new_effective_start_date in date,
                                         p_old_effective_end_date in date,
                                         p_new_effective_end_date in date
                                        )
is
    l_process_event_id number;
    l_object_version_number number;
    l_proc varchar2(240) := g_package||'.PAY_GRADE_RULES_F_ard';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;

    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_GRADE_RULES_F',
                                     null,
                                     null,
                                     null,
                                     p_old_effective_start_date,
                                     p_old_effective_start_date,
                                     'D'	--l_mode
                                    );

   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
    hr_utility.trace('> With in Create Process Event:        ');
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => NULL,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_surrogate_key         => p_old_grade_rule_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_business_group_id     => p_business_group_id
                                           );


         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
    hr_utility.set_location(l_proc, 900);
END PAY_GRADE_RULES_F_ard;

--
/* PER_ALL_PEOPLE_F */
/* name : PER_ALL_PEOPLE_F_aru
   purpose : This is procedure that records any updates
             on people.
*/
procedure PER_ALL_PEOPLE_F_aru(
p_business_group_id in number,
p_legislation_code in varchar2,
p_effective_date in date ,
p_old_APPLICANT_NUMBER in VARCHAR2,
p_new_APPLICANT_NUMBER in VARCHAR2 ,
p_old_ATTRIBUTE1 in VARCHAR2,
p_new_ATTRIBUTE1 in VARCHAR2 ,
p_old_ATTRIBUTE10 in VARCHAR2,
p_new_ATTRIBUTE10 in VARCHAR2 ,
p_old_ATTRIBUTE11 in VARCHAR2,
p_new_ATTRIBUTE11 in VARCHAR2 ,
p_old_ATTRIBUTE12 in VARCHAR2,
p_new_ATTRIBUTE12 in VARCHAR2 ,
p_old_ATTRIBUTE13 in VARCHAR2,
p_new_ATTRIBUTE13 in VARCHAR2 ,
p_old_ATTRIBUTE14 in VARCHAR2,
p_new_ATTRIBUTE14 in VARCHAR2 ,
p_old_ATTRIBUTE15 in VARCHAR2,
p_new_ATTRIBUTE15 in VARCHAR2 ,
p_old_ATTRIBUTE16 in VARCHAR2,
p_new_ATTRIBUTE16 in VARCHAR2 ,
p_old_ATTRIBUTE17 in VARCHAR2,
p_new_ATTRIBUTE17 in VARCHAR2 ,
p_old_ATTRIBUTE18 in VARCHAR2,
p_new_ATTRIBUTE18 in VARCHAR2 ,
p_old_ATTRIBUTE19 in VARCHAR2,
p_new_ATTRIBUTE19 in VARCHAR2 ,
p_old_ATTRIBUTE2 in VARCHAR2,
p_new_ATTRIBUTE2 in VARCHAR2 ,
p_old_ATTRIBUTE20 in VARCHAR2,
p_new_ATTRIBUTE20 in VARCHAR2 ,
p_old_ATTRIBUTE21 in VARCHAR2,
p_new_ATTRIBUTE21 in VARCHAR2 ,
p_old_ATTRIBUTE22 in VARCHAR2,
p_new_ATTRIBUTE22 in VARCHAR2 ,
p_old_ATTRIBUTE23 in VARCHAR2,
p_new_ATTRIBUTE23 in VARCHAR2 ,
p_old_ATTRIBUTE24 in VARCHAR2,
p_new_ATTRIBUTE24 in VARCHAR2 ,
p_old_ATTRIBUTE25 in VARCHAR2,
p_new_ATTRIBUTE25 in VARCHAR2 ,
p_old_ATTRIBUTE26 in VARCHAR2,
p_new_ATTRIBUTE26 in VARCHAR2 ,
p_old_ATTRIBUTE27 in VARCHAR2,
p_new_ATTRIBUTE27 in VARCHAR2 ,
p_old_ATTRIBUTE28 in VARCHAR2,
p_new_ATTRIBUTE28 in VARCHAR2 ,
p_old_ATTRIBUTE29 in VARCHAR2,
p_new_ATTRIBUTE29 in VARCHAR2 ,
p_old_ATTRIBUTE3 in VARCHAR2,
p_new_ATTRIBUTE3 in VARCHAR2 ,
p_old_ATTRIBUTE30 in VARCHAR2,
p_new_ATTRIBUTE30 in VARCHAR2 ,
p_old_ATTRIBUTE4 in VARCHAR2,
p_new_ATTRIBUTE4 in VARCHAR2 ,
p_old_ATTRIBUTE5 in VARCHAR2,
p_new_ATTRIBUTE5 in VARCHAR2 ,
p_old_ATTRIBUTE6 in VARCHAR2,
p_new_ATTRIBUTE6 in VARCHAR2 ,
p_old_ATTRIBUTE7 in VARCHAR2,
p_new_ATTRIBUTE7 in VARCHAR2 ,
p_old_ATTRIBUTE8 in VARCHAR2,
p_new_ATTRIBUTE8 in VARCHAR2 ,
p_old_ATTRIBUTE9 in VARCHAR2,
p_new_ATTRIBUTE9 in VARCHAR2 ,
p_old_ATTRIBUTE_CATEGORY in VARCHAR2,
p_new_ATTRIBUTE_CATEGORY in VARCHAR2 ,
p_old_BACKGROUND_CHECK_STATUS in VARCHAR2,
p_new_BACKGROUND_CHECK_STATUS in VARCHAR2 ,
p_old_BACKGROUND_DATE_CHECK in DATE,
p_new_BACKGROUND_DATE_CHECK in DATE ,
p_old_BENEFIT_GROUP_ID in NUMBER,
p_new_BENEFIT_GROUP_ID in NUMBER ,
p_old_BLOOD_TYPE in VARCHAR2,
p_new_BLOOD_TYPE in VARCHAR2 ,
p_old_BUSINESS_GROUP_ID in NUMBER,
p_new_BUSINESS_GROUP_ID in NUMBER ,
p_old_COMMENT_ID in NUMBER,
p_new_COMMENT_ID in NUMBER ,
p_old_COORD_BEN_MED_PLN_NO in VARCHAR2,
p_new_COORD_BEN_MED_PLN_NO in VARCHAR2 ,
p_old_COORD_BEN_NO_CVG_FLAG in VARCHAR2,
p_new_COORD_BEN_NO_CVG_FLAG in VARCHAR2 ,
p_old_CORRESPONDENCE_LANGUAGE in VARCHAR2,
p_new_CORRESPONDENCE_LANGUAGE in VARCHAR2 ,
p_old_COUNTRY_OF_BIRTH in VARCHAR2,
p_new_COUNTRY_OF_BIRTH in VARCHAR2 ,
p_old_CURRENT_APPLICANT_FLAG in VARCHAR2,
p_new_CURRENT_APPLICANT_FLAG in VARCHAR2 ,
p_old_CURRENT_EMPLOYEE_FLAG in VARCHAR2,
p_new_CURRENT_EMPLOYEE_FLAG in VARCHAR2 ,
p_old_CURRENT_EMP_OR_APL_FLAG in VARCHAR2,
p_new_CURRENT_EMP_OR_APL_FLAG in VARCHAR2 ,
p_old_DATE_EMPLOYEE_DATA_VERIF in DATE,
p_new_DATE_EMPLOYEE_DATA_VERIF in DATE ,
p_old_DATE_OF_BIRTH in DATE,
p_new_DATE_OF_BIRTH in DATE ,
p_old_DATE_OF_DEATH in DATE,
p_new_DATE_OF_DEATH in DATE ,
p_old_DPDNT_ADOPTION_DATE in DATE,
p_new_DPDNT_ADOPTION_DATE in DATE ,
p_old_DPDNT_VLNTRY_SVCE_FLAG in VARCHAR2,
p_new_DPDNT_VLNTRY_SVCE_FLAG in VARCHAR2 ,
p_old_EMAIL_ADDRESS in VARCHAR2,
p_new_EMAIL_ADDRESS in VARCHAR2 ,
p_old_EMPLOYEE_NUMBER in VARCHAR2,
p_new_EMPLOYEE_NUMBER in VARCHAR2 ,
p_old_EXPENSE_CHECK_SEND_TO_AD in VARCHAR2,
p_new_EXPENSE_CHECK_SEND_TO_AD in VARCHAR2 ,
p_old_FAST_PATH_EMPLOYEE in VARCHAR2,
p_new_FAST_PATH_EMPLOYEE in VARCHAR2 ,
p_old_FIRST_NAME in VARCHAR2,
p_new_FIRST_NAME in VARCHAR2 ,
p_old_FTE_CAPACITY in NUMBER,
p_new_FTE_CAPACITY in NUMBER ,
p_old_FULL_NAME in VARCHAR2,
p_new_FULL_NAME in VARCHAR2 ,
p_old_GLOBAL_PERSON_ID in VARCHAR2,
p_new_GLOBAL_PERSON_ID in VARCHAR2 ,
p_old_HOLD_APPLICANT_DATE_UNTI in DATE,
p_new_HOLD_APPLICANT_DATE_UNTI in DATE ,
p_old_HONORS in VARCHAR2,
p_new_HONORS in VARCHAR2 ,
p_old_INTERNAL_LOCATION in VARCHAR2,
p_new_INTERNAL_LOCATION in VARCHAR2 ,
p_old_KNOWN_AS in VARCHAR2,
p_new_KNOWN_AS in VARCHAR2 ,
p_old_LAST_MEDICAL_TEST_BY in VARCHAR2,
p_new_LAST_MEDICAL_TEST_BY in VARCHAR2 ,
p_old_LAST_MEDICAL_TEST_DATE in DATE,
p_new_LAST_MEDICAL_TEST_DATE in DATE ,
p_old_LAST_NAME in VARCHAR2,
p_new_LAST_NAME in VARCHAR2 ,
p_old_MAILSTOP in VARCHAR2,
p_new_MAILSTOP in VARCHAR2 ,
p_old_MARITAL_STATUS in VARCHAR2,
p_new_MARITAL_STATUS in VARCHAR2 ,
p_old_MIDDLE_NAMES in VARCHAR2,
p_new_MIDDLE_NAMES in VARCHAR2 ,
p_old_NATIONALITY in VARCHAR2,
p_new_NATIONALITY in VARCHAR2 ,
p_old_NATIONAL_IDENTIFIER in VARCHAR2,
p_new_NATIONAL_IDENTIFIER in VARCHAR2 ,
p_old_OFFICE_NUMBER in VARCHAR2,
p_new_OFFICE_NUMBER in VARCHAR2 ,
p_old_ON_MILITARY_SERVICE in VARCHAR2,
p_new_ON_MILITARY_SERVICE in VARCHAR2 ,
p_old_ORDER_NAME in VARCHAR2,
p_new_ORDER_NAME in VARCHAR2 ,
p_old_ORIGINAL_DATE_OF_HIRE in DATE,
p_new_ORIGINAL_DATE_OF_HIRE in DATE ,
p_old_PERSON_ID in NUMBER,
p_new_PERSON_ID in NUMBER ,
p_old_PERSON_TYPE_ID in NUMBER,
p_new_PERSON_TYPE_ID in NUMBER ,
p_old_PER_INFORMATION1 in VARCHAR2,
p_new_PER_INFORMATION1 in VARCHAR2 ,
p_old_PER_INFORMATION10 in VARCHAR2,
p_new_PER_INFORMATION10 in VARCHAR2 ,
p_old_PER_INFORMATION11 in VARCHAR2,
p_new_PER_INFORMATION11 in VARCHAR2 ,
p_old_PER_INFORMATION12 in VARCHAR2,
p_new_PER_INFORMATION12 in VARCHAR2 ,
p_old_PER_INFORMATION13 in VARCHAR2,
p_new_PER_INFORMATION13 in VARCHAR2 ,
p_old_PER_INFORMATION14 in VARCHAR2,
p_new_PER_INFORMATION14 in VARCHAR2 ,
p_old_PER_INFORMATION15 in VARCHAR2,
p_new_PER_INFORMATION15 in VARCHAR2 ,
p_old_PER_INFORMATION16 in VARCHAR2,
p_new_PER_INFORMATION16 in VARCHAR2 ,
p_old_PER_INFORMATION17 in VARCHAR2,
p_new_PER_INFORMATION17 in VARCHAR2 ,
p_old_PER_INFORMATION18 in VARCHAR2,
p_new_PER_INFORMATION18 in VARCHAR2 ,
p_old_PER_INFORMATION19 in VARCHAR2,
p_new_PER_INFORMATION19 in VARCHAR2 ,
p_old_PER_INFORMATION2 in VARCHAR2,
p_new_PER_INFORMATION2 in VARCHAR2 ,
p_old_PER_INFORMATION20 in VARCHAR2,
p_new_PER_INFORMATION20 in VARCHAR2 ,
p_old_PER_INFORMATION21 in VARCHAR2,
p_new_PER_INFORMATION21 in VARCHAR2 ,
p_old_PER_INFORMATION22 in VARCHAR2,
p_new_PER_INFORMATION22 in VARCHAR2 ,
p_old_PER_INFORMATION23 in VARCHAR2,
p_new_PER_INFORMATION23 in VARCHAR2 ,
p_old_PER_INFORMATION24 in VARCHAR2,
p_new_PER_INFORMATION24 in VARCHAR2 ,
p_old_PER_INFORMATION25 in VARCHAR2,
p_new_PER_INFORMATION25 in VARCHAR2 ,
p_old_PER_INFORMATION26 in VARCHAR2,
p_new_PER_INFORMATION26 in VARCHAR2 ,
p_old_PER_INFORMATION27 in VARCHAR2,
p_new_PER_INFORMATION27 in VARCHAR2 ,
p_old_PER_INFORMATION28 in VARCHAR2,
p_new_PER_INFORMATION28 in VARCHAR2 ,
p_old_PER_INFORMATION29 in VARCHAR2,
p_new_PER_INFORMATION29 in VARCHAR2 ,
p_old_PER_INFORMATION3 in VARCHAR2,
p_new_PER_INFORMATION3 in VARCHAR2 ,
p_old_PER_INFORMATION30 in VARCHAR2,
p_new_PER_INFORMATION30 in VARCHAR2 ,
p_old_PER_INFORMATION4 in VARCHAR2,
p_new_PER_INFORMATION4 in VARCHAR2 ,
p_old_PER_INFORMATION5 in VARCHAR2,
p_new_PER_INFORMATION5 in VARCHAR2 ,
p_old_PER_INFORMATION6 in VARCHAR2,
p_new_PER_INFORMATION6 in VARCHAR2 ,
p_old_PER_INFORMATION7 in VARCHAR2,
p_new_PER_INFORMATION7 in VARCHAR2 ,
p_old_PER_INFORMATION8 in VARCHAR2,
p_new_PER_INFORMATION8 in VARCHAR2 ,
p_old_PER_INFORMATION9 in VARCHAR2,
p_new_PER_INFORMATION9 in VARCHAR2 ,
p_old_PER_INFORMATION_CATEGORY in VARCHAR2,
p_new_PER_INFORMATION_CATEGORY in VARCHAR2 ,
p_old_PREVIOUS_LAST_NAME in VARCHAR2,
p_new_PREVIOUS_LAST_NAME in VARCHAR2 ,
p_old_PRE_NAME_ADJUNCT in VARCHAR2,
p_new_PRE_NAME_ADJUNCT in VARCHAR2 ,
p_old_PROGRAM_APPLICATION_ID in NUMBER,
p_new_PROGRAM_APPLICATION_ID in NUMBER ,
p_old_PROGRAM_ID in NUMBER,
p_new_PROGRAM_ID in NUMBER ,
p_old_PROGRAM_UPDATE_DATE in DATE,
p_new_PROGRAM_UPDATE_DATE in DATE ,
p_old_PROJECTED_START_DATE in DATE,
p_new_PROJECTED_START_DATE in DATE ,
p_old_RECEIPT_OF_DEATH_CERT_DA in DATE,
p_new_RECEIPT_OF_DEATH_CERT_DA in DATE ,
p_old_REGION_OF_BIRTH in VARCHAR2,
p_new_REGION_OF_BIRTH in VARCHAR2 ,
p_old_REGISTERED_DISABLED_FLAG in VARCHAR2,
p_new_REGISTERED_DISABLED_FLAG in VARCHAR2 ,
p_old_REHIRE_AUTHORIZOR in VARCHAR2,
p_new_REHIRE_AUTHORIZOR in VARCHAR2 ,
p_old_REHIRE_REASON in VARCHAR2,
p_new_REHIRE_REASON in VARCHAR2 ,
p_old_REHIRE_RECOMMENDATION in VARCHAR2,
p_new_REHIRE_RECOMMENDATION in VARCHAR2 ,
p_old_REQUEST_ID in NUMBER,
p_new_REQUEST_ID in NUMBER ,
p_old_RESUME_EXISTS in VARCHAR2,
p_new_RESUME_EXISTS in VARCHAR2 ,
p_old_RESUME_LAST_UPDATED in DATE,
p_new_RESUME_LAST_UPDATED in DATE ,
p_old_SECOND_PASSPORT_EXISTS in VARCHAR2,
p_new_SECOND_PASSPORT_EXISTS in VARCHAR2 ,
p_old_SEX in VARCHAR2,
p_new_SEX in VARCHAR2 ,
p_old_START_DATE in DATE,
p_new_START_DATE in DATE ,
p_old_STUDENT_STATUS in VARCHAR2,
p_new_STUDENT_STATUS in VARCHAR2 ,
p_old_SUFFIX in VARCHAR2,
p_new_SUFFIX in VARCHAR2 ,
p_old_TITLE in VARCHAR2,
p_new_TITLE in VARCHAR2 ,
p_old_TOWN_OF_BIRTH in VARCHAR2,
p_new_TOWN_OF_BIRTH in VARCHAR2 ,
p_old_USES_TOBACCO_FLAG in VARCHAR2,
p_new_USES_TOBACCO_FLAG in VARCHAR2 ,
p_old_VENDOR_ID in NUMBER,
p_new_VENDOR_ID in NUMBER ,
p_old_WORK_SCHEDULE in VARCHAR2,
p_new_WORK_SCHEDULE in VARCHAR2 ,
p_old_WORK_TELEPHONE in VARCHAR2,
p_new_WORK_TELEPHONE in VARCHAR2 ,
p_old_EFFECTIVE_END_DATE in DATE,
p_new_EFFECTIVE_END_DATE in DATE ,
p_old_EFFECTIVE_START_DATE in DATE,
p_new_EFFECTIVE_START_DATE in DATE
)
is
--
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_assignments_f
   where person_id = p_person_id;
--
begin
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'APPLICANT_NUMBER',
                                     p_old_APPLICANT_NUMBER,
                                     p_new_APPLICANT_NUMBER,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE1',
                                     p_old_ATTRIBUTE1,
                                     p_new_ATTRIBUTE1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE10',
                                     p_old_ATTRIBUTE10,
                                     p_new_ATTRIBUTE10,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE11',
                                     p_old_ATTRIBUTE11,
                                     p_new_ATTRIBUTE11,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE12',
                                     p_old_ATTRIBUTE12,
                                     p_new_ATTRIBUTE12,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE13',
                                     p_old_ATTRIBUTE13,
                                     p_new_ATTRIBUTE13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE14',
                                     p_old_ATTRIBUTE14,
                                     p_new_ATTRIBUTE14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE15',
                                     p_old_ATTRIBUTE15,
                                     p_new_ATTRIBUTE15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE16',
                                     p_old_ATTRIBUTE16,
                                     p_new_ATTRIBUTE16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE17',
                                     p_old_ATTRIBUTE17,
                                     p_new_ATTRIBUTE17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE18',
                                     p_old_ATTRIBUTE18,
                                     p_new_ATTRIBUTE18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE19',
                                     p_old_ATTRIBUTE19,
                                     p_new_ATTRIBUTE19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE2',
                                     p_old_ATTRIBUTE2,
                                     p_new_ATTRIBUTE2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE20',
                                     p_old_ATTRIBUTE20,
                                     p_new_ATTRIBUTE20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE21',
                                     p_old_ATTRIBUTE21,
                                     p_new_ATTRIBUTE21,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE22',
                                     p_old_ATTRIBUTE22,
                                     p_new_ATTRIBUTE22,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE23',
                                     p_old_ATTRIBUTE23,
                                     p_new_ATTRIBUTE23,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE24',
                                     p_old_ATTRIBUTE24,
                                     p_new_ATTRIBUTE24,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE25',
                                     p_old_ATTRIBUTE25,
                                     p_new_ATTRIBUTE25,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE26',
                                     p_old_ATTRIBUTE26,
                                     p_new_ATTRIBUTE26,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE27',
                                     p_old_ATTRIBUTE27,
                                     p_new_ATTRIBUTE27,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE28',
                                     p_old_ATTRIBUTE28,
                                     p_new_ATTRIBUTE28,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE29',
                                     p_old_ATTRIBUTE29,
                                     p_new_ATTRIBUTE29,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE3',
                                     p_old_ATTRIBUTE3,
                                     p_new_ATTRIBUTE3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE30',
                                     p_old_ATTRIBUTE30,
                                     p_new_ATTRIBUTE30,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE4',
                                     p_old_ATTRIBUTE4,
                                     p_new_ATTRIBUTE4,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE5',
                                     p_old_ATTRIBUTE5,
                                     p_new_ATTRIBUTE5,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE6',
                                     p_old_ATTRIBUTE6,
                                     p_new_ATTRIBUTE6,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE7',
                                     p_old_ATTRIBUTE7,
                                     p_new_ATTRIBUTE7,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE8',
                                     p_old_ATTRIBUTE8,
                                     p_new_ATTRIBUTE8,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE9',
                                     p_old_ATTRIBUTE9,
                                     p_new_ATTRIBUTE9,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ATTRIBUTE_CATEGORY',
                                     p_old_ATTRIBUTE_CATEGORY,
                                     p_new_ATTRIBUTE_CATEGORY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'BACKGROUND_CHECK_STATUS',
                                     p_old_BACKGROUND_CHECK_STATUS,
                                     p_new_BACKGROUND_CHECK_STATUS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'BACKGROUND_DATE_CHECK',
                                     p_old_BACKGROUND_DATE_CHECK,
                                     p_new_BACKGROUND_DATE_CHECK,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'BENEFIT_GROUP_ID',
                                     p_old_BENEFIT_GROUP_ID,
                                     p_new_BENEFIT_GROUP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'BLOOD_TYPE',
                                     p_old_BLOOD_TYPE,
                                     p_new_BLOOD_TYPE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'BUSINESS_GROUP_ID',
                                     p_old_BUSINESS_GROUP_ID,
                                     p_new_BUSINESS_GROUP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'COMMENT_ID',
                                     p_old_COMMENT_ID,
                                     p_new_COMMENT_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'COORD_BEN_MED_PLN_NO',
                                     p_old_COORD_BEN_MED_PLN_NO,
                                     p_new_COORD_BEN_MED_PLN_NO,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'COORD_BEN_NO_CVG_FLAG',
                                     p_old_COORD_BEN_NO_CVG_FLAG,
                                     p_new_COORD_BEN_NO_CVG_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'CORRESPONDENCE_LANGUAGE',
                                     p_old_CORRESPONDENCE_LANGUAGE,
                                     p_new_CORRESPONDENCE_LANGUAGE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'COUNTRY_OF_BIRTH',
                                     p_old_COUNTRY_OF_BIRTH,
                                     p_new_COUNTRY_OF_BIRTH,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'CURRENT_APPLICANT_FLAG',
                                     p_old_CURRENT_APPLICANT_FLAG,
                                     p_new_CURRENT_APPLICANT_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'CURRENT_EMPLOYEE_FLAG',
                                     p_old_CURRENT_EMPLOYEE_FLAG,
                                     p_new_CURRENT_EMPLOYEE_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'CURRENT_EMP_OR_APL_FLAG',
                                     p_old_CURRENT_EMP_OR_APL_FLAG,
                                     p_new_CURRENT_EMP_OR_APL_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'DATE_EMPLOYEE_DATA_VERIFIED',
                                     p_old_DATE_EMPLOYEE_DATA_VERIF,
                                     p_new_DATE_EMPLOYEE_DATA_VERIF,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'DATE_OF_BIRTH',
                                     p_old_DATE_OF_BIRTH,
                                     p_new_DATE_OF_BIRTH,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'DATE_OF_DEATH',
                                     p_old_DATE_OF_DEATH,
                                     p_new_DATE_OF_DEATH,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'DPDNT_ADOPTION_DATE',
                                     p_old_DPDNT_ADOPTION_DATE,
                                     p_new_DPDNT_ADOPTION_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'DPDNT_VLNTRY_SVCE_FLAG',
                                     p_old_DPDNT_VLNTRY_SVCE_FLAG,
                                     p_new_DPDNT_VLNTRY_SVCE_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'EMAIL_ADDRESS',
                                     p_old_EMAIL_ADDRESS,
                                     p_new_EMAIL_ADDRESS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'EMPLOYEE_NUMBER',
                                     p_old_EMPLOYEE_NUMBER,
                                     p_new_EMPLOYEE_NUMBER,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'EXPENSE_CHECK_SEND_TO_ADDRESS',
                                     p_old_EXPENSE_CHECK_SEND_TO_AD,
                                     p_new_EXPENSE_CHECK_SEND_TO_AD,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'FAST_PATH_EMPLOYEE',
                                     p_old_FAST_PATH_EMPLOYEE,
                                     p_new_FAST_PATH_EMPLOYEE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'FIRST_NAME',
                                     p_old_FIRST_NAME,
                                     p_new_FIRST_NAME,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'FTE_CAPACITY',
                                     p_old_FTE_CAPACITY,
                                     p_new_FTE_CAPACITY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'FULL_NAME',
                                     p_old_FULL_NAME,
                                     p_new_FULL_NAME,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'GLOBAL_PERSON_ID',
                                     p_old_GLOBAL_PERSON_ID,
                                     p_new_GLOBAL_PERSON_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'HOLD_APPLICANT_DATE_UNTIL',
                                     p_old_HOLD_APPLICANT_DATE_UNTI,
                                     p_new_HOLD_APPLICANT_DATE_UNTI,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'HONORS',
                                     p_old_HONORS,
                                     p_new_HONORS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'INTERNAL_LOCATION',
                                     p_old_INTERNAL_LOCATION,
                                     p_new_INTERNAL_LOCATION,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'KNOWN_AS',
                                     p_old_KNOWN_AS,
                                     p_new_KNOWN_AS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'LAST_MEDICAL_TEST_BY',
                                     p_old_LAST_MEDICAL_TEST_BY,
                                     p_new_LAST_MEDICAL_TEST_BY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'LAST_MEDICAL_TEST_DATE',
                                     p_old_LAST_MEDICAL_TEST_DATE,
                                     p_new_LAST_MEDICAL_TEST_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'LAST_NAME',
                                     p_old_LAST_NAME,
                                     p_new_LAST_NAME,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'MAILSTOP',
                                     p_old_MAILSTOP,
                                     p_new_MAILSTOP,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'MARITAL_STATUS',
                                     p_old_MARITAL_STATUS,
                                     p_new_MARITAL_STATUS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'MIDDLE_NAMES',
                                     p_old_MIDDLE_NAMES,
                                     p_new_MIDDLE_NAMES,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'NATIONALITY',
                                     p_old_NATIONALITY,
                                     p_new_NATIONALITY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'NATIONAL_IDENTIFIER',
                                     p_old_NATIONAL_IDENTIFIER,
                                     p_new_NATIONAL_IDENTIFIER,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'OFFICE_NUMBER',
                                     p_old_OFFICE_NUMBER,
                                     p_new_OFFICE_NUMBER,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ON_MILITARY_SERVICE',
                                     p_old_ON_MILITARY_SERVICE,
                                     p_new_ON_MILITARY_SERVICE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ORDER_NAME',
                                     p_old_ORDER_NAME,
                                     p_new_ORDER_NAME,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ORIGINAL_DATE_OF_HIRE',
                                     p_old_ORIGINAL_DATE_OF_HIRE,
                                     p_new_ORIGINAL_DATE_OF_HIRE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PERSON_ID',
                                     p_old_PERSON_ID,
                                     p_new_PERSON_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PERSON_TYPE_ID',
                                     p_old_PERSON_TYPE_ID,
                                     p_new_PERSON_TYPE_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION1',
                                     p_old_PER_INFORMATION1,
                                     p_new_PER_INFORMATION1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION10',
                                     p_old_PER_INFORMATION10,
                                     p_new_PER_INFORMATION10,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION11',
                                     p_old_PER_INFORMATION11,
                                     p_new_PER_INFORMATION11,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION12',
                                     p_old_PER_INFORMATION12,
                                     p_new_PER_INFORMATION12,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION13',
                                     p_old_PER_INFORMATION13,
                                     p_new_PER_INFORMATION13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION14',
                                     p_old_PER_INFORMATION14,
                                     p_new_PER_INFORMATION14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION15',
                                     p_old_PER_INFORMATION15,
                                     p_new_PER_INFORMATION15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION16',
                                     p_old_PER_INFORMATION16,
                                     p_new_PER_INFORMATION16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION17',
                                     p_old_PER_INFORMATION17,
                                     p_new_PER_INFORMATION17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION18',
                                     p_old_PER_INFORMATION18,
                                     p_new_PER_INFORMATION18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION19',
                                     p_old_PER_INFORMATION19,
                                     p_new_PER_INFORMATION19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION2',
                                     p_old_PER_INFORMATION2,
                                     p_new_PER_INFORMATION2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION20',
                                     p_old_PER_INFORMATION20,
                                     p_new_PER_INFORMATION20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION21',
                                     p_old_PER_INFORMATION21,
                                     p_new_PER_INFORMATION21,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION22',
                                     p_old_PER_INFORMATION22,
                                     p_new_PER_INFORMATION22,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION23',
                                     p_old_PER_INFORMATION23,
                                     p_new_PER_INFORMATION23,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION24',
                                     p_old_PER_INFORMATION24,
                                     p_new_PER_INFORMATION24,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION25',
                                     p_old_PER_INFORMATION25,
                                     p_new_PER_INFORMATION25,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION26',
                                     p_old_PER_INFORMATION26,
                                     p_new_PER_INFORMATION26,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION27',
                                     p_old_PER_INFORMATION27,
                                     p_new_PER_INFORMATION27,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION28',
                                     p_old_PER_INFORMATION28,
                                     p_new_PER_INFORMATION28,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION29',
                                     p_old_PER_INFORMATION29,
                                     p_new_PER_INFORMATION29,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION3',
                                     p_old_PER_INFORMATION3,
                                     p_new_PER_INFORMATION3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION30',
                                     p_old_PER_INFORMATION30,
                                     p_new_PER_INFORMATION30,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION4',
                                     p_old_PER_INFORMATION4,
                                     p_new_PER_INFORMATION4,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION5',
                                     p_old_PER_INFORMATION5,
                                     p_new_PER_INFORMATION5,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION6',
                                     p_old_PER_INFORMATION6,
                                     p_new_PER_INFORMATION6,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION7',
                                     p_old_PER_INFORMATION7,
                                     p_new_PER_INFORMATION7,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION8',
                                     p_old_PER_INFORMATION8,
                                     p_new_PER_INFORMATION8,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION9',
                                     p_old_PER_INFORMATION9,
                                     p_new_PER_INFORMATION9,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PER_INFORMATION_CATEGORY',
                                     p_old_PER_INFORMATION_CATEGORY,
                                     p_new_PER_INFORMATION_CATEGORY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PREVIOUS_LAST_NAME',
                                     p_old_PREVIOUS_LAST_NAME,
                                     p_new_PREVIOUS_LAST_NAME,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PRE_NAME_ADJUNCT',
                                     p_old_PRE_NAME_ADJUNCT,
                                     p_new_PRE_NAME_ADJUNCT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PROGRAM_APPLICATION_ID',
                                     p_old_PROGRAM_APPLICATION_ID,
                                     p_new_PROGRAM_APPLICATION_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PROGRAM_ID',
                                     p_old_PROGRAM_ID,
                                     p_new_PROGRAM_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PROGRAM_UPDATE_DATE',
                                     p_old_PROGRAM_UPDATE_DATE,
                                     p_new_PROGRAM_UPDATE_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'PROJECTED_START_DATE',
                                     p_old_PROJECTED_START_DATE,
                                     p_new_PROJECTED_START_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'RECEIPT_OF_DEATH_CERT_DATE',
                                     p_old_RECEIPT_OF_DEATH_CERT_DA,
                                     p_new_RECEIPT_OF_DEATH_CERT_DA,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'REGION_OF_BIRTH',
                                     p_old_REGION_OF_BIRTH,
                                     p_new_REGION_OF_BIRTH,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'REGISTERED_DISABLED_FLAG',
                                     p_old_REGISTERED_DISABLED_FLAG,
                                     p_new_REGISTERED_DISABLED_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'REHIRE_AUTHORIZOR',
                                     p_old_REHIRE_AUTHORIZOR,
                                     p_new_REHIRE_AUTHORIZOR,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'REHIRE_REASON',
                                     p_old_REHIRE_REASON,
                                     p_new_REHIRE_REASON,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'REHIRE_RECOMMENDATION',
                                     p_old_REHIRE_RECOMMENDATION,
                                     p_new_REHIRE_RECOMMENDATION,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'REQUEST_ID',
                                     p_old_REQUEST_ID,
                                     p_new_REQUEST_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'RESUME_EXISTS',
                                     p_old_RESUME_EXISTS,
                                     p_new_RESUME_EXISTS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'RESUME_LAST_UPDATED',
                                     p_old_RESUME_LAST_UPDATED,
                                     p_new_RESUME_LAST_UPDATED,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'SECOND_PASSPORT_EXISTS',
                                     p_old_SECOND_PASSPORT_EXISTS,
                                     p_new_SECOND_PASSPORT_EXISTS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'SEX',
                                     p_old_SEX,
                                     p_new_SEX,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'START_DATE',
                                     p_old_START_DATE,
                                     p_new_START_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'STUDENT_STATUS',
                                     p_old_STUDENT_STATUS,
                                     p_new_STUDENT_STATUS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'SUFFIX',
                                     p_old_SUFFIX,
                                     p_new_SUFFIX,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'TITLE',
                                     p_old_TITLE,
                                     p_new_TITLE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'TOWN_OF_BIRTH',
                                     p_old_TOWN_OF_BIRTH,
                                     p_new_TOWN_OF_BIRTH,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'USES_TOBACCO_FLAG',
                                     p_old_USES_TOBACCO_FLAG,
                                     p_new_USES_TOBACCO_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'VENDOR_ID',
                                     p_old_VENDOR_ID,
                                     p_new_VENDOR_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'WORK_SCHEDULE',
                                     p_old_WORK_SCHEDULE,
                                     p_new_WORK_SCHEDULE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'WORK_TELEPHONE',
                                     p_old_WORK_TELEPHONE,
                                     p_new_WORK_TELEPHONE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'WORK_TELEPHONE',
                                     p_old_WORK_TELEPHONE,
                                     p_new_WORK_TELEPHONE,
                                     p_effective_date
                                  );
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                  );

-- bug 3728906, need to handle obscure case
--   effective_start_date and original_hire_date can get updated directly by
--   core code, so do this check as well
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ALL_PEOPLE_F',
                                     'ORIGINAL_DATE_OF_HIRE',
                                     p_old_ORIGINAL_DATE_OF_HIRE,
                                     p_new_ORIGINAL_DATE_OF_HIRE,
                                     --p_effective_date
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                  );


  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
      for asgrec in asgcur (p_old_PERSON_ID) loop
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => asgrec.assignment_id,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_business_group_id     => p_business_group_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_surrogate_key         => p_old_PERSON_ID
                                           );
       end loop;
      end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
end PER_ALL_PEOPLE_F_aru;
--
/* PER_SPINAL_POINT_PLACEMENTS_F */
/* name : PER_SPINAL_POINT_PLACEMENTS_F_aru
   purpose : This is procedure that records any updates
             on spinal point placement.
*/
procedure PER_SPIN_PNT_PLACEMENTS_F_aru(
p_business_group_id in number,
p_legislation_code in varchar2,
p_effective_date in date ,
p_old_ASSIGNMENT_ID in NUMBER,
p_new_ASSIGNMENT_ID in NUMBER ,
p_old_AUTO_INCREMENT_FLAG in VARCHAR2,
p_new_AUTO_INCREMENT_FLAG in VARCHAR2 ,
p_old_BUSINESS_GROUP_ID in NUMBER,
p_new_BUSINESS_GROUP_ID in NUMBER ,
p_old_PARENT_SPINE_ID in NUMBER,
p_new_PARENT_SPINE_ID in NUMBER ,
p_old_PLACEMENT_ID in NUMBER,
p_new_PLACEMENT_ID in NUMBER ,
p_old_PROGRAM_APPLICATION_ID in NUMBER,
p_new_PROGRAM_APPLICATION_ID in NUMBER ,
p_old_PROGRAM_ID in NUMBER,
p_new_PROGRAM_ID in NUMBER ,
p_old_PROGRAM_UPDATE_DATE in DATE,
p_new_PROGRAM_UPDATE_DATE in DATE ,
p_old_REASON in VARCHAR2,
p_new_REASON in VARCHAR2 ,
p_old_REQUEST_ID in NUMBER,
p_new_REQUEST_ID in NUMBER ,
p_old_STEP_ID in NUMBER,
p_new_STEP_ID in NUMBER ,
p_old_EFFECTIVE_END_DATE in DATE,
p_new_EFFECTIVE_END_DATE in DATE ,
p_old_EFFECTIVE_START_DATE in DATE,
p_new_EFFECTIVE_START_DATE in DATE
)
is
--
begin
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_SPINAL_POINT_PLACEMENTS_F',
                                     'ASSIGNMENT_ID',
                                     p_old_ASSIGNMENT_ID,
                                     p_new_ASSIGNMENT_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_SPINAL_POINT_PLACEMENTS_F',
                                     'AUTO_INCREMENT_FLAG',
                                     p_old_AUTO_INCREMENT_FLAG,
                                     p_new_AUTO_INCREMENT_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_SPINAL_POINT_PLACEMENTS_F',
                                     'BUSINESS_GROUP_ID',
                                     p_old_BUSINESS_GROUP_ID,
                                     p_new_BUSINESS_GROUP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_SPINAL_POINT_PLACEMENTS_F',
                                     'PARENT_SPINE_ID',
                                     p_old_PARENT_SPINE_ID,
                                     p_new_PARENT_SPINE_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_SPINAL_POINT_PLACEMENTS_F',
                                     'PLACEMENT_ID',
                                     p_old_PLACEMENT_ID,
                                     p_new_PLACEMENT_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_SPINAL_POINT_PLACEMENTS_F',
                                     'PROGRAM_APPLICATION_ID',
                                     p_old_PROGRAM_APPLICATION_ID,
                                     p_new_PROGRAM_APPLICATION_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_SPINAL_POINT_PLACEMENTS_F',
                                     'PROGRAM_ID',
                                     p_old_PROGRAM_ID,
                                     p_new_PROGRAM_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_SPINAL_POINT_PLACEMENTS_F',
                                     'PROGRAM_UPDATE_DATE',
                                     p_old_PROGRAM_UPDATE_DATE,
                                     p_new_PROGRAM_UPDATE_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_SPINAL_POINT_PLACEMENTS_F',
                                     'REASON',
                                     p_old_REASON,
                                     p_new_REASON,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_SPINAL_POINT_PLACEMENTS_F',
                                     'REQUEST_ID',
                                     p_old_REQUEST_ID,
                                     p_new_REQUEST_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_SPINAL_POINT_PLACEMENTS_F',
                                     'STEP_ID',
                                     p_old_STEP_ID,
                                     p_new_STEP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_SPINAL_POINT_PLACEMENTS_F',
                                     'STEP_ID',
                                     p_old_STEP_ID,
                                     p_new_STEP_ID,
                                     p_effective_date
                                  );
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_SPINAL_POINT_PLACEMENTS_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_SPINAL_POINT_PLACEMENTS_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                  );

  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => p_old_ASSIGNMENT_ID,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_business_group_id     => p_business_group_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_surrogate_key         => p_old_PLACEMENT_ID
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
end PER_SPIN_PNT_PLACEMENTS_F_aru;
--
procedure PER_ASSIGN_BUDGET_VALUES_F_aru(
p_business_group_id in number,
p_legislation_code in varchar2,
p_effective_date in date
,
p_old_ASSIGNMENT_BUDGET_VALUE_ in NUMBER,
p_new_ASSIGNMENT_BUDGET_VALUE_ in NUMBER
,
p_old_ASSIGNMENT_ID in NUMBER,
p_new_ASSIGNMENT_ID in NUMBER
,
p_old_BUSINESS_GROUP_ID in NUMBER,
p_new_BUSINESS_GROUP_ID in NUMBER
,
p_old_PROGRAM_APPLICATION_ID in NUMBER,
p_new_PROGRAM_APPLICATION_ID in NUMBER
,
p_old_PROGRAM_ID in NUMBER,
p_new_PROGRAM_ID in NUMBER
,
p_old_PROGRAM_UPDATE_DATE in DATE,
p_new_PROGRAM_UPDATE_DATE in DATE
,
p_old_REQUEST_ID in NUMBER,
p_new_REQUEST_ID in NUMBER
,
p_old_UNIT in VARCHAR2,
p_new_UNIT in VARCHAR2
,
p_old_VALUE in NUMBER,
p_new_VALUE in NUMBER
,
p_old_EFFECTIVE_END_DATE in DATE,
p_new_EFFECTIVE_END_DATE in DATE
,
p_old_EFFECTIVE_START_DATE in DATE,
p_new_EFFECTIVE_START_DATE in DATE
)
is
--
begin
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_BUDGET_VALUES_F',
                                     'ASSIGNMENT_BUDGET_VALUE_ID',
                                     p_old_ASSIGNMENT_BUDGET_VALUE_,
                                     p_new_ASSIGNMENT_BUDGET_VALUE_,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_BUDGET_VALUES_F',
                                     'ASSIGNMENT_ID',
                                     p_old_ASSIGNMENT_ID,
                                     p_new_ASSIGNMENT_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_BUDGET_VALUES_F',
                                     'BUSINESS_GROUP_ID',
                                     p_old_BUSINESS_GROUP_ID,
                                     p_new_BUSINESS_GROUP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_BUDGET_VALUES_F',
                                     'PROGRAM_APPLICATION_ID',
                                     p_old_PROGRAM_APPLICATION_ID,
                                     p_new_PROGRAM_APPLICATION_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_BUDGET_VALUES_F',
                                     'PROGRAM_ID',
                                     p_old_PROGRAM_ID,
                                     p_new_PROGRAM_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_BUDGET_VALUES_F',
                                     'PROGRAM_UPDATE_DATE',
                                     p_old_PROGRAM_UPDATE_DATE,
                                     p_new_PROGRAM_UPDATE_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_BUDGET_VALUES_F',
                                     'REQUEST_ID',
                                     p_old_REQUEST_ID,
                                     p_new_REQUEST_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_BUDGET_VALUES_F',
                                     'UNIT',
                                     p_old_UNIT,
                                     p_new_UNIT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_BUDGET_VALUES_F',
                                     'VALUE',
                                     p_old_VALUE,
                                     p_new_VALUE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_BUDGET_VALUES_F',
                                     'VALUE',
                                     p_old_VALUE,
                                     p_new_VALUE,
                                     p_effective_date
                                  );
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_BUDGET_VALUES_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_BUDGET_VALUES_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                  );

  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => p_new_assignment_id,
                                            p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
                                            p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => pay_continuous_calc.g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
                                            p_business_group_id     => p_business_group_id,
                                            p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
                                            p_surrogate_key         => p_new_assignment_budget_value_
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
end PER_ASSIGN_BUDGET_VALUES_F_aru;
--
  procedure PER_ASSIGN_BUDGET_VALUES_F_ari(
                                p_business_group_id in number,
                                p_legislation_code in varchar2,
                                p_ASSIGNMENT_BUDGET_VALUE_ in NUMBER,
                                p_ASSIGNMENT_ID in NUMBER,
                                p_PROGRAM_APPLICATION_ID in NUMBER,
                                p_PROGRAM_ID in NUMBER,
                                p_PROGRAM_UPDATE_DATE in DATE,
                                p_REQUEST_ID in NUMBER,
                                p_UNIT in VARCHAR2,
                                p_VALUE in NUMBER,
                                p_EFFECTIVE_END_DATE in DATE,
                                p_EFFECTIVE_START_DATE in DATE
    )
  is
    l_process_api boolean;
    l_process_event_id number;
    l_object_version_number number;
  begin
--
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_BUDGET_VALUES_F',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'I'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
            p_assignment_id         => p_assignment_id,
            p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
            p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
            p_status                => 'U',
            p_description           => pay_continuous_calc.g_event_list.description(cnt),
            p_process_event_id      => l_process_event_id,
            p_object_version_number => l_object_version_number,
            p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
            p_surrogate_key         => p_ASSIGNMENT_BUDGET_VALUE_,
            p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
            p_business_group_id     => p_business_group_id
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
  end PER_ASSIGN_BUDGET_VALUES_F_ari;


/* name : personal_payment_methods_ard
   purpose : This is procedure that records any deletes
             on personal_payment_methods.
*/
  procedure PER_ASSIGN_BUDGET_VALUES_ard(
                                         p_business_group_id in number,
                                         p_legislation_code in varchar2,
                                         p_assignment_id in number,
                                         p_effective_start_date in date,
                                         p_assignment_budget_value_ in number
                                        )
  is
    l_process_event_id number;
    l_object_version_number number;
    l_proc varchar2(240) := g_package||'.per_assign_budget_values_ard';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_BUDGET_VALUES_F',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'D'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
               p_assignment_id         => p_assignment_id,
               p_effective_date        => g_event_list.effective_date(cnt),
               p_change_type           => g_event_list.change_type(cnt),
               p_status                => 'U',
               p_description           => g_event_list.description(cnt),
               p_process_event_id      => l_process_event_id,
               p_object_version_number => l_object_version_number,
               p_event_update_id       => g_event_list.event_update_id(cnt),
               p_surrogate_key         => p_assignment_budget_value_,
               p_calculation_date      => g_event_list.calc_date(cnt),
               p_business_group_id     => p_business_group_id
           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
    hr_utility.set_location(l_proc, 900);
  END per_assign_budget_values_ard;

--


--------------------------------------------
-- PER_PERIODS_OF_SERVICE
--------------------------------------------
/* Used generator to build this procedure, but removed the references to
date columns as this is a non-datetrack table
We are assuming always correction
*/
/* PER_PERIODS_OF_SERVICE */
/* name : PER_PERIODS_OF_SERVICE_aru
   purpose : This is procedure that records any changes for updates
             on per_periods_of_service CORRECTION only.
*/
procedure PER_PERIODS_OF_SERVICE_aru(
    p_business_group_id in number,
    p_legislation_code in varchar2,
    p_effective_date in date ,
    p_old_ACCEPTED_TERMINATION_DAT in DATE,
    p_new_ACCEPTED_TERMINATION_DAT in DATE,
    p_old_ACTUAL_TERMINATION_DATE in DATE,
    p_new_ACTUAL_TERMINATION_DATE in DATE ,
    p_old_ADJUSTED_SVC_DATE in DATE,
    p_new_ADJUSTED_SVC_DATE in DATE ,
    p_old_ATTRIBUTE1 in VARCHAR2,
    p_new_ATTRIBUTE1 in VARCHAR2 ,
    p_old_ATTRIBUTE10 in VARCHAR2,
    p_new_ATTRIBUTE10 in VARCHAR2 ,
    p_old_ATTRIBUTE11 in VARCHAR2,
    p_new_ATTRIBUTE11 in VARCHAR2 ,
    p_old_ATTRIBUTE12 in VARCHAR2,
    p_new_ATTRIBUTE12 in VARCHAR2 ,
    p_old_ATTRIBUTE13 in VARCHAR2,
    p_new_ATTRIBUTE13 in VARCHAR2 ,
    p_old_ATTRIBUTE14 in VARCHAR2,
    p_new_ATTRIBUTE14 in VARCHAR2 ,
    p_old_ATTRIBUTE15 in VARCHAR2,
    p_new_ATTRIBUTE15 in VARCHAR2 ,
    p_old_ATTRIBUTE16 in VARCHAR2,
    p_new_ATTRIBUTE16 in VARCHAR2 ,
    p_old_ATTRIBUTE17 in VARCHAR2,
    p_new_ATTRIBUTE17 in VARCHAR2 ,
    p_old_ATTRIBUTE18 in VARCHAR2,
    p_new_ATTRIBUTE18 in VARCHAR2 ,
    p_old_ATTRIBUTE19 in VARCHAR2,
    p_new_ATTRIBUTE19 in VARCHAR2 ,
    p_old_ATTRIBUTE2 in VARCHAR2,
    p_new_ATTRIBUTE2 in VARCHAR2 ,
    p_old_ATTRIBUTE20 in VARCHAR2,
    p_new_ATTRIBUTE20 in VARCHAR2 ,
    p_old_ATTRIBUTE3 in VARCHAR2,
    p_new_ATTRIBUTE3 in VARCHAR2 ,
    p_old_ATTRIBUTE4 in VARCHAR2,
    p_new_ATTRIBUTE4 in VARCHAR2 ,
    p_old_ATTRIBUTE5 in VARCHAR2,
    p_new_ATTRIBUTE5 in VARCHAR2 ,
    p_old_ATTRIBUTE6 in VARCHAR2,
    p_new_ATTRIBUTE6 in VARCHAR2 ,
    p_old_ATTRIBUTE7 in VARCHAR2,
    p_new_ATTRIBUTE7 in VARCHAR2 ,
    p_old_ATTRIBUTE8 in VARCHAR2,
    p_new_ATTRIBUTE8 in VARCHAR2 ,
    p_old_ATTRIBUTE9 in VARCHAR2,
    p_new_ATTRIBUTE9 in VARCHAR2 ,
    p_old_ATTRIBUTE_CATEGORY in VARCHAR2,
    p_new_ATTRIBUTE_CATEGORY in VARCHAR2 ,
    p_old_BUSINESS_GROUP_ID in NUMBER,
    p_new_BUSINESS_GROUP_ID in NUMBER ,
    p_old_DATE_START in DATE,
    p_new_DATE_START in DATE ,
    p_old_FINAL_PROCESS_DATE in DATE,
    p_new_FINAL_PROCESS_DATE in DATE ,
    p_old_LAST_STANDARD_PROCESS_DA in DATE,
    p_new_LAST_STANDARD_PROCESS_DA in DATE ,
    p_old_LEAVING_REASON in VARCHAR2,
    p_new_LEAVING_REASON in VARCHAR2 ,
    p_old_NOTIFIED_TERMINATION_DAT in DATE,
    p_new_NOTIFIED_TERMINATION_DAT in DATE ,
    p_old_PDS_INFORMATION1 in VARCHAR2,
    p_new_PDS_INFORMATION1 in VARCHAR2 ,
    p_old_PDS_INFORMATION10 in VARCHAR2,
    p_new_PDS_INFORMATION10 in VARCHAR2 ,
    p_old_PDS_INFORMATION11 in VARCHAR2,
    p_new_PDS_INFORMATION11 in VARCHAR2 ,
    p_old_PDS_INFORMATION12 in VARCHAR2,
    p_new_PDS_INFORMATION12 in VARCHAR2 ,
    p_old_PDS_INFORMATION13 in VARCHAR2,
    p_new_PDS_INFORMATION13 in VARCHAR2 ,
    p_old_PDS_INFORMATION14 in VARCHAR2,
    p_new_PDS_INFORMATION14 in VARCHAR2 ,
    p_old_PDS_INFORMATION15 in VARCHAR2,
    p_new_PDS_INFORMATION15 in VARCHAR2 ,
    p_old_PDS_INFORMATION16 in VARCHAR2,
    p_new_PDS_INFORMATION16 in VARCHAR2 ,
    p_old_PDS_INFORMATION17 in VARCHAR2,
    p_new_PDS_INFORMATION17 in VARCHAR2 ,
    p_old_PDS_INFORMATION18 in VARCHAR2,
    p_new_PDS_INFORMATION18 in VARCHAR2 ,
    p_old_PDS_INFORMATION19 in VARCHAR2,
    p_new_PDS_INFORMATION19 in VARCHAR2 ,
    p_old_PDS_INFORMATION2 in VARCHAR2,
    p_new_PDS_INFORMATION2 in VARCHAR2 ,
    p_old_PDS_INFORMATION20 in VARCHAR2,
    p_new_PDS_INFORMATION20 in VARCHAR2 ,
    p_old_PDS_INFORMATION21 in VARCHAR2,
    p_new_PDS_INFORMATION21 in VARCHAR2 ,
    p_old_PDS_INFORMATION22 in VARCHAR2,
    p_new_PDS_INFORMATION22 in VARCHAR2 ,
    p_old_PDS_INFORMATION23 in VARCHAR2,
    p_new_PDS_INFORMATION23 in VARCHAR2 ,
    p_old_PDS_INFORMATION24 in VARCHAR2,
    p_new_PDS_INFORMATION24 in VARCHAR2 ,
    p_old_PDS_INFORMATION25 in VARCHAR2,
    p_new_PDS_INFORMATION25 in VARCHAR2 ,
    p_old_PDS_INFORMATION26 in VARCHAR2,
    p_new_PDS_INFORMATION26 in VARCHAR2 ,
    p_old_PDS_INFORMATION27 in VARCHAR2,
    p_new_PDS_INFORMATION27 in VARCHAR2 ,
    p_old_PDS_INFORMATION28 in VARCHAR2,
    p_new_PDS_INFORMATION28 in VARCHAR2 ,
    p_old_PDS_INFORMATION29 in VARCHAR2,
    p_new_PDS_INFORMATION29 in VARCHAR2 ,
    p_old_PDS_INFORMATION3 in VARCHAR2,
    p_new_PDS_INFORMATION3 in VARCHAR2 ,
    p_old_PDS_INFORMATION30 in VARCHAR2,
    p_new_PDS_INFORMATION30 in VARCHAR2 ,
    p_old_PDS_INFORMATION4 in VARCHAR2,
    p_new_PDS_INFORMATION4 in VARCHAR2 ,
    p_old_PDS_INFORMATION5 in VARCHAR2,
    p_new_PDS_INFORMATION5 in VARCHAR2 ,
    p_old_PDS_INFORMATION6 in VARCHAR2,
    p_new_PDS_INFORMATION6 in VARCHAR2 ,
    p_old_PDS_INFORMATION7 in VARCHAR2,
    p_new_PDS_INFORMATION7 in VARCHAR2 ,
    p_old_PDS_INFORMATION8 in VARCHAR2,
    p_new_PDS_INFORMATION8 in VARCHAR2 ,
    p_old_PDS_INFORMATION9 in VARCHAR2,
    p_new_PDS_INFORMATION9 in VARCHAR2 ,
    p_old_PDS_INFORMATION_CATEGORY in VARCHAR2,
    p_new_PDS_INFORMATION_CATEGORY in VARCHAR2 ,
    p_old_PERIOD_OF_SERVICE_ID in NUMBER,
    p_new_PERIOD_OF_SERVICE_ID in NUMBER ,
    p_old_PERSON_ID in NUMBER,
    p_new_PERSON_ID in NUMBER ,
    p_old_PRIOR_EMPLOYMENT_SSP_PAI in DATE,
    p_new_PRIOR_EMPLOYMENT_SSP_PAI in DATE ,
    p_old_PRIOR_EMPLOYMENT_SSP_WEE in NUMBER,
    p_new_PRIOR_EMPLOYMENT_SSP_WEE in NUMBER ,
    p_old_PROGRAM_APPLICATION_ID in NUMBER,
    p_new_PROGRAM_APPLICATION_ID in NUMBER ,
    p_old_PROGRAM_ID in NUMBER,
    p_new_PROGRAM_ID in NUMBER ,
    p_old_PROGRAM_UPDATE_DATE in DATE,
    p_new_PROGRAM_UPDATE_DATE in DATE ,
    p_old_PROJECTED_TERMINATION_DA in DATE,
    p_new_PROJECTED_TERMINATION_DA in DATE ,
    p_old_REQUEST_ID in NUMBER,
    p_new_REQUEST_ID in NUMBER ,
    p_old_TERMINATION_ACCEPTED_PER in NUMBER,
    p_new_TERMINATION_ACCEPTED_PER in NUMBER
)
is
--
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_assignments_f
   where person_id = p_person_id;
  l_proc varchar2(240) := g_package||'.per_periods_of_service_aru';

begin
  hr_utility.set_location(l_proc,10);

  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  -- We are assuming always a CORRECTION as non-datetracked table!
  --if (p_old_ = p_new_
     --and  p_old_ = p_new_) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ACCEPTED_TERMINATION_DATE',
                                     p_old_ACCEPTED_TERMINATION_DAT,
                                     p_new_ACCEPTED_TERMINATION_DAT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ACTUAL_TERMINATION_DATE',
                                     p_old_ACTUAL_TERMINATION_DATE,
                                     p_new_ACTUAL_TERMINATION_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ADJUSTED_SVC_DATE',
                                     p_old_ADJUSTED_SVC_DATE,
                                     p_new_ADJUSTED_SVC_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE1',
                                     p_old_ATTRIBUTE1,
                                     p_new_ATTRIBUTE1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE10',
                                     p_old_ATTRIBUTE10,
                                     p_new_ATTRIBUTE10,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE11',
                                     p_old_ATTRIBUTE11,
                                     p_new_ATTRIBUTE11,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE12',
                                     p_old_ATTRIBUTE12,
                                     p_new_ATTRIBUTE12,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE13',
                                     p_old_ATTRIBUTE13,
                                     p_new_ATTRIBUTE13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE14',
                                     p_old_ATTRIBUTE14,
                                     p_new_ATTRIBUTE14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE15',
                                     p_old_ATTRIBUTE15,
                                     p_new_ATTRIBUTE15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE16',
                                     p_old_ATTRIBUTE16,
                                     p_new_ATTRIBUTE16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE17',
                                     p_old_ATTRIBUTE17,
                                     p_new_ATTRIBUTE17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE18',
                                     p_old_ATTRIBUTE18,
                                     p_new_ATTRIBUTE18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE19',
                                     p_old_ATTRIBUTE19,
                                     p_new_ATTRIBUTE19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE2',
                                     p_old_ATTRIBUTE2,
                                     p_new_ATTRIBUTE2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE20',
                                     p_old_ATTRIBUTE20,
                                     p_new_ATTRIBUTE20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE3',
                                     p_old_ATTRIBUTE3,
                                     p_new_ATTRIBUTE3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE4',
                                     p_old_ATTRIBUTE4,
                                     p_new_ATTRIBUTE4,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE5',
                                     p_old_ATTRIBUTE5,
                                     p_new_ATTRIBUTE5,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE6',
                                     p_old_ATTRIBUTE6,
                                     p_new_ATTRIBUTE6,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE7',
                                     p_old_ATTRIBUTE7,
                                     p_new_ATTRIBUTE7,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE8',
                                     p_old_ATTRIBUTE8,
                                     p_new_ATTRIBUTE8,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE9',
                                     p_old_ATTRIBUTE9,
                                     p_new_ATTRIBUTE9,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'ATTRIBUTE_CATEGORY',
                                     p_old_ATTRIBUTE_CATEGORY,
                                     p_new_ATTRIBUTE_CATEGORY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'BUSINESS_GROUP_ID',
                                     p_old_BUSINESS_GROUP_ID,
                                     p_new_BUSINESS_GROUP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'DATE_START',
                                     p_old_DATE_START,
                                     p_new_DATE_START,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'FINAL_PROCESS_DATE',
                                     p_old_FINAL_PROCESS_DATE,
                                     p_new_FINAL_PROCESS_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'LAST_STANDARD_PROCESS_DATE',
                                     p_old_LAST_STANDARD_PROCESS_DA,
                                     p_new_LAST_STANDARD_PROCESS_DA,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'LEAVING_REASON',
                                     p_old_LEAVING_REASON,
                                     p_new_LEAVING_REASON,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'NOTIFIED_TERMINATION_DATE',
                                     p_old_NOTIFIED_TERMINATION_DAT,
                                     p_new_NOTIFIED_TERMINATION_DAT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION1',
                                     p_old_PDS_INFORMATION1,
                                     p_new_PDS_INFORMATION1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION10',
                                     p_old_PDS_INFORMATION10,
                                     p_new_PDS_INFORMATION10,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION11',
                                     p_old_PDS_INFORMATION11,
                                     p_new_PDS_INFORMATION11,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION12',
                                     p_old_PDS_INFORMATION12,
                                     p_new_PDS_INFORMATION12,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION13',
                                     p_old_PDS_INFORMATION13,
                                     p_new_PDS_INFORMATION13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION14',
                                     p_old_PDS_INFORMATION14,
                                     p_new_PDS_INFORMATION14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION15',
                                     p_old_PDS_INFORMATION15,
                                     p_new_PDS_INFORMATION15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION16',
                                     p_old_PDS_INFORMATION16,
                                     p_new_PDS_INFORMATION16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION17',
                                     p_old_PDS_INFORMATION17,
                                     p_new_PDS_INFORMATION17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION18',
                                     p_old_PDS_INFORMATION18,
                                     p_new_PDS_INFORMATION18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION19',
                                     p_old_PDS_INFORMATION19,
                                     p_new_PDS_INFORMATION19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION2',
                                     p_old_PDS_INFORMATION2,
                                     p_new_PDS_INFORMATION2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION20',
                                     p_old_PDS_INFORMATION20,
                                     p_new_PDS_INFORMATION20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION21',
                                     p_old_PDS_INFORMATION21,
                                     p_new_PDS_INFORMATION21,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION22',
                                     p_old_PDS_INFORMATION22,
                                     p_new_PDS_INFORMATION22,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION23',
                                     p_old_PDS_INFORMATION23,
                                     p_new_PDS_INFORMATION23,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION24',
                                     p_old_PDS_INFORMATION24,
                                     p_new_PDS_INFORMATION24,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION25',
                                     p_old_PDS_INFORMATION25,
                                     p_new_PDS_INFORMATION25,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION26',
                                     p_old_PDS_INFORMATION26,
                                     p_new_PDS_INFORMATION26,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION27',
                                     p_old_PDS_INFORMATION27,
                                     p_new_PDS_INFORMATION27,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION28',
                                     p_old_PDS_INFORMATION28,
                                     p_new_PDS_INFORMATION28,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION29',
                                     p_old_PDS_INFORMATION29,
                                     p_new_PDS_INFORMATION29,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION3',
                                     p_old_PDS_INFORMATION3,
                                     p_new_PDS_INFORMATION3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION30',
                                     p_old_PDS_INFORMATION30,
                                     p_new_PDS_INFORMATION30,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION4',
                                     p_old_PDS_INFORMATION4,
                                     p_new_PDS_INFORMATION4,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION5',
                                     p_old_PDS_INFORMATION5,
                                     p_new_PDS_INFORMATION5,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION6',
                                     p_old_PDS_INFORMATION6,
                                     p_new_PDS_INFORMATION6,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION7',
                                     p_old_PDS_INFORMATION7,
                                     p_new_PDS_INFORMATION7,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION8',
                                     p_old_PDS_INFORMATION8,
                                     p_new_PDS_INFORMATION8,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION9',
                                     p_old_PDS_INFORMATION9,
                                     p_new_PDS_INFORMATION9,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PDS_INFORMATION_CATEGORY',
                                     p_old_PDS_INFORMATION_CATEGORY,
                                     p_new_PDS_INFORMATION_CATEGORY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PERIOD_OF_SERVICE_ID',
                                     p_old_PERIOD_OF_SERVICE_ID,
                                     p_new_PERIOD_OF_SERVICE_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PERSON_ID',
                                     p_old_PERSON_ID,
                                     p_new_PERSON_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PRIOR_EMPLOYMENT_SSP_PAID_TO',
                                     p_old_PRIOR_EMPLOYMENT_SSP_PAI,
                                     p_new_PRIOR_EMPLOYMENT_SSP_PAI,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PRIOR_EMPLOYMENT_SSP_WEEKS',
                                     p_old_PRIOR_EMPLOYMENT_SSP_WEE,
                                     p_new_PRIOR_EMPLOYMENT_SSP_WEE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PROGRAM_APPLICATION_ID',
                                     p_old_PROGRAM_APPLICATION_ID,
                                     p_new_PROGRAM_APPLICATION_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PROGRAM_ID',
                                     p_old_PROGRAM_ID,
                                     p_new_PROGRAM_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PROGRAM_UPDATE_DATE',
                                     p_old_PROGRAM_UPDATE_DATE,
                                     p_new_PROGRAM_UPDATE_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'PROJECTED_TERMINATION_DATE',
                                     p_old_PROJECTED_TERMINATION_DA,
                                     p_new_PROJECTED_TERMINATION_DA,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'REQUEST_ID',
                                     p_old_REQUEST_ID,
                                     p_new_REQUEST_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_SERVICE',
                                     'TERMINATION_ACCEPTED_PERSON_ID',
                                     p_old_TERMINATION_ACCEPTED_PER,
                                     p_new_TERMINATION_ACCEPTED_PER,
                                     p_effective_date
                                  );

  --end if;
--
  hr_utility.set_location(l_proc,50);
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for asgrec in asgcur (p_old_PERSON_ID) loop
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
            p_assignment_id         => asgrec.assignment_id,
            p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
            p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
            p_status                => 'U',
            p_description           => pay_continuous_calc.g_event_list.description(cnt),
            p_process_event_id      => l_process_event_id,
            p_object_version_number => l_object_version_number,
            p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
            p_business_group_id     => p_business_group_id,
            p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
            p_surrogate_key         => p_new_period_of_service_id
           );
         end loop;
       end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
  hr_utility.set_location(l_proc,900);
end PER_PERIODS_OF_SERVICE_aru;

--------------------------------------------
-- PER_PAY_PROPOSALS_aru
--------------------------------------------
/* Used generator to build this procedure, but removed the references to
date columns as this is a non-datetrack table
We are assuming always correction
*/
/* PER_PAY_PROPOSALS */
/* name : PER_PAY_PROPOSALS_aru
   purpose : This is procedure that records any changes for updates
             on per_pay_proposals CORRECTION only.
*/

procedure PER_PAY_PROPOSALS_aru(
    p_business_group_id in number,
    p_legislation_code in varchar2,
    p_effective_date in date ,
    p_old_APPROVED in VARCHAR2,
    p_new_APPROVED in VARCHAR2 ,
    p_old_ASSIGNMENT_ID in NUMBER,
    p_new_ASSIGNMENT_ID in NUMBER ,
    p_old_ATTRIBUTE1 in VARCHAR2,
    p_new_ATTRIBUTE1 in VARCHAR2 ,
    p_old_ATTRIBUTE10 in VARCHAR2,
    p_new_ATTRIBUTE10 in VARCHAR2 ,
    p_old_ATTRIBUTE11 in VARCHAR2,
    p_new_ATTRIBUTE11 in VARCHAR2 ,
    p_old_ATTRIBUTE12 in VARCHAR2,
    p_new_ATTRIBUTE12 in VARCHAR2 ,
    p_old_ATTRIBUTE13 in VARCHAR2,
    p_new_ATTRIBUTE13 in VARCHAR2 ,
    p_old_ATTRIBUTE14 in VARCHAR2,
    p_new_ATTRIBUTE14 in VARCHAR2 ,
    p_old_ATTRIBUTE15 in VARCHAR2,
    p_new_ATTRIBUTE15 in VARCHAR2 ,
    p_old_ATTRIBUTE16 in VARCHAR2,
    p_new_ATTRIBUTE16 in VARCHAR2 ,
    p_old_ATTRIBUTE17 in VARCHAR2,
    p_new_ATTRIBUTE17 in VARCHAR2 ,
    p_old_ATTRIBUTE18 in VARCHAR2,
    p_new_ATTRIBUTE18 in VARCHAR2 ,
    p_old_ATTRIBUTE19 in VARCHAR2,
    p_new_ATTRIBUTE19 in VARCHAR2 ,
    p_old_ATTRIBUTE2 in VARCHAR2,
    p_new_ATTRIBUTE2 in VARCHAR2 ,
    p_old_ATTRIBUTE20 in VARCHAR2,
    p_new_ATTRIBUTE20 in VARCHAR2 ,
    p_old_ATTRIBUTE3 in VARCHAR2,
    p_new_ATTRIBUTE3 in VARCHAR2 ,
    p_old_ATTRIBUTE4 in VARCHAR2,
    p_new_ATTRIBUTE4 in VARCHAR2 ,
    p_old_ATTRIBUTE5 in VARCHAR2,
    p_new_ATTRIBUTE5 in VARCHAR2 ,
    p_old_ATTRIBUTE6 in VARCHAR2,
    p_new_ATTRIBUTE6 in VARCHAR2 ,
    p_old_ATTRIBUTE7 in VARCHAR2,
    p_new_ATTRIBUTE7 in VARCHAR2 ,
    p_old_ATTRIBUTE8 in VARCHAR2,
    p_new_ATTRIBUTE8 in VARCHAR2 ,
    p_old_ATTRIBUTE9 in VARCHAR2,
    p_new_ATTRIBUTE9 in VARCHAR2 ,
    p_old_ATTRIBUTE_CATEGORY in VARCHAR2,
    p_new_ATTRIBUTE_CATEGORY in VARCHAR2 ,
    p_old_BUSINESS_GROUP_ID in NUMBER,
    p_new_BUSINESS_GROUP_ID in NUMBER ,
    p_old_CHANGE_DATE in DATE,
    p_new_CHANGE_DATE in DATE ,
    p_old_EVENT_ID in NUMBER,
    p_new_EVENT_ID in NUMBER ,
    p_old_FORCED_RANKING in NUMBER,
    p_new_FORCED_RANKING in NUMBER ,
    p_old_LAST_CHANGE_DATE in DATE,
    p_new_LAST_CHANGE_DATE in DATE ,
    p_old_MULTIPLE_COMPONENTS in VARCHAR2,
    p_new_MULTIPLE_COMPONENTS in VARCHAR2 ,
    p_old_NEXT_PERF_REVIEW_DATE in DATE,
    p_new_NEXT_PERF_REVIEW_DATE in DATE ,
    p_old_NEXT_SAL_REVIEW_DATE in DATE,
    p_new_NEXT_SAL_REVIEW_DATE in DATE ,
    p_old_PAY_PROPOSAL_ID in NUMBER,
    p_new_PAY_PROPOSAL_ID in NUMBER ,
    p_old_PERFORMANCE_RATING in VARCHAR2,
    p_new_PERFORMANCE_RATING in VARCHAR2 ,
    p_old_PERFORMANCE_REVIEW_ID in NUMBER,
    p_new_PERFORMANCE_REVIEW_ID in NUMBER ,
    p_old_PROPOSAL_REASON in VARCHAR2,
    p_new_PROPOSAL_REASON in VARCHAR2 ,
    p_old_PROPOSED_SALARY in VARCHAR2,
    p_new_PROPOSED_SALARY in VARCHAR2 ,
    p_old_PROPOSED_SALARY_N in NUMBER,
    p_new_PROPOSED_SALARY_N in NUMBER ,
    p_old_REVIEW_DATE in DATE,
    p_new_REVIEW_DATE in DATE)
is
--
  l_proc varchar2(240) := g_package||'.per_pay_proposals_aru';
begin
  hr_utility.set_location(l_proc,10);
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  -- We are assuming always a CORRECTION as non-datetracked table!
  --if (p_old_ = p_new_
     --and  p_old_ = p_new_) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'APPROVED',
                                     p_old_APPROVED,
                                     p_new_APPROVED,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ASSIGNMENT_ID',
                                     p_old_ASSIGNMENT_ID,
                                     p_new_ASSIGNMENT_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE1',
                                     p_old_ATTRIBUTE1,
                                     p_new_ATTRIBUTE1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE10',
                                     p_old_ATTRIBUTE10,
                                     p_new_ATTRIBUTE10,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE11',
                                     p_old_ATTRIBUTE11,
                                     p_new_ATTRIBUTE11,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE12',
                                     p_old_ATTRIBUTE12,
                                     p_new_ATTRIBUTE12,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE13',
                                     p_old_ATTRIBUTE13,
                                     p_new_ATTRIBUTE13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE14',
                                     p_old_ATTRIBUTE14,
                                     p_new_ATTRIBUTE14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE15',
                                     p_old_ATTRIBUTE15,
                                     p_new_ATTRIBUTE15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE16',
                                     p_old_ATTRIBUTE16,
                                     p_new_ATTRIBUTE16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE17',
                                     p_old_ATTRIBUTE17,
                                     p_new_ATTRIBUTE17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE18',
                                     p_old_ATTRIBUTE18,
                                     p_new_ATTRIBUTE18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE19',
                                     p_old_ATTRIBUTE19,
                                     p_new_ATTRIBUTE19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE2',
                                     p_old_ATTRIBUTE2,
                                     p_new_ATTRIBUTE2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE20',
                                     p_old_ATTRIBUTE20,
                                     p_new_ATTRIBUTE20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE3',
                                     p_old_ATTRIBUTE3,
                                     p_new_ATTRIBUTE3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE4',
                                     p_old_ATTRIBUTE4,
                                     p_new_ATTRIBUTE4,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE5',
                                     p_old_ATTRIBUTE5,
                                     p_new_ATTRIBUTE5,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE6',
                                     p_old_ATTRIBUTE6,
                                     p_new_ATTRIBUTE6,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE7',
                                     p_old_ATTRIBUTE7,
                                     p_new_ATTRIBUTE7,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE8',
                                     p_old_ATTRIBUTE8,
                                     p_new_ATTRIBUTE8,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE9',
                                     p_old_ATTRIBUTE9,
                                     p_new_ATTRIBUTE9,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'ATTRIBUTE_CATEGORY',
                                     p_old_ATTRIBUTE_CATEGORY,
                                     p_new_ATTRIBUTE_CATEGORY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'BUSINESS_GROUP_ID',
                                     p_old_BUSINESS_GROUP_ID,
                                     p_new_BUSINESS_GROUP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'CHANGE_DATE',
                                     p_old_CHANGE_DATE,
                                     p_new_CHANGE_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'EVENT_ID',
                                     p_old_EVENT_ID,
                                     p_new_EVENT_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'FORCED_RANKING',
                                     p_old_FORCED_RANKING,
                                     p_new_FORCED_RANKING,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'LAST_CHANGE_DATE',
                                     p_old_LAST_CHANGE_DATE,
                                     p_new_LAST_CHANGE_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'MULTIPLE_COMPONENTS',
                                     p_old_MULTIPLE_COMPONENTS,
                                     p_new_MULTIPLE_COMPONENTS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'NEXT_PERF_REVIEW_DATE',
                                     p_old_NEXT_PERF_REVIEW_DATE,
                                     p_new_NEXT_PERF_REVIEW_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'NEXT_SAL_REVIEW_DATE',
                                     p_old_NEXT_SAL_REVIEW_DATE,
                                     p_new_NEXT_SAL_REVIEW_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'PAY_PROPOSAL_ID',
                                     p_old_PAY_PROPOSAL_ID,
                                     p_new_PAY_PROPOSAL_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'PERFORMANCE_RATING',
                                     p_old_PERFORMANCE_RATING,
                                     p_new_PERFORMANCE_RATING,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'PERFORMANCE_REVIEW_ID',
                                     p_old_PERFORMANCE_REVIEW_ID,
                                     p_new_PERFORMANCE_REVIEW_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'PROPOSAL_REASON',
                                     p_old_PROPOSAL_REASON,
                                     p_new_PROPOSAL_REASON,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'PROPOSED_SALARY',
                                     p_old_PROPOSED_SALARY,
                                     p_new_PROPOSED_SALARY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'PROPOSED_SALARY_N',
                                     p_old_PROPOSED_SALARY_N,
                                     p_new_PROPOSED_SALARY_N,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     'REVIEW_DATE',
                                     p_old_REVIEW_DATE,
                                     p_new_REVIEW_DATE,
                                     p_effective_date
                                  );

  -- CORRECTION ONLY end if;
--
   /* Now call the API for the affected assignments */
  hr_utility.set_location(l_proc,50);
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
             p_assignment_id         => p_new_assignment_id,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_business_group_id     => p_business_group_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_surrogate_key         => p_new_pay_proposal_id
           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
  hr_utility.set_location(l_proc,900);
end PER_PAY_PROPOSALS_aru;

/* PER_PAY_PROPOSALS */
/* name : PER_PAY_PROPOSALS_ari
   purpose : This is procedure that records any insert
             on per_pay_proposals.
*/
  procedure per_pay_proposals_ari(
                       p_business_group_id in number,
                       p_legislation_code in varchar2,
                       p_assignment_id in number,
                       p_effective_start_date in date,
                       p_pay_proposal_id in number
                       )
  is
    l_process_event_id number;
    l_object_version_number number;
    l_proc varchar2(240) := g_package||'.per_pay_proposals_ari';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
-- Date column notional as this is a non-datetrack table
-- See pycodtrg.ldt to see which value is used as 'effective_start_date'
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'I'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                         p_assignment_id         => p_assignment_id,
                         p_effective_date        => g_event_list.effective_date(cnt),
                         p_change_type           => g_event_list.change_type(cnt),
                         p_status                => 'U',
                         p_description           => g_event_list.description(cnt),
                         p_process_event_id      => l_process_event_id,
                         p_object_version_number => l_object_version_number,
                         p_event_update_id       => g_event_list.event_update_id(cnt),
                         p_surrogate_key         => p_pay_proposal_id,
                         p_calculation_date      => g_event_list.calc_date(cnt),
                         p_business_group_id     => p_business_group_id
                         );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
    hr_utility.set_location(l_proc, 900);
  end per_pay_proposals_ari;
--
/* name : per_pay_proposals_ard
   purpose : This is procedure that records any deletes
             on per_pay_proposals.
*/
  procedure per_pay_proposals_ard(
                       p_business_group_id in number,
                       p_legislation_code in varchar2,
                       p_assignment_id in number,
                       p_effective_start_date in date,
                       p_pay_proposal_id in number
                       )
  is
    l_process_event_id number;
    l_object_version_number number;
    l_proc varchar2(240) := g_package||'.per_pay_proposals_ard';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
-- Date column notional as this is a non-datetrack table
-- See pycodtrg.ldt to see which value is used as 'effective_start_date'
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PAY_PROPOSALS',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'D'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                         p_assignment_id         => p_assignment_id,
                         p_effective_date        => g_event_list.effective_date(cnt),
                         p_change_type           => g_event_list.change_type(cnt),
                         p_status                => 'U',
                         p_description           => g_event_list.description(cnt),
                         p_process_event_id      => l_process_event_id,
                         p_object_version_number => l_object_version_number,
                         p_event_update_id       => g_event_list.event_update_id(cnt),
                         p_surrogate_key         => p_pay_proposal_id,
                         p_calculation_date      => g_event_list.calc_date(cnt),
                         p_business_group_id     => p_business_group_id
                         );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
    hr_utility.set_location(l_proc, 900);
  END per_pay_proposals_ard;
--
--------------------------------------------
-- PER_PERFORMANCE_REVIEWS
--------------------------------------------
/* Used generator to build this procedure, but removed the references to
date columns as this is a non-datetrack table
We are assuming always correction
*/
/* PER_PERFORMANCE_REVIEWS */
/* name : PER_PERFORMANCE_REVIEWS
   purpose : This is procedure that records any changes for updates
             on per_performance_reviews CORRECTION only.
*/
procedure PER_PERFORMANCE_REVIEWS_aru(
    p_business_group_id in number,
    p_legislation_code in varchar2,
    p_effective_date in date ,
    p_old_ATTRIBUTE1 in VARCHAR2,
    p_new_ATTRIBUTE1 in VARCHAR2 ,
    p_old_ATTRIBUTE10 in VARCHAR2,
    p_new_ATTRIBUTE10 in VARCHAR2 ,
    p_old_ATTRIBUTE11 in VARCHAR2,
    p_new_ATTRIBUTE11 in VARCHAR2 ,
    p_old_ATTRIBUTE12 in VARCHAR2,
    p_new_ATTRIBUTE12 in VARCHAR2 ,
    p_old_ATTRIBUTE13 in VARCHAR2,
    p_new_ATTRIBUTE13 in VARCHAR2 ,
    p_old_ATTRIBUTE14 in VARCHAR2,
    p_new_ATTRIBUTE14 in VARCHAR2 ,
    p_old_ATTRIBUTE15 in VARCHAR2,
    p_new_ATTRIBUTE15 in VARCHAR2 ,
    p_old_ATTRIBUTE16 in VARCHAR2,
    p_new_ATTRIBUTE16 in VARCHAR2 ,
    p_old_ATTRIBUTE17 in VARCHAR2,
    p_new_ATTRIBUTE17 in VARCHAR2 ,
    p_old_ATTRIBUTE18 in VARCHAR2,
    p_new_ATTRIBUTE18 in VARCHAR2 ,
    p_old_ATTRIBUTE19 in VARCHAR2,
    p_new_ATTRIBUTE19 in VARCHAR2 ,
    p_old_ATTRIBUTE2 in VARCHAR2,
    p_new_ATTRIBUTE2 in VARCHAR2 ,
    p_old_ATTRIBUTE20 in VARCHAR2,
    p_new_ATTRIBUTE20 in VARCHAR2 ,
    p_old_ATTRIBUTE21 in VARCHAR2,
    p_new_ATTRIBUTE21 in VARCHAR2 ,
    p_old_ATTRIBUTE22 in VARCHAR2,
    p_new_ATTRIBUTE22 in VARCHAR2 ,
    p_old_ATTRIBUTE23 in VARCHAR2,
    p_new_ATTRIBUTE23 in VARCHAR2 ,
    p_old_ATTRIBUTE24 in VARCHAR2,
    p_new_ATTRIBUTE24 in VARCHAR2,
    p_old_ATTRIBUTE25 in VARCHAR2,
    p_new_ATTRIBUTE25 in VARCHAR2 ,
    p_old_ATTRIBUTE26 in VARCHAR2,
    p_new_ATTRIBUTE26 in VARCHAR2 ,
    p_old_ATTRIBUTE27 in VARCHAR2,
    p_new_ATTRIBUTE27 in VARCHAR2 ,
    p_old_ATTRIBUTE28 in VARCHAR2,
    p_new_ATTRIBUTE28 in VARCHAR2 ,
    p_old_ATTRIBUTE29 in VARCHAR2,
    p_new_ATTRIBUTE29 in VARCHAR2 ,
    p_old_ATTRIBUTE3 in VARCHAR2,
    p_new_ATTRIBUTE3 in VARCHAR2 ,
    p_old_ATTRIBUTE30 in VARCHAR2,
    p_new_ATTRIBUTE30 in VARCHAR2 ,
    p_old_ATTRIBUTE4 in VARCHAR2,
    p_new_ATTRIBUTE4 in VARCHAR2 ,
    p_old_ATTRIBUTE5 in VARCHAR2,
    p_new_ATTRIBUTE5 in VARCHAR2 ,
    p_old_ATTRIBUTE6 in VARCHAR2,
    p_new_ATTRIBUTE6 in VARCHAR2 ,
    p_old_ATTRIBUTE7 in VARCHAR2,
    p_new_ATTRIBUTE7 in VARCHAR2 ,
    p_old_ATTRIBUTE8 in VARCHAR2,
    p_new_ATTRIBUTE8 in VARCHAR2 ,
    p_old_ATTRIBUTE9 in VARCHAR2,
    p_new_ATTRIBUTE9 in VARCHAR2 ,
    p_old_ATTRIBUTE_CATEGORY in VARCHAR2,
    p_new_ATTRIBUTE_CATEGORY in VARCHAR2 ,
    p_old_EVENT_ID in NUMBER,
    p_new_EVENT_ID in NUMBER ,
    p_old_NEXT_PERF_REVIEW_DATE in DATE,
    p_new_NEXT_PERF_REVIEW_DATE in DATE ,
    p_old_PERFORMANCE_RATING in VARCHAR2,
    p_new_PERFORMANCE_RATING in VARCHAR2 ,
    p_old_PERFORMANCE_REVIEW_ID in NUMBER,
    p_new_PERFORMANCE_REVIEW_ID in NUMBER ,
    p_old_PERSON_ID in NUMBER,
    p_new_PERSON_ID in NUMBER ,
    p_old_REVIEW_DATE in DATE,
    p_new_REVIEW_DATE in DATE
)
is
--
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_assignments_f
   where person_id = p_person_id;
  l_proc varchar2(240) := g_package||'.per_performance_reviews_aru';

begin
  hr_utility.set_location(l_proc,10);

  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  -- We are assuming always a CORRECTION as non-datetracked table!
  --if (p_old_ = p_new_
     --and  p_old_ = p_new_) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE1',
                                     p_old_ATTRIBUTE1,
                                     p_new_ATTRIBUTE1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE10',
                                     p_old_ATTRIBUTE10,
                                     p_new_ATTRIBUTE10,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE11',
                                     p_old_ATTRIBUTE11,
                                     p_new_ATTRIBUTE11,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE12',
                                     p_old_ATTRIBUTE12,
                                     p_new_ATTRIBUTE12,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE13',
                                     p_old_ATTRIBUTE13,
                                     p_new_ATTRIBUTE13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE14',
                                     p_old_ATTRIBUTE14,
                                     p_new_ATTRIBUTE14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE15',
                                     p_old_ATTRIBUTE15,
                                     p_new_ATTRIBUTE15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE16',
                                     p_old_ATTRIBUTE16,
                                     p_new_ATTRIBUTE16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE17',
                                     p_old_ATTRIBUTE17,
                                     p_new_ATTRIBUTE17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE18',
                                     p_old_ATTRIBUTE18,
                                     p_new_ATTRIBUTE18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE19',
                                     p_old_ATTRIBUTE19,
                                     p_new_ATTRIBUTE19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE2',
                                     p_old_ATTRIBUTE2,
                                     p_new_ATTRIBUTE2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE20',
                                     p_old_ATTRIBUTE20,
                                     p_new_ATTRIBUTE20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE21',
                                     p_old_ATTRIBUTE21,
                                     p_new_ATTRIBUTE21,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE22',
                                     p_old_ATTRIBUTE22,
                                     p_new_ATTRIBUTE22,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE23',
                                     p_old_ATTRIBUTE23,
                                     p_new_ATTRIBUTE23,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE24',
                                     p_old_ATTRIBUTE24,
                                     p_new_ATTRIBUTE24,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE25',
                                     p_old_ATTRIBUTE25,
                                     p_new_ATTRIBUTE25,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE26',
                                     p_old_ATTRIBUTE26,
                                     p_new_ATTRIBUTE26,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE27',
                                     p_old_ATTRIBUTE27,
                                     p_new_ATTRIBUTE27,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE28',
                                     p_old_ATTRIBUTE28,
                                     p_new_ATTRIBUTE28,
                                     p_effective_date
                                  );

--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE29',
                                     p_old_ATTRIBUTE29,
                                     p_new_ATTRIBUTE29,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE3',
                                     p_old_ATTRIBUTE3,
                                     p_new_ATTRIBUTE3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE30',
                                     p_old_ATTRIBUTE30,
                                     p_new_ATTRIBUTE30,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE4',
                                     p_old_ATTRIBUTE4,
                                     p_new_ATTRIBUTE4,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE5',
                                     p_old_ATTRIBUTE5,
                                     p_new_ATTRIBUTE5,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE6',
                                     p_old_ATTRIBUTE6,
                                     p_new_ATTRIBUTE6,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE7',
                                     p_old_ATTRIBUTE7,
                                     p_new_ATTRIBUTE7,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE8',
                                     p_old_ATTRIBUTE8,
                                     p_new_ATTRIBUTE8,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE9',
                                     p_old_ATTRIBUTE9,
                                     p_new_ATTRIBUTE9,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE_CATEGORY',
                                     p_old_ATTRIBUTE_CATEGORY,
                                     p_new_ATTRIBUTE_CATEGORY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'EVENT_ID',
                                     p_old_EVENT_ID,
                                     p_new_EVENT_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'NEXT_PERF_REVIEW_DATE',
                                     p_old_NEXT_PERF_REVIEW_DATE,
                                     p_new_NEXT_PERF_REVIEW_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'PERFORMANCE_RATING',
                                     p_old_PERFORMANCE_RATING,
                                     p_new_PERFORMANCE_RATING,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'PERFORMANCE_REVIEW_ID',
                                     p_old_PERFORMANCE_REVIEW_ID,
                                     p_new_PERFORMANCE_REVIEW_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'PERSON_ID',
                                     p_old_PERSON_ID,
                                     p_new_PERSON_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'REVIEW_DATE',
                                     p_old_REVIEW_DATE,
                                     p_new_REVIEW_DATE,
                                     p_effective_date
                                  );

  --end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
      for asgrec in asgcur (p_old_PERSON_ID) loop
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
          pay_ppe_api.create_process_event(
            p_assignment_id         => asgrec.assignment_id,
            p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
            p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
            p_status                => 'U',
            p_description           => pay_continuous_calc.g_event_list.description(cnt),
            p_process_event_id      => l_process_event_id,
            p_object_version_number => l_object_version_number,
            p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
            p_business_group_id     => p_business_group_id,
            p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
            p_surrogate_key         => p_new_performance_review_id
           );
         end loop;
       end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
end PER_PERFORMANCE_REVIEWS_aru;

--
procedure PAY_COST_ALLOCATIONS_F_aru(
    p_business_group_id in number,
    p_legislation_code in varchar2,
    p_effective_date in date,
    p_old_ASSIGNMENT_ID in NUMBER,
    p_new_ASSIGNMENT_ID in NUMBER,
    p_old_BUSINESS_GROUP_ID in NUMBER,
    p_new_BUSINESS_GROUP_ID in NUMBER,
    p_old_COST_ALLOCATION_ID in NUMBER,
    p_new_COST_ALLOCATION_ID in NUMBER,
    p_old_COST_ALLOCATION_KEYFLEX_ in NUMBER,
    p_new_COST_ALLOCATION_KEYFLEX_ in NUMBER,
    p_old_PROGRAM_APPLICATION_ID in NUMBER,
    p_new_PROGRAM_APPLICATION_ID in NUMBER,
    p_old_PROGRAM_ID in NUMBER,
    p_new_PROGRAM_ID in NUMBER,
    p_old_PROGRAM_UPDATE_DATE in DATE,
    p_new_PROGRAM_UPDATE_DATE in DATE,
    p_old_PROPORTION in NUMBER,
    p_new_PROPORTION in NUMBER,
    p_old_REQUEST_ID in NUMBER,
    p_new_REQUEST_ID in NUMBER,
    p_old_EFFECTIVE_END_DATE in DATE,
    p_new_EFFECTIVE_END_DATE in DATE,
    p_old_EFFECTIVE_START_DATE in DATE,
    p_new_EFFECTIVE_START_DATE in DATE
)
is
--
begin
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_COST_ALLOCATIONS_F',
                                     'ASSIGNMENT_ID',
                                     p_old_ASSIGNMENT_ID,
                                     p_new_ASSIGNMENT_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_COST_ALLOCATIONS_F',
                                     'BUSINESS_GROUP_ID',
                                     p_old_BUSINESS_GROUP_ID,
                                     p_new_BUSINESS_GROUP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_COST_ALLOCATIONS_F',
                                     'COST_ALLOCATION_ID',
                                     p_old_COST_ALLOCATION_ID,
                                     p_new_COST_ALLOCATION_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_COST_ALLOCATIONS_F',
                                     'COST_ALLOCATION_KEYFLEX_ID',
                                     p_old_COST_ALLOCATION_KEYFLEX_,
                                     p_new_COST_ALLOCATION_KEYFLEX_,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_COST_ALLOCATIONS_F',
                                     'PROGRAM_APPLICATION_ID',
                                     p_old_PROGRAM_APPLICATION_ID,
                                     p_new_PROGRAM_APPLICATION_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_COST_ALLOCATIONS_F',
                                     'PROGRAM_ID',
                                     p_old_PROGRAM_ID,
                                     p_new_PROGRAM_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_COST_ALLOCATIONS_F',
                                     'PROGRAM_UPDATE_DATE',
                                     p_old_PROGRAM_UPDATE_DATE,
                                     p_new_PROGRAM_UPDATE_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_COST_ALLOCATIONS_F',
                                     'PROPORTION',
                                     p_old_PROPORTION,
                                     p_new_PROPORTION,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_COST_ALLOCATIONS_F',
                                     'REQUEST_ID',
                                     p_old_REQUEST_ID,
                                     p_new_REQUEST_ID,
                                     p_effective_date
                                  );
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_COST_ALLOCATIONS_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_COST_ALLOCATIONS_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                  );

  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
             p_assignment_id         => p_old_assignment_id,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_business_group_id     => p_business_group_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_surrogate_key         => p_new_cost_allocation_id
           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
end PAY_COST_ALLOCATIONS_F_aru;
--
/* PAY_COST_ALLOCATIONS_F */
/* name : PAY_COST_ALLOCATIONS_F_ari
   purpose : This is procedure that records any insert
             on PAY_COST_ALLOCATIONS_F.
*/
  procedure PAY_COST_ALLOCATIONS_F_ari(
                                         p_business_group_id in number,
                                         p_legislation_code in varchar2,
                                         p_assignment_id in number,
                                         p_effective_start_date in date,
                                         p_cost_allocation_id in number
                                        )
  is
    l_process_event_id number;
    l_object_version_number number;
    l_proc varchar2(240) := g_package||'.PAY_COST_ALLOCATIONS_F_ari';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_COST_ALLOCATIONS_F',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'I'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => p_assignment_id,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_surrogate_key         => p_cost_allocation_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_business_group_id     => p_business_group_id
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
    hr_utility.set_location(l_proc, 900);
  end PAY_COST_ALLOCATIONS_F_ari;
--
/* name : PAY_COST_ALLOCATIONS_F_ard
   purpose : This is procedure that records any deletes
             on PAY_COST_ALLOCATIONS_F.
*/
 procedure PAY_COST_ALLOCATIONS_F_ard(
                                         p_business_group_id in number,
                                         p_legislation_code in varchar2,
                                         p_assignment_id in number,
                                         p_old_cost_allocation_ID in number,
                                         p_old_effective_start_date in date,
                                         p_new_effective_start_date in date,
                                         p_old_effective_end_date in date,
                                         p_new_effective_end_date in date
                                        )
  is
    l_process_event_id number;
    l_object_version_number number;
    l_effective_date date;
    l_mode pay_event_updates.event_type%type;
    l_column_name pay_event_updates.column_name%type;
    l_old_value      date;
    l_new_value      date;
    l_proc varchar2(240) := g_package||'.PAY_COST_ALLOCATIONS_F_ard';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
--   hr_utility.trace('> p_assignment_id: '||p_assignment_id);
--    hr_utility.trace('> p_old_cost_allocation_ID:  '||p_old_cost_allocation_ID);
--    hr_utility.trace('> p_old_effective_start_date:        '||p_old_effective_start_date);
--    hr_utility.trace('> p_new_effective_start_date:       '||p_new_effective_start_date);
--    hr_utility.trace('> pay_dyn_triggers.g_dyt_mode:        '||pay_dyn_triggers.g_dyt_mode);
--    hr_utility.trace('> pay_dyn_triggers.g_dbms_dyt:        '||pay_dyn_triggers.g_dbms_dyt);

--
    if (   pay_dyn_triggers.g_dyt_mode = pay_dyn_triggers.g_dbms_dyt
        or pay_dyn_triggers.g_dyt_mode = 'ZAP') then
--
      if (   pay_dyn_triggers.g_dyt_mode = pay_dyn_triggers.g_dbms_dyt) then
        l_mode := 'D';
      else
        l_mode := pay_dyn_triggers.g_dyt_mode;
      end if;
      l_effective_date := p_old_effective_start_date;
      l_column_name := null;
      l_old_value   := null;
      l_new_value   := null;
--
    else
      l_mode := pay_dyn_triggers.g_dyt_mode;
      if (pay_dyn_triggers.g_dyt_mode = 'DELETE') then
--
         l_effective_date := p_new_effective_end_date;
         l_column_name := 'EFFECTIVE_END_DATE';
         l_old_value   := p_old_effective_end_date;
         l_new_value   := p_new_effective_end_date;
--
      elsif (pay_dyn_triggers.g_dyt_mode = 'FUTURE_CHANGE'
            or pay_dyn_triggers.g_dyt_mode = 'DELETE_NEXT_CHANGE') then
--
         l_effective_date := p_old_effective_start_date;
         l_column_name := 'EFFECTIVE_END_DATE';
         l_old_value   := p_old_effective_end_date;
         l_new_value   := p_new_effective_end_date;
--
      end if;
    end if;
--

--    hr_utility.trace('> l_mode:        '||l_mode);

    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_COST_ALLOCATIONS_F',
                                     l_column_name,
                                     l_old_value,
                                     l_new_value,
                                     l_effective_date,
                                     l_effective_date,
                                     l_mode
                                    );
   /* Now call the API for the affected assignments */


   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
    hr_utility.trace('> With in Create Process Event:        ');
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => p_assignment_id,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_surrogate_key         => p_old_cost_allocation_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_business_group_id     => p_business_group_id
                                           );


         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
    hr_utility.set_location(l_proc, 900);
  END PAY_COST_ALLOCATIONS_F_ard;
--

-- >>>
-- >>> INSERT NEW DYT CODE ABOVE HERE
-- >>>
--
/* OK Here are all the event procedures */
--
/* Name : ee_date_change
   Purpose : This procedure is used for an element entry date change check. It checks
             the screen entry values for changes.
*/
   procedure ee_date_change ( p_element_entry_id     in number,
                              p_assignment_action_id in number,
                              p_surrogate_key        in number,
                              p_column_name          in varchar2,
                              p_old_value            in varchar2,
                              p_new_value            in varchar2,
                              p_output_result       out nocopy varchar2,
                              p_date                 in date      default null
                            )
   is
    screen_val pay_element_entry_values_f.screen_entry_value%type;
    input_val  pay_element_entry_values_f.input_value_id%type;
--
   cursor do_start_chk (sk in number,
                        ed in varchar2)
   is
   select screen_entry_value,
          element_entry_value_id
     from pay_element_entry_values_f
    where element_entry_id = sk
      and ed = effective_start_date
    minus
   select screen_entry_value,
          element_entry_value_id
     from pay_element_entry_values_f
    where element_entry_id = sk
      and ed = to_char(effective_end_date - 1);
--
   cursor do_end_chk (sk in number,
                      ed in varchar2)
   is
   select screen_entry_value,
          element_entry_value_id
     from pay_element_entry_values_f
    where element_entry_id = sk
      and ed = effective_end_date
    minus
   select screen_entry_value,
          element_entry_value_id
     from pay_element_entry_values_f
    where element_entry_id = sk
      and ed = effective_start_date + 1;
--
   begin
     p_output_result := 'FALSE';
--
     if (p_column_name = 'EFFECTIVE_START_DATE') then
--
        for chkrec in do_start_chk(p_surrogate_key, p_new_value) loop
           p_output_result := 'TRUE';
        end loop;
--
     else
--
        for chkrec in do_end_chk(p_surrogate_key, p_old_value) loop
           p_output_result := 'TRUE';
        end loop;
--
     end if;
--
   end ee_date_change;
--
/* Name : grade_rule_change
   Purpose : This procedure is used for a grade rule change
             to check that an assignment is on that grade.
*/
   procedure grade_rule_change ( p_element_entry_id     in number,
                                 p_assignment_action_id in number,
                                 p_surrogate_key        in number,
                                 p_column_name          in varchar2,
                                 p_old_value            in varchar2,
                                 p_new_value            in varchar2,
                                 p_output_result       out nocopy varchar2,
                                 p_date                 in date      default null
                               )
   is
   --
     cursor grade_chk is
     select '' chk
       from pay_grade_rules_f pgr,
            pay_assignment_actions paa,
            per_assignments_f      paf
      where paa.assignment_action_id = p_assignment_action_id
        and pgr.grade_rule_id = p_surrogate_key
        and p_date between pgr.effective_start_date
                       and pgr.effective_end_date
        and paf.assignment_id = paa.assignment_id
     -- and p_date between paf.effective_start_date                  -- Bug 6625680
     --               and paf.effective_end_date
        and paf.grade_id = pgr.grade_or_spinal_point_id
     union
     select '' chk
       from pay_grade_rules_f             pgr,
            pay_assignment_actions        paa,
            per_spinal_points             psp,
            per_spinal_point_steps_f      psps,
            per_spinal_point_placements_f pspp
      where paa.assignment_action_id = p_assignment_action_id
        and pgr.grade_rule_id = p_surrogate_key
        and p_date between pgr.effective_start_date
                       and pgr.effective_end_date
        and pgr.rate_type = 'SP'
        and psp.spinal_point_id = pgr.grade_or_spinal_point_id
        and psp.spinal_point_id = psps.spinal_point_id
        and p_date between psps.effective_start_date
                       and psps.effective_end_date
        and paa.assignment_id = pspp.assignment_id
        and pspp.step_id = psps.step_id;
     -- and p_date between pspp.effective_start_date                  -- Bug 6625680
     --                and pspp.effective_end_date;
--
   begin
--
     p_output_result := 'FALSE';
--
     for chkrec in grade_chk loop
       p_output_result := 'TRUE';
     end loop;
--
   end grade_rule_change;
--
/* Name : input_value_change
   Purpose : This procedure is used for a input value change
             to check that an assignment has an entry with that input value.
*/
   procedure input_value_change ( p_element_entry_id     in number,
                                 p_assignment_action_id in number,
                                 p_surrogate_key        in number,
                                 p_column_name          in varchar2,
                                 p_old_value            in varchar2,
                                 p_new_value            in varchar2,
                                 p_output_result       out nocopy varchar2,
                                 p_date                 in date      default null
                               )
   is
       cursor get_et_details is
       select piv.hot_default_flag,
              piv.default_value iv_default_value,
              pliv.default_value liv_default_value,
              peev.screen_entry_value
         from pay_element_entries_f pee,
              pay_element_entry_values_f peev,
              pay_element_links_f pel,
              pay_link_input_values_f pliv,
              pay_element_types_f pet,
              pay_input_values_f piv
        where pee.element_entry_id = p_element_entry_id
          and pee.element_entry_id = peev.element_entry_id
          and peev.input_value_id = p_surrogate_key
          and pee.element_link_id = pel.element_link_id
          and pliv.element_link_id = pel.element_link_id
          and pliv.input_value_id = p_surrogate_key
          and pet.element_type_id = pel.element_type_id
          and pet.element_type_id = piv.element_type_id
          and piv.input_value_id = p_surrogate_key
          and p_date between piv.effective_start_date
                         and piv.effective_end_date
          and p_date between pet.effective_start_date
                         and pet.effective_end_date
          and p_date between pliv.effective_start_date
                         and pliv.effective_end_date
          and p_date between pel.effective_start_date
                         and pel.effective_end_date
          and p_date between peev.effective_start_date
                         and peev.effective_end_date
          and p_date between pee.effective_start_date
                         and pee.effective_end_date;

   begin
--
      p_output_result:= 'FALSE';
--
      for get_det in get_et_details loop
--
         /* Check the hot default flag for input values */
         if (p_column_name = 'DEFAULT_VALUE') then
--
            if (get_det.hot_default_flag = 'Y') then
               if (get_det.liv_default_value is null
                   and get_det.screen_entry_value is null) then
--
                  p_output_result:= 'TRUE';
               end if;
            end if;
--
         end if;
--
      end loop;
--
   end input_value_change;
--
/* Name : link_iv_change
   Purpose : This procedure is used for a link input value change
             to check that an assignment has an entry with that input value.
*/
   procedure link_iv_change ( p_element_entry_id     in number,
                              p_assignment_action_id in number,
                              p_surrogate_key        in number,
                              p_column_name          in varchar2,
                              p_old_value            in varchar2,
                              p_new_value            in varchar2,
                              p_output_result        out nocopy varchar2,
                              p_date                 in date      default null
                            )
   is
       cursor get_et_details is
       select piv.hot_default_flag,
              piv.default_value iv_default_value,
              pliv.default_value liv_default_value,
              peev.screen_entry_value
         from pay_element_entries_f pee,
              pay_element_entry_values_f peev,
              pay_element_links_f pel,
              pay_link_input_values_f pliv,
              pay_element_types_f pet,
              pay_input_values_f piv
        where pee.element_entry_id = p_element_entry_id
          and pee.element_entry_id = peev.element_entry_id
          and peev.input_value_id = pliv.input_value_id
          and pee.element_link_id = pel.element_link_id
          and pliv.element_link_id = pel.element_link_id
          and pliv.link_input_value_id = p_surrogate_key
          and pet.element_type_id = pel.element_type_id
          and pet.element_type_id = piv.element_type_id
          and piv.input_value_id = pliv.input_value_id
          and p_date between piv.effective_start_date
                         and piv.effective_end_date
          and p_date between pet.effective_start_date
                         and pet.effective_end_date
          and p_date between pliv.effective_start_date
                         and pliv.effective_end_date
          and p_date between pel.effective_start_date
                         and pel.effective_end_date
          and p_date between peev.effective_start_date
                         and peev.effective_end_date
          and p_date between pee.effective_start_date
                         and pee.effective_end_date;

   begin
--
      p_output_result:= 'FALSE';
--
      for get_det in get_et_details loop
--
 --         Check the hot default flag for input values
         if (p_column_name = 'DEFAULT_VALUE') then
--
            if (get_det.hot_default_flag = 'Y') then
               if (get_det.screen_entry_value is null) then
--
                  p_output_result:= 'TRUE';
               end if;
            end if;
--
         end if;
--
      end loop;
--
   end link_iv_change;
--
/* PAY_USER_COLUMN_INSTANCES_F */
/* name : PAY_USER_COLUMN_INSTANCES_F_ari
   purpose : This is procedure that records any insert
             on PAY_USER_COLUMN_INSTANCES_F.
*/
  procedure PAY_USER_COL_INSTANCES_F_ari(
                                         p_business_group_id in number,
                                         p_legislation_code in varchar2,
                                         p_effective_start_date in date,
                                         p_user_column_instance_id in number
                                        )
  is
    l_process_event_id number;
    l_object_version_number number;
    l_proc varchar2(240) := g_package||'.PAY_USER_COLUMN_INSTANCES_F_ari';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_USER_COLUMN_INSTANCES_F',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'I'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => NULL,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_surrogate_key         => p_user_column_instance_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_business_group_id     => p_business_group_id
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
    hr_utility.set_location(l_proc, 900);
  end PAY_USER_COL_INSTANCES_F_ari;

--
  PROCEDURE PAY_USER_COL_INSTANCES_F_aru
                                      (	p_business_group_id            IN NUMBER
                                      , p_legislation_code	       IN VARCHAR2
                                      , p_effective_date	       IN DATE
                                      , p_old_BUSINESS_GROUP_ID        IN VARCHAR2
                                      , p_new_BUSINESS_GROUP_ID        IN VARCHAR2
                                      , p_old_EFFECTIVE_END_DATE       IN DATE
                                      , p_new_EFFECTIVE_END_DATE       IN DATE
                                      , p_old_EFFECTIVE_START_DATE     IN DATE
                                      , p_new_EFFECTIVE_START_DATE     IN DATE
                                      , p_old_LEGISLATION_CODE         IN VARCHAR2
                                      , p_new_LEGISLATION_CODE         IN VARCHAR2
                                      , p_old_USER_COLUMN_ID           IN NUMBER
                                      , p_new_USER_COLUMN_ID           IN NUMBER
                                      , p_old_USER_COLUMN_INSTANCE_ID  IN NUMBER
                                      , p_new_USER_COLUMN_INSTANCE_ID  IN NUMBER
                                      , p_old_USER_ROW_ID              IN NUMBER
                                      , p_new_USER_ROW_ID              IN NUMBER
                                      , p_old_VALUE                    IN VARCHAR2
                                      , p_new_VALUE                    IN VARCHAR2
				      )
  IS
  BEGIN
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_USER_COLUMN_INSTANCES_F',
                                     'BUSINESS_GROUP_ID',
                                     p_old_BUSINESS_GROUP_ID,
                                     p_new_BUSINESS_GROUP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_USER_COLUMN_INSTANCES_F',
                                     'USER_COLUMN_INSTANCE_ID',
                                     p_old_USER_COLUMN_INSTANCE_ID,
                                     p_new_USER_COLUMN_INSTANCE_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_USER_COLUMN_INSTANCES_F',
                                     'USER_ROW_ID',
                                     p_old_USER_ROW_ID,
                                     p_new_USER_ROW_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_USER_COLUMN_INSTANCES_F',
                                     'USER_COLUMN_ID',
                                     p_old_USER_COLUMN_ID,
                                     p_new_USER_COLUMN_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_USER_COLUMN_INSTANCES_F',
                                     'VALUE',
                                     p_old_VALUE,
                                     p_new_VALUE,
                                     p_effective_date
                                  );
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_USER_COLUMN_INSTANCES_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_USER_COLUMN_INSTANCES_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                  );

  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
             p_assignment_id         => NULL,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_business_group_id     => p_business_group_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_surrogate_key         => p_new_user_column_instance_id
           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--

  END PAY_USER_COL_INSTANCES_F_aru;

--
/* name : PAY_USER_COLUMN_INSTANCES_F_ard
   purpose : This is procedure that records any deletes
             on PAY_USER_COLUMN_INSTANCES_F.
*/
 procedure PAY_USER_COL_INSTANCES_F_ard(
                                         p_business_group_id in number,
                                         p_legislation_code in varchar2,
                                         p_old_user_column_instance_id in number,
                                         p_old_effective_start_date in date,
                                         p_new_effective_start_date in date,
                                         p_old_effective_end_date in date,
                                         p_new_effective_end_date in date
                                        )
  is
    l_process_event_id number;
    l_object_version_number number;
    l_effective_date date;
    l_mode pay_event_updates.event_type%type;
    l_column_name pay_event_updates.column_name%type;
    l_old_value      date;
    l_new_value      date;
    l_proc varchar2(240) := g_package||'.PAY_USER_COLUMN_INSTANCES_F_ard';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
--   hr_utility.trace('> p_assignment_id: '||p_assignment_id);
--    hr_utility.trace('> p_old_cost_allocation_ID:  '||p_old_user_col_instance_id);
--    hr_utility.trace('> p_old_effective_start_date:        '||p_old_effective_start_date);
--    hr_utility.trace('> p_new_effective_start_date:       '||p_new_effective_start_date);
--    hr_utility.trace('> pay_dyn_triggers.g_dyt_mode:        '||pay_dyn_triggers.g_dyt_mode);
--    hr_utility.trace('> pay_dyn_triggers.g_dbms_dyt:        '||pay_dyn_triggers.g_dbms_dyt);

--
    if (   pay_dyn_triggers.g_dyt_mode = pay_dyn_triggers.g_dbms_dyt
        or pay_dyn_triggers.g_dyt_mode = 'ZAP') then
--
      if (   pay_dyn_triggers.g_dyt_mode = pay_dyn_triggers.g_dbms_dyt) then
        l_mode := 'D';
      else
        l_mode := pay_dyn_triggers.g_dyt_mode;
      end if;
      l_effective_date := p_old_effective_start_date;
      l_column_name := null;
      l_old_value   := null;
      l_new_value   := null;
--
    else
      l_mode := pay_dyn_triggers.g_dyt_mode;
      if (pay_dyn_triggers.g_dyt_mode = 'DELETE') then
--
         l_effective_date := p_new_effective_end_date;
         l_column_name := 'EFFECTIVE_END_DATE';
         l_old_value   := p_old_effective_end_date;
         l_new_value   := p_new_effective_end_date;
--
      elsif (pay_dyn_triggers.g_dyt_mode = 'FUTURE_CHANGE'
            or pay_dyn_triggers.g_dyt_mode = 'DELETE_NEXT_CHANGE') then
--
         l_effective_date := p_old_effective_start_date;
         l_column_name := 'EFFECTIVE_END_DATE';
         l_old_value   := p_old_effective_end_date;
         l_new_value   := p_new_effective_end_date;
--
      end if;
    end if;
--

--    hr_utility.trace('> l_mode:        '||l_mode);

    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_USER_COLUMN_INSTANCES_F',
                                     l_column_name,
                                     l_old_value,
                                     l_new_value,
                                     l_effective_date,
                                     l_effective_date,
                                     l_mode
                                    );
   /* Now call the API for the affected assignments */


   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
    hr_utility.trace('> With in Create Process Event:        ');
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => NULL,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_surrogate_key         => p_old_user_column_instance_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_business_group_id     => p_business_group_id
                                           );


         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
    hr_utility.set_location(l_proc, 900);
  END PAY_USER_COL_INSTANCES_F_ard;

--
/* FF_GLOBALS_F */
/* name : FF_GLOBALS_F_ari
   purpose : This is procedure that records any insert
             on FF_GLOBALS_F.
*/
  procedure FF_GLOBALS_F_ari(
                                         p_business_group_id in number,
                                         p_legislation_code in varchar2,
                                         p_effective_start_date in date,
                                         p_global_id in number
                                        )
  is
    l_process_event_id number;
    l_object_version_number number;
    l_proc varchar2(240) := g_package||'.FF_GLOBALS_F_ari';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'FF_GLOBALS_F',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'I'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => NULL,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_surrogate_key         => p_global_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_business_group_id     => p_business_group_id
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
    hr_utility.set_location(l_proc, 900);
  end FF_GLOBALS_F_ari;

--
  PROCEDURE FF_GLOBALS_F_aru
                                      (	p_business_group_id            IN NUMBER
                                      , p_legislation_code	       IN VARCHAR2
                                      , p_effective_date	       IN DATE
                                      , p_old_BUSINESS_GROUP_ID        IN VARCHAR2
                                      , p_new_BUSINESS_GROUP_ID        IN VARCHAR2
                                      , p_old_EFFECTIVE_END_DATE       IN DATE
                                      , p_new_EFFECTIVE_END_DATE       IN DATE
                                      , p_old_EFFECTIVE_START_DATE     IN DATE
                                      , p_new_EFFECTIVE_START_DATE     IN DATE
                                      , p_old_LEGISLATION_CODE         IN VARCHAR2
                                      , p_new_LEGISLATION_CODE         IN VARCHAR2
                                      , p_old_global_ID                IN NUMBER
                                      , p_new_global_ID                IN NUMBER
                                      , p_old_global_VALUE             IN VARCHAR2
                                      , p_new_global_VALUE             IN VARCHAR2
				      , p_old_global_description       IN VARCHAR2
                                      , p_new_global_description       IN VARCHAR2
				      )
  IS
  BEGIN
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'FF_GLOBALS_F',
                                     'BUSINESS_GROUP_ID',
                                     p_old_BUSINESS_GROUP_ID,
                                     p_new_BUSINESS_GROUP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'FF_GLOBALS_F',
                                     'GLOBAL_ID',
                                     p_old_global_ID,
                                     p_new_global_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'FF_GLOBALS_F',
                                     'GLOBAL_VALUE',
                                     p_old_global_VALUE,
                                     p_new_global_VALUE,
                                     p_effective_date
                                  );

    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'FF_GLOBALS_F',
                                     'GLOBAL_DESCRIPTION',
                                     p_old_global_description,
                                     p_new_global_description,
                                     p_effective_date
                                  );

  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'FF_GLOBALS_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'FF_GLOBALS_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                  );

  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
             p_assignment_id         => NULL,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_business_group_id     => p_business_group_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_surrogate_key         => p_new_global_id
           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--

  END FF_GLOBALS_F_aru;

--
/* name : FF_GLOBALS_F_ard
   purpose : This is procedure that records any deletes
             on FF_GLOBALS_F.
*/
 procedure FF_GLOBALS_F_ard(
                                         p_business_group_id in number,
                                         p_legislation_code in varchar2,
                                         p_old_global_id in number,
                                         p_old_effective_start_date in date,
                                         p_new_effective_start_date in date,
                                         p_old_effective_end_date in date,
                                         p_new_effective_end_date in date
                                        )
  is
    l_process_event_id number;
    l_object_version_number number;
    l_effective_date date;
    l_mode pay_event_updates.event_type%type;
    l_column_name pay_event_updates.column_name%type;
    l_old_value      date;
    l_new_value      date;
    l_proc varchar2(240) := g_package||'.FF_GLOBALS_F_ard';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
--   hr_utility.trace('> p_assignment_id: '||p_assignment_id);
--    hr_utility.trace('> p_old_cost_allocation_ID:  '||p_old_user_col_instance_id);
--    hr_utility.trace('> p_old_effective_start_date:        '||p_old_effective_start_date);
--    hr_utility.trace('> p_new_effective_start_date:       '||p_new_effective_start_date);
--    hr_utility.trace('> pay_dyn_triggers.g_dyt_mode:        '||pay_dyn_triggers.g_dyt_mode);
--    hr_utility.trace('> pay_dyn_triggers.g_dbms_dyt:        '||pay_dyn_triggers.g_dbms_dyt);

--
    if (   pay_dyn_triggers.g_dyt_mode = pay_dyn_triggers.g_dbms_dyt
        or pay_dyn_triggers.g_dyt_mode = 'ZAP') then
--
      if (   pay_dyn_triggers.g_dyt_mode = pay_dyn_triggers.g_dbms_dyt) then
        l_mode := 'D';
      else
        l_mode := pay_dyn_triggers.g_dyt_mode;
      end if;
      l_effective_date := p_old_effective_start_date;
      l_column_name := null;
      l_old_value   := null;
      l_new_value   := null;
--
    else
      l_mode := pay_dyn_triggers.g_dyt_mode;
      if (pay_dyn_triggers.g_dyt_mode = 'DELETE') then
--
         l_effective_date := p_new_effective_end_date;
         l_column_name := 'EFFECTIVE_END_DATE';
         l_old_value   := p_old_effective_end_date;
         l_new_value   := p_new_effective_end_date;
--
      elsif (pay_dyn_triggers.g_dyt_mode = 'FUTURE_CHANGE'
            or pay_dyn_triggers.g_dyt_mode = 'DELETE_NEXT_CHANGE') then
--
         l_effective_date := p_old_effective_start_date;
         l_column_name := 'EFFECTIVE_END_DATE';
         l_old_value   := p_old_effective_end_date;
         l_new_value   := p_new_effective_end_date;
--
      end if;
    end if;
--

--    hr_utility.trace('> l_mode:        '||l_mode);

    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'FF_GLOBALS_F',
                                     l_column_name,
                                     l_old_value,
                                     l_new_value,
                                     l_effective_date,
                                     l_effective_date,
                                     l_mode
                                    );

   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
    hr_utility.trace('> With in Create Process Event:        ');
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => NULL,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_surrogate_key         => p_old_global_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_business_group_id     => p_business_group_id
                                           );


         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
    hr_utility.set_location(l_proc, 900);
END FF_GLOBALS_F_ard;

PROCEDURE PQH_RATE_MATRIX_RATES_F_ari( p_business_group_id      IN NUMBER
                                       , p_legislation_code       IN VARCHAR2
				                       , p_effective_start_date   IN DATE
				                       , p_rate_matrix_rate_id    IN NUMBER
			                         )
IS
    l_process_event_id number;
    l_object_version_number number;
    l_proc varchar2(240) := g_package||'.PQH_RATE_MATRIX_RATES_F_ari';
BEGIN
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
				                     'PQH_RATE_MATRIX_RATES_F',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'I'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => NULL,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_surrogate_key         => p_rate_matrix_rate_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_business_group_id     => p_business_group_id
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
    hr_utility.set_location(l_proc, 900);

END PQH_RATE_MATRIX_RATES_F_ari;


PROCEDURE PQH_RATE_MATRIX_RATES_F_aru ( p_business_group_id            IN NUMBER
                                      , p_legislation_code             IN VARCHAR2
				                      , p_effective_date	       IN DATE
                                      , p_old_EFFECTIVE_END_DATE       IN DATE
                                      , p_new_EFFECTIVE_END_DATE       IN DATE
                                      , p_old_EFFECTIVE_START_DATE     IN DATE
                                      , p_new_EFFECTIVE_START_DATE     IN DATE
                                      , p_old_rate_matrix_rate_id      IN NUMBER
                                      , p_new_rate_matrix_rate_id      IN NUMBER
                                      , p_old_rate_VALUE               IN VARCHAR2
                                      , p_new_rate_VALUE               IN VARCHAR2
                                      , p_old_min_rate_VALUE           IN VARCHAR2
                                      , p_new_min_rate_VALUE           IN VARCHAR2
                                      , p_old_max_rate_VALUE           IN VARCHAR2
                                      , p_new_max_rate_VALUE           IN VARCHAR2
                                      , p_old_mid_rate_VALUE           IN VARCHAR2
                                      , p_new_mid_rate_VALUE           IN VARCHAR2
				                      )
IS
BEGIN
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PQH_RATE_MATRIX_RATES_F',
                                     'RATE_MATRIX_RATE_ID',
                                     p_old_rate_matrix_rate_id,
                                     p_new_rate_matrix_rate_id,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PQH_RATE_MATRIX_RATES_F',
                                     'RATE_VALUE',
                                     p_old_RATE_VALUE,
                                     p_new_RATE_VALUE,
                                     p_effective_date
                                    );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PQH_RATE_MATRIX_RATES_F',
                                     'MIN_RATE_VALUE',
                                     p_old_MIN_RATE_VALUE,
                                     p_new_MIN_RATE_VALUE,
                                     p_effective_date
                                    );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PQH_RATE_MATRIX_RATES_F',
                                     'MAX_RATE_VALUE',
                                     p_old_MAX_RATE_VALUE,
                                     p_new_MAX_RATE_VALUE,
                                     p_effective_date
                                    );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PQH_RATE_MATRIX_RATES_F',
                                     'MID_RATE_VALUE',
                                     p_old_MID_RATE_VALUE,
                                     p_new_MID_RATE_VALUE,
                                     p_effective_date
                                    );
--
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PQH_RATE_MATRIX_RATES_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                     );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PQH_RATE_MATRIX_RATES_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                     p_new_effective_start_date)
                                     );

  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
             p_assignment_id         => NULL,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_business_group_id     => p_business_group_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_surrogate_key         => p_new_rate_matrix_rate_id
           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
END PQH_RATE_MATRIX_RATES_F_aru;

PROCEDURE PQH_RATE_MATRIX_RATES_F_ard  ( p_business_group_id        in number,
                                         p_legislation_code         in varchar2,
                                         p_old_rate_matrix_rate_id  in number,
                                         p_old_effective_start_date in date,
                                         p_new_effective_start_date in date,
                                         p_old_effective_end_date   in date,
                                         p_new_effective_end_date   in date
                                        )
IS
    l_process_event_id number;
    l_object_version_number number;
    l_effective_date date;
    l_mode pay_event_updates.event_type%type;
    l_column_name pay_event_updates.column_name%type;
    l_old_value      date;
    l_new_value      date;
    l_proc varchar2(240) := g_package||'.PQH_RATE_MATRIX_RATES_F_ard';
BEGIN
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (g_override_cc = TRUE) then
    return;
  end if;
--
    if (   pay_dyn_triggers.g_dyt_mode = pay_dyn_triggers.g_dbms_dyt
        or pay_dyn_triggers.g_dyt_mode = 'ZAP') then
--
      if (   pay_dyn_triggers.g_dyt_mode = pay_dyn_triggers.g_dbms_dyt) then
        l_mode := 'D';
      else
        l_mode := pay_dyn_triggers.g_dyt_mode;
      end if;
      l_effective_date := p_old_effective_start_date;
      l_column_name := null;
      l_old_value   := null;
      l_new_value   := null;
--
    else
      l_mode := pay_dyn_triggers.g_dyt_mode;
      if (pay_dyn_triggers.g_dyt_mode = 'DELETE') then
--
         l_effective_date := p_new_effective_end_date;
         l_column_name := 'EFFECTIVE_END_DATE';
         l_old_value   := p_old_effective_end_date;
         l_new_value   := p_new_effective_end_date;
--
      elsif (pay_dyn_triggers.g_dyt_mode = 'FUTURE_CHANGE'
            or pay_dyn_triggers.g_dyt_mode = 'DELETE_NEXT_CHANGE') then
--
         l_effective_date := p_old_effective_start_date;
         l_column_name := 'EFFECTIVE_END_DATE';
         l_old_value   := p_old_effective_end_date;
         l_new_value   := p_new_effective_end_date;
--
      end if;
    end if;
--
    hr_utility.trace('> l_mode:        '||l_mode);

    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PQH_RATE_MATRIX_RATES_F',
                                     l_column_name,
                                     l_old_value,
                                     l_new_value,
                                     l_effective_date,
                                     l_effective_date,
                                     l_mode
                                    );

   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
         hr_utility.trace('> With in Create Process Event:        ');
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
             pay_ppe_api.create_process_event(
                                            p_assignment_id         => NULL,
                                            p_effective_date        => g_event_list.effective_date(cnt),
                                            p_change_type           => g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => g_event_list.event_update_id(cnt),
                                            p_surrogate_key         => p_old_rate_matrix_rate_id,
                                            p_calculation_date      => g_event_list.calc_date(cnt),
                                            p_business_group_id     => p_business_group_id
                                           );


         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
   hr_utility.set_location(l_proc, 900);

END PQH_RATE_MATRIX_RATES_F_ard;
/*
PER_CONTACT_RELATIONSHIPS
name : PER_CONTACT_RELATIONSHIPS_ari
purpose : This is procedure that records any inserts
          on PER_CONTACT_RELATIONSHIPS.
*/
PROCEDURE per_contact_relationships_ari(
                                         p_business_group_id in number,
                                         p_legislation_code in varchar2,
                                         p_person_id in number,
                                         p_contact_relationship_id in number,
                                         p_effective_start_date in date
                                        )
IS
  --
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_all_assignments_f
   where person_id = p_person_id;
   --
  l_process_event_id      number;
  l_object_version_number number;
  l_proc varchar2(240) := 'per_contact_relationships_ari';
  --
BEGIN
  --
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
  --
  pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'I'
                                    );
  /* Now call the API for the affected assignments */
  DECLARE
    cnt number;
    l_process_event_id number;
    l_object_version_number number;
  BEGIN
    IF (pay_continuous_calc.g_event_list.sz <> 0) THEN
      --
      FOR asgrec in asgcur (p_person_id) LOOP
        --
        FOR cnt in 1..pay_continuous_calc.g_event_list.sz LOOP
          --
          pay_ppe_api.create_process_event(
             p_assignment_id         => asgrec.assignment_id,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_business_group_id     => p_business_group_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_surrogate_key         => p_contact_relationship_id);
          --
        END LOOP;
        --
      END LOOP;
      --
    END IF;
    --
    pay_continuous_calc.g_event_list.sz := 0;
    --
  END;
  --
  hr_utility.set_location(l_proc, 900);
  --
END per_contact_relationships_ari;

/*
PER_CONTACT_RELATIONSHIPS
name : PER_CONTACT_RELATIONSHIPS_aru
purpose : This is procedure that records any updates
          on PER_CONTACT_RELATIONSHIPS.
*/

procedure PER_CONTACT_RELATIONSHIPS_aru(
    p_business_group_id in number,
    p_legislation_code in varchar2,
    p_effective_date in date,
    p_old_BENEFICIARY_FLAG in VARCHAR2,
    p_new_BENEFICIARY_FLAG in VARCHAR2,
    p_old_BONDHOLDER_FLAG in VARCHAR2,
    p_new_BONDHOLDER_FLAG in VARCHAR2,
    p_old_BUSINESS_GROUP_ID in NUMBER,
    p_new_BUSINESS_GROUP_ID in NUMBER,
    p_old_CONTACT_PERSON_ID in NUMBER,
    p_new_CONTACT_PERSON_ID in NUMBER,
    p_old_CONTACT_RELATIONSHIP_ID in NUMBER,
    p_new_CONTACT_RELATIONSHIP_ID in NUMBER,
    p_old_CONTACT_TYPE in VARCHAR2,
    p_new_CONTACT_TYPE in VARCHAR2,
    p_old_CONT_ATTRIBUTE1 in VARCHAR2,
    p_new_CONT_ATTRIBUTE1 in VARCHAR2,
    p_old_CONT_ATTRIBUTE10 in VARCHAR2,
    p_new_CONT_ATTRIBUTE10 in VARCHAR2,
    p_old_CONT_ATTRIBUTE11 in VARCHAR2,
    p_new_CONT_ATTRIBUTE11 in VARCHAR2,
    p_old_CONT_ATTRIBUTE12 in VARCHAR2,
    p_new_CONT_ATTRIBUTE12 in VARCHAR2,
    p_old_CONT_ATTRIBUTE13 in VARCHAR2,
    p_new_CONT_ATTRIBUTE13 in VARCHAR2,
    p_old_CONT_ATTRIBUTE14 in VARCHAR2,
    p_new_CONT_ATTRIBUTE14 in VARCHAR2,
    p_old_CONT_ATTRIBUTE15 in VARCHAR2,
    p_new_CONT_ATTRIBUTE15 in VARCHAR2,
    p_old_CONT_ATTRIBUTE16 in VARCHAR2,
    p_new_CONT_ATTRIBUTE16 in VARCHAR2,
    p_old_CONT_ATTRIBUTE17 in VARCHAR2,
    p_new_CONT_ATTRIBUTE17 in VARCHAR2,
    p_old_CONT_ATTRIBUTE18 in VARCHAR2,
    p_new_CONT_ATTRIBUTE18 in VARCHAR2,
    p_old_CONT_ATTRIBUTE19 in VARCHAR2,
    p_new_CONT_ATTRIBUTE19 in VARCHAR2,
    p_old_CONT_ATTRIBUTE2 in VARCHAR2,
    p_new_CONT_ATTRIBUTE2 in VARCHAR2,
    p_old_CONT_ATTRIBUTE20 in VARCHAR2,
    p_new_CONT_ATTRIBUTE20 in VARCHAR2,
    p_old_CONT_ATTRIBUTE3 in VARCHAR2,
    p_new_CONT_ATTRIBUTE3 in VARCHAR2,
    p_old_CONT_ATTRIBUTE4 in VARCHAR2,
    p_new_CONT_ATTRIBUTE4 in VARCHAR2,
    p_old_CONT_ATTRIBUTE5 in VARCHAR2,
    p_new_CONT_ATTRIBUTE5 in VARCHAR2,
    p_old_CONT_ATTRIBUTE6 in VARCHAR2,
    p_new_CONT_ATTRIBUTE6 in VARCHAR2,
    p_old_CONT_ATTRIBUTE7 in VARCHAR2,
    p_new_CONT_ATTRIBUTE7 in VARCHAR2,
    p_old_CONT_ATTRIBUTE8 in VARCHAR2,
    p_new_CONT_ATTRIBUTE8 in VARCHAR2,
    p_old_CONT_ATTRIBUTE9 in VARCHAR2,
    p_new_CONT_ATTRIBUTE9 in VARCHAR2,
    p_old_CONT_ATTRIBUTE_CATEGORY in VARCHAR2,
    p_new_CONT_ATTRIBUTE_CATEGORY in VARCHAR2,
    p_old_CONT_INFORMATION1 in VARCHAR2,
    p_new_CONT_INFORMATION1 in VARCHAR2,
    p_old_CONT_INFORMATION10 in VARCHAR2,
    p_new_CONT_INFORMATION10 in VARCHAR2,
    p_old_CONT_INFORMATION11 in VARCHAR2,
    p_new_CONT_INFORMATION11 in VARCHAR2,
    p_old_CONT_INFORMATION12 in VARCHAR2,
    p_new_CONT_INFORMATION12 in VARCHAR2,
    p_old_CONT_INFORMATION13 in VARCHAR2,
    p_new_CONT_INFORMATION13 in VARCHAR2,
    p_old_CONT_INFORMATION14 in VARCHAR2,
    p_new_CONT_INFORMATION14 in VARCHAR2,
    p_old_CONT_INFORMATION15 in VARCHAR2,
    p_new_CONT_INFORMATION15 in VARCHAR2,
    p_old_CONT_INFORMATION16 in VARCHAR2,
    p_new_CONT_INFORMATION16 in VARCHAR2,
    p_old_CONT_INFORMATION17 in VARCHAR2,
    p_new_CONT_INFORMATION17 in VARCHAR2,
    p_old_CONT_INFORMATION18 in VARCHAR2,
    p_new_CONT_INFORMATION18 in VARCHAR2,
    p_old_CONT_INFORMATION19 in VARCHAR2,
    p_new_CONT_INFORMATION19 in VARCHAR2,
    p_old_CONT_INFORMATION2 in VARCHAR2,
    p_new_CONT_INFORMATION2 in VARCHAR2,
    p_old_CONT_INFORMATION20 in VARCHAR2,
    p_new_CONT_INFORMATION20 in VARCHAR2,
    p_old_CONT_INFORMATION3 in VARCHAR2,
    p_new_CONT_INFORMATION3 in VARCHAR2,
    p_old_CONT_INFORMATION4 in VARCHAR2,
    p_new_CONT_INFORMATION4 in VARCHAR2,
    p_old_CONT_INFORMATION5 in VARCHAR2,
    p_new_CONT_INFORMATION5 in VARCHAR2,
    p_old_CONT_INFORMATION6 in VARCHAR2,
    p_new_CONT_INFORMATION6 in VARCHAR2,
    p_old_CONT_INFORMATION7 in VARCHAR2,
    p_new_CONT_INFORMATION7 in VARCHAR2,
    p_old_CONT_INFORMATION8 in VARCHAR2,
    p_new_CONT_INFORMATION8 in VARCHAR2,
    p_old_CONT_INFORMATION9 in VARCHAR2,
    p_new_CONT_INFORMATION9 in VARCHAR2,
    p_old_CONT_INFORMATION_CATEGOR in VARCHAR2,
    p_new_CONT_INFORMATION_CATEGOR in VARCHAR2,
    p_old_DEPENDENT_FLAG in VARCHAR2,
    p_new_DEPENDENT_FLAG in VARCHAR2,
    p_old_END_LIFE_REASON_ID in NUMBER,
    p_new_END_LIFE_REASON_ID in NUMBER,
    p_old_PARTY_ID in NUMBER,
    p_new_PARTY_ID in NUMBER,
    p_old_PERSONAL_FLAG in VARCHAR2,
    p_new_PERSONAL_FLAG in VARCHAR2,
    p_old_PERSON_ID in NUMBER,
    p_new_PERSON_ID in NUMBER,
    p_old_PRIMARY_CONTACT_FLAG in VARCHAR2,
    p_new_PRIMARY_CONTACT_FLAG in VARCHAR2,
    p_old_PROGRAM_APPLICATION_ID in NUMBER,
    p_new_PROGRAM_APPLICATION_ID in NUMBER,
    p_old_PROGRAM_ID in NUMBER,
    p_new_PROGRAM_ID in NUMBER,
    p_old_PROGRAM_UPDATE_DATE in DATE,
    p_new_PROGRAM_UPDATE_DATE in DATE,
    p_old_REQUEST_ID in NUMBER,
    p_new_REQUEST_ID in NUMBER,
    p_old_RLTD_PER_RSDS_W_DSGNTR_F in VARCHAR2,
    p_new_RLTD_PER_RSDS_W_DSGNTR_F in VARCHAR2,
    p_old_SEQUENCE_NUMBER in NUMBER,
    p_new_SEQUENCE_NUMBER in NUMBER,
    p_old_START_LIFE_REASON_ID in NUMBER,
    p_new_START_LIFE_REASON_ID in NUMBER,
    p_old_THIRD_PARTY_PAY_FLAG in VARCHAR2,
    p_new_THIRD_PARTY_PAY_FLAG in VARCHAR2,
    p_old_DATE_END in DATE,
    p_new_DATE_END in DATE,
    p_old_DATE_START in DATE,
    p_new_DATE_START in DATE
)
is

  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_assignments_f
   where person_id = p_person_id;
l_proc varchar2(100) := 'PER_CONTACT_RELATIONSHIPS_ARU';
--
begin
hr_utility.set_location(l_proc,1);
hr_utility.trace('p_business_group_id '||p_business_group_id);
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;

hr_utility.set_location(l_proc,2);
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'BENEFICIARY_FLAG',
                                     p_old_BENEFICIARY_FLAG,
                                     p_new_BENEFICIARY_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'BONDHOLDER_FLAG',
                                     p_old_BONDHOLDER_FLAG,
                                     p_new_BONDHOLDER_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'BUSINESS_GROUP_ID',
                                     p_old_BUSINESS_GROUP_ID,
                                     p_new_BUSINESS_GROUP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONTACT_PERSON_ID',
                                     p_old_CONTACT_PERSON_ID,
                                     p_new_CONTACT_PERSON_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONTACT_RELATIONSHIP_ID',
                                     p_old_CONTACT_RELATIONSHIP_ID,
                                     p_new_CONTACT_RELATIONSHIP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONTACT_TYPE',
                                     p_old_CONTACT_TYPE,
                                     p_new_CONTACT_TYPE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE1',
                                     p_old_CONT_ATTRIBUTE1,
                                     p_new_CONT_ATTRIBUTE1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE10',
                                     p_old_CONT_ATTRIBUTE10,
                                     p_new_CONT_ATTRIBUTE10,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE11',
                                     p_old_CONT_ATTRIBUTE11,
                                     p_new_CONT_ATTRIBUTE11,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE12',
                                     p_old_CONT_ATTRIBUTE12,
                                     p_new_CONT_ATTRIBUTE12,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE13',
                                     p_old_CONT_ATTRIBUTE13,
                                     p_new_CONT_ATTRIBUTE13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE14',
                                     p_old_CONT_ATTRIBUTE14,
                                     p_new_CONT_ATTRIBUTE14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE15',
                                     p_old_CONT_ATTRIBUTE15,
                                     p_new_CONT_ATTRIBUTE15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE16',
                                     p_old_CONT_ATTRIBUTE16,
                                     p_new_CONT_ATTRIBUTE16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE17',
                                     p_old_CONT_ATTRIBUTE17,
                                     p_new_CONT_ATTRIBUTE17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE18',
                                     p_old_CONT_ATTRIBUTE18,
                                     p_new_CONT_ATTRIBUTE18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE19',
                                     p_old_CONT_ATTRIBUTE19,
                                     p_new_CONT_ATTRIBUTE19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE2',
                                     p_old_CONT_ATTRIBUTE2,
                                     p_new_CONT_ATTRIBUTE2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE20',
                                     p_old_CONT_ATTRIBUTE20,
                                     p_new_CONT_ATTRIBUTE20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE3',
                                     p_old_CONT_ATTRIBUTE3,
                                     p_new_CONT_ATTRIBUTE3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE4',
                                     p_old_CONT_ATTRIBUTE4,
                                     p_new_CONT_ATTRIBUTE4,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE5',
                                     p_old_CONT_ATTRIBUTE5,
                                     p_new_CONT_ATTRIBUTE5,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE6',
                                     p_old_CONT_ATTRIBUTE6,
                                     p_new_CONT_ATTRIBUTE6,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE7',
                                     p_old_CONT_ATTRIBUTE7,
                                     p_new_CONT_ATTRIBUTE7,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE8',
                                     p_old_CONT_ATTRIBUTE8,
                                     p_new_CONT_ATTRIBUTE8,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE9',
                                     p_old_CONT_ATTRIBUTE9,
                                     p_new_CONT_ATTRIBUTE9,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_ATTRIBUTE_CATEGORY',
                                     p_old_CONT_ATTRIBUTE_CATEGORY,
                                     p_new_CONT_ATTRIBUTE_CATEGORY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION1',
                                     p_old_CONT_INFORMATION1,
                                     p_new_CONT_INFORMATION1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION10',
                                     p_old_CONT_INFORMATION10,
                                     p_new_CONT_INFORMATION10,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION11',
                                     p_old_CONT_INFORMATION11,
                                     p_new_CONT_INFORMATION11,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION12',
                                     p_old_CONT_INFORMATION12,
                                     p_new_CONT_INFORMATION12,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION13',
                                     p_old_CONT_INFORMATION13,
                                     p_new_CONT_INFORMATION13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION14',
                                     p_old_CONT_INFORMATION14,
                                     p_new_CONT_INFORMATION14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION15',
                                     p_old_CONT_INFORMATION15,
                                     p_new_CONT_INFORMATION15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION16',
                                     p_old_CONT_INFORMATION16,
                                     p_new_CONT_INFORMATION16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION17',
                                     p_old_CONT_INFORMATION17,
                                     p_new_CONT_INFORMATION17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION18',
                                     p_old_CONT_INFORMATION18,
                                     p_new_CONT_INFORMATION18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION19',
                                     p_old_CONT_INFORMATION19,
                                     p_new_CONT_INFORMATION19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION2',
                                     p_old_CONT_INFORMATION2,
                                     p_new_CONT_INFORMATION2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION20',
                                     p_old_CONT_INFORMATION20,
                                     p_new_CONT_INFORMATION20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION3',
                                     p_old_CONT_INFORMATION3,
                                     p_new_CONT_INFORMATION3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION4',
                                     p_old_CONT_INFORMATION4,
                                     p_new_CONT_INFORMATION4,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION5',
                                     p_old_CONT_INFORMATION5,
                                     p_new_CONT_INFORMATION5,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION6',
                                     p_old_CONT_INFORMATION6,
                                     p_new_CONT_INFORMATION6,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION7',
                                     p_old_CONT_INFORMATION7,
                                     p_new_CONT_INFORMATION7,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION8',
                                     p_old_CONT_INFORMATION8,
                                     p_new_CONT_INFORMATION8,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION9',
                                     p_old_CONT_INFORMATION9,
                                     p_new_CONT_INFORMATION9,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'CONT_INFORMATION_CATEGORY',
                                     p_old_CONT_INFORMATION_CATEGOR,
                                     p_new_CONT_INFORMATION_CATEGOR,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'DEPENDENT_FLAG',
                                     p_old_DEPENDENT_FLAG,
                                     p_new_DEPENDENT_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'END_LIFE_REASON_ID',
                                     p_old_END_LIFE_REASON_ID,
                                     p_new_END_LIFE_REASON_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'PARTY_ID',
                                     p_old_PARTY_ID,
                                     p_new_PARTY_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'PERSONAL_FLAG',
                                     p_old_PERSONAL_FLAG,
                                     p_new_PERSONAL_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'PERSON_ID',
                                     p_old_PERSON_ID,
                                     p_new_PERSON_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'PRIMARY_CONTACT_FLAG',
                                     p_old_PRIMARY_CONTACT_FLAG,
                                     p_new_PRIMARY_CONTACT_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'PROGRAM_APPLICATION_ID',
                                     p_old_PROGRAM_APPLICATION_ID,
                                     p_new_PROGRAM_APPLICATION_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'PROGRAM_ID',
                                     p_old_PROGRAM_ID,
                                     p_new_PROGRAM_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'PROGRAM_UPDATE_DATE',
                                     p_old_PROGRAM_UPDATE_DATE,
                                     p_new_PROGRAM_UPDATE_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'REQUEST_ID',
                                     p_old_REQUEST_ID,
                                     p_new_REQUEST_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'RLTD_PER_RSDS_W_DSGNTR_FLAG',
                                     p_old_RLTD_PER_RSDS_W_DSGNTR_F,
                                     p_new_RLTD_PER_RSDS_W_DSGNTR_F,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'SEQUENCE_NUMBER',
                                     p_old_SEQUENCE_NUMBER,
                                     p_new_SEQUENCE_NUMBER,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'START_LIFE_REASON_ID',
                                     p_old_START_LIFE_REASON_ID,
                                     p_new_START_LIFE_REASON_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'THIRD_PARTY_PAY_FLAG',
                                     p_old_THIRD_PARTY_PAY_FLAG,
                                     p_new_THIRD_PARTY_PAY_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_CONTACT_RELATIONSHIPS',
                                     'THIRD_PARTY_PAY_FLAG',
                                     p_old_THIRD_PARTY_PAY_FLAG,
                                     p_new_THIRD_PARTY_PAY_FLAG,
                                     p_effective_date
                                  );

hr_utility.set_location(l_proc,3);
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
hr_utility.set_location(l_proc,4);
     if (pay_continuous_calc.g_event_list.sz <> 0) then
      for asgrec in asgcur (p_old_PERSON_ID) loop
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
             p_assignment_id         => asgrec.assignment_id,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_business_group_id     => p_business_group_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_surrogate_key         => p_new_contact_relationship_id
           );
         end loop;
     end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
hr_utility.set_location(l_proc,900);
--
end PER_CONTACT_RELATIONSHIPS_aru;

begin
  g_event_cache.sz := 0;
  g_event_list.sz := 0;
  g_override_cc := FALSE;
END PAY_CONTINUOUS_CALC;

/
