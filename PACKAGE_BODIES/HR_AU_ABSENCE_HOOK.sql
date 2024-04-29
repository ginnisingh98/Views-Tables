--------------------------------------------------------
--  DDL for Package Body HR_AU_ABSENCE_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AU_ABSENCE_HOOK" AS
/* $Header: peaulhab.pkb 120.2 2006/03/23 15:42:35 strussel noship $ */

g_debug boolean ;

PROCEDURE UPDATE_ABSENCE_DEV_DESC_FLEX ( p_absence_attendance_id IN NUMBER
                               ) AS

  l_proc                  varchar2(100) := 'hr_au_absence_hook.udpate_absence_dev_desc_flex';
  l_element_entry_id      pay_element_entries_f.element_entry_id%TYPE;
  l_effective_start_date  pay_element_entries_f.effective_start_date%TYPE;
  l_effective_end_date    pay_element_entries_f.effective_end_date%TYPE;
  l_processing_type       pay_element_types_f.processing_type%TYPE;
  l_ovn                   pay_element_entries_f.object_version_number%TYPE;
  l_warning               boolean;

  cursor c_get_absence_element (c_absence_attendance_id number)
  is
    select pee.element_entry_id
          ,pee.effective_start_date
          ,pee.effective_end_date
          ,pet.processing_type
          ,max(pee.object_version_number)
    from   per_absence_attendances abs
          ,pay_element_entries_f pee
          ,pay_element_types_f pet
          ,per_all_assignments_f paa
    where abs.absence_attendance_id = c_absence_attendance_id
    and   pee.creator_id = abs.absence_attendance_id
    and   pee.creator_type = 'A'
    and   pee.element_type_id = pet.element_type_id
    and   pee.effective_start_date between pet.effective_start_date and
                                           pet.effective_end_date
    and   paa.person_id = abs.person_id
    and   pee.effective_start_date between paa.effective_start_date and
                                           paa.effective_end_date
    and   paa.assignment_id = pee.assignment_id
    group by pee.element_entry_id,
             pee.effective_start_date,
             pee.effective_end_date,
             pet.processing_type
;

/* Update the absence flexfield values by doing a call to the
   update_element_entry api. This api has a legislative hook which updates
   the element entry values from the Absence flexfield so no need to do the
   same updates in here.

   Only do for recurring elements because for non-recurring the
   update_element_entry api is already being called in the core absence package.

*/

begin

  g_debug := hr_utility.debug_enabled;

  if g_debug THEN
    hr_utility.set_location('Entering '||l_proc, 10);
    hr_utility.set_location('p_absence_attendance_id ' || p_absence_attendance_id, 25);
  end if;

/* Get the element entry details for the absence element. */

  if g_debug THEN
    hr_utility.set_location(l_proc, 20);
  end if;
  open c_get_absence_element(p_absence_attendance_id);
  fetch c_get_absence_element into l_element_entry_id,
                                   l_effective_start_date,
                                   l_effective_end_date,
                                   l_processing_type,
                                   l_ovn;
  close c_get_absence_element;

  if g_debug THEN
    hr_utility.set_location('l_element_entry_id ' || l_element_entry_id, 25);
    hr_utility.set_location('l_effective_start_date ' || l_effective_start_date, 25);
    hr_utility.set_location('l_effective_end_date ' || l_effective_end_date, 25);
    hr_utility.set_location('l_processing_type ' || l_processing_type, 25);
    hr_utility.set_location('l_ovn ' || l_ovn, 25);
  end if;

/* Call the AU element entry hook package to udpate the element entry values.
   Only do for recurring elements. */

  if l_processing_type = 'R' then

    hr_au_element_entry_hook.update_element_entry_values
      (p_effective_date        => l_effective_start_date
      ,p_element_entry_id      => l_element_entry_id
      ,p_creator_type          => 'A'
      ,p_creator_id            => p_absence_attendance_id
      );

    if g_debug THEN
      hr_utility.set_location(l_proc, 90);
    end if;

  end if;

  if g_debug THEN
    hr_utility.set_location('Leaving '||l_proc, 99);
  end if;

END update_absence_dev_desc_flex ;

END hr_au_absence_hook;

/
