--------------------------------------------------------
--  DDL for Package Body PQH_BGT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BGT_UPD" as
/* $Header: pqbgtrhi.pkb 120.1 2005/09/21 03:11:10 hmehta noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_bgt_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy pqh_bgt_shd.g_rec_type) is
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
  -- Update the pqh_budgets Row
  --
  update pqh_budgets
  set
  budget_id                         = p_rec.budget_id,
  business_group_id                 = p_rec.business_group_id,
  start_organization_id             = p_rec.start_organization_id,
  org_structure_version_id          = p_rec.org_structure_version_id,
  budgeted_entity_cd                = p_rec.budgeted_entity_cd,
  budget_style_cd                   = p_rec.budget_style_cd,
  budget_name                       = p_rec.budget_name,
  period_set_name                   = p_rec.period_set_name,
  budget_start_date                 = p_rec.budget_start_date,
  budget_end_date                   = p_rec.budget_end_date,
  gl_budget_name                    = p_rec.gl_budget_name,
  psb_budget_flag                   = p_rec.psb_budget_flag,
  transfer_to_gl_flag               = p_rec.transfer_to_gl_flag,
  transfer_to_grants_flag           = p_rec.transfer_to_grants_flag,
  status                            = p_rec.status,
  object_version_number             = p_rec.object_version_number,
  budget_unit1_id                   = p_rec.budget_unit1_id,
  budget_unit2_id                   = p_rec.budget_unit2_id,
  budget_unit3_id                   = p_rec.budget_unit3_id,
  gl_set_of_books_id                = p_rec.gl_set_of_books_id,
  budget_unit1_aggregate            = p_rec.budget_unit1_aggregate,
  budget_unit2_aggregate            = p_rec.budget_unit2_aggregate,
  budget_unit3_aggregate            = p_rec.budget_unit3_aggregate,
  position_control_flag             = p_rec.position_control_flag ,
  valid_grade_reqd_flag             = p_rec.valid_grade_reqd_flag ,
  currency_code                     = p_rec.currency_code,
  dflt_budget_set_id                = p_rec.dflt_budget_set_id
  where budget_id = p_rec.budget_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_bgt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_bgt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_bgt_shd.constraint_error
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
Procedure pre_update(p_rec in pqh_bgt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
 l_budgets_rec   pqh_budgets%ROWTYPE;
--
 cursor csr_budget(p_budget_id IN number) is
 select *
 from pqh_budgets
 where budget_id = p_budget_id;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
/*
    --
      OPEN csr_budget(p_budget_id =>  p_rec.budget_id);
        FETCH csr_budget INTO l_budgets_rec;
      CLOSE csr_budget;


  hr_utility.set_location('Transfer to GL :'||l_budgets_rec.transfer_to_gl_flag, 6);

       IF NVL(l_budgets_rec.transfer_to_gl_flag,'N') = 'N' THEN
         -- delete from pqh_budget_gl_flex_maps
            delete from pqh_budget_gl_flex_maps
            where budget_id = l_budgets_rec.budget_id;
         --
       END IF;

*/

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
p_effective_date in date,p_rec in pqh_bgt_shd.g_rec_type) is
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
    pqh_bgt_rku.after_update
      (
  p_budget_id                     =>p_rec.budget_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_start_organization_id         =>p_rec.start_organization_id
 ,p_org_structure_version_id      =>p_rec.org_structure_version_id
 ,p_budgeted_entity_cd            =>p_rec.budgeted_entity_cd
 ,p_budget_style_cd               =>p_rec.budget_style_cd
 ,p_budget_name                   =>p_rec.budget_name
 ,p_period_set_name               =>p_rec.period_set_name
 ,p_budget_start_date             =>p_rec.budget_start_date
 ,p_budget_end_date               =>p_rec.budget_end_date
 ,p_gl_budget_name                =>p_rec.gl_budget_name
 ,p_psb_budget_flag               =>p_rec.psb_budget_flag
 ,p_transfer_to_gl_flag           =>p_rec.transfer_to_gl_flag
 ,p_transfer_to_grants_flag       =>p_rec.transfer_to_grants_flag
 ,p_status                        =>p_rec.status
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_budget_unit1_id               =>p_rec.budget_unit1_id
 ,p_budget_unit2_id               =>p_rec.budget_unit2_id
 ,p_budget_unit3_id               =>p_rec.budget_unit3_id
 ,p_gl_set_of_books_id            =>p_rec.gl_set_of_books_id
 ,p_budget_unit1_aggregate        =>p_rec.budget_unit1_aggregate
 ,p_budget_unit2_aggregate        =>p_rec.budget_unit2_aggregate
 ,p_budget_unit3_aggregate        =>p_rec.budget_unit3_aggregate
 ,p_position_control_flag         =>p_rec.position_control_flag
 ,p_valid_grade_reqd_flag         =>p_rec.valid_grade_reqd_flag
 ,p_currency_code                 =>p_rec.currency_code
 ,p_dflt_budget_set_id            =>p_rec.dflt_budget_set_id
 ,p_effective_date                =>p_effective_date
 ,p_business_group_id_o           =>pqh_bgt_shd.g_old_rec.business_group_id
 ,p_start_organization_id_o       =>pqh_bgt_shd.g_old_rec.start_organization_id
 ,p_org_structure_version_id_o    =>pqh_bgt_shd.g_old_rec.org_structure_version_id
 ,p_budgeted_entity_cd_o          =>pqh_bgt_shd.g_old_rec.budgeted_entity_cd
 ,p_budget_style_cd_o             =>pqh_bgt_shd.g_old_rec.budget_style_cd
 ,p_budget_name_o                 =>pqh_bgt_shd.g_old_rec.budget_name
 ,p_period_set_name_o             =>pqh_bgt_shd.g_old_rec.period_set_name
 ,p_budget_start_date_o           =>pqh_bgt_shd.g_old_rec.budget_start_date
 ,p_budget_end_date_o             =>pqh_bgt_shd.g_old_rec.budget_end_date
 ,p_gl_budget_name_o              =>pqh_bgt_shd.g_old_rec.gl_budget_name
 ,p_psb_budget_flag_o             =>pqh_bgt_shd.g_old_rec.psb_budget_flag
 ,p_transfer_to_gl_flag_o         =>pqh_bgt_shd.g_old_rec.transfer_to_gl_flag
 ,p_transfer_to_grants_flag_o     =>pqh_bgt_shd.g_old_rec.transfer_to_grants_flag
 ,p_status_o                      =>pqh_bgt_shd.g_old_rec.status
 ,p_object_version_number_o       =>pqh_bgt_shd.g_old_rec.object_version_number
 ,p_budget_unit1_id_o             =>pqh_bgt_shd.g_old_rec.budget_unit1_id
 ,p_budget_unit2_id_o             =>pqh_bgt_shd.g_old_rec.budget_unit2_id
 ,p_budget_unit3_id_o             =>pqh_bgt_shd.g_old_rec.budget_unit3_id
 ,p_gl_set_of_books_id_o          =>pqh_bgt_shd.g_old_rec.gl_set_of_books_id
 ,p_budget_unit1_aggregate_o      =>pqh_bgt_shd.g_old_rec.budget_unit1_aggregate
 ,p_budget_unit2_aggregate_o      =>pqh_bgt_shd.g_old_rec.budget_unit2_aggregate
 ,p_budget_unit3_aggregate_o      =>pqh_bgt_shd.g_old_rec.budget_unit3_aggregate
 ,p_position_control_flag_o       =>pqh_bgt_shd.g_old_rec.position_control_flag
 ,p_valid_grade_reqd_flag_o       =>pqh_bgt_shd.g_old_rec.valid_grade_reqd_flag
 ,p_currency_code_o               =>pqh_bgt_shd.g_old_rec.currency_code
 ,p_dflt_budget_set_id_o          =>pqh_bgt_shd.g_old_rec.dflt_budget_set_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_budgets'
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
Procedure convert_defs(p_rec in out nocopy pqh_bgt_shd.g_rec_type) is
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
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pqh_bgt_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.start_organization_id = hr_api.g_number) then
    p_rec.start_organization_id :=
    pqh_bgt_shd.g_old_rec.start_organization_id;
  End If;
  If (p_rec.org_structure_version_id = hr_api.g_number) then
    p_rec.org_structure_version_id :=
    pqh_bgt_shd.g_old_rec.org_structure_version_id;
  End If;
  If (p_rec.budgeted_entity_cd = hr_api.g_varchar2) then
    p_rec.budgeted_entity_cd :=
    pqh_bgt_shd.g_old_rec.budgeted_entity_cd;
  End If;
  If (p_rec.budget_style_cd = hr_api.g_varchar2) then
    p_rec.budget_style_cd :=
    pqh_bgt_shd.g_old_rec.budget_style_cd;
  End If;
  If (p_rec.budget_name = hr_api.g_varchar2) then
    p_rec.budget_name :=
    pqh_bgt_shd.g_old_rec.budget_name;
  End If;
  If (p_rec.period_set_name = hr_api.g_varchar2) then
    p_rec.period_set_name :=
    pqh_bgt_shd.g_old_rec.period_set_name;
  End If;
  If (p_rec.budget_start_date = hr_api.g_date) then
    p_rec.budget_start_date :=
    pqh_bgt_shd.g_old_rec.budget_start_date;
  End If;
  If (p_rec.budget_end_date = hr_api.g_date) then
    p_rec.budget_end_date :=
    pqh_bgt_shd.g_old_rec.budget_end_date;
  End If;
  If (p_rec.gl_budget_name = hr_api.g_varchar2) then
    p_rec.gl_budget_name :=
    pqh_bgt_shd.g_old_rec.gl_budget_name;
  End If;
  If (p_rec.psb_budget_flag = hr_api.g_varchar2) then
      p_rec.psb_budget_flag :=
      pqh_bgt_shd.g_old_rec.psb_budget_flag;
  End If;
  If (p_rec.transfer_to_gl_flag = hr_api.g_varchar2) then
    p_rec.transfer_to_gl_flag :=
    pqh_bgt_shd.g_old_rec.transfer_to_gl_flag;
  End If;
  If (p_rec.transfer_to_grants_flag = hr_api.g_varchar2) then
    p_rec.transfer_to_grants_flag :=
    pqh_bgt_shd.g_old_rec.transfer_to_grants_flag;
  End If;
  If (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    pqh_bgt_shd.g_old_rec.status;
  End If;
  If (p_rec.budget_unit1_id = hr_api.g_number) then
    p_rec.budget_unit1_id :=
    pqh_bgt_shd.g_old_rec.budget_unit1_id;
  End If;
  If (p_rec.budget_unit2_id = hr_api.g_number) then
    p_rec.budget_unit2_id :=
    pqh_bgt_shd.g_old_rec.budget_unit2_id;
  End If;
  If (p_rec.budget_unit3_id = hr_api.g_number) then
    p_rec.budget_unit3_id :=
    pqh_bgt_shd.g_old_rec.budget_unit3_id;
  End If;
  If (p_rec.gl_set_of_books_id = hr_api.g_number) then
    p_rec.gl_set_of_books_id :=
    pqh_bgt_shd.g_old_rec.gl_set_of_books_id;
  End If;
  If (p_rec.budget_unit1_aggregate = hr_api.g_varchar2) then
    p_rec.budget_unit1_aggregate :=
    pqh_bgt_shd.g_old_rec.budget_unit1_aggregate;
  End If;
  If (p_rec.budget_unit2_aggregate = hr_api.g_varchar2) then
    p_rec.budget_unit2_aggregate :=
    pqh_bgt_shd.g_old_rec.budget_unit2_aggregate;
  End If;
  If (p_rec.budget_unit3_aggregate = hr_api.g_varchar2) then
    p_rec.budget_unit3_aggregate :=
    pqh_bgt_shd.g_old_rec.budget_unit3_aggregate;
  End If;
  If (p_rec.position_control_flag = hr_api.g_varchar2) then
    p_rec.position_control_flag :=
    pqh_bgt_shd.g_old_rec.position_control_flag;
  End If;
  If (p_rec.valid_grade_reqd_flag = hr_api.g_varchar2) then
    p_rec.valid_grade_reqd_flag :=
    pqh_bgt_shd.g_old_rec.valid_grade_reqd_flag;
  End If;
  If (p_rec.currency_code = hr_api.g_varchar2) then
    p_rec.currency_code :=
    pqh_bgt_shd.g_old_rec.currency_code;
  End If;
  If (p_rec.dflt_budget_set_id = hr_api.g_number) then
    p_rec.dflt_budget_set_id :=
    pqh_bgt_shd.g_old_rec.dflt_budget_set_id;
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
  p_rec        in out nocopy pqh_bgt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqh_bgt_shd.lck
	(
	p_rec.budget_id,
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
  pqh_bgt_bus.update_validate(p_rec
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
  p_budget_id                    in number,
  p_business_group_id            in number           default hr_api.g_number,
  p_start_organization_id        in number           default hr_api.g_number,
  p_org_structure_version_id     in number           default hr_api.g_number,
  p_budgeted_entity_cd           in varchar2         default hr_api.g_varchar2,
  p_budget_style_cd              in varchar2         default hr_api.g_varchar2,
  p_budget_name                  in varchar2         default hr_api.g_varchar2,
  p_period_set_name              in varchar2         default hr_api.g_varchar2,
  p_budget_start_date            in date             default hr_api.g_date,
  p_budget_end_date              in date             default hr_api.g_date,
  p_gl_budget_name               in varchar2         default hr_api.g_varchar2,
  p_psb_budget_flag              in varchar2         default hr_api.g_varchar2,
  p_transfer_to_gl_flag          in varchar2         default hr_api.g_varchar2,
  p_transfer_to_grants_flag      in varchar2         default hr_api.g_varchar2,
  p_status                       in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_budget_unit1_id              in number           default hr_api.g_number,
  p_budget_unit2_id              in number           default hr_api.g_number,
  p_budget_unit3_id              in number           default hr_api.g_number,
  p_gl_set_of_books_id           in number           default hr_api.g_number,
  p_budget_unit1_aggregate       in varchar2         default hr_api.g_varchar2,
  p_budget_unit2_aggregate       in varchar2         default hr_api.g_varchar2,
  p_budget_unit3_aggregate       in varchar2         default hr_api.g_varchar2,
  p_position_control_flag        in varchar2         default hr_api.g_varchar2,
  p_valid_grade_reqd_flag        in varchar2         default hr_api.g_varchar2,
  p_currency_code                in varchar2         default hr_api.g_varchar2,
  p_dflt_budget_set_id           in number           default hr_api.g_number
  ) is
--
  l_rec	  pqh_bgt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_bgt_shd.convert_args
  (
  p_budget_id,
  p_business_group_id,
  p_start_organization_id,
  p_org_structure_version_id,
  p_budgeted_entity_cd,
  p_budget_style_cd,
  p_budget_name,
  p_period_set_name,
  p_budget_start_date,
  p_budget_end_date,
  p_gl_budget_name,
  p_psb_budget_flag,
  p_transfer_to_gl_flag,
  p_transfer_to_grants_flag,
  p_status,
  p_object_version_number,
  p_budget_unit1_id,
  p_budget_unit2_id,
  p_budget_unit3_id,
  p_gl_set_of_books_id,
  p_budget_unit1_aggregate,
  p_budget_unit2_aggregate,
  p_budget_unit3_aggregate,
  p_position_control_flag,
  p_valid_grade_reqd_flag     ,
  p_currency_code,
  p_dflt_budget_set_id
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
end pqh_bgt_upd;

/
