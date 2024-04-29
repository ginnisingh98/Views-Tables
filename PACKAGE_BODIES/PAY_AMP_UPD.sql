--------------------------------------------------------
--  DDL for Package Body PAY_AMP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AMP_UPD" as
/* $Header: pyamprhi.pkb 120.0.12000000.1 2007/01/17 15:29:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33);  -- Global package name
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
  (p_rec in out nocopy pay_amp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  l_proc  := g_package||'update_dml';
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  pay_amp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the pay_au_module_parameters Row
  --
  update pay_au_module_parameters
    set
     module_parameter_id             = p_rec.module_parameter_id
    ,module_id                       = p_rec.module_id
    ,internal_name                   = p_rec.internal_name
    ,data_type                       = p_rec.data_type
    ,input_flag                      = p_rec.input_flag
    ,context_flag                    = p_rec.context_flag
    ,output_flag                     = p_rec.output_flag
    ,result_flag                     = p_rec.result_flag
    ,error_message_flag              = p_rec.error_message_flag
    ,function_return_flag            = p_rec.function_return_flag
    ,enabled_flag                    = p_rec.enabled_flag
    ,external_name                   = p_rec.external_name
    ,database_item_name              = p_rec.database_item_name
    ,constant_value                  = p_rec.constant_value
    ,object_version_number           = p_rec.object_version_number
    where module_parameter_id = p_rec.module_parameter_id;
  --
  pay_amp_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_amp_shd.g_api_dml := false;   -- Unset the api dml status
    pay_amp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_amp_shd.g_api_dml := false;   -- Unset the api dml status
    pay_amp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_amp_shd.g_api_dml := false;   -- Unset the api dml status
    pay_amp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_amp_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in pay_amp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  l_proc := g_package||'pre_update';
  --
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
  (p_rec                          in pay_amp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  l_proc  := g_package||'post_update';
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
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
  (p_rec in out nocopy pay_amp_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.module_id = hr_api.g_number) then
    p_rec.module_id :=
    pay_amp_shd.g_old_rec.module_id;
  End If;
  If (p_rec.internal_name = hr_api.g_varchar2) then
    p_rec.internal_name :=
    pay_amp_shd.g_old_rec.internal_name;
  End If;
  If (p_rec.data_type = hr_api.g_varchar2) then
    p_rec.data_type :=
    pay_amp_shd.g_old_rec.data_type;
  End If;
  If (p_rec.input_flag = hr_api.g_varchar2) then
    p_rec.input_flag :=
    pay_amp_shd.g_old_rec.input_flag;
  End If;
  If (p_rec.context_flag = hr_api.g_varchar2) then
    p_rec.context_flag :=
    pay_amp_shd.g_old_rec.context_flag;
  End If;
  If (p_rec.output_flag = hr_api.g_varchar2) then
    p_rec.output_flag :=
    pay_amp_shd.g_old_rec.output_flag;
  End If;
  If (p_rec.result_flag = hr_api.g_varchar2) then
    p_rec.result_flag :=
    pay_amp_shd.g_old_rec.result_flag;
  End If;
  If (p_rec.error_message_flag = hr_api.g_varchar2) then
    p_rec.error_message_flag :=
    pay_amp_shd.g_old_rec.error_message_flag;
  End If;
  If (p_rec.function_return_flag = hr_api.g_varchar2) then
    p_rec.function_return_flag :=
    pay_amp_shd.g_old_rec.function_return_flag;
  End If;
  If (p_rec.enabled_flag = hr_api.g_varchar2) then
    p_rec.enabled_flag :=
    pay_amp_shd.g_old_rec.enabled_flag;
  End If;
  If (p_rec.external_name = hr_api.g_varchar2) then
    p_rec.external_name :=
    pay_amp_shd.g_old_rec.external_name;
  End If;
  If (p_rec.database_item_name = hr_api.g_varchar2) then
    p_rec.database_item_name :=
    pay_amp_shd.g_old_rec.database_item_name;
  End If;
  If (p_rec.constant_value = hr_api.g_varchar2) then
    p_rec.constant_value :=
    pay_amp_shd.g_old_rec.constant_value;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy pay_amp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  l_proc  := g_package||'upd';
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pay_amp_shd.lck
    (p_rec.module_parameter_id
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
  pay_amp_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pay_amp_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pay_amp_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pay_amp_upd.post_update
     (p_rec
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
  (p_module_parameter_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_module_id                    in     number
  ,p_internal_name                in     varchar2
  ,p_data_type                    in     varchar2
  ,p_input_flag                   in     varchar2
  ,p_context_flag                 in     varchar2
  ,p_output_flag                  in     varchar2
  ,p_result_flag                  in     varchar2
  ,p_error_message_flag           in     varchar2
  ,p_function_return_flag         in     varchar2
  ,p_enabled_flag                 in     varchar2
  ,p_external_name                in     varchar2
  ,p_database_item_name           in     varchar2
  ,p_constant_value               in     varchar2
  ) is
--
  l_rec   pay_amp_shd.g_rec_type;
  l_proc  varchar2(72);
--
Begin
  l_proc  := g_package||'upd';
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_amp_shd.convert_args
  (p_module_parameter_id
  ,p_module_id
  ,p_internal_name
  ,p_data_type
  ,p_input_flag
  ,p_context_flag
  ,p_output_flag
  ,p_result_flag
  ,p_error_message_flag
  ,p_function_return_flag
  ,p_enabled_flag
  ,p_external_name
  ,p_database_item_name
  ,p_constant_value
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_amp_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
begin
  g_package  := '  pay_amp_upd.';  -- Global package name
end pay_amp_upd;

/
