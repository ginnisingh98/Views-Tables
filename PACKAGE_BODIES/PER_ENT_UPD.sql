--------------------------------------------------------
--  DDL for Package Body PER_ENT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ENT_UPD" as
/* $Header: peentrhi.pkb 120.2 2005/06/16 08:27:40 vegopala noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ent_upd.';  -- Global package name
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
  (p_rec in out nocopy per_ent_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  --
  -- Update the per_calendar_entries Row
  update per_calendar_entries
    set
     calendar_entry_id               = p_rec.calendar_entry_id
    ,name                            = p_rec.name
    ,type                            = p_rec.type
    ,start_date                      = p_rec.start_date
    ,start_hour                      = p_rec.start_hour
    ,start_min                       = p_rec.start_min
    ,end_date                        = p_rec.end_date
    ,end_hour                        = p_rec.end_hour
    ,end_min                         = p_rec.end_min
    ,description                     = p_rec.description
    ,hierarchy_id                    = p_rec.hierarchy_id
    ,value_set_id                    = p_rec.value_set_id
    ,organization_structure_id       = p_rec.organization_structure_id
    ,org_structure_version_id        = p_rec.org_structure_version_id
    ,object_version_number           = p_rec.object_version_number
    ,business_group_id               = p_rec.business_group_id
    where calendar_entry_id = p_rec.calendar_entry_id;

  --
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_ent_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_ent_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_ent_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
  (p_rec in per_ent_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
  (p_effective_date               in date
  ,p_rec                          in per_ent_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_ent_rku.after_update
      (p_effective_date
      => p_effective_date
      ,p_calendar_entry_id
      => p_rec.calendar_entry_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_name
      => p_rec.name
      ,p_type
      => p_rec.type
      ,p_start_date
      => p_rec.start_date
      ,p_start_hour
      => p_rec.start_hour
      ,p_start_min
      => p_rec.start_min
      ,p_end_date
      => p_rec.end_date
      ,p_end_hour
      => p_rec.end_hour
      ,p_end_min
      => p_rec.end_min
      ,p_description
      => p_rec.description
      ,p_hierarchy_id
      => p_rec.hierarchy_id
      ,p_value_set_id
      => p_rec.value_set_id
      ,p_organization_structure_id
      => p_rec.organization_structure_id
      ,p_org_structure_version_id
      => p_rec.org_structure_version_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_business_group_id_o
      => per_ent_shd.g_old_rec.business_group_id
      ,p_name_o
      => per_ent_shd.g_old_rec.name
      ,p_type_o
      => per_ent_shd.g_old_rec.type
      ,p_start_date_o
      => per_ent_shd.g_old_rec.start_date
      ,p_start_hour_o
      => per_ent_shd.g_old_rec.start_hour
      ,p_start_min_o
      => per_ent_shd.g_old_rec.start_min
      ,p_end_date_o
      => per_ent_shd.g_old_rec.end_date
      ,p_end_hour_o
      => per_ent_shd.g_old_rec.end_hour
      ,p_end_min_o
      => per_ent_shd.g_old_rec.end_min
      ,p_description_o
      => per_ent_shd.g_old_rec.description
      ,p_hierarchy_id_o
      => per_ent_shd.g_old_rec.hierarchy_id
      ,p_value_set_id_o
      => per_ent_shd.g_old_rec.value_set_id
      ,p_organization_structure_id_o
      => per_ent_shd.g_old_rec.organization_structure_id
      ,p_org_structure_version_id_o
      => per_ent_shd.g_old_rec.org_structure_version_id
      ,p_object_version_number_o
      => per_ent_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_CALENDAR_ENTRIES'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
  (p_rec in out nocopy per_ent_shd.g_rec_type
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
    per_ent_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    per_ent_shd.g_old_rec.name;
  End If;
  If (p_rec.type = hr_api.g_varchar2) then
    p_rec.type :=
    per_ent_shd.g_old_rec.type;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    per_ent_shd.g_old_rec.start_date;
  End If;
  If (p_rec.start_hour = hr_api.g_varchar2) then
    p_rec.start_hour :=
    per_ent_shd.g_old_rec.start_hour;
  End If;
  If (p_rec.start_min = hr_api.g_varchar2) then
    p_rec.start_min :=
    per_ent_shd.g_old_rec.start_min;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    per_ent_shd.g_old_rec.end_date;
  End If;
  If (p_rec.end_hour = hr_api.g_varchar2) then
    p_rec.end_hour :=
    per_ent_shd.g_old_rec.end_hour;
  End If;
  If (p_rec.end_min = hr_api.g_varchar2) then
    p_rec.end_min :=
    per_ent_shd.g_old_rec.end_min;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    per_ent_shd.g_old_rec.description;
  End If;
  If (p_rec.hierarchy_id = hr_api.g_number) then
    p_rec.hierarchy_id :=
    per_ent_shd.g_old_rec.hierarchy_id;
  End If;
  If (p_rec.value_set_id = hr_api.g_number) then
    p_rec.value_set_id :=
    per_ent_shd.g_old_rec.value_set_id;
  End If;
  If (p_rec.organization_structure_id = hr_api.g_number) then
    p_rec.organization_structure_id :=
    per_ent_shd.g_old_rec.organization_structure_id;
  End If;
  If (p_rec.org_structure_version_id = hr_api.g_number) then
    p_rec.org_structure_version_id :=
    per_ent_shd.g_old_rec.org_structure_version_id;
  End If;
  If (p_rec.legislation_code = hr_api.g_varchar2) then
    p_rec.legislation_code :=
    per_ent_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.identifier_key = hr_api.g_varchar2) then
    p_rec.identifier_key :=
    per_ent_shd.g_old_rec.identifier_key;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy per_ent_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_ent_shd.lck
    (p_rec.calendar_entry_id
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
  per_ent_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  per_ent_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  per_ent_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  per_ent_upd.post_update
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_calendar_entry_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_start_hour                   in     varchar2  default hr_api.g_varchar2
  ,p_start_min                    in     varchar2  default hr_api.g_varchar2
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_end_hour                     in     varchar2  default hr_api.g_varchar2
  ,p_end_min                      in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_hierarchy_id                 in     number    default hr_api.g_number
  ,p_value_set_id                 in     number    default hr_api.g_number
  ,p_organization_structure_id    in     number    default hr_api.g_number
  ,p_org_structure_version_id     in     number    default hr_api.g_number
  ,p_business_group_id             in     number   default null
  ) is
--
  l_rec   per_ent_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_ent_shd.convert_args
  (p_calendar_entry_id
  ,p_business_group_id
  ,p_name
  ,p_type
  ,p_start_date
  ,p_start_hour
  ,p_start_min
  ,p_end_date
  ,p_end_hour
  ,p_end_min
  ,p_description
  ,p_hierarchy_id
  ,p_value_set_id
  ,p_organization_structure_id
  ,p_org_structure_version_id
  ,hr_api.g_varchar2
  ,hr_api.g_varchar2
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_ent_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_ent_upd;

/
