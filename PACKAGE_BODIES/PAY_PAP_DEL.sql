--------------------------------------------------------
--  DDL for Package Body PAY_PAP_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAP_DEL" as
/* $Header: pypaprhi.pkb 120.0 2005/05/29 07:14:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_pap_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) To delete the specified row from the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in pay_pap_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_pap_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the pay_accrual_plans row.
  --
  delete from pay_accrual_plans
  where accrual_plan_id = p_rec.accrual_plan_id;
  --
  pay_pap_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pay_pap_shd.g_api_dml := false;   -- Unset the api dml status
    pay_pap_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_pap_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in pay_pap_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(p_rec in pay_pap_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
    pay_pap_rkd.after_delete
      (
  p_accrual_plan_id               =>p_rec.accrual_plan_id
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
        ,p_hook_type   => 'AD');
      --
  end;
  --
  -- End of API User Hook for post_delete.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec	      in pay_pap_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pay_pap_shd.lck
	(
	p_rec.accrual_plan_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  pay_pap_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete(p_rec);
  --
  -- Delete the row.
  --
  delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  post_delete(p_rec);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_accrual_plan_id                    in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  pay_pap_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.accrual_plan_id:= p_accrual_plan_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pay_pap_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pay_pap_del;

/
