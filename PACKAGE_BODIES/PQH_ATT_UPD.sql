--------------------------------------------------------
--  DDL for Package Body PQH_ATT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ATT_UPD" as
/* $Header: pqattrhi.pkb 120.3.12000000.2 2007/04/19 12:37:00 brsinha noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_att_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy pqh_att_shd.g_rec_type) is
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
  -- Update the pqh_attributes Row
  --
  update pqh_attributes
  set
  attribute_id                      = p_rec.attribute_id,
  attribute_name                    = p_rec.attribute_name,
  master_attribute_id               = p_rec.master_attribute_id,
  master_table_route_id             = p_rec.master_table_route_id,
  column_name                       = p_rec.column_name,
  column_type                       = p_rec.column_type,
  enable_flag                       = p_rec.enable_flag,
  width                             = p_rec.width,
  object_version_number             = p_rec.object_version_number,
  region_itemname                   = p_rec.region_itemname,
  attribute_itemname                = p_rec.attribute_itemname,
  decode_function_name              = p_rec.decode_function_name
  where attribute_id = p_rec.attribute_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_att_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_att_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_att_shd.constraint_error
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
Procedure pre_update(p_rec in pqh_att_shd.g_rec_type) is
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
p_effective_date in date,p_rec in pqh_att_shd.g_rec_type) is
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
    pqh_att_rku.after_update
      (
  p_attribute_id                  =>p_rec.attribute_id
 ,p_attribute_name                =>p_rec.attribute_name
 ,p_master_attribute_id           =>p_rec.master_attribute_id
 ,p_master_table_route_id         =>p_rec.master_table_route_id
 ,p_column_name                   =>p_rec.column_name
 ,p_column_type                   =>p_rec.column_type
 ,p_enable_flag                   =>p_rec.enable_flag
 ,p_width                         =>p_rec.width
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_region_itemname               =>p_rec.region_itemname
 ,p_attribute_itemname            =>p_rec.attribute_itemname
 ,p_decode_function_name          =>p_rec.decode_function_name
 ,p_attribute_name_o              =>pqh_att_shd.g_old_rec.attribute_name
 ,p_master_attribute_id_o         =>pqh_att_shd.g_old_rec.master_attribute_id
 ,p_master_table_route_id_o       =>pqh_att_shd.g_old_rec.master_table_route_id
 ,p_column_name_o                 =>pqh_att_shd.g_old_rec.column_name
 ,p_column_type_o                 =>pqh_att_shd.g_old_rec.column_type
 ,p_enable_flag_o                 =>pqh_att_shd.g_old_rec.enable_flag
 ,p_width_o                       =>pqh_att_shd.g_old_rec.width
 ,p_object_version_number_o       =>pqh_att_shd.g_old_rec.object_version_number
 ,p_region_itemname_o             =>pqh_att_shd.g_old_rec.region_itemname
 ,p_attribute_itemname_o          =>pqh_att_shd.g_old_rec.attribute_itemname
 ,p_decode_function_name_o        =>pqh_att_shd.g_old_rec.decode_function_name
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_attributes'
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
Procedure convert_defs(p_rec in out nocopy pqh_att_shd.g_rec_type) is
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
  If (p_rec.attribute_name = hr_api.g_varchar2) then
    p_rec.attribute_name :=
    pqh_att_shd.g_old_rec.attribute_name;
  End If;
  If (p_rec.master_attribute_id = hr_api.g_number) then
    p_rec.master_attribute_id :=
    pqh_att_shd.g_old_rec.master_attribute_id;
  End If;
  If (p_rec.master_table_route_id = hr_api.g_number) then
    p_rec.master_table_route_id :=
    pqh_att_shd.g_old_rec.master_table_route_id;
  End If;
  If (p_rec.column_name = hr_api.g_varchar2) then
    p_rec.column_name := pqh_att_shd.g_old_rec.column_name;
  End If;
  If (p_rec.column_type = hr_api.g_varchar2) then
    p_rec.column_type := pqh_att_shd.g_old_rec.column_type;
  End If;
  If (p_rec.enable_flag = hr_api.g_varchar2) then
    p_rec.enable_flag := pqh_att_shd.g_old_rec.enable_flag;
  End If;
  If (p_rec.width = hr_api.g_number) then
    p_rec.width := pqh_att_shd.g_old_rec.width;
  End If;
  If (p_rec.region_itemname = hr_api.g_varchar2) then
    p_rec.region_itemname := pqh_att_shd.g_old_rec.region_itemname;
  End If;
  If (p_rec.attribute_itemname = hr_api.g_varchar2) then
    p_rec.attribute_itemname := pqh_att_shd.g_old_rec.attribute_itemname;
  End If;
  If (p_rec.decode_function_name = hr_api.g_varchar2) then
    p_rec.decode_function_name := pqh_att_shd.g_old_rec.decode_function_name;
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
  p_rec        in out nocopy pqh_att_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqh_att_shd.lck
	(
	p_rec.attribute_id,
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
  pqh_att_bus.update_validate(p_rec
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
  p_attribute_id                 in number,
  p_attribute_name               in varchar2         default hr_api.g_varchar2,
  p_master_attribute_id          in number           default hr_api.g_number,
  p_master_table_route_id        in number           default hr_api.g_number,
  p_column_name                  in varchar2         default hr_api.g_varchar2,
  p_column_type                  in varchar2         default hr_api.g_varchar2,
  p_enable_flag                  in varchar2         default hr_api.g_varchar2,
  p_width                        in number           default hr_api.g_number,
  p_object_version_number        in out nocopy       number,
  p_region_itemname              in varchar2         default hr_api.g_varchar2,
  p_attribute_itemname           in varchar2         default hr_api.g_varchar2,
  p_decode_function_name         in varchar2         default hr_api.g_varchar2
  ) is
--
  l_rec	  pqh_att_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_att_shd.convert_args
  (
  p_attribute_id,
  p_attribute_name,
  p_master_attribute_id,
  p_master_table_route_id,
  p_column_name,
  p_column_type,
  p_enable_flag,
  p_width,
  p_object_version_number,
  p_region_itemname,
  p_attribute_itemname,
  p_decode_function_name
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
end pqh_att_upd;

/
