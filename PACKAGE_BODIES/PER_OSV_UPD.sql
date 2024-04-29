--------------------------------------------------------
--  DDL for Package Body PER_OSV_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_OSV_UPD" as
/* $Header: peosvrhi.pkb 120.0 2005/05/31 12:37:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_osv_upd.';  -- Global package name
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
  (p_rec in out nocopy per_osv_shd.g_rec_type
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
  per_osv_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the per_org_structure_versions Row
  --
  update per_org_structure_versions
    set
     org_structure_version_id        = p_rec.org_structure_version_id
    ,business_group_id               = p_rec.business_group_id
    ,organization_structure_id       = p_rec.organization_structure_id
    ,date_from                       = p_rec.date_from
    ,version_number                  = p_rec.version_number
    ,copy_structure_version_id       = p_rec.copy_structure_version_id
    ,date_to                         = p_rec.date_to
    ,request_id                      = p_rec.request_id
    ,program_application_id          = p_rec.program_application_id
    ,program_id                      = p_rec.program_id
    ,program_update_date             = p_rec.program_update_date
    ,object_version_number           = p_rec.object_version_number
    ,topnode_pos_ctrl_enabled_flag   = p_rec.topnode_pos_ctrl_enabled_flag
    where org_structure_version_id = p_rec.org_structure_version_id;
  --
  per_osv_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_osv_shd.g_api_dml := false;   -- Unset the api dml status
    per_osv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_osv_shd.g_api_dml := false;   -- Unset the api dml status
    per_osv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_osv_shd.g_api_dml := false;   -- Unset the api dml status
    per_osv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_osv_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in per_osv_shd.g_rec_type
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
  ,p_rec                          in per_osv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_osv_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_org_structure_version_id
      => p_rec.org_structure_version_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_organization_structure_id
      => p_rec.organization_structure_id
      ,p_date_from
      => p_rec.date_from
      ,p_version_number
      => p_rec.version_number
      ,p_copy_structure_version_id
      => p_rec.copy_structure_version_id
      ,p_date_to
      => p_rec.date_to
      ,p_request_id
      => p_rec.request_id
      ,p_program_application_id
      => p_rec.program_application_id
      ,p_program_id
      => p_rec.program_id
      ,p_program_update_date
      => p_rec.program_update_date
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_topnode_pos_ctrl_enabled_fla
      => p_rec.topnode_pos_ctrl_enabled_flag
      ,p_business_group_id_o
      => per_osv_shd.g_old_rec.business_group_id
      ,p_organization_structure_id_o
      => per_osv_shd.g_old_rec.organization_structure_id
      ,p_date_from_o
      => per_osv_shd.g_old_rec.date_from
      ,p_version_number_o
      => per_osv_shd.g_old_rec.version_number
      ,p_copy_structure_version_id_o
      => per_osv_shd.g_old_rec.copy_structure_version_id
      ,p_date_to_o
      => per_osv_shd.g_old_rec.date_to
      ,p_request_id_o
      => per_osv_shd.g_old_rec.request_id
      ,p_program_application_id_o
      => per_osv_shd.g_old_rec.program_application_id
      ,p_program_id_o
      => per_osv_shd.g_old_rec.program_id
      ,p_program_update_date_o
      => per_osv_shd.g_old_rec.program_update_date
      ,p_object_version_number_o
      => per_osv_shd.g_old_rec.object_version_number
      ,p_topnode_pos_ctrl_enabled_f_o
      => per_osv_shd.g_old_rec.topnode_pos_ctrl_enabled_flag
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_ORG_STRUCTURE_VERSIONS'
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
  (p_rec in out nocopy per_osv_shd.g_rec_type
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
    per_osv_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.organization_structure_id = hr_api.g_number) then
    p_rec.organization_structure_id :=
    per_osv_shd.g_old_rec.organization_structure_id;
  End If;
  If (p_rec.date_from = hr_api.g_date) then
    p_rec.date_from :=
    per_osv_shd.g_old_rec.date_from;
  End If;
  If (p_rec.version_number = hr_api.g_number) then
    p_rec.version_number :=
    per_osv_shd.g_old_rec.version_number;
  End If;
  If (p_rec.copy_structure_version_id = hr_api.g_number) then
    p_rec.copy_structure_version_id :=
    per_osv_shd.g_old_rec.copy_structure_version_id;
  End If;
  If (p_rec.date_to = hr_api.g_date) then
    p_rec.date_to :=
    per_osv_shd.g_old_rec.date_to;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    per_osv_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    per_osv_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    per_osv_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    per_osv_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.topnode_pos_ctrl_enabled_flag = hr_api.g_varchar2) then
    p_rec.topnode_pos_ctrl_enabled_flag :=
    per_osv_shd.g_old_rec.topnode_pos_ctrl_enabled_flag;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy per_osv_shd.g_rec_type
  ,p_gap_warning                 out nocopy boolean
) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_osv_shd.lck
    (p_rec.org_structure_version_id
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
  per_osv_bus.update_validate
     (p_effective_date
     ,p_rec
     ,p_gap_warning
     );
  --
  -- Call the supporting pre-update operation
  --
  per_osv_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  per_osv_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  per_osv_upd.post_update
     (p_effective_date
     ,p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_org_structure_version_id     in     number
  ,p_object_version_number        in out nocopy number
  ,p_organization_structure_id    in     number    default hr_api.g_number
  ,p_date_from                    in     date      default hr_api.g_date
  ,p_version_number               in     number    default hr_api.g_number
  ,p_copy_structure_version_id    in     number    default hr_api.g_number
  ,p_date_to                      in     date      default hr_api.g_date
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_topnode_pos_ctrl_enabled_fla in     varchar2  default hr_api.g_varchar2
  ,p_gap_warning                 out nocopy     boolean) is
--
  l_rec   per_osv_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_osv_shd.convert_args
  (p_org_structure_version_id
  ,hr_api.g_number
  ,p_organization_structure_id
  ,p_date_from
  ,p_version_number
  ,p_copy_structure_version_id
  ,p_date_to
  ,p_request_id
  ,p_program_application_id
  ,p_program_id
  ,p_program_update_date
  ,p_object_version_number
  ,p_topnode_pos_ctrl_enabled_fla
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_osv_upd.upd
     (p_effective_date
     ,l_rec
     ,p_gap_warning);

  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_osv_upd;

/
