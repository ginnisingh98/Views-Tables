--------------------------------------------------------
--  DDL for Package Body PER_QH_SUMMARY_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QH_SUMMARY_UPDATE" as
/* $Header: peqhsumi.pkb 115.6 2003/05/14 12:48:58 adhunter noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  per_qh_summary_update.';
--
procedure update_summary_data
(p_effective_date                in     date
,p_person_id                     in     per_all_people_f.person_id%type
,p_chk1_checklist_item_id        in out nocopy per_checklist_items.checklist_item_id%type
,p_chk1_item_code                in     per_checklist_items.item_code%type
,p_chk1_date_due                 in     per_checklist_items.date_due%type
,p_chk1_date_done                in     per_checklist_items.date_done%type
,p_chk1_status                   in     per_checklist_items.status%type
,p_chk1_notes                    in     per_checklist_items.notes%type
,p_chk1_object_version_number    in out nocopy per_checklist_items.object_version_number%type
,p_chk2_checklist_item_id        in out nocopy per_checklist_items.checklist_item_id%type
,p_chk2_item_code                in     per_checklist_items.item_code%type
,p_chk2_date_due                 in     per_checklist_items.date_due%type
,p_chk2_date_done                in     per_checklist_items.date_done%type
,p_chk2_status                   in     per_checklist_items.status%type
,p_chk2_notes                    in     per_checklist_items.notes%type
,p_chk2_object_version_number    in out nocopy per_checklist_items.object_version_number%type
,p_chk3_checklist_item_id        in out nocopy per_checklist_items.checklist_item_id%type
,p_chk3_item_code                in     per_checklist_items.item_code%type
,p_chk3_date_due                 in     per_checklist_items.date_due%type
,p_chk3_date_done                in     per_checklist_items.date_done%type
,p_chk3_status                   in     per_checklist_items.status%type
,p_chk3_notes                    in     per_checklist_items.notes%type
,p_chk3_object_version_number    in out nocopy per_checklist_items.object_version_number%type
,p_chk4_checklist_item_id        in out nocopy per_checklist_items.checklist_item_id%type
,p_chk4_item_code                in     per_checklist_items.item_code%type
,p_chk4_date_due                 in     per_checklist_items.date_due%type
,p_chk4_date_done                in     per_checklist_items.date_done%type
,p_chk4_status                   in     per_checklist_items.status%type
,p_chk4_notes                    in     per_checklist_items.notes%type
,p_chk4_object_version_number    in out nocopy per_checklist_items.object_version_number%type
,p_chk5_checklist_item_id        in out nocopy per_checklist_items.checklist_item_id%type
,p_chk5_item_code                in     per_checklist_items.item_code%type
,p_chk5_date_due                 in     per_checklist_items.date_due%type
,p_chk5_date_done                in     per_checklist_items.date_done%type
,p_chk5_status                   in     per_checklist_items.status%type
,p_chk5_notes                    in     per_checklist_items.notes%type
,p_chk5_object_version_number    in out nocopy per_checklist_items.object_version_number%type
,p_chk6_checklist_item_id        in out nocopy per_checklist_items.checklist_item_id%type
,p_chk6_item_code                in     per_checklist_items.item_code%type
,p_chk6_date_due                 in     per_checklist_items.date_due%type
,p_chk6_date_done                in     per_checklist_items.date_done%type
,p_chk6_status                   in     per_checklist_items.status%type
,p_chk6_notes                    in     per_checklist_items.notes%type
,p_chk6_object_version_number    in out nocopy per_checklist_items.object_version_number%type
,p_chk7_checklist_item_id        in out nocopy per_checklist_items.checklist_item_id%type
,p_chk7_item_code                in     per_checklist_items.item_code%type
,p_chk7_date_due                 in     per_checklist_items.date_due%type
,p_chk7_date_done                in     per_checklist_items.date_done%type
,p_chk7_status                   in     per_checklist_items.status%type
,p_chk7_notes                    in     per_checklist_items.notes%type
,p_chk7_object_version_number    in out nocopy per_checklist_items.object_version_number%type
,p_chk8_checklist_item_id        in out nocopy per_checklist_items.checklist_item_id%type
,p_chk8_item_code                in     per_checklist_items.item_code%type
,p_chk8_date_due                 in     per_checklist_items.date_due%type
,p_chk8_date_done                in     per_checklist_items.date_done%type
,p_chk8_status                   in     per_checklist_items.status%type
,p_chk8_notes                    in     per_checklist_items.notes%type
,p_chk8_object_version_number    in out nocopy per_checklist_items.object_version_number%type
,p_chk9_checklist_item_id        in out nocopy per_checklist_items.checklist_item_id%type
,p_chk9_item_code                in     per_checklist_items.item_code%type
,p_chk9_date_due                 in     per_checklist_items.date_due%type
,p_chk9_date_done                in     per_checklist_items.date_done%type
,p_chk9_status                   in     per_checklist_items.status%type
,p_chk9_notes                    in     per_checklist_items.notes%type
,p_chk9_object_version_number    in out nocopy per_checklist_items.object_version_number%type
,p_chk10_checklist_item_id       in out nocopy per_checklist_items.checklist_item_id%type
,p_chk10_item_code               in     per_checklist_items.item_code%type
,p_chk10_date_due                in     per_checklist_items.date_due%type
,p_chk10_date_done               in     per_checklist_items.date_done%type
,p_chk10_status                  in     per_checklist_items.status%type
,p_chk10_notes                   in     per_checklist_items.notes%type
,p_chk10_object_version_number   in out nocopy per_checklist_items.object_version_number%type
) is
--
  l_checklist_item_id per_checklist_items.checklist_item_id%type;
  l_chk_object_version_number per_checklist_items.object_version_number%type;
l_proc varchar2(72) := g_package||'update_summary_data';
  --
begin
  --
  hr_utility.set_location('Entering'||l_proc, 10);
  --
  per_qh_summary_update.lock_summary_data
  (p_chk1_checklist_item_id         => p_chk1_checklist_item_id
  ,p_chk1_object_version_number     => p_chk1_object_version_number
  ,p_chk2_checklist_item_id         => p_chk2_checklist_item_id
  ,p_chk2_object_version_number     => p_chk2_object_version_number
  ,p_chk3_checklist_item_id         => p_chk3_checklist_item_id
  ,p_chk3_object_version_number     => p_chk3_object_version_number
  ,p_chk4_checklist_item_id         => p_chk4_checklist_item_id
  ,p_chk4_object_version_number     => p_chk4_object_version_number
  ,p_chk5_checklist_item_id         => p_chk5_checklist_item_id
  ,p_chk5_object_version_number     => p_chk5_object_version_number
  ,p_chk6_checklist_item_id         => p_chk6_checklist_item_id
  ,p_chk6_object_version_number     => p_chk6_object_version_number
  ,p_chk7_checklist_item_id         => p_chk7_checklist_item_id
  ,p_chk7_object_version_number     => p_chk7_object_version_number
  ,p_chk8_checklist_item_id         => p_chk8_checklist_item_id
  ,p_chk8_object_version_number     => p_chk8_object_version_number
  ,p_chk9_checklist_item_id         => p_chk9_checklist_item_id
  ,p_chk9_object_version_number     => p_chk9_object_version_number
  ,p_chk10_checklist_item_id        => p_chk10_checklist_item_id
  ,p_chk10_object_version_number    => p_chk10_object_version_number
  );
  --
  l_checklist_item_id:=p_chk1_checklist_item_id;
  l_chk_object_version_number:= p_chk1_object_version_number;
  --
  hr_utility.set_location(l_proc, 20);
  --
  if (l_checklist_item_id is null  and
      p_chk1_item_code is not null and
      (  p_chk1_status     is not null
      or p_chk1_date_due   is not null
      or p_chk1_date_done  is not null
      or p_chk1_notes      is not null)) or
     (l_checklist_item_id is not null and
      (  nvl(per_chk_shd.g_old_rec.date_due,hr_api.g_date)
      <> nvl(p_chk1_date_due,hr_api.g_date)
      or nvl(per_chk_shd.g_old_rec.date_done,hr_api.g_date)
      <> nvl(p_chk1_date_done,hr_api.g_date)
      or nvl(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
      <> nvl(p_chk1_status,hr_api.g_varchar2)
      or nvl(per_chk_shd.g_old_rec.notes,hr_api.g_varchar2)
      <> nvl(p_chk1_notes,hr_api.g_varchar2))) then
    --
  hr_utility.set_location(l_proc, 30);
  --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_checklist_item_id => l_checklist_item_id
    ,p_effective_date => p_effective_date
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => p_person_id
    ,p_item_code => p_chk1_item_code
    ,p_date_due => p_chk1_date_due
    ,p_date_done => p_chk1_date_done
    ,p_status => p_chk1_status
    ,p_notes => p_chk1_notes
    );
  end if;
  p_chk1_checklist_item_id:=l_checklist_item_id;
  p_chk1_object_version_number:=l_chk_object_version_number;
  --
  l_checklist_item_id:=p_chk2_checklist_item_id;
  l_chk_object_version_number:= p_chk2_object_version_number;
  --
  hr_utility.set_location(l_proc, 40);
  --
  if (l_checklist_item_id is null  and
      p_chk2_item_code is not null and
      (  p_chk2_status     is not null
      or p_chk2_date_due   is not null
      or p_chk2_date_done  is not null
      or p_chk2_notes      is not null)) or
     (l_checklist_item_id is not null and
      (  nvl(per_chk_shd.g_old_rec.date_due,hr_api.g_date)
      <> nvl(p_chk2_date_due,hr_api.g_date)
      or nvl(per_chk_shd.g_old_rec.date_done,hr_api.g_date)
      <> nvl(p_chk2_date_done,hr_api.g_date)
      or nvl(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
      <> nvl(p_chk2_status,hr_api.g_varchar2)
      or nvl(per_chk_shd.g_old_rec.notes,hr_api.g_varchar2)
      <> nvl(p_chk2_notes,hr_api.g_varchar2))) then
    --
  hr_utility.set_location(l_proc, 50);
  --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_checklist_item_id => l_checklist_item_id
    ,p_effective_date => p_effective_date
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => p_person_id
    ,p_item_code => p_chk2_item_code
    ,p_date_due => p_chk2_date_due
    ,p_date_done => p_chk2_date_done
    ,p_status => p_chk2_status
    ,p_notes => p_chk2_notes
    );
  end if;
  p_chk2_checklist_item_id:=l_checklist_item_id;
  p_chk2_object_version_number:=l_chk_object_version_number;
  --
  l_checklist_item_id:=p_chk3_checklist_item_id;
  l_chk_object_version_number:= p_chk3_object_version_number;
  hr_utility.set_location(l_proc, 60);
  --
  --
  if (l_checklist_item_id is null  and
      p_chk3_item_code is not null and
      (  p_chk3_status     is not null
      or p_chk3_date_due   is not null
      or p_chk3_date_done  is not null
      or p_chk3_notes      is not null)) or
     (l_checklist_item_id is not null and
      (  nvl(per_chk_shd.g_old_rec.date_due,hr_api.g_date)
      <> nvl(p_chk3_date_due,hr_api.g_date)
      or nvl(per_chk_shd.g_old_rec.date_done,hr_api.g_date)
      <> nvl(p_chk3_date_done,hr_api.g_date)
      or nvl(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
      <> nvl(p_chk3_status,hr_api.g_varchar2)
      or nvl(per_chk_shd.g_old_rec.notes,hr_api.g_varchar2)
      <> nvl(p_chk3_notes,hr_api.g_varchar2))) then
    --
  hr_utility.set_location(l_proc, 70);
  --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_checklist_item_id => l_checklist_item_id
    ,p_effective_date => p_effective_date
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => p_person_id
    ,p_item_code => p_chk3_item_code
    ,p_date_due => p_chk3_date_due
    ,p_date_done => p_chk3_date_done
    ,p_status => p_chk3_status
    ,p_notes => p_chk3_notes
    );
  end if;
  p_chk3_checklist_item_id:=l_checklist_item_id;
  p_chk3_object_version_number:=l_chk_object_version_number;
  --
  l_checklist_item_id:=p_chk4_checklist_item_id;
  l_chk_object_version_number:= p_chk4_object_version_number;
  --
  hr_utility.set_location(l_proc, 80);
  --
  if (l_checklist_item_id is null  and
      p_chk4_item_code is not null and
      (  p_chk4_status     is not null
      or p_chk4_date_due   is not null
      or p_chk4_date_done  is not null
      or p_chk4_notes      is not null)) or
     (l_checklist_item_id is not null and
      (  nvl(per_chk_shd.g_old_rec.date_due,hr_api.g_date)
      <> nvl(p_chk4_date_due,hr_api.g_date)
      or nvl(per_chk_shd.g_old_rec.date_done,hr_api.g_date)
      <> nvl(p_chk4_date_done,hr_api.g_date)
      or nvl(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
      <> nvl(p_chk4_status,hr_api.g_varchar2)
      or nvl(per_chk_shd.g_old_rec.notes,hr_api.g_varchar2)
      <> nvl(p_chk4_notes,hr_api.g_varchar2))) then
    --
  hr_utility.set_location(l_proc, 90);
  --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_checklist_item_id => l_checklist_item_id
    ,p_effective_date => p_effective_date
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => p_person_id
    ,p_item_code => p_chk4_item_code
    ,p_date_due => p_chk4_date_due
    ,p_date_done => p_chk4_date_done
    ,p_status => p_chk4_status
    ,p_notes => p_chk4_notes
    );
  end if;
  p_chk4_checklist_item_id:=l_checklist_item_id;
  p_chk4_object_version_number:=l_chk_object_version_number;
  --
  l_checklist_item_id:=p_chk5_checklist_item_id;
  l_chk_object_version_number:= p_chk5_object_version_number;
  --
  hr_utility.set_location(l_proc, 100);
  --
  if (l_checklist_item_id is null  and
      p_chk5_item_code is not null and
      (  p_chk5_status     is not null
      or p_chk5_date_due   is not null
      or p_chk5_date_done  is not null
      or p_chk5_notes      is not null)) or
     (l_checklist_item_id is not null and
      (  nvl(per_chk_shd.g_old_rec.date_due,hr_api.g_date)
      <> nvl(p_chk5_date_due,hr_api.g_date)
      or nvl(per_chk_shd.g_old_rec.date_done,hr_api.g_date)
      <> nvl(p_chk5_date_done,hr_api.g_date)
      or nvl(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
      <> nvl(p_chk5_status,hr_api.g_varchar2)
      or nvl(per_chk_shd.g_old_rec.notes,hr_api.g_varchar2)
      <> nvl(p_chk5_notes,hr_api.g_varchar2))) then
    --
  hr_utility.set_location(l_proc, 110);
  --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_checklist_item_id => l_checklist_item_id
    ,p_effective_date => p_effective_date
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => p_person_id
    ,p_item_code => p_chk5_item_code
    ,p_date_due => p_chk5_date_due
    ,p_date_done => p_chk5_date_done
    ,p_status => p_chk5_status
    ,p_notes => p_chk5_notes
    );
  end if;
  p_chk5_checklist_item_id:=l_checklist_item_id;
  p_chk5_object_version_number:=l_chk_object_version_number;
  --
  l_checklist_item_id:=p_chk6_checklist_item_id;
  l_chk_object_version_number:= p_chk6_object_version_number;
  --
  hr_utility.set_location(l_proc, 120);
  --
  if (l_checklist_item_id is null  and
      p_chk6_item_code is not null and
      (  p_chk6_status     is not null
      or p_chk6_date_due   is not null
      or p_chk6_date_done  is not null
      or p_chk6_notes      is not null)) or
     (l_checklist_item_id is not null and
      (  nvl(per_chk_shd.g_old_rec.date_due,hr_api.g_date)
      <> nvl(p_chk6_date_due,hr_api.g_date)
      or nvl(per_chk_shd.g_old_rec.date_done,hr_api.g_date)
      <> nvl(p_chk6_date_done,hr_api.g_date)
      or nvl(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
      <> nvl(p_chk6_status,hr_api.g_varchar2)
      or nvl(per_chk_shd.g_old_rec.notes,hr_api.g_varchar2)
      <> nvl(p_chk6_notes,hr_api.g_varchar2))) then
    --
  hr_utility.set_location(l_proc, 130);
  --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_checklist_item_id => l_checklist_item_id
    ,p_effective_date => p_effective_date
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => p_person_id
    ,p_item_code => p_chk6_item_code
    ,p_date_due => p_chk6_date_due
    ,p_date_done => p_chk6_date_done
    ,p_status => p_chk6_status
    ,p_notes => p_chk6_notes
    );
  end if;
  p_chk6_checklist_item_id:=l_checklist_item_id;
  p_chk6_object_version_number:=l_chk_object_version_number;
  --
  l_checklist_item_id:=p_chk7_checklist_item_id;
  l_chk_object_version_number:= p_chk7_object_version_number;
  --
  hr_utility.set_location(l_proc, 140);
  --
  if (l_checklist_item_id is null  and
      p_chk7_item_code is not null and
      (  p_chk7_status     is not null
      or p_chk7_date_due   is not null
      or p_chk7_date_done  is not null
      or p_chk7_notes      is not null)) or
     (l_checklist_item_id is not null and
      (  nvl(per_chk_shd.g_old_rec.date_due,hr_api.g_date)
      <> nvl(p_chk7_date_due,hr_api.g_date)
      or nvl(per_chk_shd.g_old_rec.date_done,hr_api.g_date)
      <> nvl(p_chk7_date_done,hr_api.g_date)
      or nvl(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
      <> nvl(p_chk7_status,hr_api.g_varchar2)
      or nvl(per_chk_shd.g_old_rec.notes,hr_api.g_varchar2)
      <> nvl(p_chk7_notes,hr_api.g_varchar2))) then
    --
  hr_utility.set_location(l_proc, 150);
  --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_checklist_item_id => l_checklist_item_id
    ,p_effective_date => p_effective_date
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => p_person_id
    ,p_item_code => p_chk7_item_code
    ,p_date_due => p_chk7_date_due
    ,p_date_done => p_chk7_date_done
    ,p_status => p_chk7_status
    ,p_notes => p_chk7_notes
    );
  end if;
  p_chk7_checklist_item_id:=l_checklist_item_id;
  p_chk7_object_version_number:=l_chk_object_version_number;
  --
  l_checklist_item_id:=p_chk8_checklist_item_id;
  l_chk_object_version_number:= p_chk8_object_version_number;
  --
  hr_utility.set_location(l_proc, 160);
  --
  if (l_checklist_item_id is null  and
      p_chk8_item_code is not null and
      (  p_chk8_status     is not null
      or p_chk8_date_due   is not null
      or p_chk8_date_done  is not null
      or p_chk8_notes      is not null)) or
     (l_checklist_item_id is not null and
      (  nvl(per_chk_shd.g_old_rec.date_due,hr_api.g_date)
      <> nvl(p_chk8_date_due,hr_api.g_date)
      or nvl(per_chk_shd.g_old_rec.date_done,hr_api.g_date)
      <> nvl(p_chk8_date_done,hr_api.g_date)
      or nvl(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
      <> nvl(p_chk8_status,hr_api.g_varchar2)
      or nvl(per_chk_shd.g_old_rec.notes,hr_api.g_varchar2)
      <> nvl(p_chk8_notes,hr_api.g_varchar2))) then
    --
  hr_utility.set_location(l_proc, 170);
  --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_checklist_item_id => l_checklist_item_id
    ,p_effective_date => p_effective_date
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => p_person_id
    ,p_item_code => p_chk8_item_code
    ,p_date_due => p_chk8_date_due
    ,p_date_done => p_chk8_date_done
    ,p_status => p_chk8_status
    ,p_notes => p_chk8_notes
    );
  end if;
  p_chk8_checklist_item_id:=l_checklist_item_id;
  p_chk8_object_version_number:=l_chk_object_version_number;
  --
  l_checklist_item_id:=p_chk9_checklist_item_id;
  l_chk_object_version_number:= p_chk9_object_version_number;
  --
  hr_utility.set_location(l_proc, 180);
  --
  if (l_checklist_item_id is null  and
      p_chk9_item_code is not null and
      (  p_chk9_status     is not null
      or p_chk9_date_due   is not null
      or p_chk9_date_done  is not null
      or p_chk9_notes      is not null)) or
     (l_checklist_item_id is not null and
      (  nvl(per_chk_shd.g_old_rec.date_due,hr_api.g_date)
      <> nvl(p_chk9_date_due,hr_api.g_date)
      or nvl(per_chk_shd.g_old_rec.date_done,hr_api.g_date)
      <> nvl(p_chk9_date_done,hr_api.g_date)
      or nvl(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
      <> nvl(p_chk9_status,hr_api.g_varchar2)
      or nvl(per_chk_shd.g_old_rec.notes,hr_api.g_varchar2)
      <> nvl(p_chk9_notes,hr_api.g_varchar2))) then
    --
  hr_utility.set_location(l_proc, 190);
  --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_checklist_item_id => l_checklist_item_id
    ,p_effective_date => p_effective_date
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => p_person_id
    ,p_item_code => p_chk9_item_code
    ,p_date_due => p_chk9_date_due
    ,p_date_done => p_chk9_date_done
    ,p_status => p_chk9_status
    ,p_notes => p_chk9_notes
    );
  end if;
  p_chk9_checklist_item_id:=l_checklist_item_id;
  p_chk9_object_version_number:=l_chk_object_version_number;
  --
  l_checklist_item_id:=p_chk10_checklist_item_id;
  l_chk_object_version_number:= p_chk10_object_version_number;
  --
  hr_utility.set_location(l_proc, 200);
  --
  if (l_checklist_item_id is null and
      p_chk10_item_code is not null and
      (  p_chk10_status     is not null
      or p_chk10_date_due   is not null
      or p_chk10_date_done  is not null
      or p_chk10_notes      is not null)) or
     (l_checklist_item_id is not null and
      (  nvl(per_chk_shd.g_old_rec.date_due,hr_api.g_date)
      <> nvl(p_chk10_date_due,hr_api.g_date)
      or nvl(per_chk_shd.g_old_rec.date_done,hr_api.g_date)
      <> nvl(p_chk10_date_done,hr_api.g_date)
      or nvl(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
      <> nvl(p_chk10_status,hr_api.g_varchar2)
      or nvl(per_chk_shd.g_old_rec.notes,hr_api.g_varchar2)
      <> nvl(p_chk10_notes,hr_api.g_varchar2))) then
    --
  hr_utility.set_location(l_proc, 210);
  --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_checklist_item_id => l_checklist_item_id
    ,p_effective_date => p_effective_date
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => p_person_id
    ,p_item_code => p_chk10_item_code
    ,p_date_due => p_chk10_date_due
    ,p_date_done => p_chk10_date_done
    ,p_status => p_chk10_status
    ,p_notes => p_chk10_notes
    );
  end if;
  p_chk10_checklist_item_id:=l_checklist_item_id;
  p_chk10_object_version_number:=l_chk_object_version_number;
  --
  hr_utility.set_location('Leaving'||l_proc, 220);
  --
end update_summary_data;
--
procedure lock_summary_data
(p_chk1_checklist_item_id        per_checklist_items.checklist_item_id%type
,p_chk1_object_version_number    per_checklist_items.object_version_number%type
,p_chk2_checklist_item_id        per_checklist_items.checklist_item_id%type
,p_chk2_object_version_number    per_checklist_items.object_version_number%type
,p_chk3_checklist_item_id        per_checklist_items.checklist_item_id%type
,p_chk3_object_version_number    per_checklist_items.object_version_number%type
,p_chk4_checklist_item_id        per_checklist_items.checklist_item_id%type
,p_chk4_object_version_number    per_checklist_items.object_version_number%type
,p_chk5_checklist_item_id        per_checklist_items.checklist_item_id%type
,p_chk5_object_version_number    per_checklist_items.object_version_number%type
,p_chk6_checklist_item_id        per_checklist_items.checklist_item_id%type
,p_chk6_object_version_number    per_checklist_items.object_version_number%type
,p_chk7_checklist_item_id        per_checklist_items.checklist_item_id%type
,p_chk7_object_version_number    per_checklist_items.object_version_number%type
,p_chk8_checklist_item_id        per_checklist_items.checklist_item_id%type
,p_chk8_object_version_number    per_checklist_items.object_version_number%type
,p_chk9_checklist_item_id        per_checklist_items.checklist_item_id%type
,p_chk9_object_version_number    per_checklist_items.object_version_number%type
,p_chk10_checklist_item_id       per_checklist_items.checklist_item_id%type
,p_chk10_object_version_number   per_checklist_items.object_version_number%type
) is
l_proc varchar2(72) := g_package||'lock_summary_data';
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if p_chk1_checklist_item_id is not null then
    per_chk_shd.lck
    (p_checklist_item_id     => p_chk1_checklist_item_id
    ,p_object_version_number => p_chk1_object_version_number
    );
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  if p_chk2_checklist_item_id is not null then
    per_chk_shd.lck
    (p_checklist_item_id     => p_chk2_checklist_item_id
    ,p_object_version_number => p_chk2_object_version_number
    );
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  if p_chk3_checklist_item_id is not null then
    per_chk_shd.lck
    (p_checklist_item_id     => p_chk3_checklist_item_id
    ,p_object_version_number => p_chk3_object_version_number
    );
  end if;
  --
  hr_utility.set_location(l_proc, 40);
  --
  if p_chk4_checklist_item_id is not null then
    per_chk_shd.lck
    (p_checklist_item_id     => p_chk4_checklist_item_id
    ,p_object_version_number => p_chk4_object_version_number
    );
  end if;
  --
  hr_utility.set_location(l_proc, 50);
  --
  if p_chk5_checklist_item_id is not null then
    per_chk_shd.lck
    (p_checklist_item_id     => p_chk5_checklist_item_id
    ,p_object_version_number => p_chk5_object_version_number
    );
  end if;
  --
  hr_utility.set_location(l_proc, 60);
  --
  if p_chk6_checklist_item_id is not null then
    per_chk_shd.lck
    (p_checklist_item_id     => p_chk6_checklist_item_id
    ,p_object_version_number => p_chk6_object_version_number
    );
  end if;
  --
  hr_utility.set_location(l_proc, 70);
  --
  if p_chk7_checklist_item_id is not null then
    per_chk_shd.lck
    (p_checklist_item_id     => p_chk7_checklist_item_id
    ,p_object_version_number => p_chk7_object_version_number
    );
  end if;
  --
  hr_utility.set_location(l_proc, 80);
  --
  if p_chk8_checklist_item_id is not null then
    per_chk_shd.lck
    (p_checklist_item_id     => p_chk8_checklist_item_id
    ,p_object_version_number => p_chk8_object_version_number
    );
  end if;
  --
  hr_utility.set_location(l_proc, 90);
  --
  if p_chk9_checklist_item_id is not null then
    per_chk_shd.lck
    (p_checklist_item_id     => p_chk9_checklist_item_id
    ,p_object_version_number => p_chk9_object_version_number
    );
  end if;
  --
  hr_utility.set_location(l_proc, 100);
  --
  if p_chk10_checklist_item_id is not null then
    per_chk_shd.lck
    (p_checklist_item_id     => p_chk10_checklist_item_id
    ,p_object_version_number => p_chk10_object_version_number
    );
  end if;
  --
  hr_utility.set_location('Leaving'||l_proc, 110);
  --
end lock_summary_data;
--
end;

/
