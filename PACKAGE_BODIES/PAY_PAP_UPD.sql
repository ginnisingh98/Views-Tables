--------------------------------------------------------
--  DDL for Package Body PAY_PAP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAP_UPD" as
/* $Header: pypaprhi.pkb 120.0 2005/05/29 07:14:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_pap_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy pay_pap_shd.g_rec_type) is
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
  pay_pap_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the pay_accrual_plans Row
  --
  update pay_accrual_plans
  set
  accrual_plan_id                   = p_rec.accrual_plan_id,
  pto_input_value_id                = p_rec.pto_input_value_id,
  accrual_category                  = p_rec.accrual_category,
  accrual_start                     = p_rec.accrual_start,
  ineligible_period_length          = p_rec.ineligible_period_length,
  ineligible_period_type            = p_rec.ineligible_period_type,
  accrual_formula_id                = p_rec.accrual_formula_id,
  co_formula_id                     = p_rec.co_formula_id,
  description                       = p_rec.description,
  ineligibility_formula_id          = p_rec.ineligibility_formula_id,
  payroll_formula_id                = p_rec.payroll_formula_id,
  defined_balance_id                = p_rec.defined_balance_id,
  tagging_element_type_id           = p_rec.tagging_element_type_id,
  balance_element_type_id           = p_rec.balance_element_type_id,
  object_version_number             = p_rec.object_version_number,
  information_category              = p_rec.information_category,
  information1                      = p_rec.information1,
  information2                      = p_rec.information2,
  information3                      = p_rec.information3,
  information4                      = p_rec.information4,
  information5                      = p_rec.information5,
  information6                      = p_rec.information6,
  information7                      = p_rec.information7,
  information8                      = p_rec.information8,
  information9                      = p_rec.information9,
  information10                     = p_rec.information10,
  information11                     = p_rec.information11,
  information12                     = p_rec.information12,
  information13                     = p_rec.information13,
  information14                     = p_rec.information14,
  information15                     = p_rec.information15,
  information16                     = p_rec.information16,
  information17                     = p_rec.information17,
  information18                     = p_rec.information18,
  information19                     = p_rec.information19,
  information20                     = p_rec.information20,
  information21                     = p_rec.information21,
  information22                     = p_rec.information22,
  information23                     = p_rec.information23,
  information24                     = p_rec.information24,
  information25                     = p_rec.information25,
  information26                     = p_rec.information26,
  information27                     = p_rec.information27,
  information28                     = p_rec.information28,
  information29                     = p_rec.information29,
  information30                     = p_rec.information30

  where accrual_plan_id = p_rec.accrual_plan_id;
  --
  pay_pap_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_pap_shd.g_api_dml := false;   -- Unset the api dml status
    pay_pap_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_pap_shd.g_api_dml := false;   -- Unset the api dml status
    pay_pap_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_pap_shd.g_api_dml := false;   -- Unset the api dml status
    pay_pap_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_pap_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in pay_pap_shd.g_rec_type) is
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
Procedure post_update(p_rec in pay_pap_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    pay_pap_rku.after_update
      (
  p_accrual_plan_id               =>p_rec.accrual_plan_id
 ,p_accrual_plan_element_type_id  =>p_rec.accrual_plan_element_type_id
 ,p_pto_input_value_id            =>p_rec.pto_input_value_id
 ,p_co_input_value_id             =>p_rec.co_input_value_id
 ,p_residual_input_value_id       =>p_rec.residual_input_value_id
 ,p_accrual_category              =>p_rec.accrual_category
 ,p_accrual_plan_name             =>p_rec.accrual_plan_name
 ,p_accrual_start                 =>p_rec.accrual_start
 ,p_accrual_units_of_measure      =>p_rec.accrual_units_of_measure
 ,p_ineligible_period_length      =>p_rec.ineligible_period_length
 ,p_ineligible_period_type        =>p_rec.ineligible_period_type
 ,p_accrual_formula_id            =>p_rec.accrual_formula_id
 ,p_co_formula_id                 =>p_rec.co_formula_id
 ,p_co_date_input_value_id        =>p_rec.co_date_input_value_id
 ,p_co_exp_date_input_value_id    =>p_rec.co_exp_date_input_value_id
 ,p_residual_date_input_value_id  =>p_rec.residual_date_input_value_id
 ,p_description                   =>p_rec.description
 ,p_ineligibility_formula_id      =>p_rec.ineligibility_formula_id
 ,p_payroll_formula_id            =>p_rec.payroll_formula_id
 ,p_defined_balance_id            =>p_rec.defined_balance_id
 ,p_tagging_element_type_id       =>p_rec.tagging_element_type_id
 ,p_balance_element_type_id       =>p_rec.balance_element_type_id
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_information_category          =>p_rec.information_category
 ,p_information1                  =>p_rec.information1
 ,p_information2                  =>p_rec.information2
 ,p_information3                  =>p_rec.information3
 ,p_information4                  =>p_rec.information4
 ,p_information5                  =>p_rec.information5
 ,p_information6                  =>p_rec.information6
 ,p_information7                  =>p_rec.information7
 ,p_information8                  =>p_rec.information8
 ,p_information9                  =>p_rec.information9
 ,p_information10                 =>p_rec.information10
 ,p_information11                 =>p_rec.information11
 ,p_information12                 =>p_rec.information12
 ,p_information13                 =>p_rec.information13
 ,p_information14                 =>p_rec.information14
 ,p_information15                 =>p_rec.information15
 ,p_information16                 =>p_rec.information16
 ,p_information17                 =>p_rec.information17
 ,p_information18                 =>p_rec.information18
 ,p_information19                 =>p_rec.information19
 ,p_information20                 =>p_rec.information20
 ,p_information21                 =>p_rec.information21
 ,p_information22                 =>p_rec.information22
 ,p_information23                 =>p_rec.information23
 ,p_information24                 =>p_rec.information24
 ,p_information25                 =>p_rec.information25
 ,p_information26                 =>p_rec.information26
 ,p_information27                 =>p_rec.information27
 ,p_information28                 =>p_rec.information28
 ,p_information29                 =>p_rec.information29
 ,p_information30                 =>p_rec.information30
 ,p_business_group_id_o           =>pay_pap_shd.g_old_rec.business_group_id
 ,p_accrual_plan_element_type__o=>pay_pap_shd.g_old_rec.accrual_plan_element_type_id
 ,p_pto_input_value_id_o          =>pay_pap_shd.g_old_rec.pto_input_value_id
 ,p_co_input_value_id_o           =>pay_pap_shd.g_old_rec.co_input_value_id
 ,p_residual_input_value_id_o     =>pay_pap_shd.g_old_rec.residual_input_value_id
 ,p_accrual_category_o            =>pay_pap_shd.g_old_rec.accrual_category
 ,p_accrual_plan_name_o           =>pay_pap_shd.g_old_rec.accrual_plan_name
 ,p_accrual_start_o               =>pay_pap_shd.g_old_rec.accrual_start
 ,p_accrual_units_of_measure_o    =>pay_pap_shd.g_old_rec.accrual_units_of_measure
 ,p_ineligible_period_length_o    =>pay_pap_shd.g_old_rec.ineligible_period_length
 ,p_ineligible_period_type_o      =>pay_pap_shd.g_old_rec.ineligible_period_type
 ,p_accrual_formula_id_o          =>pay_pap_shd.g_old_rec.accrual_formula_id
 ,p_co_formula_id_o               =>pay_pap_shd.g_old_rec.co_formula_id
 ,p_co_date_input_value_id_o      =>pay_pap_shd.g_old_rec.co_date_input_value_id
 ,p_co_exp_date_input_value_id_o  =>pay_pap_shd.g_old_rec.co_exp_date_input_value_id
 ,p_residual_date_input_value__o=>pay_pap_shd.g_old_rec.residual_date_input_value_id
 ,p_description_o                 =>pay_pap_shd.g_old_rec.description
 ,p_ineligibility_formula_id_o    =>pay_pap_shd.g_old_rec.ineligibility_formula_id
 ,p_payroll_formula_id_o          =>pay_pap_shd.g_old_rec.payroll_formula_id
 ,p_defined_balance_id_o          =>pay_pap_shd.g_old_rec.defined_balance_id
 ,p_tagging_element_type_id_o     =>pay_pap_shd.g_old_rec.tagging_element_type_id
 ,p_balance_element_type_id_o     =>pay_pap_shd.g_old_rec.balance_element_type_id
 ,p_object_version_number_o       =>pay_pap_shd.g_old_rec.object_version_number
 ,p_information_category_o        =>pay_pap_shd.g_old_rec.information_category
 ,p_information1_o                =>pay_pap_shd.g_old_rec.information1
 ,p_information2_o                =>pay_pap_shd.g_old_rec.information2
 ,p_information3_o                =>pay_pap_shd.g_old_rec.information3
 ,p_information4_o                =>pay_pap_shd.g_old_rec.information4
 ,p_information5_o                =>pay_pap_shd.g_old_rec.information5
 ,p_information6_o                =>pay_pap_shd.g_old_rec.information6
 ,p_information7_o                =>pay_pap_shd.g_old_rec.information7
 ,p_information8_o                =>pay_pap_shd.g_old_rec.information8
 ,p_information9_o                =>pay_pap_shd.g_old_rec.information9
 ,p_information10_o               =>pay_pap_shd.g_old_rec.information10
 ,p_information11_o               =>pay_pap_shd.g_old_rec.information11
 ,p_information12_o               =>pay_pap_shd.g_old_rec.information12
 ,p_information13_o               =>pay_pap_shd.g_old_rec.information13
 ,p_information14_o               =>pay_pap_shd.g_old_rec.information14
 ,p_information15_o               =>pay_pap_shd.g_old_rec.information15
 ,p_information16_o               =>pay_pap_shd.g_old_rec.information16
 ,p_information17_o               =>pay_pap_shd.g_old_rec.information17
 ,p_information18_o               =>pay_pap_shd.g_old_rec.information18
 ,p_information19_o               =>pay_pap_shd.g_old_rec.information19
 ,p_information20_o               =>pay_pap_shd.g_old_rec.information20
 ,p_information21_o               =>pay_pap_shd.g_old_rec.information21
 ,p_information22_o               =>pay_pap_shd.g_old_rec.information22
 ,p_information23_o               =>pay_pap_shd.g_old_rec.information23
 ,p_information24_o               =>pay_pap_shd.g_old_rec.information24
 ,p_information25_o               =>pay_pap_shd.g_old_rec.information25
 ,p_information26_o               =>pay_pap_shd.g_old_rec.information26
 ,p_information27_o               =>pay_pap_shd.g_old_rec.information27
 ,p_information28_o               =>pay_pap_shd.g_old_rec.information28
 ,p_information29_o               =>pay_pap_shd.g_old_rec.information29
 ,p_information30_o               =>pay_pap_shd.g_old_rec.information30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pay_accrual_plans'
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
Procedure convert_defs(p_rec in out nocopy pay_pap_shd.g_rec_type) is
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
    pay_pap_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.accrual_plan_element_type_id = hr_api.g_number) then
    p_rec.accrual_plan_element_type_id :=
    pay_pap_shd.g_old_rec.accrual_plan_element_type_id;
  End If;
  If (p_rec.pto_input_value_id = hr_api.g_number) then
    p_rec.pto_input_value_id :=
    pay_pap_shd.g_old_rec.pto_input_value_id;
  End If;
  If (p_rec.co_input_value_id = hr_api.g_number) then
    p_rec.co_input_value_id :=
    pay_pap_shd.g_old_rec.co_input_value_id;
  End If;
  If (p_rec.residual_input_value_id = hr_api.g_number) then
    p_rec.residual_input_value_id :=
    pay_pap_shd.g_old_rec.residual_input_value_id;
  End If;
  If (p_rec.accrual_category = hr_api.g_varchar2) then
    p_rec.accrual_category :=
    pay_pap_shd.g_old_rec.accrual_category;
  End If;
  If (p_rec.accrual_plan_name = hr_api.g_varchar2) then
    p_rec.accrual_plan_name :=
    pay_pap_shd.g_old_rec.accrual_plan_name;
  End If;
  If (p_rec.accrual_start = hr_api.g_varchar2) then
    p_rec.accrual_start :=
    pay_pap_shd.g_old_rec.accrual_start;
  End If;
  If (p_rec.accrual_units_of_measure = hr_api.g_varchar2) then
    p_rec.accrual_units_of_measure :=
    pay_pap_shd.g_old_rec.accrual_units_of_measure;
  End If;
  If (p_rec.ineligible_period_length = hr_api.g_number) then
    p_rec.ineligible_period_length :=
    pay_pap_shd.g_old_rec.ineligible_period_length;
  End If;
  If (p_rec.ineligible_period_type = hr_api.g_varchar2) then
    p_rec.ineligible_period_type :=
    pay_pap_shd.g_old_rec.ineligible_period_type;
  End If;
  If (p_rec.accrual_formula_id = hr_api.g_number) then
    p_rec.accrual_formula_id :=
    pay_pap_shd.g_old_rec.accrual_formula_id;
  End If;
  If (p_rec.co_formula_id = hr_api.g_number) then
    p_rec.co_formula_id :=
    pay_pap_shd.g_old_rec.co_formula_id;
  End If;
  If (p_rec.co_date_input_value_id = hr_api.g_number) then
    p_rec.co_date_input_value_id :=
    pay_pap_shd.g_old_rec.co_date_input_value_id;
  End If;
  If (p_rec.co_exp_date_input_value_id = hr_api.g_number) then
    p_rec.co_exp_date_input_value_id :=
    pay_pap_shd.g_old_rec.co_exp_date_input_value_id;
  End If;
  If (p_rec.residual_date_input_value_id = hr_api.g_number) then
    p_rec.residual_date_input_value_id :=
    pay_pap_shd.g_old_rec.residual_date_input_value_id;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    pay_pap_shd.g_old_rec.description;
  End If;
  If (p_rec.ineligibility_formula_id = hr_api.g_number) then
    p_rec.ineligibility_formula_id :=
    pay_pap_shd.g_old_rec.ineligibility_formula_id;
  End If;
  If (p_rec.payroll_formula_id = hr_api.g_number) then
    p_rec.payroll_formula_id :=
    pay_pap_shd.g_old_rec.payroll_formula_id;
  End If;
  If (p_rec.defined_balance_id = hr_api.g_number) then
    p_rec.defined_balance_id :=
    pay_pap_shd.g_old_rec.defined_balance_id;
  End If;
  If (p_rec.tagging_element_type_id = hr_api.g_number) then
    p_rec.tagging_element_type_id :=
    pay_pap_shd.g_old_rec.tagging_element_type_id;
  End If;
  If (p_rec.balance_element_type_id = hr_api.g_number) then
    p_rec.balance_element_type_id :=
    pay_pap_shd.g_old_rec.balance_element_type_id;
  End If;
  If (p_rec.information_category    = hr_api.g_varchar2) then
    p_rec.information_category :=
    pay_pap_shd.g_old_rec.information_category;
  End If;
  If (p_rec.information1 = hr_api.g_varchar2) then
    p_rec.information1 :=
    pay_pap_shd.g_old_rec.information1;
  End If;
  If (p_rec.information2 = hr_api.g_varchar2) then
    p_rec.information2 :=
    pay_pap_shd.g_old_rec.information2;
  End If;
  If (p_rec.information3 = hr_api.g_varchar2) then
    p_rec.information3 :=
    pay_pap_shd.g_old_rec.information3;
  End If;
  If (p_rec.information4 = hr_api.g_varchar2) then
    p_rec.information4 :=
    pay_pap_shd.g_old_rec.information4;
  End If;
  If (p_rec.information5 = hr_api.g_varchar2) then
    p_rec.information5 :=
    pay_pap_shd.g_old_rec.information5;
  End If;
  If (p_rec.information6 = hr_api.g_varchar2) then
    p_rec.information6 :=
    pay_pap_shd.g_old_rec.information6;
  End If;
  If (p_rec.information7 = hr_api.g_varchar2) then
    p_rec.information7 :=
    pay_pap_shd.g_old_rec.information7;
  End If;
  If (p_rec.information8 = hr_api.g_varchar2) then
    p_rec.information8 :=
    pay_pap_shd.g_old_rec.information8;
  End If;
  If (p_rec.information9 = hr_api.g_varchar2) then
    p_rec.information9 :=
    pay_pap_shd.g_old_rec.information9;
  End If;
  If (p_rec.information10 = hr_api.g_varchar2) then
    p_rec.information10 :=
    pay_pap_shd.g_old_rec.information10;
  End If;
  If (p_rec.information11 = hr_api.g_varchar2) then
    p_rec.information11 :=
    pay_pap_shd.g_old_rec.information11;
  End If;
  If (p_rec.information12 = hr_api.g_varchar2) then
    p_rec.information12 :=
    pay_pap_shd.g_old_rec.information12;
  End If;
  If (p_rec.information13 = hr_api.g_varchar2) then
    p_rec.information13 :=
    pay_pap_shd.g_old_rec.information13;
  End If;
  If (p_rec.information14 = hr_api.g_varchar2) then
    p_rec.information14 :=
    pay_pap_shd.g_old_rec.information14;
  End If;
  If (p_rec.information15 = hr_api.g_varchar2) then
    p_rec.information15 :=
    pay_pap_shd.g_old_rec.information15;
  End If;
  If (p_rec.information16 = hr_api.g_varchar2) then
    p_rec.information16 :=
    pay_pap_shd.g_old_rec.information16;
  End If;
  If (p_rec.information17 = hr_api.g_varchar2) then
    p_rec.information17 :=
    pay_pap_shd.g_old_rec.information17;
  End If;
  If (p_rec.information18 = hr_api.g_varchar2) then
    p_rec.information18 :=
    pay_pap_shd.g_old_rec.information18;
  End If;
  If (p_rec.information19 = hr_api.g_varchar2) then
    p_rec.information19 :=
    pay_pap_shd.g_old_rec.information19;
  End If;
  If (p_rec.information20 = hr_api.g_varchar2) then
    p_rec.information20 :=
    pay_pap_shd.g_old_rec.information20;
  End If;
  If (p_rec.information21 = hr_api.g_varchar2) then
    p_rec.information21 :=
    pay_pap_shd.g_old_rec.information21;
  End If;
  If (p_rec.information22 = hr_api.g_varchar2) then
    p_rec.information22 :=
    pay_pap_shd.g_old_rec.information22;
  End If;
  If (p_rec.information23 = hr_api.g_varchar2) then
    p_rec.information23 :=
    pay_pap_shd.g_old_rec.information23;
  End If;
  If (p_rec.information24 = hr_api.g_varchar2) then
    p_rec.information24 :=
    pay_pap_shd.g_old_rec.information24;
  End If;
  If (p_rec.information25 = hr_api.g_varchar2) then
    p_rec.information25 :=
    pay_pap_shd.g_old_rec.information25;
  End If;
  If (p_rec.information26 = hr_api.g_varchar2) then
    p_rec.information26 :=
    pay_pap_shd.g_old_rec.information26;
  End If;
  If (p_rec.information27 = hr_api.g_varchar2) then
    p_rec.information27 :=
    pay_pap_shd.g_old_rec.information27;
  End If;
  If (p_rec.information28 = hr_api.g_varchar2) then
    p_rec.information28 :=
    pay_pap_shd.g_old_rec.information28;
  End If;
  If (p_rec.information29 = hr_api.g_varchar2) then
    p_rec.information29 :=
    pay_pap_shd.g_old_rec.information29;
  End If;
  If (p_rec.information30 = hr_api.g_varchar2) then
    p_rec.information30 :=
    pay_pap_shd.g_old_rec.information30;
  End If;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE upd
  (p_effective_date   IN     DATE
  ,p_rec              IN OUT NOCOPY pay_pap_shd.g_rec_type
  ,p_check_accrual_ff    OUT NOCOPY BOOLEAN)
IS

  l_proc  varchar2(72) := g_package||'upd';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- We must lock the row which we need to update.
  --
  pay_pap_shd.lck
	(
	p_rec.accrual_plan_id,
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

  hr_utility.set_location(l_proc, 20);

  pay_pap_bus.update_validate
    (p_effective_date   => p_effective_date
    ,p_rec              => p_rec
    ,p_check_accrual_ff => p_check_accrual_ff);

  hr_utility.set_location(l_proc, 30);

  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);

  hr_utility.set_location(l_proc, 40);

  --
  -- Update the row.
  --
  update_dml(p_rec);

  hr_utility.set_location(l_proc, 50);

  --
  -- Call the supporting post-update operation
  --
  post_update(p_rec);

  hr_utility.set_location('Leaving: '||l_proc, 60);

END upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE upd
  (p_effective_date               IN     DATE
  ,p_accrual_plan_id              IN     NUMBER
  ,p_pto_input_value_id           IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_accrual_category             IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_accrual_start                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ineligible_period_length     IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_ineligible_period_type       IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_accrual_formula_id           IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_co_formula_id                IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_description                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ineligibility_formula_id     IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_payroll_formula_id           IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_defined_balance_id           IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_tagging_element_type_id      IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_balance_element_type_id      IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_information_category         IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information1                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information2                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information3                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information4                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information5                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information6                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information7                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information8                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information9                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information10                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information11                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information12                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information13                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information14                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information15                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information16                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information17                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information18                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information19                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information20                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information21                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information22                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information23                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information24                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information25                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information26                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information27                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information28                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information29                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_information30                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_object_version_number        IN OUT NOCOPY NUMBER
  ,p_check_accrual_ff                OUT NOCOPY BOOLEAN)
IS

  l_rec	  pay_pap_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_pap_shd.convert_args
  (
  p_accrual_plan_id,
  hr_api.g_number,
  hr_api.g_number,
  p_pto_input_value_id,
  hr_api.g_number,
  hr_api.g_number,
  p_accrual_category,
  hr_api.g_varchar2,
  p_accrual_start,
  hr_api.g_varchar2,
  p_ineligible_period_length,
  p_ineligible_period_type,
  p_accrual_formula_id,
  p_co_formula_id,
  hr_api.g_number,
  hr_api.g_number,
  hr_api.g_number,
  p_description,
  p_ineligibility_formula_id,
  p_payroll_formula_id,
  p_defined_balance_id,
  p_tagging_element_type_id,
  p_balance_element_type_id,
  p_object_version_number,
  p_information_category,
  p_information1,
  p_information2,
  p_information3,
  p_information4,
  p_information5,
  p_information6,
  p_information7,
  p_information8,
  p_information9,
  p_information10,
  p_information11,
  p_information12,
  p_information13,
  p_information14,
  p_information15,
  p_information16,
  p_information17,
  p_information18,
  p_information19,
  p_information20,
  p_information21,
  p_information22,
  p_information23,
  p_information24,
  p_information25,
  p_information26,
  p_information27,
  p_information28,
  p_information29,
  p_information30
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd
    (p_effective_date   => p_effective_date
    ,p_rec              => l_rec
    ,p_check_accrual_ff => p_check_accrual_ff);

  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

END upd;
--
END pay_pap_upd;

/
