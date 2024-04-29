--------------------------------------------------------
--  DDL for Package Body PQH_WDT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_WDT_UPD" as
/* $Header: pqwdtrhi.pkb 120.0.12000000.1 2007/01/17 00:29:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_wdt_upd.';  -- Global package name
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
--   2) To update the specified row in the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
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
Procedure update_dml(p_rec in out nocopy pqh_wdt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  -- Update the pqh_worksheet_details Row
  --
  update pqh_worksheet_details
  set
  worksheet_detail_id               = p_rec.worksheet_detail_id,
  worksheet_id                      = p_rec.worksheet_id,
  organization_id                   = p_rec.organization_id,
  job_id                            = p_rec.job_id,
  position_id                       = p_rec.position_id,
  grade_id                          = p_rec.grade_id,
  position_transaction_id           = p_rec.position_transaction_id,
  budget_detail_id                  = p_rec.budget_detail_id,
  parent_worksheet_detail_id        = p_rec.parent_worksheet_detail_id,
  user_id                           = p_rec.user_id,
  action_cd                         = p_rec.action_cd,
  budget_unit1_percent              = p_rec.budget_unit1_percent,
  budget_unit1_value                = p_rec.budget_unit1_value,
  budget_unit2_percent              = p_rec.budget_unit2_percent,
  budget_unit2_value                = p_rec.budget_unit2_value,
  budget_unit3_percent              = p_rec.budget_unit3_percent,
  budget_unit3_value                = p_rec.budget_unit3_value,
  object_version_number             = p_rec.object_version_number,
  budget_unit1_value_type_cd        = p_rec.budget_unit1_value_type_cd,
  budget_unit2_value_type_cd        = p_rec.budget_unit2_value_type_cd,
  budget_unit3_value_type_cd        = p_rec.budget_unit3_value_type_cd,
  status                            = p_rec.status,
  budget_unit1_available            = p_rec.budget_unit1_available,
  budget_unit2_available            = p_rec.budget_unit2_available,
  budget_unit3_available            = p_rec.budget_unit3_available,
  old_unit1_value                   = p_rec.old_unit1_value,
  old_unit2_value                   = p_rec.old_unit2_value,
  old_unit3_value                   = p_rec.old_unit3_value,
  defer_flag                        = p_rec.defer_flag,
  propagation_method                = p_rec.propagation_method
  where worksheet_detail_id = p_rec.worksheet_detail_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_wdt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_wdt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_wdt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
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
Procedure pre_update(p_rec in pqh_wdt_shd.g_rec_type) is
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
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
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
Procedure post_update(
p_effective_date in date,p_rec in pqh_wdt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    pqh_wdt_rku.after_update
      (
  p_worksheet_detail_id           =>p_rec.worksheet_detail_id
 ,p_worksheet_id                  =>p_rec.worksheet_id
 ,p_organization_id               =>p_rec.organization_id
 ,p_job_id                        =>p_rec.job_id
 ,p_position_id                   =>p_rec.position_id
 ,p_grade_id                      =>p_rec.grade_id
 ,p_position_transaction_id       =>p_rec.position_transaction_id
 ,p_budget_detail_id              =>p_rec.budget_detail_id
 ,p_parent_worksheet_detail_id    =>p_rec.parent_worksheet_detail_id
 ,p_user_id                       =>p_rec.user_id
 ,p_action_cd                     =>p_rec.action_cd
 ,p_budget_unit1_percent          =>p_rec.budget_unit1_percent
 ,p_budget_unit1_value            =>p_rec.budget_unit1_value
 ,p_budget_unit2_percent          =>p_rec.budget_unit2_percent
 ,p_budget_unit2_value            =>p_rec.budget_unit2_value
 ,p_budget_unit3_percent          =>p_rec.budget_unit3_percent
 ,p_budget_unit3_value            =>p_rec.budget_unit3_value
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_budget_unit1_value_type_cd    =>p_rec.budget_unit1_value_type_cd
 ,p_budget_unit2_value_type_cd    =>p_rec.budget_unit2_value_type_cd
 ,p_budget_unit3_value_type_cd    =>p_rec.budget_unit3_value_type_cd
 ,p_status                        =>p_rec.status
 ,p_budget_unit1_available        =>p_rec.budget_unit1_available
 ,p_budget_unit2_available        =>p_rec.budget_unit2_available
 ,p_budget_unit3_available        =>p_rec.budget_unit3_available
 ,p_old_unit1_value               =>p_rec.old_unit1_value
 ,p_old_unit2_value               =>p_rec.old_unit2_value
 ,p_old_unit3_value               =>p_rec.old_unit3_value
 ,p_defer_flag                    =>p_rec.defer_flag
 ,p_propagation_method            =>p_rec.propagation_method
 ,p_effective_date                =>p_effective_date
 ,p_worksheet_id_o                =>pqh_wdt_shd.g_old_rec.worksheet_id
 ,p_organization_id_o             =>pqh_wdt_shd.g_old_rec.organization_id
 ,p_job_id_o                      =>pqh_wdt_shd.g_old_rec.job_id
 ,p_position_id_o                 =>pqh_wdt_shd.g_old_rec.position_id
 ,p_grade_id_o                    =>pqh_wdt_shd.g_old_rec.grade_id
 ,p_position_transaction_id_o     =>pqh_wdt_shd.g_old_rec.position_transaction_id
 ,p_budget_detail_id_o            =>pqh_wdt_shd.g_old_rec.budget_detail_id
 ,p_parent_worksheet_detail_id_o  =>pqh_wdt_shd.g_old_rec.parent_worksheet_detail_id
 ,p_user_id_o                     =>pqh_wdt_shd.g_old_rec.user_id
 ,p_action_cd_o                   =>pqh_wdt_shd.g_old_rec.action_cd
 ,p_budget_unit1_percent_o        =>pqh_wdt_shd.g_old_rec.budget_unit1_percent
 ,p_budget_unit1_value_o          =>pqh_wdt_shd.g_old_rec.budget_unit1_value
 ,p_budget_unit2_percent_o        =>pqh_wdt_shd.g_old_rec.budget_unit2_percent
 ,p_budget_unit2_value_o          =>pqh_wdt_shd.g_old_rec.budget_unit2_value
 ,p_budget_unit3_percent_o        =>pqh_wdt_shd.g_old_rec.budget_unit3_percent
 ,p_budget_unit3_value_o          =>pqh_wdt_shd.g_old_rec.budget_unit3_value
 ,p_object_version_number_o       =>pqh_wdt_shd.g_old_rec.object_version_number
 ,p_budget_unit1_value_type_cd_o  =>pqh_wdt_shd.g_old_rec.budget_unit1_value_type_cd
 ,p_budget_unit2_value_type_cd_o  =>pqh_wdt_shd.g_old_rec.budget_unit2_value_type_cd
 ,p_budget_unit3_value_type_cd_o  =>pqh_wdt_shd.g_old_rec.budget_unit3_value_type_cd
 ,p_status_o                      =>pqh_wdt_shd.g_old_rec.status
 ,p_budget_unit1_available_o      =>pqh_wdt_shd.g_old_rec.budget_unit1_available
 ,p_budget_unit2_available_o      =>pqh_wdt_shd.g_old_rec.budget_unit2_available
 ,p_budget_unit3_available_o      =>pqh_wdt_shd.g_old_rec.budget_unit3_available
 ,p_old_unit1_value_o             =>pqh_wdt_shd.g_old_rec.old_unit1_value
 ,p_old_unit2_value_o             =>pqh_wdt_shd.g_old_rec.old_unit2_value
 ,p_old_unit3_value_o             =>pqh_wdt_shd.g_old_rec.old_unit3_value
 ,p_defer_flag_o                  =>pqh_wdt_shd.g_old_rec.defer_flag
 ,p_propagation_method_o          =>pqh_wdt_shd.g_old_rec.propagation_method
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_worksheet_details'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
  --
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
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy pqh_wdt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.worksheet_id = hr_api.g_number) then
    p_rec.worksheet_id :=
    pqh_wdt_shd.g_old_rec.worksheet_id;
  End If;
  If (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    pqh_wdt_shd.g_old_rec.organization_id;
  End If;
  If (p_rec.job_id = hr_api.g_number) then
    p_rec.job_id :=
    pqh_wdt_shd.g_old_rec.job_id;
  End If;
  If (p_rec.position_id = hr_api.g_number) then
    p_rec.position_id :=
    pqh_wdt_shd.g_old_rec.position_id;
  End If;
  If (p_rec.grade_id = hr_api.g_number) then
    p_rec.grade_id :=
    pqh_wdt_shd.g_old_rec.grade_id;
  End If;
  If (p_rec.position_transaction_id = hr_api.g_number) then
    p_rec.position_transaction_id :=
    pqh_wdt_shd.g_old_rec.position_transaction_id;
  End If;
  If (p_rec.budget_detail_id = hr_api.g_number) then
    p_rec.budget_detail_id :=
    pqh_wdt_shd.g_old_rec.budget_detail_id;
  End If;
  If (p_rec.parent_worksheet_detail_id = hr_api.g_number) then
    p_rec.parent_worksheet_detail_id :=
    pqh_wdt_shd.g_old_rec.parent_worksheet_detail_id;
  End If;
  If (p_rec.user_id = hr_api.g_number) then
    p_rec.user_id :=
    pqh_wdt_shd.g_old_rec.user_id;
  End If;
  If (p_rec.action_cd = hr_api.g_varchar2) then
    p_rec.action_cd :=
    pqh_wdt_shd.g_old_rec.action_cd;
  End If;
  If (p_rec.budget_unit1_percent = hr_api.g_number) then
    p_rec.budget_unit1_percent :=
    pqh_wdt_shd.g_old_rec.budget_unit1_percent;
  End If;
  If (p_rec.budget_unit1_value = hr_api.g_number) then
    p_rec.budget_unit1_value :=
    pqh_wdt_shd.g_old_rec.budget_unit1_value;
  End If;
  If (p_rec.budget_unit2_percent = hr_api.g_number) then
    p_rec.budget_unit2_percent :=
    pqh_wdt_shd.g_old_rec.budget_unit2_percent;
  End If;
  If (p_rec.budget_unit2_value = hr_api.g_number) then
    p_rec.budget_unit2_value :=
    pqh_wdt_shd.g_old_rec.budget_unit2_value;
  End If;
  If (p_rec.budget_unit3_percent = hr_api.g_number) then
    p_rec.budget_unit3_percent :=
    pqh_wdt_shd.g_old_rec.budget_unit3_percent;
  End If;
  If (p_rec.budget_unit3_value = hr_api.g_number) then
    p_rec.budget_unit3_value :=
    pqh_wdt_shd.g_old_rec.budget_unit3_value;
  End If;
  If (p_rec.budget_unit1_value_type_cd = hr_api.g_varchar2) then
    p_rec.budget_unit1_value_type_cd :=
    pqh_wdt_shd.g_old_rec.budget_unit1_value_type_cd;
  End If;
  If (p_rec.budget_unit2_value_type_cd = hr_api.g_varchar2) then
    p_rec.budget_unit2_value_type_cd :=
    pqh_wdt_shd.g_old_rec.budget_unit2_value_type_cd;
  End If;
  If (p_rec.budget_unit3_value_type_cd = hr_api.g_varchar2) then
    p_rec.budget_unit3_value_type_cd :=
    pqh_wdt_shd.g_old_rec.budget_unit3_value_type_cd;
  End If;
  If (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    pqh_wdt_shd.g_old_rec.status;
  End If;
  If (p_rec.budget_unit1_available = hr_api.g_number) then
    p_rec.budget_unit1_available :=
    pqh_wdt_shd.g_old_rec.budget_unit1_available;
  End If;
  If (p_rec.budget_unit2_available = hr_api.g_number) then
    p_rec.budget_unit2_available :=
    pqh_wdt_shd.g_old_rec.budget_unit2_available;
  End If;
  If (p_rec.budget_unit3_available = hr_api.g_number) then
    p_rec.budget_unit3_available :=
    pqh_wdt_shd.g_old_rec.budget_unit3_available;
  End If;
  If (p_rec.old_unit1_value = hr_api.g_number) then
    p_rec.old_unit1_value :=
    pqh_wdt_shd.g_old_rec.old_unit1_value;
  End If;
  If (p_rec.old_unit2_value = hr_api.g_number) then
    p_rec.old_unit2_value :=
    pqh_wdt_shd.g_old_rec.old_unit2_value;
  End If;
  If (p_rec.old_unit3_value = hr_api.g_number) then
    p_rec.old_unit3_value :=
    pqh_wdt_shd.g_old_rec.old_unit3_value;
  End If;
  If (p_rec.defer_flag = hr_api.g_varchar2) then
    p_rec.defer_flag :=
    pqh_wdt_shd.g_old_rec.defer_flag;
  End If;
  If (p_rec.propagation_method = hr_api.g_varchar2) then
    p_rec.propagation_method :=
    pqh_wdt_shd.g_old_rec.propagation_method;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date in date,
  p_rec        in out nocopy pqh_wdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqh_wdt_shd.lck
	(
	p_rec.worksheet_detail_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  pqh_wdt_bus.update_validate(p_rec
  ,p_effective_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(
p_effective_date,p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date in date,
  p_worksheet_detail_id          in number,
  p_worksheet_id                 in number           default hr_api.g_number,
  p_organization_id              in number           default hr_api.g_number,
  p_job_id                       in number           default hr_api.g_number,
  p_position_id                  in number           default hr_api.g_number,
  p_grade_id                     in number           default hr_api.g_number,
  p_position_transaction_id      in number           default hr_api.g_number,
  p_budget_detail_id             in number           default hr_api.g_number,
  p_parent_worksheet_detail_id   in number           default hr_api.g_number,
  p_user_id                      in number           default hr_api.g_number,
  p_action_cd                    in varchar2         default hr_api.g_varchar2,
  p_budget_unit1_percent         in number           default hr_api.g_number,
  p_budget_unit1_value           in number           default hr_api.g_number,
  p_budget_unit2_percent         in number           default hr_api.g_number,
  p_budget_unit2_value           in number           default hr_api.g_number,
  p_budget_unit3_percent         in number           default hr_api.g_number,
  p_budget_unit3_value           in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_budget_unit1_value_type_cd   in varchar2         default hr_api.g_varchar2,
  p_budget_unit2_value_type_cd   in varchar2         default hr_api.g_varchar2,
  p_budget_unit3_value_type_cd   in varchar2         default hr_api.g_varchar2,
  p_status                       in varchar2         default hr_api.g_varchar2,
  p_budget_unit1_available       in number           default hr_api.g_number,
  p_budget_unit2_available       in number           default hr_api.g_number,
  p_budget_unit3_available       in number           default hr_api.g_number,
  p_old_unit1_value              in number           default hr_api.g_number,
  p_old_unit2_value              in number           default hr_api.g_number,
  p_old_unit3_value              in number           default hr_api.g_number,
  p_defer_flag                   in varchar2         default hr_api.g_varchar2,
  p_propagation_method           in varchar2         default hr_api.g_varchar2
  ) is
--
  l_rec	  pqh_wdt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_wdt_shd.convert_args
  (
  p_worksheet_detail_id,
  p_worksheet_id,
  p_organization_id,
  p_job_id,
  p_position_id,
  p_grade_id,
  p_position_transaction_id,
  p_budget_detail_id,
  p_parent_worksheet_detail_id,
  p_user_id,
  p_action_cd,
  p_budget_unit1_percent,
  p_budget_unit1_value,
  p_budget_unit2_percent,
  p_budget_unit2_value,
  p_budget_unit3_percent,
  p_budget_unit3_value,
  p_object_version_number,
  p_budget_unit1_value_type_cd,
  p_budget_unit2_value_type_cd,
  p_budget_unit3_value_type_cd,
  p_status,
  p_budget_unit1_available,
  p_budget_unit2_available,
  p_budget_unit3_available,
  p_old_unit1_value,
  p_old_unit2_value,
  p_old_unit3_value,
  p_defer_flag,
  p_propagation_method
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(
    p_effective_date,l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqh_wdt_upd;

/
