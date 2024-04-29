--------------------------------------------------------
--  DDL for Package Body PQH_WKS_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_WKS_UPD" as
/* $Header: pqwksrhi.pkb 120.0 2005/05/29 03:01:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_wks_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy pqh_wks_shd.g_rec_type) is
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
  -- Update the pqh_worksheets Row
  --
  update pqh_worksheets
  set
  worksheet_id                      = p_rec.worksheet_id,
  budget_id                         = p_rec.budget_id,
  worksheet_name                    = p_rec.worksheet_name,
  version_number                    = p_rec.version_number,
  action_date                       = p_rec.action_date,
  date_from                         = p_rec.date_from,
  date_to                           = p_rec.date_to,
  worksheet_mode_cd                 = p_rec.worksheet_mode_cd,
  transaction_status                            = p_rec.transaction_status,
  object_version_number             = p_rec.object_version_number,
  budget_version_id                 = p_rec.budget_version_id,
  propagation_method                = p_rec.propagation_method,
  wf_transaction_category_id        = p_rec.wf_transaction_category_id
  where worksheet_id = p_rec.worksheet_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_wks_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_wks_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_wks_shd.constraint_error
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
Procedure pre_update(p_rec in pqh_wks_shd.g_rec_type) is
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
p_effective_date in date,p_rec in pqh_wks_shd.g_rec_type) is
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
    pqh_wks_rku.after_update
      (
  p_worksheet_id                  =>p_rec.worksheet_id
 ,p_budget_id                     =>p_rec.budget_id
 ,p_worksheet_name                =>p_rec.worksheet_name
 ,p_version_number                =>p_rec.version_number
 ,p_action_date                   =>p_rec.action_date
 ,p_date_from                     =>p_rec.date_from
 ,p_date_to                       =>p_rec.date_to
 ,p_worksheet_mode_cd             =>p_rec.worksheet_mode_cd
 ,p_transaction_status            =>p_rec.transaction_status
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_budget_version_id             =>p_rec.budget_version_id
 ,p_propagation_method            =>p_rec.propagation_method
 ,p_effective_date                =>p_effective_date
 ,p_wf_transaction_category_id    =>p_rec.wf_transaction_category_id
 ,p_budget_id_o                   =>pqh_wks_shd.g_old_rec.budget_id
 ,p_worksheet_name_o              =>pqh_wks_shd.g_old_rec.worksheet_name
 ,p_version_number_o              =>pqh_wks_shd.g_old_rec.version_number
 ,p_action_date_o                 =>pqh_wks_shd.g_old_rec.action_date
 ,p_date_from_o                   =>pqh_wks_shd.g_old_rec.date_from
 ,p_date_to_o                     =>pqh_wks_shd.g_old_rec.date_to
 ,p_worksheet_mode_cd_o           =>pqh_wks_shd.g_old_rec.worksheet_mode_cd
 ,p_transaction_status_o          =>pqh_wks_shd.g_old_rec.transaction_status
 ,p_object_version_number_o       =>pqh_wks_shd.g_old_rec.object_version_number
 ,p_budget_version_id_o           =>pqh_wks_shd.g_old_rec.budget_version_id
 ,p_propagation_method_o          =>pqh_wks_shd.g_old_rec.propagation_method
 ,p_wf_transaction_category_id_o  =>pqh_wks_shd.g_old_rec.wf_transaction_category_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_worksheets'
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
Procedure convert_defs(p_rec in out nocopy pqh_wks_shd.g_rec_type) is
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
  If (p_rec.budget_id = hr_api.g_number) then
    p_rec.budget_id :=
    pqh_wks_shd.g_old_rec.budget_id;
  End If;
  If (p_rec.worksheet_name = hr_api.g_varchar2) then
    p_rec.worksheet_name :=
    pqh_wks_shd.g_old_rec.worksheet_name;
  End If;
  If (p_rec.version_number = hr_api.g_number) then
    p_rec.version_number :=
    pqh_wks_shd.g_old_rec.version_number;
  End If;
  If (p_rec.action_date = hr_api.g_date) then
    p_rec.action_date :=
    pqh_wks_shd.g_old_rec.action_date;
  End If;
  If (p_rec.date_from = hr_api.g_date) then
    p_rec.date_from :=
    pqh_wks_shd.g_old_rec.date_from;
  End If;
  If (p_rec.date_to = hr_api.g_date) then
    p_rec.date_to :=
    pqh_wks_shd.g_old_rec.date_to;
  End If;
  If (p_rec.worksheet_mode_cd = hr_api.g_varchar2) then
    p_rec.worksheet_mode_cd :=
    pqh_wks_shd.g_old_rec.worksheet_mode_cd;
  End If;
  If (p_rec.transaction_status = hr_api.g_varchar2) then
    p_rec.transaction_status :=
    pqh_wks_shd.g_old_rec.transaction_status;
  End If;
  If (p_rec.budget_version_id = hr_api.g_number) then
    p_rec.budget_version_id :=
    pqh_wks_shd.g_old_rec.budget_version_id;
  End If;
  If (p_rec.propagation_method = hr_api.g_varchar2) then
    p_rec.propagation_method :=
    pqh_wks_shd.g_old_rec.propagation_method;
  End If;
  If (p_rec.wf_transaction_category_id = hr_api.g_number) then
    p_rec.wf_transaction_category_id :=
    pqh_wks_shd.g_old_rec.wf_transaction_category_id;
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
  p_rec        in out nocopy pqh_wks_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqh_wks_shd.lck
	(
	p_rec.worksheet_id,
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
  pqh_wks_bus.update_validate(p_rec
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
  p_worksheet_id                 in number,
  p_budget_id                    in number           default hr_api.g_number,
  p_worksheet_name               in varchar2         default hr_api.g_varchar2,
  p_version_number               in number           default hr_api.g_number,
  p_action_date                  in date             default hr_api.g_date,
  p_date_from                    in date             default hr_api.g_date,
  p_date_to                      in date             default hr_api.g_date,
  p_worksheet_mode_cd            in varchar2         default hr_api.g_varchar2,
  p_transaction_status                       in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_budget_version_id            in number           default hr_api.g_number,
  p_propagation_method           in varchar2         default hr_api.g_varchar2,
  p_wf_transaction_category_id   in number
  ) is
--
  l_rec	  pqh_wks_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_wks_shd.convert_args
  (
  p_worksheet_id,
  p_budget_id,
  p_worksheet_name,
  p_version_number,
  p_action_date,
  p_date_from,
  p_date_to,
  p_worksheet_mode_cd,
  p_transaction_status,
  p_object_version_number,
  p_budget_version_id,
  p_propagation_method,
  p_wf_transaction_category_id
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
end pqh_wks_upd;

/
