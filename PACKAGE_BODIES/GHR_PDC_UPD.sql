--------------------------------------------------------
--  DDL for Package Body GHR_PDC_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PDC_UPD" as
/* $Header: ghpdcrhi.pkb 120.0.12010000.3 2009/05/27 05:40:10 utokachi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_pdc_upd.';  -- Global package name
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
--   A Pl/Sql record structure.
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
Procedure update_dml(p_rec in out NOCOPY ghr_pdc_shd.g_rec_type) is
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
  --ghr_pdc_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ghr_pd_classifications Row
  --
  update ghr_pd_classifications
  set
  class_grade_by                    = p_rec.class_grade_by,
  official_title                    = p_rec.official_title,
  pay_plan                          = p_rec.pay_plan,
  occupational_code                 = p_rec.occupational_code,
  grade_level                       = p_rec.grade_level,
  object_version_number             = p_rec.object_version_number
  where pd_classification_id = p_rec.pd_classification_id;
  --
  --ghr_pdc_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --ghr_pdc_shd.g_api_dml := false;   -- Unset the api dml status
    ghr_pdc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --ghr_pdc_shd.g_api_dml := false;   -- Unset the api dml status
    ghr_pdc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --ghr_pdc_shd.g_api_dml := false;   -- Unset the api dml status
    ghr_pdc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --ghr_pdc_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in ghr_pdc_shd.g_rec_type) is
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
Procedure post_update(p_rec in ghr_pdc_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_update is called here.
  --
  begin
     ghr_pdc_rku.after_update	(
      p_pd_classification_id      =>     p_rec.pd_classification_id,
      p_position_description_id   =>     p_rec.position_description_id,
      p_class_grade_by            =>     p_rec.class_grade_by,
      p_official_title            =>     p_rec.official_title,
      p_pay_plan                  =>     p_rec.pay_plan,
      p_occupational_code         =>     p_rec.occupational_code,
      p_grade_level               =>     p_rec.grade_level,
      p_object_version_number     =>     p_rec.object_version_number,
      p_position_description_id_o =>     ghr_pdc_shd.g_old_rec.position_description_id,
      p_class_grade_by_o          =>     ghr_pdc_shd.g_old_rec.class_grade_by,
      p_official_title_o          =>     ghr_pdc_shd.g_old_rec.official_title,
      p_pay_plan_o                =>     ghr_pdc_shd.g_old_rec.pay_plan,
      p_occupational_code_o       =>     ghr_pdc_shd.g_old_rec.occupational_code,
      p_grade_level_o             =>     ghr_pdc_shd.g_old_rec.grade_level,
      p_object_version_number_o   =>     ghr_pdc_shd.g_old_rec.object_version_number
      );

  exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	 p_module_name => 'GHR_PD_CLASSIFICATIONS'
			,p_hook_type   => 'AU'
	        );
  end;
  -- End of API User Hook for post_update.
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
Procedure convert_defs(p_rec in out NOCOPY ghr_pdc_shd.g_rec_type) is
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
  If (p_rec.position_description_id = hr_api.g_number) then
    p_rec.position_description_id :=
    ghr_pdc_shd.g_old_rec.position_description_id;
  End If;
  If (p_rec.class_grade_by = hr_api.g_varchar2) then
    p_rec.class_grade_by :=
    ghr_pdc_shd.g_old_rec.class_grade_by;
  End If;
  If (p_rec.official_title = hr_api.g_varchar2) then
    p_rec.official_title :=
    ghr_pdc_shd.g_old_rec.official_title;
  End If;
  If (p_rec.pay_plan = hr_api.g_varchar2) then
    p_rec.pay_plan :=
    ghr_pdc_shd.g_old_rec.pay_plan;
  End If;
  If (p_rec.occupational_code = hr_api.g_varchar2) then
    p_rec.occupational_code :=
    ghr_pdc_shd.g_old_rec.occupational_code;
  End If;
  If (p_rec.grade_level = hr_api.g_varchar2) then
    p_rec.grade_level :=
    ghr_pdc_shd.g_old_rec.grade_level;
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
  p_rec        in out NOCOPY ghr_pdc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ghr_pdc_shd.lck
	(
	p_rec.pd_classification_id,
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
  ghr_pdc_bus.update_validate(p_rec);
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
  p_pd_classification_id         in number,
  p_position_description_id      in number           default hr_api.g_number,
  p_class_grade_by               in varchar2         default hr_api.g_varchar2,
  p_official_title               in varchar2         default hr_api.g_varchar2,
  p_pay_plan                     in varchar2         default hr_api.g_varchar2,
  p_occupational_code            in varchar2         default hr_api.g_varchar2,
  p_grade_level                  in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out NOCOPY number
  ) is
--
  l_rec	  ghr_pdc_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('pdc id:' || to_char(p_pd_classification_id) ||l_proc, 5);
  hr_utility.set_location('pd id:' || to_char(p_position_description_id)||l_proc, 5);
  hr_utility.set_location('ovn :' || to_char(p_position_description_id)||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ghr_pdc_shd.convert_args
  (
  p_pd_classification_id,
  p_position_description_id,
  p_class_grade_by,
  p_official_title,
  p_pay_plan,
  p_occupational_code,
  p_grade_level,
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
end ghr_pdc_upd;

/
