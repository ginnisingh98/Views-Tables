--------------------------------------------------------
--  DDL for Package Body PQP_EXR_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_EXR_UPD" as
/* $Header: pqexrrhi.pkb 120.4 2006/10/20 18:38:32 sshetty noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_exr_upd.';  -- Global package name
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
  (p_rec in out nocopy pqp_exr_shd.g_rec_type
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
  pqp_exr_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the pqp_exception_reports Row
  --

  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP')
  THEN

  update pqp_exception_reports
    set
     exception_report_id             = p_rec.exception_report_id
    ,exception_report_name           = p_rec.exception_report_name
    ,legislation_code                = p_rec.legislation_code
    ,business_group_id               = p_rec.business_group_id
    ,currency_code                   = p_rec.currency_code
    ,balance_type_id                 = p_rec.balance_type_id
    ,balance_dimension_id            = p_rec.balance_dimension_id
    ,variance_type                   = p_rec.variance_type
    ,variance_value                  = p_rec.variance_value
    ,comparison_type                 = p_rec.comparison_type
    ,comparison_value                = p_rec.comparison_value
    ,object_version_number           = p_rec.object_version_number
    ,output_format                   = p_rec.output_format_type
    ,variance_operator               = p_rec.variance_operator
     where exception_report_id = p_rec.exception_report_id;

  ELSE

  update pqp_exception_reports
    set
     exception_report_id             = p_rec.exception_report_id
    ,exception_report_name           = p_rec.exception_report_name
    ,legislation_code                = p_rec.legislation_code
    ,business_group_id               = p_rec.business_group_id
    ,currency_code                   = p_rec.currency_code
    ,balance_type_id                 = p_rec.balance_type_id
    ,balance_dimension_id            = p_rec.balance_dimension_id
    ,variance_type                   = p_rec.variance_type
    ,variance_value                  = p_rec.variance_value
    ,comparison_type                 = p_rec.comparison_type
    ,comparison_value                = p_rec.comparison_value
    ,object_version_number           = p_rec.object_version_number
    ,output_format                   = p_rec.output_format_type
    ,variance_operator               = p_rec.variance_operator
    ,last_updated_by                 = 2
    ,last_update_date                = sysdate
     where exception_report_id = p_rec.exception_report_id;

  END IF;
  --
  pqp_exr_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqp_exr_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_exr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqp_exr_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_exr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqp_exr_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_exr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqp_exr_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in pqp_exr_shd.g_rec_type
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
  (p_rec                          in pqp_exr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqp_exr_rku.after_update (
      p_exception_report_id      => p_rec.exception_report_id
      ,p_exception_report_name   => p_rec.exception_report_name
        ,p_legislation_code      => p_rec.legislation_code
      ,p_business_group_id       => p_rec.business_group_id
      ,p_currency_code           => p_rec.currency_code
      ,p_balance_type_id         => p_rec.balance_type_id
      ,p_balance_dimension_id    => p_rec.balance_dimension_id
      ,p_variance_type           => p_rec.variance_type
      ,p_variance_value          => p_rec.variance_value
      ,p_comparison_type         => p_rec.comparison_type
      ,p_comparison_value        => p_rec.comparison_value
      ,p_object_version_number   => p_rec.object_version_number
      ,p_output_format_type      => p_rec.output_format_type
      ,p_variance_operator       => p_rec.variance_operator
      ,p_exception_report_name_o => pqp_exr_shd.g_old_rec.exception_report_name
      ,p_legislation_code_o      => pqp_exr_shd.g_old_rec.legislation_code
      ,p_business_group_id_o     => pqp_exr_shd.g_old_rec.business_group_id
      ,p_currency_code_o         => pqp_exr_shd.g_old_rec.currency_code
      ,p_balance_type_id_o       => pqp_exr_shd.g_old_rec.balance_type_id
      ,p_balance_dimension_id_o  => pqp_exr_shd.g_old_rec.balance_dimension_id
      ,p_variance_type_o         => pqp_exr_shd.g_old_rec.variance_type
      ,p_variance_value_o        => pqp_exr_shd.g_old_rec.variance_value
      ,p_comparison_type_o       => pqp_exr_shd.g_old_rec.comparison_type
      ,p_comparison_value_o      => pqp_exr_shd.g_old_rec.comparison_value
      ,p_object_version_number_o => pqp_exr_shd.g_old_rec.object_version_number
      ,p_output_format_type_o    => pqp_exr_shd.g_old_rec.output_format_type
      ,p_variance_operator_o     => pqp_exr_shd.g_old_rec.variance_operator
         );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_EXCEPTION_REPORTS'
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
  (p_rec in out nocopy pqp_exr_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.exception_report_name = hr_api.g_varchar2) then
    p_rec.exception_report_name :=
    pqp_exr_shd.g_old_rec.exception_report_name;
  End If;
  If (p_rec.legislation_code = hr_api.g_varchar2) then
    p_rec.legislation_code :=
    pqp_exr_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pqp_exr_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.currency_code = hr_api.g_varchar2) then
    p_rec.currency_code :=
    pqp_exr_shd.g_old_rec.currency_code;
  End If;
  If (p_rec.balance_type_id = hr_api.g_number) then
    p_rec.balance_type_id :=
    pqp_exr_shd.g_old_rec.balance_type_id;
  End If;
  If (p_rec.balance_dimension_id = hr_api.g_number) then
    p_rec.balance_dimension_id :=
    pqp_exr_shd.g_old_rec.balance_dimension_id;
  End If;
  If (p_rec.variance_type = hr_api.g_varchar2) then
    p_rec.variance_type :=
    pqp_exr_shd.g_old_rec.variance_type;
  End If;
  If (p_rec.variance_value = hr_api.g_number) then
    p_rec.variance_value :=
    pqp_exr_shd.g_old_rec.variance_value;
  End If;
  If (p_rec.comparison_type = hr_api.g_varchar2) then
    p_rec.comparison_type :=
    pqp_exr_shd.g_old_rec.comparison_type;
  End If;
  If (p_rec.comparison_value = hr_api.g_number) then
    p_rec.comparison_value :=
    pqp_exr_shd.g_old_rec.comparison_value;
  End If;
  If (p_rec.output_format_type = hr_api.g_varchar2) then
    p_rec.output_format_type :=
    pqp_exr_shd.g_old_rec.output_format_type;
  End If;
  If (p_rec.variance_operator = hr_api.g_varchar2) then
    p_rec.variance_operator :=
    pqp_exr_shd.g_old_rec.variance_operator;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy pqp_exr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqp_exr_shd.lck
    (p_rec.exception_report_id
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
  pqp_exr_bus.update_validate
     (p_rec
     );

   hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pqp_exr_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pqp_exr_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pqp_exr_upd.post_update
     (p_rec
     );
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_exception_report_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_exception_report_name        in     varchar2
  ,p_legislation_code             in     varchar2
  ,p_business_group_id            in     number
  ,p_currency_code                in     varchar2
  ,p_balance_type_id              in     number
  ,p_balance_dimension_id         in     number
  ,p_variance_type                in     varchar2
  ,p_variance_value               in     number
  ,p_comparison_type              in     varchar2
  ,p_comparison_value             in     number
  ,p_output_format_type           in     varchar2
  ,p_variance_operator            in     varchar2
  ) is
--
  l_rec   pqp_exr_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqp_exr_shd.convert_args
  (p_exception_report_id
  ,p_exception_report_name
  ,p_legislation_code
  ,p_business_group_id
  ,p_currency_code
  ,p_balance_type_id
  ,p_balance_dimension_id
  ,p_variance_type
  ,p_variance_value
  ,p_comparison_type
  ,p_comparison_value
  ,p_object_version_number
  ,p_output_format_type
  ,p_variance_operator
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqp_exr_upd.upd (l_rec );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqp_exr_upd;


/
