--------------------------------------------------------
--  DDL for Package Body PQH_TCA_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TCA_UPD" as
/* $Header: pqtcarhi.pkb 120.2 2005/10/12 20:19:48 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_tca_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy pqh_tca_shd.g_rec_type) is
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
  -- Update the pqh_txn_category_attributes Row
  --
  update pqh_txn_category_attributes
  set
  txn_category_attribute_id         = p_rec.txn_category_attribute_id,
  attribute_id                      = p_rec.attribute_id,
  transaction_category_id           = p_rec.transaction_category_id,
  value_set_id                      = p_rec.value_set_id,
  object_version_number             = p_rec.object_version_number,
  transaction_table_route_id        = p_rec.transaction_table_route_id,
  form_column_name                  = p_rec.form_column_name,
  identifier_flag                   = p_rec.identifier_flag,
  list_identifying_flag             = p_rec.list_identifying_flag,
  member_identifying_flag           = p_rec.member_identifying_flag,
  refresh_flag                      = p_rec.refresh_flag,
  select_flag                       = p_rec.select_flag,
  value_style_cd                    = p_rec.value_style_cd
  where txn_category_attribute_id = p_rec.txn_category_attribute_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_tca_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_tca_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_tca_shd.constraint_error
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
Procedure pre_update(p_rec in pqh_tca_shd.g_rec_type) is
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
p_effective_date in date,p_rec in pqh_tca_shd.g_rec_type) is
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
    pqh_tca_rku.after_update
      (
  p_txn_category_attribute_id     =>p_rec.txn_category_attribute_id
 ,p_attribute_id                  =>p_rec.attribute_id
 ,p_transaction_category_id       =>p_rec.transaction_category_id
 ,p_value_set_id                  =>p_rec.value_set_id
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_transaction_table_route_id    =>p_rec.transaction_table_route_id
 ,p_form_column_name              =>p_rec.form_column_name
 ,p_identifier_flag               =>p_rec.identifier_flag
 ,p_list_identifying_flag         =>p_rec.list_identifying_flag
 ,p_member_identifying_flag       =>p_rec.member_identifying_flag
 ,p_refresh_flag                  =>p_rec.refresh_flag
 ,p_select_flag                   =>p_rec.select_flag
 ,p_value_style_cd                =>p_rec.value_style_cd
 ,p_effective_date                =>p_effective_date
 ,p_attribute_id_o                =>pqh_tca_shd.g_old_rec.attribute_id
 ,p_transaction_category_id_o     =>pqh_tca_shd.g_old_rec.transaction_category_id
 ,p_value_set_id_o                =>pqh_tca_shd.g_old_rec.value_set_id
 ,p_object_version_number_o       =>pqh_tca_shd.g_old_rec.object_version_number
 ,p_transaction_table_route_id_o  =>pqh_tca_shd.g_old_rec.transaction_table_route_id
 ,p_form_column_name_o            =>pqh_tca_shd.g_old_rec.form_column_name
 ,p_identifier_flag_o             =>pqh_tca_shd.g_old_rec.identifier_flag
 ,p_list_identifying_flag_o       =>pqh_tca_shd.g_old_rec.list_identifying_flag
 ,p_member_identifying_flag_o     =>pqh_tca_shd.g_old_rec.member_identifying_flag
 ,p_refresh_flag_o                =>pqh_tca_shd.g_old_rec.refresh_flag
 ,p_select_flag_o                =>pqh_tca_shd.g_old_rec.select_flag
 ,p_value_style_cd_o              =>pqh_tca_shd.g_old_rec.value_style_cd
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_txn_category_attributes'
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
Procedure convert_defs(p_rec in out nocopy pqh_tca_shd.g_rec_type) is
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
  If (p_rec.attribute_id = hr_api.g_number) then
    p_rec.attribute_id :=
    pqh_tca_shd.g_old_rec.attribute_id;
  End If;
  If (p_rec.transaction_category_id = hr_api.g_number) then
    p_rec.transaction_category_id :=
    pqh_tca_shd.g_old_rec.transaction_category_id;
  End If;
  If (p_rec.value_set_id = hr_api.g_number) then
    p_rec.value_set_id :=
    pqh_tca_shd.g_old_rec.value_set_id;
  End If;
  If (p_rec.transaction_table_route_id = hr_api.g_number) then
    p_rec.transaction_table_route_id :=
    pqh_tca_shd.g_old_rec.transaction_table_route_id;
  End If;
  If (p_rec.form_column_name = hr_api.g_varchar2) then
    p_rec.form_column_name :=
    pqh_tca_shd.g_old_rec.form_column_name;
  End If;
  If (p_rec.identifier_flag = hr_api.g_varchar2) then
    p_rec.identifier_flag :=
    pqh_tca_shd.g_old_rec.identifier_flag;
  End If;
  If (p_rec.list_identifying_flag = hr_api.g_varchar2) then
    p_rec.list_identifying_flag :=
    pqh_tca_shd.g_old_rec.list_identifying_flag;
  End If;
  If (p_rec.member_identifying_flag = hr_api.g_varchar2) then
    p_rec.member_identifying_flag :=
    pqh_tca_shd.g_old_rec.member_identifying_flag;
  End If;
  If (p_rec.refresh_flag = hr_api.g_varchar2) then
    p_rec.refresh_flag :=
    pqh_tca_shd.g_old_rec.refresh_flag;
  End If;
  If (p_rec.select_flag = hr_api.g_varchar2) then
    p_rec.select_flag :=
    pqh_tca_shd.g_old_rec.select_flag;
  End If;
  If (p_rec.value_style_cd = hr_api.g_varchar2) then
    p_rec.value_style_cd :=
    pqh_tca_shd.g_old_rec.value_style_cd;
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
  p_rec        in out nocopy pqh_tca_shd.g_rec_type,
  p_delete_attr_ranges_flag in varchar2
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqh_tca_shd.lck
	(
	p_rec.txn_category_attribute_id,
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
  pqh_tca_bus.update_validate(p_rec
  ,p_effective_date,p_delete_attr_ranges_flag);
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
  p_txn_category_attribute_id    in number,
  p_attribute_id                 in number           default hr_api.g_number,
  p_transaction_category_id      in number           default hr_api.g_number,
  p_value_set_id                 in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_transaction_table_route_id   in number           default hr_api.g_number,
  p_form_column_name             in varchar2         default hr_api.g_varchar2,
  p_identifier_flag              in varchar2         default hr_api.g_varchar2,
  p_list_identifying_flag        in varchar2         default hr_api.g_varchar2,
  p_member_identifying_flag      in varchar2         default hr_api.g_varchar2,
  p_refresh_flag                 in varchar2         default hr_api.g_varchar2,
  p_select_flag                  in varchar2         default hr_api.g_varchar2,
  p_value_style_cd               in varchar2         default hr_api.g_varchar2
  ,p_delete_attr_ranges_flag      in varchar2         default hr_api.g_varchar2
  ) is
--
  l_rec	  pqh_tca_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_tca_shd.convert_args
  (
  p_txn_category_attribute_id,
  p_attribute_id,
  p_transaction_category_id,
  p_value_set_id,
  p_object_version_number,
  p_transaction_table_route_id,
  p_form_column_name,
  p_identifier_flag,
  p_list_identifying_flag,
  p_member_identifying_flag,
  p_refresh_flag,
  p_select_flag,
  p_value_style_cd
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(
    p_effective_date,l_rec,p_delete_attr_ranges_flag);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqh_tca_upd;

/
