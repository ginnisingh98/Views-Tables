--------------------------------------------------------
--  DDL for Package Body PQH_VLD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_VLD_INS" as
/* $Header: pqvldrhi.pkb 115.2 2002/12/13 00:33:20 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_vld_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_validation_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_validation_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  pqh_vld_ins.g_validation_id_i := p_validation_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
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
Procedure insert_dml
  (p_rec in out nocopy pqh_vld_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  --
  -- Insert the row into: pqh_fr_validations
  --
  insert into pqh_fr_validations
      (validation_id
      ,pension_fund_type_code
      ,pension_fund_id
      ,business_group_id
      ,person_id
      ,request_date
      ,completion_date
      ,previous_employer_id
      ,previously_validated_flag
      ,status
      ,employer_amount
      ,employer_currency_code
      ,employee_amount
      ,employee_currency_code
      ,deduction_per_period
      ,deduction_currency_code
      ,percent_of_salary
      ,object_version_number
      )
  Values
    (p_rec.validation_id
    ,p_rec.pension_fund_type_code
    ,p_rec.pension_fund_id
    ,p_rec.business_group_id
    ,p_rec.person_id
    ,p_rec.request_date
    ,p_rec.completion_date
    ,p_rec.previous_employer_id
    ,p_rec.previously_validated_flag
    ,p_rec.status
    ,p_rec.employer_amount
    ,p_rec.employer_currency_code
    ,p_rec.employee_amount
    ,p_rec.employee_currency_code
    ,p_rec.deduction_per_period
    ,p_rec.deduction_currency_code
    ,p_rec.percent_of_salary
    ,p_rec.object_version_number
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
Procedure pre_insert
  (p_rec  in out nocopy pqh_vld_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select pqh_fr_validations_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from pqh_fr_validations
     where validation_id =
             pqh_vld_ins.g_validation_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (pqh_vld_ins.g_validation_id_i is not null) Then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found Then
       Close C_Sel2;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','pqh_fr_validations');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.validation_id :=
      pqh_vld_ins.g_validation_id_i;
    pqh_vld_ins.g_validation_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.validation_id;
    Close C_Sel1;
  End If;
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
--   This private procedure contains any processing which is required after
--   the insert dml.
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
Procedure post_insert
  (p_effective_date               in date
  ,p_rec                          in pqh_vld_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqh_vld_rki.after_insert
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
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_FR_VALIDATIONS'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in date
  ,p_rec                          in out nocopy pqh_vld_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqh_vld_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  pqh_vld_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pqh_vld_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  pqh_vld_ins.post_insert
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in     date
  ,p_pension_fund_type_code         in     varchar2
  ,p_pension_fund_id                in     number
  ,p_business_group_id              in     number
  ,p_person_id                      in     number
  ,p_previously_validated_flag      in     varchar2
  ,p_request_date                   in     date     default null
  ,p_completion_date                in     date     default null
  ,p_previous_employer_id           in     number   default null
  ,p_status                         in     varchar2 default null
  ,p_employer_amount                in     number   default null
  ,p_employer_currency_code         in     varchar2 default null
  ,p_employee_amount                in     number   default null
  ,p_employee_currency_code         in     varchar2 default null
  ,p_deduction_per_period           in     number   default null
  ,p_deduction_currency_code        in     varchar2 default null
  ,p_percent_of_salary              in     number   default null
  ,p_validation_id                     out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   pqh_vld_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqh_vld_shd.convert_args
    (null
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
    ,null
    );
  --
  -- Having converted the arguments into the pqh_vld_rec
  -- plsql record structure we call the corresponding record business process.
  --
  pqh_vld_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_validation_id := l_rec.validation_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqh_vld_ins;

/
