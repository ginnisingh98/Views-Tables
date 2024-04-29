--------------------------------------------------------
--  DDL for Package Body PQH_WFS_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_WFS_UPD" as
/* $Header: pqwfsrhi.pkb 115.7 2003/04/02 20:02:19 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_wfs_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy pqh_wfs_shd.g_rec_type) is
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
  -- Update the pqh_worksheet_fund_srcs Row
  --
  update pqh_worksheet_fund_srcs
  set
  worksheet_fund_src_id             = p_rec.worksheet_fund_src_id,
  worksheet_bdgt_elmnt_id           = p_rec.worksheet_bdgt_elmnt_id,
  distribution_percentage           = p_rec.distribution_percentage,
  cost_allocation_keyflex_id        = p_rec.cost_allocation_keyflex_id,
  project_id                        = p_rec.project_id ,
  award_id                          = p_rec.award_id ,
  task_id                           = p_rec.task_id ,
  expenditure_type                  = p_rec.expenditure_type ,
  organization_id                   = p_rec.organization_id ,
  object_version_number             = p_rec.object_version_number
  where worksheet_fund_src_id = p_rec.worksheet_fund_src_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_wfs_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_wfs_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_wfs_shd.constraint_error
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
Procedure pre_update(p_rec in pqh_wfs_shd.g_rec_type) is
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
Procedure post_update(p_rec in pqh_wfs_shd.g_rec_type) is
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
    pqh_wfs_rku.after_update
      (
  p_worksheet_fund_src_id         =>p_rec.worksheet_fund_src_id
 ,p_worksheet_bdgt_elmnt_id       =>p_rec.worksheet_bdgt_elmnt_id
 ,p_distribution_percentage       =>p_rec.distribution_percentage
 ,p_cost_allocation_keyflex_id    =>p_rec.cost_allocation_keyflex_id
 ,p_project_id                    =>p_rec.project_id
 ,p_award_id                      =>p_rec.award_id
 ,p_task_id                       =>p_rec.task_id
 ,p_expenditure_type              =>p_rec.expenditure_type
 ,p_organization_id               =>p_rec.organization_id
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_worksheet_bdgt_elmnt_id_o     =>pqh_wfs_shd.g_old_rec.worksheet_bdgt_elmnt_id
 ,p_distribution_percentage_o     =>pqh_wfs_shd.g_old_rec.distribution_percentage
 ,p_cost_allocation_keyflex_id_o  =>pqh_wfs_shd.g_old_rec.cost_allocation_keyflex_id
 ,p_project_id_o                  =>pqh_wfs_shd.g_old_rec.project_id
 ,p_award_id_o                    =>pqh_wfs_shd.g_old_rec.award_id
 ,p_task_id_o                     =>pqh_wfs_shd.g_old_rec.task_id
 ,p_expenditure_type_o            =>pqh_wfs_shd.g_old_rec.expenditure_type
 ,p_organization_id_o             =>pqh_wfs_shd.g_old_rec.organization_id
 ,p_object_version_number_o       =>pqh_wfs_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_worksheet_fund_srcs'
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
Procedure convert_defs(p_rec in out nocopy pqh_wfs_shd.g_rec_type) is
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
  If (p_rec.worksheet_bdgt_elmnt_id = hr_api.g_number) then
    p_rec.worksheet_bdgt_elmnt_id :=
    pqh_wfs_shd.g_old_rec.worksheet_bdgt_elmnt_id;
  End If;
  If (p_rec.distribution_percentage = hr_api.g_number) then
    p_rec.distribution_percentage :=
    pqh_wfs_shd.g_old_rec.distribution_percentage;
  End If;
  If (p_rec.cost_allocation_keyflex_id = hr_api.g_number) then
    p_rec.cost_allocation_keyflex_id :=
    pqh_wfs_shd.g_old_rec.cost_allocation_keyflex_id;
  End If;
  If (p_rec.project_id = hr_api.g_number) then
    p_rec.project_id :=
    pqh_wfs_shd.g_old_rec.project_id;
  End If;
  If (p_rec.award_id = hr_api.g_number) then
    p_rec.award_id :=
    pqh_wfs_shd.g_old_rec.award_id;
  End If;
  If (p_rec.task_id = hr_api.g_number) then
    p_rec.task_id :=
    pqh_wfs_shd.g_old_rec.task_id;
  End If;
  If (p_rec.expenditure_type = hr_api.g_varchar2) then
    p_rec.expenditure_type :=
    pqh_wfs_shd.g_old_rec.expenditure_type;
  End If;
  If (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    pqh_wfs_shd.g_old_rec.organization_id;
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
  p_rec        in out nocopy pqh_wfs_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqh_wfs_shd.lck
	(
	p_rec.worksheet_fund_src_id,
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
  pqh_wfs_bus.update_validate(p_rec);
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
  post_update(p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_worksheet_fund_src_id        in number,
  p_worksheet_bdgt_elmnt_id      in number           default hr_api.g_number,
  p_distribution_percentage      in number           default hr_api.g_number,
  p_cost_allocation_keyflex_id   in number           default hr_api.g_number,
  p_project_id                   in number           default hr_api.g_number,
  p_award_id                     in number           default hr_api.g_number,
  p_task_id                      in number           default hr_api.g_number,
  p_expenditure_type             in varchar2         default hr_api.g_varchar2,
  p_organization_id              in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number
  ) is
--
  l_rec	  pqh_wfs_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_wfs_shd.convert_args
  (
  p_worksheet_fund_src_id,
  p_worksheet_bdgt_elmnt_id,
  p_distribution_percentage,
  p_cost_allocation_keyflex_id,
  p_project_id,
  p_award_id,
  p_task_id,
  p_expenditure_type,
  p_organization_id,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqh_wfs_upd;

/
