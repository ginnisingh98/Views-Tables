--------------------------------------------------------
--  DDL for Package Body PQP_AAT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_AAT_INS" as
/* $Header: pqaatrhi.pkb 120.2.12010000.3 2009/07/01 10:58:37 dchindar ship $ */
--
-- ---------------------------------------------------------------------------+
-- |                     Private Global Definitions                           |
-- ---------------------------------------------------------------------------+
--
g_package  varchar2(33) := '  pqp_aat_ins.';  -- Global package name
--
-- ---------------------------------------------------------------------------+
-- |----------------------------< dt_insert_dml >-----------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic for datetrack. The
--   functions of this procedure are as follows:
--   1) Get the object_version_number.
--   2) To set the effective start and end dates to the corresponding
--      validation start and end dates. Also, the object version number
--      record attribute is set.
--   3) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   4) To insert the row into the schema with the derived effective start
--      and end dates and the object version number.
--   5) To trap any constraint violations that may have occurred.
--   6) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   insert_dml and pre_update (logic permitting) procedure and must have
--   all mandatory arguments set.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure dt_insert_dml
  (p_rec                     in out nocopy pqp_aat_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
-- Cursor to select 'old' created AOL who column values
--
  Cursor C_Sel1 Is
    select t.created_by,
           t.creation_date
    from   pqp_assignment_attributes_f t
    where  t.assignment_attribute_id       = p_rec.assignment_attribute_id
    and    t.effective_start_date =
             pqp_aat_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc                varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          pqp_assignment_attributes_f.created_by%TYPE;
  l_creation_date       pqp_assignment_attributes_f.creation_date%TYPE;
  l_last_update_date    pqp_assignment_attributes_f.last_update_date%TYPE;
  l_last_updated_by     pqp_assignment_attributes_f.last_updated_by%TYPE;
  l_last_update_login   pqp_assignment_attributes_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
      (p_base_table_name => 'pqp_assignment_attributes_f'
      ,p_base_key_column => 'assignment_attribute_id'
      ,p_base_key_value  => p_rec.assignment_attribute_id
      );
  --
  -- Set the effective start and end dates to the corresponding
  -- validation start and end dates
  --
  p_rec.effective_start_date := p_validation_start_date;
  p_rec.effective_end_date   := p_validation_end_date;
  --
  -- If the datetrack_mode is not INSERT then we must populate the WHO
  -- columns with the 'old' creation values and 'new' updated values.
  --
  If (p_datetrack_mode <> hr_api.g_insert) then
    hr_utility.set_location(l_proc, 10);
    --
    -- Select the 'old' created values
    --
    Open C_Sel1;
    Fetch C_Sel1 Into l_created_by, l_creation_date;
    If C_Sel1%notfound Then
      --
      -- The previous 'old' created row has not been found. We need
      -- to error as an internal datetrack problem exists.
      --
      Close C_Sel1;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    End If;
    Close C_Sel1;
    --
    -- Set the AOL updated WHO values
    --
    l_last_update_date   := sysdate;
    l_last_updated_by    := fnd_global.user_id;
    l_last_update_login  := fnd_global.login_id;
  End If;
  --
  pqp_aat_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pqp_assignment_attributes_f
  --
  insert into pqp_assignment_attributes_f
      (assignment_attribute_id
      ,effective_start_date
      ,effective_end_date
      ,business_group_id
      ,assignment_id
      ,contract_type
      ,work_pattern
      ,start_day
      ,object_version_number
      ,primary_company_car
      ,primary_car_fuel_benefit
      ,primary_class_1a
      ,primary_capital_contribution
      ,primary_private_contribution
      ,secondary_company_car
      ,secondary_car_fuel_benefit
      ,secondary_class_1a
      ,secondary_capital_contribution
      ,secondary_private_contribution
      ,company_car_calc_method
      ,company_car_rates_table_id
      ,company_car_secondary_table_id
      ,private_car
      ,private_car_calc_method
      ,private_car_rates_table_id
      ,private_car_essential_table_id
      ,tp_is_teacher
      ,tp_headteacher_grp_code --added for head Teacher seconded location for salary scale calculation
      ,tp_safeguarded_grade
      ,tp_safeguarded_grade_id
      ,tp_safeguarded_rate_type
      ,tp_safeguarded_rate_id
      ,tp_safeguarded_spinal_point_id
      ,tp_elected_pension
      ,tp_fast_track
      ,aat_attribute_category
      ,aat_attribute1
      ,aat_attribute2
      ,aat_attribute3
      ,aat_attribute4
      ,aat_attribute5
      ,aat_attribute6
      ,aat_attribute7
      ,aat_attribute8
      ,aat_attribute9
      ,aat_attribute10
      ,aat_attribute11
      ,aat_attribute12
      ,aat_attribute13
      ,aat_attribute14
      ,aat_attribute15
      ,aat_attribute16
      ,aat_attribute17
      ,aat_attribute18
      ,aat_attribute19
      ,aat_attribute20
      ,aat_information_category
      ,aat_information1
      ,aat_information2
      ,aat_information3
      ,aat_information4
      ,aat_information5
      ,aat_information6
      ,aat_information7
      ,aat_information8
      ,aat_information9
      ,aat_information10
      ,aat_information11
      ,aat_information12
      ,aat_information13
      ,aat_information14
      ,aat_information15
      ,aat_information16
      ,aat_information17
      ,aat_information18
      ,aat_information19
      ,aat_information20
	,lgps_process_flag
	,lgps_exclusion_type
	,lgps_pensionable_pay
	,lgps_trans_arrang_flag
	,lgps_membership_number
      ,created_by
      ,creation_date
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      )
  Values
    (p_rec.assignment_attribute_id
    ,p_rec.effective_start_date
    ,p_rec.effective_end_date
    ,p_rec.business_group_id
    ,p_rec.assignment_id
    ,p_rec.contract_type
    ,p_rec.work_pattern
    ,p_rec.start_day
    ,p_rec.object_version_number
    ,p_rec.primary_company_car
    ,p_rec.primary_car_fuel_benefit
    ,p_rec.primary_class_1a
    ,p_rec.primary_capital_contribution
    ,p_rec.primary_private_contribution
    ,p_rec.secondary_company_car
    ,p_rec.secondary_car_fuel_benefit
    ,p_rec.secondary_class_1a
    ,p_rec.secondary_capital_contribution
    ,p_rec.secondary_private_contribution
    ,p_rec.company_car_calc_method
    ,p_rec.company_car_rates_table_id
    ,p_rec.company_car_secondary_table_id
    ,p_rec.private_car
    ,p_rec.private_car_calc_method
    ,p_rec.private_car_rates_table_id
    ,p_rec.private_car_essential_table_id
    ,p_rec.tp_is_teacher
    ,p_rec.tp_headteacher_grp_code --added for head Teacher seconded location for salary scale calculation
    ,p_rec.tp_safeguarded_grade
    ,p_rec.tp_safeguarded_grade_id
    ,p_rec.tp_safeguarded_rate_type
    ,p_rec.tp_safeguarded_rate_id
    ,p_rec.tp_safeguarded_spinal_point_id
    ,p_rec.tp_elected_pension
    ,p_rec.tp_fast_track
    ,p_rec.aat_attribute_category
    ,p_rec.aat_attribute1
    ,p_rec.aat_attribute2
    ,p_rec.aat_attribute3
    ,p_rec.aat_attribute4
    ,p_rec.aat_attribute5
    ,p_rec.aat_attribute6
    ,p_rec.aat_attribute7
    ,p_rec.aat_attribute8
    ,p_rec.aat_attribute9
    ,p_rec.aat_attribute10
    ,p_rec.aat_attribute11
    ,p_rec.aat_attribute12
    ,p_rec.aat_attribute13
    ,p_rec.aat_attribute14
    ,p_rec.aat_attribute15
    ,p_rec.aat_attribute16
    ,p_rec.aat_attribute17
    ,p_rec.aat_attribute18
    ,p_rec.aat_attribute19
    ,p_rec.aat_attribute20
    ,p_rec.aat_information_category
    ,p_rec.aat_information1
    ,p_rec.aat_information2
    ,p_rec.aat_information3
    ,p_rec.aat_information4
    ,p_rec.aat_information5
    ,p_rec.aat_information6
    ,p_rec.aat_information7
    ,p_rec.aat_information8
    ,p_rec.aat_information9
    ,p_rec.aat_information10
    ,p_rec.aat_information11
    ,p_rec.aat_information12
    ,p_rec.aat_information13
    ,p_rec.aat_information14
    ,p_rec.aat_information15
    ,p_rec.aat_information16
    ,p_rec.aat_information17
    ,p_rec.aat_information18
    ,p_rec.aat_information19
    ,p_rec.aat_information20
    ,p_rec.lgps_process_flag
    ,p_rec.lgps_exclusion_type
    ,p_rec.lgps_pensionable_pay
    ,p_rec.lgps_trans_arrang_flag
    ,p_rec.lgps_membership_number
    ,l_created_by
    ,l_creation_date
    ,l_last_update_date
    ,l_last_updated_by
    ,l_last_update_login
    );
  --
  pqp_aat_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqp_aat_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_aat_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqp_aat_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_aat_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqp_aat_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ---------------------------------------------------------------------------+
-- |------------------------------< insert_dml >------------------------------|
-- ---------------------------------------------------------------------------+
Procedure insert_dml
  (p_rec                   in out nocopy pqp_aat_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pqp_aat_ins.dt_insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_dml;
--
-- ---------------------------------------------------------------------------+
-- |------------------------------< pre_insert >------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--   Also, if comments are defined for this entity, the comments insert
--   logic will also be called, generating a comment_id if required.
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
-- ---------------------------------------------------------------------------+
Procedure pre_insert
  (p_rec                   in out nocopy pqp_aat_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pqp_assignment_attributes_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.assignment_attribute_id;
  Close C_Sel1;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ---------------------------------------------------------------------------+
-- |----------------------------< post_insert >-------------------------------|
-- ---------------------------------------------------------------------------+
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure post_insert
  (p_rec                   in pqp_aat_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqp_aat_rki.after_insert
      (p_effective_date
      => p_effective_date
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_assignment_attribute_id
      => p_rec.assignment_attribute_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_contract_type
      => p_rec.contract_type
      ,p_work_pattern
      => p_rec.work_pattern
      ,p_start_day
      => p_rec.start_day
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_primary_company_car
      => p_rec.primary_company_car
      ,p_primary_car_fuel_benefit
      => p_rec.primary_car_fuel_benefit
      ,p_primary_class_1a
      => p_rec.primary_class_1a
      ,p_primary_capital_contribution
      => p_rec.primary_capital_contribution
      ,p_primary_private_contribution
      => p_rec.primary_private_contribution
      ,p_secondary_company_car
      => p_rec.secondary_company_car
      ,p_secondary_car_fuel_benefit
      => p_rec.secondary_car_fuel_benefit
      ,p_secondary_class_1a
      => p_rec.secondary_class_1a
      ,p_secondary_capital_contributi
      => p_rec.secondary_capital_contribution
      ,p_secondary_private_contributi
      => p_rec.secondary_private_contribution
      ,p_company_car_calc_method
      => p_rec.company_car_calc_method
      ,p_company_car_rates_table_id
      => p_rec.company_car_rates_table_id
      ,p_company_car_secondary_table
      => p_rec.company_car_secondary_table_id
      ,p_private_car
      => p_rec.private_car
      ,p_private_car_calc_method
      => p_rec.private_car_calc_method
      ,p_private_car_rates_table_id
      => p_rec.private_car_rates_table_id
      ,p_private_car_essential_table
      => p_rec.private_car_essential_table_id
      ,p_tp_is_teacher
      => p_rec.tp_is_teacher
       ,p_tp_headteacher_grp_code  --added for head Teacher seconded location for salary scale calculation
      => p_rec.tp_headteacher_grp_code
      ,p_tp_safeguarded_grade
      => p_rec.tp_safeguarded_grade
      ,p_tp_safeguarded_grade_id
      => p_rec.tp_safeguarded_grade_id
      ,p_tp_safeguarded_rate_type
      => p_rec.tp_safeguarded_rate_type
      ,p_tp_safeguarded_rate_id
      => p_rec.tp_safeguarded_rate_id
      ,p_tp_spinal_point_id
      => p_rec.tp_safeguarded_spinal_point_id
      ,p_tp_elected_pension
      => p_rec.tp_elected_pension
      ,p_tp_fast_track
      => p_rec.tp_fast_track
      ,p_aat_attribute_category
      => p_rec.aat_attribute_category
      ,p_aat_attribute1
      => p_rec.aat_attribute1
      ,p_aat_attribute2
      => p_rec.aat_attribute2
      ,p_aat_attribute3
      => p_rec.aat_attribute3
      ,p_aat_attribute4
      => p_rec.aat_attribute4
      ,p_aat_attribute5
      => p_rec.aat_attribute5
      ,p_aat_attribute6
      => p_rec.aat_attribute6
      ,p_aat_attribute7
      => p_rec.aat_attribute7
      ,p_aat_attribute8
      => p_rec.aat_attribute8
      ,p_aat_attribute9
      => p_rec.aat_attribute9
      ,p_aat_attribute10
      => p_rec.aat_attribute10
      ,p_aat_attribute11
      => p_rec.aat_attribute11
      ,p_aat_attribute12
      => p_rec.aat_attribute12
      ,p_aat_attribute13
      => p_rec.aat_attribute13
      ,p_aat_attribute14
      => p_rec.aat_attribute14
      ,p_aat_attribute15
      => p_rec.aat_attribute15
      ,p_aat_attribute16
      => p_rec.aat_attribute16
      ,p_aat_attribute17
      => p_rec.aat_attribute17
      ,p_aat_attribute18
      => p_rec.aat_attribute18
      ,p_aat_attribute19
      => p_rec.aat_attribute19
      ,p_aat_attribute20
      => p_rec.aat_attribute20
      ,p_aat_information_category
      => p_rec.aat_information_category
      ,p_aat_information1
      => p_rec.aat_information1
      ,p_aat_information2
      => p_rec.aat_information2
      ,p_aat_information3
      => p_rec.aat_information3
      ,p_aat_information4
      => p_rec.aat_information4
      ,p_aat_information5
      => p_rec.aat_information5
      ,p_aat_information6
      => p_rec.aat_information6
      ,p_aat_information7
      => p_rec.aat_information7
      ,p_aat_information8
      => p_rec.aat_information8
      ,p_aat_information9
      => p_rec.aat_information9
      ,p_aat_information10
      => p_rec.aat_information10
      ,p_aat_information11
      => p_rec.aat_information11
      ,p_aat_information12
      => p_rec.aat_information12
      ,p_aat_information13
      => p_rec.aat_information13
      ,p_aat_information14
      => p_rec.aat_information14
      ,p_aat_information15
      => p_rec.aat_information15
      ,p_aat_information16
      => p_rec.aat_information16
      ,p_aat_information17
      => p_rec.aat_information17
      ,p_aat_information18
      => p_rec.aat_information18
      ,p_aat_information19
      => p_rec.aat_information19
      ,p_aat_information20
      => p_rec.aat_information20
	,p_lgps_process_flag
      => p_rec.lgps_process_flag
      ,p_lgps_exclusion_type
      => p_rec.lgps_exclusion_type
      ,p_lgps_pensionable_pay
      => p_rec.lgps_pensionable_pay
      ,p_lgps_trans_arrang_flag
      => p_rec.lgps_trans_arrang_flag
      ,p_lgps_membership_number
      => p_rec.lgps_membership_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_ASSIGNMENT_ATTRIBUTES_F'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ---------------------------------------------------------------------------+
-- |-------------------------------< ins_lck >--------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   The ins_lck process has one main function to perform. When inserting
--   a datetracked row, we must validate the DT mode.
--
-- Prerequisites:
--   This procedure can only be called for the datetrack mode of INSERT.
--
-- In Parameters:
--
-- Post Success:
--   On successful completion of the ins_lck process the parental
--   datetracked rows will be locked providing the p_enforce_foreign_locking
--   argument value is TRUE.
--   If the p_enforce_foreign_locking argument value is FALSE then the
--   parential rows are not locked.
--
-- Post Failure:
--   The Lck process can fail for:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) When attempting to the lock the parent which doesn't exist.
--      For the entity to be locked the parent must exist!
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure ins_lck
  (p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_rec                   in pqp_aat_shd.g_rec_type
  ,p_validation_start_date out nocopy date
  ,p_validation_end_date   out nocopy date
  ) is
--
  l_proc                  varchar2(72) := g_package||'ins_lck';
  l_validation_start_date date;
  l_validation_end_date   date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate the datetrack mode mode getting the validation start
  -- and end dates for the specified datetrack operation.
  --
  dt_api.validate_dt_mode
    (p_effective_date          => p_effective_date
    ,p_datetrack_mode          => p_datetrack_mode
    ,p_base_table_name         => 'pqp_assignment_attributes_f'
    ,p_base_key_column         => 'assignment_attribute_id'
    ,p_base_key_value          => p_rec.assignment_attribute_id
    ,p_enforce_foreign_locking => true
    ,p_validation_start_date   => l_validation_start_date
    ,p_validation_end_date     => l_validation_end_date
    );
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End ins_lck;
--
-- ---------------------------------------------------------------------------+
-- |---------------------------------< ins >----------------------------------|
-- ---------------------------------------------------------------------------+
Procedure ins
  (p_effective_date in     date
  ,p_rec            in out nocopy pqp_aat_shd.g_rec_type
  ) is
--
  l_proc                        varchar2(72) := g_package||'ins';
  l_datetrack_mode              varchar2(30) := hr_api.g_insert;
  l_validation_start_date       date;
  l_validation_end_date         date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the lock operation
  --
  pqp_aat_ins.ins_lck
    (p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_rec                   => p_rec
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting insert validate operations
  --
  pqp_aat_bus.insert_validate
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting pre-insert operation
  --
  pqp_aat_ins.pre_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Insert the row
  --
  pqp_aat_ins.insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting post-insert operation
  --
  pqp_aat_ins.post_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
end ins;
--
-- ---------------------------------------------------------------------------+
-- |---------------------------------< ins >----------------------------------|
-- ---------------------------------------------------------------------------+
Procedure ins
  (p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_assignment_id                  in     number
  ,p_contract_type                  in     varchar2 default null
  ,p_work_pattern                   in     varchar2 default null
  ,p_start_day                      in     varchar2 default null
  ,p_primary_company_car            in     number   default null
  ,p_primary_car_fuel_benefit       in     varchar2 default null
  ,p_primary_class_1a               in     varchar2 default null
  ,p_primary_capital_contribution   in     number   default null
  ,p_primary_private_contribution   in     number   default null
  ,p_secondary_company_car          in     number   default null
  ,p_secondary_car_fuel_benefit     in     varchar2 default null
  ,p_secondary_class_1a             in     varchar2 default null
  ,p_secondary_capital_contributi   in     number   default null
  ,p_secondary_private_contributi   in     number   default null
  ,p_company_car_calc_method        in     varchar2 default null
  ,p_company_car_rates_table_id     in     number   default null
  ,p_company_car_secondary_table    in     number   default null
  ,p_private_car                    in     number   default null
  ,p_private_car_calc_method        in     varchar2 default null
  ,p_private_car_rates_table_id     in     number   default null
  ,p_private_car_essential_table    in     number   default null
  ,p_tp_is_teacher                  in     varchar2 default null
  ,p_tp_headteacher_grp_code	    in     number   default null --added for head Teacher seconded location for salary scale calculation
  ,p_tp_safeguarded_grade           in     varchar2 default null
  ,p_tp_safeguarded_grade_id        in     number   default null
  ,p_tp_safeguarded_rate_type       in     varchar2 default null
  ,p_tp_safeguarded_rate_id         in     number   default null
  ,p_tp_spinal_point_id             in     number   default null
  ,p_tp_elected_pension             in     varchar2 default null
  ,p_tp_fast_track                  in     varchar2 default null
  ,p_aat_attribute_category         in     varchar2 default null
  ,p_aat_attribute1                 in     varchar2 default null
  ,p_aat_attribute2                 in     varchar2 default null
  ,p_aat_attribute3                 in     varchar2 default null
  ,p_aat_attribute4                 in     varchar2 default null
  ,p_aat_attribute5                 in     varchar2 default null
  ,p_aat_attribute6                 in     varchar2 default null
  ,p_aat_attribute7                 in     varchar2 default null
  ,p_aat_attribute8                 in     varchar2 default null
  ,p_aat_attribute9                 in     varchar2 default null
  ,p_aat_attribute10                in     varchar2 default null
  ,p_aat_attribute11                in     varchar2 default null
  ,p_aat_attribute12                in     varchar2 default null
  ,p_aat_attribute13                in     varchar2 default null
  ,p_aat_attribute14                in     varchar2 default null
  ,p_aat_attribute15                in     varchar2 default null
  ,p_aat_attribute16                in     varchar2 default null
  ,p_aat_attribute17                in     varchar2 default null
  ,p_aat_attribute18                in     varchar2 default null
  ,p_aat_attribute19                in     varchar2 default null
  ,p_aat_attribute20                in     varchar2 default null
  ,p_aat_information_category       in     varchar2 default null
  ,p_aat_information1               in     varchar2 default null
  ,p_aat_information2               in     varchar2 default null
  ,p_aat_information3               in     varchar2 default null
  ,p_aat_information4               in     varchar2 default null
  ,p_aat_information5               in     varchar2 default null
  ,p_aat_information6               in     varchar2 default null
  ,p_aat_information7               in     varchar2 default null
  ,p_aat_information8               in     varchar2 default null
  ,p_aat_information9               in     varchar2 default null
  ,p_aat_information10              in     varchar2 default null
  ,p_aat_information11              in     varchar2 default null
  ,p_aat_information12              in     varchar2 default null
  ,p_aat_information13              in     varchar2 default null
  ,p_aat_information14              in     varchar2 default null
  ,p_aat_information15              in     varchar2 default null
  ,p_aat_information16              in     varchar2 default null
  ,p_aat_information17              in     varchar2 default null
  ,p_aat_information18              in     varchar2 default null
  ,p_aat_information19              in     varchar2 default null
  ,p_aat_information20              in     varchar2 default null
  ,p_lgps_process_flag              in     varchar2 default null
  ,p_lgps_exclusion_type            in     varchar2 default null
  ,p_lgps_pensionable_pay           in     varchar2 default null
  ,p_lgps_trans_arrang_flag         in     varchar2 default null
  ,p_lgps_membership_number         in     varchar2 default null
  ,p_assignment_attribute_id           out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ) is
--
  l_rec         pqp_aat_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqp_aat_shd.convert_args
    (null
    ,null
    ,null
    ,p_business_group_id
    ,p_assignment_id
    ,p_contract_type
    ,p_work_pattern
    ,p_start_day
    ,null
    ,p_primary_company_car
    ,p_primary_car_fuel_benefit
    ,p_primary_class_1a
    ,p_primary_capital_contribution
    ,p_primary_private_contribution
    ,p_secondary_company_car
    ,p_secondary_car_fuel_benefit
    ,p_secondary_class_1a
    ,p_secondary_capital_contributi
    ,p_secondary_private_contributi
    ,p_company_car_calc_method
    ,p_company_car_rates_table_id
    ,p_company_car_secondary_table
    ,p_private_car
    ,p_private_car_calc_method
    ,p_private_car_rates_table_id
    ,p_private_car_essential_table
    ,p_tp_is_teacher
    ,p_tp_headteacher_grp_code  --added for head Teacher seconded location for salary scale calculation
    ,p_tp_safeguarded_grade
    ,p_tp_safeguarded_grade_id
    ,p_tp_safeguarded_rate_type
    ,p_tp_safeguarded_rate_id
    ,p_tp_spinal_point_id
    ,p_tp_elected_pension
    ,p_tp_fast_track
    ,p_aat_attribute_category
    ,p_aat_attribute1
    ,p_aat_attribute2
    ,p_aat_attribute3
    ,p_aat_attribute4
    ,p_aat_attribute5
    ,p_aat_attribute6
    ,p_aat_attribute7
    ,p_aat_attribute8
    ,p_aat_attribute9
    ,p_aat_attribute10
    ,p_aat_attribute11
    ,p_aat_attribute12
    ,p_aat_attribute13
    ,p_aat_attribute14
    ,p_aat_attribute15
    ,p_aat_attribute16
    ,p_aat_attribute17
    ,p_aat_attribute18
    ,p_aat_attribute19
    ,p_aat_attribute20
    ,p_aat_information_category
    ,p_aat_information1
    ,p_aat_information2
    ,p_aat_information3
    ,p_aat_information4
    ,p_aat_information5
    ,p_aat_information6
    ,p_aat_information7
    ,p_aat_information8
    ,p_aat_information9
    ,p_aat_information10
    ,p_aat_information11
    ,p_aat_information12
    ,p_aat_information13
    ,p_aat_information14
    ,p_aat_information15
    ,p_aat_information16
    ,p_aat_information17
    ,p_aat_information18
    ,p_aat_information19
    ,p_aat_information20
    ,p_lgps_process_flag
    ,p_lgps_exclusion_type
    ,p_lgps_pensionable_pay
    ,p_lgps_trans_arrang_flag
    ,p_lgps_membership_number
    );
  --
  -- Having converted the arguments into the pqp_aat_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqp_aat_ins.ins
    (p_effective_date
    ,l_rec
    );
  --
  -- Set the OUT arguments.
  --
  p_assignment_attribute_id          := l_rec.assignment_attribute_id;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  p_object_version_number            := l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqp_aat_ins;

/
