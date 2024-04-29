--------------------------------------------------------
--  DDL for Package Body PAY_PAP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAP_INS" as
/* $Header: pypaprhi.pkb 120.0 2005/05/29 07:14:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_pap_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
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
Procedure insert_dml(p_rec in out nocopy pay_pap_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  pay_pap_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pay_accrual_plans
  --
  insert into pay_accrual_plans
  (	accrual_plan_id,
	business_group_id,
	accrual_plan_element_type_id,
	pto_input_value_id,
	co_input_value_id,
	residual_input_value_id,
	accrual_category,
	accrual_plan_name,
	accrual_start,
	accrual_units_of_measure,
	ineligible_period_length,
	ineligible_period_type,
	accrual_formula_id,
	co_formula_id,
	co_date_input_value_id,
	co_exp_date_input_value_id,
	residual_date_input_value_id,
	description,
        ineligibility_formula_id,
        payroll_formula_id,
        defined_balance_id,
        tagging_element_type_id,
        balance_element_type_id,
	object_version_number,
        information_category,
        information1,
        information2,
        information3,
        information4,
        information5,
        information6,
        information7,
        information8,
        information9,
        information10,
	information11,
        information12,
        information13,
        information14,
        information15,
        information16,
        information17,
        information18,
        information19,
        information20,
        information21,
        information22,
        information23,
        information24,
        information25,
        information26,
        information27,
        information28,
        information29,
        information30

  )
  Values
  (	p_rec.accrual_plan_id,
	p_rec.business_group_id,
	p_rec.accrual_plan_element_type_id,
	p_rec.pto_input_value_id,
	p_rec.co_input_value_id,
	p_rec.residual_input_value_id,
	p_rec.accrual_category,
	p_rec.accrual_plan_name,
	p_rec.accrual_start,
	p_rec.accrual_units_of_measure,
	p_rec.ineligible_period_length,
	p_rec.ineligible_period_type,
	p_rec.accrual_formula_id,
	p_rec.co_formula_id,
	p_rec.co_date_input_value_id,
	p_rec.co_exp_date_input_value_id,
	p_rec.residual_date_input_value_id,
	p_rec.description,
        p_rec.ineligibility_formula_id,
        p_rec.payroll_formula_id,
        p_rec.defined_balance_id,
        p_rec.tagging_element_type_id,
        p_rec.balance_element_type_id,
	p_rec.object_version_number,
        p_rec.information_category,
        p_rec.information1,
        p_rec.information2,
        p_rec.information3,
        p_rec.information4,
        p_rec.information5,
        p_rec.information6,
        p_rec.information7,
        p_rec.information8,
        p_rec.information9,
        p_rec.information10,
        p_rec.information11,
        p_rec.information12,
        p_rec.information13,
        p_rec.information14,
        p_rec.information15,
        p_rec.information16,
        p_rec.information17,
        p_rec.information18,
        p_rec.information19,
        p_rec.information20,
        p_rec.information21,
        p_rec.information22,
        p_rec.information23,
        p_rec.information24,
        p_rec.information25,
        p_rec.information26,
        p_rec.information27,
        p_rec.information28,
        p_rec.information29,
        p_rec.information30

  );
  --
  pay_pap_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy pay_pap_shd.g_rec_type) is
--
  l_proc                      varchar2(72) := g_package||'pre_insert';

  Cursor C_Sel1 is select pay_accrual_plans_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.accrual_plan_id;
  Close C_Sel1;
  --

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec             in pay_pap_shd.g_rec_type) is
--
  l_proc                      varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    pay_pap_rki.after_insert
      (
  p_accrual_plan_id               =>p_rec.accrual_plan_id
 ,p_business_group_id             =>p_rec.business_group_id
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
 ,p_information_category	  =>p_rec.information_category
 ,p_information1		  =>p_rec.information1
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
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pay_accrual_plans'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE ins
  (p_effective_date   IN     DATE
  ,p_rec              IN OUT NOCOPY pay_pap_shd.g_rec_type
  ,p_check_accrual_ff    OUT NOCOPY BOOLEAN)
IS

  l_proc  varchar2(72) := g_package||'ins';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Call the supporting insert validate operations
  --
  pay_pap_bus.insert_validate
    (p_effective_date   => p_effective_date
    ,p_rec              => p_rec
    ,p_check_accrual_ff => p_check_accrual_ff);

  hr_utility.set_location(l_proc, 20);

  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec);

  hr_utility.set_location(l_proc, 30);

  --
  -- Insert the row
  --
  insert_dml(p_rec);

  hr_utility.set_location(l_proc, 40);

  --
  -- Call the supporting post-insert operation
  --
  post_insert(p_rec);

  hr_utility.set_location('Leaving:'||l_proc, 50);

END ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE ins
  (p_effective_date               IN  DATE
  ,p_business_group_id            IN  NUMBER
  ,p_accrual_plan_element_type_id IN  NUMBER
  ,p_pto_input_value_id           IN  NUMBER
  ,p_co_input_value_id            IN  NUMBER
  ,p_residual_input_value_id      IN  NUMBER
  ,p_accrual_category             IN  VARCHAR2
  ,p_accrual_plan_name            IN  VARCHAR2
  ,p_accrual_units_of_measure     IN  VARCHAR2
  ,p_accrual_start                IN  VARCHAR2 DEFAULT NULL
  ,p_ineligible_period_length     IN  NUMBER   DEFAULT NULL
  ,p_ineligible_period_type       IN  VARCHAR2 DEFAULT NULL
  ,p_accrual_formula_id           IN  NUMBER   DEFAULT NULL
  ,p_co_formula_id                IN  NUMBER   DEFAULT NULL
  ,p_co_date_input_value_id       IN  NUMBER   DEFAULT NULL
  ,p_co_exp_date_input_value_id   IN  NUMBER   DEFAULT NULL
  ,p_residual_date_input_value_id IN  NUMBER   DEFAULT NULL
  ,p_description                  IN  VARCHAR2 DEFAULT NULL
  ,p_ineligibility_formula_id     IN  NUMBER   DEFAULT NULL
  ,p_payroll_formula_id           IN  NUMBER   DEFAULT NULL
  ,p_defined_balance_id           IN  NUMBER   DEFAULT NULL
  ,p_tagging_element_type_id      IN  NUMBER   DEFAULT NULL
  ,p_balance_element_type_id      IN  NUMBER   DEFAULT NULL
  ,p_information_category         IN  VARCHAR2 DEFAULT NULL
  ,p_information1                 IN  VARCHAR2 DEFAULT NULL
  ,p_information2                 IN  VARCHAR2 DEFAULT NULL
  ,p_information3                 IN  VARCHAR2 DEFAULT NULL
  ,p_information4                 IN  VARCHAR2 DEFAULT NULL
  ,p_information5                 IN  VARCHAR2 DEFAULT NULL
  ,p_information6                 IN  VARCHAR2 DEFAULT NULL
  ,p_information7                 IN  VARCHAR2 DEFAULT NULL
  ,p_information8                 IN  VARCHAR2 DEFAULT NULL
  ,p_information9                 IN  VARCHAR2 DEFAULT NULL
  ,p_information10                IN  VARCHAR2 DEFAULT NULL
  ,p_information11                IN  VARCHAR2 DEFAULT NULL
  ,p_information12                IN  VARCHAR2 DEFAULT NULL
  ,p_information13                IN  VARCHAR2 DEFAULT NULL
  ,p_information14                IN  VARCHAR2 DEFAULT NULL
  ,p_information15                IN  VARCHAR2 DEFAULT NULL
  ,p_information16                IN  VARCHAR2 DEFAULT NULL
  ,p_information17                IN  VARCHAR2 DEFAULT NULL
  ,p_information18                IN  VARCHAR2 DEFAULT NULL
  ,p_information19                IN  VARCHAR2 DEFAULT NULL
  ,p_information20                IN  VARCHAR2 DEFAULT NULL
  ,p_information21                IN  VARCHAR2 DEFAULT NULL
  ,p_information22                IN  VARCHAR2 DEFAULT NULL
  ,p_information23                IN  VARCHAR2 DEFAULT NULL
  ,p_information24                IN  VARCHAR2 DEFAULT NULL
  ,p_information25                IN  VARCHAR2 DEFAULT NULL
  ,p_information26                IN  VARCHAR2 DEFAULT NULL
  ,p_information27                IN  VARCHAR2 DEFAULT NULL
  ,p_information28                IN  VARCHAR2 DEFAULT NULL
  ,p_information29                IN  VARCHAR2 DEFAULT NULL
  ,p_information30                IN  VARCHAR2 DEFAULT NULL
  ,p_accrual_plan_id              OUT NOCOPY NUMBER
  ,p_object_version_number        OUT NOCOPY NUMBER
  ,p_check_accrual_ff             OUT NOCOPY BOOLEAN)
IS

  l_rec	  pay_pap_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pay_pap_shd.convert_args
  (
  null,
  p_business_group_id,
  p_accrual_plan_element_type_id,
  p_pto_input_value_id,
  p_co_input_value_id,
  p_residual_input_value_id,
  p_accrual_category,
  p_accrual_plan_name,
  p_accrual_start,
  p_accrual_units_of_measure,
  p_ineligible_period_length,
  p_ineligible_period_type,
  p_accrual_formula_id,
  p_co_formula_id,
  p_co_date_input_value_id,
  p_co_exp_date_input_value_id,
  p_residual_date_input_value_id,
  p_description,
  p_ineligibility_formula_id,
  p_payroll_formula_id,
  p_defined_balance_id,
  p_tagging_element_type_id,
  p_balance_element_type_id,
  null,
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
  -- Having converted the arguments into the pay_pap_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins
    (p_effective_date   => p_effective_date
    ,p_rec              => l_rec
    ,p_check_accrual_ff => p_check_accrual_ff);

  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_accrual_plan_id := l_rec.accrual_plan_id;
  p_object_version_number := l_rec.object_version_number;

  hr_utility.set_location('PK = '||to_char(p_accrual_plan_id), 9);

  hr_utility.set_location(' Leaving:'||l_proc, 10);

END ins;

END pay_pap_ins;

/
