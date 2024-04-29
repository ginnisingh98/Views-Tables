--------------------------------------------------------
--  DDL for Package Body PER_EVT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_EVT_UPD" as
/* $Header: peevtrhi.pkb 120.2 2008/04/30 11:32:10 uuddavol ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_evt_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
  (p_rec in out nocopy per_evt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --

  per_evt_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the per_events Row
  --
  update per_events
    set
     event_id                        = p_rec.event_id
    ,business_group_id               = p_rec.business_group_id
    ,location_id                     = p_rec.location_id
    ,internal_contact_person_id      = p_rec.internal_contact_person_id
    ,organization_run_by_id          = p_rec.organization_run_by_id
    ,assignment_id                   = p_rec.assignment_id
    ,date_start                      = p_rec.date_start
    ,type                            = p_rec.type
    ,comments                        = p_rec.comments
    ,contact_telephone_number        = p_rec.contact_telephone_number
    ,date_end                        = p_rec.date_end
    ,emp_or_apl                      = p_rec.emp_or_apl
    ,event_or_interview              = p_rec.event_or_interview
    ,external_contact                = p_rec.external_contact
    ,time_end                        = p_rec.time_end
    ,time_start                      = p_rec.time_start
    ,request_id                      = p_rec.request_id
    ,program_application_id          = p_rec.program_application_id
    ,program_id                      = p_rec.program_id
    ,program_update_date             = p_rec.program_update_date
    ,attribute_category              = p_rec.attribute_category
    ,attribute1                      = p_rec.attribute1
    ,attribute2                      = p_rec.attribute2
    ,attribute3                      = p_rec.attribute3
    ,attribute4                      = p_rec.attribute4
    ,attribute5                      = p_rec.attribute5
    ,attribute6                      = p_rec.attribute6
    ,attribute7                      = p_rec.attribute7
    ,attribute8                      = p_rec.attribute8
    ,attribute9                      = p_rec.attribute9
    ,attribute10                     = p_rec.attribute10
    ,attribute11                     = p_rec.attribute11
    ,attribute12                     = p_rec.attribute12
    ,attribute13                     = p_rec.attribute13
    ,attribute14                     = p_rec.attribute14
    ,attribute15                     = p_rec.attribute15
    ,attribute16                     = p_rec.attribute16
    ,attribute17                     = p_rec.attribute17
    ,attribute18                     = p_rec.attribute18
    ,attribute19                     = p_rec.attribute19
    ,attribute20                     = p_rec.attribute20
    ,party_id                        = p_rec.party_id
    ,object_version_number           = p_rec.object_version_number
    where event_id = p_rec.event_id;
  --
  per_evt_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_evt_shd.g_api_dml := false;   -- Unset the api dml status
    per_evt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_evt_shd.g_api_dml := false;   -- Unset the api dml status
    per_evt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_evt_shd.g_api_dml := false;   -- Unset the api dml status
    per_evt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_evt_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception wil be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
  (p_rec in per_evt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
  (p_rec                          in per_evt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  begin
    --
    per_evt_rku.after_update
      (p_event_id
      => p_rec.event_id
      ,p_location_id
      => p_rec.location_id
      ,p_internal_contact_person_id
      => p_rec.internal_contact_person_id
      ,p_organization_run_by_id
      => p_rec.organization_run_by_id
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_date_start
      => p_rec.date_start
      ,p_type
      => p_rec.type
      ,p_comments
      => p_rec.comments
      ,p_contact_telephone_number
      => p_rec.contact_telephone_number
      ,p_date_end
      => p_rec.date_end
      ,p_emp_or_apl
      => p_rec.emp_or_apl
      ,p_event_or_interview
      => p_rec.event_or_interview
      ,p_external_contact
      => p_rec.external_contact
      ,p_time_end
      => p_rec.time_end
      ,p_time_start
      => p_rec.time_start
      ,p_request_id
      => p_rec.request_id
      ,p_program_application_id
      => p_rec.program_application_id
      ,p_program_id
      => p_rec.program_id
      ,p_program_update_date
      => p_rec.program_update_date
      ,p_attribute_category
      => p_rec.attribute_category
      ,p_attribute1
      => p_rec.attribute1
      ,p_attribute2
      => p_rec.attribute2
      ,p_attribute3
      => p_rec.attribute3
      ,p_attribute4
      => p_rec.attribute4
      ,p_attribute5
      => p_rec.attribute5
      ,p_attribute6
      => p_rec.attribute6
      ,p_attribute7
      => p_rec.attribute7
      ,p_attribute8
      => p_rec.attribute8
      ,p_attribute9
      => p_rec.attribute9
      ,p_attribute10
      => p_rec.attribute10
      ,p_attribute11
      => p_rec.attribute11
      ,p_attribute12
      => p_rec.attribute12
      ,p_attribute13
      => p_rec.attribute13
      ,p_attribute14
      => p_rec.attribute14
      ,p_attribute15
      => p_rec.attribute15
      ,p_attribute16
      => p_rec.attribute16
      ,p_attribute17
      => p_rec.attribute17
      ,p_attribute18
      => p_rec.attribute18
      ,p_attribute19
      => p_rec.attribute19
      ,p_attribute20
      => p_rec.attribute20
      ,p_party_id
      => p_rec.party_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_location_id_o
      => per_evt_shd.g_old_rec.location_id
      ,p_internal_contact_person_id_o
      => per_evt_shd.g_old_rec.internal_contact_person_id
      ,p_organization_run_by_id_o
      => per_evt_shd.g_old_rec.organization_run_by_id
      ,p_assignment_id_o
      => per_evt_shd.g_old_rec.assignment_id
      ,p_date_start_o
      => per_evt_shd.g_old_rec.date_start
      ,p_type_o
      => per_evt_shd.g_old_rec.type
      ,p_comments_o
      => per_evt_shd.g_old_rec.comments
      ,p_contact_telephone_number_o
      => per_evt_shd.g_old_rec.contact_telephone_number
      ,p_date_end_o
      => per_evt_shd.g_old_rec.date_end
      ,p_emp_or_apl_o
      => per_evt_shd.g_old_rec.emp_or_apl
      ,p_event_or_interview_o
      => per_evt_shd.g_old_rec.event_or_interview
      ,p_external_contact_o
      => per_evt_shd.g_old_rec.external_contact
      ,p_time_end_o
      => per_evt_shd.g_old_rec.time_end
      ,p_time_start_o
      => per_evt_shd.g_old_rec.time_start
      ,p_request_id_o
      => per_evt_shd.g_old_rec.request_id
      ,p_program_application_id_o
      => per_evt_shd.g_old_rec.program_application_id
      ,p_program_id_o
      => per_evt_shd.g_old_rec.program_id
      ,p_program_update_date_o
      => per_evt_shd.g_old_rec.program_update_date
      ,p_attribute_category_o
      => per_evt_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => per_evt_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => per_evt_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => per_evt_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => per_evt_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => per_evt_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => per_evt_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => per_evt_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => per_evt_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => per_evt_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => per_evt_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => per_evt_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => per_evt_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => per_evt_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => per_evt_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => per_evt_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => per_evt_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => per_evt_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => per_evt_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => per_evt_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => per_evt_shd.g_old_rec.attribute20
      ,p_party_id_o
      => per_evt_shd.g_old_rec.party_id
      ,p_object_version_number_o
      => per_evt_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_EVENTS'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs
  (p_rec in out nocopy per_evt_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    per_evt_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.location_id = hr_api.g_number) then
    p_rec.location_id :=
    per_evt_shd.g_old_rec.location_id;
  End If;
  If (p_rec.internal_contact_person_id = hr_api.g_number) then
    p_rec.internal_contact_person_id :=
    per_evt_shd.g_old_rec.internal_contact_person_id;
  End If;
  If (p_rec.organization_run_by_id = hr_api.g_number) then
    p_rec.organization_run_by_id :=
    per_evt_shd.g_old_rec.organization_run_by_id;
  End If;
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    per_evt_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.date_start = hr_api.g_date) then
    p_rec.date_start :=
    per_evt_shd.g_old_rec.date_start;
  End If;
  If (p_rec.type = hr_api.g_varchar2) then
    p_rec.type :=
    per_evt_shd.g_old_rec.type;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    per_evt_shd.g_old_rec.comments;
  End If;
  If (p_rec.contact_telephone_number = hr_api.g_varchar2) then
    p_rec.contact_telephone_number :=
    per_evt_shd.g_old_rec.contact_telephone_number;
  End If;
  If (p_rec.date_end = hr_api.g_date) then
    p_rec.date_end :=
    per_evt_shd.g_old_rec.date_end;
  End If;
  If (p_rec.emp_or_apl = hr_api.g_varchar2) then
    p_rec.emp_or_apl :=
    per_evt_shd.g_old_rec.emp_or_apl;
  End If;
  If (p_rec.event_or_interview = hr_api.g_varchar2) then
    p_rec.event_or_interview :=
    per_evt_shd.g_old_rec.event_or_interview;
  End If;
  If (p_rec.external_contact = hr_api.g_varchar2) then
    p_rec.external_contact :=
    per_evt_shd.g_old_rec.external_contact;
  End If;
  If (p_rec.time_end = hr_api.g_varchar2) then
    p_rec.time_end :=
    per_evt_shd.g_old_rec.time_end;
  End If;
  If (p_rec.time_start = hr_api.g_varchar2) then
    p_rec.time_start :=
    per_evt_shd.g_old_rec.time_start;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    per_evt_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    per_evt_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    per_evt_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    per_evt_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    per_evt_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    per_evt_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    per_evt_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    per_evt_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    per_evt_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    per_evt_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    per_evt_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    per_evt_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    per_evt_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    per_evt_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    per_evt_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    per_evt_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    per_evt_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    per_evt_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    per_evt_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    per_evt_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    per_evt_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    per_evt_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    per_evt_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    per_evt_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    per_evt_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.party_id = hr_api.g_number) then
    p_rec.party_id :=
    per_evt_shd.g_old_rec.party_id;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy per_evt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- We must lock the row which we need to update.
  --
  per_evt_shd.lck
    (p_rec.event_id
    ,p_rec.object_version_number
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  per_evt_bus.update_validate
     (p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  per_evt_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  per_evt_upd.update_dml(p_rec);

  --
  -- Call the supporting post-update operation
  --
  per_evt_upd.post_update
     (p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_event_id                     in     number
  ,p_object_version_number        in out nocopy number
  ,p_date_start                   in     date      default hr_api.g_date
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_internal_contact_person_id   in     number    default hr_api.g_number
  ,p_organization_run_by_id       in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_contact_telephone_number     in     varchar2  default hr_api.g_varchar2
  ,p_date_end                     in     date      default hr_api.g_date
  ,p_emp_or_apl                   in     varchar2  default hr_api.g_varchar2
  ,p_event_or_interview           in     varchar2  default hr_api.g_varchar2
  ,p_external_contact             in     varchar2  default hr_api.g_varchar2
  ,p_time_end                     in     varchar2  default hr_api.g_varchar2
  ,p_time_start                   in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_party_id                     in     number    default hr_api.g_number
  ) is
--
  l_rec   per_evt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_evt_shd.convert_args
  (p_event_id
  ,p_business_group_id
  ,p_location_id
  ,p_internal_contact_person_id
  ,p_organization_run_by_id
  ,p_assignment_id
  ,p_date_start
  ,p_type
  ,p_comments
  ,p_contact_telephone_number
  ,p_date_end
  ,p_emp_or_apl
  ,p_event_or_interview
  ,p_external_contact
  ,p_time_end
  ,p_time_start
  ,p_request_id
  ,p_program_application_id
  ,p_program_id
  ,p_program_update_date
  ,p_attribute_category
  ,p_attribute1
  ,p_attribute2
  ,p_attribute3
  ,p_attribute4
  ,p_attribute5
  ,p_attribute6
  ,p_attribute7
  ,p_attribute8
  ,p_attribute9
  ,p_attribute10
  ,p_attribute11
  ,p_attribute12
  ,p_attribute13
  ,p_attribute14
  ,p_attribute15
  ,p_attribute16
  ,p_attribute17
  ,p_attribute18
  ,p_attribute19
  ,p_attribute20
  ,p_party_id
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_evt_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End upd;
--
end per_evt_upd;

/
