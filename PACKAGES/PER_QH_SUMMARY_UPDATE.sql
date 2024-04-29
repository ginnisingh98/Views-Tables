--------------------------------------------------------
--  DDL for Package PER_QH_SUMMARY_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QH_SUMMARY_UPDATE" AUTHID CURRENT_USER as
/* $Header: peqhsumi.pkh 115.4 2003/05/14 12:48:09 adhunter noship $ */

procedure update_summary_data
(p_effective_date                in     date
,p_person_id                     in     per_all_people_f.person_id%type
,p_chk1_checklist_item_id        in out nocopy     per_checklist_items.checklist_item_id%type
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
);
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
);
--
end;

 

/
