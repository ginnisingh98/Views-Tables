--------------------------------------------------------
--  DDL for Package Body PQH_VLD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_VLD_UPD" as
/* $Header: pqvldrhi.pkb 115.2 2002/12/13 00:33:20 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_vld_upd.';  -- Global package name
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
  (p_rec in out nocopy pqh_vld_shd.g_rec_type
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
  --
  --
  -- Update the pqh_fr_validations Row
  --
  update pqh_fr_validations
    set
     validation_id                   = p_rec.validation_id
    ,pension_fund_type_code          = p_rec.pension_fund_type_code
    ,pension_fund_id                 = p_rec.pension_fund_id
    ,business_group_id               = p_rec.business_group_id
    ,person_id                       = p_rec.person_id
    ,request_date                    = p_rec.request_date
    ,completion_date                 = p_rec.completion_date
    ,previous_employer_id            = p_rec.previous_employer_id
    ,previously_validated_flag       = p_rec.previously_validated_flag
    ,status                          = p_rec.status
    ,employer_amount                 = p_rec.employer_amount
    ,employer_currency_code          = p_rec.employer_currency_code
    ,employee_amount                 = p_rec.employee_amount
    ,employee_currency_code          = p_rec.employee_currency_code
    ,deduction_per_period            = p_rec.deduction_per_period
    ,deduction_currency_code         = p_rec.deduction_currency_code
    ,percent_of_salary               = p_rec.percent_of_salary
    ,object_version_number           = p_rec.object_version_number
    where validation_id = p_rec.validation_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pqh_vld_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pqh_vld_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pqh_vld_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
  (p_rec in pqh_vld_shd.g_rec_type
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
  (p_effective_date               in date
  ,p_rec                          in pqh_vld_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqh_vld_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_validation_id
      => p_rec.validation_id
      ,p_pension_fund_type_code
      => p_rec.pension_fund_type_code
      ,p_pension_fund_id
      => p_rec.pension_fund_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_person_id
      => p_rec.person_id
      ,p_request_date
      => p_rec.request_date
      ,p_completion_date
      => p_rec.completion_date
      ,p_previous_employer_id
      => p_rec.previous_employer_id
      ,p_previously_validated_flag
      => p_rec.previously_validated_flag
      ,p_status
      => p_rec.status
      ,p_employer_amount
      => p_rec.employer_amount
      ,p_employer_currency_code
      => p_rec.employer_currency_code
      ,p_employee_amount
      => p_rec.employee_amount
      ,p_employee_currency_code
      => p_rec.employee_currency_code
      ,p_deduction_per_period
      => p_rec.deduction_per_period
      ,p_deduction_currency_code
      => p_rec.deduction_currency_code
      ,p_percent_of_salary
      => p_rec.percent_of_salary
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_pension_fund_type_code_o
      => pqh_vld_shd.g_old_rec.pension_fund_type_code
      ,p_pension_fund_id_o
      => pqh_vld_shd.g_old_rec.pension_fund_id
      ,p_business_group_id_o
      => pqh_vld_shd.g_old_rec.business_group_id
      ,p_person_id_o
      => pqh_vld_shd.g_old_rec.person_id
      ,p_request_date_o
      => pqh_vld_shd.g_old_rec.request_date
      ,p_completion_date_o
      => pqh_vld_shd.g_old_rec.completion_date
      ,p_previous_employer_id_o
      => pqh_vld_shd.g_old_rec.previous_employer_id
      ,p_previously_validated_flag_o
      => pqh_vld_shd.g_old_rec.previously_validated_flag
      ,p_status_o
      => pqh_vld_shd.g_old_rec.status
      ,p_employer_amount_o
      => pqh_vld_shd.g_old_rec.employer_amount
      ,p_employer_currency_code_o
      => pqh_vld_shd.g_old_rec.employer_currency_code
      ,p_employee_amount_o
      => pqh_vld_shd.g_old_rec.employee_amount
      ,p_employee_currency_code_o
      => pqh_vld_shd.g_old_rec.employee_currency_code
      ,p_deduction_per_period_o
      => pqh_vld_shd.g_old_rec.deduction_per_period
      ,p_deduction_currency_code_o
      => pqh_vld_shd.g_old_rec.deduction_currency_code
      ,p_percent_of_salary_o
      => pqh_vld_shd.g_old_rec.percent_of_salary
      ,p_object_version_number_o
      => pqh_vld_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_FR_VALIDATIONS'
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
  (p_rec in out nocopy pqh_vld_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.pension_fund_type_code = hr_api.g_varchar2) then
    p_rec.pension_fund_type_code :=
    pqh_vld_shd.g_old_rec.pension_fund_type_code;
  End If;
  If (p_rec.pension_fund_id = hr_api.g_number) then
    p_rec.pension_fund_id :=
    pqh_vld_shd.g_old_rec.pension_fund_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pqh_vld_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    pqh_vld_shd.g_old_rec.person_id;
  End If;
  If (p_rec.request_date = hr_api.g_date) then
    p_rec.request_date :=
    pqh_vld_shd.g_old_rec.request_date;
  End If;
  If (p_rec.completion_date = hr_api.g_date) then
    p_rec.completion_date :=
    pqh_vld_shd.g_old_rec.completion_date;
  End If;
  If (p_rec.previous_employer_id = hr_api.g_number) then
    p_rec.previous_employer_id :=
    pqh_vld_shd.g_old_rec.previous_employer_id;
  End If;
  If (p_rec.previously_validated_flag = hr_api.g_varchar2) then
    p_rec.previously_validated_flag :=
    pqh_vld_shd.g_old_rec.previously_validated_flag;
  End If;
  If (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    pqh_vld_shd.g_old_rec.status;
  End If;
  If (p_rec.employer_amount = hr_api.g_number) then
    p_rec.employer_amount :=
    pqh_vld_shd.g_old_rec.employer_amount;
  End If;
  If (p_rec.employer_currency_code = hr_api.g_varchar2) then
    p_rec.employer_currency_code :=
    pqh_vld_shd.g_old_rec.employer_currency_code;
  End If;
  If (p_rec.employee_amount = hr_api.g_number) then
    p_rec.employee_amount :=
    pqh_vld_shd.g_old_rec.employee_amount;
  End If;
  If (p_rec.employee_currency_code = hr_api.g_varchar2) then
    p_rec.employee_currency_code :=
    pqh_vld_shd.g_old_rec.employee_currency_code;
  End If;
  If (p_rec.deduction_per_period = hr_api.g_number) then
    p_rec.deduction_per_period :=
    pqh_vld_shd.g_old_rec.deduction_per_period;
  End If;
  If (p_rec.deduction_currency_code = hr_api.g_varchar2) then
    p_rec.deduction_currency_code :=
    pqh_vld_shd.g_old_rec.deduction_currency_code;
  End If;
  If (p_rec.percent_of_salary = hr_api.g_number) then
    p_rec.percent_of_salary :=
    pqh_vld_shd.g_old_rec.percent_of_salary;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy pqh_vld_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqh_vld_shd.lck
    (p_rec.validation_id
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
  pqh_vld_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pqh_vld_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pqh_vld_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pqh_vld_upd.post_update
     (p_effective_date
     ,p_rec
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
  (p_effective_date               in     date
  ,p_validation_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_pension_fund_type_code       in     varchar2  default hr_api.g_varchar2
  ,p_pension_fund_id              in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_previously_validated_flag    in     varchar2  default hr_api.g_varchar2
  ,p_request_date                 in     date      default hr_api.g_date
  ,p_completion_date              in     date      default hr_api.g_date
  ,p_previous_employer_id         in     number    default hr_api.g_number
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_employer_amount              in     number    default hr_api.g_number
  ,p_employer_currency_code       in     varchar2  default hr_api.g_varchar2
  ,p_employee_amount              in     number    default hr_api.g_number
  ,p_employee_currency_code       in     varchar2  default hr_api.g_varchar2
  ,p_deduction_per_period         in     number    default hr_api.g_number
  ,p_deduction_currency_code      in     varchar2  default hr_api.g_varchar2
  ,p_percent_of_salary            in     number    default hr_api.g_number
  ) is
--
  l_rec   pqh_vld_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_vld_shd.convert_args
  (p_validation_id
  ,p_pension_fund_type_code
  ,p_pension_fund_id
  ,p_business_group_id
  ,p_person_id
  ,p_request_date
  ,p_completion_date
  ,p_previous_employer_id
  ,p_previously_validated_flag
  ,p_status
  ,p_employer_amount
  ,p_employer_currency_code
  ,p_employee_amount
  ,p_employee_currency_code
  ,p_deduction_per_period
  ,p_deduction_currency_code
  ,p_percent_of_salary
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqh_vld_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqh_vld_upd;

/
