--------------------------------------------------------
--  DDL for Package Body GHR_NRE_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_NRE_UPD" as
/* $Header: ghnrerhi.pkb 120.1.12010000.1 2009/03/26 10:13:57 utokachi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_nre_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out NOCOPY ghr_nre_shd.g_rec_type) is
--
  l_proc  varchar2(72);
  l_rec ghr_nre_shd.g_rec_type;
--
Begin
  l_proc := g_package||'update_dml';
  hr_utility.set_location('Entering:'||l_proc, 5);

  l_rec := p_rec;
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  -- Update the ghr_noac_remarks Row
  --
  update ghr_noac_remarks
  set
  noac_remark_id                    = p_rec.noac_remark_id,
  nature_of_action_id               = p_rec.nature_of_action_id,
  remark_id                         = p_rec.remark_id,
  required_flag                     = p_rec.required_flag,
  enabled_flag                      = p_rec.enabled_flag,
  date_from                         = p_rec.date_from,
  date_to                           = p_rec.date_to,
  object_version_number             = p_rec.object_version_number
  where noac_remark_id = p_rec.noac_remark_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    p_rec := l_rec;
    ghr_nre_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    p_rec := l_rec;
    ghr_nre_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    p_rec := l_rec;
    ghr_nre_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    p_rec := l_rec;
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
Procedure pre_update(p_rec in ghr_nre_shd.g_rec_type) is
--
  l_proc  varchar2(72);
--
Begin
  l_proc  := g_package||'pre_update';
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
p_effective_date in date,p_rec in ghr_nre_shd.g_rec_type) is
--
  l_proc  varchar2(72);
--
Begin
  l_proc   := g_package||'post_update';
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    ghr_nre_rku.after_update
      (
  p_noac_remark_id                =>p_rec.noac_remark_id
 ,p_nature_of_action_id           =>p_rec.nature_of_action_id
 ,p_remark_id                     =>p_rec.remark_id
 ,p_required_flag                 =>p_rec.required_flag
 ,p_enabled_flag                  =>p_rec.enabled_flag
 ,p_date_from                     =>p_rec.date_from
 ,p_date_to                       =>p_rec.date_to
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_nature_of_action_id_o         =>ghr_nre_shd.g_old_rec.nature_of_action_id
 ,p_remark_id_o                   =>ghr_nre_shd.g_old_rec.remark_id
 ,p_required_flag_o               =>ghr_nre_shd.g_old_rec.required_flag
 ,p_enabled_flag_o                =>ghr_nre_shd.g_old_rec.enabled_flag
 ,p_date_from_o                   =>ghr_nre_shd.g_old_rec.date_from
 ,p_date_to_o                     =>ghr_nre_shd.g_old_rec.date_to
 ,p_object_version_number_o       =>ghr_nre_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ghr_noac_remarks'
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
Procedure convert_defs(p_rec in out NOCOPY ghr_nre_shd.g_rec_type) is
--
  l_proc  varchar2(72);
  l_rec ghr_nre_shd.g_rec_type;
--
Begin
  --
  l_proc := g_package||'convert_defs';
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_rec := p_rec;
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.nature_of_action_id = hr_api.g_number) then
    p_rec.nature_of_action_id :=
    ghr_nre_shd.g_old_rec.nature_of_action_id;
  End If;
  If (p_rec.remark_id = hr_api.g_number) then
    p_rec.remark_id :=
    ghr_nre_shd.g_old_rec.remark_id;
  End If;
  If (p_rec.required_flag = hr_api.g_varchar2) then
    p_rec.required_flag :=
    ghr_nre_shd.g_old_rec.required_flag;
  End If;
  If (p_rec.enabled_flag = hr_api.g_varchar2) then
    p_rec.enabled_flag :=
    ghr_nre_shd.g_old_rec.enabled_flag;
  End If;
  If (p_rec.date_from = hr_api.g_date) then
    p_rec.date_from :=
    ghr_nre_shd.g_old_rec.date_from;
  End If;
  If (p_rec.date_to = hr_api.g_date) then
    p_rec.date_to :=
    ghr_nre_shd.g_old_rec.date_to;
  End If;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
exception
  when others then
     p_rec := l_rec;
     raise;
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date in date,
  p_rec        in out NOCOPY ghr_nre_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
  l_rec ghr_nre_shd.g_rec_type;
--
Begin
  l_proc  := g_package||'upd';
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_rec := p_rec;
  --
  -- We must lock the row which we need to update.
  --
  ghr_nre_shd.lck
	(
	p_rec.noac_remark_id,
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
  ghr_nre_bus.update_validate(p_rec
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
exception
  when others then
    p_rec := l_rec;
    raise;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date in date,
  p_noac_remark_id               in number,
  p_nature_of_action_id          in number           default hr_api.g_number,
  p_remark_id                    in number           default hr_api.g_number,
  p_required_flag                in varchar2         default hr_api.g_varchar2,
  p_enabled_flag                 in varchar2         default hr_api.g_varchar2,
  p_date_from                    in date             default hr_api.g_date,
  p_date_to                      in date             default hr_api.g_date,
  p_object_version_number        in out NOCOPY number
  ) is
--
  l_rec	  ghr_nre_shd.g_rec_type;
  l_proc  varchar2(72);
  l_object_version_number number;
--
Begin
  l_proc := g_package||'upd';
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_object_version_number := p_object_version_number;
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ghr_nre_shd.convert_args
  (
  p_noac_remark_id,
  p_nature_of_action_id,
  p_remark_id,
  p_required_flag,
  p_enabled_flag,
  p_date_from,
  p_date_to,
  p_object_version_number
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
exception
   when others then
      p_object_version_number := l_object_version_number;
      raise;
End upd;
--
end ghr_nre_upd;

/
